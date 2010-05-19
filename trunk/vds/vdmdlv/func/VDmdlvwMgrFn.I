/* $Id: VDmdlvwMgrFn.I,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdmdlv/func / VDmdlvwMgrFn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmdlvwMgrFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
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
# Revision 1.2  1995/08/23  23:39:18  pinnacle
# Replaced: vdmdlv/func/*.I for:  by tlbriggs for vds.240
#
 *
 * History:
 *	11-03-1994  Raju   	Creation
 *    	08/23/95    tlb		Modified to use _MALLOC, _FREE
 *
 *************************************************************************/
class implementation Root;

/*+fe
Internal function   VDcrt_mdlvw_mgr()

Abstract
  This function creates model view manager in current space.

Arguments
  No arguments

Notes

Return status
  same as OM return status

History
   11-03-1994  Raju   Creation
-fe*/
#include "OMminimum.h"
#include "OMprimitives.h"
#include "ex.h"
#include "exmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"


#include "vderrmacros.h"

extern  OMuword  OPP_VDmdlvwMgr_class_id;

from  GRvg   import  GRputname;

long  VDcrt_mdlvw_mgr()
{
IGRlong         sts;
char            filename[81], MdlvwMgrPath[81];
struct  GRid    module;
struct  GRid    VDmdlvwMgrObj;


    sts = VDSget_filename ( filename );
    DIstmcpy( MdlvwMgrPath, filename, "IGENOD", NULL, NULL ) ;

    __DBGpr_str("MdlvwMgrPath", MdlvwMgrPath );

    ex$get_cur_mod(id = &module.objid, osnum = &module.osnum);

    VDmdlvwMgrObj.osnum = module.osnum;

    sts = om$construct( classid = OPP_VDmdlvwMgr_class_id,
			osnum   = VDmdlvwMgrObj.osnum,
			p_objid = &VDmdlvwMgrObj.objid );
    if(!(sts & 1)) goto wrapup;
    __DBGpr_obj ( "MdlvwMgrObj", VDmdlvwMgrObj );


    sts = di$add_name ( objname = "MdlVwMgr",
                        path    = MdlvwMgrPath,
                        objid   = VDmdlvwMgrObj.objid);
    if ( sts != DIR_S_SUCCESS )
	printf("di$add_name failure\n");


wrapup:
   return sts;

}


/*+fe
Internal function   VDget_mdlvw_mgr()

Abstract
  This function gets objid of model view manager in given space.
  Return status = OM_S_SUCCESS, if mdlvw mgr exists.
		= OM ERROR, if mdlvw mgr does not exist.

Arguments
 GRspacenum		*osnum	   I -  object space from which mdlvw mgr
					is needed
 struct GRid		*MdlvwMgr    O -  objid of model view manager

Notes

Return status
  same as OM return status

History
   11-03-1994  Raju   Creation
-fe*/

long  VDget_mdlvw_mgr (
 GRspacenum		*osnum,
 struct GRid		*MdlvwMgr
)
{
IGRlong         sts;
struct  GRid	mod_id;



  if ( osnum )
	{  mod_id.osnum = *osnum;
	   ex$get_modid ( mod_osnum = mod_id.osnum, mod_id = &mod_id.objid );
	}
  else
	ex$get_cur_mod ( id = &mod_id.objid,  osnum = &mod_id.osnum );

  /*
   * Get id of model view manager
   */
  sts = ex$get_objid_from_NOD(
                        NODname         = "IGENOD",
                        objname         = "MdlVwMgr",
                        pobjid          = &MdlvwMgr->objid,
                        modid           = mod_id.objid,
                        mod_osnum       = mod_id.osnum);
  if(!(sts&1)) goto wrapup ;

  MdlvwMgr->osnum = mod_id.osnum;

  __DBGpr_obj ( "MdlvwMgr :", *MdlvwMgr );

wrapup:
  return sts;

}

end implementation Root;

