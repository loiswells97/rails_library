class AddReadColumnToBooksTable < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :has_been_read, :string, :default => "No"
  end
end
