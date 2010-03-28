#ifndef palco_include
#define palco_include

#include <stdio.h>

#define PALETTE_LOCATED     50505050
#define PALETTE_FIELD       12
#define PALCRE 0
#define PALCFL 1
#define PALADD 2
#define PALREM 3
#define PALSAV 4
#define PALSTU 4

#define CO_store_cmd            0
#define CO_create_pal           1
#define CO_add_cmd              2
#define CO_init_pal             3
#define CO_rem_cmd              4
#define CO_sav_pal              5
#define CO_del_pal              6
#define CO_pop_cmd              7
#define CO_palette_locate_on    8
#define CO_palette_locate_off   9

#ifdef DEBUG     

#define _error_print(stt1, stt2) \
{ \
     fprintf(stderr,"Fatal Error: File = %s  Line = %d\n",__FILE__,__LINE__); \
     if ( !(stt1 & 1) ) om$report_error (sts = stt1); \
     else fprintf(stderr,"NON OM Error: Return = %d\n", stt2); \
}
#define _error_ck(stt,sts) \
     if ( !(stt&1) ) { \
          *sts = stt; \
          _error_print(stt,stt); \
          goto quit; \
     }
     
#define _error_ck2(stt1,stt2,sts) \
     if ( !(stt1&stt2&1) ) { \
          *sts = stt1; \
          _error_print(stt1,stt2); \
          goto quit; \
     }
     
#else

#define _error_ck(stt,sts) \
     if ( !(stt&1) ) { \
          *sts = stt; \
          goto quit; \
     }
     
#define _error_ck2(stt1,stt2,sts) \
     if ( !(stt1&stt2&1) ) { \
          *sts = stt1; \
          goto quit; \
     }
     
#endif /* DEBUG */

#endif
