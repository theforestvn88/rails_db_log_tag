module DbLogTag
    module_function

    def set_enable_environment(envs)
        @@envs = envs.map(&:to_s)
    end

    def enable?
        @@envs ||= ["development", "test"]
        @@envs.include?(ENV["RAILS_ENV"])
    end
end
