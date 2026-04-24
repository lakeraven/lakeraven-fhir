# lakeraven-fhir

FHIR R4 resource builders and serialization primitives for Lakeraven EHR.

**Boundary rule:** depends only on stdlib + activesupport. No actionpack, no app models, no Rails runtime.

## Install

```ruby
# Gemfile
gem "lakeraven-fhir", github: "lakeraven/lakeraven-fhir"
```

## Public API

### Require entrypoints

```ruby
require "lakeraven-fhir"                  # everything
require "lakeraven/fhir/builders"         # just builders (lightest)
require "lakeraven/fhir/serializable"     # builders + serializable concern
require "lakeraven/fhir/base_decorator"   # builders + decorator base class
```

### Lakeraven::FHIR::Builders (concern)

Include in any class to get FHIR data type helpers:

```ruby
class MyModel
  include Lakeraven::FHIR::Builders

  def to_fhir
    OpenStruct.new(
      resourceType: "Observation",
      meta: fhir_meta("http://hl7.org/fhir/us/core/StructureDefinition/us-core-vital-signs"),
      subject: fhir_reference("Patient", "rpms-123"),
      code: fhir_codeable_concept(system: "http://loinc.org", code: "8867-4", display: "Heart Rate", text: "Heart Rate")
    )
  end
end
```

Methods: `fhir_meta`, `fhir_reference`, `fhir_codeable_concept`, `fhir_coding`, `openstruct_to_hash`

### Lakeraven::FHIR::Serializable (concern)

Include in ActiveModel classes for FHIR serialization. Automatically includes Builders.

```ruby
class Patient
  include ActiveModel::Model
  include Lakeraven::FHIR::Serializable

  def to_fhir
    # build FHIR resource using builders
  end

  def self.resource_class
    "Patient"
  end

  def self.from_fhir_attributes(fhir_resource)
    # extract attributes from FHIR resource
  end
end
```

Provides: `as_json` (via `to_fhir` + `openstruct_to_hash`), `from_fhir` class method

### Lakeraven::FHIR::BaseDecorator

Base class for FHIR decorators that wrap models. Includes Builders.

```ruby
class FhirEncounter < Lakeraven::FHIR::BaseDecorator
  def to_fhir
    OpenStruct.new(
      resourceType: "Encounter",
      id: model.id&.to_s,
      status: model.status
    )
  end
end
```

## Migration from rpms_redux

| rpms_redux | lakeraven-fhir |
|---|---|
| `FhirBuilders` | `Lakeraven::FHIR::Builders` |
| `FhirSerializable` | `Lakeraven::FHIR::Serializable` |
| `BaseFhirDecorator` | `Lakeraven::FHIR::BaseDecorator` |

## License

Apache-2.0
