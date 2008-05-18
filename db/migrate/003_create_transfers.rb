class CreateTransfers < ActiveRecord::Migration
  def self.up
    create_table :transfers do |t|
      t.integer :receiver_id
      t.integer :sender_id
      t.integer :amount, :default=>1
      t.datetime :created_at
      t.string :description, :default=>""
      t.string :link
      t.string :ip

      t.timestamps
    end
  end

  def self.down
    drop_table :transfers
  end
end
