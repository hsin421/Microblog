class AddColumnFollower < ActiveRecord::Migration
  def change 
  	add_column :followers, :follower_id, :integer
  end
end
