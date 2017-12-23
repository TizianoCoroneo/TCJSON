Pod::Spec.new do |s|

s.name         = "TCJSON"
s.version      = "0.2.4"
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

s.subspec 'Core' do |core|
    core.source_files = "TCJSON/Classes/Core/**"
end

s.subspec 'Alamofire' do |af|
    af.source_files = "TCJSON/Classes/Alamofire/**"
    af.dependency 'TCJSON/Core'
    af.dependency 'Alamofire'
end

s.subspec 'Moya' do |moya|
    moya.source_files = "TCJSON/Classes/Moya/**"
    moya.dependency 'TCJSON/Core'
    moya.dependency 'Moya'
end

end
