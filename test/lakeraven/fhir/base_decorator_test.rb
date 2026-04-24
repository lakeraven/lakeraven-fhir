# frozen_string_literal: true

require "test_helper"

class Lakeraven::FHIR::BaseDecoratorTest < Minitest::Test
  class FakeModel
    attr_accessor :id, :status
    def initialize(id:, status:)
      @id = id
      @status = status
    end
  end

  class FakeDecorator < Lakeraven::FHIR::BaseDecorator
    def to_fhir
      OpenStruct.new(
        resourceType: "Encounter",
        id: model.id.to_s,
        status: model.status,
        meta: fhir_meta("http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter")
      )
    end
  end

  def setup
    @model = FakeModel.new(id: 42, status: "finished")
    @decorator = FakeDecorator.new(@model)
  end

  def test_to_fhir
    fhir = @decorator.to_fhir
    assert_equal "Encounter", fhir.resourceType
    assert_equal "42", fhir.id
    assert_equal "finished", fhir.status
  end

  def test_as_json
    json = @decorator.as_json
    assert_kind_of Hash, json
    assert_equal "Encounter", json[:resourceType]
  end

  def test_delegates_to_model
    assert_equal 42, @decorator.id
    assert_equal "finished", @decorator.status
  end

  def test_respond_to_missing
    assert @decorator.respond_to?(:id)
    assert @decorator.respond_to?(:status)
    refute @decorator.respond_to?(:nonexistent_method)
  end

  def test_with_view_factory
    decorator = FakeDecorator.with_view(@model, view: :summary)
    assert_equal "Encounter", decorator.to_fhir.resourceType
  end

  def test_builders_available
    ref = @decorator.fhir_reference("Patient", "rpms-1")
    assert_equal "Patient/rpms-1", ref.reference
  end

  def test_base_raises_not_implemented
    base = Lakeraven::FHIR::BaseDecorator.new(@model)
    assert_raises(NotImplementedError) { base.to_fhir }
  end
end
