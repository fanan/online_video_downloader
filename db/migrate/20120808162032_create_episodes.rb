class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.integer :number
      t.integer :series_id
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
