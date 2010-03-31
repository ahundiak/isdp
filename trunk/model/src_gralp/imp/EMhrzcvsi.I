class implementation EMShrzcvs;

#include "igrdef.h"
#include "igr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grownerdef.h"
#include "exmacros.h"
#include "nddef.h"
#include "bstypes.h"
#include "OMmacros.h"
#include "EMShrzcvs.h"
#include "refdef.h"
#include "emssfcvs.h"
#include "emsedgedef.h"

from EMSdatpln import EMget_pln_info;
from GRreffile import GRgetrfprops;


extern int   EMinvmtrxmul();


/*
Name

    GRget_locate_properties

Abstract

        This method returns the owner locate properties of a horizon
    curve object.

Synopsis

        Type                   Name           I/O       Description
 --------------------- ---------------------- --- --------------------------
 IGRlong               *msg                    O  Return code.
 IGRint                *properties             O  The owner locate
                                                  properties.

Description

        This method returns the owner locate properties for associative
    parting lines groups.  It does not allow itself or its components to
    be located for write operations.  It only allows its components to
    be located for read operations.

Notes

Keywords

    method

History

   06/08/93  :  WBC  :  Creation date.

Justification

        Don't want myself or my components located for write operations.

*/

method GRget_locate_properties(IGRlong *msg;
                               IGRint *properties)
{
    *msg = MSSUCC;

    *properties = GR_LC_CMP_READ  |
                  GR_LC_RIGID;  

    return (OM_S_SUCCESS);
}


/*
Name

    NDparent_deleted

Abstract
        This method deletes the horizon curve since one of its parents has
    been deleted.

Synopsis

        Type                   Name           I/O       Description
 --------------------- ---------------------- --- --------------------------
 IGRlong               *msg                    O  Return code.
 IGRint                 count_deleted          I  Number of deleted parents.
 struct GRid            list_deleted[]         I  Object ids of the deleted
                                                  parents.
 struct GRid           *new_obj                O  New id of the child if it
                                                  changed.
 struct GRmd_env       *md_env                 I  Module environment of the
                                                  parent objects.

Description

        This method deletes the horizon curve since one of its parents has
    been deleted.  The associative parting lines should be deleted whenever
    either of their parents (surface or reference plane) is deleted.

Notes

Keywords

    method delete display

History

   06/08/93  :  WBC  :  Creation date.

Justification

        Need to delete myself in certain cases.

*/

method NDparent_deleted(IGRlong *msg;
                        IGRint count_deleted;
                        struct GRid list_deleted [];
                        struct GRid *new_obj;
                        struct GRmd_env *md_env)
{
    IGRlong                 status;
    IGRmatrix              *matr[1];
    struct GRid             my_grid;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (new_obj)
    {
        new_obj->osnum = OM_Gw_current_OS;
        new_obj->objid = my_id;
    }

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    matr[0] = (IGRmatrix *) md_env->md_env.matrix;

    dp$display(msg = msg,
               mode = GRbe,
               oids = &my_grid,
               mtx_type = &md_env->md_env.matrix_type,
               matrix = matr);

    /* disconnect all parents */

    om$send(msg = message NDnode.NDdisconnect(0,NULL),
            targetid = my_id);

    status = om$send(msg = message GRgraphics.GRdelete(msg, md_env),
                     targetid = my_id);

    return(status);
}


/*
Name

    NDparent_rf_detached

Abstract

        This method deletes the horizon curve since one of its parents has
    been disconnected because the reference file in which the parent resides
    has been detached.

Synopsis

        Type                   Name           I/O       Description
 --------------------- ---------------------- --- --------------------------
 IGRlong               *msg                    O  Return code.
 struct GRid           *parent_grid            I  Object id of the parent
                                                  being disconnected.
 struct GRmd_env       *md_env                 I  Module environment of the
                                                  parent object.
 struct GRid           *new_obj                O  New id of the child if it
                                                  changed.

Description

        This method deletes the horizon curve since one of its parents has
    been disconnected because the reference file in which the parent resides
    has been detached.  The horizon curves should be deleted whenever
    either their surface or reference plane is no longer accesible.

Notes

Keywords

    method delete display

History

   06/29/93  :  WBC  :  Creation date.

Justification

        Need to delete myself in certain cases.

*/

method NDparent_rf_detached(IGRlong *msg;
                            struct GRid *parent_grid;
                            struct GRmd_env *md_env;
                            struct GRid *new_obj)
{
    IGRlong                 status;
    IGRmatrix              *matr[1];
    struct GRid             my_grid;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (new_obj)
    {
        new_obj->osnum = OM_Gw_current_OS;
        new_obj->objid = my_id;
    }

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    matr[0] = (IGRmatrix *) md_env->md_env.matrix;

    dp$display(msg = msg,
               mode = GRbe,
               oids = &my_grid,
               mtx_type = &md_env->md_env.matrix_type,
               matrix = matr);

    /* disconnect all parents */

    om$send(msg = message NDnode.NDdisconnect(0, NULL),
            targetid = my_id);

    status = om$send(msg = message GRgraphics.GRdelete(msg, md_env),
                     targetid = my_id);

    return(status);
}


