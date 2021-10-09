# frozen_string_literal: true

module DbLogTag
  module Scope
    # helper method to create refinement module
    # that add scope tag to record classes which be used
    #
    # ex:
    # class PersonJob
    #   using DbLogTag::Scope.create "PersonJob" => [Person]
    #
    # now all Person queries log, such as Person.first, 
    # will be automatically prepend scope tag "PersonJob"
    #
    def self.create_refinement(scopes)
      # init an anonymous module
      # that will be `using`
      Module.new do
        scopes.each do |scope_tag, clazzs|
          clazzs.each do |kclazz|
            if kclazz.is_a?(Symbol) or kclazz.is_a?(String)
              kclazz = kclazz.to_s.classify.constantize
            end

            # it's better to use refinement here
            # so set up scope tags for Person queries in a job/worker
            # will not effect Person class and 
            # any Person queries in other places: services/controllers ...
            #
            refine kclazz.singleton_class do
              # decorating all querying methods
              # to add log_tag before call the origin query method
              (ActiveRecord::Querying::QUERYING_METHODS + [:all]).each do |q|
                define_method(q) do |*args, &block|
                  kclazz.log_tag("#{scope_tag}").send(q, *args, &block)
                end
              end
            end
          end
        end
      end
    end
  end
end

