require "rails_helper"

RSpec.describe ApplicationRecord, type: :model do
  it "inherits from ActiveRecord::Base" do
    expect(described_class.superclass).to eq(ActiveRecord::Base)
  end

  it "is an abstract class" do
    expect(described_class.abstract_class).to be(true)
  end
end
