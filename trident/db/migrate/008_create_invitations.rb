class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column "user_id",        :integer
      t.column "recipient",      :string
      t.column "key",            :string      
    end
  end

  def self.down
    drop_table :invitations
  end
end
