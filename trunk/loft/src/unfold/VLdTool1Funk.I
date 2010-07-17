/*f
	VLdToolsFunk.I contains all the basics functions to create
	apply transformations for the unwrap command.

JLL 21 dec 92 : add argument dim to function VLcre3dCvFromParams to
		be able to handle funny IGRbsp_curve structure even if it's
		uv space.
JLL 29 dec 92 : add argument NumObj to function VLapplyTransf() to be
		able to apply transformation matrix to a list of
		objects.
JLL 7  mai 94 : add trfMat and trfMatType as output arguments in
		VLapplyTransf()
JLL 10 mai 94 : add GRchglevel method in VLgetCrvsConToSrf()

*/


class implementation VLabstract;


#include <stdio.h>
#include <math.h>
#include "vlprototype.h"

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "madef.h"
#include "gr.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "bserr.h"
#include "bstypes.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "igr.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "nddef.h"
#include "asmacros.h"
#include "parametric.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "asmacros.h"
#include "bsicmpcvoff.h"
#include "vsmiscmacros.h"
#include "vlcntrline.h"
#include "vlmark.h"
#include "vlrolline.h"
#include "bsvalues.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vlglinedef.h"
#include "vlstructure.h"
#include "expmacros.h"
#include "expression.h"
#include "vsplatedef.h"
#include "griomacros.h"
#include "vlgrmacros.h"
#include "vlgrdef.h"
#include "vsgeommacros.h"
#include "vsstfnrdef.h"
#include "grdpbmacros.h"
#include "vlquerydef.h"
#include "vsbmaxisdef.h"
#include "vltemplate.h"
#include "vlunfold.h"
#include "exmacros.h"
#include "exproto.h"
#include "cotxmacros.h"
#include "gotextdef.h"
#include "vlstrechval.h"
#include "vlmsg.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "bsalloccv.h"
#include "bsallocsf.h"
#include "bsfreecv.h"
#include "bsfreesf.h"

#include "vldbgmacros.h"

  
from	IGEgragad	import	DPinrot;
from    GRcurve		import  GRendpts;
from    GRgencs         import  GRgetmatrix;
from    ACrg_collect    import	AClist_attribute;
from    VLmrkLine       import	WhichSide;
from    VLctrLine       import  VLget_attributes;

extern GRclassid	OPP_GR3dlinestr_class_id;
extern GRclassid        OPP_GRgencs_class_id;
extern GRclassid        OPP_EMSgenbs_class_id;
extern GRclassid        OPP_VLmrkLine_class_id;

extern  IGRchar		*memcpy();
extern			ASmake_source_from_env();
extern IGRint 		MAinvmx();
extern IGRint 		MAmulmx();
extern IGRboolean	MAtypemx();
extern 			VLbrowseFctInTree();
extern 			VLfilterClass();
extern  int             VLgetMacrosAtStep();
extern struct GRid      NULL_GRID;
extern void		BSsfeval(), BSsfevaln();

#define ANGLE (cos(M_PI/4))

/* convert a point coordinate from Base cs to cs */
VLconvert_coord( vect, wld, cs)
IGRdouble	*vect;	/* I : point to convert 	*/
IGRdouble	*wld;	/* O : converted point		*/
struct GRid	*cs;	/* I : coordinate system	*/
{
IGRdouble	mat[16],inv_mat[16];
int 		four,one;
IGRlong		loc_msg,status;

      /* get cs matrix */
      status = om$send(  msg = message GRgencs.GRgetmatrix( &loc_msg, mat ),
				senderid = NULL_OBJID,
                              targetid = cs->objid,
                              targetos = cs->osnum);
      if (!(status&loc_msg&1))	return	0;
      four = 4; one = 1;
      MAinvmx( &loc_msg, &four, mat, inv_mat );
      if (!(loc_msg&1))	return	0;
      MAmulmx( &loc_msg, &four, &four, &one, inv_mat, vect, wld);
      if (!(loc_msg&1))	return	0;
      return 1;
}

/*===========================================================================*/

/*d this function create an order 2 bspline surface giving the poles,
    the number of poles in u and v and the 2 knot vectors. */

/*h 23/october/92 JLL creation date */
/*===========================================================================*/

IGRlong VLcreOrd2Srf (
 
	IGRdouble	*poles,	  /*I the given poles */
	IGRint		Nu,	  /*I the number of poles in u */
	IGRint		Nv,	  /*I the number of poles in v */
	IGRdouble	*KtsU,    /*I the internal knots in u */
	IGRdouble	*KtsV,	  /*I the internal knots in v */
	IGRshort  	constOpt, /*I constOpt = 0 just the bs 
				      constOpt = 1 the structure + the object
				      constOpt = 2 just just object */

struct 	GRvg_construct	*cst,	  /*I the construction list */
	IGRboolean	display,  /*I display option to send a display or not */
struct	GRobj_env	*ObjSrf,  /*O the resulting surface */
struct	IGRbsp_surface  **sf,     /*O depending to constOpt the BS structure */
	IGRlong		*msg      /*O return code MSSUCC or MSFAIL */
)

