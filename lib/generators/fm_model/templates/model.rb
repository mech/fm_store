class <%= file_name.classify %>
  include FmStore::Layout
  
  set_layout "<%= layout_name %>"
  set_database "<%= database_name %>"

<% @fields.each do |field| -%>
  field :<%= field.parameterize.underscore %>, String, :fm_name => "<%= field %>"
<% end -%>
end
