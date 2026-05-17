# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  ActiveRecord::SchemaDumper.ignore_tables |= [
    /^tiger\./,
    /^topology\./,
    'spatial_ref_sys'
  ]
end
