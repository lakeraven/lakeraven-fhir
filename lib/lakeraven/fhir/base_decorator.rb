# frozen_string_literal: true

# Base class for FHIR decorators that wrap domain models.
#
# Provides:
# - FHIR builder helpers (via Builders concern)
# - JSON serialization (via to_fhir + openstruct_to_hash)
# - View context support for PHI redaction
# - Method delegation to the wrapped model
#
# Usage:
#   class FhirEncounter < Lakeraven::FHIR::BaseDecorator
#     def to_fhir
#       OpenStruct.new(
#         resourceType: "Encounter",
#         id: model.id&.to_s,
#         status: model.status
#       )
#     end
#   end
#
module Lakeraven
  module FHIR
    class BaseDecorator
      include Builders

      attr_reader :model

      def initialize(model, view: :full, current_user: nil)
        @model = model
        if respond_to?(:view_context=)
          self.view_context = view
          self.current_user = current_user
        end
      end

      def self.with_view(model, view: :full, current_user: nil)
        new(model, view: view, current_user: current_user)
      end

      def to_fhir
        raise NotImplementedError, "#{self.class} must implement #to_fhir"
      end

      def as_json(*)
        fhir_resource = to_fhir
        openstruct_to_hash(fhir_resource)
      end

      def method_missing(method, *args, &block)
        if model.respond_to?(method)
          model.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        model.respond_to?(method, include_private) || super
      end
    end
  end
end
