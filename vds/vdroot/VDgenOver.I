/* $Id: VDgenOver.I,v 1.5 2002/06/07 14:44:14 ramarao Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot/VDgenOver.I
 *
 * Description:
 *
 * Dependencies:
 *	$Log: VDgenOver.I,v $
 *	Revision 1.5  2002/06/07 14:44:14  ramarao
 *	Implemented To Do List.
 *	
 *	Revision 1.4  2002/06/03 19:17:18  ramarao
 *	Used a seperate flag for recompute info.
 *	
 *	Revision 1.3  2002/05/22 21:51:15  ramarao
 *	Added a bit of code to debug out the recompute info.
 *	
 *	Revision 1.2  2001/02/22 18:25:01  ad
 *	*** empty log message ***
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      10/3/95		 MSM		Creation
 *      09/26/99	SSR		TR # MP1208
 *	02/22/01	adz		Change the return statements.
 *
 * -------------------------------------------------------------------*/

class implementation VDSroot ;

#include "nd.h"
#include "AS_status.h"

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"
#include "ACdb_info.h"
#include "VDScheckdef.h"
#include "VDobj.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

extern GRclassid        OPP_SMcomp_class_id;

/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *md_env )
{
	IGRlong			status = OM_S_SUCCESS,
				msg;
	struct GRid		MyId;
	struct ACobj_info_1	ObjInfo;
	IGRboolean		is_comp=FALSE;
	GRclassid		ClassId;

	SetProc( VDSroot.NDdelete ); Begin

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

        om$get_classid ( objid = MyId.objid,
                         osnum = MyId.osnum,
                         p_classid = &ClassId );
        if ( om$is_ancestry_valid
                        ( subclassid = ClassId,
                          superclassid = OPP_SMcomp_class_id ) == OM_S_SUCCESS)
	    is_comp = TRUE;

	__DBGpr_obj("My ID :", MyId );

/*	status = VdsGet_db_info( &MyId, &ObjInfo, 1 );
	__DBGpr_int ( "Quantity ", ObjInfo.quantity );
*/

  	status =
  	om$send (     msg      = message ACncpx.NDdelete( md_env ),
                targetid = my_id,
		mode	 = OM_e_wrt_message );
  	as$status();

	status = VDPPmeDelete ( &msg, MyId, is_comp );
	CheckRC ( status, msg );
wrapup:
	End
	return OM_S_SUCCESS;

} /* NDdelete */
/*----------------------------------------------------------------------------*/

method NDupdate( int *msg, cn_type, count;
		 struct GRid *parents;
		 int *parent_state;
		 struct GRid *context,*new_objid;
		 struct GRmd_env *md_env )
{
	IGRlong			status;
	struct GRid		MyId;
	struct GRobj_env        myOE;

	SetProc( VDSroot.NDupdate ); Begin

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	myOE.obj_id  = MyId;
	myOE.mod_env = *md_env;

	if( VDgetCMPtoggle() )
	{
	    printf( "Recomputing (VDS) --- " );
	    vdobj$Print( objID = &MyId );
	}

	*msg = MSSUCC;
	new_objid->objid = NULL_OBJID;
	new_objid->osnum = OM_Gw_current_OS;

  	status =
  	om$send (     msg      = message ACncpx.NDupdate( msg, cn_type, count,
				parents, parent_state, context, new_objid,
				md_env ),
                targetid = my_id,
		mode	 = OM_e_wrt_message );
	if( ! ( status & 1 & (*msg) ) )
	{
	    VDaddToDoList( myOE );
	}
        else
        {
            VDremoveFromToDoList( myOE );
        }
  	as$status();
	__DBGpr_obj ( "new Objid :", *new_objid );

	/*
         * SSR 26 AUG all transactions to be maintained in trans list even if
	 * ISDP is not connected to AIM. TR # MP1208
	 * if( IsPmeEnabled() == TRUE )
	 */
	__DBGpr_obj("Recomputing :", MyId );

	status = VDPPmeUpdate ( msg, MyId, *new_objid );
	CheckRC ( status, *msg );
	*msg = MSSUCC ;
	End
	return OM_S_SUCCESS;
}

method ACcontext_compute_feet(	IGRint 		count;
                        	struct GRid     context_obj;
                        	struct GRid     *feet_list;
                        	struct GRmd_env *md_env)
{
        IGRlong                 status = OM_S_SUCCESS;
        struct GRid             MyId;
        GRclassid               ClassId;

	/*
	 * Only check for the objects of the drawing related classes.
	 * These objects do have flexible list of feets, which can result
	 * in invalid inheritence of symbology of previous occurances.
	 *	 Ad / Rama: 02/11/98
	 */

        MyId.objid = my_id;
        MyId.osnum = OM_Gw_current_OS;

        om$get_classid ( objid = MyId.objid,
                         osnum = MyId.osnum,
                         p_classid = &ClassId );

        if( om$is_ancestry_valid
                        ( subclassid = ClassId,
                          superclassname = "VDdrwGm" ) == OM_S_SUCCESS)

		return ( OM_S_SUCCESS );

	/*
	 * Call the default process.
	 */

        status =
	om$send(msg      = message ACncpx.ACcontext_compute_feet(
						count ,
						context_obj ,
						feet_list ,
						md_env ),
		mode	 = OM_e_wrt_message ,
                targetid = my_id );
 
	return status ;
}

end implementation VDSroot ;
