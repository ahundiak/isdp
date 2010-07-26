/* ###################   APOGEE COMPILED   ################## */
class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "lcdef.h"
#include "grownerdef.h"
#include "OMerrordef.h"
#include "godef.h"
#include "grerr.h"
#include "lcmacros.h"
#include "lcmsg.h"
#include "grgsdef.h"
#include "gocmacros.h"

#define OUTSIDE   0
#define INSIDE    1
#define OVERLAP   2

extern IGRint   GRget_to_comp_chansel();

/*\
Name
    GRlocate_owner

Description
    This method performs the locate operation for owners.  This method
    is responsible for locating the owner and the component that sent 
    this message.

    *msg           IGRlong              completion code
    *cvl           struct GRlc_cvl      Module and action handler info
    *path          struct GRlc_path     The locate path of objects
    *path_position  IGRint              Position of calling object in
                                       the path structure.

Notes
    The msg should be initialized to GR_I_NO_RESPONSE.  Only
    legitimate owners can change the message setting.

Return Values
    MSSUCC            -  if successful completion 
    MSFAIL            -  if error occurred
    GR_I_NO_RESPONSE  -  If no legitimate owners.
\*/
method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position)
{
    IGRlong           om_msg;
    IGRint            owner_eligible;
    IGRint            component_eligible;
    IGRint            i;
    OM_S_CHANSELECT   chansel;
    IGRboolean        dont_loc=FALSE;


    if (me->properties & GRIS_ASSOCIATIVE)
    {
      if (!(cvl->attributes.obj_attr.owner_action & LC_RIGID_COMP))
      {
        /*Locating for a write (GEOM_MOD) - is it allowed by the locator?*/
        if (!(cvl->attributes.obj_attr.owner_action & LC_ASSOCIATIVE))
        {
          /*Locator does not support associative write*/
          /*Locator doesn't support associative elements*/
          dont_loc = TRUE;
          GRLocInfo(GRObjectIneligible, LC_E_AssocWrite,
                    OM_Gw_current_OS, my_id);
        }
        else if (me->properties & GRHAS_EXTERNAL_CONSTRAINT)
        {
          /*Locator supports associative write...does it support ext. constr.*/

          if (!(cvl->attributes.obj_attr.owner_action & LC_EXTERN_CONSTRAINED))
          {
            /*Locator dont support externally constrained elements.*/
            /*Locator doesn't support externally constrained elements*/
            dont_loc = TRUE;
            GRLocInfo(GRObjectIneligible, LC_E_ExternConstrain,
                      OM_Gw_current_OS, my_id);
          }
        }

        if (dont_loc)
        {
          *msg = MSSUCC;
          om_msg = OM_S_SUCCESS;
          goto wrapup;
        }
      }
    }    

    if ( om_msg = GRget_to_owner_chansel( &chansel ) ) 
    {
        /* 
         *  Add myself to the path.
         */
        GRlc_add_path(path, path_position, my_id, OM_Gw_current_OS);
        path[*path_position].lc_info.module_info = cvl->module;

        GRLocInfo(GROwnerInfo, LC_I_DeferToOwner, OM_Gw_current_OS, my_id);

        /*
         *  Send the GRlocate_owner message to my first owner.
         */
        *msg = GR_I_NO_RESPONSE;
        om_msg = om$send (msg = message GRcmpowner.GRlocate_owner 
                                                    ( msg, 
                                                      cvl, 
                                                      path,
                                                      path_position),
                          p_chanselect = &chansel, 
                          to = NULL, 
                          from = NULL);

        if (om_msg == OM_W_UNKNOWN_MSG || om_msg == OM_E_NOSUCHCLASS)
        {
            /* owner is an unknown owner, go ahead and locate if it
             * is not for modification and the relationship is rigid.
             */
            IGRlong save_msg;
    
            save_msg = om_msg;
            om_msg=OM_S_SUCCESS;
            *msg=GR_I_NO_RESPONSE;
           
            if (me->properties & GR_RIGID_RELATIONSHIP)
            {
               if (! (cvl->attributes.obj_attr.owner_action & LC_RIGID_COMP))
               {
                   om_msg=save_msg;
                   *msg=MSSUCC;
               }    
            }      
        }
        if (om_msg & *msg & 1) 
        {
            if (*msg == GR_I_NO_RESPONSE) 
            {
                /*
                 *  None of the owners responded to the locate message.
                 */

                GRLocInfo(GROwnerInfo, LC_I_NoOwnerResponse,
                          OM_Gw_current_OS, my_id);

                owner_eligible = FALSE;      /* Since I do not have an owner */
                component_eligible = 
                (cvl->attributes.obj_attr.owner_action & LC_OBJ_W_OWNER) ? 
                 2 : 1;

                om_msg = om$send (msg = message GRgraphics.GRlocate_processing 
                                                            (msg,
                                                             cvl, 
                                                             path, 
                                                             path_position, 
                                                             &owner_eligible,
                                                             &component_eligible),
                                  targetid = my_id);
            }

            if ((om_msg & *msg & 1) && (*msg != GRNO_PROCESSING_NEEDED))/*DLB*/
            {
                IGRboolean call_action=TRUE, stop_on_assoc=FALSE;

                if (cvl->attributes.obj_attr.owner_action & LC_STOP_ON_ASSOC)
                {
                  if (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE))
                    call_action = FALSE;
                  else stop_on_assoc = TRUE;
                }

                if (call_action && path[*path_position].call_action_handler) 
                {
                    GRLocInfo(GROwnerInfo, LC_I_CallActionHandler,
                              OM_Gw_current_OS, my_id);

                    om_msg = (*cvl->action_handler)
                                    ( (cvl->act_parms), 
                                      &path[*path_position].lc_info, 
                                      (cvl->locate_args),
                                      &path[*path_position].action);
                    /*DLB*/
                    if (stop_on_assoc) *msg = GRNO_PROCESSING_NEEDED;
                }
            }
        }

        GRlc_remove_path(path, path_position);

        if (om_msg == OM_I_STOP_SENDING) 
            for (i=0; i <= *path_position; ++i) 
                path[i].call_action_handler = FALSE;
        else 
        {
            om_msg = GRsend_to_next_sibling ( 
                            path[*path_position].lc_info.located_obj.osnum,
                            path[*path_position].lc_info.located_obj.objid,
                            OM_Gw_current_OS, my_id, 
                            message GRcmpowner.GRlocate_owner (msg, 
                                                               cvl, 
                                                               path, 
                                                               path_position) );
        }

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_LOCATED);
    }