/*
Name

    EMplanar_to_view

Abstract

        This method determines if the horizon curves are planar to the
    specified view and if the specified module environment is the same
    as the "surface to horizon curves" environment.

Synopsis

        Type                Name     I/O          Description
 --------------------- ------------- --- -------------------------------
 IGRlong               *EMmsg         O  Return code.
 IGRint                 options       I  Options bitmask.  Definitions
                                         are in EMShrzcvs.h.
 struct  GRmdenv_info  *mdenv_info    I  The module environment info of
                                         the horizon curve's surface.
 IGRvector              z_vector      I  The z-vector with which to
                                         compare the horizon curves.
                                         If this argument is NULL,
                                         the window id must be specified.
                                         If both are specified, only
                                         z_vector is used.
 struct GRid           *window_grid   I  Window id of the view with
                                         which to compare the horizon
                                         curves.  This argument is not
                                         used if z_vector was specified.
 GRspacenum            *osnum         I  Only horizon curves in this
                                         object space will be eligible.
                                         If this argument is NULL,
                                         horizon curves in all objects
                                         spaces will be eligible.
 struct GRid           *curve_id      O  The object id and object space
                                         number of a matching horizon
                                         curve, if any.  Optional argument;
                                         send NULL if information is not
                                         needed.

Return Values

    - EMS_S_Success    : The horizon curves are planar to the view.
    - EMS_I_NotFound   : The horizon curves are not planar to the view.
    - EMS_E_InvalidArg : Neither z_vector nor window_grid was specified.
    - EMS_E_Fail       : Failure.

    If the option EMS_HRZCVS_STOP_SEND is set and the horizon curves are
    planar to the specified view, the OM return status is set to
    OM_I_STOP_SENDING.  This is useful when doing channel sends since the
    notification channel is unordered and channel sends out unordered channels
    go to every object on the channel unless the send is explicitly stopped.
    This provides a way to stop the channel send once a match has been found.

Description

        This method determines if the horizon curves are planar to the
    specified view and if the specified module environment is the same
    as the "surface to horizon curves" environment.  The horizon curves'
    plane is determined by their parent reference plane.
*/

method EMplanar_to_view(IGRlong *EMmsg;
                        IGRint options;
                        struct GRmdenv_info *mdenv_info;
                        IGRvector z_vector;
                        struct GRid *window_grid;
                        GRspacenum *osnum;
                        struct GRid *curve_id)
{
    int                   EMcompare_vectors();
 
    IGRlong               status,
                          bytes_ret;
    IGRint                which_error,
                          index;
    IGRdouble             z[3],
                          ref_z_vector[3],
                         *view_z_ptr,
                          value,
                          v_matrix[16],
                          surf_matrix[16];
    IGRshort              surf_matrix_type;
    IGRboolean            match;
    struct GRmd_env       md_env;
    struct GRid           ref_pln_id,
                          surf_id;
    struct var_list       list[2];
    OM_S_CHANSELECT       father;

    status = OM_S_SUCCESS;
    *EMmsg = EMS_I_NotFound;

    /* if this horizon curve's object space does not match the specified
     * object space, stop processing and exit
     */

    if (osnum &&
        (*osnum != OM_Gw_current_OS))
        goto wrapup;

    /* determine the window orientation to be compared with the
     * horizon curve's orientation
     */

    if (z_vector)
        view_z_ptr = z_vector;
    else if (window_grid)
    {
        list[0].var = VW_ROT_NO_CON;
        list[0].var_ptr = (IGRchar *)v_matrix;
        list[0].num_bytes = sizeof(IGRdouble) * 16;
        list[0].bytes_returned = &bytes_ret;

        list[1].var = END_PARAM;
        list[1].var_ptr = NULL;
        list[1].num_bytes = 0;
        list[1].bytes_returned = NULL;

        status = dp$inq_set_gragad(msg = EMmsg,
                                   osnum = window_grid->osnum,
                                   gragad_objid = window_grid->objid,
                                   which_error = &which_error,
                                   var_list = list);
        if (! (1 & status & *EMmsg))
        {
            *EMmsg = EMS_E_Fail;
            goto wrapup; 
        }

        z[0] = v_matrix[8];
        z[1] = v_matrix[9];
        z[2] = v_matrix[10];
        view_z_ptr = z;
    }
    else
    {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
    }

    status = EMmake_chanselect(NDfather_father, &father);
    if (! (1 & status))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup; 
    }

    /* Get the GRid of the reference plane. */

    status = om$send(msg = message NDnode.ASreturn_go(&ref_pln_id,
                                                   &md_env.md_env.matrix_type,
                                                   md_env.md_env.matrix),
                     p_chanselect = &father,
                     from = EMS_HRZCVS_REF_PLN_INDEX,
                     to = EMS_HRZCVS_REF_PLN_INDEX);
    if (! (1 & status))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup; 
    }

    md_env.md_id.osnum = 0;
    md_env.md_id.objid = NULL_OBJID;

    /* get the z_vector from the reference plane */

    status = om$send(msg = message EMSdatpln.EMget_pln_info(EMmsg, NULL,
                                                            &md_env, NULL,
                                                            NULL,
                                                            ref_z_vector,
                                                            NULL, NULL),
                     senderid = my_id,
                     targetid = ref_pln_id.objid,
                     targetos = ref_pln_id.osnum);

    if (! (1 & status & *EMmsg))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup; 
    }

    if (EMcompare_vectors(view_z_ptr, ref_z_vector, &value))
    {
        status = om$send(msg = message NDnode.ASreturn_go(&surf_id,
                                                          &surf_matrix_type,
                                                          surf_matrix),
                         p_chanselect = &father,
                         from = EMS_HRZCVS_SURF_INDEX,
                         to = EMS_HRZCVS_SURF_INDEX);
        if (! (1 & status))
        {
            *EMmsg = EMS_E_Fail;
            goto wrapup; 
        }

        match = TRUE;

        for (index = 0; index < 16; index++)
        {
            if (mdenv_info->matrix[index] != surf_matrix[index])
            {
                match = FALSE;
                break;
            }
        }

        if (match)
        {
            *EMmsg = EMS_S_Success;

            if (options & EMS_HRZCVS_STOP_SEND)
                status = OM_I_STOP_SENDING;

            if (curve_id)
            {
                curve_id->objid = my_id;
                curve_id->osnum = OM_Gw_current_OS;
            }
        }
    }

wrapup:

    return(status);
}


