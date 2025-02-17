require_relative "./checker"
require_relative "./parser"

module Word
  class FileChecker
    attr_reader :results, :word_count_total, :unrecognized_word_count_total

    def initialize(text_path, dictionary)
      @text_path = text_path
      @dictionary = dictionary

      @snips = [ "", "", "" ] # 3 lines of context: before, current, after
      @results = [] # { line_idx: 0, unrecognized_words: [], snips: [] }
      @need_to_add_next_snip = false
      @word_count_total = 0
      @unrecognized_word_count_total = 0
    end

    def check_file
      ::File.foreach(@text_path, chomp: true).map.with_index do |text_line, line_idx|
        check_line(text_line, line_idx)
      end

      # Snips update before each line; we need to update the last line's snips
      update_snips("")
    end

  private

    def check_line(text_line, line_idx)
      update_snips(text_line)
      words_in_line = ::Word::Parser.parse(text_line)
      @word_count_total += words_in_line.size

      unrecognized_words = words_in_line.map do |word_hash|
        ::Word::Checker.new(@dictionary, word_hash[:word], word_hash[:sentence_starter]).check
      end.compact
      @unrecognized_word_count_total += unrecognized_words.size

      if unrecognized_words.any?
        @results << { line_idx: line_idx, unrecognized_words: unrecognized_words }
        @need_to_add_next_snip = true
      end
    end

    def update_snips(text_line)
      @snips = @snips.drop(1) if @snips.length >= 3
      @snips = @snips << text_line.strip

      if @need_to_add_next_snip
        @results.last[:snips] = @snips
        @need_to_add_next_snip = false
      end
    end
  end
end
