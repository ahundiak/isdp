/* $Id: VDgrcontext.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp/VDgrcontexti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgrcontext.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/03/23  16:19:12  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by impd for vds
#
# Revision 1.6  1998/03/19  20:24:22  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by yzhu for vds
#
# Revision 1.5  1998/03/18  23:29:26  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by impd for vds
#
# Revision 1.4  1998/03/02  20:42:36  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by yzhu for vds
#
# Revision 1.3  1997/12/09  22:15:28  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by impd for vds
#
# Revision 1.2  1997/12/09  21:51:54  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/05/06  16:10:00  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by azuurhou for vds.240
#
# Revision 1.3  1996/04/22  09:16:48  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by rgade for vds.240
#
# Revision 1.2  1996/04/21  16:25:34  pinnacle
# Replaced: vddrawing/imp/VDgrcontext.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/03/19  21:57:44  pinnacle
# Created: vddrawing/imp/VDgrcontext.I by azuurhou r#
# rno
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/18/95	adz		New
 *	04/20/96	ravi		Integration in code.
 *	03/18/98	adz/yzhu	Initialization of Xform global
 *
 * -------------------------------------------------------------------*/

class implementation VDcontext;

#include <stdio.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "madef.h"		/* MAIDMX */
#include "refdef.h"		/* REFERENCE_INSTANCE_DATA */
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "v_dbgmacros.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "vddrwattr.h"
#include "gocmacros.h"
#include "VDmem.h"

from	GRreffile	import	GRinquireref;
from	GRgraphics	import	GRgetrang;
from	GRvg		import  GRputattr;
from	GRlistener	import	GRnotifylis;


extern	int		VDchk_child_on_class();
extern	int		VDdrw_GetChannelOwner();

%safe
IGRboolean    VDS_K_RecomputeDrawing  = FALSE ;
IGRboolean    VDS_K_RecomputeDrawingM = FALSE ;
%endsafe


/*****************************************************************************/
void	VDctx_SetRecomputeDrawingFlag( int flag )
{
	VDS_K_RecomputeDrawing = (flag ) ? TRUE : FALSE ;
	__DBGpr_int(" RecomputeDrawingFlag ", VDS_K_RecomputeDrawing );
}

/*****************************************************************************
 * The context inside the VDcontext instance needs to be updated after
 * a move of the object.
 */
VD_ctxUpdateLbSys( msg, ctx, lbsys )

long			*msg ;
struct	GRid		*ctx ;
struct	IGRlbsys	*lbsys ;
{
	int			sts = OM_S_SUCCESS ;
	struct	GRmd_env	ctxEnv ;	/* Context environment    */
	struct	GRid		ref ,		/* reference file object. */
				tmpCtx ;	/* Temporarty context     */
	IGRshort		mx_type ;
	IGRdouble		matrix[16],
				origin[3];
	GRrange			range;
	IGRboolean		world;

	SetProc( VD_ctxUpdateLbSys ); Begin

	*msg = MSSUCC ;

	ref.objid = NULL_OBJID ;

	sts =
	om$send(msg = message GRcontext.GRgetmodule_env( msg, &ctxEnv ),
		targetid = ctx->objid,
		targetos = ctx->osnum,
		senderid = NULL_OBJID );

	if( !(sts&*msg&1)){
		*msg = MSFAIL ;
		goto wrapup ;
	}

	/*
	 * find reference object.
	 */
	sts = VDdrw_findmtxctx( msg, ctxEnv.md_env.matrix, &ref, &tmpCtx );

	if( ref.objid == NULL_OBJID ){
		*msg = MSFAIL ;
		goto wrapup ;
	}

