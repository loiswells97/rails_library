class AuthorsController < ApplicationController
  def index
    @authors = Author.order(:surname)
  end

  def show
    @author = Author.find(params[:id])
  end
end
