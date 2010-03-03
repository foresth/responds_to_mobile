require File.dirname(__FILE__) + '/lib/respond_to_mobile_helper.rb'
require File.dirname(__FILE__) + '/lib/mobilized_styles'
require File.dirname(__FILE__) + '/lib/respond_to_mobile'

ActionView::Base.send(:include, RespondToMobileHelper)
ActionView::Base.send(:include, MobilizedStyles)
ActionView::Base.send(:alias_method_chain, :stylesheet_link_tag, :mobilization)