class implementation Root;

%safe
#include <math.h>
%endsafe

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
#include "OMindex.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"

#include "OMprimitives.h"
#include "dp.h"
#include "igrdp.h"
#include "gr.h"
#include "DEso.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "refdef.h"
#include "ref.h"

#include "DEsomacros.h"

from GRreffile import GRchglevels; /* */
from GRreffile import GRgetlevels; /* */
from GRgraphics import GRconstruct;

struct  GRmd_env md_env;
struct  GRid     RF_id;

main ()
{
  long    msg;
  int	  status;
  FILE    *rfp;  			    /* file pointers		   */
  FILE    *wfp;
  int     i = 0;			    /* a counter */
  int     levels[32];
  int     action;
  int     j;
  struct	  IGRdisplay symb;
  char            my_file [DI_PATH_MAX];
  struct	  IGRlbsys lbsys;
  struct GRmd_env md_env;
  
  if ((rfp = fopen ("input/infile","r")) == NULL) /* if the file 'infile' !exist, */  
    dpgen(rfp);					  /* create it			*/
 
  rfp = fopen ("input/infile","r");				
  if ((wfp = fopen ("output/masterout","r")) != NULL) /* open new master out file if it !exist	*/
      wfp = fopen ("output/newout","w");              /* ,write to new file otherwise		*/
    else wfp = fopen ("output/masterout","w");
  
  for (i = 0; i < 32; i++) 
    levels[i] = 0;

  ex$filename (name = my_file, len = DI_PATH_MAX);
  status = ex$save_module (ftype = EX_visible,
       			filename = my_file,
  			newfilename = "reffile");
  if (status != 1)
  {
    fprintf (stderr, "CANNOT save module as reffile\n");
    return 0;
  } 
  
  status = ex$get_cur_mod ( id = &md_env.md_id.objid, 
                          osnum = &md_env.md_id.osnum );

  if (status != 1)
  {
    fprintf (stderr, "CANNOT get current module\n");
    return 0;
  } 
    

  md_env.md_env.matrix_type = MAIDMX;
  symb.color  = 1;
  symb.style  = 1;
  symb.weight = 1;
  md_env.md_env.matrix [0] = 	 1.0; 
  md_env.md_env.matrix [1] = 	 0.0; 
  md_env.md_env.matrix [2] = 	 0.0;
  md_env.md_env.matrix [3] = -3600.0; 
  md_env.md_env.matrix [4] =	 0.0; 
  md_env.md_env.matrix [5] = 	 1.0; 
  md_env.md_env.matrix [6] = 	 0.0; 
  md_env.md_env.matrix [7] =  1300.0; 
  md_env.md_env.matrix [8] = 	 0.0; 
  md_env.md_env.matrix [9] = 	 0.0; 
  md_env.md_env.matrix [10] = 	 1.0; 
  md_env.md_env.matrix [11] = 	 0.0; 
  md_env.md_env.matrix [12] = 	 0.0; 
  md_env.md_env.matrix [13] = 	 0.0; 
  md_env.md_env.matrix [14] = 	 0.0; 
  md_env.md_env.matrix [15] = 	 1.0;

  lbsys.matrix [0]  = 		1.0;
  lbsys.matrix [1]  = 		0.0;
  lbsys.matrix [2]  = 		0.0;
  lbsys.matrix [3]  = 	    -3600.0;
  lbsys.matrix [4]  = 		0.0;
  lbsys.matrix [5]  = 		1.0;
  lbsys.matrix [6]  = 		0.0;
  lbsys.matrix [7]  = 	     1300.0;
  lbsys.matrix [8]  = 		0.0;
  lbsys.matrix [9]  = 		0.0;
  lbsys.matrix [10] = 		1.0;
  lbsys.matrix [11] = 		0.0;
  lbsys.matrix [12] = 		0.0;
  lbsys.matrix [13] = 		0.0;
  lbsys.matrix [14] = 		0.0;
  lbsys.matrix [15] = 		1.0;

  GRattach_file ( &msg, &RF_id,"reffile",&md_env,&symb, 0, 0, "window", "1", &lbsys );
  if (status != 1)
  {
    fprintf (stderr, "CANNOT attach the reference file\n");
    return 0;
  } 

  while (fscanf(rfp,"%d",&action) != EOF) {
    for (i = 0; i < 32; i++) 
      fscanf (rfp,"%d",&levels[i]);
    action = (short)(action);
    TSchg_levels (&msg, &action, &levels[0], &RF_id);
    for (i = 0; i < 32; i++) 
      levels[i] = 0;
    TSget_levels (&msg, &levels[0], &RF_id);
    fprintf (wfp,"%d\n",action);
    for (i = 0; i < 32; i++) 
      fprintf (wfp,"%d\n",levels[i]);
    fprintf (wfp,"\n");
    }		
    					/* and write them to file		*/
  fclose (wfp);
  fclose (rfp);
};

TSchg_levels ( msg, flag, levels, p_gr_id)
long            *msg;
short		*flag;
int		*levels;
struct GRid     *p_gr_id;

{
  int		  status;		
  long		  messag;
  
  status = om$send ( msg      = message GRreffile.GRchglevels (&messag, flag, levels),
      targetos = p_gr_id->osnum, 
      targetid = p_gr_id->objid,
      senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "Error changing levels, file %s at line %d\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  
  
  return status;
}


TSget_levels (msg,levels,gr_id)

int	    *msg;
int	    *levels;
struct GRid *gr_id;
{
  long	      mesag;
  int         status;
  status = om$send ( msg = message GRreffile.GRgetlevels (&mesag,levels),
      targetos = gr_id->osnum,
      targetid = gr_id->objid,
      senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "Error getting levels, file %s at line %d\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  };
    
  return status;
}


dpgen(wfp)             /* this function generates the input for change levels */

FILE *wfp;

#include <stdio.h>
#include <limits.h>
{
long mrand48();
double drand48();
int NumChanges = 1000;
int NumOptions = 3;
int i, j;
long levels;
short	option; 

fclose (wfp);
wfp = fopen ("input/infile","w");


for (i = 0; i < NumChanges; i++)
  {
	option = (int)(drand48 () * NumOptions);
	fprintf (wfp, "%d\n", option);
	for ( j=0; j < 32; j++) {
	    levels = mrand48 ();
	    fprintf (wfp, "%d\n",levels);
	    }
	fprintf (wfp, "\n");
  }
fclose(wfp);
}

end implementation Root;


