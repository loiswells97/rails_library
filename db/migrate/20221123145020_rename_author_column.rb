class RenameAuthorColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :books, :author, :author_name
  end
end
