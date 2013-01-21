module DepartmentsHelper
  def link_to_if_authorized_with_global(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options.delete_if{|k,v| k == :global}, html_options, *parameters_for_method_reference) if authorize_for_with_global(options[:controller] || params[:controller], options[:action], options[:global])
  end
  def authorize_for_with_global(controller, action, global = false)
    User.current.allowed_to?({:controller => controller, :action => action}, @project, {:global => global})
  end

  def query_list_item_value_content(value, name, item, query=nil)
    return super unless value.is_a? Department
    link_to h(value.name), department_path(value)
  end
end
