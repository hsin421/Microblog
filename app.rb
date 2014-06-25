require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
enable :sessions
use Rack::Flash, :sweep => true
set :sessions => true

set :database, "sqlite3:microblog.sqlite3"

get '/' do 
 erb :index
	
end

get '/profile' do 
 erb :profile 
	
end

get '/edit' do 

	erb :profile_edit
	
end

get '/sign_up' do
    erb :sign_up

end

get '/main' do 
    erb :main
	
end



