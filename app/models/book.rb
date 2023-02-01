class Book < ApplicationRecord
  belongs_to :author
  belongs_to :series, optional: true
  accepts_nested_attributes_for :author
  accepts_nested_attributes_for :series
  has_and_belongs_to_many :lists
  has_one_attached :photo, :dependent => :destroy
end
