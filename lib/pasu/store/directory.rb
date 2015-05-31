require 'pasu/store/generic_file'

module Pasu
  class Store
    class Directory < GenericFile
      include Enumerable

      def type
        'directory'
      end

      def parent
        self.class.new(store, path.parent)
      end

      def children
        store.children_of(path)
      end

      def create_file(name, io)
        path = path.join(name)
        store.create_file(path, io)
      end

      def root?
        store.root?(path)
      end

      def each(&block)
        children.each(&block)
      end
    end
  end
end
