/* $Id: VDdrw2di.I,v 1.5 2002/02/26 16:20:13 ahundiak Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw2di.I
 *
 * Description:
 *
 *      This file implements the methods for the 2d representation of an
 *	3d-model object.
 *
 * Dependencies:
 *	VDdrw2d.S
 *
 * History:
 * 11/28/94  	adz  	Creation Date.
 * 03/27/95  	adz  	Modification for instance.
 * 08/22/95  	adz  	Remove level checking.
 * 03/24/98  	adz  	TR179800825 Call Drawingview Range.
 * 03/29/98  	ah   	TR179800825 MoveVDdrw_getDrawing_Lbs from vddrawing/cmd 
 *                      to correct unresolved symbols
 * 02/27/00  	adz  	TR179900701 check for active child.
 * 07/27/00     Jayadev add occurence and design_file attributes 
 *			to parent ACrg_collector
 * 10/30/00     Jayadev function VDaddAttr has been changed to take ACrg_coll
 *                      structure as input 
 * 09/04/01     Adz     MP5572. The VDdrw_getDrawing_Lbs had invalid return status
 * -------------------------------------------------------------------------
 */

class implementation VDdrw2d;

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
#include "ACattrib.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ACrg_collect.h"
#include "ref.h"
#include "refdef.h"
#include "vds.h"
#include "vddrwattr.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDmsg.h"

#include "v_vecmxproto.h"
/*
#define vdsDEBUG        1
#define vdserrDEBUG     1

#include "v_dbgmacros.h"

#define DEBUG 1
*/
extern	GRclassid	OPP_VDdrwGm_class_id,
			OPP_GRowner_class_id,
			OPP_VDcontext_class_id, 
			OPP_GRcompcurve_class_id ;

from	VDcontext	import	VDget_extract_info;
from	GRcontext	import	GRgetmodule_env;
from	expression	import	modify;

from GRreffile import GRinquireref;

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
	myDef->info		= VD_I_ObjDrw2d ;
	myDef->type		= VD_O_drw2dObj ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */

/*----------------------------------------------------------------------------*/
#argsused
static long VDdrw2d_drwACncpx_NDdrawing_copy_geom(construction,
						drw2dView,
						visualFile,
						selected_elements,
						nb_elements,
						outList,
						outCount,
						vector,
						point,
						levelMask,
						lbsys,
						from_env,
						to_env,
						drwId )

struct GRid     *construction ;
char            *drw2dView ;
char            *visualFile ;
struct GRid     *selected_elements ;
int              nb_elements ;
struct GRid    **outList ;
int             *outCount ;
IGRdouble       *vector, *point ;
int             *levelMask ;
struct IGRlbsys *lbsys ;
struct GRmd_env *from_env, *to_env ;
struct GRid     *drwId;
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

	SetProc( VDdrw2d_drwACncpx_NDdrawing_copy_geom ); Begin

	__DBGpr_obj( "MY_ID", *construction );

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
				drwPlane	= &drawingPlane,
				viewPlane	= &viewPlane,
				viewVector	= viewVector,
				drwEnv		= to_env,
				drwLbsys	= lbsys,
				selCount	= nb_elements,
				selList		= selected_elements,
				filename	= fl_Name,
				set_name	= st_Name,
				appData  	= (void *) drwId,
				output		= &output);

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

	End
	return OM_S_SUCCESS ;

} /* VDdrw2d_drwACncpx_NDdrawing_copy_geom */

/* ----------------------------------------------------------------------
 * This function will get the range of the drawing view, based on context
 * object.
 *
 * Moved from vddrawing/cmd/VDm_drawingi.I
 */

VDdrw_getDrawing_Lbs(	context, md_env, lbs )

struct	GRid		*context ;
struct	GRmd_env	*md_env ;
struct	IGRlbsys	*lbs ;

