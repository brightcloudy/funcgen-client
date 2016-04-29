require 'celluloid/current'
require 'celluloid/io'
require 'highline/import'
require_relative 'client'
require_relative 'message'

class FuncgenClientInterface

  include Celluloid

  def initialize(messagequeue, socket = nil)
    @queue = messagequeue
    @socket = socket
  end

  def repl
    loop do
      while not @queue.empty? do
        sleep 0.05
      end
      cmd = STDIN.gets
      @queue << FuncgenMessage.new(cmd, :interface)
    end
  end

  def servercheck
    begin
      return if @socket.nil?
      loop do
        raise "EOF" if @socket.eof?
        news = @socket.gets
        @queue << FuncgenMessage.new(news, :server)
      end
    rescue
      @socket.close
      @socket = nil
      @queue << FuncgenMessage.new("EOF", :server)
    end
  end
end
