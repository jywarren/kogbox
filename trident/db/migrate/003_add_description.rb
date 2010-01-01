class AddDescription < ActiveRecord::Migration
  def self.up
    add_column "snippets", "description", :text
    add_column "users", "fullname", :string
  end

  def self.down
    remove_column "snippets", "description"
    remove_column "users", "fullname"
  end
end
