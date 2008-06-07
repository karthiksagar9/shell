class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.string :type, :title
      t.text :summary, :body
      t.string :state
      t.datetime :published_at
      t.timestamps
    end
    add_index :contents, [:type, :published_at]
    add_index :contents, [:state, :published_at]
  end

  def self.down
    drop_table :contents
  end
end
