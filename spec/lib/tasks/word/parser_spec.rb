require "rails_helper"
require_relative "../../../../lib/tasks/word/parser"

::RSpec.describe ::Word::Parser do
  describe "#parse" do
    let(:parsed) { ::Word::Parser.parse(text_line) }

    context "when terminal punctuation" do
      let(:text_line) { "lions, tigers; bears. penguins..." }
      let(:expected) do
        [
          { sentence_starter: true, word: "lions" },
          { sentence_starter: false, word: "tigers" },
          { sentence_starter: false, word: "bears" },
          { sentence_starter: true, word: "penguins" }
        ]
      end

      it "parses the text" do
        expect(parsed).to eq expected
      end
    end

    context "when terminal single quotation" do
      let(:text_line) { "kangaroos' koalas.' lemurs,' orangutans'. katydids'," }
      let(:expected) do
        [
          { sentence_starter: true, word: "kangaroos" },
          { sentence_starter: false, word: "koalas" },
          { sentence_starter: true, word: "lemurs" },
          { sentence_starter: false, word: "orangutans" },
          { sentence_starter: true, word: "katydids" }
        ]
      end

      it "parses the text" do
        expect(parsed).to eq expected
      end
    end

    context "when terminal double quotation" do
      let(:text_line) { 'kangaroos" koalas." lemurs," orangutans". katydids",' }
      let(:expected) do
        [
          { sentence_starter: true, word: "kangaroos" },
          { sentence_starter: false, word: "koalas" },
          { sentence_starter: true, word: "lemurs" },
          { sentence_starter: false, word: "orangutans" },
          { sentence_starter: true, word: "katydids" }
        ]
      end

      it "parses the text" do
        expect(parsed).to eq expected
      end
    end
  end
end
