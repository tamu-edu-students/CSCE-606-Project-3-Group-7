require "geocoder"
require "proj"

class MessageController < ApplicationController
  def create
    # Your code for creating a message goes here
    @message = Message.new(message_params)
    if @message.save
      render json: { status: "Message created successfully", message: @message }, status: :created
    else
      render json: { status: "Error", errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
  def message_params
    p = params.require(:message).permit(:body, :user_id, :lat, :lon, :address)
    cartesian = if p[:lat] && p[:lon]
      geo_to_cartesian(p[:lat].to_f, p[:lon].to_f)
    elsif p[:address]
      address_to_cartesian(p[:address])
    else
      Rails.logger.warn("No latitude/longitude or address provided")
      Proj::Coordinate.new(x: nil, y: nil, z: nil)
    end
    Rails.logger.info("Cartesian coordinates: x=#{cartesian&.x}, y=#{cartesian&.y}, z=#{cartesian&.z}")
    p.permit(:body, :user_id).merge(
      ecef_x: cartesian&.x,
      ecef_y: cartesian&.y,
      ecef_z: cartesian&.z
    )
  end

  def geo_to_cartesian(lat, lon)
    Rails.logger.info("Converting geo to cartesian: lat=#{lat}, lon=#{lon}")
    transform = Proj::Transformation.new("EPSG:4326", "EPSG:4978")
    transform.forward(Proj::Coordinate.new(lon: lon, lat: lat, z: 0))
  end

  def address_to_cartesian(address)
    Rails.logger.info("Geocoding address: #{address}")
    results = Geocoder.search(address)
    if results.any?
      lat, lon = results.first.latitude, results.first.longitude
      Rails.logger.info("Geocoded coordinates: lat=#{lat}, lon=#{lon}")
      geo_to_cartesian(lat.to_f, lon.to_f)
    else
      Rails.logger.warn("Geocoding failed for address: #{address}")
      nil
    end
  end
end
