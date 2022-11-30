class Book < ApplicationRecord
  belongs_to :author
  has_and_belongs_to_many :lists
  has_one_attached :photo, :dependent => :destroy
end
