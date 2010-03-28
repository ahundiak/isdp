/* #######################   APOGEE COMPILED   ################### */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:       GRvg
     METHOD NAME:       GRlocate

     Abstract:  This method will check to see if the graphics object
                passes the locate properties check and the level 
                check.  
                
                If so, the owner is notified that the graphics has
                received a locate request.  The owner then does
                the processing to determine if the object should
                be located. If so, the owner calls the action
                handler.

                If the object has no owner, this method calls the
                GRlocate_processing .  If the processing succeeds,
                this object calls the action handler.
-----
%SC%    

     GRlocate(cvl,range_key)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
       *cvl        GRlc_cvl      structure containing all locate info
       range_key   OM_p_KEY_DESC pointer to the range key information
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     
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
        
        SDG     06/03/86 : Design date.
        SDG     06/18/86 : Addition of "owner" code. 
        MAS     08/12/86 : Addition of range as input
        MAS     11/30/87 : Total redesign
        mrm     02/06/91   always return either OM_I_STOP_SENDING or
                           OM_S_SUCCESS to avoid problems with
                           premature termination of the rtree pass
                           during locate
                05/07/92   Added GRLocInfo
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method will check to see if the graphics object passes the 
locate properties check and the level check.  
                
If so, the owner is notified that the graphics has received a 
locate request.  The owner then does the processing to determine if 
the object should be located. If so, the owner calls the action
handler.

If the object has no owner, this method calls the GRlocate_processing.  
If the processing succeeds, this object calls the action handler.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "bserr.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "grerr.h"
#include "lcmsg.h"

from GRcmpowner import GRlocate_owner;

extern    IGRboolean    GRinit_path();

method GRlocate(struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
    IGRlong     OMmsg,                  /* OM return value              */
                msg1;                   /* local return message         */

    IGRint      path_position,
                object_valid,
                owner_elig,
                comp_elig;

    struct GRlc_path *path;             /* the locate path structure    */

    OM_S_CHANSELECT chandef;            /* the objects channel          */


    OMmsg = OM_S_SUCCESS;
    cvl->msg = MSSUCC;
    object_valid = 1;

    GRLocInfo(GRObjectHit, LC_I_ObjectHit, OM_Gw_current_OS, my_id);

    GRloccheck(&msg1,&cvl->module.md_env.matrix_type,
               cvl->module.md_env.matrix,&me->properties,       
               &cvl->attributes.obj_attr.properties,
               &me->level,cvl->levels,&my_id);

    if (! ( 1 & msg1))                  /* failed locate criteria       */
    {
        if (msg1 == GRINVOBJECT)
        {
           object_valid = 0;
        }
        else
        {
            goto wrapup;
        }
    }

    if (me->properties & GRIS_ASSOCIATIVE)
    {
      if (!(cvl->attributes.obj_attr.owner_action & LC_RIGID_COMP))
      {
        /*Locating for a write (GEOM_MOD) - is it allowed by the locator?*/
        if (!(cvl->attributes.obj_attr.owner_action & LC_ASSOCIATIVE))
        {
          /*Locator does not support associative write*/
          /*Locator doesn't support associative elements*/
          GRLocInfo(GRObjectIneligible, LC_E_AssocWrite,
                    OM_Gw_current_OS, my_id);
          goto wrapup;
        }
        else if (me->properties & GRHAS_EXTERNAL_CONSTRAINT)
        {
          /*Locator supports associative write...does it support ext. constr.*/

          if (!(cvl->attributes.obj_attr.owner_action & LC_EXTERN_CONSTRAINED))
          {
            /*Locator dont support externally constrained elements.*/
            /*Locator doesn't support externally constrained elements*/
            GRLocInfo(GRObjectIneligible, LC_E_ExternConstrain,
                      OM_Gw_current_OS, my_id);
            goto wrapup;
          }
        }
      }
    }    

    /* Eventually, do range check here
     */

    GRinit_path(&msg1,cvl,&my_id,&OM_Gw_current_OS,&path,&path_position);

    if ( 1 & msg1 )
    {
        OMmsg = GRget_to_owner_chansel(&chandef);

        if (1 & OMmsg )
        {
            msg1 = GR_I_NO_RESPONSE;

            GRLocInfo(GROwnerInfo, LC_I_DeferToOwner, OM_Gw_current_OS, my_id);

            OMmsg = om$send(msg = message GRcmpowner.GRlocate_owner
                        (&msg1,cvl,path,&path_position),
                p_chanselect = &chandef,
                from = 0,
                to = 0);
            
            if ( (msg1 == GR_I_NO_RESPONSE) && 
                 ( object_valid) &&
                 (cvl->attributes.obj_attr.owner_action != LC_OBJ_W_OWNER))
            {
                /* the owner (if any) did not handle the message
                 */

                GRLocInfo(GROwnerInfo, LC_I_NoOwnerResponse,
                          OM_Gw_current_OS, my_id);

                owner_elig = 0;
                comp_elig = 1;

                OMmsg = om$send(
                    msg = message GRgraphics.GRlocate_processing
                        (&msg1,cvl,path,&path_position,&owner_elig,
                         &comp_elig),
                    targetid = my_id);
        
            }
            if ((path[path_position].call_action_handler) &&
                (object_valid) &&
                (OMmsg != OM_I_STOP_SENDING) &&
                (msg1 != GRNO_PROCESSING_NEEDED))
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
                    GRLocInfo(GROwnerInfo, LC_I_CallActionHandler,
                              OM_Gw_current_OS, my_id);

                    OMmsg = (*cvl->action_handler)
                        (cvl->act_parms,
                         &path[path_position].lc_info,
                         cvl->locate_args,
                         &path[path_position].action);

                    /*DLB - a useless step?*/
                    if (stop_on_assoc)
                        msg1 = GRNO_PROCESSING_NEEDED;
                }
            }
        }
        GRlc_remove_path(path,&path_position);
    }

    GR_NOTIFY_LISTENERS(&cvl->msg,&OMmsg,GR_LOCATED);

wrapup:

    if (OMmsg != OM_I_STOP_SENDING) OMmsg = OM_S_SUCCESS;

    return(OMmsg);
}

end implementation GRvg;
