class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :subtitle
      t.string :author
      t.string :publisher
      t.string :publication_date
      t.string :number_of_pages

      t.timestamps
    end
  end
end
