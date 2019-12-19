module Codeslave
  class CLI
    def initialize(args)
      @options = Slop.parse(args) do |option|
        option.string '-o', '--org', 'github org'
        option.string '-r', '--repo', "regex against which to match repo names"
        option.bool '-h', '--help', 'print this help'
        option.on '-v', '--version', 'print the version'
      end

      validate_options!

      token = ENV['CODESLAVE_GITHUB_TOKEN'] || request_token
      @okclient = Octokit::Client.new(access_token: token)
    end

    def run
      repos
      require 'pry'; binding.pry
    end

    private

    def repos
      @repos ||= begin
        repos = @options[:org].nil? ?
          @okclient.repos :
          @okclient.org_repos(@options[:org])

        last_response = @okclient.last_response
        while last_response.rels[:next] do
          repos.concat last_response.rels[:next].get.data
          last_response = last_response.rels[:next].get
        end

        repos
          .reject { |r| Regexp.new(@options[:repo]).match(r[:name]).nil? }
          .map { |r| Codeslave::Repo.new(r) }
      end
    end

    def request_token
      puts 'Github Personal Access Token missing'.colorize(:red)
      puts 'Please supply it now:'

      STDIN.gets.chomp
    end

    def validate_options!
      abort(@options) if @options.help?
      abort("Codeslave v#{Codeslave::VERSION}") if @options.version?
    end
  end
end
