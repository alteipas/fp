class AddMoreToFusers < ActiveRecord::Migration
  def self.up
    add_column :fusers, :favs, :integer, :default=>0
    add_column :fusers, :url, :string
    fuser=Fuser.create(
            :login => "midas",
            :email => "midas@hecpeare.net",
            :password => "pass",
            :password_confirmation => "pass"
    )
    fuser.activate
  end


  def self.down
    remove_column :fusers, :url
    remove_column :fusers, :favs
  end
end
