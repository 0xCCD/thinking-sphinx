class ThinkingSphinx::ActiveRecord::Field
  attr_reader :column

  def initialize(column, options = {})
    @column, @options = column, options
  end

  def name
    (@options[:as] || column.__name).to_s
  end

  def to_group_sql(associations)
    column_with_table associations
  end

  def to_select_sql(associations, source)
    if @options[:as].present?
      "#{column_with_table(associations)} AS #{@options[:as]}"
    else
      column_with_table associations
    end
  end

  def with_attribute?
    @options[:sortable]
  end

  private

  def column_with_table(associations)
    "#{associations.alias_for(column.__stack)}.#{column.__name}"
  end
end
