require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
enable :sessions
use Rack::Flash
set :sessions => true

set :database, "sqlite3:microblog.sqlite3"


get '/' do
	erb :index
end

post '/sign_in' do
  @user = User.where(uname: params[:uname]).first
	if @user.pwd == params[:pwd]
		session[:user_id] = @user.id
		redirect '/profile'
		else
		flash[:alert] = "There was a problem signing you in. Please try again."
	end
end

get '/profile' do
	erb :profile
end

get '/sign_up' do
	erb :sign_up
end
