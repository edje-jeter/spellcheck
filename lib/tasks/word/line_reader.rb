require_relative "./line_parser"

module Word
  class LineReader
    attr_reader :line, :word_count

    def initialize(line)
      @line = line
      @words = ::Word::LineParser.parse(line) # TODO: make parser handle nil, empty, etc
      @word_count = @words.size
    end

    def next_word
      @words.shift
    end

    def word_position(word, start_position)
      @line.index(word, start_position)
    end
  end
end
