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
        option.string(
          '--branch-prefix',
          'prefix of the new branch',
          default: 'codeslave'
        )

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

      say "#{repos.size} repo(s) found:", space: true
      repos.each { |r| say "* #{r.name}", color: :green }

      say 'Would you like to clone these repos? (Y/n)', space: true
      abort if ask.casecmp?('n')

      begin
        clone_repos
        display_branch_list

        say <<~MESSAGE, space: true, color: :yellow
          You're about to run this script against the aforementioned list:
          => #{@script_path}
        MESSAGE

        say "Would you like to execute this script? (Y/n)"
        abort if ask.casecmp?('n')

        repos.each do |repo|
          repo.branches.each do |branch|
            new_branch = [
              @options[:branch_prefix],
              branch,
              Time.now.to_i
            ].join('/')

            repo.checkout! branch
            repo.checkout! new_branch, create: true

            say "=> Running script on #{repo.name}:#{new_branch}"
            script_result = command(
              [@script_path, repo.clone_dir, repo.name, branch].join(' ')
            )

            if script_result[:status].success? && !repo.has_changed?
              say 'SCRIPT SUCCEEDED BUT NO CHANGES TO COMMIT!', color: :yellow
              next
            elsif !script_result[:status].success?
              say 'SCRIPT FAILED!', color: :red
              next
            end

            say 'SCRIPT SUCCEEDED! COMMITTING CHANGES!', color: :green

            repo.add_all!
            repo.commit! script_result[:stdout]

            if @options[:debug]
              say 'DEBUG ENABLED! SKIPPING PUSH & PULL REQUEST!', color: :yellow
              next
            end

            repo.push!

            pr_result = repo.pull_request!(branch, @options[:reviewers])

            if pr_result[:status].success?
              say "=> PULL REQUEST URL: #{pr_result[:stdout]}", color: :green
            else
              say "=> PULL REQUEST FAILED!", color: :red
            end
          end
        end
      ensure
        if @options[:debug]
          say <<~MESSAGE, space: :true, color: :yellow
            The temporary directory has been retained because you have specified
            the --debug flag. You can view it here:
            => #{@tmpdir}
          MESSAGE
        else
          FileUtils.remove_entry(@tmpdir)
        end
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

        repos.map! { |r| Codeslave::Repo.new(r, @tmpdir, @options[:branch]) }

        return repos if @options[:repo].nil?

        repo_name_regex = Regexp.new(@options[:repo])
        repos.select { |r| r.name =~ repo_name_regex }
      end
    end

    def clone_repos
      repos.each do |repo|
        say "=> Cloning #{repo.name} to #{repo.clone_dir}", color: :light_blue
        repo.clone!
      end
    end

    def display_branch_list
      repos.each do |repo|
        say "* #{repo.name}:", space: true

        if repo.branches.empty?
          say ' - NONE FOUND', color: :red
          next
        end

        repo.branches.each { |b| say " - #{b}", color: :green }
      end
    end

    def request_token
      say 'Github Personal Access Token missing', color: :red
      say 'Please supply it now:'
      ask
    end

    def validate_options!
      abort(@options.to_s) if @options.help?
      abort("Codeslave v#{Codeslave::VERSION}") if @options.version?

      raise OptionError if @options[:script].nil?
    end
  end
end
