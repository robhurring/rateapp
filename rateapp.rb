require './lib/topic'

class RateApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :public_folder, proc{ File.join(root, 'public') }
  set :views, proc{ File.join(root, 'views') }

  configure do
    Pusher.app_id = ENV['RATEAPP_PUSHER_ID']
    Pusher.key = ENV['RATEAPP_PUSHER_KEY']
    Pusher.secret = ENV['RATEAPP_PUSHER_SECRET']

    if redistogo = ENV['REDISTOGO_URL']
      uri = URI.parse redistogo
      instance = Redis.new host: uri.host, port: uri.port, password: uri.password
    else
      instance = Redis.new host: 'localhost'
    end
    $redis = Redis::Namespace.new(:rateapp, redis: instance)
  end

  before do
    @topic = Topic.get 'default'
  end

  get '/config.json' do
    content_type :json

    config = {
      pusher: {
        key: Pusher.key,
        channel: 'default',
        debug: ENV['RACK_ENV'] == 'development'
      },
      topic: {
        name: 'ohai',
        score: 10
      }
    }

    config.to_json
  end

  get '/' do
    10.times{ @topic.incr! }

    haml :index
  end

  post '/upvote' do
    content_type :json
  end

  post '/downvote' do
    content_type :json

  end
end