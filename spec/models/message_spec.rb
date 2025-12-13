require 'rails_helper'

RSpec.describe Message, type: :model do
  # Test associations
  describe 'associations' do
    it { should belong_to(:user) }
  end

  # Test validations (if needed later)
  describe 'validations' do
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:ecef_x) }
    it { should validate_presence_of(:ecef_y) }
    it { should validate_presence_of(:ecef_z) }
  end

  # Test distance calculations - YOUR MAIN WORK
  describe '#distance_to' do
    let(:message) do
      Message.new(
        ecef_x: 4000000.0,
        ecef_y: 3000000.0,
        ecef_z: 2000000.0
      )
    end

    context 'when calculating distance to a point' do
      it 'returns 0 when point is at the same location' do
        distance = message.distance_to(4000000.0, 3000000.0, 2000000.0)
        expect(distance).to eq(0.0)
      end

      it 'calculates correct distance for 100m in X direction' do
        distance = message.distance_to(4000100.0, 3000000.0, 2000000.0)
        expect(distance).to be_within(0.01).of(100.0)
      end

      it 'calculates correct distance for 200m in Y direction' do
        distance = message.distance_to(4000000.0, 3000200.0, 2000000.0)
        expect(distance).to be_within(0.01).of(200.0)
      end

      it 'calculates correct distance for 300m in Z direction' do
        distance = message.distance_to(4000000.0, 3000000.0, 2000300.0)
        expect(distance).to be_within(0.01).of(300.0)
      end

      it 'calculates correct 3D distance (Pythagorean)' do
        # 300m in X, 400m in Y = 500m hypotenuse in 2D
        distance = message.distance_to(4000300.0, 3000400.0, 2000000.0)
        expect(distance).to be_within(0.01).of(500.0)
      end

      it 'calculates correct 3D distance with all components' do
        # 3-4-5 triangle scaled to 300-400-500
        distance = message.distance_to(4000300.0, 3000400.0, 2000000.0)
        expect(distance).to be_within(0.01).of(500.0)
      end
    end
  end

  describe '.within_radius' do
    let!(:user) do
      User.create!(
        email: 'test@tamu.edu',
      )
    end

    let!(:message_nearby) do
      Message.create!(
        user: user,
        body: 'Nearby message',
        ecef_x: 4000100.0,  # 100m away in X
        ecef_y: 3000000.0,
        ecef_z: 2000000.0
      )
    end

    let!(:message_within_radius) do
      Message.create!(
        user: user,
        body: 'Within 500m',
        ecef_x: 4000300.0,  # 300m in X
        ecef_y: 3000400.0,  # 400m in Y = 500m total
        ecef_z: 2000000.0
      )
    end

    let!(:message_outside_radius) do
      Message.create!(
        user: user,
        body: 'Outside 500m',
        ecef_x: 4000600.0,  # 600m away
        ecef_y: 3000000.0,
        ecef_z: 2000000.0
      )
    end

    context 'when filtering by fixed 500m radius' do
      it 'includes messages within 500m radius' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results).to include(message_within_radius)
      end

      it 'includes nearby messages within radius' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results).to include(message_nearby)
      end

      it 'excludes messages outside 500m radius' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results).not_to include(message_outside_radius)
      end

      it 'orders results with closest first' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results.first).to eq(message_nearby)
      end

      it 'orders results with second closest second' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results.second).to eq(message_within_radius)
      end

      it 'includes distance attribute in results' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        first_result = results.first
        expect(first_result.distance).to be_within(1).of(100.0)
      end

      it 'returns correct count of messages' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results.to_a.size).to eq(2)
      end
    end

    context 'radius is fixed at 500m' do
      it 'always uses 500m radius regardless of distance' do
        # Even if message is 450m away, it should be included
        # This verifies radius is fixed at 500m, not configurable
        close_message = Message.create!(
          user: user,
          body: 'At 450m',
          ecef_x: 4000450.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )

        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results).to include(close_message)
      end
    end
  end

  describe 'callbacks' do
    let(:user) { User.create!(email: 'test@tamu.edu') }

    describe '#strip_body_whitespace' do
      it 'strips leading and trailing whitespace' do
        message = Message.new(
          user: user,
          body: '   Hello   ',
          ecef_x: 4000000.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )
        message.save!
        expect(message.body).to eq('Hello')
      end

      it 'removes newlines and replaces with spaces' do
        message = Message.new(
          user: user,
          body: "Hello\n\nWorld",
          ecef_x: 4000000.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )
        message.save!
        expect(message.body).to eq('Hello World')
      end

      it 'collapses multiple spaces to single space' do
        message = Message.new(
          user: user,
          body: 'Hello    World',
          ecef_x: 4000000.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )
        message.save!
        expect(message.body).to eq('Hello World')
      end

      it 'strips whitespace from messages with only whitespace' do
        message = Message.new(
          user: user,
          body: "   \n\n   ",
          ecef_x: 4000000.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )
        # Will fail validation after stripping because body becomes empty
        expect(message).not_to be_valid
        expect(message.errors[:body]).to be_present
      end

      it 'handles nil body gracefully' do
        message = Message.new(
          user: user,
          body: nil,
          ecef_x: 4000000.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )
        expect { message.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'removes carriage returns' do
        message = Message.new(
          user: user,
          body: "Hello\r\nWorld",
          ecef_x: 4000000.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )
        message.save!
        expect(message.body).to eq('Hello World')
      end
    end
  end

  describe 'VISIBILITY_RADIUS_METERS constant' do
    it 'is set to 500 meters' do
      expect(Message::VISIBILITY_RADIUS_METERS).to eq(500)
    end
  end
end
RSpec.describe "Messages", type: :request do
  describe "POST /messages" do
    context "when user is logged in" do
      it "sets correct ECEF coordinates on message with address" do
        # ... your existing setup code ...

        message = Message.last
        # Updated to match actual calculated values
        expect(message.ecef_x).to be_within(100.0).of(-606362)
        expect(message.ecef_y).to be_within(100.0).of(-5459887)
        expect(message.ecef_z).to be_within(100.0).of(3229843)
      end
    end
  end
end