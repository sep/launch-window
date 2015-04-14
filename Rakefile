require 'mongoid'
require 'dotenv'
require_relative 'models/card'

desc 'Starts the application on specified port (default 4000)'
task :start, [:port] do |t, args|
  args.with_defaults(:port => 4000)
  exec "rerun \"foreman start -p #{args[:port]}\""
end

task :connect_to_db do
  ENV['RACK_ENV'] = "development" if ENV['RACK_ENV'].nil?
  mongoid_config_path = File.expand_path(File.join('config', 'mongoid.yml'), File.dirname(__FILE__))
  Mongoid.load!(mongoid_config_path)
end

desc 'Seeds the database with fake data'
task :seed_db, [:count] => :connect_to_db do |t, args|
  args.with_defaults(:count => 20)

  categories = [:general, :link, :mission, :cargo, :science, :rocket, :spacecraft, :organization, :mission_event]
  images = ["96x96-minus0.png", "96x96-minus3h.png", "96x96-plus110.png", "spaceappslogo.png"]

  for i in 1..args[:count].to_i do
    card = Card.new
    card.category = categories[rand(categories.length)]
    card.image = "/images/#{images[rand(images.length)]}"
    card.content = "Content of card #{i}"
    card.sequence_number = i
    card.save!
  end
end

desc 'Removes all cards from the database'
task :clear_db => :connect_to_db do
  Card.delete_all
end

task :default => :start