class implementation VLstretchV;

#include        <math.h>
#include	"AS_status.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"DIdef.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"msmacros.h"
#include	"msdef.h"
#include	"vddrwattr.h"
#include	"vsplatedef.h"
#include	"asmacros.h"
#include 	"ACrg_collect.h"
#include 	"igr.h"
#include 	"ACattrib.h"
#include 	"nddef.h"
#include	"vlstructure.h"
#include        "vsmiscmacros.h"
#include        "vldbgmacros.h"
#include	"vlstrechval.h"
#include	"vds.h"
#include	"vlmsg.h"
#include	"bserr.h"
#include 	"cotxmacros.h"
#include 	"gotextdef.h"
#include 	"bsdistptpt.h"
#include 	"vlunfold.h"
#include        "bsnorvec.h"
#include        "bsdistptpt.h"
#include        "bstst_plan.h"
#include        "bsarclen.h"

from    EMSsubbs        import  EMisoparcvs;
from    VLunwrap        import  getRoots;
from    GRtext          import  GRgettxattr;

extern GRclassid        OPP_GR3dlinestr_class_id, OPP_VLunwrap_class_id,
			OPP_VLunwObj_class_id ;
extern void		BScveval(), BSsfeval();

/* *********************************************************************** *
  Given a stretchV object and the number of a text-feet, this function 
  returns the value of this text.
 * *********************************************************************** */
long VLget_strech_val (
         struct GRobj_env *strech, /* I: id of the stretchV object */
         int num_feet,             /* I: the feet number */
         double *val               /* O: returned value */
                       )
{
long sts,msg,loc_msg;
char name_feet[50];
struct GRobj_env text;
int		 tmp;
IGRuchar 		 *val_string = NULL;

  msg = MSFAIL;
  sprintf(name_feet,"feet%d",num_feet);
  sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                       &loc_msg,
                                       name_feet,
                                       &(text.obj_id),
                                       &(text.mod_env.md_env.matrix_type),
                                       text.mod_env.md_env.matrix),
  targetid        = strech->obj_id.objid,
  targetos        = strech->obj_id.osnum,
  senderid        = NULL_OBJID );
  if (!(sts&loc_msg&1)) goto quit;
  if (strech->mod_env.md_env.matrix_type != MAIDMX) {
    tmp = 4;
    MAmulmx(&loc_msg,&tmp,&tmp,&tmp,strech->mod_env.md_env.matrix,
            text.mod_env.md_env.matrix,text.mod_env.md_env.matrix);
    MAtypemx( &loc_msg, text.mod_env.md_env.matrix,
                                   &(text.mod_env.md_env.matrix_type));
  }
  
  sts = om$send( msg      = message GRtext.GRgettxattr(
                                       &loc_msg,
                                       NULL,
                                       NULL,
                                       &val_string),
  targetid        = text.obj_id.objid,
  targetos        = text.obj_id.osnum,
  senderid        = NULL_OBJID );
  if (!(sts&loc_msg&1)) goto quit;
  sscanf((char *)val_string,"%lf",val);

  msg = MSSUCC;
quit :
  if (val_string) {free(val_string); val_string = NULL;}
  return msg;
}

/* *********************************************************************** *
  This function creates the arrow foot of the macro. 
 * *********************************************************************** */
long VLcreate_arrow(
              GRobjid cv1,                 /* I: curve1 */
              GRobjid cv2,                 /* I: curve2 */
              double  par,                 /* I: parameter on cv1 and cv2 */
              struct  GRvg_construct *cst, /* I: construction list */
              struct GRid *arrow)          /* I: returned arrow */
{
long 			msg,loc_msg,sts;
BSrc			bsrc;
struct IGRbsp_curve	*cv;
double			point[16];
double			pt[6],dist,dist3;
double			vec[4];
int			tmp;
struct IGRpolyline	geom;

  msg = MSFAIL;
  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = cv1,
                  targetos = cst->env_info->md_id.osnum);
  if (!(loc_msg&sts&1))  {goto quit;}

// find three points on cv1

  BScveval(cv,par,0,point,&bsrc);
  if (bsrc != BSSUCC) goto quit;
  BScveval(cv,par-0.005,0,&pt[0],&bsrc);
  if (bsrc != BSSUCC) goto quit;
  BScveval(cv,par+0.005,0,&pt[3],&bsrc);
  if (bsrc != BSSUCC) goto quit;
  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = cv2,
                  targetos = cst->env_info->md_id.osnum);
  if (!(loc_msg&sts&1))  {goto quit;}

// find one point on cv2
  BScveval(cv,par,0,&point[3],&bsrc);
  vec[0] = point[3]-point[0];
  vec[1] = point[4]-point[1];
  vec[2] = point[5]-point[2];
  vec[3] = 0;
  BSnorvec(&bsrc,vec);
  if (bsrc != BSSUCC) goto quit;
  dist = BSdistptpt(&bsrc,point,&point[3]);
  dist3 = dist/4.5;
  dist = dist/4.;
  if (bsrc != BSSUCC) goto quit;
  point[3] = point[0]+ dist*vec[0];
  point[4] = point[1]+ dist*vec[1];
  point[5] = point[2]+ dist*vec[2];

  point[6] = pt[0] + dist3*vec[0];
  point[7] = pt[1] + dist3*vec[1];
  point[8] = pt[2] + dist3*vec[2];

  point[9] = pt[3] + dist3*vec[0];
  point[10] = pt[4] + dist3*vec[1];
  point[11] = pt[5] + dist3*vec[2];

  point[12] = point[3];
  point[13] = point[4];
  point[14] = point[5];
  
 // construct arrow

  tmp = cst->display->weight;
  cst->display->weight = 3;
  cst->geometry = (char *) &geom;
  geom.num_points = 5;
  geom.points = point;
  arrow->objid = NULL_OBJID;
  arrow->osnum = cst->env_info->md_id.osnum;
  sts = om$construct( classid = OPP_GR3dlinestr_class_id, 
	              p_objid = &(arrow->objid),
         	      osnum   = arrow->osnum,
		      msg     = message GRgraphics.GRaltconstruct(cst) );
  if (!(sts&1)) goto quit;
  cst->display->weight = tmp;

  msg = MSSUCC;
  quit :
  return msg;
}

/* *********************************************************************** *
  Given a list of parameter (param_for_length), this function computes 
  the sum of arc lengthes between knots which are between consecutif 
  parameters.
 * *********************************************************************** */
