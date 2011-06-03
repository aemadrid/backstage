#
# Copyright 2011 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rack/test'
require 'backstage'
require 'json'

TEST_ROOT = File.expand_path( File.dirname( __FILE__ ) )

def app
  Backstage::Application
end

def resource_with_mock_mbean(klass)
  mock_mbean = mock('mbean')
  def mock_mbean.method_missing(method, *args, &block)
    method.to_s
  end

  if klass == Backstage::Log
    resource = Backstage::Log.new(File.join( TEST_ROOT, 'data', 'railsapp', 'log', 'production.log' ))
  else
    resource = klass.new('mock_mbean', mock_mbean)
    resource.stub(:app).and_return(resource_with_mock_mbean(Backstage::App)) unless klass == Backstage::App
  end
  
  resource.stub(:pool_type).and_return('shared') if klass == Backstage::Pool
  
  resource.stub(:name).and_return('name')
  resource.stub(:app_name).and_return('app_name')

  resource
end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
