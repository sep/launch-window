require 'thread'
require 'json'
require 'twitter'

def twitter_init
  if (ENV["TWITTER_CONSUMER_SECRET"].nil? || ENV["TWITTER_TOKEN_SECRET"].nil?)
    return
  end
  
  $twitter_client = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = "xHqPm3OaIJ9EVS3oIB0elQyQg"
    config.consumer_secret     = ENV.fetch("TWITTER_CONSUMER_SECRET")
    config.access_token        = "3150020329-32IHFKN3mEEoJIJxQVSLVCAL6DiRBRXi2LtKLFp"
    config.access_token_secret = ENV.fetch("TWITTER_TOKEN_SECRET")
  end
  
  $tweet_buffer = Array.new
  $twitter_mutex = Mutex.new
  Thread.new{twitter_read()}
end

def twitter_read
  $twitter_client.filter(track: "Nintendo") do |tweet|
    $twitter_mutex.synchronize do
      $tweet_buffer.push(tweet) unless tweet.retweeted_status?
      $tweet_buffer.shift() if $tweet_buffer.length > 20
    end
  end
end

get '/tweets' do
  content_type :json
  
  if $twitter_mutex.nil?
    halt({ :error => "Could not initialize Twitter stream" }.to_json)
  end
  
  $twitter_mutex.synchronize do
      @minTime = Time.at(params['after'].nil? ? 0 : params['after'].to_i)
      @tweets = $tweet_buffer.map { |t| { :text => t.text, :user_handle => t.user.screen_name, :user_name => t.user.name, :user_image => t.user.profile_image_url.to_s, :created => t.created_at, :timestamp => t.created_at.to_i } }
      @tweets.delete_if { |t| t[:created] <= @minTime }
      @tweets.to_json
  end
end
