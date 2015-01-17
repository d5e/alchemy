class SearchController < ApplicationController
  
  helper_method :elastic_response

  def show
  end
  
  protected
  
  def elastic_response
    return [] if params[:q].nil?
    Substance.search params[:q], size: 1000
  end
  
  
  # DRAFT
  def self.custom_search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^10', 'text']
          }
        }
      }
    )
  end

  
end
