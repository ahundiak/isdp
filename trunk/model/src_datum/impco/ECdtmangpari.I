/* ###################   APOGEE COMPILED   ################## */

/* --- ECdtmangpar methods ------------------------- */

/*
NAME
        Overridden methods:
           init_method (super_cmd)
           execute_method (super_cmd)
           sleep_method (super_cmd)
           wakeup_method (super_cmd)
           delete (Root)
           is_status_form_valid (ECdtmfc)
        
        Declared:
           display_normal

DESCRIPTION
        Override of the execute method for reference plane placement
        commands. PLACE REFERENCE PLANE PARALLEL TO PLANAR ELEMENT (through
        a point) and  PLACE REFERENCE PLANE ANGULAR TO PLANAR ELEMENT.


PARAMETERS
        execute( int *response; 
                 char *response_data; 
                 int pos )

        sleep( int pos )

        wakeup (int pos)

        display_normal ( int draw_background )

GLOBALS USED

ALGORITHM (TBD)
   See header for functions EFcreate_ref_parallel_to_plane1() and 
   EFcreate_ref_angular_to_plane1()

FUNCTIONS CALLED (TBD)


NOTES (TBD)


HISTORY
        07/22/92 - Shelley R. Heard : created, with reverence of previous
                                      implementation (ECdtmppang).
        08/04/92 - Shelley R. Heard : removed debug printf statements.
        11/10/93 - Carlos M. DIaz   : added calls to FIf_is_valid (Allied problem).
        08/15/94 - Scott C. Walters : clarified sleep method

        08/16/94 -Vidya: made the local-variable 'prev_states' as an
                         instance so that previous-states in which the
                         CO would be is not disturbed because of command
                         stacking.
*/

class implementation ECdtmangpar;

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
#include "EMCRfPlanPar.h"   /* form gadgets and groups */

#include "actparam.h"
#include "madef.h"
#include "maidmx.h"

/* New states for parallel */
#define NUMBER_OF_STATES      8  /* used in previous_state array */
#define IDENTIFY_PLANE        1
#define SPECIFY_OFFSET        2
#define IDENTIFY_FIRST_AXIS   3
#define IDENTIFY_SECOND_AXIS  4
#define GET_AXIS_DIRECTION    5
#define ACCEPT_NORMAL         6
#define LOCATE_WINDOW         7
#define PROCESS               8

/*
 *  Status form fields return with the following value asignments:
 *  First axis                 (0==X, 1==Y)
 *  Planar face axis alignment (0==ARBITRARY, 1==SINGLE AXIS, 2==BOTH AXES)
 *  Reference plane alignment  (0==ALIGN, 1==AXES DEFINED)
 */
#define X_AXIS_PRIMARY  (0)
#define Y_AXIS_PRIMARY  (1)

#define ARBITRARY_AXES  (0)
#define ONE_AXIS_ONLY   (1)
#define BOTH_AXES       (2)

#define AXIS_ALIGNED    (0)
#define AXES_DEFINED    (1)

#define MAX_NUM_WIN     (32)
#define TANGENT         (0)  /* for EFdisplay_curve_normal_or_tangent() flag */

/*
 *  STATE TRANSITION MACROS TO ASSURE WE GET WERE WERE SUPPOSED TO BE!
 */
#define clear_state_history() \
        { \
	   int ndx; \
	   for (ndx=0; ndx < NUMBER_OF_STATES; ndx++ )  \
	   me->prev_states[ndx] = 0; \
        }
#define goto_state( new_state )  \
            me->prev_states[new_state] = ME.super_cmd->state; \
            ME.super_cmd->state = new_state;

#define backup_state() \
	     ME.super_cmd->state = me->prev_states[ME.super_cmd->state];


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

extern void EMCRfPlanPar_notification_routine();


static GRspacenum osn;
static struct GRmd_env dispenv;
static IGRlong bytes_in, bytes_out;
static IGRlong amsg_loc;


static int get_status_parms( form, 
                             p_primary_axis,
                             p_planar_face_align, 
                             ref_plane_align )
   Form form;
   int *p_primary_axis; 
   int *p_planar_face_align; 
   int *ref_plane_align;
{
   int status,
       state;

   /* from PARALLEL_TO_PLANAR_FACE_GRP FACE group */
   if ( p_planar_face_align )
   {
      status = FIg_get_state( form, EMS_g_BOTH_AXES, &state );
      if ( state == 1 )
      {
         *p_planar_face_align = BOTH_AXES; 
      }
      else
      {
         status = FIg_get_state( form, EMS_g_ONE_AXIS, &state );
         if ( state == 1 )
         {
            *p_planar_face_align = ONE_AXIS_ONLY; 
         }
         else
         {
            /* don't have to check ARBITRARY since it MUST be set */
            *p_planar_face_align = ARBITRARY_AXES;
         }
      }
   }
   if ( ref_plane_align )
   {
      /* from PARALLEL_TO_REF_PLANE_GRP group */
      status = FIg_get_state( form, EMS_g_ALIGN, &state );
      if ( state == 1 )
      {
         *ref_plane_align = AXIS_ALIGNED; 
      }
      else
      {
         /* don't have to check DEFINE_AXES since it MUST be set */
         *ref_plane_align = AXES_DEFINED; 
      }
   }

   if (p_primary_axis)
   {
      /* from PRIMARY_AXIS_GRP group */
      status = FIg_get_state( form, EMS_g_X_PRIMARY, &state );
      if ( state == 1 )
      {
         *p_primary_axis = X_AXIS_PRIMARY;
      }
      else
      {
         /* don't have to check Y_PRIMARY since it MUST be set */
         *p_primary_axis = Y_AXIS_PRIMARY;
      }
   }

   return OM_S_SUCCESS;
}


