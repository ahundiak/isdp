/* ###################   APOGEE COMPILED   ################## */
class implementation ECdelgralp;

/*

   Command:       Delete Surface Feature


   Notes: 
   This command object will allow the user to locate a surface
   that will get all of its surface features (EMSgraloops) removed.


   History:
   Sept 28 1992  Jack  Creation
   Nov  15 1992  Jack  Ansi compliance.
   08/14/94      scw    Intel Solaris port ( sleep method )


*/

#include "EMS.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include <stdio.h>
#include <string.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "codef.h"
#include "codpdef.h"
#include "griodef.h"
#include "grio.h"
#include "EMSdpb.h"
# include "griomacros.h"    /* co$getevent */
# include "EMSlogic.h"      /* EMSokay */
#include "igrdef.h"
#include "dpmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "grmsg.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "detaildef.h"
#include "EMSdprquery.h"
#include "grgsmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "emsdef.h"


# ifndef DEBUG
# define DEBUG 0
# endif

/* states */
#define BEGIN_STATE        0
#define LOC_SURF           1


extern IGRlong EMselective_fence();

extern OMuword  OPP_EMSgraloop_class_id,
                OPP_EMSsurface_class_id,
                OPP_EMSsubbs_class_id;

method init (IGRint type; IGRchar *string)
{
  ME.super_cmd->mytype = type;
  return (OM_S_SUCCESS);
}

