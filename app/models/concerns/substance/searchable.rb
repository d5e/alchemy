module Substance::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :name, analyzer: 'english', index_options: 'offsets'
        indexes :cas, analyzer: 'english', index_options: 'offsets'
        indexes :alt_names, analyzer: 'english', index_options: 'offsets'
        indexes :sensory_tags, analyzer: 'english', index_options: 'offsets'
        indexes :notes, analyzer: 'english', index_options: 'offsets'
        indexes :notes_alt_1, analyzer: 'english', index_options: 'offsets'
        indexes :notes_alt_2, analyzer: 'english', index_options: 'offsets'
      end
    end

  end
end