long VLcomputeLength3D(
     GRobjid                *iso,  /* I: isocurve on the unit surface */
     struct IGRbsp_surface  *srf3d,/* I: 3D surface */
     int                    nb_uv, /* I: number of knots on the isocurve*/
     double                 *uv,   /* I: knots on the isocurve */
     double                 *param_for_length, /* I: parameters on the iso
                                                     to compute lengthes
                                                     between it */
     struct  GRvg_construct *cst,              /* I: construction list */
     double                 *sf3d_length       /* O: lengthes betwen 
                                                     parameters of 
                                                     param_for_length */
                       )
{
long            msg,sts,loc_msg;
struct IGRbsp_curve     *cv=NULL;
int             jj,kk,l=0;
IGRpoint        point,point3d,point2d;
double          len;
BSrc            bsrc;

  msg = MSFAIL;
  l = 0;

  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = *iso,
                  targetos = cst->env_info->md_id.osnum);
  if (!(loc_msg&sts&1))  {goto quit;}

  len = 0;
  BScveval(cv,uv[0],0,point2d,&bsrc);
  if (bsrc != BSSUCC) goto quit;
  BSsfeval(srf3d,point2d[0],point2d[1],0,point3d,&bsrc);
  if (bsrc != BSSUCC) goto quit;
  for (kk=1,jj=1;jj<nb_uv;jj++)
  {
      BScveval(cv,uv[jj],0,point2d,&bsrc);
      if (bsrc != BSSUCC) goto quit;
      BSsfeval(srf3d,point2d[0],point2d[1],0,point,&bsrc);
      if (bsrc != BSSUCC) goto quit;
      len += BSdistptpt(&bsrc,point3d,point);
      point3d[0] = point[0];
      point3d[1] = point[1];
      point3d[2] = point[2];
      if (
          (uv[jj] -  param_for_length[kk] < 0.00001) &&
          (uv[jj] -  param_for_length[kk] > -0.00001)
          ) {
         sf3d_length[l] = len;
         l++;
         kk++;
         len = 0;
      }
  }
  msg = MSSUCC;
quit :
  return msg;
}

/* *********************************************************************** *
  This function creates the feet of the macro for a boundary unwrap
  option.
 * *********************************************************************** */

