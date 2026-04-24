# frozen_string_literal: true

require "test_helper"
require "active_model"

class Lakeraven::FHIR::SerializableTest < Minitest::Test
  class FakePatient
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Lakeraven::FHIR::Serializable

    attribute :dfn, :integer
    attribute :name, :string

    def to_fhir
      OpenStruct.new(
        resourceType: "Patient",
        id: "rpms-#{dfn}",
        name: [ OpenStruct.new(family: name) ]
      )
    end

    def self.resource_class
      "Patient"
    end

    def self.from_fhir_attributes(fhir_resource)
      { name: fhir_resource.name&.first&.family }
    end
  end

  def test_as_json_returns_hash
    patient = FakePatient.new(dfn: 1, name: "DOE")
    json = patient.as_json
    assert_kind_of Hash, json
    assert_equal "Patient", json[:resourceType]
    assert_equal "rpms-1", json[:id]
    assert_equal "DOE", json[:name].first[:family]
  end

  def test_from_fhir_attributes
    fhir = OpenStruct.new(name: [ OpenStruct.new(family: "SMITH") ])
    attrs = FakePatient.from_fhir_attributes(fhir)
    assert_equal "SMITH", attrs[:name]
  end

  def test_resource_class
    assert_equal "Patient", FakePatient.resource_class
  end

  def test_builders_available
    patient = FakePatient.new(dfn: 1, name: "DOE")
    ref = patient.fhir_reference("Patient", "rpms-1")
    assert_equal "Patient/rpms-1", ref.reference
  end
end
