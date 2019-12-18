module Codeslave
  module Helpers
    def display_list(list, prefix = "* ")
      list.each do |item|
        puts [prefix, item].join
      end
    end

    def say(message, space: true, color: :white)
      puts if space
      puts message.colorize(color.to_sym)
    end

    def ask
      STDIN.gets.chomp
    end

    def warning(message)
      say(message, color: :red)
    end

    def command(cmd, chdir: Dir.pwd, error: false)
      stdout, stderr, status = Open3.capture3(cmd, chdir: chdir)

      unless status.success?
        error ? (raise Error, stderr) : warning(stderr)
      end

      {
        stdout: stdout,
        stderr: stderr,
        status: status
      }
    end
  end
end
