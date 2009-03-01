# $Id: hawler.rb 26 2009-01-02 07:27:37Z warchild $
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
# +Hawler+, the HTTP crawler.  Written after years of reusing the same perl
# code over and over in every tool that could make use of crawling
# functionality.  Now it is truly reusable and in Ruby.
#
# Written to ease satisfying curiousities about the way the web is woven.  
#
# The original gem and tools that make use of Hawler can be found at:
#
#   http://spoofed.org/files/hawler/
#
# The basic idea is that a Hawler visits a given URI (+get+), pulls
# all of the links from the response body (+harvest+), and repeats this
# until every link to the specified +recurse+ +depth+ has been visited.
# Every URI that is visit is passed to +analyze+, which is simply a block
# that takes the URI, referer, and the response as arguments.
#
# This is a unordered, breadth-first crawl.  Enjoy.
#
# Jon Hart <jhart@spoofed.org>

require 'net/http'
require 'net/https'
require 'uri'
require 'set'
require 'hawlee'
require 'hawlerhelper'

class Hawler

  attr_accessor :verbose, :debug, :help
  attr_accessor :recurse, :depth
  attr_accessor :sleep, :force, :brute
  attr_accessor :peek, :types, :headers
  attr_accessor :proxy, :proxyport

  # Simple helper to create a new +Hawlee+
  def generate_hawlee(link, hawlee)
    print_debug("Queuing #{link} for processing")
    Hawlee.new(link, hawlee.uri, hawlee.depth + 1)
  end

  def initialize(uri, block)
    unless (uri =~ /^https?:\/\//) 
      uri = "http://#{uri}"
    end
    
    @uri = uri
    @block = block
    @links = {}
   
    @recurse = false
    @verbose = false
    @debug = false
    @depth = nil 
    @sleep = 0
    @done = false
    @force = false
    @brute = false
    @peek = false
    @types = Hash[ *%w(text/html text/xml application/xml).collect { |v| [v,1] }.flatten ]
    @headers = {}
    @proxy = nil
    @proxyport = nil

    # register some signal handlers.  halt on ctrl-c, enable verbose on SIGUSR1
    # and enable debug on SIGUSR2
    Signal.trap("INT", lambda { @done = true and puts "Terminating -- ctrl-c" })
    Signal.trap("USR1", lambda { @verbose = !@verbose and puts "Enabling verbose mode" })
    Signal.trap("USR2", lambda { @debug = !@debug and puts "Enabling debug mode" })
  end

  # Start the Hawler.
  def start
    if (!@recurse)
      @depth = 0 
    end
    @uri = HawlerHelper.valid_uri(@uri) or exit(1)
    hawl(@uri)
  end

private

  # For every every URI, do something called +what+ which
  # consists of executing +block+
  def do_once(uri, referer, what, block)
    unless (@links[uri])
      @links[uri] = Hawlee.new(uri, referer, 0)
    end

    if (@links[uri].send("#{what}?"))
      print_debug("Skipping #{uri} (referer #{referer}) -- '#{what}' already called")
    else
      print_verbose("Calling #{what} on #{uri} (referer #{referer})")
      @links[uri].send("#{what}")
      return block.call
    end
  end

  def hawl(uri)
    # sucks to have to use an array for this, but
    # order is important to achieve something that is close
    # to a breadth-first search
    links_to_process = [] 
    links_to_process << Hawlee.new(uri, nil, 0)

    while (!links_to_process.empty?)
      cur_hawlee = links_to_process.shift

      if (HawlerHelper.offsite?(uri, cur_hawlee.uri))
        unless (@force)
          print_debug("Skipping offsite URI #{cur_hawlee}")
          next
        end
      end

      if (@peek)
        do_once(cur_hawlee.uri, cur_hawlee.referer, :head, lambda {
          if (@depth && cur_hawlee.depth > @depth)
            print_debug("Max recursion depth of #{@depth} at #{cur_hawlee.uri}")
            return false 
          end

          peek_response = HawlerHelper.head(cur_hawlee.uri, cur_hawlee.referer, @headers, @proxy, @proxyport)
          if (peek_response.nil?)
            return false 
          else
            case peek_response
              when Net::HTTPRedirection
                if (HawlerHelper.valid_uri(peek_response['location']))
                  redirect = uri.merge(peek_response['location'])
                  links_to_process << generate_hawlee(redirect, cur_hawlee)
                  return false
                end
            end
            
            # only pass this URI on for retrieval if it's 
            # Content-Type is one that is likely to have links in it.
            if (peek_response.key?("Content-Type"))
              c = peek_response["Content-Type"]
              c.gsub!(/;.*/, "")
              if (@types["#{c}"])
                return true
              else
                return false
              end
            else 
              return true 
            end
          end
        }) or next
      end
      
      response = nil
      do_once(cur_hawlee.uri, cur_hawlee.referer, :get, lambda {
        if (@depth && cur_hawlee.depth > @depth)
          print_debug("Max recursion depth of #{@depth} at #{cur_hawlee.uri}")
        else 
          response = HawlerHelper.get(cur_hawlee.uri, cur_hawlee.referer, @headers, @proxy, @proxyport)
          unless (response.nil?)
            case response
              when Net::HTTPRedirection
                if (HawlerHelper.valid_uri(response['location']))
                  redirect = uri.merge(response['location'])
                  links_to_process << generate_hawlee(redirect, cur_hawlee)
                end
            end
          end
        end
      })

      unless (response.nil?)
        case response
          when Net::HTTPRedirection
          when Net::HTTPSuccess
            do_once(cur_hawlee.uri, cur_hawlee.referer, :harvest, lambda {
              HawlerHelper.harvest(cur_hawlee.uri, response.body).each do |l|
                links_to_process << generate_hawlee(l, cur_hawlee)
              end

              if (@brute)
                HawlerHelper.brute_from_uri(cur_hawlee.uri).each do |b|
                  links_to_process << generate_hawlee(b, cur_hawlee)
                end

                HawlerHelper.brute_from_data(cur_hawlee.uri, response.body) do |b|
                  links_to_process << generate_hawlee(b, cur_hawlee)
                end
              end
            })
          end
      end

      do_once(cur_hawlee.uri, cur_hawlee.referer, :analyze, lambda { @block.call(cur_hawlee.uri, cur_hawlee.referer, response) } )

      break if (@done)
      Kernel.sleep(@sleep) if (@sleep)
    end

  end

  # Print debug messages if so desired
  def print_debug(msg)
    puts msg if (@debug) 
    STDOUT.flush
  end

  # Print verbose messages if so desired
  def print_verbose(msg)
    puts msg if (@verbose) 
    STDOUT.flush
  end

end

