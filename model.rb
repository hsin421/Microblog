class User < ActiveRecord::Base
	has_many :posts
	has_many :followers
	has_many :followings
	
   
end

class Post < ActiveRecord::Base
    belongs_to :user

end

class Follower < ActiveRecord::Base
      belongs_to :user
end

class Following < ActiveRecord::Base
     belongs_to :user
end

#deletes repeated followings and followers, if any. This code is not executed anywhere, 
#run this method when clearing repeated following/follower is needed
def Deletefollowrepeat
	b=[]
	lg = Following.all.length
	for a in (1..lg-1)
		for c in (a+1..lg)
			if Following.find(a).following_id == Following.find(c).following_id && Following.find(a).user_id == Following.find(c).user_id
				if b.index(c) == nil
					b << c
				
				end
			end
		end
	end
	lng=Follower.all.length
	d=[]
	for a in (1..lng-1)
		for c in (a+1..lng)
			if Follower.find(a).follower_id == Follower.find(c).follower_id && Follower.find(a).user_id == Follower.find(c).user_id
				if d.index(c) == nil
					d << c
					
				end
			end
		end
	end
	for i in b
		Following.find(i).delete
	end
	for j in d
		Follower.find(d).delete
	end
end

