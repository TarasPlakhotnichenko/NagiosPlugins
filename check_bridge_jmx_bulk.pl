#!/usr/bin/perl -w

#/usr/local/nagios/libexec/check_bridge_jmx_bulk.pl  10.240.16.8 5186 0 flow
#/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
#Add to jvm:  -javaagent:$LIB/jolokia-jvm-1.0.4-agent.jar=port=5190,host=10.240.16.10 \
#Search mbean: /usr/bin/jmx4perl http://10.240.16.5:5188/jolokia  search 'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.230.48.44:5188/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'

#/usr/bin/jmx4perl http://10.242.16.8:5186/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.230.48.43:5188/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=ULBULB_IX43M1_MSG,type=Plugin  State

#/usr/bin/jmx4perl http://10.230.16.11:5188/jolokia  search 'com.ullink.ulbridge.sessioninterfaces.modules:*'

#
#Ver. 20141005
#Auto generating nagios config file - ullink_adapaters.cfg

#/usr/bin/jmx4perl http://ip:port/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_Algo1,plugin-type=FIX,type=Plugin  State

#kill  `ps -aef | grep check_bridge_jmx_bulk.pl | grep -v grep | awk '{print $2}'`
#/usr/local/nagios/libexec/check_bridge_jmx_bulk.pl

use JMX::Jmx4Perl;
use JMX::Jmx4Perl::Request;
use strict;
use warnings;
no strict 'refs';

use POSIX qw(setsid);
use LWP::Simple;
use Time::Local;



# flush the buffer
$| = 1;

&daemonize;

my $adapter='';
my %adapter_start_stop = ();
my @requests=();
my @responses=();

my $start_human='';
my $stop_human='';

my $state=3;
my $OUTPUT;

my $time_shift=0;
my $ullink_adapters='';
my $ullink_adapters_file='ullink_adapters.cfg';


my %all_tasks = (
'10.240.16.11' => {
time_shift => '3',
	
'5188' => {
bridge_type => 'bridge',
file => 'Bridge_10_240_16_11.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv
  
'com.ullink.ulbridge.sessioninterfaces.plugins:name=DictionarySQLImport,type=Plugin' =>  {
request => '',
position => '',
name => 'DictionarySQLImport',
service_name => '',
service_unconditional_check => '1',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=FileExport_1,type=Plugin' =>  {
request => '',
position => '',
name => 'FileExport_1',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=JDBCExport,type=Plugin' =>  {
request => '',
position => '',
name => 'JDBCExport',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=JDBCExport2,type=Plugin' =>  {
request => '',
position => '',
name => 'JDBCExport2',
service_name => '',
},

  
'com.ullink.ulbridge.sessioninterfaces.plugins:name=FO_CHIX_MN,type=Plugin' =>  {
request => '',
position => '',
name => 'FO_CHIX_MN',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QFE_35_NEW,type=Plugin' =>  {
request => '',
position => '',
name => 'QFE_35_NEW',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QFE_73_NEW,type=Plugin' =>  {
request => '',
position => '',
name => 'QFE_73_NEW',
service_name => '',
},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_IX44,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'ULB_MSG_IX44',
#service_name => '',
#},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_LSE_COL,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_LSE_COL',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_LD4,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_LD4',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_IX5,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_IX5',
service_name => '',
},




'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_PLT,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_PLT',
service_name => '',
},

#Mbean list to be monitored-------------------------------------------------------------^^^
}
},



