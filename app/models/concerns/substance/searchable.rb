module Substance::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name table_name

    mapping do
      indexes :name, analyzer: 'english', index_options: 'offsets'
      indexes :name_suggest, type: 'completion', payloads: true, index_analyzer: "simple", search_analyzer: "simple"
      indexes :tags_suggest, type: 'completion', payloads: true, index_analyzer: "simple", search_analyzer: "simple"
      indexes :cas, analyzer: 'english', index_options: 'offsets'
      indexes :alt_names, analyzer: 'english', index_options: 'offsets'
      indexes :sensory_tags, analyzer: 'english', index_options: 'offsets'
      indexes :notes, analyzer: 'english', index_options: 'offsets'
      indexes :notes_alt_1, analyzer: 'english', index_options: 'offsets'
      indexes :notes_alt_2, analyzer: 'english', index_options: 'offsets'
      indexes :vp_mmHg_25C, type: 'float'
    end


  end
  
  

  def as_indexed_json(options = {})
     {
       name: name,
       cas: cas,
       alt_names: alt_names,
       sensory_tags: sensory_tags,
       notes: notes,
       notes_alt_1: notes_alt_1,
       notes_alt_2: notes_alt_2,
       vp_mmHg_25C: vp_mmHg_25C,
       name_suggest: {
         input: name.split(/\b/),
         output: name,
         payload: {
           resource_id: id,
           character: character
         }
       },
       tags_suggest: {
         input: sensory_tags.split(/\b/),
         output: name,
         payload: {
           resource_id: id,
           character: character
         }
       }
     }
   end

end