{
	IGRlong				status = OM_S_SUCCESS ;
	struct	GRref_instance_data	rfi;
	struct	GRinquire_list		inq[2];
	struct	GRmd_env		con_env ;
	struct	GRid			my_context,
					refId ;
	IGRboolean			pass = FALSE,
					world = FALSE ;
	IGRlong				msg;
	IGRint				msg1;
	IGRshort			mx_type = MAIDMX;
	IGRdouble			matrix[16],
					origin[3];
	GRrange				range;

	SetProc( VDdrw_getDrawing_Lbs ); Begin

	refId.objid = NULL_OBJID ;

	status =
	om$send(msg = message GRcontext.GRgetmodule_env( &msg, &con_env ),
                targetid = context->objid,
                targetos = context->osnum,
                senderid = NULL_OBJID );

	if( 1 & status & msg ){

		status =
		VDfindmtxctx( &msg, con_env.md_env.matrix,
                              &refId, &my_context );
	}
	if( refId.objid == NULL_OBJID ) {
		__DBGpr_com(" Can't find Reference File ");
		status = OM_E_ABORT ;
		goto wrapup ;
	}

	/*
	 * reference file origin
	 */

	inq[0].var = REFERENCE_INSTANCE_DATA;
	inq[0].num_requested = sizeof(rfi);
	inq[0].var_ptr = (char *) &rfi;
	inq[1].var = END_REPORT_REQUEST;

	status =
	om$send(msg = message GRreffile.GRinquireref(&msg,md_env,inq,&msg1,
						       &pass,NULL),
		senderid = NULL_OBJID,
		targetid = refId.objid,
		targetos = refId.osnum);
	if( !(status & msg & 1 )){
		__DBGpr_com(" Can't inquire Reference File ");
		status = OM_E_ABORT ;
		goto wrapup ;
	}

	origin[0] =
		rfi.ref_to_master_matrix[0] * rfi.vw_origin[0] +
                rfi.ref_to_master_matrix[1] * rfi.vw_origin[1] +
                rfi.ref_to_master_matrix[2] * rfi.vw_origin[2] +
                rfi.ref_to_master_matrix[3] ;

	origin[1] =
		rfi.ref_to_master_matrix[4] * rfi.vw_origin[0] +
                rfi.ref_to_master_matrix[5] * rfi.vw_origin[1] +
                rfi.ref_to_master_matrix[6] * rfi.vw_origin[2] +
                rfi.ref_to_master_matrix[7] ;

	origin[2] =
		rfi.ref_to_master_matrix[8]  * rfi.vw_origin[0] +
                rfi.ref_to_master_matrix[9]  * rfi.vw_origin[1] +
                rfi.ref_to_master_matrix[10] * rfi.vw_origin[2] +
                rfi.ref_to_master_matrix[11] ;
		  
	status =
	om$send(msg = message GRgraphics.GRgetrang(&msg,&mx_type,
							matrix,&world,range),
		senderid = NULL_OBJID,
		targetid = refId.objid,
		targetos = refId.osnum);
	if( !(status & msg & 1 )){
		__DBGpr_com(" Can't find range of Reference File ");
		status = OM_E_ABORT ;
		goto wrapup ;
	}

	MAidmx(&msg,lbs->matrix);
	lbs->diag_pt1[0] = range[0] - origin[0];
	lbs->diag_pt1[1] = range[1] - origin[1];
	lbs->diag_pt1[2] = range[2] - origin[2];
	lbs->diag_pt2[0] = range[3] - origin[0];
	lbs->diag_pt2[1] = range[4] - origin[1];
	lbs->diag_pt2[2] = range[5] - origin[2];
	lbs->matrix[3]  = origin[0];
	lbs->matrix[7]  = origin[1];
	lbs->matrix[11] = origin[2];

