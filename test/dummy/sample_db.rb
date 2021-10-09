# frozen_string_literal: true

require "active_record"

require_relative "./person"

bob = Person.create!(name: "bob")
lisa = Person.create!(name: "lisa")

oop = Book.create!(name: "oop")
ruby = Book.create!(name: "ruby")