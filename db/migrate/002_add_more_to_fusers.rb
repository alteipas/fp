class AddMoreToFusers < ActiveRecord::Migration
  def self.up
    add_column :fusers, :favs, :integer, :default=>0
    add_column :fusers, :url, :string, :default=>""
    add_column :fusers, :name, :string, :default=>""
    add_column :fusers, :inviter_id, :integer
    add_column :fusers, :invitation_amount, :integer, :default=>1
  end


  def self.down
    remove_column :fusers, :url
    remove_column :fusers, :favs
  end
end
