class implementation ECmarchfil;

/*
  ALGORITHM:

  init:    initialize instance data, set up form and send ECelements.init()
           compress static array of eles.
  wakeup:  recalculate march arrow base & tip and update instance data
  delete:  free any memory and delete CO
  execute: the main loop has a default state of options/actions form.  the
           command is driven by option selected on the this form.

           get radius:    get fillet/patch radius

           add fillets:   hilite all fillets in the static array.
                          locate and add fillet new to the array
                          (it's assumed the user located fillet.  we don't 
                           check if he/she located something else)

           place fillet:  locate 2 surfaces & place a fillet.  
                          if(! rolling on a fillet) the fillet is extended
                          EMcrfilletsurf
                          if(extended fillet)
                            map fillet to boundaries (EMflsfint)
                          if closed fillet after mapping
                             start a new chain
                          else 
                             if (closed fillet || multiple pieces) && first ele
                               get a data point from the user
                             disp/evaluate march dir
                             if previous element was a fillet,
                                EMflflimpose() or EMflflimpose2()
                             else previous element was a sph patch
                                EMspflimpose()
                             else if no previous ele (this is first ele)
                                clip one end to boundary
                             clip open end to boundary (ECmf_newfl)
                             disp march dir
                             store open edge 'Vs'
                             save state
                             add fillet to static array of fillets

           sph. patch:    locate 3 surfaces & place a sph. patch.  
                          EMcrpsphere
                          if previous element was a fillet,
                             EMspflimpose()
                          disp march dir
                          store open edge 'Vs'
                          save state

           trim fillet:   if located a sph. patch
           (tan surfs)       EMspflimpose()
                          else 
                             lcoate 'n' surfaces
                             EMmarfiltantrim (extends fillet before trimming)
                          update open edge 'Vs'
                          no march dir disp
                          save state

           trim fillet:   lcoate 'n' surfaces
           (int surfs)    EMmarfiltrim (extends fillet before trimming)
                          update open edge 'Vs'
                          no march dir disp
                          save state

           new chain:     cleanup & initialization.

           change dir:    show open (not imposed) ends of all eles
                          locate the desired end
                          make lcoated ele as march front, disp direction

           UNDO:          copy elements from previously saved state by 
                          sending message pop_node
                          disp march dir at hot edge

           extend fillet: EMbef_filterm() to extend open (marching) end of 
                          fillet upto natural surface.

           fillet_extend: set extension for fillets to be placed from now on
                          (the existing fillets are not affected)
                         
note: if last ele (top ele) in eles array is sph patch, march_arrow is not
      valid.  march_arrow can be calculated only after placing next fillet.

 get_locate_criteria:     see ECelements.S


 proc_locobj:             special handling for first ele in 
                          GET_RADIUS : get radius of located ele, set harmless
                                       static global and terminate do_locate
                          TAN_TRIM   : if located sph. patch, terminate
                             &         do_locate
                          INT_TRIM 


 push_node:               save state by copying current element.


 pop_node:                see UNDO above


 disp_march_dir:          see method for documentation

******************************************************************************

  HISTORY

  pac      11/18/92     creation
  pac      06/18/92     rewrite
  Sudha    07/05/93     Modified for BSprototypes ansification
  pac      08/02/93     UMS complient
  pac      08/17/93     changed logic of proc_locobj
                        no errorcheck  after EMflflimpose2() & ECmf_newfl()
                        Toggle Sf Bdry Loc from within the command
                        enable MATL/NON_MATL toggle after poking new_chain
                        retain radius across invocations
  scw      08/14/94     clarfied sleep method


*/

#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsfreesf.h"

#include "msdef.h"
#include "msmacros.h"

#include "igr.h"
#include "EC_S.h"
#include "EC_M.h"
#include "EMSopt.h"
#include "EMSlmdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "emsbool.h"
#include "ECmfdef.h"
#include "ECmfopt.h"
#include "ECmferr.h"

#include "bssph_prop.h"
#include "bssfeval.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsfilsftest.h"

#define SOME_TOL 0.000001
#define EQUAL_TOL 0.000001
#define FILLET_TOL 0.05

#define GET_RADIUS	1
#define GET_POINT       2
#define OPT_FORM        3
#define PLACE_FILLET	4
#define PROC_FILLET	5
#define PLACE_SPH	6
#define PROC_SPH	7
#define INT_TRIM	8
#define TAN_TRIM	9
#define ADD_FILLETS    10
#define EXT_FILLET     11
#define CHANGE_DIR     12

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define MEM_FREE( addr ) if ( addr ) { free ( addr ) ; addr = 0 ; }
#define TLS_EQUAL(a, b) ( (fabs(a-b) < EQUAL_TOL) ? 1 : 0 )
#define GE(a, b) ( (a>b) || (fabs(a-b) < EQUAL_TOL) )
#define LE(a, b) ( (a<b) || (fabs(a-b) < EQUAL_TOL) )

extern double fabs(), atof(), sqrt(), BSlenvec();
extern GRclassid OPP_EMSsubbs_class_id;
extern GRclassid OPP_GRflxown_class_id;
extern OMuword OPP_EMSpsphere_class_id;

from GRvg import GRgetsize, GRgetgeom;
from GRgraphics import GRcopy, GRdelete, GRchgprops, GRdisplay;
from EMSsubbs import EMget_edges, EMsftanorm, EMget_ele_header;
from EMSedge import EMdisplay, EMinternalpt, EMget_bcxyz_geom;
from EMSboundary import EMgetsurface_info;

%safe
static double harmless_global=-1;
static struct GRid *ECmf_fillets=0;
static IGRint ECmf_num_fillets=0;
static double ECmf_radius=0.1;
%endsafe

%safe
static int qq_sf_is_fill();
static int qq_get_ele_radius();
static int get_pos_orient();
static int qq_build_ele_header();
%endsafe

