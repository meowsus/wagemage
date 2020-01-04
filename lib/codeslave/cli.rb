module Codeslave
  class CLI
    include Codeslave::Helpers

    def initialize(args)
      @options = Slop.parse(args) do |option|
        option.bool '-h', '--help', 'print this help'
        option.on '-v', '--version', 'print the version'

        option.string '-o', '--org', 'github org'
        option.string '-r', '--repo', 'regex against which to match repo names'
        option.string '-b', '--branch', 'regex against which to match branches'

        option.path '-s', '--script', "the script to run on each repo's branch"

        option.array '--reviewers', 'array of github users to put on the PR'
        option.bool '--debug', "don't push or issue PR, keep the tmp directory"
      end

      validate_options!

      token = ENV['CODESLAVE_GITHUB_TOKEN'] || request_token
      @okclient = Octokit::Client.new(access_token: token)

      @tmpdir = Dir.mktmpdir
      @script_path = @options[:script].expand_path.to_s
    end

    def run
      raise Error, 'No repos found' if repos.empty?

      say "#{repos.size} repo(s) found:", color: :green
      display_list(repos.map(&:name))

      say 'Would you like to clone these repos? (Y/n)'
      abort if ask.casecmp?('n')

      begin
        repos.each do |repo|
          say "=> Cloning #{repo.name} to #{repo.clone_dir}", space: false
          repo.clone!
        end

        repos.each do |repo|
          branches = repo.branches(@options[:branch])

          if branches.empty?
            warning("Couldn't find matching branches for '#{repo.name}'")
          else
            say "Found #{branches.size} for '#{repo.name}':", color: :green
            display_list(branches, ' - ')
          end
        end

        if @options[:debug]
          say "Debugging is enabled. Rest easy, my friend.", color: :green
          say "Would you like to continue? (Y/n)"
        else
          say <<~MESSAGE, color: :yellow
            You are about to execute the following script on every listed branch:
            => #{@script_path}

            This is a potentially dangerous action.

            Are you absolutely sure you want to do this? (Y/n)
          MESSAGE
        end
        abort if ask.casecmp?('n')

        repos.each do |repo|
          repo.branches(@options[:branch]).each do |branch|
            repo.checkout!(branch)
            repo.checkout!("codeslave/#{branch}/#{Time.now.to_i}", true)

            result = command([@script_path, repo.clone_dir, branch].join(' '))

            unless result[:status].success?
              warning("=> #{repo.name}:#{branch} | #{result[:stderr]}")
              next
            end

            unless repo.has_changed?
              warning("=> #{repo.name}:#{branch} | No changes to commit")
              next
            end

            repo.add_all!
            repo.commit!(result[:stdout])

            if @options[:debug]
              say "=> Committed to '#{repo.clone_dir}' but not pushed"
              next
            end

            repo.push!

            result = repo.pull_request!(branch, @options[:reviewers])
            say <<~MESSAGE, space: false, color: :green
              => #{repo.name}:#{branch} | #{result[:stdout]}
            MESSAGE
          end
        end
      ensure
        FileUtils.remove_entry(@tmpdir) unless @options[:debug]
      end
    end

    private

    def repos
      @repos ||= begin
        repos = @options[:org].nil? ?
          @okclient.repos :
          @okclient.org_repos(@options[:org])

        last_response = @okclient.last_response
        while last_response.rels[:next] do
          repos.concat(last_response.rels[:next].get.data)
          last_response = last_response.rels[:next].get
        end

        repos.map! { |r| Codeslave::Repo.new(r, @tmpdir) }

        return repos if @options[:repo].nil?

        repo_name_regex = Regexp.new(@options[:repo])
        repos.select { |r| r.name =~ repo_name_regex }
      end
    end

    def request_token
      say 'Github Personal Access Token missing', color: :red
      say 'Please supply it now:', space: false
      ask
    end

    def validate_options!
      abort(@options.to_s) if @options.help?
      abort("Codeslave v#{Codeslave::VERSION}") if @options.version?

      raise OptionError if @options.script.nil?
    end
  end
end
