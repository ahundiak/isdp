/* ###################   APOGEE COMPILED   ################## */
/*
    History

      dhm    02/01/92    added GRm_TEXT_VALUE to the locate_mask so that
                         reference planes can be located by name.
      ra     07/02/92    message system compliance.
      scw    08/15/94    clarified sleep method
      satish 05/30/95    default angle is handled correctly
*/

class implementation ECdtmppang;

#include <stdio.h>                      /* Needed for print statements */
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "lcmacros.h"

#include "exmacros.h"                   /* Has ex$putque */
#include "maerr.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "dpdef.h"
#include "EMSdatumdef.h"
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "EMdtmacros.h" /* For ems$get_..*/
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "REdatpln.h"
#include "EMSasmacros.h"
#include "EMSdef.h" /* For EMparms */
#include "EMSconstruct.h"
#include "emsdef.h"
#include "EMSaction.h"                  /* Action handler stuff */
#include "msmacros.h"
#include "ECcmd.h"
#include "ECmsg.h"

#include "actparam.h"


# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

/*
 * states 
 */
#define NUMBER_OF_STATES 7   /* includes state 0 */
#define IDENTIFY_PLANAR_ELEMENT 1
#define IDENTIFY_PIVOT 2
#define ENTER_VALUE 3
#define ACCEPT_NORMAL 4
#define LOCATE_WINDOW 5
#define PROCESS 6

#define MAX_NUM_WIN 32

/* status form gadget indices */
#define SAVE 1
#define CONVERT_TO_WINDOW 5
#define BOTTOM 13
#define TOP 14
#define LEFT 15
#define RIGHT 16
#define PARALLEL_PLANE 0

/*
 *  STATE TRANSITION MACROS TO ASSURE WE GET WERE WERE SUPPOSED TO BE!
 */
#define clear_state_history() \
        { \
	   int ndx; \
	   for (ndx=0; ndx < NUMBER_OF_STATES; ndx++ )  \
	   prev_states[ndx] = 0; \
        }
#define goto_state( new_state )  \
            prev_states[new_state] = ME.super_cmd->state; \
            ME.super_cmd->state = new_state;

#define backup_state() \
	     ME.super_cmd->state = prev_states[ME.super_cmd->state];


from GRgraphics   import GRdisplay, GRgetrang, GRgetprops;
from EMSdatpln    import EMget_pln_info;
from EMSdatplnmgr import EMget_info, EMactivate;
from EMSsurface   import EMget_point_on_surface, EMalgnnrml;

extern OMuword OPP_GRbspline_class_id,
               OPP_EMSsubbs_class_id,
               OPP_GRvg_class_id,
               OPP_GR3dlineseg_class_id,
               OPP_GRcurve_class_id,
               OPP_SKmgr_class_id;

static GRspacenum osn;
static struct GRmd_env dispenv;
static IGRlong bytes_in, bytes_out;
static IGRlong amsg_loc;

static long unlock_form(form)
   Form form;
{
   FIg_enable(form, BOTTOM);
   FIg_enable(form, TOP);
   FIg_enable(form, LEFT);
   FIg_enable(form, RIGHT);

   return 1;
}

static long lock_form(form)
   Form form;
{
   FIg_disable(form, BOTTOM);
   FIg_disable(form, TOP);
   FIg_disable(form, LEFT);
   FIg_disable(form, RIGHT);

   return 1;
}

