class DefaultValues < ActiveRecord::Migration
  def self.up
    fuser=Fuser.create(
            :login => "midas",
            :email => "midas@hecpeare.net",
            :password => "pass",
            :password_confirmation => "pass"
    )
    fuser.activate
 
  end

  def self.down
    Fuser.find('midas').destroy
  end
end
