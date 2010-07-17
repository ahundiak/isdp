/* $Id: VLunwObji.I,v 1.4 2001/06/20 22:58:02 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwObji.I
 *
 * Description: Unwrap Object Compute Engine.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwObji.I,v $
 *      Revision 1.4  2001/06/20 22:58:02  ramarao
 *      Fixed a crash problem.
 *
 *      Revision 1.3  2001/02/20 01:07:33  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:20  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/06/23  23:05:02  pinnacle
# Replaced: loft/src/unwext/VLunwObji.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/06/23  21:13:14  pinnacle
# Replaced: loft/src/unwext/VLunwObji.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/05/17  19:48:18  pinnacle
# Created: loft/src/unwext/VLunwObji.I by rchennup for Service Pack
#
# Revision 1.7  2000/03/14  23:04:02  pinnacle
# (No comment)
#
# Revision 1.5  2000/03/10  19:29:22  pinnacle
# (No comment)
#
# Revision 1.4  2000/03/08  20:40:22  pinnacle
# (No comment)
#
# Revision 1.3  1999/12/30  19:00:20  pinnacle
# (No comment)
#
# Revision 1.2  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.6  1998/04/27  15:44:12  pinnacle
# ah
#
# Revision 1.5  1998/04/25  21:39:04  pinnacle
# Replaced: src/unwext/VLunwObji.I for:  by impd for loft
#
# Revision 1.4  1998/04/23  08:37:36  pinnacle
# Replaced: src/unwext/VLunwObji.I for:  by rchennup for loft
#
# Revision 1.3  1998/03/27  14:42:04  pinnacle
# Replaced: src/unwext/VLunwObji.I for:  by smpathak for loft
#
# Revision 1.2  1997/10/31  19:29:40  pinnacle
# Replaced: src/unwext/VLunwObji.I for:  by rchennup for loft
#
 *
 * History:
 * MM/DD/YY   AUTHOR    DESCRIPTION
 * 10/28/97   Rama Rao  File Creation
 * 04/26/98   Adz	ACconstruct_feet check for gmCount == 0
 * 04/27/98   ah        Last minute change by Rama Rao, delete
 *                        object if construction fails
 * 04/09/99   ah        Rama Rao SP08 Fixes
 * 03/08/00   RR	Called VDSetParserModelOE() in ACconstruct_feet();
 *************************************************************************/

class implementation VLunwObj;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "asbox.h"
#include "bserr.h"
#include "nddef.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "drawparam.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "acmacros.h"
#include "vddrwattr.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_pplslc.h"
#include "vsplatedef.h"
#include "vlunfold.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlunwext.h"
#include "vldbgmacros.h"

#define vdsDEBUG     1
#define vdsDEBUG     1

from    EMSgenbs	import  GRconstruct;
from    ACrg_collect	import	ACget_named_attribute;

extern	GRclassid	OPP_EMSgenbs_class_id, OPP_GRcompcurve_class_id,
			OPP_GRtext_class_id,
			OPP_VDdrwGm_class_id, OPP_GR3dpoint_class_id   ;

extern  IGRchar         *memcpy();

/*----------------------------------------------------------------------------*/

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	SetProc( VLunwObj_VDgetObjDef ); Begin

	*msg	= MSSUCC ;

	myDef->info		= VL_I_ObjUnw ;
//	myDef->type		= VL_O_unwObj ;

	sts	= OM_S_SUCCESS ;

	End ;
	return sts ;

} /* VDgetObjDef */

method	ACconstruct_feet(	IGRlong		*msg;
				IGRint		cn_type; 
				IGRint		count;
				struct GRid	list[];
				struct GRmd_env *md_env;
				IGRint		*fcount;
				struct GRid	*feet_list )
{
	/*
	 * Root list:
	 *	- Options  ACrg collection
	 * 	- Plate object
	 *	- List Of Edge Attribute Objects on the Plate
	 */

	IGRlong			sts1, msg1;	
	IGRshort  		action, props, trfMatType;
	IGRint			i, sts = OM_S_SUCCESS, gm, four=4, NumOldCrvs,
				gmCount=0, gmMax, index, modLevel[32],
				va_count=0;
	IGRboolean		UnwrapSrfWanted=FALSE;
	IGRdouble		fromMat[16], orgToMat[16], toMat[16], ORG[3],
				drwPnt[3], drwVec[3], trfMat[16], invMat[16];
	struct GRid		*gmList=NULL, myGRid, gmId, gmFeetId, 
				plateId, gmMacDef;
	struct GRobj_env	myObjEnv, plateOE, min_rec, OldCrv;
	struct  IGRpolyline     geom;
	struct IGRplane		drawingPlane, viewPlane ;
	IGRvector		viewVector ;
	IGRpoint		viewPoint ;
	struct	IGRlbsys	ctxLbs;
	struct  ACrg_coll     	attrib;
	struct GRvg_construct   cst;
	enum GRdpmode           mode = GRbd;
	GRobjid			dummy;
	GRname			unwObj_nm, fl_name, st_name, gmMacro;
        VDpartAttr              attr ;
        VDdrw2dVwInfo           vwInfo ;
	VD_drwOutputData	*output = NULL ;
	IGRchar			gmFeetName[10];

	SetProc( VLunwObj_ACconstruct_feet ); Begin

	*msg = MSSUCC ;

	myGRid.objid = my_id;
	myGRid.osnum = OM_Gw_current_OS;

	sts = _VD_SEND_OBJN( myGRid, NDnode.NDget_objects( ND_ROOT,
			     &plateId, 1, NULL, 1, 1, &count ));
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
	__DBGpr_obj( " Parent Plate ", plateId );

