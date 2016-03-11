SparkleFormation.new(:public_subnet_vpc).load(:base, :vpc).overrides do

  description 'VPC with Public Subnets'

  ## Access the list of available Availability Zones via registry entry.
  zones = registry!(:zones)

  ## Iterate over each AZ creating a public subnet. Auto-generate
  ## Subnet CIDRs based on index.
    zones.each_with_index do |zone, index|

    dynamic!(:vpc_subnet, ['public_', zone.gsub('-', '_') ].join,
      :vpc_id => ref!(:vpc),
      :route_table => ref!(:public_route_table),
      :availability_zone => zone
    )

    parameters(['public_', zone.gsub('-', '_'), '_subnet_cidr' ].join) do
      default ['10.0.', index, '.0/24'].join
    end

  end

end
