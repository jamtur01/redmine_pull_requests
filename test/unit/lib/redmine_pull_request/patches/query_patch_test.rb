require File.dirname(__FILE__) + '/../../../../test_helper'

class RedminePullRequest::Patches::QueryTest < ActionController::TestCase

  context "Query#available_columns" do
    should "include pull requests" do
      pull_request_column = Query.available_columns.select {|c| c.name == :pull_requests}
      assert pull_request_column.present?
    end
  end

  context "Query#available_filters" do
    should "include a pull request filter" do
      pull_request_filter = Query.new.available_filters["pull_requests"]
      assert pull_request_filter.present?
    end

    should "use a 'text' format for the pull request filter" do
      pull_request_filter = Query.new.available_filters["pull_requests"]
      assert_equal :text, pull_request_filter[:type]
    end
  end
end
