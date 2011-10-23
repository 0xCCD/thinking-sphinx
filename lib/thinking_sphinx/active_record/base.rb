module ThinkingSphinx::ActiveRecord::Base
  extend ActiveSupport::Concern

  included do
    after_commit :after_commit_with_sphinx
  end

  module ClassMethods
    def search(query = nil, options = {})
      ThinkingSphinx.search query, scoped_sphinx_options.merge(options)
    end

    def primary_key_for_sphinx
      @primary_key_for_sphinx ||
      (
        superclass.respond_to?(:primary_key_for_sphinx?) &&
        superclass.primary_key_for_sphinx? &&
        superclass.primary_key_for_sphinx
      ) || primary_key || :id
    end

    def primary_key_for_sphinx?
      @primary_key_for_sphinx.present?
    end

    def set_primary_key_for_sphinx(key)
      @primary_key_for_sphinx = key
    end

    private

    def scoped_sphinx_options
      {:classes => [self]}
    end
  end

  module InstanceMethods
    def after_commit_with_sphinx
      indices = sphinx_indices.select { |index| index.delta? }
      sphinx_config.controller.index *indices.collect(&:name) if indices.any?
    end

    def sphinx_config
      ThinkingSphinx::Configuration.instance
    end

    def sphinx_indices
      sphinx_config.indices_for_reference(self.class.name.underscore.to_sym)
    end
  end
end
