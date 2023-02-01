module RecommendationsHelper

  def related_books(books, read_status=['Yes', 'In progress', 'No'])
    authors = books.map{|book| book.author}
    lists = []
    books.each{|book| lists.append(*(book.lists.select {|list| !['Up Next 📖', 'Favourites 🌟'].include?(list.title)}))}
    author_recommendations = Book.where(author: [authors], has_been_read: read_status)
    list_recommendations = []
    lists.each do |list|
      list.books.where(has_been_read: read_status).each do |book|
        list_recommendations.append(book)
      end
    end
    series_list = books.map{|book| book.series}
    series_recommendations = []
    series_list.each do |series|
      if !series.nil?
        series.books.where(has_been_read: read_status).each do |book|
          series_recommendations.append(book)
        end
      end
    end

    return (author_recommendations + series_recommendations + list_recommendations)
  end

  def rogue_suggestions
    read_or_in_progress_books = Book.where(has_been_read: ['Yes', 'In progress'])
    if cookies[:rogue_wait].to_i > 0
      rogue_wait = cookies[:rogue_wait].to_i
      books_read_within_timeframe = read_or_in_progress_books.filter{|book| !book.date_finished_reading || book.date_finished_reading > rogue_wait.year.ago}
      non_rogue_books = related_books(books_read_within_timeframe) + read_or_in_progress_books
    else
      non_rogue_books = related_books(read_or_in_progress_books)
    end
    return Book.all - non_rogue_books
  end

  def rereads(books)
    rereads = related_books(books, read_status='Yes')
    reread_wait = cookies[:reread_wait].to_i || 1
    return rereads.filter{|book| book.date_finished_reading && book.date_finished_reading < reread_wait.year.ago}
  end

  def weighted_sample(array, n)
    result = []
    while result.length < [array.uniq.length, n].min
      random_sample = array.sample()
      result.append random_sample unless result.include?(random_sample)
    end
    result.sort_by{|element| array.count(element)}.reverse
  end

end
