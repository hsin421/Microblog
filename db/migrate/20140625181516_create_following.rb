class CreateFollowing < ActiveRecord::Migration
  def change
  	create_table :followerings do |t|
  		t.integer :user_id
  	end
  end
end
