class AddProdDevAndCounters < ActiveRecord::Migration
  def self.up
    add_column "snippets", "release", :string
    add_column "snippets", "last_marker", :datetime
    add_column "snippets", "count", :integer
    add_column "snippets", "total_use", :integer
  end

  def self.down
    remove_column "snippets", "release"
    remove_column "snippets", "last_marker"
    remove_column "snippets", "count"
    remove_column "snippets", "total_use"
  end
end
