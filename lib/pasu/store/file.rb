require 'pasu/store/generic_file'
require 'pasu/store/directory'

module Pasu
  class Store
    class File < GenericFile
      def type
        'file'
      end

      def directory
        Directory.new(store, path.parent)
      end
    end
  end
end
