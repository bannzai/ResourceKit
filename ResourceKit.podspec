Pod::Spec.new do |spec|

  spec.name         = "ResourceKit"
  spec.version      = "0.4.2"
  spec.license      = "MIT"

  spec.summary      = "Enable autocomplete use resources like in swift project"
  spec.homepage     = "https://github.com/bannzai/ResourceKit"

  spec.author             = { "Yudai hirose" => "kingkong999yhirose@gmail.com" }
  spec.social_media_url   = "https://facebook.com/yudai.owata.hirose"

  spec.source = { :http => "https://github.com/bannzai/ResourceKit/releases/download/#{spec.version}/ResourceKit.zip" }

  spec.ios.deployment_target     = '8.0'

  spec.preserve_paths = "ResourceKit"

end

