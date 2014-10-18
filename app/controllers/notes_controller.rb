class NotesController < InheritedResources::Base
  
  
  private
  
  def note_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:note).permit(:name, :tags, :body, :links)
   end

end
  
