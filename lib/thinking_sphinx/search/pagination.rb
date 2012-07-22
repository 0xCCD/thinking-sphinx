# For Kaminari and Will Paginate
module ThinkingSphinx::Search::Pagination
  def self.included(base)
    base.instance_eval do
      alias_method :limit_value,  :per_page
      alias_method :page_count,   :total_pages
      alias_method :num_pages,    :total_pages
      alias_method :total_count,  :total_entries
      alias_method :count,        :total_entries
      alias_method :offset_value, :offset
    end
  end

  def current_page
    @options[:page] = 1 if @options[:page].blank?
    @options[:page].to_i
  end

  def first_page?
    current_page == 1
  end

  def last_page?
    next_page.nil?
  end

  def next_page
    current_page >= total_pages ? nil : current_page + 1
  end

  def next_page?
    !next_page.nil?
  end

  def page(number)
    @options[:page] = number
    self
  end

  def per(limit)
    @options[:limit] = limit
    self
  end

  def previous_page
    current_page == 1 ? nil : current_page - 1
  end

  def total_entries
    meta['total_found'].to_i
  end

  def total_pages
    return 0 if meta['total'].nil?

    @total_pages ||= (meta['total'].to_i / per_page.to_f).ceil
  end
end
