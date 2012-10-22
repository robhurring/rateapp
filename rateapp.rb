class RateApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :public_folder, proc{ File.join(root, 'public') }
  set :views, proc{ File.join(root, 'views') }

  configure do
    Pusher.app_id = ENV['RATEAPP_PUSHER_ID']
    Pusher.key = ENV['RATEAPP_PUSHER_KEY']
    Pusher.secret = ENV['RATEAPP_PUSHER_SECRET']
  end

  get '/config.json' do
    content_type :json

    {
      pusher: {
        key: Pusher.key,
        channel: 'default',
        debug: ENV['RACK_ENV'] == 'development'
      }
    }.to_json
  end

  get '/' do
    haml :index
  end
end