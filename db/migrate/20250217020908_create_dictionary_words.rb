class CreateDictionaryWords < ActiveRecord::Migration[8.0]
  def change
    create_table :dictionary_words do |t|
      t.string :words

      t.timestamps
    end
  end
end
