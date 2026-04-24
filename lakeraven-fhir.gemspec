# frozen_string_literal: true

require_relative "lib/lakeraven/fhir/version"

Gem::Specification.new do |spec|
  spec.name = "lakeraven-fhir"
  spec.version = Lakeraven::FHIR::VERSION
  spec.authors = ["Lakeraven"]
  spec.email = ["hello@lakeraven.com"]

  spec.summary = "FHIR R4 resource builders and serialization primitives"
  spec.description = "Shared helpers for constructing FHIR R4 data types (Reference, " \
                     "CodeableConcept, Coding, Meta) and serializing ActiveModel objects " \
                     "to FHIR-compliant JSON. No Rails runtime required."
  spec.homepage = "https://github.com/lakeraven/lakeraven-fhir"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  # Boundary rule: only stdlib + activesupport. No actionpack, no app models.
  spec.add_dependency "activesupport", ">= 7.1"
  spec.add_dependency "ostruct"
end
