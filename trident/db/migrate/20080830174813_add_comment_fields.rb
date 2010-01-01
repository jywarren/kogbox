class AddCommentFields < ActiveRecord::Migration
  def self.up
    add_column :comments, "name", :string, :length => 40, :default => ""
    add_column :comments, "email", :string, :length => 60, :default => ""
  end

  def self.down
    remove_column :comments, "name"
    remove_column :comments, "email"
  end
end
