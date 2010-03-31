/* ###################   APOGEE COMPILED   ################## */
class implementation EMSasectvw;

#include "EMSasectvw.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "dpmacros.h"
#include "nddef.h"
#include "exmacros.h"
#include "EMSkey.h"
#include <alloca.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gocmacros.h"
#include "asmacros.h"
#include "asbox.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "lcmsg.h"
#include "grerr.h"
#include "ndmacros.h"


from GRdvattach import GRget_drawing_view_id;
from GRdrawview import GRget_model_geometry,
                       GRget_drawing_attachment_id;

extern GRclassid OPP_EMSsolid_class_id;

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)

/* ******************************************************
Description
  This routine retrieves information about the object and
  stores it in the input structure.

Notes
 The maximum information that we can put into the type field of
 GRobj_info structure is 30 characters.
 
History
 Creation : WBC : 09/21/91
 Sudha   06/01/93    modified to handle BSprototype headers
******************************************************** */

{
    *msg = MSSUCC;
    info->type[0] = '\0';  /* in case ex$message fails to fill in type */

    ex$message(msgnumb = EMS_I_asectvw,
               buff = info->type);

    return(OM_S_SUCCESS);
}

method EMget_parent_type(IGRlong *EMmsg;
                         IGRint primitive_type;
                         IGRuint root_count;
                         IGRuint *root_type)

/* ************************************************************************
Description
 This function gets the root types which is used for getting information
 about the parents. Adequate memory needs to be allocated for root_type 
 enough to suffice the number of parents.

Arguments
 Input
  root_count : number of roots expected. Necessary.
  
 Output
  root_type : Memory allocated to suffice the number of parents.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail : If there was an error in getting the root_structures.
 EMS_E_InvalidArg : If the number of roots expected does not match what
                    is returned.
                    Or if the construction code is invalid.
                    Or if root list is not supplied.

History
   02/13/92 : WBC  : Creation (copied from EMSagrp override of this method).
 ************************************************************************* */

{
 IGRlong status,i;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
  
 switch (primitive_type)
 {
  case EMS_ASsect_view:
  case EMS_ASsection_view:
  case EMS_ASsectvw:
  case EMS_ASsectvw_tran:

    for (i=0;i<root_count;i++)
      root_type[i] = EMSlcinfo;
  break;

  default:
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
 }

wrapup:
 EMWRAPUP (status, *EMmsg, "In EMSasectvw:EMget_parent_type error"); 
 return (status);
}

method NDparent_deleted(IGRlong *msg;
                        IGRint count_deleted; struct GRid list_deleted [];
                        struct GRid *new_obj; struct GRmd_env *md_env)

/* *******************************************************************

Description

 This method checks to see which parents are being deleted and if the
 section view's drawing view is being deleted, the section view will first
 erase itself then delete itself.

Arguments
 Input
  count_deleted : number of parents being deleted
  list_deleted : the parents being deleted
  md_env : module environment of the objects

 Output
  msg : Completion message.
  new_obj : resultant object after the deleted parents are taken into
            account; in this case will always return my_id

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If success.
  MSFAIL: If failure.

History
 09/16/92 : WBC  : Creation
*********************************************************************** */

