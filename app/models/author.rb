class Author < ApplicationRecord
  has_many :books

  def full_name
    first_name!='' ? "#{first_name} #{surname}" : surname
  end

  def related
    books.map do |book|
      book.related.map {|related_book| related_book.author}
    end.flatten.uniq
  end

  def relatedness(author)
    books.sum {|book| author.books.sum {|author_book| book.relatedness_to(author_book)}}
  end
end