/*
Name

    EMdisplay

Abstract

            This method is used to display the horizon curves for a
    paticular view.

Synopsis

        Type                Name     I/O          Description
 --------------------- ------------- --- -------------------------------
 IGRlong               *EMmsg         O  Return code.
 IGRint                 options       I  Display options which are
                                         defined in EMShrzcvs.h.
 IGRshort              *matrix_type   I  Matrix type.
 IGRmatrix              matrix        I  Matrix to use when displaying
                                         the horizon curves.
 enum GRdpmode         *mode          I  Display mode.
 struct IGRaltdisplay  *alt_symb      I  Alternate display symbology.
 struct DP_information *sp_info       I  Display specific information.
 OM_p_KEY_DESC          key           I  Range key.

Return Values

        EMS_S_Success    : Horizon curves, if any, for the specified view
                           were successfully displayed.
        EMS_I_NotFound   : No horizon curves were found for the specified
                           view.
        EMS_E_Fail       : Could not display the horizon curves.
        EMS_E_InvalidArg : The argument sp_info was NULL, so the view
                           orientation could not be determined.

Description

        This method is used to display the horizon curves for the
    specified view.  The horizon curves' orientation is determined from
    their reference plane parent and is compared with the orientation of
    the specified matrix.  If the orientations are the same and the window
    osnum is the same as the horizon curves' osnum, the horizon
    curves are displayed.  This method assumes it was invoked by the
    horizon curves' surface parent, so the input transformation matrix
    must be adjusted by the transformation between the horizon curve and
    its surface parent.

Notes

    If a horizon curve is successfully displayed and the options bit
    EMS_HRZCVS_STOP_SEND is set, the OM return code is set to
    OM_I_STOP_SENDING in order to stop a channel send of this message.

Keywords

    method display

History

   07/02/93  :  WBC  :  Creation date.

Justification

        Needed a special display routine for horizon curves so that the
    horizon curves' orientation can be compared with the view's orientation
    to determine if the horizon curves should be displayed.

*/

method EMdisplay(IGRlong *EMmsg; IGRint options; IGRshort *matrix_type;
                 IGRmatrix matrix; enum GRdpmode *mode;
                 struct IGRaltdisplay *alt_symb;
                 struct DP_information *sp_info;
                 OM_p_KEY_DESC key)
{
    IGRdouble           surf_matrix[16],
                        local_matrix[16];
    IGRlong             status;
    struct GRid         window_grid,
                        surf_grid;
    struct GRmdenv_info mdenv_info;
    OM_S_CHANSELECT     father;
    IGRshort            surf_matrix_type,
                        local_matrix_type;

    status = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;

    /* if the window id is not available, cannot determine its orientation */

    if (sp_info)
    {
        if (sp_info->view_osnum != OM_Gw_current_OS)
        {
            *EMmsg = EMS_I_NotFound;
            goto wrapup;
        }

        window_grid.objid = sp_info->view_objid;
        window_grid.osnum = sp_info->view_osnum;
        mdenv_info.matrix_type = *matrix_type;
        OM_BLOCK_MOVE(matrix, &mdenv_info.matrix, sizeof(IGRdouble) * 16);

        status = om$send(msg = message EMShrzcvs.EMplanar_to_view(EMmsg, NULL,
                                                           &mdenv_info, NULL,
                                                           &window_grid, NULL,
                                                           NULL),
                         targetid = my_id);

        if (status & 1)
        {
            if (*EMmsg == EMS_S_Success)
            {
                /* get the tranformation matrix that goes from the surface's
                 * environment to the horizon curves' environment
                 */

                status = EMmake_chanselect(NDfather_father, &father);
                if (! (1 & status))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup; 
                }

                status = om$send(msg = message NDnode.ASreturn_go(&surf_grid,
                                                           &surf_matrix_type,
                                                           surf_matrix),
                                 p_chanselect = &father,
                                 from = EMS_HRZCVS_SURF_INDEX,
                                 to = EMS_HRZCVS_SURF_INDEX);
                if (! (1 & status))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup;
                }

                /* since this method makes the assumption that it is being
                 * called by its surface parent, it must also assume the input
                 * matrix is relative to the surface parent's environment;
                 * since these horizon curves were created in their own object
                 * space's environment, the input matrix must be adjusted to
                 * account for the difference in environments between the
                 * surface parent and its horizon curves; this "adjustment"
                 * is done by multiplying the input matrix by the inverse of
                 * the "parent surface to horizon curves" transformation
                 * matrix
                 */

                if (! EMinvmtrxmul(EMmsg, matrix, surf_matrix, local_matrix,
                                   &local_matrix_type))
                    goto wrapup;

                status = om$send(mode = OM_e_wrt_message,
                                 msg = message GRowner.GRdisyourself(EMmsg,
                                                           &local_matrix_type,
                                                           local_matrix, mode,
                                                           alt_symb, sp_info,
                                                           key),
                                 targetid = my_id);

                if ((1 & status & *EMmsg) &&
                    (options & EMS_HRZCVS_STOP_SEND))
                    status = OM_I_STOP_SENDING;
            }
        }
        else
            *EMmsg = EMS_E_Fail;
    }
    else
    {
        status = OM_E_ERROR;
        *EMmsg = EMS_E_InvalidArg;
    }

wrapup:

    return (status);
}


/*
Name

    EMlocate

Abstract

            This method is used to determine if any of the horizon curves
    would be located using the input locate information.

Synopsis

        Type                Name     I/O          Description
 --------------------- ------------- --- -------------------------------
 IGRlong               *EMmsg         O  Return code.
 struct GRlc_cvl       *cvl           I  Locate information.
 struct GRid           *window_grid   I  Id of the window in which the
                                         locate is taking place.
 IGRlong               *prism_rel     I  Prism relation desired (for prism
                                         locate only).  Optional argument,
                                         may be set to NULL.
 IGRboolean            *inside       I/O Indicates if the element is
                                         inside the prism.  Only valid for
                                         prism locates.  May be NULL
                                         otherwise.
 IGRboolean            *outside      I/O Indicates if the element is
                                         outside the prism.  Only valid
                                         for prism locates.  May be NULL
                                         otherwise.
 IGRboolean            *overlap      I/O Indicates if the element
                                         overlaps the prism.  Only valid
                                         for prism locates.  May be NULL
                                         otherwise.
 struct GRlc_info      *loc_parms     O  Locate parameters.  A NULL pointer
                                         may be passed in if this information
                                         is not needed.
 IGRboolean            *was_located   O  Set to TRUE if one of the
                                         horizon curves was hit.

Return Values

        EMS_I_Found      : Horizon curves for the specified view
                           were successfully located.
        EMS_I_NotFound   : The horizon curves were not locatable for the
                           specified view.
        EMS_E_Fail       : Could not display the horizon curves.

Description

            This method is used to determine if any of the horizon curves
    would be located using the input locate information.  The horizon
    curves would only be located if they are planar to the specified view
    and the locate view's osnum is the same as the horizon curves' osnum.

Notes

Keywords

    method locate

History

   07/08/93  :  WBC  :  Creation date.

*/

