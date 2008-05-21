class CreateAbitants < ActiveRecord::Migration
  def self.up
    create_table "abitants", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :login_by_email_token, :string, :limit => 40
      t.column :activated_at, :datetime
      
    end
  end

  def self.down
    drop_table "abitants"
  end
end
