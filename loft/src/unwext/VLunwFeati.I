/* $Id: VLunwFeati.I,v 1.4 2001/06/26 21:26:22 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwFeati.I
 *
 * Description: Feature Object Compute Engine.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwFeati.I,v $
 *      Revision 1.4  2001/06/26 21:26:22  ramarao
 *      Fixed TR# 5245.
 *
 *      Revision 1.3  2001/02/20 01:07:21  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:10  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/06/23  23:07:38  pinnacle
# Created: loft/src/unwext/VLunwFeati.I by rchennup for Service Pack
#
# Revision 1.4  1998/09/09  05:03:28  pinnacle
# Replaced: src/unwext/VLunwFeati.I for:  by smpathak for loft
#
# Revision 1.3  1998/06/25  20:13:26  pinnacle
# Replaced: src/unwext/VLunwFeati.I for:  by smpathak for loft
#
# Revision 1.2  1998/06/22  21:41:44  pinnacle
# Replaced: src/unwext/VLunwFeati.I for:  by smpathak for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.5  1998/01/23  15:25:26  pinnacle
# Replaced: src/unwext/VLunwFeati.I for:  by rchennup for loft
#
# Revision 1.4  1998/01/02  04:14:32  pinnacle
# Replaced: src/unwext/VLunwFeati.I for:  by rchennup for loft
#
# Revision 1.3  1997/10/31  19:28:38  pinnacle
# Replaced: src/unwext/VLunwFeati.I for:  by rchennup for loft
#
# Revision 1.1  1997/10/28  15:29:12  pinnacle
# Created: src/unwext/VLunwFeati.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *      06/22/98   Sandeep      File Modification for TR179801074
 *      09/08/98   Sandeep      Modified for crash reported by Ad. VLunwFeat 
				made available in parser.
  *************************************************************************/

class implementation VLunwFeat;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "exmacros.h"
#include "asbox.h"
#include "acdef.h"
#include "acmacros.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ACrg_collect.h"
#include "VDobj.h"
#include "vds.h"
#include "vddrwattr.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "v_miscmacros.h"
#include "vlmsg.h"
#include "vlstructure.h"
#include "vlunfold.h"
#include "v_vecmxproto.h"
#include "vldbgmacros.h"

extern	GRclassid	OPP_VDdrwGm_class_id,
			OPP_GRowner_class_id,
			OPP_VDcontext_class_id, 
			OPP_GRcompcurve_class_id ;

from	VDcontext	import	VDget_extract_info;
from	GRcontext	import	GRgetmodule_env;
from    VLunwObj	import  VDdeleteIfEmpty;
from    ACrg_collect	import	AClist_attribute;

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

IGRint		sts = OM_S_SUCCESS ;

	/*
	 * Put the properties to no proptect:
	 *	- Does not create source,
	 *	- Does not verify the number (variable number of templates) 
	 *	- Does not verify the template types
	 */

	prop = prop | AChdr_noprotect | ACcant_place_sym;

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
		return	OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= VL_I_ObjUnwFeat ;
//	myDef->type		= VL_O_unwfeat ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */

/*----------------------------------------------------------------------------*/

static long VLunwFeat_drwACncpx_NDdrawing_copy_geom(construction,
						drw2dView,
						visualFile,
						selected_elements,
						nb_elements,
						outList,
						outCount,
						vector,
						point,
						lbsys,
						from_env,
						to_env,
						unwfeat )

struct GRid		*construction ;
char			*drw2dView ;
char			*visualFile ;
struct GRid		*selected_elements ;
int			nb_elements ;
struct GRid		**outList ;
int			*outCount ;
double			*vector,
			*point ;
struct IGRlbsys		*lbsys ;
struct GRmd_env		*from_env,
			*to_env ; 
struct GRid             *unwfeat;
{

	long			sts,
				msg ;
	IGRchar			*fl_Name = NULL ;
	IGRchar			*st_Name = NULL ;
	struct IGRplane		drawingPlane,
				viewPlane ;
	IGRvector		viewVector ;
	IGRpoint		viewPoint ;
	VD_drwOutputData	*output = NULL ;

	SetProc( VLunwFeat_drwACncpx_NDdrawing_copy_geom ); Begin

	__DBGpr_obj( "MY_ID", *construction );
        __DBGpr_obj( "unwfeat ---> ", *unwfeat );

	sts = VLunwext_LoadKeyWords();
	if ( !(1 & sts)) {
		goto wrapup;
	}

	*outCount	= 0 ;
	*outList	= NULL ;

