class implementation DEso;

#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "DEso.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "refdef.h"
#include "ref.h"

#define MIN_X -1300.0
#define MIN_Y -1000.0

#define MAX_X 1300.0
#define MAX_Y 1000.0

from GRreffile import GRchgrfprops, GRgetrfprops;

extern DEcheck_display();
extern TSsetGraphicsATPflag();

main ()
{
  long              msg;
  unsigned long     ref_properties;
  int               i;
  OM_S_OBJID        ref_id;
  struct GRmd_env   md_env;
  short             flag;
  int               mesg;
  
  TSsetGraphicsATPflag ( 0 );

  /* this test routine requires a reference file called part.dgn */
  ex$get_cur_mod ( id = &md_env.md_id.objid, 
     osnum = &md_env.md_id.osnum );

  /* we retrieve draw.dgn */
  ex$retrieve_module ( ftype    = EX_visible,
  	               filename = "draw.dgn",
                       create   = 0,
                       save 	= 0,
                       activate = TRUE,
                       osnum    = &md_env.md_id.osnum,
                       modid    = &md_env.md_id.objid,
                       msg      = &mesg );        
  
  /* the ref file object is called ":<master>:ref:refnames:part.dgn" */
  di$translate ( objname = "part.dgn",
                 osnum = md_env.md_id.osnum,
                 path  = "ref:refnames",
                 p_objid = &ref_id );

  /* we change the properties */
  flag = 1 /* set property bit */;
  ref_properties = GRHIDDEN_OFF;
  om$send ( msg = message GRreffile.GRchgrfprops ( &msg, &flag, &ref_properties ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id );
  
  /* make sure it worked */
  ref_properties = 0;
  om$send ( msg = message GRreffile.GRgetrfprops ( &msg, &ref_properties ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id );
  if (!(ref_properties & GRHIDDEN_OFF))
    printf ( "in file %s at line %d: bad properties\n", __FILE__, __LINE__ );

  /* we display again */
  TSsetGraphicsATPflag ( 1 );
  DEcheck_display ();

  return OM_S_SUCCESS;  
}


end implementation DEso;

