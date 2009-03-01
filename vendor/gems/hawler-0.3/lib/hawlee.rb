# $Id: hawlee.rb 24 2009-01-02 07:22:54Z warchild $
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
# Simple class to track URIs as they are crawled.  Mildly better than using
# a hash of hashes.  The order of operations for a URI is get, harvest
# the links, and then analyze the response
#
# Jon Hart <jhart@spoofed.org>

class Hawlee
  attr_accessor :uri, :referer, :depth

  def initialize(uri, referer, depth)
    @uri = uri
    @referer = referer
    @depth = depth
    @head = false
    @analyze = false
    @get = false
    @harvest = false
  end

  # Mark this URI as having been analyzed
  def analyze(val=true)
    @analyze = val
  end

  # Has this URI been analyzed?
  def analyze?
    @analyze
  end

  # Mark this URI as having been HEAD
  def head(val=true)
    @head = val
  end

  # Has this URI been crawled?
  def head?
    @head
  end

  # Mark this URI as having had its links pulled
  def harvest(val=true)
    @harvest = val
  end

  # Have we got this URI's links?
  def harvest?
    @harvest
  end

  # Mark this URI as having been got
  def get(val=true)
    @get = val
  end

  # Has this URI been got?
  def get?
    @get
  end

  def to_s
    "#{@uri}"
  end 

end
