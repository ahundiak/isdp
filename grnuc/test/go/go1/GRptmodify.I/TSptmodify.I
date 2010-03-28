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

from GRgraphics import GRconstruct; /* places an object         */
from GRvg       import GRgetsymb;   /* retrieves weight, color, style and level for id  */
from GRvg       import GRgenabsg;   /* retrieves coordinates for id       */
from GRpoint    import GRmodify;

#define MaxNumPoles 20
#define NumLines 200

main ()
{
  long msg;
  struct GRmd_env env;

  FILE *rfp;
  FILE *wfp;
  int ids[NumLines];        /* holds all object ids placed */
  double poles[MaxNumPoles][3];
  int NumPoles;
  double drand48();
  int c;           /* color  */
  int w;           /* weight */
  int s;           /* style  */
  int l;           /* level  */
  int i = 0;
  int j;
  int k;
  int M;
  int N;
  int NewNumPoles;
  struct   IGRpolyline   polyline;
  GRobjid  new_objid;
  struct   GRpost_info   post_info;
  long     status;
  struct   GRparms       vert_loc;
  IGRpoint point;
  struct   IGRline       boreline;
  double array[3];
  double another[3];
/* initialize array */

  for (i = 0; i < MaxNumPoles; i++)
   for (j = 0; j < 3; j++)
    poles [i][j] = 0;

  env.md_id.osnum = 2;        /* initializing env */
  env.md_id.objid = 21;        /*    .  */
  env.md_env.matrix_type = 2;      /*    .  */
  MAidmx (&msg, env.md_env.matrix); /*    .  */

  /* check if the input file exists, if it doesn't, generate it */

  if ((rfp = fopen ("input/infile","r")) == NULL) dpgen(rfp);
  rfp = fopen ("input/infile","r");

  /* read input file and place the objects found there */

  i = 0;
  while ((fscanf(rfp,"%d %d",&NumPoles,&post_info.construct_flag)) != EOF) {
    for (j=0;j<NumPoles;j++)
      fscanf(rfp,"%LE %LE %LE",&poles[j][0],&poles[j][1],&poles[j][2]);
    fscanf(rfp,"%d %d %d %d %d",&c,&w,&s,&l,&NewNumPoles);
    TSplace_point (&msg,&ids [i++],&poles[0],&env,c,w,s,l);
  }
  fclose (rfp);

  /* read again input file, this time to execute the routine modify */

  i = 0;
  rfp = fopen ("input/infile","r");
  new_objid = 5000;
  while ((fscanf(rfp,"%d %d",&NumPoles,&post_info.construct_flag)) != EOF) {
    for (j=0;j<NumPoles;j++)
      fscanf(rfp,"%LE %LE %LE",&poles[j][0],&poles[j][1],&poles[j][2]);
    fscanf(rfp,"%d %d %d %d %d",&c,&w,&s,&l,&NewNumPoles);
    boreline.point1 = &another[0];
    boreline.point1[0] = poles[0][0];
    boreline.point1[1] = poles[0][1];
    boreline.point1[2] = poles[0][2];
    boreline.point2 = &array[0];
    boreline.point2[0] = boreline.point2[1] = boreline.point2[2] = 0; 
        
    status = om$send ( msg  = message GRpoint.GRmodify(&msg,
        &env,&vert_loc,point,&boreline,&new_objid),
        targetos = 2,
        targetid = ids[i],
        senderid = NULL_OBJID );
    /* printf ("Old id:%d\tnew id:%d\tflag:%d\n",
          ids[i],new_objid,post_info.construct_flag); */
    if (!(status & 1)) {
      printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    };
    ids[i++] = new_objid;
  };

  /* check if master output file exists to create new file or master */

  if ((wfp = fopen ("output/masterout","r")) != NULL)
    wfp = fopen ("output/newout","w");
  else wfp = fopen ("output/masterout","w");

  /* retrieve objects by id number stored in array ids[] */

  for (i=0; i< NumLines; i++)
  {
    TSretrieve_3dpoint (ids[i],&NumPoles,&poles[0],&c,&w,&s,&l);
    fprintf (wfp,"%d ",NumPoles);/*printf("Poles:%d, ID:%d, IDx:%d\n",NumPoles,ids[i],i);*/
    for (M = 0; M < NumPoles; M++)
      for (N = 0; N < 3; N++)
        fprintf (wfp,"%.16LE ",poles[M][N]);
    fprintf (wfp,"%d %d %d %d\n", c, w, s, l);
  }
  fclose (wfp);
};

