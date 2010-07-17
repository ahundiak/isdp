/* $Id: VLdToolsFunk.I,v 1.3 2001/02/20 01:06:48 build Exp $  */

/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loftdp/ src/unfold/VLdToolsFunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLdToolsFunk.I,v $
 *      Revision 1.3  2001/02/20 01:06:48  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 19:49:23  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/05/17  20:38:04  pinnacle
# Replaced: loft/src/tools/VLdToolsFunk.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/05/02  23:15:36  pinnacle
# Created: loft/src/unfold/VLdToolsFunk.I by rchennup for Service Pack
#
# Revision 1.2  1999/06/01  22:25:22  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.6  1997/01/29  20:29:34  pinnacle
# Replaced: src/unfold/VLdToolsFunk.I for:  by rchennup for loft
#
# Revision 1.5  1996/05/01  06:54:18  pinnacle
# Replaced: src/unfold/VLdToolsFunk.I for:  by rchennup for loft
#
# Revision 1.4  1996/01/31  09:03:14  pinnacle
# Replaced: src/unfold/VLdToolsFunk.I for:  by svkadamb for loft
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

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
#include "values.h"
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
#include "DIprims.h"
#include "vlforkmacros.h"
#include "ACattrib.h"
#include "vlstifftpl.h"
#include "vldbgmacros.h"
#include "v_datamacros.h"

#define vsDEBUG		1
#define vserrDEBUG	1
  
from    GRcurve		import  GRendpts;
from    GRgencs         import  GRgetmatrix;
from    GRcurve         import  GRmidpoint;
from    EMSsubbs        import  EMget_props;
from    EMSsfimpbnd     import  EMget_subbs;

extern GRclassid        OPP_ACheader_class_id, OPP_EMSgenbs_class_id;

extern 			BSchtptstsf();
extern 			BSchtptstso();
extern 			BSsfarrevn();
extern 			BSkts_f_fit();
extern 			BSkts_f_app();
extern 			BSrev_cv();
extern			GRdpb_get();
extern			GRdpb_put();
extern	IGRdouble	BSdistptpt();
extern	IGRboolean	BScrossp();
extern	IGRdouble	BSdotp();
extern	IGRdouble	BSlenvec();
extern  IGRboolean	BSnorvec();
extern  void		BSchtptstcv();
extern	void		BSalloccv(), BSallocsf();
extern	IGRboolean	BSfreecv(), BSfreesf();
extern  IGRchar		*memcpy();
extern  void		BSsfeval();
extern			GRdisplay_object();
extern  IGRdouble	sqrt();
extern	IGRdouble	cos(),fabs();
extern			ASmake_source_from_env();
extern IGRint 		MAinvmx();
extern IGRint 		MAmulmx();
extern IGRboolean	MAtypemx();
extern IGRint 		BSsfevaln();
extern 			VLbrowseFctInTree();
extern 			VLfilterClass();
extern  int             VLgetMacrosAtStep();
extern  void            FAevPtSfFaDr();
extern struct GRid      NULL_GRID;

IGRlong VLunwPlateHasVABevel(   IGRlong                 *msg,
                                struct GRobj_env        *plate,
                                IGRint                  *count,
                                struct GRobj_env        **list,
                                IGRint                  to_extend,
                                IGRchar                 *side_to_extend,
                                struct GRobj_env        *ext_surf )
{
IGRlong                 sts;
IGRint                  i, loc_sts, numObjects=0;
struct GRobj_env        surf_obj, *list_obj=NULL;
struct IGRbsp_surface   *ext_surf_geom=NULL;
struct  GRvg_construct  cst;

  SetProc( VLunwPlateHasVABevel ); Begin

  if( !plate || !count )        return OM_E_INVARG;

  sts = *msg = MSSUCC;
  __DBGpr_obj("Input Plate ", plate->obj_id );
  VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep, &numObjects, &list_obj );
  VLfilterDef( numObjects, list_obj, &numObjects, "VA_Bevel" );
  __DBGpr_int("Number of Variable Bevels ", numObjects );

  *count = numObjects ;

  if( !numObjects ) { sts = MSSUCC; goto wrapup; }

  if( list )
  {
     *list = NULL ;
     if( !( (*list) = _MALLOC( numObjects, struct GRobj_env ))) vd_$mem_fail();
     for( i=0; i<numObjects; ++i ) (*list)[i] = list_obj[i];
  }

  __DBGpr_int("Want to extend the Base Surface? ", to_extend );
  if( !to_extend || !ext_surf ) { sts = MSSUCC; goto wrapup; }

  VLinitCnst( &cst );
  ext_surf->_objid  = NULL_OBJID;
  ext_surf->_osnum  = cst.env_info->md_id.osnum;
  ext_surf->mod_env = *(cst.env_info);

  __DBGpr_str("Side to extend ", side_to_extend );
  sts = om$send( msg = message NDmacro.ACreturn_foot( msg,
                        side_to_extend, &surf_obj.obj_id,
                        &surf_obj._matrix_type, surf_obj._matrix ),
                senderid = plate->_objid,
                targetid = plate->_objid,
                targetos = plate->_osnum  );
  __CheckRC( sts, *msg, "NDmacro.ACreturn_foot: Base Surface", wrapup );
  surf_obj._md_os = surf_obj._osnum;
  ex$get_modid ( mod_osnum = surf_obj._md_os,
                 mod_id    = &surf_obj._md_id );
  __DBGpr_obj("Base Surface ", surf_obj.obj_id );
  __DBGpr_obj("Surface Mod Id ", surf_obj.mod_env.md_id );

  if( !get_extsurf_geom( &surf_obj.obj_id, &surf_obj.mod_env,
                         50.0, &ext_surf_geom )) goto wrapup;

  cst.geometry      = (IGRchar *) ext_surf_geom;
  sts =  om$construct(  classid = OPP_EMSgenbs_class_id,
                        p_objid = &ext_surf->_objid,
                        osnum   = ext_surf->_osnum,
                        msg     = message GRgraphics.GRconstruct(&cst) );
  __DBGpr_obj("Extended Surface ", ext_surf->obj_id );

