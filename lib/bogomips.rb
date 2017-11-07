#
#  bogomips.rb
#
#  Copyright (c) 2013 by Daniel Kelley
#
#

def bogomips

  cpuinfo =  "/proc/cpuinfo"

  if File.exists? cpuinfo
    IO.foreach(cpuinfo) do |line|
      if line =~ /^bogomips\s+:\s+(\S+)/
        return $1.to_f
      end
    end
  else
    # default
    1000.0
  end

end
