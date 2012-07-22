class ThinkingSphinx::Masks::ScopesMask
  def initialize(search)
    @search = search
  end

  def respond_to?(method, include_private = false)
    super || can_apply_scope?(method)
  end

  def search(query = nil, options = {})
    query, options = nil, query if query.is_a?(Hash)
    merge! query, options
    @search
  end

  private

  def apply_scope(scope, *args)
    search *sphinx_scopes[scope].call(*args)
  end

  def can_apply_scope?(scope)
    @search.options[:classes].present?    &&
    @search.options[:classes].length == 1 &&
    @search.options[:classes].first.respond_to?(:sphinx_scopes) &&
    sphinx_scopes[scope].present?
  end

  def merge!(query, options)
    @search.query = query unless query.nil?
    options.each do |key, value|
      case key
      when :conditions, :with, :without
        @search.options[key] ||= {}
        @search.options[key].merge! value
      when :without_ids
        @search.options[key] ||= []
        @search.options[key] += value
      else
        @search.options[key] = value
      end
    end
  end

  def method_missing(method, *args, &block)
    apply_scope method, *args
  end

  def sphinx_scopes
    @search.options[:classes].first.sphinx_scopes
  end
end
