class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.integer :number
      t.integer :episode_id
      t.integer :size
      t.integer :format, :default => 1
      t.integer :status, :default => 1
      t.string :url

      t.timestamps
    end
  end
end
