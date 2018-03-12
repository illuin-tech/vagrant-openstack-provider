require 'colorize'
require 'singleton'
require 'vagrant-openstack-illuin-provider/version'

module VagrantPlugins
  module Openstack
    class VersionChecker
      include Singleton

      #
      # :latest, :outdated or :unstable
      #
      # A version is considered unstable if it does not
      # respect the pattern or if it is greater than the
      # latest from rubygem
      #
      attr_accessor :status

      def initialize
        @status = nil
      end

      #
      # Check the latest version from rubygem and set the status
      #
      def check
        return @status unless @status.nil?
        latest  = Gem.latest_spec_for('vagrant-openstack-illuin-provider').version.version
        current = VagrantPlugins::Openstack::VERSION

        unless current =~ VERSION_PATTERN
          @status = :unstable
          print I18n.t('vagrant_openstack.version_unstable')
          return
        end

        if latest.eql? current
          @status = :latest
          return
        end

        v_latest = latest.split('.').map(&:to_i)
        v_current = current.split('.').map(&:to_i)

        i_latest = v_latest[2] + v_latest[1] * 1000 + v_latest[0] * 1_000_000
        i_current = v_current[2] + v_current[1] * 1000 + v_current[0] * 1_000_000

        if i_current > i_latest
          @status = :unstable
          print I18n.t('vagrant_openstack.version_unstable')
          return
        end

        @status = :outdated
        print I18n.t('vagrant_openstack.version_outdated', latest: latest, current: current)
      end

      private

      def print(message)
        puts message.yellow
        puts ''
      end
    end

    # rubocop:disable Lint/HandleExceptions
    def self.check_version
      Timeout.timeout(3, Errors::Timeout) do
        VersionChecker.instance.check
      end
    rescue
      # Do nothing whatever the failure cause
    end
    # rubocop:enable Lint/HandleExceptions
  end
end