method init (IGRint type; IGRchar *string)
{
  IGRlong ret0=OM_S_SUCCESS;
  IGRint ii, indx;
  struct GRid temp_arr[100];
  char *form_ptr=0;

  ME.ECmarchfil->radius = ECmf_radius;
  ME.ECmarchfil->fil_extend = -1;
  ME.ECmarchfil->num_nodes = 0;
  ME.ECmarchfil->march_front = 0;
  ME.ECmarchfil->material_side = 1;
  ME.ECmarchfil->new_chain = 1;
  ME.ECmarchfil->disp_trim = 0;

  ret0 = om$send (mode = OM_e_wrt_message, msg = message ECelements.init
             (type, string), targetid = my_id);
  MF_EMerr_hndlr (EMSerror (ret0), ret0, OM_E_ABORT, ret_end);

  /* 
   * allocate array if necessary
   */

  if(! ECmf_num_fillets)
    {
    ECmf_fillets = (struct GRid *) 
                          om$malloc( size = 100 * sizeof(struct GRid) );
    MF_EMerr_hndlr (!ECmf_fillets, ret0, EMS_E_NoDynamicMemory, ret_end);

    }
  else if(! ECmf_num_fillets%100)
    {
    ECmf_fillets = (struct GRid *) om$realloc( ptr = (char *) ECmf_fillets, 
                        size = (100 + ECmf_num_fillets) * sizeof(struct GRid) );
    MF_EMerr_hndlr (!ECmf_fillets, ret0, EMS_E_NoDynamicMemory, ret_end);
    }

  /*
   * compress array
   */

  indx = 0;
  for(ii=0; ii<ECmf_num_fillets; ii++)
    if( om$is_objid_valid(osnum = ECmf_fillets[ii].osnum, 
                          objid = ECmf_fillets[ii].objid ) == OM_S_SUCCESS )
      {
      temp_arr[indx].objid = ECmf_fillets[ii].objid;
      temp_arr[indx].osnum = ECmf_fillets[ii].osnum;
      indx++;
      }
  ECmf_num_fillets = indx;

  for(ii=0; ii<ECmf_num_fillets; ii++)
    {
    ECmf_fillets[ii].objid = temp_arr[ii].objid;
    ECmf_fillets[ii].osnum = temp_arr[ii].osnum;
    }

  /*
   * setup form
   */

  form_ptr = 0;
  ret0 = ECmf_setup_form(&form_ptr, 0, 1, 0, 0, my_id, OM_Gw_current_OS, 0);
  MF_EMerr_hndlr (EMSerror (ret0), ret0, OM_E_ABORT, ret_end);

  FIg_disable(form_ptr, GAD_GRP);
  FIg_enable(form_ptr, NEW_CHAIN);
  FIg_set_state_on(form_ptr, NEW_CHAIN);
  FIg_enable(form_ptr, MATLTOGGLE);

  ME.ECmarchfil->form_ptr = form_ptr;
  ME.super_cmd->state = GET_RADIUS;

ret_end:
  return (ret0);
}
/* init */

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRlong msg_loc, eventmask, size, ret0=OM_S_SUCCESS;
  struct GRevent event;
  struct GRvg_construct const_list;
  struct IGResbc esbc;
  enum EMSuser_responses useract;
  IGRushort opts=0;
  IGRint num_fil,ii, num_fillets;
  IGRdouble radius=0.0, rho;
  IGRpoint dummy_point;
  GRobjid *fillets=0;
  struct GRid *fil_id=NULL;  /* free only on TERMINATE */
  struct GRid *sph_id=NULL; 
  char promptstr[50];
  /* IGRint num_nodes, prev_indx, *march_stack, march_front; */
  struct IGRbsp_surface *sph_surf=0, **fil_surf=0;
  IGRushort *fillet_srf_props=0;
  IGRboolean no_need=0;


  /* fill construction list */

  const_list.msg = &msg_loc;
  const_list.env_info = &ME.ECelements->active_md_env;
  const_list.newflag = FALSE;
  const_list.level = ME.ECelements->active_level;
  const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  const_list.geometry = NULL;
  const_list.display = &ME.ECelements->active_display;
  esbc.is_polydis = FALSE;
  esbc.is_curvedis = TRUE;
  const_list.class_attr = 0;
  const_list.name = NULL;

  while (TRUE)
    {

    switch (ME.super_cmd->state)
      {
      case GET_RADIUS:

        ex$message( msgnumb = EM_M_RndMan );
        ex$message(msgnumb = EMS_I_Set_Tog, field = ERROR_FIELD);

	{
        char tempstr[150];

        ex$message( msgnumb = EMS_P_LocEle_Ip_Rad, buff = tempstr);
        sprintf(promptstr, "%s[%4.4f]", tempstr, ME.ECmarchfil->radius);

        eventmask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP | 
                    GRm_VALUE | GRm_RESTART;
        ret0 = co$getevent (msg = &msg_loc, prompt = promptstr,
	                    value_type = GRIO_DISTANCE,
                            response = response, 
                            response_data = response_data,
		            event_mask = eventmask, event = &event);
#ifdef DEBUG
  if(0)
    {
    fprintf(stderr, "resp %d resp data %s\n", *response, response_data);
    fflush(stderr);
    }
#endif

        if (msg_loc == GRw_no_value)
	  {
          ME.super_cmd->state = OPT_FORM;
	  ME.ECmarchfil->new_chain = 1;
	  ME.ECmarchfil->disp_trim = 0;
	  break;
	  }

        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
        ex$message(msgnumb = EMS_P_ClearPromptField);

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.super_cmd->state = OPT_FORM;
	    ME.ECmarchfil->new_chain = 1;
	    ME.ECmarchfil->disp_trim = 0;
            break;

          case EX_BACK_UP:
          case EX_RESTART:
            ME.super_cmd->state = GET_RADIUS;
            break;

          case EX_VALUE:

	    ME.ECmarchfil->radius = atof(response_data);
	    if(! ME.ECmarchfil->radius)
	      ME.super_cmd->state = GET_RADIUS;
	    else
	      {
              ME.super_cmd->state = OPT_FORM;
	      ME.ECmarchfil->new_chain = 1;
	      ME.ECmarchfil->disp_trim = 0;
              ECmf_radius = ME.ECmarchfil->radius;
	      }
             break;

          case EX_DATA:

            {
            size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
            ret0 = ex$putque ( msg = &msg_loc, response = response, 
                               byte = &size, buffer = (char *) &event.event );
            MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, 
                            OM_E_ABORT, ret_end);

            ME.ECelements->max_to_locate = 1;
            
            ex$message( msgnumb = EMS_P_Ex_Ele, buff = promptstr);
            ret0 = om$send (msg = message ECelements.do_locate (&msg_loc,
                            &useract, response, response_data, 
                            promptstr,
                            NULL, NULL, NULL, NULL, NULL), targetid = my_id);
            MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, 
                            OM_E_ABORT, ret_end);

            if (useract == EMSuser_moveon)
              ME.super_cmd->state = GET_RADIUS;
            else if (useract == EMSuser_data)
              {
              struct ele_stack *temp_ele=0;
#ifdef DEBUG 
if(0)
  for(ii=0; ii<ME.ECelements->num_elems; ii++)
    fprintf(stderr, "loc surface %d\n", 
	  ME.ECelements->elems[ii].located_obj.objid);
#endif

               temp_ele = (struct ele_stack *)
                           om$malloc( size = sizeof(struct ele_stack) );
               MF_EMerr_hndlr (!temp_ele, ret0, EMS_E_NoDynamicMemory, ret_end);

               temp_ele->ele_grid.objid = 
                                 ME.ECelements->elems[0].located_obj.objid;
               temp_ele->ele_grid.osnum = 
                                 ME.ECelements->elems[0].located_obj.osnum;
               temp_ele->objs_surf = 0;
               temp_ele->model_surf[0].objid = NULL_OBJID;
               temp_ele->model_surf[1].objid = NULL_OBJID;
               temp_ele->model_surf[2].objid = NULL_OBJID;
/* fix for umr */
               temp_ele->marked_edges[0]= -1;
               temp_ele->marked_edges[1]= -1;
               temp_ele->marked_edges[2]= -1;

              if(ME.ECmarchfil->curr_ele_type == SPH_ELEMENT)
                {
	        ME.ECmarchfil->disp_trim = 0;
                temp_ele->elem_type = SPH_ELEMENT;
                }
              else if(ME.ECmarchfil->curr_ele_type == FIL_ELEMENT)
                {
                temp_ele->elem_type = FIL_ELEMENT;
	        ME.ECmarchfil->disp_trim = 1;
                temp_ele->hot_edge = harmless_global;
                harmless_global = -1;
                }

              ME.ECmarchfil->curr_ele_type = -1; /* re-initialize */

              opts = 0;
              opts = FIRST_ELE;
              ret0 = ECmf_open_edges(&msg_loc, opts, 
                                     &ME.ECelements->active_md_env, 
                                     0, temp_ele);
              MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), 
                              ret0, OM_E_ABORT, ret_end);

              ret0 = om$send (msg = message ECmarchfil.push_node(&msg_loc,
                              temp_ele), targetid = my_id);
              MF_EMerr_hndlr(EMSerror(ret0 & msg_loc), ret0, 
                             OM_E_ABORT, ret_end);

              ret0 = om$send (msg = message ECmarchfil.disp_march_dir(&msg_loc,
                              0 ), targetid = my_id);
              if(EMSerror (ret0 & msg_loc))
                {
#ifdef DEBUG 
  fprintf(stderr, "Error tracking march direction\n");
  fflush(stderr);
#endif
                ex$message(msgnumb = EMS_E_Mch_Dir, field = ERROR_FIELD);
                }

              temp_ele = 0;

              ME.ECelements->locate_stack.num_entries = 0;
              ME.ECelements->num_elems = 0;
              ME.ECelements->num_events = 0;
	      ME.ECmarchfil->new_chain = 0;
              ME.super_cmd->state = OPT_FORM;
              }
            /* if (useract == EMSuser_data) */

            else if (useract == EMSuser_backup)
              ME.super_cmd->state = GET_RADIUS;

	    else
              goto ret_end;

            }
          /* case EX_DATA */ 

           default:
             goto ret_end;

          }
        /* switch (event.response) */

	}
        break; /* case GET_RADIUS */

      case OPT_FORM:
	{
        ret0 = ECmf_setup_form(&ME.ECmarchfil->form_ptr, 1,
                               ME.ECmarchfil->new_chain, 
                               ME.ECmarchfil->disp_trim, 
                               ME.ECmarchfil->num_nodes,
                               my_id, OM_Gw_current_OS, 0);
        MF_EMerr_hndlr (EMSerror (ret0), ret0, OM_E_ABORT, ret_end);

        om$send (msg = message ECmarchfil.disp_march_dir(&msg_loc, 0 ), 
                               targetid = my_id);

        UI_status("");

        ex$message( msgnumb = EM_M_RndMan );
        ex$message( msgnumb = EMS_P_New_Opt, buff = promptstr);

        ret0 = co$getevent(msg = &msg_loc, prompt = promptstr,
                        event_mask = GRm_MOVE_ON | GRm_RJT_MOVEON |
                                     GRm_BACK_UP | GRm_FORM_FINISHED,
                        response = response, response_data = response_data,
                        event = &event);

        MF_EMerr_hndlr (EMSerror(ret0 & msg_loc), ret0, msg_loc, ret_end);

	switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.super_cmd->state = PLACE_FILLET;
            FIg_call_notification_routine(ME.ECmarchfil->form_ptr, FILLET);
            break;

          case EX_BACK_UP:
          case EX_RESTART:
            ME.super_cmd->state = OPT_FORM;
            break;

          case EX_FORM_FINISHED:
            { 
	    switch (ME.ECmarchfil->form_option)
              {
              case NEW_CHAIN:
                dp$erase_hilite(msg = &ret0);
                ret0 = ECmf_free_copies(&msg_loc, &ME.ECelements->active_md_env,
                                        ME.ECmarchfil->num_nodes, 
                                        ME.ECmarchfil->copies);
                MF_EMerr_hndlr (EMSerror(ret0 & msg_loc), 
                                         ret0, msg_loc, ret_end);

                ME.ECelements->num_elems = 0;
                ME.ECelements->num_events = 0;
                ME.ECelements->locate_stack.num_entries = 0;
                ME.ECmarchfil->num_nodes=0;
                ME.ECmarchfil->march_front = 0;
                ME.ECmarchfil->fil_extend = -1;
                /*ME.ECmarchfil->material_side = 1;*/
                ME.ECmarchfil->new_chain = 1;
                ME.ECmarchfil->disp_trim = 0;
                FIg_enable(ME.ECmarchfil->form_ptr, MATLTOGGLE);

                ME.super_cmd->state = GET_RADIUS;
              break;

	    case FILLET:
              ME.super_cmd->state = PLACE_FILLET;
              break;

            case SPH_PATCH:
              ME.super_cmd->state = PLACE_SPH;
              break;

            case FILLET_EXT:
              ME.super_cmd->state = EXT_FILLET;
              break;

            case FILL_INT:
              ME.super_cmd->state = INT_TRIM;
              break;

            case FILL_TAN:
              ME.super_cmd->state = TAN_TRIM;
              break;

            case DIR_CHANGE:
              ME.super_cmd->state = CHANGE_DIR;
              break;

            case UNDO:
              ret0 = om$send (msg = message ECmarchfil.pop_node(&msg_loc),
                              targetid = my_id);
              MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), 
                              ret0, OM_E_ABORT, ret_end);
              ME.ECmarchfil->march_front = ME.ECmarchfil->num_nodes - 1;
              opts = 0;
              opts |= REDISPLAY_UNDO;
              ret0 = om$send (msg = message ECmarchfil.disp_march_dir(&msg_loc,
                              opts ), targetid = my_id);
              if(EMSerror (ret0 & msg_loc))
                {
#ifdef DEBUG 
  fprintf(stderr, "Error tracking march direction\n");
  fflush(stderr);
#endif
                ex$message(msgnumb = EMS_E_Mch_Dir, field = ERROR_FIELD);
                }

              ME.super_cmd->state = OPT_FORM;
              break;

            case FILLETS_ADD:
              ME.super_cmd->state = ADD_FILLETS;
              break;
	      } /* swtich ME.ECmarchfil->form_option */
            break;
            } /* case FORM_FINISHED */

          default:
            goto ret_end;

          } /* switch event.response */
        }
        break; /* case OPT_FORM */

      case PLACE_FILLET:
        {
        if(ME.ECmarchfil->material_side)
          {
          ex$message( msgnumb = EMS_I_Fl_Rm_Mat );
          }
        else
          {
          ex$message( msgnumb = EMS_I_Fl_Add_Mat );
          }

        ex$message( msgnumb = EMS_P_FillSurf, buff = promptstr);
        ME.ECelements->max_to_locate = 2;
        ret0 = om$send (msg = message ECelements.do_locate (&msg_loc,
                            &useract, response, response_data, 
                            promptstr,
                            NULL, NULL, NULL, NULL, NULL), targetid = my_id);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, 
                            OM_E_ABORT, ret_end);

        if (useract == EMSuser_moveon)
              ME.super_cmd->state = PLACE_FILLET;
        else if (useract == EMSuser_backup)
           ME.super_cmd->state = OPT_FORM;
        else if (useract == EMSuser_data)
              {
              IGRpoint ref_pt;
              IGRint num_segs;
              IGRdouble *str_segs=0, *end_segs=0;

              ex$message(msgnumb = EMS_I_PlFl, field = ERROR_FIELD);
	      UI_prompt("");

              ME.ECmarchfil->fil_opts = 0;
              ME.ECmarchfil->fil_num_segs = 0;
              MEM_FREE(ME.ECmarchfil->fil_str_segs);
              MEM_FREE(ME.ECmarchfil->fil_end_segs);
              MEM_FREE(ME.ECmarchfil->fil_grid);
        
              ret0 = get_pos_orient(ME.ECelements->num_elems,
                                    ME.ECelements->active_md_env,
                                    ME.ECelements->elems,
                                    ME.ECelements->elemprops);
              MF_EMerr_hndlr (EMSerror(ret0), ret0, OM_E_ABORT, ret_end);

              opts = 0;

              if(ME.ECmarchfil->material_side)
                {
                if(ME.ECelements->elemprops[0])
                  opts | = EMS_RND_SF1_NATSIDE;
                if(ME.ECelements->elemprops[1])
                  opts | = EMS_RND_SF2_NATSIDE;
                }
              else
               {
               if(!ME.ECelements->elemprops[0])
                 opts | = EMS_RND_SF1_NATSIDE;
               if(!ME.ECelements->elemprops[1])
                 opts | = EMS_RND_SF2_NATSIDE;
               }
            
              if(! qq_sf_is_fill(ME.ECelements->num_elems, 
                                ME.ECelements->elems) )
                opts | = EMS_RND_EXTEND_SURF;
          
              opts | = EMS_RND_SINGLE_FILLET | EMS_RND_INT_ROLLING_BALL;
              opts | = EMS_RND_BOUND_SURF  | EMS_RND_ORIENTED; 
              opts | = EMS_RND_CHECK_CURV_PROB;

              rho = sqrt(2.0) - 1;
              fillets=0;
              radius = ME.ECmarchfil->radius;

#ifdef DEBUG 
if(0)
  for(ii=0; ii<ME.ECelements->num_elems; ii++)
    fprintf(stderr, "loc surface %d\n", 
	  ME.ECelements->elems[ii].located_obj.objid);
#endif

              ref_pt[0] = ME.ECelements->locev.event.button.x;
              ref_pt[1] = ME.ECelements->locev.event.button.y;
              ref_pt[2] = ME.ECelements->locev.event.button.z;
              fil_surf = 0;
              fillet_srf_props = 0;
              ret0 = EMcrfilletsurf (&msg_loc, opts, &const_list,
                       radius, radius, rho, dummy_point, dummy_point,
                       dummy_point, ref_pt, NULL,
                       &ME.ECelements->elems[0].located_obj, 
                       &ME.ECelements->elems[1].located_obj, 
                       NULL, NULL, &num_fillets, &fillets, &fil_surf, 
                       &fillet_srf_props );

              if( EMSerror (ret0 & msg_loc) || (!num_fillets) )
                {
                BSrc rc;
                ex$message(msgnumb = EMS_I_Fl_Fail, field = ERROR_FIELD);
                ME.super_cmd->state = PLACE_FILLET;
                for(num_fil=0; num_fil < num_fillets; num_fil++)
 		  if(fil_surf[num_fil])
		   { BSfreesf(&rc,fil_surf[num_fil]);fil_surf[num_fil]=NULL;}
		if(fil_surf) om$dealloc(ptr = fil_surf); fil_surf = NULL;
                } /* we don't have a fillet */
              else
                {  
                fil_id = (struct GRid *)
                            om$malloc( size = sizeof(struct GRid) );
                MF_EMerr_hndlr (!fil_id, ret0, EMS_E_NoDynamicMemory, ret_end);

                fil_id->objid = fillets[0];
                fil_id->osnum = const_list.env_info->md_id.osnum;

                /*
                 * save stuff to be used in PROC_FILLET
                 */
       
                ME.ECmarchfil->fil_opts = opts;
                ME.ECmarchfil->fil_grid= fil_id;
                ME.ECmarchfil->fil_degen_opt = *fillet_srf_props;
                ME.ECmarchfil->fil_base_surfs[0].objid = 
                                     ME.ECelements->elems[0].located_obj.objid;
                ME.ECmarchfil->fil_base_surfs[0].osnum = 
                                     ME.ECelements->elems[0].located_obj.osnum;
                ME.ECmarchfil->fil_base_surfs[1].objid = 
                                     ME.ECelements->elems[1].located_obj.objid;
                ME.ECmarchfil->fil_base_surfs[1].osnum = 
                                     ME.ECelements->elems[1].located_obj.osnum;
                ME.ECmarchfil->fil_surf = fil_surf[0];
              
                if(! (opts & EMS_RND_EXTEND_SURF) )
                  {
                  ME.super_cmd->state = PROC_FILLET;
                  goto end_place_fillet;
                  }
                ret0 = ECmf_flsfint(&msg_loc, 0, &const_list,
                                    &ME.ECelements->active_md_env, fil_id,
                                    &ME.ECelements->elems[0].located_obj,
                                    &ME.ECelements->elems[1].located_obj,
                                    0, 0, 0, &num_segs, &str_segs, &end_segs );
                MF_EMerr_hndlr (EMSerror (ret0 & msg_loc),
                                ret0, OM_E_ABORT, ret_end);

                ME.ECmarchfil->fil_num_segs = num_segs;
                ME.ECmarchfil->fil_str_segs = str_segs;
                ME.ECmarchfil->fil_end_segs = end_segs;

                if( (TLS_EQUAL(str_segs[0], 0.0) && TLS_EQUAL(end_segs[0], 1.0))
                                                 &&
                                    ( fil_surf[0]->v_phy_closed ) )

                  {
                  dp$display(msg = &ret0, oids = fil_id, mode = GRbdhe);

                  dp$erase_hilite(msg = &ret0);
                  ret0 = ECmf_free_copies(&msg_loc, 
                                          &ME.ECelements->active_md_env,
                                          ME.ECmarchfil->num_nodes,
                                          ME.ECmarchfil->copies);
                  MF_EMerr_hndlr (EMSerror(ret0 & msg_loc),
                                           ret0, msg_loc, ret_end);

                  ME.ECelements->num_elems = 0;
                  ME.ECelements->num_events = 0;
                  ME.ECelements->locate_stack.num_entries = 0;
                  ME.ECmarchfil->num_nodes=0;
                  ME.ECmarchfil->march_front = 0;
                  ME.ECmarchfil->fil_extend = -1;
                  /*ME.ECmarchfil->material_side = 1;*/
                  ME.ECmarchfil->new_chain = 1;
                  ME.ECmarchfil->disp_trim = 0;

                  FIg_reset(ME.ECmarchfil->form_ptr, GAD_GRP);
                  FIg_disable(ME.ECmarchfil->form_ptr, GAD_GRP);
                  FIg_enable(ME.ECmarchfil->form_ptr, NEW_CHAIN);
                  FIg_enable(ME.ECmarchfil->form_ptr, MATLTOGGLE);
                  ME.super_cmd->state = GET_RADIUS;

                  no_need = 1;
                  goto end_place_fillet;
                  }
                /* closed fillet */  

                else if( (! ME.ECmarchfil->num_nodes) &&
                         ( fil_surf[0]->v_phy_closed || (num_segs>1) ) )
                  {
                  if(fil_surf[0]->v_phy_closed)
                    dp$display(msg = &ret0, oids = fil_id, mode = GRhhd);

                  ret0 = ECmf_show_segs(&msg_loc, fil_surf[0], num_segs, 
                                        str_segs, end_segs);
                  MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), 
                                  ret0, OM_E_ABORT, ret_end);
                  ME.super_cmd->state = GET_POINT;
                  goto end_place_fillet;
                  }
                else
                  ME.super_cmd->state = PROC_FILLET;

                } /* we do have a fillet */

   end_place_fillet:

              if(fil_id)
                {
                ECmf_fillets[ECmf_num_fillets].objid = fil_id->objid;
                ECmf_fillets[ECmf_num_fillets].osnum = fil_id->osnum;
                ECmf_num_fillets++;
	        /* fix for mlk */
		om$dealloc(ptr = fil_id);
                }

              MEM_FREE(fillets);
              MEM_FREE(fillet_srf_props);
              fil_id = 0;

              if(!no_need)
                {
                ME.ECelements->locate_stack.num_entries = 0;
                ME.ECelements->num_elems = 0;
                ME.ECelements->num_events = 0;
	        ME.ECmarchfil->new_chain = 0;
                }
              else
                no_need = 0;

           }
           /* if (useract == EMSuser_data) */

	else
              goto ret_end;

        }
        break; /* case PLACE_FILLET */


      case PLACE_SPH:
        {
        IGRpoint ref_pt;

        if(ME.ECmarchfil->material_side)
          {
          ex$message( msgnumb = EMS_I_Sp_Rm_Mat );
          }
        else
          {
          ex$message( msgnumb = EMS_I_Sp_Add_Mat );
          }

	ME.ECelements->max_to_locate = 3;

        ex$message( msgnumb = EMS_P_FillSurf, buff = promptstr);
        ret0 = om$send (msg = message ECelements.do_locate (&msg_loc,
                   	  &useract, response, response_data, promptstr,
                   	  NULL, NULL, NULL, NULL, NULL), targetid = my_id);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
         	     ret_end);

        if (useract == EMSuser_moveon)
           ME.super_cmd->state = SPH_PATCH;
        else if (useract == EMSuser_backup)
           ME.super_cmd->state = OPT_FORM;
        else if (useract == EMSuser_data)
	   {
	   UI_prompt("");
           ex$message(msgnumb = EMS_I_PlSp, field = ERROR_FIELD);

           sph_id = (struct GRid *) 
                     om$malloc( size = sizeof(struct GRid) );
           MF_EMerr_hndlr (!sph_id, ret0, EMS_E_NoDynamicMemory, ret_end);

           ref_pt[0] = ME.ECelements->locev.event.button.x;
           ref_pt[1] = ME.ECelements->locev.event.button.y;
           ref_pt[2] = ME.ECelements->locev.event.button.z;

           radius = ME.ECmarchfil->radius;
           ret0 = EMcrpsphere( &msg_loc, ME.ECmarchfil->material_side, 
                               &const_list, radius, ref_pt,
                               0, 0, 0, 0, 0, 0,
                               &(ME.ECelements->elems[0].located_obj), 
                               &(ME.ECelements->elems[1].located_obj), 
                               &(ME.ECelements->elems[2].located_obj), 
                               sph_id, &sph_surf, 0 );
 
           if( EMSerror (ret0 & msg_loc) )
             {
             ex$message(msgnumb = EMS_I_Sp_Fail, field = ERROR_FIELD);
             ME.super_cmd->state = SPH_PATCH;
             ME.ECmarchfil->disp_trim  = 1;
	     if(sph_id) om$dealloc(ptr = sph_id);
             sph_id = NULL;
             }
           else
             {  
             IGRint num_nodes, march_front;
             struct ele_stack *eles=0, temp_ele;
             eles = ME.ECmarchfil->eles;
             num_nodes  = ME.ECmarchfil->num_nodes;
             march_front = ME.ECmarchfil->march_front;

             temp_ele.marked_edges[0]= -1;
             temp_ele.marked_edges[1]= -1;
             temp_ele.marked_edges[2]= -1;
             temp_ele.ele_grid.objid = sph_id->objid;
             temp_ele.ele_grid.osnum = sph_id->osnum;
             temp_ele.elem_type = SPH_ELEMENT;
             temp_ele.objs_surf = sph_surf;
             temp_ele.hot_edge = -1;
             temp_ele.model_surf[0].objid = 
                                ME.ECelements->elems[0].located_obj.objid;
             temp_ele.model_surf[0].osnum = 
                                ME.ECelements->elems[0].located_obj.osnum;
             temp_ele.model_surf[1].objid = 
                                ME.ECelements->elems[1].located_obj.objid;
             temp_ele.model_surf[1].osnum = 
                                ME.ECelements->elems[1].located_obj.osnum;
             temp_ele.model_surf[2].objid = 
                                ME.ECelements->elems[2].located_obj.objid;
             temp_ele.model_surf[2].osnum = 
                                ME.ECelements->elems[2].located_obj.osnum;
             opts = 0;
             opts |= FIRST_ELE;
             ret0 = ECmf_open_edges(&msg_loc, opts, 
                                    &ME.ECelements->active_md_env,
                                    0, &temp_ele);
             MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, 
                             ret_end);

             /*
              * if prevoius element was a fillet
              */

             if(num_nodes && 
                (eles[march_front].elem_type==FIL_ELEMENT))
               {

               /*
                * impose boundary at v==0 or v==1 for current fillet?
                * first fill in the temp structure
                */

               ret0 = EMspflimpose(&msg_loc, 0, &ME.ECelements->active_md_env,
                                   &temp_ele,
                                   &eles[march_front], 0);

               if(EMSerror (ret0 & msg_loc))
                 {
#ifdef DEBUG
  fprintf(stderr, "Error imposing boundary\n");
  fflush(stderr);
#endif
                 ex$message(msgnumb = EMS_E_Imp_Bd, field = ERROR_FIELD);
                 }
               }

             ret0 = om$send (msg = message ECmarchfil.push_node(&msg_loc, 
                             &temp_ele), targetid = my_id);
             MF_EMerr_hndlr(EMSerror (ret0 & msg_loc), 
                            ret0, OM_E_ABORT, ret_end);

             ret0 = om$send (msg = message ECmarchfil.disp_march_dir(&msg_loc,
                             0 ), targetid = my_id);
             if(EMSerror (ret0 & msg_loc))
               {
#ifdef DEBUG
  fprintf(stderr, "Error tracking march direction\n");
  fflush(stderr);
#endif
               ex$message(msgnumb = EMS_E_Mch_Dir, field = ERROR_FIELD);
               }

/* fix for mlk */
             if(sph_id) om$dealloc(ptr = sph_id);
             sph_id = NULL;
             ME.super_cmd->state = OPT_FORM;

             }
            /* else successful partial sphere */
 
           ME.ECelements->locate_stack.num_entries = 0;
           ME.ECelements->num_elems = 0;
           ME.ECelements->num_events = 0;
	   ME.ECmarchfil->new_chain = 0;
	   ME.ECmarchfil->disp_trim = 0;
           }
	else
           goto ret_end;
        }
        break; /* case sph patch */

      case INT_TRIM:
        {
        IGRint ll, num_nodes, march_front;
        struct ele_stack *eles=0, *temp_ele=0;

        ex$message( msgnumb = EMS_P_Tr_Int, field = ERROR_FIELD);
        ex$message( msgnumb = EMS_P_FillSurf, buff = promptstr);

	ME.ECelements->max_to_locate = MAXINT;
        ret0 = om$send (msg = message ECelements.do_locate (&msg_loc,
                   	  &useract, response, response_data, promptstr,
                   	  NULL, NULL, NULL, NULL, NULL), 
                        targetid = my_id);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
         	        ret_end);

        if (useract == EMSuser_backup)
           ME.super_cmd->state = OPT_FORM;
        else if (useract == EMSuser_moveon || useract == EMSuser_data)
           if(! ME.ECelements->num_elems) 
             ME.super_cmd->state = INT_TRIM;
           else
	     {
             ex$message(msgnumb = EMS_I_TrimmingFillets, field = ERROR_FIELD);
	     
             num_nodes = ME.ECmarchfil->num_nodes;
             eles = ME.ECmarchfil->eles;
             march_front = ME.ECmarchfil->march_front;

             ret0 = EMmarfiltrim(&msg_loc, BDRY_IMPOSED, 
                      &ME.ECelements->active_md_env, 
                      &eles[march_front].hot_edge, 
                      ME.ECelements->num_elems, 
                      ME.ECelements->elems, 
                      &eles[march_front].ele_grid, 0);
         
             if(EMSerror (ret0 & msg_loc))
               {
#ifdef DEBUG
  fprintf(stderr, "Error imposing boundary\n");
  fflush(stderr);
#endif
               ex$message(msgnumb = EMS_E_Imp_Bd, field = ERROR_FIELD);
               }
             else
               {
               /*
                * save state on TRIM
                */

               temp_ele = (struct ele_stack *)
                           om$malloc( size = sizeof(struct ele_stack) );
               MF_EMerr_hndlr (!temp_ele, ret0, EMS_E_NoDynamicMemory, ret_end);

               temp_ele->ele_grid.objid = eles[march_front].ele_grid.objid;
               temp_ele->ele_grid.osnum = eles[march_front].ele_grid.osnum;
               temp_ele->elem_type = FIL_ELEMENT;
               temp_ele->objs_surf = eles[march_front].objs_surf;
               for(ll=0;ll<3;ll++)
                 temp_ele->open_edges[ll].objid = NULL_OBJID;
               temp_ele->model_surf[0].objid = 
                                        eles[march_front].model_surf[0].objid;
               temp_ele->model_surf[0].osnum = 
                                        eles[march_front].model_surf[0].osnum;
               temp_ele->model_surf[1].objid = 
                                        eles[march_front].model_surf[1].objid;
               temp_ele->model_surf[1].osnum = 
                                        eles[march_front].model_surf[1].osnum;
               temp_ele->hot_edge = -1;;

               ret0 = om$send (msg = message ECmarchfil.push_node(&msg_loc,
                              temp_ele), targetid = my_id);
               MF_EMerr_hndlr(EMSerror (ret0 & msg_loc), 
                              ret0, OM_E_ABORT, ret_end);

               temp_ele = 0;

               } /* after impose boundary */

             ME.ECelements->locate_stack.num_entries = 0;
             ME.ECelements->num_elems = 0;
             ME.ECelements->num_events = 0;
             ME.super_cmd->state = OPT_FORM;
	     ME.ECmarchfil->new_chain = 0;

             } /* after user hit moveon */
	else
           goto ret_end;
        }
        break; /* case INT_TRIM */

      case TAN_TRIM:
        {
        IGRint ll, num_nodes, march_front;
        IGRboolean found_patch;
        struct ele_stack *eles=0, *temp_ele=0;

        ex$message(msgnumb = EMS_P_Tr_Tan, field = ERROR_FIELD);
        ex$message( msgnumb = EMS_P_FillSurf, buff = promptstr);

	ME.ECelements->max_to_locate = MAXINT;
        ret0 = om$send (msg = message ECelements.do_locate (&msg_loc,
                   	  &useract, response, response_data, promptstr,
                   	  NULL, NULL, NULL, NULL, NULL), 
                        targetid = my_id);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
         	        ret_end);

        if (useract == EMSuser_backup)
           ME.super_cmd->state = OPT_FORM;
        else if (useract == EMSuser_moveon || useract == EMSuser_data)
           if(! ME.ECelements->num_elems) 
             ME.super_cmd->state = TAN_TRIM;
           else
	     {

             ex$message(msgnumb = EMS_I_TrimmingFillets, field = ERROR_FIELD);
	     
             num_nodes = ME.ECmarchfil->num_nodes;
             eles = ME.ECmarchfil->eles;
             march_front = ME.ECmarchfil->march_front;

             if( (ME.ECelements->num_elems == 1) && 
                 (ME.ECmarchfil->curr_ele_type == SPH_ELEMENT) )
               {

               ME.ECmarchfil->curr_ele_type = -1; /* re-initialize */

               /*
                * if identified sph patch from current chain, use it!
                * eles fill in a temp structure
                */

               found_patch = 0;
               for(ii=0; ii<num_nodes; ii++)
                 if(eles[ii].ele_grid.objid == 
                                    ME.ECelements->elems[0].located_obj.objid)
                   {
                   found_patch = 1;
                   break; 
                   }

               if(found_patch)
                 {
                 ret0 = EMspflimpose(&msg_loc, 0, &ME.ECelements->active_md_env,
                                     &eles[ii].ele_grid, &eles[march_front], 0);
                 }
               else
                 {
                 temp_ele = (struct ele_stack *)
                             om$malloc( size = sizeof(struct ele_stack) );
                 MF_EMerr_hndlr (!temp_ele, ret0, 
                                 EMS_E_NoDynamicMemory, ret_end);

                 temp_ele->ele_grid.objid = 
                                   ME.ECelements->elems[0].located_obj.objid;
                 temp_ele->ele_grid.osnum = 
                                   ME.ECelements->elems[0].located_obj.osnum;
                 temp_ele->objs_surf = 0;
               
                 ret0 = EMspflimpose(&msg_loc, 0, &ME.ECelements->active_md_env,
                                     temp_ele, &eles[march_front], 0);

                 MEM_FREE(temp_ele);
                 }


               } /* trim against a corner sph patch */

             else
               {
               ret0 = EMmarfiltantrim(&msg_loc, 0, 
                      &ME.ECelements->active_md_env, 
                      ME.ECelements->num_elems, ME.ECelements->elems, 
                      &eles[march_front].ele_grid, &eles[march_front].hot_edge);

               } /* else general trim against multiple tan. surfs */
         
             /* 
              * common error handling for above if - else if - else block
              */

             if(EMSerror (ret0 & msg_loc))
               {
#ifdef DEBUG
  fprintf(stderr, "Error imposing boundary\n");
  fflush(stderr);
#endif

               ex$message(msgnumb = EMS_E_Imp_Bd, field = ERROR_FIELD);
               }
             else
               {
               /*
                * save state on TRIM
                */

               temp_ele = (struct ele_stack *)
                           om$malloc( size = sizeof(struct ele_stack) );
               MF_EMerr_hndlr (!temp_ele, ret0, 
                               EMS_E_NoDynamicMemory, ret_end);

               temp_ele->ele_grid.objid = eles[march_front].ele_grid.objid;
               temp_ele->ele_grid.osnum = eles[march_front].ele_grid.osnum;
               temp_ele->elem_type = FIL_ELEMENT;
               temp_ele->objs_surf = eles[march_front].objs_surf;
               for(ll=0;ll<3;ll++)
                 temp_ele->open_edges[ll].objid = NULL_OBJID;
               temp_ele->model_surf[0].objid =
                                        eles[march_front].model_surf[0].objid;
               temp_ele->model_surf[0].osnum =
                                        eles[march_front].model_surf[0].osnum;
               temp_ele->model_surf[1].objid =
                                        eles[march_front].model_surf[1].objid;
               temp_ele->model_surf[1].osnum =
                                        eles[march_front].model_surf[1].osnum;
               temp_ele->hot_edge = -1;;

               ret0 = om$send (msg = message ECmarchfil.push_node(&msg_loc,
                               temp_ele), targetid = my_id);
               MF_EMerr_hndlr(EMSerror (ret0 & msg_loc), 
                              ret0, OM_E_ABORT, ret_end);

               temp_ele = 0;

               } /* after impose boundary */

             ME.ECelements->locate_stack.num_entries = 0;
             ME.ECelements->num_elems = 0;
             ME.ECelements->num_events = 0;
             ME.super_cmd->state = OPT_FORM;
	     ME.ECmarchfil->new_chain = 0;
             } /* after user hit moveon or selected a sph patch or a fillet */
	else
           goto ret_end;
        }
        break; /* case TAN_TRIM */

     case ADD_FILLETS:
        {
        IGRlong dummy;
        for(ii=0; ii<ECmf_num_fillets; ii++)
          dp$display(msg = &dummy, oids = &ECmf_fillets[ii], mode = GRbdhd);

        ex$message(msgnumb = EMS_P_Loc_Ex_Fl);
        ex$message( msgnumb = EMS_P_Fl, buff = promptstr);

        ME.ECelements->max_to_locate = MAXINT;
        ret0 = om$send (msg = message ECelements.do_locate (&msg_loc,
                              &useract, response, response_data, promptstr,
                   	      NULL, NULL, NULL, NULL, NULL), 
                              targetid = my_id);
       MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);

        if(useract == EMSuser_backup)
          ME.super_cmd->state = OPT_FORM;
        else if (useract == EMSuser_moveon || useract == EMSuser_data)
          {
          for(ii=0; ii<ME.ECelements->num_elems; ii++)
            {
            ECmf_fillets[ECmf_num_fillets].objid = 
                            ME.ECelements->elems[ii].located_obj.objid;
            ECmf_fillets[ECmf_num_fillets].osnum = 
                            ME.ECelements->elems[ii].located_obj.osnum;
            ECmf_num_fillets++;
            }
          ME.ECelements->locate_stack.num_entries = 0;
          ME.ECelements->num_elems = 0;
          ME.ECelements->num_events = 0;
          ME.super_cmd->state = OPT_FORM;
          }
        /* if (useract == EMSuser_moveon || useract == EMSuser_data) */
        else
          goto ret_end;

        for(ii=0; ii<ECmf_num_fillets; ii++)
          dp$display(msg = &dummy, oids = &ECmf_fillets[ii], mode = GRbdhe);
        }
        break; /* case ADD_FILLETS */

      case GET_POINT:
        {
        ex$message( msgnumb = EMS_P_Approx_Pt, buff = promptstr);

        eventmask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_RESTART;
        ret0 = co$getevent(msg = &msg_loc, prompt = promptstr, 
                           response = response, response_data = response_data,
                           event_mask = eventmask,event = &event);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
        ex$message(msgnumb = EMS_P_ClearPromptField);

        switch (event.response)
          {
          case EX_RJT_MOVEON:
          case EX_BACK_UP:
          case EX_RESTART:
            ME.super_cmd->state = GET_POINT;
            break;
          case EX_DATA:
            ME.ECmarchfil->march_arrow[1][0] = 
                                      ME.ECelements->locev.event.button.x;
            ME.ECmarchfil->march_arrow[1][1] = 
                                      ME.ECelements->locev.event.button.y;
            ME.ECmarchfil->march_arrow[1][2] = 
                                      ME.ECelements->locev.event.button.z;
            ME.super_cmd->state = PROC_FILLET;
            break;

          default:
            goto ret_end;
          }
        }
        break;

      case PROC_FILLET:
        {
        IGRint ll;
        struct ele_stack *prev_ele=0;

        /* 
         * all imposing functions update hot_edge
         * ECmf_open_edges updates open edges for temp_ele
         */

        IGRboolean march_side;
        struct ele_stack temp_ele;

        /* 
         * fill in temp node.  hot edge and march arrow will probably be
         * updated.  push this node on the ele_list.
         */

        temp_ele.ele_grid.objid = ME.ECmarchfil->fil_grid->objid;
        temp_ele.ele_grid.osnum = ME.ECmarchfil->fil_grid->osnum;
        temp_ele.elem_type = FIL_ELEMENT;
        temp_ele.objs_surf = ME.ECmarchfil->fil_surf;
	temp_ele.marked_edges[0]= -1;
	temp_ele.marked_edges[1]= -1;
	temp_ele.marked_edges[2]= -1;
        for(ll=0;ll<3;ll++)
          temp_ele.open_edges[ll].objid = NULL_OBJID;
        temp_ele.model_surf[0].objid = ME.ECmarchfil->fil_base_surfs[0].objid;
        temp_ele.model_surf[0].osnum = ME.ECmarchfil->fil_base_surfs[0].osnum;
        temp_ele.model_surf[1].objid = ME.ECmarchfil->fil_base_surfs[1].objid;
        temp_ele.model_surf[1].osnum = ME.ECmarchfil->fil_base_surfs[1].osnum;

        /* evaluate march end of the fillet */
        if(ME.ECmarchfil->num_nodes)
          {
          ret0 = ECmf_march_end(&msg_loc, 0, &ME.ECelements->active_md_env,
                      ME.ECmarchfil->radius, ME.ECmarchfil->march_arrow, 
                      &ME.ECmarchfil->eles[ME.ECmarchfil->march_front],
                      &temp_ele, &march_side);
          MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
          }
        else
          march_side = 1;

        temp_ele.hot_edge = march_side;

        /* process exact fillet */
        if( (!(ME.ECmarchfil->fil_opts & EMS_RND_EXTEND_SURF)) && 
            (ME.ECmarchfil->num_nodes) )
          {
          ret0 = EMflflimpose2(&msg_loc, 0, &const_list, 
                              ME.ECmarchfil->fil_degen_opt, &temp_ele,
                              &ME.ECmarchfil->eles[ME.ECmarchfil->march_front]);
/*
          MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
*/
/******** UMS ******/
          if(EMSerror (ret0 & msg_loc))
            UI_status("Boundary not imposed");
          
          goto end_proc_fillet;
          }

        /* process closed (circular) fillet */ 
        if(ME.ECmarchfil->fil_surf->v_phy_closed)
          {
          opts = 0;
          opts |= CLOSE_ELE;
          ret0 = ECmf_newfl(&msg_loc, opts, &ME.ECelements->active_md_env, 
                            ME.ECmarchfil->fil_num_segs,
                            ME.ECmarchfil->fil_str_segs,
                            ME.ECmarchfil->fil_end_segs,
                            ME.ECmarchfil->march_arrow[1], &temp_ele );
          MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
          goto end_proc_fillet;
          }

        /* process first fillet */
        if( !ME.ECmarchfil->num_nodes )
          {
          if(! (ME.ECmarchfil->fil_opts & EMS_RND_EXTEND_SURF) ) 
            goto end_proc_fillet;  /* exact first fillet */
 
          opts = 0;
          opts |= FIRST_ELE;
          ret0 = ECmf_newfl(&msg_loc, opts, &ME.ECelements->active_md_env, 
                            ME.ECmarchfil->fil_num_segs,
                            ME.ECmarchfil->fil_str_segs,
                            ME.ECmarchfil->fil_end_segs,
                            ME.ECmarchfil->march_arrow[1], &temp_ele );
/*
          MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
*/
/******** UMS ******/
          if( EMSerror (ret0 & msg_loc) )
            UI_status("Fillet not clipped to base surf");

          goto end_proc_fillet;
          }

        /* not a first fillet */
        if(ME.ECmarchfil->eles[ME.ECmarchfil->march_front].elem_type ==
                                                      SPH_ELEMENT)
          {
          ret0 = EMspflimpose(&msg_loc, 0, &ME.ECelements->active_md_env,
                              &ME.ECmarchfil->eles[ME.ECmarchfil->march_front],
                              &temp_ele, 1);
          }
        else /* prev ele == FIL_ELEMENT */
          {
          ret0 = EMflflimpose(&msg_loc, 0, 
                              &ME.ECelements->active_md_env,
                              &ME.ECmarchfil->eles[ME.ECmarchfil->march_front],
                              &temp_ele);
          }
        if(EMSerror (ret0 & msg_loc))
          {
#ifdef DEBUG
  fprintf(stderr, "Error imposing boundary\n");
  fflush(stderr);
#endif

          ex$message(msgnumb = EMS_E_Imp_Bd, field = ERROR_FIELD);
          }
        else /* fix the other end */
          {
          opts=0;
          ret0 = ECmf_newfl(&msg_loc, opts, &ME.ECelements->active_md_env, 
                            ME.ECmarchfil->fil_num_segs,
                            ME.ECmarchfil->fil_str_segs,
                            ME.ECmarchfil->fil_end_segs,
                            ME.ECmarchfil->march_arrow[1], &temp_ele );
/*
          MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
*/
/******** UMS ******/
          if( EMSerror (ret0 & msg_loc) )
            UI_status("Fillet not clipped to base surf");

          }

end_proc_fillet:
        
        /* mark open edges */
        opts = 0;
        if(! ME.ECmarchfil->num_nodes)
          {
          opts |= FIRST_ELE;
          prev_ele = 0;
          }
        else if(ME.ECmarchfil->eles[ME.ECmarchfil->march_front].elem_type ==
                FIL_ELEMENT)
          prev_ele = &ME.ECmarchfil->eles[ME.ECmarchfil->march_front];
        else
          prev_ele = 0;

        ret0 = ECmf_open_edges(&msg_loc, opts, &ME.ECelements->active_md_env,
                               prev_ele, &temp_ele);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
  
        /* save current node */
        ret0 = om$send (msg = message ECmarchfil.push_node(&msg_loc, &temp_ele),
                        targetid = my_id);
        MF_EMerr_hndlr(EMSerror(ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);

        /* disp direction */
        opts = 0;
        ret0 = om$send (msg = message ECmarchfil.disp_march_dir(&msg_loc, opts),
                        targetid = my_id);
        if(EMSerror (ret0 & msg_loc))
          {
#ifdef DEBUG
  fprintf(stderr, "Error tracking march direction\n");
  fflush(stderr);
#endif
          ex$message(msgnumb = EMS_E_Mch_Dir, field = ERROR_FIELD);
          }

        ME.super_cmd->state = OPT_FORM;
        ME.ECmarchfil->disp_trim  = 1;
        }
        break;

      case CHANGE_DIR:
        {
        IGRboolean edge_locatable=0;
        IGRint ll;
        struct GRid *open_edge;
        enum GRdpmode mode=GRhhd;
        struct DPele_header edge_header;
       
        opts = 0;
        opts |= EMS_WHL_EDGE;
        dp$erase_hilite(msg = &ret0);
        for(ii=0; ii<ME.ECmarchfil->num_nodes; ii++)
          for(ll=0; ll<3; ll++)
            if(ME.ECmarchfil->eles[ii].open_edges[ll].objid != NULL_OBJID)
              {
              open_edge = &ME.ECmarchfil->eles[ii].open_edges[ll];
#ifdef DEBUG
  fprintf(stderr, "open edge %d\n", open_edge->objid);
#endif
              ret0 = qq_build_ele_header(&msg_loc, open_edge, 
                                 &ME.ECelements->active_md_env, &edge_header);
/*
              MF_EMerr_hndlr (EMSerror(ret0 & msg_loc), 
                              ret0, OM_E_ABORT, ret_end);
*/
              if(! EMSerror(ret0 & msg_loc) )
                {
                ret0= om$send(msg = message EMSedge.EMdisplay(&msg_loc, 
                              &edge_header,
                              &ME.ECelements->active_md_env.md_env.matrix_type,
                              ME.ECelements->active_md_env.md_env.matrix,
                              &mode, 0, opts, 0),
                              targetid = open_edge->objid,
                              targetos = open_edge->osnum);
                }
/*
              MF_EMerr_hndlr (EMSerror(ret0 & msg_loc), 
                              ret0, OM_E_ABORT, ret_end);
*/
              }

        ex$message(msgnumb = EMS_I_Ch_Dir);

        ret0 = om$send (msg = message ECmarchfil.set_new_locate_criteria
                              (&msg_loc, "EMSedge"), targetid = my_id);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
                        ret_end);

        /* if not on, turn on edge locate */
        edge_locatable = EFedge_curves_locatable();
        if(!edge_locatable)
          EFset_locate_eligibility(&msg_loc, 1, "EMSedge");

 
        ME.ECelements->max_to_locate = 1;

        ex$message( msgnumb = EMS_I_Edge, buff = promptstr);
        ret0 = om$send (msg = message ECelements.do_locate (&msg_loc,
                          &useract, response, response_data, promptstr,
                          NULL, NULL, NULL, NULL, NULL), targetid = my_id);
        MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
                        ret_end);

        /* turn off if you turned it on */
        if(!edge_locatable)
          EFset_locate_eligibility(&msg_loc, 0, "EMSedge");

        if (useract == EMSuser_moveon)
           ME.super_cmd->state = CHANGE_DIR;
        else if (useract == EMSuser_backup)
           {
           ME.super_cmd->state = OPT_FORM;
           ret0 = om$send (msg = message ECmarchfil.set_new_locate_criteria
                          (&msg_loc, "EMSsubbs"), targetid = my_id);
           MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
                           ret_end);
           }
        else if (useract == EMSuser_data)
          {
          IGRboolean dir_changed=0;
          struct GRid srf_id;
#ifdef DEBUG
 fprintf(stderr, "id edge %d\n", ME.ECelements->elems[0].located_obj.objid);
#endif
          ret0 = om$send(msg = message EMSboundary.EMgetsurface_info
                        (&msg_loc, &srf_id.objid, NULL),
                        targetid = ME.ECelements->elems[0].located_obj.objid,
                        targetos = ME.ECelements->elems[0].located_obj.osnum,
                        senderid = NULL_OBJID);
          MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);

          srf_id.osnum = ME.ECelements->elems[0].located_obj.osnum;

          for(ii=0; ii<ME.ECmarchfil->num_nodes; ii++)
              if(ME.ECmarchfil->eles[ii].ele_grid.objid == srf_id.objid)
                {
                ME.ECmarchfil->march_front = ii;

                /* update hot edge if selected fillet */
                if(ME.ECmarchfil->eles[ii].elem_type == FIL_ELEMENT)
                  {
                  ret0 = ECmf_update_edge(&msg_loc, opts, 
                                     &ME.ECelements->active_md_env,
                                     &ME.ECmarchfil->eles[ii],
                                     &ME.ECelements->elems[0].located_obj);
                  MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
                                  ret_end);
                  ME.ECmarchfil->disp_trim = 1;
                  }
                
                /* disp dir */
                opts = 0;
                ret0 = om$send (msg = message ECmarchfil.disp_march_dir
                                      (&msg_loc, opts ), targetid = my_id);
                if(EMSerror (ret0 & msg_loc))
                  {
#ifdef DEBUG
  fprintf(stderr, "Error tracking march direction\n");
  fflush(stderr);
#endif
                  ex$message(msgnumb = EMS_E_Mch_Dir, field = ERROR_FIELD);
                  }
                dir_changed = 1;
                ME.super_cmd->state = OPT_FORM;
                ret0 = om$send (msg = message ECmarchfil.set_new_locate_criteria
                               (&msg_loc, "EMSsubbs"), targetid = my_id);
                MF_EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT,
                                ret_end);

                break;
                } 

          if(! dir_changed)
            ME.super_cmd->state = CHANGE_DIR;

          ME.ECelements->locate_stack.num_entries = 0;
          ME.ECelements->num_elems = 0;
          ME.ECelements->num_events = 0;
	  ME.ECmarchfil->new_chain = 0;
          }
         /* if (useract == EMSuser_data) */
        else
           goto ret_end;
        }
        break;

      case EXT_FILLET:
        {
        ret0 = EMbef_filterm( &msg_loc, 0, &ME.ECelements->active_md_env, 
               &ME.ECmarchfil->eles[ME.ECmarchfil->march_front].ele_grid, 
               &ME.ECmarchfil->eles[ME.ECmarchfil->march_front].hot_edge );
        if(EMSerror (ret0 & msg_loc))
          ex$message(msgnumb = EMS_E_Ex_Fl, field = ERROR_FIELD);

        ME.super_cmd->state = OPT_FORM;
        }
        break;

      default:
        ret0 = OM_E_ABORT;
        goto ret_end;

      } /* switch super_cmd->state*/
    } 	/* while TRUE */

