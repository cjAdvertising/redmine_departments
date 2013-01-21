require_dependency 'query'

module RedmineDepartments
  # Patches Redmine's Queries dynamically, adding the Deliverable
  # to the available query columns
  module QueryPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        #base.add_available_column(QueryColumn.new(:deliverable_subject, :sortable => "#{Deliverable.table_name}.subject"))

        alias_method_chain :available_filters, :departments
        alias_method_chain :available_columns, :departments
        alias_method_chain :sql_for, :departments
      end

    end

    module ClassMethods
    end

    module InstanceMethods

      def available_columns_with_departments
        available_columns_without_departments.merge :departments => {}
      end

      # Wrapper around the +available_filters+ to add a new Departments filter
      def available_filters_with_departments
        return @available_filters if @available_filters.present?
        @available_filters = available_filters_without_departments.merge :department_id => {
          :type => :list_optional, :order => 14,
          :choices => Department.all.map { |d| [d.name, d.id.to_s] }
        }
      end

      def sql_for_with_departments(name, operator=nil, values=nil, table=nil, field=nil, type=nil)
        return sql_for_without_departments(name, operator, values, table, field, type) unless name == :department_id
        values ||= values_for(name)
        table ||= queryable_class.table_name
        operator ||= operator_for(name)
        sql = "#{table}.id #{"NOT" if ["!", "!*"].include?(operator)} IN (SELECT issue_has_departments.issue_id FROM issue_has_departments"
        if ["=", "!"].include? operator
          sql << " WHERE " + sql_for_without_departments(name, "=", values, "issue_has_departments")
        end
        sql + ")"
      end
    end
  end
end