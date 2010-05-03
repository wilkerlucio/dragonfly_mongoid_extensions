require 'mongo'

module Dragonfly
  module DataStorage
    class MongoGridFsStore < Base
      def initialize(host, database)
        @db = Mongo::Connection.new(host).db(database)
        @grid = Mongo::Grid.new(@db)
      end
      
      def store(temp_object)
        # returns object id
        id = @grid.put(File.read(temp_object.path), :filename => temp_object.basename)
        id
      end

      def retrieve(uid)
        file = @grid.get(BSON::ObjectID.from_string(uid))
        file.read
      rescue
        raise DataNotFound, $!.message  
      end
      
      def destroy(uid)
        @grid.delete(BSON::ObjectID.from_string(uid))
      rescue
        raise DataNotFound, $!.message
      end
    end
  end
end