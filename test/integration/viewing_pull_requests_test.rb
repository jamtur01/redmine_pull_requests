require 'test_helper'

class ViewingPullRequestsTest < ActionController::IntegrationTest
  setup do
    User.current = nil
  end

  should "show pull requests on an issue to an administrator" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:pull_requests, 'http://support.example.com/ticket/123, #143')
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    # pull requests shown
    assert_select '.pull-requests' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
    
  end

  should "show pull requests on an issue to a Project Member with the View pull requests permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:pull_requests, 'http://support.example.com/ticket/123, #143')
    @role = Role.generate!(:permissions => [:view_pull_requests, :view_issues])
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

    # pull requests shown
    assert_select '.pull-requests' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
  end

  should "not show pull requests on an issue to a Project Member without the View pull requests permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:pull_requests, 'http://support.example.com/ticket/123, #143')
    @role = Role.generate!(:permissions => [:view_issues])
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

    assert_select '.pull-requests', :count => 0
  end

  should "not show pull requests on an issue to a Non-Member without the View pull requests permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:pull_requests, 'http://support.example.com/ticket/123, #143')
    Role.non_member.update_attribute(:permissions, [:view_issues])
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '.pull-requests', :count => 0
  end

  should "not show pull requests on an issue to an Anonymous user without the View pull requests permission" do
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:pull_requests, 'http://support.example.com/ticket/123, #143')
    Role.anonymous.update_attribute(:permissions, [:view_issues])

    assert !User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '.pull-requests', :count => 0
  end
end

