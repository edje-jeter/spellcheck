class RenameWordsToWordInDictionaryWords < ActiveRecord::Migration[8.0]
  def change
    rename_column :dictionary_words, :words, :word
  end
end
