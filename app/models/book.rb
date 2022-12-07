class Book < ApplicationRecord
  belongs_to :author
  accepts_nested_attributes_for :author
  has_and_belongs_to_many :lists
  has_one_attached :photo, :dependent => :destroy
end
