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

#define MaxNumPoles 20
#define NumLines 200

main ()
{
  long msg;
  struct GRmd_env env;

  FILE *rfp;  			   
  FILE *wfp;
  int ids[NumLines];		    /* holds all object ids placed */
  double poles[MaxNumPoles][3];
  int NumPoles;
  int c; 			    /* color  */
  int w; 			    /* weight */
  int s; 			    /* style  */
  int l; 			    /* level  */
  int i = 0;
  int j;		
  int k;
  int M;
  int N;

  env.md_id.osnum = 2;		    /* initializing env */
  env.md_id.objid = 21;		    /*		.	*/
  env.md_env.matrix_type = 2;	    /*		.	*/
  MAidmx (&msg, env.md_env.matrix); /*		.	*/


  if ((rfp = fopen ("input/infile","r")) == NULL) dpgen(rfp); /* if the file 'infile' !exist, */  
  rfp = fopen ("input/infile","r");				/* create it			*/
  
  while ((fscanf(rfp,"%d",&NumPoles)) != EOF) {
    for (j=0;j<NumPoles;j++)
      fscanf(rfp,"%LE %LE %LE",&poles[j][0],&poles[j][1],&poles[j][2]);
    fscanf(rfp,"%d %d %d %d",&c,&w,&s,&l);
    TSplace_string (&msg,&ids [i++],NumPoles,&poles[0],&env,c,w,s,l);
    }
  fclose (rfp);						/* read file and place points	*/
  
  if ((wfp = fopen ("output/masterout","r")) != NULL) /* open new master out file if it !exist	*/
      wfp = fopen ("output/newout","w");              /* ,write to new file otherwise		*/
    else wfp = fopen ("output/masterout","w");
  for (i=0; i< NumLines; i++)			/* retrieve points using ids stored in	*/
  {							/* ids[]			*/
    TSretrieve_3dpoint (ids[i],&NumPoles,&poles[0],&c,&w,&s,&l);
    fprintf (wfp,"%d ",NumPoles);/*printf("Poles:%d, ID:%d, IDx:%d\n",NumPoles,ids[i],i);*/
     for (M = 0; M < NumPoles; M++)
      for (N = 0; N < 3; N++)
       fprintf (wfp,"%.16LE ",poles[M][N]);
    fprintf (wfp,"%d %d %d %d\n", c, w, s, l);
  }						
  fclose (wfp);
};

TSplace_string ( msg, p_objid,NumPoles,poles, md_env, c, w, s, l)
long            *msg;
GRobjid         *p_objid;
int 		NumPoles;
double	*poles;
struct 	GRmd_env *md_env;
int c;
int w;
int s;
int l;

{
  long                  status;
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
  curve.poles = &poles[0];
  curve.num_poles = NumPoles;

  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = l;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  status = om$construct( msg	= message GRgraphics.GRconstruct( &ConstructList ),
      osnum     = md_env->md_id.osnum,
      classname = "GR3dlinestr",
      p_objid   = p_objid );

  return status;
}

TSretrieve_3dpoint (id,NumPolesp,polesp,c,w,s,l)

GRobjid    id;
int	   *NumPolesp;
double *polesp;
int        *c;
int        *w;
int        *s;
int        *l;
    
{
  IGRshort   matrixt;
  IGRmatrix  matrix;
  IGRlong    msg; 		/* for the macro */
  IGRlong    mesag;		/* for the function genabsg */
  IGRchar    *absgptr;
  struct     IGRbsp_curve   *curve;
  struct     GRsymbology    symb;
  long       status;
  int 	     i,j;
    
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
  *NumPolesp = curve->num_poles; 
  for (i = 0; i < (curve->num_poles); i++)
    for (j = 0; j < 3; j++)
      polesp[3*i+j] = curve->poles[3*i+j];
  *c = symb.display_attr.color;
  *w = symb.display_attr.weight;
  *s = symb.display_attr.style;
  *l = symb.level;

  return status;
}

dpgen(wfp)
FILE *wfp;
/* This function generates real numbers and writes them to the file "infile" */

#include <stdio.h>
#include <limits.h>
#include <math.h>

{
double range = 10000;
int NumColors = 256;
int NumStyles = 8;
int NumWeights = 32;
int NumLayers = 1024;
int I,J,M,N;
double i, j, k;
int c, w, s, l;
int NumPoles;
double poles[MaxNumPoles][3];
double drand48(); 
wfp = fopen ("input/infile","w");
for (I = 0; I < NumLines; I++) {
	while ((NumPoles = (int)((drand48() * MaxNumPoles)+1)) == 1);
	for (J = 0; J < NumPoles; J++) { 
         while (((i = (drand48 () - 0.5)* range)>=(-0.25*range))&&(i<=(0.25*range)));
	 while (((j = (drand48 () - 0.5)* range)>=(-0.25*range))&&(j<=(0.25*range)));
	 while (((k = (drand48 () - 0.5)* range)>=(-0.25*range))&&(k<=(0.25*range)));
	 poles[J][0] = i; /*printf ("%LE\n",i);*/
	 poles[J][1] = j; /*printf ("%LE\n",j);*/
	 poles[J][2] = k; /*printf ("%LE\n \n",k);*/
	}     
/*	printf ("\n"); */
	c = (int)(drand48 () * NumColors);
/*	w = (int)(drand48 () * NumWeights); */
	
	if      ((i>=0)&&(j>=0)&&(k>=0)) w = 0;
	else if ((i< 0)&&(j>=0)&&(k>=0)) w = 1;
	else if ((i>=0)&&(j< 0)&&(k>=0)) w = 2;
	else if ((i< 0)&&(j< 0)&&(k>=0)) w = 3;
	else if ((i>=0)&&(j>=0)&&(k< 0)) w = 4;
	else if ((i< 0)&&(j>=0)&&(k< 0)) w = 5;
	else if ((i>=0)&&(j< 0)&&(k< 0)) w = 6;
	else    		         w = 7;
	
	s = (int)(drand48 () * NumStyles);
	l = (int)(drand48 () * NumLayers);
	fprintf (wfp, "%d ",NumPoles);
	for (M = 0; M < NumPoles; M++)
	  for (N = 0; N < 3; N++)
	    fprintf (wfp,"%.16LE ",poles[M][N]);
	    /* printf ("%.16LE\n ",poles[M][N]) */
	fprintf (wfp,"%d %d %d %d\n", c, w, s, l);
	} 
fclose(wfp);
}

end implementation Root;


