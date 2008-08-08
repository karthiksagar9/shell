class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
	  t.column :permalink,					:string
      t.column :name,                      :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code, :string, :limit => 40
      t.column :activated_at, :datetime
      t.column :deleted_at, :datetime
      t.column :identity_url, :string
      t.column :state, :string, :null => :no, :default => 'pending'
      t.column :role, :string, :null => :no, :default => 'subscriber'
    end
    add_index :users, [:login]
    add_index :users, [:state, :role]
  end

  def self.down
    drop_table "users"
  end
end
