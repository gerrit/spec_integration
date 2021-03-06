# FIXME: this should be in a module that only gets loaded in integrationtests
# This monkeypatch currently makes it impossible to create isolated controller specs
# that pass through exceptions (see “Expecting Errors” on http://rspec.info/rdoc-rails/classes/Spec/Rails/Example/ControllerExampleGroup.html)
ActionController::Base.class_eval do
  alias_method :rescue_action, :rescue_action_without_fast_errors

  attr_reader :rescued_exception
  def rescue_action_with_integration_support(e)
    @rescued_exception = e
    rescue_action_without_integration_support e
  end
  alias_method_chain :rescue_action, :integration_support
end