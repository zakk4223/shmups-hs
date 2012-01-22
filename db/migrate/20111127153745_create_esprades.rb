class CreateEsprades < ActiveRecord::Migration
  def self.up

    create_table :esprades do |t|
      t.string :player
      t.integer :score
      t.text :stage
      t.text :character
      t.boolean :current
      t.text :raw_entry
      t.belongs_to :game
      t.timestamps
    end

  end

  def self.down
    drop_table :esprades
  end
end
