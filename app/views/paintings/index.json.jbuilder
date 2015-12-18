json.array!(@paintings) do |painting|
  json.extract! painting, :id, :name, :s3Url
  json.url painting_url(painting, format: :json)
end
