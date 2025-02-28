module Word
  class Snippet
    SNIPPET_RADIUS = 35

    attr_reader :word, :idx

    def initialize(word, idx, max_snippet)
      @word = word
      @idx = idx
      @max_snippet = max_snippet
    end

    def build
      text = snippet_with_emphasis
      text[start(text)..stop(text)]
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
