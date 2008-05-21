class DefaultValues < ActiveRecord::Migration
  def self.up
    abitant=Abitant.create(
            :login => "midas",
            :email => "midas@hecpeare.net",
            :password => "pass",
            :password_confirmation => "pass"
    )
    abitant.activate
 
  end

  def self.down
    Abitant.find('midas').destroy
  end
end
