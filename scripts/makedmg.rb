#!/usr/bin/env ruby

def run(cmd, &block)
  puts "> #{cmd}"
  if block == nil
    abort "** command failed with error" if !system(cmd)
  else
    IO.popen(cmd, &block)
  end
end

def getVersion(productdir)
  File.foreach("#{productdir}/../Versions.txt").each do |line|
    match = /^AppsFlyerAdobeExtension ([0-9.]*)/.match(line)
    return match[1] if match != nil
  end
end    

def makeDMG(productdir, dmgdir, dmgname, volumename)    
  tempdmg = "#{dmgdir}/af-adobe-temp-#{Process.pid}.dmg"
  finaldmg = "#{dmgdir}/#{dmgname}.dmg"
  run("hdiutil create -size 512m #{tempdmg} -layout NONE") 
  disk_id = nil
  run("hdid -nomount #{tempdmg}") { |hdid| disk_id = hdid.readline.split[0] }
  run("newfs_hfs -v '#{volumename}' #{disk_id}")
  run("hdiutil eject #{disk_id}")
  run("hdid #{tempdmg}") { |hdid| disk_id = hdid.readline.split[0] }
  run("cp -R #{productdir}/bin/* '/Volumes/#{volumename}'")
  run("cp -R #{productdir}/../AppsFlyerAdobeExtension/Vendor/* '/Volumes/#{volumename}'")
  run("hdiutil eject #{disk_id}")
  run("rm -f #{finaldmg}")
  run("hdiutil convert -format UDZO #{tempdmg} -o #{finaldmg} -imagekey zlib-level=9")
  run("rm #{tempdmg}")
end    

productdir = ARGV[0]
abort "Error: no product directory specified" if productdir == nil

dmgdir = ARGV[1]
abort "Error: no DMG directory specified" if dmgdir == nil 

version = getVersion "#{productdir}"
abort "Error: cannot determine version" if version == nil

makeDMG productdir, dmgdir, "appsflyeradobeextension-#{version}", "AppsFlyerAdobeExtension #{version}"