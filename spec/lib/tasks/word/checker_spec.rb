require "rails_helper"
require_relative "../../../../lib/tasks/word/checker"

::RSpec.describe ::Word::Checker do
  describe "#check" do
    let(:dictionary) { ::Set.new([ "lemur", "giraffe" ]) }

    context "when empty" do
      it "returns nil" do
        expect(::Word::Checker.new("", dictionary).check).to be_nil
      end
    end

    context "when recognized contraction" do
      it "returns nil" do
        expect(::Word::Checker.new("don't", dictionary).check).to be_nil
      end
    end

    context "when recognized single-character word" do
      it "returns nil" do
        expect(::Word::Checker.new("a", dictionary).check).to be_nil
      end
    end

    context "when number" do
      it "returns nil" do
        expect(::Word::Checker.new("-$1,234.56", dictionary).check).to be_nil
      end
    end

    context "when includes non-letters" do
      it "returns the original word" do
        expect(::Word::Checker.new("le.mur", dictionary).check).to eq "le.mur"
      end
    end

    context "when not in dictionary" do
      it "returns the original word" do
        expect(::Word::Checker.new("lemurzzz", dictionary).check).to eq "lemurzzz"
      end
    end

    context "when possessive and in dictionary" do
      it "returns nil" do
        expect(::Word::Checker.new("lemur's", dictionary).check).to be_nil
      end
    end

    context "when possessive and not in dictionary" do
      it "returns the original word" do
        expect(::Word::Checker.new("lemurz's", dictionary).check).to eq "lemurz's"
      end
    end

    context "when word in dictionary" do
      it "returns nil" do
        expect(::Word::Checker.new("lemur", dictionary).check).to be_nil
      end
    end
  end
end