long VLarcLStrV (
              struct GRobj_env *unw,   /* I: unwraped plate obj */
              struct mise_a_plat *dev,
              int nb_step_in_u,        /* I: number of steps in u */
              int nb_step_in_v,        /* I: number of steps in v */
              struct  GRvg_construct  *cst,
              int *numFeet,            /* O: number of sterch values
                                             and iso curves which will
                                             be the feet of the macro */
              struct GRid *Flist       /* O : the list of this feet */
            )
{
long			msg,loc_msg,sts;
int			i,j,k;
int			tmp,max;
IGRdouble		mid,pt[8],*point = NULL;
IGRdouble		*param_u = NULL;
IGRdouble		*param_v = NULL; 
IGRdouble		*param2d_u = NULL; 
IGRdouble		*param2d_v = NULL; 
IGRdouble		*unw_length = NULL; 
IGRdouble		*sf3d_length = NULL; 
IGRdouble	        mat[16],matrix[16];
IGRdouble		*mat_u,*mat_v;
struct IGRbsp_curve	*cv=NULL;
struct IGRbsp_surface	*unwSrf=NULL;
BSrc			bsrc;
IGRuchar		number[20];
IGRshort		len;
struct IGRlbsys		lbsys;
struct GRobj_env        unw_surf,unit_surf;
struct  IGRpolyline     geom;
int			index_cv_v;
struct IGRbsp_surface	*srf2d = NULL;
long 		        numCurves;
GRobjid         	*iso = NULL;

   msg = MSFAIL;
   mat_u = mat_v = NULL;
   *numFeet = 0;

   if( vs$is_ancestry_valid(    object = &unw->obj_id,
                                classid = OPP_VLunwrap_class_id ) )
   {
      // get the name feet of the unwrap, we want the matrix of this text
      sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &loc_msg,
                                      UNFOLD_NAM_NAME,
                                      &unw_surf.obj_id,
                                      &unw_surf.mod_env.md_env.matrix_type,
                                      unw_surf.mod_env.md_env.matrix ),
                               senderid = NULL_OBJID,
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
      if (!(sts&loc_msg&1)) {
          goto quit;
      }
      if (unw->mod_env.md_env.matrix_type != MAIDMX) {
    	  tmp = 4;
    	  MAmulmx(&loc_msg,&tmp,&tmp,&tmp,unw->mod_env.md_env.matrix,
            unw_surf.mod_env.md_env.matrix,unw_surf.mod_env.md_env.matrix);
    	  MAtypemx( &loc_msg, unw_surf.mod_env.md_env.matrix,
                                   &(unw_surf.mod_env.md_env.matrix_type));
      }

      // get the geometry of the text, we will use its matrix later
      sts = om$send( msg    = message GRvg.GRgetgeom(
                                        &loc_msg,
                                        &(unw_surf.mod_env.md_env.matrix_type),
                                        unw_surf.mod_env.md_env.matrix,
                                        (IGRchar *) &lbsys),
                               senderid = NULL_OBJID,
                               targetid = unw_surf.obj_id.objid,
                               targetos = unw_surf.obj_id.osnum ) ;
      if (!(sts&loc_msg&1)) {
    	 goto quit;
      }
  }
  else if( vs$is_ancestry_valid(    object = &unw->obj_id,
                                   classid = OPP_VLunwObj_class_id ) )
  {
	VDpartAttr  attr ;
        attr.Iwant = VL_I_toMat ;
        attr.specific = (void *) lbsys.matrix ;
	sts = om$send( msg    = message GRvg.GRgetattr( &loc_msg, 
							(char *)&attr ),
                               senderid = NULL_OBJID,
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
        __CheckRC( sts, loc_msg, "GRvg.GRgetattr", quit ) ;
  }

  // construct a rotation matrix
  for (i=0;i<16;i++) mat[i]=0;
  mat[1]=mat[10]=mat[15]=1;
  mat[4] = -1;

  i=4;
  MAmulmx(&loc_msg,&i,&i,&i,lbsys.matrix,mat,matrix);

  // find the unwraped surface
  sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &loc_msg,
                                      UNFOLD_NAM_UNWSRF,
                                      &unw_surf.obj_id,
                                      &unw_surf.mod_env.md_env.matrix_type,
                                      unw_surf.mod_env.md_env.matrix ),
                               senderid = NULL_OBJID,
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
  if (!(sts&loc_msg&1)) {
    goto quit;
  }
  if (unw->mod_env.md_env.matrix_type != MAIDMX) {
    tmp = 4;
    MAmulmx(&loc_msg,&tmp,&tmp,&tmp,unw->mod_env.md_env.matrix,
            unw_surf.mod_env.md_env.matrix,unw_surf.mod_env.md_env.matrix);
    MAtypemx( &loc_msg, unw_surf.mod_env.md_env.matrix,
                                   &(unw_surf.mod_env.md_env.matrix_type));
  }
  sts = VLgetGeometry(&unw_surf,FALSE,NULL_OBJID,&unwSrf,&loc_msg);
  if (!(sts&loc_msg&1)) goto quit;
  sts  = VLgetGeometry(&dev->surf_id, FALSE, NULL_OBJID,
                          (IGRchar ** )&dev->surface, &loc_msg );
  if( ! (sts&loc_msg&1)) goto quit;

  param2d_u = (IGRdouble *) malloc(nb_step_in_u*sizeof(double));
  if (param2d_u == NULL)   {goto quit;}
  param2d_v = (IGRdouble *) malloc(nb_step_in_v*sizeof(double));
  if (param2d_v == NULL)   {goto quit;}
  param_u = (IGRdouble *) malloc(nb_step_in_u*sizeof(double)); 
  if (param_u == NULL)  {goto quit;}
  param_v = (IGRdouble *) malloc(nb_step_in_v*sizeof(double));
  if (param_v == NULL)   {goto quit;}
  if (nb_step_in_u > nb_step_in_v) max = nb_step_in_u;
  else max = nb_step_in_v;
  point = (IGRdouble *) malloc(3*max*sizeof(double));
  if (point == NULL)   {goto quit;}

  // is the surface planar ?
  BStst_plan( ( dev->surface->u_num_poles * dev->surface->v_num_poles ),
               dev->surface->poles,
               dev->surface->weights,
               &dev->developpable,
               pt,
               &loc_msg );
  if( loc_msg != BSSUCC ){
        printf("Error BStst_plan\n");
        goto quit;
  }
    // find the unit surface
    sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &loc_msg,
                                      UNFOLD_NAM_UVSRF,
                                      &unit_surf.obj_id,
                                      &unit_surf.mod_env.md_env.matrix_type,
                                      unit_surf.mod_env.md_env.matrix ),
                               senderid = NULL_OBJID,
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
    if (!(sts&loc_msg&1)) {
      goto quit;
    }

    // get surfaces's geometries
    sts = VLgetGeometry(&unit_surf,FALSE,NULL_OBJID,&srf2d,&loc_msg);
    if (!(sts&loc_msg&1)) goto quit;

  if (!dev->developpable) {
    unw_length = (IGRdouble *) malloc(max*sizeof(double));
    if (unw_length == NULL)   {goto quit;}
    sf3d_length = (IGRdouble *) malloc(max*sizeof(double));
    if (sf3d_length == NULL)   {goto quit;}
  }

  // compute u values

  tmp = nb_step_in_u -1;
  for (i=0;i<tmp; i++){
    mid = (IGRdouble) i/tmp;
    for (j=0; j < unwSrf->u_num_knots-1; j++)

             // take the nearest parameter
      if (mid >= unwSrf->u_knots[j] && mid < unwSrf->u_knots[j+1]) {
        param_u[i] = unwSrf->u_knots[j]; // u parameters on the unwrap surface
        param2d_u[i] = srf2d->u_knots[j];// u parameters on the unit surface 
        break;
    }
  }
  param_u[nb_step_in_u-1] = 1;
  param2d_u[nb_step_in_u-1] = 1;

  // compute v values

  tmp = nb_step_in_v -1;
  for (i=0;i<tmp; i++)
  {
    mid = (IGRdouble) i/tmp;
    for (j=0; j < unwSrf->v_num_knots-1; j++)

             // take the nearest parameter
      if (mid >= unwSrf->v_knots[j] && mid < unwSrf->v_knots[j+1]) {
        param_v[i] = unwSrf->v_knots[j];
        param2d_v[i] = srf2d->v_knots[j];// v parameters on the unit surface 
        break;
    }
  }
  param_v[nb_step_in_v-1] = 1;
  param2d_v[nb_step_in_v-1] = 1;

  // construct the U feet line strings
  *numFeet = IDX_VFEET;
  for (i=0;i<nb_step_in_u;i++)
  {
    k=0;
    for (j=0;j<nb_step_in_v;j++) {
      BSsfeval(unwSrf,param_u[i],param_v[j],0,&point[k],&bsrc);
      if (bsrc != BSSUCC) goto quit;
      k += 3;
    }
    geom.num_points = nb_step_in_v;
    geom.points = point;
    cst->geometry = (char *) &geom;
    Flist[*numFeet].osnum = cst->env_info->md_id.osnum;
    sts = om$construct( classid = OPP_GR3dlinestr_class_id,
                           osnum   = Flist[*numFeet].osnum,
                           p_objid = &Flist[*numFeet].objid );
    if (!(sts&1)) goto quit;
    sts = om$send(msg      = message GRgraphics.GRaltconstruct(cst),
                     senderid = NULL_OBJID,
                     targetid = Flist[*numFeet].objid,
                     targetos = Flist[*numFeet].osnum );
  
    (*numFeet)++;
  }

  // create the first feet of the macro
  sts = VLcreate_arrow(Flist[IDX_VFEET].objid,Flist[IDX_VFEET+1].objid,
                       (param_u[0]+param_u[1])/5.,
                       cst,&Flist[IDX_FFEET]);
  if (!(sts&1)) goto quit;

  index_cv_v = *numFeet;  // save the index of the V feet line strings

  // construct the V feet line strings
  for (i=0;i<nb_step_in_v;i++)
  {
    k=0;
    for (j=0;j<nb_step_in_u;j++) {
      BSsfeval(unwSrf,param_u[j],param_v[i],0,&point[k],&bsrc);
      if (bsrc != BSSUCC) goto quit;
      k += 3;
    }
    geom.num_points = nb_step_in_u;
    geom.points = point;
    cst->geometry = (char *) &geom;
    Flist[*numFeet].osnum = cst->env_info->md_id.osnum;
    sts = om$construct( classid = OPP_GR3dlinestr_class_id,
                           osnum   = Flist[*numFeet].osnum,
                           p_objid = &Flist[*numFeet].objid );
    if (!(sts&1)) goto quit;
    sts = om$send(msg      = message GRgraphics.GRaltconstruct(cst),
                     senderid = NULL_OBJID,
                     targetid = Flist[*numFeet].objid,
                     targetos = Flist[*numFeet].osnum );
    (*numFeet)++;
  }

  /* decide we will affecte the rotation matrix for texts in u
     or for texts in v */

  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = Flist[IDX_VFEET].objid,
                  targetos = Flist[IDX_VFEET].osnum);
  if (!(loc_msg&sts&1))  {goto quit;}

  BScveval(cv,0.,0,&pt[0],&bsrc);
  BScveval(cv,0.5,0,&pt[4],&bsrc);
  j=4; tmp = 1;
  pt[3] = pt[7] = 1;
  mat_u = lbsys.matrix;
  mat_v = lbsys.matrix;
  if (fabs(pt[1]-pt[5]) > fabs(pt[0]-pt[4])) {mat_u = matrix;}
  else {mat_v = matrix;}

  if (dev->developpable) {
    for (i=0; i<nb_step_in_u;i++) 
    {
      for (k=0;k<nb_step_in_v-1;k++) 
      {
        BSsfeval(unwSrf,param_u[i],(param_v[k]+param_v[k+1])/2.,0,
                 pt,&bsrc);
        if (bsrc != BSSUCC) goto quit;

        sprintf((char *)number,"0.00");
        len = strlen((char *)number);
        co$place_text(msg = &loc_msg,
                    text_string = number,
                    text_length = &len,
                    origin = pt,
                    lbs_matrix = mat_u,
                    flags = 1,
                    buffer = &Flist[*numFeet]);
         if (!(loc_msg&1)) {
                 printf("problems in co$place_text\n");
                 goto quit;
         }
         (*numFeet)++;
       }
    }
  }
  else {
    // compute lengths in the u direction on the unwrap surface
    // find iso curves
    sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                  &loc_msg,
                                  &(unit_surf.mod_env.md_env.matrix_type),
                                  unit_surf.mod_env.md_env.matrix,
                                  cst,
                                  FALSE,
                                  nb_step_in_u,
                                  param2d_u,
                                  TRUE,
                                  &numCurves,
                                  &iso),
        senderid  = NULL_OBJID,
        targetid  = unit_surf.obj_id.objid,
        targetos  = unit_surf.obj_id.osnum );

    if (!(sts&loc_msg&1))  {goto quit;}
    if (nb_step_in_u < numCurves) nb_step_in_u = numCurves;

    for (i=0;i<nb_step_in_u;i++)
    {
      sts = VLcomputeLength3D(&iso[i],dev->surface,srf2d->v_num_knots,
                              srf2d->v_knots, param2d_v,
                              cst,sf3d_length);
      if (!(sts&1)) goto quit;
                  
      for (j=0;j<nb_step_in_v-1;j++)
      {
          BSsfeval(unwSrf,param_u[i],param_v[j],0,&pt[0],&bsrc);
          BSsfeval(unwSrf,param_u[i],param_v[j+1],0,&pt[3],&bsrc);
          if (bsrc != BSSUCC) goto quit;

          unw_length[j] = BSdistptpt(&bsrc,pt,&pt[3]);
      }
      for (j=0,k=0;k<nb_step_in_v-1;k++,j+=3) {
        BSsfeval(unwSrf,param_u[i],(param_v[k]+param_v[k+1])/2.,0,
                 &point[j],&bsrc);
        if (bsrc != BSSUCC) goto quit;
      }
      for (j=0,k=0;k<nb_step_in_v-1;k++,j+=3)
      {
        sprintf((char *)number,"%lf",unw_length[k] - sf3d_length[k]);
        len = strlen((char *)number);
        co$place_text(msg = &loc_msg,
                      text_string = number,
                      text_length = &len,
                      origin = &point[j],
                      lbs_matrix = mat_u,
                      flags = 1,
                      buffer = &Flist[*numFeet]);
        if (!(loc_msg&1)) {
          printf("problems in co$place_text\n");
          goto quit;
        }
        (*numFeet)++;
      }
    }
    if (iso) {
      for (i=0;i<numCurves;i++)
         om$send( msg = message  GRgraphics.GRdelete( &sts,cst->env_info),
                      senderid = NULL_OBJID,
                      targetid = iso[i],
                      targetos = cst->env_info->md_id.osnum);
         free(iso);iso=NULL;
    }
  }
  if (dev->developpable) {
    for (i=0; i<nb_step_in_v;i++) 
    {
      for (k=0;k<nb_step_in_u-1;k++) 
      {
        BSsfeval(unwSrf,(param_u[k]+param_u[k+1])/2.,param_v[i],0,
                 pt,&bsrc);
        if (bsrc != BSSUCC) goto quit;

        sprintf((char *)number,"0.00");
        len = strlen((char *)number);
        co$place_text(msg = &loc_msg,
                    text_string = number,
                    text_length = &len,
                    origin = pt,
                    lbs_matrix = mat_v,
                    flags = 1,
                    buffer = &Flist[*numFeet]);
         if (!(loc_msg&1)) {
                 printf("problems in co$place_text\n");
                 goto quit;
         }
         (*numFeet)++;
       }
    }
  }
  else {
    // compute lengths in the v direction on the unwrap surface
    // find iso curves
    sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                  &loc_msg,
                                  &(unit_surf.mod_env.md_env.matrix_type),
                                  unit_surf.mod_env.md_env.matrix,
                                  cst,
                                  FALSE,
                                  nb_step_in_v,
                                  param2d_v,
                                  FALSE,
                                  &numCurves,
                                  &iso),
        senderid  = NULL_OBJID,
        targetid  = unit_surf.obj_id.objid,
        targetos  = unit_surf.obj_id.osnum );

    if (!(sts&loc_msg&1))  {goto quit;}
    if (nb_step_in_v < numCurves) nb_step_in_v = numCurves;

    for (i=0;i<nb_step_in_v;i++)
    {
      sts = VLcomputeLength3D(&iso[i],dev->surface,srf2d->u_num_knots,
                              srf2d->u_knots, param2d_u,
                              cst,sf3d_length);
      if (!(sts&1)) goto quit;
                  
      for (j=0;j<nb_step_in_u-1;j++)
      {
          BSsfeval(unwSrf,param_u[j],param_v[i],0,&pt[0],&bsrc);
          BSsfeval(unwSrf,param_u[j+1],param_v[i],0,&pt[3],&bsrc);
          if (bsrc != BSSUCC) goto quit;

          unw_length[j] = BSdistptpt(&bsrc,pt,&pt[3]);
      }
      for (j=0,k=0;k<nb_step_in_u-1;k++,j+=3) {
        BSsfeval(unwSrf,(param_u[k]+param_u[k+1])/2.,param_v[i],0,
                 &point[j],&bsrc);
        if (bsrc != BSSUCC) goto quit;
      }
      for (j=0,k=0;k<nb_step_in_u-1;k++,j+=3)
      {
        sprintf((char *)number,"%lf",unw_length[k] - sf3d_length[k]);
        len = strlen((char *)number);
        co$place_text(msg = &loc_msg,
                      text_string = number,
                      text_length = &len,
                      origin = &point[j],
                      lbs_matrix = mat_v,
                      flags = 1,
                      buffer = &Flist[*numFeet]);
        if (!(loc_msg&1)) {
          printf("problems in co$place_text\n");
          goto quit;
        }
        (*numFeet)++;
      }
    }
  }
  
  msg = MSSUCC;
