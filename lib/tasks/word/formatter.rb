include ActionView::Helpers::NumberHelper

module Word
  class Formatter
    attr_reader :line_idx, :words, :snips, :max_snippet

    SNIPPET_RADIUS = 35

    def initialize(line_idx, words, snips)
      @line_idx = line_idx
      @words = words.compact
      @snips = snips

      @max_snippet = snips.join(" ").strip
      @current_line_start_idx = snips[0].length
    end

    def format
      most_recent_idx = @current_line_start_idx

      words.map do |word|
        idx = max_snippet.index(word, most_recent_idx == 0 ? 0 : most_recent_idx + 1)
        most_recent_idx = idx
        RowFormatter.new(line_idx, word, idx, max_snippet).format
      end
    end

  private

    class RowFormatter
      attr_reader :word, :idx

      def initialize(line_idx, word, idx, max_snippet)
        @line_idx = line_idx
        @word = word
        @idx = idx
        @max_snippet = max_snippet
      end

      def format
        "#{number_with_delimiter(@line_idx).rjust(6)}  #{word.rjust(15)}:  \"#{snippet}\""
      end

    private

      def snippet
        text = snippet_with_emphasis
        start = snippet_start(text)
        stop = snippet_stop(text)
        snippet_with_emphasis[start..stop]
      end

      def snippet_start(text)
        raw_start = [ 0, idx - SNIPPET_RADIUS ].max
        raw_start == 0 ? 0 : raw_start + text[raw_start..idx].index(" ") + 1
      end

      def snippet_stop(text)
        max_possible_index = text.length - 1
        raw_stop = [ max_possible_index, idx + word.length + SNIPPET_RADIUS ].min
        raw_stop == max_possible_index ? raw_stop : raw_stop - 1 - text[idx..raw_stop].reverse.index(" ")
      end

      def snippet_with_emphasis
        emphasized_word = "\e[1m[#{word}]\e[0m"

        if idx == 0
          @max_snippet.sub(word, emphasized_word)
        else
          "#{@max_snippet[0..(idx - 1)]}#{@max_snippet[idx..-1].sub(word, emphasized_word)}"
        end
      end
    end
  end
end