{


 	IGRlong		rc;
 struct	IGRbsp_surface  *tmpSf;

 tmpSf = NULL;

 BSallocsf ( (IGRshort)(2), (IGRshort)(2),
	     (IGRlong)Nu, (IGRlong)Nv,
	     (IGRboolean ) FALSE, (IGRshort)0, &tmpSf, &rc);
 if (rc != BSSUCC) {
	   printf("Error in VLcreOrd2Srf\n");
	   printf("BSallocsf on <struct IGRbsp_surface *> returns %d\n", rc);
	   goto wrapup; 
 }

 /*c set up the sf structure */

	tmpSf->u_order 		= (IGRshort)   2;
	tmpSf->v_order 		= (IGRshort)   2;
	tmpSf->u_periodic 	= (IGRboolean) FALSE;
	tmpSf->v_periodic 	= (IGRboolean) FALSE;
	tmpSf->u_non_uniform 	= (IGRboolean) TRUE;
	tmpSf->v_non_uniform 	= (IGRboolean) TRUE;
	tmpSf->u_num_poles   	= (IGRlong)    Nu;
	tmpSf->v_num_poles   	= (IGRlong)    Nv;
	tmpSf->u_num_knots   	= (IGRlong)    2 + Nu;
	tmpSf->v_num_knots   	= (IGRlong)    2 + Nv;
	tmpSf->rational		= (IGRboolean) FALSE;
	tmpSf->planar        	= (IGRboolean) FALSE;
	tmpSf->u_phy_closed  	= (IGRboolean) FALSE;
	tmpSf->v_phy_closed  	= (IGRboolean) FALSE;
	tmpSf->pos_orient    	= (IGRboolean) TRUE;
	tmpSf->on_off	  	= (IGRboolean) TRUE;
	tmpSf->num_boundaries 	= (IGRshort) 0;

 /*c store the poles of surface, just do a memcpy */

     memcpy ( (IGRchar *)tmpSf->poles,(IGRchar *)poles,
	      (IGRint) 3 * Nu * Nv * sizeof(IGRdouble) );

 /*c store the knots in u */

      tmpSf->u_knots[0] = 0.0;
      memcpy ( (IGRchar *)&tmpSf->u_knots[1],(IGRchar *)KtsU,
	       (IGRint) Nu * sizeof(IGRdouble) );
      tmpSf->u_knots[tmpSf->u_num_knots-1] = 1.0;


 /*c same story in v */
      tmpSf->v_knots[0] = 0.0;
      memcpy ( (IGRchar *)&tmpSf->v_knots[1],(IGRchar *)KtsV,
	       (IGRint) Nv * sizeof(IGRdouble) );
      tmpSf->v_knots[tmpSf->v_num_knots-1] = 1.0;

  if( constOpt == 0 ){
	*sf = tmpSf;
	*msg = MSSUCC;
 	return MSSUCC;
  }


  cst->geometry = (IGRchar *) tmpSf;

  ObjSrf->obj_id.objid = NULL_OBJID; 
  ObjSrf->obj_id.osnum = cst->env_info->md_id.osnum; 


  rc =	om$construct( classid = OPP_EMSgenbs_class_id, 
	              p_objid = &ObjSrf->obj_id.objid, 
         	      osnum   = ObjSrf->obj_id.osnum,
	              msg     = message GRgraphics.GRconstruct(cst) );

 if( !(rc&1) ){ 
	printf("error in om$construct for sf\n");
	goto wrapup;
 }

 ObjSrf->mod_env = (*cst->env_info);

 if( display == TRUE ){

	gr$display_object ( object_id = (struct GRid *)&ObjSrf->obj_id,
                	    md_env    = cst->env_info,
		     	    mode      = GRbd );
 }

 cst->geometry = NULL;
 if( ( constOpt == 2 ) && (tmpSf != NULL) ) BSfreesf(&rc,tmpSf );
 else *sf = tmpSf;

 *msg = MSSUCC;
 return MSSUCC;

wrapup:
 if( tmpSf != NULL ) BSfreesf(&rc,tmpSf);
 *msg = MSFAIL;
 return MSFAIL;

}

/*****************************************************************************/

/*d this function create an order 2 bspline curve in 3D space giving 
    his representation as a linestring in the uv space. */

/*h 23/october/92 JLL creation date */
/*****************************************************************************/

IGRlong VLcre3dCvFromParams (

IGRshort		dim,	/*I to tell if we have 3d or 2d data*/
struct 	IGRbsp_surface	*devSrf,/*I surface used to evaluate the 3d point
				    giving the uv parameters */ 
	IGRint		numUV,  /*I number of points to evaluate */
	IGRdouble	*uv,    /*I the uv parameters */
struct 	GRvg_construct	*cst,   /*I construction list */
struct	GRobj_env	*obj,   /*O the object representing the 3D mapping */
	IGRlong		*msg    /*O return code MSSUCC or MSFAIL */
)

{

IGRint			k, i;
struct	IGRpolyline	lst;
BSrc			rc;

	lst.points = NULL;
 	lst.points = (IGRdouble *)om$malloc( size = 3*numUV*sizeof(IGRdouble));
 	if( lst.points == NULL ){
		printf(" malloc lst.points : Failed\n");
		goto wrapup;
 	}

 	cst->geometry	= (IGRchar *) &lst;

        for(k=0;k<numUV;k++){
		i = dim * k;
		BSsfeval( devSrf, uv[i], uv[i+1], 0, &(lst.points[3*k]), &rc );
 	}

	obj->obj_id.objid = NULL_OBJID;
	obj->obj_id.osnum = cst->env_info->md_id.osnum;
	obj->mod_env      = *(cst->env_info);

	lst.num_points	= numUV;
  	om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &obj->obj_id.objid, 
         	            osnum   = obj->obj_id.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );

	if( lst.points ) om$dealloc( ptr = lst.points );
	cst->geometry = NULL;

	*msg = MSSUCC;
	return(MSSUCC);

wrapup:
	if( lst.points ) om$dealloc( ptr = lst.points );
	cst->geometry = NULL;	
	*msg = MSFAIL;
	return(MSFAIL);
}

/* find if a surface/plate is longitudinal, transversal or 
   horizontal in the boat */ 
