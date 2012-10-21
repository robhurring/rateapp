class RateApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :public_folder, proc{ File.join(root, 'public') }
  set :views, proc{ File.join(root, 'views') }

  configure do

  end

  get '/' do
    haml :index
  end
end