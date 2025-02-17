class DictionaryWord < ApplicationRecord
  validates :words, presence: true
end
