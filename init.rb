require 'redmine'

Redmine::Plugin.register :redmine_pull_request do
  name 'Redmine Pull Request'
  author 'Eric Davis'
  description 'Allows linking pull requests in Redmien tickets.'
  url 'https://github.com/jamtur01/redmine-pull-request'

  version '0.0.1'

  requires_redmine :version_or_higher => '0.9.2'

  settings({
             :partial => 'settings/redmine_pull_request',
             :default => {
               'base_url' => nil
             }
           })

  project_module :pull_request do
    permission :view_request_urls, {}
    permission :edit_request_urls, {}
  end
end
require 'redmine_pull_request/hooks/view_issues_form_details_bottom_hook'
require 'redmine_pull_request/hooks/view_issues_show_description_bottom_hook'
require 'redmine_pull_request/hooks/controller_issues_edit_before_save_hook'

require 'dispatcher'
Dispatcher.to_prepare :redmine_pull_request do

  require_dependency 'query'
  unless Query.included_modules.include?(RedminePullRequest::Patches::QueryPatch)
    Query.send(:include, RedminePullRequest::Patches::QueryPatch)
  end

  require_dependency 'issue'
  Issue.send(:include, RedminePullRequest::Patches::IssuePatch)
end
