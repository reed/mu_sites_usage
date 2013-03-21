if ['development', 'staging'].include? Rails.env
  Dir.glob("#{Rails.root}/app/models/**/*.rb") do |model_name|
    require_dependency model_name
  end
end