static long unlock_form(form)
   Form form;
{
   FIg_enable(form, EMS_g_BOTH_AXES );
   FIg_enable(form, EMS_g_ONE_AXIS );
   FIg_enable(form, EMS_g_ARBITRARY );
   FIg_enable(form, EMS_g_ALIGN );
   FIg_enable(form, EMS_g_DEFINE_AXES );
   FIg_enable(form, EMS_g_X_PRIMARY );
   FIg_enable(form, EMS_g_Y_PRIMARY );

   return 1;
}

static long lock_form(form)
   Form form;
{
   FIg_disable(form, EMS_g_BOTH_AXES );
   FIg_disable(form, EMS_g_ONE_AXIS );
   FIg_disable(form, EMS_g_ARBITRARY );
   FIg_disable(form, EMS_g_ALIGN );
   FIg_disable(form, EMS_g_DEFINE_AXES );
   FIg_disable(form, EMS_g_X_PRIMARY );
   FIg_disable(form, EMS_g_Y_PRIMARY );

   return 1;
}


method execute(int *response; char *response_data; int pos)
{
   IGRboolean aflag=0;
   long  sts,
         fi_sts,
         msg;

   int 
      i_sts,
      reverse_vector = 0,
      locate_mask,
      accept_mask,
      display_flag,
      primary_axis,
      planar_face_align,
      ref_plane_align,
      total_numwin, 
      numwin,
      eventmask;

   enum GRdpmode 
      display_mode;

   struct GRlc_locate 
      attributes;

   OMuword 
      r_classes[5],
      e_classes[5];

   OM_S_CLASSLIST 
      rtree_classes,
      eligible_classes;

   struct GRevent 
      accept_event,
      event;

   struct GRid 
      wingrid[MAX_NUM_WIN];

   int  prompt_key,
        accept_key;

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
   short prev_states[NUMBER_OF_STATES];
   *  made the local-varaible prev_states an instance to support
   * command stacking  ---- vidya 08/16/94
   */


   sts = OM_S_SUCCESS;
   msg = MSSUCC;

   aflag = pwIsActivationOn();

   locate_mask = GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;
   accept_mask = GRm_DATA;

   /* Command title display */
   ex$message ( msgnumb = EM_M_CrRfPlPrPL);

   display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;           /* Erase the hilite plane */

   attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT;                    /* Ignore modified and new props */

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
         ME.super_cmd->state = IDENTIFY_PLANE;
         break;
       }

       case IDENTIFY_PLANE:
       {
         clear_state_history();

         unlock_form(me->form); /* even if it's already unlocked */

         /*
          *  notify user that status form is available.  This is the
          *  only state we do this.
          */
 	 GRstatus_display_button(1);
         ex$message (msgnumb = EMS_E_InStFmRvOp);

         me->options = 0;    
         attributes.properties =
            LC_RW |
            LC_LC_ONLY          |       /* Locate locatable objects */
            LC_DP_ONLY          |       /* Locate displayable objects */
            IGN_MOD_BIT         |       /* Ignore modified and new props */
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
         accept_key = EMS_P_AcceptReject;

         aflag = pwIsActivationOn();
         if (aflag)
         {
           extern IGRlong RFlocate_ref_plane_handler();
           GRspacenum osn;
           osn = pwGetActiveOs();
            
         sts = lc$locate(
           rc =                 &msg,
           event1 =             &me->locate_event,
           event2 =             &accept_event,
           mask1 =              locate_mask,
           mask2 =              accept_mask,
           display_flag =       display_flag,
           locate_key =         prompt_key,
           acc_key =            accept_key,
           attributes =        &attributes,
           relocate_key =       EMS_P_ElementNotLocated,
           stack =             &me->locate_stack,
           rtree_classes =     &rtree_classes,
           eligible_classes =  &eligible_classes,
           act_handler      = RFlocate_ref_plane_handler,
           act_args         = &osn);
         }
         else
         {
         sts = lc$locate(
           rc =                 &msg,
           event1 =             &me->locate_event,
           event2 =             &accept_event,
           mask1 =              locate_mask,
           mask2 =              accept_mask,
           display_flag =       display_flag,
           locate_key =         prompt_key,
           acc_key =            accept_key,
           attributes =        &attributes,
           relocate_key =       EMS_P_ElementNotLocated,
           stack =             &me->locate_stack,
           rtree_classes =     &rtree_classes,
           eligible_classes =  &eligible_classes);
         }
  
         if (!(1&sts)) return (OM_S_SUCCESS);

         if (!(1&msg))
         {
            if (*response == STATUS_DISP)
            {
               fi_sts = FIf_is_displayed( me->form, &me->form_displayed );
               if ( ! me->form_displayed )
               {
                  fi_sts  = FIf_display ( me->form );
                  if (!fi_sts) 
                  {
                     me->form_displayed = TRUE;
                  }
                  else
                  {
                     fprintf(stderr, "Cannot display form EMCRfPlanPar\n" );
                  }
               }
               break; /* come back around */
            }
            if (ME.ECdtmfc->locate_event.response != EX_BACK_UP)
                return(OM_S_SUCCESS);
         }
         else
         {
           int msg_loc;
           struct GRid *loc_GRid;
           ME.ECdtmfc->elems[0] = accept_event.located_object[0];
           ME.ECdtmfc->elems[0].geom_parms.polygon_inx = 0;
           loc_GRid = &ME.ECdtmfc->elems[0].located_obj;
 
           sts = dp$erase_hilite(msg = &msg);
           if (!(1&sts&msg)) return (OM_E_ABORT);
 
           if (EFisAncestryValid(&msg_loc, 
                                 loc_GRid->objid,
                                 loc_GRid->osnum, 
                                 OPP_EMSdatpln_class_id, 
                                 FALSE))
           {
              me->ref_plane_identified = TRUE;
           }
           else
           {
              me->ref_plane_identified = FALSE;  /* planar element located */  
           }
           goto_state(SPECIFY_OFFSET);
         }
         break;
      }

      case SPECIFY_OFFSET:
      {
        char *value_string;
        value_string = '\0';


        unlock_form(me->form); /* even if it's already unlocked */
        eventmask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_DATA;

        prompt_key = EMS_P_KyInOfDs0EnThrPt;
        value_string = GRIO_DISTANCE;

        sts = ems$getevent (msg = &msg,
                            event_mask = eventmask,
                            msgnum = prompt_key,
                            value_type = value_string,
                            response = (IGRlong *) response,
                            response_data = response_data,
                            event = &me->value_event);
        if (!(1&sts)) goto wrapup;

        if (*response == STATUS_DISP)
        {
           fi_sts = FIf_is_displayed( me->form, &me->form_displayed );
           if (!me->form_displayed)
           {
              fi_sts  = FIf_display ( me->form );
              if (!fi_sts)
              {
                 me->form_displayed = TRUE;
              }
              else
              {
                 fprintf(stderr, "Cannot display form EMCRfPlanPar\n" );
              }
           }
           break;
        }

        /* 
         * Here the status form settings are critical in determining the
         * next state later on:
         */

	if (FIf_is_valid(me->form)) {
		*response = TERMINATE;
       		return (OM_E_ABORT);
       		}
           
        i_sts = get_status_parms(  me->form, 
                                  &primary_axis,
                                  &planar_face_align, 
                                  &ref_plane_align );

        if  ((me->value_event.response == EX_RJT_MOVEON) 
          || (   me->value_event.response == EX_VALUE 
              && me->value_event.event.value == 0.0))
        {
          me->value_event.response = EX_RJT_MOVEON;
          me->value_event.subtype = GRst_DEFAULT;
          me->value_event.located_object[0].located_obj.objid = NULL_OBJID;
          me->value_event.event.value = 0.0;
          if ( me->ref_plane_identified )
          {
            if (ref_plane_align == AXIS_ALIGNED )
            {
              goto_state(LOCATE_WINDOW);
            }
            else
            {
              goto_state(IDENTIFY_FIRST_AXIS);
            }
          }
          else /* planar element identified */
          {
            if ( planar_face_align == ARBITRARY_AXES )
            {
              goto_state(LOCATE_WINDOW);
            }
            else
            {
              goto_state(IDENTIFY_FIRST_AXIS);
            }
          }
        }
        else if (me->value_event.response == EX_VALUE)
        {
          goto_state(ACCEPT_NORMAL);
        }
        else if (me->value_event.response == EX_BACK_UP)
        {
          backup_state();
          break;
        }
        else if (me->value_event.response == EX_DATA )
        {
          if ( me->ref_plane_identified )
          {
            if (ref_plane_align == AXIS_ALIGNED )
            {
              goto_state(LOCATE_WINDOW);
            }
            else
            {
              goto_state(IDENTIFY_FIRST_AXIS);
            }
          }
          else /* planar element identified */
          {
            if ( planar_face_align == ARBITRARY_AXES )
            {
              goto_state(LOCATE_WINDOW);
            }
            else
            {
              goto_state(IDENTIFY_FIRST_AXIS);
            }
          }
           
        }
        else
        {
          return (OM_S_SUCCESS);
        }
        break;
      }


      case ACCEPT_NORMAL:
      {

        unlock_form(me->form); /* even if it's already unlocked */
        sts = om$send (msg = message ECdtmangpar.display_normal(TRUE),
                       targetid = my_id);
        if (!(1&sts)) goto wrapup;

        eventmask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;

        ex$message ( msgnumb = EMS_P_AcOfDrMvOnToRv );

        /*
         * no prompt - event is already on SEQ
         */
        sts = co$getevent (msg = &msg,
                           event_mask = eventmask,
                           response = response,
                           response_data = response_data,
                           event = &event);

        if ( *response == STATUS_DISP)
        {
           fi_sts = FIf_is_displayed( me->form, &me->form_displayed );
           if ( ! me->form_displayed )
           {
             fi_sts  = FIf_display ( me->form );
             if (!fi_sts) 
             {
                me->form_displayed = TRUE;
             }
             else
             {
                fprintf(stderr, "Cannot display form EMCRfPlanPar\n" );
             }
           }
           break;
        }

        /* 
         * Here the status form settings are critical in determining the
         * next state later on:
         */
        i_sts = get_status_parms(  me->form, 
                                  &primary_axis,
                                  &planar_face_align, 
                                  &ref_plane_align );

        if (event.response == EX_DATA)
        {
          me->normal_displayed = TRUE;
          if (me->ref_plane_identified)
          {
            if (ref_plane_align ==  AXIS_ALIGNED)
            {
              goto_state(LOCATE_WINDOW);
            }
            else
            {
              goto_state(IDENTIFY_FIRST_AXIS);
            }
          }
          else  /* planar face identified */
          {
            if (planar_face_align ==  ARBITRARY_AXES)
            {
              goto_state(LOCATE_WINDOW);
            }
            else
            {
              goto_state(IDENTIFY_FIRST_AXIS);
            }
          }
        }
        else if (event.response == EX_RJT_MOVEON)
        {
          me->normal_displayed = TRUE;
          sts = om$send (msg = message ECdtmangpar.display_normal(FALSE),
                         targetid = my_id);
          if (!(1&sts)) goto wrapup;

          if (ME.ECdtmfc->elems[0].geom_parms.polygon_inx)
            ME.ECdtmfc->elems[0].geom_parms.polygon_inx = 0;
          else
            ME.ECdtmfc->elems[0].geom_parms.polygon_inx = 1;

          sts = om$send (msg = message ECdtmangpar.display_normal(TRUE),
                         targetid = my_id);
          if (!(1&sts)) goto wrapup;
        }
        else if (event.response == EX_BACK_UP)
        {
          me->normal_displayed = FALSE;
          sts = om$send (msg = message ECdtmangpar.display_normal(FALSE),
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


      case IDENTIFY_FIRST_AXIS :
      {
        extern   long ppdatum_action_handler();
        struct   EMSaction_handler locate;
        OMuword accept_classid[2];
        int lc_info_index;

        unlock_form(me->form); /* even if it's already unlocked */
        /* except in this state, ARBITRARY is not an option */
        FIg_disable(me->form, EMS_g_ARBITRARY ); 
        attributes.properties |= LC_RW;

        attributes.owner_action = LC_READ;
        if(aflag)
          attributes.owner_action |= LC_REF_OBJECTS;

        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        r_classes[0] = OPP_GRbspline_class_id;
        e_classes[0] = OPP_GRbspline_class_id;

	if (FIf_is_valid(me->form)) {
		*response = TERMINATE;
       		return (OM_E_ABORT);
       		}
        
        i_sts = get_status_parms(  me->form, 
                                  &primary_axis,
                                  &planar_face_align, 
                                  &ref_plane_align );
   
        
        lc_info_index = (primary_axis == X_AXIS_PRIMARY) ? 1 : 2;

        locate_mask = GRm_DATA | GRm_BACK_UP;
        prompt_key = primary_axis ? EMS_P_IdentYAxis : EMS_P_IdentXAxis;

        if (   (!me->ref_plane_identified && planar_face_align == BOTH_AXES  )
            || ( me->ref_plane_identified && ref_plane_align == AXES_DEFINED ) )
        {
           accept_key = 
              primary_axis ? EMS_P_IdentPosXAxisRjt : EMS_P_IdentPosYAxisRjt;
        }
        else
        {
           accept_key = EMS_P_AcceptReject;
        }

        accept_classid[0] = OPP_GRcurve_class_id;
        accept_classid[1] = OPP_SKmgr_class_id;
        locate.next = NULL;
        locate.option = 1;
        locate.type = 3;
        locate.num_objects = 2;
        locate.objects.classids = accept_classid;

        sts = lc$locate(
           rc               = &msg,
           event1           = &me->locate_event,
           event2           = &accept_event,
           mask1            =  locate_mask,
           mask2            =  accept_mask,
           display_flag     =  display_flag,
           act_handler      =  ppdatum_action_handler,
           act_args         = &locate,
           locate_key       =  prompt_key,
           acc_key          =  EMS_P_AcceptReject,
           attributes       = &attributes,
           relocate_key     =  EMS_P_ElementNotLocated,
           stack            = &me->locate_stack,
           rtree_classes    = &rtree_classes,
           eligible_classes = &eligible_classes);
        if (!(1&sts)) return (OM_S_SUCCESS);

	if (FIf_is_valid(me->form)) {
		*response = TERMINATE;
       		return (OM_E_ABORT);
       		}
 
        i_sts = get_status_parms(  me->form, 
                                  &primary_axis,
                                  &planar_face_align, 
                                  &ref_plane_align );
    
        if (!(1&msg))
        {
          if ( *response == STATUS_DISP)
          {
            fi_sts = FIf_is_displayed( me->form, &me->form_displayed );
            if ( ! me->form_displayed )
            {
              fi_sts  = FIf_display ( me->form );
              if (!fi_sts) 
              {
                 me->form_displayed = TRUE;
              }
              else
              {
                 fprintf(stderr, "Cannot display form EMCRfPlanPar\n" );
              }
            }
            break;
          } 
          
          if (ME.ECdtmfc->locate_event.response == EX_BACK_UP)
          {
            backup_state();
            break;
          }
          else
           return(OM_S_SUCCESS);
        }
        else
        {
          if (accept_event.response == EX_DATA)
          {
            ME.ECdtmfc->elems[lc_info_index] = accept_event.located_object[0];
            ++me->num_hilited;
          }
        }

        if (me->ref_plane_identified)
        {
          if (ref_plane_align==AXES_DEFINED )
          {
            goto_state(IDENTIFY_SECOND_AXIS);
          }
          else
          {
            goto_state(GET_AXIS_DIRECTION);
          }
        }
        else /* planar element located */
        {
          if (planar_face_align == BOTH_AXES)
          {
            goto_state(IDENTIFY_SECOND_AXIS);
          } 
          else
          {
            goto_state(GET_AXIS_DIRECTION);
          }
        }
        break;
      }


      case IDENTIFY_SECOND_AXIS:
      {
        extern   long ppdatum_action_handler();
        struct   EMSaction_handler locate;
        OMuword accept_classid[2];
        int lc_info_index;

        lock_form(me->form); /* even if it's already locked */

        attributes.properties |= LC_RW;

        attributes.owner_action = LC_READ;
        if(aflag)
          attributes.owner_action |= LC_REF_OBJECTS;

        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        r_classes[0] = OPP_GRbspline_class_id;
        e_classes[0] = OPP_GRbspline_class_id;


        locate_mask =  GRm_DATA | GRm_BACK_UP;
        prompt_key = primary_axis ? EMS_P_IdentPosXAxis : EMS_P_IdentPosYAxis;

        accept_classid[0] = OPP_GRcurve_class_id;
        accept_classid[1] = OPP_SKmgr_class_id;
        locate.next = NULL;
        locate.option = 1;
        locate.type = 3;
        locate.num_objects = 2;
        locate.objects.classids = accept_classid;
          
        sts = lc$locate(
           rc               = &msg,
           event1           = &me->locate_event,
           event2           = &accept_event,
           mask1            =  locate_mask,
           mask2            =  accept_mask,
           display_flag     =  display_flag,
           act_handler      =  ppdatum_action_handler,
           act_args         = &locate,
           locate_key       =  prompt_key,
           acc_key          =  EMS_P_AcceptReject,
           attributes       = &attributes,
           relocate_key     =  EMS_P_ElementNotLocated,
           stack            = &me->locate_stack,
           rtree_classes    = &rtree_classes,
           eligible_classes = &eligible_classes);

        if (!(1&sts)) return (OM_S_SUCCESS);

	if (FIf_is_valid(me->form)) {
		*response = TERMINATE;
       		return (OM_E_ABORT);
       		}

        i_sts = get_status_parms(  me->form, 
                                  &primary_axis,
                                  &planar_face_align, 
                                  &ref_plane_align );

        lc_info_index = (primary_axis == X_AXIS_PRIMARY) ? 2 : 1;

        if (!(1&msg))
        {
            if (*response == STATUS_DISP)
            {
               fi_sts = FIf_is_displayed( me->form, &me->form_displayed );
               if ( ! me->form_displayed )
               {
                  fi_sts  = FIf_display ( me->form );
                  if (!fi_sts) 
                  {
                     me->form_displayed = TRUE;
                  }
                  else
                  {
                     fprintf(stderr, "Cannot display form EMCRfPlanPar\n" );
                  }
               }
               break; /* come back around */
            }

          if (ME.ECdtmfc->locate_event.response == EX_BACK_UP)
          {
            backup_state();
            break;
          }
          else
          {
            return(OM_S_SUCCESS);
          }
        }
        else
        {
          if (accept_event.response == EX_DATA)
          {
           ME.ECdtmfc->elems[lc_info_index] = accept_event.located_object[0];
           ++me->num_hilited;
          }
        }

        goto_state(LOCATE_WINDOW);

        /*
         * Shelley Heard: 09/22/92 - we lock and unlick the form now; 
         * we no longer erase the form when it is not needed.
         */
        /*
         * fi_sts = FIf_is_displayed( me->form, &me->form_displayed );
         * if (me->form_displayed)
         * {
         *    FIf_erase(ME.ECdtmfc->form);
         *    me->form_displayed = FALSE;
         * }
         */
        break;
      }
      
      
      case  GET_AXIS_DIRECTION:
      {
         int lc_info_index;
         struct IGRdisplay active_display;

        lock_form(me->form); /* even if it's already locked */
        /*
         * display the axis direction arrow for the single axis identified;
         * MOVEON reverses the arrow continuously until it is accepted.
         */
        sts = gr$get_active_display( buffer = &active_display );

	if (FIf_is_valid(me->form)) {
		*response = TERMINATE;
       		return (OM_E_ABORT);
       		}

        i_sts = get_status_parms(  me->form, 
                                  &primary_axis,
                                   (int *) NULL,
                                   (int *) NULL );
        lc_info_index = (primary_axis == X_AXIS_PRIMARY) ? 1 : 2;

        aflag = pwIsActivationOn();
        if (aflag)
        {
          bytes_in = sizeof (struct GRmd_env);
          gr$get_module_env (msg = &amsg_loc, sizbuf = &bytes_in,
                             buffer = &dispenv, nret = &bytes_out);
        }

        sts = EFdisplay_curve_normal_or_tangent(
                &ME.ECdtmfc->elems[lc_info_index],
                &me->locate_event,
                 TANGENT,
                 reverse_vector,
                 my_id,
                 GRbd,        
                aflag ? &dispenv : &me->elems[0].module_info,
                &active_display,
                &msg);

        ex$message ( msgnumb = EMS_P_AccAxisDirMvOnRv );

        eventmask = GRm_RJT_MOVEON | GRm_DATA | GRm_STRING | GRm_BACK_UP ;
        event.event.keyin[0] = '\0';

        sts = co$getevent( msg = &msg, 
                           event_mask = eventmask,
                           response = response, 
                           response_data = response_data,
                           event = &event );
                           
        sts = EFdisplay_curve_normal_or_tangent(
                &ME.ECdtmfc->elems[lc_info_index],
                &me->locate_event,
                 TANGENT,
                 reverse_vector,
                 my_id,
                 GRbe,        
                aflag ? &dispenv : &me->elems[0].module_info,
                &active_display,
                &msg);
                   
        if( event.response == EX_DATA )
        {
          me->options = reverse_vector ? EMS_EDGE_REV : 0;

          goto_state(LOCATE_WINDOW);
        }
        else if ( event.response == EX_RJT_MOVEON )
        {
          reverse_vector = reverse_vector ? 0 : 1;
          /*
           * No state change
           */
        }
        else if ( event.response == EX_BACK_UP )
        {
          backup_state();
        }
        else if ( event.response == GR_UNKNOWN_TYPE )
        {
          return (OM_S_SUCCESS);
        }

        break;
      }

      case LOCATE_WINDOW:
      {
        struct GRevent event;

        lock_form(me->form); /* even if it's already locked */

        ex$message (msgnumb = EMS_P_IdWnROrMvOnNoReOr);

        eventmask = GRm_RJT_MOVEON | GRm_DATA | GRm_STRING | GRm_BACK_UP ;
        event.event.keyin[0] = '\0';

        sts = co$getevent( msg = &msg, 
                           event_mask = eventmask,
                           response = response, 
                           response_data = response_data,
                           event = &event );

        /* clear error field */
        ex$message ( msgnumb = EMS_I_00000 , field = ERROR_FIELD);

        if (*response == STATUS_DISP)
        {
          fi_sts = FIf_is_displayed( me->form, &me->form_displayed );
          if ( ! me->form_displayed )
          {
            fi_sts  = FIf_display ( me->form );
            if (!fi_sts) 
            {
              me->form_displayed = TRUE;
            }
            else
            {
              fprintf(stderr, "Cannot display form EMCRfPlanPar\n" );
            }
          }
          break; /* come back around */
        }

        switch (event.response)
        {
           case EX_DATA:
           {
              wingrid[0].objid = event.event.button.objid;
              wingrid[0].osnum = event.event.button.osnum;
              numwin = 1;
              if (IF_NULL_OBJID (wingrid[0].objid))
              {
                 ex$message (msgnumb = EMS_S_NotWindowSpecification);
                 break;
              }
	      /* since PROCESS has no filter, no need to save prev_state */
              ME.super_cmd->state = PROCESS;
              break;
           }

           case EX_STRING:
           {
              if (event.event.keyin[0] == '\0')
              {
                wingrid[0].objid = NULL_OBJID;
	        /* since PROCESS has no filter, no need to save prev_state */
                ME.super_cmd->state = PROCESS;
                break;
              }
              sts = dp$get_gragad_id (
                       msg = &msg, 
                       name = event.event.keyin,
                       total_num = &total_numwin,
                       numberofids = &numwin,
                       found_GRids = wingrid,
                       type_gragad = ALL_GG_CLASSES | ACTIVE_GG);

              if (!(1&sts)) return (OM_E_ABORT);

              if (!numwin)        
              {
                ex$message (msgnumb = EMS_S_NotWindowSpecification);
                break;
              }
	      /* since PROCESS has no filter, no need to save prev_state */
              ME.super_cmd->state = PROCESS;
              break;
           }

          case EX_RJT_MOVEON:
          {
            wingrid[0].objid = NULL_OBJID;
	    /* since PROCESS has no filter, no need to save prev_state */
            ME.super_cmd->state = PROCESS;
            break;
          }

         case EX_BACK_UP:
         {
           backup_state();

           if (me->value_event.subtype == GRst_DEFAULT)
	       {
             struct GRlc_info *erase_elem;

             erase_elem = &ME.ECdtmfc->elems[1];
             display_mode = GRhe;
             if (erase_elem->located_obj.objid != NULL_OBJID)
             {
               aflag = pwIsActivationOn();
               if (aflag)
               {
                 bytes_in = sizeof (struct GRmd_env);
                 gr$get_module_env (msg = &amsg_loc, sizbuf = &bytes_in,
                 buffer = &dispenv, nret = &bytes_out);
                 sts = om$send ( msg = message GRgraphics.GRdisplay(
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
                 sts = om$send (
                      msg = message GRgraphics.GRdisplay(
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
           break;
         }
          
         default:
            return (OM_S_SUCCESS);

        }
                      
        break;
      }

      case PROCESS:
      {
        OMuword constr_os;
        OM_S_OBJID res_id,old_datum;
        double xdir[3], zdir[3], origin[3];
        struct GRvg_construct const_list;
        struct GRlc_info datum_lc_info;
        struct GRid mgr_GRid;

        /*
         * NO FILTER CALL IN THIS STATE.
         */
	if (FIf_is_valid(me->form)) {
		*response = TERMINATE;
       		return (OM_E_ABORT);
       		}

        i_sts = get_status_parms(  me->form, 
                                  &primary_axis,
                                  &planar_face_align, 
                                  &ref_plane_align );

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
     
        /*
         *  Determine options for construction of new reference plane.
         */
        if ( me->value_event.response == EX_OBJID || 
             me->value_event.response == EX_DATA )
        {
          me->options |= EMS_THRU_POINT;
        }
        else if (me->value_event.response != EX_RJT_MOVEON)
        {
          me->options |= EMS_OFFSET_VALUE;
        }

        if (me->ref_plane_identified)
        {
          if (ref_plane_align == AXES_DEFINED)
          {
            me->options |= (EMS_X_EDGE || EMS_Y_EDGE);
            if (primary_axis == X_AXIS_PRIMARY)
            {
              me->options |= EMS_X_EDGE_PRIMARY;
            }
          }
        }
        else /* planar element identified */
        {
          if (planar_face_align != ARBITRARY_AXES )
          {
            if (primary_axis == X_AXIS_PRIMARY)
            {
              me->options |= (EMS_X_EDGE_PRIMARY);
            }
            if (planar_face_align == BOTH_AXES )
            {
               me->options |= (EMS_X_EDGE || EMS_Y_EDGE );
            }
            else
            {
              if (primary_axis == X_AXIS_PRIMARY)
              {
                me->options |= EMS_X_EDGE;
              }
              else
              {
                me->options |= EMS_Y_EDGE;
              }
            }
          }
        }
        constr_os = const_list.env_info->md_id.osnum;

  
        /* 
         * make new reference plane the active one 
         */
        /*
         * Make sure you get the correct osnum's plane manager
         */

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
        me->options |= EMS_PLANE_REV;

      sts = EFcreate_ref_parallel_to_plane1( 
                 &msg,
                  (me->is_associative ? NULL : EMSasconst_notassociative),
                 &ME.ECdtmfc->elems[0],
                 &ME.ECdtmfc->elems[1],
                 &me->value_event,
                  me->options,
                 &const_list,
                 &res_id );

       if (!(1&msg)) return (OM_E_ABORT);

      if (wingrid[0].objid != NULL_OBJID)
      {
       struct GRmd_env rfenv;

       if(aflag = pwIsActivationOn())
       {
         sts = pwGetActiveModuleEnv(&rfenv);
         sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg,
                              NULL, &rfenv,
                              xdir,NULL,zdir,origin,NULL),
                        targetid = res_id,
                        targetos = constr_os);
         if (!(1&sts&msg)) return (OM_E_ABORT);
       datum_lc_info.module_info = rfenv;
       }
       else
       {
         sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg,
                              NULL,const_list.env_info,
                              xdir,NULL,zdir,origin,NULL),
                        targetid = res_id,
                        targetos = constr_os);
         if (!(1&sts&msg)) return (OM_E_ABORT);
       datum_lc_info.module_info = *(const_list.env_info);
       }
                      
       datum_lc_info.located_obj.objid = res_id;
       datum_lc_info.located_obj.osnum = constr_os;

       sts = EMsetwinornt (&msg, numwin, wingrid,
                    origin,
                    xdir, zdir,
                    &datum_lc_info);
       if (!(1&sts&msg)) return (OM_E_ABORT);
      }

       if (old_datum != NULL_OBJID)
      {
        /*
         * Redisplay the old datum plane since the now constructed entity is going
         * to be active.
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

        if (!(1&sts&msg))  return (OM_E_ABORT);
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
      if (!(1&sts&msg))  return (OM_E_ABORT);
      ME.super_cmd->state = IDENTIFY_PLANE;

      if (me->normal_displayed)
      {
        om$send (msg = message ECdtmangpar.display_normal(FALSE),
                 targetid = my_id);
        sts = dp$erase_hilite(msg = &msg);
        me->num_hilited = 0;
      }
       /*
        * clear out options for next cycle 
        */
       me->options = 0; 
     }

     /* no default -just drop through */

    }  /* switch (ME.super_cmd->state) */

   } while (TRUE);

wrapup:

   /* on exit, set me->form_displayed so that on a subsequent wakeup,
    * the form is displayed if needed.
    */
   fi_sts = FIf_is_displayed( me->form, &me->form_displayed );

   if (!(1&sts&msg)) return (OM_E_ABORT);
   else
    return (OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
   long sts = OM_S_SUCCESS;
   long msg_loc;

   GRstatus_display_button(0);
   if (me->set_edge_locatable_flag)
    EFset_locate_eligibility(&msg_loc,2,"EMSedge");

   if (me->normal_displayed)
   {
     om$send (msg = message ECdtmangpar.display_normal(FALSE),
                   targetid = my_id);
   }

   sts = om$send (msg = message ECdtmangpar.sleep(pos),
                  mode = OM_e_wrt_parent,
                  targetid = my_id);

   return(sts);
}


method init(int type;char *str_ptr)
{
   int sts,
       fi_sts;

   sts = om$send (msg = message ECdtmfc.init(type, str_ptr),
                  mode = OM_e_wrt_message,
                  targetid = my_id);

   /* create status form - but do not display it */

   fi_sts  = FIf_new (0, 
                      "EMCRfPlanPar", 
                      EMCRfPlanPar_notification_routine, 
                      &me->form );

   if (fi_sts != FI_SUCCESS) 
   {
      fprintf(stderr, "Cannot find form EMCRfPlanPar\n" );
      me->form = NULL;
   }
   else
   {
      /* Make sure default values are set */
      fi_sts = FIg_set_state_on( me->form, EMS_g_BOTH_AXES );
      fi_sts = FIg_set_state_on( me->form, EMS_g_ALIGN     );
      fi_sts = FIg_set_state_on( me->form, EMS_g_X_PRIMARY );
   }
   
   me->form_displayed = FALSE;

   return(OM_S_SUCCESS);
}

method wakeup (int pos)
{
   IGRboolean aflag=0;
   long sts = OM_S_SUCCESS;
   long msg_loc;
   extern short EFedge_curves_locatable();

   if (!(EFedge_curves_locatable ()))
   {
    me->set_edge_locatable_flag = 1;
    EFset_locate_eligibility(&msg_loc,2,"EMSedge");
   }
   else
     me->set_edge_locatable_flag = 0;
   
   /*
    *  if status form should be re-displayed, then do it.
    */
   if (me->form_displayed)
   {
     FIf_display( me->form );
   }
   sts = om$send (msg = message ECdtmangpar.wakeup(pos),
                  mode = OM_e_wrt_parent,
                  targetid = my_id);

   aflag = pwIsActivationOn();
   if (aflag)
   {
     sts = pwGetActiveModuleEnv(&me^^ECelement.md_env);
   }

   if (me->normal_displayed)
   {
     om$send (msg = message ECdtmangpar.display_normal(TRUE),
              targetid = my_id);
   }

   if (me->form_displayed)
   {
     FIf_display( me->form );
   }

   return(sts);
}


method display_normal(int draw_background)
{
   IGRboolean aflag=0;
   long sts, msg_loc;
   struct GRmd_env *loc_env;
   struct GRid *grid;
   short reverse_vector, in_world;
   double range[6], vector[3],origin[3];
   enum GRdpmode display_mode;

   msg_loc = sts = OM_S_SUCCESS;

   if (ME.ECdtmfc->elems[0].geom_parms.polygon_inx)
      reverse_vector = 1;
   else
      reverse_vector = 0; 

   in_world = TRUE;
      
   loc_env = &me->elems[0].module_info;
   grid = &me->elems[0].located_obj;

   sts = om$send (msg = message GRgraphics.GRgetrang(
                                  &msg_loc,
                                  &loc_env->md_env.matrix_type,
                                   loc_env->md_env.matrix,
                                  &in_world,
                                   range),
                  targetid = grid->objid,
                  targetos = grid->osnum);
   if (!(1&sts&msg_loc)) goto wrapup;

    if (me->ref_plane_identified)
    {
      sts = om$send ( msg = message EMSdatpln.EMget_pln_info(
                                       &msg_loc,
                                        NULL, 
                                        loc_env,
                                        NULL,
                                        NULL,
                                        vector,
                                        origin,
                                        NULL),
                      targetid = grid->objid,
                      targetos = grid->osnum);
      if (!(1&sts&msg_loc)) goto wrapup;
    }
    else
    {
      short pos_orient,i;
      unsigned short pos_option;
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
      EFdraw_vector_on_screen( my_id, 
                               &ME.ECelement->active_display,
                               &me->md_env, 
                               display_mode, 
                               reverse_vector,
                               origin,
                               vector,
                               range,
                              &msg_loc);
    }
    if (!(1&msg_loc)) goto wrapup;

wrapup:
   if (!(1&sts&msg_loc)) return (OM_E_ABORT);
   return (sts);
}


method is_status_form_valid(int *valid)
{
   if ((ME.super_cmd->state == IDENTIFY_PLANE)  ||
       (ME.super_cmd->state == SPECIFY_OFFSET))
   {
     *valid = TRUE;
   }
   else
   {
     *valid = FALSE;
   }

   return (OM_S_SUCCESS);
}

method delete (int f_defer_flag)
{
   int sts;

   sts = om$send ( msg = message ECdtmfc.delete(f_defer_flag),
                   mode = OM_e_wrt_message,
                   targetid = my_id);

   return (OM_S_SUCCESS);
}



#ifdef HODEDODODODODO    /* multiply defined for now */
long ppdatum_action_handler(
   do_not_locate,
   new_entry,
   locate_args,
   action)

  struct EMSaction_handler *do_not_locate;
  struct GRlc_info         *new_entry;
  struct LC_action_args    *locate_args;
  enum GRlocate_action     *action;
{
   short        call_action_handler;
   long         msg_loc;
   long         sts;
  /*
   * Initialize
   */
   call_action_handler = TRUE;

   switch (*action)
    {
     case add_all:
     case add_inside:
     case add_outside:
     case add_overlap:
     case add_nopost:
     {
       long     i;
       short graphics_props;
       struct   GRid check_id, *search_id, temp_GRid;
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
       short dont_locate;
   
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
     extern long LCptlocact();

      sts = LCptlocact(NULL, new_entry, locate_args, action);
   }
   else
     sts = OM_S_SUCCESS;
  /*
   * Eof
   */
   return(sts);
}

#endif

end implementation ECdtmangpar;
