module BooksHelper

  STATUS_SORT_ORDER = ['Yes', 'In progress', 'No']

  def sort_books(books, sort)
    if sort.nil?
      return books.sort_by{|book| book[:title]}
    elsif sort == 'has_been_read'
      return books.sort_by{|book| STATUS_SORT_ORDER.find_index(book[sort])}
    elsif sort == 'author'
      return books.sort_by{|book| book.author.surname}
    else
      return books.sort_by{|book| book[sort] || 0}
    end
  end
end
