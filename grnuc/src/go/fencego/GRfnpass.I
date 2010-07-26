/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRfnpass

Description
        This file contains methods which are overridden so that they
        may be passed to the fence object.

History
        hgw     ??/??/??    creation
        mrm     11/07/89    removed GRplotobject
        msm     07/09/92    ANSI-C conversion.
*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "grownmacros.h"

#define PASS_ON_TO_FENCE  GRpass_on_to_fence (OM_Gw_current_OS, my_id, OPPmargs)

/*
    The following messages are disallowed.  If they are passed to the fence
    an abnormal exit is probable because of difficulties with the interception
    mechanism.  These messages send with respect to message to a parent class,
    but the message actually arrives at the interceptor, which initiates a
    loop.  Other messages may also cause this problem, but these are the only
    ones currently identified.  Because of an impending release date, the
    decision was made to fix exactly these problems.  A better solution
    should be investigated as time permits.

    mrm 4/18/89
*/

from GRvg import GRmodify;
from GRcurve import GRdelvertex, GRinsvertex, /* TR 90N2068 */ GRcpparallel;

method unknown (OM_p_MESSAGE msg)
{
    IGRlong         sts;
    OMuword         vg, curve, index, defclass;
    OM_S_CHANNUM    channum;

    om$get_channel_number (channame = "GRcmpowner.to_components",
                           p_channum = &channum);

/*    if (channum == in_channel)    */
    if (!memcmp((IGRchar *)&channum,(IGRchar *)&in_channel,sizeof(OM_S_CHANNUM)) )
    {
        /*
         *  ignore messages from the graphic object
         */

        sts = OM_W_UNKNOWN_MSG;
    }
    else
    {
        /*
         *  make sure that the message is not one which is disallowed
         */

        om$get_classid (classname = "GRvg", p_classid = &vg);
        om$get_classid (classname = "GRcurve", p_classid = &curve);
        index = msg->select.FuncIndex;
        defclass = msg->select.DefClassid;
#if defined(__STDC__) || defined(__cplusplus)
        if ((index == GRvg_OPP_GRmodify_method_index && defclass == vg) || 
            (index == GRcurve_OPP_GRdelvertex_method_index && defclass == curve) ||
            (index == GRcurve_OPP_GRinsvertex_method_index && defclass == curve))
        {
            sts = OM_W_UNKNOWN_MSG;
        }
#else
       if ((index == GRvg$GRmodify_method_index && defclass == vg) || 
            (index == GRcurve$GRdelvertex_method_index && defclass == curve) ||
            (index == GRcurve$GRinsvertex_method_index && defclass == curve))
        {
            sts = OM_W_UNKNOWN_MSG;
        }
#endif
        else
        {
	  /** This is a temporary fix for TR 90N2068, a better solution
	      should be investigated as time permits **/

#if defined(__STDC__) || defined(__cplusplus)
      if(index == GRcurve_OPP_GRcpparallel_method_index && defclass == curve)
#else
          if(index == GRcurve$GRcpparallel_method_index && defclass == curve)
#endif
	  {
	   	unsigned int         count;
    	   	OM_S_OBJECT_LINKAGE  list;
    	   	OM_S_CHANSELECT      chansel;

    		chansel.type = OM_e_name;
    		chansel.u_sel.name = "GRcmpowner.to_components";

    		sts = om$get_channel_objects (	objid = my_id,
                                  		osnum = OM_Gw_current_OS,
                                  		p_chanselect = &chansel,
                                  		list = &list,
                                  		size = 1,
                                  		count = &count);
    		if (sts & 1)
    		{
        		sts = om$cancel_intercept ( osnum = list.osnum,
                                    		    objid = list.S_objid);
        		if (sts & 1)
        		{
            			sts = om$send (	msg = msg,
                           			senderid = my_id, 
                           			targetid = list.S_objid,
                           			targetos = list.osnum );
        		}

        		sts = om$set_intercept ( osnum = list.osnum,
                                    		 objid = list.S_objid,
						 target_objid = my_id );
    		}
          }
	  else
            sts = GRpass_on_to_fence (OM_Gw_current_OS, my_id, msg);
        }
    }
    return (sts);                                              
}

method GRlocaldp(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
                 struct GRparms *parms; enum GRdpmode *mode;
                 struct GRid *display_info; IGRshort *display_location; 
                 IGRshort *display_flag)
{
   return(PASS_ON_TO_FENCE);
}

method GRapprojpt(IGRlong *msg; IGRshort *matrix_type;
                  IGRmatrix matrix; struct GRparms *locate_parms;
                  struct IGRline *boreline; IGRpoint proj_pt;
                  struct GRparms *proj_parms)
{
   return(PASS_ON_TO_FENCE);
}

method GRptproject(IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; IGRpoint point,proj_pt;
                   struct GRparms *proj_parms)
{
   return(PASS_ON_TO_FENCE);
}

method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; struct IGRline *line;
                   IGRpoint ln_pt,proj_pt; IGRdouble *t;
                   struct GRparms *proj_parms)
{
   return(PASS_ON_TO_FENCE);
}

method GRlocate_processing(IGRlong *msg; struct GRlc_cvl *cvl; 
                           struct GRlc_path *path; IGRint *path_position; 
                           IGRint *owner_eligible; 
                           IGRint *component_eligible)
{
   return(PASS_ON_TO_FENCE);
}

method GRdisplay(IGRlong *msg;  IGRshort *type; IGRmatrix matrix;
        enum GRdpmode *mode; struct GRid *display_info)
{
   return(PASS_ON_TO_FENCE);
}

