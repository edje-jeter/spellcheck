# frozen_string_literal: true

require_relative "./word/output"
require_relative "./word/suggester"
require_relative "./word/spell_checker"

namespace :spell do
  desc "Identify unrecognized words in a text"

  task :check, [ :dict_path, :text_path ] => :environment do |_t, args|
    include ::Word::Output

    @time_start = Time.now
    @text_path = args[:text_path]
    @dict_path = args[:dict_path]

    abort bad_file_footer(@text_path) unless ::File.file?(@text_path)
    abort bad_file_footer(@dict_path) unless ::File.file?(@dict_path)

    @dictionary = ::File.readlines(@dict_path, chomp: true).map(&:downcase).to_set

    puts main_header

    puts section_header("Populating suggestion bank")
    suggester = ::Word::Suggester.new(@dictionary)

    suggester.batches.each do |words|
      suggester.add_words(words)
      puts suggestion_bank_batch_added_msg(words.size, suggester.word_count)
    end

    puts suggestion_bank_completed_msg(suggester.word_count, suggester.creation_duration)

    puts unrecognized_words_report_header
    @spell_checker = ::Word::SpellChecker.new(@text_path, @dictionary)

    while (unrecognized_word = @spell_checker.next_unrecognized_word)
      suggestion = suggester.add_suggestion(unrecognized_word)
      puts unrecognized_word_report(*@spell_checker.next_unrecognized_word_report_args, suggestion)
    end
    puts no_unrecognized_words_msg if @spell_checker.unrecognized_word_count_total.zero?

    puts main_footer
  end
end
