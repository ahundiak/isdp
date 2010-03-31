#ifndef emsdebug_include
#define emsdebug_include

#ifndef _STDIO_H
#include <stdio.h>
#endif

extern IGRboolean _ems_debug, _ems_debug_to_file;
extern FILE *_ems_debug_file;

#define DEBUG_REPORT(condition, idmessg, idnum, usernum) \
         { \
         if ((condition) && _ems_debug) \
           { \
           if (_ems_debug_to_file) \
             fprintf (_ems_debug_file, "%s - %d: %d\n", \
              idmessg, idnum, usernum); \
           fprintf (stderr, "%s - %d: %d\n", \
            idmessg, idnum, usernum); \
           } \
         }
#endif
