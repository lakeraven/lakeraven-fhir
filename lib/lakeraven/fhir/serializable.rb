# frozen_string_literal: true

module Lakeraven
  module FHIR
    module Serializable
      extend ActiveSupport::Concern
      include Builders

      class_methods do
        def from_fhir_attributes(_fhir_resource)
          raise NotImplementedError
        end

        def resource_class
          raise NotImplementedError
        end
      end

      def as_json(*)
        fhir_resource = to_fhir
        openstruct_to_hash(fhir_resource)
      end
    end
  end
end
