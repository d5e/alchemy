module Blend::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :name, analyzer: 'english', index_options: 'offsets'
        indexes :sensory_tags, analyzer: 'english', index_options: 'offsets'
        indexes :notes, analyzer: 'english', index_options: 'offsets'
        indexes :ingredients do
          indexes :substance do
            indexes :sensory_tags, analyzer: 'english', index_options: 'offsets'
            indexes :notes, analyzer: 'english', index_options: 'offsets'
          end
        end
      end
    end
  end
  
end