quit :
  if(srf2d) {om$dealloc(ptr=srf2d);srf2d=NULL;}
  if(unwSrf) {om$dealloc(ptr=unwSrf);unwSrf=NULL;}
  if (param_u) {free(param_u);param_u = NULL;}
  if (param_v) {free(param_v);param_v = NULL;}
  if (unw_length) {free(unw_length);unw_length = NULL;}
  if (sf3d_length) {free(sf3d_length);sf3d_length = NULL;}
  if (point) {free(point);point = NULL;}
  if (iso) {
    for (i=0;i<numCurves;i++)
       om$send( msg = message  GRgraphics.GRdelete( &sts,cst->env_info),
                    senderid = NULL_OBJID,
                    targetid = iso[i],
                    targetos = cst->env_info->md_id.osnum);
       free(iso);iso=NULL;
  }
  return msg;
}

/* *********************************************************************** *
  This function creates the feet of the macro for a parametric unwrap
  option.
 * *********************************************************************** */

long VLparamStrV (
              struct GRobj_env *unw,   /* I: unwraped plate obj */
              struct mise_a_plat *dev,
              int nb_step_in_u,        /* I: number of steps in u */
              int nb_step_in_v,        /* I: number of steps in v */
              struct  GRvg_construct  *cst,
              int *numFeet,            /* O: number of sterch values
                                             and iso curves which will
                                             be the feet of the macro */
              struct GRid *Flist       /* O : the list of this feet */
            )
{
long			msg,loc_msg,sts;
long			numCurves;
GRobjid                 *sf3d_iso_u = NULL,*sf3d_iso_v = NULL;
GRobjid                 *unw_iso_u = NULL,*unw_iso_v = NULL;
int			i,j,k;
int			tmp;
IGRdouble		mid,pt[8],*point = NULL;
IGRdouble		*param_u = NULL;
IGRdouble		*param_v = NULL; 
IGRdouble		*unw_length = NULL; 
IGRdouble		*sf3d_length = NULL; 
IGRdouble	        mat[16],matrix[16];
IGRdouble		*mat_u,*mat_v;
struct IGRbsp_curve	*cv;
IGRboolean		stat;
BSrc			bsrc;
IGRuchar		number[20];
IGRshort		len;
struct IGRlbsys		lbsys;
struct GRobj_env        unw_surf;

   msg = MSFAIL;
   mat_u = mat_v = NULL;
   *numFeet = 0;

   if( vs$is_ancestry_valid(    object = &unw->obj_id,
                                classid = OPP_VLunwrap_class_id ) )
   {
  // get the name feet of the unwrap, we want the matrix of this text
   sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &loc_msg,
                                      UNFOLD_NAM_NAME,
                                      &unw_surf.obj_id,
                                      &unw_surf.mod_env.md_env.matrix_type,
                                      unw_surf.mod_env.md_env.matrix ),
                               senderid = NULL_OBJID,
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
  if (!(sts&loc_msg&1)) {
    goto quit;
  }
  if (unw->mod_env.md_env.matrix_type != MAIDMX) {
    tmp = 4;
    MAmulmx(&loc_msg,&tmp,&tmp,&tmp,unw->mod_env.md_env.matrix,
            unw_surf.mod_env.md_env.matrix,unw_surf.mod_env.md_env.matrix);
    MAtypemx( &loc_msg, unw_surf.mod_env.md_env.matrix,
                                   &(unw_surf.mod_env.md_env.matrix_type));
  }
  // get the geometry of the text, we will use its matrix later
  sts = om$send( msg    = message GRvg.GRgetgeom(
                                        &loc_msg,
                                        &(unw_surf.mod_env.md_env.matrix_type),
                                        unw_surf.mod_env.md_env.matrix,
                                        (IGRchar *) &lbsys),
                               senderid = NULL_OBJID,
                               targetid = unw_surf.obj_id.objid,
                               targetos = unw_surf.obj_id.osnum ) ;
  if (!(sts&loc_msg&1)) {
    goto quit;
  }
  }
  else if( vs$is_ancestry_valid(    object = &unw->obj_id,
                                   classid = OPP_VLunwObj_class_id ) )
  {
	VDpartAttr  attr ;
        attr.Iwant = VL_I_toMat ;
        attr.specific = (void *) lbsys.matrix ;
	sts = om$send( msg    = message GRvg.GRgetattr( &loc_msg, 
							(char *)&attr ),
                               senderid = NULL_OBJID,
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
        __CheckRC( sts, loc_msg, "GRvg.GRgetattr", quit ) ;
  }

  // construct a rotation matrix
  for (i=0;i<16;i++) mat[i]=0;
  mat[1]=mat[10]=mat[15]=1;
  mat[4] = -1;

  i=4;
  MAmulmx(&loc_msg,&i,&i,&i,lbsys.matrix,mat,matrix);

  // find the unwraped surface
  sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &loc_msg,
                                      UNFOLD_NAM_UNWSRF,
                                      &unw_surf.obj_id,
                                      &unw_surf.mod_env.md_env.matrix_type,
                                      unw_surf.mod_env.md_env.matrix ),
                               senderid = NULL_OBJID,
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
  if (!(sts&loc_msg&1)) {
    goto quit;
  }
  if (unw->mod_env.md_env.matrix_type != MAIDMX) {
    tmp = 4;
    MAmulmx(&loc_msg,&tmp,&tmp,&tmp,unw->mod_env.md_env.matrix,
            unw_surf.mod_env.md_env.matrix,unw_surf.mod_env.md_env.matrix);
    MAtypemx( &loc_msg, unw_surf.mod_env.md_env.matrix,
                                   &(unw_surf.mod_env.md_env.matrix_type));
  }

  param_u = (IGRdouble *) malloc(nb_step_in_u*sizeof(double)); 
  if (param_u == NULL)  {goto quit;}
  param_v = (IGRdouble *) malloc(nb_step_in_v*sizeof(double));
  if (param_v == NULL)   {goto quit;}
  if (nb_step_in_u > nb_step_in_v) tmp = nb_step_in_u;
  else tmp = nb_step_in_v;
  unw_length = (IGRdouble *) malloc(tmp*sizeof(double));
  if (unw_length == NULL)   {goto quit;}
  sf3d_length = (IGRdouble *) malloc(tmp*sizeof(double));
  if (sf3d_length == NULL)   {goto quit;}
  point = (IGRdouble *) malloc(3*tmp*sizeof(double));
  if (point == NULL)   {goto quit;}
  
  // compute u and v values
  tmp = nb_step_in_u -1;
  for (i=0;i<nb_step_in_u; i++){
    param_u[i] = (IGRdouble) i/tmp;
  }
  tmp = nb_step_in_v -1;
  for (i=0;i<nb_step_in_v; i++)
    param_v[i] = (IGRdouble) i/tmp;


  // find iso curves with constant u
  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                  &loc_msg,
                                  &(dev->surf_id.mod_env.md_env.matrix_type),
                                  dev->surf_id.mod_env.md_env.matrix,
                                  cst,
                                  FALSE,
                                  nb_step_in_u,
                                  param_u,
                                  TRUE,
                                  &numCurves,
                                  &sf3d_iso_u),
        senderid  = NULL_OBJID,
        targetid  = dev->surf_id.obj_id.objid,
        targetos  = dev->surf_id.obj_id.osnum );
  if (!(sts&loc_msg&1))  {goto quit;}
  if (numCurves != nb_step_in_u) nb_step_in_u = numCurves;
  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                  &loc_msg,
                                  &(dev->surf_id.mod_env.md_env.matrix_type),
                                  dev->surf_id.mod_env.md_env.matrix,
                                  cst,
                                  FALSE,
                                  nb_step_in_v,
                                  param_v,
                                  FALSE,
                                  &numCurves,
                                  &sf3d_iso_v),
        senderid  = NULL_OBJID,
        targetid  = dev->surf_id.obj_id.objid,
        targetos  = dev->surf_id.obj_id.osnum );
  if (!(sts&loc_msg&1))  {goto quit;}
  if (numCurves != nb_step_in_v) nb_step_in_v = numCurves;

  tmp = cst->display->weight;
  cst->display->weight = 1;
  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                  &loc_msg,
                                  &(unw_surf.mod_env.md_env.matrix_type),
                                  unw_surf.mod_env.md_env.matrix,
                                  cst,
                                  FALSE,
                                  nb_step_in_u,
                                  param_u,
                                  TRUE,
                                  &numCurves,
                                  &unw_iso_u),
        senderid  = NULL_OBJID,
        targetid  = unw_surf.obj_id.objid,
        targetos  = unw_surf.obj_id.osnum );
  if (!(sts&loc_msg&1))  {goto quit;}
  if (numCurves != nb_step_in_u) nb_step_in_u = numCurves;

  // create the first feet of the macro
  sts = VLcreate_arrow(unw_iso_u[0],unw_iso_u[1],(param_u[0]+param_u[1])/5.,
                       cst,&Flist[IDX_FFEET]);
  if (!(sts&1)) goto quit;
  *numFeet = IDX_VFEET;
  
  // the iso curves are also feet of the macro
  for (j=0;j<numCurves;j++)
  {
    Flist[*numFeet].objid = unw_iso_u[j];
    Flist[*numFeet].osnum = cst->env_info->md_id.osnum;
    (*numFeet)++;
  }
  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                  &loc_msg,
                                  &(unw_surf.mod_env.md_env.matrix_type),
                                  unw_surf.mod_env.md_env.matrix,
                                  cst,
                                  FALSE,
                                  nb_step_in_v,
                                  param_v,
                                  FALSE,
                                  &numCurves,
                                  &unw_iso_v),
        senderid  = NULL_OBJID,
        targetid  = unw_surf.obj_id.objid,
        targetos  = unw_surf.obj_id.osnum );
  if (!(sts&loc_msg&1))  {goto quit;}
  if (numCurves != nb_step_in_v) nb_step_in_v = numCurves;

  // the iso curves are also feet of the macro
  for (j=0;j<numCurves;j++)
  {
    Flist[*numFeet].objid = unw_iso_v[j];
    Flist[*numFeet].osnum = cst->env_info->md_id.osnum;
    (*numFeet)++;
  }

  cst->display->weight = tmp;

  for (i=0;i<nb_step_in_u;i++)
  {
    sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = sf3d_iso_u[i],
                  targetos = cst->env_info->md_id.osnum);
    if (!(loc_msg&sts&1))  {goto quit;}

    for (j=0;j<nb_step_in_v-1;j++)
    {
      mid = (param_v[j]+param_v[j+1])/2.;
      BSarclen (&bsrc,&stat,cv,&(param_v[j]),&param_v[j+1],
                &mid,&sf3d_length[j]);

    }
    sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = unw_iso_u[i],
                  targetos = cst->env_info->md_id.osnum);
    if (!(loc_msg&sts&1))  {goto quit;}
  
    if (i==0) {
  /* decide we will affecte the rotation matrix for texts in u
     or for texts in v */
      BScveval(cv,0.,0,&pt[0],&bsrc);
      BScveval(cv,0.5,0,&pt[4],&bsrc);
      j=4; tmp = 1;
      mat_u = lbsys.matrix;
      mat_v = lbsys.matrix;
      if (fabs(pt[1]-pt[5]) > fabs(pt[0]-pt[4])) mat_u = matrix;
      else mat_v = matrix;
    }

    for (j=0;j<nb_step_in_v-1;j++)
    {
      mid = (param_v[j]+param_v[j+1])/2.;
      BSarclen (&bsrc,&stat,cv,&(param_v[j]),&param_v[j+1],
                &mid,&unw_length[j]);
    }
    for (j=0,k=0;k<nb_step_in_v-1;k++,j+=3) {
      BScveval(cv,(param_v[k]+param_v[k+1])/2.,0,&point[j],&bsrc);
    }
    
    for (j=0,k=0;k<nb_step_in_v-1;k++,j+=3)
    {
      sprintf((char *)number,"%lf",unw_length[k] - sf3d_length[k]);
      len = strlen((char *)number);
      co$place_text(msg = &loc_msg,
                    text_string = number,
                    text_length = &len,
                    origin = &point[j],
                    lbs_matrix = mat_u,
                    flags = 1,
                    buffer = &Flist[*numFeet]);
      if (!(loc_msg&1)) {
        printf("problems in co$place_text\n");
        goto quit;
      }
      (*numFeet)++;
    }
  }

  for (i=0;i<nb_step_in_v;i++)
  {
    if (mat_v == NULL) goto quit;
    sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = sf3d_iso_v[i],
                  targetos = cst->env_info->md_id.osnum);
    if (!(loc_msg&sts&1))  {goto quit;}

   for (j=0;j<nb_step_in_u-1;j++)
   {
     mid = (param_u[j]+param_u[j+1])/2.;
     BSarclen (&bsrc,&stat,cv,&(param_u[j]),&param_u[j+1],
               &mid,&sf3d_length[j]);
   }
    sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cst->env_info->md_env.matrix_type,
                                    cst->env_info->md_env.matrix,
                                   (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = unw_iso_v[i],
                  targetos = cst->env_info->md_id.osnum);
    if (!(loc_msg&sts&1))  {goto quit;}

    for (j=0;j<nb_step_in_u-1;j++)
    {
      mid = (param_u[j]+param_u[j+1])/2.;
      BSarclen (&bsrc,&stat,cv,&(param_u[j]),&param_u[j+1],
                &mid,&unw_length[j]);
      
    }
    for (j=0,k=0;k<nb_step_in_u-1;k++,j+=3) {
      BScveval(cv,(param_u[k]+param_u[k+1])/2.,0,&point[j],&bsrc);
    }

    for (j=0,k=0;k<nb_step_in_u-1;k++,j+=3)
    {
      sprintf((char *)number,"%lf",unw_length[k] - sf3d_length[k]);
      len = strlen((char *)number);
      co$place_text(msg = &loc_msg,
                    text_string = number,
                    text_length = &len,
                    origin = &point[j],
                    lbs_matrix = mat_v,
                    flags = 1,
                    buffer = &Flist[*numFeet]);
      if (!(loc_msg&1)) {
        printf("problems in co$place_text\n");
        goto quit;
      }
      (*numFeet)++;
    }
  }
  msg = MSSUCC;
