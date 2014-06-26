require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
require 'paperclip'
require 'data_mapper'
require 'dm-paperclip'

enable :sessions
use Rack::Flash, :sweep => true
set :sessions => true

set :database, "sqlite3:microblog.sqlite3"
#DataMapper::setup(:default, "sqlite3:microblog.sqlite3")


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
  flash[:alert] = "You don't seem to have an account with us. Please sign up."
  redirect '/sign_up'
end
end

# IN CASE I NEED TO REVERT
# post '/sign_up' do
#   User.create(params[:user])
#   @user = User.find_by(params[:user])
#   flash[:greeting]="Account Created!"
#   session[:user_id] = @user.id
#     redirect '/profile'
# end

post '/sign_up' do

  puts params.inspect
  
  if User.find_by(uname: params[:user]["uname"]) == nil

  User.create(params[:user])
  @user = User.find_by(params[:user])
  session[:user_id] = @user.id
  flash[:greeting] = "Account created! Start following friends, writing posts and filling out your profile."
    redirect '/profile'

  else
  flash[:alert] = "That username is in use. Please choose another."
  redirect '/sign_up'
end

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

get '/follow' do

end





#Experimental, may not work!!
#This part is for images/files upload from paperclip and datamapper gems
#should do "gem install data_mapper" and "gem install paperclip" & "gem install dm-paperclip"

def make_paperclip_mash(file_hash)
  mash = Mash.new
  mash['tempfile'] = file_hash[:tempfile]
  mash['filename'] = file_hash[:filename]
  mash['content_type'] = file_hash[:type]
  mash['size'] = file_hash[:tempfile].size
  mash
end

post '/upload' do
  halt 409, "File seems to be emtpy" unless params[:file][:tempfile].size > 0
  @resource = Resource.new(:file => make_paperclip_mash(params[:file]))
  halt 409, flash[:error]="There were some errors processing your request...\n#{resource.errors.inspect}" unless @resource.save
 
  erb :upload
end
 
get '/' do
  erb :index
end

#Above == Paperclip/datamapper uploader


