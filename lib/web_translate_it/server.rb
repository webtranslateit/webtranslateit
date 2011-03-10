# encoding: utf-8
require 'sinatra/base'
require 'erb'

module WebTranslateIt
  class Server < Sinatra::Base
    attr_reader :config
    
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public, "#{dir}/public"
    set :static, true
    set :lock, true
        
    helpers do
      def wti_root
        ""
      end
      
      def highlight(value, expected)
        return if value.nil?
        print_value = value == true ? "Yes" : "No"
        value == expected ? "<em>#{print_value}</em>" : "<em class=\"information\">#{print_value}</em>"
      end
    end
    
    get '/' do
      @config = WebTranslateIt::Configuration.new('.')
      erb :index, :locals => { :config => config, :locale => "" }
    end
    
    get '/:locale' do
      @config = WebTranslateIt::Configuration.new('.')
      erb :index, :locals => { :config => config, :locale => params[:locale] }
    end
    
    post '/pull/' do
      `wti pull`
      redirect "/"
    end
    
    post '/pull/:locale' do
      `wti pull -l #{params[:locale]}`
      redirect "/#{params[:locale]}"
    end
    
    def self.start(host, port)
      puts "Starting wti server..."
      Dir::mkdir('log') unless FileTest::directory?('log')
      logger = ::File.open("log/webtranslateit.log", "a+")
      STDOUT.reopen(logger)
      STDERR.reopen(logger)
      WebTranslateIt::Server.run! :host => host, :port => port
    end
  end
end