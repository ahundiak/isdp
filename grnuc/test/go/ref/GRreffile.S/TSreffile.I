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

#include "DEsomacros.h"

#define MIN_X -1300.0
#define MIN_Y -1000.0

#define MAX_X 1300.0
#define MAX_Y 1000.0

#define NB_FILES 3
#define NB_OBJECTS 100

from GRcontext import GRgetmodule_env;

%safe
void ConstObj ();
%endsafe


static struct GRmd_env md_env;

extern TSsetGraphicsATPflag();
extern DEcheck_display();

main ()
{
  long              msg;
  int               status, master, i, j;
  char              my_file [DI_PATH_MAX];
  struct IGRdisplay symb;
  struct IGRlbsys   lbsys;
  FILE              *fet;
  char		    namestr [DI_PATH_MAX];

  status = 0;
  ConstObj ( NB_OBJECTS );

  /* We just wanna do a fit */
  TSsetGraphicsATPflag ( 0 );
  DEcheck_display ();

  ex$filename ( name = my_file, len = DI_PATH_MAX );
  for (i = 0; i < NB_FILES; i++) 
  {
    sprintf ( namestr, "f%d", i); 
    unlink ( namestr );
    status = ex$save_module ( ftype = EX_visible,
                              filename = my_file, 
                              newfilename = namestr ) ;
    if (status != 1)
    {
     fprintf ( stderr, "CANNOT save module as f%d\n",i );
     return 0;
    }
  }

  status = ex$get_cur_mod ( id = &md_env.md_id.objid, 
                   osnum = &md_env.md_id.osnum );
  md_env.md_env.matrix_type = MAIDMX;
  symb.color = 1;
  symb.style = 1;
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
  
  for (i = 0; i < NB_FILES ; i++) 
  {
    /* retrieve fi */
    sprintf ( namestr, "f%d", i); 
    status = ex$retrieve_module (
    	ftype    = EX_visible,		   filename = namestr,
        create   = 0,
        save 	 = 0,	           activate = TRUE,
        osnum    = &md_env.md_id.osnum,    modid    = &md_env.md_id.objid,
        msg      = (int *)&msg );        
    
    for (j = 0; j < NB_FILES ; j++) 
    {
      char namestr [DI_PATH_MAX];
      
      lbsys.matrix [0] = 		1.0; 
      lbsys.matrix [1] = 		0.0; 
      lbsys.matrix [2] = 		0.0;
      lbsys.matrix [3] = 	    -3600.0 + i * 100; 
      lbsys.matrix [4] = 		0.0; 
      lbsys.matrix [5] = 		1.0; 
      lbsys.matrix [6] = 		0.0; 
      lbsys.matrix [7] = 	     1300.0; 
      lbsys.matrix [8] = 		0.0; 
      lbsys.matrix [9] = 		0.0; 
      lbsys.matrix [10] = 	1.0; 
      lbsys.matrix [11] = 	0.0; 
      lbsys.matrix [12] = 	0.0; 
      lbsys.matrix [13] = 	0.0; 
      lbsys.matrix [14] = 	0.0; 
      lbsys.matrix [15] = 	1.0;
  
      sprintf ( namestr, "f%d", j ); 
      GRattach_file ( &msg,namestr,&md_env,&symb, 0, 0, "window", "1", &lbsys );
    } 
    status = ex$save_module ( ftype = EX_visible,
                     filename = namestr );
  }
  
  for (i = 0; i < NB_FILES ; i++)
  {
    sprintf ( namestr, "f%d", i);
    status = ex$retrieve_module (
    	ftype    = EX_visible,		   filename = namestr,
        create   = 0,
        save 	 = TRUE,	           activate = TRUE,
        osnum    = &md_env.md_id.osnum,    modid    = &md_env.md_id.objid,
        msg      = (int *)&msg );        
    status = ex$retrieve_module (
    	ftype    = EX_visible,		   filename = namestr,
        create   = 0,
        save 	 = 0,		           activate = TRUE,
        osnum    = &md_env.md_id.osnum,    modid    = &md_env.md_id.objid,
        msg      = (int *)&msg );        
  }
  
  for (i = 0; i < NB_FILES ; i++)
  {
    sprintf ( namestr, "f%d", i);
    status = ex$retrieve_module (
    	ftype    = EX_visible,		   filename = namestr,
        create   = 0,
        save 	 = 0,			   activate = TRUE,
        osnum    = &md_env.md_id.osnum,    modid    = &md_env.md_id.objid,
        msg      = (int *)&msg );        
    status = ex$retrieve_module (
    	ftype    = EX_visible,		   filename = namestr,
        create   = 0,
        save 	 = 1,	        	   activate = TRUE,
        osnum    = &md_env.md_id.osnum,    modid    = &md_env.md_id.objid,
        msg      = (int *)&msg );        
  }

  TSsetGraphicsATPflag ( 1 );
  DEcheck_display ();
  
  if (status == 1)
    for (i = 0; i < NB_FILES ; i++) 
    {
      sprintf ( namestr, "f%d", i);
      unlink (namestr);
    }
    else 
      printf ("ERRORS FOUND");
    
}


void ConstObj (num_objects)
int num_objects;
{
double range = 10000;
int NumColors = 256;
int NumStyles = 8;
int NumWeights = 32;
int NumLayers = 1024;
double i, j, k;
int c, w, s, l;
int I;
long                  status;
long		      msg;
double                points [3];
struct GRvg_construct ConstructList;
struct IGRbsp_curve   curve;
struct IGRdisplay     symb;
GRobjid		      objid;
GRobjid		      *p_objid; 
double                drand48 ();

  md_env.md_id.osnum = 2;		    /* initializing env */
  md_env.md_id.objid = 21;		    /*		.	*/
  md_env.md_env.matrix_type = 2;	    /*		.	*/
  MAidmx (&msg, md_env.md_env.matrix); /*		.	*/
  p_objid = &objid;
 
 for (I = 0 ; I < num_objects; I++) {
 	while (((i = (drand48 () - 0.5)* range)>=(-0.25*range))&&(i<=(0.25*range)));
	while (((j = (drand48 () - 0.5)* range)>=(-0.25*range))&&(j<=(0.25*range)));
	while (((k = (drand48 () - 0.5)* range)>=(-0.25*range))&&(k<=(0.25*range)));
	     
	c = (int)(drand48 () * NumColors);
	w = (int)(drand48 () * NumWeights);
	s = (int)(drand48 () * NumStyles);
	l = (int)(drand48 () * NumLayers);
	
  status = OM_S_SUCCESS;
  msg = MSSUCC;


  ConstructList.msg = &msg;
  ConstructList.env_info = &md_env;
  symb.color = c;
  symb.style = s;
  symb.weight = w;
  ConstructList.display = &symb;
  curve.poles = points;
  curve.num_poles = 1;

  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = l;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  points [0] = i;
  points [1] = j;
  points [2] = k;

  status = om$construct( msg	= message GRgraphics.GRconstruct( &ConstructList ),
      osnum     = md_env.md_id.osnum,
      classname = "GR3dpoint",
      p_objid   = p_objid );
  }
}
  
end implementation DEso;

