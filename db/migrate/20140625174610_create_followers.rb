class CreateFollowers < ActiveRecord::Migration
  def change
  	create_table :followers do |t|
  		t.integer :user_id
  	end
  end
end
