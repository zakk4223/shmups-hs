class AddGameScoreentryAssociation < ActiveRecord::Migration
  def self.up
    change_table :ketsuis do |t|
      t.belongs_to :game
    end
    ketsui_game = Game.find_by_short_name('ketsui')
    Ketsui.update_all("game_id = #{ketsui_game.id}")
  end

  def self.down
    change_table :ketsuis do |t|
      t.remove :game_id
    end
  end
end
