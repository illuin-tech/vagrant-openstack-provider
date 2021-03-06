module VagrantPlugins
  module Openstack
    class Utils
      def initialize
        @logger = Log4r::Logger.new('vagrant_openstack::action::config_resolver')
      end

      def get_ip_address(env)
        addresses = env[:openstack_client].nova.get_server_details(env, env[:machine].id)['addresses']
        # First, try to get a floating ip with the right version. If none of the floating ip is of the right version,
        # return the first floating ip anyway.
        fallback = nil
        addresses.each do |_, network|
          network.each do |network_detail|
            next unless network_detail['OS-EXT-IPS:type'] == 'floating'
            if env[:machine].provider_config.ip_version.nil?
              return network_detail['addr']
            elsif get_ip_version(network_detail['addr']) == env[:machine].provider_config.ip_version
              return network_detail['addr']
            end
            fallback ||= network_detail['addr']
          end
        end
        return fallback unless fallback.nil?

        fail Errors::UnableToResolveIP if addresses.size == 0

        # If only one network, we don't use networks config and return the first IP of the correct version
        # If no IP for this version, return the first IP anyway
        if addresses.size == 1
          net_addresses = addresses.first[1]
          fail Errors::UnableToResolveIP if net_addresses.size == 0
          if env[:machine].provider_config.ip_version.nil?
            return net_addresses[0]['addr']
          else
            right_version_ip = filter_by_version(net_addresses, env[:machine].provider_config.ip_version)
            if right_version_ip.nil?
              return net_addresses[0]['addr']
            else
              return right_version_ip
            end
          end
        end

        # If multiple networks exist, follow the order of the networks config and return the first IP of the correct
        # version, be it in the first network or not.
        fallback = nil
        env[:machine].provider_config.networks.each do |network|
          if network.is_a? String
            net_addresses = addresses[network]
          else
            net_addresses = addresses[network[:name]]
          end
          next if net_addresses.size == 0
          fallback ||= net_addresses[0]['addr']
          if env[:machine].provider_config.ip_version.nil?
            return net_addresses[0]['addr']
          else
            right_version_ip = filter_by_version(net_addresses, env[:machine].provider_config.ip_version)
            if right_version_ip.nil?
              next
            else
              return right_version_ip
            end
          end
        end
        fail Errors::UnableToResolveIP if fallback.nil?
        fallback
      end

      private

      def get_ip_version(ip)
        (ip.include? '.') ? 4 : 6
      end

      def filter_by_version(net_addresses, wanted_ip_version)
        net_addresses.each do |address|
          if get_ip_version(address['addr']) == wanted_ip_version
            return address['addr']
          end
        end
        nil
      end
    end
  end
end
