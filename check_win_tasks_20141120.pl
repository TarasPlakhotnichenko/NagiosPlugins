#!/usr/bin/perl

#passive checks for windows services which have two batch files - one starts the service , the other stops it.
#Ver.20140129
#example: /usr/local/nagios/libexec/check_win_tasks.pl
#/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
#
#Nagios doesn't allow some symbols in service description... so we  cut 10 first symbols and concanate it with <+more> in service description in  check_tasks hash
#Besides we replace all spaces with underscores in service names to let nagios send correct http link in mails.

#Ver.20140813
#Added  program section for generating nagios configuration file


#Ver.20140815
#Added unconditional check - start and stop batch commands are absent (x and x accodingly)


#Ver.20140819  
#Added SERVICE_NAME so as to name service  in Nagios different  to real service name

#time_shift => '4' - winter time
#time_shift => '3' - summer time

#When stop batch is absent, replace stop field value with x:
#'AstsTW_Teap15018' => {
#'START'    => 'Start AstsTW_Teap15018',
#'STOP'     => 'x',
#},

#kill  `ps -aef | grep check_win_tasks.pl | grep -v grep | awk '{print $2}'`
#/usr/local/nagios/libexec/check_win_tasks.pl
#ssh  support\@10.242.16.13  sc query type= service state= all | grep FixPreTradeJaneStreet
#/usr/local/nagios/libexec/check_nt -H 10.242.16.22 -p 12489 -v SERVICESTATE -d SHOWALL -l "NSClientpp"
#/usr/local/nagios/libexec/check_nt -H 10.240.16.27 -p 12489 -v SERVICESTATE -d SHOWALL -l 'Fix2Micex'
#/usr/local/nagios/libexec/check_nt -H 10.253.4.11 -p 12489 -v SERVICESTATE -d SHOWALL -l 'NSClientpp'


#wmic service where (state="running") get caption
#ssh support@10.242.16.16 'wmic service where (state="running") get caption'
#ssh support@10.242.16.18 'wmic service Q_FixInMD_15163 get PathName'
#wmic service LIST CONFIG



use strict;
#use warnings;

use POSIX qw(setsid);
use LWP::Simple;

# flush the buffer
$| = 1;

# daemonize the program
&daemonize;

my $clock_hour=`/bin/date +%H`;
my $clock_min=`/bin/date +%M`;
chomp ($clock_hour);
chomp ($clock_min);

my $time_current=`/bin/date +%s`;
chomp ($time_current);

my $time_shift=0;
my $clock=0;

my $local_path='/usr/local/nagios/var/tmp/win_tasks';
my $nagios_path='/usr/local/nagios';

my %check_tasks=();   #hash initial definition: ip => start/stop_batch_file => windows_service
my %tasks=();         #hash get time from file for each batch to start: batch_file => start_time
my %service_times=(); #hash: from each check_tasks if batch_file exists in task: windows_service => start and stop times

my $uptodate=0;
my $state=3;

my $windows_services_file = 'windows_services.cfg';


