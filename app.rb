require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
require 'paperclip'

enable :sessions
use Rack::Flash, :sweep => true
set :sessions => true

set :database, "sqlite3:microblog.sqlite3"

helpers do
  def current_user
    session[:user_id].nil? ? nil : User.find(session[:user_id])
  end
end

get '/' do
	erb :index
end

post '/sign_in' do
  puts params.inspect
  if User.find_by(uname: params[:user]["uname"]) != nil
      @user = User.find_by(uname: params[:user]["uname"])
  
  puts "user pwd is #{@user.pwd} "
  puts "params pwd is #{params[:user]["pwd"]}"
    	if @user.pwd == params[:user]["pwd"]
    		session[:user_id] = @user.id
    		redirect '/profile'
    		else
    		flash[:alert] = "Wrong password. Please try again."
        redirect '/'
    	end
else
  flash[:alert] = "You don't seem to have an account with us. Please sign up"
  redirect '/sign_up'
end
end

post '/sign_up' do
User.create(params[:user])
@user = User.find_by(params[:user])
flash[:greeting]="Account Created!"
session[:user_id] = @user.id
  redirect '/profile'

end

get '/profile' do
	erb :profile
end

get '/sign_up' do
	erb :sign_up
end

get '/sign_out' do
  flash[:greeting]="Goodbye! Come again!"
  redirect '/'

end  

dblength = User.last.id.to_i

#To establish following/follower
#Still need to put '/follow#{a}' link on the page 
for a in (1..dblength)
  get '/follow#{a}' do
   Following.create({"id"=>User.find(a).id, "user_id"=>current_user.id})
   Follower.create({"user_id"=> User.find(a).id, "id"=> current_user.id})
  end
end






