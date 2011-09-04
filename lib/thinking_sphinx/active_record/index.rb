class ThinkingSphinx::ActiveRecord::Index < Riddle::Configuration::Index
  attr_reader :reference
  attr_writer :definition_block

  def initialize(reference, options = {})
    @reference = reference
    @docinfo   = :extern

    super reference.to_s
  end

  def interpret_definition!
    return if @interpreted_definition

    ThinkingSphinx::ActiveRecord::Interpreter.translate! self, @definition_block
    @interpreted_definition = true
  end

  def model
    @model ||= reference.to_s.camelize.constantize
  end

  def offset
    @offset ||= config.next_offset(reference)
  end

  def render
    interpret_definition!

    @path ||= config.indices_location.join(name)

    super
  end

  private

  def config
    ThinkingSphinx::Configuration.instance
  end
end
