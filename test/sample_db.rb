# frozen_string_literal: true

require "active_record"

require_relative "./dummy/person"

bob = Person.create!(name: "bob")