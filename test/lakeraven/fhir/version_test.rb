# frozen_string_literal: true

require "test_helper"

class Lakeraven::FHIR::VersionTest < Minitest::Test
  def test_version_is_set
    refute_nil Lakeraven::FHIR::VERSION
  end
end
