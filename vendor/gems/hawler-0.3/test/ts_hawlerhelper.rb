# $Id: ts_hawlerhelper.rb 4 2008-03-02 04:47:09Z warchild $

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'hawlerhelper'
require 'test/unit'
require 'test/unit/assertions'


class TestHawlerHelper < Test::Unit::TestCase

  def setup
    @html = %q{
    <html>
    <head>
    <title>This is some poorly written html</title>
    </head>
    <body>
    This is some bogus html that should have some links of
    the <a href="lkajfdlakjfd">usual</a> form, as well as the 
    not so pretty form by just http://letting/it/all/hang/out
    or like so http://foo/klasjfd
    <script src="/path/to/nasty/js"></script>
    <img src="http://blahblah"/>
    </body>
    </html>
    }

    @targets = %w(http://www.google.com http://www.yahoo.com http://slashdot.org)
  end

  def test_harvest
    assert_equal(2, HawlerHelper.harvest("http://foo", @html).size)
    assert_equal(3, HawlerHelper.harvest("http://blahblah", @html).size)
  end

  def test_brute
    assert_equal(6, HawlerHelper.brute_from_uri("http://foo/bar/baf/blah").size)
    assert_equal(3, HawlerHelper.brute_from_data("http://foo", @html).size)
  end

  def test_offsite
    assert HawlerHelper.offsite?("http://google.com", "http://yahoo.com")
    assert ! HawlerHelper.offsite?("http://spoofed.org", "http://spoofed.org/blah")
  end

  def test_get
    uri = @targets[rand(@targets.size)]
    assert_kind_of(Net::HTTPSuccess, HawlerHelper.get(uri, nil, nil))
  end
end

