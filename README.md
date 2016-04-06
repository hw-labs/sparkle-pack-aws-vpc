# sparkle-pack-vpc

SparklePack providing AWS VPC templates.

## Use Cases

This SparklePack provides templates, components and dynamics for building Amazon Virtual Private Cloud networks across multiple availability zones. The following templates are provided:

* `lazy_vpc__public_subnet_vpc` - Creates a VPC with "public" subnets in each known availability zone, routing directly to the Internet via an Internet Gateway resource (no NAT).
* `lazy_vpc__nat_subnet_vpc` - Creates the same VPC as `lazy_vpc__public_subnet_vpc` but with additional "private" subnet per availability zone, routing to the Internet via an NAT Gateway resource.

Known availability zones are determined by querying the AWS API via [sparkle-pack-aws-availability-zones](https://github.com/hw-labs/sparkle-pack-aws-availability-zones).

## Usage

If you are using Bundler, add `sfn` and `sparkle-pack-aws-vpc` to your Gemfile:
```ruby
gem 'sfn'
gem 'sparkle-pack-aws-vpc'
```

Update your `.sfn` config file to ensure both the 'sparkle-pack-aws-availability-zones' and 'sparkle-pack-aws-vpc' SparklePacks are loaded:
```ruby
Configuration.new do
  sparkle_pack [ 'sparkle-pack-aws-availability-zones', 'sparkle-pack-aws-vpc' ]
end
```

You can now create a VPC using `sfn create`:
```
$ bundle exec sfn create vpc --file lazy_vpc__public_subnet_vpc
```

Or nest a VPC in another SparkleFormation Template (e.g. your infrastructure template):
```ruby
  nest!(:lazy_vpc__nat_subnet_vpc)
```