        sts = _VD_SEND_OBJN( plateId, NDmacro.ACreturn_foot(
                                        msg, "", &plateOE.obj_id,
                                        &plateOE._matrix_type,
                                        plateOE._matrix           ) );
        __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );
        __DBGpr_obj( " Original Plate in model ", plateOE.obj_id );
        plateOE._md_os = plateOE._osnum;
        ex$get_modid(   mod_osnum = plateOE._md_os,
                        mod_id    = &plateOE._md_id ) ;

	VDSetParserModelOE(&plateOE);

	gmId.objid = NULL_OBJID ;
	gmId.osnum = OM_Gw_current_OS;

	VLinitCnst( &cst );

	VLunw_InitObjInfo( msg, &vwInfo );

	vwInfo.intName	= unwObj_nm ;
	vwInfo.prjVec	= drwVec ;
	vwInfo.prjPnt	= drwPnt ;
	vwInfo.objLev	= modLevel ;
	vwInfo.drwLbsys	= &ctxLbs ;

	attr.Iwant = VD_I_drwProjAllInfo ;
	attr.specific = (void *) &vwInfo ;
	sts = _VD_SEND_MY( GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	/* Get the visualization support file */
	attr.Iwant = VD_I_drwVisual ;
	sts = _VD_SEND_MY( GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );
	strcpy( fl_name, attr.aString );

	drawingPlane.point  = drwPnt ;
	drawingPlane.normal = drwVec ;
		
	viewPlane.point		= (double *) VD_mxorigin( ctxLbs.matrix, viewPoint );
	viewPlane.normal	= drwVec ;

	VD_vccpy( viewVector, drwVec ) ;

	if( strlen( unwObj_nm ))	strcpy( st_name, unwObj_nm ) ;

   	sts = VLunwext_LoadKeyWords();
	if ( !(1 & sts)) {
	   goto wrapup;
	}

	sts =
	vd_$drwExecConfig(	msg		= msg,
				elmId		= &myGRid,
				elmEnv		= md_env,
				drwPlane	= &drawingPlane,
				viewPlane	= &viewPlane,
				viewVector	= viewVector,
				drwEnv		= md_env,
				drwLbsys	= &ctxLbs,
				selCount	= 1,
				selList		= &myGRid,
				filename	= fl_name,
				set_name	= st_name,
				elm_type	= "unwrap",
				output		= &output ) ;
	if( !(sts & 1 & *msg )){
		int			n	= 0 ;
		VD_drwOutputData	*p	= output ;
		while( p ) { n += p->set.count ; p = p->next ; }

		if( n ) {
			sts  = OM_S_SUCCESS ;
			*msg = MSSUCC ;
		}
                else
                {
                        VD_drwFreeOutputData( &output ) ;
                        sts  = OM_E_ABORT ;
                        goto wrapup;
                }

	}

	if( sts & 1 & *msg ) {
		int			n	= 0 ;
		VD_drwOutputData	*p	= output ;
		while( p ) { n += p->set.count ; p = p->next ; }

		if( n ) {
			gmList = _MALLOC( n, struct GRid ) ;
			if( gmList ) {
				n = 0 ;
				p = output ;
				while( p ) {
					int i ;
					int max = p->set.count ;
					struct GRid *l = p->set.list ;
					for( i = 0 ; i < max ; i++ ) {
						gmList[n++] = l[i] ;
					}
					p = p->next ;
				}
				gmCount = n ;
			}
		}
	}

	VD_drwFreeOutputData( &output ) ;

	if( ! gmCount ){
		__DBGpr_com(" No Output Found after Parsing ");
		sts = MSFAIL ;
		goto wrapup ;
	}

        vd$ppl_getarg_at_index(  which_info = GLOBAL_INFO,
                                 index      = 3,
                                 value      = &min_rec   );

        output = NULL;
        sts = VLunwext_LoadKeyWords();
        if ( !(1 & sts)) {
           goto wrapup;
        }

        sts =
        vd_$drwExecConfig(
                          msg             = msg,
                          elmId           = &min_rec.obj_id,
                          elmEnv          = md_env,
                          drwPlane        = &drawingPlane,
                          viewPlane       = &viewPlane,
                          viewVector      = viewVector,
                          drwEnv          = md_env,
                          drwLbsys        = &ctxLbs,
                          selCount        = 1,
                          selList         = &min_rec.obj_id,
                          filename        = fl_name,
                          elm_type        = "min-rec",
                          appData         = (void *) &me->dev,
                          output          = &output ) ;

        if( !(sts & 1 & *msg )){
                int                     n       = 0 ;
                VD_drwOutputData        *p      = output ;
                while( p ) { n += p->set.count ; p = p->next ; }

                if( n ) {
                        sts = OM_S_SUCCESS ;
                        *msg = MSSUCC ;
                }
        }

        if( sts & 1 & *msg ) {
                int                     n       = 0 ;
                VD_drwOutputData        *p      = output ;
                while( p ) { n += p->set.count ; p = p->next ; }

                if( n ) {
		   if( !( gmList =
			_REALLOC( gmList, gmCount+n, struct GRid )) )
                     vd_$mem_fail();

                   n = 0 ;
                   p = output ;
                   while( p ) {
                        int i ;
                        int max = p->set.count ;
                        struct GRid *l = p->set.list ;
                        for( i = 0 ; i < max ; i++ ) {
                                gmList[gmCount+n] = l[i] ;
                                ++n;
                        }
                        p = p->next ;
                   }
                   gmCount += n ;
                }
        }
        VD_drwFreeOutputData( &output ) ;

        vd$ppl_getarg_at_index(  which_info = GLOBAL_INFO,
                                 index      = 4,
                                 value      = &NumOldCrvs   );

	if( NumOldCrvs )
	{
         for( i=0; i<NumOldCrvs; ++i )
         {
           output = NULL;
           sts = VLunwext_LoadKeyWords();
           if ( !(1 & sts)) {
                goto wrapup;
           }

           vd$ppl_getarg_at_index(  which_info = GLOBAL_INFO,
                                    index      = 5+i,
                                    value      = &OldCrv   );

           sts =
           vd_$drwExecConfig(
                          msg             = msg,
                          elmId           = &OldCrv.obj_id,
                          elmEnv          = md_env,
                          drwPlane        = &drawingPlane,
                          viewPlane       = &viewPlane,
                          viewVector      = viewVector,
                          drwEnv          = md_env,
                          drwLbsys        = &ctxLbs,
                          selCount        = 1,
                          selList         = &OldCrv.obj_id,
                          filename        = fl_name,
                          elm_type        = "stock-line",
                          appData         = (void *) &me->dev,
                          output          = &output ) ;

           if( !(sts & 1 & *msg )){
                int                     n       = 0 ;
                VD_drwOutputData        *p      = output ;
                while( p ) { n += p->set.count ; p = p->next ; }

                if( n ) {
                        sts = OM_S_SUCCESS ;
                        *msg = MSSUCC ;
                        continue;
                }
           }

           if( sts & 1 & *msg ) {
                int                     n       = 0 ;
                VD_drwOutputData        *p      = output ;
                while( p ) { n += p->set.count ; p = p->next ; }

                if( n ) {
		   if( !( gmList =
			_REALLOC( gmList, gmCount+n, struct GRid )) )
                     vd_$mem_fail();

                   n = 0 ;
                   p = output ;
                    while( p ) {
                        int i ;
                        int max = p->set.count ;
                        struct GRid *l = p->set.list ;
                        for( i = 0 ; i < max ; i++ ) {
                                gmList[gmCount+n] = l[i] ;
                                ++n;
                        }
                        p = p->next ;
                   }
                   gmCount += n ;
                }
           }
           VD_drwFreeOutputData( &output ) ;
         }

	}

	/*
	 * Check the number of components of the return graphics
	 */
	gmMax = 0 ;
	for( i=0 ; i<gmCount ; i++ ){

	   if(	vd_$is_ancestry_valid(
			object	= gmList +i,
			classid = OPP_GRowner_class_id )){

		IGRint	count = 0 ;

		sts =
		_VD_SEND_OBJ(	gmList[i],
				GRowner.GRget_number_components(msg, &count));
		gmMax = (sts&*msg&1) ? (gmMax + count) : (gmMax + 5);
	   }
	   else{
		gmMax ++;
	   }
	}

	__DBGpr_int(" gmCount" , gmCount );
	__DBGpr_int(" gmMax  " , gmMax   );

	sts =
	VD_drwGeomGiveMacroBySize( msg, gmMax, gmMacro );
	__CheckRC( sts, *msg, "VD_drwGeomGiveMacroBySize", wrapup );

	__DBGpr_str(" Macro Name ", gmMacro );

	/*
	 * find the macro definition for the first occurence.
	 */
	gmMacDef.objid = NULL_OBJID ;
	sts =
	ac$find_macro_defn(	action           = ACfind_load,
				macro_name       = gmMacro,
				p_macro_defn_id  = &gmMacDef );

	if( ! ( sts&1 ) || gmMacDef.objid == NULL_OBJID ){
		return OM_S_SUCCESS ;
	}

	/*
	 * load the macro definition.
	 */
	gmId.osnum = md_env->md_id.osnum;
	sts =
	om$construct(	classid	= OPP_VDdrwGm_class_id,
			osnum   = gmId.osnum,
			p_objid = &gmId.objid,
			msg	= message ACcpx.ACload_macro(gmMacDef));
	__CheckRC( sts, 1, "Construct VDdrwGm and Load Geom macro", wrapup );

	sts =
	_VD_SEND_OBJ(	gmId,
			NDnode.NDmove_to_root(msg, &gmId, md_env));
	__CheckRC( sts, *msg, "NDnode.NDmove_to_root", wrapup );

	for( gm=0 ; gm<gmCount ; gm++ ){
	     IGRlong  tmp_ind = OM_K_MAXINT;
             sts = _VD_SEND_OBJN(  gmList[gm], GRconnector.GRrigidconn( 
					msg, &gmId, &tmp_ind ) );
	     __CheckRC( sts, *msg, "GRconnector.GRrigidconn", wrapup );
	}
	/*
	 * Now change GRcompcurve to AScompcurve to support indexing
	 */
	if( gmCount ){

	    struct GRid	Comp ;
	    for( index = 0 ; index < OM_K_MAXINT ; index++ ){

		sts =
		om$get_objid_at_index(	objid		= gmId.objid,
					osnum		= gmId.osnum,
					p_chanselect	= &AS_to_comp,
					index		= index,
					osnumaddr	= &Comp.osnum,
					objidaddr	= &Comp.objid );
		if( !(sts&1)) break;
		__DBGpr_obj("gm ", Comp ); 

		if( ! (vd_$is_ancestry_valid(
				object	= &Comp,
				classid = OPP_GRcompcurve_class_id )))
			continue ;

		om$change_class(	osnum     = Comp.osnum,
					objid     = Comp.objid,
					classname = "AScompcurve" ) ;

		sts =
		_VD_SEND_OBJ(	Comp,
				NDnode.NDmove_to_root(	msg, &Comp, md_env ));
		__CheckRC( sts, *msg, "NDnode.NDmove_to_root", wrapup );

	    } /* indexes in one geom type */

	} /* for all geom objects */

	/*
	 * Second check on the output
	 */
	if( ! gmCount ){
		__DBGpr_com(" No Output Found after Parsing ");
		sts = MSFAIL ;
		goto wrapup ;
	}

	sts =
	_VD_SEND_OBJ(	gmId,
			NDnode.NDmove_to_root( msg, &gmId,md_env));
	__CheckRC( sts, *msg, "NDnode.NDmove_to_root", wrapup );

	/*
	 * connect the components with geometry and
	 * create the drawing part
	 */
	*fcount = 3 ;
	feet_list[0] = gmId;

    	attr.Iwant = VL_I_fromMat ;
    	attr.specific = (void *) fromMat ;
    	sts = _VD_SEND_MY( GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

    	attr.Iwant = VL_I_toMat ;
    	attr.specific = (void *) orgToMat ;
    	sts = _VD_SEND_MY( GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	i = 0;

	do
	{
	  sprintf( gmFeetName, "$%d",i );

          sts = _VD_SEND_OBJN( gmId,
                               NDmacro.ACreturn_foot(
                                         msg,
                                         gmFeetName,
                                         &gmFeetId,
                                         &md_env->md_env.matrix_type,
                                         md_env->md_env.matrix ));
	  if( !( 1 & sts & (*msg ) )) break;

   	  if(	!vd_$is_ancestry_valid(
			object	= &gmFeetId,
			classid = OPP_GRtext_class_id )){
    		sts = VLapplyTransf( &gmFeetId, 1, md_env, fromMat, orgToMat,
                            trfMat, &trfMatType, msg );
		__CheckRC( sts, *msg, "VLapplyTransf", wrapup );
	  }
	  i = i+1;

 	} while(1);

	strcpy( attrib.name, UNFOLD_ATT_SRFWANTED );
        attrib.desc.type = AC_ATTRIB_DOUBLE;

	sts = _VD_SEND_OBJN( list[0], ACrg_collect.ACget_named_attribute(
							msg, &attrib ) );
        __CheckRC( sts, *msg, "ACrg_collect.ACget_named_attribute", wrapup );

        UnwrapSrfWanted = attrib.desc.value.att_exp;

        cst.geometry = (IGRchar *) me->dev.devsrf;
        feet_list[1].osnum = md_env->md_id.osnum;
        sts = om$construct( classid = OPP_EMSgenbs_class_id,
                               osnum   = feet_list[1].osnum,
                               p_objid = &feet_list[1].objid,
			       msg     = message GRgraphics.GRconstruct(
						&cst) );
        __CheckRC( sts, *cst.msg, "EMSgenbs.GRconstruct", wrapup );
	cst.geometry = NULL;

	if( UnwrapSrfWanted == FALSE )
	{
           props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
           action = 0;
           sts = om$send ( msg = message GRgraphics.GRchgprops(
                                                msg,
                                                &action,
                                                &props ),
                           targetid = feet_list[1].objid,
                           targetos = feet_list[1].osnum );
           __CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup );
	}

   	sts = VLapplyTransf( &feet_list[1], 1, md_env, fromMat, orgToMat,
                            trfMat, &trfMatType, msg );
	__CheckRC( sts, *msg, "VLapplyTransf", wrapup );

  	if (!me->dev.tesselation_option) {
           geom.num_points = 1;
           ORG[2] = ORG[1] = ORG[0] = 0;
           geom.points = &ORG[0];
	   cst.properties  &=  ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);
           cst.geometry = (char *)&geom;
           feet_list[2].osnum = md_env->md_id.osnum;
           sts = om$construct( classid = OPP_GR3dpoint_class_id,
                               osnum   = feet_list[2].osnum,
                               p_objid = &feet_list[2].objid );
	   __CheckRC( sts, 1, "om$construct:GR3dpoint_class", wrapup );

           sts = om$send(msg      = message GRgraphics.GRaltconstruct(&cst),
                       senderid = NULL_OBJID,
                       targetid = feet_list[2].objid,
                       targetos = feet_list[2].osnum );
           __CheckRC( sts, *cst.msg, "GR3dpoint.GRaltconstruct", wrapup );
  	}
  	else feet_list[2] = me->dev.uvSrfId;
	cst.geometry = NULL;

	myObjEnv.obj_id  = myGRid;
	myObjEnv.mod_env = *md_env;

        sts = _VD_SEND_OBJ( gmId, GRgraphics.GRdisplay( msg,
                        &md_env->md_env.matrix_type, md_env->md_env.matrix,
                        &mode, &md_env->md_id ) );
        __CheckRC( sts, *msg, "GRgraphics.GRdisplay", wrapup ) ;

        sts = VLprocessFeats( msg, myObjEnv );
        __CheckRC( sts, *msg, "VLprocessFeats", wrapup );

	mode = GRbe;
        sts = _VD_SEND_OBJ( gmId, GRgraphics.GRdisplay( msg,
                        &md_env->md_env.matrix_type, md_env->md_env.matrix,
                        &mode, &md_env->md_id ) );
        __CheckRC( sts, *msg, "GRgraphics.GRdisplay", wrapup ) ;

    	attr.Iwant = VL_I_toMat ;
    	attr.specific = (void *) toMat ;
    	sts = _VD_SEND_MY( GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

    	attr.Iwant = VL_I_toMat ;
    	attr.specific = (void *) orgToMat ;
    	sts = _VD_SEND_MY( GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	for( i=0; i<16; ++i )
	  if( orgToMat[i] != toMat[i] )  break;

	if(  i==16 )
	{
	   *msg = MSSUCC;
	   sts  = OM_S_SUCCESS ;
	   goto wrapup;
	}
        MAinvmx( msg, &four, orgToMat, invMat );
        MAmulmx( msg, &four, &four, &four, toMat, invMat, trfMat );
        MAtypemx( msg, trfMat, &trfMatType);

        dummy = NULL_OBJID ;

        sts = om$send(  msg     = message GRgraphics.GRxform(
                                                      msg,
                                                      md_env,
                                                      &trfMatType,
                                                      trfMat,
                                                      &dummy ),
                     senderid = NULL_OBJID,
                     targetid = feet_list[0].objid,
                     targetos = feet_list[0].osnum  );
        __CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup );
	feet_list[0].objid = dummy;

        dummy = NULL_OBJID ;
        sts = om$send(  msg     = message GRgraphics.GRxform(
                                                      msg,
                                                      md_env,
                                                      &trfMatType,
                                                      trfMat,
                                                      &dummy ),
                     senderid = NULL_OBJID,
                     targetid = feet_list[1].objid,
                     targetos = feet_list[1].osnum  );
        __CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup );
	feet_list[1].objid = dummy;

	mode = GRbd;
        sts = _VD_SEND_OBJ( feet_list[0], GRgraphics.GRdisplay( msg,
                        &md_env->md_env.matrix_type, md_env->md_env.matrix,
                        &mode, &md_env->md_id ) );
        __CheckRC( sts, *msg, "GRgraphics.GRdisplay", wrapup ) ;

	*msg = MSSUCC;
	sts  = OM_S_SUCCESS ;

	wrapup:
	   if( !(sts&(*msg)&1) )
	   {	
            	sts1 = _VD_SEND_OBJN( feet_list[1], 
					GRgraphics.GRdelete( &msg1, md_env ));
           }

	   sts1 = VLunwPlateHasVABevel( &msg1, &plateOE, &va_count, NULL,
				FALSE, NULL, NULL );
	   if( (sts1&1) && va_count )
           {
		IGRint	chan_count=0;

		sts1 = om$get_channel_count ( osnum = me->dev.surf_id._osnum,
					      objid = me->dev.surf_id._objid,
					      p_chanselect = &AS_to_owner,
					      count = (OMuint *)&chan_count );
		if( !(sts1&1) || !chan_count )
		{
		    sts1 = _VD_SEND_OBJN( me->dev.surf_id.obj_id,
				GRgraphics.GRdelete( &msg1, md_env ));
		}
           }
	   vd$ppl_free_args( which_info = GLOBAL_INFO );

	   VLunwRedFeats( &msg1, myGRid );

           BSfreesf( &sts1, me->dev.devsrf );
           BSfreesf( &sts1, me->dev.surface );
           _FREE( me->dev.devsrf );
           _FREE( me->dev.surface );
	   _FREE( me->dev.P );
	   _FREE( me->dev.def );
	   _FREE( me->dev.Param_u );
	   _FREE( me->dev.Param_v );
	   _FREE( gmList );
	   End ;
	   return sts;
}

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	NDupdate from NDnode

  Description:
 
      This file implements the NDupdate for the object after modification.
 
  Dependencies:
	VDdrw2dVw

  History:
 
  -------------------------------------------------------------------------
 */


