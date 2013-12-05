class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.integer :game_id
      t.integer :amount
      t.string :team
      t.integer :user_id

      t.timestamps

    end

    add_index :bets, [:game_id, :user_id], :unique => true
  end
end
