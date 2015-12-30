require 'rb-inotify'

require 'pp'

class PkgStat
  def initialize(name)
    @name = name
    @events = []
  end

  def add_event(ev)
    @events += ev
  end

  def complete?
    false
  end

  def send_to(uri)
  end
end

pkg_dir='/usr/portage/packages_'
begin
  pkg_dir = `emerge --info 2> /dev/null | grep PKGDIR`.chomp.gsub('"','').split('=')[1]
rescue
end

pkgs = {}
notifier = INotify::Notifier.new 
notifier.watch(pkg_dir, :all_events, :recursive, :dont_follow) do |ev|
  if ev.name =~ /\.tbz2$/
    pkg = pkgs[ev.name]
    pkg = PkgStat.new(ev.name) unless pkg
    pkgs[ev.name] = pkg
    pkg.add_event ev.flags
    if pkg.complete?
    end

    puts "#{ev.absolute_name}, #{ev.flags}"
    puts 'MOVED TO!' if ev.flags.include? :moved_to
  end
end

Signal.trap(:INT) {
  notifier.stop
  notifier.close
  puts 'Exit ..'
  p pkgs
  exit 0
}

notifier.run
