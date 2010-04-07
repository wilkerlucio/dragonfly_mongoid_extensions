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
        id = @grid.put(File.read(temp_object.path), temp_object.basename)
        id
      end

      def retrieve(uid)
        file = @grid.get(Mongo::ObjectID.from_string(uid))
        file.read
      end
      
      def destroy(uid)
        @grid.delete(Mongo::ObjectID.from_string(uid))
      end
    end
  end
end