VLlongHorzOrTrans (SurfObj,type)
struct GRobj_env        *SurfObj;  /* I : Given Surface */
       IGRint		*type;     /* O : type of surface : 
                                                    0 : Horizontal
                                                    1 : Transversal
                                                    2 : Longitudinal
                                   */
{
	BSrc		bsrc;
	IGRlong		sts,loc_msg;
struct 	IGRbsp_surface	*sf=NULL;
        IGRlong		num;
        IGRpoint	point;
        IGRdouble	pr_horz,pr_long,pr_trans,vect[3],normal[4];

  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
  if (!(loc_msg&sts&1)) {
    return 0;
  }
  BSsfevaln(sf,0.5,0.5,1,&num,point,normal,&bsrc);
  if (bsrc != BSSUCC) {
    return 0;
  }
  BSnorvec(&bsrc,normal);
  if (bsrc != BSSUCC) {
    return 0;
  }
  vect[0] = vect[1] = 0; vect[2] = 1;
  pr_horz = BSdotp(&bsrc,normal,vect);
  if (pr_horz <0) pr_horz = -pr_horz;
  vect[0] = 1; vect[2] = 0;
  pr_trans = BSdotp(&bsrc,normal,vect);
  if (pr_trans <0) pr_trans = -pr_trans;
  vect[0] = 0; vect[1] = 1;
  pr_long = BSdotp(&bsrc,normal,vect);
  if (pr_long <0) pr_long = -pr_long;

  if (pr_horz >= pr_trans & pr_horz >= pr_long)
    *type= VL_HORZ;   // Horizontal
  else {
    if (pr_trans >= pr_horz & pr_trans >= pr_long)
      *type= VL_TRANS;    // Transversal
    else *type = VL_LONG;  // Longitudinal
  }
  return 1;
}

/* Given a plate, this function find the plate's side with more of
   marking Lines */
VLget_side_w_more_mrkln(plate,side_name)
struct GRobj_env        *plate;    /* I : Given Plate.*/
char                    *side_name;/* O : the side with more stiffners.*/
{
struct GRobj_env        *trav = NULL;
int                     nb,i,side;
int                     nb_Bot,nb_Off;
long                    sts,msg;


  msg = MSFAIL;
  nb_Bot = nb_Off = 0;

  // find the marking Lines on the plates
  VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL,
                     VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep,
                     &nb, &trav );

  VLfilterClass(nb,trav,&nb,OPP_VLmrkLine_class_id);
  for (i=0;i<nb;i++)
  {
    sts = om$send( msg      = message VLmrkLine.WhichSide (&side),
                     targetid = trav[i].obj_id.objid,
                     targetos = trav[i].obj_id.osnum,
                     senderid = NULL_OBJID ) ;
    if (!(sts&1)) goto quit;
    if (side == VS_K_stOnBotOfPlate) nb_Bot++;
    else nb_Off++;
  }
  if (nb_Off > nb_Bot) strcpy(side_name,VS_K_plTopSfPath);
  else strcpy(side_name,VS_K_plBotSfPath);

  msg = MSSUCC;
quit :
  if (trav) { free(trav); trav = NULL;}
  return msg;
}
/* Given a plate, this function find the numbers of vertical and horizontal
   marking lines */ 
IGRlong VLgetNumMrkLns (plate, num_hor_ln, num_ver_ln)
struct GRobj_env	*plate;      /* I  plate */
IGRint			*num_hor_ln; /* O  number of horizental marking lines */
IGRint			*num_ver_ln; /* O  number of vertical marking lines */
{
IGRlong			msg,sts,loc_msg;
struct GRobj_env	*trav = NULL;
IGRint			nb,i,dim=4;
IGRpoint		startpt,endpt;
BSrc			rc;
IGRdouble		vect[3];
struct GRobj_env        obj;

  msg = MSFAIL;
  *num_hor_ln = 0;
  *num_ver_ln = 0;
  VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL,
                     VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep,
                     &nb, &trav );

  VLfilterClass(nb,trav,&nb,OPP_VLmrkLine_class_id);
  for (i=0;i<nb;i++)
  {
    sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                       &loc_msg,
                                       VLFirstMrkName,
                                       &(obj.obj_id),
                                       &(obj.mod_env.md_env.matrix_type),
                                       obj.mod_env.md_env.matrix),
                      targetid        = trav[i].obj_id.objid,
                      targetos        = trav[i].obj_id.osnum,
                      senderid        = NULL_OBJID );
    if (!(sts&loc_msg&1))
      goto quit;

    if (trav[i].mod_env.md_env.matrix_type != MAIDMX) {
      MAmulmx(&loc_msg,&dim,&dim,&dim,trav[i].mod_env.md_env.matrix,
              obj.mod_env.md_env.matrix,obj.mod_env.md_env.matrix);
      MAtypemx( &loc_msg, obj.mod_env.md_env.matrix,
                                     &(obj.mod_env.md_env.matrix_type));
    }

    sts = om$send ( msg =  message GRcurve.GRendpts (
					&loc_msg,
					&(obj.mod_env.md_env.matrix_type),
					obj.mod_env.md_env.matrix,
					startpt,endpt),
		      targetid        = obj.obj_id.objid,
                      targetos        = obj.obj_id.osnum,
                      senderid        = NULL_OBJID );
    if (!(sts&loc_msg&1))
      goto quit;
      vect[0] = endpt[0] - startpt[0];
      vect[1] = endpt[1] - startpt[1];
      vect[2] = endpt[2] - startpt[2];
      BSnorvec(&rc,vect);
      if (rc != BSSUCC) goto quit;
      if (fabs(vect[0]) < ANGLE) {
        (*num_ver_ln)++;
      }
      else {
        (*num_hor_ln)++;
      }
  }
  msg = MSSUCC;
quit :
  if (trav) free(trav);
  return msg;
}

/* ************************************************************************* */
/*  Given a plate, this function find the number of the stiffners attached
    to it and compute the expansion of the plate.                            */
/* ************************************************************************* */
VLcompute_expansion_factors (plate,length,width,x_expansion,
                            y_expansion,type_expansion,cur_env,
                            mat,new_length,new_width)
struct GRobj_env *plate;                 /* I : Given Plate.*/
double		 length,width;           /* I : Given length and width*/
double		 x_expansion,y_expansion;/* I : Given expansion parameters*/
int		 type_expansion;         /* I : type of expansion.*/
struct GRmd_env  *cur_env;               /* I : current environnement*/
double		 *mat;                   /* IO : matrix which include now
                                                the expansion factor.*/
