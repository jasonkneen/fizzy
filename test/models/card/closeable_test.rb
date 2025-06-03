require "test_helper"

class Card::CloseableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "closed scope" do
    assert_equal [ cards(:shipping) ], Card.closed
    assert_not_includes Card.open, cards(:shipping)
  end

  test "popping" do
    assert_not cards(:logo).closed?

    cards(:logo).close(user: users(:kevin))

    assert cards(:logo).closed?
    assert_equal users(:kevin), cards(:logo).closed_by
  end
end