quit :
   if (sf3d_iso_v) {
     for (i=0;i<nb_step_in_v;i++)
       om$send( msg = message  GRgraphics.GRdelete( &sts,cst->env_info),
                    senderid = NULL_OBJID,
                    targetid = sf3d_iso_v[i],
                    targetos = cst->env_info->md_id.osnum);
    }
   if (sf3d_iso_u) {
      for (i=0;i<nb_step_in_u;i++)
        om$send( msg = message  GRgraphics.GRdelete( &sts,cst->env_info),
                  senderid = NULL_OBJID,
                  targetid = sf3d_iso_u[i],
                  targetos = cst->env_info->md_id.osnum);
   }

  if (param_u) {free(param_u);param_u = NULL;}
  if (param_v) {free(param_v);param_v = NULL;}
  if (unw_length) {free(unw_length);unw_length = NULL;}
  if (sf3d_length) {free(sf3d_length);sf3d_length = NULL;}
  if (sf3d_iso_u) {free(sf3d_iso_u);sf3d_iso_u = NULL;}
  if (sf3d_iso_v) {free(sf3d_iso_v);sf3d_iso_v = NULL;}
  if (unw_iso_u) {free(unw_iso_u);unw_iso_u = NULL;}
  if (unw_iso_v) {free(unw_iso_v);unw_iso_v = NULL;}
  if (point) {free(point);point = NULL;}
  return msg;
}

