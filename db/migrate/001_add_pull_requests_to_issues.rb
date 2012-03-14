class AddPullRequestsToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :pull_requests, :text, :null => true
  end

  def self.down
    remove_column :issues, pull_requests
  end
end
