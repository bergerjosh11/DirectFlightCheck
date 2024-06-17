require 'httparty'
require 'json'
require 'optparse'
require 'dotenv/load'

API_KEY = ENV['API_KEY']

def direct_flight?(departure_airport, arrival_airport)
  url = "http://api.aviationstack.com/v1/routes"
  response = HTTParty.get(url, query: {
    access_key: API_KEY,
    dep_iata: departure_airport,
    arr_iata: arrival_airport
  })

  if response.success?
    data = JSON.parse(response.body)
    routes = data['data']

    if routes.empty?
      puts "No direct flights found from #{departure_airport} to #{arrival_airport}."
      false
    else
      puts "Direct flights found from #{departure_airport} to #{arrival_airport}:"
      routes.each do |route|
        puts "Airline: #{route['airline']['name']}, Flight Number: #{route['flight_number']}"
      end
      true
    end
  else
    puts "Error fetching flight data: #{response['error']['info']}"
    false
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: check_flights.rb [options]"

  opts.on("-d", "--departure DEPARTURE", "Departure airport code") do |d|
    options[:departure] = d
  end

  opts.on("-a", "--arrival ARRIVAL", "Arrival airport code") do |a|
    options[:arrival] = a
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

if options[:departure] && options[:arrival]
  direct_flight?(options[:departure], options[:arrival])
else
  puts "Both departure and arrival airport codes are required."
  puts "Usage: check_flights.rb -d DEPARTURE -a ARRIVAL"
end
