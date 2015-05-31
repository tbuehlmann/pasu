require 'pathname'

require 'cuba'
require 'cuba/render'
require 'cuba/flash'
require 'cuba/send_file'
require 'puma'
require 'slim'

require 'pasu/store'
require 'pasu/store/directory'
require 'pasu/store/file'

module Pasu
  class Application < Cuba
    use Rack::Session::Cookie, secret: 'santa_does_not_exist'
    use Cuba::Flash

    plugin SendFile
    plugin Cuba::Render

    settings[:render][:template_engine]  = :slim
    settings[:render][:options][:pretty] = true
    settings[:render][:views] = Pathname.new(__dir__).join('..', '..', 'views')

    settings[:directory] = Pathname.pwd
    settings[:recursive] = true
    settings[:dotfiles] = true
    settings[:upload] = false
    settings[:basic_auth] = {}
    settings[:host] = '0.0.0.0'
    settings[:port] = 8080

    class << self
      def run
        setup_store
        setup_basic_auth

        Rack::Handler.get('Puma').run(self, Host: settings[:host], Port: settings[:port], Verbose: true)
      end

      private

      def setup_store
        settings[:store] = Store.new(settings[:directory], recursive: settings[:recursive], dotfiles: settings[:dotfiles])
      end

      def setup_basic_auth
        if settings[:basic_auth].any?
          use Rack::Auth::Basic do |username, password|
            settings[:basic_auth][username] == password
          end
        end
      end
    end

    define do
      on get do
        on root do
          @directory = settings[:store].root_directory
          res.write view(:directory)
        end

        on /files\/(.*)/ do |escaped_path|
          path = unescape_path(escaped_path)
          object = settings[:store].find(path)

          case object
          when Store::Directory
            @directory = object
            res.write view(:directory)
          when Store::File
            send_file(object.filesystem_path)
          else
            flash[:alert] = 'Could not find file: %s' % path
            res.redirect '/'
          end
        end
      end

      on post do
        on upload_allowed do
          on /files\/(.*)/ do |escaped_path|
            path = unescape_path(escaped_path)
            directory = settings[:store].find(path)

            if directory.kind_of?(Store::Directory)
              file = settings[:store].create_file(path, req.params['file'][:filename], req.params['file'][:tempfile])

              if file
                flash[:alert] = 'File saved'
                res.redirect req.path
              else
                flash[:alert] = 'Something went wrong'
                res.redirect '/'
              end
            else
              flash[:alert] = 'Invalid upload path provided'
              res.redirect '/'
            end
          end

          on invalid_upload_path do
            flash[:alert] = 'Invalid upload path provided'
            res.redirect '/'
          end
        end

        on upload_not_allowed do
          flash[:alert] = 'Uploads are not allowed'
          res.redirect '/'
        end
      end
    end

    private

    def escape_path(path)
      file_names = path.each_filename.map do |file_name|
        Rack::Utils.escape_path(file_name)
      end.join('/')

      file_names == '.' ? '/' : "/#{file_names}"
    end

    def unescape_path(escaped_path)
      path_parts = escaped_path.split('/').map do |file_name|
        Rack::Utils.unescape(file_name)
      end

      path_parts.join('/')
    end

    def save_file(directory, file)
      path = directory.join(file[:filename])
      File.open(path, 'wb') { |f| f.write(file[:tempfile].read) }
    end

    def upload_allowed
      settings[:upload]
    end

    def upload_not_allowed
      true
    end
  end
end
