# encoding: utf-8
# Copyright (c) 2010 mech
#
require 'rubygems'

gem "activemodel", "~>3.0.0.rc"
gem "will_paginate", "~>3.0.pre"

require "singleton"
require 'yaml'
require 'rfm'
require 'rfm/metadata/field'
require 'fm_store/ext/field'
require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require 'will_paginate/collection'

require 'fm_store/config'
require 'fm_store/associations'
require 'fm_store/persistence'
require 'fm_store/builders/collection'
require 'fm_store/builders/single'
require 'fm_store/connection'
require 'fm_store/components'
require 'fm_store/field'
require 'fm_store/fields'
require 'fm_store/finders'
require 'fm_store/criteria'
require 'fm_store/layout'

if defined?(Rails)
  require 'fm_store/railtie'
end