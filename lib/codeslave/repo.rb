module Codeslave
  class Repo
    include Codeslave::Helpers

    attr_reader :clone_dir

    def initialize(info, dir)
      @info = info
      @clone_dir = [dir, info[:full_name]].join('/')
    end

    def name
      @info[:full_name]
    end

    def url
      @info[:ssh_url]
    end

    def clone!
      command("git clone #{url} #{clone_dir}", error: true)
    end

    def branches(pattern = nil)
      result = command('git branch -a', chdir: @clone_dir)

      return [] unless result[:status].success?

      branch_list =
        result[:stdout]
          .split("\n")
          .select { |b| b.include?('remotes/origin/') }
          .reject { |b| b.include?('->') }
          .map { |b| b.split('/')[2..-1].join('/') }

      return branch_list if pattern.nil?

      branch_name_regex = Regexp.new(pattern)
      branch_list.select { |b| b =~ branch_name_regex }
    end

    def checkout!(ref, create = false)
      cmd = create ? "git checkout -b #{ref}" : "git checkout #{ref}"
      command(cmd, chdir: @clone_dir)
    end

    def add_all!
      command('git add .', chdir: @clone_dir)
    end

    def commit!(message)
      command(%Q[git commit -m "#{message}"], chdir: @clone_dir)
    end

    def push!
      command('git push origin HEAD', chdir: @clone_dir)
    end

    def pull_request!(base_branch, reviewers = [])
      cmd = "hub pull-request --no-edit -b #{base_branch}"
      cmd = [cmd, '-r', reviewers.join(',')].join(' ') unless reviewers.empty?

      command(cmd, chdir: @clone_dir)
    end

    def has_changed?
      result = command('git status -s', chdir: @clone_dir)
      !result[:stdout].empty?
    end
  end
end
