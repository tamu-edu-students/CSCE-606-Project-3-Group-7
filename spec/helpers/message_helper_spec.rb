require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the MessageHelper. For example:
#
# describe MessageHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe MessageHelper, type: :helper do
  it "converts geo coordinates to cartesian" do
    cartesian = MessageHelper.geo_to_cartesian(34.729847, -86.5859011)
    expect(cartesian).to be_a(Array)
    expect(cartesian.length).to eq(3)
    expect(cartesian).to all(be_a(Float))
    expect(cartesian[0]).to be_within(1.0).of(312503)
    expect(cartesian[1]).to be_within(1.0).of(-5238246)
    expect(cartesian[2]).to be_within(1.0).of(3613276)
  end

  it "geocodes an address to cartesian coordinates" do
    cartesian = MessageHelper.address_to_cartesian("Zachry Engineering Education Complex, College Station, TX")
    expect(cartesian).to be_a(Array)
    expect(cartesian.length).to eq(3)
    expect(cartesian).to all(be_a(Float))
    # the building has a radius of about 100m, so allow some leeway
    expect(cartesian[0]).to be_within(100.0).of(-606693)
    expect(cartesian[1]).to be_within(100.0).of(-5459887)
    expect(cartesian[2]).to be_within(100.0).of(3229843)
  end
end
