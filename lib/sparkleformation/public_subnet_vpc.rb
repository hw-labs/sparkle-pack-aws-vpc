SparkleFormation.new(:lazy_vpc__public_subnet_vpc).load(:aws_vpc_core).overrides do

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

  resources do
    %w( public private ).each do |type|
      set!("#{type}_route_table".to_sym) do
        type 'AWS::EC2::RouteTable'
        properties do
          vpc_id ref!(:vpc)
          tags array!(
            -> {
              key 'Name'
              value join!(stack_name!, " #{type}")
            }
          )
        end
      end
    end

    internet_gateway do
      type 'AWS::EC2::InternetGateway'
      properties do
        tags array!(
          -> {
            key 'Name'
            value stack_name!
          }
        )
      end
    end

    internet_gateway_attachment do
      type 'AWS::EC2::VPCGatewayAttachment'
      properties do
        internet_gateway_id ref!(:internet_gateway)
        vpc_id ref!(:vpc)
      end
    end

    public_subnet_internet_route do
      type 'AWS::EC2::Route'
      properties do
        destination_cidr_block '0.0.0.0/0'
        gateway_id ref!(:internet_gateway)
        route_table_id ref!(:public_route_table)
      end
    end
  end

  outputs do
    public_subnet_ids do
      value join!(public_subnet_ids, :options => { :delimiter => ',' })
    end

    [ :public_route_table, :private_route_table, :internet_gateway ].each do |x|
      set!(x) do
        value ref!(x)
      end
    end
  end

end