double		 *new_length,*new_width; /* O : length and width expanded.*/
{
double		scale;
IGRlong		msg,sts,loc_msg;
int		num_hor_ln,num_ver_ln;

  msg = MSFAIL;
  *new_length = length;
  *new_width = width;
/*
  if (x_expansion !=0) {
     sts = co$cvt_imp_to_wrk(msg =  &loc_msg,
                             unit_type = GRIO_DISTANCE,
                             osnum     = cur_env->md_id.osnum,
                             primary = x_expansion,
                             result  = &x_expansion);
     if(!(sts & loc_msg & 1)) {
       printf("Problems in converting units\n");
       goto quit;
     }
   }
   if (y_expansion !=0) {
     sts = co$cvt_imp_to_wrk(msg =  &loc_msg,
                             unit_type = GRIO_DISTANCE,
                             osnum     = cur_env->md_id.osnum,
                             primary = y_expansion,
                             result  = &y_expansion);
     if(!(sts & loc_msg & 1)) {
       printf("Problems in converting units\n");
       goto quit;
     }
   }
*/
  if (type_expansion == BY_STIFFNERS) {
   // sts = VLgetNumStiff(plate,cur_env,&num_hor_st,&num_ver_st);
    sts = VLgetNumMrkLns(plate,&num_hor_ln,&num_ver_ln);
    if (sts != MSSUCC) {
      printf("Problems at getting stiffners\n");
      num_hor_ln = 0;
      num_ver_ln = 0;
    }
    *new_width = width+num_hor_ln*y_expansion;
    *new_length = length+num_ver_ln*x_expansion;
  }
  else {
    if (type_expansion == GLOBAL_LW_RATIO) {
      *new_width = width+width*y_expansion;
      *new_length = length+length*x_expansion;
    }
  }

  if (*new_length != length) {
    scale = (*new_length)/length;
    mat[0] = mat[0]*scale;
    mat[4] = mat[4]*scale;
    mat[8] = mat[8]*scale;
    mat[12] = mat[12]*scale;
  }
  if (*new_width != width) {
    scale = (*new_width)/width;
    mat[1] = mat[1]*scale;
    mat[5] = mat[5]*scale;
    mat[9] = mat[9]*scale;
    mat[13] = mat[13]*scale;
 } 
  msg = MSSUCC;
quit :
  return msg;
}

/* ************************************************************************ */
/*     No more then six control lines on a plate (three on each side
       with respect to x, y or z axis), this function eleminate 
       doubled control lines in two lists (the first list control
       lines are contained by template managers).                           */
       
/* ************************************************************************ */
IGRlong VLfilterCntLn(Mgr_count,cntrl,tp_manager,count,list,ln_to_add)
int		 Mgr_count;   /* I : number of objects in first list.*/
struct GRobj_env *cntrl;      /* I : first control line list*/
struct GRobj_env *tp_manager; /* I : list of template manager corresponding*/
                              /*     to the first list.*/
int		 count;       /* I : number of objects in second list.*/
struct GRobj_env *list;       /* I : second control line list*/
int		 *ln_to_add;  /* O : number of lines in first list that should*/
                              /*     added to the second one.*/
{
IGRlong 	msg,loc_msg,status;
int             i,j,nb_list;
char		*axis=NULL,side[50];
int             *plate_side=NULL;
struct GRid	temp_list[200];
int		nb_temp,nb_att;
struct ACrg_coll list_att[100];


  msg = MSFAIL;
  *ln_to_add = Mgr_count;
  nb_list = 0;
  axis = (char *) malloc((Mgr_count+count)*sizeof(char));
  plate_side = (int *) malloc((Mgr_count+count)*sizeof(int));
  
  for (j=0;j<count;j++)
  {
                                  /* get control line's attributes */
    status = om$send(msg = message VLctrLine.VLget_attributes(
                                              &loc_msg,
                                              side,
                                              NULL,
                                              &axis[j],
                                              NULL),
                            senderid = NULL_OBJID,
                            targetid = list[j].obj_id.objid,
                            targetos = list[j].obj_id.osnum);

    if (!(status&loc_msg&1)) {
      printf("problems in getting attributes\n");
      goto quit;
    }
    if (!strcmp(side,VS_K_plTopSfPath)) plate_side[j] = INVNORM_ON;
    else plate_side[j] = INVNORM_OF;
  }
  for (j=0;j<Mgr_count;j++)
  {
   status = om$send(msg = message NDnode.NDget_objects(
                                              ND_ROOT,temp_list,
                                              200,
                                              NULL, 0,
                                              OM_K_MAXINT, &nb_temp),
                               senderid = NULL_OBJID,
                               targetos = tp_manager[j].obj_id.osnum,
                               targetid = tp_manager[j].obj_id.objid);
    if (!(status&1)) {
      goto quit;
    }
    status = om$send(msg = message ACrg_collect.AClist_attribute
                                                (&loc_msg,100,list_att,&nb_att),
                       senderid = NULL_OBJID,
                       targetid = temp_list[IDX_TM_ATTR].objid,
                       targetos = temp_list[IDX_TM_ATTR].osnum);
    if (!(status&loc_msg&1)) {
      goto quit;
    }
    if ((i=VLseekFields(list_att,nb_att,NAM_TM_INV)) != -1) {
        plate_side[j+count] = list_att[i].desc.value.att_exp;
        if (plate_side[j+count] != INVNORM_ON &&
            plate_side[j+count] != INVNORM_OF) {
            printf("Error in template manager's inv_norm attribute\n");      
        }
    }
    else goto quit;

    if ((i=VLseekFields(list_att,nb_att,NAM_TM_AXIS)) != -1) {
      if (list_att[i].desc.value.att_exp == IDX_AX1) axis[j+count] = 'x';
      else if (list_att[i].desc.value.att_exp == IDX_AX2) axis[j+count] = 'y';
           else axis[j+count] = 'z';
    }
    else goto quit;
  }
  for (i=1;i<count+Mgr_count;i++)
  {
    for (j=i-1;j>=0;j--) {
      if (axis[i] == axis[j] && plate_side[i] == plate_side[j]) {
        if (i < count) {
          list[i].obj_id.objid = NULL_OBJID;
          nb_list++;
        }
        else  {
          cntrl[i-count].obj_id.objid = NULL_OBJID;
          (*ln_to_add)--;
        }
        break;
      }
    }
  }
  (*ln_to_add) -= nb_list;
  msg = MSSUCC;
  quit :
  if (axis) {free(axis); axis = NULL;}
  if (plate_side) {free(plate_side); plate_side = NULL;}
  return msg;
}

