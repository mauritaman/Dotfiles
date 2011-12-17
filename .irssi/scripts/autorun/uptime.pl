###1: Type /sysuptime to show yourself your systems uptime in the current window you are in
###2: Type /sysuptime-win to msg the window you are in. If it's a channel you will let everyone in the channel know.
###If it's a private message, that person will know.

###This script works/tested on FreeBSD, OpenBSD and Linux and SHOULD work on NetBSD.
###If this script does not work on netBSD please email me letting me know what errors that you get

use Irssi;
#use strict;
#use warnings;
our ($VERSION, %IRSSI);

$VERSION = "1.00";
%IRSSI = (
     "author"      => 'culb',
     "contact"     => 'dat727boi[at]gmail.com or culb[at]mindboggle.us',
     "name"        => '!uptime trigger',
     "description" => '!uptime channel trigger so others can see your uptime - /sysuptime print to Irssi your uptime - /sysuptime-win message the current window your uptime',
     "license"     => 'Include my name and contact info if you use ANY of my ideas',
     "changed"     => '2009'
);

Irssi::active_win()->print(qq{Uptime script $VERSION. By: $IRSSI{"author"}
Please consult the script for instructions.});

###Turn channel trigger on or off. 0 = off and 1 = on
###Set the channel the !uptime trigger will work in
our $triguptime = '1';
our $chan = '#r00m';

sub message_public {
        my ($server, $msg, $nick, $addr, $channel) = @_;
 	if (($msg eq "!uptime") and ($channel eq "$chan") and ($triguptime eq '1')) {
		my $display = &uptime_ALL;
		chomp $display;
###Even though this isnt needed, I like seeing the users !uptime message before my response and not vica versa
		Irssi::signal_continue($server, $msg, $nick, $addr, $channel);
##############################################################################################################
		$server->command("msg $channel $display");
	return;
	}
	else {return;}
}

sub sysuptime {
	my ($data, $server, $witem) = @_;
		my $channel = $witem->{name};
		my $display = &uptime_ALL;
		chomp $display;
		Irssi::active_win()->print("$display");
		return;
}

sub sysuptime_win {
	my ($data, $server, $witem) = @_;
	if ($witem->{type} eq "CHANNEL" || $witem->{type} eq "QUERY"){
	        my $channel = $witem->{name};
		my $display = &uptime_ALL;
		chomp $display;
		$server->command ("msg $channel $display\n");
		return;
	}
	else{
		Irssi::active_win()->print("\002Please switch to a channel or query window to display.");
		return;
	}
}

sub uptime_ALL{
                my($day, $days, $hour, $hours, $minute, $minutes, $second, $seconds, $uptime, $sec, $time);
	if (($^O eq 'openbsd') or ($^O eq 'netbsd')){
		$sec = `/sbin/sysctl -n kern.boottime`;
        	chomp($sec);
        	$sec 	  =~ s/,//g;
        	$uptime   = `date +%s`; chomp($uptime);
        	$time = $uptime - $sec;
	}
	if ($^O eq 'freebsd'){
        	$sec = `sysctl -n kern.boottime | awk '{print \$4}'`;
        	chomp($sec);
        	$sec 	  =~ s/,//g;
        	$uptime   = `date +%s`; chomp($uptime);
        	$time = $uptime - $sec;
	}
 	if ($^O eq 'linux') {
		my @uptime = `cat /proc/uptime`;
		my @up  = split(/ /, $uptime[0]);
		$time  = $up[0];
	}
        	$time 	  = sprintf("%2d", $time);
        	$day      = int($time / 86400);
        	$time 	  %= 86400;
        	$hour     = int($time / 3600);
        	$time 	  %= 3600;
        	$minute   = int($time / 60);
                $time    %= 60;
                $second   = int($time);

        if ($day == 1){$days = "day"} elsif (($day > 1) or ($day == 0)) {$days = "days";}
        if ($hour == 1){$hours = "hour"} elsif (($hour > 1) or ($hour == 0)) {$hours = "hours";}
        if ($minute == 1){$minutes = "minute"} elsif (($minute > 1) or ($minute == 0)) {$minutes = "minutes";}
        if ($second == 1){$seconds = "second"} elsif (($second > 1) or ($second == 0)) {$seconds = "seconds";}

                my $display = 'System Uptime: ';
		$display .= "$day" . "$days" if defined $day and $day >= '1';
		$display .= ", " if defined $day and $day >= '1' and defined $hour and $hour >= '1'; 
		$display .= "$hour" . "$hours" if defined $hour and $hour >= '1';
		$display .= ", " if defined $hour and $hour >= '1' and defined $minute and $minute >= '1';
		$display .= "$minute" . "$minutes" if defined $minute and $minute >= '1';
		$display .= ", " if defined $minute and $minute >= '1' and defined $second and $second >= '1';
		$display .= "$second" . "$seconds" if defined $second and $second >= '1';
	return ("$display");
}

Irssi::command_bind('sysuptime', 'sysuptime');
Irssi::command_bind('sysuptime-win', 'sysuptime_win');
Irssi::signal_add('message public', 'message_public');