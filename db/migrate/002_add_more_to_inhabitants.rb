class AddMoreToInhabitants < ActiveRecord::Migration
  def self.up
    add_column :inhabitants, :favs, :integer, :default=>0
    add_column :inhabitants, :url, :string, :default=>""
    add_column :inhabitants, :name, :string, :default=>""
    add_column :inhabitants, :inviter_id, :integer
    add_column :inhabitants, :invitation_favs, :integer, :default=>1
  end

  def self.down
    remove_column :inhabitants, :invitation_favs
    remove_column :inhabitants, :inviter_id
    remove_column :inhabitants, :name
    remove_column :inhabitants, :url
    remove_column :inhabitants, :favs
  end
end
