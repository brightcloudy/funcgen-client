require 'celluloid/current'
require 'celluloid/io'
require 'highline/import'
require_relative 'interface'
require_relative 'message'

class FuncgenClient
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    puts "Connecting..."
    begin
      @socket = TCPSocket.new(host, port)
    rescue
      abort "Connection failed!"
    end
    puts "Connected!"
    @infoqueue = Queue.new
    @interface = FuncgenClientInterface.new(@infoqueue)
    @serverchecker = FuncgenClientInterface.new(@infoqueue, @socket)
  end

  def run
    @interface.async.repl
    @serverchecker.async.servercheck
    loop do
      info = @infoqueue.pop
      if info.is_from?(:interface)
        handle_cmd info.message
      end
      if info.is_from?(:server)
        puts "[SERVER] #{info.message}"
      end
    end
  end

  def shutdown
    @interface.terminate if @interface
    @serverchecker.terminate if @serverchecker
    @socket.close if @socket
  end

  def handle_cmd(cmd)
    args = cmd.strip.downcase.split(' ')
    case args[0]
      when "exit"
        exit
      when "ping"
        send_ping
      when "sync"
        send_cmd "sync"
      when "on"
        send_cmd "on"
      when "off"
        send_cmd "off"
      when "freq"
        freqstr = args[1].split('.')
        format = "%.5i%.5i" % [freqstr[0].to_i, freqstr[1].to_i*10000]
        send_cmd "freq #{format}"
      when "ampl"
       	amplstr = args[1].split('.')
        format = "%.2i%.2i" % [amplstr[0].to_i, amplstr[1].to_i] 
				send_cmd "ampl #{format}"
			when "list"
        puts "List of commands:"
        puts "exit"
        puts "ping"
        puts "on"
        puts "off"
        puts "freq 1.0 [kHz]"
        puts "ampl 1.0 [V]"
        puts "sync"
      else
        unknown_cmd args[0]
    end
  end

  def send_cmd(cmd)
    @socket.puts cmd
  end

  def send_ping
    puts "PING!"
    @socket.puts "PING!"
  end

  def unknown_cmd(cmd)
    puts "Unknown command '#{cmd}'!"
  end

end
