/* ###################   APOGEE COMPILED   ################## */
class implementation ECmarktan;

/*

   Command:       Mark Tangent Edges
   Specification: 

   Notes: 
   This command object will allow the user to locate a solid or 
   composite surface, and have the system mark any common edges 
   that are tangency.


   History:
   July 11 1992  Jack  Creation
   Sept 03 1992  Dave  ANSI compliance. 
   Sept 06 1992  Jack  Added processing status messages during processing.
   Aug  14 1994  scw   Clarified sleep method
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


# ifndef DEBUG
# define DEBUG 0
# endif

/* states */
#define BEGIN_STATE        0
#define LOC_SOLID_COMPSURF 1

#define NUM_PTS  2  /* number of points on edge for testing tangency */

from EMSsurface import EMgetInfoAboutComponents;
from EMSsubbs   import EMget_tan_btn_surfs;
from EMSedge    import EMset_props;

extern IGRlong EMselective_fence();
extern void EFfreeComponentInfoMem();

extern OMuword OPP_EMScompsurf_class_id;

method init (IGRint type; IGRchar *string)
{
  ME.super_cmd->mytype = type;
  return (OM_S_SUCCESS);
}

method wakeup (IGRint pos)
{

 ex$message(msgnumb = EM_M_MkTnEd )

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
  OMuword   solids;
  OM_S_CLASSLIST	yes_classes, 
                        no_classes;
  IGRlong               numb_objs = 0; 
  struct GRlc_info     *group_objs;
  IGRint    num_comp_info=0;
  struct EMScomponent_info *comp_info = NULL;
  IGRdouble len = 1.0;
  IGRdouble *angles=NULL;
  IGRint num_pts = 2;
  IGRint num = 0,
         num_surfs = 0,
         num_com_sf = 0;
  IGRlong event_size = 0;
  struct GRid sf_grid;
  IGRushort props = 0;
  IGRshort  option = 0;

  angles = (IGRdouble *) om$malloc(size = NUM_PTS * sizeof(IGRdouble));

  
 do
  {
   switch(ME.super_cmd->state)
    {

   case BEGIN_STATE:
     ME.super_cmd->state = LOC_SOLID_COMPSURF;
     break;

   case LOC_SOLID_COMPSURF:

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
       r_classes[0] = OPP_EMSsurface_class_id; /* this will get solids too */
       e_classes[0] = OPP_EMScompsurf_class_id;

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
           locate_key = EMS_P_IdSlCmSf,  /*identify solid/composite surface */
           acc_key = EMS_P_AcceptNextSolCompSurf,
           relocate_key = EMS_S_SolCompSurfNotFnd,
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

            solids = OPP_EMScompsurf_class_id;
            no_classes.w_count = 0;
            yes_classes.w_count = 1;
            yes_classes.p_classes = &solids;
       
            numb_objs = 0;
            group_objs = NULL;
           
            status = EMselective_fence(&yes_classes,
                                    &no_classes,
                                    &locate_event.located_object[0],
                                     FALSE, /* don't break_down_composites */
                                     FALSE, /* is_operation_readonly */
                                     my_id,
                                    &numb_objs,
                                    &group_objs,
                                    &EMmsg);
            if(! (1 & status & EMmsg)) goto wrapup;

            if (!numb_objs)
            {
             ex$message(msgnumb = EMS_S_InvInp )
             dp$erase_hilite(msg = &EMmsg);
             break;
            }

            me->num_solids = numb_objs;


            /* do vla stuff here to set size of locobj vla */
            status = om$vla_set_dimension(varray = me->locobj,
                                       size = me->num_solids);
            if (! (1 & status)) goto wrapup;



            for(num=0; num < me->num_solids; num++)
             {

              me->locobj[num] = group_objs[num];

              /*
               * for each solid, send the message to get
               * the groups of adjacent surfaces with common
               * edges.
               */
              status = om$send(msg = message EMSsurface.EMgetInfoAboutComponents(
                                &EMmsg, 
                                &num_comp_info,
                                &comp_info),
                   mode = OM_e_wrt_message,
                   senderid = my_id,
                   targetid = me->locobj[num].located_obj.objid,
                   targetos = me->locobj[num].located_obj.osnum);
              if (!(1 & status & EMmsg)) goto wrapup;
  
              sf_grid.osnum = me->locobj[num].located_obj.osnum;

              /* 
               * pair up each surface with its common edge
               * surfaces and send the message to determine 
               * if the common edge is tangent.
               */
              for(num_surfs=0; num_surfs < num_comp_info; num_surfs++)
               {
                for(num_com_sf=0; 
                        num_com_sf < comp_info[num_surfs].num_adjoin_info;
                              num_com_sf++)
                  {
                   sf_grid.objid = comp_info[num_surfs].surf_id;
/*           comp_info[num_surfs].adjoin_info[num_com_sf].adjoining_surf_id; */

                   /*
                    * Note: may need to check the other_edge_pairs in 
                    * addition to the first_edge_pair.
                    */
                   status = om$send(msg = message EMSsubbs.EMget_tan_btn_surfs(
                          &EMmsg,
                          &me->locobj[num].module_info.md_env,
                          &sf_grid,
                          &comp_info[num_surfs].adjoin_info[num_com_sf].first_edge_pair[0],
                           NULL,
                           num_pts,    /* number of points to test on edge */
                          &len, 
                           NULL, 
                           NULL,
                           angles),
                    senderid = my_id,
                    targetid = comp_info[num_surfs].surf_id,
                    targetos = me->locobj[num].located_obj.osnum);
                  if (!(1 & status & EMmsg)) goto wrapup;
                  

                  if((angles[0] == 0.0) && (angles[1] == 0.0))
                   {
                    /* the two tested points show this edge to be tangent */
                    props |= EMED_TANGENT;
                    option = EMS_O_ON;
                    status = om$send(msg = message EMSedge.EMset_props(
                                            &EMmsg, 
                                             props,
                                             option),
                    senderid = my_id,
                    targetid = 
                    comp_info[num_surfs].adjoin_info[num_com_sf].first_edge_pair[0],
                    targetos = me->locobj[num].located_obj.osnum);
                    if (!(1 & status & EMmsg)) goto wrapup;

                   }
                                     
                  } /* for each common surface */                 
                 
               } /* for each surface of the current solid */
              
             } /* for each solid */
            me->num_solids = 0;

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
                     locate_key = EMS_P_IdSlCmSf,  /*identify solid/composite surface */
                     acc_key = EMS_P_AcceptNextSolCompSurf,
                     relocate_key = EMS_S_SolCompSurfNotFnd,
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


          /* return to top of do and process this solid */
         } while(TRUE); /* end do-while, infinite loop, will exit when
                           the user finishes locating solids. */
       me->num_solids = 0;
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

  if(comp_info)
    EFfreeComponentInfoMem(num_comp_info, 
                           comp_info);
 
  if(angles)
     om$dealloc(ptr = angles);

 return (OM_S_SUCCESS);
}

method super_cmd.sleep (IGRint pos)
{


  UI_prompt ("");
  UI_message ("");
  

  return (OM_S_SUCCESS);
}

end implementation ECmarktan;