/* *********************************************************************** *
  This function makes some tests on the unwrap and call other
  functions to create the feet of the macro.
 * *********************************************************************** */

long VLcreStrechValues (
              struct GRobj_env *unw,   /* I: unwraped plate obj */
              struct GRmd_env *cur_env,/* I: curent environment */
              int nb_step_in_u,        /* I: number of steps in u */
              int nb_step_in_v,        /* I: number of steps in v */
              int *numFeet,            /* O: number of sterch values
                                             and iso curves which will
                                             be the feet of the macro */
              struct GRid *Flist       /* O : the list of this feet */
            )
{
long			msg,loc_msg,sts;
struct mise_a_plat	dev;
int			bool;
struct  GRvg_construct  cst;

   msg = MSFAIL;
   if ( !unw || !numFeet || !Flist ) goto quit;
   VLinitDev(&dev);
   if( vs$is_ancestry_valid(    object = &unw->obj_id,
                                classid = OPP_VLunwrap_class_id ) )
   {
       sts = om$send(msg = message VLunwrap.getRoots(&loc_msg,cur_env,
                                                 &dev,NULL,NULL,NULL, NULL,
					         &bool,NULL,NULL),
                           senderid = NULL_OBJID,
                           targetid = unw->obj_id.objid,
                           targetos = unw->obj_id.osnum);
       if (!(sts&loc_msg&1)) goto quit;
   }
   else if( vs$is_ancestry_valid(    object = &unw->obj_id,
				     classid = OPP_VLunwObj_class_id ) )
   {
      struct unw_obj_plat 	myDev;
      VDpartAttr		attr;

        attr.Iwant = VL_I_getOpts ;
        attr.specific = (void *) &myDev ;
	sts = om$send(msg = message GRvg.GRgetattr( &msg, (char *)&attr ),
			senderid = NULL_OBJID,
			targetid = unw->obj_id.objid,
			targetos = unw->obj_id.osnum	);
        __CheckRC( sts, msg, "GRvg.GRgettattr", quit );

        dev.surf_id 		= myDev.surf_id;
        dev.developpable 	= myDev.developpable;
        dev.tesselation_option 	= myDev.tesselation_option;
        dev.side_of_plate 	= myDev.side_of_plate;
        dev.uvSrfId 	  	= myDev.uvSrfId;

        sts = VLgetGeometry( &dev.surf_id, TRUE, NULL_OBJID,
                                (IGRchar **)&dev.surface, &msg );
        __CheckRC( sts, msg, "VLgetGeometry", quit );
	bool = TRUE;
   }
    // if there is no unwraped surface 
   if (bool == FALSE) {
     msg = NEED_UNW_SURF;
     ex$message(msgnumb = VL_E_NeedUnwSurf,time=0,seconds=0);
     goto quit;
   }
   VLinitCnst(&cst);
   cst.env_info = cur_env;
  if (dev.tesselation_option == PARAMETRIC)
    sts = VLparamStrV(unw,&dev,nb_step_in_u,nb_step_in_v,
                      &cst,numFeet,Flist);
  else sts = VLarcLStrV(unw,&dev,nb_step_in_u,nb_step_in_v,
                        &cst,numFeet,Flist);

  if (!(sts&1)) goto quit;
  msg = MSSUCC;
quit :
  VLfreeDev(&dev);
  return msg;
}

