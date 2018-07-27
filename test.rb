#!/usr/bin/env ruby

require "curses"
require "pry-byebug"
include Curses

def onsig(sig)
  close_screen
  exit sig
end

def ranf
  rand(32767).to_f / 32767
end

puts "GO"
# main #
for i in %w[HUP INT QUIT TERM]
  if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
    trap(i) {|sig| onsig(sig) }
  end
end

def rand_hex_byte
  format("%x",rand(16))
end
def rand_tag_id
  12.times.map { rand_hex_byte }.join
end

tags = 7.times.map do |idx, memo|
  { id: rand_tag_id }
end

def rescan(tags)
  tags.map do |tag|
    if tag[:rssi]
      tag[:rssi] = tag[:rssi] + 5 - rand(11)
    else
      tag[:rssi] = -rand(100)
    end
    tag
  end
end

Curses.init_screen
Curses.start_color
Curses.use_default_colors
Curses.curs_set(0)

HIGHLIGHT=1
HEADER=2
Curses.init_pair(HIGHLIGHT, COLOR_YELLOW, COLOR_BLACK)
Curses.init_pair(HEADER, COLOR_CYAN, COLOR_BLACK)

win1 = Curses::Window.new(40, 20, 0, 0)

def render_row(s, row, color = nil)
  setpos(row + 1, 0);
  attron(Curses.color_pair(color) | A_NORMAL) if color
  addstr(s)
  attroff(Curses.color_pair(color)) if color
end

def format_header(arr)
  [
    arr[0].ljust(18),
    arr[1].rjust(5)
  ].join
end

def format_row(arr)
  [
    arr[0].rjust(18),
    arr[1].rjust(5)
  ].join
end

while true
  ctr = 0

  tags = rescan(tags)

  render_row(format_header(["TagID", "RSSI"]), 0, HEADER)

  tags.sort_by{ |tag| -tag[:rssi] }.each_with_index do |tag, index|
   # puts line
    # check that there's data in packet_data and that it matches the Fujitsu Regex, since we'll get lots of irrelevant BLE packets
    row_string = format_row([tag[:id].chars.each_slice(2).map(&:join).join(" "), tag[:rssi].to_s])
    (index > 2) ? render_row(row_string, index + 1) : render_row(row_string, index + 1, HIGHLIGHT)
    refresh
  end
  sleep(0.2)

  win1 << "THING"
end

# end of main