/*===========================================================================*/

/*d the function build a ccordinate system knowing the origin and 
    a view matrix. */

/*h 23/novenber/92 JLL creation date */
/*===========================================================================*/
IGRlong VLcreWinRef (

IGRdouble		*orig,    /*I   Origin of the referential */
struct GRid		winObj,   /*I   a win ID to get the axis */
IGRboolean		creOpt,   /*I   TRUE -> a referential is created 
					FALSE -> only refMat is created */
struct GRvg_construct	*cst,	  /*I   the cst */
IGRboolean		disOpt,   /*I   TRUE -> the ref object is displayed */
IGRdouble		*refMat,  /*O   the output matrix */
struct GRobj_env	*refGRid, /*O   the ref object created */
IGRlong			*rc       /*O	MSSUCC or MSFAIL */
)

/*c beginning of code */

{

	IGRint		i, k;
	IGRlong		MSsts;
	IGRdouble	viewMat[16];
struct  IGRlbsys  	cs_sys;
struct  GRcs_construct  cs_args;  /* Specific default attribute for cs       */

	refGRid->obj_id.objid = NULL_OBJID;
	refGRid->obj_id.osnum = cst->env_info->md_id.osnum;

  	MSsts = om$send( msg      = message  IGEgragad.DPinrot(rc,viewMat ),
		         senderid = NULL_OBJID,
	   	         targetid = winObj.objid,
	   	         targetos = winObj.osnum );
	if( !(*rc&MSsts&1) ) {
		#ifdef DEBUG
			printf(" error in IGEgragad.DPinrot\n");
		#endif
		goto wrapup;
	}
	#ifdef DEBUG
		for(i=0;i<16;i+=4)
		printf("mat[%d]= %f,%f,%f,%f\n",i,viewMat[i],viewMat[i+1],
				    viewMat[i+2],viewMat[i+3]);
	#endif

	for(i=0;i<3;i++){
		k = 4*i;
		cs_sys.diag_pt1[i]  	= 0.0;
		cs_sys.diag_pt2[i]  	= 0.0;
		refMat[k]    	    	= viewMat[i];
		refMat[k+1]  		= viewMat[i+4];
		refMat[k+2]  		= viewMat[i+8];
		refMat[k+3]  		= orig[i];
		refMat[12+i] 		= 0.0;
	}
	refMat[15] = 1.0;

	if( creOpt == TRUE ){

		memcpy( (IGRchar*)cs_sys.matrix,
			(IGRchar*)refMat, (IGRint) 16*sizeof(IGRdouble));
	

   		cs_args.desc    = NULL;
   		cs_args.flag    = CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
		cst->class_attr = (IGRchar *)&cs_args;
  		cst->geometry   = (IGRchar *)&cs_sys;

  		MSsts = om$construct( 
			      classid = OPP_GRgencs_class_id, 
	                      p_objid = &refGRid->obj_id.objid, 
         	              osnum   = refGRid->obj_id.osnum,
			      msg     = message GRgraphics.GRconstruct(cst));
		if( !(MSsts&1) ) {
			#ifdef DEBUG
			write(" error in GRgencs.GRconstruct\n");
			#endif
			goto wrapup;
		}

		refGRid->mod_env = *(cst->env_info);

		if( disOpt == TRUE ){

		gr$display_object ( object_id = (struct GRid *)&refGRid->obj_id,
                	    	    md_env    = cst->env_info,
		     	    	    mode      = GRbd );
		}

		ASmake_source_from_env( &refGRid->obj_id, 
					cst->env_info, &refGRid->obj_id );	
	}
	cst->geometry = NULL;
	*rc = MSSUCC;
	return(MSSUCC);
	
wrapup:
	cst->geometry = NULL;
	*rc = MSFAIL;
	return(MSFAIL);

}
/*****************************************************************************/
/*d This function constructs the from matrix which will be use by 
    VLapplyTransf() using the range of a linestring. This linestring
    has been build by the minimum rectangle encompassing a planar object.
    This function use GRvg.GRgenabsg so do not be surprise if your
    geometry is modifyed.
    the x axis of the matrix is lying the largest length of the
    rectangle.
 */
/*****************************************************************************/

VLcreFromMat( RNG, mod_env, fromMat, ret )


/*h 23/novenber/92 JLL creation date */

struct	GRid		RNG;	  /*I the linestring defining the minimum
				      rectangle */
struct	GRmd_env	*mod_env; /*I mod env the linetring */
	IGRdouble	*fromMat; /*O the from matrix */
	IGRlong		*ret;	  /*O return code MSSUCC or MSFAIL */

