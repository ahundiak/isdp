/* ###################   APOGEE COMPILED   ################## */
class implementation EChoriz;

/*
   HISTORY
   
   09-July-91  Jack  Creation
   01-Aug-91   Jack  Added two break statements that were needed 
                     in the big switch statement in execute.
   09-Aug-91   Jack  Changed the module env. stuff sent with the 
                     GRdisplay from that of the located object to 
                     that of the master file.  Problem occured when
                     located object was in a reference file.
   13-Aug-91   Jack  Changed locate class eligibility from
                     OPP_EMSsubbs_class_id to OPP_EMSsurface_class_id.
                     Had a problem locating solid cylinders.
   13-Aug-91   Jack  Added option to delete the horizon loop from
                     the located surface for the specified orientation.
   22-Aug-91   Jack  Changed to updated message keys that will work with
                     the new icons.
   29-Aug-91   Jack  Changed so that locate point is used to determine
                     view rather than accept point.
   15-Sep-91   Jack  Made changes to support reference planes.
   16-Oct-91   Jack  UMS changes for message keys for command names.
   23-Nov-91   Jack  Don't allow backup to identify a reference plane
                     for the Delete horizon edge command.
   31-Dec-91   Jack  Cause the associativity button to turn blue when 
                     this command is used.  Restore the button before
                     exiting.
   5-july-93   Sudha Modified for BSprototypes ansification
   14-aug-94   scw   clarified sleep method

   NOTES
   This command-object is used to place horizon/cusp edges on a 
   specified surface or set of surfaces in a specified orientation.
   The user may specify a reference plane to which the horizon loop
   will be associative.  If this reference plane is not parallel to
   a currently displayed view, a horizon loop with no edges will be placed.
   If the reference plane is then rotated to be parallel with some view,
   then the horizon edges will get updated and displayed.  If the user
   does not identify a reference plane, the horizon loop will be 
   placed with respect to the base reference plane of the chosen view.
   This reference plane is not known by the user, nor is it modifiable.

   When adding the chain locates to this command, it got kind of 
   complicated.  Here is the pseudo-code:

   begin_state:
     goto loc_sf_or_backup
   break;

   loc_sf_or_backup:
     set up loc criteria for sf in any OS
     lc$locate
     if(object_not_located)
         goto locate_ref_plane (since we know it was a backup)
     else 
      do 
        we have a data or group, process it
        push accept_event on queue
        lc$locate
        if(object_not_located)
            goto begin_state
      enddo 
  break;

  locate_ref_plane:
    set up locate criteria for reference plane in master file only
    lc$locate
     if(object_not_located)
         goto begin_state
     else 
        we have a ref plane, process it
        change locate criteria for surfaces in master file only
        do
          push accept_event on queue
          lc$locate
          if(object_not_located)
             goto locate_ref_plane
          else
            we have a surface, process it
        enddo 
  break;

*/

#include "EMS.h"
#include "EMSopt.h"
#include <string.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "codef.h"
#include "griodef.h"
#include "grio.h"
#include "EMSdpb.h"
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
# include "griomacros.h"    /* co$getevent */
# include "EMSlogic.h"      /* EMSokay */
#include "ECmsg.h"
#include "ECcmd.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "exdef.h"
#include "ex.h" 
#include "exmacros.h"
#include "DItypedef.h" 
#include "DIdef.h"
#include "EMSasnuc.h"

/* command states */
#define BEGIN_STATE             0
#define LOC_SF_OR_BACKUP        1
#define LOC_REF_PLANE           2

/* mytypes */
#define CREATE  0
#define DELETE  1

#define DEBUG 0
#if DEBUG
#include <stdio.h>                      /* Needed for print statements */
#endif

#include "matypemx.h"

from EMSsubbs   import EMget_graphics_edges;
from GRgraphics import GRdisplay;
from EMSdatpln  import EMget_pln_info;

extern OMuword OPP_EMSsurface_class_id,
               OPP_EMSsubbs_class_id,
	       OPP_EMSdatpln_class_id;

extern IGRlong EMselective_fence(),
               EFwin_parallel_ref_pln();
extern IGRint  GRdisplay_associative_button();


#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn EChorizi.I error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    goto wrapup;\
   }\
 }
#endif






method init (IGRint type; IGRchar *string)
{
  ME.super_cmd->mytype = type;
  return (OM_S_SUCCESS);
}

