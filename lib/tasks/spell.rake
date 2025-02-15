# frozen_string_literal: true

require_relative "./word/checker"
require_relative "./word/formatter"
require_relative "./word/parser"

namespace :spell do
  desc "Identify unrecognized words in a text"

  task :check, [ :dictionary_path, :text_path ] => :environment do |_t, args|
    include ActionView::Helpers::NumberHelper

    time_start = Time.now
    puts "Running spellcheck"

    # dictionary_path = args[:dictionary_path]
    dictionary_path = "/Users/edjejeter/dev/spellcheck/tmp/dictionary.txt"
    puts "Using dictionary from #{dictionary_path}."

    # text_path = args[:text_path]
    text_path = "/Users/edjejeter/dev/spellcheck/tmp/text_sample_alpha.txt"

    dictionary_file_size = ::File.size(dictionary_path)
    puts "Dictionary file size: #{dictionary_file_size}"

    # Establish dictionary
    dictionary = ::Set.new

    ::File.foreach(dictionary_path, chomp: true).each do |dictionary_line|
      dictionary.add(dictionary_line.downcase)
    end

    unrecognized_words = []
    snippet_lines = [ "", "", "" ] # 3 lines of context: before, current, after

    SNIPPET_RADIUS = 30

    # results = ::File.foreach(text_path, chomp: true).map.with_index do |text_line, line_idx|      # output existing notes
    #   snippet_lines = snippet_lines.drop(1) if snippet_lines.length >= 3
    #   snippet_lines = snippet_lines << text_line.strip

    #   # unrecognized_words.compact.each do |unrecognized_word|
    #   #   # snippet = raw_snippet[left_start..right_end]
    #   #   snippet = "placeholder"

    #   #   puts "#{number_with_delimiter(line_idx).to_s.rjust(6)}  #{unrecognized_word.to_s.rjust(20)}:  \"#{snippet}\""
    #   # end
    #   ::Word::Formatter.new(line_idx, unrecognized_words, snippet_lines).format.each do |formatted_line|
    #     puts formatted_line
    #   end

    #   unrecognized_words = []

    #   ::Word::Parser.parse(text_line).each do |word|
    #     unrecognized_words << ::Word::Checker.new(word.downcase, dictionary).check
    #   end
    # end
    snips = [ "", "", "" ] # 3 lines of context: before, current, after
    results = [] # { line_idx: 0, unrecognized_words: [], snips: "" }
    need_to_add_next_snip = false

    ::File.foreach(text_path, chomp: true).map.with_index do |text_line, line_idx|      # output existing notes
      snips = snips.drop(1) if snips.length >= 3
      snips = snips << text_line.strip

      if need_to_add_next_snip
        results.last[:snips] = snips
        need_to_add_next_snip = false
      end

      unrecognized_words = ::Word::Parser.parse(text_line).map do |word|
        ::Word::Checker.new(word, dictionary).check
      end.compact

      if unrecognized_words.any?
        results << { line_idx: line_idx, unrecognized_words: unrecognized_words, snips: [] }
        need_to_add_next_snip = true
      end
    end

    results.each do |result|
      # puts result
      ::Word::Formatter.new(result[:line_idx], result[:unrecognized_words], result[:snips]).format.each do |formatted_line|
        puts formatted_line
      end
    end

    # TODO: output stuff from last line (because we output the notes for the previous line when we read a line; for the last line there is no next line)


    puts "===================================="
    # puts "Unrecognized words: #{unrecognized_words.join(', ')}"

    time_stop = Time.now
    puts "Spellcheck completed in #{time_stop - time_start} seconds"
  end
end