	drawingPlane.point	= point ;
	drawingPlane.normal	= vector ;
		
	viewPlane.point		= VD_mxorigin( lbsys->matrix, viewPoint ) ;
	viewPlane.normal	= vector ;

	VD_vccpy( viewVector, vector ) ;

	if( strlen( drw2dView ))	st_Name = drw2dView ;
	if( strlen( visualFile ))	fl_Name = visualFile ;

	sts =
	vd_$drwExecConfig(	msg		= &msg,
				elmId		= construction,
				elmEnv		= from_env,
                                appData         = (void *) unwfeat,
				drwPlane	= &drawingPlane,
				viewPlane	= &viewPlane,
				viewVector	= viewVector,
				drwEnv		= to_env,
				drwLbsys	= lbsys,
				selCount	= nb_elements,
				selList		= selected_elements,
				filename	= fl_Name,
				set_name	= st_Name,
				output		= &output ) ;
	if( !(sts & 1 & msg )){
		int			n	= 0 ;
		VD_drwOutputData	*p	= output ;
		while( p ) { n += p->set.count ; p = p->next ; }

		if( n ) {
			sts = OM_S_SUCCESS ;
			msg = MSSUCC ;
		}
	}

	if( sts & 1 & msg ) {
		int			n	= 0 ;
		VD_drwOutputData	*p	= output ;
		while( p ) { n += p->set.count ; p = p->next ; }

		if( n ) {
			*outList = _MALLOC( n, struct GRid ) ;
			if( *outList ) {
				n = 0 ;
				p = output ;
				while( p ) {
					int i ;
					int max = p->set.count ;
					struct GRid *l = p->set.list ;
					for( i = 0 ; i < max ; i++ ) {
						(*outList)[n++] = l[i] ;
					}
					p = p->next ;
				}
				*outCount = n ;
			}
		}
	}

	VD_drwFreeOutputData( &output ) ;
wrapup:
	End
	return OM_S_SUCCESS ;

} /* VLunwFeat_drwACncpx_NDdrawing_copy_geom */

