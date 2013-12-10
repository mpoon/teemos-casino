class CreateOpenBets < ActiveRecord::Migration
  def change
    drop_table :bets do
      #
    end

    create_table :bets do |t|
      t.references :open_bet, index: true
      t.integer :amount
      t.string :team
      t.references :user, index: true
      t.timestamps
    end

    create_table :open_bets do |t|
      t.integer :game_id
      t.string :event
      t.string :state
      t.datetime :expires_at
      t.timestamps
    end

    remove_column :game_events, :expires_at, :datetime do
      #
    end
  end
end
