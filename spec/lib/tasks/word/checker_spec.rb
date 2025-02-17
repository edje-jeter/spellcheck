require "rails_helper"
require_relative "../../../../lib/tasks/word/checker"

::RSpec.describe ::Word::Checker do
  describe "#check" do
    let(:dictionary) { ::Set.new([ "lemur", "giraffe" ]) }

    context "when empty" do
      it "returns nil" do
        expect(::Word::Checker.new(dictionary, "").check).to be_nil
      end
    end

    context "when capitalized and not sentence start" do
      it "returns nil" do
        expect(::Word::Checker.new(dictionary, "George", false).check).to be_nil
      end
    end

    context "when capitalized and sentence start" do
      it "returns the original word" do
        expect(::Word::Checker.new(dictionary, "George", true).check).to eq "George"
      end
    end

    context "when non-capitalized proper noun (not in dictionary)" do
      it "returns the original word" do
        expect(::Word::Checker.new(dictionary, "george", false).check).to eq "george"
      end
    end

    context "when recognized contraction" do
      it "returns nil" do
        expect(::Word::Checker.new(dictionary, "don't").check).to be_nil
      end
    end

    context "when recognized single-character word" do
      it "returns nil" do
        expect(::Word::Checker.new(dictionary, "a").check).to be_nil
      end
    end

    context "when number" do
      it "returns nil" do
        expect(::Word::Checker.new(dictionary, "-$1,234.56").check).to be_nil
      end
    end

    context "when includes non-letters" do
      it "returns the original word" do
        expect(::Word::Checker.new(dictionary, "le.mur").check).to eq "le.mur"
      end
    end

    context "when not in dictionary" do
      it "returns the original word" do
        expect(::Word::Checker.new(dictionary, "lemurzzz").check).to eq "lemurzzz"
      end
    end

    context "when possessive and in dictionary" do
      it "returns nil" do
        expect(::Word::Checker.new(dictionary, "lemur's").check).to be_nil
      end
    end

    context "when possessive and not in dictionary" do
      it "returns the original word" do
        expect(::Word::Checker.new(dictionary, "lemurz's").check).to eq "lemurz's"
      end
    end

    context "when word in dictionary" do
      it "returns nil" do
        expect(::Word::Checker.new(dictionary, "lemur").check).to be_nil
      end
    end
  end
end