wrapup:
  _FREE( list_obj );
  _FREE( ext_surf_geom );
  End
  return MSSUCC;
}

/******************** VLextractSurf *************************************/
/*									*/
/* This function extract the surface from a plate or a image,           */
/* and avoid problems with reference files                              */
/*									*/
/************************************************************************/

IGRlong VLextractSurf ( surf, cur_env,dev,plate_obj)
struct GRid		*surf;    /*I: located object */
struct GRmd_env         *cur_env; /*I: current environment */
struct mise_a_plat	*dev;    /* O: structure to fill with informations */
struct GRobj_env        *plate_obj;/*O: the plate, it may be NULL if we
                                        don't want it */
{
long			i_sts,msg,stat;
int			dim,tmp,loc_sts,numObjects=0, vb_count=0;
struct GRid 		id;
struct ret_struct	ret_struct;
struct GRobj_env	*plate,pl,*list_obj=NULL, ext_surf;
OMuword                 plate_cl, GoTemp_cl;
OMuword                 img_cl,sfimp_cl, sfrembnd_cl;
char			word[50];
unsigned char		props;

  msg = MSFAIL;
  if (plate_obj == NULL) plate = &pl;
  else                   plate = plate_obj;
  /*---------------------------------------------------------*/
  /*c retrieve the support surface and retrieve the geometry */
  /*---------------------------------------------------------*/

  dev->res_id = *surf;

  	i_sts = om$send( msg      = message NDmacro.ACreturn_foot(	
					&stat ,
					"",
					&(plate->obj_id), 
					&(plate->mod_env.md_env.matrix_type), 
					plate->mod_env.md_env.matrix ),
	         senderid = NULL_OBJID,
	         targetid = surf->objid,
	         targetos = surf->osnum );
  	__CheckRC( i_sts, stat, "NDmacro.ACreturn_foot", quit );

  plate->mod_env.md_id.osnum = plate->obj_id.osnum;
  ex$get_modid(	mod_osnum = plate->mod_env.md_id.osnum,
	        mod_id    = &plate->mod_env.md_id.objid) ;

  __DBGpr_obj("plate ",plate->obj_id );

  om$get_classid ( classname = "VSplate",      p_classid = &plate_cl );
  om$get_classid ( classname = "VSimgFeature", p_classid = &img_cl );
  om$get_classid ( classname = "EMSsfimpbnd",  p_classid = &sfimp_cl );
  om$get_classid ( osnum     = plate->obj_id.osnum,
		   objid     = plate->obj_id.objid,
		   p_classid = &GoTemp_cl ) ;
  if( 
      (om$is_ancestry_valid( superclassid = plate_cl,
			    subclassid	 = GoTemp_cl ) == OM_S_SUCCESS ) ||
      (om$is_ancestry_valid( superclassid = img_cl,
			    subclassid	 = GoTemp_cl ) == OM_S_SUCCESS )
    ) {

	VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL,VL_Q_DOWN_DIRECT,
			   VLgetMacrosAtStep, &numObjects, &list_obj );
	VLfilterDef(numObjects, list_obj, &numObjects,"srf_rogue" );

        if( numObjects )
        {
          i_sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &stat,
                                      "Surf",
                                      &dev->surf_id.obj_id,
                                      &dev->surf_id.mod_env.md_env.matrix_type,
                                      dev->surf_id.mod_env.md_env.matrix ),
                               senderid = NULL_OBJID,
                               targetid = list_obj[0].obj_id.objid,
                               targetos = list_obj[0].obj_id.osnum ) ;
          dev->surf_id.mod_env.md_id.osnum = dev->surf_id.obj_id.osnum;
          dev->surf_id.mod_env.md_id.objid = list_obj[0].mod_env.md_id.objid;
          if (list_obj[0].mod_env.md_env.matrix_type != MAIDMX) {
        	dim = 4;
        	MAmulmx(&stat,&dim,&dim,&dim,list_obj[0].mod_env.md_env.matrix,
                	dev->surf_id.mod_env.md_env.matrix,
                	dev->surf_id.mod_env.md_env.matrix);
        	MAtypemx( &stat, dev->surf_id.mod_env.md_env.matrix,
                  	&dev->surf_id.mod_env.md_env.matrix_type);
          }
	  goto make_source;
	}

	/*
	 * Choose the side of plate 
	 

        if (dev->side_of_plate == MAX_MARK)
          VLget_side_w_more_mrkln(plate,word);
        else {
          if (dev->side_of_plate == OFFSET_SIDE)
            strcpy(word,VS_K_plTopSfPath);
          else strcpy(word,VS_K_plBotSfPath);
        }
	*/

	if(  dev->side_of_plate == OFFSET_SIDE || 
	     dev->side_of_plate == OFFSET_FLIP ) strcpy(word,VS_K_plTopSfPath);
	else strcpy(word,VS_K_plBotSfPath);

 	i_sts = VLunwPlateHasVABevel( &stat, plate, &vb_count, NULL,
		 	TRUE, word, &ext_surf );
	__CheckRC( i_sts, stat, "VLunwPlateHasVABevel", quit );	
	if( vb_count && ext_surf.obj_id.objid != NULL_OBJID )
	{
	   dev->surf_id = ext_surf;
	   goto make_source;
	}

	i_sts = om$send( msg	= message NDmacro.ACreturn_foot(
				      &stat,
				      word,
				      &dev->surf_id.obj_id,
				      &dev->surf_id.mod_env.md_env.matrix_type,
				      dev->surf_id.mod_env.md_env.matrix ),
		       	       senderid = NULL_OBJID,
		       	       targetid = plate->obj_id.objid,
		       	       targetos = plate->obj_id.osnum ) ;

	__CheckRC( i_sts, stat, "NDmacro.ACreturn_foot", quit );

        dev->surf_id.mod_env.md_id.osnum = dev->surf_id.obj_id.osnum;
        dev->surf_id.mod_env.md_id.objid = plate->mod_env.md_id.objid;
        if (plate->mod_env.md_env.matrix_type != MAIDMX) {
        dim = 4;
        MAmulmx(&stat,&dim,&dim,&dim,plate->mod_env.md_env.matrix,
                dev->surf_id.mod_env.md_env.matrix,
                dev->surf_id.mod_env.md_env.matrix);
        MAtypemx( &stat, dev->surf_id.mod_env.md_env.matrix,
                  &dev->surf_id.mod_env.md_env.matrix_type);
        }
  	if( om$is_ancestry_valid( superclassid = img_cl,
			          subclassid   = GoTemp_cl ) == OM_S_SUCCESS ) {
          i_sts = om$send(msg = message GRgraphics.GRcopy(
                                                  &stat,
                                                  &dev->surf_id.mod_env,
                                                  cur_env,
                                                  &(id.objid) ),
                                  senderid = NULL_OBJID,
                                  targetid = dev->surf_id.obj_id.objid,
                                  targetos = dev->surf_id.obj_id.osnum );
          dev->surf_id.obj_id.osnum = cur_env->md_id.osnum;
          dev->surf_id.obj_id.objid = id.objid;
          dev->surf_id.mod_env = *cur_env;
          if( ! (i_sts&stat&1)){
            printf("Problems at GRcopy\n");
            goto quit;
          }
        }

