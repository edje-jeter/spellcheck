# frozen_string_literal: true

require_relative "./file_reader"
require_relative "./line_reader"
require_relative "./checker"

module Word
  class SpellChecker
    attr_reader :word_count_total, :unrecognized_word_count_total

    def initialize(text_path, dictionary)
      @file_reader = ::Word::FileReader.new(text_path)
      @word_checker = ::Word::Checker.new(dictionary)

      @line = ""
      @line_idx = 0
      @line_before = ""
      @word_count_total = 0
      @unrecognized_word_count_total = 0
      @unrecognized_word = ""
      @unrecognized_word_idx = 0
      @unrecognized_word_idx_before = 0
      @max_snippet = ""

      read_next_line
    end

    def add_unrecognized_word(unrecognized_word)
      @unrecognized_word = unrecognized_word
      @unrecognized_word_count_total += 1
      @max_snippet = [ @line_before, @line ].join(" ").strip
      @unrecognized_word_idx = @max_snippet.index(@unrecognized_word, @unrecognized_word_idx_before + 1)
      @unrecognized_word_idx_before = @unrecognized_word_idx
    end

    def report_args
      [ @line_idx, @unrecognized_word, @unrecognized_word_idx, @max_snippet ]
    end

    def read_next_line
      @line_before = @line # NOTE: update line_before before re-assigning @line
      @line = @file_reader.next_line
      return if @line.nil?

      @line_reader = ::Word::LineReader.new(@line)
      @line_idx = @file_reader.line_idx
      @word_count_total += @line_reader.word_count
      @unrecognized_word = ""
      @unrecognized_word_idx = 0
      @unrecognized_word_idx_before = @line_before.length - 1
      @max_snippet = ""
    end

    def next_unrecognized_word
      word = @line_reader.next_word

      if unrecognized?(word)
        add_unrecognized_word(word[:word])
        return word[:word]
      end

      read_next_line if word.nil?
      return if @line.nil?

      next_unrecognized_word
    end

    def next_unrecognized_word_report_args
      [ @line_idx, @unrecognized_word, @unrecognized_word_idx, @max_snippet ]
    end

    def unrecognized?(word)
      return false if word.nil?

      @word_checker.unrecognized?(word[:word], word[:sentence_starter])
    end
  end
end