method	NDupdate(		IGRint		*msg;
				IGRint		cn_type; 
				IGRint		count;
				struct GRid	*parents;
				IGRint		*parent_state ;
				struct GRid	*context ;
				struct GRid	*new_objid ;
				struct GRmd_env	*md_env )
{
	IGRlong		loc_msg, sts = OM_S_SUCCESS;
 	OM_S_CHANSELECT to_feat;
	enum GRdpmode   mode=GRbe;
	
	SetProc( VLunwObj_NDupdate ); Begin

	*msg = MSSUCC ;

	sts =
	_VD_SEND_WRT_M( my_id, ACncpx.NDupdate(	msg,
						cn_type,
						count,
						parents,
						parent_state,
						context,
						new_objid,
						md_env ));
	__CheckRC( sts, *msg, "ACncpx.NDupdate", wrapup ) ;

        /*
         * Find the channel name.
         */
        to_feat.type       = OM_e_name;
        to_feat.u_sel.name = "VLunwObj.to_feat";

        sts =
        _VD_SEND_CHAN(  to_feat, GRgraphics.GRdisplay( &loc_msg,
			&md_env->md_env.matrix_type, md_env->md_env.matrix,
			&mode, &md_env->md_id ) );
        __CheckRC( sts, *msg, "GRgraphics.GRdisplay", wrapup ) ;

