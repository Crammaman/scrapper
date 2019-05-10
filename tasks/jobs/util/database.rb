require 'mysql2'
require 'singleton'
module Util
  class DB
    include Singleton

    def initialize

      @connections_mutex = Mutex.new

      @available_connections = []

      5.times do
        @available_connections << Mysql2::Client.new( host: 'localhost', username: 'root', password: 'ohgodnottheroot' )
      end
    end

    def run_query query = nil

      connection = nil

      while @available_connections.length < 1
        sleep 1
      end

      @connections_mutex.synchronize do
        connection = @available_connections.shift
      end

      raise 'Failed to allocate connection' if connection.nil?

      unless query.nil?
        connection.query query
      else
        yield connection
      end

    ensure
      @available_connections << connection
    end

    def self.run_query query = nil, &block
      unless query.nil?
        connection.query query
      else
        self.instance.run_query &block
      end
    end
  end
end
