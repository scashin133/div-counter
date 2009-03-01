# $Id: hawlerhelper.rb 30 2009-01-24 20:27:56Z warchild $
#
# Copyright (c) 2008, Jon Hart 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY Jon Hart ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Jon Hart BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# A collection of helper methods for making the life of a crawler
# easier.  Designed to be self-contained.
#
# Jon Hart <jhart@spoofed.org>

require 'hpricot'

module HawlerHelper

  # Given a +uri+, return all possible variations of the path.
  def self.brute_from_uri(uri)
    uri = valid_uri(uri)
    links = Set.new

    # if we get http://foo/bar/baf/blah, also
    # queue up http://foo/bar/baf, http://foo/bar
    # and http://foo.  Don't bother carrying the query
    # string around either.
    uri.query = nil
    parts = uri.path.split(/\//)
    
    (parts.size - 1).downto(0) do |s|
      links << uri.merge(parts[0..s].join("/") + "/") unless (s == parts.size - 1)
      links << uri.merge(parts[0..s].join("/")) unless (s == 0)
    end

    links.to_a
  end
  
  # Given some +data+, find all possible URIs, regardless of whether or not
  # they are actual links
  def self.brute_from_data(uri, data)
    links = Set.new
    URI.extract(data, ['http', 'https']).each do |l|
      l.gsub!(/['"].*/, '') # work around extract's inability to handle javascript
      l.gsub!(/^["']/, '') # remove leading quote(s)
      l.gsub!(/["']$/, '') # remove trailing quote(s)
      l.gsub!(/^\.\//, '') # handle "src=./foo"
      l = valid_uri(l) or next
      uri = valid_uri(uri) or next
      links << uri.merge(l).to_s
    end

    links.to_a
  end


  # Send an HTTP GET request to +uri+, setting a Referer header of
  # +referer+, setting other headers from the +headers+ hash.  Return
  # the Net::HTTPResponse object
  def self.get(uri, referer, headers, proxy=nil, proxyport=nil)
    request("GET", uri, referer, headers, proxy, proxyport)
  end

  # Given a +uri+ and the +data+ returned from retrieving said URI
  # extract all links.  Pulls links from the following tag types: a, link, 
  # img, script, frame and form.  Missing some?  Let me know!
  def self.harvest(uri, data)
    links = Set.new
    uri = valid_uri(uri)
    doc = Hpricot(data)
    tags = Hash[ *%w(a href link href img src script src frame src form action) ]

    tags.each do |k,v|
      (doc/"#{k}").each do |t|
        next if (t.attributes[v].nil? || t.attributes[v].empty?)
        l = valid_uri(t.attributes[v]) or next
        next if (offsite?(uri.merge(l), uri))
        links << uri.merge(l)
      end
    end
    links.to_a
  end

  # Send an HTTP HEAD request to +uri+, setting a Referer header of
  # +referer+, setting other headers from the +headers+ hash.  Return
  # the Net::HTTPResponse object
  def self.head(uri, referer, headers, proxy, proxyport)
    request("HEAD", uri, referer, headers, proxy, proxyport)
  end

  # Is +uri+ offsite from +referer+?
  def self.offsite?(uri, referer)
    uri = valid_uri(uri) or return true
    referer = valid_uri(referer) or return true
    if (referer.host == uri.host ||
       "www.#{referer.host}" == uri.host ||
       referer.host == "www.#{uri.host}")
      return false
    else
      return true 
    end
  end

  # Send an HTTP method of +method+ request to +uri+, setting a Referer header
  # of +referer+, setting other headers from the +headers+ hash.  Return
  # the Net::HTTPResponse object
  def self.request(method, uri, referer, headers, proxy, proxyport)
    uri = valid_uri(uri) or return nil
    method.downcase!

    begin
      http = Net::HTTP.new(uri.host, uri.port, proxy, proxyport)

      req = uri.query.nil? ? uri.path : "#{uri.path}?#{uri.query}"

      unless (referer.nil?)
        headers["Referer"] = referer.to_s unless (headers["Referer"])
      end

      if (uri.scheme == "https")
        http.use_ssl = true 
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.send "request_#{method}", req, headers
    rescue Exception => e
      puts "Connection to #{uri} failed! -- #{e}"
      return nil
    end

    response
  end

  # Is this URI valid?  Essentially just calls URI.parse()
  def self.valid_uri(uri)
    begin
      link = URI.parse("#{uri}")
        unless (link.scheme =~ /https?/ || link.scheme.nil?)
          return false
        end
      link.path = "/" if link.path.empty?
      link.fragment = nil
     rescue URI::Error => e
      return false 
    end

    link
  end

end

