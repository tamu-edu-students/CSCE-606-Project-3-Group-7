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
        email: 'test@example.com',
        ecef_x: 4000000.0,
        ecef_y: 3000000.0,
        ecef_z: 2000000.0
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

    context 'when filtering by radius' do
      it 'includes messages within radius' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0, 500)
        expect(results).to include(message_nearby)
        expect(results).to include(message_within_radius)
      end

      it 'excludes messages outside radius' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0, 500)
        expect(results).not_to include(message_outside_radius)
      end

      it 'orders results by distance (closest first)' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0, 500)
        expect(results.first).to eq(message_nearby)  # 100m
        expect(results.second).to eq(message_within_radius)  # 500m
      end

      it 'includes distance in results' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0, 500)
        first_result = results.first
        expect(first_result.distance).to be_within(1).of(100.0)
      end
    end

    context 'with different radius values' do
      it 'respects 200m radius' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0, 200)
        expect(results).to include(message_nearby)
        expect(results).not_to include(message_within_radius)
      end

      it 'respects default 500m radius' do
        results = Message.within_radius(4000000.0, 3000000.0, 2000000.0)
        expect(results.to_a.size).to eq(2)
      end
    end
  end
end