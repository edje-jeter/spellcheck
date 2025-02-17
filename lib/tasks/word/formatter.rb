include ActionView::Helpers::NumberHelper

module Word
  class Formatter
    SNIPPET_RADIUS = 35
    COLUMN_WIDTH_LINE_NUM = 8
    COLUMN_WIDTH_WORD = 15

    def initialize(results, suggestions)
      @results = results
      @suggestions = suggestions
    end

    def formatted_rows
      return [ "No unrecognized words found!" ] if @results.empty?

      @results.map do |result_by_line|
        Line.new(result_by_line, column_width_word, @suggestions).format
      end
    end

    def header_row
      [
        "Line".rjust(COLUMN_WIDTH_LINE_NUM),
        "Word".rjust(column_width_word),
        "   Context / Suggestions"
      ].join("")
    end

    def header_divider_row
      [
        "-----".rjust(COLUMN_WIDTH_LINE_NUM),
        ("-" * (column_width_word - 2)).rjust(column_width_word),
        "   ------------------------"
      ].join("")
    end

    def column_width_word
      @column_width_word ||= [ largest_word_length + 3, COLUMN_WIDTH_WORD ].max
    end

  private

    def largest_word_length
      @largest_word_length ||= @results.flat_map { |result| result[:unrecognized_words] }.map(&:length).max || 0
    end

    class Line
      def initialize(result_by_line, column_width_word, suggestions)
        @column_width_word = column_width_word
        @line_idx = result_by_line[:line_idx]
        @words = result_by_line[:unrecognized_words].compact
        @suggestions = suggestions

        snips = result_by_line[:snips]

        @max_snippet = snips.join(" ").strip
        @current_line_start_idx = snips[0].length
      end

      def format
        most_recent_idx = @current_line_start_idx

        @words.map do |word|
          idx = @max_snippet.index(word, most_recent_idx == 0 ? 0 : most_recent_idx + 1)
          most_recent_idx = idx
          snippet = Snippet.new(word, idx, @max_snippet).build

          [
            number_with_delimiter(@line_idx).rjust(COLUMN_WIDTH_LINE_NUM),
            "#{word.rjust(@column_width_word)}:  ",
            snippet,
            "\n",
            " " * (COLUMN_WIDTH_LINE_NUM + @column_width_word + 3),
            @suggestions[word.downcase].present? ? "...#{@suggestions[word.downcase].join(', ')}" : "[no suggestions]",
            "\n",
            "\n"
          ].join("")
        end
      end
    end

    class Snippet
      attr_reader :word, :idx

      def initialize(word, idx, max_snippet)
        @word = word
        @idx = idx
        @max_snippet = max_snippet
      end

      def build
        text = snippet_with_emphasis
        snippet_with_emphasis[start(text)..stop(text)]
      end

    private

      def start(text)
        raw_start = [ 0, idx - SNIPPET_RADIUS ].max
        raw_start == 0 ? 0 : raw_start + text[raw_start..idx].index(" ") + 1
      end

      def stop(text)
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