method GRgetprops(IGRlong *msg; IGRshort *props)
{
   return(PASS_ON_TO_FENCE);
}

method GRchgprops(IGRlong *msg; IGRshort *action; IGRshort *props)
{
   return(PASS_ON_TO_FENCE);
}

method GRgethprops(IGRlong *msg; IGRuint *props)
{
   return(PASS_ON_TO_FENCE);
}

#ifndef IDRAW

method GRgentform(IGRlong *msg; struct GRmd_env *md_env;
                  IGRint (*tform_function)(); IGRchar *info; 
                  GRobjid *newobjid)
{
   return(PASS_ON_TO_FENCE);
}

#endif

method GRxform(IGRlong *msg; struct GRmd_env *md_env;
               IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
   return(PASS_ON_TO_FENCE);
}

method GRaltconstruct(struct GRvg_construct *arglist)
{
   return(PASS_ON_TO_FENCE);
}

method GRformatele(IGRlong *msg; struct GRmd_env *md_env;
                   IGRchar *dgn_buf; IGRchar *bs_buf; IGRchar *ele_buf; 
                   IGRint *ele_size; IGRint *file_des; 
                   IGRdouble *max_overflow; IGRdouble *scale_factor)
{
/*
   return(PASS_ON_TO_FENCE);
*/
   return(OM_S_SUCCESS);
}

method GRaddwrng (IGRlong *msg; struct GRmd_env *md_info)
{
   return(PASS_ON_TO_FENCE);
}

method GRremwrng (IGRlong *msg; struct GRmd_env *md_info)
{
   return(PASS_ON_TO_FENCE);
}

#ifndef IDRAW

method GRcpforundo(IGRlong *msg; struct GRmd_env *obj_env, *new_env;
                   IGRboolean *delete; GRobjid *new_objid)
{
   return(PASS_ON_TO_FENCE);
}

method GRundocp(IGRlong *msg; struct GRmd_env *env; IGRboolean *delete)
{
   return(PASS_ON_TO_FENCE);
}

#endif

method GRfunction(IGRlong *msg; IGRint (*user_function)();
                  IGRchar *user_info)
{
   return(PASS_ON_TO_FENCE);
}

method GRprismrel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                  IGRlong *prism_rel; IGRshort *type_prism; IGRchar *prism;
                  IGRlong *relationship)
{
   return(PASS_ON_TO_FENCE);
}

method GRidchanged(IGRlong *msg; IGRshort *num_ids; struct GRid *newids)
{
   return(PASS_ON_TO_FENCE);
}

method GRgetrang(IGRlong *msg;IGRshort *matrix_type; IGRmatrix matrix; 
                 IGRboolean *world; GRrange range)
{
   return(PASS_ON_TO_FENCE);
}

method GRlevelcount(IGRlong *msg;IGRint *byte_count; IGRint *object_count)
{
   return(PASS_ON_TO_FENCE);
}

method GRreport_defaults( IGRlong *msg; IGRchar *form; IGRint *label;
                          IGRint *list_size;
                          struct GRreport_processor *processor )
{
   return(PASS_ON_TO_FENCE);
}

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{
   return(PASS_ON_TO_FENCE);
}

method GRreport( IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                 struct GRreport_item *list;
                 struct GRreport_processor *processor )
{
   return(PASS_ON_TO_FENCE);
}

method GRptprocess(IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; IGRdouble *acc_tolerance; 
                   IGRpoint point,proj_pt; struct GRparms *proj_parms)
{
   return(PASS_ON_TO_FENCE);
}

method GRlnprocess(IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; IGRdouble *acc_tolerance; 
                   struct IGRline *line; IGRpoint ln_pt,proj_pt; 
                   IGRdouble *t; struct GRparms *proj_parms)
{
   return(PASS_ON_TO_FENCE);
}
#ifndef IDRAW

method GRplotprep(IGRlong *msg; struct GRmd_env *cur_env; 
                  struct GRmd_env *target_env; IGRshort *num_prisms;
                  struct IGRcv_prism *prism_array; struct GRid *set_id;
                  IGRlong *begin_index, *end_index)
{
   return(PASS_ON_TO_FENCE);
}

method GRrcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
   return(PASS_ON_TO_FENCE);
}

#endif

method GRconstruct(struct GRvg_construct *arglist)
{
   return(PASS_ON_TO_FENCE);
}

method GRdisconn(IGRlong *msg; struct GRid *owners_id)
{
   return(PASS_ON_TO_FENCE);
}

IGRint GRpass_on_to_fence (osnum, objid, pass_msg)
OMuword        osnum;
GRobjid        objid;
OM_p_MESSAGE   pass_msg;
{
    IGRlong              sts;
    unsigned int         count;
    OM_S_OBJECT_LINKAGE  list;
    OM_S_CHANSELECT      chansel;

    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRcmpowner.to_components";

    sts = om$get_channel_objects (objid = objid,
                                  osnum = osnum,
                                  p_chanselect = &chansel,
                                  list = &list,
                                  size = 1,
                                  count = &count);
    if (sts & 1)
    {
        sts = om$disable_intercept (osnum = list.osnum,
                                    objid = list.S_objid);
        if (sts & 1)
        {
            sts = om$send (msg = pass_msg,
                           senderid = objid, 
                           targetid = list.S_objid,
                           targetos = list.osnum);
        }
    }
    return (sts);                                              
}
end implementation GRgsmgr;