method wakeup (IGRint pos)
{

 ex$message(msgnumb = EM_M_DlSfFea )

  return (OM_S_SUCCESS);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{


  IGRlong EMmsg,
          status,
          locate_mask, 
          accept_mask, 
          display_flag;
  struct GRlc_locate attributes;
  OMuword         r_classes[2], e_classes[2];
  struct GRevent  accept_event,
                  locate_event;
  OM_S_CLASSLIST  rtree_classes, eligible_classes;  
  IGRlong         object_was_located;  
  OMuword   surfaces;
  OM_S_CLASSLIST	yes_classes, 
                        no_classes;
  IGRlong               numb_objs = 0; 
  struct GRlc_info     *group_objs=NULL;
  IGRint num = 0,
         cnt=0;
  IGRlong event_size = 0;
  OMuint obj_count=0;
  OM_S_CHANSELECT       to_helpers;
  OM_S_OBJECT_LINKAGE *channel_objects = NULL;
  OMuword obj_classid;

  
 do
  {
   switch(ME.super_cmd->state)
    {

   case BEGIN_STATE:
     ME.super_cmd->state = LOC_SURF;
     break;

   case LOC_SURF:

      locate_mask = GRm_DATA | GRm_OBJID | GRm_SPECIFIED_OBJ | GRm_RESTART;
      accept_mask = GRm_DATA | GRm_RESTART | GRm_RJT_MOVEON;

       display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL;                   /* Erase the hilite plane */
       attributes.properties = 
        LC_LC_NONLC             |       /* Locate locatable and nonloc objects */
        LC_DP_INVIS             |       /* Locate displayable and invis objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* Locate read and write objects */
       attributes.owner_action = 
        LC_RIGID_OWNER  |              
        LC_RIGID_COMP   |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */


       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsurface_class_id;

       ex$message(msgnumb = EMS_S_ClearStatusField) 

     /*
      * first locate the solid or composite surface 
      */
     status = gr$gslocate (
           msg    = &object_was_located,
           event1 = &me->locate_event,
           event2 = &accept_event,
           locate_event = &locate_event,
           mask1  =  locate_mask,
           mask2  =  accept_mask,
           display_flag = display_flag,
           unhilight_mode = (enum GRdpmode ) GRbdhe,           
           locate_key = EMS_P_00031,           /* Identify surface */
           acc_key = EMS_P_AccwSf, 
           relocate_key = EMS_I_00011,
           attributes =  &attributes,
           stack = &me->locate_stack,
           num_inputs = 0,
           p_chanselect = NULL,
           rtree_classes    = &rtree_classes,
           eligible_classes = &eligible_classes);



      if((!object_was_located) || (accept_event.response IS GR_UNKNOWN_TYPE))
       {
         dp$erase_hilite(msg = &EMmsg);
         return(OM_S_SUCCESS);
       }
      else 
        do
         {
            ex$message(msgnumb = EMS_S_Processing )
             
            surfaces = OPP_EMSsurface_class_id;
            no_classes.w_count = 0;
            yes_classes.w_count = 1;
            yes_classes.p_classes = &surfaces;
       
            numb_objs = 0;
            group_objs = NULL;
           
            status = EMselective_fence(&yes_classes,
                                    &no_classes,
                                    &locate_event.located_object[0],
                                     TRUE, /* don't break_down_composites */
                                     FALSE, /* is_operation_readonly */
                                     my_id,
                                    &numb_objs,
                                    &group_objs,
                                    &EMmsg);
            if(! (1 & status & EMmsg)) goto wrapup;

            if (!numb_objs)
            {
             ex$message(msgnumb = EMS_S_InvInp) 
             dp$erase_hilite(msg = &EMmsg);
             break;
            }

            me->num_surfaces = numb_objs;


            /* do vla stuff here to set size of locobj vla */
            status = om$vla_set_dimension(varray = me->locobj,
                                       size = me->num_surfaces);
            if (! (1 & status)) goto wrapup;


         /*
          * this is the meat of the command
          * for each surface...
          */ 
         for(num=0; num < me->num_surfaces; num++)
          {
            me->locobj[num] = group_objs[num];

            status = EMmake_chanselect( EMSrequester_to_helpers, &to_helpers );
            if(! (1 & status)) goto wrapup;
  
            /*
             * get the count of objects on the EMShelper channel
             */
            status = om$get_channel_count( objid = me->locobj[num].located_obj.objid,
                                           osnum = me->locobj[num].located_obj.osnum,
                                           p_chanselect = &to_helpers,
                                           count = &obj_count ); 
            if(! (1 & status)) goto wrapup;
     
            if(obj_count)
             {
              channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                 OM_S_OBJECT_LINKAGE)*obj_count);

             /*
              * get the objects
              */
             status = om$get_channel_objects( objid = me->locobj[num].located_obj.objid,
                                              osnum = me->locobj[num].located_obj.osnum,
                                              p_chanselect = &to_helpers,
                                              list = channel_objects,
                                              size = obj_count,
                                              count = &obj_count);
             if(! (1 & status)) goto wrapup;
     
             /*
              * for each object, get the classid and see
              * if it is an EMSgraloop object, if so, delete it.
              */
              for(cnt = 0; cnt < obj_count; cnt++)
               {
                 status = om$get_classid( objid = channel_objects[cnt].S_objid,
                                          osnum = channel_objects[cnt].osnum,
                                          p_classid = &obj_classid );
                 if(! (1 & status)) goto wrapup;             
     
                 if( obj_classid == OPP_EMSgraloop_class_id )
                  {
                   status =  om$send(msg     = message Root.delete(1),
                                     targetid = channel_objects[cnt].S_objid,
                                     targetos = channel_objects[cnt].osnum);
                   if(! (1 & status)) goto wrapup;
                  } /* end if EMSgraloop class */
    
               } /* end for each helper object */
             } /* end if this surface had helper objects */
          } /* for each surface */   


            me->num_surfaces = 0;

            if (accept_event.response != EX_OBJID)
             { 
               /* push the accept event on the software queue unless
                  there was an event generator
                */
               event_size = sizeof(accept_event.event) + sizeof(IGRint);
               status = ex$putque(msg      = &EMmsg,
                                  response = &accept_event.response, 
                                  byte     = &event_size,
                                  buffer   = (char *)&accept_event.event);
               if (!(1 & status & EMmsg)) goto wrapup;
             }

           ex$message(msgnumb = EMS_S_ClearStatusField) 

           status = gr$gslocate (
                     msg    = &object_was_located,
                     event1 = &me->locate_event,
                     event2 = &accept_event,
                     locate_event = &locate_event,
                     mask1  =  locate_mask,
                     mask2  =  accept_mask,
                     display_flag = display_flag,
                     unhilight_mode = (enum GRdpmode ) GRbdhe,           
                     locate_key = EMS_P_00031,           /* Identify surface */
                     acc_key = EMS_P_AccwSf, 
                     relocate_key = EMS_I_00011,
                     attributes =  &attributes,
                     stack = &me->locate_stack,
                     num_inputs = 0,
                     p_chanselect = NULL,
                     rtree_classes    = &rtree_classes,
                     eligible_classes = &eligible_classes);

           if((!object_was_located) || (accept_event.response IS GR_UNKNOWN_TYPE))
            {
             dp$erase_hilite(msg = &EMmsg);
             if(group_objs) 
               {
               om$dealloc(ptr = group_objs);
               group_objs = NULL;
               }
             return(OM_S_SUCCESS);
            }

/* fix for mlk */
          if(group_objs) 
            {
            om$dealloc(ptr = group_objs);
            group_objs = NULL;
            }
          /* return to top of do and process this solid */
         } while(TRUE); /* end do-while, infinite loop, will exit when
                           the user finishes locating surfaces. */
       me->num_surfaces = 0;
      break;   


/*
 * Something has messed up our state table
 */
     default:
#ifdef DEBUG
     printf("default state: problem.");
#endif
      break;
    }
  }
 while(TRUE);

wrapup:
  *response = TERMINATE;
 if(group_objs)
   {
   om$dealloc(ptr = group_objs);
   group_objs = NULL;
   }

 return (OM_S_SUCCESS);
}

method super_cmd.sleep (IGRint pos)
{


  UI_prompt ("");
  UI_message ("");
  

  return (OM_S_SUCCESS);
}

end implementation ECdelgralp;
