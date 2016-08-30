#!/usr/bin/perl -w
# /usr/local/nagios/libexec/check_bridge_jmx.pl  192.168.215.77 5188 ULBULB_MN77IX44_MSG  com.ullink.ulbridge.sessioninterfaces.plugins:name=ULBULB_MN77IX44_MSG,plugin-type=FIX,type=Plugin  logged 0
#/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
#Add to jvm:  -javaagent:$LIB/jolokia-jvm-1.0.4-agent.jar=port=5108,host=192.168.215.84 \
#Search mbean: /usr/bin/jmx4perl http://192.168.215.77:5188/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#
#Ver. 20120715

use strict;
use warnings;

unless ($#ARGV == 5) { print("usage:\ncheck_bridge_jmx.pl <ip> <port>  <adapter name> <mbean>  <state: disconnect|stopped|logged> <[-]time shift (hours)>\n"); exit(1);}
my $ip = $ARGV[0];
my $port = $ARGV[1];
my $adapter_param = $ARGV[2];
my $mbean = $ARGV[3];
my $state = $ARGV[4];
my $time_shift= $ARGV[5];

my $adapter='';

my $start_human='';
my $stop_human='';

my $status='UNKNOWN';
my $OUTPUT;

my %targets = ();
my %adapter_start_stop = ();
my $ullink_schedule_file='';
my $bridge_schedule_file='';


if ($ip eq '192.168.215.85')
{
$bridge_schedule_file='Bridge_192_168_215_85.txt';

} 
elsif ($ip eq '192.168.215.83')
{
$bridge_schedule_file='Bridge_192_168_215_83.txt';

} 
elsif ($ip eq '192.168.215.84')
{
$bridge_schedule_file='Bridge_192_168_215_84.txt';

}  
elsif ($ip eq '10.230.48.44')
{
$bridge_schedule_file='Bridge_10_230_48_44.txt';
}
elsif ($ip eq '192.168.215.77')
{
$bridge_schedule_file='Bridge_192_168_215_77.txt';
} 
else
{
print "Out of condition\n";
}


#my @mbeans = ();
#my $tmp_str=`/usr/bin/jmx4perl http://192.168.215.84:5108/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'`;
#@mbeans=split('\n', $tmp_str);

#foreach (@mbeans) {
# 	print "$_\n";
#	}


#Getting ullink adapters schedule------------------------vvv
$bridge_schedule_file="/var/www/html/twiki/data/OSL/" . "$bridge_schedule_file";
open(IN, "$bridge_schedule_file") or die "can't open $bridge_schedule_file: $!\n";
while(my $line = <IN>)
{
if (($line=~m/\s+\d+:\d+\s+.*|\s+\d+:\d+/i))
  {
   
   if($line =~/^\|\s+!(\w+)\s+\|/i)
   {
   $adapter=$1;
   }
   
   my @tmp = split('\|', $line);
   
   #start time string---vvv
   $tmp[8]=~s/^\s+//;
   $tmp[8]=~s/\s+$//;
   #start time string---^^^
   
   #stop time string---vvv
   $tmp[9]=~s/^\s+//;
   $tmp[9]=~s/\s+$//;
   #stop time string---^^^
   
   my $start_str='';
   if($tmp[8] =~/^(\d+:\d+)/i) {$start_str=$1;}
   
   my $stop_str='';
   if($tmp[9] =~/^(\d+:\d+)/i) {$stop_str=$1;}
  
   if (($start_str) and ($stop_str)) {
   $adapter_start_stop{$adapter}{start}=$start_str;
   $adapter_start_stop{$adapter}{stop}=$stop_str;
   }
   if ($adapter eq $adapter_param) {last;}
  }  
}
close(IN);

#while ( my ($key, $value) = each(%adapter_start_stop) ) {
#print "Adapter: $key => Start: $adapter_start_stop{$key}{start}, Stop:  $adapter_start_stop{$key}{stop}\n";
#}
#Getting ullink adapters schedule------------------------^^^


#convert current hour and minutes into minutes--vvv
my $clock_hour=`/bin/date +%H`;
chomp($clock_hour);
my $clock_min=`/bin/date +%M`;
chomp($clock_min);
#convert current hour and minutes into minutes--^^^

if (($clock_hour-$time_shift) < 0)
	{
    $clock_hour=(24-abs($clock_hour-$time_shift));
	} elsif (($clock_hour-$time_shift) == 0)
	{
	 $clock_hour=0;
	} else
   {
    $clock_hour=$clock_hour-$time_shift;
	}


my $clock_current=$clock_hour*60+$clock_min;
#print "$clock_hour:$clock_min\n";


while ( my ($key, $value) = each(%adapter_start_stop) ) {
if ($key eq $adapter_param) {
my ($start_hour,$start_min)=split/:/,$adapter_start_stop{$key}{start};
my ($stop_hour,$stop_min)=split/:/,$adapter_start_stop{$key}{stop};

#Time shift for displaying in  nagios interface------------------vvv
my $tmp_h=0;
if (($start_hour+$time_shift) < 24)
	{
	 $tmp_h=$start_hour+$time_shift;
	} elsif (($start_hour+$time_shift) == 24)
	{
	 $tmp_h=0;
	} else
   {
    $tmp_h=abs(24-abs($start_hour+$time_shift));
	}
	$start_human="$tmp_h:$start_min";

if (($stop_hour+$time_shift) < 24)
	{
	 $tmp_h=$stop_hour+$time_shift;
	} elsif (($stop_hour+$time_shift) == 24)
	{
	 $tmp_h=0;
	}  else
   {
    $tmp_h=abs(24-abs($stop_hour+$time_shift));
	}
	$stop_human="$tmp_h:$stop_min";	
#Time shift for displaying in  nagios interface------------------^^^


my $start=$start_hour*60+$start_min;
my $stop=$stop_hour*60+$stop_min;

#print "$start_hour:$start_min - $stop_hour:$stop_min\n";

#Add minute  to start time to wait an adapter to be logged properly
$start=$start+60;

if ((($start <= $stop) && ($clock_current <= $stop) && ($clock_current >= $start)) || (($start >= $stop) && ($clock_current <= $stop) && ($clock_current >= $start)) || (($start >= $stop) && ($clock_current <= $stop) && ($clock_current <= $start))  || (($start >= $stop) && ($clock_current >= $stop) && ($clock_current >= $start)))
# || (($start >= $stop) && ($clock_current >= $stop) && ($clock_current >= $start))
{
     $OUTPUT='---';
     eval
     {
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(4);
     #$OUTPUT=`/opt/twiddle-standalone/bin/twiddle.sh --host=$ip --port=$port get \'$mbean\' State`;
	 
	 $OUTPUT=`/usr/bin/jmx4perl http://$ip:$port/jolokia  read  \'$mbean\' State`;
	 alarm(0);
     };
	 
     chomp($OUTPUT);
	 
	 if ($OUTPUT) {
	  if ($OUTPUT=~/$state/i)
	  {
	  $status='OK';
	  } 
	  else
	  {
	  $status='CRIT';
	  }
	 }
	 else
	 {
	  $OUTPUT = 'can not get info: host is unreachable or bridge is down';
	  $status='UNKNOWN';
	 }
	 print "$OUTPUT" . ".  Scheduled: start: $start_human, stop: $stop_human\n";
	 
} else

#out of scheduled time----------------------------------vvv
{
  $status='OK';
  print "The service is out of bridge scheduled time: start: $start_human, stop: $stop_human\n";
}
#out of scheduled time----------------------------------^^^
last;
}
}


#print "$status\n";
if ($@) {
    warn "timed out.\n";
} else {

if ($status eq "OK") {  exit 0;
} elsif ($status eq "WARN") { exit 1;
} elsif ($status eq "CRIT") { exit 2;
} else { #unknown!
        exit 3;
}
}
