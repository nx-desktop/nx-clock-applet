#
# Regular cron jobs for the nx-clock-applet package
#
0 4	* * *	root	[ -x /usr/bin/nx-clock-applet_maintenance ] && /usr/bin/nx-clock-applet_maintenance
