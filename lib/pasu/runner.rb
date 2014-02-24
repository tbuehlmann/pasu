module Pasu
  class Runner
    def initialize
      OptionParser.new do |p|
        p.banner = 'Usage: pasu [options]'

        p.separator ''
        p.separator 'Options:'

        p.on('-v', '--version', 'Print version.') do
          puts "Pasu #{VERSION} (https://github.com/tbuehlmann/pasu)"
          exit
        end

        p.on('-d', '--directory DIRECTORY', 'Set the base directory for listing files. (Default: pwd)') do |dir|
          directory = Pathname.new(dir).expand_path

          if directory.directory?
            options[:directory] = directory
          else
            puts "Couldn't find directory #{dir}"
            exit 1
          end
        end

        p.on('--no-recursion', "Don't recursively list directories. (Default: false)") do
          options[:recursive] = false
        end

        p.on('-u', '--upload', 'Allow uploading of files. (Default: false)') do
          options[:upload] = true
        end

        p.on('--basic-auth USER:PW', 'Only allowing requests with valid user/pw combination provided. (Default: None)') do |access|
          username, password = access.split(':')
          options[:basic_auth] ||= {}
          options[:basic_auth][username] = password
        end

        p.on('-b', '--bind HOST', 'Bind the server to the given host. (Default: 0.0.0.0)') do |host|
          options[:host] = host
        end

        p.on('-p', '--port PORT', 'Bind the server to the given port. (Default: 8080)') do |port|
          options[:port] = Integer(port)
        end

        p.on('-s', '--server RACK_HANDLER', 'Use your own rack handler. (Default: Puma)') do |handler|
          options[:handler] = handler
        end

        p.on_tail('-h', '--help', 'Show this message.') do
          puts p
          exit
        end
      end.parse!
    end

    def options
      @options ||= {}
    end

    def run
      Pasu::Application.setup(options)

      begin
        Pasu::Application.run
      rescue Errno::EADDRINUSE
        puts "Port #{options[:port]} is already in use. Quitting."
      end
    end
  end
end
