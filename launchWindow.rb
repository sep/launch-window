require 'rubygems'
require 'sinatra'
require 'json'
require 'dotenv'
require 'mongoid'
require 'time'
require_relative 'models/card'
require_relative 'twitter'
require_relative 'twitter'

Dotenv.load
configure do
  enable :sessions

  mongoid_config_path = File.expand_path(File.join('config', 'mongoid.yml'), File.dirname(__FILE__))
  Mongoid.load!(mongoid_config_path)
  
  twitter_init

  #Seed Content for testing
  nowUTCDate = Time.now.to_i
  newCard = Card.new(content: "This is my card content", image: "images/spaceappslogo.png", sequence_number: 1, published_time: nil)
  newCard.save!
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry guacamole, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb :index, :locals => {:launchName => "SpaceX CRS-6 Launch", :launchHastag => "#CRS-6"}
end

get '/admin' do
  erb :admin, :locals => {:launchName => "ADMIN PANEL - - - SpaceX CRS-6 Launch", :launchHastag => "#CRS-6"}
end

get '/cards/unpublished' do
  messages = []
  Card.where(published_time: nil).each do |card|
    messages.append({:id => card.id.to_s, :message => card.content, :imageURI => card.image, :sequenceNumber => card.sequence_number, :publishedTime => nil})
  end

  messages.sort_by!{|m| m[:sequenceNumber]}

  content_type :json
  messages.to_json
end

post '/publish/:id' do
  card = Card.find(params['id'])
  card.published_time = DateTime.now.new_offset(0)
  card.save!
end

get '/cards' do 
  after = params[:after]
  afterDateTime = DateTime.new(2000,1,1)
  if(!after.empty? && after != "null")
    afterDateTime =  DateTime.iso8601(after)
  end 

  messages = []
  Card.where(:published_time.gt => afterDateTime).each do |card|
    messages.append({:id => card.id.to_s, :message => card.content, :name => "Bob", :imageURI => card.image, :sequenceNumber => card.sequence_number, :publishedTime => card.published_time.to_s})
  end
  
  #Demo Content
  #messages.append({:id => 1,
  #      :message => 'this is the awesome message', 
  #      :title => 'This is the title', 
  #      :name => 'Bob',
  #      :imageURI => 'http://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Wild_Turkeys.jpg/250px-Wild_Turkeys.jpg'});
  #messages.append({:id => 2,
  #       :message => 'this is another awesome message', 
	#			 :title => 'This is another title', 
	#			 :name => 'Dave'});
   
  content_type :json
  messages.to_json
  
end