'10.240.16.8' => {
time_shift => '3',

'5186' => {
bridge_type => 'flow',
file => 'Flow_10_240_16_8.txt',


#/usr/bin/jmx4perl http://10.240.16.8:5186/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.240.16.8:5186/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=BP_FLOWTRADERS_04,plugin-type=FIX,type=Plugin State
	
#Mbean list to be monitored-------------------------------------------------------------vvv


  
'com.ullink.ulbridge.sessioninterfaces.plugins:name=ORC_01,plugin-type=FIX,type=Plugin' => {
request => '',
position => '',
name => 'ORC_01',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=BP_FLOWTRADERS_04,plugin-type=FIX,type=Plugin' => {
request => '',
position => '',
name => 'BP_FLOWTRADERS_04',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=BP_FLOWTRADERS_01,plugin-type=FIX,type=Plugin' => {
request => '',
position => '',
name => 'BP_FLOWTRADERS_01',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=BP_FLOWTRADERS_02,plugin-type=FIX,type=Plugin' => {
request => '',
position => '',
name => 'BP_FLOWTRADERS_02',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=BP_FLOWTRADERS_03,plugin-type=FIX,type=Plugin' => {
request => '',
position => '',
name => 'BP_FLOWTRADERS_03',
service_name => '',
},




#'com.ullink.ulbridge.sessioninterfaces.plugins:name=FXFINPRO_01,plugin-type=FIX,type=Plugin' => {
#request => '',
#position => '',
#name => 'FXFINPRO_01',
#service_name => '',
#},




#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},


'10.242.16.10' => {
time_shift => '3',
	
'5111' => {
bridge_type => 'bridge',
file => 'Bridge_10_242_16_10.txt',

#/usr/bin/jmx4perl http://10.242.16.10:5111/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'	
#/usr/bin/jmx4perl http://10.242.16.10:5111/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg,plugin-type=FIX,*'
#/usr/bin/jmx4perl http://10.242.16.10:5111/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg,plugin-type=FIX,type=ConfigurationPlugin  State
#/usr/bin/jmx4perl http://10.242.16.10:5111/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=PELynch_SS,plugin-type=FIX,type=Plugin  State
#Mbean list to be monitored-------------------------------------------------------------vvv



'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_MN10,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_MN10',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_FX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_FX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_FixIn,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_FixIn',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_F2P,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_F2P',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_OMS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_OMS',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=PELynch_BS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PELynch_BS',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=PELynch_SS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PELynch_SS',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Fidessa,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Fidessa',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_LD4,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Cucumber_LD4',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg_UAT,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bloomberg_UAT',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_LD4_UAT,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_LD4_UAT',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_LSEDEV,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_LSEDEV',
service_name => '',
},


#'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_M1_6,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'B2B_M1_6',
#service_name => '',
#},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_MN10,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_MN10',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=FORTS_FIX_NEW,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'FORTS_FIX_NEW',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Webb_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Webb_Orders',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_Reporting,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_Reporting',
service_name => '',
},




#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},



'10.242.16.6' => {
time_shift => '3',
	
'5180' => {
bridge_type => 'bridge',
file => 'Bridge_10_242_16_6.txt',


#/usr/bin/jmx4perl http://10.242.16.6:5180/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.242.16.6:5180/jolokia  read  com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg_VCON,plugin-type=FIX,type=Plugin State
	
#Mbean list to be monitored-------------------------------------------------------------vvv

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_Reporting,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_Reporting',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=RK_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'RK_01',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=RN_FIX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'RN_FIX',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg_CMF,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bloomberg_CMF',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=JDBCExport_BridgeActivity,type=Plugin' =>  {
request => '',
position => '',
name => 'JDBCExport_BridgeActivity',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Neovest_DC,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Neovest_DC',
service_name => '',
},



#'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg_Quotes,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'Bloomberg_Quotes',
#service_name => '',
#},





'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg_VCON,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bloomberg_VCON',
service_name => '',
},


#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},


'10.234.16.6' => {
time_shift => '3',
	
'5199' => {
bridge_type => 'bridge',
file => 'Bridge_10_234_16_6.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv
#/usr/bin/jmx4perl http://10.234.16.6:5199/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.234.16.6:5199/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_M1_5,plugin-type=FIX,type=Plugin  State

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_M1_5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_M1_5',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_M1_UAT,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_M1_UAT',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_IX_5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_IX_5',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=OMSDealer,type=Plugin' =>  {
request => '',
position => '',
name => 'OMSDealer',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=OMSSales,type=Plugin' =>  {
request => '',
position => '',
name => 'OMSSales',
service_name => '',
},











#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},


#'10.242.16.10' => {
#time_shift => '0',
	
#'5186' => {
#bridge_type => 'flow',
#file => 'Flow_10_242_16_10.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=PUMPER_ALL_1,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'PUMPER_ALL_1',
#service_name => '',
#},


#Mbean list to be monitored-------------------------------------------------------------^^^
	
#}
#},

'10.240.16.6' => {
time_shift => '0',
	
'5188' => {
bridge_type => 'bridge',
file => 'Bridge_10_240_16_6.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULBULB_MNPERIX_SS,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'ULBULB_MNPERIX_SS',
#service_name => '',
#},

#Mbean list to be monitored-------------------------------------------------------------^^^
	
},

'5184' => {
bridge_type => 'flow',
file => 'Flow_192_168_215_83.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=DictionarySQLImport,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'DictionarySQLImport',
#service_name => 'DictionarySQLImport_flow',
#},

#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},



'10.240.16.10' => {
time_shift => '0',
	
'5188' => {
bridge_type => 'bridge',
file => 'Bridge_10_240_16_10.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv

#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},


'10.242.16.5' => {
time_shift => '3',
	
'5190' => {
bridge_type => 'bridge',
file => 'Bridge_M1_10_242_16_5.txt',

#/usr/bin/jmx4perl http://10.242.16.5:5190/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.242.16.5:5190/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_M1,plugin-type=FIX,type=Plugin  State

#Mbean list to be monitored-------------------------------------------------------------vvv

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_INTX44,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'B2B_INTX44',
#service_name => '',
#},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_IX,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'Cucumber_IX',
#service_name => '',
#},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_M1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Cucumber_M1',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=FORTS_FIX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'FORTS_FIX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Jane_Street_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Jane_Street_Orders',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Kerdos_Dropcopy,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Kerdos_Dropcopy',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=ORC_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ORC_Orders',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_INTX5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_INTX5',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_LD4_6,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_LD4_6',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_OMS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_OMS',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_MN77,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_MN77',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF77_Algo1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF77_Algo1',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_F2P,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_F2P',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_Retail1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_Retail1',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_Retail2,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_Retail2',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_COLO_4,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_COLO_4',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF77_Algo1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF77_Algo1',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF93_Algo1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF93_Algo1',
service_name => '',
},




'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_Algo1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_Algo1',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_All_Retail,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_All_Retail',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=FORTS_FIX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'FORTS_FIX',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=PE_Lynch_BS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PE_Lynch_BS',
service_name => '',
#service_unconditional_check => '1',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=PE_Lynch_SS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PE_Lynch_SS',
service_name => '',
service_unconditional_check => '1',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_Reporting,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_Reporting',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=SLE_FIX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'SLE_FIX',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_IX_5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Cucumber_IX_5',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_IX_5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Cucumber_IX_5',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_M1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Cucumber_M1',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_M16,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_M16',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_FX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_FX',
service_name => '',
},








#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},



'10.242.16.8' => {
time_shift => '3',
	
'5186' => {
bridge_type => 'bridge',
file => 'Flow_M1_10_242_16_8.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv
#/usr/bin/jmx4perl http://10.242.16.8:5186/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.242.16.8:5186/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=OPTION_01,plugin-type=FIX,type=Plugin State

'com.ullink.ulbridge.sessioninterfaces.plugins:name=KERDOS_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'KERDOS_01',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=OPTION_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'OPTION_01',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=PRBB_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PRBB_01',
service_name => '',
},



#Mbean list to be monitored-------------------------------------------------------------^^^
	
},

'5187' => {
bridge_type => 'flow',
file => 'Flow_2_10_242_16_8.txt',

#/usr/bin/jmx4perl http://10.242.16.8:5187/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=PUMPER_MCMN,plugin-type=FIX,type=Plugin  State	
#/usr/bin/jmx4perl http://10.242.16.8:5187/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'

#Mbean list to be monitored-------------------------------------------------------------vvv


'com.ullink.ulbridge.sessioninterfaces.plugins:name=PUMPER_MCMN,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PUMPER_MCMN',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ORC_02,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ORC_02',
service_name => '',
},


#Mbean list to be monitored-------------------------------------------------------------^^^
	
},

'5185' => {
bridge_type => 'flow',
file => 'Flow_3_10_242_16_8.txt',

#/usr/bin/jmx4perl http://10.242.16.8:5185/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=PUMPER_MCMN,plugin-type=FIX,type=Plugin  State	
#/usr/bin/jmx4perl http://10.242.16.8:5185/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'

#Mbean list to be monitored-------------------------------------------------------------vvv

'com.ullink.ulbridge.sessioninterfaces.plugins:name=UNIVER_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'UNIVER_01',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=KBFC_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'KBFC_01',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=THIRDROME_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'THIRDROME_01',
service_name => '',
},



#Mbean list to be monitored-------------------------------------------------------------^^^
	
},

},


'10.242.16.9' => {
time_shift => '3',
	
'5187' => {
bridge_type => 'bridge',
file => 'Bridge_10_242_16_9.txt',

#/usr/bin/jmx4perl http://10.242.16.9:5187/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=DictionarySQLImport,type=Plugin  State	
#/usr/bin/jmx4perl http://10.242.16.9:5187/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#Mbean list to be monitored-------------------------------------------------------------vvv

'com.ullink.ulbridge.sessioninterfaces.plugins:name=EXANTE_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'EXANTE_01',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=VIPUNIVERSAL_01,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'VIPUNIVERSAL_01',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=VIPUNIVERSAL_02,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'VIPUNIVERSAL_02',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=VIPUNIVERSAL_03,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'VIPUNIVERSAL_03',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=VIPUNIVERSAL_03,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'VIPUNIVERSAL_03',
service_name => '',
},



#'com.ullink.ulbridge.sessioninterfaces.plugins:name=DictionarySQLImport,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'DictionarySQLImport',
#service_name => '',
#},

#Mbean list to be monitored-------------------------------------------------------------^^^
	
},

},



'10.230.16.11' => {
time_shift => '3',
	
'5188' => {
bridge_type => 'bridge',
file => 'Bridge_10_230_16_11.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv
#/usr/bin/jmx4perl http://10.230.16.11:5188/jolokia  search 'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.230.16.11:5188/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=DictionarySQLImport,type=Plugin  State

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_IX44,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'ULB_MSG_IX44',
#service_name => '',
#},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=EDASales,type=Plugin' =>  {
request => '',
position => '',
name => 'EDASales',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_IX5,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_IX5',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_LD4,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_LD4',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_LSECOLO_4,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_LSECOLO_4',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULB_MSG_PLT_5,type=Plugin' =>  {
request => '',
position => '',
name => 'ULB_MSG_PLT_5',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=FileExport_1,type=Plugin' =>  {
request => '',
position => '',
name => 'FileExport_1',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=JDBCExport,type=Plugin' =>  {
request => '',
position => '',
name => 'JDBCExport',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=JDBCExport2,type=Plugin' =>  {
request => '',
position => '',
name => 'JDBCExport2',
service_name => '',
},


#Mbean list to be monitored-------------------------------------------------------------^^^
},

'5186' => {
bridge_type => 'bridge2',
file => 'Bridge_lse_10_230_16_11.txt',

#/usr/bin/jmx4perl http://10.230.16.11:5186/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=PUMPER_MCMN,plugin-type=FIX,type=Plugin  State	
#/usr/bin/jmx4perl http://10.230.16.11:5186/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'

#Mbean list to be monitored-------------------------------------------------------------vvv

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_PLT,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_PLT',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=ABC_Orders_1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ABC_Orders_1',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ABC_Orders_2,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ABC_Orders_2',
service_name => '',
},

#Mbean list to be monitored-------------------------------------------------------------^^^
	
},


},



'10.230.16.5' => {
time_shift => '3',
	
'5122' => {
bridge_type => 'bridge',
file => 'Bridge_10_230_16_5.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv
#/usr/bin/jmx4perl http://10.230.16.5:5122/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.230.16.5:5122/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_REP,plugin-type=FIX,type=Plugin  State

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_IX46,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'B2B_IX46',
#service_name => '',
#},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_M15,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_M15',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_MC5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_MC5',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg_FUT,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bloomberg_FUT',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bluefintrading_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bluefintrading_Orders',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bluefintrading_Drop_Copy,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bluefintrading_Drop_Copy',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=CQG_PROD,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'CQG_PROD',
service_name => '',
service_unconditional_check => '1',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Charles_River_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Charles_River_Orders',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_CME,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_CME',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=GSA_Drop_Copy,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GSA_Drop_Copy',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Goldenberg_Drop_Copy,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Goldenberg_Drop_Copy',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Kyte_Drop_Copy,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Kyte_Drop_Copy',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Realtick_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Realtick_Orders',
service_name => '',
},





'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_REP,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_REP',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_IX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Cucumber_IX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Exante_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Exante_Orders',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Jane_Street_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Jane_Street_Orders',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Charles_River_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Charles_River_Orders',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bluefintrading_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bluefintrading_Orders',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=CAC_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'CAC_Orders',
service_name => '',
},




'com.ullink.ulbridge.sessioninterfaces.plugins:name=ABC_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ABC_Orders',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ABC_Orders_2,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ABC_Orders_2',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=ABC_Orders_3,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ABC_Orders_3',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Goldenberg_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Goldenberg_Orders',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Fidessa,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Fidessa',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_INTX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_INTX',
service_name => '',
},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_M1,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'B2B_REP_M1',
#service_name => '',
#},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_MC,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'B2B_REP_MC',
#service_name => '',
#},


#'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_ULPLT,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'B2B_REP_ULPLT',
#service_name => '',
#},


#'com.ullink.ulbridge.sessioninterfaces.plugins:name=Reuters,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'Reuters',
#service_name => '',
#},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=FileExport,type=Plugin' =>  {
request => '',
position => '',
name => 'FileExport',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_LD4_6,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_LD4_6',
service_name => '',
},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=Kyte_Drop_Copy_2,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'Kyte_Drop_Copy_2',
#service_name => '',
#},



#Mbean list to be monitored-------------------------------------------------------------^^^
}
},