/*----------------------------------------------------------------------------*/

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
	 *	- Dynamic collection (description, location, comp_flag, ...).
	 * 	- Parent object.
	 *	- List of Edge Attribute Objects
	 */

	IGRshort		trfMatType;
	IGRint			sts = OM_S_SUCCESS ;
	struct GRid		modObj,			/* 3d object	*/
				UnwObj,
				ctxObj,			/* context obj	*/
				myGRid,			/* i		*/
				gmId,			/* gm object	*/
				gmMacDef,		/* gm macro def	*/
				*gmList = NULL,		/* list of 2d 	*/
				*rfList = NULL;		/* list of dep	*/
	IGRint			gmCount,		/* Nb gm objs	*/
				gmMax,			/* Nb ind geom  */
				rfCount,		/* Nb of dep	*/
				i, j, index,
				gm, num, apply_exp=0,
				modLevel[32];		/* dgn levels	*/
	struct	IGRlbsys	ctxLbs;
	IGRdouble		drwPnt[3],
				drwVec[3],
				fromMat[16],
				toMat[16],
				orgToMat[16],
				trfMat[16];
	GRname			gmMacro,
				visualFile,
				drw2dView ;
	struct unw_obj_plat     dev;
	struct GRmd_env		modEnv ;
	struct GRobj_env	boxOE ;
	struct ACrg_coll 	ACrg[UNFOLD_NB_OPT];
	VDpartAttr		attr ;
	VDdrw2dVwInfo		vwInfo ;

	SetProc( VLunwFeat_ACconstruct_feet ); Begin
 
	*msg = MSFAIL;

	/*
	 * init drawing object.
	 */
	myGRid.objid = my_id;
	myGRid.osnum = OM_Gw_current_OS;

	gmId.objid = NULL_OBJID ;
	gmId.osnum = OM_Gw_current_OS;

	/*
	 * find object in model and its macro definition
	 */
	sts =
	_VD_SEND_OBJ(	list[1],
			NDmacro.ACreturn_foot(	msg,
						"",
						&modObj,
						&modEnv.md_env.matrix_type,
						modEnv.md_env.matrix ));
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );

	modEnv._MD_OS = modObj.osnum;
	sts = ex$get_modid(	mod_osnum = modEnv._MD_OS,
				mod_id	  = &modEnv._MD_ID );

	/*
	 * The reference object is a parent object connect through
	 * generated "make_source" of the 3d-model object and the Context.
	 */
	sts = _VD_SEND_MY( VLunwFeat.VLgetUnw_obj( msg, &UnwObj ) );
	__CheckRC( sts, *msg, "VLunwFeat.VLgetUnw_obj", wrapup );

	VLunw_InitObjInfo( msg, &vwInfo );

	vwInfo.intName	= drw2dView ;
	vwInfo.prjVec	= drwVec ;
	vwInfo.prjPnt	= drwPnt ;
	vwInfo.objLev	= modLevel ;
	vwInfo.drwLbsys	= &ctxLbs ;

	/* Get the visualization support file */
	attr.Iwant = VD_I_drwVisual ;
	sts = _VD_SEND_OBJ( UnwObj, GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );
	strcpy( visualFile, attr.aString );

	attr.Iwant = VD_I_drwProjAllInfo ;
	attr.specific = (void *) &vwInfo ;
	sts = _VD_SEND_OBJ( UnwObj, GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

    	attr.Iwant = VL_I_fromMat ;
    	attr.specific = (void *) fromMat ;
    	sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

    	attr.Iwant = VL_I_toMat ;
    	attr.specific = (void *) toMat ;
    	sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

        attr.Iwant = VL_I_getOpts ;
        attr.specific = (void *) &dev ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

        boxOE._objid = NULL_OBJID;
        vdobj$GetTemplate( objID = &UnwObj,
                           nth   = 0,
                           templateOE = &boxOE );

	sts = _VD_SEND_OBJN( boxOE.obj_id, ACrg_collect.AClist_attribute(
				msg, UNFOLD_NB_OPT, ACrg, &num ) );
        __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup ) ;

	if((j=VLseekFields(ACrg,num,UNFOLD_ATT_EXPTYPE)) != -1 &&
	     dev.developpable > 0   		&&
	     ACrg[j].desc.value.att_exp != NO_EXPANSION ) 
	{
	   IGRdouble	x_scale = 1.0, y_scale = 1.0 ;
	   if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_X_EXPANSION)) != -1) {
		x_scale = ACrg[j].desc.value.att_exp + 1.0 ;
	   }

           if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_Y_EXPANSION)) != -1) {
                y_scale = ACrg[j].desc.value.att_exp + 1.0 ;
           }
	   if( x_scale != 1.0  || y_scale != 1.0 )
	   {
		for( i=0; i<16; ++i ) orgToMat[i] = toMat[i] ;
		apply_exp = 1 ;
	   	toMat[0]  = toMat[0]*x_scale;
	   	toMat[4]  = toMat[4]*x_scale;
	   	toMat[8]  = toMat[8]*x_scale;
	   	toMat[12] = toMat[12]*x_scale;

	   	toMat[1]  = toMat[1]*y_scale;
	   	toMat[5]  = toMat[5]*y_scale;
	   	toMat[9]  = toMat[9]*y_scale;
	   	toMat[13] = toMat[13]*y_scale;
	   }
	}

	rfList  = &modObj ;
	rfCount = 1 ;

	VD_drw_GetCtxAndRefFromSrc( &(list[1]), &ctxObj, (struct GRid *)NULL );

	if( vd_$is_ancestry_valid(	object	= &ctxObj,
					classid	= OPP_VDcontext_class_id )){

	  /*
	   * reference object list "rfList" is a static list of
	   * objects created inside the command VDget_extract_info().
	   * The buffer does not to be freed inside this command.
	   */
	  sts =
	  _VD_SEND_OBJ(	ctxObj,
			VDcontext.VDget_extract_info(	&rfList,
							&rfCount, /* not used */
							drwVec,
							drwPnt,
							modLevel,
							&ctxLbs ));
	  __CheckRC( sts, 1, "VDcontext.VDget_extract_info", wrapup );
	}
	  
	if( !(sts&*msg&1) || (strlen( drw2dView ) == 0) ){
		/*
		 * No set found for object.
		 */
		rfList  = &modObj ;
		rfCount = 1 ;
	}

	/*
         * See if filename has been specified.
         */
	__DBGpr_str(" visualFile ", visualFile );
	__DBGpr_str(" drw2dView  ", drw2dView );

	/*
	 * give the current object within the drawing extraction to
	 * information concerning object specific treatments.
	 */
	gmList	= NULL ;
	gmCount = 0 ;

	sts =
	VLunwFeat_drwACncpx_NDdrawing_copy_geom(	&modObj,
						drw2dView,	/* Set of   */
						visualFile,	/* filename */
						rfList,		/* reference */
						rfCount,
						&gmList,
						&gmCount,
						drwVec,
						drwPnt,
						&ctxLbs,
						&modEnv,
						md_env,
						&myGRid );

	rfList = NULL ;

	/*
	 * get the geometry objects from the macro.
	 *	- geom : Extract geometry information.
	 *
	 * delete the previous occurence of the geometry collectors.
	 */
	sts =
	_VD_SEND_MY( NDmacro.ACreturn_foot( msg, "geom", &gmId, NULL, NULL ));
	if( gmId.objid != NULL_OBJID ){
            sts =
            _VD_SEND_OBJN( gmId, GRconnector.GRdisconn( msg, &myGRid ));
	    __CheckRC( sts, *msg, "GRconnector.GRdisconn", wrapup );

	    sts = _VD_SEND_OBJN( gmId, GRgraphics.GRdelete( msg, md_env ));
	    __CheckRC( sts, *msg, "GRgraphics.GRdelete", wrapup ) ;
	    gmId.objid = NULL_OBJID ;
	}

	/*
	 * Check the number of components of the return graphics
	 */
	gmMax = 0 ;
	for( i=0 ; i<gmCount ; i++ ){

	   if( apply_exp )
	   {
	       sts = VLapplyTransf( &gmList[i], 1, md_env,
                        orgToMat, toMat, trfMat, &trfMatType, msg );
	   }

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
        /****** Modification for TR #179801074 ****/
           if( cn_type == 2 )
           {
                sts = VLapplyTransf( &gmList[i], 1, md_env,
                        fromMat, toMat, trfMat, &trfMatType, msg );
                __CheckRC( sts, *msg, "VLapplyTransf", wrapup ) ;
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

		sts = _VD_SEND_OBJ(	Comp,
				NDnode.NDmove_to_root(	msg, &Comp, md_env ));
		__CheckRC( sts, *msg, "NDnode.NDmove_to_root", wrapup ) ;
 
	    } /* indexes in one geom type */

	} /* for all geom objects */

	/*
	 * connect the components with geometry and
	 * create the drawing part
	 */
	*fcount = 1 ;
	feet_list[0] = gmId;

	*msg = MSSUCC;
	sts  = OM_S_SUCCESS ;

	wrapup:

		_FREE( gmList );
		End ;
		return sts ;;
}


