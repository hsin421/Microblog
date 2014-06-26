class RenameFollowing < ActiveRecord::Migration
  def change
  	rename_table(:followerings, :followings)
  end
end