TSplace_point ( msg, p_objid,poles, md_env, c, w, s, l)
long            *msg;
GRobjid         *p_objid;
double  *poles;
struct   GRmd_env *md_env;
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

  /* init. variables for construct */

  ConstructList.msg = msg;
  ConstructList.env_info = md_env;
  symb.color = c;
  symb.style = s;
  symb.weight = w;
  ConstructList.display = &symb;
  curve.poles = &poles[0];
  curve.num_poles = 1;

  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = l;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  status = om$construct( msg  = message GRgraphics.GRconstruct( &ConstructList ),
      osnum     = md_env->md_id.osnum,
      classname = "GR3dpoint",
      p_objid   = p_objid );

  return status;
}

TSretrieve_3dpoint (id,NumPolesp,polesp,c,w,s,l)

GRobjid    id;
int     *NumPolesp;
double *polesp;
int        *c;
int        *w;
int        *s;
int        *l;

{
  IGRshort   matrixt;
  IGRmatrix  matrix;
  IGRlong    msg;     /* for the macro */
  IGRlong    mesag;    /* for the function genabsg */
  IGRchar    *absgptr;
  struct     IGRbsp_curve   *curve;
  struct     GRsymbology    symb;
  long       status;
  int        I,J;

  MAidmx (&msg,matrix);    /* initialize environment matrix to identity */
  matrixt = 2;

  /* get the abstract geometry */

  status = om$send ( msg  = message GRvg.GRgenabsg(&mesag,&matrixt,
      matrix,&absgptr),
      targetos = 2,
      targetid = id,
      senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  };

  /* get the symbology */

  status = om$send ( msg      = message GRvg.GRgetsymb ( &msg, &symb ),
      targetos = 2,
      targetid = id,
      senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "Error in file %s at line %d\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }

  /* assign methods returns to the function parameters */

  curve = (struct IGRbsp_curve *) absgptr;
  *NumPolesp = curve->num_poles;
  for (I = 0; I < (curve->num_poles); I++)
    for (J = 0; J < 3; J++)
      polesp[3*I+J] = curve->poles[3*I+J];
  *c = symb.display_attr.color;
  *w = symb.display_attr.weight;
  *s = symb.display_attr.style;
  *l = symb.level;

  return status;
}

/* generate strings with random number of poles, coordinates, color, weight, 
   style and level. Also generate the new number of poles that the function
   being tested is going to use upon each string */

dpgen(wfp)
FILE *wfp;

#include <stdio.h>
#include <limits.h>
#include <math.h>

{
  double range = 10000;
  int NumColors = 256;
  int NumStyles = 8;
  /* int NumWeights = 32; deleted because we'll use only 8. */
  int NumLayers = 1024;
  int I,J,M,N;
  double i, j, k;
  int c, w, s, l;
  int NumPoles;
  double poles[MaxNumPoles][3];
  double drand48();
  int NewNumPoles;
  int Construct_flag;
  wfp = fopen ("input/infile","w");
  
/* initialize the matrix */

  for (I = 0; I < MaxNumPoles; I++)
   for (J = 0; J < 3; J++)
    poles [I][J] = 0;  

  for (I = 0; I < NumLines; I++) {
    while ((NumPoles = (int)((drand48() * MaxNumPoles)+1)) == 1);
    for (J = 0; J < NumPoles; J++) {
      while (((i = (drand48 () - 0.5)* range)>=(-0.25*range))&&(i<=(0.25*range)));
      while (((j = (drand48 () - 0.5)* range)>=(-0.25*range))&&(j<=(0.25*range)));
      while (((k = (drand48 () - 0.5)* range)>=(-0.25*range))&&(k<=(0.25*range)));
      poles[J][0] = i;
      poles[J][1] = j;
      poles[J][2] = k;
      };
      
      c = (int)(drand48 () * NumColors);

      if      ((i>=0)&&(j>=0)&&(k>=0)) w = 0;
      else if ((i< 0)&&(j>=0)&&(k>=0)) w = 1;
      else if ((i>=0)&&(j< 0)&&(k>=0)) w = 2;
      else if ((i< 0)&&(j< 0)&&(k>=0)) w = 3;
      else if ((i>=0)&&(j>=0)&&(k< 0)) w = 4;
      else if ((i< 0)&&(j>=0)&&(k< 0)) w = 5;
      else if ((i>=0)&&(j< 0)&&(k< 0)) w = 6;
      else w = 7;

      s = (int)(drand48 () * NumStyles);
      l = (int)(drand48 () * NumLayers);
      NewNumPoles = (int)(drand48 () * MaxNumPoles +1);
      Construct_flag = (int)(drand48() + 0.5);
      fprintf (wfp, "%d %d\n",NumPoles,Construct_flag);
      for (M = 0; M < NumPoles; M++) {
        for (N = 0; N < 3; N++)
          fprintf (wfp,"%.16LE ",poles[M][N]);
        fprintf (wfp,"\n");
        }
      fprintf (wfp,"%d %d %d %d\n %d\n \n", c, w, s, l, NewNumPoles);
    }
  fclose(wfp);
}

end implementation Root;
