module Pasu
  class Application < Cuba
    plugin SendFile
    plugin Cuba::Render
    
    settings[:render][:template_engine] = 'slim'
    dir = File.expand_path(File.dirname(__FILE__))
    settings[:render][:views] = File.join(dir, '..', '..', 'views')

    class << self
      def setup(options = {})
        settings.merge!(default_settings)
        settings.merge!(options)
        setup_basic_auth
      end

      def default_settings
        {
          directory: Pathname.pwd,
          recursive: true,
          dotfiles: true,
          upload: false,
          basic_auth: {},
          host: '0.0.0.0',
          port: 8080,
          handler: 'Puma'
        }
      end

      def run
        rack_handler = Rack::Handler.get(settings[:handler])
        rack_handler.run(
          self,
          Host: settings[:host],
          Port: settings[:port],
          Verbose: true
        )
      end

      private

      def setup_basic_auth
        if settings[:basic_auth].any?
          use Rack::Auth::Basic do |username, password|
            settings[:basic_auth][username] == password
          end
        end
      end
    end

    define do
      on /(.*)/ do |escaped_path|
        @path = unescape_path(escaped_path)

        on get do
          on file do
            send_file(@path)
          end

          on directory do
            @files = children(@path)
            res.write view(:directory)
          end

          on file_not_found do
            res.status = 404
            res.write view(:file_not_found)
          end
        end

        on post do
          on upload_allowed do
            on directory do
              on param(:file) do |file|
                save_file(@path, file)
                res.redirect escape_path(@path.relative_path_from(settings[:directory]))
              end

              on no_file_attached do
                res.status = 400
                res.write view(:no_file_attached)
              end
            end

            on directory_not_found do
              res.status = 404
              res.write view(:directory_not_found)
            end
          end

          on upload_not_allowed do
            res.status = 401
            res.write view(:no_upload)
          end
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
      file_names = escaped_path.split('/').map do |file_name|
        Rack::Utils.unescape(file_name)
      end

      settings[:directory].join(*file_names)
    end

    def children(path)
      path.children.tap do |files|
        files.select!  { |file| (file.directory? || file.file?) && file.readable? }
        files.sort_by! { |file| [file.ftype, file.basename] }
        files.reject!  { |file| unallowed_dotfile?(file) }

        if settings[:recursive]
          if path != settings[:directory]
            files.unshift(path.parent)
          end
        else
          files.select!(&:file?)
        end
      end
    end

    def directory
      @path.directory? && @path.readable? && allowed_directory?(@path)
    end

    def file
      @path.file? && @path.readable? && allowed_directory?(@path.parent) && !unallowed_dotfile?(@path)
    end

    def allowed_directory?(directory)
      is_descendant = directory.ascend do |ascendant|
        return false if unallowed_dotfile?(ascendant)
        break(true) if ascendant == settings[:directory]
      end

      (settings[:recursive] || directory == settings[:directory]) && is_descendant
    end

    def unallowed_dotfile?(path)
      !settings[:dotfiles] && File.basename(path).start_with?('.')
    end

    # TODO: wb correct?
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

    def file_not_found
      true
    end

    def directory_not_found
      true
    end

    def no_file_attached
      true
    end
  end
end
