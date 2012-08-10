class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :title
      t.string :url
      t.string :path, :null => false, :default => File.expand_path('~/Downloads')

      t.timestamps
    end
  end
end
