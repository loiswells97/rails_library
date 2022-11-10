class RenameTargetTypeColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :targets, :type, :target_type
  end
end
