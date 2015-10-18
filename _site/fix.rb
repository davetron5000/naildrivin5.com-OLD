#!/usr/bin/env ruby

require 'fileutils'

ARGV.each do |filename|
  puts "Fixing #{filename}"
  temp_filename = "/tmp/#{$$}"
  inside_blockquote = false
  in_footnotes = false
  File.open(temp_filename,"w") do |file|
    File.open(filename).readlines.each do |line|
      #if line =~ /\{\% highlight/
      #  puts "Fixing line"
      #  file.puts
      #  file.puts line
      #elsif line =~ /\{\% endhighlight/
      #  puts "Fixing ending line"
      #  file.puts line
      #  file.puts
      if line =~ /\{\% endblockquote/
        puts "Out of blockquote"
        inside_blockquote = false
      elsif line =~ /\{\% blockquote/
        puts "In a blockquote"
        inside_blockquote = true
      elsif inside_blockquote
        file.puts "> #{line}"
      elsif line =~ /\{\% img (.*) \%\}/
        parts = $1.split(/\s/)
        if parts[0]  !~ /^\//
          _align = parts.shift
        end
        url = parts.shift
        if parts[0] =~ /$\d+$/
          _width = parts.shift
        end
        title = parts.join(' ')
        title = "image" if title.strip == ''
        file.puts "![#{title}](#{url})"
      elsif line =~ /^(.*){% fn_ref (\d+) %}(.*)$/
        before = $1
        number = $2
        after = $3
        file.puts "#{before}<a name=\"back-#{number}\"></a><sup><a href=\"##{number}\">#{number}</a></sup>#{after}"
      elsif line =~ /endfootnotes/
        in_footnotes = false
        file.puts "</ol></footer>"
      elsif line =~ /\{\% pullquote/
        file.puts "<div class='has-pullquote'>"
      elsif line =~ /\{\% endpullquote/
        file.puts "</div>"
      elsif line =~ /^(.*)\{\"(.*)\"\}(.*$)/
        file.puts "#{$1} <span class='pullquote'>#{$2}</span> #{$3}"
      elsif in_footnotes
        if line =~ /\{\% fn (.*) \%\}/
          content = $1
          puts "Found footnote #{in_footnotes}: #{content}"
          file.puts "<li>"
          file.puts "<a name='#{in_footnotes}'></a>"
          file.puts "<sup>1</sup>#{content}<a href='#back-1'>↩</a>"
          file.puts "</li>"
          in_footnotes += 1
        else
          raise "Weird.  Line #{line} is inside footnotes, but doesn't match our pattern"
        end
      elsif line =~ /\{\% footnotes/
        in_footnotes = 1
        file.puts "<footer class='footnotes'>"
        file.puts "<ol>"
      else
        file.puts line
      end
    end
  end
  if inside_blockquote
    raise "Something's wrong, still in a blockquote"
  end
  FileUtils.mv temp_filename,filename
end
