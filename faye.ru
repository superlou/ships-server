require 'faye'
bayeux = Faye::RackAdapter.new(mount: '/faye', timeout: 25)
run bayeux

# check out foreman gem http://blog.daviddollar.org/2011/05/06/introducing-foreman.html
