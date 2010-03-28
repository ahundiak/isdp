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

from GRreffile import GRchgstyle;

extern DEcheck_display2();
extern TSsetGraphicsATPflag();

main ()
{
  long              msg;
  FILE 		   *rfp;

  if ((rfp = fopen ("input/infile","r")) == NULL) 
  	GenerateInput (rfp);  
  rfp = fopen ("input/infile","r");

  if (rfp == NULL) {
    printf ("Unable to create or read from input file\n");
    return 0;
    }
  
  ChangeStyle (rfp);
  fclose (rfp);
}

ChangeStyle (rfp)
FILE		   *rfp;
#define MaxNumStyles 8

  {
  int               i;
  OM_S_OBJID        ref_id1, ref_id2;
  struct GRmd_env   md_env;
  FILE		   *wfp;
  int		    msg, styleidx;
  unsigned char    styles [MaxNumStyles];
  long		    status = 0;
  char		   *getenv();
  char		   *strcat();
  char		   *strcpy();
  char		   filespec1[DI_PATH_MAX];
  char		   filespec2[DI_PATH_MAX];
  char		   path[DI_PATH_MAX];
  long             mesg;
  
  styles [0]  = 0;
  styles [1]  = 1;
  styles [2]  = 2;
  styles [3]  = 3;
  styles [4]  = 4;
  styles [5]  = 5;
  styles [6]  = 6;
  styles [7]  = 7;

  /* this function requires files called -wframes-, -solids- under test/dwgs */
  ex$get_cur_mod ( id = &md_env.md_id.objid, 
     osnum = &md_env.md_id.osnum );

  if ( (strcpy (filespec1, getenv("GRNUC"))) && 
       (strcpy (filespec2, getenv("GRNUC")))   )
    if ( (strcat (filespec1 ,"/test/dwgs/wframes")) && 
         (strcat (filespec2 ,"/test/dwgs/solids"))   )  {
       link (filespec1,"wframes");
       link (filespec2,"solids");
       }
    else  {
      printf ("Couldn't make up filenames");
      return 0;
      }
  else  {
    printf ("Couldn't get environment variable $GRNUC");
    return 0;
    }

  TSsetGraphicsATPflag ( 0 );

  ex$retrieve_module ( ftype    = EX_visible,
  	               filename = "wframes",
                       create   = 0,
                       save 	= 0,
                       activate = TRUE,
                       osnum    = &md_env.md_id.osnum,
                       modid    = &md_env.md_id.objid,
                       msg      = &msg );        
  
  /* the ref file object is called ":<master>:ref:refnames:wframes" */
  di$translate ( objname = "wframes2",
                 osnum = md_env.md_id.osnum,
                 path  = "ref:refnames",
                 p_objid = &ref_id1 );
                 
  di$translate ( objname = "solids2",
                 osnum = md_env.md_id.osnum,
                 path  = "ref:refnames",
                 p_objid = &ref_id2 );

  if ((wfp = fopen ("output/masterout","r")) != NULL) 
      wfp = fopen ("output/newout","w");              
    else wfp = fopen ("output/masterout","w");

  if (wfp == NULL) {
    printf ("Unable to create output file\n");
    return 0;
    }
 
  while (fscanf(rfp,"%d",&styleidx) != EOF)
    {
    /* change the properties */
    status = om$send ( msg = message GRreffile.GRchgstyle ( &mesg,&styles[styleidx] ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id1 );
            
    status = om$send ( msg = message GRreffile.GRchgstyle ( &mesg,&styles[styleidx] ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id2 );

    fprintf (wfp, "Style changed to: %d\n",styles[styleidx]);
    if (!(status & 1))
     {
       printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
       om$report_error ( sts = status );
     };
    Fit ();
    };
  
  fclose (wfp);

  TSsetGraphicsATPflag (1);
  DEcheck_display2 ("Styles");

  unlink ("wframes");
  unlink ("solids");

  return OM_S_SUCCESS;
  }

GenerateInput (wfp)
FILE		*wfp;
#include <stdio.h>
#include <limits.h>
%safe
#include <math.h>
%endsafe
#define NumChanges 10

  {
    int styleidx, I;
    double drand48(); 
    
    wfp = fopen ("input/infile","w");
    
    for (I = 0; I < NumChanges; I++) {
      
      styleidx = (int)(drand48 () * MaxNumStyles);
      fprintf (wfp, "%d\n", styleidx);
      }

    fclose (wfp);
  }

end implementation DEso;
