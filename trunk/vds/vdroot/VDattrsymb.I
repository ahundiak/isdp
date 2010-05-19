/* $Id: VDattrsymb.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDattrsymb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDattrsymb.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/06/05  11:53:02  pinnacle
# TR179801119
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/03/14  20:13:10  pinnacle
# Replaced: vdroot/VDattrsymb.I for:  by kddinov for vds
#
# Revision 1.4  1998/03/12  17:56:38  pinnacle
# Replaced: vdroot/VDattrsymb.I for:  by kddinov for vds
#
# Revision 1.3  1998/03/11  17:23:38  pinnacle
# Replaced: vdroot/VDattrsymb.I for:  by kddinov for vds
#
# Revision 1.2  1997/07/08  14:28:20  pinnacle
# Replaced: vdroot/VDattrsymb.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/28  10:31:24  pinnacle
# Created: vdroot/VDattrsymb.I by rgade for vds.241
#
# Revision 1.2  1995/05/31  20:10:12  pinnacle
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/28/97  sundar  Creation
 * 06/30/97  yzhu    use VDsetAttDrSymb
 * 3-98	     KDD     symbology return status OM_S_SUCCESS.
 * 06/03/98  ah      TR179801119 Equipment being placed with random symbology  
 * -------------------------------------------------------------------*/

class implementation VDSroot ;

#include "AS_status.h"
#include "vdattmacros.h"
#include "v_drw.h"
#include "v_dbgmacros.h"
#include "vddgndef.h"

/*----------------------------------------------------------------------------*/
/* -----------------------------------------------------------------------------
 * 06/03/98 ah TR179801119
 * Route got a little carried away with making thing return success when they have
 * failed.  If VDgetAttrDrivenSymb does not find a match in the symbology file then
 * it needs to return fail otherwise, the calling routine applies random symbology
 */
method VDgetAttrDrivenSymb( long *msg; 
	char *fileName; 
	struct GRmd_env *md_env;
	struct GRsymbology *symb )
{
        struct GRid             hdr;
	IGRlong			sts;

	SetProc( VDgetAttrDrivenSymb ); Begin 
        hdr.objid = my_id;
        hdr.osnum = OM_Gw_current_OS;
 
        sts =
        vd$get_attr_symbology(    msg = msg,
                                  path = "config/attribute",
                                  file_name = fileName,
                                  obj = &hdr,
                                  obj_env = md_env,
                                  symbology = symb);

	/* KDD 3-98 symbology failure shouldn't break placement, compute, etc. */
	/* TR179801119 Sure, but this still needs to fail if no symbology found */

        as$status( sts = sts, msg = "vd$get_attr_symbology failure");
 
        End
	  // *msg = MSSUCC;
        return sts;
}

method VDputAttrDrivenSymb( long *msg; struct GRmd_env *md_env; char *fileName)
{
struct  GRsymbology     symbology;
IGRlong 		sts;
struct GRid             collId, objId;
VD_drwOutputData        *output = NULL;       

	SetProc( VDputAttrDrivenSymb ); Begin
        objId.objid = my_id;
        objId.osnum = OM_Gw_current_OS;

        collId.objid = NULL_OBJID ;
        sts =
        VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
        if( (sts&*msg&1) ) {
            /* use attr.symb or user defined file for symbology driven */
	    sts = VDsetAttDrSymb(msg, objId, md_env, output );
            VD_drwFreeOutputData( &output ) ;
        }
        else {
            /* still use the equip.att or routeattr.symb if no collector
               exists
             */
        
	    sts = om$send( msg = message VDSroot.VDgetAttrDrivenSymb(
                                        msg,
					fileName,
					md_env,
                                        &symbology),
                   targetid = my_id );
	
	    if( sts & *msg & 1 ){
		sts = om$send( msg = message GRvg.GRputsymb(
                                        msg,
                                        &symbology),
                   	targetid = my_id );
        	as$status( sts = sts );
	    } else *msg = 0;
        }

	/* KDD 3-98 symbology failure shouldn't break placement, compute, etc. */
	/* TR179801119 Leave this in since place equipment does not check anyways
	 * Assume some route stuff needs this
	 */
	as$status( sts = sts, msg = "VDputAttrDrivenSymb failure"); 

	End
	*msg = MSSUCC;
	return OM_S_SUCCESS;
}	
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

