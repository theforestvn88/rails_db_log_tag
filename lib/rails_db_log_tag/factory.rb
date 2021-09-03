# frozen_string_literal: true

module RailsDbLogTag
  class Factory
    TAGS = {
      # one usecase come to my head is the VERSION
      # ex: "[v.1.0.1] Product Load (0.3ms)  SELECT "products".* FROM "products" ..."
      :fixed_prefix => "%s",

      # db info: name|role|shard
      # DatabaseConfigurations
      :db => ->(kclazz, format_tag = "db[name: %name, role: %role, shard: %shard]") {
        m = Module.new do
          define_method("proxy_all") do |*args, &block|
            db_info = format_tag
            ["%name", "%role", "%shard"].zip([
              "#{kclazz.connection_pool.db_config.name}",
              "#{ActiveRecord::Base.current_role}",
              "#{ActiveRecord::Base.current_shard}"
            ]).each do |key, info|
              db_info = db_info.gsub(key, info) if db_info.include?(key)
            end

            all.log_tag(db_info)
          end
          delegate(*ActiveRecord::Querying::QUERYING_METHODS, to: :proxy_all)
        end

        kclazz.extend(m)
        -> {}
      }
    }.freeze

    def self.create_tag(tag, *args)
      tag_formula = TAGS[tag]
      error_create_tag = "could not create tag #{tag}"
      raise ArgumentError, error_create_tag if tag_formula.nil?

      case tag_formula
      when Proc
        if args.is_a?(Hash)
          tag_formula.call(**args)
        else
          tag_formula.call(*args)
        end
      when String
        format_string = tag_formula % args
        -> { format_string }
      else
        raise ArgumentError, error_create_tag
      end
    end
  end
end
