require "test_helper"

class HtmlHelperTest < ActionView::TestCase
  test "convert URLs into anchor tags" do
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com" rel="noreferrer">https://example.com</a></p>),
      format_html("<p>Check this: https://example.com</p>")
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com/" rel="noreferrer">https://example.com/</a></p>),
      format_html("<p>Check this: https://example.com/</p>")
  end

  test "don't' include punctuation in URL autolinking" do
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com" rel="noreferrer">https://example.com</a>!</p>),
      format_html("<p>Check this: https://example.com!</p>")
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com" rel="noreferrer">https://example.com</a>.</p>),
      format_html("<p>Check this: https://example.com.</p>")
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com" rel="noreferrer">https://example.com</a>?</p>),
      format_html("<p>Check this: https://example.com?</p>")
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com" rel="noreferrer">https://example.com</a>,</p>),
      format_html("<p>Check this: https://example.com,</p>")
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com" rel="noreferrer">https://example.com</a>:</p>),
      format_html("<p>Check this: https://example.com:</p>")
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com" rel="noreferrer">https://example.com</a>;</p>),
      format_html("<p>Check this: https://example.com;</p>")
  end

  test "respect existing links" do
    assert_equal_html \
      %(<p>Check this: <a href="https://example.com">https://example.com</a></p>),
      format_html("<p>Check this: <a href=\"https://example.com\">https://example.com</a></p>")
  end

  test "convert email addresses into mailto links" do
    assert_equal_html \
      %(<p>Contact us at <a href="mailto:support@example.com">support@example.com</a></p>),
      format_html("<p>Contact us at support@example.com</p>")
  end

  test "respect existing linked emails" do
    assert_equal_html \
      %(<p>Contact us at <a href="mailto:support@example.com">support@example.com</a></p>),
      format_html(%(<p>Contact us at <a href="mailto:support@example.com">support@example.com</a></p>))
  end

  test "don't autolink content in excluded elements" do
    %w[ figcaption pre code ].each do |element|
      assert_equal_html \
        "<#{element}>Check this: https://example.com</#{element}>",
        format_html("<#{element}>Check this: https://example.com</#{element}>")
    end
  end
end