{
    IGRlong                 status;
    IGRint                  index;
    OMuint                  dvattach_index;
    OM_S_CHANSELECT         chansel;
    IGRmatrix              *matr[1];
    struct GRid             drawview_obj,
                            my_grid;
    IGRboolean              drawview_obj_deleted;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;
    drawview_obj_deleted = FALSE;

    if (new_obj)
    {
        new_obj->osnum = OM_Gw_current_OS;
        new_obj->objid = my_id;
    }

    /* determine if the section view's drawing view is being deleted */

    status = om$send(msg = message EMSasectvw.EMget_sv_dvattach_id(msg,
                                                        &drawview_obj,
                                                        &dvattach_index),
                     targetid = my_id);

    if (1 & status & *msg)
    {
        /* must get the object at the drawing view attachment index, which is
         * an ASsource object, since the list_deleted contains the objects
         * directly on the father channel instead of the graphic objects
         * connected to them
         */

        status = EMmake_chanselect(NDfather_father, &chansel);

        if (! (1 & status))
        {
            *msg = MSFAIL;
            goto wrapup;
        }

        status = om$get_objid_at_index(objid = my_id, 
                                       p_chanselect = &chansel,
                                       index = dvattach_index,
                                       objidaddr = &drawview_obj.objid,
		                       osnumaddr = &drawview_obj.osnum);
        if (! (1 & status))
        {
            *msg = MSFAIL;
            goto wrapup;
        }

        for (index = 0; index < count_deleted; index++)
        {
            if ((list_deleted[index].objid == drawview_obj.objid) &&
                (list_deleted[index].osnum == drawview_obj.osnum))
            {
                drawview_obj_deleted = TRUE;
                break;
            }
        }
    }
    else if ((1 & status) &&
             (*msg == EMS_E_NotFound))
    {
        /* the drawing view attachment was not found so it must have been
         * deleted
         */

        drawview_obj_deleted = TRUE;
    }
    else
    {
        *msg = MSFAIL;
        goto wrapup;
    }

    if (drawview_obj_deleted)
    {
        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;
        matr[0] = (IGRmatrix *) md_env->md_env.matrix;

        dp$display(msg = msg,
                   mode = GRbe,      /* erase myself (the section view) */
                   oids = &my_grid,
                   mtx_type = &md_env->md_env.matrix_type,
                   matrix = matr);

        /* disconnect all parents */

        om$send(msg = message NDnode.NDdisconnect(0, NULL),
                targetid = my_id);

        status = om$send(msg = message GRgraphics.GRdelete(msg, md_env),
                         targetid = my_id);
    }
    else  /* not deleting the drawing view; send message on to parent class */
    {
        om$send(mode = OM_e_wrt_parent,
                msg = message EMSasectvw.NDparent_deleted(msg, count_deleted,
                                               list_deleted, new_obj, md_env),
                targetid = my_id);
    }

wrapup:

    return(status);
}

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)

/* *******************************************************************

Description

 This method first deletes its drawing view parent, then deletes itself.

Arguments
 Input
  md_env : module environment of the object

 Output
  msg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If success.
  MSFAIL: If failure.

History
 09/17/92 : WBC  : Creation
*********************************************************************** */

{
    IGRlong                 status;
    IGRmatrix              *matr[1];
    struct GRid             dv_attach_obj,
                            drawview_obj;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    /* need to delete the section view's drawing view since it serves no
     * purpose once the section view is deleted; find the section view's
     * drawing view by first finding the drawing view attachment (one of the
     * section view's parents) and then finding its drawing view; must delete
     * the drawing view instead of the drawing view attachment since objects
     * owned by the drawing view (e.g. the directional arrows connected to
     * the cutting plane line) would not be deleted if the drawing view
     * attachment was sent the delete message
     */

    status = om$send(msg = message EMSasectvw.EMget_sv_dvattach_id(msg,
                                                        &dv_attach_obj, NULL),
                     targetid = my_id);

    if (1 & status & *msg)
    {
        status = om$send(msg = message GRdvattach.GRget_drawing_view_id(
                                                          msg, &drawview_obj),
                         targetid = dv_attach_obj.objid,
                         targetos = dv_attach_obj.osnum);

        if (1 & status & *msg)
        {
            /* first erase then delete the drawing view */

            matr[0] = (IGRmatrix *) md_env->md_env.matrix;

            dp$display(msg = msg,
                       mode = GRbe,
                       oids = &drawview_obj,
                       mtx_type = &md_env->md_env.matrix_type,
                       matrix = matr);

            om$send(msg = message GRgraphics.GRdelete(msg, md_env),
                    targetid = drawview_obj.objid,
                    targetos = drawview_obj.osnum);
        }
    }

    status = om$send(mode = OM_e_wrt_parent,
                     msg = message EMSasectvw.GRdelete(msg, md_env),
                     targetid = my_id);

    return(status);
}

extern OMuword OPP_GRdvattach_class_id;

method EMget_sv_dvattach_id(IGRlong *EMmsg; struct GRid *dvattach_id;
                            OMuint *chan_index)

/* *******************************************************************

Description

 This method returns the id of the Section View's parent drawing view
attachment.

Arguments
 Input

 Output
    EMmsg :       Completion message.
    dvattach_id:  The object id and osnum of the drawing view attachment
                  which is the parent of the Section View.
    chan_index:  (Optional) The channel index at which the drawing view
                 attachment is connected to the Section View's father channel;
                 a NULL pointer may be passed in if this information is not
                 needed.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success:   If success.
  EMS_E_NotFound:  If failure:  the drawing view attachment is not found.

History
 11/05/92 : WBC  : Creation
*********************************************************************** */

