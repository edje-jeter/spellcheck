module Word
  class Suggester
    SUGGESTION_BANK_BATCH_SIZE = 25_000

    attr_reader :creation_duration, :word_count, :suggestions

    def initialize(dictionary)
      @dictionary = dictionary.to_a.each_slice(SUGGESTION_BANK_BATCH_SIZE)
      ::DictionaryWord.delete_all
      @word_count = 0
      @suggestions = {}
      @duration = 0.0
    end

    def add_words(words)
      @creation_time_start ||= Time.now
      ::DictionaryWord.insert_all!(words.map { |word| { word: word } })
      @word_count += words.size
      @creation_duration = Time.now - @creation_time_start
    end

    # def batch_size
    #   SUGGESTION_BANK_BATCH_SIZE
    # end

    def batches
      @dictionary.to_a.each_slice(SUGGESTION_BANK_BATCH_SIZE).map { |batch| batch }.first
    end

    def next_batch
      @dictionary.next
    rescue StopIteration
      nil
    end

    # def create_suggestion_bank
    #   time_start = Time.now
    #   ::DictionaryWord.delete_all

    #   @dictionary.each_slice(SUGGESTION_BANK_BATCH_SIZE) do |words|
    #     ::DictionaryWord.insert_all!(words.map { |word| { word: word } })
    #     @word_count += words.size
    #     puts batch_msg(words)
    #   end

    #   @duration = Time.now - time_start
    # end

    def add_suggestion(word_original)
      word = word_original.downcase
      return @suggestions[word] if @suggestions[word]

      @patterns = Patterns.new(word)
      suggestion = first_suggestions.presence || second_suggestions
      @suggestions[word] = suggestion

      suggestion
    end

  private

    attr_reader :patterns

    def batch_msg(words)
      [
        "  Added #{number_with_delimiter(words.size)} words:",
        "#{number_with_delimiter(@word_count)}"
      ].join(" ")
    end

    def first_suggestions
      conditions = patterns.first_attempt.map { |pattern| "word LIKE ?" }.join(" OR ")
      values = patterns.first_attempt.map { |pattern| pattern }

      ::DictionaryWord.where(conditions, *values).map { |dw| dw.word }
    end

    def second_suggestions
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
