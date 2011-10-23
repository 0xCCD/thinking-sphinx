require 'spec_helper'

describe ThinkingSphinx::ActiveRecord::Base do
  let(:model) {
    Class.new(ActiveRecord::Base) do
      include ThinkingSphinx::ActiveRecord::Base
    end
  }

  describe '.search' do
    it "returns a new search object" do
      model.search.should be_a(ThinkingSphinx::Search)
    end

    it "passes through arguments to the search object initializer" do
      ThinkingSphinx::Search.should_receive(:new).with('pancakes', anything)

      model.search 'pancakes'
    end

    it "scopes the search to a given model" do
      ThinkingSphinx::Search.should_receive(:new).
        with(anything, hash_including(:classes => [model]))

      model.search 'pancakes'
    end
  end
end
