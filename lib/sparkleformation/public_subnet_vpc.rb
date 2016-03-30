SparkleFormation.new(:lazy_vpc__public_subnet_vpc).load(:base, :vpc).overrides do

  description 'VPC with Public Subnets'

  ## Access the list of available Availability Zones via registry entry.
  zones = registry!(:zones)

  ## Instantiate an empty array to collect our public subnet IDs
  public_subnet_ids = []

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

    public_subnet_ids.push(ref!(['public_', zone.gsub('-', '_'), '_subnet'].join.to_sym))
  end

  outputs(:public_subnet_ids) do
    value join!(public_subnet_ids, :options => { :delimiter => ',' })
  end

end