ret_end:

  MEM_FREE(fillets);
  if(fil_id)
  om$dealloc(ptr = fil_id);
  fil_id = NULL;
  if(sph_id)
  om$dealloc(ptr = sph_id);
  sph_id = NULL;

  if (EMSerror (ret0))
    {
    *response = TERMINATE;
    /*MEM_FREE(filletarr);*/
    MEM_FREE(sph_id);
    }

  return (ret0);

} /* execute */

method super_cmd.sleep  (IGRint defer_flag)
{
  IGRlong ret0=OM_S_SUCCESS;

  FIf_erase(ME.ECmarchfil->form_ptr);
  ret0 = om$send (mode = OM_e_wrt_message,
                  msg = message ECelements.sleep(defer_flag),
                  targetid = my_id);
  return (ret0);
}

method wakeup (IGRint defer_flag)
{
  IGRlong ret0=OM_S_SUCCESS; 
  IGRlong msg_loc=EMS_S_Success;
  IGRushort opts=0;

  ret0 = ECmf_setup_form(&ME.ECmarchfil->form_ptr, 1, 
                         ME.ECmarchfil->new_chain,
                         ME.ECmarchfil->disp_trim, ME.ECmarchfil->num_nodes, 
                         my_id, OM_Gw_current_OS, 1);
  MF_EMerr_hndlr (EMSerror (ret0), ret0, OM_E_ABORT, ret_end);


  opts |= REDISPLAY_WAKEUP;
  ret0 = om$send (msg = message ECmarchfil.disp_march_dir(&msg_loc,
                  opts ), targetid = my_id);
  if(EMSerror (ret0 & msg_loc))
    {
#ifdef DEBUG
  fprintf(stderr, "Error tracking march direction\n");
  fflush(stderr);
#endif
    ex$message(msgnumb = EMS_E_Mch_Dir, field = ERROR_FIELD);
    }

  ret0 = om$send (mode = OM_e_wrt_message, 
                  msg = message ECelements.wakeup(defer_flag),
                  targetid = my_id);
ret_end:

  return (ret0);

} /* wakeup */

