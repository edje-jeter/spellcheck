# frozen_string_literal: true

module Word
  class Parser
    SEPARATORS = [
      " ",    # space
      "...",  # ellipsis
      "-",    # hyphen
      "--",   # double hyphen (en dash)
      "---"   # triple hyphen (em dash)
    ].freeze

    SENTENCE_ENDERS = [ # NOTE: order matters; longer punctuation first to avoid partial matches
      ".'",   # period + single quote
      "'.",   # single quote + period
      '."',   # period + double quote
      '".',   # double quote + period
      ".",    # period

      "?'",   # question mark + single quote
      "'?",   # single quote + question mark
      '?"',   # question mark + double quote
      '"?',   # double quote + question mark
      "?",    # question mark

      "!'",   # exclamation mark + single quote
      "'!",   # single quote + exclamation mark
      '!"',   # exclamation mark + double quote
      '"!',   # double quote + exclamation mark
      "!"     # exclamation point
    ].freeze

    INITIAL_PUNCTUATION = [
      "'",    # single quote
      '"'     # double quote
    ].freeze

    TERMINAL_PUNCTUATION = [ # NOTE: order matters; longer punctuation first to avoid partial matches
      ".'",   # period + single quote
      "'.",   # single quote + period
      '."',   # period + double quote
      '".',   # double quote + period

      ",'",   # comma + single quote
      "',",   # single quote + comma
      ',"',   # comma + double quote
      '",',   # double quote + comma

      "?'",   # question mark + single quote
      "'?",   # single quote + question mark
      '?"',   # question mark + double quote
      '"?',   # double quote + question mark
      "?",    # question mark

      "!'",   # exclamation mark + single quote
      "'!",   # single quote + exclamation mark
      '!"',   # exclamation mark + double quote
      '"!',   # double quote + exclamation mark
      "!",    # exclamation point

      "...",  # ellipsis
      "..",   # double period
      ".",    # period

      "---",  # triple hyphen (em dash)
      "--",   # double hyphen (en dash)
      "-",    # hyphen

      ",",    # comma
      ";",    # semicolon
      ":",    # colon
      "?",    # question mark
      "!",    # exclamation point

      "'",    # single quote
      '"'     # double quote
    ].freeze

    def self.parse(text_line)
      words = text_line.split(::Regexp.union(SEPARATORS)).reject(&:empty?)
      words.map.with_index { |word, idx| to_word_hash(words, word, idx) }
           .map { |word_hash| remove_initial_punctuation(word_hash) }
           .map { |word_hash| remove_terminal_punctuation(word_hash) }
    end

  private

    def self.to_word_hash(words, word, idx)
      { word: word, sentence_starter: sentence_starter?(words, idx) }
    end
    private_class_method :to_word_hash

    def self.sentence_starter?(words, idx)
      idx == 0 || (words[idx - 1].end_with?(*SENTENCE_ENDERS))
    end

    def self.remove_initial_punctuation(word_hash)
      new_word = word_hash[:word]

      INITIAL_PUNCTUATION.each do |punctuation|
        new_word.delete_prefix!(punctuation)
      end

      word_hash[:word] = new_word
      word_hash
    end
    private_class_method :remove_initial_punctuation

    def self.remove_terminal_punctuation(word_hash)
      new_word = word_hash[:word]

      TERMINAL_PUNCTUATION.each do |punctuation|
        new_word.delete_suffix!(punctuation)
      end

      word_hash[:word] = new_word
      word_hash
    end
    private_class_method :remove_terminal_punctuation
  end
end
