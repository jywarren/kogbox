class AddAncestorId < ActiveRecord::Migration
  def self.up
    add_column "snippets", "ancestor_id", :integer
  end

  def self.down
    remove_column "snippets", "ancestor_id"
  end
end
