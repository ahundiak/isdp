class implementation Root;

#define SUCCESS         1
#define NO_ELEMENTS     2
#define LOOP            3
#define RETCONTROL      4

/*
Abstract
	This routine is called from LCcselect.  It performs the
	accept/reject cycle of the locate filter.  This routine is
	called only when the default case of element hilight is requested.

Algorithm

        If only one element in stack 
	    set accept = 1

        while (exit_code && the stack has entries)
            get the type of element and layer (LCgetinfo)
            set proper place to hilight
            set hilight mode
            hilight the element
            if accept = 1
                goto quit with accept codes
            set up dynamics
            check for locate cursor
            get an input
            clean up locate cursor (if necessary)
            if input = RESET
                if hilite_erarse
                    erase hilite plane
                else
                    draw element in background
                check to see if more elements in stack
            else if UNKNOWN
                set return codes for unknow type
            else
                if DATA
                    if PROJECT ACCEPT POINT
                        if boreline
                            get boreline projection (LCget_parms)
                        else
                            get point projection    (LCget_parms)
                set accept return codes
            if error occured
                if hilite_erase
                    erase hilite plane
                else
                    draw element in background
      return
            
History
	7/20/87	Started documentation
*/


#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dpdef.h"
#include "dp.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "codebug.h"
#include "dpmacros.h"
#include "igrmacros.h"
#include "exmacros.h"

from GRgraphics import GRdisplay;

#define st_mod     stack->entry[stack->num_entries - 1].module_info
#define st_ent     stack->entry[stack->num_entries - 1]