make_source:
        as$make_source(go_grid = dev->surf_id.obj_id,
                       mod_env = &dev->surf_id.mod_env,
                       as_os = cur_env->md_id.osnum,
                       as_grid = &dev->res_id);

	__DBGpr_obj("surf_id = ",dev->surf_id.obj_id );

	/* retrieve the thickness */

	tmp = 0 ;
	i_sts = om$send( msg	= message NDmacro.ACgive_structure(
					&loc_sts,
					&tmp,
					VS_K_plThcknsAttr,
					&ret_struct,
					&(plate->mod_env) ),
                       senderid = NULL_OBJID,
	       	       targetid = plate->obj_id.objid,
	       	       targetos = plate->obj_id.osnum ) ;

	__CheckRC( i_sts, loc_sts, "NDmacro.ACgive_structure", quit );

	dev->epaisseur = fabs(ret_struct.var.root_pm_st.value) ;
		
	/*
	 * check the orientation of the surface. 
	 */

	i_sts = om$send( msg	= message EMSsubbs.EMget_props( 
								&stat,
								&props ),
                       senderid = NULL_OBJID,
	       	       targetid = dev->surf_id.obj_id.objid,
	       	       targetos = dev->surf_id.obj_id.osnum ) ;

	__CheckRC( i_sts, stat, "EMSsubbs.EMget_props", quit );
	#ifdef DEBUG
	printf("avant test nor dev->epaisseur = %f\n",dev->epaisseur);
	printf("dev->surf_id = %d,%d\n",dev->surf_id.obj_id.objid,
		dev->surf_id.obj_id.osnum); 
	#endif
	if( props & EMSIS_NRML_REVERSED ) dev->epaisseur = - dev->epaisseur;
	
	#ifdef DEBUG
	printf("dev->epaisseur = %f\n",dev->epaisseur);
	#endif

  }/* end of case if a plate or image plate has been located */


  else	if( om$is_ancestry_valid( superclassid = sfimp_cl,
			          subclassid   = GoTemp_cl ) == OM_S_SUCCESS ) {

		__DBGpr_com("EMSsfimpbnd");

		i_sts = om$send( msg	= message EMSsfimpbnd.EMget_subbs( 
						&stat,
						&dev->surf_id.obj_id.objid ),
                               senderid = NULL_OBJID,
	       	       	       targetid = plate->obj_id.objid,
	       	               targetos = plate->obj_id.osnum ) ;


		__CheckRC( i_sts, stat, "EMSsfimpbnd.EMget_subbs", quit );

		dev->surf_id.obj_id.osnum = plate->obj_id.osnum;
		dev->surf_id.mod_env = plate->mod_env;
  		#ifdef DEBUG
		printf("fisrt EMget_subbs i_sts = %d, stat= %d\n",i_sts,stat);
		printf("dev->surf_id 2 = %d, %d\n",dev->surf_id.obj_id.objid, 
			dev->surf_id.obj_id.osnum);
  		#endif


  	om$get_classid ( osnum     = dev->surf_id.obj_id.osnum,
		   	 objid     = dev->surf_id.obj_id.objid,
		   	 p_classid = &GoTemp_cl ) ;

  	om$get_classid ( classname = "EMSsfrembnd", p_classid = &sfrembnd_cl);

	if( (om$is_ancestry_valid( 
			superclassid = sfimp_cl,
			subclassid   = GoTemp_cl ) == OM_S_SUCCESS ) ||
	    (om$is_ancestry_valid( 
			superclassid = sfrembnd_cl,
			subclassid   = GoTemp_cl ) == OM_S_SUCCESS ) ) {

		plate->obj_id.objid = dev->surf_id.obj_id.objid;

		i_sts = om$send( msg	  = message EMSsfimpbnd.EMget_subbs( 
						&stat,
						&dev->surf_id.obj_id.objid ),
                                 senderid = NULL_OBJID,
       	       	       		 targetid = plate->obj_id.objid,
       	               		 targetos = plate->obj_id.osnum ) ;

  		#ifdef DEBUG
		printf("second EMget_subbs i_sts = %d, stat= %d\n",i_sts,stat);
		printf("dev->surf_id 2 = %d, %d\n",dev->surf_id.obj_id.objid, 
			dev->surf_id.obj_id.osnum);
  		#endif

		if( !( 1 & stat ) ) {
			printf("Error in srf_sub\n");
			printf( "Error in second EMSsfimpbnd.EMget_subbs\n" ) ;
			goto quit ;
		}

	}

        	
  }
  else {
	dev->surf_id = *plate;
	dev->epaisseur = 0.0;
  }

  msg = MSSUCC;