	/*
	 * reference file origin
	 */
	{
		struct GRref_instance_data	rfi;
		struct GRinquire_list		inq[2];
		struct GRmd_env			dummyEnv ;
		IGRboolean			pass = FALSE;
		IGRint				sts1;
 
		inq[0].var		= REFERENCE_INSTANCE_DATA ;
		inq[0].num_requested	= sizeof(rfi) ;
		inq[0].var_ptr		= (char *) &rfi ;
		inq[1].var		= END_REPORT_REQUEST ;

		MAidmx( msg, dummyEnv.md_env.matrix );
		dummyEnv.md_env.matrix_type = MAIDMX ;
		dummyEnv.md_id.objid = NULL_OBJID ;

		sts =
		om$send(msg = message GRreffile.GRinquireref(
					msg,
					&dummyEnv,
					inq,
					&sts1,
					&pass,
					(struct GRinfo_processor *)NULL ),
			senderid = NULL_OBJID,
			targetid = ref.objid,
			targetos = ref.osnum);

		if( !(sts&*msg&1)){
			*msg = MSFAIL ;
			goto wrapup ;
		}

		__DBGpr_mat( "Ref_To_Master ", rfi.ref_to_master_matrix );
		__DBGpr_vec( "Ref_To_Origin ", rfi.vw_origin );

		origin[0] = rfi.ref_to_master_matrix[0] * rfi.vw_origin[0] +
			    rfi.ref_to_master_matrix[1] * rfi.vw_origin[1] +
			    rfi.ref_to_master_matrix[2] * rfi.vw_origin[2] +
			    rfi.ref_to_master_matrix[3] ;

		origin[1] = rfi.ref_to_master_matrix[4] * rfi.vw_origin[0] +
               	            rfi.ref_to_master_matrix[5] * rfi.vw_origin[1] +
               	            rfi.ref_to_master_matrix[6] * rfi.vw_origin[2] +
              	            rfi.ref_to_master_matrix[7] ;

		origin[2] = rfi.ref_to_master_matrix[8]  * rfi.vw_origin[0] +
                            rfi.ref_to_master_matrix[9]  * rfi.vw_origin[1] +
                            rfi.ref_to_master_matrix[10] * rfi.vw_origin[2] +
                            rfi.ref_to_master_matrix[11] ;
	}

	__DBGpr_vec("Origin", origin );
		  
	/*
	 * get the range of the reference atachement.
	 */
	world = FALSE;
	MAidmx( msg, matrix );
	mx_type = MAIDMX ;
	sts =
	om$send(msg = message GRgraphics.GRgetrang(
					msg,&mx_type,matrix,&world,range),
		senderid = NULL_OBJID,
		targetid = ref.objid,
		targetos = ref.osnum);
	if( !(sts&*msg)){
		*msg = MSFAIL ;
		goto wrapup ;
	}

	__DBGpr_vec("Range_min", range );
	__DBGpr_vec("Range_max", range +3 );

	MAidmx( msg, lbsys->matrix );
	lbsys->diag_pt1[0] = range[0] - origin[0];
	lbsys->diag_pt1[1] = range[1] - origin[1];
	lbsys->diag_pt1[2] = range[2] - origin[2];

	lbsys->diag_pt2[0] = range[3] - origin[0];
	lbsys->diag_pt2[1] = range[4] - origin[1];
	lbsys->diag_pt2[2] = range[5] - origin[2];

	__DBGpr_vec(" diag_pt1 ", lbsys->diag_pt1 );
	__DBGpr_vec(" diag_pt2 ", lbsys->diag_pt2 );

	lbsys->matrix[3]  = origin[0];
	lbsys->matrix[7]  = origin[1];
	lbsys->matrix[11] = origin[2];

wrapup:
	End
	return sts ;
}

/* This function updates the lbsys of VDdrw2dVw objects */

VDdrwVw_UpdateCtx( msg, ctxId, ctxLbs )

IGRlong			*msg;		/* O - OUTPUT STATUS */
struct GRid		*ctxId;		/* I - INPUT */
struct IGRlbsys 	*ctxLbs;	/* I - INPUT */
{

	int               	sts = OM_S_SUCCESS ,
				i,
				count = 0 ;
	OM_S_CHANSELECT   	to_misc;
	OM_S_OBJECT_LINKAGE	*Objlist=NULL;
	IGRboolean	  	drw2dExist = FALSE;
	struct GRid	  	drw2dId,
				drwVwId,
				parent,
				source;
	VDpartAttr        	attr;

	SetProc( VDdrw_UpdateCtx ); Begin

        *msg = MSSUCC ;

	/*
	 * Get the objects from "misc" channel
	 */

