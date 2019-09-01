require 'httpi'
require 'json'
if ENV['LAMBDA_ENV'].nil? || ENV['LAMBDA_ENV'] == 'development'
  require 'pry'
  require 'dotenv/load'
end


# Hue values:
# |------------------------
# Red     0.00  16.67
# Yellow  16.94 33.33
# Green   33.61 50.00
# Cyan    50.28 66.67
# Blue    66.94 83.33
# Magenta 83.61 100.00


# # Get the device ID
# request = HTTPI::Request.new("https://api.smartthings.com/v1/devices")
# request.headers['Authorization'] = 'Bearer ' + ENV['FULL_TOKEN']
# response = HTTPI.get(request)
# binding.pry

puts 'Starting the color change.'
request = HTTPI::Request.new("https://api.smartthings.com/v1/devices/#{ENV['BULB_DEVICE_ID']}/commands")
request.headers['Authorization'] = 'Bearer ' + ENV['LIMITED_TOKEN']
color_to_change_to = {hue: rand(0..100), saturation: rand(5..100)}
request.body = [
  {
    command: 'on',
    capability: 'switch',
    component: 'main',
    arguments: []
  },
  {
    command: 'setLevel',
    capability: 'switchLevel',
    component: 'main',
    arguments: [100]
  },
  {
    command: 'setColor',
    capability: 'colorControl',
    component: 'main',
    arguments: [color_to_change_to]
  }
].to_json

puts "Changing to: #{color_to_change_to}"
response = HTTPI.post(request)
puts "Done! | #{response.code} | #{response.body}"
