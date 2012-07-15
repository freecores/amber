/*----------------------------------------------------------------
//                                                              //
//  boot-loader.h                                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Defines for the boot-loader application.                    //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/
#define TELNET_PORT         23

#define MAX_PACKET_SIZE     2000
#define ETHMAC_RX_BUFFERS   8
#define TCP_TX_BUFFERS      256

#define TELNET_WILL 251
#define TELNET_WONT 252
#define TELNET_DO   253
#define TELNET_DONT 254

#define UDP_READ  1
#define UDP_WRITE 2
#define UDP_DATA  3
#define UDP_ACK   4
#define UDP_ERROR 5


/* Generic MII registers. */
/* Taken from kernel source file include/linux/mii.h */
#define MII_BMCR            0x00        /* Basic mode control register */
#define MII_BMSR            0x01        /* Basic mode status register  */
#define MII_PHYSID1         0x02        /* PHYS ID 1                   */
#define MII_PHYSID2         0x03        /* PHYS ID 2                   */
#define MII_ADVERTISE       0x04        /* Advertisement control reg   */
#define MII_LPA             0x05        /* Link partner ability reg    */
#define MII_EXPANSION       0x06        /* Expansion register          */
#define MII_CTRL1000        0x09        /* 1000BASE-T control          */
#define MII_STAT1000        0x0a        /* 1000BASE-T status           */
#define MII_ESTATUS	    0x0f	/* Extended Status */
#define MII_DCOUNTER        0x12        /* Disconnect counter          */
#define MII_FCSCOUNTER      0x13        /* False carrier counter       */
#define MII_NWAYTEST        0x14        /* N-way auto-neg test reg     */
#define MII_RERRCOUNTER     0x15        /* Receive error counter       */
#define MII_SREVISION       0x16        /* Silicon revision            */
#define MII_RESV1           0x17        /* Reserved...                 */
#define MII_LBRERROR        0x18        /* Lpback, rx, bypass error    */
#define MII_PHYADDR         0x19        /* PHY address                 */
#define MII_RESV2           0x1a        /* Reserved...                 */
#define MII_TPISTATUS       0x1b        /* TPI status for 10mbps       */
#define MII_NCONFIG         0x1c        /* Network interface config    */

/* Basic mode control register. */
/* Taken from kernel source file include/linux/mii.h */
#define BMCR_RESV               0x003f  /* Unused...                   */
#define BMCR_SPEED1000		0x0040  /* MSB of Speed (1000)         */
#define BMCR_CTST               0x0080  /* Collision test              */
#define BMCR_FULLDPLX           0x0100  /* Full duplex                 */
#define BMCR_ANRESTART          0x0200  /* Auto negotiation restart    */
#define BMCR_ISOLATE            0x0400  /* Disconnect DP83840 from MII */
#define BMCR_PDOWN              0x0800  /* Powerdown the DP83840       */
#define BMCR_ANENABLE           0x1000  /* Enable auto negotiation     */
#define BMCR_SPEED100           0x2000  /* Select 100Mbps              */
#define BMCR_LOOPBACK           0x4000  /* TXD loopback bits           */
#define BMCR_RESET              0x8000  /* Reset the DP83840           */

/* Basic mode status register. */
/* Taken from kernel source file include/linux/mii.h */
#define BMSR_ERCAP              0x0001  /* Ext-reg capability          */
#define BMSR_JCD                0x0002  /* Jabber detected             */
#define BMSR_LSTATUS            0x0004  /* Link status                 */
#define BMSR_ANEGCAPABLE        0x0008  /* Able to do auto-negotiation */
#define BMSR_RFAULT             0x0010  /* Remote fault detected       */
#define BMSR_ANEGCOMPLETE       0x0020  /* Auto-negotiation complete   */
#define BMSR_RESV               0x00c0  /* Unused...                   */
#define BMSR_ESTATEN		0x0100	/* Extended Status in R15 */
#define BMSR_100HALF2           0x0200  /* Can do 100BASE-T2 HDX */
#define BMSR_100FULL2           0x0400  /* Can do 100BASE-T2 FDX */
#define BMSR_10HALF             0x0800  /* Can do 10mbps, half-duplex  */
#define BMSR_10FULL             0x1000  /* Can do 10mbps, full-duplex  */
#define BMSR_100HALF            0x2000  /* Can do 100mbps, half-duplex */
#define BMSR_100FULL            0x4000  /* Can do 100mbps, full-duplex */
#define BMSR_100BASE4           0x8000  /* Can do 100mbps, 4k packets  */


