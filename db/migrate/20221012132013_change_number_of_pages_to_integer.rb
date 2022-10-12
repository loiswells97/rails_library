class ChangeNumberOfPagesToInteger < ActiveRecord::Migration[7.0]
  def change
    change_column :books, :number_of_pages, :integer
  end
end