IGRint  QYselect (msg, select_info, select_args)
IGRlong                   *msg;
struct LC_select_args     *select_info;
IGRchar                   *select_args;
{

    IGRint                  i;
    OMuint                  count;
    IGRlong                 om_msg = OM_S_SUCCESS,
                            ret_code,
                            new_mask,
                            exit_code,
                            string_status;
    IGRshort                accept = 0;
    IGRchar                 info[75],
                            class_name[80];
    IGRmatrix              *mat[1];
    struct GRid             dis_id,
                            dir_grid, module_grid;
    enum GRdpmode           display_mode;
    OM_S_CHANSELECT         to_comp_chandef,
                            to_own_chandef;
    OM_S_OBJECT_LINKAGE    *channel_list = NULL;

    IGRint                 *response;
    IGRlong                *mask,
                           *display_flag;
    IGRchar		   *acc_prompt,                                  
                           *response_data,
                           *obj_hilighted;
    IGRboolean             *is_bore;
    struct GRevent         *accept_event,
                           *acc_event1;
    struct GRlc_stack      *stack;
    struct GRlc_dynamics   *dyn;        


    response_data =  select_info->response_data;
    obj_hilighted =  select_info->obj_hilighted;
    acc_prompt    =  select_info->acc_prompt;
    is_bore       =  select_info->is_bore;
    response      =  select_info->response;
    mask          = &select_info->eventmask;
    display_flag  = &select_info->display_flag;
    stack         =  select_info->stack;
    dyn           =  select_info->dyn;
    accept_event  =  select_info->accept_event;
    acc_event1    =  select_info->acc_event1;

    *msg = LC_OBJ_LOCATED;
    exit_code = LOOP;

    if ( (LC_ACC_ONE_ELEMENT & *display_flag) && stack->num_entries == 1 ) 
    {
        accept = 1;
    }

    while ((exit_code == LOOP) && (stack->num_entries) ) 
    {

       LCget_info(st_ent.located_obj.objid, st_ent.located_obj.osnum,info);

       /*
        *   Highlight the element in one or all windows
        */

       if (*display_flag & ALL_WINDOWS) 
       {
          dis_id = stack->module;
       }
       else 
       {
          dis_id = stack->window;
       }
       mat[0] = (IGRmatrix *) st_mod.md_env.matrix;

       /*
        *  highlight all boundaries in all windows
        */
       display_mode = GRhhd;

       om_msg = om$get_classname( classname = class_name,
                                  objid = st_ent.located_obj.objid,
                                  osnum = st_ent.located_obj.osnum );

       /*
        *  check the classname
        */
       om_msg = om$is_ancestry_valid( subclassname = class_name,
                                      superclassname = "GRgrgrp" );

       string_status = strcmp( class_name, "GRgrgrp" ) == 0;

       if (! ((om_msg == OM_I_INVANCESTRY) && (!string_status)) )
       {
          om_msg = om$make_chanselect(channame = "GRcmpowner.to_components",
                                      p_chanselect = &to_comp_chandef );

          om_msg = om$get_channel_count( objid = st_ent.located_obj.objid,
                                         osnum = st_ent.located_obj.osnum,
                                         p_chanselect = &to_comp_chandef,
                                         count = &count);

          channel_list = (OM_S_OBJECT_LINKAGE *)om$malloc(size = 
                                  (sizeof(OM_S_OBJECT_LINKAGE)) * count);

          /*
           * Get objid and object space number of GO
           */
          om_msg = om$get_channel_objects( objid = st_ent.located_obj.objid,
                                           osnum = st_ent.located_obj.osnum,  
                                           p_chanselect = &to_comp_chandef,
                                           list  =  channel_list,
                                           size  =  count,
                                           count = &count);

          for( i = 0; i < count; i++ )
          {
             dir_grid.osnum = OM_Gw_current_OS;
             dir_grid.objid = channel_list [i].S_objid;

             ex$get_cur_mod(id = &module_grid.objid, osnum = &module_grid.osnum );
	
             om_msg = om$send(msg = message GRgraphics.GRdisplay(msg,
				    &st_mod.md_env.matrix_type,
				     st_mod.md_env.matrix,
				    &display_mode,
				    &module_grid ),
                              senderid = NULL_OBJID,
                              targetid = channel_list [i].S_objid );
          }                			   

          om$dealloc(ptr = channel_list);
       }
       else
       {
          dir_grid.osnum = st_ent.located_obj.osnum;
          dir_grid.objid = st_ent.located_obj.objid;

             ex$get_cur_mod(id = &module_grid.objid, osnum = &module_grid.osnum );
	
          om_msg = om$send(msg = message GRgraphics.GRdisplay(msg,
				    &st_mod.md_env.matrix_type,
				     st_mod.md_env.matrix,
				    &display_mode,
				    &module_grid ),
                              senderid = NULL_OBJID,
                              targetid = dir_grid.objid, targetos = dir_grid.osnum );

       }
       
       if (!(om_msg & 1)) 
       {
            *msg = LC_RELOCATE;
            *display_flag = LC_RELOCATE;
            return ( 0 );
       }

      *obj_hilighted = TRUE;
       UI_status (info);

       if (accept) 
       {
            ret_code = 1;
            *msg = LC_OBJ_LOCATED;
            exit_code = SUCCESS;
            acc_event1->located_object[0] =
                                    stack->entry[stack->num_entries - 1];
            acc_event1->num_id++;
            stack->num_entries = 0;
            goto quit;
        }

        /*
         *    Call dynamics function if the pointer is specified
         */  

        if (dyn) 
        {
            dyn->GRlc_event.located_object[0] = st_ent;
            dyn->GRlc_object = st_ent.located_obj;
            (*dyn->GRlc_dyn) (&dyn->GRlc_object, &dyn->GRlc_event, 
                              dyn->add_info);
        }        

        new_mask = *mask | GRm_RESET;
        if (*display_flag & LC_ACCEPT_CURSOR) 
        {
            LCdef_cursor ();
        }
        if (co$getevent (msg = &om_msg,
                         event_mask = new_mask,
                         prompt = acc_prompt,
                         response = response,
                         response_data = response_data,
                         event = accept_event) 
             == MSFAIL)
        {
            *msg = LC_NO_OBJ_LOCATED;
            return (0);
        }
        if (*display_flag & LC_ACCEPT_CURSOR) 
        {
            LCrestore_cursor();    
        }
        switch (accept_event->response) 
        {

            /* 
             *  The case of the rejected object
             *     unhilight and increment stack if possible
             */

            case RESET:
                if(*display_flag & LC_ERASE_LOC_ELEMENT) 
                {

                   om_msg = dp$display (msg = msg,
                                        osnum = dis_id.osnum,
                                        objid = dis_id.objid,
                                        mode = GRbdhe,
                        oids = &stack->entry[stack->num_entries-1].located_obj,
                                        mtx_type = &st_mod.md_env.matrix_type,
                                        matrix = mat);
                }
		else 
                {
                    dp$erase_hilite(msg = &om_msg,
                                    objid = stack->module.objid,
                                    osnum = stack->module.osnum); 
                }
                if (!--stack->num_entries) 
                {
                    exit_code = NO_ELEMENTS;
                    *msg = LC_RELOCATE;
                    ret_code = 1;
                }
                else if (!(om_msg & 1)) 
                {
                    *msg = LC_NO_OBJ_LOCATED;
                    ret_code = 0;
                }
                *obj_hilighted = FALSE;
                break;

            case GR_UNKNOWN_TYPE:
                *msg = LC_UNKNOWN_TYPE;
                exit_code = RETCONTROL;
                ret_code = 1;
                break;

            default:
            /*
             *    The case of the accepted object.
             *                   Philip Marlowe
             *    The object is returned in highlight to 
             *    whoever called the located filter.
             */

	    if (accept_event->response == DATA) 
            {    

               /*
                *    If the third bit is not set in the display flag
                *    project the accept point onto the element using
                *    a point or boreline project depending on the
                *    type of locate that is occuring 
                */

               if (!(*display_flag & NO_PROJ_ACCEPT_POINT)) 
               {
                   if (*is_bore) 
                   {
                       if (!LCget_parms (accept_event->event.button.x,
                           accept_event->event.button.y,
                           accept_event->event.button.z, LC_LNPROJECT,
                           st_ent.located_obj.objid, st_ent.located_obj.osnum,
                           accept_event->event.button.objid,
                           accept_event->event.button.osnum,
                           st_ent.proj_pnt, &st_ent.geom_parms,
                           st_mod.md_env.matrix_type, st_mod.md_env.matrix)) 
                       {

                           *msg = LC_NO_OBJ_LOCATED;
                           ret_code = 0;
                           goto quit;
                       }
                   }
                   else
                   {
                       if (!LCget_parms (accept_event->event.button.x,
                           accept_event->event.button.y,
                           accept_event->event.button.z, LC_PTPROJECT,
                           st_ent.located_obj.objid, st_ent.located_obj.osnum,
                           accept_event->event.button.objid,
                           accept_event->event.button.osnum,
                           st_ent.proj_pnt, &st_ent.geom_parms,
                           st_mod.md_env.matrix_type, st_mod.md_env.matrix)) 
                       {
                           *msg = LC_NO_OBJ_LOCATED;
                           ret_code = 0;
                           goto quit;
                       }
                   }
               }
          }
          ret_code = 1;
          *msg = LC_OBJ_LOCATED;
          exit_code = SUCCESS;
          acc_event1->located_object[0] = stack->entry[stack->num_entries - 1];
          acc_event1->num_id = 1;
          stack->num_entries = 0;
          break;
      }
   }  /* end while */

    /*
     *   Unhilight the element if necessary.
     */

    if (*obj_hilighted && (exit_code == RETCONTROL))
    {
        if(*display_flag & LC_ERASE_LOC_ELEMENT) 
        {
            om_msg = dp$display (msg = &om_msg,
                                 osnum = dis_id.osnum,
                                 objid = dis_id.objid,
                                 mode = GRbdhe,
                        oids = &stack->entry[stack->num_entries-1].located_obj,
                                 mtx_type = &st_mod.md_env.matrix_type,
                                 matrix = mat);
        }
        else 
        {
           dp$erase_hilite(msg = &om_msg,
                           objid = stack->module.objid,
                           osnum = stack->module.osnum); 
        }
        UI_status ( "" );
        *obj_hilighted = FALSE;
    }
quit:
    return( ret_code );
}


end implementation Root;
