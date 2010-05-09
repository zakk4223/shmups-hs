class CreateKetsuis < ActiveRecord::Migration
  def self.up
    create_table :ketsuis do |t|
      t.string :player
      t.integer :score
      t.text :stage
      t.text :ship
      t.string :version
      t.boolean :current
      t.text :raw_entry
      t.timestamps
    end
  end

  def self.down
    drop_table :ketsuis
  end
end
