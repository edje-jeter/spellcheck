require "rails_helper"
require_relative "../../../../lib/tasks/word/formatter"

::RSpec.describe ::Word::Formatter do
  describe "#format" do
    let(:formatted) { ::Word::Formatter.new(line_index, unrecognized_words, snippet_lines).format }
    let(:line_index) { 12_3456 }
    let(:unrecognized_words) { [ "lemurz", "girafe", "lemurz" ] }
    let(:snippet_lines) do
      [
        "The quick brown fox jumps over the lazy dog.",
        "Angry lemurz ate my girafe, so lemurz are not welcome here.",
        "Seriously, lemurz are not welcome here."
      ]
    end

    context "when no unrecognized words" do
      # it "returns nil" do
      #   expect(::Word::Formatter.new("", dictionary).format).to be_nil
      # end
    end

    context "when ... TODO" do
      let(:expected) do
        [
          "123,456           lemurz:  \"placeholder\"",
          "123,456           girafe:  \"placeholder\"",
          "123,456           lemurz:  \"placeholder\""
        ]
      end

      it "returns ..." do
        expect(formatted).to eq expected
      end
    end
  end
end