{

struct	IGRbsp_curve 	*cv;
	IGRlong		stat;
	IGRdouble	vx[3], vy[3], vz[3], vxRef[3], vyRef[3];
	IGRint		i, j;



	/*c retrieve the poles of the rectangle */

	cv = NULL;
	stat = om$send ( msg      = message GRvg.GRgenabsg (
					ret,
            				&mod_env->md_env.matrix_type,
            				mod_env->md_env.matrix,
			     		(IGRchar **)&cv ),
		         senderid = NULL_OBJID,
	   		 targetid = RNG.objid,
	   		 targetos = RNG.osnum );


	/*c define the x and y axis */ 

	for(i=0;i<3;i++){
		fromMat[4*i+3]	= cv->poles[i];
		vx[i] 		= cv->poles[3+i] - cv->poles[i];
		vy[i]		= cv->poles[9+i] - cv->poles[i];
	}


	/*c if the length of the x axis is less than y axis switch the axis
	    to get full time the largest length along the x axis of the
	    view */

	if( BSdotp(ret,vx,vx) < BSdotp(ret,vy,vy) ){
		for(i=0;i<3;i++){
			vz[0] = vx[i];
			vx[i] = vy[i];
			vy[i] = vz[0];
		}
	}

	vxRef[0] = 1.0;
	vxRef[1] = 0.0;
	vxRef[2] = 0.0;
	vyRef[0] = 0.0;
	vyRef[1] = 1.0;
	vyRef[2] = 0.0;


	if( BSdotp(ret,vxRef,vx) < 0.0 ){
		vx[0] = -1.0*vx[0];
		vx[1] = -1.0*vx[1];
		vx[2] = -1.0*vx[2];
	}
	if( BSdotp(ret,vyRef,vy) < 0.0 ){
		vy[0] = -1.0*vy[0];
		vy[1] = -1.0*vy[1];
		vy[2] = -1.0*vy[2];
	}
	
	BSnorvec(ret,vx);
	BSnorvec(ret,vy);
	BScrossp(ret,vx,vy,vz);
	BSnorvec(ret,vz);

	for ( i=0; i<3; i++) {
		j = 4 * i;
		fromMat[j]   = vx[i];
		fromMat[j+1] = vy[i];
		fromMat[j+2] = vz[i];
		fromMat[j+3] = cv->poles[i];
	}

	fromMat[12] = fromMat[13] = fromMat[14] = 0.0;
	fromMat[15] = 1.0;

	*ret = MSSUCC;
	return(MSSUCC);
}
/*****************************************************************************/
/*d This function constructs the from matrix which will be use by 
    VLapplyTransf() using the range of a linestring. This linestring
    has been build by the minimum rectangle encompassing a planar object.
    This function use GRvg.GRgenabsg so do not be surprise if your
    geometry is modifyed.
    the x axis of the matrix is lying the largest length of the
    rectangle.
 */
/*****************************************************************************/
    
VLnewCreFromMat1 (

struct	GRid		RNG,	  /*I the linestring defining the minimum
				      rectangle */
struct	GRmd_env	*mod_env, /*I mod env the linetring */
	/*       IGRboolean	isZaxisReversed, */
				  /*I tells if regarding to the thickness of
				      the plate the z axis is reversed or not */
	IGRdouble	*fromMat, /*O the from matrix */
	IGRlong		*ret	  /*O return code MSSUCC or MSFAIL */
)


/*h 23/novenber/92 JLL creation date */

{

struct	IGRbsp_curve 	*cv;
	IGRlong		stat;
	IGRdouble	vx[3], vy[3], vz[3], vxRef[3], vyRef[3];
	IGRdouble	vxLen, vyLen, signInX, signInY;
	IGRint		i, j, indPi[3];



	/*c retrieve the poles of the rectangle */

	cv = NULL;
	stat = om$send ( msg      = message GRvg.GRgenabsg (
					ret,
            				&mod_env->md_env.matrix_type,
            				mod_env->md_env.matrix,
			     		(IGRchar **)&cv ),
		         senderid = NULL_OBJID,
	   		 targetid = RNG.objid,
	   		 targetos = RNG.osnum );

	
	/*c because the unwraping is done in the xyz world coordinate
	    systeme, we can set up our referential axis as follow */	

	vxRef[0] = 1.0;
	vxRef[1] = 0.0;
	vxRef[2] = 0.0;
	vyRef[0] = 0.0;
	vyRef[1] = 1.0;
	vyRef[2] = 0.0;

	/*c the minimun rectangle is lying the xy world coordinate plane.
	    To find the lower left corner we need to first rotate this
	    rectangle such that his major axis will be parallele to the
	    world coordinate axis. */
	


	/*c define the x and y axis from the rectangle */ 

	for(i=0;i<3;i++){
		vx[i] 		= cv->poles[3+i] - cv->poles[i];
		vy[i]		= cv->poles[9+i] - cv->poles[i];
	}

	vxLen = sqrt( (BSdotp(ret,vx,vx)) );
	vyLen = sqrt( (BSdotp(ret,vy,vy)) );

	signInX = BSdotp(ret,vxRef,vx);
	signInY = BSdotp(ret,vyRef,vy);


	if( vxLen > vyLen ){
		if     ( (signInX > 0.0) && (signInY > 0.0) ){
			indPi[0] = 0;
			indPi[1] = 3;
			indPi[2] = 9;
		}
		else if( (signInX < 0.0) && (signInY > 0.0) ){
			indPi[0] = 3;
			indPi[1] = 0;
			indPi[2] = 6;
		}
		else if( (signInX > 0.0) && (signInY < 0.0) ){
			indPi[0] = 9;
			indPi[1] = 6;
			indPi[2] = 0;
		}
		else if(  (signInX < 0.0) && (signInY < 0.0) ){
			indPi[0] = 6;
			indPi[1] = 9;
			indPi[2] = 3;
		}
		else{
			indPi[0] = 0;
			indPi[1] = 3;
			indPi[2] = 9;
		} 
	}
	else{

		if     ( (signInX > 0.0) && (signInY > 0.0) ){
			indPi[0] = 3;
			indPi[1] = 6;
			indPi[2] = 0;
		}
		else if( (signInX < 0.0) && (signInY > 0.0) ){
			indPi[0] = 0;
			indPi[1] = 9;
			indPi[2] = 3;
		}
		else if( (signInX > 0.0) && (signInY < 0.0) ){
			indPi[0] = 6;
			indPi[1] = 3;
			indPi[2] = 9;
		}
		else if(  (signInX < 0.0) && (signInY < 0.0) ){
			indPi[0] = 9;
			indPi[1] = 0;
			indPi[2] = 6;
		}
		else{
			indPi[0] = 3;
			indPi[1] = 6;
			indPi[2] = 0;
		} 

	}

	#ifdef DEBUG
	printf("signInX = %d, signInY = %d\n",signInX,signInY); 
	printf("indPi[0] = %d, indPi[1] = %d, indPi[2] = %d\n",
		 indPi[0],indPi[1] , indPi[2] ); 
	#endif

	for(i=0;i<3;i++){
		vx[i] = cv->poles[indPi[1]+i] - cv->poles[indPi[0]+i];
		vy[i] = cv->poles[indPi[2]+i] - cv->poles[indPi[0]+i];
	}


	
	BSnorvec(ret,vx);
	BSnorvec(ret,vy);
	BScrossp(ret,vx,vy,vz);
	BSnorvec(ret,vz);

	for ( i=0; i<3; i++) {
		j = 4 * i;
		fromMat[j]   = vx[i];
		fromMat[j+1] = vy[i];
		fromMat[j+2] = vz[i];
		fromMat[j+3] = cv->poles[indPi[0]+i];
	}

	fromMat[12] = fromMat[13] = fromMat[14] = 0.0;
	fromMat[15] = 1.0;

	*ret = MSSUCC;
	return(MSSUCC);
}
/*****************************************************************************/