method EMlocate(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                struct GRid *window_grid; IGRlong *prism_rel;
                IGRboolean *inside; IGRboolean *outside; IGRboolean *overlap;
                struct GRlc_info *loc_parms; IGRboolean *was_located)
{
    IGRdouble            surf_matrix[16],
                         local_matrix[16];
    IGRdouble            intersection_param;
    IGRlong              status;
    IGRuint              index,
                         num_components;
    OM_S_CHANSELECT      to_components,
                         father;
    struct IGRbsp_curve *curve_geom;
    struct GRlc_info    *loc_parms_ptr,
                         local_loc_parms;
    struct GRid          surf_grid;
    IGRshort             relation,
                         surf_matrix_type,
                         local_matrix_type;

    status = OM_S_SUCCESS;
    *EMmsg = EMS_I_NotFound;
    *was_located = FALSE;

    if (window_grid->osnum != OM_Gw_current_OS)
    {
        *EMmsg = EMS_I_NotFound;
        goto wrapup;
    }

    status = om$send(msg = message EMShrzcvs.EMplanar_to_view(EMmsg, NULL,
                                                          &cvl->module.md_env,
                                                          NULL, window_grid,
                                                          NULL, NULL),
                     targetid = my_id);

    if (status & 1)
    {
        if (*EMmsg == EMS_S_Success)
        {
            /* these horizon curves are planar to the specified view; check
             * each of the curves and stop at the first one that is "hit"
             * by this locate
             */

            status = EMmake_chanselect(GRcmpowner_to_components,
                                       &to_components);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            status = om$get_channel_count(objid = my_id,
                                          p_chanselect = &to_components,
                                          count = &num_components);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            if (num_components)
            {
                /* get the tranformation matrix that goes from the surface's
                 * environment to the horizon curves' environment
                 */

                status = EMmake_chanselect(NDfather_father, &father);
                if (! (1 & status))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup; 
                }

                status = om$send(msg = message NDnode.ASreturn_go(&surf_grid,
                                                           &surf_matrix_type,
                                                           surf_matrix),
                                 p_chanselect = &father,
                                 from = EMS_HRZCVS_SURF_INDEX,
                                 to = EMS_HRZCVS_SURF_INDEX);
                if (! (1 & status))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup;
                }

                /* since this method makes the assumption that it is being
                 * called by its surface parent, it must also assume the input
                 * matrix is relative to the surface parent's environment;
                 * since these horizon curves were created in their own object
                 * space's environment, the input matrix must be adjusted to
                 * account for the difference in environments between the
                 * surface parent and its horizon curves; this "adjustment"
                 * is done by multiplying the input matrix by the inverse of
                 * the "parent surface to horizon edges" transformation
                 * matrix
                 */

                if (! EMinvmtrxmul(EMmsg, cvl->module.md_env.matrix,
                                   surf_matrix, local_matrix,
                                   &local_matrix_type))
                    goto wrapup;
            }

            if (loc_parms)
                loc_parms_ptr = loc_parms;
            else
                loc_parms_ptr = &local_loc_parms;

            for (index = 0; index < num_components; index++)
            {
                status = om$send(msg = message GRvg.GRgenabsg(EMmsg,
                                                    &local_matrix_type,
                                                    local_matrix,
                                                    (IGRchar **)&curve_geom),
                                 p_chanselect = &to_components,
                                 from = index,
                                 to = index);

                if (! (1 & status * *EMmsg))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup;
                }

                EFisoCurveLocate(EMmsg, curve_geom, cvl, loc_parms_ptr, TRUE,
                                 &intersection_param, &relation);

                EFinterpretRelation(EMmsg, relation, cvl->attributes.type,
                                    0, NULL, intersection_param, prism_rel,
                                    inside, outside, overlap, was_located);

                if (*was_located)
                {
                    status = OM_I_STOP_SENDING;
                    *EMmsg = EMS_I_Found;
                }
            }
        }
    }
    else
    {
        *EMmsg = EMS_E_Fail;
    }

wrapup:

    return (status);
}


/*
Name

    EMbdrylocate

Abstract

            This method is used to locate horizon curves.

Synopsis

        Type                Name     I/O          Description
 --------------------- ------------- --- -------------------------------
 IGRlong               *EMmsg         O  Return code.
 struct GRlc_cvl       *cvl           I  Locate information.
 range_key              OM_p_KEY_DESC I  Range key.

Return Values

        EMS_S_Success    : No errors were encountered.
        EMS_I_Found      : A horizon curve was "hit" but not accepted.
        EMS_E_Fail       : A failure occurred.

Description

            This method is used to locate horizon curves.  The horizon
    curves will only be located if they are planar to the specified view
    and the locate view's osnum is the same as the horizon curves' osnum.

Notes

Keywords

    method locate

History

   07/10/93  :  WBC  :  Creation date.

*/

