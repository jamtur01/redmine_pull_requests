module RedminePullRequest
  module Hooks
    class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener

      def url_for(options={})
        if options.is_a? String
          escape_once(options)
        else
          super
        end
      end
      
      # * issue
      def view_issues_show_description_bottom(context={})
        return '' if context[:issue].project.nil?
        return '' unless User.current.allowed_to?(:view_pull_requests, context[:issue].project)

        html = '<hr />'
        inner_section = ''
        inner_section << content_tag(:p, content_tag(:strong, l(:field_pull_requests)))

        if context[:issue].pull_requests.present?
          items = context[:issue].pull_requests_as_list.inject('') do |list, pull_request|
            list << content_tag(:tr,
                                content_tag(:td,
                                            link_to(pull_request.text, pull_request.url, :title => l(:simple_request_text_external_request_link, :content => pull_request.text))))
            list
          end
          
          inner_section << content_tag(:table, items, :style => 'width: 100%')
        end
        
        html << content_tag(:div, inner_section, :class => 'request-urls')

        return html
      end
    end
  end
end
