class DefaultValues < ActiveRecord::Migration
  def self.up
    inhabitant=Inhabitant.create(
            :login => "midas",
            :email => "midas@hecpeare.net",
            :password => "pass",
            :password_confirmation => "pass"
    )
    inhabitant.activate
 
  end

  def self.down
    Inhabitant.find('midas').destroy
  end
end
