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
      text_line.split(::Regexp.union(SEPARATORS))
               .reject(&:empty?)
               .map(&:strip)
               .map { |word| remove_initial_punctuation(word) }
               .map { |word| remove_terminal_punctuation(word) }
    end

  private

    def self.remove_initial_punctuation(word)
      INITIAL_PUNCTUATION.each { |punctuation| word.delete_prefix!(punctuation) }
      word
    end
    private_class_method :remove_initial_punctuation

    def self.remove_terminal_punctuation(word)
      TERMINAL_PUNCTUATION.each { |punctuation| word.delete_suffix!(punctuation) }
      word
    end
    private_class_method :remove_terminal_punctuation
  end
end
