set ns [new Simulator]

set tf [open lab1.tr w]
$ns trace-all $tf

set nf [open lab1.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 10Mb 2ms DropTail
$ns duplex-link $n1 $n2 10Mb 2ms DropTail
$ns duplex-link $n2 $n3 10Mb 2ms DropTail

$ns queue-limit $n0 $n2 5
$ns queue-limit $n1 $n2 5
$ns queue-limit $n2 $n3 5

set udp1 [new Agent/UDP] 
$ns attach-agent $n1 $udp1 
set null1 [new Agent/Null] 
$ns attach-agent $n3 $null1 
$ns connect $udp1 $null1 
set cbr1 [new Application/Traffic/CBR] 
$cbr1 attach-agent $udp1 
$ns at 1.1 "$cbr1 start" 
 
set tcp [new Agent/TCP] 
$ns attach-agent $n0 $tcp 
set sink [new Agent/TCPSink] 
$ns attach-agent $n3 $sink 
$ns connect $tcp $sink 
set ftp [new Application/FTP] 
$ftp attach-agent $tcp 

$ns at 0.1 "$ftp start" 
$ns at 10.0 "finish" 
proc finish {} { 
	global ns tf nf 
	$ns flush-trace 
	close $tf 
	close $nf
	puts "running nam..." 
	exec nam lab1.nam & 
	exit 0 
} 
$ns run 
