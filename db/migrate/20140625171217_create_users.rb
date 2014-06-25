class CreateUsers < ActiveRecord::Migration
  def change
  	create_table :users do |t|
  		t.string :fname
  		t.string :lname
  		t.string :email
  		t.string :uname
  		t.string :pwd
  		t.boolean :haspic
  		t.string :piclocation
  	end
  end
end
