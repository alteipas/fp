class AddMoreToAbitants < ActiveRecord::Migration
  def self.up
    add_column :abitants, :favs, :integer, :default=>0
    add_column :abitants, :url, :string, :default=>""
    add_column :abitants, :name, :string, :default=>""
  end

  def self.down
    remove_column :abitants, :name
    remove_column :abitants, :url
    remove_column :abitants, :favs
  end
end
