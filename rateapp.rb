require './lib/topic'

if redistogo = ENV['REDISTOGO_URL']
  uri = URI.parse redistogo
  instance = Redis.new host: uri.host, port: uri.port, password: uri.password
else
  instance = Redis.new host: 'localhost', port: '6379'
end

$redis = Redis::Namespace.new(:rateapp, redis: instance)

class RateApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :public_folder, proc{ File.join(root, 'public') }
  set :views, proc{ File.join(root, 'views') }
  set :channel, 'default'

  configure do
    Pusher.app_id = ENV['RATEAPP_PUSHER_ID']
    Pusher.key = ENV['RATEAPP_PUSHER_KEY']
    Pusher.secret = ENV['RATEAPP_PUSHER_SECRET']
  end

  before do
    @topic = Topic.get settings.channel
  end

  get '/' do
    haml :index
  end

  get '/config' do
    content_type :json

    {
      key: Pusher.key,
      channel: 'default',
      debug: ENV['RACK_ENV'] == 'development'
    }.to_json
  end

  get '/topic' do
    content_type :json
    @topic.to_json
  end

  post '/topic' do
    status 200

    data = JSON.parse(params['model'])

    if data['vote'] == 1
      @topic.incr!
    else
      @topic.decr!
    end

    @topic.save
    Pusher[settings.channel].trigger 'score-changed', {percent: @topic.percent}

    nil
  end
end