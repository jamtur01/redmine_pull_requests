module RedminePullRequest
  module Hooks
    class ControllerIssuesEditBeforeSaveHook < Redmine::Hook::ViewListener
      # * params
      # * issue
      # * time_entry
      # * journal
      def controller_issues_edit_before_save(context={})
        if context[:params] && context[:params][:issue] && context[:params][:issue][:pull_requests] && User.current.allowed_to?(:edit_pull_requests, context[:issue].project)
          context[:issue].pull_requests = context[:params][:issue][:pull_requests]
        end
        return ''
          
      end
    end
  end
end