{
    IGRlong                 status;
    OMuint                  num_parents,
                            index;
    OM_S_CHANSELECT         chansel;
    OMuword                 classid;
    struct GRmd_env         module_env;

    *EMmsg = EMS_E_NotFound;
    status = EMmake_chanselect(NDfather_father, &chansel);

    if (status & 1)
    {
        status = om$get_channel_count(objid = my_id,
                                      p_chanselect = &chansel,
                                      count = &num_parents);

        if (1 & status)
        {
            /* search for the parent that is of class GRdvattach; start search
             * after the cutting plane line parent since we know the drawing
             * view attachment comes after the cutting plane line
             */

            for (index = CUT_PLN_LINE_INDEX + 1; index < num_parents; index++)
            {
                status = om$send(msg = message NDnode.ASreturn_go(dvattach_id,
                                               &module_env.md_env.matrix_type,
                                               module_env.md_env.matrix),
                                 p_chanselect = &chansel,
                                 from = index,
                                 to = index);

                if (1 & status)
                {
                    status = om$get_classid(osnum = dvattach_id->osnum,
                                            objid = dvattach_id->objid,
                                            p_classid = &classid);

                    if (1 & status)
                    {
                        if (classid == OPP_GRdvattach_class_id)
                        {
                            *EMmsg = EMS_S_Success;

                            if (chan_index)
                                *chan_index = index;
                            break;
                        }
                    }
                }
            }
        }
    }

    return(OM_S_SUCCESS);
}