method execute(int *response; char *response_data; int pos)
{
  IGRboolean aflag=0;
  IGRlong sts,msg;
  IGRint locate_mask, accept_mask,display_flag;
  enum GRdpmode display_mode;
  struct GRlc_locate attributes;
  OMuword r_classes[5], e_classes[5];
  OM_S_CLASSLIST rtree_classes, eligible_classes;
  struct GRevent accept_event, event;
  struct GRid wingrid[MAX_NUM_WIN];
  int  prompt_key, acc_key = EMS_P_00000;
  IGRint total_numwin, numwin,eventmask;

  /*
   *  PREVIOUS STATE ARRAY;  Each time a state transition occurs the previous
   *  state is recorded so that BACK_UP will work properly.  This is necessary
   *  because there are multiple paths to reach a particular state.  Each time
   *  the command restarts, the state array is cleared.  BEFORE a state 
   *  transition occurs, set prev_state[<state you are going to>] to the 
   *  current state.  When a backup occurs, the new current state is set to 
   *  prev_state[<current_state>].  Shelley Heard 9/29/92
   *
   *  SEE #define MACROS ABOVE:
   *     clear_state_history()
   *     goto_state(new_state)
   *     backup_state()
   */
  short prev_states[NUMBER_OF_STATES]; /* only refrenced in #define macros */

 
  sts = OM_S_SUCCESS;
  msg = MSSUCC;
 
  aflag = pwIsActivationOn();

  locate_mask = GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;
  accept_mask = GRm_DATA;
 
  ex$message ( msgnumb = EM_M_CrRfPlAnPl);
 
  display_flag = 
      ELEM_HILIGHT              |       /* Hilite the whole element */
      NO_PROJ_ACCEPT_POINT      |       /* Don't project the accept point */
      ACC_REJ_CYCLE             |       /* Run through accept reject cycle */
      RELOCATE                  |       /* Relocate if none found */
      LC_REGULAR_HIGHLIGHT      |       /* Use regular hilite not 1/2 */
      LC_ERASE_LOC_ELEMENT;             /* Erase the hilite plane */

  attributes.properties = 
      LC_LC_ONLY              |       /* Locate locatable objects */
      LC_DP_ONLY              |       /* Locate displayable objects */
      IGN_MOD_BIT             ;       /* Ignore modified and new props */

  rtree_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes = &r_classes[0];
  eligible_classes.w_flags = OM_CLST_subclass;
  eligible_classes.p_classes = &e_classes[0];


  /*
   * Enter infinite loop.
  */
  do
  {
    switch (ME.super_cmd->state)
    {
      case 0:
      {
        ME.super_cmd->state = IDENTIFY_PLANAR_ELEMENT;
        break;
      }


      case IDENTIFY_PLANAR_ELEMENT:
      {
        unlock_form(ME.ECdtmfc->form); /* even if it's already unlocked */
        clear_state_history();

        attributes.properties = 
           LC_RW | 
           LC_LC_ONLY              |       /* Locate locatable objects */
           LC_DP_ONLY              |       /* Locate displayable objects */
           IGN_MOD_BIT             |       /* Ignore modified and new props */
           LC_PLANAR_ONLY; 

        attributes.owner_action = LC_READ | LC_HANDLES;

        /*
         * If activetion is on, this locate propery will allow the locate of
         * ref-planes in reference files. The locate action handler will
         * ensure that only ref-planes in the active file are located.
         */
        if(aflag)
          attributes.owner_action |= LC_REF_OBJECTS;

        rtree_classes.w_count = 1;
        eligible_classes.w_count = 2;
        r_classes[0] = OPP_GRvg_class_id;
        e_classes[0] = OPP_EMSsubbs_class_id;
        e_classes[1] = OPP_EMSdatpln_class_id;
        me->ref_plane_identified = FALSE;
        ME.ECdtmfc->elems[0].located_obj.objid = NULL_OBJID;

        prompt_key = EMS_P_IdPlFcRfPl;
        if      (me->options == EMS_BOTTOM_ELEMENT)
        {
          acc_key = EMS_P_IdBotPivotEdge;
        }
        else if (me->options == EMS_TOP_ELEMENT)
        {
          acc_key = EMS_P_IdTopPivotEdge;
        }
        else if (me->options == EMS_LEFT_ELEMENT)
        {
          acc_key = EMS_P_IdLeftPivotEdge;
        }
        else if (me->options == EMS_RIGHT_ELEMENT)
        {
          acc_key = EMS_P_IdRtPivotEdge;
        }
       
        aflag = pwIsActivationOn();
        if (aflag)
        {
          extern IGRlong RFlocate_ref_plane_handler();
          GRspacenum osn;
          osn = pwGetActiveOs();

        sts = lc$locate(
          rc =                   &msg,
          event1 =               &me->locate_event,
          event2 =               &accept_event,
          mask1 =                locate_mask,
          mask2 =                accept_mask,
          display_flag =         display_flag,
          locate_key =           prompt_key,
          acc_key =              acc_key,
          attributes =           &attributes,
          relocate_key    =      EMS_P_ElementNotLocated,
          stack =                &me->locate_stack,
          rtree_classes =        &rtree_classes,
          eligible_classes =     &eligible_classes,
          act_handler      =     RFlocate_ref_plane_handler,
          act_args         =     &osn);
        }
        else
        {
        sts = lc$locate(
          rc =                   &msg,
          event1 =               &me->locate_event,
          event2 =               &accept_event,
          mask1 =                locate_mask,
          mask2 =                accept_mask,
          display_flag =         display_flag,
          locate_key =           prompt_key,
          acc_key =              acc_key,
          attributes =           &attributes,
          relocate_key    =      EMS_P_ElementNotLocated,
          stack =                &me->locate_stack,
          rtree_classes =        &rtree_classes,
          eligible_classes =     &eligible_classes);
        }

        if (!(1&sts)) return (OM_S_SUCCESS);
       
        if (!(1&msg))
        {
	  if (ME.ECdtmfc->locate_event.response == EX_FORM_FINISHED )
	  {
            break;
	  }
	  else if (ME.ECdtmfc->locate_event.response != EX_BACK_UP)
	  {
            return(OM_S_SUCCESS);
	  }
        }
        else
        {
          IGRint msg_loc;
          struct GRid *loc_GRid;
          ME.ECdtmfc->elems[0] = accept_event.located_object[0];
          ME.ECdtmfc->elems[0].geom_parms.polygon_inx = 0;
          loc_GRid = &ME.ECdtmfc->elems[0].located_obj;

          sts = dp$erase_hilite(msg = &msg);
          if (!(1&sts&msg)) return (OM_E_ABORT);

          if (EFisAncestryValid(&msg_loc, loc_GRid->objid,loc_GRid->osnum, 
                                OPP_EMSdatpln_class_id, FALSE))
          {
            goto_state(IDENTIFY_PIVOT);
            me->ref_plane_identified = TRUE;
            break;
          }

          /*
           * Put the accept event onto the queue
          */
          if (accept_event.response == EX_DATA)
          {
            IGRlong putque_size;
            putque_size = sizeof(accept_event.event) + sizeof (IGRint) ;
            sts = ex$putque( msg = &msg, 
			     response = response,
                             byte = &putque_size, 
			     buffer = (IGRchar *) &accept_event.event);
            if (!(1&sts)) return (OM_E_ABORT);
          }
          goto_state(IDENTIFY_PIVOT);
        }
        break;
      }


      case IDENTIFY_PIVOT:
      {
        extern   int ppdatum_action_handler();
        struct   EMSaction_handler locate;
        OMuword accept_classid[2];
  
        unlock_form(ME.ECdtmfc->form); /* even if it's already unlocked */

        attributes.properties |= LC_RW;
  
        attributes.owner_action = LC_READ;
        if(aflag)
          attributes.owner_action |= LC_REF_OBJECTS;

        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        r_classes[0] = OPP_GRbspline_class_id;
        e_classes[0] = OPP_GRbspline_class_id;
  
        ex$message (msgnumb = EMS_E_InStFmRvOp);
          
        if (me->options == EMS_BOTTOM_ELEMENT)
        {
          prompt_key = EMS_P_IdBotPivotEdge;
        }
        else if (me->options == EMS_TOP_ELEMENT)
        {
          prompt_key = EMS_P_IdTopPivotEdge;
        }
        else if (me->options == EMS_LEFT_ELEMENT)
        {
          prompt_key = EMS_P_IdLeftPivotEdge;
        }
        else if (me->options == EMS_RIGHT_ELEMENT)
        {
          prompt_key = EMS_P_IdRtPivotEdge;
        }
  
        accept_classid[0] = OPP_GRcurve_class_id;
        accept_classid[1] = OPP_SKmgr_class_id;
        locate.next = NULL;
        locate.option = 1;
        locate.type = 3;
        locate.num_objects = 2;
        locate.objects.classids = accept_classid;
  
           
        sts = lc$locate(
           rc =                   &msg,
           event1 =               &me->locate_event,
           event2 =               &accept_event,
           mask1 =                 locate_mask,
           mask2 =                 accept_mask,
           display_flag =          display_flag,
           act_handler =           ppdatum_action_handler,
           act_args =             &locate,
           locate_key =            prompt_key,
           acc_key =               EMS_P_AcceptReject,
           attributes =           &attributes,
           relocate_key =          EMS_P_ElementNotLocated,
           stack =                &me->locate_stack,
           rtree_classes =        &rtree_classes,
           eligible_classes =     &eligible_classes);
        if (!(1&sts)) return (OM_S_SUCCESS);
         
        if (!(1&msg))
        {
          if (ME.ECdtmfc->locate_event.response == EX_BACK_UP)
          {
            struct GRlc_info  *erase_elem = NULL;
  
            backup_state();

            erase_elem = &ME.ECdtmfc->elems[0];
            display_mode = GRhe;
  
            if (erase_elem)
            {
              aflag = pwIsActivationOn();
              if (aflag)
              {
                bytes_in = sizeof (struct GRmd_env);
                gr$get_module_env (msg = &amsg_loc, sizbuf = &bytes_in,
                buffer = &dispenv, nret = &bytes_out);
                sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                                           &dispenv.md_env.matrix_type,
                                           dispenv.md_env.matrix,
                                           &display_mode,
                                           &dispenv.md_id),
                               targetid = erase_elem->located_obj.objid,
                               targetos = erase_elem->located_obj.osnum);
              }
              else
              {
                sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                                        &me->md_env.md_env.matrix_type,
                                        me->md_env.md_env.matrix,
                                        &display_mode,
                                        &me->md_env.md_id),
                               targetid = erase_elem->located_obj.objid,
                               targetos = erase_elem->located_obj.osnum);
              }
              if (!(1&sts&msg))  return (OM_E_ABORT);
              --me->num_hilited;
            }
  
            break;
           }
          else 
           return(OM_S_SUCCESS);
        }
        else
        {
          if (accept_event.response == EX_DATA)
          {
            ME.ECdtmfc->elems[1] = accept_event.located_object[0];
            ++me->num_hilited;
          }
        }
  
        /* the order of the next two lines is critical */
        goto_state(ENTER_VALUE);
        break;
      }


      case ENTER_VALUE:
      {
        char value_string[256];
        value_string[0] = '\0';
  
        lock_form(ME.ECdtmfc->form); /* even if it's already unlocked */

        eventmask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
  
        strcpy(value_string,GRIO_SCALAR);
        prompt_key = EMS_P_EnRoAnDg90;
  
        sts = ems$getevent (msg = &msg,
                            event_mask = eventmask,
                            msgnum = prompt_key,
                            value_type = value_string,
                            response = (IGRlong *) response,
                            response_data = response_data,
                            event = &event);

        if (event.response == EX_VALUE)
        {

          if (event.event.value > 180)
          {
            ex$message (msgnumb = EMS_E_AnShLT180Deg);
            break;
          }
	  if (event.event.value == 0)
	  {
                me->value_event.subtype = GRst_REGULAR;
		me->value_event.event.value = 90;
	  }
	  else
          	OM_BLOCK_MOVE(&event, &me->value_event, sizeof (struct GRevent));
          goto_state(ACCEPT_NORMAL);
        }
        else if (event.response == EX_BACK_UP)
        {
          struct GRlc_info  *erase_elem = NULL;

          erase_elem = &ME.ECdtmfc->elems[1];

          backup_state();
  
          if (erase_elem)
          {
            display_mode = GRhe;
            aflag = pwIsActivationOn();
            if (aflag)
            {
              bytes_in = sizeof (struct GRmd_env);
              gr$get_module_env (msg = &amsg_loc, sizbuf = &bytes_in,
              buffer = &dispenv, nret = &bytes_out);
              sts = om$send (msg = message GRgraphics.GRdisplay(
                                   &msg,
                                   &dispenv.md_env.matrix_type,
                                    dispenv.md_env.matrix,
                                   &display_mode,
                                   &dispenv.md_id),
                           targetid = erase_elem->located_obj.objid,
                           targetos = erase_elem->located_obj.osnum);
            }
            else
            {
              sts = om$send (msg = message GRgraphics.GRdisplay(
                                   &msg,
                                   &me->md_env.md_env.matrix_type,
                                    me->md_env.md_env.matrix,
                                   &display_mode,
                                   &me->md_env.md_id),
                           targetid = erase_elem->located_obj.objid,
                           targetos = erase_elem->located_obj.osnum);
            }
            if (!(1&sts&msg))  return (OM_E_ABORT);
            --me->num_hilited;
          }
        }
        else if (event.response == EX_RJT_MOVEON)
        {
          me->value_event.subtype = GRst_REGULAR;
          me->value_event.located_object[0].located_obj.objid = NULL_OBJID;
        
          me->value_event.event.value = 90;
          goto_state(LOCATE_WINDOW);
        
	}
        else
        {
          return (OM_S_SUCCESS);
        }
        break;
      }


      case ACCEPT_NORMAL:
      {
         lock_form(ME.ECdtmfc->form); /* even if it's already unlocked */
         sts = om$send (msg = message ECdtmppang.display_normal(TRUE),
                      targetid = my_id);
         if (!(1&sts)) goto wrapup;
  
         eventmask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
         
         sts = co$getevent (msg = &msg,
                            msgnum = EMS_P_AcDrMvOnToRv,
                            event_mask = eventmask,
                            response = response,
                            response_data = response_data,
                            event = &event);
  
         if (event.response == EX_DATA)
         {
           me->normal_displayed = TRUE;

           goto_state(LOCATE_WINDOW);
         }
         else if (event.response == EX_RJT_MOVEON)
         {
           me->normal_displayed = TRUE;
           sts = om$send (msg = message ECdtmppang.display_normal(FALSE),
                          targetid = my_id);
           if (!(1&sts)) goto wrapup;
  
           if (ME.ECdtmfc->elems[0].geom_parms.polygon_inx)
             ME.ECdtmfc->elems[0].geom_parms.polygon_inx = 0;
           else
             ME.ECdtmfc->elems[0].geom_parms.polygon_inx = 1;
  
           sts = om$send (msg = message ECdtmppang.display_normal(TRUE),
                          targetid = my_id);
           if (!(1&sts)) goto wrapup;
  
           goto_state(LOCATE_WINDOW);
         }
         else if (event.response == EX_BACK_UP)
         {
           me->normal_displayed = FALSE;
           sts = om$send (msg = message ECdtmppang.display_normal(FALSE),
                          targetid = my_id);
           if (!(1&sts)) goto wrapup;
  
           /*
            * Erase the highlight plane.
            */
           sts = dp$erase_hilite(msg = &msg);
  
           backup_state();
         }
         else
         {
           return (OM_S_SUCCESS);
         }
         break;
      }


      case LOCATE_WINDOW:
      {
        struct GRevent event;
  
  
        lock_form(ME.ECdtmfc->form); /* even if it's already unlocked */
        eventmask = GRm_RJT_MOVEON | GRm_DATA | GRm_STRING | GRm_BACK_UP ;
        event.event.keyin[0] = '\0';
  
        sts = co$getevent ( msg = &msg,
                            event_mask = eventmask,
                            msgnum = EMS_P_IdWnROrMvOnNoReOr,
                            response = response, 
                            response_data = response_data,
                            event = &event);

        switch (event.response)
        {
           case EX_DATA:
             wingrid[0].objid = event.event.button.objid;
             wingrid[0].osnum = event.event.button.osnum;
             numwin = 1;
             if (IF_NULL_OBJID (wingrid[0].objid))
             {
                ex$message (msgnumb = EMS_S_NotWindowSpecification);
                break;
             }

             goto_state(PROCESS);
             break;
    
           case EX_STRING:
             if (event.event.keyin[0] == '\0')
             {
               wingrid[0].objid = NULL_OBJID;
               goto_state(PROCESS);
               break;
             }
             sts = dp$get_gragad_id (msg = &msg, name = event.event.keyin,
                           total_num = &total_numwin, numberofids = &numwin,
                           found_GRids = wingrid,
                           type_gragad = ALL_GG_CLASSES | ACTIVE_GG);
             if (!(1&sts)) return (OM_E_ABORT);
             if (!numwin)        
             {
                ex$message (msgnumb = EMS_S_NotWindowSpecification);
                break;
             }

             goto_state(PROCESS);
             break;
  
           case EX_RJT_MOVEON:
           {
             wingrid[0].objid = NULL_OBJID;
             goto_state(PROCESS);
             break;
           }
  
           case EX_BACK_UP:
           {
             struct GRid *erase_elem_GRid;
  
             erase_elem_GRid = NULL;
             backup_state();
           }
           break;
          
           default:
             return (OM_S_SUCCESS);
        }
        break;
      }


      case PROCESS:
      {
        OMuword constr_os;
        OM_S_OBJID res_id,old_datum;
        IGRdouble xdir[3], zdir[3], origin[3];
        struct GRvg_construct const_list;
        struct GRlc_info datum_lc_info;
        struct GRid mgr_GRid;
  
  
        const_list.msg = &msg;
        const_list.env_info = &me->md_env;
        const_list.newflag = FALSE;
        const_list.level = ME.ECelement->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_NEW | GRIS_LOCATABLE;
        const_list.geometry = NULL;
        const_list.display = &ME.ECelement->active_display;
        const_list.class_attr = NULL;
        const_list.name = NULL;
        me->num_hilited = 0;
        sts = dp$erase_hilite(msg = &msg);
        if (!(1&sts&msg)) return (OM_E_ABORT);
     
        constr_os = const_list.env_info->md_id.osnum;
    

        aflag = pwIsActivationOn();
        if (aflag)
        {
          osn = pwGetActiveOs();
          sts = ems$get_datum_plane_mgr(msg = &msg,
                                      osnum = &osn,
                                      mgrid = &mgr_GRid.objid,
                                      mgros = &mgr_GRid.osnum);
        }
        else
        {
          sts = ems$get_datum_plane_mgr(msg = &msg,
                                      mgrid = &mgr_GRid.objid,
                                      mgros = &mgr_GRid.osnum);
        }
        if (!(1&msg&sts)) return (OM_E_ABORT);
     
        sts = om$send (msg = message EMSdatplnmgr.EMget_info(&msg,
                               NULL,NULL,NULL,&old_datum,NULL),
                       targetid = mgr_GRid.objid,
                       targetos = mgr_GRid.osnum);
        if (!(1&sts&msg)) return (OM_E_ABORT);
    
        if (old_datum != NULL_OBJID)
        {
  
          /*
           * Erase the active datum plane since the now constructed entity 
           * is going to be active.
           */
          display_mode = GRbe;
          aflag = pwIsActivationOn();
          if (aflag)
          {
            bytes_in = sizeof (struct GRmd_env);
            gr$get_module_env (msg = &amsg_loc, sizbuf = &bytes_in,
            buffer = &dispenv, nret = &bytes_out);
            sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                          &dispenv.md_env.matrix_type,
                          dispenv.md_env.matrix,
                          &display_mode,
                          &dispenv.md_id),
                      targetid = old_datum,
                      targetos = mgr_GRid.osnum);
          }
          else
          {
            sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &display_mode,
                          &me->md_env.md_id),
                      targetid = old_datum,
                      targetos = mgr_GRid.osnum);
          }
          if (!(1&sts&msg))  return (OM_E_ABORT);
        }
      
        if (ME.ECdtmfc->elems[0].geom_parms.polygon_inx)
          me->options |= EMS_REVERSE_DIR;
        EFcreate_ref_angle_to_plane(&msg,
                                     (me->is_associative ?
                                     NULL : EMSasconst_notassociative),
                                    &ME.ECdtmfc->elems[0],
                                    &ME.ECdtmfc->elems[1],
                                    &me->value_event,
                                     me->options,
                                    &const_list,
                                    &res_id);
        if (!(1&msg)) return (OM_E_ABORT);
  
        if (wingrid[0].objid != NULL_OBJID)
        {
          sts = om$send (msg = message EMSdatpln.EMget_pln_info(
                                  &msg,
                                   NULL,const_list.env_info,
                                   xdir,
                                   NULL, 
                                   zdir,
                                   origin,
                                   NULL),
                         targetid = res_id,
                         targetos = constr_os);
          if (!(1&sts&msg)) 
            return (OM_E_ABORT);
  
          datum_lc_info.module_info = *(const_list.env_info);
          datum_lc_info.located_obj.objid = res_id;
          datum_lc_info.located_obj.osnum = constr_os;
  
          sts = EMsetwinornt ( &msg, 
                                numwin, 
                                wingrid,
                                origin,
                                xdir, 
                                zdir,
                               &datum_lc_info);
          if (!(1&sts&msg)) 
          return (OM_E_ABORT);
        }
  
        if (old_datum != NULL_OBJID)
        {
          /*
           * Redisplay the old datum plane since the now constructed entity 
           * is going to be active.
           */
  
          display_mode = GRbd;
          aflag = pwIsActivationOn();
          if (aflag)
          {
            bytes_in = sizeof (struct GRmd_env);
            gr$get_module_env (msg = &amsg_loc, sizbuf = &bytes_in,
            buffer = &dispenv, nret = &bytes_out);
            sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &dispenv.md_env.matrix_type,
                         dispenv.md_env.matrix,
                         &display_mode,
                         &dispenv.md_id),
                     targetid = old_datum,
                     targetos = mgr_GRid.osnum);
          }
          else
          {
            sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &display_mode,
                         &me->md_env.md_id),
                     targetid = old_datum,
                     targetos = mgr_GRid.osnum);
          }
          if (!(1&sts&msg))  
            return (OM_E_ABORT);
        }
  
        display_mode = GRbd;
  
        aflag = pwIsActivationOn();
        if (aflag)
        {
          bytes_in = sizeof (struct GRmd_env);
          gr$get_module_env (msg = &amsg_loc, sizbuf = &bytes_in,
          buffer = &dispenv, nret = &bytes_out);
          sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &dispenv.md_env.matrix_type,
                         dispenv.md_env.matrix,
                         &display_mode,
                         &dispenv.md_id),
                     targetid = res_id,
                     targetos = constr_os);
        }
        else
        {
          sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &display_mode,
                         &me->md_env.md_id),
                     targetid = res_id,
                     targetos = constr_os);
        }
        if (!(1&sts&msg))  
        return (OM_E_ABORT);

        /* restart the command */
        ME.super_cmd->state = IDENTIFY_PLANAR_ELEMENT;
  
        if (me->normal_displayed)
        {
          om$send (msg = message ECdtmppang.display_normal(FALSE),
                   targetid = my_id);
          sts = dp$erase_hilite(msg = &msg);
          me->num_hilited = 0;
        }
      }
    }
  }
  while (TRUE);

