class AddPropertiesToUser < ActiveRecord::Migration
  def change
    add_column :users, :properties, :hstore, default: {}
  end
end
