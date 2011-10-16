require 'spec_helper'

describe ThinkingSphinx::ActiveRecord::PropertySQLPresenter do
  let(:adapter)      { double('adapter') }
  let(:associations) {
    double('associations', :alias_for => 'articles', :aggregate_for? => false)
  }

  before :each do
    adapter.stub(:quote) { |column| column }
  end

  context 'with a field' do
    let(:presenter) {
      ThinkingSphinx::ActiveRecord::PropertySQLPresenter.new(
        field, adapter, associations
      )
    }
    let(:field)     { double('field', :name => 'title', :columns => [column]) }
    let(:column)    {
      double('column', :string? => false, :__stack => [],
        :__name => 'title')
    }

    describe '#to_group' do
      it "returns the column name as a string" do
        presenter.to_group.should == 'articles.title'
      end

      it "gets the column's table alias from the associations object" do
        column.stub!(:__stack => [:users, :posts])

        associations.should_receive(:alias_for).with([:users, :posts]).
          and_return('posts')

        presenter.to_group
      end

      it "returns nil if the property is an aggregate" do
        associations.stub! :aggregate_for? => true

        presenter.to_group.should be_nil
      end
    end

    describe '#to_select' do
      it "returns the column name as a string" do
        presenter.to_select.should == 'articles.title AS title'
      end

      it "gets the column's table alias from the associations object" do
        column.stub!(:__stack => [:users, :posts])

        associations.should_receive(:alias_for).with([:users, :posts]).
          and_return('posts')

        presenter.to_select
      end

      it "returns the column name with an alias when provided" do
        field.stub!(:name => :subject)

        presenter.to_select.should == 'articles.title AS subject'
      end

      it "groups and concatenates aggregated columns" do
        adapter.stub :group_concatenate do |clause, separator|
          "GROUP_CONCAT(#{clause} SEPARATOR '#{separator}')"
        end

        associations.stub! :aggregate_for? => true

        presenter.to_select.
          should == "GROUP_CONCAT(articles.title SEPARATOR ' ') AS title"
      end

      it "concatenates multiple columns" do
        adapter.stub :concatenate do |clause, separator|
          "CONCAT_WS('#{separator}', #{clause})"
        end

        field.stub!(:columns => [column, column])

        presenter.to_select.
          should == "CONCAT_WS(' ', articles.title, articles.title) AS title"
      end
    end
  end

  context 'with an attribute' do
    let(:presenter) {
      ThinkingSphinx::ActiveRecord::PropertySQLPresenter.new(
        attribute, adapter, associations, :integer
      )
    }
    let(:attribute) {
      double('attribute', :name => 'created_at', :columns => [column])
    }
    let(:column)    {
      double('column', :string? => false, :__stack => [],
        :__name => 'created_at')
    }

    before :each do
      adapter.stub :cast_to_timestamp do |clause|
        "UNIX_TIMESTAMP(#{clause})"
      end
    end

    describe '#to_group' do
      it "returns the column name as a string" do
        presenter.to_group.should == 'articles.created_at'
      end

      it "gets the column's table alias from the associations object" do
        column.stub!(:__stack => [:users, :posts])

        associations.should_receive(:alias_for).with([:users, :posts]).
          and_return('posts')

        presenter.to_group
      end

      it "returns nil if the column is a string" do
        column.stub!(:string? => true)

        presenter.to_group.should be_nil
      end

      it "returns nil if the property is an aggregate" do
        associations.stub! :aggregate_for? => true

        presenter.to_group.should be_nil
      end
    end

    describe '#to_select' do
      it "returns the column name as a string" do
        presenter.to_select.should == 'articles.created_at AS created_at'
      end

      it "gets the column's table alias from the associations object" do
        column.stub!(:__stack => [:users, :posts])

        associations.should_receive(:alias_for).with([:users, :posts]).
          and_return('posts')

        presenter.to_select
      end

      it "returns the column name with an alias when provided" do
        attribute.stub!(:name => :creation_timestamp)

        presenter.to_select.
          should == 'articles.created_at AS creation_timestamp'
      end

      it "ensures datetime attributes are converted to timestamps" do
        presenter = ThinkingSphinx::ActiveRecord::PropertySQLPresenter.new(
          attribute, adapter, associations, :timestamp
        )

        presenter.to_select.
          should == 'UNIX_TIMESTAMP(articles.created_at) AS created_at'
      end
    end
  end
end
