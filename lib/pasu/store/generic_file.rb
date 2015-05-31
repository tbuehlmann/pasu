module Pasu
  class Store
    class GenericFile
      attr_accessor :store, :path

      def initialize(store, path)
        self.store = store
        self.path = path
      end

      def type
        raise NotImplementedError
      end

      def name
        path.basename.to_s
      end

      def dotfile?
        path.basename.to_s.start_with?('.')
      end

      def filesystem_path
        store.filesystem_path(path)
      end
    end
  end
end
