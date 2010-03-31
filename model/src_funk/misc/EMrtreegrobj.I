/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
/*
 Abstract
        This utility scans the database of a given module
        and picks up the objects under GRgraphics in the R-tree that are 
	within a given range.

	The memory for the returned objects is always allocated by the 
	function and is to be freed by the caller.

	If no search point is passed in, the search is made around the
	origin.
	If no search tolerance is passed in, max tolerance(GRDGNLIMITS_MAX_D)
	is used.
	Both the above being input as NULL will mean the entire design space
	is encompassed in the search through the R tree.
	
	Options are currently ignored.
	
History
	SM	26-Jul-89	Creation.
*/

#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMindex.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "gomacros.h"

from GRgraphics import GRfunction;

struct objinfo
{
  struct GRid     *obj;
  IGRint          bufsize, num;
};

void EMreturn_rtree_graphics_objects (rc,
            search_pt,
            search_tol,
            module_env,
	    options, 
            objs, 
	    numobjs)
            
IGRlong         *rc;            /* return code */
IGRdouble       *search_pt;     /* world coord. point about which
                                  search is to be made */
IGRdouble       *search_tol;     /* search tolerance */
struct GRmd_env *module_env;    /* information of the module
                                   under consideration */
IGRushort options;	/* currently ignored */
struct GRid	**objs;
IGRint		*numobjs;
{
 IGRlong	sts = OM_S_SUCCESS, msg1;

 struct objinfo   objinfo;
 struct GRfunction_info func_info;
 struct GRgraphics_GRfunction_Msg arglist;
 OM_S_MESSAGE msgstruct;
 IGRint	(*f)(), PutObjid(), i;
 extern void EMscan(); 
 IGRdouble	locsearch_pt[3], locsearch_tol;

 *rc = EMS_S_Success;
 *numobjs = 0;
 *objs = NULL;
 objinfo.bufsize = 0;
 objinfo.obj = NULL;
 objinfo.num = 0;
 if(!search_pt) search_pt = locsearch_pt;
 if(!search_tol) search_tol = &locsearch_tol;

 /* 
  if no search point is passed in we search around the origin.
  if no search tol is passed in we search with maximum tolerance, which will
  encompass the entire design space.
 */

 for(i=0; i<3; i=i+1) locsearch_pt[i] = 0.0;
 locsearch_tol = GRDGNLIMITS_MAX_D;

 go$build_user_function_buffer(buffer = &func_info,
   			       md_env = module_env,
                               pass_on = 0,
			       your_info = &objinfo);

 f = PutObjid;

 arglist.msg = &msg1;
 arglist.user_function = f;
 arglist.user_info = (IGRchar *)&func_info;

 /* GRgraphics.GRfunction message will be sent to all rtree objects within
    the range box.
    The function to be invoked upon receiving this message is specified as
    PutObjid(), which simply allocates memory if required and appends the
    GRid passed in to it, to a list.
 */
 sts = om$make_message(classname = "GRgraphics", 
    		       methodname = "GRfunction",
		       size = sizeof(arglist), 
		       p_arglist = &arglist,
		       p_msg = &msgstruct);
 EMerr_hndlr(!(1&sts), *rc, EMS_E_Fail, wrapup);

 EMscan(rc, search_pt, search_tol, module_env, &msgstruct);
 
 *objs = objinfo.obj;
 *numobjs = objinfo.num;

wrapup:
return;
  }



/* The following function will be invoked for each eligible rtree object
   encountered. The function will be invoked via GRgraphics.GRfunction
   method.
*/
#define INC	1

IGRint PutObjid(EMmsg, my_info, user_info)
IGRint *EMmsg;
struct GRid *my_info;
struct GRfunction_info *user_info;
 {
  struct objinfo *objinfo;

  objinfo = (struct objinfo *)user_info->info;
  *EMmsg = EMS_S_Success;

  if(!objinfo->bufsize)
   {
    if(objinfo->obj)
     objinfo->obj = (struct GRid *)om$realloc(ptr = (IGRchar *)objinfo->obj, 
  		 	size = (objinfo->num + INC) * sizeof(struct GRid));
    else
     objinfo->obj = (struct GRid *)om$malloc(size = INC * sizeof(struct GRid));
    objinfo->bufsize = INC;
   }

  if(!objinfo->obj)
   {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  objinfo->obj[(objinfo->num)++] = *my_info;
  (objinfo->bufsize)--;

wrapup:
if(1&*EMmsg)
  return (EMS_S_Success);
else 
  return(EMS_E_Fail);
}
        
end implementation Root;
