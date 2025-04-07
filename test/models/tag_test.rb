require "test_helper"

class TagTest < ActiveSupport::TestCase
  setup do
    @account = accounts("37s")
  end

  test "creating or deleting a tag touches the account, so tags dialog fragment cache is invalidated" do
    assert_changes -> { @account.reload.updated_at } do
      @account.tags.create!(title: "ReleaseBlocker")
    end

    assert_changes -> { @account.reload.updated_at } do
      @account.tags.find_by(title: "ReleaseBlocker").destroy
    end
  end

  test "downcase title" do
    assert_equal "a tag", @account.tags.create!(title: "A TAG").title
  end
end
