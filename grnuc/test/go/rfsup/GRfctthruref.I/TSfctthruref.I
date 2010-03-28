class implementation GRreffile;

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


%safe
static FILE *fet = NULL;
%endsafe


TSfct ( msg, type, mx, arg )
long        *msg	/* completion code				OUT */;
short       *type	/* the matrix type				 IN */;
double      *mx		/* the matrix					 IN */;
char        *arg	/* the extra arguments passed to the function    IN */; 
{
  int i;
  
  *msg = MSSUCC;
  fprintf ( fet, "%s: %d - ( ", arg, *type );
  for (i = 0; i < 16; i++)
    fprintf ( fet, "%lf ", mx [i] );
  fprintf ( fet, ")\n" );
  fflush ( fet );

  return OM_S_SUCCESS;
}


TSfctthruref ( ref_name )
char *ref_name	/* The reference file name				IN  */;
/*
   This procedure test if we can send a function through ref_name
   using GRfctthruref.
*/
{
  int         status;
  long        msg;
  struct GRid ref_grid;
  char        tmp [DI_PATH_MAX];
   
  status = di$translate ( osnum = 2,
                          path = "ref:refnames",
                          objname = ref_name,
                          p_objid = &ref_grid.objid,
                          p_osnum = &ref_grid.osnum );
  if (!(status & 1))
    fprintf ( stderr, "Error in file %s at line %d\n", __FILE__, __LINE__ );
  sprintf ( tmp, "It works for %s\n", ref_name );
  GRfctthruref ( &msg, &ref_grid, 0, TSfct, tmp );
  if (msg != MSSUCC)
    fprintf ( stderr, "Error in file %s at line %d\n", __FILE__, __LINE__ );
  
  return OM_S_SUCCESS;
}


main ()
/*
   This test routine expects the following files to be present: master, r1, r2,
   r3, c1, c2.  The following tree is also expected:
   
   			M -----------
                      / | \         |
                     /  |  \        |
                    /   |   \       |
                   r1   r2   r3    c1 <----
                  /  \  |           \     |
                 /    \ |            \    |
                r2     r3             c2-->     
*/
{
  int        status;
  GRspacenum osnum;
  GRobjid    mod_id;

  /* we retrieve M */ 
  status = ex$retrieve_module ( filename = "M", 
                                ftype = EX_visible, 
                                osnum = &osnum,
                                modid = &mod_id );
  if (!(status & 1))
    fprintf ( stderr, "Error in file %s at line %d\n", __FILE__, __LINE__ );
  else
  {
    fet = fopen ( "output/newout", "w" );  
    if (fet)    
    {
      TSfctthruref ( "r1" );
      TSfctthruref ( "r2" );
      TSfctthruref ( "r3" );
      TSfctthruref ( "c1" );
    }
    else
      printf ( "Error in file %s at line %d: cannot open output/newout\n", 
               __FILE__, __LINE__ );    
  }

  return 1;
}


end implementation GRreffile;