method GRdelete(IGRlong *msg ; struct GRmd_env *md_env)
{
	IGRlong 		sts;
	struct GRid 		UnwObj;
	OM_S_CHANSELECT      	to_feat, to_obj;

	SetProc( VLunwFeat_GRdelete ); Begin

    	to_feat.type = OM_e_name;
    	to_feat.u_sel.name = "VLunwObj.to_feat";

    	to_obj.type = OM_e_name;
    	to_obj.u_sel.name = "VLunwFeat.to_obj";

	sts = _VD_SEND_MY( VLunwFeat.VLgetUnw_obj( msg, &UnwObj ) );
	__CheckRC( sts, *msg, "VLunwFeat.VLgetUnw_obj", wrapup ) ;
	
        sts = _VD_SEND_MY( Root.disconnect(
                                to_obj, UnwObj.objid, UnwObj.osnum, to_feat ));
	__CheckRC( sts, 1, "Root.disconnect", wrapup ) ;

        sts = _VD_SEND_WRT_M( my_id, ASnode.GRdelete( msg, md_env ));
	__CheckRC( sts, *msg, "ASnode.GRdelete", wrapup ) ;

wrapup:
	End ;
	return sts;
}


method	VLgetUnw_obj(	IGRlong         *msg;
                        struct   GRid   *unw_obj )
{
	IGRint  		sts = OM_S_SUCCESS, count;
	OM_S_CHANSELECT		to_obj;
	GRobjlink		UnwVw;

	SetProc( VLunwFeat_VLgetunw_obj ); Begin
	
	*msg	= MSSUCC ;

        to_obj.type        = OM_e_name;
        to_obj.u_sel.name  = "VLunwFeat.to_obj";

        sts = om$get_channel_objects( objid        = my_id,
                                      p_chanselect = &to_obj,
                                      size         = 1,
                                      list         = &UnwVw,
                                      count        = (OMuint *)&count );

        if( count != 1 ){
                *msg = MSFAIL ;
                goto wrapup ;
        }

        if( unw_obj ){
                unw_obj->objid    = UnwVw.S_objid ;
                unw_obj->osnum    = UnwVw.osnum ;

                __DBGpr_obj(" Owner ", *unw_obj );
        }

	wrapup:
		End ;
		return sts;
}

end implementation VLunwFeat;

