#
# Regular cron jobs for the nomad-clock-applet package
#
0 4	* * *	root	[ -x /usr/bin/nomad-clock-applet_maintenance ] && /usr/bin/nomad-clock-applet_maintenance
