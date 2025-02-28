# frozen_string_literal: true

module Word
  class Checker
    RECOGNIZED_CONTRACTIONS = ::Set.new(%w(
      i'm you're he's she's it's we're they're
      i'll you'll he'll she'll it'll we'll they'll
      i'd you'd he'd she'd it'd we'd they'd
      i've you've he's she's it's we've they've
      isn't aren't wasn't weren't haven't hasn't hadn't don't doesn't didn't
      can't won't wouldn't couldn't shouldn't mightn't mustn't
      let's y'all ain't o'clock
    ])).freeze

    RECOGNIZED_SINGLE_CHAR_WORDS = ::Set.new(%w[a i]).freeze

    # FUTURE: contractions with more than one apostrophe, eg, fo'c'sle or fo'c's'le
    # FUTURE: contractions with hyphens, eg, I'd've or I'dn't've
    # FUTURE: different characters for apostrophe, eg, '’´

    attr_reader :dictionary, :word, :word_original

    def initialize(dictionary)
      @dictionary = dictionary
    end

    def unrecognized?(word, sentence_starter = false)
      @word_original = word
      @word = word.downcase
      @sentence_starter = sentence_starter

      return false if word.empty?
      return false if capitalized_and_not_sentence_start?
      return false if recognized_contraction?
      return false if recognized_single_character_word?
      return false if number?
      return true if has_non_letters? && !possessive?
      return false if in_dictionary? # we want the dictionary lookup to be last because it's the most expensive

      true
    end

  private

    def capitalized_and_not_sentence_start?
      !@sentence_starter && @word_original.match?(/\A[A-Z]{1}[a-z']*\z/)
    end

    def has_non_letters?
      !word.match?(/\A[a-z]+\z/)
    end

    def in_dictionary?
      word_to_look_up = (possessive? ? word.delete_suffix("'s") : word).downcase
      dictionary.include?(word_to_look_up)
    end

    def number?
      word.match?(/\A[-]?[$]?[0-9,.]+%?\z/)
    end

    def possessive?
      word.match?(/\A[a-z]+'s\z/)
    end

    def recognized_contraction?
      RECOGNIZED_CONTRACTIONS.include?(word)
    end

    def recognized_single_character_word?
      RECOGNIZED_SINGLE_CHAR_WORDS.include?(word)
    end
  end
end