method NDupdate(IGRint *EMmsg;
                IGRint cnt_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
/* *************************************************************************

Description
    This method determines if the section view's drawing view attachment is
the only parent that has changed.  If it is, the "old" drawing view is simply
moved to its new position based on the position of its drawing view attachment;
recomputing the section view is not necessary.  If parents other than the
drawing view attachment have been changed, the section view is recomputed.


History
 02/02/93: WBC : Creation date.
   ************************************************************************* */
{
    IGRdouble                 trans_matrix[16],  /* translation matrix */
                              delta_vec[3],
                              origin[3];
    IGRlong                   loc_msg,status,
                              rc;
    IGRuint                   type,
                              info_size,
                              index;
    OMuint                    dv_attach_index;
    GRobjid                   newobjid;
    enum GRdpmode             dpmode;
    struct GRid               cur_mod,
                              go_grid,
                              drawview_grid;
    struct IGRlbsys           lbsys;
    struct EMS_ASsectvw_info *sectvw_info;
    struct EMS_ASsectvw_tran_info *sectvw_tran_info;
    IGRshort                  four = 4,matrix_type;
    OMuword                   classid;
    IGRboolean                xform_sectvw,
                              ret_value;
    IGRmatrix		      out_matrix,inverse_matrix;
    IGRint		      ii;
    extern IGRboolean MAinvmx(),MAmulmx();


    /* Initialise the new object to be myself so that even if we fail
     * the dependents can still recompute based on my geometry if they
     * like.
     */

     new_objid->objid = my_id;
     new_objid->osnum = OM_Gw_current_OS;

    /* if this section view's type is EMS_ASsectvw, it contains its origin
     * so we can just move the section view; otherwise we don't know where
     * to move the section view from so it is then necessary to recompute
     * the section view
     */

    status = om$send(msg = message EMSassoc.EMget_info((IGRlong *)EMmsg, NULL,
                                                       &type, &info_size, NULL),
                     targetid = my_id);
    EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

    if (type == EMS_ASsectvw || type == EMS_ASsectvw_tran)
    {
        /* find the drawing view attachment object */

        for (dv_attach_index = CUT_PLN_LINE_INDEX + 1;
             dv_attach_index < count; dv_attach_index++)
        {
            status = om$send(msg = message NDnode.ASreturn_go(&go_grid,
				 		              &matrix_type,
				 		              trans_matrix),
                             targetid = list[dv_attach_index].objid,
	                     targetos = list[dv_attach_index].osnum);
            EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

            status = om$get_classid(osnum = go_grid.osnum,
                                    objid = go_grid.objid,
                                    p_classid = &classid);
            EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

            if (classid == OPP_GRdvattach_class_id)
                break;
        }
        EMerr_hndlr((dv_attach_index >= count), *EMmsg, EMS_E_Fail,
                    wrapup);
    }

    /* if this section view is of type EMS_ASsectvw (contains its origin)
     * and only this parent has changed, move (transform) the section view
     * instead of recomputing it
     */

    if ((type == EMS_ASsectvw || type == EMS_ASsectvw_tran) &&
        (parent_state[dv_attach_index] == ND_COMP_SUCC))
    {
        xform_sectvw = TRUE;

        for (index = 0; index < count; index++)
        {
            if ((index != dv_attach_index) &&
                (parent_state[index] != ND_COMP_SAME))
            {
                xform_sectvw = FALSE;
                break;
            }
        }
    }
    else
        xform_sectvw = FALSE;

    if (xform_sectvw)
    {
        if (!(cnt_type & ND_COMP_NO_DISPLAY) ||
            !(cnt_type & ND_COMP_NO_ERASE))
        {
            status = ex$get_cur_mod(id = &cur_mod.objid,
                                    osnum = &cur_mod.osnum);
            if (!(1&status)) goto wrapup;
        }

        if (!(cnt_type & ND_COMP_NO_ERASE))
        {
            dpmode = GRbe;

            status = om$send(msg = message GRgraphics.GRdisplay(
                                               (IGRlong *)EMmsg,
                                               &md_env->md_env.matrix_type,
                                               md_env->md_env.matrix, &dpmode,
                                               &cur_mod),
                             targetid = my_id);
            EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
        }

        /* get the drawing view's origin which will be the section view's
         * new origin
         */

        status = om$send(msg = message GRdvattach.GRget_drawing_view_id(&rc,
                                                            &drawview_grid),
                         targetid = go_grid.objid,
                         targetos = go_grid.osnum);
        EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

        status = om$send(msg = message GRdrawview.GRget_model_geometry(&rc,
                                                            md_env, &lbsys),
                         targetid = drawview_grid.objid,
                         targetos = drawview_grid.osnum);
        EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);

        origin[0] = lbsys.matrix[3];
        origin[1] = lbsys.matrix[7];
        origin[2] = lbsys.matrix[11];

        /* get the drawing view's current origin */

        if(type == EMS_ASsectvw) 
        {
        sectvw_info = NULL;
        sectvw_info = (struct EMS_ASsectvw_info *)alloca(info_size);
        EMerr_hndlr(!sectvw_info, *EMmsg, EMS_E_NoStackMemory, wrapup);

        status = om$send(msg = message EMSassoc.EMget_info((IGRlong *)EMmsg,
                                                   NULL, &type,
                                                   &info_size,
                                                   (IGRchar **) &sectvw_info),
                         targetid = my_id);
        EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        /* create a translation vector that goes from the section view's current
         * origin to drawing view attachment's origin, create a translation
         * matrix from that vector and translate the section view
         */

        for (index = 0; index < 3; index++)
            delta_vec[index] = origin[index] - sectvw_info->origin[index];

        MAtrlmx(&rc, delta_vec, trans_matrix);

        ret_value = MAtypemx(&rc, trans_matrix, &matrix_type);
        EMerr_hndlr (!(1 & ret_value), *EMmsg, EMS_E_Fail, wrapup);


        /* update the origin in the section view object */

        sectvw_info->origin[0] = origin[0];
        sectvw_info->origin[1] = origin[1];
        sectvw_info->origin[2] = origin[2];

        status = om$send(msg = message EMSassoc.EMput_info((IGRlong *)EMmsg,
                                                NULL, EMS_ASsectvw, info_size,
                                                (IGRchar *) sectvw_info),
                         targetid = my_id,
                         targetos = OM_Gw_current_OS);
        EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
        }
        
        if(type != EMS_ASsectvw_tran)
        {
        status = om$send(msg = message GRgraphics.GRxform(&rc, md_env,
                                                          &matrix_type,
                                                          trans_matrix,
                                                          &newobjid),
                         targetid = my_id);
        EMerr_hndlr (!(1 & status & rc), *EMmsg, EMS_E_Fail, wrapup);
	}

        if (!(cnt_type & ND_COMP_NO_DISPLAY))
        {
            dpmode = GRbd;

            status = om$send(msg = message GRgraphics.GRdisplay(
                                               (IGRlong *)EMmsg,
                                               &md_env->md_env.matrix_type,
                                               md_env->md_env.matrix, &dpmode,
                                               &cur_mod),
                             targetid = my_id);
            EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
        }
    }
    else  /* recompute the section view */
    {
        status = om$send(msg = message EMSasectvw.NDupdate(EMmsg, cnt_type,
                                                        count, list,
                                                        parent_state, context,
                                                        new_objid, md_env),
                         mode = OM_e_wrt_parent,
                         targetid = my_id);
        EMerr_hndlr(!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
    }

wrapup:

    if (xform_sectvw)
    {
        if (1 & status & *EMmsg)
            *EMmsg = ND_COMP_SUCC;
        else
            *EMmsg = ND_COMP_FAIL;
    }

    return(status);
}

method GRdrop (IGRlong *msg; struct GRmd_env *env)
/*
Description
     This method will drop all the solids from the section view.
 
Return Values
     EMmsg - MSSUCC if all is well.
 
Notes
 
History
     12/22/94 : Vidya : Creation...
*/

{

IGRlong                status,stat_OM;
OM_S_CHANSELECT        to_comps;
IGRint            ii;
IGRint            owner_count, component_count;
OMuint            f_count,num_objects;
OM_S_CHANSELECT   child_chansel,father_chansel, component_chansel;
OM_S_OBJECT_LINKAGE *f_ids = NULL,*list_ids = NULL;
struct GRid id,my_GRid;
GRclassid classid;
 
    stat_OM = OM_S_SUCCESS;
    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
 
    component_count = 0;
    EMmake_chanselect(NDfather_father, &father_chansel); 
    EMmake_chanselect(NDchildren_children, &child_chansel); 
    status = om$get_channel_count(objid = my_id,
                                  osnum = OM_Gw_current_OS,
                                  p_chanselect = &child_chansel,
                                  count = &f_count);
    if (!(1&status)) goto wrapup;
    num_objects = 0;
    f_ids = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
					f_count);
    status = om$get_channel_objects(objid = my_id,
                                    p_chanselect = &child_chansel,
                                    list = f_ids,
                                    size = f_count,
                                    count = &num_objects);
    if(!(1 & status))
      goto wrapup;

    for(ii = 0; ii < num_objects; ii++)
      {
      struct GRid comp_id,my_source;
      status = om$send(msg = message NDnode.ASreturn_go(&comp_id,
                                               &env->md_env.matrix_type,
                                               env->md_env.matrix),
				targetid = f_ids[ii].S_objid ,
                   		targetos = f_ids[ii].osnum);
      if(!(1 & status))
          goto wrapup;
      status = om$send(msg = message GRconnector.GRdisconn(msg,
                                                            &my_GRid),
                                 targetid = comp_id.objid,
                                 targetos = comp_id.osnum);
      if(!(1 & status))
          goto wrapup;
 
      as$make_source(go_grid = comp_id,
                 as_grid = &my_source,
                 as_os    = OM_Gw_current_OS);

      status = om$send(msg = message Root.move_chan(child_chansel, 
						      f_ids[ii].S_objid,
						      OM_Gw_current_OS,
                        			      child_chansel),
                   			targetid = my_source.objid,
					targetos = my_source.osnum);
      if (!(1 & status)) goto wrapup;

      } 

      status = om$send( msg = message GRowner.GRdrop(msg, env),
                      targetid = my_id,
		      mode = OM_e_wrt_message);
      if (!(1 & status)) goto wrapup;
 
wrapup:
 return(status);
}

