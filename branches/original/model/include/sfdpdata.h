#ifndef _sfdpdata_include
#define _sfdpdata_include

#ifndef _STDIO_H
#include <stdio.h>
#endif

#ifndef igrtypedef_include
// #include "igr_include/igrtypedef.h"
#include "igrtypedef.h"
#endif

#ifndef igr_include
// #include "igr_include/igr.h"
#include "igr.h"
#endif

#ifndef PWgmdata_include
#include "PWgmdata.h"
#endif

#ifndef igrdp_include
#include "igrdp.h"
#endif


struct PWsfattrdata
{
  PWobjid               id;
  PWosnum               os;
  struct IGRdisplay 	attr;

  int			polygon_display;
  int			surface_display;
};

#endif







