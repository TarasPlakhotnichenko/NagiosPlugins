#!/usr/bin/perl
#Usage command_line: $USER1$/check_license.pl $HOSTADDRESS$ $ARG0$ $ARG1$ 
#Usage command_line: /usr/local/nagios/libexec/check_license.pl 10.230.48.43 root /var/bridge/conf ulbridge.ini 15
#ver.20120622
use strict;
use warnings;

unless ($#ARGV == 4) { print("usage:\tcheck_license.pl <ip> <user> <remote path> <remote file> <days left>\n"); exit(1);}


my $remote_ip=$ARGV[0];
my $user=$ARGV[1];
my $remote_path=$ARGV[2];
my $remote_file=$ARGV[3];
my $days_left_param=$ARGV[4];
chomp($remote_ip);
chomp($remote_path);
chomp($remote_file);
#chomp($days_left_param);
my $local_path='/usr/local/nagios/var/tmp/check_licence';
my $date_current=`date +%Y%m%d`;

my $range = 2000;
my $random_number = int(rand($range));

chomp($date_current);
my $state='';

eval
{
 $SIG{'ALRM'} = sub { die "Timeout\n"; };
 alarm(8);
`sftp  "$user"\@"$remote_ip":"$remote_path"/"$remote_file"  "$local_path"/"$remote_ip"_"$remote_file"_"$random_number"`;
 alarm(0);
};

#Last attempt---------------vvv
if ($@) {
    die unless $@ eq "Timeout\n";
    sleep 10;	
	eval
    {
    $SIG{'ALRM'} = sub { die "Timeout\n"; };
    alarm(8);
    `sftp  "$user"\@"$remote_ip":"$remote_path"/"$remote_file"  "$local_path"/"$remote_ip"_"$remote_file"_"$random_number"`;
    alarm(0);
    };
	
	if ($@) {
	die unless $@ eq "Timeout\n";
	exit;
	}
   }

#Last attempt---------------^^^



my $file_in="$remote_ip" . "_" . "$remote_file" . "_" . "$random_number";
my $expire_date = get_ini($local_path,$file_in);
#print "$local_path" . '/' . "$file_in";
`rm -f "$local_path"/"$file_in"`;

#2012-07-24 00-00-00
my ($expire_date_y, $expire_date_m, $expire_date_d);
if ($expire_date=~m/^(\d\d\d\d).*/)
{
$expire_date_y=$1;
}

if ($expire_date=~m/^\d\d\d\d-(\d\d).*/)
{
$expire_date_m=$1;
}

if ($expire_date=~m/.*\d\d\d\d-\d\d-(\d\d).*/)
{
$expire_date_d=$1;
}

my $expire_date_ymd="$expire_date_y" . "$expire_date_m" . "$expire_date_d";

my $date_current_stamp=`date +%s -d $date_current`;
my $expire_date_stamp=`date +%s -d $expire_date_ymd`;
my $day_diff=$expire_date_stamp-$date_current_stamp;

my $days_left_calc=$day_diff/60/60/24;


if ($days_left_calc >= 0) {
if ($days_left_calc < $days_left_param)
 {
  print "The licence will expire in $days_left_calc days. Expiring date: $expire_date Path: $remote_path";
  $state = 'CRIT';
 }
 else
 {
  print "Expiring date: $expire_date Path: $remote_path. The licence will expire in $days_left_calc days. ";
  $state = 'OK';
 }
 #else
 #{
 # print "UKNOWN";
 #$state = 'UKNOWN';
 #}
} else
{
 print "Expiring date: $expire_date Path: $remote_path.";
 $state = 'UKNOWN';
}


if ($@) {
    warn "timed out.\n";
} else {

if ($state eq "OK") { exit 0;
} elsif ($state eq "WARN") { exit 1;
} elsif ($state eq "CRIT") { exit 2;
} else { print "UKNOWN"; #unknown!
        exit 3;
}
}


sub get_ini
{
my($path, $file_in) = @_;
  open(IN, '<', "$path/$file_in") or die "can't open $path/$file_in: $!\n";
  my $expire_date='';
  
  while(<IN>)
  {
   if ($_ =~m/^\[Licence\]/i)
   {
    my $CUR_POSITION=tell(IN);
    do  {
	  last if eof(IN); 
	  $_=readline(*IN);
	  
	  if  ($_ =~ m/^ExpireDate/i) {
	  $_ =~ s/^ExpireDate.*=//i;
	  
	  $_ =~ s/^\s+//;
	   chomp($_);
	   $expire_date=$_;
	  }
	  
	  if  ($_ =~ m/^expiration/i) {
	  $_ =~ s/^expiration.*=//i;
	  
	  $_ =~ s/^\s+//;
	   chomp($_);
	   $expire_date=$_;
	  }


	  
	 } until ($_ =~m/^\[.*\]/);
	 seek(IN, $CUR_POSITION, 0);
    }
   }
return $expire_date;
close IN;   
}

