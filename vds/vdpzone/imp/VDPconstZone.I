class implementation VDPRoot;

/*+fe

    Function VDPconstructZoneObject()

    Abstract
	This function constructs a Zone Object given it's parents and Context
	info.

    Arguments

    Notes

    Return Status

-fe*/

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "parametric.h"
#include "godef.h"
#include "go.h"

#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asbox.h"
#include "asmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDPdef.h"
#include "VDPzone.h"

from   GRgraphics  import	GRconstruct;
from   NDnode  	   import	NDconnect;
from   VDPZoneObj  import	VDPSetInstance;


IGRint	VDPconstructZoneObject(	long		*msg,	      /*  O  */
				struct GRid	*gr_obj,      /*  I  */
				struct GRmd_env	*gr_env,      /*  I  */
				struct VDPzone	*ZoneInfo )   /* I/O */
{
    IGRlong			status = OM_S_SUCCESS;
    IGRint			numberOfBytes = 0,
				BytesReceived = 0;
    struct GRas			assoc_lis;
    struct GRvg_construct	cnst_list;
    struct GRid			src_obj, ctx_id, ZoneListId,
				ZoneObj;
    struct GRmd_env		mod_env;
 

    SetProc ( VDPconstructZoneObject ); Begin

    *msg = MSSUCC;

    status = VDPGetZoneListId( msg, &ZoneListId );
    CheckRC (status, *msg );

    numberOfBytes = sizeof ( struct GRmd_env );
    gr$get_module_env  (   msg     = msg,
                           sizbuf  = &numberOfBytes,
                           buffer  = &mod_env,
                           nret    = &BytesReceived );

    cnst_list.msg      = msg;
    cnst_list.env_info = &mod_env;
    cnst_list.geometry = NULL;
    cnst_list.newflag  = FALSE;
/*  cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE; */
    cnst_list.class_attr = ( IGRchar *) &assoc_lis;
    cnst_list.name       = NULL;


    status = as$make_source (   go_grid  =   *gr_obj,
				mod_env  =   gr_env,
				as_os    =   mod_env.md_id.osnum,
				as_grid  =   &src_obj );

    __DBGpr_obj("src_obj", src_obj );

    status = GRfindcontext (    msg,
				&(gr_env->md_env.matrix_type),
				gr_env->md_env.matrix,
				&(gr_obj->osnum),
				&ctx_id );

    if( !(status & *msg & 1) ) ctx_id.objid = NULL_OBJID;

    assoc_lis.num_parents = 1;
    assoc_lis.parents  = &src_obj;
    assoc_lis.context  = &ctx_id;
    assoc_lis.go_attr  = NULL;
    assoc_lis.as_attr  = NULL;

    ZoneObj.osnum = mod_env.md_id.osnum;
    status = om$construct ( osnum = ZoneObj.osnum,
			classid = OPP_VDPZoneObj_class_id,
			p_objid = &ZoneObj.objid,
			msg = message GRgraphics.GRconstruct ( &cnst_list ) );
    __CheckRC ( status, 1, "om$construct ", wrapup );

    ZoneInfo->ZoneId = ZoneObj;

    status = _VD_SEND_OBJN ( ZoneObj, VDPZoneObj.VDPSetInstance ( msg, *ZoneInfo ));
    CheckRC ( status, *msg );

wrapup :
    End
    return status;
}


IGRint	VDPconnectZonetoGRobj(	long		*msg,	      /*  O  */
				struct GRid	*gr_obj,      /*  I  */
				struct GRmd_env	*gr_env,      /*  I  */
				struct VDPzone	ZoneInfo )   /* I/O */
{
    IGRlong			status = OM_S_SUCCESS;
    IGRint			numberOfBytes = 0,
				BytesReceived = 0;
    struct GRid			src_obj,ZoneId;
    struct GRmd_env		mod_env;

    SetProc( VDPconnectZonetoGRobj ); Begin

    numberOfBytes = sizeof ( struct GRmd_env );
    gr$get_module_env  (   msg     = msg,
                           sizbuf  = &numberOfBytes,
                           buffer  = &mod_env,
                           nret    = &BytesReceived );

    status = as$make_source (   go_grid  =   *gr_obj,
				mod_env  =   gr_env,
				as_os    =   mod_env.md_id.osnum,
				as_grid  =   &src_obj );

    __DBGpr_obj("src_obj", src_obj );

    ZoneId = ZoneInfo.ZoneId;
    status =
    _VD_SEND_OBJN ( ZoneId, NDnode.NDconnect( 1, &src_obj, NULL_GRID, ND_ADD ));
    CheckRC (status, 1);

    End
    return OM_S_SUCCESS;
}

end implementation VDPRoot;
