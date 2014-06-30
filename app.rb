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

# define current user and set session for user log in
helpers do
  def current_user
    if session[:user_id] != nil 
      if session[:user_id] <= User.last.id
      return User.find(session[:user_id])
    else
      session[:user_id] = nil
      return nil
    end
    else
      return nil
    
  end
  end
end

#direct user to sign in page if not logged in, to profile if logged in
get '/' do
  if current_user == nil && session[:user_id] == nil
	erb :index
  else
    erb :profile
  end
end

#for users to see, follow and interact with all other users
get '/directory' do
  # @allUsers = []
  erb :directory
end

#To see all the current user's posts
get '/my_posts' do
  erb :my_posts
end

#for Admin to see all user info
get '/admin' do
  erb :admin
end


post '/sign_in' do

  if User.find_by(uname: params[:user]["uname"]) != nil
      @user = User.find_by(uname: params[:user]["uname"])
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
  flash[:greeting] = "Account created! Try Checking out everyone (go to Users), writing posts and filling out your profile."
  Following.create({"following_id"=>@user.id, "user_id"=>@user.id})  #so the user follows self
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


#user creating post from profile page
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

#mallory's delete account functionality below
# 1) delete all posts 2) change user name/pwd 3) make sure the deleted does not show up in follow lists
get '/delete_account' do
  
    for a in current_user.posts 
      a.delete
    end
    current_user.update(:uname=> "#{current_user.uname}_deleted_#{Time.now.to_s}", :pwd => "#{SecureRandom.base64(10)}", :lname=> nil, :fname=> nil, :email=> nil)
    session[:user_id] = nil
    flash[:alert] = "We're sorry to see you go."
    erb :sign_up
end


#delete account functionality here
# get '/delete_account' do
#   User.find(current_user.id).upate("uname"=>current_user.uname+"_deleted", "pwd"=>"deleted", "email"=> "deleted")
#   flash[:alert] = "We're sorry to see you go ):"
#   redirect '/sign_up'
# end


get '/sign_up' do
	erb :sign_up
end


get '/sign_out' do
  session[:user_id] = nil
  flash[:greeting]="Goodbye! Come again!"
  redirect '/'

end  


#Selfpost grabs posts from current user
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

#This puts Selfpost in the correct format and HTML output
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
  #grabs an array of timestapms
  array_time = []
  for a in my_array
   array_time << a.timecreated
  end
  #sorts timestamp in order and puts the corresponding posts in array_want
 array_want = []
 for a in array_time.sort
   for b in my_array
    if a == b.timecreated
      array_want << b
    end
   end
  end
  #deletes repeating entries
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

#number from 0 to 9, each number returning a posts from previous array, with 9 the latest and 0 the oldest
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


#generates a list of followings without repeat & without self and filters out deleted accounts and unfollows
def followinglistgenerator(user)
   b=[]
   lg=User.find(user.id).followings.length
   if lg != 0
   for a in (0...lg)
    
    if User.find(user.id).followings[a].following_id != user.id && User.find(User.find(user.id).followings[a].following_id).uname[-33..-27] != "deleted"
      b << User.find(user.id).followings[a]
    end 
    
  end
  end
  return b
end
#generates a list of followers without repeat & without self and filters out deleted accounts and unfollows
def followerlistgenerator(user)
   b=[]
   lg=User.find(user.id).followers.length
   if lg != 0
   for a in (0...lg)
    
    if User.find(user.id).followers[a].follower_id != user.id && User.find(User.find(user.id).followers[a].follower_id).uname[-33..-27] != "deleted"
      b << User.find(user.id).followers[a]
    end 
    
  end
  end
  return b
end
    
#users page, redirect to profile if click on self (not functional yet donno why)
get '/users/:id' do
  @id = params[:id]
  # puts "@id is  #{@id}"
  # puts "current user id is  #{current_user.id}"
  if @id == current_user.id
  erb :my_posts
  else
  erb :users
  end
end

#for following and follower relationships: Following(following_id=>3, user_id=>5) means 5 is following 3
# and Follower(follower_id=>3, user_id=>5) means 3 is a follower of 5 
# Hsin's convention, sorry for all confusions LOL
get '/follow/:id' do
  @id=params[:id]
  Following.create("following_id"=>@id, "user_id"=>current_user.id)
  Follower.create("follower_id"=>current_user.id, "user_id"=>@id)
  erb :users
end  

#redirect all unfollow data to the deleted account(deletest) so that it wont show up in lists     
get '/unfollow/:id' do
  @id = params[:id]
  for a in Following.where(:user_id=>current_user.id, :following_id=>@id) 
    a.update(:user_id=> 6, :following_id=>6)
  end
  for a in Follower.where(:user_id=>@id, :follower_id=>current_user.id) 
    a.update(:user_id=> 6, :follower_id=>6)
  end
flash[:alert]="User unfollowed"
erb :users
end

#Intricate details of "follow me", "following" and "unfollow" buttons
#see users page for details, but it's hard to comment there so explained here
#if statement conditions whether the user is current user's following list, if no show "follow me" (#follow_button)
#if yes, show "following" (#follow_button2). Mallory's JS lets hovering change "following" to "unfollow"
#link #follow_button2 to '/unfollow/@id' which removes following/follower relations, which in turn swaps
#follow_button2 to #follow_button via the initial if statement in line 342

#==============================================
#Redirect pages
#when using post - simply redirect '/'
#when using get - do erb :page

#==============================================
#database.find_by() returns first matched element
#database.where() returns all matched elements

#==============================================
#remaining puzzle: how to call Ruby methods in Javascript and vice versa


