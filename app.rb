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
  if session[:user_id] == nil
	erb :index
  else
    erb :profile
  end
end

get '/admin' do
  erb :admin

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

  if params[:user]["pwd"] == params[:cfpwd]  

  User.create(params[:user])
  @user = User.find_by(params[:user])
  session[:user_id] = @user.id
  flash[:greeting] = "Account created! Start following friends, writing posts and filling out your profile."
  Following.create({"id"=>@user.id, "user_id"=>@user.id})  #so the user follows self
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
  
  Post.create({"body"=>params["body"], "user_id"=>current_user.id, "timecreated"=>Time.now})
  redirect '/profile'
end

get '/profile_edit' do
  erb :profile_edit
end


#this works, just not very pretty yet
post '/profile_edit' do

  if params[:pwd] == params[:cfpwd] 
    current_user.update(pwd: params[:pwd])
    else flash[:alert] = "Password does not match."
    redirect '/profile_edit'
  end
  if params[:fname] != ""
    current_user.update(fname: params[:fname])
  end
  if params[:lname] != ""
    current_user.update(lname: params[:lname])
  end
  if params[:email] != ""
    current_user.update(email: params[:email])
  end
  flash[:alert] = "Your changes have been made!"
  redirect '/profile_edit'
end

#have to add delete account functionality here
# post '/delete_account' do
  
#   flash[:alert] = "We're sorry to see you go ):"
#     redirect '/sign_up'
# end


get '/sign_up' do
	erb :sign_up
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:greeting]="Goodbye! Come again!"
  redirect '/'

end  

#Selfpost grabs posts from self
def Selfpost(user, number)
  a=user.posts.order('timecreated ASC')
  length = a.length
  if length >=10
    return a[length-1-9+number]
  elsif length <10
    if number >= 10-length
      return a[length-1-9+number]
    else return nil
    end
  end
end

#This puts Selfpost in the correct format
def superselfpost(user, number)
  if Selfpost(user, number) != nil
    return "<ul class='postDetails'>
            <li class='postsUname'>@#{user.uname}</li>
            <li class='postsDatetime'>#{Selfpost(user,number).timecreated.to_s[0..15]}</li>
        </ul>
        <div class='postsBody'>
           #{Selfpost(user,number).body}
        </div>"
  else
    return ""
  end
end

#returns an array of posts the user's following generated, sorted by time created in ascending order
def Postgrabber(my_user)
  
  my_array = []
  for f in my_user.followings
   for p in User.find(f.following_id).posts
  
    my_array << p     
    end
  end
  array_time = []
  for a in my_array
   array_time << a.timecreated
  end
 array_want = []
 for a in array_time.sort
   for b in my_array
    if a == b.timecreated
      array_want << b
    end
   end
  end
  no_repeat = []
  lg = array_want.length
  no_repeat << array_want[0]
  for a in (0...lg)
    if array_want[a] != array_want[a+1]
      no_repeat << array_want[a+1]
    end
  end

  return no_repeat
end

#number from 0 to 9, each number returning a posts from previous array
def Postgenerator(user, number)
  a=Postgrabber(user)
  length = a.length
  if length >=10
    return a[length-1-9+number]
  elsif length <10
    if number >= 10-length
      return a[length-1-9+number]
    else return nil
    end
  end
end

#puts Postgenerator in correct html output
def superPostgenerator(user, number)
  if Postgenerator(user, number) != nil
    return "<ul class='postDetails'>
            <li class='postsUname'><a href='/users/#{Postgenerator(current_user,number).user_id}'>@#{User.find(Postgenerator(current_user,number).user_id).uname} </a></li>
            <li class='postsDatetime'>#{Postgenerator(current_user,number).timecreated.to_s[0..15]}</li>
        </ul>
        <div class='postsBody'>
           #{Postgenerator(current_user,number).body}
        </div>"
  else
    return ""
  end
end

#generates a list of followings without repeat & without self
def followinglistgenerator(user, id)
   b=[]
   lg=User.find(id).followings.length
   if lg != 0
   if User.find(id).followings[0].following_id != current_user.id
   b << User.find(id).followings[0]
   end
   for a in (0...lg-1)
    if User.find(id).followings[a].following_id != User.find(id).followings[a+1].following_id && User.find(id).followings[a+1].following_id != current_user.id
      b << User.find(id).followings[a+1]
    end 
     
  end
  end
  return b
end
#generates a list of followers without repeat & without self
def followerlistgenerator(user, id)
   b=[]
   lg=User.find(id).followers.length
   if lg != 0
   if User.find(id).followers[0].follower_id != current_user.id
   b << User.find(id).followers[0]
   end
   for a in (0...lg-1)
    if User.find(id).followers[a].follower_id != User.find(id).followers[a+1].follower_id && User.find(id).followers[a+1].follower_id != current_user.id
      b << User.find(id).followers[a+1]
      
      
    end
  end
end
  return b
end
    
#users page, redirect to profile if click on self
get '/users/:id' do
  @id = params[:id]
  puts "@id is  #{@id}"
  puts "current user id is  #{current_user.id}"
  if @id == current_user.id
  erb :profile
  else
  erb :users
  end
end

#for following and follower relationships: Following(id:3, user_id:5) means 5 is following 3
# and Follower(id:3, user_id:5) means 3 is a follower of 5 
# Hsin's convention, sorry for all confusions LOL
get '/follow/:id' do
  @id=params[:id]
  Following.create("following_id"=>@id, "user_id"=>current_user.id)
  Follower.create("follower_id"=>current_user.id, "user_id"=>@id)
  redirect '/'
end  
      






