require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  it "inherits from ActionMailer::Base" do
    expect(described_class.superclass).to eq(ActionMailer::Base)
  end

  it "has the correct default from address" do
    # `default` returns the default params hash for the mailer
    expect(described_class.default[:from]).to eq("from@example.com")
  end

  it "uses the mailer layout" do
    expect(described_class._layout).to eq("mailer")
  end
end