'10.234.16.5' => {
time_shift => '3',
	
'5190' => {
bridge_type => 'bridge',
file => 'Bridge_10_234_16_5.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv
#/usr/bin/jmx4perl http://10.234.16.5:5190/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.234.16.5:5190/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=CITI,plugin-type=FIX,type=Plugin  State

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_MCMN,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_MCMN',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_HESE,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_HESE',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_AEX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_AEX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_PEX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_PEX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_SAX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_SAX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_M1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_M1',
service_name => '',
},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=BATS,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'BATS',
#service_name => '',
#},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_INTX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_INTX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_TSX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_TSX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_CSE,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_CSE',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_OSLO,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_OSLO',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_HKEX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_HKEX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_SGX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_SGX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_XETRA,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_XETRA',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_XETRA_2,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_XETRA_2',
service_name => '',
},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_XETRA_RESERVE,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'GLTW_XETRA_RESERVE',
#service_name => '',
#},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=KCG,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'KCG',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=KCG_ALGO,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'KCG_ALGO',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_CHIX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_CHIX',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=CHIX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'CHIX',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=CITI,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'CITI',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=FileExport,type=Plugin' =>  {
request => '',
position => '',
name => 'FileExport',
service_name => '',
},




#'com.ullink.ulbridge.sessioninterfaces.plugins:name=BATS,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'BATS',
#service_name => '',
#service_unconditional_check => '1',
#},




