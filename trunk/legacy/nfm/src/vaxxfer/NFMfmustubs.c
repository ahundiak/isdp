
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"


/* 12/17/92 - KT - SUN Port - Cannot use any xns or clearinghouse functions */

/* solaris and sco also included - SSRS - 27/12/93 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined(OS_HPUX))
/* HP PORT-IGI- 10 Jun 1994 */
fmu_connect()
 {
 printf(" fmu_connect is stubbed in NFMfmustubs.c\n") ; 
 }
fmu_disconnect()
 {
 printf(" fmu_disconnect is stubbed in NFMfmustubs.c\n") ; 
 }
fmu_receive()
 {
 printf(" fmu_receive is stubbed in NFMfmustubs.c\n") ; 
 }
fmu_set()
 {
 printf(" fmu_set is stubbed in NFMfmustubs.c\n") ; 
 }
fmu_send()
 {
 printf(" fmu_send is stubbed in NFMfmustubs.c\n") ; 
 }
fmu_rcmd()
 {
 printf(" fmu_rcmd is stubbed in NFMfmustubs.c\n") ; 
 }
clh_vbyop()
 {
 printf(" clh_vbyop is stubbed in NFMfmustubs.c\n") ; 
 }
ncl_lkp_prop()
 {
 printf(" ncl_lkp_prop is stubbed in NFMfmustubs.c\n") ; 
 }
#endif
