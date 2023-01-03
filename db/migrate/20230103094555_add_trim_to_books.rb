class AddTrimToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :trim, :string
  end
end
