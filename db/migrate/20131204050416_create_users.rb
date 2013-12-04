class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitch_id, null: false
      t.integer :wallet, null: false, default: 0
      t.string :name, null: false
      t.string :email

      t.timestamps
    end
  end
end
