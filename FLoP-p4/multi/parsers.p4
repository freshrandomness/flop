#ifndef DCNC_PARSER
#define DCNC_PARSER

#include "defines.p4"
#include "headers.p4"

#define DCNC_PORT 8888

parser start {
    return parse_ethernet;
}

parser parse_ethernet {
    extract (ethernet);
    return select (latest.etherType) {
        0x0800:     parse_ipv4;
        default:    ingress;
    }
}

parser parse_ipv4 {
    extract (ipv4);
    return select (latest.protocol) {
        6:          parse_tcp;
        17:         parse_udp;
        default:    ingress;
    }
}

field_list ipv4_field_list {
    ipv4.version;
    ipv4.ihl;
    ipv4.diffserv;
    ipv4.totalLen;
    ipv4.identification;
    ipv4.flags;
    ipv4.fragOffset;
    ipv4.ttl;
    ipv4.protocol;
    ipv4.srcAddr;
    ipv4.dstAddr;
}

field_list_calculation ipv4_chksum_calc {
    input {
        ipv4_field_list;
    }
    algorithm: csum16;
    output_width: 16;
}

calculated_field ipv4.hdrChecksum {
    update ipv4_chksum_calc;
}

parser parse_tcp {
    extract (tcp);
    return ingress;
}

parser parse_udp {
    extract (udp);
    return select (latest.dstPort) {
        // DCNC_PORT: parse_dcnc;
        default:    ingress;
    }
}

// parser parse_dcnc {
//     extract (dcnc);
//     return select (latest.op) {
//         DCNC_READ_REPLY: parse_dcnc_value;
//         DCNC_UPDATE_VALUE_REQUEST: parse_dcnc_value;
//         DCNC_HOT_READ_REQUEST: parse_dcnc_load;
//         default: ingress;
//     }
// }

// parser parse_dcnc_value {
//     extract (dcnc_value);
//     return ingress;
// }

// parser parse_dcnc_load {
//     extract (dcnc_load);
//     return ingress;
// }

#endif
