# frozen_string_literal: true

module DbLogTag
  # helper method to create refinement module
  # that add refinement tag to all queries be called on refinement's scope
  #
  # ex:
  # class PersonJob
  #   using DbLogTag.refinement_tag { |db, shard, role| "PersonJob" }
  #
  # now all queries in this job
  # will be automatically prepend refinement tag "PersonJob"
  #
  def self.refinement_tag(refinement_proc, **options)
    return Module.new {} unless DbLogTag.enable?
    
    # init an anonymous module
    # that will be `using`
    Module.new do
      refine ActiveRecord::Base.singleton_class do
        # decorating all querying methods
        # to add log_tag before call the origin query method
        (ActiveRecord::Querying::QUERYING_METHODS + [:all]).each do |q|
          define_method(q) do |*args, &block|
            log_tag(**options) do |db, shard, role| 
              refinement_proc.call(db, shard, role)
            end.send(q, *args, &block)
          end
        end
      end
    end
  end
end
