desc 'Starts the application on specified port (default 4000)'
task :start, [:port] do |t, args|
  args.with_defaults(:port => 4000)
  exec "rerun \"foreman start -p #{args[:port]}\""
end

task :thingy do
  require 'mongoid'
  require_relative 'models/card'
  require 'dotenv'

  Dotenv.load

  card = Card.first
  p card
end

task :default => :start