method delete (IGRint defer_flag)
{
  IGRlong ret0=OM_S_SUCCESS, msg_loc=EMS_S_Success;

  FIf_delete(ME.ECmarchfil->form_ptr);

  ret0 = om$send (mode = OM_e_wrt_message, msg = message Root.delete
                  (defer_flag), targetid = my_id);

  ret0 = ECmf_free_copies(&msg_loc, &ME.ECelements->active_md_env,
                          ME.ECmarchfil->num_nodes, ME.ECmarchfil->copies);
  MF_EMerr_hndlr (EMSerror(ret0 & msg_loc), ret0, msg_loc, ret_end);

ret_end:

  return (ret0);

} /* delete */


method get_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                            OM_S_CLASSLIST *rtree_classes, *elig_classes,
                            *nelig_classes; IGRushort *geomprops;
                            IGRshort *operation; IGRushort *options;
                            IGRint *minnum_to_locate, *maxnum_to_locate)
{
  IGRlong ret0;

  *msg = EMS_S_Success;
  ret0 = OM_S_SUCCESS;

  rtree_classes->w_count = 1;
  rtree_classes->w_flags = OM_CLST_subclass;
  rtree_classes->p_classes[0] = OPP_EMSsubbs_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_EMSsubbs_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = EC_LOC_APPENDOBJNUM;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (ret0);
} /* method get_locate_criteria */

