SparkleFormation.component(:aws_vpc_core) do |_config ={}|
  set!('AWSTemplateFormatVersion', '2010-09-09')

  parameters do
    stack_creator do
      type 'String'
      default ENV['USER']
    end

    vpc_cidr do
      description 'VPC Subnet'
      type 'String'
      default '10.0.0.0/16'
    end

    dns_support do
      description 'Enable VPC DNS Support'
      type 'String'
      default 'true'
      allowed_values %w(true false)
    end

    dns_hostnames do
      description 'Enable VPC DNS Hostname Support'
      type 'String'
      default 'true'
      allowed_values %w(true false)
    end

    instance_tenancy do
      description 'Enable VPC Instance Tenancy'
      type 'String'
      default 'default'
      allowed_values %w(default dedicated)
    end
  end

  resources do
    dhcp_options do
      type 'AWS::EC2::DHCPOptions'
      properties do
        domain_name 'ec2.internal'
        domain_name_servers ['AmazonProvidedDNS']
        tags array!(
          -> {
            key 'Name'
            value stack_name!
          }
        )
      end
    end

    vpc do
      type 'AWS::EC2::VPC'
      properties do
        cidr_block ref!(:vpc_cidr)
        enable_dns_support ref!(:dns_support)
        enable_dns_hostnames ref!(:dns_hostnames)
        instance_tenancy ref!(:instance_tenancy)
        tags array!(
          -> {
            key 'Name'
            value stack_name!
          }
        )
      end
    end

    vpc_dhcp_options_association do
      type 'AWS::EC2::VPCDHCPOptionsAssociation'
      properties do
        vpc_id ref!(:vpc)
        dhcp_options_id ref!(:dhcp_options)
      end
    end

    private_route_table do
      type 'AWS::EC2::RouteTable'
      properties do
        vpc_id ref!(:vpc)
        tags array!(
          -> {
            key 'Name'
            value join!(stack_name!, " private")
          }
        )
      end
    end
  end

  outputs do
    vpc_id do
      value ref!(:vpc)
    end

    [ :vpc_cidr, :private_route_table ].each do |x|
      set!(x) do
        value ref!(x)
      end
    end
  end
end