wrapup:
    return (om_msg);
}

/*\
Name
    GRlocate_processing

Description
    This method performs the locate processing for an owner.

    *msg                 IGRlong           completion code
    *cvl                 struct GRlc_cvl   Module and action handler info
    *path                struct GRlc_path  The locate path of objects
    *path_position       IGRint            Position of calling object in
                                           the path structure.
    *owner_eligible      IGRint            If 1 owner is eligible
                                           If 0 owner is not eligible
    *component_eligible  IGRint            If 0 no components are eligible
                                           If 1 all components are eligible
                                           If 2 all but immediate component
                                           are eligible

Return Values
    MSSUCC   -  if successful completion 
    MSFAIL   -  if error occurred
\*/

method GRlocate_processing (IGRlong *msg; 
                            struct GRlc_cvl *cvl;
                            struct GRlc_path *path; 
                            IGRint *path_position;
                            IGRint *owner_eligible; 
                            IGRint *component_eligible)
{
    IGRlong om_msg;
    IGRint  properties;

    *msg = MSSUCC;

    /*
     *  Get the locate properties.
     */
    om_msg = om$send ( msg = message GRowner.GRget_locate_properties (msg, 
                                                                      &properties), 
                       targetid = my_id);

    /*
     *  Perform the locate processing.
     */
    om_msg = GRowner_locate_processing (msg, 
                                        cvl, 
                                        path, 
                                        path_position, 
                                        owner_eligible, 
                                        component_eligible, 
                                        my_id, 
                                        OM_Gw_current_OS,
                                        properties);

    return (om_msg);
}

