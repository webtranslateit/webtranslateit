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
        root = request.path
        root = "" if root == "/"
        root
      end
      
      def highlight(value, expected)
        return if value.nil?
        print_value = value == true ? "Yes" : "No"
        value == expected ? "<em>#{print_value}</em>" : "<em class=\"information\">#{print_value}</em>"
      end      
    end
    
    get '/' do
      erb :index, :locals => { :config => config }
    end
    
    post '/pull' do
      WebTranslateIt::CommandLine.pull
      redirect "/"
    end

    def initialize(*args)
      super
      @config = WebTranslateIt::Configuration.new('.')
    end

    def self.start(host, port)
      WebTranslateIt::Server.run! :host => host, :port => port
    end
    
  end
end