/*d This function constructs the from matrix which will be use by 
    VLapplyTransf() using the range of a linestring. This linestring
    has been build by the minimum rectangle encompassing a planar object.
    This function use GRvg.GRgenabsg so do not be surprise if your
    geometry is modifyed.
    the x axis of the matrix is lying the largest length of the
    rectangle.
 */
/*****************************************************************************/
    

/*h 23/novenber/92 JLL creation date */
VLnewCreFromMat (

struct	GRid		RNG,	  /*I the linestring defining the minimum
				      rectangle */
struct	GRmd_env	*mod_env, /*I mod env the linetring */
struct  mise_a_plat	*dev,     /*I to know if:
				      - the surface is flat.
						( dev->devellopable = 1 )
				      - to evaluate the good z axis of the
					matrix according on which side we see
					the plate */
				  /*I tells if regarding to the thickness of
				      the plate the z axis is reversed or not */
	IGRdouble	*fromMat, /*O the from matrix */
	IGRlong		*ret	  /*O return code MSSUCC or MSFAIL */
)

{

struct	IGRbsp_curve 	*cv;
	IGRlong		stat;
	IGRdouble	vx[3], vy[3], vz[3], vxRef[3], vyRef[3];
	IGRdouble	vxLen, vyLen;
	IGRint		i, j, indPi[3];
	IGRdouble	points[3];
	IGRint		num;

	/*c retrieve the poles of the rectangle */

	cv = NULL;
	stat = om$send ( msg      = message GRvg.GRgenabsg (
					ret,
            				&mod_env->md_env.matrix_type,
            				mod_env->md_env.matrix,
			     		(IGRchar **)&cv ),
		         senderid = NULL_OBJID,
	   		 targetid = RNG.objid,
	   		 targetos = RNG.osnum );

	/* evaluate the normal of the unfold surface at the param(0.5,0.5) */

  	BSsfevaln(dev->devsrf,0.5,0.5,1,&num,points,vz,&stat);
  	if (stat != BSSUCC) {
		printf("Error in VLnewCreFromMat\n");
		printf("BSsfevaln Failed\n");
		goto wrapup;
  	}
  	BSnorvec(&stat,vz);
	
	/* check to have the vz axis pointing in my direction */
	if( dev->epaisseur > 0.0 ) for(i=0;i<3;i++) vz[i] = -vz[i];

	/*c select the major axis as the x axis */ 

	for(i=0;i<3;i++){
		vx[i] 		= cv->poles[3+i] - cv->poles[i];
		vyRef[i]	= cv->poles[9+i] - cv->poles[i];
	}

	vxLen = sqrt( (BSdotp(&stat,vx,vx)) );
	vyLen = sqrt( (BSdotp(&stat,vyRef,vyRef)) );


	/*c because the planar and non planar case are not anymore identical
	    we should solve the two cases separetly */

	#ifdef DEBUG
	__DBGpr_bscv( "poles min rec", cv, &stat );
	#endif

//	if( dev->developpable == 1 ){

		if( vyLen > vxLen ){

			for(i=0;i<3;i++){
				 vxRef[i] = vx[i];
				 vx[i] = vyRef[i];
				 vyRef[i] = vxRef[i];
			}

			BSnorvec(&stat,vx);
			BScrossp(&stat,vz,vx,vy);
			BSnorvec(&stat,vy);
			indPi[0] = 0;
		
			if( BSdotp(&stat,vy,vyRef) < 0.0 ) indPi[0] = 3;
//			printf("vyLen >>> vxLen indPi[0] = %d\n",indPi[0]);

		}
		else{
			BSnorvec(&stat,vx);
			BScrossp(&stat,vz,vx,vy);
			BSnorvec(&stat,vy);
			indPi[0] = 0;
			if( BSdotp(&stat,vy,vyRef) < 0.0 ) indPi[0] = 9;
//			printf("vyLen <<< vxLen indPi[0] = %d\n",indPi[0]);
		}

//	}
//	else{

//		if( vyLen > vxLen ) for(i=0;i<3;i++) vx[i] = vy[i];
//		BSnorvec(&stat,vx);
//		BScrossp(&stat,vz,vx,vy);
//		BSnorvec(&stat,vy);
//		indPi[0] = 0;

	
		/*c because the unwraping is done in the xyz world coordinate
	    	    systeme, we can set up our referential axis as follow */
	
		/*c the minimun rectangle is lying the xy world coordinate 
		    plane.
	    	    To find the lower left corner we need to first rotate this
	    	    rectangle such that his major axis will be parallele to the
	    	    world coordinate axis. */

/*
		vxRef[0] = 1.0;
		vxRef[1] = 0.0;
		vxRef[2] = 0.0;
		vyRef[0] = 0.0;
		vyRef[1] = 1.0;
		vyRef[2] = 0.0;

	



		signInX = BSdotp(ret,vxRef,vx);
		signInY = BSdotp(ret,vyRef,vy);


		if( vxLen > vyLen ){
			if ( (signInX > 0.0) && (signInY > 0.0) ){
				indPi[0] = 0;
				indPi[1] = 3;
				indPi[2] = 9;
			}
			else if( (signInX < 0.0) && (signInY > 0.0) ){
				indPi[0] = 3;
				indPi[1] = 0;
				indPi[2] = 6;
			}
			else if( (signInX > 0.0) && (signInY < 0.0) ){
				indPi[0] = 9;
				indPi[1] = 6;
				indPi[2] = 0;
			}
			else if(  (signInX < 0.0) && (signInY < 0.0) ){
				indPi[0] = 6;
				indPi[1] = 9;
				indPi[2] = 3;
			}
			else{
				indPi[0] = 0;
				indPi[1] = 3;
				indPi[2] = 9;
			} 
		}
		else{

			if( (signInX > 0.0) && (signInY > 0.0) ){
				indPi[0] = 3;
				indPi[1] = 6;
				indPi[2] = 0;
			}
			else if( (signInX < 0.0) && (signInY > 0.0) ){
				indPi[0] = 0;
				indPi[1] = 9;
				indPi[2] = 3;
			}
			else if( (signInX > 0.0) && (signInY < 0.0) ){
				indPi[0] = 6;
				indPi[1] = 3;
				indPi[2] = 9;
			}
			else if(  (signInX < 0.0) && (signInY < 0.0) ){
				indPi[0] = 9;
				indPi[1] = 0;
				indPi[2] = 6;
			}
			else{
				indPi[0] = 3;
				indPi[1] = 6;
				indPi[2] = 0;
			} 

		}

		#ifdef DEBUG
		printf("signInX = %d, signInY = %d\n",signInX,signInY); 
		printf("indPi[0] = %d, indPi[1] = %d, indPi[2] = %d\n",
			 indPi[0],indPi[1] , indPi[2] ); 
		#endif

		for(i=0;i<3;i++){
			vx[i] = cv->poles[indPi[1]+i] - cv->poles[indPi[0]+i];
			vy[i] = cv->poles[indPi[2]+i] - cv->poles[indPi[0]+i];
		}

		BSnorvec(ret,vx);
		BSnorvec(ret,vy);
		BScrossp(ret,vx,vy,vz);
		BSnorvec(ret,vz);
*/

//	} 

	

	for ( i=0; i<3; i++) {
		j = 4 * i;
		fromMat[j]   = vx[i];
		fromMat[j+1] = vy[i];
		fromMat[j+2] = vz[i];
		fromMat[j+3] = cv->poles[indPi[0]+i];
	}

	fromMat[12] = fromMat[13] = fromMat[14] = 0.0;
	fromMat[15] = 1.0;

	*ret = MSSUCC;
	return(MSSUCC);

wrapup:
	*ret = MSFAIL;
	return( MSFAIL);
}
/*****************************************************************************/

