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

extern DEcheck_display2();
extern TSsetGraphicsATPflag();

main_TSAllprops ()
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
  
  ChangeProps (rfp);
  fclose (rfp);
}

ChangeProps (rfp)
FILE		   *rfp;
#define MaxIndex 15
#define NumFlags 3

  {
  int               i;
  OM_S_OBJID        ref_id1, ref_id2;
  struct GRmd_env   md_env;
  FILE		   *wfp;
  int		    msg, flagidx, propidx;
  unsigned long	    ref_properties[MaxIndex];
  short		    flags[NumFlags];
  long		    status = 0;
  
  char		   *getenv();
  char		   *strcat();
  char		   *strcpy();
  char		   filespec1[DI_PATH_MAX];
  char		   filespec2[DI_PATH_MAX];
  
  ref_properties [0]  = GRRF_IS_READ_ONLY;
  ref_properties [1]  = GRRF_CLIP_POLY_USED;
  ref_properties [2]  = GRRF_SAVED_VIEW_USED;
  ref_properties [3]  = GRIS_SKEW;
  ref_properties [4]  = GRIS_MODEL_ATTACHMENT;
  ref_properties [5]  = GRIS_TEMPORARY;
  ref_properties [6]  = GR_CAN_BE_ACTIVE;
  ref_properties [7]  = GROVERRIDE_SYMBOLOGY;
  ref_properties [8]  = GRHIDDEN_OFF;
  ref_properties [9]  = GRMASTER_CONTEXT;
  ref_properties [10] = GREMPTY_CONTEXT;
  ref_properties [11] = GRCYCLIC_ATTACHMENT;
  ref_properties [12] = GRACTIVATED_CONTEXT;
  ref_properties [13] = GRLOC_ATTACHMENT;
  ref_properties [14] = GRLOC_OBJECTS;

  flags [0] = 0;
  flags [1] = 1;
  flags [2] = 2;

  TSsetGraphicsATPflag (0);

  /* this function requires a reference file called wframes */
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

  /* we retrieve wframes */
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
 

  while (fscanf(rfp,"%d %d",&propidx,&flagidx) != EOF)
    {
    unsigned long	existingprop1, existingprop2;
    long mesg;

    /* read properties before changing */
    existingprop1 = existingprop2 = 0;

    status = om$send ( msg = message GRreffile.GRgetrfprops ( &mesg, &existingprop1 ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id1 );

    status = om$send ( msg = message GRreffile.GRgetrfprops ( &mesg, &existingprop2 ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id2 );

    fprintf (wfp, "Old prop: %x %x; ",existingprop1, existingprop2);
    if (!(status & 1))
    {
      printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    };

    /* change the properties */
    status = om$send ( msg = message GRreffile.GRchgrfprops ( &mesg, &flags[flagidx], 
    						     &ref_properties[propidx] ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id1 );

    status = om$send ( msg = message GRreffile.GRchgrfprops ( &mesg, &flags[flagidx], 
    						     &ref_properties[propidx] ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id2 );

    fprintf (wfp, "Input prop: %x, flag: %d; ",ref_properties[propidx],flags[flagidx]);
    if (!(status & 1))
    {
      printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    };
    
    /* read properties after change */
    existingprop1 = existingprop2 = 0;
    status = om$send ( msg = message GRreffile.GRgetrfprops ( &mesg, &existingprop1 ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id1 );

    status = om$send ( msg = message GRreffile.GRgetrfprops ( &mesg, &existingprop2 ),
            senderid = NULL_OBJID,
            targetos = md_env.md_id.osnum,
            targetid = ref_id2 );

    fprintf (wfp, "New prop: %x %x\n",existingprop1, existingprop2);
    if (!(status & 1))
      {
        printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
        om$report_error ( sts = status );
      };
    Fit (); 
    };
  
  fclose (wfp);

  /* we display again */
  TSsetGraphicsATPflag (1);
  DEcheck_display2 ("All");

  unlink ("wframes");
  unlink ("solids");

  return OM_S_SUCCESS;
  }

GenerateInput ()

#include <stdio.h>
#include <limits.h>
%safe
#include <math.h>
%endsafe
  
#define NumChanges 10

  {
    FILE	*wfp;
    int propindex, flagindex, I;
    double drand48(); 
    
    
    fclose (wfp);
    wfp = fopen ("input/infile","w");
    
    for (I = 0; I < NumChanges; I++) {
      
      propindex = (int)(drand48 () * MaxIndex);
      flagindex = (int)(drand48 () * NumFlags); 
    
      fprintf (wfp, "%d %d\n", propindex, flagindex);
      }
                  
  }
  

end implementation DEso;
