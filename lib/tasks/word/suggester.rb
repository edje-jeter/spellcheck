module Word
  class Suggester
    attr_reader :word, :patterns

    def initialize(word)
      @word = word
      @patterns = Patterns.new(word)
    end

    def suggestions
      output = first_suggestions
      return output if output.present?

      output = second_suggestions(output)
      output
    end

  private

    def first_suggestions
      conditions = patterns.first_attempt.map { |pattern| "word LIKE ?" }.join(" OR ")
      values = patterns.first_attempt.map { |pattern| pattern }

      ::DictionaryWord.where(conditions, *values).map { |dw| dw.word }
    end

    def second_suggestions(output)
      return [] if patterns.multi_error_ending.empty?

      conditions = patterns.multi_error_ending.map { |pattern| "word LIKE ?" }.join(" OR ")
      values = patterns.multi_error_ending.map { |pattern| pattern }

      ::DictionaryWord.where(conditions, *values)
                      .map { |dw| dw.word }
                      .filter { |suggestion| suggestion =~ patterns.multi_error_ending_regex_filter }
    end

    class Patterns
      MULTI_ERROR_ENDING_BASE_SIZE = 3
      MULTI_ERROR_ENDING_MIN_SIZE = 5

      attr_reader :word

      def initialize(word)
        @word = word
      end

      def first_attempt
        [
          single_deletion,
          single_error,
          single_insertion,
          double_insertion,
          single_inversion
        ].flatten
      end

      # single deletion: unusually --> unusally; there --> ther
      def single_deletion
        (0..word.length).map { |i| word.dup.insert(i, "_") }.uniq
      end

      # single error: unusually --> unusuzlly
      def single_error
        (0..(word.length - 1)).map do |i|
          pattern = word.dup
          pattern[i] = "_"
          pattern
        end.uniq
      end

      # single insertion: apple --> appple; playing --> playeing; happily --> happilly
      # appple <-- ppple, apple, apple, apple, apppe, apppl
      def single_insertion
        (0...word.length).map { |i| word[0...i] + word[i+1..-1] }.uniq
      end

      # double insertion: splat --> splaaat; laaat, saaat, spaat, splat, splat, splaa
      def double_insertion
        (0...(word.length - 1)).map { |i| word[0...i] + word[i+2..-1] }.uniq
      end

      # single position inversion: friends --> freinds
      def single_inversion
        (0...(word.length - 1)).map do |i|
          swapped_word = word.dup
          swapped_word[i], swapped_word[i+1] = swapped_word[i+1], swapped_word[i]
          swapped_word
        end
      end

      # multi_error_ending: a Hail-Mary for longer words when nothing else has worked
      # For words of at least, say, 8 chars, assume the first part of the word is right and
      # the total length isn't off by more than 1 short or two long.
      # embarrassed --> embarased: embar____, embar_____, embar______, embar_______, embar________
      def multi_error_ending
        return [] if word.length < MULTI_ERROR_ENDING_MIN_SIZE

        base = word[0..(MULTI_ERROR_ENDING_BASE_SIZE - 1)]

        (word.length - 1..word.length + 2).map do |i|
          base + ("_" * (i - MULTI_ERROR_ENDING_BASE_SIZE))
        end
      end

      def multi_error_ending_regex_filter
        /\A#{word[0..(MULTI_ERROR_ENDING_BASE_SIZE - 1)]}[#{word[MULTI_ERROR_ENDING_BASE_SIZE..-1]}]*\z/
      end
    end
  end
end
