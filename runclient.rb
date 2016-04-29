#!/usr/bin/env ruby
require_relative 'client'
abort "Needs to provide 2 arguments server and port" if ARGV.length < 2
client = FuncgenClient.new(ARGV[0], ARGV[1])
client.run
