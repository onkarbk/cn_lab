BEGIN { 
tcp_d=0;
tcp_r=0; 
udp_d=0;
udp_r=0; 
} 
{ 
if ( $1 == "d" && $5 == "tcp") 
tcp_d ++; 

if ( $1 == "r" && $5 == "tcp") 
tcp_r ++; 
 
if ( $1 == "d" && $5 == "cbr") 
udp_d ++; 

if ( $1 == "r" && $5 == "cbr") 
udp_r ++; 
} 
END { 
printf("Number of packet dropped in TCP %d\n", tcp_d); 
printf("Number of packet dropped in UDP %d\n", udp_d); 
printf("Number of packet Received in TCP %d\n", tcp_r); 
printf("Number of packet Received in UDP %d\n", udp_r); 
} 
