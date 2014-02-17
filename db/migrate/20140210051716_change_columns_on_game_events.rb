class ChangeColumnsOnGameEvents < ActiveRecord::Migration
  def change
    add_column :game_events, :bet_id, :integer
    add_column :game_events, :result, :string
    remove_column :game_events, :team, :string
  end
end
