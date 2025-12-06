class Message < ApplicationRecord
  belongs_to :user

  # Constants - Fixed visibility radius per US4.1
  VISIBILITY_RADIUS_METERS = 500

  # Validations
  validates :body, presence: true
  validates :ecef_x, presence: true
  validates :ecef_y, presence: true
  validates :ecef_z, presence: true

  # Callbacks
  before_save :strip_body_whitespace

  # Instance method: Calculate Euclidean distance to a point (in meters)
  # ECEF coordinates are already in meters, so this is straightforward 3D distance
  def distance_to(x, y, z)
    Math.sqrt(
      (ecef_x - x)**2 +
      (ecef_y - y)**2 +
      (ecef_z - z)**2
    )
  end

  # Class method (scope): Find messages within FIXED 500m radius
  # Radius is not configurable per requirements (US4.1)
  scope :within_radius, ->(x, y, z) {
    radius_meters = VISIBILITY_RADIUS_METERS

    # Bounding box optimization: filter candidates before expensive sqrt
    where(
      "ecef_x BETWEEN ? AND ? AND
       ecef_y BETWEEN ? AND ? AND
       ecef_z BETWEEN ? AND ?",
      x - radius_meters, x + radius_meters,
      y - radius_meters, y + radius_meters,
      z - radius_meters, z + radius_meters
    )
    # Add WHERE clause to filter by exact distance
    .where(
      "SQRT(
        POW(ecef_x - ?, 2) +
        POW(ecef_y - ?, 2) +
        POW(ecef_z - ?, 2)
      ) <= ?",
      x.to_f, y.to_f, z.to_f, radius_meters
    )
    # Calculate exact distance and add as 'distance' attribute
    .select(
      "messages.*",
      "SQRT(
        POW(ecef_x - #{x.to_f}, 2) +
        POW(ecef_y - #{y.to_f}, 2) +
        POW(ecef_z - #{z.to_f}, 2)
      ) AS distance"
    )
    # Order by closest first
    .order("distance ASC")
  }

  private

  def strip_body_whitespace
    return unless body.present?

    # Strip all leading/trailing whitespace (including newlines)
    # Collapse multiple newlines/whitespace to single spaces
    cleaned = body.strip
    cleaned = cleaned.gsub(/\r\n|\r|\n/, " ") # Replace all newlines with spaces
    cleaned = cleaned.gsub(/\s+/, " ")         # Collapse multiple spaces to one
    self.body = cleaned.strip
  end
end
