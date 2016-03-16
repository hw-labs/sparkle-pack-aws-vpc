Gem::Specification.new do |s|
  s.name = 'sparkle-pack-aws-vpc'
  s.version = '0.1.2'
  s.licenses = ['MIT']
  s.summary = 'AWS VPC SparklePack'
  s.description = 'SparklePack to create a VPC on AWS'
  s.authors = ['Cameron Johnston', 'Michael F. Weinberg']
  s.email = 'support@heavywater.io'
  s.homepage = 'http://sparkleformation.io'
  s.files = Dir[ 'lib/**/**/**' ]
  s.add_runtime_dependency 'sparkle-pack-aws-availability-zones'
end
