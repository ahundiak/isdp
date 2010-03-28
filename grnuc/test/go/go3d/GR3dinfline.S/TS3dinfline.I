/* This program reads data points from file called "infile" and sends them to EMS */
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

from GRgraphics import GRconstruct; /* places an object 				*/
from GRvg       import GRgetsymb;   /* retrieves weight, color, style and level for id  */
from GRvg   	import GRgenabsg;   /* retrieves coordinates for id 			*/

main ()
{
  long msg;
  struct GRmd_env env;

  FILE *rfp;  			   
  FILE *wfp;
  double x1;			    /* holds x coord    	   */
  double y1;			    /* holds y coord    	   */
  double z1;			    /* holds z coord    	   */
  double x2;
  double y2;
  double z2;
  int ids[1000];		    /* holds all object ids placed */

  int c; 			    /* color  */
  int w; 			    /* weight */
  int s; 			    /* style  */
  int l; 			    /* level  */
  int i = 0;			    

  env.md_id.osnum = 2;		    /* initializing env */
  env.md_id.objid = 21;		    /*		.	*/
  env.md_env.matrix_type = 2;	    /*		.	*/
  MAidmx (&msg, env.md_env.matrix); /*		.	*/


  if ((rfp = fopen ("input/infile","r")) == NULL) dpgen(rfp); /* if the file 'infile' !exist, */  
  rfp = fopen ("input/infile","r");				/* create it			*/
  
  while (fscanf(rfp,"%LE %LE %LE %LE %LE %LE %d %d %d %d",
  		     &x1,&y1,&z1,&x2,&y2,&z2,&c,&w,&s,&l) != EOF)
    TSplace_line (&msg,&ids [i++],x1,y1,z1,x2,y2,z2,&env,c,w,s,l);
  fclose (rfp);						/* read file and place
  							 lines	*/
  
  if ((wfp = fopen ("output/masterout","r")) != NULL) /* open new master out file if it !exist	*/
      wfp = fopen ("output/newout","w");              /* ,write to new file otherwise		*/
    else wfp = fopen ("output/masterout","w");

  for (i=0; i<1000; i++)			/* retrieve points using ids stored in	*/
  {							/* ids[]			*/
    TSretrieve_line (ids[i],&x1,&y1,&z1,&x2,&y2,&z2,&c,&w,&s,&l);
    fprintf (wfp,"%.16LE %.16LE %.16LE %.16LE %.16LE %.16LE %d %d %d %d\n"
    		  ,x1,   y1,    z1,    x2,    y2,    z2,    c, w, s, l);
  }						/* and write them to file		*/
  fclose (wfp);
};

TSplace_line ( msg, p_objid, p1x, p1y, p1z, p2x, p2y, p2z, md_env, c, w, s, l)
long            *msg;
GRobjid         *p_objid;
double     	p1x, p1y, p1z, p2x, p2y, p2z;
struct 	GRmd_env *md_env;
int c;
int w;
int s;
int l;

{
  long                  status;
  double                points [6];
  struct GRvg_construct ConstructList;
  struct IGRbsp_curve   curve;
  struct IGRdisplay     symb;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* init. varables for construct */
  ConstructList.msg = msg;
  ConstructList.env_info = md_env;
  symb.color = c;
  symb.style = s;
  symb.weight = w;
  ConstructList.display = &symb;
  curve.poles = &points [0];
  curve.num_poles = 2;

  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = l;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  points [0] = p1x;
  points [1] = p1y;
  points [2] = p1z;
  points [3] = p2x;
  points [4] = p2y;
  points [5] = p2z;  

  status = om$construct( msg	= message GRgraphics.GRconstruct( &ConstructList ),
      osnum     = md_env->md_id.osnum,
      classname = "GR3dinfline",
      p_objid   = p_objid );

  return status;
}

TSretrieve_line (id,x1,y1,z1,x2,y2,z2,c,w,s,l)

GRobjid    id;
double    *x1;
double    *y1;
double    *z1;
double    *x2;
double    *y2;
double    *z2;
int    *c;
int    *w;
int    *s;
int    *l;
    
{
  IGRshort   matrixt;
  IGRmatrix  matrix;
  IGRlong    msg; 		/* for the macro */
  IGRlong    mesag;		/* for the function genabsg */
  IGRchar    *absgptr;
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
  curve = (struct IGRbsp_curve *) absgptr; 
  *x1 = curve->poles[0];
  *y1 = curve->poles[1];
  *z1 = curve->poles[2];
  *x2 = curve->poles[3];
  *y2 = curve->poles[4];
  *z2 = curve->poles[5];  
  *c = symb.display_attr.color;
  *w = symb.display_attr.weight;
  *s = symb.display_attr.style;
  *l = symb.level;

  return status;
}

dpgen(wfp)

FILE *wfp;

#include <stdio.h>
#include <limits.h>
#include <math.h>
{
double range = 10000;
int NumLines = 1000;
int NumColors = 256;
int NumStyles = 8;
int NumWeights = 32;
int NumLayers = 1024;
int I;
double i1, j1, k1, i2, j2, k2;
int c, w, s, l;
double drand48(); 
wfp = fopen ("input/infile","w");
for (I = 0; I < NumLines; I++) {
	while (((i1 = (drand48 () - 0.5)* range)>=(-0.25*range))&&(i1<=(0.25*range)));
	while (((j1 = (drand48 () - 0.5)* range)>=(-0.25*range))&&(j1<=(0.25*range)));
	while (((k1 = (drand48 () - 0.5)* range)>=(-0.25*range))&&(k1<=(0.25*range)));
	while (((i2 = (drand48 () - 0.5)* range)>=(-0.25*range))&&(i2<=(0.25*range)));
	while (((j2 = (drand48 () - 0.5)* range)>=(-0.25*range))&&(j2<=(0.25*range)));
	while (((k2 = (drand48 () - 0.5)* range)>=(-0.25*range))&&(k2<=(0.25*range)));
	     
	c = (int)(drand48 () * NumColors);
	
	if      ((i1>=0)&&(j1>=0)&&(k1>=0)) w = 0;
	else if ((i1< 0)&&(j1>=0)&&(k1>=0)) w = 1;
	else if ((i1>=0)&&(j1< 0)&&(k1>=0)) w = 2;
	else if ((i1< 0)&&(j1< 0)&&(k1>=0)) w = 3;
	else if ((i1>=0)&&(j1>=0)&&(k1< 0)) w = 4;
	else if ((i1< 0)&&(j1>=0)&&(k1< 0)) w = 5;
	else if ((i1>=0)&&(j1< 0)&&(k1< 0)) w = 6;
	else    			    w = 7;
	
	s = (int)(drand48 () * NumStyles);
	l = (int)(drand48 () * NumLayers);
	fprintf (wfp, "%.16LE %.16LE %.16LE %.16LE %.16LE %.16LE %d %d %d %d\n",
			i1,   j1,    k1,    i2,    j2,    k2,    c, w, s, l);
	} 
fclose(wfp);
}

end implementation Root;


