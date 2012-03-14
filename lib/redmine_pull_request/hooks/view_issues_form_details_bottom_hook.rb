module RedminePullRequest
  module Hooks
    class ViewIssuesFormDetailsBottomHook < Redmine::Hook::ViewListener
      # * :issue
      # * :form
      def view_issues_form_details_bottom(context={})
        return '' if context[:issue].nil? || context[:issue].project.nil?
        return '' unless User.current.allowed_to?(:view_pull_requests, context[:issue].project)
        return '' unless User.current.allowed_to?(:edit_pull_requests, context[:issue].project)

        return content_tag(:p, context[:form].text_area(:pull_requests, :cols => 60, :rows => 3))
      end
    end
  end
end
