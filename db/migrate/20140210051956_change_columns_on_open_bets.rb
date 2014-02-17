class ChangeColumnsOnOpenBets < ActiveRecord::Migration
  def change
    remove_column :open_bets, :event, :string
    add_column :open_bets, :kind, :string
    add_column :open_bets, :bet_id, :integer
  end
end
