SparkleFormation.dynamic(:vpc_nat_routing) do |_name, _config = {}|

  subnet = _config.fetch(:nat_subnet)

  resources("#{subnet}_nat_eip".to_sym) do
    type 'AWS::EC2::EIP'
    properties do
      domain 'vpc'
    end
  end

  resources("#{subnet}_nat_gateway".to_sym) do
    type 'AWS::EC2::NatGateway'
    properties do
      allocation_id attr!("#{subnet}_nat_eip".to_sym, :allocation_id)
      subnet_id ref!(subnet)
    end
  end

  resources("#{subnet}_nat_route".to_sym) do
    type 'AWS::EC2::Route'
    depends_on process_key!("#{subnet}_nat_gateway".to_sym)
    properties do
      route_table_id _config.fetch(:nat_route_table)
      destination_cidr_block _config.fetch(:nat_destination, '0.0.0.0/0')
      nat_gateway_id ref!("#{subnet}_nat_gateway".to_sym)
      end
  end
end
