# Install gems locally so that you can upload them to the Lambda
# bundle install --path vendor/bundle

# Deployment:
# zip -r amazon_iot_button_color_change.zip amazon_iot_button_color_change.rb vendor
# aws lambda update-function-code --function-name IoTbutton_change-color --zip-file fileb://amazon_iot_button_color_change.zip
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

def lambda_handler(event:, context:)
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

  { statusCode: 200, body: JSON.generate("Changing to: #{color_to_change_to} | #{response.code} | #{response.body}") }
end
