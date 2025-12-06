module MessageHelper
  def geo_to_cartesian(lat, lon)
    Rails.logger.info("Converting geo to cartesian: lat=#{lat}, lon=#{lon}")
    # https://ea4eoz.blogspot.com/2015/11/simple-wgs-84-ecef-conversion-functions.html
    a = 6378137.0 # WGS84 semi-major axis in meters
    e = 0.081819190842622 # WGS84 first eccentricity
    e_sq = e**2
    lat_rad = lat * Math::PI / 180.0
    lon_rad = lon * Math::PI / 180.0
    n = a / Math.sqrt(1 - e_sq * Math.sin(lat_rad)**2) # Radius of curvature in the prime vertical
    x = n * Math.cos(lat_rad) * Math.cos(lon_rad)
    y = n * Math.cos(lat_rad) * Math.sin(lon_rad)
    z = n * (1 - e_sq) * Math.sin(lat_rad)
    [ x, y, z ]
  end
  module_function :geo_to_cartesian

  def address_to_cartesian(address)
    Rails.logger.info("Geocoding address: #{address}")
    results = Geocoder.search(address)
    if results.any?
      lat, lon = results.first.latitude, results.first.longitude
      Rails.logger.info("Geocoded coordinates: lat=#{lat}, lon=#{lon}")
      geo_to_cartesian(lat.to_f, lon.to_f)
    else
      Rails.logger.warn("Geocoding failed for address: #{address}")
      [ nil, nil, nil ]
    end
  end
  module_function :address_to_cartesian
end