wrapup:
  if (!(1&sts&msg)) 
    return (OM_E_ABORT);
  else
    return (OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
 IGRlong sts = OM_S_SUCCESS;
 IGRlong msg_loc;

 if (me->set_edge_locatable_flag)
  EFset_locate_eligibility(&msg_loc,2,"EMSedge");

 if (me->normal_displayed)
 {
   om$send (msg = message ECdtmppang.display_normal(FALSE),
                 targetid = my_id);
 }

 sts = om$send (msg = message ECdtmppang.sleep(pos),
                mode = OM_e_wrt_parent,
                targetid = my_id);

 return(sts);
}

method wakeup (int pos)
{
 IGRboolean aflag=0;
 IGRlong sts = OM_S_SUCCESS;
 IGRlong msg_loc;
 extern IGRboolean EFedge_curves_locatable();

 if (!(EFedge_curves_locatable ()))
 {
  me->set_edge_locatable_flag = 1;
  EFset_locate_eligibility(&msg_loc,2,"EMSedge");
 }
 else
  me->set_edge_locatable_flag = 0;
 
 sts = om$send (msg = message ECdtmppang.wakeup(pos),
                mode = OM_e_wrt_parent,
                targetid = my_id);

 aflag = pwIsActivationOn();
 if (aflag)
 {
   sts = pwGetActiveModuleEnv(&me^^ECelement.md_env);
 }

 if (me->normal_displayed)
 {
   om$send (msg = message ECdtmppang.display_normal(TRUE),
                 targetid = my_id);
 }

 GRstatus_display_button(1);

 return(sts);
}


