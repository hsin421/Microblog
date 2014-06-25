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

class Resource
  include DataMapper::Resource
  include Paperclip::Resource

  property :id,     Serial

  has_attached_file :file,
                    :url => "/system/:attachment/:id/:style/:basename.:extension",
                    :path => "/Users/Shin/Desktop/group/Microblog/Public/system/:attachment/:id/:style/:basename.:extension"
end

Resource.auto_migrate!