method EMbdrylocate(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                    OM_p_KEY_DESC range_key)
{
    IGRdouble            surf_matrix[16];
    struct GRmd_env      tmp_env;
    struct GRid          window_grid,
                         surf_grid;
    IGRlong              status;
    IGRuint              index,
                         num_components;
    OM_S_CHANSELECT      to_components,
                         father;
    IGRshort             tmp_env_used,
                         surf_matrix_type;

    status = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    window_grid.objid = cvl->button.objid;
    window_grid.osnum = cvl->button.osnum ;
    tmp_env_used = FALSE;

    if (window_grid.osnum != OM_Gw_current_OS)
        goto wrapup;

    status = om$send(msg = message EMShrzcvs.EMplanar_to_view(EMmsg, NULL,
                                                          &cvl->module.md_env,
                                                          NULL, &window_grid,
                                                          NULL, NULL),
                     targetid = my_id);

    if (status & 1)
    {
        if (*EMmsg == EMS_S_Success)
        {
            /* get the tranformation matrix that goes from the surface's
             * environment to the horizon curves' environment
             */

            status = EMmake_chanselect(NDfather_father, &father);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup; 
            }

            status = om$send(msg = message NDnode.ASreturn_go(&surf_grid,
                                                           &surf_matrix_type,
                                                           surf_matrix),
                             p_chanselect = &father,
                             from = EMS_HRZCVS_SURF_INDEX,
                             to = EMS_HRZCVS_SURF_INDEX);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            /* since this method makes the assumption that it is being
             * called by its surface parent, it must also assume the input
             * matrix is relative to the surface parent's environment;
             * since these horizon curves were created in their own object
             * space's environment, the input matrix must be adjusted to
             * account for the difference in environments between the
             * surface parent and its horizon curves; this "adjustment"
             * is done by multiplying the input matrix by the inverse of
             * the "parent surface to horizon edges" transformation
             * matrix;
             * temporarily switch the input module environment with that
             * generated by the previous matrix multiplication so that
             * we are using the correct locate environment
             */

            OM_BLOCK_MOVE(&cvl->module, &tmp_env, sizeof(struct GRmd_env));
            tmp_env_used = TRUE;

            if (! EMinvmtrxmul(EMmsg, tmp_env.md_env.matrix, surf_matrix,
                               cvl->module.md_env.matrix,
                               &cvl->module.md_env.matrix_type))
                goto wrapup;

            cvl->module.md_id.osnum = OM_Gw_current_OS;
            ex$get_modid(mod_osnum = OM_Gw_current_OS,
                         mod_id = &cvl->module.md_id.objid);

            /* these horizon curves are planar to the specified view; check
             * each of the curves and stop at the first one that is "hit"
             * by this locate
             */

            status = EMmake_chanselect(GRcmpowner_to_components,
                                       &to_components);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            status = om$get_channel_count(objid = my_id,
                                          p_chanselect = &to_components,
                                          count = &num_components);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            for (index = 0; index < num_components; index++)
            {
                status = om$send(msg = message GRgraphics.GRlocate(cvl,
                                                                   range_key),
                                 p_chanselect = &to_components,
                                 from = index,
                                 to = index);

                if (! (1 & status))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup;
                }
                else if (status == OM_I_STOP_SENDING)
                {
                    *EMmsg = EMS_S_Success;
                    break;
                }
                else if ((status == OM_S_SUCCESS) &&
                         (cvl->msg == MSSUCC))
                    *EMmsg = EMS_I_Found;
            }
        }
    }
    else
    {
        *EMmsg = EMS_E_Fail;
    }

wrapup:

    if (tmp_env_used)
        OM_BLOCK_MOVE(&tmp_env, &cvl->module, sizeof(struct GRmd_env));

    return (status);
}


/*
Name

    GRdisyourself

Abstract

            This method displays the horizon curves.

Synopsis

        Type                Name     I/O          Description
 --------------------- ------------- --- -------------------------------
 IGRlong               *EMmsg         O  Return code.
 IGRshort              *type          I  Matrix type.
 IGRmatrix              matrix        I  Matrix to use when displaying
                                         the horizon curves.
 enum GRdpmode         *mode          I  Display mode.
 struct IGRaltdisplay  *alt_symb      I  Alternate display symbology.
 struct DP_information *sp_info       I  Display specific information.
 OM_p_KEY_DESC          key           I  Range key.

Return Values

    MSSUCC    : Horizon curves, if any, for the specified view
                were successfully displayed.
    MSFAIL    : Could not display the horizon curves.
    MSINARG   : The argument sp_info was NULL, so the view
                orientation could not be determined.

Description

        This method displays the horizon curves if their orientation matches
    the orientation of the specified view and the specified view's osnum is
    the same as the horizon curves' osnum.  It also finds if its parent
    surface's reference file has GROVERRIDE_SYMBOLOGY set and if it does,
    uses the override symbology.

Notes

Keywords

    method display

History

   07/15/93  :  WBC  :  Creation date.

Justification

        Need to determine if the view orientation is planar to the horizon
    curves' orientation before displaying the horizon curves.
*/

