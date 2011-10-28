class ThinkingSphinx::Search::RetryOnStaleIds
  attr_reader   :search
  attr_accessor :retries, :stale_ids

  def initialize(search)
    @search    = search
    @stale_ids = []
    @retries   = search.stale_retries
  end

  def try_with_stale(&block)
    begin
      block.call
    rescue ThinkingSphinx::Search::StaleIdsException => error
      raise error if retries <= 0

      search.reset!
      append_stale_ids error.ids

      self.retries -= 1 and retry
    end
  end

  private

  def append_stale_ids(ids)
    self.stale_ids |= ids

    search.options[:without_ids] ||= []
    search.options[:without_ids] += ids
  end
end
