# $Id: ts_hawlee.rb 4 2008-03-02 04:47:09Z warchild $

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'hawlee'
require 'test/unit'
require 'test/unit/assertions'

class TestHawlee < Test::Unit::TestCase
  def test_init
    assert_nothing_raised{f = Hawlee.new("http://blah.test.com", "http://google.com", 0)}
  end

  def test_flip
    h = Hawlee.new("http://spoofed.org", nil, 0)
    %w(head get harvest analyze).each do |t|
      h.send t
      assert h.send("#{t}?")
    end
  end
end
 
