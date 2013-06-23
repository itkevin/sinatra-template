require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/reloader'
require 'data_mapper'
require 'slim'
require 'better_errors'
require './app/url_helpers'

class MyApp < Sinatra::Base
  register Sinatra::AssetPack

  set :root, File.dirname(__FILE__)
  set :slim, :pretty => true, :format => :html5
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db")
  DataMapper.finalize
  DataMapper.auto_upgrade!

  helpers UrlHelpers

  configure :development do
    register Sinatra::Reloader
    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path("..", __FILE__)
  end

  assets {
    serve '/js',     from: 'app/js'        # Default
    serve '/css',    from: 'app/css'       # Default
    serve '/images', from: 'app/images'    # Default

    # The second parameter defines where the compressed version will be served.
    # (Note: that parameter is optional, AssetPack will figure it out.)
    js :app, '/js/app.js', [
      '/js/vendor/**/*.js',
      '/js/lib/**/*.js',
      '/js/*.js'
    ]

    css :application, '/css/application.css', [
      '/css/screen.css',
      '/css/*.css'
    ]

    js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
    css_compression :simple   # :simple | :sass | :yui | :sqwish
  }

  get "/" do
    slim :index
  end

end
