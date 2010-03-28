class implementation Root;

%safe
#include <math.h>
%endsafe
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "exmacros.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "madef.h"
#include "maerr.h"
#include "stdio.h"

from GRgraphics import GRconstruct; /* constructs an object (data point here) 				*/
from GRvg       import GRgetsymb;   /* retrieves weight, color, style and level for id  */
from GRvg   	import GRgenabsg;   /* retrieves coordinates for id 			*/
from GRpoint    import GRgetobjinfo;  /* */

main ()
{
  long msg;
  struct GRmd_env env;

  FILE *rfp;  			    /* file pointers		   */
  FILE *wfp;
  double x;			    /* holds x coord    	   */
  double y;			    /* holds y coord    	   */
  double z;			    /* holds z coord    	   */
  int ids[1000];		    /* holds all object ids placed */
  struct GRobj_info	info;

  int c; 			    /* color  */
  int w; 			    /* weight */
  int s; 			    /* style  */
  int l; 			    /* level  */
  int i = 0;			    /* a counter */

  env.md_id.osnum = 2;		    /* initializing env */
  env.md_id.objid = 21;		    /*		.	*/
  env.md_env.matrix_type = 2;	    /*		.	*/
  MAidmx (&msg, env.md_env.matrix); /*		.	*/


  if ((rfp = fopen ("input/infile","r")) == NULL) dpgen(rfp); /* if the file 'infile' !exist, */  
  rfp = fopen ("input/infile","r");				/* create it			*/
  
  while (fscanf(rfp,"%s %LE %LE %LE %d %d %d %d",
                     &info.type,&x,&y,&z,&c,&w,&s,&l) != EOF)
    TSplace_3dpoint (&msg,&ids [i++],x,y,z,&env,c,w,s,l);
  fclose (rfp);						/* read file and place points	*/
  
  if ((wfp = fopen ("output/masterout","r")) != NULL) /* open new master out file if it !exist	*/
      wfp = fopen ("output/newout","w");              /* ,write to new file otherwise		*/
    else wfp = fopen ("output/masterout","w");

  for (i=0; i<1000; i++)			/* retrieve points using ids stored in	*/
  {							/* ids[]			*/
    TSretrieve_3dpoint (ids[i],&x,&y,&z,&c,&w,&s,&l,&info);
    fprintf (wfp,"%s %.16LE %.16LE %.16LE %d %d %d %d\n",info.type,x,y,z,c,w,s,l);
  }						/* and write them to file		*/
  fclose (wfp);
};

TSplace_3dpoint ( msg, p_objid, p1x, p1y, p1z, md_env, c, w, s, l)
long            *msg;
GRobjid         *p_objid;
double     p1x, p1y, p1z;
struct GRmd_env *md_env;
int c;
int w;
int s;
int l;

{
  long                  status;
  double                points [3];
  struct GRvg_construct ConstructList;
  struct IGRbsp_curve   curve;
  struct IGRdisplay     symb;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  					/* init. variables for construct */
  ConstructList.msg = msg;
  ConstructList.env_info = md_env;
  symb.color = c;
  symb.style = s;
  symb.weight = w;
  ConstructList.display = &symb;
  curve.poles = &points [0];
  curve.num_poles = 1;

  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = l;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  points [0] = p1x;
  points [1] = p1y;
  points [2] = p1z;

  status = om$construct( msg	= message GRgraphics.GRconstruct( &ConstructList ),
      osnum     = md_env->md_id.osnum,
      classname = "GR3dpoint",
      p_objid   = p_objid );

  return status;
}

TSretrieve_3dpoint (id,x,y,z,c,w,s,l,info)

GRobjid    id;
double    *x;
double    *y;
double    *z;
int       *c;
int       *w;
int       *s;
int       *l;
struct GRobj_info *info;
    
{
  IGRshort   matrixt;
  IGRmatrix  matrix;
  IGRlong    msg; 		    /* for the macro             */
  IGRlong    mesag;		    /* for the function genabsg  */
  IGRchar    *absgptr;              /* pointer to geometry       */
  struct     IGRbsp_curve   *curve;
  struct     GRsymbology    symb;
  long       status;
  
  MAidmx (&msg,matrix);		/* initialize matrix to identity */
  matrixt = 2;
  status = om$send ( msg	= message GRvg.GRgenabsg(&mesag,&matrixt,matrix,&absgptr),
      targetos = 2,
      targetid = id,
      senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  };
  status = om$send ( msg      = message GRvg.GRgetsymb ( &msg, &symb ),
      targetos = 2,
      targetid = id,
      senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  
  status = om$send ( msg      = message GRpoint.GRgetobjinfo ( &msg,info),
      targetos = 2,
      targetid = id,
      senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  
  
  curve = (struct IGRbsp_curve *) absgptr; 
  *x = curve->poles[0];
  *y = curve->poles[1];
  *z = curve->poles[2];
  *c = symb.display_attr.color;
  *w = symb.display_attr.weight;
  *s = symb.display_attr.style;
  *l = symb.level;
  
  return status;
}
dpgen(wfp)             /* this function generates data points */


FILE *wfp;

#include <stdio.h>
#include <limits.h>
#include <math.h>

{
double range = 10000;
int NumPoints = 1000;
int NumColors = 256;
int NumStyles = 8;
int NumWeights = 32;
int NumLayers = 1024;
int I;
double i, j, k;
int c, w, s, l;
double drand48(); 
fclose (wfp);
wfp = fopen ("input/infile","w");
for (I = 0; I < NumPoints; I++) {
	while (((i = (drand48 () - 0.5)* range)>=(-0.25*range))&&(i<=(0.25*range)));
	while (((j = (drand48 () - 0.5)* range)>=(-0.25*range))&&(j<=(0.25*range)));
	while (((k = (drand48 () - 0.5)* range)>=(-0.25*range))&&(k<=(0.25*range)));
	     
	c = (int)(drand48 () * NumColors);
/*	w = (int)(drand48 () * NumWeights); */
	
	if      ((i>=0)&&(j>=0)&&(k>=0)) w = 0; /* if x,y,z > 0 give weight 0      */
	else if ((i< 0)&&(j>=0)&&(k>=0)) w = 1; /* if x < 0, y,z > 0 give weight 1 */
	else if ((i>=0)&&(j< 0)&&(k>=0)) w = 2; /* ....                            */
	else if ((i< 0)&&(j< 0)&&(k>=0)) w = 3; /*        ....                     */
	else if ((i>=0)&&(j>=0)&&(k< 0)) w = 4; /*              ....               */
	else if ((i< 0)&&(j>=0)&&(k< 0)) w = 5; /*                     ....        */
	else if ((i>=0)&&(j< 0)&&(k< 0)) w = 6; /*                             ....*/
	else    			 w = 7; /* if x,y,z < 0 give weight 7      */
	
	s = (int)(drand48 () * NumStyles);
	l = (int)(drand48 () * NumLayers);
	fprintf (wfp, "Point %.16LE %.16LE %.16LE %d %d %d %d\n", i, j, k, c, w, s, l);
	}
fclose(wfp);
}

end implementation Root;