/*\
Name
    GRowner_locate_processing

Description
    This is a function that peforms the locate processing for owners.
 
    *msg                 IGRlong           return code
    *cvl                 struct GRlc_cvl   Locate structure
    path[]               struct GRlc_path  The locate path
    *path_position       IGRint            The position in the path
    *owner_eligible      IGRint            If 1 owner is eligible
                                           If 0 owner is not eligible
    *component_eligible  IGRint            If 0 no components are eligible
                                           If 1 all components are eligible
                                           If 2 all but immediate component
                                           are eligible
    objid                GRobjid           The owner objid
    osnum                GRspacenum        The owner osnum
    properties           IGRint            locate properties of owner

Return Values
    MSSUCC   -  if successful completion 
    MSFAIL   -  if error occurred
\*/
IGRint GRowner_locate_processing (msg, 
                                  cvl, 
                                  path, 
                                  path_position, 
                                  owner_eligible, 
                                  component_eligible,
                                  objid, 
                                  osnum, 
                                  properties)
    IGRlong           *msg;
    struct GRlc_cvl   *cvl;
    struct GRlc_path  *path;
    IGRint            *path_position;
    IGRint            *owner_eligible;
    IGRint            *component_eligible;
    GRobjid           objid;
    GRspacenum        osnum;
    IGRint            properties;
{
    IGRlong              om_msg;
    IGRint               local_cmp_eligible;     /* component eligiblity for*/
                                                 /* my components.          */
    IGRint               local_eligible;         /* my eligibility          */

    *msg = MSSUCC;

    /*
     *  Determine if my components will be eligible.
     */
    local_cmp_eligible = FALSE;
    if (*component_eligible) 
    {
        /*
         *  Determine the eligibility of my components.
         */ 
        local_cmp_eligible = GRcomponent_eligibility (msg, 
                                                      cvl, 
                                                      path,
                                                      path_position, 
                                                      objid, 
                                                      osnum, 
                                                      properties);
    }

    local_eligible = FALSE;
    if (*component_eligible & 1) 
    {
        /*
         *  Determine the eligiblility of my self.
         */
        local_eligible = GRowner_eligibility (msg, 
                                              cvl, 
                                              path,
                                              path_position,
                                              objid, 
                                              osnum, 
                                              properties);
    }

    /*
     *  Perform the locate processing.
     */
    om_msg = GRowner_locate_processing1( msg, 
                                         cvl, 
                                         path, 
                                         path_position, 
                                         owner_eligible,
                                         component_eligible,
                                         objid,
                                         osnum,
                                         properties,
                                         local_cmp_eligible,
                                         local_eligible);

    return (om_msg);
}
/*\
Name
    GRowner_locate_processing1

Description
    This is a function that peforms the locate processing for owners.

    *msg                 IGRlong           return code
    *cvl                 struct GRlc_cvl   Locate structure
    path[]               struct GRlc_path  The locate path
    *path_position       IGRint            The position in the path
    *owner_eligible      IGRint            If 1 owner is eligible
                                           If 0 owner is not eligible
    *component_eligible  IGRint            If 0 no components are eligible
                                           If 1 all components are eligible
                                           If 2 all but immediate component
                                           are eligible
    objid                GRobjid           The owner objid
    osnum                GRspacenum        The owner osnum
    properties           IGRint            locate properties of owner
    local_cmp_eligible   IGRint            If 0 no components are eligible
                                           If 1 components are eligible
    local_eligible       IGRint            If 0 owner is not eligible
                                           If 1 owner is eligible
 
Return Values
    MSSUCC   -  if successful completion 
    MSFAIL   -  if error occurred
\*/
#argsused
IGRint GRowner_locate_processing1 ( msg, 
                                    cvl, 
                                    path, 
                                    path_position, 
                                    owner_eligible, 
                                    component_eligible,
                                    objid, 
                                    osnum, 
                                    properties, 
                                    local_cmp_eligible, 
                                    local_eligible)
    IGRlong           *msg;
    struct GRlc_cvl   *cvl;
    struct GRlc_path  *path;
    IGRint            *path_position;
    IGRint            *owner_eligible;
    IGRint            *component_eligible;
    GRobjid           objid;
    GRspacenum        osnum;
    IGRint            properties;
    IGRint            local_cmp_eligible;
    IGRint            local_eligible;
{
    IGRlong              om_msg;
    IGRlong              ret_msg;
    IGRlong              prism_rel;
    IGRlong              comp_rel;
    IGRint               local_own_eligible;     /* owner eligiblity for    */
                                                 /* my components           */
    IGRint               local_locate;           /* my locatablility        */
    IGRint               temp_path_position;
    IGRint               i;
    IGRshort             prism_type;
    IGRlong              save_attr;
    enum GRlocate_action action;

    om_msg = OM_S_SUCCESS;

    /* fix start for TR# 119422552 : - Detected by Purify

    *  When the path result is GR_LC_PROCESSED for a prism locate, 
    *  the variable comp_rel is not set. This is resulting in less
    *  number of elements located by CVE. To fix the problem, initialize
    *  the variable comp_rel to -1.  

    */

    comp_rel = -1;

    /* fix end - TR# 119422552  */

    local_own_eligible = local_eligible | *owner_eligible;
    local_locate = FALSE;
    if (local_own_eligible || local_cmp_eligible) 
    {
        /*
         *  Determine if I am geometrically locatable.
         */
        if ( GRprocess_component(cvl, path, path_position, properties) ||
             local_cmp_eligible)
        {
            /*
             *  My component has not been processed or it is eligible
             *  for locate.  Send it the GRlocate_processing message.
             *  The prism_attr field is set so that the true relationship of
             *  the component may be found.  Note that the true relationship
             *  of components is also found in the GRprismrel_owner method.
             */

	  if ( *path_position )
	  {
	    /* Purify fix -  case *path_position = 0 
       	     * I may not have any components for locate, hence don't do anything 
	    */
	
            save_attr = cvl->prism_attr;
            cvl->prism_attr = 0;

            temp_path_position = *path_position - 1;
            om_msg = om$send (msg = message GRgraphics.GRlocate_processing 
                                                      ( msg,
                                                        cvl, 
                                                        path, 
                                                        &temp_path_position, 
                                                        &local_own_eligible,
                                                        &local_cmp_eligible),
                              senderid = objid,
                              targetos = path[*path_position - 1].lc_info.located_obj.osnum,
                              targetid = path[*path_position - 1].lc_info.located_obj.objid);
            cvl->prism_attr = save_attr;
	  }	  

        }

        if (path[*path_position].result != GR_LC_NORESULT) 
        {
            if (local_eligible)
                if ((path[*path_position].result & GR_LC_HIT) == GR_LC_HIT)
                    local_locate = TRUE;
        }
        else 
        {
            path[*path_position].result = GR_LC_PROCESSED;
            switch (cvl->attributes.type) 
            {
            case GR_nam_loc:
                if (path[*path_position].name_entry) 
                {
                    local_locate = TRUE;
                    path[*path_position].result = GR_LC_HIT;
                    path[*path_position].action = add_all;
                }
                break;

            case GR_crit_loc:
                local_locate = TRUE;
                path[*path_position].result = GR_LC_HIT;
                path[*path_position].action = add_all;
         
                /*
                 *  Post the graphics object.
                 */
                action = post_object;
                om_msg = (*cvl->action_handler)( (cvl->act_parms),
                                                 &path[*path_position].lc_info, 
                                                 (cvl->locate_args), 
                                                 &action);
                break;

            case GR_pt_loc:
            case GR_bl_loc:
                /*
                 *  If my component was located then I a located.
                 */
                if ( (path[*path_position - 1].result & GR_LC_HIT) == GR_LC_HIT) 
                {
                    local_locate = TRUE;
                    path[*path_position].result = GR_LC_HIT;
                    path[*path_position].action = add_all;

                    path[*path_position].lc_info.module_info = 
                       path[*path_position - 1].lc_info.module_info;
                    path[*path_position].lc_info.geom_parms =
                       path[*path_position - 1].lc_info.geom_parms;

                    for (i=0; i < 3; ++i)
                        path[*path_position].lc_info.proj_pnt[i] =
                        path[*path_position - 1].lc_info.proj_pnt[i];

/************************** KLUDGE ***********************************
   This should be done but is not because the locate filter is not
   supporting the functionality.

                    if (local_eligible) {
                        action = post_object;
                        om_msg = (*cvl->action_handler)( (cvl->act_parms),
                                                         &path[*path_position].lc_info, 
                                                         (cvl->locate_args), 
                                                         &action);
                    }
************************** KLUDGE *************************************/
                }
                break;
   
            case GR_cv_loc:
            case GR_rp_loc:

                prism_type = (cvl->attributes.type == GR_rp_loc) ? 0 : 1;

                if (path[*path_position - 1].result != GR_LC_NORESULT) 
                {
                    switch (path[*path_position - 1].result) 
                    {
                    case GR_LC_INSIDE:
                        comp_rel = INSIDE;
                        break;

                    case GR_LC_OUTSIDE:
                        comp_rel = OUTSIDE;
                        break;

                    case GR_LC_OVERLAP:
                        comp_rel = OVERLAP;
                        break;
                    }

                    om_msg = om$send ( msg = message GRowner.GRprismrel_owner 
                                              ( &ret_msg, 
                                                &cvl->module.md_env.matrix_type, 
                                                cvl->module.md_env.matrix, 
                                                &cvl->prism_attr,
                                                &path[*path_position -1].lc_info.located_obj,
                                                &comp_rel, 
                                                &prism_type,
                                                (prism_type) ? 
                                                (IGRchar *)&cvl->attributes.acc_cv_prism :
                                                (IGRchar *)&cvl->attributes.acc_rt_prism, 
                                                &prism_rel), 
                                       senderid = objid, targetid = objid);
                }
                else 
                {
                    om_msg = om$send ( msg = message GRowner.GRprismrel_owner 
                                              ( &ret_msg, 
                                                &cvl->module.md_env.matrix_type, 
                                                cvl->module.md_env.matrix, 
                                                &cvl->prism_attr,
                                                NULL, 
                                                NULL, 
                                                &prism_type,
                                                (prism_type) ? 
                                                (IGRchar *)&cvl->attributes.acc_cv_prism :
                                                (IGRchar *)&cvl->attributes.acc_rt_prism, 
                                                &prism_rel),
                                       senderid = objid, targetid = objid);
                }
            
                /*
                 *  Is the objects relationship to the prism the requested
                 *  relationship?
                 */
                if (om_msg & ret_msg & 1) 
                {
                    local_locate = TRUE;
                    if (prism_rel == 1) 
                    {
                        path[*path_position].result = GR_LC_INSIDE;
                        path[*path_position].action = add_inside;
                    }
                    else if (prism_rel == 2) {
                        path[*path_position].result = GR_LC_OVERLAP;
                        path[*path_position].action = add_overlap;
                    }
                    else {
                        path[*path_position].result = GR_LC_OUTSIDE;
                        path[*path_position].action = add_outside;
                    }
                }

                action = post_object;
                om_msg = (*cvl->action_handler)( (cvl->act_parms),
                                                 &path[*path_position].lc_info, 
                                                 (cvl->locate_args), &action);
                break;
            }

            if (local_locate && local_eligible && 
                *msg != GRNO_PROCESSING_NEEDED) 
            {
                /* 
                 * Is this a top down locate?  
               path[*path_position].call_action_handler = TRUE;
                 */

               if (!(cvl->attributes.obj_attr.owner_action & 
                     LC_BOTTOM_UP))
               {
                   path[*path_position].call_action_handler = 1;
               }
               else
               {
                 IGRboolean call_action=TRUE, stop_on_assoc=FALSE;
     
                 if (cvl->attributes.obj_attr.owner_action & LC_STOP_ON_ASSOC)
                 {
                   IGRlong dlb_msg;
                   IGRshort props=NULL;
                   om$send(msg=message GRgraphics.GRgetprops(&dlb_msg, &props),
                           senderid=NULL_OBJID,targetid=objid,targetos=osnum);
                   if (!(props & GRIS_ASSOCIATIVE)) call_action = FALSE;
                   else stop_on_assoc = TRUE;
                 }

                 if (call_action)
                 {
                   om_msg = (*cvl->action_handler)( cvl->act_parms,
                           &path[*path_position].lc_info,cvl->locate_args,
                           &path[*path_position].action);

                   if ((cvl->attributes.obj_attr.owner_action & LC_BOTTOM_UP)
                       && !stop_on_assoc 
                       && om_msg == OM_I_STOP_SENDING)
                       *msg = GRNO_PROCESSING_NEEDED;

                   /*DLB*/
                   if (stop_on_assoc) 
                       *msg = GRNO_PROCESSING_NEEDED;
                 }
               }
            }
        }
    }

    return (om_msg);
}


