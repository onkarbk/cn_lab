set ns [new Simulator] 
 
set tf [open lab4.tr w] 
$ns trace-all $tf 
 
set nf [open lab4.nam w] 
$ns namtrace-all $nf 
set cwind [open win2.tr w] 
set n1 [$ns node] 
set n2 [$ns node] 
set n3 [$ns node] 
set n4 [$ns node] 
set n5 [$ns node] 
set n6 [$ns node] 
 
$ns duplex-link $n1 $n3 5Mb 2ms DropTail 
$ns duplex-link $n2 $n3 5Mb 2ms DropTail 
$ns duplex-link $n3 $n4 5Mb 2ms DropTail 
$ns duplex-link $n4 $n5 5Mb 2ms DropTail 
$ns duplex-link $n4 $n6 1.5Mb 10ms DropTail
 
set tcp0 [new Agent/TCP]  
$ns attach-agent $n1 $tcp0 
set sink0 [new Agent/TCPSink] 
$ns attach-agent $n6 $sink0 
$ns connect $tcp0 $sink0 
set ftp [new Application/FTP] 
$ftp attach-agent $tcp0 
 
$ns at 1.2 "$ftp start" 
 
set tcp1 [new Agent/TCP] 
$ns attach-agent $n2 $tcp1 
set sink1 [new Agent/TCPSink] 
$ns attach-agent $n5 $sink1 
$ns connect $tcp1 $sink1 
set telnet [new Application/Telnet] 
$telnet attach-agent $tcp1 
 
$ns at 1.5 "$telnet start" 
 
$ns at 10.0 "finish" 
 
proc plotWindow {tcpSource file} { 
global ns 
set time 0.01 
set now [$ns now] 
set cwnd [$tcpSource set cwnd_] 
puts $file "$now $cwnd" 
$ns at [expr $now+$time] "plotWindow $tcpSource $file" } 
$ns at 2.0 "plotWindow $tcp0 $cwind" 
$ns at 5.5 "plotWindow $tcp1 $cwind" 
 
proc finish {} { 
global ns tf nf cwind 
$ns flush-trace 
close $tf 
close $nf 
 
puts "running nam..." 
puts "FTP PACKETS.." 
puts "Telnet PACKETS.." 
exec nam lab4.nam & 
exec xgraph win2.tr & 
exit 0 
} 
$ns run