	status = OM_S_SUCCESS ;

wrapup:
	End
	return (status & 1) ;
}

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
	 *	- Context object.
	 */

	IGRint			sts = OM_S_SUCCESS ;
	IGRlong			status = OM_S_SUCCESS ;
	struct GRid		modObj,			/* 3d object	*/
				ctxObj,			/* context obj	*/
				myGRid,			/* i		*/
				drwVwId,		/* VDdrw2dVw    */
				gmId,			/* gm object	*/
				gmMacDef,		/* gm macro def	*/
				*gmList = NULL,		/* list of 2d 	*/
				*rfList = NULL;		/* list of dep	*/
	IGRint			gmCount,		/* Nb gm objs	*/
				gmMax,			/* Nb ind geom  */
				rfCount,		/* Nb of dep	*/
				i,index,
				gm,
				attr_type,
				modLevel[32];		/* dgn levels	*/
	struct	IGRlbsys	ctxLbs,
				refLbs ;
	IGRdouble		drwPnt[3],
				drwVec[3],
				p1[15];
	struct	IGRrt_prism	ctxPrism;
	GRname			gmMacro,
				visualFile,
				drw2dView ;
	struct		GRmd_env	modEnv ;
	struct 		GRobj_env    objEnv, chdEnv;
	VDpartAttr		attr ;
	VDdrw2dVwInfo		vwInfo ;
	GRname			occ_name, design_name, attr_name;
 	IGRchar			*syntax;
	struct ACrg_coll        attribute;

	SetProc( VDdrw2d_ACconstruct_feet ); Begin
 
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

	__DBGpr_mat("(1)modEnv.md_env.matrix ", modEnv.md_env.matrix );

	modEnv._MD_OS = modObj.osnum;
	sts = ex$get_modid(	mod_osnum = modEnv._MD_OS,
				mod_id	  = &modEnv._MD_ID );

	/*
	 * Check if object is consumed (get active child).
	 */
	objEnv.obj_id  = modObj ;
	objEnv.mod_env = modEnv ;
	VDatGetConsumingChild( &objEnv, &chdEnv );
	__DBGpr_obj(" ModelObj", objEnv.obj_id );
	__DBGpr_obj(" ChildObj", chdEnv.obj_id );
	modObj = objEnv.obj_id ;
	modEnv = objEnv.mod_env ;

	__DBGpr_mat("(2)modEnv.md_env.matrix ", modEnv.md_env.matrix );

	/*
	 * The reference object is a parent object connect through
	 * generated "make_source" of the 3d-model object and the Context.
	 */
	sts =
	VDdrw_GetChannelOwner(  msg, &myGRid, VD_O_drw2d, &drwVwId );
	__CheckRC( sts, *msg, "VDdrw_GetChannelOwner", wrapup );

	VDdrw_Init2dVwInfo( msg, &vwInfo );

	vwInfo.intName	= drw2dView ;
	vwInfo.prjVec	= drwVec ;
	vwInfo.prjPnt	= drwPnt ;
	vwInfo.objLev	= modLevel ;
	vwInfo.drwLbsys	= &ctxLbs ;

	/*
	 * Check the visualization support file.
	 */
	attr.Iwant = VD_I_drwChkStsMask ;
        attr.aType = VD_B_drwTransParent ;
	sts = _VD_SEND_MY( GRvg.GRgetattr( msg, (char *)&attr ));
        if( !(sts&*msg&1)){	vwInfo.visFile	= visualFile ; }
	else{			vwInfo.trsFile	= visualFile ; } 

	attr.Iwant = VD_I_drwProjAllInfo ;
	attr.specific = (void *) &vwInfo ;
	sts = _VD_SEND_OBJ( drwVwId, GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

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

	  __DBGpr_com(" CONTEXT LBsys ");
	  __DBGpr_vec(" diag_pt1 ", ctxLbs.diag_pt1 );
	  __DBGpr_vec(" diag_pt2 ", ctxLbs.diag_pt2 );
	  __DBGpr_mat(" OriginMtx", ctxLbs.matrix );

	  if( VDdrw_getDrawing_Lbs(   &ctxObj, md_env, &refLbs )){

		ctxLbs = refLbs ;
	  	__DBGpr_com(" REFERENCE LBsys ");
		__DBGpr_vec(" diag_pt1 ", ctxLbs.diag_pt1 );
		__DBGpr_vec(" diag_pt2 ", ctxLbs.diag_pt2 );
		__DBGpr_mat(" OriginMtx", ctxLbs.matrix );
	  }
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

        sts = VDdrwUpdateAttrCollector( msg, &myGRid, &objEnv, visualFile );
        __CheckRC( sts, *msg, "VDdrwUpdateAttrCollector", wrapup );

	/*
	 * give the current object within the drawing extraction to
	 * information concerning object specific treatments.
	 */
	gmList	= NULL ;
	gmCount = 0 ;

	sts =
	VDdrw2d_drwACncpx_NDdrawing_copy_geom(	&modObj,
						drw2dView,	/* Set of   */
						visualFile,	/* filename */
						rfList,		/* reference */
						rfCount,
						&gmList,
						&gmCount,
						drwVec,
						drwPnt,
						modLevel,
						&ctxLbs,
						&modEnv,
						md_env ,
						&myGRid);

	rfList = NULL ;

	/*
	 * get the geometry objects from the macro.
	 *	- geom : Extract geometry information.
	 *
	 * delete the previous occurence of the geometry collectors.
	 */
#if 0 /* commented during TR:179702015 ( activally this for VDdrw3d object) */
	sts =
	_VD_SEND_MY( NDmacro.ACreturn_foot( msg, "geom", &gmId, NULL, NULL ));
	if( gmId.objid != NULL_OBJID ){
            sts =
            _VD_SEND_OBJN( gmId, GRconnector.GRdisconn( msg, &myGRid ));
	    __CheckRC( sts, *msg, "GRconnector.GRdisconn", wrapup );

	    sts =
	    _VD_SEND_OBJN( gmId, GRgraphics.GRdelete( msg, md_env ));
	    CheckRC( sts, *msg );
	    gmId.objid = NULL_OBJID ;
	}
#endif

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

	sts =
	_VD_SEND_OBJ(	gmId,
			NDnode.NDmove_to_root(msg, &gmId, md_env));
	CheckRC( sts, *msg );

	/* 
	 * Modif to make it working when the drawing plane in not on z = 0.
	 * Just set the height of the ctxPrism to the correct value.
	 * 04/27/93, AD, CH.
	 * ctxPrism.height = 2;
	 */

	/*
	 *  Jean 10/14/93
	 * We look if the object is in a ctxPrism of height 2 (here I take the
	 * first hard code value of jla but I'm not sure it's really good to
	 * hard code this value.). The z value of this ctxPrism is object -1
	 * In any case the z coordinate of the ctxPrism has not to be at z = -1
	 * which exclude case where drawing view is not at z = 0.
	 * The solution in 2.1 which was ctxPrism was z = -1 
	 * ctxLbs.matrix[11] + 2 was not good. What if z < 0 ?
	 */    

	if( gmCount ){

	  /*
	   * Jean 10/14/93
	   * (04/27/93 was ctxLbs.matrix[11] + 2;)
	   */ 
	  ctxPrism.height = 2;

	  /*
	   * Jean 10/14/93
	   * (04/27/93 was ctxLbs.matrix[11] = -1;)
	   */
	  ctxLbs.matrix[11] -= 1;

	  for( gm=0 ; gm<16 ;gm++ ) ctxPrism.matrix[gm] = ctxLbs.matrix[gm];

	  p1[0] = ctxLbs.diag_pt1[0];
	  p1[1] = ctxLbs.diag_pt1[1];
	  p1[2] = 0;
  
	  p1[3] = ctxLbs.diag_pt2[0];
	  p1[4] = ctxLbs.diag_pt1[1];
	  p1[5] = 0;
 
	  p1[6] = ctxLbs.diag_pt2[0];
	  p1[7] = ctxLbs.diag_pt2[1];
	  p1[8] = 0;

	  p1[9] = ctxLbs.diag_pt1[0];
	  p1[10]= ctxLbs.diag_pt2[1];
	  p1[11]= 0;

	  p1[12]= ctxLbs.diag_pt1[0];
	  p1[13]= ctxLbs.diag_pt1[1];
	  p1[14]= 0;

	  ctxPrism.polygon.num_points = 5;
	  ctxPrism.polygon.points = p1;
  
	  for( gm=0 ; gm<gmCount ; gm++ ){
		VDdrw2d_clipping_geom(	gmList +gm,
					&gmId,
					(char *)&ctxPrism,
					md_env );
	  }
	} /* if( gmCount ) */

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
		CheckRC( sts, *msg );

	    } /* indexes in one geom type */

	} /* for all geom objects */

	sts =
	_VD_SEND_OBJ(	gmId,
			NDnode.NDmove_to_root( msg, &gmId,md_env));
	CheckRC( sts, *msg );

	/* Attach the occurence attribute to the parent ACrg_collector */

