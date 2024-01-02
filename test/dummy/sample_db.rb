# frozen_string_literal: true

require "active_record"

require_relative "./person"

Person.create!(name: "bob")
Person.create!(name: "lisa")

Book.create!(name: "oop")
Book.create!(name: "ruby")