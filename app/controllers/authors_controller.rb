class AuthorsController < ApplicationController
  def index
    search_term = filter_params[:search_term]
    filtered_authors = Author.where("lower(first_name || ' ' || surname) LIKE (?)", "%#{search_term}%")
    @authors = search_term.nil? ? Author.order(:surname) : filtered_authors.order(:surname)
  end

  def show
    @author = Author.find(params[:id])
  end

  private
    def filter_params
      params.fetch(:filter, {}).permit(:search_term)
    end
end
