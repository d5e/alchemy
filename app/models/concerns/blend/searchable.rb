module Blend::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    
    index_name table_name

    mapping do
      indexes :name, analyzer: 'english', index_options: 'offsets'
      indexes :name_suggest, type: 'completion', payloads: true, index_analyzer: "simple", search_analyzer: "simple"
      indexes :sensory_tags, analyzer: 'english', index_options: 'offsets'
      indexes :notes, analyzer: 'english', index_options: 'offsets'
    end

  end


  def as_indexed_json(options = {})
     {
       name: name,
       sensory_tags: sensory_tags,
       notes: notes,
       name_suggest: {
         input: name.split(/\b/),
         output: name,
         payload: {
           resource_id: id,
           color: color
         }
       }
     }
   end
     
end
