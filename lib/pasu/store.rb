require 'pasu/store/directory'
require 'pasu/store/file'

module Pasu
  class Store
    attr_accessor :root, :recursive, :dotfiles

    def initialize(root, **options)
      self.root = Pathname.new(root).expand_path
      self.recursive = options.fetch(:recursive, false)
      self.dotfiles  = options.fetch(:dotfiles, true)
    end

    def find(path)
      filesystem_path = filesystem_path(path)

      if child_of_root?(filesystem_path) && filesystem_path.exist?
        file_or_directory_for_path(filesystem_path)
      end
    end

    def root_directory
      file_or_directory_for_path(root)
    end

    def create_file(path, filename, io)
      file = File.new(self, Pathname.new(path).join(filename))

      if file.directory.filesystem_path.directory? && !file.filesystem_path.exist? && allowed_file?(file)
        ::File.open(file.filesystem_path, 'wb') { |f| f.write(io.read) }
        file
      else
        nil
      end
    end

    def root?(path)
      filesystem_path(path) == root
    end

    def children_of(path)
      children = filesystem_path(path).children.map { |path| file_or_directory_for_path(path) }
      children.compact.sort_by { |child| [child.class.to_s, child.name] }
    end

    def filesystem_path(path)
      root.join(path).expand_path
    end

    private

    def file_or_directory_for_path(filesystem_path)
      case filesystem_path.ftype
      when 'directory'
        directory = Directory.new(self, filesystem_path.relative_path_from(root))
        allowed_directory?(directory) ? directory : nil
      when 'file'
        file = File.new(self, filesystem_path.relative_path_from(root))
        allowed_file?(file) ? file : nil
      end
    end

    def child_of_root?(filesystem_path)
      filesystem_path.to_s.start_with?(root.to_s)
    end

    def allowed_directory?(directory)
      directory.root? || (recursive && !unallowed_dotfile?(directory))
    end

    def allowed_file?(file)
      allowed_directory?(file.directory) && !unallowed_dotfile?(file)
    end

    def unallowed_dotfile?(file_or_directory)
      !dotfiles && file_or_directory.dotfile?
    end
  end
end
