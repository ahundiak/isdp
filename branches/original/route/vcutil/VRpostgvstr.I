/* $Id: VRpostgvstr.I,v 1.2 2001/02/20 01:11:46 build Exp $ */
/*---------------------------------------------------------------------------
 *  I/VDS
 *
 * File:        vrutil/VRpostgvstr.I
 *
 * Description:
 *
 *      This file implements the methods to ACgive_structure a object.
 *
 * Revision History:
 *      $Log: VRpostgvstr.I,v $
 *      Revision 1.2  2001/02/20 01:11:46  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/01/28  20:15:46  pinnacle
# Created: vcutil/VRpostgvstr.I by lawaddel for route
#
 *
 * Dependencies:
 *      VRpost.S
 *
 * History:
 * 01/21/99  law    CR179802489-add new fields for posting
 * -------------------------------------------------------------------------
 */

class implementation VRpost;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACrg_collect.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"

/*+me
 -------------------------------------------------------------------------
  Public Message 
	ACgive_structure

  Abstract
	ACgive_structure the object.

  Status/Return Code
	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-me*/


method	ACgive_structure(	IGRint			*rc;
				IGRint			*direct_ind;
				IGRchar			*foot_name;
				struct ret_struct	*str; 
				struct GRmd_env		*md_env )
{
	IGRlong 		status;
	struct	GRid		myGRid;
        struct  GRid  		MyTemp0;
        IGRint NbTemp;

	SetProc( VRpost_ACgive_structure ); Begin

	myGRid.objid	= my_id;
	myGRid.osnum	= OM_Gw_current_OS;

        __DBGpr_obj("VRpost obj id",myGRid);
        __DBGpr_str("footname",foot_name);

        status =
	om$send(msg = message ACrg_collect.ACgive_structure (
						rc,
						direct_ind,
						foot_name,
						str,
						md_env ),
		targetid = myGRid.objid,
                targetos = myGRid.osnum,
		mode = OM_e_wrt_message );

#ifdef	vdsDEBUG
        if(str->type != text_type)
           __DBGpr_dbl("value is ",str->var.root_pm_st.value);
        else
           __DBGpr_str("text is ",str->var.text_st.text_string);
#endif

	End
	return	status;	
}

/*----------------------------------------------------------------------------*/
method VRGetCompSeqNo(IGRlong *msg;
                       struct GRid *CompSeqNo)
{
	SetProc( VRGetCompSeqNo ); Begin

	CompSeqNo->objid = me->CompSeq_no.objid ;
	CompSeqNo->osnum = me->CompSeq_no.osnum ;
	*msg = MSSUCC ;

	End
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method VRSetCompSeqNo(IGRlong *msg;
                       struct GRid CompSeqNo)
{
	SetProc( VRSetCompSeqNo ); Begin
	me->CompSeq_no.objid = CompSeqNo.objid ;
	me->CompSeq_no.osnum = CompSeqNo.osnum ;
        __DBGpr_obj("Setting CompSeqNo instance",me->CompSeq_no);
	*msg = MSSUCC ;

	End
	return OM_S_SUCCESS ;
}

end implementation VRpost;

