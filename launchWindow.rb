require 'rubygems'
require 'sinatra'
require 'json'
require 'dotenv'
require 'mongoid'

Dotenv.load
configure do
  enable :sessions

  mongoid_config_path = File.expand_path(File.join('config', 'mongoid.yml'), File.dirname(__FILE__))
  Mongoid.load!(mongoid_config_path)
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

get '/cards' do 
  # make call to mongo to get data
  # convert data to json 
  # arrayOfCards.to_json
  
  @messages = [{:message => 'this is the awesome message', :title => 'This is the title' }, {:message => 'this is another awesome message', :title => 'This is another title' }]
   
  content_type :json
  @messages.to_json
  
end
