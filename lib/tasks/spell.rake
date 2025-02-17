# frozen_string_literal: true

require_relative "./word/file_checker"
require_relative "./word/formatter"
require_relative "./word/suggester"

namespace :spell do
  desc "Identify unrecognized words in a text"

  task :check, [ :dictionary_path, :text_path ] => :environment do |_t, args|
    include ActionView::Helpers::NumberHelper

    time_start = Time.now
    puts "===================================="
    puts "--- Running spellcheck ---"
    puts "------------------------------------"

    text_path = args[:text_path]
    abort "Spellcheck ended because text file not found: #{text_path}" unless ::File.file?(text_path)
    puts "#{'File:'.rjust(12)} #{text_path} (#{number_to_human_size(::File.size(text_path))})"

    dictionary_path = args[:dictionary_path]
    abort "Spellcheck ended because dictionary file not found: #{text_path}" unless ::File.file?(text_path)
    puts "#{'Dictionary:'.rjust(12)} #{dictionary_path} (#{number_to_human_size(::File.size(dictionary_path))})"
    puts ""

    puts "--- Reading dictionary file ---"
    dictionary = ::Set.new
    ::File.foreach(dictionary_path, chomp: true).each do |dictionary_line|
      dictionary.add(dictionary_line.downcase)
    end
    puts "  Found #{number_with_delimiter(dictionary.size)} words"
    puts ""

    puts "--- Initializing suggester database ---"
    puts "--- Clearing existing suggester ---"
    ::DictionaryWord.delete_all
    puts ""

    puts "--- Adding words to suggester ---"
    added_word_count = 0
    slice_size = 30_000
    dictionary.each_slice(slice_size) do |slice|
      ::DictionaryWord.insert_all!(slice.map { |word| { word: word } })
      added_word_count += slice.size
      puts "  Added #{number_with_delimiter(slice.size)} words: #{number_with_delimiter(added_word_count)}"
    end

    time_suggester_stop = Time.now
    time_suggester_duration = (time_suggester_stop - time_start).round(2)
    puts ""
    puts "  Dictionary initialized with #{number_with_delimiter(added_word_count)} words in #{time_suggester_duration} seconds"
    puts ""

    puts "--- Checking text for unrecognized words ---"
    puts ""

    file_checker = ::Word::FileChecker.new(text_path, dictionary)
    file_checker.check_file
    results_by_line = file_checker.results

    suggestions = {}
    results_by_line.pluck(:unrecognized_words).flatten.map(&:downcase).uniq.each do |word|
      suggestions[word] = ::Word::Suggester.new(word).suggestions
    end

    formatter = ::Word::Formatter.new(results_by_line, suggestions)

    if results_by_line.empty?
      puts "No unrecognized words found!"
    else
      puts formatter.header_row
      puts formatter.header_divider_row
      formatter.formatted_rows.each do |formatted_row|
        puts formatted_row
      end
    end

    puts "===================================="
    puts ""

    time_stop = Time.now
    summary_msg = [
      "Spellcheck completed in #{(time_stop - time_start).round(2)} seconds.",
      "It found #{file_checker.unrecognized_word_count_total} unrecognized words",
      "out of #{file_checker.word_count_total} total words."
    ].join(" ")
    puts summary_msg

    puts ""
    puts "===================================="
    puts ""
  end
end
