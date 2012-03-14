require 'test_helper'

class EditingPullRequestsTest < ActionController::IntegrationTest
  setup do
    User.current = nil
  end

  should "show allow editing pull requests for an administrator" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success
    assert_equal "/issues/#{@issue.id}", current_url

    fill_in "Pull Requests", :with => 'http://support.example.com/ticket/123, #143'
    fill_in "notes", :with => 'Adding two pull requests'
    click_button "Submit"

    assert_response :success
    assert_equal "http://www.example.com/issues/#{@issue.id}", current_url

    # Pull requests shown
    assert_select '.pull-requests' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
    
  end

  should "show pull requests on an issue to a Project Member with the Edit Pull Requests permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:pull_requests, 'http://support.example.com/ticket/123, #143')
    @role = Role.generate!(:permissions => [:view_pull_requests, :view_issues, :edit_pull_requests, :edit_issues])
    Member.generate!(:principal => @user, :roles => [@role], :project => @project)
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success
    assert_equal "/issues/#{@issue.id}", current_url

    fill_in "Pull Requests", :with => 'http://support.example.com/ticket/123, #143'
    fill_in "notes", :with => 'Adding two pull requests'
    click_button "Submit"

    assert_response :success
    assert_equal "http://www.example.com/issues/#{@issue.id}", current_url

    # Pull requests shown
    assert_select '.pull-requests' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
  end

  should "not show pull requests on an issue to a Project Member without the Edit Pull Requests permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @role = Role.generate!(:permissions => [:view_issues, :edit_issues, :view_pull_requests])
    Member.generate!(:principal => @user, :roles => [@role], :project => @project)
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '#issue_pull_requests', :count => 0
    fill_in "notes", :with => 'Adding two pull requests'
    click_button "Submit"

    assert_response :success
    assert_equal "http://www.example.com/issues/#{@issue.id}", current_url

    assert @issue.reload.pull_requests.blank?, "Pull requests were saved."
  end

  should "not show pull requests on an issue to a Non-Member without the Edit Pull Requests permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    Role.non_member.update_attribute(:permissions, [:view_issues, :edit_issues, :view_pull_requests])
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '#issue_pull_requests', :count => 0
    fill_in "notes", :with => 'Adding two pull requests'
    click_button "Submit"

    assert @issue.reload.pull_requests.blank?, "Pull requests were saved."
  end

  should "not show pull requests on an issue to an Anonymous user without the Edit Pull Requests permission" do
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    Role.anonymous.update_attribute(:permissions, [:view_issues, :edit_issues, :view_pull_requests])

    assert !User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '#issue_pull_requests', :count => 0
    fill_in "notes", :with => 'Adding two pull requests'
    click_button "Submit"

    assert @issue.reload.pull_requests.blank?, "Pull requests were saved."
  end

  should "not allow unauthorized users to update pull requests from a form" do
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    Role.anonymous.update_attribute(:permissions, [:view_issues, :edit_issues, :view_pull_requests])

    assert !User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '#issue_pull_requests', :count => 0
    fill_in "notes", :with => 'Adding two pull requests'
    click_button "Submit"

    put "/issues/#{@issue.id}/edit", :issue => {:pull_requests => 'crafted form post'}

    assert @issue.reload.pull_requests.blank?, "Pull requests were saved."
  end
end

