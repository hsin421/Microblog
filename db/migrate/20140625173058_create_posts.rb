class CreatePosts < ActiveRecord::Migration
  def change
  	create_table :posts do |t|
  		t.text :body
  		t.datetime :timecreated
  		t.integer :user_id
  	end
  end
end
