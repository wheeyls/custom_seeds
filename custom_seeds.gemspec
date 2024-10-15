lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'custom_seeds/version'

Gem::Specification.new do |spec|
  spec.name          = 'custom_seeds'
  spec.version       = CustomSeeds::VERSION
  spec.authors       = ['Michael Wheeler']
  spec.email         = ['mwheeler@g2.com']

  spec.summary       = 'custom_seeds gem'

  spec.files         = `[ -d ".git" ] > /dev/null && type git > /dev/null && git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'progress_bar', '1.3.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '3.10.0'
end
