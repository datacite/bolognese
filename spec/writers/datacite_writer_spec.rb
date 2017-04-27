require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:id) { "https://doi.org/10.5061/DRYAD.8515" }

  subject { Bolognese::Metadata.new(input: id, from: "datacite") }

end
