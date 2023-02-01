module BooksHelper

  STATUS_SORT_ORDER = ['Yes', 'In progress', 'No']

  def filter_and_sort_books(books, sort, search_term)
    filtered_books = filter_books(books, search_term)
    return sort_books(filtered_books, sort)
  end

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

  def filter_books(books, search_term)
    return books if search_term.nil?
    title_results = books.where("lower(title) LIKE (?)", "%#{search_term}%")
    author_results = books.joins(:author).where("lower(authors.first_name || ' ' || authors.surname) LIKE (?)", "%#{search_term}%")
    subtitle_results = books.where("lower(subtitle) LIKE (?)", "%#{search_term}%")
    blurb_results = books.where("lower(blurb) LIKE (?)", "%#{search_term}%")
    publisher_results = books.where("lower(publisher) LIKE (?)", "%#{search_term}%")
    series_results = books.joins(:series).where("lower(series.title) LIKE (?)", "%#{search_term}%")
    list_results = books.joins(:lists).where("lower(lists.title) LIKE (?)", "%#{search_term}%")
    (title_results + author_results + series_results + subtitle_results + list_results + blurb_results + publisher_results).uniq
  end
end
