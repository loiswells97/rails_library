class AddFirstPublishedColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :year_first_published, :integer
  end
end