#Mbean list to be monitored-------------------------------------------------------------^^^
}
},




'10.240.16.5' => {
time_shift => '3',
	
'5188' => {
bridge_type => 'bridge',
file => 'Bridge_10_240_16_5.txt',


#/usr/bin/jmx4perl http://10.240.16.5:5188/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg,plugin-type=FIX,type=Plugin  State
#/usr/bin/jmx4perl http://10.240.16.5:5188/jolokia  search  'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg,plugin-type=FIX,*'
#/usr/bin/jmx4perl http://10.240.16.5:5188/jolokia  search 'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#Mbean list to be monitored-------------------------------------------------------------vvv


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Bloomberg,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Bloomberg',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=Cucumber_for_all,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Cucumber_for_all',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=EDASales,type=Plugin' =>  {
request => '',
position => '',
name => 'EDASales',
service_name => '',
},

#'com.ullink.ulbridge.sessioninterfaces.plugins:name=Flowtraders_Orders,plugin-type=FIX,type=Plugin' =>  {
#request => '',
#position => '',
#name => 'Flowtraders_Orders',
#service_name => '',
#},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Flowtraders_Orders_00,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Flowtraders_Orders_00',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Flowtraders_Orders_02,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Flowtraders_Orders_02',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Flowtraders_Orders_03,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Flowtraders_Orders_03',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=ITG_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ITG_Orders',
service_name => '',
},




'com.ullink.ulbridge.sessioninterfaces.plugins:name=JDBCExport,type=Plugin' =>  {
request => '',
position => '',
name => 'JDBCExport',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=ORC_Orders1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ORC_Orders1',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF77_M1_Algo,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF77_M1_Algo',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULBULB_IX5_MSG,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ULBULB_IX5_MSG',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULBULB_MN77M1_MSG,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ULBULB_MN77M1_MSG',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=ULBULB_M1_REP,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'ULBULB_M1_REP',
service_name => '',
},




