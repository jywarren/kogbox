class AddSnippetCreatedOn < ActiveRecord::Migration
  def self.up
    add_column "snippets", "created_on", :datetime
  end

  def self.down
    remove_column "snippets", "created_on"
  end
end