quit :
  _FREE( list_obj );
  return msg;
}

/*************** VLfindOrientation ************************/
/**
   Given a surface, this function finds three edges witch are, respectively,
   closest to the Middel, the Front and the Down direction.
   Also, it determinates if the surface is Starboard, Port or Middel.
									  **
****************************************************************************/
VLfindOrientation (surf,edgeC,edgeF,edgeD,surf_type)
struct GRobj_env	*surf;               /* I : The Surface */
struct GRid		*edgeC,*edgeF,*edgeD;/* O : edgeC :closest to the Middel
                                                    edgeF :closest to the Front
 						    edgeD :closest to the Down
					     */
int			*surf_type;          /* O : the surface is :
						    Middel    :    1
						    Starboard :    2
						    Port      :    3
                                             */
{
IGRlong		sts,loc_msg,msg;
IGRint		negative,count,i;
struct GRid	grEdge,*list=NULL;
IGRpoint	midpt,stpt,enpt;
double		miny,minz,maxx,fab;

/*
  edgeC->objid = NULL_OBJID;
  edgeF->objid = NULL_OBJID;
  edgeD->objid = NULL_OBJID;
*/
  
  msg = MSFAIL;
  *surf_type = VL_NOTHING;
  sts = vs$get_surface_edges( msg         = &loc_msg,
                              sfId        = &(surf->obj_id),
                              sfEnv       = &surf->mod_env,
                              edgeType    = VS_K_CONTOUR_EDGES,
                              edCount     = &count,
                              edList      = &list ) ;
  if (!(sts&loc_msg&1)) {
    printf("Problems at Getting Edges\n");
  }
  
  miny = OM_K_MAXINT; maxx = -OM_K_MAXINT;
  minz = OM_K_MAXINT; negative = -1; 
  for (i=0;i<count;i++)
  {
    sts = vs$get_graphic_edge( msg    = &loc_msg,
                               edId   = &list[i],
                               edEnv  = &surf->mod_env,
                               copy   = FALSE,
                               copyEnv   = NULL,
                               grEdge = &grEdge) ;
    if( !( sts & 1 & loc_msg) ) {
      printf( "~~~~~~~~~~ERROR in vs$get_graphic_edge\n" ) ;
      goto quit;
    }
    sts = om$send ( msg      = message GRcurve.GRmidpoint (
                                       &loc_msg,
                                       &surf->mod_env.md_env.matrix_type,
                                       surf->mod_env.md_env.matrix,
                                       NULL,
                                       midpt ),
                      senderid = NULL_OBJID,
                      targetid = grEdge.objid,
                      targetos = grEdge.osnum );
    if( !( sts & 1 & loc_msg) ) {
      printf( "~~~~~~~~~~ERROR in GRmidpoint\n" ) ;
      goto quit;
    }
    sts = om$send( msg = message GRcurve.GRendpts(
                                      &loc_msg,
                                      &surf->mod_env.md_env.matrix_type,
                                      surf->mod_env.md_env.matrix,
                                      stpt,enpt),
                          targetid = grEdge.objid,
                          targetos = grEdge.osnum,
                          senderid = NULL_OBJID);
    if( !( sts & 1 & loc_msg) ) {
      printf( "~~~~~~~~~~ERROR in GRendpts\n" ) ;
      goto quit;
    }

    if ( 
        (stpt[1]<=0 && enpt[1] <=0) ||
        (stpt[1]>=0 && enpt[1] >=0)
       ) {

       if (midpt[1]>0) negative =0;
       else negative =1;
       fab = fabs(midpt[1]);
       if (miny > fab) {
         miny = fab;
         *edgeC = list[i];       // find closest edge to the Middel
       }
    }
    else *surf_type = VL_MIDDEL;       // Middel

    if (maxx < midpt[0]) {
      maxx = midpt[0];
      *edgeF = list[i];        // find closest edge to the Front
    }
    
    if (minz > midpt[2]) {
      minz = midpt[2];
      *edgeD = list[i];        // find closest edge to the Down
    }

  }/* end loop on i */

  if (*surf_type == VL_NOTHING) {
    if (negative==1) *surf_type = VL_PORT;
    else if (negative==0) *surf_type = VL_STARBOARD;
  }
  
  msg = MSSUCC;
  quit :
    if (list)	 free(list);
    return msg;
}

