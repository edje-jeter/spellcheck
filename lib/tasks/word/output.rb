include ActionView::Helpers::NumberHelper

require_relative "./snippet"

module Word
  module Output
    COLUMN_WIDTH_LINE_NUM = 8
    COLUMN_WIDTH_WORD = 15
    TEXT_FILE_NOT_FOUND = "Spellcheck ended because text file not found."
    DICT_FILE_NOT_FOUND = "Spellcheck ended because dictionary file not found."

    attr_reader :time_start

    def bad_file_footer(file_path)
      [
        "",
        "====================================",
        "////// Spellcheck ended because file not found //////",
        file_path.present? ? "Path: #{file_path}" : "[path not provided]",
        "\n",
        "===================================="
      ].join("\n")
    end

    def main_footer
      time_stop = Time.now
      [
        "====================================",
        "\n\n",
        "Spellcheck completed in #{(time_stop - time_start).round(2)} seconds. ",
        "It found #{@spell_checker.unrecognized_word_count_total} unrecognized words ",
        "out of #{@spell_checker.word_count_total} total words.",
        "\n\n",
        "====================================",
        "\n\n",
        section_header("End of spellcheck")
      ].join("")
    end

    def main_header
      text_size = number_to_human_size(::File.size(@text_path))
      dict_size = number_to_human_size(::File.size(@dict_path))

      [
        "====================================",
        "--- Running spellcheck ---",
        "------------------------------------",
        "#{'File:'.rjust(12)} #{@text_path} (#{text_size})",
        "#{'Dictionary:'.rjust(12)} #{@dict_path} (#{dict_size})\n",
        section_header("Reading dictionary file"),
        "  Found #{number_with_delimiter(@dictionary.size)} words\n\n"
      ].join("\n")
    end

    def no_unrecognized_words_msg
      "\nNo unrecognized words found in the text.\n\n"
    end

    def section_header(title)
      "\n--- #{title} ---"
    end

    def suggestion_bank_batch_added_msg(word_count, suggestion_bank_word_count)
      [
        "  Added #{number_with_delimiter(word_count)} words:",
        "#{number_with_delimiter(suggestion_bank_word_count)}"
      ].join(" ")
    end

    def suggestion_bank_completed_msg(raw_word_count, raw_duration)
      word_count = number_with_delimiter(raw_word_count)
      duration = raw_duration.round(2)
      "\n  Suggestion bank populated with #{word_count} words in #{duration} seconds\n\n"
    end

    def unrecognized_word_report(*args)
      UnrecognizedWordReport.new(*args).generate
    end

    def unrecognized_words_report_header
        [
          section_header("Checking text for unrecognized words"),
          "\n",
          "Line".rjust(COLUMN_WIDTH_LINE_NUM),
          "Word".rjust(COLUMN_WIDTH_WORD),
          "   Context / Suggestions",
          "\n",
          "-----".rjust(COLUMN_WIDTH_LINE_NUM),
          ("-" * (COLUMN_WIDTH_WORD - 2)).rjust(COLUMN_WIDTH_WORD),
          "   ------------------------"
        ].join("")
    end

  private

    class UnrecognizedWordReport
      SUGGESTION_SPACER = " " * (COLUMN_WIDTH_LINE_NUM + COLUMN_WIDTH_WORD + 3)

      def initialize(line_idx, word, word_idx, max_snippet, suggestion)
        @line_idx = line_idx
        @word = word
        @word_idx = word_idx
        @max_snippet = max_snippet
        @suggestion = suggestion
      end

      def generate
        [
          number_with_delimiter(@line_idx).rjust(COLUMN_WIDTH_LINE_NUM),
          "#{@word.rjust(COLUMN_WIDTH_WORD)}:  ",
          ::Word::Snippet.new(@word, @word_idx, @max_snippet).build,
          "\n",
          SUGGESTION_SPACER,
          @suggestion.present? ? "...#{@suggestion.join(', ')}" : "[no suggestions]",
          "\n\n"
        ].join("")
      end
    end
  end
end
