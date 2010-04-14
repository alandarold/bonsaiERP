class CreateOrganisations < ActiveRecord::Migration
  def self.up
    create_table :organisations do |t|
      t.references :country
      t.references :currency
      t.string :name, :limit => 100
      t.string :address
      t.string :address_alt
      t.string :phone, :limit => 20
      t.string :phone_alt, :limit => 20
      t.string :mobile, :limit => 20
      t.string :email
      t.string :website
      t.integer :user_id

      t.timestamps
    end
    add_index :organisations, :country_id
    add_index :organisations, :currency_id
  end

  def self.down
    drop_table :organisations
  end
end
