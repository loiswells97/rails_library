require 'books_helper'

class Book < ApplicationRecord
  belongs_to :author
  belongs_to :series, optional: true
  accepts_nested_attributes_for :author
  accepts_nested_attributes_for :series
  has_and_belongs_to_many :lists
  has_one_attached :photo, :dependent => :destroy

  def title_and_author
    "#{title} (#{author.full_name})"
  end

  def related
    (related_by_author + related_by_series + related_by_list).uniq
  end

  def related_by_author
    author.books - [self]
  end

  def related_by_series
    series.books - [self]
  end

  def related_by_list
    lists.map { |list| list.books  - [self] }.flatten.uniq
  end

  def is_related?(book)
    related.include?(book)
  end

  def relatedness_to(book)
    related_by_list_with_duplicates = lists.map { |list| list.books  - [self] }.flatten
    (related_by_author + related_by_list + related_by_list_with_duplicates).count(book)
  end
end

