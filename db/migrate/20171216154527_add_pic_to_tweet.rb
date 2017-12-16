class AddPicToTweet < ActiveRecord::Migration[5.1]
  def change
  	add_column :tweets, :pic, :text
  end
end