/*\
Name
    GRprocess_component

Description
    This is a helper function for the locate processing method for
    owners.  It will determine if the locate processing method for
    the components should be called.

    *cvl           struct GRlc_cvl   Locate structure
    path[]         struct GRlc_path  The locate path
    *path_position IGRint            The position in the path
    properties     IGRint            locate properties of owner

Return Values
    0  -  do not call the component locate processing method
    1  -  call the component locate processing method
\*/
IGRint GRprocess_component(cvl, path, path_position, properties)
    struct GRlc_cvl   *cvl;
    struct GRlc_path  path[];
    IGRint            *path_position;
    IGRint            properties;
{
    IGRint   process;    /*  TRUE if component should be called for locate  */
                         /*  processing.                                    */
                         /*  FALSE if component should not be called for    */
                         /*  locate processing.                             */
                     
    IGRint   position;	 /* introduced to fix, abr detected by Purify	    */

    process = FALSE;

    if ( *path_position > 0 )
       position = *path_position - 1;
    else
       position = *path_position;

    if (!path[*path_position].name_entry) 
    {
        if ((cvl->attributes.type == GR_rp_loc) || 
            (cvl->attributes.type == GR_cv_loc) ||
            (cvl->attributes.type == GR_crit_loc) )
        {
	    /* Purify - if the owner gets hit first, no components will
	       be in the processed path, hence look for right path position */

            if ( (path[position].result == GR_LC_NORESULT) &&
                 (!(properties & GR_LC_NO_PRM_COMP)))
                process = TRUE;
        }
        else if (path[position].result == GR_LC_NORESULT)
            process = TRUE;
    }

    return (process);
}
end implementation GRowner;

