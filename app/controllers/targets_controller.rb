class TargetsController < ApplicationController

  def index
    @targets = Target.all
  end

  def show
    @target = Target.find(params[:id])
    @books = Book.all.where("date_finished_reading > ?", @target.start_date).and(
      Book.all.where("date_finished_reading < ?", @target.end_date)
    )
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
end
