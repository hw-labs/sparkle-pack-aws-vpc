SparkleFormation.dynamic(:vpc_nat_routing) do |_name, _config = {}|

  resources("#{_name}_nat_eip".to_sym) do
    type 'AWS::EC2::EIP'
    properties do
      domain 'vpc'
    end
  end

  resources("#{_name}_nat_gateway".to_sym) do
    type 'AWS::EC2::NatGateway'
    properties do
      allocation_id attr!("#{_name}_nat_eip".to_sym, :allocation_id)
      subnet_id _config.fetch(:nat_subnet)
    end
  end

  resources("#{_name}_nat_route".to_sym) do
    type 'AWS::EC2::Route'
    depends_on process_key!("#{_name}_nat_gateway".to_sym)
    properties do
      route_table_id _config.fetch(:nat_route_table)
      destination_cidr_block _config.fetch(:nat_destination, '0.0.0.0/0')
      nat_gateway_id ref!("#{_name}_nat_gateway".to_sym)
      end
  end
end