%check_tasks = (

'10.240.16.21' => {
time_shift => '0',

'services' => {

'__FixInReporting' => {
'START'    => 'start FixInReporting (15025)',
'STOP'     => 'STOP FixReporting (15025)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'FixInServiceOMStest' => {
'START'    => 'start FIXINOMS (15060)',
'STOP'     => 'STOP FIXINOMS (15060)',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFix15164' => {
'START'    => 'Start QuikFixMDBackUp (15164)',
'STOP'     => 'Stop QuikFixMDBackUp (15164)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},



'_FixInService73ALL' => {
'START'    => 'Start FIXIN73_ALL (15151)',
'STOP'     => 'Stop FIXIN73_ALL (15151)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'_FixInService73ALL2' => {
'START'    => 'Start FIXIN73_ALL2 (15150)',
'STOP'     => 'Stop FIXIN73_ALL2 (15150)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFix15163' => {
'START'    => 'Start QuikFix15163',
'STOP'     => 'Stop QuikFix15163',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Q_FixInReport_15170' => {
'START'    => 'Start Q_FixInReport_15170',
'STOP'     => 'Stop Q_FixInReport_15170',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'_FixInService73ALL' => {
'START'    => 'Start FIXIN73_ALL (15151)',
'STOP'     => 'Stop FIXIN73_ALL (15151)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},




'FixInServiceFXConv' => {
'START'    => 'Start FIXIn FX Conv (15160)',
'STOP'     => 'Stop FIXIn FX Conv (15160)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFIX_OR_FORTS' => {
'START'    => 'Start QuikFIX_OR_FORTS',
'STOP'     => 'Stop QuikFIX_OR_FORTS',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFix15164' => {
'START'    => 'Start QuikFixMDBackUp (15164)',
'STOP'     => 'Stop QuikFixMDBackUp (15164)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},






},
},

'10.240.16.13' => {

time_shift => '0',
'services' => {

'fix2micexMD18000' => {
'START'    => 'Start Fix2MicexMD18000',
'STOP'     => 'Stop Fix2MicexMD18000',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'Fix2micexMD18003' => {
'START'    => 'Start Fix2MicexMD18003',
'STOP'     => 'Stop Fix2MicexMD18003',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Quik Transaction Gate S' => {
'START'    => 'Start AstsTW_Sec',
'STOP'     => 'Stop AstsTW_Sec',
},


'FxConverter' => {
'START'    => 'Start FXConv',
'STOP'     => 'Stop FXConv',
},

'QuikOSLBackOffServer' => {
'START'    => 'START BO',
'STOP'     => 'STOP BO',
},

'QuikOSLBackOffServerKB' => {
'START'    => 'START BO_KBO',
'STOP'     => 'STOP BO_KBO',
},






},
},

#'10.48.16.69' => {
#time_shift => '0',
#'services' => {

#'__FixInService_MDIn' => {
#'START'    => 'start FIXIN_MDIn (15021)',
#'STOP'     => 'STOP FIXIN_MDIn (15021)',
#},

#'_FixInService_MDInGL' => {
#'START'    => 'Start FixIn_MDGL (15025)',
#'STOP'     => 'Stop FixIn_MDGL (15025)',
#},

#'FixIn_MDORC_15161' => {
#'START'    => 'Start FixIn_MDORC_15161',
#'STOP'     => 'Stop FixIn_MDORC_15161',
#},

#'FixIn_MDORC_15162' => {
#'START'    => 'Start FixIn_MDORC_15162',
#'STOP'     => 'Stop FixIn_MDORC_15162',
#},

#'FixIn_Reporting_Bloom' => {
#'START'    => 'Start QuikFixBloom',
#'STOP'     => 'Stop QuikFixBloom',
#},

#'FixInService02' => {
#'START'    => 'start FIX-02 (15022)',
#'STOP'     => 'stop FIX-02 (15022)',
#},


#'FixInService7ALL' => {
#'START'    => 'Start FIXIN7_ALL (15152)',
#'STOP'     => 'Stop FIXIN7_ALL (15152)',
#},

#'FixInService7ALL2' => {
#'START'    => 'Start FIXIN7_ALL2 (15150)',
#'STOP'     => 'Stop FIXIN7_ALL2 (15150)',
#},


#'QuikFix15163' => {
#'START'    => 'Start QuikFix15163',
#'STOP'     => 'Stop QuikFix15163',
#},

#'QuikTransactionGate' => {
#'START'    => 'Start AstsTW',
#'STOP'     => 'Stop AstsTW',
#},

#'QUIK balancer15100' => {
#'START'    => 'Start Balancer15100',
#'STOP'     => 'STOP Balancer15100',
#},

#'QUIK balancer15500' => {
#'START'    => 'Start Balancer15500',
#'STOP'     => 'Stop Balancer15500',
#},


#'QUIK sub-01' => {
#'START'    => 'Start SUB-01',
#'STOP'     => 'STOP SUB-01',
#},

#'QuikFix15163' => {
#'START'    => 'Start QuikFix15163',
#'STOP'     => 'Stop QuikFix15163',
#},

#'FixIn_Reporting_Bloom' => {
#'START'    => 'Start QuikFixBloom',
#'STOP'     => 'Stop QuikFixBloom',
#},


#},
#},

'172.24.135.163' => {
time_shift => '3',
'services' => {

'MSSQLSERVER' => {
'START'    => 'x',
'STOP'     => 'x',
},

'GL Export' => {
'START'    => '\Start GL Export',
'STOP'     => '\Stop GL Export',
},

'GL Export SETS' => {
'START'    => '\Start GL Export SETS',
'STOP'     => '\Stop GL Export SETS',
},

'GL Export US' => {
'START'    => '\Start GL Export US',
'STOP'     => '\Stop GL Export US',
},




},
},

#Can't escape dollar sign in service name in  nagios 3.3.1
'172.24.135.164' => {
time_shift => '0',
'services' => {

'MSSQLSERVER' => {
'START'    => 'x',
'STOP'     => 'x',
'SERVICE_NAME' => 'MSSQLSERVER',
},


'AMS_FT1' => {
'START'    => '\Front Arena\AMS_FT1 Start',
'STOP'     => '\Front Arena\AMS_FT1 Stop',
},


'XMBA_FT1_INS' => {
'START'    => '\Front Arena\XMBA_FT1_INS Start',
'STOP'     => '\Front Arena\XMBA_FT1_INS Stop',
},

'ADS' => {
'START'    => 'x',
'STOP'     => 'x',
},

'AMB' => {
'START'    => 'x',
'STOP'     => 'x',
},


'AMBA' => {
'START'    => 'x',
'STOP'     => 'x',
},

'AMPH_FT1' => {
'START'    => '\Front Arena\AMPH_FT1 Start',
'STOP'     => '\Front Arena\AMPH_FT1 Stop',
},

'AMS_XTR' => {
'START'    => '\Front Arena\AMS_XTR Start',
'STOP'     => '\Front Arena\AMS_XTR Stop',
},

'XMBA_GT_XTR_INS' => {
'START'    => '\Front Arena\XMBA_GT_XTR_INS Start',
'STOP'     => '\Front Arena\XMBA_GT_XTR_INS Stop',
},

'AMS_GT_LSE' => {
'START'    => '\Front Arena\AMS_GT_LSE Start',
'STOP'     => '\Front Arena\AMS_GT_LSE Stop',
},


},
},



#'172.24.135.164' => {
#time_shift => '3',
#'services' => {

#'SQL Server (SQLTRSY)' => {
#'START'    => 'x',
#'STOP'     => 'x',
#},


#},
#},




'10.230.48.48' => {
time_shift => '3',
'services' => {

'GL Export SETS' => {
'START'    => 'start_gl_export_SETS',
'STOP'     => 'stop_gl_export_SETS',
},

'GL Export BOV' => {
'START'    => 'start_gl_export_BOV',
'STOP'     => 'stop_gl_export_BOV',
},

'GL Export DER' => {
'START'    => 'start_gl_export_der',
'STOP'     => 'stop_gl_export_der',
},

'GL Export' => {
'START'    => 'start_gl_export_NOSETS',
'STOP'     => 'stop_gl_export_SETS',
},

'GL P3_feed,GL P3_cme,GL P3_der,GL P3_or' => {
'START'    => 'At4',
'STOP'     => 'At2',
},

},
},


#'10.48.16.47' => {
#time_shift => '0',
#'services' => {

#'Fix2Micex Service MD_18000' => {
#'START'    => 'Start Fix2MicexMD_18000',
#'STOP'     => 'Stop Fix2MicexMD_18000',
#},

#'Fix2Micex Service MD18001' => {
#'START'    => 'Start Fix2MicexMD_18001',
#'STOP'     => 'Stop Fix2MicexMD_18001',
#},

#'FIXIn86_FORTS93_15164' => {
#'START'    => 'Start FIXIN47_FORTS93_15164',
#'STOP'     => 'Stop FIXIN47_FORTS93_15164',
#},

#'FIXIn86_FORTS93_15165' => {
#'START'    => 'Start FIXIN47_FORTS93_15165',
#'STOP'     => 'Stop FIXIN47_FORTS93_15165',
#},

#'FixInService86ABC' => {
#'START'    => 'Start FIXIN86_ABC',
#'STOP'     => 'Stop FIXIN86_ABC',
#},

#'FixInService86ALL1' => {
#'START'    => 'Start FIXIN86_ALL1',
#'STOP'     => 'Stop FIXIN86_ALL1',
#},

#'FixInService86ALL2' => {
#'START'    => 'Start FIXIN86_ALL2',
#'STOP'     => 'Stop FIXIN86_ALL2',
#},

#'FORTSGATE_ROUTER_86' => {
#'START'    => 'Start Router86',
#'STOP'     => 'Stop Router86',
#},

#'QuikFix86_FORTS77_15153' => {
#'START'    => 'Start FIXIN86_FORTS77_15153',
#'STOP'     => 'Stop FIX86_FORTS77_15153',
#},

#'QuikFix86_FORTS77_15160' => {
#'START'    => 'Start FIX86_FORTS77_15160',
#'STOP'     => 'Stop FIX86_FORTS77_15160',
#},

#'Quik Forts Gate_86' => {
#'START'    => 'Start Forts86',
#'STOP'     => 'Stop Forts86',
#},

#'QuikTransactionGate' => {
#'START'    => 'Start AstsTW',
#'STOP'     => 'Stop AstsTW',
#},

#'FORTSGATE_ROUTER_ST47' => {
#'START'    => 'Start Router ST47',
#'STOP'     => 'Stop Router ST47',
#},

#'FORTSGATE_ROUTER_86' => {
#'START'    => 'Start Router86',
#'STOP'     => 'Stop Router86',
#},

#},
#},


#'10.48.16.17' => {
#time_shift => '0',
#'services' => {

#'Fix2plazaIIMD18000' => {
#'START'    => 'Start Fix2plazaIIMD18000',
#'STOP'     => 'Stop Fix2plazaIIMD18000',
#},

#'Fix2plazaIIMD18001' => {
#'START'    => 'Start Fix2plazaIIMD18001',
#'STOP'     => 'Stop Fix2plazaIIMD18001',
#},

#'FORTSGATE_Router' => {
#'START'    => 'Start Router',
#'STOP'     => 'Stop Router',
#},

#'FORTSGATE_ROUTER_FIX' => {
#'START'    => 'Start Router_Fix2plazaIIMD18000',
#'STOP'     => 'Stop Router_Fix2plazaIIMD18000',
#},

#'QuikFortsGate' => {
#'START'    => 'Start FortsGate',
#'STOP'     => 'Stop FortsGate',
#},


#'QuikFortsGate_ST19' => {
#'START'    => 'Start Forts ST19',
#'STOP'     => 'Stop Router ST19',
#},

#'FORTSGATE_ROUTER_ST19' => {
#'START'    => 'Start Router ST19',
#'STOP'     => 'Stop Router ST19',
#},

#'FORTSGATE_ROUTER_FIX' => {
#'START'    => 'Start Router_Fix2plazaIIMD18000',
#'STOP'     => 'Stop Router_Fix2plazaIIMD18000',
#},

#'QUIKSub-02' => {
#'START'    => 'Start SUB-02',
#'STOP'     => 'Stop SUB-02',
#},


#},
#},


'10.240.16.17' => {
time_shift => '0',
'services' => {

'MSSQLSERVER' => {
'START'    => 'x',
'STOP'     => 'x',
},


},
},





'10.240.16.18' => {
time_shift => '0',
'services' => {

'QuikProxyService15100' => {
'START'    => 'Start Balancer15100',
'STOP'     => 'STOP Balancer15100',
},

'QuikProxyService15200' => {
'START'    => 'Start Balancer15200',
'STOP'     => 'STOP Balancer15200',
},

'QuikProxyService15400' => {
'START'    => 'Start Balancer15400',
'STOP'     => 'STOP Balancer15400',
},

'QuikProxyService15500' => {
'START'    => 'Start Balanser15500',
'STOP'     => 'Stop Balanser15500',
},

'QuikSub-01' => {
'START'    => 'Start SUB-01',
'STOP'     => 'STOP SUB-01',
},

'QuikReportsService' => {
'START'    => 'START ReportsTW',
'STOP'     => 'STOP ReportsTW',
},


},
},



'10.240.16.22' => {
time_shift => '0',
'services' => {

#'GLServiceBOV' => {
#'START'    => 'START GLTW_BOV',
#'STOP'     => 'STOP GLTW_BOV',
#},

'GLServiceCBOT' => {
'START'    => 'START GLTW_CBOT',
'STOP'     => 'STOP GLTW_CBOT',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLServiceCHI_X' => {
'START'    => 'START GLTW_ChiX',
'STOP'     => 'STOP GLTW_ChiX',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLServiceCME' => {
'START'    => 'START GLTW_CME',
'STOP'     => 'STOP GLTW_CME',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLTW_EURONEXT' => {
'START'    => 'START GLTW_EURONEXT_AEX_PEX',
'STOP'     => 'STOP GLTW_EURONEXT',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLServiceTSX' => {
'START'    => 'START GLTW_TSX(Toronto)',
'STOP'     => 'STOP GLTW_TSX(Toronto)',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'QuikAlgoService' => {
'START'    => 'START AlgoTrading',
'STOP'     => 'STOP AlgoTrading',
},

'QuikAlgoServiceOMS' => {
'START'    => 'START OMS',
'STOP'     => 'STOP OMS',
},


'EESGate' => {
'START'    => 'START EESTW',
'STOP'     => 'STOP EESTW',
},



},
},


#'10.48.16.6' => {
#time_shift => '0',
#'services' => {

#'QuikOSLBackOffServer' => {
#'START'    => 'START BO',
#'STOP'     => 'STOP BO',
#},



#'GLServiceHKEX' => {
#'START'    => 'START GLTW_HKEX',
#'STOP'     => 'STOP GLTW_HKEX',
#},

#'GLServiceSAXESS' => {
#'START'    => 'START GLTW_SAXESS',
#'STOP'     => 'STOP GLTW_SAXESS',
#},

#'GLServiceEDX' => {
#'START'    => 'START GLTW_EDX',
#'STOP'     => 'STOP GLTW_EDX',
#},

#'GLServiceCHI_X_DL' => {
#'START'    => 'START GLTW CHI_X_DL',
#'STOP'     => 'STOP GLTW_CHI_X_DL',
#},

#'GLServicePROT' => {
#'START'    => 'START GLTW_LSE_PROT',
#'STOP'     => 'STOP GLTW_LSE_PROT',
#},



#'QuikExporterINT' => {
#'START'    => 'START QuikExportInt',
#'STOP'     => 'STOP QuikExportInt',
#},

#},
#},


#'10.240.16.20' => {
#time_shift => '0',
#'services' => {


#'Quik_Forts_Gate_ST35' => {
#'START'    => 'Start FortsST35',
#'STOP'     => 'Stop FortsST35',
#},


#'Quik_Forts_Gate_STXi' => {
#'START'    => 'Start FortsSTXi',
#'STOP'     => 'Stop FortsSTXi',
#},


#'FORTSGATE_ROUTER_STXI' => {
#'START'    => 'Start Router STXi',
#'STOP'     => 'Stop Router STXi',
#},


#'FORTSGATE_ROUTER_ST73' => {
#'START'    => 'Start Router ST73',
#'STOP'     => 'Stop Router ST73',
#},


#'Quik_Forts_Gate_ST73' => {
#'START'    => 'Start FortsST73',
#'STOP'     => 'Stop FortsST73',
#},


#'FORTSGATE_ROUTER_ST35' => {
#'START'    => 'Start Router ST35',
#'STOP'     => 'Stop Router ST35',
#},



#},
#},


#'10.240.16.16' => {
#time_shift => '0',
#'services' => {

#'FixInService35ALL' => {
#'START'    => 'Start FIXIN35_ALL (15160)',
#'STOP'     => 'Stop FIXIN35_ALL (15160)',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
#},

#'FixInService35ALL2' => {
#'START'    => 'Start FixIn_ALL_2 (15162)',
#'STOP'     => 'Stop FixIn_ALL_2 (15162)',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
#},


#'FixInService35MD' => {
#'START'    => 'Start FIXIN35_MD',
#'STOP'     => 'Stop FIXIN35_MD',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
#},

#'Quik Transaction Gate T' => {
#'START'    => 'Start AstsTW_T',
#'STOP'     => 'Stop AstsTW_T',
#},

#'QuikFix35_FORTS93_15164' => {
#'START'    => 'Start FIXIN35_FORTS93_15164',
#'STOP'     => 'Stop FIXIN35_FORTS93_15164',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
#},

#'QuikServer' => {
#'START'    => 'start QUIKOSL_T-new',
#'STOP'     => 'STOP QUIKOSL_T',
#},

#'_FixInService35FORTS' => {
#'START'    => 'Start FIXIN35_FORTS77',
#'STOP'     => 'Stop FIXIN35_FORTS77',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
#},

#'QuikFIX_OR4_FORTS77_15154' => {
#'START'    => 'Start QuikFIX_OR4_FORTS77_15154',
#'STOP'     => 'Stop QuikFIX_OR4_FORTS77_15154',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
#},


#'_FixInService35ALL' => {
#'START'    => 'Start FIXIN35_ALL (15160)',
#'STOP'     => 'Stop FIXIN35_ALL (15160)',
#},

#'QuikFIX_OR_FORTS' => {
#'START'    => 'Start QuikFIX_OR_FORTS',
#'STOP'     => 'Stop QuikFIX_OR_FORTS',
#},




#},
#},


'10.240.16.23' => {
time_shift => '0',
'services' => {


'QuikBrokerQuoteService' => {
'START'    => 'Start SiceTW',
'STOP'     => 'STOP SiceTW',
},


'QuikBrokerQuoteServiceGL' => {
'START'    => 'Start SiceTW GL',
'STOP'     => 'STOP SiceTW GL',
},


'QuikBrokerQuoteServiceKB' => {
'START'    => 'Start SiceTW_KB',
'STOP'     => 'STOP SiceTW_KB',
},


'GLTW_NASDAQ' => {
'START'    => 'Start GLTW_NASDAQ',
'STOP'     => 'STOP GLTW_NASDAQ',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

#'GLServiceNASDAQ' => {
#'START'    => 'Start GLTW_NASDAQ Intraday',
#'STOP'     => 'STOP GLTW_NASDAQ Intraday',
#},


'GLTW_XETRA_ALGO' => {
'START'    => 'Start GLTW_XETRA_ALGO',
'STOP'     => 'STOP GLTW_XETRA_ALGO',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


'QuikCurrTransactionGate' => {
'START'    => 'Start AstsCurr_MB00583',
'STOP'     => 'STOP AstsCurr',
},

'QuikMultihubFO' => {
'START'    => 'Start MultiHubCurr',
'STOP'     => 'STOP MultiHub',
},


'QuikCurrTransactionGateCL5' => {
'START'    => 'Start AstsCurr_CL5_MD03495',
'STOP'     => 'STOP AstsCurr_CL5',
},

'QuikExportertWest' => {
'START'    => 'Start Export_West',
'STOP'     => 'STOP Export_West',
},


'GLTW_NYSE' => {
'START'    => 'Start GLTW_NYSE',
'STOP'     => 'STOP GLTW_NYSE',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


#'GLServiceNYSE' => {
#'START'    => 'Start GLTW_NYSE Intraday',
#'STOP'     => 'STOP GLTW_NYSE Intraday',
#},


'GLTW_LSE_MD' => {
'START'    => 'Start GLTW_LSE_MD',
'STOP'     => 'STOP GLTW_LSE_MD',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


'InstrService' => {
'START'    => 'Start InstrTW',
'STOP'     => 'Stop InstrTW',
},


'HolidayGate_WEST' => {
'START'    => 'Start HolidayTW',
'STOP'     => 'Stop HolidayTW',
},

'HolidayTW_MICEX_Retail' => {
'START'    => 'Start HolidayTW_MICEX_Retail',
'STOP'     => 'Stop HolidayTW_MICEX_Retail',
},


'HolidayTW_RTS_Retail' => {
'START'    => 'Start HolidayTW_RTS_Retail',
'STOP'     => 'Stop HolidayTW_RTS_Retail',
},


},
},


'10.240.16.19' => {
time_shift => '0',
'services' => {

'GLTW_LSE' => {
'START'    => '\Start GLTW_LSE',
'STOP'     => '\Stop GLTW_LSE',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLTW_LSE_ALGO' => {
'START'    => '\Start GLTW_LSE_ALGO',
'STOP'     => '\Stop GLTW_LSE_ALGO',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLTW_SGX' => {
'START'    => '\Start GLTW_SGX',
'STOP'     => '\Stop GLTW_SGX',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLTW_WSE' => {
'START'    => '\Start GLTW_WSE',
'STOP'     => '\Stop GLTW_WSE',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLServiceXETRA' => {
'START'    => '\Start GLTW_XETRA',
'STOP'     => '\Stop GLTW_XETRA',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

#'GLServiceAMEX' => {
#'START'    => '\Start GLTW_AMEX',
#'STOP'     => '\Stop GLTW_AMEX',
#},


'GLServiceNYSEARCA' => {
'START'    => '\Start NYSE_ARCA',
'STOP'     => '\Stop NYSE_ARCA',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'QuikSub-02' => {
'START'    => '\Start Sub-02',
'STOP'     => '\Stop Sub02',
},
},
},


'10.240.16.27' => {
time_shift => '0',
'services' => {

'Fix2Micex_TI07LTD' => {
'START'    => '\Start Fix2Micex',
'STOP'     => '\Stop Fix2Micex',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'FORTSGATE_ROUTER' => {
'START'    => '\Start FORTSGATE_Router',
'STOP'     => '\Stop FORTSGATE_Router',
},

'Fix2Micex_MD' => {
'START'    => '\Start Fix2Micex_MD',
'STOP'     => '\Stop Fix2Micex_MD',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'Fix2PlzaII' => {
'START'    => '\Start Fix2PlzaII',
'STOP'     => '\Stop Fix2PlzaII',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'FORTSGATE_ROUTER' => {
'START'    => '\Start FORTSGATE_Router',
'STOP'     => '\Stop FORTSGATE_Router',
},

'QuikExporterCalypso' => {
'START'    => '\Start Exporter Calypso',
'STOP'     => '\Stop Exporter Calypso',
},

'QuikMultihub' => {
'START'    => '\Start Multihub_KB',
'STOP'     => '\Stop Multihub_KB',
},


'mdpump_f2m' => {
'START'    => '\Start_mdpump_f2m',
'STOP'     => '\Stop_mdpump_f2m',
},

'mdpump_f2p' => {
'START'    => '\Start_mdpump_f2p',
'STOP'     => '\Stop_mdpump_f2p',
},

'FORTSGATE_ROUTER' => {
'START'    => '\Start FORTSGATE_Router',
'STOP'     => '\Stop FORTSGATE_Router',
},



'Q_Fix2Plaza_MD18000' => {
'START'    => '\Start FIX2Plaza_MD18000',
'STOP'     => '\Stop Fix2Plaza_MD18000',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Q_Fix2Plaza_MD18001' => {
'START'    => '\Start FIX2Plaza_MD18001',
'STOP'     => '\Stop FIX2Plaza_MD18001',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Q_Router_F2P_MD18000' => {
'START'    => '\Start P2Router F2P MD 18000',
'STOP'     => '\Stop P2Router F2P MD 18000',
},


'Q_Router_F2P_MD18001' => {
'START'    => '\Start P2Router F2P MD 18001',
'STOP'     => '\Start P2Router F2P MD 18001',
},


},
},


'10.242.16.22' => {
time_shift => '0',
'services' => {

'Q_ROUTER_UX' => {
'START'    => '\start Ux Router',
'STOP'     => '\stop Ux Router',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFOUXGate' => {
'START'    => '\start UxGate',
'STOP'     => '\stop Ux Gate',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLTW_ChiXM1' => {
'START'    => '\start GLService_ChiX_M1',
'STOP'     => '\stop GLService_ChiX_M1',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


'GLTW_LSE_M1' => {
'START'    => '\start GLService_LSE_M1',
'STOP'     => '\stop GLService_LSE_M1',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


'GLTW_HKEX' => {
'START'    => '\start GLService_HKEX',
'STOP'     => '\stop GLService_HKEX',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLTW_SAXESS' => {
'START'    => '\start GLService_SAXESS',
'STOP'     => '\stop GLService_SAXESS',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


'GLTW_EDX' => {
'START'    => '\start GLService_EDX',
'STOP'     => '\stop GLService_EDX',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


'GLTW_AMEX' => {
'START'    => '\start GLService_AMEX',
'STOP'     => '\stop GLService_AMEX',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'GLTW_XETRA' => {
'START'    => '\start GLService_XETRA',
'STOP'     => '\stop GLService_XETRA',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},


'GLTW_NYSE_ARCA' => {
'START'    => '\start GLService_NYSE_ARCA',
'STOP'     => '\stop GLService_NYSE_ARCA',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'QuikSub-01' => {
'START'    => '\Start Sub-01',
'STOP'     => '\Stop Sub-01',
},


},
},



'10.242.16.17' => {
time_shift => '0',
'services' => {

'QuikSub-03' => {
'START'    => '\Start Sub3',
'STOP'     => '\Stop Sub3',
},

},
},



'10.242.16.28' => {
time_shift => '0',
'services' => {

'QuikProxy15100' => {
'START'    => '',
'STOP'     => '\Stop Balancer 15100',
},

'QuikProxy15500' => {
'START'    => '\Start Balancer 15500 Q2Q',
'STOP'     => '\Stop Balancer 15500 Q2Q',
},

'QuikSub-01' => {
'START'    => '\Start SUB-01',
'STOP'     => '\Stop SUB-01',
},


'MSSQLSERVER' => {
'START'    => 'x',
'STOP'     => 'x',
},


},
},


'10.242.16.23' => {
time_shift => '0',
'services' => {

'QuikProxy15100' => {
'START'    => '\Start Balancer 15100',
'STOP'     => '\Stop Balancer 15100',
},

'QuikProxy15500' => {
'START'    => '\Start Balancer 15500',
'STOP'     => '\Stop Balancer 15500',
},


'QUIKSub-03' => {
'START'    => '\Start Sub3',
'STOP'     => '\Stop Sub3',
},


},
},





'10.230.16.41' => {
time_shift => '0',
'services' => {

'Fix2Micex_CETS' => {
'START'    => '\Start Fix2Cets_ABC',
'STOP'     => '\Stop Fix2Cets_ABC',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'GLServiceLSE' => {
'START'    => '\StartLSE',
'STOP'     => '\Stop_GLTWLSE',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
},

'_FixInService41MD' => {
'START'    => '\Start FIXIN41_MD',
'STOP'     => '\Stop FIXIN41_MD',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'_FixInService_ALL' => {
'START'    => '\Start FixIn_All',
'STOP'     => '\Stop FixIn_All',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikServer' => {
'START'    => '\Start QuikServer',
'STOP'     => '\Stop QuikServer',
},

'Fix2MicexMD1' => {
'START'    => '\Start Fix2MicexMD_ABC',
'STOP'     => '\Stop Fix2MicexMD_ABC',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},



},
},



'10.240.16.14' => {
time_shift => '0',
'services' => {

#'P2ROUTER_FORTSGATE_MN_ALGO' => {
#'START'    => 'start P2Router_FORTSGate_MN_ALGO',
#'STOP'     => 'stop P2Router_FORTSGate_MN_ALGO',
#},


'P2Router_FORTSGate_MN_RETAIL' => {
'START'    => 'start P2Router_FORTSGate_MN_Retail',
'STOP'     => 'stop P2Router_FORTSGate_MN_Retail',
},

#'QuikFortsGate_MN_Algo' => {
#'START'    => 'start QuikFortsGate_MN_Algo',
#'STOP'     => 'stop QuikFortsGate_MN_Algo',
#},


'QuikFortsGate_MN_Retail' => {
'START'    => 'start QuikFortsGate_MN_Retail',
'STOP'     => 'stop QuikFortsGate_MN_Retail',
},


},
},



'172.23.29.50' => {
time_shift => '0',
'services' => {

#'GL Export' => {
#'START'    => 'start_glexport_day',
#'STOP'     => 'stop_glexport_day',
#},

#'GL Export BOV' => {
#'START'    => 'start_BOV_GLEXPORT',
#'STOP'     => 'stop_BOV_GLEXPORT',
#},

#'GL Export US' => {
#'START'    => 'start_glexport_US',
#'STOP'     => 'stop_glexport_US',
#},

#'GL Export Der' => {
#'START'    => 'start_GL_Export_Der',
#'STOP'     => 'stop_GL_Export_Der',
#},

#'GL Export SETS' => {
#'START'    => 'start_SETS_glexport',
#'STOP'     => 'stop_SETS_glexport',
#},


},
},

#'192.168.215.89' => {
#time_shift => '0',
#'services' => {

#'QuikCurrTransactionGate' => {
#'START'    => '\Start AstsCurr',
#'STOP'     => '\Stop AstsCurr',
#},

#'FORTSGATE_Router' => {
#'START'    => '\Start Router',
#'STOP'     => '\Stop Router',
#},


#'QuikServer' => {
#'START'    => '\Start QUIK_MAIN-new',
#'STOP'     => '\Stop Quik',
#},

#'QuikCurrTransactionGate_3495' => {
#'START'    => '\Start AstsCurr_3495',
#'STOP'     => '\Stop AstsCurr_3495',
#},

#'QuikCurrTransactionGate_3518' => {
#'START'    => '\Start AstsCurr_3518',
#'STOP'     => '\Stop AstsCurr_3518',
#},

#'QuikTransactionGateGko' => {
#'START'    => '\Start AstsGKO',
#'STOP'     => '\Stop AstsGKO',
#},

#'QuikTransactionGate' => {
#'START'    => '\Start AstsTW',
#'STOP'     => '\Stop AstsTW',
#},

#'QuikFortsGate' => {
#'START'    => '\Start FortsGate',
#'STOP'     => '\Stop FortsGate',
#},

#},
#},


#'10.48.16.7' => {
#time_shift => '0',
#'services' => {


#'QuikExportertLondon' => {
#'START'    => '\START_QuikExporterLondon',
#'STOP'     => '\STOP_QuikExporterLondon',
#},


#'QuikExportertBrokerMonitor' => {
#'START'    => '\Start QuikExporterBrokerMonitor',
#'STOP'     => '\Stop QuikExporterBrokerMonitor',
#},


#'QuikSub-03' => {
#'START'    => '\StartSub3',
#'STOP'     => '\StopSub3',
#},


#'QuikProxyService' => {
#'START'    => '\Start Balancer Sub-03',
#'STOP'     => '\stop Balancer Sub-03',
#},


#},
#},


'10.240.16.32' => {
time_shift => '0',
'services' => {

#'FORTSGATE_Router' => {
#'START'    => 'Start Router',
#'STOP'     => 'Stop Router',
#},

#'EES Gate_Test' => {
#'START'    => 'Start EESTW TEST',
#'STOP'     => 'Stop EESTW TEST',
#},

'QuikService' => {
'START'    => 'Start Server_QuikTest',
'STOP'     => 'Stop Server_QuikTest',
},


'QuikAdministrator' => {
'START'    => 'Start QAdmin',
'STOP'     => 'Stop QAdmin',
},


#'AstsTW_Teap15018' => {
#'START'    => 'Start AstsTW_Teap15018',
#'STOP'     => 'x',
#},

},
},


'10.240.16.15' => {
time_shift => '0',
'services' => {

'QuikReplicator' => {
'START'    => 'start ReplTW',
'STOP'     => 'STOP ReplTW',
},

'QuikServer' => {
'START'    => 'start QuikServer-new',
'STOP'     => 'STOP QUIK_OSL',
},

},
},


'10.240.16.26' => {
time_shift => '0',
'services' => {

'QuikCurrTransactionGate' => {
'START'    => '\Start AstsCurr',
'STOP'     => '\STOP AstsCurr',
},

'QuikAstsTW' => {
'START'    => '\Start AstsTW',
'STOP'     => '\Stop AstsTW',
},

'EESGate' => {
'START'    => '\Start EEs',
'STOP'     => '\Stop EEs',
},

'Fix2Micex_1' => {
'START'    => '\start FixToMicex',
'STOP'     => '\Stop FixToMicex',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikBrokerQuoteService' => {
'START'    => '\Start BQ',
'STOP'     => '\Stop BQ',
},


'Fix2Plaza_ORUAT' => {
'START'    => '\Start Fix2Plaza ORUAT',
'STOP'     => 'Stop Fix2Plaza ORUAT',
},

'QuikFortsGate' => {
'START'    => '\Start FORTSGATE',
'STOP'     => '\Stop FORTSGATE',
},

'QuikFix2CETS' => {
'START'    => '\Start FIX2Cets ABC',
'STOP'     => '\Stop FIX2Cets ABC',
},


'_FixInServiceFXConv' => {
'START'    => '\Start FXConverter',
'STOP'     => '\Stop FxConverter',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'FixInTest' => {
'START'    => '\Start FixInTest',
'STOP'     => '\Stop FixInTest',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'QuikService' => {
'START'    => '\Start Server Game',
'STOP'     => '\Stop Server Game',
},

'Quik_RTSST_Gate' => {
'START'    => '\Start RTSST Gate',
'STOP'     => '\Stop RTSST Gate',
},


'FixInM1Bridge' => {
'START'    => '\Start FixInM1Bridge',
'STOP'     => '\Stop FixInM1Bridge',
},


'FxConverter' => {
'START'    => '\Start FXConverter',
'STOP'     => '\Stop FxConverter',
},


'FixInORUAT' => {
'START'    => '\Start FixIn 16023 OR UAT',
'STOP'     => '\Stop FixIn 16023 OR UAT',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'FixInMDUAT' => {
'START'    => '\Start FixIn 16024 MD UAT',
'STOP'     => '\Stop FixIn 16024 MD UAT',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Fix2Micex_MDUAT' => {
'START'    => '\Start Fix2Micex MDUAT',
'STOP'     => '\Stop Fix2Micex MDUAT',
},

'Fix2Plaza_MDUAT' => {
'START'    => '\Start Fix2Plaza MDUAT',
'STOP'     => '\Stop Fix2Plaza MDUAT',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


},
},


'10.240.16.31' => {
time_shift => '0',
'services' => {

'QuikSub-04' => {
'START'    => '\Start Sub4',
'STOP'     => '\Stop Sub4',
},

'QuikExportKB2OSL' => {
'START'    => '\Start QuikExporterKB2OSL',
'STOP'     => '\Stop QuikExporterKB2OSL',
},

'MSSQLSERVER' => {
'START'    => 'x',
'STOP'     => 'x',
},


},
},


'10.242.16.21' => {
time_shift => '0',
'services' => {

'Fix2MicexJaneSt18004' => {
'START'    => '\Start Fix2MicexJaneSt18004',
'STOP'     => '\Stop Fix2MicexJaneSt18004',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'QuikFIX_MD1_15161' => {
'START'    => '\Start QuikFIX_MD1_15161',
'STOP'     => '\Stop QuikFIX_MD1_15161',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFIX_MD2_15162' => {
'START'    => '\Start QuikFIX_MD2_15162',
'STOP'     => '\Stop QuikFIX_MD2_15162',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFIX_OR1_15151_All' => {
'START'    => '\Start QuikFIX_OR1_15151_All',
'STOP'     => '\Stop QuikFIX_OR1_15151_All',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFIX_OR2_15152_All' => {
'START'    => '\Start QuikFIX_OR2_15152_All',
'STOP'     => '\Stop QuikFIX_OR2_15152_All',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'QuikFIXDropCopy_15025' => {
'START'    => '\Start QuikFIX_Reporting_15025',
'STOP'     => '\Stop QuikFIX_Reporting_15025',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFIX_OMS_15060' => {
'START'    => '\Start QuikFIX_OMS_15060',
'STOP'     => '\Stop QuikFIX_OMS_15060',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'QuikFIX_OR_FORTS_15155' => {
'START'    => '\Start QuikFIX_OR_FORTS_15155',
'STOP'     => '\Stop QuikFIX_OR_FORTS_15155',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFIX_FXConv_15160' => {
'START'    => '\Start QuikFIX_FXConv_15160',
'STOP'     => '\Stop QuikFIX_FXConv_15160',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},







},
},




'10.240.16.25' => {
time_shift => '0',
'services' => {

'QuikExportert_41' => {
'START'    => '\Start_Export_41',
'STOP'     => '\Stop_Export_41',
},


#'QUIKSub-02' => {
#'START'    => '\Start SUB02',
#'STOP'     => '\Stop SUB02',
#},


'QORTDBServer,QORTExchangeServer,srvAccountsStarter,SrvPositionerStarter,srvReporterStarter,srvRisksStarter,srvTDBStarter' => {
'START'    => '\start_qort',
'STOP'     => '\STOP_QORT',
},



},
},



#'10.48.16.15' => {
#time_shift => '0',
#'services' => {

#'' => {
#'START'    => '',
#'STOP'     => '',
#},

#},
#},

#'10.48.16.16' => {
#time_shift => '0',
#'services' => {

#'srvReporterStarter' => {
#'START'    => 'start_6 srvReporter',
#'STOP'     => 'STOP_ALL_QORT',
#},
#},
#},



'10.240.16.29' => {
time_shift => '0',
'services' => {


'QuikReportExport' => {
'START'    => 'Start_ExportQreport',
'STOP'     => 'Stop_ExportQreport',
},

'MSSQLSERVER' => {
'START'    => 'x',
'STOP'     => 'x',
},

},
},





'10.243.66.22' => {
time_shift => '0',
'services' => {

'QORTDBServer' => {
'START'    => 'start_1 QORTES_DB',
'STOP'     => 'STOP_ALL_QORT',
},

'QORTExchangeServer' => {
'START'    => 'start_2 QORT_SERVER',
'STOP'     => 'STOP_ALL_QORT',
},

'srvAccountsStarter' => {
'START'    => 'start_5 srvAccounts',
'STOP'     => 'STOP_ALL_QORT',
},

'SrvPositionerStarter' => {
'START'    => 'start_3 srvPositioner',
'STOP'     => 'STOP_ALL_QORT',
},

'srvReporterStarter' => {
'START'    => 'start_6 srvReporter',
'STOP'     => 'STOP_ALL_QORT',
},

'srvRisksStarter' => {
'START'    => 'start_4 srvRisks',
'STOP'     => 'STOP_ALL_QORT',
},


'QORTsrvQUIK' => {
'START'    => 'start_7 srvQUIK_1',
'STOP'     => 'STOP_ALL_QORT',
},


'QORTsrvQUIK2' => {
'START'    => 'start_9 srvQUIK_2',
'STOP'     => 'STOP_ALL_QORT',
},

'QORTsrvReporter' => {
'START'    => 'start_6 srvReporter',
'STOP'     => 'STOP_ALL_QORT',
},


},
},


#'192.168.215.106' => {
#time_shift => '0',
#'services' => {

#'' => {
#'START'    => '',
#'STOP'     => '',
#},

#},
#},


'10.242.16.7' => {
time_shift => '0',
'services' => {

'F2M_Tower_18001' => {
'START'    => '\Start F2M TOWER PrTr 18001',
'STOP'     => '\Stop F2M TOWER PrTr 18001',
},

#'FORTS_ROUTER_OSL' => {
#'START'    => '\Start Router Forts OSL FO',
#'STOP'     => '\Stop Router Forts OSL FO',
#},

#'FORTS_ROUTER_OSL_RTSST' => {
#'START'    => '\Start FORTS ROUTER OSL RTSST',
#'STOP'     => '\Stop FORTS ROUTER OSL RTSST',
#},

'F2M_MD_PeLynch_18003' => {
'START'    => '\Start F2M PeLynch 18001 MD',
'STOP'     => '\Stop F2M TOWER PrTr 18001',
},


},
},


#'10.242.16.6' => {
#time_shift => '0',
#'services' => {

#'' => {
#'START'    => '',
#'STOP'     => '',
#},

#},
#},


'10.242.16.15' => {
time_shift => '0',
'services' => {

'QuikService' => {
'START'    => '\Start Server_new',
'STOP'     => '\Stop Server Quik',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
		
},

#'' => {
#'START'    => '\Start QminReplicator',
#'STOP'     => 'x',
#},



},
},


'10.242.16.16' => {
time_shift => '0',
'services' => {

'QuikAstsTWGate' => {
'START'    => '\Start AstsTW',
'STOP'     => '\Stop AstsTW',
},

'QuikServer' => {
'START'    => '\Start SrvQuik',
'STOP'     => '\Stop SrvQuik',
},


'QuikFixInM1ALL1' => {
'START'    => '\Start FIXInM1 All1',
'STOP'     => '\Stop FIXInM1 All1',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'QuikFixInM1ALL2' => {
'START'    => '\Start FIXInM1 All2',
'STOP'     => '\Stop FIXInm1 All2',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'FIXInM1FORTS77_1' => {
'START'    => '\Start FIXInM1Forts77_1',
'STOP'     => '\Stop FIXInM1Forts77_1',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'FIXInM1FORTS77_2' => {
'START'    => '\Start FIXInM1Forts77_2',
'STOP'     => '\Stop FIXInM1Forts77_2',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'QuikFIX_OR5_FORTS93_15155' => {
'START'    => '\Start QuikFIX_OR5_FORTS93_15155',
'STOP'     => '\Stop QuikFIX_OR5_FORTS93_15155',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


},
},


'10.242.16.19' => {
time_shift => '0',
'services' => {

'QuikSub-02' => {
'START'    => '\Start SUB-02',
'STOP'     => '\Stop SUB-02',
},


'QuikExportertBrokerMonitor' => {
'START'    => '\Start QuikExporterBrokerMonitor',
'STOP'     => '\Stop QuikExporterBrokerMonitor',
},


'QuikExpLondon' => {
'START'    => '\START_QuikExporterLondon',
'STOP'     => '\STOP_QuikExporterLondon',
},


'QuikExporterUllink' => {
'START'    => '\Start QuikExporterUlink',
'STOP'     => '\Stop QuikExporterUlink',
},


'QuikExportertActimize' => {
'START'    => '\Start ExporterActimize',
'STOP'     => '\Stop ExporterActimize',
},


'QuikExporterHelpdesk' => {
'START'    => '\Start ExporterHelpDesk',
'STOP'     => '\Stop ExporterHelpDesk',
},

'QuikExporterQReports' => {
'START'    => '\Start QuikQuikExportReport',
'STOP'     => '\Stop QuikReportExport',
},

'QuikExpNomos' => {
'START'    => '\Start Exporter Nomos',
'STOP'     => '\Stop Exporter Nomos',
},

},
},


'10.228.16.24' => {
time_shift => '0',
'services' => {

'Quik_FIX2LSE' => {
'START'    => '\Start FIX2LSE',
'STOP'     => '\Stop FIX2LSE',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'Test_Quik_FIX2LSE' => {
'START'    => '\Start TEST FIX2LSE',
'STOP'     => '\Stop TEST FIX2LSE',
},

#'QuikLSEGate' => {
#'START'    => '\Start LSE',
#'STOP'     => '\Stop LSE',
#},


},
},


'10.228.16.13' => {
time_shift => '0',
'services' => {

'Quik_FIX2LSE' => {
'START'    => '\Start FIX2LSE',
'STOP'     => '\Stop FIX2LSE',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

},
},


'10.242.16.13' => {
time_shift => '0',
'services' => {

'FixPreTradeJaneStreet' => {
'START'    => '\Start FixPreTrade JaneStreet',
'STOP'     => '\Stop FixPreTrade JaneStreet',
},

'Fix2MicexMD18000' => {
'START'    => '\Start Fix2MicexMD18000',
'STOP'     => '\Stop Fix2MicexMD18000',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},

'Fix2MicexMD18005' => {
'START'    => '\Start Fix2MicexMD18005',
'STOP'     => '\Stop Fix2MicexMD18005',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Fix2PlazaMD_18001' => {
'START'    => '\Start FIX2PlazaMD18001',
'STOP'     => '\Stop FIX2PlazaMD18001',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Q_ROUTER_F2P' => {
'START'    => '\Start Router F2P_18003',
'STOP'     => '\Stop Router F2P_18003',
},

'FixPreTradeJaneStreet' => {
'START'    => '\Start FixPreTrade JaneStreet',
'STOP'     => '\Stop FixPreTrade JaneStreet',
},

'FixPreTradeJaneStreet_73' => {
'START'    => '\Start FixPreTrade JaneStreet 73',
'STOP'     => '\Stop FixPreTrade JaneStreet 73',
},


'P2ROUTER_F2PMD18001' => {
'START'    => '\Start Router F2PMD18001',
'STOP'     => '\Stop Router F2PMD18001',
},

'Q_Fix2PlazaII_18003' => {
'START'    => '\Start FIX2Plaza_Reserve_OR_Ullink_18003',
'STOP'     => '\Stop FIX2Plaza_Reserve_OR_Ullink_18003',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'Fix2Micex_OR' => {
'START'    => '\Start FIX2Micex_OR_18100',
'STOP'     => '\Stop FIX2Micex_OR_18100',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},



'Fix2MicexJaneSt18004' => {
'START'    => '\Start Fix2MicexJaneSt18004',
'STOP'     => '\Stop Fix2MicexJaneSt18004',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},


'QuikAstsTW_M1' => {
'START'    => '\Start AstsTW M1',
'STOP'     => '\Stop AstsTW M1',
},

'QuikAstsTW_Xion' => {
'START'    => '\Start AstsTW Xion',
'STOP'     => '\Stop AstsTW Xion',
},

'Q_CROSS_RPS' => {
'START'    => '\Start CrossRPS',
'STOP'     => '\Stop CrossRPS',
},


'QuikSecSettlCode' => {
'START'    => '\Start SecSettl',
'STOP'     => '\Stop SecSettl',
},



},
},


#Îòîøëî ÁÄ
#'10.242.16.14' => {
#time_shift => '0',
#'services' => {

#'QuikFortsGate_ALGO' => {
#'START'    => '\Start FortsGate Algo',
#'STOP'     => '\Stop FortsGate Algo',
#},


#'QuikFortsGate_Retail' => {
#'START'    => '\Start FortsGate Retail',
#'STOP'     => '\Stop FortsGate Retail',
#},

#'P2ROUTER_FORTSGATE_RETAIL' => {
#'START'    => '\Start ROUTER Algo OSL',
#'STOP'     => '\Stop ROUTER Retail OSL',
#},


#'P2ROUTER_FORTSGATE_ALGO' => {
#'START'    => '\Start ROUTER Retail OSL',
#'STOP'     => '\Stop ROUTER Retail OSL',
#},

#'Q_P2R_MN_ALGO' => {
#'START'    => '\Start_ROUTER_ALGO_MN',
#'STOP'     => '\Stop_router_ALGO_MN',
#},

#'Q_P2R_IX_ALGO' => {
#'START'    => '\START_ROUTER_ALGO_IX',
#'STOP'     => '\STOP_ROUTER_IX_ALGO',
#},

#'Q_P2R_MN_RETAIL' => {
#'START'    => '\START_ROUTER_RETAIL_MN',
#'STOP'     => '\STOP_ROUTER_MN_RETAIL',
#},

#'QuikFortsGate_In' => {
#'START'    => '',
#'STOP'     => '\stop_QuikFortsGate_In',
#},

#'QuikFortsGate_MN_Algo' => {
#'START'    => '\Start_ROUTER_ALGO_MN',
#'STOP'     => '\STOP_ROUTER_IX_ALGO',
#},


#'QuikFortsGate_MN_Retail' => {
#'START'    => '\START_ROUTER_RETAIL_MN',
#'STOP'     => '\STOP_ROUTER_MN_RETAIL',
#},


#},
#},










#'10.242.16.18' => {
#time_shift => '0',
#'services' => {

#'GLTW_LSE_ALGO' => {
#'START'    => '\Start GLTW LSE_Algo',
#'STOP'     => '\Stop LSE_Algo',
#'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserGLTW#$HOSTNAME$_$SERVICEDESC$',
#},


#'QuikSub-01' => {
#'START'    => '\Start Sub-01',
#'STOP'     => '\Stop Sub-01',
#},

#},
#},



'10.242.16.20' => {
time_shift => '0',
'services' => {

'Q_ROUTER_RTSST_ALGO' => {
'START'    => '\Start Router RTSST Algo',
'STOP'     => '\Stop Router RTSST Algo',
},

'Q_RTSST_Gate_ALGO' => {
'START'    => '\Start RTSST Gate Algo',
'STOP'     => '\Stop RTSST Gate Algo',
},


'Q_RTSST_Gate_RETAIL' => {
'START'    => '\Start RTSST Gate Retail',
'STOP'     => '\Stop RTSST Gate Retail',
},


'QuikMultihubTW' => {
'START'    => '\Start MultiHub M1',
'STOP'     => '\Stop MultiHub M1',
},


'QuikCurrTransactionGateCL5_M1_MD03495' => {
'START'    => '\Start AstsTW Curr CL5 M1 MD03495',
'STOP'     => '\Stop AstsTW Curr CL5 M1 MD03495',
},


'QuikCurrTransactionGateM1_MB00583' => {
'START'    => '\Start AstsTW Curr_M1_MB00583',
'STOP'     => '\Stop AstsTW Curr_M1_MB00583',
},


'QuikMultihubTW' => {
'START'    => '\Start MultiHub M1',
'STOP'     => '\Stop MultiHub M1',
},


'QuikGate_ICAP' => {
'START'    => '\Start ICAP',
'STOP'     => '\Stop ICAP',
},


'Q_Router_F2P_FAST' => {
'START'    => '\Start P2Router_F2P_FAST',
'STOP'     => '\Stop P2Router_F2P_FAST',
},

'Q_Fix2Plaza_FAST' => {
'START'    => '\Start FIX2PlazaII_FAST',
'STOP'     => '\Stop FIX2PlazaII_FAST',
'ACTION_URL' => 'action_url              http://nagios.otkritie.com/twiki/bin/view/OSL/WinInisParserFIXIN#$HOSTNAME$_$SERVICEDESC$',
},



},
},






#'10.242.16.8' => {
#time_shift => '0',
#'services' => {

#'QuikFixInM1ALL1' => {
#'START'    => '\Start FIXInM1 All1',
#'STOP'     => '\Stop FIXInM1 All1',
#},

#'QuikFixInM1ALL2' => {
#'START'    => '\Start FIXInM1 All2',
#'STOP'     => '\Stop FIXInm1 All2',
#},

#},
#},


'172.23.27.3' => {
time_shift => '0',
'services' => {

'GL Export' => {
'START'    => '\Start GL Export',
'STOP'     => '\Stop GL Export',
},

'GL Export BOV' => {
'START'    => '\Start GL Export BOV',
'STOP'     => '\Stop GL Export BOV',
},

'GL Export US' => {
'START'    => '\Start GL Export US',
'STOP'     => '\Stop GL Export US',
},

'GL Export Der' => {
'START'    => '\Start GL Export der',
'STOP'     => '\Stop GL Export der',
},

'GL Export SETS' => {
'START'    => '\Start GL Export SETS',
'STOP'     => '\Stop GL Export SETS',
},

'GL Export v9 TEST' => {
'START'    => '\Start GL Export TEST',
'STOP'     => '\Stop GL Export TEST',
},

},
},



#-----
);

#Populating windows_services.cfg---------------------------------------------------vvv
open (WINDOWS_SERVICES_FILE, ">/usr/local/nagios/etc/objects/$windows_services_file");
while ( my ($ip, $values) = each(%check_tasks) ) {
  print WINDOWS_SERVICES_FILE "#---$ip------------------------------------------------------------------------------vvv\n\n";
  while ( my   ($instance, $value) = each(%$values) ) {
  if (($instance eq 'services')) {
    while ( my ($key, $value) = each(%$value) ) {
	 print WINDOWS_SERVICES_FILE "define    service{\n";
	 print WINDOWS_SERVICES_FILE "use                     windows-service\n";
     print WINDOWS_SERVICES_FILE "host_name               $ip\n";
	 
	 
	 if ($check_tasks{$ip}{$instance}{$key}{'SERVICE_NAME'}) {
	 print WINDOWS_SERVICES_FILE "service_description     $check_tasks{$ip}{$instance}{$key}{'SERVICE_NAME'}\n";
	 }
	 else
	 {
	 if ($key =~m/^(.*?),/)
	 {
	 my $service_desc = $1;
	 $service_desc =~s/\s+/_/g;
	 print WINDOWS_SERVICES_FILE "service_description     $service_desc\+more\n";
	 }
	 else
	 {
	 my $service_desc = $key;
	 $service_desc =~s/\s+/_/g;
     print WINDOWS_SERVICES_FILE "service_description     $service_desc\n";
	 }
	 }
	 
     print WINDOWS_SERVICES_FILE "servicegroups           Windows_services\n";
	 
	if ($check_tasks{$ip}{$instance}{$key}{'SERVICE_NAME'}) {
	 print WINDOWS_SERVICES_FILE "display_name            $check_tasks{$ip}{$instance}{$key}{'SERVICE_NAME'}\n";
	}
	else
	{
	if ($key =~m/^(.*?),/)
	 {
	 my $service_desc = $1;
	 $service_desc =~s/\s+/_/g;
     print WINDOWS_SERVICES_FILE "display_name            $service_desc\+more\n";	 
	 }
	 else
	 {
	 my $service_desc = $key;
	 $service_desc =~s/\s+/_/g;
     print WINDOWS_SERVICES_FILE "display_name            $service_desc\n";
	 }
	 }
	 
	 
	 
	 
     print WINDOWS_SERVICES_FILE "check_command           check_win_tasks\!0\n";
     print WINDOWS_SERVICES_FILE "check_period            normal\n";
     print WINDOWS_SERVICES_FILE "flap_detection_enabled  0\n";
     print WINDOWS_SERVICES_FILE "active_checks_enabled   0\n";
     print WINDOWS_SERVICES_FILE "notes_url               http://nagios.otkritie.com/twiki/data/OSL/servers/winservers_sysinfo_\$HOSTNAME\$.txt\n";	 
	 if ($check_tasks{$ip}{$instance}{$key}{'ACTION_URL'}) {
     print WINDOWS_SERVICES_FILE "$check_tasks{$ip}{$instance}{$key}{'ACTION_URL'}\n";	 
	 }
	 
	 
	 
	 print WINDOWS_SERVICES_FILE "}\n\n";
    }
  }
  
  }
  print WINDOWS_SERVICES_FILE "#---$ip------------------------------------------------------------------------------^^^\n\n";  
  }

close WINDOWS_SERVICES_FILE;  
  


#Populating windows_services.cfg---------------------------------------------------^^^




#Retrieving tasks from remote windows box-------------------vvv
for my $host ( keys %check_tasks ) {

#testing if file is uptodate-------------------vvv
 if (-e "$local_path/win_services_$host.txt") {
  open (NAG, "<$local_path/win_services_$host.txt");
  $uptodate = (-M NAG);
  #print "$uptodate\n";
  close NAG;
 }
 
 if  ($uptodate > 0.25)
 {
 `rm  $local_path/win_services_$host.txt`;
 }
#testing if file is uptodate-------------------^^^


#get new file----------------------------------vvv
 my $filesize = -s "$local_path/win_services_$host.txt";
 #print "$filesize\n";
 if  (!(-e "$local_path/win_services_$host.txt") or ($filesize == 0))
 {
  open (NAG, ">$local_path/win_services_$host.txt");
  eval
  {
  #$SIG{'ALRM'} = sub { die 'Timeout' };
  $SIG{'ALRM'} = sub { next; };
  alarm(15);
  #print NAG `ssh  support\@$host schtasks /query /FO csv /NH | enca -L ru -x UTF-8`;
  print NAG `ssh  support\@$host schtasks /query /FO csv`;
  alarm(0);
  };
  close (NAG);
 }
#get new file----------------------------------^^^

}
#Retrieving tasks from remote windows box-------------------^^^


for my $host ( keys %check_tasks ) {

if (open(my $IN, '<', "$local_path/win_services_$host.txt")) 
{
my $batch='';
my $time='';
my $str='';

#Loading current tasks to hash------------vvv
while (<$IN>) {
chomp($_);

if (($_=~m/.*(\d+:\d+:\d+).*/i) and !($_=~m/disabled/i))
  {
   $_=~ s/\r//g;
  
   if ($_=~m/^"(.*)","\d+.*/i)
   {
   $batch=$1;
   $batch=~ s/\s+$//g;
   }
   
   #24h format
   if ($_=~m/(\d+:\d+:\d+)/i)
   {
   $time=$1;
   }
   
   if (($_=~m/(\d+:\d+:\d+\s+AM)/i) and ($time=~m/^12+/i))
   {
   my ($h,$m,$s)='';
   ($h,$m,$s)=split/:/,$time;
   $time = "0:$m:$s";
   #print "$host $batch $time\n";
   }
   
   #PM
   if ($_=~m/(\d+:\d+:\d+\s+PM)/i)
   {
   my $tmp=$1;
   my ($h,$m,$s)='';   
     if ($tmp=~m/(\d+:\d+:\d+)/i)
	 {
	  $tmp = $1;
	  ($h,$m,$s)=split/:/,$tmp;
	  $h=$h+12;
	 }
	$time = "$h:$m:$s";
   }
   $tasks{$host}{$batch}=$time;
   #print "$host --- $batch --- $time\n";
  } 
}
close $IN;
#Loading current tasks to hash------------^^^
}
else
{
next;
}
}


#Define start and stop times for each service - populating service_times hash ------------vvv
my ($actual_start_hour,$actual_start_min,$actual_stop_hour,$actual_stop_min)='';

while ( my ($host, $values) = each(%check_tasks) ) {



#----Time shift------------vvv
while ( my ($key, $value) = each(%$values) ) {
if ($key eq 'time_shift')
 {
 $time_shift = $value;
 }
}
#----Time shift------------^^^

while ( my ($key, $values) = each(%$values) ) {
unless ($key eq 'time_shift')
{
#----processes------------------------------------vvv
while ( my ($process, $values) = each(%$values) ) {
#----batches--------------------------------------vvv
while ( my ($key, $value) = each(%$values) ) {

    if ($tasks{$host}{$value}) {
	
    if ($key eq 'START') 
    {
	($actual_start_hour,$actual_start_min)=split/:/,$tasks{$host}{$value};
	$service_times{$host}{$process}{start}=$actual_start_hour*60 + $actual_start_min;
	
    #Start time shift for displaying in  nagios interface--------------vvv
	my $tmp_h=0;
	if (($actual_start_hour+$time_shift) < 24)
	{
	 $tmp_h=$actual_start_hour+$time_shift;
	} elsif (($actual_start_hour+$time_shift) == 24)
	{
	$tmp_h=0;
	}
	else
	{
	 $tmp_h=abs(24-abs($actual_start_hour+$time_shift));
	}
	$service_times{$host}{$process}{start_human}="$tmp_h:$actual_start_min";
	#Start time shift for displaying in  nagios interface---------------^^^
		
    } elsif ($key eq 'STOP')
    {
	($actual_stop_hour,$actual_stop_min)=split/:/,$tasks{$host}{$value};
	$service_times{$host}{$process}{stop}=$actual_stop_hour*60 + $actual_stop_min;
	
	#Stop time shift for displaying in  nagios interface----------------vvv
	my $tmp_h=0;
	if (($actual_stop_hour+$time_shift) < 24)
	{
	 $tmp_h=$actual_stop_hour+$time_shift;
	} elsif (($actual_stop_hour+$time_shift) == 24)
	{
	$tmp_h=0;
	}
	else
	{
	 $tmp_h=abs(24-abs($actual_stop_hour+$time_shift));
	}
	$service_times{$host}{$process}{stop_human}="$tmp_h:$actual_stop_min";
	#Stop time shift for displaying in  nagios interface----------------^^^

    }
	
	
	#print "$host $process $service_times{$host}{$process}{start}\n";
  }
  
  #To handle the case when start or stop batch is absent
  elsif ($value eq 'x')
  {
  if ($key eq 'STOP')
  {
  $service_times{$host}{$process}{stop} = $value;
  }
  
  if ($key eq 'START')
  {
  $service_times{$host}{$process}{start} = $value;
  }
  
  #print "-$host- -$process-  start: $service_times{$host}{$process}{start}  stop: $service_times{$host}{$process}{stop}\n";
  }
  #print "$host $value $process $key $tasks{$host}{$value}  -$service_times{$host}{$process}{start}-  -$service_times{$host}{$process}{stop}-\n";
  
  
  if ($key eq 'SERVICE_NAME')
    {
  	 $service_times{$host}{$process}{service_name}=$value;
  	}
  
}
#----batches--------------------------------------^^^ 
#print  " $host " . " $process " . " start: $service_times{$host}{$process}{start_human} " . " $service_times{$host}{$process}{stop_human} " . "\n"; 

}
#----processes------------------------------------^^^ 
}
}
}
#Define start and stop times for each service - populating service_times hash ------------^^^


sleep 10;

while(1) {

open (CMDFILE, '>>/dev/shm/nagios.cmd'); 
my $check_nt='';
while ( my ($host, $values) = each(%service_times) ) {


#----Time shift for current time------------vvv
while ( my ($host_chk_tsks, $values_host_chk_tsks) = each(%check_tasks) ) {
 if ($host_chk_tsks eq $host) {
 while ( my ($key, $value) = each(%$values_host_chk_tsks) ) {
   if ($key eq 'time_shift')
   {
    $time_shift = $value;
   }
  }
 }
}

$clock_hour=`/bin/date +%H`;
$clock_min=`/bin/date +%M`;
$clock=0;
chomp ($clock_hour);
chomp ($clock_min);

my $time_current=`/bin/date +%s`;
chomp ($time_current);

if (($clock_hour-$time_shift) < 0)
{
$clock_hour=(24-abs($clock_hour-$time_shift));
}
elsif (($clock_hour-$time_shift) == 0)
{
$clock_hour=0;
}
else
{
$clock_hour=($clock_hour-$time_shift);
}
$clock=$clock_hour*60+$clock_min;
#----Time shift for current time------------^^^


my ($start,$stop,$start_human, $stop_human, $value)=0;
my ($start_stop,$service)='';

while ( my ($service, $values) = each(%$values)) {

#print "$host $service $service_times{$host}{$service}{start}  $service_times{$host}{$service}{stop}\n";  

  #Nagios doesn't allow some symbols in service description...----vvv
  my $service2show=$service;
  if ($service2show=~ m/\,/i)
  {
  #$service2show=~s/\,/\+/g;
  #my $tmp=substr $service2show, 0, 10;
  
  $service2show=~m/^(.*?),/;
  
  
  #$service2show = $tmp . "+more";
  $service2show = $1 . "+more";
  
  #print "---- $service2show\n";
  }
  #Nagios doesn't allow some symbols in service description...----^^^
  
  #Replace spaces with underscores in service name----vvv
  if ($service2show=~ m/ /g)
  {
   $service2show=~s/ /\_/g;
  }
  #Replace spaces with underscores in service name----^^^
  
  
  if ($service_times{$host}{$service}{service_name})
  {
  $service2show = $service_times{$host}{$service}{service_name};
  }
  


#The service must have both start and stop times (in case if the batch was disabled)



#if start and stop times are digits?
if (($service_times{$host}{$service}{start} eq $service_times{$host}{$service}{start}+0) and ($service_times{$host}{$service}{stop} eq $service_times{$host}{$service}{stop}+0))
{
#print "$host $service $service_times{$host}{$service}{start}  $service_times{$host}{$service}{stop}\n";  
while (($start_stop, $value) = each(%$values) ) {

 if ($start_stop eq 'start')
 {
 $start= $value;
 }
 elsif ($start_stop eq 'stop')
 {
 $stop= $value;
 }
 elsif ($start_stop eq 'start_human')
 {
 $start_human= $value;
 }
 elsif ($start_stop eq 'stop_human')
 {
 $stop_human= $value;
 }
}


#---Trimming time borders-----------------------------------------------------vvv

#Add minute  to start time to wait a service to settle properly
$start=$start+2;
#print "$start $clock_current $stop\n";

#subtract a minute  from stop time to avoid checks when the service goes down
if (($stop - 3) > 0)
{
$stop=$stop - 3;
} else
{
 #---23*60+59---
 $stop = 1439;
}

#---Trimming time borders-----------------------------------------------------^^^

if ((($start <= $stop) && ($clock <= $stop) && ($clock >= $start)) || (($start >= $stop) && !(($clock >= $stop) && ($clock <= $start))))
 {
  $check_nt='';
  eval
  {
  $SIG{'ALRM'} = sub {  die "time out\n"; };
  alarm(5); 
  $check_nt=`/usr/local/nagios/libexec/check_nt -H $host -p 12489 -v SERVICESTATE -d SHOWALL -l '$service'`;
  alarm(0);
  };
  
  if ($@) {
        die unless $@ eq "time out\n";   # propagate unexpected errors
        $check_nt=' Time out';

    }
  
  
  sleep(0.1);
  chomp($check_nt);
  
  #print "$host $service2show (start: $start_human, stop: $stop_human) $check_nt\n";
     
  if (($check_nt=~m/Started/i) and !($check_nt=~m/Stopped/i))
  {
  #print "$host $service2show (start: $start_human, stop: $stop_human) is running\n";
  $state = 0;
  }
  elsif ($check_nt=~m/Stopped/i)
  {
  #print "$host $service2show (start: $start_human, stop: $stop_human) is stopped\n";
  $state=2;
  }
  else
  {
  #print "$host $service2show (start: $start_human, stop: $stop_human) is  in unknown state\n";
  $state=3;
  }
  
  $check_nt =  "$start_human - start, $stop_human - stop, ($clock_hour:$clock_min)" . $check_nt;
  #print  "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;$state;$check_nt\n";
  print CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;$state;$check_nt\n";
  
 }
 else
 {
  
  $check_nt = "$start_human - start, $stop_human - stop, ($clock_hour:$clock_min). The service is out of schedule time";
  #print  "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;0;$check_nt\n";
  print CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;0;$check_nt\n";
 }
 }
 
 #ToDo: handle the service start when stop batch is absent
 #----------------------We have only start batch-------------------------------------------------------------------------------------------------vvv
 elsif (($service_times{$host}{$service}{start} eq $service_times{$host}{$service}{start}+0) and ($service_times{$host}{$service}{stop} eq 'x'))
 {
 
  #$check_nt='The service is disabled';
  #print CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;0;$check_nt\n";
  #print "$host $service $service_times{$host}{$service}{start}  $service_times{$host}{$service}{stop} \n";
  
  #So far leave the below lines untouched:
  $check_nt='The monitoring  is under dev';
  print CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;0;$check_nt\n";
 }
 #----------------------We have only start batch-------------------------------------------------------------------------------------------------^^^
 
 
 
 
 #--------------------------------------------------------------------------------------------------------------------------------------------------
 #----------------------Unconditional check - we don't have start and stop batch-----------------------------------------------------------------vvv
 elsif (($service_times{$host}{$service}{start} eq 'x') and ($service_times{$host}{$service}{stop} eq 'x'))
 {

 $check_nt='';
  eval
  {
  $SIG{'ALRM'} = sub {  die "time out\n"; };
  alarm(5); 
  $check_nt=`/usr/local/nagios/libexec/check_nt -H $host -p 12489 -v SERVICESTATE -d SHOWALL -l '$service'`;
  alarm(0);
  };
  
  if ($@) {
        die unless $@ eq "time out\n";   # propagate unexpected errors
        $check_nt=' Time out';

    }
  
  
  sleep(0.1);
  chomp($check_nt);
     
  if (($check_nt=~m/Started/i) and !($check_nt=~m/Stopped/i))
  {
  $state = 0;
  }
  elsif ($check_nt=~m/Stopped/i)
  {
  $state=2;
  }
  else
  {
  $state=3;
  }
  
  $check_nt =  "x - start, x - stop, ($clock_hour:$clock_min)" . $check_nt;
  print CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;$state;$check_nt\n";
 }
 #----------------------Unconditional check - we don't have start and stop batch-----------------------------------------------------------------^^^
 #--------------------------------------------------------------------------------------------------------------------------------------------------
 
 
 
 else
 {
  $check_nt='The service is disabled';
  #print  "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;0;$check_nt\n";
  print CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$host;$service2show;0;$check_nt\n";
 }
} 
}
close (CMDFILE);
sleep 120;
}


sub daemonize {
chdir '/' or die "Can’t chdir to /: $!";
open STDIN, '/dev/null' or die "Can’t read /dev/null: $!";
open STDOUT, '>>/dev/null' or die "Can’t write to /dev/null: $!";
open STDERR, '>>/dev/null' or die "Can’t write to /dev/null: $!";
defined(my $pid = fork) or die "Can’t fork: $!";
exit if $pid;
setsid or die "Can’t start a new session: $!";
umask 0;
}
