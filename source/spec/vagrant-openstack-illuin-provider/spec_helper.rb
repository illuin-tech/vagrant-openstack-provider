
if ENV['COVERAGE'] != 'false'
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter 'spec'
  end
end

Dir[
  'lib/vagrant-openstack-illuin-provider/version_checker.rb',
  'lib/vagrant-openstack-illuin-provider/logging.rb',
  'lib/vagrant-openstack-illuin-provider/config.rb',
  'lib/vagrant-openstack-illuin-provider/config_resolver.rb',
  'lib/vagrant-openstack-illuin-provider/utils.rb',
  'lib/vagrant-openstack-illuin-provider/errors.rb',
  'lib/vagrant-openstack-illuin-provider/provider.rb',
  'lib/vagrant-openstack-illuin-provider/client/*.rb',
  'lib/vagrant-openstack-illuin-provider/command/*.rb',
  'lib/vagrant-openstack-illuin-provider/action/*.rb'].each { |file| require file[4, file.length - 1] }

require 'rspec/its'
require 'webmock/rspec'
require 'fakefs/safe'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end

I18n.load_path << File.expand_path('locales/en.yml', Pathname.new(File.expand_path('../../../', __FILE__)))

VagrantPlugins::Openstack::Logging.init
