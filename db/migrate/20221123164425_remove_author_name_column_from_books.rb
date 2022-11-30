class RemoveAuthorNameColumnFromBooks < ActiveRecord::Migration[7.0]
  def up
    remove_column :books, :author_name
  end

  def down
    add_column :books, :author_name, :string
    Book.all.each do |book|
      book.author_name = "#{book.author.first_name} #{book.author.surname}"
      book.save
    end
  end
end