method GRdisyourself(IGRlong *msg;
                     IGRshort *type;
                     IGRmatrix matrix;
                     enum GRdpmode *mode;
                     struct IGRaltdisplay *alt_symb;
                     struct DP_information *sp_info;
                     OM_p_KEY_DESC key)
{
    extern IGRlong         GRcheckref(),
                           GRfindcontext();
    extern IGRboolean      MAmulmx(),
                           MAtypemx();

    struct GRid            window_grid,
                           surf_grid,
                           context_grid;
    struct GRsymbology     ref_symb;
    struct IGRaltdisplay  *alt_symb_ptr,
                           local_alt_symb;
    struct GRmdenv_info    mdenv_info;
    OM_S_CHANSELECT        father,
                           to_reffile;
    IGRdouble              surf_matrix[16];
    IGRlong                status,
                           tmp_msg;
    IGRulong               ref_props;
    IGRshort               surf_matrix_type,
                           dimension;
    IGRushort              color;
    char unsigned          wght,
                           style;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (sp_info)
    {
        if (sp_info->view_osnum != OM_Gw_current_OS)
            goto wrapup;

        window_grid.objid = sp_info->view_objid;
        window_grid.osnum = sp_info->view_osnum;

        /* find the parent surface's environment matrix; this will
         * be used to both adjust the input module environment matrix to
         * take into accout the difference between the horizon curve's and
         * it surface's environment and to determine if the surface is in a
         * reference file and if it is, what reference file it resides in
         */

        status = EMmake_chanselect(NDfather_father, &father);
        if (! (1 & status))
        {
            *msg = MSFAIL;
            goto wrapup; 
        }

        status = om$send(msg = message NDnode.ASreturn_go(&surf_grid,
                                                   &surf_matrix_type,
                                                   surf_matrix),
                         p_chanselect = &father,
                         from = EMS_HRZCVS_SURF_INDEX,
                         to = EMS_HRZCVS_SURF_INDEX);
        if (! (1 & status))
        {
            *msg = MSFAIL;
            goto wrapup; 
        }

        if (*type == MAIDMX)
        {
            mdenv_info.matrix_type = surf_matrix_type;
            OM_BLOCK_MOVE(surf_matrix, mdenv_info.matrix,
                          sizeof(IGRdouble) * 16);
        }
        else if (surf_matrix_type == MAIDMX)
        {
            mdenv_info.matrix_type = *type;
            OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRdouble) * 16);
        }
        else
        {
            dimension = 4;
            MAmulmx(&tmp_msg, &dimension, &dimension,&dimension, matrix,
                    surf_matrix, mdenv_info.matrix);
            MAtypemx(&tmp_msg, mdenv_info.matrix, &mdenv_info.matrix_type);
        }

        status = om$send(msg = message EMShrzcvs.EMplanar_to_view(&tmp_msg,
                                                           NULL, &mdenv_info,
                                                           NULL, &window_grid,
                                                           NULL, NULL),
                         targetid = my_id);

        if (status & 1)
        {
            if (tmp_msg == EMS_S_Success)
            {
                alt_symb_ptr = alt_symb;

                GRcheckref(&tmp_msg, &surf_matrix_type, surf_matrix, NULL,
                           &surf_grid.osnum);

                if (tmp_msg == MSSUCC)
                {
                    /* the surface is in a reference file; find the context
                     * object associated with the reference file
                     */

                    status = GRfindcontext(&tmp_msg, &surf_matrix_type,
                                           surf_matrix, &surf_grid.osnum,
                                           &context_grid);

                    if (1 & status & tmp_msg)
                    {
                        status = om$make_chanselect(channame = "GRcontext.to_reffile",
                                                    p_chanselect = &to_reffile);

                        if (1 & status)
                        {
                            /* if the reference files GROVERRIDE_SYMBOLOGY
                             * properties bit is set, use the reference
                             * file's symbology
                             */

                            status = om$send(msg = message GRreffile.GRgetrfprops(
                                                    &tmp_msg, &ref_props),
                                             p_chanselect = &to_reffile,
                                             senderid = context_grid.objid,
                                             targetos = context_grid.osnum,
                                             from = 0,
                                             to = 0);

                            if ((1 & status & tmp_msg) &&
                                (ref_props & GROVERRIDE_SYMBOLOGY))
                            {
                                status = om$send(msg = message GRvg.GRgetsymb(
                                                     &tmp_msg, &ref_symb),
                                                 p_chanselect = &to_reffile,
                                                 senderid = context_grid.objid,
                                                 targetos = context_grid.osnum,
                                                 from = 0,
                                                 to = 0);

                                if (1 & status & tmp_msg)
                                {
                                    local_alt_symb.color = NULL;
                                    local_alt_symb.weight = NULL;
                                    local_alt_symb.style = NULL;

                                    if (alt_symb)
                                        local_alt_symb = *alt_symb;

                                    if ((ref_symb.display_attr.color != ((unsigned short)-1)) &&
                                        (! local_alt_symb.color))
                                    {
                                        local_alt_symb.color = &color;
                                        color = ref_symb.display_attr.color;
                                    }
      
                                    if ((ref_symb.display_attr.weight != ((unsigned char) -1)) &&
                                        (! local_alt_symb.weight))
                                    {
                                        local_alt_symb.weight = &wght;
                                        wght = ref_symb.display_attr.weight;
                                    }
      
                                    if ((ref_symb.display_attr.style != ((unsigned char) -1)) &&
                                        (! local_alt_symb.style))
                                    {
                                        local_alt_symb.style = &style;
                                        style = ref_symb.display_attr.style;
                                    }

                                    /* if the local_symb is all zeroes,
                                     * then there really isn't an
                                     * override, the GROVERRIDE_SYMBOLOGY
                                     * bit probably shouldn't have been
                                     * set
                                     */  

                                    if (!local_alt_symb.color &&
                                        !local_alt_symb.weight &&
                                        !local_alt_symb.style)
                                        alt_symb_ptr = 0;
                                    else
                                        alt_symb_ptr = &local_alt_symb;
                                }
                            }
                        }
                    }
                }

                status = om$send(mode = OM_e_wrt_message,
                                 msg = message GRowner.GRdisyourself(msg,
                                                          type, matrix, mode,
                                                          alt_symb_ptr,
                                                          sp_info, key),
                                 targetid = my_id);
            }
        }
        else
            *msg = MSFAIL;
    }
    else
    {
        status = OM_E_ERROR;
        *msg = MSINARG;
    }

wrapup:

    return(status);
}


/*
Name

    NDupdate

Abstract

        This method erases the horizon curves (both the background and
    highlight planes) before the recompute and displays the recomputed
    horizon curves after the recompute is complete.

Synopsis

        Type                Name     I/O          Description
 --------------------- ------------- --- -------------------------------
 IGRint                *EMmsg         O  Return code.
 IGRint                 cnt_type      I  Compute type options (defined
                                         in nddef.h)
 IGRint                 count         I  Number of parents.
 struct GRid           *list          I  List of parents.
 IGRint                *parent_state  I  Completion code of parents
                                         compute.
 struct GRid           *context       I  Context GRid used if the compute
                                         is done in a macro.
 struct GRid           *new_objid     I  New GRid of the associative
                                         element.
 struct GRmd_env       *md_env        I  Module environment for the
                                         recompute.

Description

        This method first checks to see if the option to erase this element
    is set and if it is, it erases the horizon curves on both the background
    and highlight planes and temporarily clears the option to erase.
    The call to erase the element in the inherited NDupdate method only
    erases the background plane.  Horizon curves need to also erase the
    highlight plane since their surface parent may have been sent a highlight
    display message after its been xformed, which would cause the horizon
    curves to be highlighted in their "old" position, that is, their position
    before this update message.
        Next the method checks to see if the option to display this element
    is set and if it is, it temporarily clears this option.  A message is then
    sent to myself to recompute.  After the recompute is completed, the
    horizon curves are displayed if the original option so indicates.  This is
    done since the display of this element is dependent on it having its
    parents attached and the default implementation of NDupdate does the
    display before the parents have been connected.

Keywords

    method display

History

   07/06/93  :  WBC  :  Creation date.

Justification

        Need to display the recomputed element after its parents have been
    connected.

*/

