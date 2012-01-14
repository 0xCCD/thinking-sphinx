class ThinkingSphinx::Search::Glaze < BlankSlate
  def initialize(object, raw = {})
    @object, @raw = object, raw.with_indifferent_access
  end

  def ==(object)
    (@object == object) || super
  end

  def distance
    @object.respond_to?(:distance) ? @object.distance : @raw[:geodist].to_f
  end

  def equal?(object)
    @object.equal? object
  end

  def geodist
    @object.respond_to?(:geodist) ? @object.geodist : @raw[:geodist].to_f
  end

  def sphinx_attributes
    @object.respond_to?(:sphinx_attributes) ? @object.sphinx_attributes : @raw
  end

  def unglazed
    @object
  end

  def weight
    @object.respond_to?(:weight) ? @object.weight : @raw[:weight]
  end

  private

  def method_missing(method, *args, &block)
    @object.send(method, *args, &block)
  end
end
