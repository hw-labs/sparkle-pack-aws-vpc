SparkleFormation.new(:nat_subnet_vpc, :inherit => :public_subnet_vpc).overrides do

  description 'VPC with Public & NAT Subnets'

  ## Access the list of available Availability Zones via registry entry.
  zones = registry!(:zones)

  nat_zone = zones.first.gsub('-','_')
  ## Iterate over each AZ creating a public subnet. Auto-generate
  ## Subnet CIDRs based on index.

  zones.each_with_index do |zone, index|

    dynamic!(:subnet, ['private_', zone.gsub('-', '_') ].join,
      :vpc_id => ref!(:vpc),
      :route_table => ref!(:private_route_table),
      :availability_zone => zone
    )

    parameters(['private_', zone.gsub('-', '_'), '_subnet_cidr' ].join) do
      type 'String'
      default ['10.0.1', index, '.0/24'].join
    end
  end

  dynamic!(:vpc_nat_routing, :nat_vpc,
    :nat_subnet => ref!("public_#{nat_zone}_subnet".to_sym),
    :nat_route_table => ref!(:private_route_table))
end
