class CreateSnippets < ActiveRecord::Migration
  def self.up
    create_table :snippets do |t|
      t.column "user_id",         :integer
      t.column "method_name",     :string
      t.column "code",            :text      
      t.column "language",        :string      
      t.column "version",         :integer, :default => "0"
    end
  end

  def self.down
    drop_table :snippets
  end
end