/*d This function apply a transformation matrix, builded using the two matrix */

/*h 23/novembre/92 JLL creation date */
/*h 29/december/92 JLL add NumObj argument to make the function more general*/
/*h  7/mai/94      jll add trfMat and trfMatType as output arg */
/*****************************************************************************/

IGRlong VLapplyTransf( Obj, NumObj, mod_env, FromMat, ToMat, trfMat, trfMatType,
                       msg )

struct	GRid		*Obj;	     /*I list of  graphic objects on which 
					 we apply the transformation */
	IGRint		NumObj;      /*I Number of graphic objects */
struct	GRmd_env	*mod_env;    /*I the module of the object */
	IGRdouble	*FromMat;    /*I the from matrix */
	IGRdouble	*ToMat;      /*I the to matrix */
	IGRdouble	*trfMat;     /*O the resulting transformation matrix */
	IGRshort	*trfMatType; /*O the matrix type */
	IGRlong		*msg;	     /*O return code MSSUCC or MSFAIL */

{
	IGRint		four;
	IGRdouble	tmp_matrix[16];
	IGRlong		stat;
	struct	GRid	LocCopiedObj;
	IGRint		i;

	four = 4;

	/* Evaluate the transformation matrix.*/

  	MAinvmx ( msg, &four, FromMat, tmp_matrix);
  	MAmulmx ( msg, &four, &four, &four, ToMat, tmp_matrix, trfMat);
	MAtypemx( msg, trfMat, trfMatType);


	for(i=0;i<NumObj;i++){

	   if( Obj[i].objid != NULL_OBJID ){
  		stat = om$send ( msg      = message GRgraphics.GRxform (
						msg,
            					mod_env,
						trfMatType,
						trfMat,
						&LocCopiedObj.objid ),
			        senderid = NULL_OBJID,
	   		        targetid = Obj[i].objid,
	   			targetos = Obj[i].osnum );
		if (!((*msg)&stat&1)) {
       			write ("Error GRgraphics.GRxform");
       			goto wrapup;
		}
			
		if( LocCopiedObj.objid != Obj[i].objid ){
			Obj[i].objid = LocCopiedObj.objid;
			Obj[i].osnum = mod_env->md_id.osnum;
		}
	    }

	}

	*msg = MSSUCC;
	return(MSSUCC);


wrapup:
	*msg = MSFAIL;
	return(MSFAIL);


}

/*****************************************************************************/
	
void __DBGpr_bscv( txt, bsp, rc )

IGRchar			*txt; 
struct IGRbsp_curve 	*bsp;
IGRlong			*rc;


{

IGRint	i,j, k;

  printf(txt);
  printf("\n");
 
  if( bsp == NULL ){
	printf("Error in __DBGpr_bscv\n");
	printf("curve has a null pointer \n");
	*rc = BSFAIL;
	return;
  }

  printf("      order = %d, num_poles = %d, num_knots = %d\n",
	  bsp->order,bsp->num_poles,bsp->num_knots);

  k = bsp->num_poles;

  if( bsp->rational == FALSE ){
	for(i=0;i<k;i=i+1){
		j= 3*i;
		printf( "      poles[%d] = %15.3f, %15.3f, %15.3f\n",i,
		bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2]);
	}
  }
  else{
	
	for(i=0;i<k;i=i+1){
		j= 3*i;
		printf("      poles[%d] = %15.3f, %15.3f, %15.3f, %15.6f\n",i,
		bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2],bsp->weights[i]);
	}
  }

  k = bsp->num_knots;

  for(i=0;i<k;i=i+1) printf("      knots[%d] = %12.10f\n",i,bsp->knots[i]);

  *rc = BSSUCC;  
  return;
}

end implementation VLabstract;
