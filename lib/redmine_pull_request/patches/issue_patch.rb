module RedminePullRequest
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def pull_requests
          if User.current.allowed_to?(:view_pull_requests, project)
            self.read_attribute(:pull_requests)
          else
            nil
          end
        end

        def pull_requests=(v)
          # Also set @issue_before_change's pull requests so
          # #create_journal don't see the changes, thus preventing the
          # pull_request changes from being logged. (Data exposure)
          @issue_before_change.pull_requests = v if @issue_before_change
          self.write_attribute(:pull_requests, v)
        end

        def pull_requests_as_list
          return [] if pull_requests.blank?

          urls = pull_requests.split("\n").
            collect {|items| items.split(',')}.
            flatten.
            collect {|items| items.split(' ')}.
            flatten.
            collect(&:strip)

          unless Struct.const_defined?("PullRequest")
            Struct.new("PullRequest", :text, :url)
          end

          urls.inject([]) do |links, text|
            if text.match(/#/) &&
                Setting.plugin_redmine_pull_request &&
                Setting.plugin_redmine_pull_request['base_url'].present?

              link = Setting.plugin_redmine_pull_request['base_url'].gsub('{id}', text.gsub('#',''))
            else
              link = text # Full url used
            end
            links << Struct::PullRequest.new(text, link)
            links
          end

        end
      end
    end
  end
end
