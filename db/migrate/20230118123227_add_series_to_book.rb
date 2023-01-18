class AddSeriesToBook < ActiveRecord::Migration[7.0]
  def change
    add_reference :books, :series, foreign_key: true
    add_column :books, :series_number, :integer
  end
end
