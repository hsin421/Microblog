require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
require 'paperclip'

enable :sessions
use Rack::Flash, :sweep => true
set :sessions => true

configure(:development){set :database, "sqlite3:microblog.sqlite3"}

helpers do
  def current_user
    session[:user_id].nil? ? nil : User.find(session[:user_id])
  end
end

get '/' do
	erb :index
end

post '/sign_in' do

  #puts params.inspect
  if User.find_by(uname: params[:user]["uname"]) != nil
      @user = User.find_by(uname: params[:user]["uname"])
  
  # puts "user pwd is #{@user.pwd} "
  # puts "params pwd is #{params[:user]["pwd"]}"
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


post '/sign_up' do
  
  if User.find_by(uname: params[:user]["uname"]) == nil

  if params[:user]["pwd"] == params[:user]["cfpwd"]  

  User.create(params[:user])
  @user = User.find_by(params[:user])
  session[:user_id] = @user.id
  flash[:greeting] = "Account created! Start following friends, writing posts and filling out your profile."
    redirect '/profile'
   else
    flash[:alert] = "Password doesn't match. Please try again"
    redirect '/sign_up'
  end

  else
  flash[:alert] = "That username is in use. Please choose another."
  redirect '/sign_up'
end

end

get '/profile' do
  if current_user != nil
	erb :profile
  else
    redirect '/'
  end
end

#gets post from profile page
post '/profile' do
  puts params.inspect
  Post.create({"body"=>params["body"], "user_id"=>current_user.id, "timecreated"=>Time.now})
  redirect '/profile'
end

get '/profile_edit' do

  erb :profile_edit
end

get '/sign_up' do
	erb :sign_up
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:greeting]="Goodbye! Come again!"
  redirect '/'

end  

#returns an array of posts the user's following generated
def Postgrabber(my_user)
  
  my_array = []
  for f in my_user.followings

  
   for p in User.find(f.id).posts
  
    my_array << p 
    
    
end
end

  return my_array
end

#number from 0 to 9, each number returning a posts from previous array
def Postgenerator(user, number)
  a=Postgrabber(user)
  length = a.length
  if length >=10
    return a[number]
  elsif length <10
    if number <= length
      return a[number]
    else return nil
    end
  end
end
      
# dblength = User.last.id.to_i




#To establish following/follower
#Still need to put '/follow#{a}' link on the page 
# for a in (1..dblength)
#   get '/follow#{a}' do
#    Following.create({"id"=>User.find(a).id, "user_id"=>current_user.id})
#    Follower.create({"user_id"=> User.find(a).id, "id"=> current_user.id})
#   end
# end






