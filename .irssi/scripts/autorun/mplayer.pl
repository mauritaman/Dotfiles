use strict;
#use warnings;
use Irssi qw(command_bind active_win signal_add);

#Thanks to Remco/Khisanth for the help with the flood protection

my ($VERSION, %IRSSI);
$VERSION = '1.01';
%IRSSI = (
    "author"	  => 'culb',
    "contact"	  => 'dat727boi[at]gmail.com or culb[at]mindboggle.us',
    "name"	  => 'MPlayer: now playing',
    "description" => 'Display Mplayers currently playing song',
    "license"	  => 'Include my name and contact info if you use ANY of my ideas',    
);

#Set this to 'mplayer if you dont use the UI or 'gmplayer' if you use the UI. 
#the command will be what you set this too. IE: if set to 'gmplayer' the command will be /gmplayer
#new to version 1.01
my $player = 'mplayer';

#Set this to the channel(s) you want the trigger to work on
no warnings 'qw';
my @c = qw();
use warnings;

#Set this to what you want to trigger the script
my $trigger = '!mplayer';

#Set this for the time to wait before letting the trigger be usable again in SECONDS!
my $time = 5;#<-THIS IS IN SECOND INCREMENTS

sub mplayer_command{
	my ($data, $server, $witem) = @_;
	my ($pid, @media, @files, $play);
	#If not connected to a server, tell the user to connect and halt
	if (!$server || !$server->{connected}) {
		Irssi::print("\002Please connect to a server and then /mplayer in a channel or PM window");
		return;
	}
	#If mplayer is NOT running, warn the user and halt
	if (!`ps -d | grep mplayer`){
		active_win()->print("\002Mplayer is not running");
		return;
	}
	elsif (`ps -d | grep mplayer`){
	if ($witem && ($witem->{type} eq 'CHANNEL' || $witem->{type} eq 'QUERY')){
		$pid = `pidof $player`;
		chomp $pid;
	#If more then one instance of Mplayer is running, warn the user to close all but one and halt
	if($pid =~ /^(\d*)\s/){
		active_win()->print("\002More than one instance of Mplayer is running. Only one instance of Mplayer needs to be running");
		return;
	}
		@files = `lsof -F -p $pid`;	
		@media = grep m/(.*)\.(avi|mpg|mkv|ogg|ogm|wmv|iso|mp4|mpeg|mov|mp3|flv$)/, @files;
		$play = $media[0];
	#If Mplayer isn't running, warn the user and halt
	if($play !~ m/^(.*)\/(.*)\.(avi|mpg|mkv|ogg|ogm|wmv|iso|mp4|mpeg|mov|mp3|flv$)/){
		active_win()->print("Mplayer is running but not playing.");	
		return;
	}
		$play =~ m/^(.*)\/(.*)\.(avi|mpg|mkv|ogg|ogm|wmv|iso|mp4|mpeg|mov|mp3|flv$)/;
		$play = $2. '.' .$3;
#		$play =~ s/\.\w+$//;
	active_win()->command("say np: $play");
	return;
	}
	#If the user is in the status window, warn the user to move to a channel or PM window and halt
	elsif (!$witem && $witem->{type} ne 'CHANNEL' || $witem->{type} ne 'QUERY'){
		active_win()->print("Switch to a channel or PM window to use this command");
		return;
	}
    }
	else{
		return;
	}
}
#Declare the flood protect when the script is loaded and not each time its called. More scalable.
my %lastcommand = ();
sub mplayer_trigger{
		my ($server, $message, $nick, $address, $channel) = @_;
		my ($pid, @media, @files, $play);

	#Lets keep idiots from making us flood :-)
	return if defined $lastcommand{$channel} and (time() - $lastcommand{$channel} < $time);
		$lastcommand{$channel} = time();

	#Check if the channel is one in our list :-)
	if (!!grep {$_ eq "$channel"} @c){
	#If mplayer is NOT running, warn the user and halt
	return if (!`ps -d | grep mplayer` && $message eq $trigger);

	if (`ps -d | grep mplayer` && $message eq $trigger){

		$pid = `pidof $player`;
		chomp $pid;
	#If more then one instance of Mplayer is running, warn the user to close all but one and halt
	if($pid =~ /^(\d*)\s/){
		active_win()->print("\002More than one instance of Mplayer is running. Only one instance of Mplayer needs to be running");
		return;
	}
		@files = `ps aux | grep $pid`;	
		@media = grep m/(.*)\.(avi|mpg|mkv|ogg|ogm|wmv|iso|mp4|mpeg|mov|mp3|flv$)/, @files;
		$play = $media[0];
	#If Mplayer isn't running, warn the user and halt
	return if ($play !~ m/^(.*)\/(.*)\.(avi|mpg|mkv|ogg|ogm|wmv|iso|mp4|mpeg|mov|mp3|flv$)/);

		$play =~ m/^(.*)\/(.*)\.(avi|mpg|mkv|ogg|ogm|wmv|iso|mp4|mpeg|mov|mp3|flv$)/;
		$play = $2;
		$play =~ s/\.\w+$//;
	$server->command("MSG $channel np: $play");
	return;
	}
    }
	else{
		return;
	}
}
active_win()->print("\002Mplayer now playing loaded. Version:$VERSION by $IRSSI{author}");
command_bind("$player", \&mplayer_command);
signal_add('message public', 'mplayer_trigger');
