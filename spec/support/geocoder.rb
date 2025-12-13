Geocoder.configure(lookup: :test, ip_lookup: :test)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates'  => [30.61904, -96.33697],  # Slightly adjusted
      'latitude'     => 30.61904,
      'longitude'    => -96.33697,
      'address'      => 'Zachry Engineering Education Complex, College Station, TX',
      'state'        => 'Texas',
      'state_code'   => 'TX',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)