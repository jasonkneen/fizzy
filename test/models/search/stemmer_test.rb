require "test_helper"

class Search::StemmerTest < ActiveSupport::TestCase
  test "stem single word" do
    result = Search::Stemmer.stem("running")

    assert_equal "run", result
  end

  test "stem multiple words" do
    result = Search::Stemmer.stem("test, running      JUMPING & walking")

    assert_equal "test run jump walk", result
  end

  test "split Chinese characters for FTS indexing" do
    result = Search::Stemmer.stem("测试")

    assert_equal "测 试", result
  end

  test "split Japanese characters for FTS indexing" do
    result = Search::Stemmer.stem("テスト")

    assert_equal "テ ス ト", result
  end

  test "split Korean characters for FTS indexing" do
    result = Search::Stemmer.stem("테스트")

    assert_equal "테 스 트", result
  end

  test "mixed CJK and English" do
    result = Search::Stemmer.stem("running 测试 test")

    assert_equal "run 测 试 test", result
  end

  test "mixed CJK and English without spaces" do
    result = Search::Stemmer.stem("hello世界test")

    assert_equal "hello 世 界 test", result
  end

  test "CJK punctuation is treated as separator" do
    result = Search::Stemmer.stem("你好。世界")

    assert_equal "你 好 世 界", result
  end
end
