class implementation Root;

/*+fe
Internal function   VDcrt_vol_mgr()

Abstract
  This function creates view volume manager in current space.

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

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"


#include "vderrmacros.h"

extern  OMuword  OPP_VDvwvolMgr_class_id;

from  GRvg   import  GRputname;

long  VDcrt_vol_mgr()
{
IGRlong         sts;
char            filename[81], VolMgrPath[81];
struct  GRid    module;
struct  GRid    VDvwvolMgrObj;


    sts = VDSget_filename ( filename );
    DIstmcpy( VolMgrPath, filename, "IGENOD", NULL, NULL ) ;

    __DBGpr_str("VolMgrPath", VolMgrPath );

    ex$get_cur_mod(id = &module.objid, osnum = &module.osnum);

    VDvwvolMgrObj.osnum = module.osnum;

    sts = om$construct( classid = OPP_VDvwvolMgr_class_id,
                        osnum   = VDvwvolMgrObj.osnum,
                        p_objid = &VDvwvolMgrObj.objid );
    if(!(sts & 1)) goto wrapup;
    __DBGpr_obj ( "VolMgrObj", VDvwvolMgrObj );


    sts = di$add_name ( objname = "VwVolMgr",
                        path    = VolMgrPath,
                        objid   = VDvwvolMgrObj.objid);
   if ( sts != DIR_S_SUCCESS )
	printf("di$add_name failure\n");


wrapup:
   return sts;

}

/*+fe
Internal function   VDget_vol_mgr()

Abstract
  This function gets objid of view volume manager in given space.
  Return status = OM_S_SUCCESS, if vvol mgr exists.
		= OM ERROR, if vvol mgr does not exist.

Arguments
 GRspacenum		*osnum	   I -  object space from which vvol mgr
					is needed
 struct GRid		*VolMgr    O -  objid of view volume manager

Notes

Return status
  same as OM return status

History
   11-03-1994  Raju   Creation
-fe*/
long  VDget_vol_mgr (
 GRspacenum		*osnum,
 struct GRid		*VolMgr
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
   * Get id of view vol manager
   */
  sts = ex$get_objid_from_NOD(
			NODname         = "IGENOD",
			objname         = "VwVolMgr",
			pobjid          = &VolMgr->objid,
			modid           = mod_id.objid,
			mod_osnum       = mod_id.osnum);
  if(!(sts&1)) goto wrapup ;

  VolMgr->osnum = mod_id.osnum;

  __DBGpr_obj ( "GetVolMgrObj : VolMgr obj", *VolMgr );

wrapup:
  return sts;

}

end implementation Root;