/* ************************************************************************** */
/* Given two unwrapping edges, this function find how they are positionned
   in the unwrapping minimum rectangle. Then it find the orientation macro 
   names  to place the orientation symboles on the surface.                   */
/* ************************************************************************** */

VLget_mac_names(ln,orient,length,width,cs,ln_env,cur_env,symbo)
struct GRid 	*ln;               /* I : the two closest unwraped lines to
                                           two directions of the following
                                           three one : Middel, Front and Down.*/
       int	orient;            /* I : the surface is longitudinal, 
                                           transversal or horizontal */
       double 	length,width;	   /* I : minimum rectangle's length and width*/
struct GRid	*cs;               /* I : unwrap coordinate system*/
struct GRmd_env *ln_env,*cur_env;  /* I : lines and current environments.*/
char 	         *symbo;           /* O : the found macro name.*/
{
long		 stat,suc;
double 	 	 midpt[4],cs_pt[4];
int		 symb,symb1,sbl,sbl1;
double 		 min,min1, minim,minim1;
struct GRid 	 tmp,line[2];

  symb=sbl=0;
  if (ln[0].objid == NULL_OBJID) line[0] = ln[2]; //if surface cut shipaxis
  else line[0] = ln[0];
  line[1] = ln[1];

  stat = om$send ( msg      = message GRcurve.GRmidpoint (
                                     &suc,
                                     &(ln_env->md_env.matrix_type),
                                     ln_env->md_env.matrix,
                                     NULL,
                                     midpt ),
                      senderid = NULL_OBJID,
                      targetid = line[0].objid,
                      targetos = line[0].osnum );
  if (!(stat&1)) {

    /* get the Graphic Object */
    stat = vs$get_graphic_edge( msg    = &suc,
                                edId   = &line[0],
                                edEnv  = ln_env,
                                copy   = TRUE,
                                copyEnv= cur_env,
                                grEdge = &tmp);
                  if( !( stat & 1 & suc) ) {
#ifdef DEBUG1
printf("Problemes in get_mac_names in vs$get_graphic_edge\n");
fflush(stdout);
#endif
                    return 0;
                  }
     line[0] = tmp;
  }
  if (!(suc&1)) {
#ifdef DEBUG1
printf("Problemes in get_mac_names in GRmidpoint\n");
fflush(stdout);
#endif
    return 0;
  }
  midpt[3] = 1;
  if (!VLconvert_coord(midpt,cs_pt,cs)) return 0;
                               
    /* find to which two sides of the minimum rectangle line[0] is closest */

  min1 = OM_K_MAXINT; symb1 = -1;
  min = cs_pt[0]; symb = VL_LEFT;
  if (min > cs_pt[1]) {
    min1 = min;
    symb1 = symb;
    min = cs_pt[1];
    symb = VL_BOTTOM;
  }
  else {
    if (min1 > cs_pt[1]) {
      min1 = cs_pt[1];
      symb1 = VL_BOTTOM;
    }
  }
  if (min > length - cs_pt[0]) {
    min1 = min;
    symb1 = symb;
    min = length - cs_pt[0];
    symb = VL_RIGHT;
  }
  else {
    if (min1 > length - cs_pt[0]) {
    min1 = length - cs_pt[0];
    symb1 = VL_RIGHT;
    }
  }
  if (min > width - cs_pt[1]) {
    min1 = min;
    symb1 = symb;
    min = width - cs_pt[1];
    symb = VL_TOP;
  }
  else {
    if (min1 > width - cs_pt[1]) {
    min1 = width - cs_pt[1];
    symb1 = VL_TOP;
    }
  }
  
  stat = om$send ( msg      = message GRcurve.GRmidpoint (
                                     &suc,
                                     &(ln_env->md_env.matrix_type),
                                     ln_env->md_env.matrix,
                                     NULL,
                                     midpt ),
			senderid = NULL_OBJID,
                        targetid = line[1].objid,
                        targetos = line[1].osnum );
  if (!(stat&1)) {

    /* get the Graphic Object */
    stat = vs$get_graphic_edge( msg    = &suc,
                                edId   = &line[1],
                                edEnv  = ln_env,
                                copy   = TRUE,
                                copyEnv= cur_env,
                                grEdge = &tmp);
                  if( !( stat & 1 & suc) ) {
#ifdef DEBUG1
printf("Problemes in get_mac_names in vs$get_graphic_edge 2\n");
fflush(stdout);
#endif
                    return 0;
                  }
     line[1] = tmp;
  }
  if (!(suc&1)) {
#ifdef DEBUG1
printf("Problemes in get_mac_names in GRmidpoint 2\n");
fflush(stdout);
#endif
    return 0;
  }
  midpt[3] = 1;
  if (!VLconvert_coord(midpt,cs_pt,cs)) return 0;

    /* find to which two sides of the minimum rectangle line[1] is closest */

  minim1 = OM_K_MAXINT; sbl1 = -1;
  minim = cs_pt[0]; sbl = VL_LEFT;
  if (minim > cs_pt[1]) {
    minim1 = minim;
    sbl1 = sbl;
    minim = cs_pt[1];
    sbl = VL_BOTTOM;
  }
  else {
    if (minim1 > cs_pt[1]) {
      minim1 = cs_pt[1];
      sbl1 = VL_BOTTOM;
    }
  }
  if (minim > length - cs_pt[0]) {
    minim1 = minim;
    sbl1 = sbl;
    minim = length - cs_pt[0];
    sbl = VL_RIGHT;
  }
  else {
    if (minim1 > length - cs_pt[0]) {
    minim1 = length - cs_pt[0];
    sbl1 = VL_RIGHT;
    }
  }
  if (minim > width - cs_pt[1]) {
    minim1 = minim;
    sbl1 = sbl;
    minim = width - cs_pt[1];
    sbl = VL_TOP;
  }
  else {
    if (minim1 > width - cs_pt[1]) {
    minim1 = width - cs_pt[1];
    sbl1 = VL_TOP;
    }
  }

  switch (symb) {
    case VL_LEFT :
    case VL_RIGHT :
    if (sbl == VL_LEFT || sbl == VL_RIGHT) { /* if there is contradiction (two 
                                          arrows in the same or in opposite 
                                          direction).*/
      if ((min1 - min) < (minim1 -minim)) symb = symb1;
      else sbl = sbl1; 
    }
    break;
  case VL_BOTTOM :
  case VL_TOP :
    if (sbl == VL_BOTTOM || sbl == VL_TOP) {/* if there is contradiction (two 
                                         arrows in the same or in opposite 
                                         direction).*/
      if ((min1 - min) < (minim1 -minim)) symb = symb1;
      else sbl = sbl1; 
    }
    break;
  }

  switch(orient) {
  case VL_HORZ :
    if (ln[0].objid == NULL_OBJID)
      sprintf(symbo,"%s%d","symbF",sbl);
    else
      sprintf(symbo,"%s%d%d","symbCF",symb,sbl);
    break;
  case VL_TRANS :
    if (ln[0].objid == NULL_OBJID)
      sprintf(symbo,"%s%d","symbD",sbl);
    else
      sprintf(symbo,"%s%d%d","symbCD",symb,sbl);
    break;
  case VL_LONG :
    if( ( symb == VL_BOTTOM && sbl == VL_TOP    ) ||
        ( symb == VL_TOP    && sbl == VL_BOTTOM ) ||
        ( symb == VL_LEFT   && sbl == VL_RIGHT  ) ||
        ( symb == VL_RIGHT  && sbl == VL_LEFT   )    )
    {
        symb = VL_RIGHT; sbl = VL_TOP;
    }
    sprintf(symbo,"%s%d%d","symbFD",symb,sbl);
    break;
  }
#ifdef DEBUG1
  printf("ORIENT=%d\n",orient);
  printf("SYMBO=%s\n",symbo);
#endif

return 1;
}

