$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bumeran/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bumeran"
  s.version     = Bumeran::VERSION
  s.authors     = ["Rodrigo Fernandez"]
  s.email       = ["chaotiklv@gmail.com"]
  s.homepage    = "https://github.com/rfernand/bumeran"
  s.summary     = "A gem to access the Bumeran api"
  s.description = "A gem to access the Bumeran api: https://developers.bumeran.com"
  s.license     = "MIT"

  #s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  #s.test_files = Dir["test/**/*"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 3.2.19"
  s.add_dependency "httparty", ">= 0.13.3"
  #s.add_dependency "activesupport", "3.2.19"

  s.add_development_dependency 'rake'
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry-byebug"
end
