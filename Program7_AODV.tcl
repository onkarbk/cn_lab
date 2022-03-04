set val(chan)		Channel/WirelessChannel
set val(prop)		Propagation/TwoRayGround
set val(netif)		Phy/WirelessPhy
set val(mac)		Mac/802_11
set val(ifq)		Queue/DropTail/PriQueue
set val(ll)		LL
set val(ant)		Antenna/OmniAntenna
set val(x)		500
set val(y)		400
set val(ifqlen)	50
set val(nn)		3
set val(stop)		60
set val(rp)		AODV

set ns [new Simulator]
set tracefd		[open simple-aodv.tr w]
set windowVsTime2	[open win.tr w]
set namtrace 		[open simwrls.nam w]

$ns trace-all $tracefd
$ns use-newtrace
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

set topo 	[new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

#Node Configuration
$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON 
#Creating Nodes
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns node]
$node_($i) random-motion 0
}


for {set i 0} {$i < $val(nn)} {incr i} {
$ns initial_node_pos $node_($i) 40
}

$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0



#Topology Design
$ns at 0.0 "$node_(0) setdest 450.0 285.0 30.0"
$ns at 0.0 "$node_(1) setdest 200.0 285.0 30.0"
$ns at 0.0 "$node_(2) setdest 1.0 285.0 30.0"

$ns at 25.0 "$node_(0) setdest 300.0 285.0 10.0"
$ns at 25.0 "$node_(2) setdest 100.0 285.0 10.0"

$ns at 40.0 "$node_(0) setdest 490.0 285.0 5.0"
$ns at 40.0 "$node_(2) setdest 1.0 285.0 5.0"


#Generating Traffic
set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp0
$ns attach-agent $node_(1) $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0



$ns at 10.0 "$ftp0 start"

proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"}
$ns at 10.1 "plotWindow $tcp0 $windowVsTime2"

#Simulation Termination
for {set i 0} {$i < $val(nn) } {incr i} {
$ns at $val(stop) "$node_($i) reset";
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 60.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
	global ns tracefd namtrace
	$ns flush-trace
	close $tracefd
	close $namtrace
	exec nam simwrls.nam &
	
	exec xgraph win.tr &
}
$ns run
