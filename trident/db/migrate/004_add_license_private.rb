class AddLicensePrivate < ActiveRecord::Migration
  def self.up
    add_column "snippets", "license_id", :integer
    add_column "snippets", "published", :string
    create_table "licenses", :force => true do |t|
      t.column :name,                     :string
      t.column :text,                     :text
    end
  end

  def self.down
    remove_column "snippets", "license"
    remove_column "snippets", "published"
    drop_table "licenses"
  end
end