method GRxform( IGRlong *msg; struct GRmd_env *md_env;
                IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 IGRlong EMmsg,stat_OM;
 struct GRid my_grid;
 extern IGRboolean ASbroadcast_in_progress;
  IGRint ic,cn_type;

 *msg = EMS_S_Success;
 
  stat_OM = om$send(mode = OM_e_wrt_message,
                 msg = message GRowner.GRxform(&EMmsg, md_env,
                       matrix_type, matrix, newobjid),
                 targetid = my_id);

 my_id = *newobjid;
 if(!ASbroadcast_in_progress)
   {
   struct GRid child_GRid;
   IGRint ii;
   OMuint children_count = 0;
   OM_S_CHANSELECT to_children;
   EMmake_chanselect(NDchildren_children, &to_children);
   om$get_channel_count(p_chanselect = &to_children,
                         objid = my_id,
                         count = &children_count);
   for(ii = 0; ii < children_count; ii++)
     {
     om$get_objid_at_index(objid = my_id,
                           p_chanselect = &to_children,
                           index = ii,
                           objidaddr = &child_GRid.objid,
                           osnumaddr = &child_GRid.osnum);
 
     cn_type = ND_COMP;
     nd$wait_batch(type = GR_GEOM_POSTED,
               l_object = &child_GRid,
               l_obj_info = &cn_type,
               nb_obj   = 1);
     }
   }

   return(stat_OM);
}

