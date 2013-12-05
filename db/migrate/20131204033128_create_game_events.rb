class CreateGameEvents < ActiveRecord::Migration
  def change
    create_table :game_events do |t|
      t.integer :game_id
      t.string :kind, null: false
      t.string :team
      t.datetime :expires_at
      t.timestamps
    end
  end
end
