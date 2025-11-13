require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  it "inherits from ActiveJob::Base" do
    expect(described_class.superclass).to eq(ActiveJob::Base)
  end

  it "can be subclassed and enqueued" do
    test_job_class = Class.new(described_class) do
      def perform; end
    end

    expect {
      test_job_class.perform_later
    }.to have_enqueued_job(test_job_class)
  end
end