IGRint EMcompute_rotation(msg, matrix_type, matrix,sect_obj,sect_osnum)
IGRlong *msg;
IGRshort *matrix_type;
IGRmatrix matrix;
GRobjid sect_obj;
OMuword sect_osnum;
{

  IGRlong loc_msg,status;
  IGRuint type,info_size,new_size;
  IGRchar *info_ptr=NULL;
  IGRmatrix out_matrix,cp_matrix,cprot_matrix;
  IGRshort   four = 4;
  IGRint ii;
  IGRdouble temp_origin[3];
  struct  EMS_ASsectvw_tran_info *sectvw_tran_info=NULL;
  struct  EMS_ASsectvw_info *sectvw_info=NULL;
  extern IGRboolean MAinvmx(),MAmulmx();

    *msg = MSSUCC;

    status = om$send (msg = message EMSassoc.EMget_info(&loc_msg,NULL,&type,
                          &info_size, NULL),
		    senderid = NULL_OBJID,
                    targetid = sect_obj,
		    targetos = sect_osnum);
    EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, wrapup);


    new_size = info_size;
    if(type == EMS_ASsectvw)
      {
	/* Change of type required */
      sectvw_info = (struct EMS_ASsectvw_info *)alloca(info_size);
      EMerr_hndlr(!sectvw_info, *msg, EMS_E_NoStackMemory, wrapup);
      status = om$send(msg = message EMSassoc.EMget_info(&loc_msg,
                                            NULL, &type,
                                            &info_size,
                                            (IGRchar **) &sectvw_info),
		         senderid = NULL_OBJID,
                         targetid = sect_obj,
                         targetos = sect_osnum);

      new_size = info_size + sizeof(double) * 16;
      sectvw_tran_info = (struct EMS_ASsectvw_tran_info *)alloca(new_size); 
      EMerr_hndlr(!sectvw_tran_info, *msg, EMS_E_NoStackMemory, wrapup);
      MAidmx (&loc_msg, sectvw_tran_info->rot_matrix);
      for(ii = 0; ii < 3; ii++)
        {
        sectvw_tran_info->origin[ii] = sectvw_info->origin[ii];
        sectvw_tran_info->view_info.z_vec[ii] = 
	                   sectvw_info->view_info.z_vec[ii];
        }
      sectvw_tran_info->view_info.cht = sectvw_info->view_info.cht;
      sectvw_tran_info->view_info.flags = sectvw_info->view_info.flags;
      sectvw_tran_info->rot_angle = sectvw_info->rot_angle;
      }
    else 
      {

       sectvw_tran_info = (struct EMS_ASsectvw_tran_info *)alloca(info_size);
       EMerr_hndlr(!sectvw_tran_info, *msg, EMS_E_NoStackMemory, wrapup);
       status = om$send(msg = message EMSassoc.EMget_info(&loc_msg,
                                            NULL, &type,
                                            &info_size,
                                            (IGRchar **) &sectvw_tran_info),
		         senderid = NULL_OBJID,
                         targetid = sect_obj,
			 targetos = sect_osnum);
       EMerr_hndlr(!(1 & status & *msg), *msg, EMS_E_Fail, wrapup);
       }

     if(sectvw_tran_info)
       {
       (void) MAidmx (&loc_msg, out_matrix);
       (void) MAidmx (&loc_msg, cprot_matrix);

       memcpy(cp_matrix,matrix,16*sizeof(double));
       memcpy(cprot_matrix,sectvw_tran_info->rot_matrix,16*sizeof(double));

      
       (void) MAmulmx(&loc_msg, &four, &four, &four, 
                      cprot_matrix, cp_matrix, out_matrix);
      
       memcpy(sectvw_tran_info->rot_matrix,out_matrix,16*sizeof(double));
      
       status = om$send(msg = message EMSassoc.EMput_info(&loc_msg,
                                                NULL, EMS_ASsectvw_tran, 
						new_size,
                                                (IGRchar *) sectvw_tran_info),
		         senderid = NULL_OBJID,
                         targetid = sect_obj,
                         targetos = OM_Gw_current_OS);
       EMerr_hndlr(!(1 & status & *msg), *msg, EMS_E_Fail, wrapup);
       }
 
wrapup:
 return(OM_S_SUCCESS);
}

end implementation EMSasectvw;
