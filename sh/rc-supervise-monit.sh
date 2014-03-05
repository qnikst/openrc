#!/bin/sh
# Shell wrapper for runscript

# Copyright (c) 2013 Alexander Vershilov <qnikst@gentoo.org>
# Released under the 2-clause BSD license.


# This is glue for Monit based supervision.
#
# Prerequences to use monit based supervision on your system:
#    1. Monit should be running by the supervision of the init
#       you can do it by adding 
#         
#          mo:2345:respawn:/usr/local/bin/monit -Ic /etc/monitrc
#
#       to the /etc/inittab and running:
#
#         telinit q
#
#       with other PID-1 solutions may differ.
#
#       This is needed to get monit be supervised itself.
#    2. Monit should have following settings:
#
#       INCLUDE "/run/openrc-monit/*"
#
#       as this directory is used to store runtime scripts

# We are checking if we have SERVICE file installed
# in this case we are proceeding with current file

supervision_start() {
    start_posts=${start_postss}${start_postss+':'}plugin_monit_start_post;
}

supervision_stop() {
	stop_pres=${stop_postss}${stop_posts+':'}plugin_monit_stop_pre;
}

plugin_monit_start_post() {
	case ${RC_MONIT_TYPE:-$rc_monit_type} in
	'file')
		[ -d /run/openrc-monit/files/ ] || mkdir -p /run/openrc-monit/files
		cp /etc/conf.d/monit-files/${RC_SVCNAME} \
			/run/openrc-monit/files/${RC_SVCNAME}
		monit reload
		#exec monit start ${RC_SVSNAME}
		sleep 1
		monit monitor ${RC_SVCNAME}
		;;
	'native')
		monit monitor ${RC_SVCNAME}
		;;
	*)
		eerror "default configuration option is not implemented yet"
	esac
}

plugin_monit_stop_pre() {
	case ${RC_MONIT_TYPE:-$rc_monit_type} in
	'file')
		monit unmonitor ${RC_SVCNAME}
		rm /run/openrc-monit/files/${RC_SVCNAME}
		monit reload
		;;
	'native')
		monit unmonitor ${RC_SVCNAME}
		;;
	*)
		eerror "default configuration option is not implemented yet"
esac
}

