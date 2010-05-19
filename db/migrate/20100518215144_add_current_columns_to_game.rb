class AddCurrentColumnsToGame < ActiveRecord::Migration
  def self.up
    change_table :games do |t|
      t.string :current_columns, :default => 'player'
    end
  end

  def self.down
    change_table :games do |t|
      t.remove :current_columns
    end
  end
end
