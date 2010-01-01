class CreateIncludes < ActiveRecord::Migration
  def self.up
    create_table :includes do |t|
      t.column "snippet_id",     :integer
      t.column "user_id",        :integer
      t.column "parent_id",      :integer
    end
  end

  def self.down
    drop_table :includes
  end
end