/*==========================================================================*/
/*  Given a surface, this function place on it two macros for the unwrapping 
    orientation problem.
/*==========================================================================*/

IGRlong VLplace_symbols (
        struct GRobj_env	*surf,     /* I : Given Surface*/
               int		surf_type, /* I : surface type : Port, Starboard
						  or Middle.*/
        struct GRid		*cs,
        struct GRvg_construct   *cst,   /* I : construction list*/
               double           x1,   /* I : position of the macro1 on surface*/
               double           y1,   /* I : position of the macro1 on surface*/
               double           x2,   /* I : position of the macro2 on surface*/
               double           y2,   /* I : position of the macro2 on surface*/
        struct GRid		*line, /* I : used to find macro2 names.*/
        double			length,/* I : minimumrectangle length.*/
        double			width, /* I : minimumrectangle width.*/
        struct GRid             *type_symb, /* O : macro1*/
        struct GRid             *orient_symb /* O : macro2.*/
                        )
{
IGRlong		msg,sts,loc_msg;
char		type[2],symb_name[200];
struct GRid	TEMP[4],src_id;
int             j,i,orient,loc_sts;
struct GRid	cop_obj;
double		scale_mat[16];
short		scale_mattype;
double		wld[4],trans_mat[16],vect[4];
short		trans_mattype;
double          scale;

  msg = MSFAIL;

   /* the symbols we will ACmplace in this function were made with a 
      constant size computed to fit well in files using the metric units.
      for the imperial units we must scale the obtained symbol */

   /* find which measure system do we use */
   scale = 1.;
   sts =co$unit_database_type( osnum=cst->env_info->md_id.osnum,
                               db_type = &i );
   if (!(sts&1)) scale = 1.;
   else {
     if (i == GRIO_UNITS_ARE_ENGLISH) scale = 25.4/(double)VL_ARROW_SIZE;
   }

   if (scale != 1) {
     for (i=1;i<16;i=i+1) scale_mat[i] = 0;
     scale_mat[0] = scale; scale_mat[5] = scale;
     scale_mat[10] =scale; scale_mat[15] = 1;
     MAtypemx( &sts, scale_mat, &scale_mattype);
  
       /* get cs matrix */
     sts = om$send(  msg = message GRgencs.GRgetmatrix( &loc_msg, trans_mat ),
                                targetid = cs->objid,
                                targetos = cs->osnum,
                                senderid = NULL_OBJID);
     if (!(sts&loc_msg&1)) {
       msg = MSSUCC;
       goto quit;
     }
    vect[0] = x2; vect[1] = y2; vect[2] = 0; vect[3] = 1;
    i=4; j=1;
    MAmulmx( &loc_msg, &i, &i, &j, trans_mat, vect, wld );
  
    for (i=1;i<16;i=i+1) trans_mat[i] = 0;
    trans_mat[0] = 1; trans_mat[5] = 1;
    trans_mat[10] =1; trans_mat[15] = 1;
    trans_mat[3] = wld[0] - wld[0]*scale;
    trans_mat[7] = wld[1] - wld[1]*scale;
    trans_mat[11] = wld[2] - wld[2]*scale;
    MAtypemx( &sts, trans_mat, &trans_mattype); 
  }

    /* place Type macro */
      if (surf_type == VL_MIDDEL) type[0] = 'M';
      else {
        if (surf_type == VL_PORT) type[0] = 'S';
        else type[0] = 'P';
      }
      type[1] = '\0';

      TEMP[0] = *cs;
      TEMP[1].osnum = cst->env_info->md_id.osnum;
      TEMP[1].objid = NULL_OBJID;
      exp$create(exp_name = NULL,
                 exp_value = (IGRdouble) x1,
                 p_exp_id = &TEMP[1].objid,
                 osnum = cst->env_info->md_id.osnum);
      TEMP[2].osnum = cst->env_info->md_id.osnum;
      TEMP[2].objid = NULL_OBJID;
      exp$create(exp_name = NULL,
                 exp_value = (IGRdouble) y1,
                 p_exp_id = &TEMP[2].objid,
                 osnum = cst->env_info->md_id.osnum);

      src_id.osnum = cst->env_info->md_id.osnum;
      src_id.objid = NULL_OBJID;
      sts = om$construct( classid = OPP_ACheader_class_id,
                          osnum     = src_id.osnum,
                          p_objid   = &src_id.objid);
      sts = om$send(  msg  = message ACncpx.ACmplace(
                                          &loc_sts,
                                          AChdr_nodisplay, 0,
                                          type,
                                          3,
                                          TEMP,
                                          cst->env_info),
                          senderid = NULL_OBJID,
                          targetid = src_id.objid,
                          targetos = src_id.osnum );
      if (!(sts & loc_sts & 1)) {
#ifdef DEBUG1
  printf("Pbs in ACncpx.ACmplace\n");
  fflush(stdout);
#endif
        goto quit;
      }
      type_symb->osnum = cst->env_info->md_id.osnum;
      type_symb->objid = NULL_OBJID;
      sts = om$send(  msg  = message NDnode.NDmove_to_root (&loc_msg,
                                                            type_symb,
                                                            cst->env_info ),
                          senderid = NULL_OBJID,
                          targetid = src_id.objid,
                          targetos = src_id.osnum );
      if (!(sts & loc_msg & 1)) {
#ifdef DEBUG1
  printf("Pbs in NDnode.NDmove_to_root\n");
  fflush(stdout);
#endif
       goto quit;
      }

     sts = VLlongHorzOrTrans(surf,&orient);
     if (!(sts&1)) {
       goto quit;
    }
    sts = VLget_mac_names(line,orient,length, width,cs, cst->env_info,
                          cst->env_info,symb_name);
    if (!(sts&1)) {
      goto quit;
    }

    TEMP[1].osnum = cst->env_info->md_id.osnum;
    TEMP[1].objid = NULL_OBJID;
    exp$create(exp_name = NULL,
               exp_value = (IGRdouble) x2,
               p_exp_id = &TEMP[1].objid,
               osnum = cst->env_info->md_id.osnum);
    TEMP[2].osnum = cst->env_info->md_id.osnum;
    TEMP[2].objid = NULL_OBJID;
    exp$create(exp_name = NULL,
               exp_value = (IGRdouble) y2,
               p_exp_id = &TEMP[2].objid,
               osnum = cst->env_info->md_id.osnum);
    src_id.osnum = cst->env_info->md_id.osnum;
    src_id.objid = NULL_OBJID;
    sts = om$construct( classid = OPP_ACheader_class_id,
                         p_objid = &(src_id.objid),
                         osnum = src_id.osnum);
    sts = om$send(  msg  = message ACncpx.ACmplace(
                                        &loc_sts,
                                        AChdr_nodisplay, 0,
                                        symb_name,
                                        3,
                                        TEMP,
                                        cst->env_info),
                        senderid = NULL_OBJID,
                        targetid = src_id.objid,
                        targetos = src_id.osnum );
    if (!(sts & loc_sts & 1)) {
#ifdef DEBUG1
  printf("Pbs in ACncpx.ACmplace 2\n");
  fflush(stdout);
#endif
      goto quit;
    }

    orient_symb->objid = NULL_OBJID;
    orient_symb->osnum = cst->env_info->md_id.osnum;

    sts = om$send(  msg  = message NDnode.NDmove_to_root (&loc_msg,
					      orient_symb,
					      cst->env_info ),
                        senderid = NULL_OBJID,
                        targetid = src_id.objid,
                        targetos = src_id.osnum );
     if(!(sts & loc_msg & 1)) {
#ifdef DEBUG1
  printf("Pbs in NDnode.NDmove_to_root 2\n");
  fflush(stdout);
#endif
        goto quit;
     }

  if (scale != 1) {
    sts =  om$send ( msg      = message GRgraphics.GRxform (
                                   &loc_msg,
                                   cst->env_info,
                                   &scale_mattype,
                                   scale_mat,
                                   &cop_obj.objid ),
                         senderid = NULL_OBJID,
                         targetid =orient_symb->objid,
                         targetos = orient_symb->osnum );
    if (!(sts&loc_msg&1)) {
      msg=MSSUCC;
      goto quit;
    }

    sts =  om$send ( msg      = message GRgraphics.GRxform (
                                   &loc_msg,
                                   cst->env_info,
                                   &trans_mattype,
                                   trans_mat,
                                   &cop_obj.objid ),
                         senderid = NULL_OBJID,
                         targetid = orient_symb->objid,
                         targetos = orient_symb->osnum );
    if (!(sts&loc_msg&1)) {
      msg = MSSUCC;
      goto quit;
    }

    sts =  om$send ( msg      = message GRgraphics.GRxform (
                                   &loc_msg,
                                   cst->env_info,
                                   &scale_mattype,
                                   scale_mat,
                                   &cop_obj.objid ),
                         senderid = NULL_OBJID,
                         targetid =type_symb->objid,
                         targetos = type_symb->osnum );
    if (!(sts&loc_msg&1)) {
      msg=MSSUCC;
      goto quit;
    }

    sts =  om$send ( msg      = message GRgraphics.GRxform (
                                   &loc_msg,
                                   cst->env_info,
                                   &trans_mattype,
                                   trans_mat,
                                   &cop_obj.objid ),
                         senderid = NULL_OBJID,
                         targetid = type_symb->objid,
                         targetos = type_symb->osnum );
    if (!(sts&loc_msg&1)) {
      msg = MSSUCC;
      goto quit;
    }
  }


  msg = MSSUCC;
quit :
  return msg;
}

end implementation VLabstract;
