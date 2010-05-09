class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :name
      t.string :short_name
      t.string :entry_split
      t.string :entry_order
      t.string :scoreboard_template
      t.timestamps
      
    end
  end

  def self.down
    drop_table :games
  end
end
