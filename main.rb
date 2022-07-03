require 'uri'
require 'net/http'
require 'openssl'
require 'yaml'
require 'json'

def secrets
  @secrets ||= YAML.load_file("credentials.yml")
end

def get_recipe_ids(ingredients: [])
  return unless ingredients.any?

  ingredients_query_params = ingredients.join("%2C")
  total_results = 5

  url = URI("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/findByIngredients?ingredients=#{ingredients_query_params}&number=#{total_results}&ranking=1")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)
  request["X-RapidAPI-Key"] = secrets['recipe-food-nutrition-api-key']
  request["X-RapidAPI-Host"] = 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com'

  response = http.request(request)
  response = JSON.parse(response.read_body)
  #puts response.read_body

  # recipe ids
  response.map { |result| result['id'] }
end


def get_recipes(ingredients: [])
  recipes_ids = get_recipe_ids(ingredients: ingredients)

  recipes_ids.each do |recipe_id|
    url = URI("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/#{recipe_id}/information")
 
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = secrets['recipe-food-nutrition-api-key']
    request["X-RapidAPI-Host"] = 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com'

    response = http.request(request)
    puts response.read_body
  end
end


get_recipes(ingredients: ['apple', 'orange'])
