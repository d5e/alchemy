module ActiveRecord
  module AttributeMethods

    # If we haven't generated any methods yet, generate them, then
    # see if we've created the method we're looking for.
    def method_missing(method, *args, &block) # :nodoc:
      if method.to_sym == :hidden? && !self.respond_to?(:hidden?) || method.to_sym == :locked? && !self.respond_to?(:locked?)
        return false
      else
        super
      end
    end

  end
end