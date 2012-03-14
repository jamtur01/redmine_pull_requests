module RedminePullRequest
  module Patches
    module QueryPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          class << self
            # Redmine 0.9 compatibility patches
            def available_columns=(v)
              self.available_columns = (v)
            end unless respond_to?(:available_columns=)

            def add_available_column(column)
              self.available_columns << (column) if column.is_a?(QueryColumn)
            end unless respond_to?(:add_available_column)
          end

          Query.add_available_column(QueryColumn.new(:pull_requests,
                                                     :sortable => "#{Issue.table_name}.pull_requests"))

          alias_method_chain :available_filters, :pull_requests
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def available_filters_with_pull_requests
          core_filters = available_filters_without_pull_requests

          core_filters["pull_requests"] = {
            :type => :text, :order => 17
          }
          
          @available_filters = core_filters
        end
      end
    end
  end
end
