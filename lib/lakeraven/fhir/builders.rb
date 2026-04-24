# frozen_string_literal: true

# Shared FHIR resource builder methods.
#
# Provides reusable helpers for constructing FHIR data types (Reference,
# CodeableConcept, Coding, Meta) that appear across many resource models.
# Included automatically via Serializable; also available to decorators.
#
module Lakeraven
  module FHIR
    module Builders
      extend ActiveSupport::Concern

      # Build a FHIR Meta element with one or more profile URLs.
      def fhir_meta(*profiles)
        OpenStruct.new(profile: profiles)
      end

      # Build a FHIR Reference (e.g., "Patient/rpms-123").
      def fhir_reference(type, id, display: nil)
        ref = OpenStruct.new(reference: "#{type}/#{id}")
        ref.display = display if display
        ref
      end

      # Build a FHIR CodeableConcept.
      #
      # Single coding shorthand:
      #   fhir_codeable_concept(system: "http://loinc.org", code: "8867-4",
      #                         display: "Heart Rate", text: "Heart Rate")
      #
      # Multiple codings:
      #   fhir_codeable_concept(codings: [{system:, code:, display:}, ...], text: "Heart Rate")
      #
      # Text only (no code):
      #   fhir_codeable_concept(text: "Free text")
      #
      def fhir_codeable_concept(system: nil, code: nil, display: nil, text: nil, codings: nil)
        coding_list = if codings
          codings.map { |c| fhir_coding(**c) }
        elsif system && code
          [ fhir_coding(system: system, code: code, display: display) ]
        else
          []
        end

        OpenStruct.new(coding: coding_list, text: text)
      end

      # Build a single FHIR Coding element.
      def fhir_coding(system:, code:, display: nil)
        OpenStruct.new(system: system, code: code, display: display)
      end

      # Recursively convert OpenStruct trees to plain hashes for JSON serialization.
      def openstruct_to_hash(obj)
        case obj
        when OpenStruct
          obj.to_h.transform_values { |v| openstruct_to_hash(v) }
        when Array
          obj.map { |v| openstruct_to_hash(v) }
        when Hash
          obj.transform_values { |v| openstruct_to_hash(v) }
        else
          obj
        end
      end
    end
  end
end
