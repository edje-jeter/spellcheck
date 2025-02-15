require "rails_helper"
require_relative "../../../../lib/tasks/word/parser"

::RSpec.describe ::Word::Parser do
  describe "#parse" do
    let(:parsed) { ::Word::Parser.parse(text_line) }

    context "when spaces" do
      let(:text_line) { "My name is Inigo Montoya" }

      it "parses the text" do
        expect(parsed).to eq([ "My", "name", "is", "Inigo", "Montoya" ])
      end
    end

    context "when comma" do
      let(:text_line) { "Eats, shoots, and leaves" }

      it "parses the text" do
        expect(parsed).to eq([ "Eats", "shoots", "and", "leaves" ])
      end
    end

    context "when period" do
      let(:text_line) { "The end. The beginning" }

      it "parses the text" do
        expect(parsed).to eq([ "The", "end", "The", "beginning" ])
      end
    end

    context "when terminal punctuation" do
      let(:text_line) { "lions, tigers; bears. penguins..." }

      it "parses the text" do
        expect(parsed).to eq([ "lions", "tigers", "bears", "penguins" ])
      end
    end

    context "when terminal comma" do
      let(:text_line) { "First off," }

      it "parses the text" do
        expect(parsed).to eq([ "First", "off" ])
      end
    end

    context "when terminal single quotation" do
      let(:text_line) { "kangaroos' koalas.' lemurs,' orangutans'. katydids'," }

      it "parses the text" do
        expect(parsed).to eq([ "kangaroos", "koalas", "lemurs", "orangutans", "katydids" ])
      end
    end

    context "when terminal double quotation" do
      let(:text_line) { 'kangaroos" koalas." lemurs," orangutans". katydids",' }

      it "parses the text" do
        expect(parsed).to eq([ "kangaroos", "koalas", "lemurs", "orangutans", "katydids" ])
      end
    end
  end
end
