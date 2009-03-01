# $Id: hawleroptions.rb 27 2009-01-02 07:56:17Z warchild $
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
# Helper class to make tweaking +Hawler+'s various internals a bit easier.
#
# Jon Hart <jhart@spoofed.org>

require 'optparse'
require 'ostruct'

class HawlerOptions 
  attr_reader :options

  o = Struct.new(
                  :brute,
                  :depth,
                  :debug,
                  :force,
                  :headers,
                  :help,
                  :peek,
                  :proxy,
                  :proxyport,
                  :recurse,
                  :sleep,
                  :types,
                  :verbose
                )
  @options = o.new(
                  false,
                  nil,
                  false,
                  false,
                  {'User-Agent' => 'Hawler (http://spoofed.org/files/hawler/)'},
                  nil,
                  false,
                  nil,
                  nil,
                  false,
                  0,
                  %q{text/html, text/xml, application/xml},
                  false
                 )

  def self.parse(args, banner="Usage: #{File.basename $0} [URI] [options]")
    op = OptionParser.new do |op|

      unless (banner.nil?)
        op.banner = banner
      end

      op.on("-b", "Bruteforce URLs (Default: #{@options.brute})") do |o|
        @options.brute = o
      end

      op.on("-d", "Show debug output (SIGUSR2) (Default: #{@options.debug})") do |o|
        @options.debug = o
      end

      op.on("-f", "Force offsite crawling (Default: #{@options.force})") do |o|
        @options.force = o
      end

      op.on_tail("-h", "Show help") do
        puts op
        exit
      end

      op.on("-H [HEADER]", "Append this header to all requests.  May be called multiple times (Default: #{@options.headers.inspect})") do |o|
        if (o =~ /([^:]*):\s+?(.*)/)
          @options.headers[$1] = $2
        else
          @options.headers[o] = ""
        end
      end

      op.on("-p", "\"Peek\" at all URIs (HEAD) (Default: #{@options.peek})") do |o|
        @options.peek = o
      end

      op.on("-P [IP:PORT]", "Proxy IP and port (Default: #{self.nilprint(@options.proxy)}:#{self.nilprint(@options.proxyport)})") do |o|
        @options.proxy, @options.proxyport = o.split(":")
      end

      op.on("-r [=DEPTH]", "Recurse. DEPTH optional (Default: #{@options.recurse}, #{self.nilprint(@options.depth)})") do |o|
        @options.recurse = true
        @options.depth = o.to_i if (o)
      end

      op.on("-s [SLEEP]", "Sleep s seconds between each request (Default: #{@options.sleep})") do |o|
        @options.sleep = o.to_i
      end

      op.on("-t [TYPES]", "Only download, crawl and analyze these types (Default: #{@options.types})" ) do |o|
        @options.types = o.to_i
      end

      op.on("-v", "Run verbosely (SIGUSR1) (Default: #{@options.verbose})") do |o|
        @options.verbose = o
      end
    end 

    @options.help = op.help

    begin
      op.parse!(args)
    rescue OptionParser::InvalidOption => e
#      puts e
#      puts op.help
#      exit(1)
    end
      
    @options
  end

private

  def self.nilprint(o)
    o.nil? ? "nil" : o
  end
end