method display_normal(IGRint draw_background)
{
 IGRboolean aflag=0;
 IGRlong sts, msg_loc;
 struct GRmd_env *loc_env;
 struct GRid *grid;
 IGRboolean reverse_vector, in_world;
 IGRdouble range[6], vector[3],origin[3];
 enum GRdpmode display_mode;

 sts = OM_S_SUCCESS;

 if (ME.ECdtmfc->elems[0].geom_parms.polygon_inx)
    reverse_vector = 1;
 else
    reverse_vector = 0; 

 in_world = TRUE;
    
 loc_env = &me->elems[0].module_info;
 grid = &me->elems[0].located_obj;

 sts = om$send (msg = message GRgraphics.GRgetrang(&msg_loc,
                          &loc_env->md_env.matrix_type,
                          loc_env->md_env.matrix, &in_world,
                          range),
                    targetid = grid->objid,
                    targetos = grid->osnum);
 if (!(1&sts&msg_loc)) goto wrapup;

  if (me->ref_plane_identified)
  {
    sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg_loc,
                        NULL, loc_env,NULL,NULL,vector,origin,NULL),
                   targetid = grid->objid,
                   targetos = grid->osnum);
    if (!(1&sts&msg_loc)) goto wrapup;
  }
  else
  {
   IGRboolean pos_orient,i;
   IGRushort pos_option;
   struct EMparms parms;

   sts = om$send(msg = message EMSsurface.EMget_point_on_surface(&msg_loc,
                          loc_env,0,1, origin, &parms),
                   targetid = grid->objid,
                   targetos = grid->osnum);
   if (!(1&sts&msg_loc)) goto wrapup;

   pos_option = EMS_GET_POS_ORIENT;
   sts = om$send (msg = message EMSsurface.EMalgnnrml(
                           &msg_loc,
                           pos_option,
                           &pos_orient,
                           NULL,
                           NULL),
                   targetid = grid->objid,
                   targetos = grid->osnum);
   if (!(1&sts&msg_loc)) goto wrapup;

   OM_BLOCK_MOVE(parms.normal, vector, sizeof (IGRvector));
   if (pos_orient)
   {
     for (i=0;i<3;i++)
      vector[i] *= -1.0;
   }
  }

   if (draw_background)
     display_mode = GRbd;
   else
     display_mode = GRbe;
  aflag = pwIsActivationOn();
  if (aflag)
  {
    bytes_in = sizeof (struct GRmd_env);
    gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in,
    buffer = &dispenv, nret = &bytes_out);

    EFdraw_vector_on_screen( my_id,
                            &ME.ECelement->active_display,
                            &dispenv,
                             display_mode,
                             reverse_vector,
                             origin,
                             vector,
                             range,
                            &msg_loc);
  }
  else
  {

    EFdraw_vector_on_screen(my_id, &ME.ECelement->active_display,
                           &me->md_env, display_mode, reverse_vector,
                             origin,
                              vector,range,&msg_loc);
  }
  if (!(1&msg_loc)) goto wrapup;

