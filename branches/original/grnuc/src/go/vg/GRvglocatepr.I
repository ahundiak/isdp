/* #######################    APOGEE COMPILED   ######################## */
 /*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:       GRvg
     METHOD NAME:       GRlocate_processing

     Abstract:  This method will check to see if the graphics object
                passes the class list check and the tolerance check.
                
-----
%SC%    

     GRlocate_processing(msg,cvl,path,path_position,owner_elig,
                        comp_elig)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
       *cvl        GRlc_cvl      structure containing all locate info
       path[]      GRlc_path     path information about the object
       *path_position IGRint     position of object in path array
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *msg       IGRlong       completion code
       path[]      GRlc_path     path information about the object
       *path_position IGRint     position of object in path array
       *owner_elig IGRint        indicator of whether owner is eligible
       *comp_elig  IGRint        indicator of whether component is
                                 eligible

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
        
        MAS     11/30/87 : Design date.
        JSD     07/03/91 : No longer locates invisible SOs.
        JSD     10/08/91 : Locates invisible SOs if dpb INVIS_SO_ON flag is OFF.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "bserr.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "lcmacros.h"
#include "grerr.h"
#include "dpdef.h"
#include "DEso.h"
#include "DEsomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lcmsg.h"
 
extern    IGRboolean    GRtransrange();

method GRlocate_processing(IGRlong *msg; struct GRlc_cvl *cvl;
        struct GRlc_path *path; IGRint *path_position,
        *owner_elig, *comp_elig)
{
    IGRchar     *prism;

    IGRshort    type_prism;

    IGRlong  OMmsg;                     /* OM return value              */
    IGRlong  msg1;                      /* local return message         */

    IGRint      eligible_flag,
                indicator;

    IGRdouble   t;

    IGRpoint    line_pt;

    GRclassid   classid;

    IGRboolean  top_down_locate,        /* kludge for now               */
                check_geom;

    IGRdouble   new_u,
                old_u1,
                old_u2;

    struct IGRdisplay old_display;

    struct GRid go_grid,
                window_grid;

    IGRint      old_type;

    IGRboolean  invis_on;


    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    cvl->msg = MSSUCC;
    eligible_flag = 0;
    check_geom=                         /* flag to process geometry     */
        (path[*path_position].result == GR_LC_NORESULT ? 1: 0);

    top_down_locate = !(cvl->attributes.obj_attr.owner_action & 
                        LC_BOTTOM_UP);

    path[*path_position].result |= GR_LC_PROCESSED;

    if (*comp_elig)
    {
        if (1 & (OMmsg = om$get_classid(objid = my_id,
                           p_classid = &classid)))
        {                               /* check ancestry               */
            msg1 = lc$classchek(rc = &OMmsg,
                        classid_to_check = classid,
                        eligible_classes = cvl->classes);
            if ( 1 & msg1 )
            {
                eligible_flag = 1;
            }
            else
                GRLocInfo(GRObjectIneligible, LC_E_InvClass,
                          OM_Gw_current_OS, my_id);
        }
    }

    if (eligible_flag || *owner_elig)
    {
        if (check_geom)
        {
            if (cvl->attributes.type == GR_pt_loc)      
            {                           /* point locate                 */
                OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRptprocess(&cvl->msg,
                        &cvl->module.md_env.matrix_type,
                         cvl->module.md_env.matrix,
                        &cvl->attributes.acc_tolerance,
                         cvl->attributes.acc_point,
                         path[*path_position].lc_info.proj_pnt,
                        &path[*path_position].lc_info.geom_parms),
                    senderid = my_id,
                    targetid = my_id);

                if (1 & OMmsg & cvl->msg)
                {
                    if (eligible_flag)
                    {
                        path[*path_position].action = add_all;
                    }
                    if (cvl->msg != GR_I_OUTSIDE_TOL)
                    {
                        path[*path_position].result = GR_LC_HIT;
                    }
                    else
                        GRLocInfo(GRObjectIneligible, LC_E_OutsideTol,
                                  OM_Gw_current_OS, my_id);
                }
            }
            else if (cvl->attributes.type == GR_bl_loc)
            {                           /* bore line locate             */
                OMmsg = om$send(msg = message GRgraphics.GRlnprocess
                                (&cvl->msg,
                                 &cvl->module.md_env.matrix_type,
                                 cvl->module.md_env.matrix,
                                 &cvl->attributes.acc_tolerance,
                                 &cvl->attributes.acc_line,
                                 line_pt,path[*path_position].lc_info.proj_pnt,
                                 &t, &path[*path_position].lc_info.geom_parms),
                                senderid = my_id,
                                targetid = my_id);

                if (1 & OMmsg & cvl->msg)
                {
                    /* Is there is a SO on the object? */

                    if ( me->properties & DEHAS_OVERRIDE )
                    { /* YES - get the SO? */

                        go_grid.objid = my_id;
                        go_grid.osnum = OM_Gw_current_OS;

                        window_grid.objid = cvl->button.objid;
                        window_grid.osnum = OM_Gw_current_OS;

                        new_u = path[*path_position].lc_info.geom_parms.u;

                        msg1 = de$retrieve_override (
                             msg         = &OMmsg,
			     p_type      = &old_type,
                             p_u1        = &old_u1,
                             p_u2        = &old_u2,
                             p_symbology = &old_display,
                             go_grid     = &go_grid,
                             u           =  new_u,
                             window_grid = &window_grid,
                             module      = &cvl->module );

                        if ( 1 & OMmsg )
                        { /* If it is the only one, are we on it? */

                          if ( ( old_u1 <= new_u ) && ( new_u <= old_u2 ) )
                          { /* YES - is it invisible */

                            if ( old_type & DE_INVIS )
                            { /* YES - do we accept or reject? */

                              msg1 = gr$get_invis_so_on( buffer = &invis_on );
			      if ( invis_on )
			      {
                                if (!(cvl->attributes.obj_attr.owner_action & 
                                      LC_INVIS_OVERRIDE))
                                { /* REJECT - locate invisible override bit
                                     not set */

                                    eligible_flag = 0;
                                    cvl->msg = GR_I_OUTSIDE_TOL;
                                    GRLocInfo(GROwnerInfo, LC_E_InvisOverride,
                                              OM_Gw_current_OS, my_id);
                                }
			      }
                            }
                          }
                        }

			OMmsg = OM_S_SUCCESS;
                    }

                    if (eligible_flag)
                    {
                        path[*path_position].action = add_all;
                    }
                    if (cvl->msg != GR_I_OUTSIDE_TOL)
                    {
                        path[*path_position].result = GR_LC_HIT;
                    }
                    else
                        GRLocInfo(GRObjectIneligible, LC_E_OutsideTol,
                                  OM_Gw_current_OS, my_id);
                }  
            }
            else if ((cvl->attributes.type == GR_rp_loc) || 
                     (cvl->attributes.type == GR_cv_loc))
            {
                if (cvl->attributes.type == GR_rp_loc)
                {
                    prism = (IGRchar *)&cvl->attributes.acc_rt_prism;
                    type_prism = 0;
                }
                else
                {
                    prism = (IGRchar *)&cvl->attributes.acc_cv_prism;
                    type_prism = 1;
                }  
  
                OMmsg = om$send(msg = message GRgraphics.GRprismrel
                                (&cvl->msg,&cvl->module.md_env.matrix_type,
                                 cvl->module.md_env.matrix,&cvl->prism_attr,
                                 &type_prism,prism,(long *)&indicator),
                                senderid = my_id,
                                targetid = my_id);

                if (1 & cvl->msg & OMmsg)
                {
                    if (indicator == 1)
                    {
                        path[*path_position].result = GR_LC_INSIDE;
                        if (eligible_flag)
                        {
                            path[*path_position].action = add_inside;
                        }
                    }
                    else if (indicator == 2)
                    {
                        path[*path_position].result = GR_LC_OVERLAP;
                        if (eligible_flag)
                        {
                            path[*path_position].action = add_overlap;
                        }
                    }
                    else 
                    {
                        path[*path_position].result = GR_LC_OUTSIDE;
                        if (eligible_flag)
                        {
                            path[*path_position].action = add_outside;
                        }
                    }
                }
            }
            else if ((cvl->attributes.type == GR_nam_loc) ||
                (cvl->attributes.type == GR_crit_loc))
            {
                if (eligible_flag)
                {
                    path[*path_position].action = add_all;
                }

                path[*path_position].result = GR_LC_HIT;
            }
            else                        /* invalid locate for now       */
            {
                OMmsg = OM_E_ABORT;
                cvl->msg = MSFAIL;
            }
        }
       
        if ( (path[*path_position].result & ~GR_LC_PROCESSED) && 
             (eligible_flag) && (*msg != GRNO_PROCESSING_NEEDED))
        {
            IGRboolean call_action = TRUE, stop_on_assoc = FALSE;

            if (cvl->attributes.obj_attr.owner_action & LC_STOP_ON_ASSOC)
            {
                if (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE))
                    call_action = FALSE;
                else
                    stop_on_assoc = TRUE;
            }

            if (call_action)
            {
                if ( top_down_locate )
                {
                    path[*path_position].call_action_handler = 1;
                }
                else
                {
                    GRLocInfo(GROwnerInfo, LC_I_CallActionHandler,
                              OM_Gw_current_OS, my_id);

                    OMmsg = (*cvl->action_handler)
                        (cvl->act_parms, &path[*path_position].lc_info,
                         cvl->locate_args, &path[*path_position].action);
  
                    if (!top_down_locate &&
                        !stop_on_assoc &&
                        OMmsg == OM_I_STOP_SENDING)
                        *msg = GRNO_PROCESSING_NEEDED;
  
                    /*DLB*/
                    if (stop_on_assoc)
                        *msg = GRNO_PROCESSING_NEEDED;
                }
            }
        }
    }


    return(OMmsg);
}
end implementation GRvg;
