require 'log4r'
require 'json'

require 'vagrant-openstack-illuin-provider/client/heat'
require 'vagrant-openstack-illuin-provider/client/keystone'
require 'vagrant-openstack-illuin-provider/client/nova'
require 'vagrant-openstack-illuin-provider/client/neutron'
require 'vagrant-openstack-illuin-provider/client/cinder'
require 'vagrant-openstack-illuin-provider/client/glance'

module VagrantPlugins
  module Openstack
    class Session
      include Singleton

      attr_accessor :token
      attr_accessor :project_id
      attr_accessor :endpoints

      def initialize
        @token = nil
        @project_id = nil
        @endpoints = {}
      end

      def reset
        initialize
      end
    end

    def self.session
      Session.instance
    end

    def self.keystone
      Openstack::KeystoneClient.instance
    end

    def self.nova
      Openstack::NovaClient.instance
    end

    def self.heat
      Openstack::HeatClient.instance
    end

    def self.neutron
      Openstack::NeutronClient.instance
    end

    def self.cinder
      Openstack::CinderClient.instance
    end

    def self.glance
      Openstack::GlanceClient.instance
    end
  end
end
