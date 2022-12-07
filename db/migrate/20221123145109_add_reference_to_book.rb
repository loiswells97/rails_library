class AddReferenceToBook < ActiveRecord::Migration[7.0]
  def up
    add_reference :books, :author, foreign_key: true
    Book.all.each do |book|
      author_name = book.author_name
      author_first_name = author_name.split(' ')[0..-2].join(' ')
      author_surname = author_name.split(' ').last
      author = Author.find_by(first_name: author_first_name, surname: author_surname)
      book.author = author
      book.save
    end
  end

  def down
    remove_column :books, :author_id
  end
end