'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_All_Retail,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_All_Retail',
service_name => '',
},
  

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_75,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_75',
service_name => '',
},  

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_M1_Retail,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_M1_Retail',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_FX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_FX',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=TickTS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'TickTS',
service_name => '',
},

 
'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_F2P,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_F2P',
service_name => '',
},
 
 
'com.ullink.ulbridge.sessioninterfaces.plugins:name=QF_75,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'QF_75',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=PE_Lynch_Test_BS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PE_Lynch_Test_BS',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=PE_Lynch_Test_SS,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'PE_Lynch_Test_SS',
service_name => '',
},


#Mbean list to be monitored-------------------------------------------------------------^^^
	
}
},



'10.228.16.6' => {
time_shift => '3',
	
'5190' => {
bridge_type => 'bridge',
file => 'Bridge_10_228_16_6.txt',


#/usr/bin/jmx4perl http://10.228.16.6:5190/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=Trading_GW,type=Plugin  State		
#/usr/bin/jmx4perl http://10.228.16.6:5190/jolokia  search 'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#Mbean list to be monitored-------------------------------------------------------------vvv

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_M1_5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_M1_5',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Q_FIX2LSE,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Q_FIX2LSE',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_ALGO,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_ALGO',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=DC_IX46,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'DC_IX46',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=DC_DL225,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'DC_DL225',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=DC_MN85,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'DC_MN85',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_7,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_7',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_73,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_73',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=FileExport,type=Plugin' =>  {
request => '',
position => '',
name => 'FileExport',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=AKBF_Orders,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'AKBF_Orders',
service_name => '',
},






#Mbean list to be monitored-------------------------------------------------------------^^^
}
},





'10.228.16.5' => {
time_shift => '3',
	
'5199' => {
bridge_type => 'bridge',
file => 'Bridge_10_228_16_5.txt',
	
#Mbean list to be monitored-------------------------------------------------------------vvv
#/usr/bin/jmx4perl http://10.228.16.5:5199/jolokia  search 'com.ullink.ulbridge.sessioninterfaces.plugins:type=Plugin,*'
#/usr/bin/jmx4perl http://10.228.16.5:5199/jolokia  read com.ullink.ulbridge.sessioninterfaces.plugins:name=Arbitragis_Orders_IX_5,plugin-type=FIX,type=Plugin  State

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_LD4,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_LD4',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=Arbitragis_Orders_IX_5,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'Arbitragis_Orders_IX_5',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_INTX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_INTX',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_MCMN,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_MCMN',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_M1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_M1',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_MCMN,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_MCMN',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_Algo,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_Algo',
service_name => '',
},



'com.ullink.ulbridge.sessioninterfaces.plugins:name=B2B_REP_INTX,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'B2B_REP_INTX',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_Retail_M1,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_Retail_M1',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=GLTW_Retail_MCMN,plugin-type=FIX,type=Plugin' =>  {
request => '',
position => '',
name => 'GLTW_Retail_MCMN',
service_name => '',
},


'com.ullink.ulbridge.sessioninterfaces.plugins:name=FileExport,type=Plugin' =>  {
request => '',
position => '',
name => 'FileExport',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=TradingGW_ABC,type=Plugin' =>  {
request => '',
position => '',
name => 'TradingGW_ABC',
service_name => '',
},

'com.ullink.ulbridge.sessioninterfaces.plugins:name=TradingGW_Arbitragis,type=Plugin' =>  {
request => '',
position => '',
name => 'TradingGW_Arbitragis',
service_name => '',
},




#Mbean list to be monitored-------------------------------------------------------------^^^
}
},

 
);

#Populating ullink_adapters.cfg---------------------------------------------------vvv
open (ULLINK_ADAPTERS_FILE, ">/usr/local/nagios/etc/objects/$ullink_adapters_file");

  print ULLINK_ADAPTERS_FILE "define servicegroup {\n";
  print ULLINK_ADAPTERS_FILE "servicegroup_name       ullink_adapters\n";
  print ULLINK_ADAPTERS_FILE "alias                   ullink adapters\n";  
  print ULLINK_ADAPTERS_FILE "}\n\n";  


while ( my ($ip, $values) = each(%all_tasks) ) {
  print ULLINK_ADAPTERS_FILE "#---$ip------------------------------------------------------------------------------vvv\n\n";  
  
while ( my   ($instance, $value) = each(%$values) ) {
  if (($instance=~m/^\d+/i)) {
  
  #print ULLINK_ADAPTERS_FILE "iii\n";
  
  while ( my ($key, $value) = each(%$value) ) {
  unless (($key eq 'bridge_type') or ($key eq 'file')) {
  print ULLINK_ADAPTERS_FILE "define	 service{\n";
  print ULLINK_ADAPTERS_FILE "	use                      ullink\n";
  print ULLINK_ADAPTERS_FILE "	host_name                $ip\n";
  print ULLINK_ADAPTERS_FILE "	servicegroups            ullink_adapters\n";
  unless ($all_tasks{$ip}{$instance}{$key}{'service_name'}) 
  {
  print ULLINK_ADAPTERS_FILE "	service_description      $all_tasks{$ip}{$instance}{$key}{'name'}\n";
  }
  else
  {
  print ULLINK_ADAPTERS_FILE "	service_description      $all_tasks{$ip}{$instance}{$key}{'service_name'}\n";
  }
  print ULLINK_ADAPTERS_FILE "	check_command            check_bridge_jmx_bulk!5190!0\n";
  print ULLINK_ADAPTERS_FILE "	check_period             normal\n";
  print ULLINK_ADAPTERS_FILE "	flap_detection_enabled   0\n";  
  print ULLINK_ADAPTERS_FILE "	active_checks_enabled    0\n";
  print ULLINK_ADAPTERS_FILE "	passive_checks_enabled   1\n";  
  
  my $topic_file = $all_tasks{$ip}{$instance}{file};
  $topic_file =~ s/\.[^.]+$//;
  print ULLINK_ADAPTERS_FILE "	notes_url                http://nagios.otkritie.com/twiki/bin/view/OSL/$topic_file\n";
  print ULLINK_ADAPTERS_FILE "}\n";
  }
  }
 }
}
print ULLINK_ADAPTERS_FILE "#---$ip------------------------------------------------------------------------------^^^\n\n";
}
close ULLINK_ADAPTERS_FILE;

