SparkleFormation.new(:lazy_vpc__nat_subnet_vpc, :inherit => :public_subnet_vpc).overrides do

  description 'VPC with Public & NAT Subnets'

  ## Access the list of available Availability Zones via registry entry.
  zones = registry!(:zones)

  ## Instantiate an empty array to collect our private subnet IDs
  private_subnet_ids = []

  nat_zone = zones.first.gsub('-','_')
  ## Iterate over each AZ creating a public subnet. Auto-generate
  ## Subnet CIDRs based on index.

  zones.each_with_index do |zone, index|

    dynamic!(:vpc_subnet, ['private_', zone.gsub('-', '_') ].join,
      :vpc_id => ref!(:vpc),
      :route_table => ref!(:private_route_table),
      :availability_zone => zone
    )

    parameters(['private_', zone.gsub('-', '_'), '_subnet_cidr' ].join) do
      type 'String'
      default ['10.0.1', index, '.0/24'].join
    end

    outputs("#{['private_', zone.gsub('-', '_') ].join}_subnet".to_sym) do
      value ref!("#{['private_', zone.gsub('-', '_') ].join}_subnet".to_sym)
    end

    private_subnet_ids.push(ref!(['private_', zone.gsub('-', '_'), '_subnet'].join.to_sym))
  end

  outputs(:private_subnet_ids) do
    value join!(private_subnet_ids, :options => { :delimiter => ',' })
  end

  dynamic!(:vpc_nat_routing, :nat_vpc,
    :nat_subnet => ref!("public_#{nat_zone}_subnet".to_sym),
    :nat_route_table => ref!(:private_route_table)
  )
end
