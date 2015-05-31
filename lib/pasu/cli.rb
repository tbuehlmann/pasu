require 'optparse'
require 'pathname'

require 'pasu'

module Pasu
  class CLI
    class << self
      def start
        configure_application
        run_application
      end

      private

      def configure_application
        arguments = parser.parse!

        if path = arguments.first
          directory = Pathname.new(path).expand_path

          if directory.directory?
            app.settings[:directory] = directory
          else
            puts "Couldn't find directory: #{directory}"
            exit 1
          end
        end
      end

      def run_application
        require 'pasu'

        begin
          Pasu::Application.run
        rescue Errno::EADDRINUSE
          warn 'Port #{Pasu::Application.settings[:port]} is already in use. Quitting.'
          exit 1
        end
      end

      def app
        Pasu::Application
      end

      def parser
        OptionParser.new do |p|
          p.banner = 'Usage: pasu [<directory>] [options]'

          p.separator ''
          p.separator 'Options:'

          p.on '-h', '--host <host>', 'Bind the server to a given host (default: 0.0.0.0)' do |host|
            app.settings[:host] = host
          end

          p.on '-p', '--port <port>', 'Bind the server to a given port (default: 8080)' do |port|
            app.settings[:port] = Integer(port)
          end

          p.on '--no-recursion', 'Recursively list directories (default: true)' do
            app.settings[:recursive] = false
          end

          p.on '--no-dotfiles', 'List dotfiles (default: true)' do
            app.settings[:dotfiles] = false
          end

          p.on '-u', '--upload', 'Allow file uploads (default: false)' do
            app.settings[:upload] = true
          end

          p.on '-b', '--basic-auth <user>:<pw>', 'Only allow requests for a certain user/password combination (default: none)' do |auth|
            username, password = auth.split(':')
            app.settings[:basic_auth][username] = password
          end

          p.on '-v', '--version', 'Print the version' do
            puts "Pasu #{VERSION} (https://github.com/tbuehlmann/pasu)"
            exit
          end

          p.on_tail '--help', 'Show this message' do
            puts p
            exit
          end
        end
      end
    end
  end
end
