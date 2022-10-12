class AlterPublicationDateField < ActiveRecord::Migration[7.0]
  def change
    change_column :books, :publication_date, :integer
  end
end