#Populating ullink_adapters.cfg---------------------------------------------------^^^


#Getting ullink adapters schedule into %adapter_start_stop------------------------vvv
while ( my ($ip, $values) = each(%all_tasks) ) {
while ( my   ($instance, $value) = each(%$values) ) {
unless ($instance eq 'time_shift')
{
#print "$all_tasks{$ip}{$instance}{file}\n";

my $bridge_schedule_file="/var/www/html/twiki/data/OSL/" . "$all_tasks{$ip}{$instance}{file}";
if (open(IN, "$bridge_schedule_file")) {
while(my $line = <IN>)
{

if (($line=~m/\s+\d+:\d+\s+.*|\s+\d+:\d+/i))
  {
   
   #if adapter name doesn't include links
   #if($line =~/^\|\s+!(\w+)\s+\|/i)
   
   if($line =~/^\|\s+\[\[\w+\#\w+\]\[(\w+)\]\]/i)
   {
   $adapter=$1;
   $adapter=~s/^\s+//;
   $adapter=~s/\s+$//;
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
   
   #start reset time string---vvv
   #$tmp[10]=~s/^\s+//;
   #$tmp[10]=~s/\s+$//;
   #start reset time string---^^^
   
   my $start_str='';
   if($tmp[8] =~/^(\d+:\d+)/i) {$start_str=$1;}
   
   my $stop_str='';
   if($tmp[9] =~/^(\d+:\d+)/i) {$stop_str=$1;}
  
   if ($start_str) {
   $adapter_start_stop{$ip}{$instance}{$adapter}{start}=$start_str;
   #print "$ip start - $adapter $start_str";
   }
   
   
   if ($stop_str) {
   $adapter_start_stop{$ip}{$instance}{$adapter}{stop}=$stop_str;
   #print "$ip stop - $adapter $stop_str\n";
   }
   
   
  }
  #elsif
  #{
  #print "$line\n";
  #print "$ip start - $adapter";
  #print "$ip stop - $adapter\n";
  #}
    
}
close(IN);
}
else
{
next;
}



#while ( my ($ip, $values) = each(%adapter_start_stop) ) {
#while ( my   ($adapter, $value) = each(%$values) ) {
#print "Adapter: $ip => Start: $adapter_start_stop{$ip}{$instance}{$adapter}{start}, Stop:  $adapter_start_stop{$ip}{$instance}{$adapter}{stop}\n";
#}
#}



}
}
}
#Getting ullink adapters schedule into %adapter_start_stop------------------------^^^

#Endless loop---------------------------------------------------------------------vvv
while (1)
{

#Main cycle-----------------------------------------------------------------------vvv
while ( my ($ip, $values) = each(%all_tasks) ) {

#Getting time_shift------vvv
while ( my   ($instance, $value) =  each(%$values) ) {
 if ($instance eq 'time_shift')
 {
 $time_shift = $value;
 }
}
#Getting time_shift------^^^

while ( my   ($instance, $value) =  each(%$values) ) {

unless ($instance eq 'time_shift')
{

#Bulk requests--------------------------------------------------------------------vvv
#print "ip: $ip, port: $instance,  mbean reference: $value\n";
my $jmx = new JMX::Jmx4Perl(url => "http://$ip:$instance/jolokia");
   @requests=();
   @responses=();
   while ( my ($key, $value) = each(%$value) ) {
   unless (($key eq 'bridge_type') or ($key eq 'file'))
   {
   
   #prepairing request-----------------------------------------------------------vvv
   my $request = new JMX::Jmx4Perl::Request(READ,"$key",'State');
   $all_tasks{$ip}{$instance}{$key}{'request'}=$request;
   my $pos = push(@requests,$request);
   $pos--;
   $all_tasks{$ip}{$instance}{$key}{'position'}=$pos;
   #prepairing request-----------------------------------------------------------^^^
   }
   }
   

   #executing request------------------------------------------------------------vvv
   if (@requests) {
   eval
   {
   $SIG{'ALRM'} = sub { die "time out\n"; };
   alarm(5);
   @responses = $jmx->request(@requests);
   alarm(0);
   };
   
   if ($@) {
        die unless $@ eq "time out\n";   # propagate unexpected errors
        #print "timeout\n";
        #next;
    }
    
   }
   #executing request------------------------------------------------------------^^^   
   
   #jmx responses to corresponding adapter in hash-------------------------------vvv
   my $i=0;
   for ($i=0; $i <= $#requests; $i++) {
   #-----------------------------vvv
   foreach my $key (keys %$value) {
   unless (($key eq 'bridge_type') or ($key eq 'file')) {
    #print "$ip $responses[$i]\n";
    if (($all_tasks{$ip}{$instance}{$key}{'position'} eq $i) and ($responses[$i]))
    {
	 
	 my $adapter_name=$all_tasks{$ip}{$instance}{$key}{'name'};
	 $adapter_start_stop{$ip}{$instance}{$adapter_name}{state} = $responses[$i]->value();
	 
    }
	elsif (!$responses[$i])
	{
	#print "$ip $key  " .    "\n";
    my $adapter_name=$all_tasks{$ip}{$instance}{$key}{'name'};
	$adapter_start_stop{$ip}{$instance}{$adapter_name}{state} = 'time out';
	}
   }
   } 
   #-----------------------------^^^
   }
  
   #jmx responses to corresponding adapter in hash-------------------------------^^^
   
#Bulk requests--------------------------------------------------------------------^^^


#=============Times===============================================================vvv

#my ($clock_min,$clock_hour)=(localtime)[1,2];

my $shift_seconds=60*60*$time_shift;
my $time_current=time();
my $clock_current=$time_current-$shift_seconds;

my ($sec,$clock_min,$clock_hour,$day,$month,$year)=0;
my $day0=0;
($sec,$clock_min,$clock_hour,$day0,$month,$year)=localtime($time_current);

($sec,$clock_min,$clock_hour,$day,$month,$year)=0;
($sec,$clock_min,$clock_hour,$day,$month,$year)=localtime($clock_current);
my $new_day=$day0 - $day;


if ($new_day > 0)
{

$clock_current=$clock_current+86400;
}



#=============Times===============================================================^^^


#=============Nagios==============================================================vvv
my $CMDFILE;
open ($CMDFILE, '>>/dev/shm/nagios.cmd');

foreach my $key (keys %$value) {
unless (($key eq 'bridge_type') or ($key eq 'file')) {

#---Nagios service can have different name compared to  bridge adapter name----vvv
my $adapter_name=$all_tasks{$ip}{$instance}{$key}{'name'};
my $service_name='';
if ($all_tasks{$ip}{$instance}{$key}{'service_name'})
  {
   $service_name=$all_tasks{$ip}{$instance}{$key}{'service_name'};
  }
 else
 {
  $service_name=$adapter_name;
 }
#---Nagios service can have different name compared to  bridge adapter name----^^^ 

#print "$ip $adapter_name $adapter_start_stop{$ip}{$instance}{$adapter_name}{start}\n";

if (($adapter_start_stop{$ip}{$instance}{$adapter_name}{start}) && ($adapter_start_stop{$ip}{$instance}{$adapter_name}{stop}))
{
my ($start_hour,$start_min)=split/:/,$adapter_start_stop{$ip}{$instance}{$adapter_name}{start};
my ($stop_hour,$stop_min)=split/:/,$adapter_start_stop{$ip}{$instance}{$adapter_name}{stop};


my $start= timelocal(0,$start_min,$start_hour,(localtime)[3,4,5]);
my $stop= timelocal(0,$stop_min,$stop_hour,(localtime)[3,4,5]);
$start_human="$start_hour:$start_min";
$stop_human="$stop_hour:$stop_min";

#---Trimming time borders-----------------------------------------------------vvv
$stop=$stop-120;
$start=$start+120;
#---Trimming time borders-----------------------------------------------------^^^

#23:30 - start, 22:05 - stop, (14:35:shift:3). The service is out of bridge scheduled time 
if (($start > $stop) && ($clock_current < $stop))
{
$start=$start-86400;
} elsif (($start > $stop) &&  ($clock_current > $stop))
{
$stop=$stop+86400;
}


$OUTPUT='---';
#print "$ip $service_name: $start $clock_current $stop\n";
if (($clock_current < $stop) && ($clock_current > $start))
{
 process_check_result($CMDFILE,$ip,$adapter_start_stop{$ip}{$instance}{$adapter_name}{state},$service_name,$start_human,$stop_human,$clock_hour,$clock_min,$time_current,$time_shift);
}
#elsif ( !(($clock_current > $stop) && ($clock_current > $start)) && ($start > $stop))
#{
#process_check_result($CMDFILE,$ip,$adapter_start_stop{$ip}{$instance}{$adapter_name}{state},$service_name,$start_human,$stop_human,$clock_hour,$clock_min,$time_current,$time_shift);
#}
else
#out of scheduled time----------------------------------vvv
{
  #print "$service_name $start $clock_current $stop\n";
  $state=0;
  $OUTPUT="$start_human - start, $stop_human - stop, ($clock_hour:$clock_min;shift:$time_shift). The service is out of bridge scheduled time";

  print $CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$ip;$service_name;$state;$OUTPUT\n";
}
#out of scheduled time----------------------------------^^^

}

#We have only stop time for adapter----------------------vvv
elsif (!($adapter_start_stop{$ip}{$instance}{$adapter_name}{start}) && ($adapter_start_stop{$ip}{$instance}{$adapter_name}{stop}))
{

my ($stop_hour,$stop_min)=split/:/,$adapter_start_stop{$ip}{$instance}{$adapter_name}{stop};
my $stop= timelocal(0,$stop_min,$stop_hour,(localtime)[3,4,5]);
$stop_human="$stop_hour:$stop_min";

my $midnight = timelocal(0,0,0,(localtime)[3,4,5]);

#8 hours gap
my $midnight_gap=$midnight+28800;


#---Trimming time borders-----------------------------------------------------vvv
$stop=$stop-120;
#---Trimming time borders-----------------------------------------------------^^^

$OUTPUT='---';
if (($clock_current < $stop) || (($clock_current > $stop) && ($clock_current < $midnight ) && ($clock_current > $midnight_gap)))
#if ($clock_current < $stop)
{
 process_check_result($CMDFILE,$ip,$adapter_start_stop{$ip}{$instance}{$adapter_name}{state},$service_name,'x',$stop_human,$clock_hour,$clock_min,$time_current,$time_shift);
} else

#out of scheduled time----------------------------------vvv
{
  $state=0;
  $OUTPUT="x - start, $stop_human - stop, ($clock_hour:$clock_min;shift:$time_shift). The service is out of bridge scheduled time";
  print $CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$ip;$service_name;$state;$OUTPUT\n";
}
#out of scheduled time----------------------------------^^^

}
#We have only stop time for adapter----------------------^^^

#We have only start time for adapter----------------------vvv
elsif (!($adapter_start_stop{$ip}{$instance}{$adapter_name}{stop}) && !($all_tasks{$ip}{$instance}{$key}{'service_unconditional_check'}) && ($adapter_start_stop{$ip}{$instance}{$adapter_name}{start}))
{

my ($start_hour,$start_min)=split/:/,$adapter_start_stop{$ip}{$instance}{$adapter_name}{start};
my $start= timelocal(0,$start_min,$start_hour,(localtime)[3,4,5]);

$start_human="$start_hour:$start_min";
$stop_human="x";

#print "$ip $service_name $start_hour $start_min\n";

#my $start= timelocal(0,$start_min,$start_hour,(localtime)[3,4,5]);

#my $midnight = timelocal(0,0,0,(localtime)[3,4,5]);

#8 hours gap
#my $midnight_gap=$midnight+28800;


#---Trimming time borders-----------------------------------------------------vvv
$start=$start+120;
#---Trimming time borders-----------------------------------------------------^^^


$OUTPUT='---';
#if (($clock_current > $start)) || (($clock_current < $start) && ($clock_current > $midnight ) && ($clock_current < $midnight_gap))

if ($clock_current > $start)

#if ($clock_current > $start)
{
 process_check_result($CMDFILE,$ip,$adapter_start_stop{$ip}{$instance}{$adapter_name}{state},$service_name,$start_human,'x',$clock_hour,$clock_min,$time_current,$time_shift);
} else

#out of scheduled time----------------------------------vvv
{
  $state=0;
  $OUTPUT="$start_human - start, x - stop, ($clock_hour:$clock_min;shift:$time_shift). The service is out of bridge scheduled time";
  print $CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$ip;$service_name;$state;$OUTPUT\n";
}
#out of scheduled time----------------------------------^^^

}
elsif ($all_tasks{$ip}{$instance}{$key}{'service_unconditional_check'})
{

 if ($adapter_start_stop{$ip}{$instance}{$adapter_name}{start})
 {
 my ($start_hour,$start_min)=split/:/,$adapter_start_stop{$ip}{$instance}{$adapter_name}{start};
 my $start= timelocal(0,$start_min,$start_hour,(localtime)[3,4,5]);
 $start_human="$start_hour:$start_min";
 }
 else
 {
 $start_human='x';
 }
 

 #Always do check----------------------------------------vvv
 {
 process_check_result($CMDFILE,$ip,$adapter_start_stop{$ip}{$instance}{$adapter_name}{state},$service_name,$start_human,"x",$clock_hour,$clock_min,$time_current,$time_shift);
 }
 #Always do check----------------------------------------^^^
 $start_human='x';
 $stop_human='x';

}

#print "$ip $service_name\n";

}
}
close ($CMDFILE);

#=============Nagios==============================================================^^^

} 


}
}
#Main cycle-----------------------------------------------------------------------^^^
sleep 180;
}
#Endless loop---------------------------------------------------------------------^^^

sub process_check_result
{
my($CMDFILE,$ip,$OUTPUT,$service_name,$start_human,$stop_human,$clock_hour,$clock_min,$time_current,$time_shift) = @_;
chomp($OUTPUT);
 
#print " $ip  $OUTPUT\n"; 
 
if ($OUTPUT) {
 if ($OUTPUT=~m/logged/i)
  {
   $state=0;
  } 
  elsif ($OUTPUT=~/disconnected|connected/i)
  {
  $state=1;
  }
  elsif ($OUTPUT=~/stopped/i)
  {
  $state=2;
  }
  elsif ($OUTPUT=~/time out/i)
  {
  $state=3;
  }
  
 }
 else
 {
  $OUTPUT = 'Can not get info.';
  $state=3;
 }
 
 $OUTPUT="$start_human - start, $stop_human - stop, ($clock_hour:$clock_min;shift:$time_shift). State: " . "$OUTPUT";
 print $CMDFILE "[$time_current] PROCESS_SERVICE_CHECK_RESULT;$ip;$service_name;$state;$OUTPUT\n";
 
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
