Pod::Spec.new do |s|

s.name         = "TCJSON"
s.version      = "0.1.14"
s.summary      = "TCJSON is a utility that wraps Codable coding/decoding."

s.description  = <<-DESC
Simple monadic wrapper for JSON Codable. You can use this to simplify boring coding and decoding from/to JSON.
DESC

s.homepage     = "https://github.com/TizianoCoroneo/TCJSON"

s.license      = "MIT"

s.author             = { "Tiziano Coroneo" => "tizianocoroneo@me.com" }

s.social_media_url   = "https://facebook.com/tizianocoroneo"

s.source       = { :git => "https://github.com/TizianoCoroneo/TCJSON.git", :tag => "#{s.version}" }

s.platform = :ios, "11.0"

s.source_files  = "TCJSON/Classes", "TCJSON/Classes/**/*.{h,m}"
s.exclude_files = "TCJSON/Classes/Exclude"

end