/*      The following code has been commented ****************************
 *      This part of code not update w.r.t changes in VDaddAttr function
 *
 *
   	occ_name[0] = '\0';
   	status = om$send(msg = message GRvg.GRgetname (msg,occ_name),
                    	senderid = NULL_OBJID,
                    	targetid = modObj.objid,
                    	targetos = modObj.osnum);
	if(!(status & *msg &1)) __DBGpr_obj("GRvg.GRgetname failed",modObj);

        if((status&*msg&1) && occ_name[0] != '\0')
        {
         	syntax = strrchr(occ_name,':');
         	if(syntax) syntax++;
         	else syntax = occ_name;
        }
                __DBGpr_str(" occurence ", occ_name );
                __DBGpr_str(" syntax ", syntax );
	if(syntax && syntax[0] != '\0'){
		strcpy(attr_name,"occurence");
		attr_type = AC_ATTRIB_TEXT; 
		sts = VDaddAttr(myGRid,attr_name,syntax,attr_type,0,0);
		if(!(sts&1)) __DBGpr_obj("Failed adding occurence",myGRid);
	}
        VDget_design_name(modObj.osnum,design_name,md_env);
        syntax = design_name;
                __DBGpr_str(" design_name ", design_name );
	if(syntax && syntax[0] != '\0'){
		strcpy(attr_name,"design_file");
		attr_type = AC_ATTRIB_TEXT; 
		sts = VDaddAttr(myGRid,attr_name,syntax,attr_type,0,0);
		if(!(sts&1)) __DBGpr_obj("Failed adding occurence",myGRid);
	}
 *
 *
 *******The above code has been commented ****************************/

   	occ_name[0] = '\0';
	sts = VDgetOccName(modObj,occ_name);
	if(!(sts&1)) __DBGpr_obj("failed VDgetOccName for",modObj);
                __DBGpr_str(" occurence ", occ_name );

        if((sts&1) && occ_name[0] != '\0')
	{
                strcpy(attribute.name,"occurence");
                attribute.desc.type = AC_ATTRIB_TEXT;
                strcpy(attribute.desc.value.att_txt,occ_name);
		sts = VDaddAttr(myGRid,attribute,0,0);
		if(!(sts&1)) __DBGpr_obj("Failed adding occurence",myGRid);
	}
	

	/*
	 * connect the components with geometry and
	 * create the drawing part
	 */
	*fcount = 1 ;
	feet_list[0] = gmId;
	sts =
	_VD_SEND_OBJ(	gmId, GRconnector.GRdisconn( msg, &myGRid ));

	*msg = MSSUCC;
	sts  = OM_S_SUCCESS ;
 
	wrapup:

		_FREE( gmList );
		End ;
		return sts ;;
}

end implementation VDdrw2d;