method NDupdate(IGRint *EMmsg;
                IGRint cnt_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
    struct GRid    cur_mod;
    IGRlong        status;
    IGRint         tmp_cnt_type;
    enum GRdpmode  dpmode;

    tmp_cnt_type = cnt_type;

    status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
    if (! (1 & status)) goto wrapup;

    if (! (cnt_type & ND_COMP_NO_ERASE))
    {
        /* if the options indicates this element is to be erased, erase it
         * on both the background and highlight planes
         */

        dpmode = GRbehe;

        status = om$send(msg = message GRgraphics.GRdisplay((IGRlong *)EMmsg, 
                                              &md_env->md_env.matrix_type, 
                                              md_env->md_env.matrix, &dpmode,
                                              &cur_mod), 
                         targetid = my_id);

        EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        tmp_cnt_type |= ND_COMP_NO_ERASE;
    }

    /* temporarily change the options so that the recomputed element
     * will not be display since it will be displayed in this method
     * after the recompute has completed
     */

    if (! (cnt_type & ND_COMP_NO_DISPLAY))
        tmp_cnt_type |= ND_COMP_NO_DISPLAY;

    status = om$send(mode = OM_e_wrt_message,
                     msg = message EMSassoc.NDupdate(EMmsg, tmp_cnt_type,
                                                     count, list,
                                                     parent_state, context,
                                                     new_objid, md_env),
                     targetid = my_id);

    if ((1 & status & *EMmsg) &&
        (! (cnt_type & ND_COMP_NO_DISPLAY)))
    {
        dpmode = GRbd;

        status = om$send(msg = message GRgraphics.GRdisplay((IGRlong *)EMmsg, 
                                              &md_env->md_env.matrix_type, 
                                              md_env->md_env.matrix, &dpmode,
                                              &cur_mod), 
                         targetid = new_objid->objid,
                         targetos = new_objid->osnum);

        EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    }

wrapup:

    return(status);
}


/*
Name

    EMget_parent_type

Abstract

        This method gets the root types which are used for getting information
    about the parents.

Synopsis

        Type                Name       I/O          Description
 --------------------- --------------- --- -------------------------------
 IGRlong               *EMmsg           O  Return code.
 IGRint                 primitive_type  I  Type indicating which root
                                           types are to be returned.
 IGRuint                root_count      I  Number of root elements.
 IGRuint               *root_type       O  The type of each root (parent),
                                           which is used to when getting
                                           information about the roots.
                                           The caller must allocate memory
                                           for these types (must have an
                                           array the size of root_count).

Return Values

    EMS_S_Success    : If all goes well.
    EMS_E_Fail       : If there was an error in getting the root_structures.
    EMS_E_InvalidArg : If the number of roots expected does not match what
                       is returned, or if the construction code is invalid
                       or if root list is not supplied.

Description

        This method gets the root types which are used for getting
    information about the parents (roots).

Keywords

    method associative

History

   07/15/93  :  WBC  :  Creation date.

Justification

        Need root types appropriate for this class with respect to the
    primitive_type.

*/

method EMget_parent_type(IGRlong *EMmsg;
                         IGRint primitive_type;
                         IGRuint root_count;
                         IGRuint *root_type)
{
    IGRlong status,
            index;

    *EMmsg = EMS_S_Success;
    status = OM_S_SUCCESS;
  
    switch (primitive_type)
    {
        case EMS_AShorizon_curves:

            for (index = 0; index < root_count; index++)
                root_type[index] = EMSlcinfo;
            break;

        default:
        {
            *EMmsg = EMS_E_InvalidArg;
            goto wrapup;
        }
    }

wrapup:

    return (status);
}


/*
Name

    EMexecuteCurveFunction

Abstract

        This method invokes the specified function for each horizon curve
    if the horizon curves' orientation matches the window orientation.

Synopsis

        Type                Name       I/O          Description
 --------------------- --------------- --- -------------------------------
 IGRlong               *EMmsg           O  Return code.
 IGRint                 options         I  Options which are
                                           defined in EMShrzcvs.h.
 IGRshort              *matrix_type     I  Matrix type.
 IGRmatrix              matrix          I  The surface's environment matrix.
 IGRint                (*f)()           I  The function to be executed on
                                           the horizon curves.
 IGRchar               *args            I  Pointer to the argument structure
                                           to be passed to f().

Return Values

    EMS_S_Success    : If all goes well.
    EMS_I_NotFound   : If the surface doesn't have any horizon curves that
                       have the same orientation as the specified z vector.
    EMS_E_Fail       : If there was an error in getting the root_structures.
    EMS_E_InvalidArg : If the view vector pointer equals NULL.


Description

        This method determines if the specified orientation matches the
    horizon curves' orientation and if it does, it gets the geometry of each
    horizon curve and calls the specified function for each curve, sending in
    the curve's geometry.

Notes

    If the horizon curves are successfully processed by the input function,
    and the options bit EMS_HRZCVS_STOP_SEND is set, the OM return code is
    set to OM_I_STOP_SENDING in order to stop a channel send of this message.

Keywords

    method

History

   07/26/93  :  WBC  :  Creation date.

*/

