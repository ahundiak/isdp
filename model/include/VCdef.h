#ifndef VCdef_include
#define VCdef_include
/* common (base) definitions */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>


#ifdef DEBUG
# define _debug(x) x
#else
# define _debug(x)
#endif

/*
** Program flow control
*/
#define DBG_RETURN VCdebug_return
extern int DBG_RETURN;

#define BREAK if(DBG_RETURN)\
        fprintf(stderr,"Break %s.%d\n",__FILE__,__LINE__); break
#define CONTINUE if(DBG_RETURN)\
        fprintf(stderr,"Continue %s.%d\n",__FILE__,__LINE__); continue
#define Goto(x) {if(DBG_RETURN)\
        fprintf(stderr,"Goto %s.%d\n",__FILE__,__LINE__); goto x;}
#define RETURN if(DBG_RETURN) \
        fprintf(stderr,"Return %s.%d\n",__FILE__,__LINE__); return

#endif  VCdef_include
