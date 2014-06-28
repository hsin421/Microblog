class AddColumnFollowing < ActiveRecord::Migration
  def change
  	add_column :followings, :following_id, :integer
  end
end
