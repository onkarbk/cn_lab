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
set val(nn) 25
set val(stop) 100.0
set val(rp) AODV
set val(sc) "file1"
set val(cp) "file2"


set ns_ [new Simulator]
set tf [open p12.tr w]
$ns_ trace-all $tf
set nf [open p12.nam w]
$ns_ namtrace-all-wireless $nf $val(x) $val(y)
set prop [new $val(prop)]
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(nn)]

   $ns_ node-config -adhocRouting $val(rp) \
-channelType $val(chan) \
-phyType $val(netif) \
-propType $val(prop) \
-macType $val(mac) \
-ifqType $val(ifq) \
-llType $val(ll) \
-antType $val(ant) \
-ifqLen $val(ifqlen) \
-topoInstance $topo \
-routerTrace ON \
-agentTrace ON \
-macTrace ON 

for {set i 0} {$i<$val(nn)} {incr i} {
set node_($i) [$ns_ node] 
$node_($i) random-motion 0 }

for {set i 0} {$i < $val(nn)} {incr i} {
set xx [expr rand()*500]
set yy [expr rand()*400]
$node_($i) set X_ $xx
$node_($i) set Y_ $yy }

for {set i 0} {$i<$val(nn)} {incr i} {
$ns_ initial_node_pos $node_($i) 40 }

source $val(sc)
source $val(cp)

for {set i 0} {$i< $val(nn)} {incr i} {
$ns_ at $val(stop) "$node_($i) reset" ; }
$ns_ at $val(stop) "$ns_ halt"
$ns_ run
