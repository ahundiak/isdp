class implementation	Root;

#include <stdio.h>
#include <math.h>
#include <string.h>

#	include	"OMlimits.h"		/*				*/
#	include	"OMminimum.h"		/* Typedefs			*/
#	include	"OMerrordef.h"		/* Error codes OM_?_*		*/
#	include	"OMprimitives.h"	/* Macros om$*()		*/
#include "OMmacros.h"
#	include	"igetypedef.h"		/* IGE typedefs GR*		*/
#	include	"igrtypedef.h"		/* Typedef IGR*			*/
#	include	"igrdef.h"		/* Constants IGR??		*/
#	include	"igr.h"			/* Structs IGR* for geometries	*/
#	include	"igrdp.h"		/* Structs IGR* for display	*/
#	include	"gr.h"			/* Structs GR* for graphic info	*/
#	include	"godef.h"		/* Constants GR* for graphics	*/
#	include	"go.h"			/* Struct GR* for graphics	*/

#include "AS_status.h"

from	ACcpx		import	find_macro		;
from	OMObjSpace	import	pass			;
from	GRgraphics	import	GRfunction		;
from	GRgraphics	import	GRdelete		;

extern  OMuword OPP_ACcpx_class_id ;

PALget_hdrs(md_env)
struct GRmd_env *md_env;
{

  IGRlong  status, msg;
  OM_S_CLASSLIST classlist;
  OMuword classid;
  OM_S_OBJID os_objid;
/*struct GRid hdr;*/
  struct GRfunction_info user_info;
   
  IGRint PALis_mac_def_attached();

  _pdm_debug("Enter PALget_hdrs()", 0);

   /*
    * build the class list
    */
   classlist.w_count = 1; 
   classlist.w_flags = 0;
   classid =  OPP_ACcpx_class_id;
   classlist.p_classes = &classid;

   status = om$osnum_to_oso_objid(osnum = md_env->md_id.osnum,
                                  p_objid = &os_objid);


   user_info.md_env = md_env;
   user_info.pass_to_other_spaces = 0;
   user_info.info = (IGRchar *) md_env;
    
   /*
    * send the find_macro message to each ACcpx class
    * object in the object space.
    */
   status = om$send(msg = message OMObjSpace.pass
                              (&classlist, 
                                OM_e_wrt_object,
/*                              message ACcpx.find_macro(&hdr)), */
                                message GRgraphics.GRfunction(&msg, PALis_mac_def_attached, (IGRchar *) &user_info)),
                    senderid = NULL_OBJID,
/*                  targetid = os_objid,*/
                    targetid = OM_GO_current_OS_objid,
                    targetos = md_env->md_id.osnum);
                    
   if(! (1 & status)) goto wrapup;

   return(1);

wrapup:
    _pdm_debug("Failure in message pass", 0);
    as$status(sts = status);
    return(0);
}

PALis_mac_def_attached(msg, object, user_info)
IGRlong *msg;
struct GRid *object;
struct GRfunction_info *user_info;
{
  int sts;
  struct GRid hdr;

    _pdm_debug("object: %d", object->objid);
    _pdm_debug("object: %d", object->osnum);

    sts = om$send( msg = message ACcpx.find_macro( &hdr),
                      	         senderid = object->objid,
                      	         targetid = object->objid,
        	        	 targetos = object->osnum);

    /* failure returned if object has no macro definition
    attached or if macro library is not attached.		*/

    /* Could not get macro definition.	*/
    if (!(sts & 1))
    {
      /* macro attached to defintion header
      but macro library not attached.		*/
      if (sts == OM_W_ABORT)
      {
        _pdm_debug("Macro library is not attached.", 0);
      }

      /* macro definition header does not exist.	*/
      else if (sts == OM_W_UNKNOWN_MSG)
      {
        _pdm_debug("Cleaning up this object.", 0);
        sts = om$send( msg = message GRgraphics.GRdelete(msg, (struct GRmd_env *) user_info->info),
                      	         senderid = object->objid,
                      	         targetid = object->objid,
        	        	 targetos = object->osnum);
        
        if (!(sts & 1))
        {
          _pdm_debug("Unable to delete object", 0);
        }

      }
      else
      {
        *msg = sts;
        return(sts);
      }
    }
    else
    {
      _pdm_debug("header: %d", hdr.objid);
      _pdm_debug("header: %d", hdr.osnum);
    }

    *msg = OM_S_SUCCESS;
    return(OM_S_SUCCESS);
}

end implementation	Root;