method wakeup(int pos)
{
   IGRlong        i, 
                  EMmsg, 
                  sts;
   enum           GRdpmode DisplayMode;
   struct GRlc_info *info;
   IGRint         size_buf,
                  bytes_ret;
   struct GRmd_env master_md_env;                 


   DisplayMode = GRhd;

   if(ME.super_cmd->mytype == CREATE )
    {
      /* turn on the associativity button */
      sts = GRdisplay_associative_button(1);

      ex$message(msgnumb = EM_M_PlHrCsEd )
      ex$message(msgnumb = EMS_S_BkUpIdRp )
    } 
       else if(ME.super_cmd->mytype == DELETE )
           ex$message(msgnumb = EM_M_DlHrEd )

   size_buf = sizeof(struct GRmd_env);

   gr$get_module_env(msg    = &EMmsg,
                     sizbuf = &size_buf,
                     buffer = &master_md_env,
                     nret   = &bytes_ret);

    for (i = 1; i <= me->numcrv; i++)
    {
        info = &me->locobj[i];
        sts = om$send(msg = message GRgraphics.GRdisplay
                           (&EMmsg,
                            &master_md_env.md_env.matrix_type,
                             master_md_env.md_env.matrix, 
                            &DisplayMode, 
                            &master_md_env.md_id),
                     senderid = my_id, 
                      targetid = info->located_obj.objid,
                      targetos = info->located_obj.osnum);
        if (!(1 & sts)) return(OM_E_ABORT);
    }

    return(OM_S_SUCCESS);
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{


  IGRlong    EMmsg,
             sts = OM_S_SUCCESS;
  IGRshort   options = 0;
  IGRint     num_gralp_edges,
             num_horiz_edges,
             num_cusp_edges,
             size_buf,
             bytes_ret,
             which_error;
  IGRlong    event_size;
  struct GRid *gralp_edges = NULL,
              *horiz_edges = NULL,
              *cusp_edges  = NULL,
               window_grid;              
  IGRlong      locate_mask = 0, 
               accept_mask = 0, 
               display_flag;
  struct GRlc_locate attributes;
  IGRlong         object_was_located;
  struct GRevent  accept_event,
                  locate_event;
  enum GRdpmode   DisplayMode;
  struct GRmd_env master_md_env,
                  rp_md_env;
  OMuword         r_classes[5], e_classes[5];
  OM_S_CLASSLIST  rtree_classes, eligible_classes;
  OMuword		surfaces;
  OM_S_CLASSLIST	yes_classes, 
                        no_classes;
  IGRlong             numb_objs = 0; 
  struct GRlc_info   *group_objs;
  IGRint              cntr;
  struct var_list     list[2];
  struct GRid         ref_pln_GRid;            
  struct EMSobject_info parents[2];
  IGRint              num_parents,
                      window_found;
  IGRvector           rp_z_vector;


/*
 * Enter infinite loop
 */
 do
  {
   switch(ME.super_cmd->state)
    {

/*
 * Room for growth
 */
   case BEGIN_STATE:
     ME.super_cmd->state = LOC_SF_OR_BACKUP;
     break;

/*
 * Locate the surface or backup to identify a reference plane.  
 * Note that if the user does not choose a ref plane, he may 
 * choose surfaces that are in reference files.
 */
   case LOC_SF_OR_BACKUP:
     if(ME.super_cmd->mytype == DELETE) /* don't allow backup for delete */
      locate_mask = GRm_DATA | GRm_OBJID | GRm_SPECIFIED_OBJ | GRm_RESTART;
     else
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_SPECIFIED_OBJ |
                    GRm_RESTART;
      accept_mask = GRm_DATA | GRm_OBJID | GRm_SPECIFIED_OBJ | GRm_RESTART;


       display_flag = 
        ONE_WINDOW              |       /* Hilite in only one window */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL;                   /* Erase the hilite plane */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* Locate read and write objects */
       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |                /* We want the surface itself */
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

/* 
       sts = gr$gsput_locate_criteria(msg = &EMmsg,
                                      attributes = &attributes,
                                      rtree_classes = &rtree_classes,
                                      eligible_classes = &eligible_classes);

       sts =  lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRbdhe,
         locate_key =           EMS_P_00132,  identify surface/solid
         acc_key =              EMS_P_AccwSfSl,  Accept w/next surf/sol/rej
         relocate_key =         EMS_I_SfSlNotLocated, sf/sol not found 
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
*/

     if(ME.super_cmd->mytype != DELETE)
        ex$message(msgnumb = EMS_S_BkUpIdRp )

     sts = gr$gslocate (
           msg    = &object_was_located,
           event1 = &me->locate_event,
           event2 = &accept_event,
           locate_event = &locate_event,
           mask1  =  locate_mask,
           mask2  =  accept_mask,
           display_flag = display_flag,
           unhilight_mode = (enum GRdpmode ) GRbdhe,           
           locate_key = EMS_P_00132,  /*identify surface/solid */
           acc_key    = EMS_P_AccwSfSl,  /* Accept w/next surf/sol/rej */
           relocate_key = EMS_I_SfSlNotLocated, /* sf/sol not found */ 
           attributes =  &attributes,
           stack = &me->locate_stack,
           num_inputs = 0,
           p_chanselect = NULL,
           rtree_classes    = &rtree_classes,
           eligible_classes = &eligible_classes);


      if (!object_was_located)
       {
        if (accept_event.response == EX_BACK_UP)
         {
          ME.super_cmd->state = LOC_REF_PLANE;
          break;
         }
        else
         return(OM_S_SUCCESS);
       }
      else if (accept_event.response IS GR_UNKNOWN_TYPE)
             {
              dp$erase_hilite(msg = &EMmsg);
              return(OM_S_SUCCESS);
             }
           else
           do
           {

            surfaces = OPP_EMSsurface_class_id;
            no_classes.w_count = 0;
            yes_classes.w_count = 1;
            yes_classes.p_classes = &surfaces;
       
            numb_objs = 0;
            group_objs = NULL;
           
            sts = EMselective_fence(&yes_classes,
                                    &no_classes,
                                    &locate_event.located_object[0],
                                     TRUE, /* break_down_composites */
                                     FALSE, /* is_operation_readonly */
                                     my_id,
                                    &numb_objs,
                                    &group_objs,
                                    &EMmsg);
            ERROR(sts, EMmsg, "EMselective_fence error")

            if (!numb_objs)
            {
             ex$message(msgnumb = EMS_S_InvInp )
             dp$erase_hilite(msg = &EMmsg);
             break;
            }

            me->numcrv = numb_objs;


            /* do vla stuff here to set size of locobj vla */
            sts = om$vla_set_dimension(varray = me->locobj,
                                       size = me->numcrv);
            if (! (1 & sts)) goto wrapup;


            options = 0;

            if(ME.super_cmd->mytype == CREATE)
               options |= EMS_OPT_CREATE; /* create horizon and cusp edges
                                             but don't return them.
                                           */    
            else if(ME.super_cmd->mytype == DELETE)
                    options |= EMS_OPT_DELETE_HRZ ;

            size_buf = sizeof(struct GRmd_env);

            gr$get_module_env(msg    = &EMmsg,
                              sizbuf = &size_buf,
                              buffer = &master_md_env,
                              nret   = &bytes_ret);

            window_grid.osnum = accept_event.event.button.osnum;
            window_grid.objid = accept_event.event.button.objid;

            
            /* load up the vla with the objects and send 
             * EMget_graphics_edges to each.
             */
            for(cntr=0;cntr < me->numcrv; cntr++)
             {
              me->locobj[cntr] = group_objs[cntr];

              num_gralp_edges = 0;
              num_horiz_edges = 0;
              num_cusp_edges  = 0;

            if(ME.super_cmd->mytype == DELETE)
             {
               /* if we are going to delete the horizon edges, we need
                  to first send an erase to the object.
                */  
               DisplayMode = GRbe;
               sts = om$send(msg = message GRgraphics.GRdisplay
                           (&EMmsg,
                            &master_md_env.md_env.matrix_type,
                             master_md_env.md_env.matrix, 
                            &DisplayMode, 
                            &window_grid), 
                            senderid = my_id,
                            targetos = me->locobj[cntr].located_obj.osnum,
                            targetid = me->locobj[cntr].located_obj.objid );
               ERROR(sts, EMmsg, "call to GRgraphics.GRdisplay error")
             }

  
            list[0].var = WLD_TO_VIEW;
            list[0].var_ptr = (IGRchar *)rp_md_env.md_env.matrix;
            list[0].num_bytes = sizeof(IGRdouble) * 16;
            list[0].bytes_returned = (long *)&bytes_ret;

            list[1].var = END_PARAM;
            list[1].var_ptr = NULL;
            list[1].num_bytes = 0;
            list[1].bytes_returned = NULL;
 
            sts = dp$inq_set_gragad(msg = &EMmsg,
                                osnum = window_grid.osnum,
                                gragad_objid = window_grid.objid,
                                which_error = &which_error,
                                var_list = list);
            ERROR(sts, EMmsg, "call to dp$inq_set_gragad error")

            sts = MAtypemx(&EMmsg, rp_md_env.md_env.matrix, &rp_md_env.md_env.matrix_type);
            ERROR(sts, EMmsg, "call to MAtypemx error")


            ems$get_reference_plane_for_given_orientation(
                 msg = &EMmsg,
                 env_info = &(me->locobj[cntr].module_info),
                 refpln_mxtyp = &rp_md_env.md_env.matrix_type,
                 refpln_mx = rp_md_env.md_env.matrix,
                 pln_GRid = &ref_pln_GRid);
  
            rp_md_env.md_id.objid = 0;
            rp_md_env.md_id.osnum = 0;   

            /* set up the parents of the horizon loop to send to 
               EMget_graphics_edges.  
             */  
            parents[0].grid.objid = ref_pln_GRid.objid;
            parents[0].grid.osnum = ref_pln_GRid.osnum;
            parents[0].env = rp_md_env;
            parents[1].grid.objid = me->locobj[cntr].located_obj.objid;
            parents[1].grid.osnum = me->locobj[cntr].located_obj.osnum;
            parents[1].env = me->locobj[cntr].module_info;

            num_parents = 2;

            sts = om$send( msg = message EMSsubbs.EMget_graphics_edges(
                                            &EMmsg,
                                            &num_parents, /* new parm */
                                             parents,     /* new parm */
                                             options,
                                            &num_gralp_edges,
                                            &num_horiz_edges,
                                            &num_cusp_edges,
                                            &gralp_edges,
                                            &horiz_edges,
                                            &cusp_edges ),
                          senderid = my_id,
                          targetos = me->locobj[cntr].located_obj.osnum,
                          targetid = me->locobj[cntr].located_obj.objid );
            ERROR(sts, EMmsg, "call to EMSsubbs.EMget_graphics_edges error")


            DisplayMode = GRbdhe;
            sts = om$send(msg = message GRgraphics.GRdisplay
                         (&EMmsg,
                          &master_md_env.md_env.matrix_type,
                           master_md_env.md_env.matrix, 
                          &DisplayMode, 
                          &window_grid), 
                          senderid = my_id,
                          targetos = me->locobj[cntr].located_obj.osnum,
                          targetid = me->locobj[cntr].located_obj.objid );
            ERROR(sts, EMmsg, "call to GRgraphics.GRdisplay error")


          } /* end for cntr */ 

       me->numcrv = 0;

       if (accept_event.response != EX_OBJID)
        { 
          /* push the accept event on the software queue unless
             there was an event generator
           */
          event_size = sizeof(accept_event.event) + sizeof(IGRint);
          sts = ex$putque(msg      = &EMmsg,
                          response = &accept_event.response, 
                          byte     = &event_size,
                          buffer   = (char *)&accept_event.event);
          ERROR(sts, EMmsg, "call to ex$putque")   
        }

       sts = gr$gslocate (
           msg    = &object_was_located,
           event1 = &me->locate_event,
           event2 = &accept_event,
           locate_event = &locate_event,
           mask1  =  locate_mask,
           mask2  =  accept_mask,
           display_flag = display_flag,
           unhilight_mode = (enum GRdpmode ) GRbdhe,           
           locate_key = EMS_P_00132,  /*identify surface/solid */
           acc_key    = EMS_P_AccwSfSl,  /* Accept w/next surf/sol/rej */
           relocate_key = EMS_I_SfSlNotLocated, /* sf/sol not found */ 
           attributes =  &attributes,
           stack = &me->locate_stack,
           num_inputs = 0,
           p_chanselect = NULL,
           rtree_classes    = &rtree_classes,
           eligible_classes = &eligible_classes);



       if (!object_was_located)
        {
         if (accept_event.response == EX_BACK_UP)
          {
            ME.super_cmd->state = BEGIN_STATE;
            break;
          }
         else
          return(OM_S_SUCCESS);
        }
       else if (accept_event.response IS GR_UNKNOWN_TYPE)
             {
               dp$erase_hilite(msg = &EMmsg);
               return(OM_S_SUCCESS);
              }


      /* return to top of do and process this surface */         
      } while(TRUE); /* end do-while, infinite loop, will exit when the
                        user finishes locating surfaces */
      me->numcrv = 0;
   break;

/* 
   Locate reference plane
   Since the user is choosing a reference plane, location of surfaces
   will be limited to those in the master file.
*/
   case LOC_REF_PLANE:
       display_flag = 
        ONE_WINDOW              |       /* Hilite in only one window */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL;                   /* Erase the hilite plane */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* Locate read and write objects */
       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |                /* We want the surface itself */
        LC_HANDLES     |
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_EMSdatpln_class_id;
       e_classes[0] = OPP_EMSdatpln_class_id;       



     sts = gr$gslocate (
           msg    = &object_was_located,
           event1 = &me->locate_event,
           event2 = &accept_event,
           locate_event = &locate_event,
           mask1  =  locate_mask,
           mask2  =  accept_mask,
           display_flag = display_flag,
           unhilight_mode = (enum GRdpmode ) GRbdhe,           
           locate_key = EMS_P_IdRefPln, /* identify reference plane */ 
           acc_key    = EMS_P_AcWSfSo, /* Accept w/ surf/sol/rej*/
           relocate_key = EMS_I_EltNotLocated, /* element not found */
           attributes =  &attributes,
           stack = &me->locate_stack,
           num_inputs = 0,
           p_chanselect = NULL,
           rtree_classes    = &rtree_classes,
           eligible_classes = &eligible_classes);


      if (!object_was_located)
       {
       if (accept_event.response == EX_BACK_UP)
        {
         ME.super_cmd->state = BEGIN_STATE;
          break;
         }
        else
         return(OM_S_SUCCESS);
       }
      else if (accept_event.response IS GR_UNKNOWN_TYPE)
             {
              dp$erase_hilite(msg = &EMmsg);
              return(OM_S_SUCCESS);
             }
           else
             {
               /* get the reference plane info from the event and load
                  it into the parent structure
                */
               parents[0].grid.objid = 
                   locate_event.located_object[0].located_obj.objid;
               parents[0].grid.osnum = 
                   locate_event.located_object[0].located_obj.osnum;
               OM_BLOCK_MOVE(&locate_event.located_object[0].module_info,
                            &parents[0].env,sizeof(struct GRmd_env));

              /* change locate criteria for locating surfaces */
              r_classes[0] = OPP_EMSsubbs_class_id;
              e_classes[0] = OPP_EMSsurface_class_id;       


              do
               {
               if (accept_event.response != EX_OBJID)
                 {
                  /* push the accept event on the software queue unless
                     there was an event generator
                   */
                  event_size = sizeof(accept_event.event) + sizeof(IGRint);
                  sts = ex$putque(msg      = &EMmsg,
                                  response = &accept_event.response, 
                                  byte     = &event_size,
                                  buffer   = (char *)&accept_event.event);
                  ERROR(sts, EMmsg, "call to ex$putque")   
                 }
                 

             sts = gr$gslocate (
                msg    = &object_was_located,
                event1 = &me->locate_event,
                event2 = &accept_event,
                locate_event = &locate_event,
                mask1  =  locate_mask,
                mask2  =  accept_mask,
                display_flag = display_flag,
                unhilight_mode = (enum GRdpmode ) GRbdhe,           
                locate_key = EMS_P_00132,  /*identify surface/solid */
                acc_key    = EMS_P_AccwSfSl,  /* Accept w/next surf/sol/rej */
                relocate_key = EMS_I_SfSlNotLocated, /* sf/sol not found */ 
                attributes =  &attributes,
                stack = &me->locate_stack,
                num_inputs = 0,
                p_chanselect = NULL,
                rtree_classes    = &rtree_classes,
                eligible_classes = &eligible_classes);


                if (!object_was_located)
                 {
                  if (accept_event.response == EX_BACK_UP)
                    {
                     ME.super_cmd->state = LOC_REF_PLANE;
                     break;
                    }
                  else
                   return(OM_S_SUCCESS);
                 }
               else if (accept_event.response IS GR_UNKNOWN_TYPE)
                      {
                        dp$erase_hilite(msg = &EMmsg);
                        return(OM_S_SUCCESS);
                      }
                    else
                      {
            surfaces = OPP_EMSsurface_class_id;
            no_classes.w_count = 0;
            yes_classes.w_count = 1;
            yes_classes.p_classes = &surfaces;
       
            numb_objs = 0;
            group_objs = NULL;
            
            sts = EMselective_fence(&yes_classes,
                                    &no_classes,
                                    &locate_event.located_object[0],
                                     TRUE, /* break_down_composites */
                                     FALSE, /* is_operation_readonly */
                                     my_id,
                                    &numb_objs,
                                    &group_objs,
                                    &EMmsg);
            ERROR(sts, EMmsg, "EMselective_fence error")


            if (!numb_objs)
            {
             ex$message(msgnumb = EMS_S_InvInp )
             dp$erase_hilite(msg = &EMmsg);
             break;
            }

            me->numcrv = numb_objs;


            /* do vla stuff here to set size of locobj vla */
            sts = om$vla_set_dimension(varray = me->locobj,
                                       size = me->numcrv);
            if (! (1 & sts)) goto wrapup;


            options = 0;

            options |= EMS_OPT_CREATE; /* create horizon and cusp edges
                                             but don't return them.
                                           */    
            size_buf = sizeof(struct GRmd_env);

            gr$get_module_env(msg    = &EMmsg,
                              sizbuf = &size_buf,
                              buffer = &master_md_env,
                              nret   = &bytes_ret);

             
             /* get the z_vector from the reference plane */   
             sts = om$send(msg = message EMSdatpln.EMget_pln_info
                           (&EMmsg,
                             NULL,
                            &group_objs[0].module_info, 
                             NULL,
                             NULL,
                             rp_z_vector,
                             NULL,
                             NULL), 
                   senderid = my_id,
                   targetos = parents[0].grid.osnum,
                   targetid = parents[0].grid.objid);
             if(! (1 & sts & EMmsg)) goto wrapup;


            /* determine the window that is aligned with the view
               of the reference plane 
             */
            window_found = FALSE;
            sts = EFwin_parallel_ref_pln(
                            &EMmsg,
                            &master_md_env.md_id, 
                             rp_z_vector,
                            &window_found,
                            &window_grid );
            ERROR(sts, EMmsg, "EFwin_parallel_ref_pln error")
            

            /* load up the vla with the objects and send 
             * EMget_graphics_edges to each.
             */
            for(cntr=0;cntr < me->numcrv; cntr++)
             {
              me->locobj[cntr] = group_objs[cntr];

              num_gralp_edges = 0;
              num_horiz_edges = 0;
              num_cusp_edges  = 0;


            /* set up the parents of the horizon loop to send to 
               EMget_graphics_edges.  I already loaded the reference
               plane into parents[0].
             */  
            parents[1].grid.objid = me->locobj[cntr].located_obj.objid;
            parents[1].grid.osnum = me->locobj[cntr].located_obj.osnum;
            parents[1].env = me->locobj[cntr].module_info;

            num_parents = 2;

            sts = om$send( msg = message EMSsubbs.EMget_graphics_edges(
                                            &EMmsg,
                                            &num_parents, /* new parm */
                                             parents,     /* new parm */
                                             options,
                                            &num_gralp_edges,
                                            &num_horiz_edges,
                                            &num_cusp_edges,
                                            &gralp_edges,
                                            &horiz_edges,
                                            &cusp_edges ),
                          senderid = my_id,
                          targetos = me->locobj[cntr].located_obj.osnum,
                          targetid = me->locobj[cntr].located_obj.objid );
            ERROR(sts, EMmsg, "call to EMSsubbs.EMget_graphics_edges error")

           if(window_found)
            {
              DisplayMode = GRbdhe;
              sts = om$send(msg = message GRgraphics.GRdisplay
                           (&EMmsg,
                            &master_md_env.md_env.matrix_type,
                             master_md_env.md_env.matrix, 
                            &DisplayMode, 
                            &window_grid), 
                          senderid = my_id,
                          targetos = me->locobj[cntr].located_obj.osnum,
                          targetid = me->locobj[cntr].located_obj.objid );
              ERROR(sts, EMmsg, "call to GRgraphics.GRdisplay error")
            }
 
                 } /* end for cntr */ 
                 me->numcrv = 0;
                } /* end else -- process the surface(s) */
                 
              } while(TRUE); /* get the surfaces */

             } /* end else -- process the ref plane then get surfaces */
   break;

/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
      break;
    }
  }
 while(TRUE);



wrapup:
  *response = TERMINATE;
  return(sts);

}


method super_cmd.sleep(int pos)
{
    IGRlong        EMmsg, 
                   sts;

    /* turn off the associativity button */
    sts = GRdisplay_associative_button(0);

    sts = dp$erase_hilite(msg = &EMmsg);
    ERROR(sts, EMmsg, "dp$erase_hilite error")

wrapup:
    return(OM_S_SUCCESS);
}


end implementation EChoriz;