	sts = _VD_SEND_MY( VLunwObj.VDcompute( &loc_msg, &cn_type ));
	__CheckRC( sts, loc_msg, "VLunwObj.VDcompute", wrapup );

	wrapup :
		End ;
		return sts ;
}


/*+mo
 -------------------------------------------------------------------------
  Public Message 
	VDcompute from VDSroot

  Description:
 
      This file implements the VDcompute call for all VLunwFeat objects.
 
  Dependencies:

  History:
 
  -------------------------------------------------------------------------
 */

method	VDcompute(	long		*msg;
			int		*type )
{
	/*
	 * find the list of all the VLunwFeat objects which are
	 * connect to this VLunwObj object.
	 */
	IGRint			sts = OM_S_SUCCESS ,
				count,
				sizBuf,
				sizRet ;
	struct	GRid		myGRid,
				*grids = NULL ;
	struct	GRmd_env	locEnv ;

	SetProc( VLunwObj_VDcompute ); Begin

	*msg	= MSSUCC ;

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	sizBuf = sizeof( locEnv );
	sts =
	gr$get_module_env(	msg	= msg,
				sizbuf	= &sizBuf,
				buffer	= &locEnv,
				nret	= &sizRet );

        sts =
        VLunw_GetChannelObjects( msg, &myGRid, NULL, &count,&grids,NULL);
        __CheckRC( sts, *msg, "VLunw_GetChannelObjects", wrapup );

	__DBGpr_int(" Object Found ", count );
	__DBGpr_objlist( " Object List ", count, grids );
	/*
	 * This way we can use the internal sets for processing increasement.
	 */
	sts = VLunw_ProcessFeat_Objects( msg, &locEnv, type, count, grids );
	__CheckRC( sts, *msg, "VLunw_ProcessFeat_Objects", wrapup );

	wrapup :
		_FREE( grids );
		End ;
		return sts ;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract

	Place an occurence of the macro in the design file.

  Arguments
      int 		*suc       	O 	0 FAILED 1 SUCCESS
      int		prop            I 	see macro.h
      char		rep             I 	navsea representation
      char 		*macro_name	I 	the macro to place
      int 		numb_obj	I 	the number of real template
      struct GRid 	*uplist     	I 	the list of templates
      struct GRid 	*def_occ    	I 	transfer context has to be 
						performed from this default 
						occurence
      struct GRmd_env	*mod_env	I	module env

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/
method ACmplace_from_def(	int		*rc,
						prop;
				char		rep;
				char		*macro_name;
				int		num_temp;
				struct GRid	*temp_list;
				struct GRid	*def_occ;
				struct GRmd_env *md_env ){

	/*
	 * Put the properties to no proptect:
	 *	- Does not create source,
	 *	- Does not verify the number (variable number of templates) 
	 *	- Does not verify the template types
	 */

	IGRint		sts = OM_S_SUCCESS ;

	SetProc( VLunwObj_ACmplace_from_def ); Begin

//	prop = prop | AChdr_noprotect | ACcant_place_sym | AChdr_nocompute ;
	prop = prop | AChdr_noprotect | ACcant_place_sym ;

	sts =
	_VD_SEND_WRT_M( my_id, ACncpx.ACmplace_from_def(rc,
							prop,
							rep, 
							macro_name,
							num_temp,
							temp_list,
							def_occ,
							md_env ));
	__CheckRC( sts, *rc, "ACncpx.ACmplace_from_def", wrapup ) ;

	wrapup:
		End ;
		return	sts;
}

/*mo+
 -------------------------------------------------------------------------
  Public Message
        GRputattr	from GRvg

  Abstract
        Set the instance info for 3d visualization Volume Area object.

  Arguments
        OUT     long            *msg            Completion code.
	OUT	VDpartAttr	*attr		Information.

  Note

 -------------------------------------------------------------------------
-mo*/

method	GRputattr(	IGRlong         *msg ;
                        IGRchar		*attr ){

	IGRint			sts = OM_S_SUCCESS , i, lenBuf, lenStr, lenDiff,
				lenInfo, maxNote, *pInt ;
	IGRlong			rc ;
	IGRdouble		*pDouble ;
	VDpartAttr		*part ;
	VDdrw2dVwInfo		*vwInfo ;
	struct	IGRlbsys	*pLbsys ;
	GRname			buffer;
	struct edge_match_list  match_lst;
	struct mise_a_plat	*dev;

	SetProc( VLunwObj_GRputattr ); Begin
	
	*msg	= MSSUCC ;
	part	= (VDpartAttr *) attr ;

	maxNote = VD_I_drwNoteOther2 - VD_I_drwNoteName ;

	switch(	part->Iwant ) {

	case	VD_I_drwInitialization	:
		sts =
		om$vla_set_dimension(	varray	= me->visual, size = 0 );
		om$vla_set_dimension(	varray	= me->name     , size = 0 );
		om$vla_set_dimension(	varray	= me->note     , size = 7 );
		om$vla_set_dimension(	varray	= me->indx     , size = 7 );

		buffer[0] = '\0';
		
		for( i=0 ; i<= maxNote ; i++ ){
			me->indx[i] = i ;
			strcpy(	&me->note[ me->indx[i]], buffer );
		}

		for( i=0 ; i<32 ; i++ ) me->drwLevel[i] = ~0 ;
		me->drwPnt[0] = 0 ; me->drwPnt[1] = 0 ; me->drwPnt[2] = 0 ;
		me->drwVec[0] = 0 ; me->drwVec[1] = 0 ; me->drwVec[2] = 1 ;

                MAidmx( msg, me->drwLbs.matrix );
                me->drwLbs.diag_pt1[0] = -MAXDOUBLE ;
                me->drwLbs.diag_pt1[1] = -MAXDOUBLE ;
                me->drwLbs.diag_pt1[2] = -MAXDOUBLE ;
                me->drwLbs.diag_pt2[0] =  MAXDOUBLE ;
                me->drwLbs.diag_pt2[1] =  MAXDOUBLE ;
                me->drwLbs.diag_pt2[2] =  MAXDOUBLE ;

		for( i=0 ; i<16 ; i++ )
		{
		   if( i%4 ) me->fromMat[i] = 0 ;
		   else      me->fromMat[i] = 1 ;
		}

		for( i=0 ; i<16 ; i++ )
		{
		   if( i%4 ) me->toMat[i] = 0 ;
		   else      me->toMat[i] = 1 ;
		}

        	me->dev.nb_def  = 0;
        	me->dev.nb_P    = 0;
        	me->dev.Nb_u    = 0;
        	me->dev.Nb_v    = 0;
		me->dev.surface = NULL;
		me->dev.devsrf  = NULL;
		me->dev.P       = NULL;
		me->dev.def     = NULL;
		me->dev.Param_u = NULL;
		me->dev.Param_v = NULL;

		break ;

	case	VD_I_drwInternalName	:

		lenInfo = 1 + strlen( part->aString );
		om$vla_set_dimension( varray = me->name, size = lenInfo );
		strcpy( me->name, part->aString );
		__DBGpr_str(" name  ", me->name  );

		break ;
	case	VD_I_drwNoteName	:
	case	VD_I_drwNoteScale	:
	case	VD_I_drwNoteLocation	:
	case	VD_I_drwNoteDesciption	:
	case	VD_I_drwNoteReference	:
	case	VD_I_drwNoteOther1	:
	case	VD_I_drwNoteOther2	:

		/*
		 * get the information from the buffer.
		 */
		i = part->Iwant - VD_I_drwNoteName ;

		__DBGpr_int( "Table Index ", i );
		lenBuf  = om$dimension_of(	varray	= me->note );
		lenStr  = strlen( &me->note[ me->indx[i]] );
		lenInfo = strlen( part->aString );
		lenDiff = lenInfo - lenStr ;

		__DBGpr_int( "	lenStr  ", lenStr  );
		__DBGpr_int( "	lenInfo ", lenInfo );
		__DBGpr_int( "	lenDiff ", lenDiff ); 

		/*
		 * Check what to do with buffer.
		 * If lenStr = lenInfo	-> copy info.
		 * If lenStr < lenInfo  -> copy info + move buffer 
		 *			   change indx list + rezise note..
		 * If lenStr > lenInfo  -> increase note + move buffer,
		 *			   change indx list + copy info.
		 */
		if( lenDiff == 0 ){
		  strcpy( &me->note[ me->indx[i]], (char *) part->aString );
		}
		else{
		  if( lenDiff > 0 )
		    om$vla_set_dimension(	varray	= me->note,
						size	= lenBuf + lenDiff );

		  if( i < maxNote ){
		      lenInfo = lenBuf - me->indx[i] ;
		      OM_BLOCK_MOVE(	&me->note[ me->indx[i+1] ],
					&me->note[ me->indx[i+1] + lenDiff ],
					lenInfo * sizeof( IGRchar ) );
		  }

		  strcpy( &me->note[ me->indx[i]], part->aString );

		  i++ ;
		  for( ; i<= maxNote ; i++ ) me->indx[i] += lenDiff ;

		  if( lenDiff < 0 )
		    om$vla_set_dimension(	varray	= me->note,
						size	= lenBuf + lenDiff );
		}

#ifdef	vdsDEBUG
		for( i=0 ; i<=maxNote ; i++ )
		  __DBGpr_str( "INFO ", &me->note[ me->indx[i]] );
#endif
	
		break ;
	case	VD_I_drwVisual	:

		/*
		 *  Temporary the support file for all are the same.
		 */

		lenInfo = 1 + strlen( part->aString );
		om$vla_set_dimension( varray = me->visual, size = lenInfo );
		strcpy( me->visual, part->aString );

		break ;

	case	VD_I_drwProjPnt :

		pDouble	= (IGRdouble *) part->specific ;
		me->drwPnt[0]	= pDouble[0] ;
		me->drwPnt[1]	= pDouble[1] ;
		me->drwPnt[2]	= pDouble[2] ;

		break ;
	case	VD_I_drwProjVec :

		pDouble	= (IGRdouble *) part->specific ;
		me->drwVec[0]	= pDouble[0] ;
		me->drwVec[1]	= pDouble[1] ;
		me->drwVec[2]	= pDouble[2] ;

		break ;

	case    VL_I_fromMat :

		pDouble = (IGRdouble *) part->specific ;
		for( i=0; i<16; ++i )  me->fromMat[i] = pDouble[i] ;

		break ;

	case    VL_I_toMat :

		pDouble = (IGRdouble *) part->specific ;
		for( i=0; i<16; ++i )  me->toMat[i] = pDouble[i] ;

		break ;

	case    VL_I_edgeMatch :

		match_lst = *(( struct edge_match_list * ) part->specific);
		me->EdgeCount = match_lst.Count;
		om$vla_set_dimension( 	varray = me->EdgeList, 
					size   = match_lst.Count );
		for( i=0; i<match_lst.Count; ++i )
			me->EdgeList[i] = match_lst.EdgeList[i];
		break ;

	case	VL_I_devStruct :

		dev = ( struct mise_a_plat * )part->specific;

		me->dev.surf_id  = dev->surf_id;
		me->dev.res_id  = dev->res_id;
		me->dev.developpable = dev->developpable;
		me->dev.tesselation_option = dev->tesselation_option;
		me->dev.side_of_plate = dev->side_of_plate;
		me->dev.uvSrfId = dev->uvSrfId;

		if( dev->P )
		{
	  	   me->dev.nb_P = dev->Nb_u*dev->Nb_v*3;
		   me->dev.P = _MALLOC( me->dev.nb_P, IGRdouble );
		   for( i=0; i<me->dev.nb_P; ++i )  me->dev.P[i] = dev->P[i];
		}

		if( dev->def )
		{
	  	   me->dev.nb_def   = (  dev->Nb_u*dev->Nb_v*3 + 
		    		         4*(dev->Nb_u-1)*(dev->Nb_v-1) +
                	                 3*(2*(dev->Nb_u-1 + dev->Nb_v-1)+1) +
                        	         2*(dev->Nb_u + dev->Nb_v) -1 ) ;
		   me->dev.def = _MALLOC( me->dev.nb_def, IGRdouble );
          	   memcpy ( (IGRchar *)me->dev.def,(IGRchar *)dev->def,
                   	    (IGRint) ( me->dev.nb_def * sizeof(IGRdouble)) );
		}

		if( dev->Param_u )
		{
	  	   me->dev.Nb_u = dev->Nb_u;
		   me->dev.Param_u = _MALLOC( me->dev.Nb_u, IGRdouble );
		   for( i=0; i<me->dev.Nb_u; ++i )  
			me->dev.Param_u[i] = dev->Param_u[i];
		}

		if( dev->Param_v )
		{		
	  	   me->dev.Nb_v = dev->Nb_v;
		   me->dev.Param_v = _MALLOC( me->dev.Nb_v, IGRdouble );
		   for( i=0; i<me->dev.Nb_v; ++i )  
			me->dev.Param_v[i] = dev->Param_v[i];
		}

      		BSallocsf (   (IGRshort)dev->surface->u_order,
                 	      (IGRshort)dev->surface->v_order,
	                      (IGRlong)dev->surface->u_num_poles,
        	              (IGRlong)dev->surface->v_num_poles,
                	      (IGRboolean )dev->surface->rational,
	                      (IGRshort)dev->surface->num_boundaries,
        	              &me->dev.surface, &rc);
		if (rc != BSSUCC) {
        	   printf("Error in GRputattr()\n");
	           printf("Error in BSallocsf for surface: Returns %d\n", rc);
     		   sts = OM_E_ABORT;
	           goto wrapup;
        	}

	        BSsf_copy( &rc, dev->surface, me->dev.surface );
        	if (rc != BSSUCC) {
	           printf("Error in copying dev->surface in GRputattr()\n");
     		   sts = OM_E_ABORT;
	           goto wrapup;
        	}

	      	BSallocsf (   (IGRshort)dev->devsrf->u_order,
        	              (IGRshort)dev->devsrf->v_order,
                	      (IGRlong)dev->devsrf->u_num_poles,
	                      (IGRlong)dev->devsrf->v_num_poles,
        	              (IGRboolean )dev->devsrf->rational,
                	      (IGRshort)dev->devsrf->num_boundaries,
	                      &me->dev.devsrf, &rc);
     		if (rc != BSSUCC) {
	           printf("Error in GRputattr()\n");
        	   printf("Error in BSallocsf for devsrf: Returns %d\n", rc);
	     	   sts = OM_E_ABORT;
        	   goto wrapup;
	        }

	        BSsf_copy( &rc, dev->devsrf, me->dev.devsrf );
        	if (rc != BSSUCC) {
	           printf("Error in copying dev->devsrf in GRputattr()\n");
     		   sts = OM_E_ABORT;
	           goto wrapup;
        	}

		break ;

	case	VD_I_drwProjLbs :

		pLbsys = (struct IGRlbsys *) part->specific ;
		me->drwLbs = *pLbsys ;

		break ;
	case	VD_I_drwProjLevel :

		pInt = (IGRint *) part->specific ;
		for( i=0 ; i<32 ; i++ ) me->drwLevel[i] = pInt[i] ;

		break ;
	case	VD_I_drwProjAllInfo :

                vwInfo = (VDdrw2dVwInfo *) part->specific ;
                if( vwInfo->intName ){
                  lenInfo = 1 + strlen( vwInfo->intName );
                  om$vla_set_dimension( varray = me->name, size = lenInfo );
                  strcpy( me->name, vwInfo->intName );
		}

                if( vwInfo->visFile ){
		  lenInfo = 1 + strlen( vwInfo->visFile );
		  om$vla_set_dimension( varray= me->visual, size= lenInfo );
		  strcpy( me->visual, vwInfo->visFile );
		}

                if( vwInfo->prjVec ){
		  me->drwVec[0]	= vwInfo->prjVec[0] ;
		  me->drwVec[1]	= vwInfo->prjVec[1] ;
		  me->drwVec[2]	= vwInfo->prjVec[2] ;
		}
		if( vwInfo->prjPnt ){
			me->drwPnt[0]	= vwInfo->prjPnt[0] ;
			me->drwPnt[1]	= vwInfo->prjPnt[1] ;
			me->drwPnt[2]	= vwInfo->prjPnt[2] ;
		}
		if( vwInfo->objLev ){
			for(i=0;i<32;i++) me->drwLevel[i] = vwInfo->objLev[i] ;
		}
		if( vwInfo->drwLbsys ){
			me->drwLbs = *vwInfo->drwLbsys ;
		}
		break ;
	default :

		__DBGpr_int(" Unknown Type ", part->Iwant );
	}
wrapup:
	End ;
	return sts ;
}

/*me+
 -------------------------------------------------------------------------
  Public Message
        GRgetattr	from GRvg

  Abstract
	Retrieve attribute values.

  Arguments
        OUT     long            *msg            Completion code.
	IN	VDpartAttr	*attr		Information.

  Note

 -------------------------------------------------------------------------
-mo*/

method GRgetattr(	IGRlong         *msg ;
			IGRchar		*attr ){

	IGRlong			sts=OM_S_SUCCESS ;
	VDpartAttr		*part ;
	VDdrw2dVwInfo		*vwInfo ;
	IGRint			i, count, *pInt ;
	IGRdouble		*pDouble ;
        IGRchar                 side[30];
        struct GRid             myGRid, plateId;
        struct GRobj_env        plateOE;
	struct edge_match_list  *match_lst;
	struct unw_obj_plat	*dev ;

	SetProc( VLunwObj_GRgetattr ); Begin

	*msg	= MSSUCC ;
	part    = (VDpartAttr *) attr ;

	__DBGpr_int( "TYPE ", part->Iwant );

	switch(	part->Iwant ) {

	case	VD_I_drwInitialization	:

		__DBGpr_com(" Invalid Option " );
		*msg = OM_E_INVARG ;
		break ;
	case	VD_I_drwInternalName	:

		strcpy( part->aString, me->name );
		__DBGpr_str( " Info ", part->aString );

		break ;
	case	VD_I_drwNoteName	:
	case	VD_I_drwNoteScale	:
	case	VD_I_drwNoteLocation	:
	case	VD_I_drwNoteDesciption	:
	case	VD_I_drwNoteReference	:
	case	VD_I_drwNoteOther1	:
	case	VD_I_drwNoteOther2	:

		strcpy( part->aString,
			&me->note[ me->indx[(part->Iwant-VD_I_drwNoteName)]] );
		__DBGpr_str( " Info ", part->aString );
	
		break ;
	case	VD_I_drwVisual	:

		strcpy( part->aString, me->visual );

		__DBGpr_str(" visual", me->visual );

		break ;

	case	VD_I_drwProjPnt :

		/*
		 * External buffering.
		 */
		pDouble		= (IGRdouble *) part->specific ;
		pDouble[0]	= me->drwPnt[0]	;
		pDouble[1]	= me->drwPnt[1]	;
		pDouble[2]	= me->drwPnt[2]	;

		break ;

	case    VL_I_fromMat :

		pDouble         = (IGRdouble *) part->specific ;
		for( i=0; i<16; ++i )  pDouble[i] = me->fromMat[i];

		break;

	case    VL_I_toMat :

		pDouble         = (IGRdouble *) part->specific ;
		for( i=0; i<16; ++i )  pDouble[i] = me->toMat[i];

		break;

	case    VL_I_edgeMatch :

		match_lst = ( struct edge_match_list * ) part->specific;
		match_lst->Count = me->EdgeCount;

		if( !(match_lst->EdgeList = _MALLOC( 	me->EdgeCount, 
							struct EdgeMatch )) )
		{
		   printf("\n Memory Failure in GRvggetattr");
		   return OM_E_NODYNMEM ;
		}

		for( i=0; i<me->EdgeCount; ++i )
			match_lst->EdgeList[i] = me->EdgeList[i] ;

		break ;

	case    VL_I_getOpts :

		dev = ( struct unw_obj_plat * ) part->specific;

		if( ( om$is_objid_valid ( osnum = me->dev.surf_id._osnum,
		      objid = me->dev.surf_id._objid  ) == OM_S_SUCCESS ) &&
		    ( vd_$is_ancestry_valid( object  = &me->dev.surf_id,
				classid = OPP_EMSsurface_class_id ) ) )
		{
		   dev->surf_id = me->dev.surf_id;
		}
		else
		{
                   myGRid.objid = my_id;
                   myGRid.osnum = OM_Gw_current_OS;

                   sts = _VD_SEND_OBJN( myGRid, NDnode.NDget_objects( ND_ROOT,
                             &plateId, 1, NULL, 1, 1, &count ));
                   __DBGpr_obj( " Parent Plate ", plateId );

                   sts = _VD_SEND_OBJN( plateId, NDmacro.ACreturn_foot(
                                        msg, "", &plateOE.obj_id,
                                        &plateOE._matrix_type,
                                        plateOE._matrix           ) );
                   __DBGpr_obj( " Original Plate in model ", plateOE.obj_id );
                   plateOE._md_os = plateOE._osnum;
                   ex$get_modid(   mod_osnum = plateOE._md_os,
                                   mod_id    = &plateOE._md_id ) ;

                   // Get the correct surface from the Non-hole plate parent
                   if (  dev->side_of_plate == OFFSET_SIDE ||
                         dev->side_of_plate == OFFSET_FLIP    )
                         	strcpy(side, VS_K_plTopSfPath);
               	   else         strcpy(side, VS_K_plBotSfPath);
                   __DBGpr_str("Side to Unwrap ", side );

                   sts = _VD_SEND_OBJN( plateOE.obj_id, NDmacro.ACreturn_foot(
                        msg, side, &dev->surf_id.obj_id,
                        &dev->surf_id._matrix_type,
                        dev->surf_id._matrix ) );
                   __DBGpr_obj( "Parent Surface ", dev->surf_id.obj_id );

                   dev->surf_id._md_os = dev->surf_id._osnum;
                   ex$get_modid(   mod_osnum = dev->surf_id._md_os,
                                mod_id    = &dev->surf_id._md_id ) ;
                   __DBGpr_obj( "Surface Module ID ", dev->surf_id.mod_env.md_id );

                   me->dev.surf_id = dev->surf_id;
		}

          	dev->developpable = me->dev.developpable;
          	dev->tesselation_option = me->dev.tesselation_option;
          	dev->side_of_plate = me->dev.side_of_plate;
          	dev->uvSrfId = me->dev.uvSrfId;

	 	break ;

	case    VL_I_devStruct :
                dev = ( struct unw_obj_plat * ) part->specific;

                if( om$is_objid_valid ( osnum = me->dev.surf_id._osnum,
			 objid = me->dev.surf_id._objid  ) == OM_S_SUCCESS )
                {
                   dev->surf_id = me->dev.surf_id;
                }
                else
                {
                   myGRid.objid = my_id;
                   myGRid.osnum = OM_Gw_current_OS;

                   sts = _VD_SEND_OBJN( myGRid, NDnode.NDget_objects( ND_ROOT,
                             &plateId, 1, NULL, 1, 1, &count ));
                   __DBGpr_obj( " Parent Plate ", plateId );

                   sts = _VD_SEND_OBJN( plateId, NDmacro.ACreturn_foot(
                                        msg, "", &plateOE.obj_id,
                                        &plateOE._matrix_type,
                                        plateOE._matrix           ) );
                   __DBGpr_obj( " Original Plate in model ", plateOE.obj_id );
                   plateOE._md_os = plateOE._osnum;
                   ex$get_modid(   mod_osnum = plateOE._md_os,
                                   mod_id    = &plateOE._md_id ) ;

                   // Get the correct surface from the Non-hole plate parent
                   if (  dev->side_of_plate == OFFSET_SIDE ||
                         dev->side_of_plate == OFFSET_FLIP    )
                        	strcpy(side, VS_K_plTopSfPath);
                   else    	strcpy(side, VS_K_plBotSfPath);
                   __DBGpr_str("Side to Unwrap ", side );

                   sts = _VD_SEND_OBJN( plateOE.obj_id, NDmacro.ACreturn_foot(
                        msg, side, &dev->surf_id.obj_id,
                        &dev->surf_id._matrix_type,
                        dev->surf_id._matrix ) );
                   __DBGpr_obj( "Parent Surface ", dev->surf_id.obj_id );

                   dev->surf_id._md_os = dev->surf_id._osnum;
                   ex$get_modid(   mod_osnum = dev->surf_id._md_os,
                                   mod_id    = &dev->surf_id._md_id ) ;
                   __DBGpr_obj( "Surface Module ID ", dev->surf_id.mod_env.md_id );

                   me->dev.surf_id = dev->surf_id;
		}

	  	dev->developpable = me->dev.developpable;
		dev->tesselation_option = me->dev.tesselation_option;
		dev->side_of_plate = me->dev.side_of_plate;
		dev->uvSrfId = me->dev.uvSrfId;

		dev->nb_def  = 0;
		dev->nb_P    = 0;
		dev->Nb_u    = 0;
		dev->Nb_v    = 0;
		dev->surface = NULL;
		dev->devsrf  = NULL;
		dev->P       = NULL;
		dev->def     = NULL;
		dev->Param_u = NULL;
		dev->Param_v = NULL;

		if( me->dev.def )
		{
		   dev->nb_def = me->dev.nb_def;
		   dev->def = _MALLOC( me->dev.nb_def, IGRdouble );

		   for( i=0; i<me->dev.nb_def; ++i )
			  dev->def[i] = me->dev.def[i];
		}

		if( me->dev.P )
		{
		   dev->nb_P = me->dev.nb_P;
		   dev->P = _MALLOC( me->dev.nb_P, IGRdouble );
		   for( i=0; i<me->dev.nb_P; ++i )
			dev->P[i] = me->dev.P[i];
		}

		if( me->dev.Param_u )
		{
		   dev->Nb_u = me->dev.Nb_u;
		   dev->Param_u = _MALLOC( me->dev.Nb_u, IGRdouble );
		   for( i=0; i<me->dev.Nb_u; ++i )
			dev->Param_u[i] = me->dev.Param_u[i];
		}
		if( me->dev.Param_v )
		{
		   dev->Nb_v = me->dev.Nb_v;
		   dev->Param_v = _MALLOC( me->dev.Nb_v, IGRdouble );
		   for( i=0; i<me->dev.Nb_v; ++i )
			dev->Param_v[i] = me->dev.Param_v[i];
		}
		break ;

	case	VD_I_drwProjVec :

		pDouble		= (IGRdouble *) part->specific ;
		pDouble[0]	= me->drwVec[0]	;
		pDouble[1]	= me->drwVec[1]	;
		pDouble[2]	= me->drwVec[2]	;

		break ;
	case	VD_I_drwProjLbs :

		*(struct IGRlbsys *)part->specific = me->drwLbs ;

		break ;
	case	VD_I_drwProjLevel :

		pInt = (IGRint *) part->specific ;
		for( i=0 ; i<32 ; i++ ) pInt[i] = me->drwLevel[i] ;

		break ;
	case	VD_I_drwProjAllInfo :

                vwInfo = (VDdrw2dVwInfo *) part->specific ;
                if( vwInfo->intName )
                        strcpy( vwInfo->intName, me->name );
                if( vwInfo->visFile )
                        strcpy( vwInfo->visFile, me->visual );
                if( vwInfo->prjVec ){
			vwInfo->prjVec[0]	= me->drwVec[0]	;
			vwInfo->prjVec[1]	= me->drwVec[1]	;
			vwInfo->prjVec[2]	= me->drwVec[2]	;
		}
		if( vwInfo->prjPnt ){
			vwInfo->prjPnt[0]	= me->drwPnt[0]	;
			vwInfo->prjPnt[1]	= me->drwPnt[1]	;
			vwInfo->prjPnt[2]	= me->drwPnt[2]	;
		}
		if( vwInfo->objLev ){
			for(i=0;i<32;i++) vwInfo->objLev[i] = me->drwLevel[i] ;
		}
		if( vwInfo->drwLbsys ){
			*vwInfo->drwLbsys = me->drwLbs ;
		}

		break; 
	default :
		__DBGpr_int(" Unknown Type ", part->Iwant );
	}

	End ;
	return sts ;
}


/*+mo
 -------------------------------------------------------------------------
  Private Message 
	VDdeleteIfEmpty 

  Description:
	Delete the object itself under certain conditions.
 
  Dependencies:
	VLunwObj

  History:
 
  -------------------------------------------------------------------------
 */

method	VDdeleteIfEmpty(	IGRlong			*msg;
				struct	GRmd_env	*md_env ){

	long		        sts = OM_S_SUCCESS ;
	OMuint			cnt = 0 ;
	IGRint			action = 0 ;
	OM_S_CHANSELECT		to_obj ;

	SetProc( VLunwObj_VDdeleteIfEmpty ); Begin

	*msg = MSSUCC;

        to_obj.type        = OM_e_name;
        to_obj.u_sel.name  = "VLunwObj.to_feat";

	sts =
	om$get_channel_count(	objid		= my_id,
				p_chanselect	= &to_obj,
				count		= &cnt );
	CheckRC( sts, 1 );

       __DBGpr_int( "count ", cnt );

	if( ! cnt ){

		struct	GRid	myGRid ;

		myGRid.objid	= my_id ;
		myGRid.osnum	= OM_Gw_current_OS ;

                /*
                 * check if object exist in VDbatData object -> remove it.
                 */
                sts =
                VDbat_UpdateControlData( msg, md_env, &myGRid, action );
                CheckRC( sts, *msg );
		
		sts =
		_VD_SEND_WRT_M( my_id, ASnode.GRdelete( msg, md_env ));
		CheckRC( sts, *msg );
	}
	
	End ;
	return sts ;	
}

end implementation VLunwObj;
 