wrapup:
 if (!(1&sts&msg_loc)) return (OM_E_ABORT);
 return (sts);
}

method is_status_form_valid(IGRint *valid)
{
 if ( (ME.super_cmd->state == IDENTIFY_PIVOT) ||
      (ME.super_cmd->state == IDENTIFY_PLANAR_ELEMENT) )
  *valid = TRUE;
 else
  *valid = FALSE;
 return (OM_S_SUCCESS);
}

ppdatum_action_handler(
 do_not_locate,
 new_entry,
 locate_args,
 action)

struct  EMSaction_handler *do_not_locate;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;

{
 IGRboolean     call_action_handler, aflag = 0;
 IGRlong msg_loc;
 IGRlong        sts;
/*
 * Initialize
 */

 /** Added for RFA. Pivot selected should be in the current activated OS. **/
 if (aflag = pwIsActivationOn())
 {
   GRspacenum osn;
   osn = pwGetActiveOs();
   if (new_entry->located_obj.osnum != osn)
   {
     return(OM_S_SUCCESS);
   }
 }


 call_action_handler = TRUE;

 switch (*action)
 {
   case add_all:
   case add_inside:
   case add_outside:
   case add_overlap:
   case add_nopost:
   {
     IGRlong    i;
     IGRshort graphics_props;
     struct     GRid check_id, *search_id, temp_GRid;
     OM_S_CHANSELECT to_owners;

     search_id = &new_entry->located_obj;
/*
 * See if the guy that was identified has a rigid owner.
 */
     graphics_props = 0;
     sts = om$send (msg = message GRgraphics.GRgetprops(&msg_loc,
                          &graphics_props),
                    senderid = NULL_OBJID,
                    targetid = search_id->objid,
                    targetos = search_id->osnum);
      if (!(1&sts&msg_loc)) return (OM_S_SUCCESS);

      if (graphics_props & GR_RIGID_RELATIONSHIP)
      {
       EMmake_chanselect(GRconnector_to_owners, &to_owners);

       sts = om$get_objid_at_index( osnum = search_id->osnum,
                                    objid = search_id->objid,
                                    p_chanselect = &to_owners,
                                    index = 0,      
                                    objidaddr = &temp_GRid.objid,
                                    osnumaddr = &temp_GRid.osnum);
       if (!(1&sts))
       {
        return (OM_S_SUCCESS);
       }
       check_id = temp_GRid;
       call_action_handler = FALSE;
      }
      else
      {
       check_id = *search_id;
      }
   
     if (((do_not_locate->option == 0) || (do_not_locate->option == 1)) &&
        !call_action_handler)
    {
     OMuword search_classid, check_classid;
     struct GRid *search_id;
     IGRboolean dont_locate;
 
     search_id = &check_id;

     if (do_not_locate->option == 0)
      dont_locate = TRUE;
     else 
      dont_locate = FALSE;

     for (i=0;i<do_not_locate->num_objects;i++)
     {
       check_classid = do_not_locate->objects.classids[i];

       sts = om$get_classid(objid = search_id->objid,
                            osnum = search_id->osnum,
                            p_classid = &search_classid);
       if (!(1&sts)) return (sts);

       sts = om$is_ancestry_valid (subclassid = search_classid,
                                   superclassid = check_classid);
       if (sts == OM_S_SUCCESS)
       {
        call_action_handler = (dont_locate ?  FALSE : TRUE );
        break;
       }
       else if (sts == OM_I_INVANCESTRY)
       {
        call_action_handler = (dont_locate ?  TRUE : FALSE);
        sts = OM_S_SUCCESS;
       }
       else
       {
       /*
        * If there is an error in getting the ancestry do not locate
        * the said object.
        */
        call_action_handler = FALSE;
        sts = OM_S_SUCCESS;
        break;
       }
     }
    }

    if (call_action_handler &&
         do_not_locate->next)
     {
       sts = EFlocate_action_handler(
        do_not_locate->next,
        new_entry,
        locate_args,
        action);
       return(sts);
     }
    }
    break;
/*
 * If the action is not to add then let the
 * regular action handler take care of the 
 * situation.
 */
   case start_transition:
   case end_transition:
   case post_object:
   case check_object:
    break;
  } /* switch (*action) */
/*
 * Call the action handler
 */
 if (call_action_handler)
  {
   extern IGRlong LCptlocact();

   sts = LCptlocact(NULL, new_entry, locate_args, action);
  }
 else
  sts = OM_S_SUCCESS;
/*
 * Eof
 */
 return(sts);
}
end implementation ECdtmppang;
