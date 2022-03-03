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
set val(nn)		2
set val(stop)		150
set val(rp)		DSDV

set ns [new Simulator]
set tracefd		[open simple-dsdv.tr w]
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
-macTrace OFF \
-movementTrace ON
#Creating Nodes
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns node]

}

$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0

$node_(0) set X_ 490.0
$node_(0) set Y_ 285.0
#Topology Design
$ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"
$ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0"
$ns at 110.0 "$node_(0) setdest 480.0 300.0 5.0"
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

for {set i 0} {$i < $val(nn)} {incr i} {
$ns initial_node_pos $node_($i) 130
}
#Simulation Termination
for {set i 0} {$i < $val(nn) } {incr i} {
$ns at $val(stop) "$node_($i) reset";
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
	global ns tracefd namtrace
	$ns flush-trace
	close $tracefd
	close $namtrace
	exec nam simwrls.nam &
	
	exec xgraph win.tr &
}
$ns run
