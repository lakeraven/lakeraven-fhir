# frozen_string_literal: true

require "test_helper"

class Lakeraven::FHIR::BuildersTest < Minitest::Test
  class TestModel
    include Lakeraven::FHIR::Builders
  end

  def setup
    @b = TestModel.new
  end

  def test_fhir_meta_single_profile
    meta = @b.fhir_meta("http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient")
    assert_kind_of OpenStruct, meta
    assert_equal [ "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient" ], meta.profile
  end

  def test_fhir_meta_multiple_profiles
    meta = @b.fhir_meta("http://example.com/a", "http://example.com/b")
    assert_equal 2, meta.profile.length
  end

  def test_fhir_reference_without_display
    ref = @b.fhir_reference("Patient", "rpms-123")
    assert_equal "Patient/rpms-123", ref.reference
    assert_nil ref.display
  end

  def test_fhir_reference_with_display
    ref = @b.fhir_reference("Practitioner", "rpms-456", display: "Dr. Smith")
    assert_equal "Practitioner/rpms-456", ref.reference
    assert_equal "Dr. Smith", ref.display
  end

  def test_fhir_codeable_concept_single_coding
    cc = @b.fhir_codeable_concept(system: "http://loinc.org", code: "8867-4", display: "Heart Rate", text: "Heart Rate")
    assert_equal "Heart Rate", cc.text
    assert_equal 1, cc.coding.length
    assert_equal "http://loinc.org", cc.coding.first.system
    assert_equal "8867-4", cc.coding.first.code
  end

  def test_fhir_codeable_concept_text_only
    cc = @b.fhir_codeable_concept(text: "Free text")
    assert_equal "Free text", cc.text
    assert_equal [], cc.coding
  end

  def test_fhir_codeable_concept_multiple_codings
    cc = @b.fhir_codeable_concept(
      codings: [
        { system: "http://loinc.org", code: "8867-4", display: "Heart Rate" },
        { system: "http://snomed.info/sct", code: "364075005", display: "Heart rate" }
      ],
      text: "Heart Rate"
    )
    assert_equal 2, cc.coding.length
  end

  def test_fhir_coding
    coding = @b.fhir_coding(system: "http://loinc.org", code: "8867-4", display: "HR")
    assert_equal "http://loinc.org", coding.system
    assert_equal "8867-4", coding.code
    assert_equal "HR", coding.display
  end

  def test_openstruct_to_hash_nested
    nested = OpenStruct.new(
      resourceType: "Patient",
      name: [ OpenStruct.new(family: "Smith", given: [ "John" ]) ],
      meta: OpenStruct.new(profile: [ "http://example.com" ])
    )
    result = @b.openstruct_to_hash(nested)
    assert_kind_of Hash, result
    assert_equal "Patient", result[:resourceType]
    assert_equal "Smith", result[:name].first[:family]
  end

  def test_openstruct_to_hash_primitives
    assert_equal "hello", @b.openstruct_to_hash("hello")
    assert_equal 42, @b.openstruct_to_hash(42)
    assert_nil @b.openstruct_to_hash(nil)
  end
end
