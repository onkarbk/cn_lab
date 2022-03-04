set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(x) 500
set val(y) 500
set val(ifqlen) 50
set val(nn) 5
set val(stop) 150.0
set val(rp) AODV

set ns [new Simulator]
set tf [open p9.tr w]
$ns trace-all $tf
$ns use-newtrace
set nf [open p9.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
-channelType $val(chan) \
-propType $val(prop) \
-phyType $val(netif) \
-macType $val(mac) \
-ifqType $val(ifq) \
-llType $val(ll) \
-antType $val(ant) \
-ifqLen $val(ifqlen) \
-topoInstance $topo \
-macTrace ON \
-agentTrace ON \
-routerTrace ON \
-IncomingErrorProc "uniformErr1" \
-OutgoingErrorProc "uniformErr1"

proc uniformErr1 {} {
set err [new ErrorModel]
$err set rate_ 0.01
return $err
}

for {set i 0} {$i<$val(nn)} {incr i} {
set node_($i) [$ns node]
$node_($i) random-motion 0 }

$ns at 1.0 "$node_(0) setdest 10.0 10.0 50.0"
$ns at 1.0 "$node_(1) setdest 10.0 10.0 50.0"
$ns at 1.0 "$node_(2) setdest 50.0 50.0 50.0"
$ns at 1.0 "$node_(3) setdest 100.0 100.0 50.0"
$ns at 1.0 "$node_(4) setdest 100.0 100.0 50.0"

set tcp [new Agent/TCP]
$ns attach-agent $node_(0) $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $node_(2) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1.0 "$ftp start"
$ns at 50.0 "$ftp stop"

set tcp1 [new Agent/TCP]
$ns attach-agent $node_(1) $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $node_(2) $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 1.0 "$ftp1 start"
$ns at 50.0 "$ftp1 stop"

for {set i 0} {$i<$val(nn)} {incr i} {
$ns initial_node_pos $node_($i) 40 }
for {set i 0} {$i<$val(nn)} {incr i} {
$ns at $val(stop) "$node_($i) reset" }

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at $val(stop) "$ns halt"

proc stop {} {
global ns nf tf
$ns flush-trace
close $nf
close $tf
exec nam p9.nam &
exit 0
}
$ns run
