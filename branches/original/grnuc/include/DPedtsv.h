#ifndef  DPedtsv_include

#define  DPedtsv_include


/*  This file is the saved view struct used in COedtsv.sl.  It depends on
 *           dpfile.h
 */

#ifdef SUNOS 
#include "sunlimits.h"
#endif

#include <limits.h>

struct sv_info
{
  int         delete_flag;
  char        name[DI_PATH_MAX], descript[DI_PATH_MAX];
  struct GRid oid;
};


#endif
