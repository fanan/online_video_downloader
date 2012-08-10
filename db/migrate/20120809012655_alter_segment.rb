class AlterSegment < ActiveRecord::Migration
  def up
    rename_column :segments, :status, :status_id
    rename_column :segments, :format, :format_id
  end

  def down
    rename_column :segments, :status_id, :status
    rename_column :segments, :format_id, :format
  end
end
