/* $Id: VDrflconsti.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDrflconsti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrflconsti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation VDrflconst;

#include "AS_status.h"
#include "asbox.h"

method NDcompute_node( IGRlong *msg; IGRint cn_type;
                       IGRint count; struct GRid list [];
                       struct GRmd_env *md_env)
{

 long status,loc_msg;
 struct GRid macro,macro_def,rfl;
 struct GRmd_env fr_env;

 /* Recopy parent */

 *msg = MSFAIL;
 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",&macro,
				&fr_env.md_env.matrix_type,
				fr_env.md_env.matrix),
		  targetid = list[0].objid);
 as$status(action = RET_STATUS);

 fr_env.md_id.objid = NULL_OBJID;
 fr_env.md_id.osnum = macro.osnum;

 /* To make sure real macro id stored */

 status = om$send(msg = message ACcpx.find_macro(&macro_def),
		  targetid = macro.objid,
		  targetos = macro.osnum);
 as$status(action = RET_STATUS);

 status = om$send(  msg     = message NDnode.NDcopy_to_root( &loc_msg,
                                                                0,
                                                                &fr_env,
                                                                md_env,
                                                                &rfl ),
                                        targetid= macro.objid,
                                        targetos= macro.osnum ) ;
 as$status(action = RET_STATUS);


 /* delete old components and take new ones */

 status = om$send(msg = message GRgraphics.GRdelete(&loc_msg,md_env),
		  p_chanselect = &AS_to_comp);
 as$status(action = RET_STATUS);

 status = om$send(msg = message Root.move_chan(AS_to_comp,rfl.objid,rfl.osnum,
					       AS_to_comp),
		  targetid = my_id);
 as$status(action = RET_STATUS);

 status = om$send(msg = message Root.delete(0),
		  targetid = rfl.objid);

 *msg = MSSUCC;
 me->STATE |= ncpx_root;
 return OM_S_SUCCESS;
}

method find_macro(struct GRid *macro)
{
 me->STATE |= ncpx_root;
 return  om$send(msg = message ACncpx.find_macro(macro),
		 targetid = my_id,
		 mode = OM_e_wrt_message);
}


method GRxform(IGRlong *msg; struct GRmd_env *obj_dsenv;
               IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 long status;

 me->STATE &= ~ncpx_root;

 status=om$send(msg= message
                ACncpx.GRxform(msg,obj_dsenv,matrix_type,matrix,newobjid),
                targetid=my_id,
                mode = OM_e_wrt_message);
 me->STATE &= ~ncpx_root;
 return status;
}

end implementation VDrflconst;