	sts =
	om$make_chanselect(	channame	= "GRcontext.to_misc",
                                p_chanselect	= &to_misc );
	sts =
	om$get_channel_count(	osnum		= ctxId->osnum,
                                objid		= ctxId->objid,
                                p_chanselect	= &to_misc,
                                count		= (OMuint *) &count ) ;

	if ( count )
		Objlist = _MALLOC( count, OM_S_OBJECT_LINKAGE );
	if( Objlist == NULL ) {
		goto wrapup ;
	}

	sts =
	om$get_channel_objects(	osnum         = ctxId->osnum,
                                objid         = ctxId->objid,
                                p_chanselect  = &to_misc,
                                list          = Objlist,
                                size          = count,
                                count         = (OMuint *) &count );

	__DBGpr_int(" Count ", count );

	if( ! count ) goto wrapup ;

	for( i=0; i<count ; i++ ){

		drw2dId.objid	= NULL_OBJID;
		parent.objid	= NULL_OBJID;
		source.objid	= Objlist[i].S_objid;
		source.osnum	= Objlist[i].osnum;

		sts =
        	VDchk_child_on_class(   msg, &parent, &source,
                                	"VDdrw2d", &drw2dId );

		drw2dExist = ( drw2dId.objid == NULL_OBJID ) ? FALSE : TRUE ;

		if ( drw2dExist )  break;

	}

	/*
	 * Found a valid child occurance.
	 */
	if( drw2dExist ){

		/*
		 * Get the channel connection between drw2d & drw2dVw.
		 */
		__DBGpr_obj(" drw2d ", drw2dId );

		sts =
        	VDdrw_GetChannelOwner( msg, &drw2dId, VD_O_drw2d, &drwVwId );

		attr.Iwant = VD_I_drwProjLbs;
		attr.specific = ctxLbs;

		sts =
		om$send(msg = message GRvg.GRputattr( msg, (char *)&attr ),
			senderid = NULL_OBJID,
			targetid = drwVwId.objid,
			targetos = drwVwId.osnum ); 
	}

wrapup:

	_FREE( Objlist );
  
	End
	return sts;
}
 
method  GRupdatectx( IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix )
{
	int			sts = OM_S_SUCCESS ;
	struct	GRid		myId ;
	struct	IGRlbsys	lbsys ;
        long			OMmsg,
				mask = GR_GEOM_XFORMED;
	OM_S_CHANSELECT         chan;

	SetProc( GRupdatectx ); Begin

	__DBGpr_int("Osnum", me->osnum );
	__DBGpr_vec(" Before Pt1 ", me->lbs.diag_pt1 );
	__DBGpr_vec(" Before Pt2 ", me->lbs.diag_pt2 );

	/*
	 * Change the instance Lbsys values for the new situation.
	 */
	myId.objid	= my_id ;
	myId.osnum	= OM_Gw_current_OS ;

	sts = VD_ctxUpdateLbSys( msg, &myId, &lbsys );
	if( sts&*msg&1 ){
		/*
		 * Update the instance.
		 */
		__DBGpr_com(" Range lbsys is updated." );
		me->lbs = lbsys ;

		/*
		 * Update the lbsys of VDdrw2dVw object
		 */
        	sts = VDdrwVw_UpdateCtx( msg, &myId, &lbsys );  
	}

	__DBGpr_vec(" After Pt1 ", me->lbs.diag_pt1 );
	__DBGpr_vec(" After Pt2 ", me->lbs.diag_pt2 );

	sts = 
	om$send(msg  = message GRcontext.GRupdatectx( msg, mx_type, matrix ),
		mode = OM_e_wrt_message,
		targetid = my_id );

	__DBGpr_int( "VDS_K_RecomputeDrawing", VDS_K_RecomputeDrawing );
	if( VDS_K_RecomputeDrawing ){

		__DBGpr_com(" Update the MISC Channel ");

		OMmsg =
		om$make_chanselect(
				channame = "GRcontext.to_misc",
                                p_chanselect = &chan );

		sts =
		om$send(msg = message GRlistener.GRnotifylis(
					msg,&OMmsg,&mask,NULL),
			p_chanselect = &chan );
        
		sts =
		om$send(msg = message GRcontext.GRnotifymisc ( msg ),
			mode = OM_e_wrt_message,
                	targetid = my_id );
	}

	End
	return sts;
}

end implementation VDcontext;
