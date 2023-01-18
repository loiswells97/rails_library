class TargetsController < ApplicationController
  STATUS_SORT_ORDER = ['Yes', 'In progress', 'No']

  def index
    @targets = Target.all
  end

  def show
    @target = Target.find(params[:id])
    target_books = Book.all.where("date_finished_reading > ?", @target.start_date).and(
      Book.all.where("date_finished_reading < ?", @target.end_date)
    )
    @books = sort_books(target_books)
  end

  def new
    @target = Target.new
  end

  def create
    @target = Target.new(target_params)
    if @target.save
      redirect_to(targets_path)
    else
      render('new')
    end
  end

  def edit
    @target = Target.find(params[:id])
  end

  def update
    @target = Target.find(params[:id])
    if @target.update(target_params)
      redirect_to(targets_path)
    else
      render('edit')
    end
  end

  def delete
    @target = Target.find(params[:id])
  end

  def destroy
    @target = Target.find(params[:id])
    @target.destroy
    redirect_to(targets_path)
  end

  def target_progress(target)
    books = Book.all.where("date_finished_reading > ?", target.start_date).and(
      Book.all.where("date_finished_reading < ?", target.end_date)
    )
    if target.target_type == 'books'
      return books.length
    elsif target.target_type == 'pages'
      return books.sum{|book| book.number_of_pages}
    end
  end
  helper_method :target_progress

  private
    def target_params
      params.require(:target).permit(:target_type, :target, :start_date, :end_date)
    end
    
    def sort_books(books)
      if params[:sort].nil?
        return books.sort_by{|book| book[:title]}
      elsif params[:sort] == 'has_been_read'
        return books.sort_by{|book| STATUS_SORT_ORDER.find_index(book[params[:sort]])}
      elsif params[:sort] == 'author'
        return books.sort_by{|book| book.author.surname}
      else
        return books.sort_by{|book| book[params[:sort]] || 0}
      end
    end
end