/* ************************************************************************ *
  create a VLstretchV object.
 * ************************************************************************ */
method create (
               		IGRlong 		*msg; 
               		struct GRobj_env	*unw;
               		IGRdouble 		step_in_u;
               		IGRdouble 		step_in_v;
               		struct GRmd_env		*cur_env
              )
{
struct GRid temp[10];
IGRlong status,loc_msg;
IGRint  loc_msg1;
struct mise_a_plat dev;
struct GRobj_env	unw_surf;
struct IGRbsp_surface	*unwSrf=NULL;

  *msg = MSFAIL;
   if( vs$is_ancestry_valid(    object = &unw->obj_id,
                                classid = OPP_VLunwrap_class_id ) )
   {
       status = om$send(msg = message VLunwrap.getRoots(&loc_msg,cur_env,
                                                 &dev,NULL,NULL,NULL, NULL,
                                                 NULL,NULL,NULL),
                           targetid = unw->obj_id.objid,
                           targetos = unw->obj_id.osnum);
       if (!(status&loc_msg&1)) goto quit; 
  }
   else if( vs$is_ancestry_valid(    object = &unw->obj_id,
				     classid = OPP_VLunwObj_class_id ) )
   {
      struct unw_obj_plat 	myDev;
      VDpartAttr		attr;

        attr.Iwant = VL_I_getOpts ;
        attr.specific = (void *) &myDev ;
	status = om$send(msg = message GRvg.GRgetattr( msg, (char *)&attr ),
			senderid = NULL_OBJID,
			targetid = unw->obj_id.objid,
			targetos = unw->obj_id.osnum	);
        __CheckRC( status, *msg, "GRvg.GRgettattr", quit );

        dev.surf_id 		= myDev.surf_id;
        dev.developpable 	= myDev.developpable;
        dev.tesselation_option 	= myDev.tesselation_option;
        dev.side_of_plate 	= myDev.side_of_plate;
        dev.uvSrfId 	  	= myDev.uvSrfId;
  }
  if (dev.tesselation_option) {
    // find the unwraped surface
    status = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &loc_msg,
                                      UNFOLD_NAM_UNWSRF,
                                      &unw_surf.obj_id,
                                      &unw_surf.mod_env.md_env.matrix_type,
                                      unw_surf.mod_env.md_env.matrix ),
                               targetid = unw->obj_id.objid,
                               targetos = unw->obj_id.osnum ) ;
    if (!(status&loc_msg&1)) goto quit;
    status = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &cur_env->md_env.matrix_type,
                                    cur_env->md_env.matrix,
                                   (IGRchar **)&unwSrf),
                  targetid = unw_surf.obj_id.objid,
                  targetos = unw_surf.obj_id.osnum);
  if (!(loc_msg&status&1))  {goto quit;}

    if (step_in_u > unwSrf->u_num_poles) step_in_u = unwSrf->u_num_poles;
    if (step_in_v > unwSrf->v_num_poles) step_in_v = unwSrf->v_num_poles;
  }
  if ((step_in_u-1)*step_in_v +
      (step_in_v-1)*step_in_u +
      step_in_u + step_in_v + 1
                       > MACRO_NB_FFEET + MACRO_NB_VFEET) {
    ex$message(msgnumb = VL_E_FineMesh,time=0,seconds=0);
    goto quit;
  }

  status = exp$create( exp_value  = (IGRdouble) step_in_u,
                       osnum      = cur_env->md_id.osnum,
                       p_exp_id   = &(temp[IDX_STEPU].objid),
                       p_osnum    = &(temp[IDX_STEPU].osnum) );
  if (!(status&1)) {
    printf("Problems at creating expression\n");
    goto quit;
  }
  status = exp$create( exp_value  = (IGRdouble) step_in_v,
                       osnum      = cur_env->md_id.osnum,
                       p_exp_id   = &(temp[IDX_STEPV].objid),
                       p_osnum    = &(temp[IDX_STEPV].osnum) );
  if (!(status&1)) {
    printf("Problems at creating expression\n");
    goto quit;
  }

  as$make_source( go_grid = unw->obj_id,
                  mod_env = &(unw->mod_env),
                  as_os   = cur_env->md_id.osnum ,
                  as_grid = &temp[IDX_UNW]); 

  status = om$send(  msg  = message ACncpx.ACmplace(
                                          &loc_msg1,
                                          AChdr_noprotect | AChdr_nodisplay, 0,
                                          VLstrechVal,
                                          MACRO_NB_TEMP,
                                          temp,
                                          cur_env ),
                          targetid = my_id);
  if (!(status&loc_msg1&1)) {
    goto quit;
  }

  *msg = MSSUCC;
