/* COattrerr.h */
#ifndef COattrerr.h
#define COattrerr.h
#include <stdio.h>

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
#define _err_ck(stt) \
     if ( !(stt&1) ) { \
          _error_print(stt,stt); \
          goto quit; \
     }
     
#define _error_ck2(stt1,stt2,sts) \
     if ( !(stt1&stt2&1) ) { \
          *sts = stt1; \
          _error_print(stt1,stt2); \
          goto quit; \
     }
 
#define _err_ck2(stt1,stt2) \
     if ( !(stt1&stt2&1) ) { \
          _error_print(stt1,stt2); \
          goto quit; \
     }
     
#else

#define _error_ck(stt,sts) \
     if ( !(stt&1) ) { \
          *sts = stt; \
          goto quit; \
     }
     
#define _err_ck(stt) \
     if ( !(stt&1) ) { \
          goto quit; \
     }
     
#define _error_ck2(stt1,stt2,sts) \
     if ( !(stt1&stt2&1) ) { \
          *sts = stt1; \
          goto quit; \
     }
     
#define _err_ck2(stt1,stt2) \
     if ( !(stt1&stt2&1) ) { \
          goto quit; \
     }
     
#endif /* DEBUG */

#endif /* COattrerr.h */ 
                     
        
              