typedef struct {
    unsigned char mac[6];
    unsigned char ip[4];
} mac_ip_t;


typedef struct {
    unsigned int payload_valid;
    unsigned int starting_seq;
    unsigned int ending_seq;
    unsigned int len_bytes;
    unsigned int ack_received;
    time_t       resend_time;
    char         buf[MAX_PACKET_SIZE];
} packet_buffer_t;


typedef struct {
    /* Ethernet */
    unsigned char   src_mac[6];
    unsigned char   dst_mac[6];
    unsigned int    eth_type;
    
    /* IPv4 */
    unsigned char   src_ip[4];
    unsigned char   dst_ip[4];
    unsigned int    ip_len;        // IP; in bytres
    unsigned int    ip_header_len; // IP; in 32-bit words
    unsigned int    ip_proto;
    
    /* TCP */       
    unsigned int    tcp_src_port;
    unsigned int    tcp_dst_port;
    unsigned int    tcp_hdr_len;
    unsigned int    tcp_seq;
    unsigned int    tcp_ack;
    unsigned int    tcp_flags;
    unsigned int    tcp_window_size;
    unsigned int    tcp_len;
    unsigned int    tcp_payload_len;
    unsigned int    tcp_src_time_stamp;
    
    /* Telnet */
    unsigned int    telnet_payload_len;
} packet_t;



typedef struct {

    packet_buffer_t** tcp_buf;
    int          tcp_current_buf;

    /* Telnet rx and tx line buffers */
    line_buf_t*  telnet_rxbuf;
    line_buf_t*  telnet_txbuf;

    int          telnet_sent_opening_message;
    int          telnet_echo_mode;
    int          telnet_connection_state;
    int          telnet_options_sent;
    
    int          packets_sent;
    int          packets_received;
    int          packets_resent;
    
    int          tcp_connection_state;
    int          tcp_reset;
    int          tcp_disconnect;
    int          tcp_seq;            /* should be random initial seq number for tcp */
    int          tcp_last_seq; 
    unsigned int tcp_last_ack;
    
    int          id; 
    
    packet_t*    rx_packet;  /* Header info from last packet received */
} socket_t;



/* Enumerated types */
enum mdi_ctrl {
	mdi_write = 0x04000000,
	mdi_read  = 0x08000000,
	mdi_ready = 0x10000000,
};



enum telnet_state {
	TELNET_CLOSED    = 0,
	TELNET_OPEN      = 1
};


/* Global Variables */
extern mac_ip_t    self_g;
extern packet_t*   rx_packet_g;
extern socket_t*   socket0_g;
extern socket_t*   socket1_g;


/* Functions */
void            init_packet_buffers     (socket_t*);
unsigned short  header_checksum16       (unsigned char *buf, unsigned short len, unsigned int sum);

void            arp_reply               (char *buf, mac_ip_t*);
void            ping_reply              (packet_t* packet0, int ping_id, int ping_seq, char * rx_buf);

void            ethernet_header         (char *buf, mac_ip_t* target, unsigned short type);
void            ip_header               (char *buf, mac_ip_t* target, unsigned short ip_len, char ip_proto);

void            parse_rx_packet         (char*, packet_t*);
void            parse_arp_packet        (char*);
void            parse_ip_packet         (char*, packet_t*);
void            parse_ping_packet       (char*, packet_t*);

socket_t*       init_socket             (int);