method set_new_locate_criteria(IGRlong *msg; char* class)
{
  IGRlong ret0;
  IGRint maxnum_classes, min_to_lc, max_to_lc;
  IGRint minnum_to_locate, maxnum_to_locate;
  GRclassid r_classmem[2], e_classmem[2];
  OM_S_CLASSLIST rtree_classes, elig_classes, nelig_classes;
  IGRushort geomprops, options;
  IGRshort operation;

#ifdef MOD22
  IGRushort topo_props;
  IGRlong display_flag, locate_mask, accept_mask;
#endif

  IGRlong stat_OM;

  *msg = EMS_S_Success;
  ret0 = OM_S_SUCCESS;
  stat_OM = OM_S_SUCCESS;

  r_classmem[0] = OPP_GRgraphics_class_id;
  e_classmem[0] = OPP_GRgraphics_class_id;

  if(! strcmp(class, "EMSsubbs") )
    {
    r_classmem[0] = OPP_EMSsubbs_class_id;
    e_classmem[0] = OPP_EMSsubbs_class_id;
    }

  if(! strcmp(class, "EMSedge") )
    {
    r_classmem[0] = OPP_EMSedge_class_id;
    e_classmem[0] = OPP_EMSedge_class_id;
    }

  rtree_classes.w_count = 1;
  rtree_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes = r_classmem;

  elig_classes.w_count = 1;
  elig_classes.w_flags = OM_CLST_subclass;
  elig_classes.p_classes = e_classmem;

  nelig_classes.w_count = 0;

  maxnum_classes = MAXNUM_RESTRICTIVE_CLASSES-1;
  geomprops = NULL;
  operation = EC_GEOM_READ;
  options = EC_LOC_APPENDOBJNUM;

  minnum_to_locate = 1;
  maxnum_to_locate = 1;

  min_to_lc = 1;
  max_to_lc = 1;


#ifdef MOD22
  ME.ECelements->locate_stack.num_entries = 0;
  ME.ECelements->num_elems = 0;
  ME.ECelements->num_events = 0;

  if (rtree_classes.w_count > maxnum_classes ||
      elig_classes.w_count > maxnum_classes ||
      nelig_classes.w_count > maxnum_classes)
  {
    UI_status("Cannot locate too many classes");
    stat_OM = OM_E_ABORT;
    goto quit;
  }

  ME.ECelements->rtree_classes.w_count = rtree_classes.w_count;
  ME.ECelements->rtree_classes.w_flags = rtree_classes.w_flags;
  ME.ECelements->rtree_classes.p_classes = ME.ECelements->r_classmem;
  memcpy(ME.ECelements->r_classmem, rtree_classes.p_classes,
         rtree_classes.w_count * sizeof(GRclassid));

  ME.ECelements->elig_classes.w_count = elig_classes.w_count;
  ME.ECelements->elig_classes.w_flags = elig_classes.w_flags;
  ME.ECelements->elig_classes.p_classes = ME.ECelements->e_classmem;
  memcpy(ME.ECelements->e_classmem, elig_classes.p_classes,
         elig_classes.w_count * sizeof(GRclassid));

  ME.ECelements->nelig_classes.w_count = nelig_classes.w_count;
  ME.ECelements->nelig_classes.w_flags = nelig_classes.w_flags;
  ME.ECelements->nelig_classes.p_classes = ME.ECelements->ne_classmem;
  memcpy(ME.ECelements->ne_classmem, nelig_classes.p_classes,
         nelig_classes.w_count * sizeof(GRclassid));

  if (operation == EC_GEOM_READ || operation == EC_ATTR_READ)
  {
    geomprops |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_RW;
    topo_props = LC_RIGID_COMP | LC_RIGID_OWNER |
                 LC_FLEX_COMP | LC_FLEX_OWNER |
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else if (operation == EC_ATTR_WRITE)
  {
    geomprops |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_WRITE_ONLY;
    topo_props = LC_RIGID_COMP | LC_RIGID_OWNER |
                 LC_FLEX_COMP | LC_FLEX_OWNER |
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else if (operation == EC_GEOM_CHGSHAPE || operation == EC_GEOM_NOCHGSHAPE)
  {
    geomprops |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_WRITE_ONLY;
    topo_props = LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER |
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else
  {
    stat_OM = OM_E_ABORT;
    goto quit;
  }


  if (options & EC_LOC_RIGIDCOMPOK)
    topo_props |= LC_RIGID_COMP;

  if (options & EC_LOC_ASSOCOK)
    topo_props |= LC_ASSOCIATIVE;

  if (options & EC_LOC_EXTCONSTOK)
    topo_props |= LC_EXTERN_CONSTRAINED;

  if (options & EC_LOC_NOFLEXGROUPS)
    topo_props &= ~LC_FLEX_OWNER;
  else if (maxnum_to_locate > 1 && topo_props & LC_FLEX_OWNER)
    ME.ECelements->e_classmem[ME.ECelements->elig_classes.w_count++] = OPP_GRflxown_class_id;

  if (options & EC_LOC_READONLYOK)
    geomprops |= LC_READ_ONLY;


  locate_mask = GRm_DATA | GRm_TEXT_VALUE | GRm_BACK_UP;
  if (maxnum_to_locate > 1 && !(options & EC_LOC_NOSPECOBJS))
    locate_mask |= GRm_SPECIFIED_OBJ;
  if (minnum_to_locate == 0)
    locate_mask |= GRm_RJT_MOVEON;

  accept_mask = GRm_DATA;
  if (maxnum_to_locate > 1)
  {
    accept_mask |= GRm_TEXT_VALUE;
    if (!(options & EC_LOC_NOSPECOBJS))
      accept_mask |= GRm_SPECIFIED_OBJ;
  }

  ME.ECelements->locate_mask = locate_mask;
  ME.ECelements->accept_mask = accept_mask;
  ME.ECelements->owner_action = topo_props;
  ME.ECelements->properties = geomprops;
  ME.ECelements->min_to_locate = minnum_to_locate;
  ME.ECelements->max_to_locate = maxnum_to_locate;
  ME.ECelements->options = options;

  display_flag = (options & EC_LOC_DISPONEWINDOW ? ONE_WINDOW : ALL_WINDOWS ) |
                 ELEM_HILIGHT |
                 (options & EC_LOC_PROJACCPT ?
                  PROJ_ACCEPT_POINT : NO_PROJ_ACCEPT_POINT) |
                 (options & EC_LOC_NO_ACC_RJT ?
                  NO_ACC_REJ_CYCLE | DO_NOT_RELOCATE :
                  ACC_REJ_CYCLE |
                  (options & EC_LOC_NO_RELOCATE ?
                   DO_NOT_RELOCATE : RELOCATE )) | LC_REGULAR_HIGHLIGHT |
                 LC_ERASE_LOC_ELEMENT;
  if (options & EC_LOC_DISPELEMDIR || options & EC_LOC_PROJLOCPT)
    display_flag |= LC_INPUT_LOC_POINT;
  if (maxnum_to_locate > 1)
    display_flag |= LC_ACCEPT_CURSOR;
  ME.ECelements->display_flag = display_flag;

quit:
  return stat_OM;

#else
  ret0 = om$send(msg = message ECelements.set_locate_criteria(msg,
                                                              maxnum_classes,
                                                              &rtree_classes,
                                                              &elig_classes,
                                                              &nelig_classes,
                                                              geomprops,
                                                              operation,
                                                              options,
                                                              min_to_lc,
                                                              max_to_lc),
                  targetid = my_id);
  MF_EMerr_hndlr(EMSerror(ret0 & *msg), ret0, OM_E_ABORT, ret_end);

ret_end:

  return ret0;
#endif

}
/* set_new_locate_criteria */

method proc_locobj (IGRlong *msg; struct GRevent *loc_event, *acc_event,
                                                 *ob_event)
{
  IGRint array_size=0, num_edges=0;
  IGRlong ret0;
  char classname[OM_K_MAXCLASS_LEN];
  struct GRid *first_obj=0, *edges=0;
  IGRdouble ele_radius;
  IGRint qq_type=0;

  *msg = EMS_I_Found;
  ret0 = OM_S_SUCCESS;

  if( (  (ME.super_cmd->state == INT_TRIM)||(ME.super_cmd->state == GET_RADIUS)
       ||(ME.super_cmd->state == TAN_TRIM) ) && (!ME.ECelements->num_elems) )
    {
    first_obj = &ob_event->located_object[0].located_obj;
    ret0 = om$get_classname(objid = first_obj->objid,
                            osnum = first_obj->osnum,
                            classname = classname);
    MF_EMerr_hndlr (EMSerror (ret0), ret0, OM_E_ABORT, ret_end);

    if( (!strcmp(classname, "EMSpsphere"))||(!strcmp(classname, "EMApsphere")) )
      {
      /*
       * if this partial sph has 3 non-degen edges, assumed that we can 
       * terminate against this patch
       */

      ret0= om$send(msg = message EMSsubbs.EMget_edges(msg, MAXINT,
                    EMS_OPT_NON_DEG_SEAM_XYZCLSD, 
                    &ME.ECelements->active_md_env, &edges,
                    &array_size, &num_edges),
                    targetid = first_obj->objid,
                    targetos = first_obj->osnum);
      MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

      if(num_edges == 3)
        {
        *msg = EMS_I_NoMore;
        ME.ECmarchfil->curr_ele_type = SPH_ELEMENT;
        if(ME.super_cmd->state == GET_RADIUS)
          {
          qq_type = SPH_ELEMENT;
          ret0 = qq_get_ele_radius(first_obj, &qq_type,
                                   &ME.ECelements->active_md_env, &ele_radius);
          if(EMSerror(ret0))
            {
            ex$message(msgnumb = EMS_E_Comp_Rad, field = ERROR_FIELD);
            EMomerr_exit(ret0, ret_end);
            }
          ME.ECmarchfil->radius = ele_radius;
          ECmf_radius = ele_radius;
          } /* if ME.super_cmd->state == GET_RADIUS */
        } /* num_edges == 3 */
      }
    /* if got a partial sph */

    else
      {
      /* else code for special fillet case handling */
      if(ME.super_cmd->state == GET_RADIUS)
        {
        qq_type = 0;
        ret0 = qq_get_ele_radius(first_obj, &qq_type, 
                                 &ME.ECelements->active_md_env, &ele_radius);
        if(EMSerror(ret0))
          {
          ex$message(msgnumb = EMS_E_De_Fl, field = ERROR_FIELD);
          EMomerr_exit(ret0, ret_end);
          }
        else if (qq_type == FIL_ELEMENT)
          {
          *msg = EMS_I_NoMore;
          ME.ECmarchfil->curr_ele_type = FIL_ELEMENT;
          ME.ECmarchfil->radius = ele_radius;
          ECmf_radius = ele_radius;
          }
        else
          *msg = EMS_I_NotFound;
        }
      /* if(ME.super_cmd->state == GET_RADIUS) */

      } /* if first ele was not a partial sph */


    } /* if located first ele in GET_RADIUS or TAN_TRIM or INT_TRIM */

ret_end:

  MEM_FREE(edges);
  return (ret0);

} /* method proc_locobj */


/*
 * for all the located elements, look at IGRbsp_surf struct and set pos_orient
 * flag in properties array elemprops
 */

static int get_pos_orient(num_elems, active_md_env, elems, elemprops)
int num_elems;
struct GRmd_env active_md_env;
struct GRlc_info elems[];
IGRushort elemprops[];
{
  IGRint ii;
  IGRlong msg, ret0=OM_S_SUCCESS;
  struct IGRbsp_surface *surf_info=0;
 
  for(ii=0; ii<num_elems; ii++)
    {
    surf_info=0;
    ret0 = EMgetvggeom ( &msg,
                         &active_md_env.md_env.matrix_type,
                         active_md_env.md_env.matrix,
                         &elems[ii].located_obj,
                         &surf_info, 0 );

   MF_EMerr_hndlr (EMSerror (ret0 & msg), ret0, OM_E_ABORT, ret_end);
    
    if(surf_info)
      {
      elemprops[ii] = surf_info->pos_orient; 
      MEM_FREE(surf_info);
      }

    } /* for */

ret_end:

  MEM_FREE(surf_info);
  return ret0;

} /* get_pos_orient */


method push_node(IGRlong *msg; struct ele_stack *ele;)
{
  IGRshort props, action; 
  IGRlong ret0=OM_S_SUCCESS;
  IGRint v_s;
  struct GRid *o_objsptr=0, *s_objsptr=0;
  struct GRmd_env *active_md_env;
  IGRint *num_nodes, *march_front;
  struct ele_stack *eles=0, *copies=0;

  *msg = EMS_S_Success;

  active_md_env = &ME.ECelements->active_md_env;
  num_nodes = &ME.ECmarchfil->num_nodes;
  march_front = &ME.ECmarchfil->march_front;
  eles = ME.ECmarchfil->eles;
  copies = ME.ECmarchfil->copies;

  /*
   * disp all objs
   */

  dp$display(msg = &ret0, oids = &ele->ele_grid, mode = GRbd);

  /*
   * allocate space if necessary
   */

  v_s = om$dimension_of (varray = ME.ECmarchfil->eles);
  if(*num_nodes == v_s)
    {
    ret0 = om$vla_set_dimension (varray = ME.ECmarchfil->eles, 
                                 size = v_s + ELEMS_ARRAY_INCR);
    EMomerr_exit (ret0, ret_end);
    eles = ME.ECmarchfil->eles;

    ret0 = om$vla_set_dimension (varray = ME.ECmarchfil->copies, 
                                 size = v_s + ELEMS_ARRAY_INCR);
    EMomerr_exit (ret0, ret_end);
    copies = ME.ECmarchfil->copies;
    }

  /* 
   * save new ele
   */

  memcpy( &eles[*num_nodes], ele, sizeof(struct ele_stack) );

  o_objsptr = &eles[*num_nodes].ele_grid;
  s_objsptr = &copies[*num_nodes].ele_grid;

  action = 0;
  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  ret0 = om$send ( msg = message GRgraphics.GRcopy(msg,
                             active_md_env, active_md_env,
                             &(s_objsptr->objid) ),
                             senderid = NULL_OBJID,
                             targetid = o_objsptr->objid,
                             targetos = o_objsptr->osnum );
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
    
  s_objsptr->osnum = o_objsptr->osnum;

  ret0 = om$send ( msg = message GRgraphics.GRchgprops(msg,
                             &action, &props),
                             senderid = NULL_OBJID,
                             targetid = s_objsptr->objid,
                             targetos = s_objsptr->osnum );
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  (*num_nodes)++;
  (*march_front) = (*num_nodes) - 1;

ret_end:

  return ret0;

} /* push_node */

method pop_node(IGRlong *msg)
{
  IGRshort props, action; 
  IGRushort opts=0;
  IGRlong ret0=OM_S_SUCCESS;
  struct GRmd_env *active_md_env;
  IGRint *num_nodes;
  struct ele_stack *eles=0, *copies=0;

  *msg = EMS_S_Success;
  if( !ME.ECmarchfil->num_nodes )
    goto ret_end;

  active_md_env = &ME.ECelements->active_md_env;
  num_nodes = &ME.ECmarchfil->num_nodes;
  eles = ME.ECmarchfil->eles;
  copies = ME.ECmarchfil->copies;

  dp$display( msg=&ret0, oids=&(eles[*num_nodes-1].ele_grid), mode=GRbehe );

  ret0 = om$send( msg = message GRgraphics.GRdelete( msg, active_md_env),
                  senderid = NULL_OBJID,
                  targetos = eles[*num_nodes-1].ele_grid.osnum,
                  targetid = eles[*num_nodes-1].ele_grid.objid );
/*
   MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
*/

  ret0 = om$send( msg = message GRgraphics.GRdelete( msg, active_md_env),
                  senderid = NULL_OBJID,
                  targetos = copies[*num_nodes-1].ele_grid.osnum,
                  targetid = copies[*num_nodes-1].ele_grid.objid );
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  (*num_nodes)--;

  if( !ME.ECmarchfil->num_nodes )
    {
    ME.ECmarchfil->new_chain = 1;
    ME.ECmarchfil->disp_trim = 0;
    goto ret_end;
    }
  else if(ME.ECmarchfil->eles[ME.ECmarchfil->num_nodes-1].elem_type 
          == SPH_ELEMENT)
    ME.ECmarchfil->disp_trim = 0;

    dp$display( msg=&ret0, oids=&(eles[*num_nodes-1].ele_grid), mode=GRbehe );

    ret0 = om$send( msg = message GRgraphics.GRdelete( msg, active_md_env),
                    senderid = NULL_OBJID,
                    targetos = eles[*num_nodes-1].ele_grid.osnum,
                    targetid = eles[*num_nodes-1].ele_grid.objid );
/*
   MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
*/
  
    ret0 = om$send ( msg = message GRgraphics.GRcopy( msg, 
                           active_md_env, active_md_env, 
                           &eles[*num_nodes-1].ele_grid.objid),
                           senderid = NULL_OBJID,
                           targetid = copies[*num_nodes-1].ele_grid.objid,
                           targetos = copies[*num_nodes-1].ele_grid.osnum );
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

if(0)
  fprintf(stderr, "cpy frm stk %d\n", eles[*num_nodes-1].ele_grid.objid);

    eles[*num_nodes-1].ele_grid.osnum = copies[*num_nodes-1].ele_grid.osnum;


    opts = 0;
    if( *num_nodes == 1)
      opts = FIRST_ELE;
    ret0 = ECmf_open_edges(msg, opts, &ME.ECelements->active_md_env, 0, 
                           &eles[*num_nodes-1]);
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
  
    /* is this ugly or what, but need to update fillet list! */
    ECmf_fillets[ECmf_num_fillets].objid=eles[*num_nodes-1].ele_grid.objid;
    ECmf_fillets[ECmf_num_fillets].osnum=eles[*num_nodes-1].ele_grid.osnum;
    ECmf_num_fillets++;

  action = 1;
  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  ret0 = om$send ( msg = message GRgraphics.GRchgprops( msg,
                           &action, &props),
                           senderid = NULL_OBJID,
                           targetid = eles[*num_nodes-1].ele_grid.objid,
                           targetos = eles[*num_nodes-1].ele_grid.osnum );
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
  dp$display( msg=&ret0, oids=&eles[*num_nodes-1].ele_grid, mode=GRbdhe );
    
ret_end:
  return ret0;
  
} /* pop_node */



/*
 * disp marching direction
 *
 * ME.ECelements->eles[march_front] is current ele
 *
 * if(current ele) == SPH_ELEMENT, just hilite it.  What about march arrow?
 * if(current ele) == FIL_ELEMENT, disp arrow at hot edge, update march arrow.
 */

method disp_march_dir(IGRlong *msg; IGRushort opts)
{
  IGRint ii;
  IGRlong ret0=OM_S_SUCCESS;
  struct GRmd_env *active_md_env;
  IGRdouble pt_on_edge[2];
  struct GRid *curr_elem=0, *edges=0;
/* fix for abr of edge_num being -1 */
  IGRint num_nodes, *curr_elem_type=0, edge_num=0, array_size=0, num_edges=0; 
  IGRint flip_vect=0;
  IGRdouble *curr_hot_edge=0; 
  IGRint march_front=0;
  struct ele_stack *eles=0, *curr_ele=0;
  enum GRdpmode mode=GRhd;
  IGRpoint tanpoints[3];
  IGRvector vect;
  GRrange vect_range;
  struct EMSpartolbasis pt_edge_tol;

  IGRdouble                  p_range[4];
  IGRdouble                  min_bnd_hot_v, max_bnd_hot_v;
  IGRint                     num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;

  struct GRid the_edge_id; 

  *msg = EMS_S_Success;

  active_md_env = &ME.ECelements->active_md_env;
  num_nodes = ME.ECmarchfil->num_nodes;
  eles = ME.ECmarchfil->eles;
  march_front = ME.ECmarchfil->march_front;
  curr_ele = &eles[march_front];
  curr_elem = &curr_ele->ele_grid;
  curr_hot_edge = &eles[march_front].hot_edge;
  curr_elem_type = &eles[march_front].elem_type;

  /*
   * stupid check
   */

  if( !num_nodes )
    {
    dp$erase_hilite(msg = &ret0);
    goto ret_end;
    }

  if(curr_ele->elem_type == SPH_ELEMENT)
    goto arrow_display;

  MEM_FREE(edges);
  array_size = 0;
  num_edges  = 0;

  /*
   * get edges for current fillet & dermine edge id to draw the arrow
   */

  ret0= om$send(msg = message EMSsubbs.EMget_edges(msg, MAXINT, 
                EMS_OPT_NON_DEG_SEAM_XYZCLSD, active_md_env, &edges, 
                &array_size, &num_edges),
                targetid = curr_elem->objid,
                targetos = curr_elem->osnum);
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  for(ii=0; ii<num_edges; ii++)
    {

    /*
     * get midpt of chosen edge
     */

     ret0 = om$send (msg = message EMSedge.EMinternalpt (msg,
                     1, 0, pt_on_edge, NULL, &pt_edge_tol),
                     targetid = edges[ii].objid,
                     targetos = edges[ii].osnum); 
     MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

     if(fabs(pt_on_edge[1] - *curr_hot_edge) < EQUAL_TOL)
       {
       edge_num = ii;
       break;
       }
    }
  /* for num_edges */

  the_edge_id.objid = edges[edge_num].objid;
  the_edge_id.osnum = edges[edge_num].osnum;

arrow_display:

  /*
   * erase previous arrow
   */

  dp$erase_hilite(msg = &ret0);

  /*
   * hilite whole sph patch 
   */

  if(*curr_elem_type == SPH_ELEMENT)
    {
    /*dp$display( msg=&ret0, oids=curr_elem, mode=GRhd );*/
    for(ii=0; ii<3; ii++)
      if(curr_ele->open_edges[ii].objid != NULL_OBJID)
        {
        ret0= om$send(msg = message EMSedge.EMdisplay(msg, 0, 
                      &active_md_env->md_env.matrix_type,
                      active_md_env->md_env.matrix,
                      &mode, 0, EMS_WHL_EDGE, 0),
                      targetid = curr_ele->open_edges[ii].objid,
                      targetos = curr_ele->open_edges[ii].osnum); 
        MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
        }
    goto cleanup;
    }


  /*
   * for fillet, hilite the chosen edge
   */

  ret0= om$send(msg = message EMSedge.EMdisplay(msg, 0, 
                &active_md_env->md_env.matrix_type,
                active_md_env->md_env.matrix,
                &mode, 0, EMS_WHL_EDGE, 0),
                targetid = the_edge_id.objid,
                targetos = the_edge_id.osnum); 
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);


  /* 
   * for internal pt, if v==0, flip arrow.
   */

  if(*curr_elem_type == FIL_ELEMENT)
    {
      p_range[0] = 0;
      p_range[1] = 1;
      p_range[2] = 0;
      p_range[3] = 1;
      ret0 = EMis_natsf(msg, curr_elem, p_range, &num_mineds, &mineds,
                        &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
      MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

      MEM_FREE(mineds);
      MEM_FREE(maxeds);

      if( fabs(*curr_hot_edge - min_bnd_hot_v) < EQUAL_TOL )
        flip_vect = 1;
    }


  /*
   * get tanget to element's surface at the midpt
   * we need 4*radius since stupid funtcion EFdraw_vector_on_screen() 
   * scales it down by 4
   */

  ret0 = om$send( msg = message EMSsubbs.EMsftanorm(msg, 
                  &active_md_env->md_env.matrix_type,
                  active_md_env->md_env.matrix, 0,
                  1, &pt_on_edge[0], 1, &pt_on_edge[1], 
                  4*ME.ECmarchfil->radius, 0, 1, 0, (IGRdouble *)tanpoints, 0),
                  targetid = curr_elem->objid,
                  targetos = curr_elem->osnum);
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  /*
   * make a normalized tan vector and display it with arrowhd
   */

  BSmkvec (msg, vect, tanpoints[1], tanpoints[2]);
  MF_EMerr_hndlr (*msg != BSSUCC, ret0, OM_E_ABORT, ret_end);

  BSnorvec(msg, vect);
  MF_EMerr_hndlr (*msg != BSSUCC, ret0, OM_E_ABORT, ret_end);

  *msg = EMS_S_Success;

  if((tanpoints[2][0] - tanpoints[1][0]) > 0)
    {
    vect_range[0] = tanpoints[1][0];
    vect_range[3] = tanpoints[2][0];
    }
  else
    {
    vect_range[3] = tanpoints[1][0];
    vect_range[0] = tanpoints[2][0];
    }

  if((tanpoints[2][1] - tanpoints[1][1]) > 0)
    {
    vect_range[1] = tanpoints[1][1];
    vect_range[4] = tanpoints[2][1];
    }
  else
    {
    vect_range[4] = tanpoints[1][1];
    vect_range[1] = tanpoints[2][1];
    }

  if((tanpoints[2][2] - tanpoints[1][2]) > 0)
    {
    vect_range[2] = tanpoints[1][2];
    vect_range[5] = tanpoints[2][2];
    }
  else
    {
    vect_range[5] = tanpoints[1][2];
    vect_range[2] = tanpoints[2][2];
    }

  EFdraw_vector_on_screen(my_id, &ME.ECelements->active_display, 
                          active_md_env, GRhd, flip_vect, 
                          tanpoints[1], vect, vect_range, msg);
  MF_EMerr_hndlr (EMSerror (*msg), ret0, OM_E_ABORT, ret_end);


  /* 
   * update instance data so that we can project this arrow if next ele is also
   * a fillet
   */

  if(! flip_vect)
    {
    ME.ECmarchfil->march_arrow[0][0] = tanpoints[1][0];
    ME.ECmarchfil->march_arrow[0][1] = tanpoints[1][1];
    ME.ECmarchfil->march_arrow[0][2] = tanpoints[1][2];
    ME.ECmarchfil->march_arrow[1][0] = tanpoints[2][0];
    ME.ECmarchfil->march_arrow[1][1] = tanpoints[2][1];
    ME.ECmarchfil->march_arrow[1][2] = tanpoints[2][2];
    }
  else
    {
    ME.ECmarchfil->march_arrow[1][0] = tanpoints[1][0];
    ME.ECmarchfil->march_arrow[1][1] = tanpoints[1][1];
    ME.ECmarchfil->march_arrow[1][2] = tanpoints[1][2];
    ME.ECmarchfil->march_arrow[0][0] = tanpoints[2][0];
    ME.ECmarchfil->march_arrow[0][1] = tanpoints[2][1];
    ME.ECmarchfil->march_arrow[0][2] = tanpoints[2][2];
    }

cleanup:

  if(*curr_elem_type == SPH_ELEMENT)
    *curr_hot_edge = 0;


ret_end:

  MEM_FREE(edges);
  return ret0;

} /* disp_march_dir */


method do_form_notification(IGRint form_label, gad_label; IGRdouble value;
                             char *form_ptr)
{
  IGRlong ret0=OM_S_SUCCESS, msg=EMS_S_Success, size;
  IGRint state, response;

  form_label = form_label;
  value = value;

  if(gad_label == MATLTOGGLE)
    {
    FIg_get_state(form_ptr, gad_label, &state);
    if(state)
      ME.ECmarchfil->material_side = 0;
    else
      ME.ECmarchfil->material_side = 1;
    }
  else if(gad_label == COLLAPSE_GAD)
    FIf_collapse(form_ptr);
  else
    {
    FIg_disable(form_ptr, GAD_GRP);
    FIg_enable(form_ptr, gad_label);
    ME.ECmarchfil->form_option = gad_label;

    response = EX_FORM_FINISHED;
    size = 0;
    ret0 = ex$putque(msg = &msg, byte = &size, 
                     response = &response, buffer = NULL);
#ifdef DEBUG
    if(! (ret0 & msg & 1) )
      fprintf(stderr, "error doing ex$putque in do_form_notification\n");
#endif
    }

return 1;

} /* do_form_notification */


/*
 * given ele_grid, ele_type (either SPH_ELEMENT or FIL_ELEMENT, get ele_radius)
 * if ele_type ==0, check if ele is a fillet & then return radius
 */

static int qq_get_ele_radius(ele_grid, ele_type, active_md_env, ele_radius)
struct GRid                  *ele_grid;
IGRint                       *ele_type;
struct GRmd_env              *active_md_env;
IGRdouble                    *ele_radius;
{
  IGRlong                    ret0 = OM_S_SUCCESS;
  IGRlong                    mloc;
  struct IGRbsp_surface      *surf_info=0;
  struct BSgeom_bsp_surf     bsgeom_surf;
  IGRdouble                  p_range[4];
  IGRint                     fil_type, num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;
  IGRdouble                  min_bnd_hot_v, max_bnd_hot_v;


  *ele_radius = 0;

  ret0 = EMgetvggeom ( &mloc,
                       &active_md_env->md_env.matrix_type,
                       active_md_env->md_env.matrix,
                       ele_grid,
                       &surf_info, 0 );
  MF_EMerr_hndlr (EMSerror (ret0 & mloc), ret0, OM_E_ABORT, ret_end);

  if(*ele_type == SPH_ELEMENT)
    {
    bsgeom_surf.bspsf = surf_info;

    BSsph_prop(&bsgeom_surf, &mloc);
    MF_EMerr_hndlr (mloc != BSSUCC, ret0, OM_E_ABORT, ret_end);

    *ele_radius = bsgeom_surf.len1;
    }
  else
    {

    BSfilsftest( surf_info, 0.05, &fil_type, ele_radius, &mloc );
    MF_EMerr_hndlr (mloc != BSSUCC, ret0, OM_E_ABORT, ret_end);

    if(fil_type)
      {

      /*
       * stephen's func would give V end at which boundary is imposed
       * if boundary is imposed at both ends, discard the fillet
       * else set ugly global as where boundary is imposed  this gobal
       * is used in disp_march_dir to set march_dir
       */

      p_range[0] = 0;
      p_range[1] = 1;
      p_range[2] = 0;
      p_range[3] = 1;
      ret0 = EMis_natsf(&mloc, ele_grid, p_range, &num_mineds, &mineds,
                        &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
      MF_EMerr_hndlr (EMSerror (ret0 & mloc), ret0, OM_E_ABORT, ret_end);
      if(min_bnd_hot_v != -1)
        {
#ifdef DEBUG 
fprintf(stderr, "got a fillet min_bnd_hot_v %lf\n", min_bnd_hot_v);
fflush(stderr);
#endif

        harmless_global = min_bnd_hot_v;  
        *ele_type = FIL_ELEMENT;
        }
      else if(max_bnd_hot_v != -1)
        {
#ifdef DEBUG 
fprintf(stderr, "got a fillet max_bnd_hot_v %lf\n", max_bnd_hot_v);
fflush(stderr);
#endif

        harmless_global = max_bnd_hot_v;  
        *ele_type = FIL_ELEMENT;
        }

      } 
    /* if (fil_type) */

    }
  /* if *ele_type != SPH_ELEMENT */


ret_end:

  MEM_FREE(surf_info);
  MEM_FREE(mineds);
  MEM_FREE(maxeds);

  return ret0;

} /* qq_get_ele_radius */

static int qq_sf_is_fill(num_elems, elems)
IGRint num_elems;
struct GRlc_info *elems;
{
  IGRint ii, jj;

  for(ii=0; ii<num_elems; ii++)
    for(jj=0; jj<ECmf_num_fillets; jj++)
      if(elems[ii].located_obj.objid == ECmf_fillets[jj].objid)
        return 1;

  return 0;

}

static int qq_build_ele_header(msg, open_edge, active_md_env, edge_header)
IGRlong *msg;
struct GRid *open_edge;
struct GRmd_env *active_md_env;
struct DPele_header *edge_header;
{
  IGRlong stat=OM_S_SUCCESS;
  struct GRid srf_id;
  struct IGResqbs bsqsurf;
  GRrange range;
  struct GRsymbology symb;
  union IGRele_attr  ele_spec_att;


  *msg = EMS_S_Success;
  ele_spec_att.bsqsurf = &bsqsurf;


  stat = om$send(msg = message EMSboundary.EMgetsurface_info
                (msg, &srf_id.objid, NULL), 
                targetid = open_edge->objid,
                targetos = open_edge->osnum,
                senderid = NULL_OBJID);
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);
 
  srf_id.osnum = active_md_env->md_id.osnum;

  stat = om$send(msg = message EMSsubbs.EMget_ele_header(msg, NULL,
                    &active_md_env->md_env, NULL, edge_header, range,
                    &symb.display_attr, ele_spec_att, NULL),
                    targetos = srf_id.osnum,
                    targetid = srf_id.objid,
                    senderid = NULL_OBJID);
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  edge_header->dis_att->weight = 2;
  edge_header->dis_att->color = 8;
  
ret_end:

  return stat;
}

end implementation ECmarchfil;