quit :
  return 1;
}

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{
struct GRobj_env	unw;
int			i,nb_step_in_u,nb_step_in_v;
IGRlong			sts,loc_msg;
struct ret_struct	str;
OMuword                 TEMP_cl,acpretend_cl;

   *msg = MSFAIL;
   if (!md_env || !list || !fcount || !feet_list ) goto quit;

   om$get_classid(  classname = "ACpretend",  p_classid = &acpretend_cl);
   *fcount = 0;
   sts = om$send(  msg      = message NDnode.NDgive_structure
                                            ( &loc_msg, &str,md_env ),
                                        targetid = list[IDX_STEPU].objid,
                                        targetos = list[IDX_STEPU].osnum );
   if (!(sts&loc_msg&1)) goto quit;
    nb_step_in_u = str.var.root_pm_st.value;

   sts = om$send(  msg      = message NDnode.NDgive_structure
                                            ( &loc_msg, &str,md_env ),
                                        targetid = list[IDX_STEPV].objid,
                                        targetos = list[IDX_STEPV].osnum );
   if (!(sts&loc_msg&1)) goto quit;
   nb_step_in_v = str.var.root_pm_st.value;

   unw.obj_id = list[IDX_UNW];
   unw.mod_env = *md_env;

   om$get_classid(osnum      = list[IDX_UNW].osnum,
                  objid      = list[IDX_UNW].objid,
                  p_classid  = &TEMP_cl) ;

      /* The following 'if' is to support objects in reference files */

   if( om$is_ancestry_valid( superclassid  = acpretend_cl,
                                subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {
     unw.obj_id.objid = NULL_OBJID;
     sts = om$send( msg  = message NDnode.ASreturn_go(
                                      &unw.obj_id,
                                      &unw.mod_env.md_env.matrix_type,
                                      unw.mod_env.md_env.matrix ),
                        targetid = list[IDX_UNW].objid,
                        targetos = list[IDX_UNW].osnum );
     if( !( 1 & sts ) ){
       goto quit;
     }
     unw.mod_env.md_id.osnum = unw.obj_id.osnum;
   }

  // Create feet

   sts = VLcreStrechValues(&unw,md_env,nb_step_in_u,nb_step_in_v,
                              fcount,feet_list);
   if (!(sts&1)) {
     if (sts != NEED_UNW_SURF) {
       ex$message(msgnumb = VL_E_BadPlc,time=0,seconds=0);
       goto quit;
     }
     else 
      om$send(    msg      = message GRgraphics.GRdelete
                                            ( &sts, md_env ),
                            targetid = my_id);
   }

  *msg = MSSUCC;
quit :
  if (*msg == MSFAIL) {
    for (i=0;i< *fcount; i++)
      om$send(    msg      = message GRgraphics.GRdelete
                                            ( &sts, md_env ),
                            targetid = feet_list[i].objid,
                            targetos = feet_list[i].osnum );
      feet_list[UNFOLD_IDX_UNWSRF].objid = NULL_OBJID;
      *fcount = 0; 
  }
  return *msg;
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjStretchValues;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLstretchV;