method EMexecuteCurveFunction(IGRlong *EMmsg;
                              IGRint options;
                              IGRshort *matrix_type;
                              IGRmatrix matrix;
                              IGRint (*f)();
                              IGRchar *args)
{
    extern int              EMcpmscs20();

    IGRlong                 status;
    IGRuint                 index,
                            num_components;
    IGRvector               view_z_vector;
    IGRdouble               surf_matrix[16],
                            local_matrix[16];
    struct EMScurveinfo    *cv_struct;
    struct GRmdenv_info     mdenv_info;
    struct GRid             surf_grid;
    struct IGRbsp_curve    *curve_geom;
    struct EMSinvoker_info  my_info;
    OM_S_CHANSELECT         father,
                            to_components;
    IGRshort                surf_matrix_type,
                            local_matrix_type;
    IGRuchar                my_cvtype;

    *EMmsg = EMS_S_Success;
    status = OM_S_SUCCESS;

    if(f == EMcpmscs20)
    {
        cv_struct = ((struct EMSwireframe_mscinfo *)args)->curve_info;
    }
    else
    {
        cv_struct = (struct EMScurveinfo *)args;
    }

    /* this routine requires the view_vector be set */

    if (cv_struct->view_vector == NULL)
    {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;      
    }

    view_z_vector[0] = cv_struct->view_vector[0];
    view_z_vector[1] = cv_struct->view_vector[1];
    view_z_vector[2] = cv_struct->view_vector[2];

    mdenv_info.matrix_type = *matrix_type;
    OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRdouble) * 16);

    status = om$send(msg = message EMShrzcvs.EMplanar_to_view(EMmsg, NULL,
                                                              &mdenv_info,
                                                              view_z_vector,
                                                              NULL, NULL,
                                                              NULL),
                     targetid = my_id);

    if (status & 1)
    {
        if (*EMmsg == EMS_S_Success)
        {
            /* these horizon curves are planar to the specified view; check
             * each of the curves and stop at the first one that is "hit"
             * by this locate
             */

            status = EMmake_chanselect(GRcmpowner_to_components,
                                       &to_components);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            status = om$get_channel_count(objid = my_id,
                                          p_chanselect = &to_components,
                                          count = &num_components);
            if (! (1 & status))
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            if (num_components)
            {
                /* get the tranformation matrix that goes from the surface's
                 * environment to the horizon curves' environment
                 */

                status = EMmake_chanselect(NDfather_father, &father);
                if (! (1 & status))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup; 
                }

                status = om$send(msg = message NDnode.ASreturn_go(&surf_grid,
                                                           &surf_matrix_type,
                                                           surf_matrix),
                                 p_chanselect = &father,
                                 from = EMS_HRZCVS_SURF_INDEX,
                                 to = EMS_HRZCVS_SURF_INDEX);
                if (! (1 & status))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup;
                }

                /* since this method makes the assumption that it is being
                 * called by its surface parent, it must also assume the input
                 * matrix is relative to the surface parent's environment;
                 * since these horizon curves were created in their own object
                 * space's environment, the input matrix must be adjusted to
                 * account for the difference in environments between the
                 * surface parent and its horizon curves; this "adjustment"
                 * is done by multiplying the input matrix by the inverse of
                 * the "parent surface to horizon curves" transformation
                 * matrix
                 */

                if (! EMinvmtrxmul(EMmsg, matrix, surf_matrix, local_matrix,
                                   &local_matrix_type))
                    goto wrapup;

                my_info.flags = EMSexecCvF_FirstEdge | EMSexecCvF_Edge;
                my_info.obj.objid = NULL_OBJID;
                my_info.obj.osnum = OM_Gw_current_OS;
                my_info.cvtype = &my_cvtype;

                for (index = 0; index < num_components; index++)
                {
                    if (index == 1)
                        my_info.flags &= ~EMSexecCvF_FirstEdge;

                    status = om$send(msg = message GRvg.GRgenabsg(EMmsg,
                                                     &local_matrix_type,
                                                     local_matrix,
                                                     (IGRchar **)&curve_geom),
                                     p_chanselect = &to_components,
                                     from = index,
                                     to = index);

                    if (! (1 & status & *EMmsg))
                    {
                        *EMmsg = EMS_E_Fail;
                        goto wrapup;
                    }

                    /* call the specified function, sending in each horizon
                     * curve's geometry
                     */

                    if (curve_geom->num_poles == 2)
                        my_cvtype = EMlinesegment;
                    else
                        my_cvtype = EMlinestring;

                    *EMmsg = (*f)(curve_geom, args, &my_info);
                }

                if (options & EMS_HRZCVS_STOP_SEND)
                    status = OM_I_STOP_SENDING;
            }
        }
    }
    else
        *EMmsg = EMS_I_NotFound;

wrapup:

    return(status);
}


/*
Name

    EMfind_hrzcvs

Abstract

        This message helps determine if any horizon curves exist in an object
    space.

Synopsis

        Type                Name       I/O          Description
 --------------------- --------------- --- -------------------------------
 IGRlong               *EMmsg           O  Return code.

Return Values

    EMS_I_Found   : If the object is a horizon curve.

Description

        This method returns the OM return code OM_I_STOP_SENDING which will
    stop a channel or object space send.

Keywords

    method

History

   07/28/93  :  WBC  :  Creation date.

*/

method EMfind_hrzcvs(IGRlong *EMmsg)
{
    *EMmsg = EMS_I_Found;

    return(OM_I_STOP_SENDING);
}


/*
Name

    EMpasson

Abstract

        This message is used to pass on a message to horizon curve objects.

Synopsis

        Type                Name       I/O          Description
 --------------------- --------------- --- -------------------------------
 OM_p_MESSAGE           pass_msg        I  Pointer to message to pass to
                                           the horizon curve elements.

Description

        This message is used to pass on a message to horizon curve objects.
    It is useful when a message needs to be sent from a surface to only
    its horizon curves via the notification channel.

Keywords

    method

History

   09/16/93  :  WBC  :  Creation date.

*/

method EMpasson(OM_p_MESSAGE pass_msg)
{
    return(om$send(msg = pass_msg,
                   targetid = my_id));
}

end implementation EMShrzcvs;
