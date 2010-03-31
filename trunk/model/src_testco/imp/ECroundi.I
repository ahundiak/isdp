/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
	This command is rewritten to support phoenix rounding interface. It
	consists of one main form & a sub-form. The options supported are
	different edge selection options, fillet type (constant or varying),
	neutral angle definition & a way to deselect the selected edges.
	In addition to the form input the user can switch between different 
	options by keying in a unique character.
	The user also has an option not to complete the round process. In
	that the fillet surface would be generated which can then be used in
	manual mode to complete the round.

OPTIONS

ALGORITHM
	The use of the command is thru. the form/keying in unique character. 
	Based on the edge selection type a different method is invoked.

NOTES
	Refer to the rounding specifications for more details of the various 
	features supported.
	Chamfer edge/vertex is now moved to a new file ECchamferi.I
	Single edge/vertex option is implemented in EMrndedloc.I	
	Surface loop option is implemented in EMrndsurfloc.I	
	Chain edge option is implemented in EMrndchailoc.I	
	Fillet/All radii edge option is implemented in EMrndcacxloc.I	

HISTORY
    	Tapadia 11/25/92 
	SCW     04/01/93  Added setting of locate_ref_obj instance for
                          edge/vertex location.
        SCW     08/14/94  clarified sleep method
        Prashant 07/15/96 Added subform_displayed in method sleep so as
                          to erase it first than the main form ( in response 
                          to TR# 119528639 & TR# 119305803) 

*/

class implementation ECround;

#include <stdio.h>
#include "math.h"
#include <stdlib.h>
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "lcmacros.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "EMSaction.h"
#include "griomacros.h"
#include "OMprimitives.h"
#include "emserr.h"
#include "DIdef.h"
#include "EMSdpb.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSasmacros.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSasopts.h"
#include "EMSprop.h"
#include "EMSrnd.h"
#include "EC_P.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_E.h"
#include "EC_S.h"
#include "msdef.h"
#include "msmacros.h"

#include "OMmacros.h"
#include "OMminimum.h"
#include "EMS.h"
#include "igr.h"
#include "gr.h"
#include "ECmsg.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "prototypes/bsdistptpt.h"
#include "grdpbmacros.h"
#include "igrtypedef.h"


/*
 * This global variable is defined in src_bound/imped/EMedbdryloc.I
 * and is meant to indicate to the locate machinery that we do
 * not want to locate tangent edges.
 */

extern IGRboolean locate_tangent_edges;

#define DEBUG 0  /*Set to 1 if want error strings printed.*/

#define EDGE_SEL_OPT	0
#define ROUND    	4
#define UNDO     	5
#define EDGE_VERTEX 	6
#define SURFACE_LOOP	9
#define CHAIN		13
#define FILLET_RADII	19

#define MAXGROUP  10

from GRgraphics  import GRdisplay,
                        GRdelete;
from GRvg        import GRgetsize, GRgetgeom, GRgetsymb, GRputsymb
                        ;
from EMSsurface  import EMgetactiveid, EMlmround, EMshow_normals, 
                        EMrevorient,EMlmnewround;
from EMSsubbs    import EMget_edges;
from EMSdpr      import EMdeactivate, EMundo;
from EMSsfdpr    import EMadd;
from EMSboundary import EMgetsurface_info;
from EMSedge     import EMdisplay, EMxyz_endpt;

#define RNDEDGE 	0
#define RNDVERT 	1

#define CHAIN_TYPE		1
#define EDGE_VERTEX_TYPE	2
#define SURFACE_LOOP_TYPE	3
#define FILLET_TYPE		4
#define RADII_TYPE		5
#define CONSTANT_TYPE		6
#define VARYING_TYPE		7

%safe
static IGRdouble def_radius = -1.0;
static IGRint pre_tmp_ed;
static IGRint pre_bkp_entries;
%endsafe

#define ARRAY_INC 10

extern OMuword OPP_EMSsubbs_class_id, 
               OPP_EMSsolid_class_id,
               OPP_EMSsfboolean_class_id;
extern IGRlong EFhilite_edge_with_weight();
extern void EFrestore_hilite_of_edges();

extern int ReGroupEdges();

method init(int type; char *str_ptr)
{
    IGRlong sts;
    IGRlong msg = MSSUCC;
    IGRchar units[52];
    short num_defaults = 1, flag = 0;
    IGRdouble factor;

    /* initialize */
    ME.super_cmd->state = EDGE_SEL_OPT;
    ME.super_cmd->form_id = NULL_OBJID;
    me->form_displayed = FALSE;
    me->subform_displayed = FALSE;
    me->form = NULL ;
    me->sub_form = NULL ;
    /* the default angle of v_bottom */
    me->neutral_edge_angle = 0.001;
    me->fillet_type = CONSTANT_TYPE;
    me->edge_type = CHAIN_TYPE; 
    me->valid_inputdata = TRUE;
     me->option_change = FALSE;
    me->radius_changed = 1;
    me->selection = TRUE;
    me->fillet_out = FALSE;
    me->numed = 0;
    me->numtmped = 0;
    me->numtmp_chain_links = 0;
    me->rnd_construct_id.objid = NULL_OBJID;
    me->active_GRid.objid = NULL_OBJID;
    me->inner_loop = FALSE;
    me->num_bkp_entries = 0;
me->numgroup=0;
    sts = om$send(mode = OM_e_wrt_message,
		msg = message COconst.init(type, str_ptr), 
		targetid = my_id);

    /* Get the default units */
    sts = co$get_default_units(msg = &msg,
			table_name = GRIO_DISTANCE,
			osnum = 2,
			flag = &flag,
			num_defaults = &num_defaults,
			default_units = units);

    /* Based on the units assign a default value for diameter & depth */
    if(strncmp(units,"mm", 2) == 0) {
	if(def_radius < 0.0) 
		def_radius = 5.0;
    }
    else if(strncmp(units,"in", 2) == 0) {
	if(def_radius < 0.0) 
		def_radius = .1;
    }
    else {
	sts = co$cvt_exp_to_wrk(msg =  &msg,
                              unit_type = "UOM_DISTANCE",
			      osnum = 2,
                              units = 1.0,
                              alias = units, 
                              result = &factor);
	if(def_radius < 0.0) 
	  def_radius = 0.1/ factor;
    }

    me->active_rad = def_radius;
    return(sts);
}

method wakeup(int pos)
{
    IGRboolean    state;
    IGRlong sts;
    sts = OM_S_SUCCESS;

    if(ME.super_cmd->state != UNDO)
     	sts = om$send(mode = OM_e_wrt_parent,
                 msg = message ECround.wakeup(pos),
                 targetid = my_id);
    if(!(1& sts)) return(OM_E_ABORT);
    gr$get_associative_flag( buffer = &state );
    if (state) {
    	GRdisplay_associative_button(TRUE);
    	me->associative = TRUE;
    }
    else me->associative = FALSE;


    if(me->form_displayed == TRUE) {
	sts = FIf_display(ME.ECsfedloc->form);
    }
    GRstatus_display_button(TRUE);

    EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
    return(sts);
}

method super_cmd.sleep(int pos)
{
    IGRlong sts;

    sts = OM_S_SUCCESS;
    if (me->associative) GRdisplay_associative_button(FALSE);


    sts = om$send(mode = OM_e_wrt_parent,
                 msg = message ECround.sleep(pos),
                 targetid = my_id);
    if(!(1 & sts)) return(OM_E_ABORT);

    if(me->form_displayed == TRUE) {
       if(me->subform_displayed == TRUE)
         FIf_erase(ME.ECsfedloc->sub_form);
	FIf_erase(ME.ECsfedloc->form);
    }
    GRstatus_display_button(FALSE);

    return(sts);
}

method execute( int *response; char *response_data; int pos )
{
 IGRushort 	local_options;
 IGRlong        OM_stat,sts;
 IGRint         jj,ii,i,j, mytype, num_ele, tmp_val, cur_edge_type, cur_fil_type, 
		num_edges; 
 IGRlong        msg, msg_loc; 
 OMuword        osnum;
int aa,bb;
 IGRshort       operation_type;
 IGRboolean     EFisAncestryValid(), save_locate_tangent_edges,cur_sel_type;
 extern IGRlong EFlocate_action_handler();
 IGRlong        stat_func;
 IGRchar        prompt_string[MAX_CHAR];
 void 		EFparse_keyin();
 void 		EFsubparse_keyin();
 IGRdouble 	chtol;
 IGRpoint       edge_ends[2];
 IGRlong 	EFget_actual_edges_list();
 void 	EFrecompute_chains_radius();
 struct GRvg_construct 		construct_list;
 struct EMSrnd_boundary_input   *rnd_edges;
struct EMSrnd_boundary_input *grp_rnd_edges;
int grp_num_edges;
int tmp_grp_count;
int new_chain_flag;
char *env_flag=NULL;
int free_edge_flag;
int first_end_flag;
int second_end_flag;
int first_else,second_else;
int modified=0;
int left_edge[200],right_edge[200];
int first_edge , last_edge;
int num_processed;
int already_processed;
IGRboolean dist_processed;
IGRboolean dist1_processed;
int tmp_count;
int first_group_edge = 0;
int tmp_group;
int prev_edge=0;
int current_group=0;
int edge_count=0; 
int end_flag=0;
int processed_edges[50];
int tmp_numgroup=0;
int numgroup=0;
int numround[1000];
IGRboolean EFedgeprocessed();

        IGRdouble       xyztol,sqtol;
        IGRpoint  start_pt, end_pt, ref_pt,start_pt1, end_pt1;

        IGRlong bsrc;
        IGRdouble dist,dist1;
IGRint orig_group_id, replace_group_id;
IGRint kk;
IGRint tempflag;

        struct EMSrnd_boundary_input *tmp_rnd_edges;


    
 struct EMSround_error          *round_error;
tempflag = 0;
free_edge_flag=0;
first_end_flag = 0;
second_end_flag = 0;

 OM_stat = OM_S_SUCCESS;
 mytype = ME.super_cmd->mytype;
 osnum = me->ModuleInfo.md_id.osnum;
 round_error = NULL;
tmp_grp_count =0;
new_chain_flag = 0;
 me->locate_ref_obj = FALSE;
/*
for(ii=0;ii<MAXGROUP;ii++)
{
        numround[ii]=0;
}
*/

 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chtol);

 switch(mytype)
 {
   case RNDEDGE:
     	ex$message(msgnumb = EM_M_RndEdg);
     	operation_type = EMS_ROUND_OPR;
     	break;
   case RNDVERT:
     	ex$message(msgnumb = EM_M_RndVtx);
     	operation_type = EMS_ROUND_OPR;
     	break;
   default:
     	ERROR(OM_E_ABORT, EMS_E_Fail, "invalid mytype", wrapup);      
 }

 do
  {
   switch(ME.super_cmd->state)
   {
   
    /* Based on the edge type the right command state is executed */ 

    case EDGE_SEL_OPT:
	if(me->edge_type == EDGE_VERTEX_TYPE)
   		ME.super_cmd->state = EDGE_VERTEX;
	else if(me->edge_type == CHAIN_TYPE)
   		ME.super_cmd->state = CHAIN;
	else if(me->edge_type == SURFACE_LOOP_TYPE)
   		ME.super_cmd->state = SURFACE_LOOP;
	else if(me->edge_type == FILLET_TYPE || me->edge_type == RADII_TYPE)
   		ME.super_cmd->state = FILLET_RADII;
	break;

    /* Based on the edge option the user is prompted for different data 
    	based on the method invoked */

    case EDGE_VERTEX:
    case SURFACE_LOOP:
    case CHAIN:
    case FILLET_RADII:
      {
     	char (*funcptr)()=NULL ;

	cur_edge_type = me->edge_type;
	cur_fil_type = me->fillet_type;
	cur_sel_type = me->selection;

	/* Edge option is single edge/vertex */
   	if(ME.super_cmd->state == EDGE_VERTEX) {
//printf(" EDGE_VERTEX \n");
new_chain_flag=0;
            save_locate_tangent_edges = locate_tangent_edges;
            locate_tangent_edges = 0;
       	    OM_stat = om$send(mode = OM_e_wrt_message,
       			msg = message ECround.locate_rnd_edge( &msg_loc, 
                	response, response_data, prompt_string, funcptr),
       	    	targetid = my_id);
            locate_tangent_edges = save_locate_tangent_edges;
	}

	/* Edge option is surface loop */
   	else if(ME.super_cmd->state == SURFACE_LOOP) {
//printf(" SURFACE_LOOP \n");
new_chain_flag=0;
            save_locate_tangent_edges = locate_tangent_edges;
            locate_tangent_edges = 0;
       	    OM_stat = om$send(mode = OM_e_wrt_message,
       			msg = message ECround.locate_surf_edge( &msg_loc, 
                	response, response_data, prompt_string, funcptr),
       	    	targetid = my_id);
            locate_tangent_edges = save_locate_tangent_edges;
	}

	/* Edge option is chain edges */
   	else if(ME.super_cmd->state == CHAIN) {
            save_locate_tangent_edges = locate_tangent_edges;
            locate_tangent_edges = 0;
       	    OM_stat = om$send(mode = OM_e_wrt_message,
       			msg = message ECround.locate_chain_edge( &msg_loc, 
                	response, response_data, prompt_string, funcptr),
       	    	targetid = my_id);
if(( ME.super_cmd->state == CHAIN) && (ME.super_cmd->state != SURFACE_LOOP))
{
//printf(" CHAIN \n");
        new_chain_flag =1;
}
            locate_tangent_edges = save_locate_tangent_edges;
	}

	/* Edge option is all fillets (concave)/all radii (convex)  */
   	else if(ME.super_cmd->state == FILLET_RADII) {
//printf(" FILLET_RADII \n");
new_chain_flag=0;
            save_locate_tangent_edges = locate_tangent_edges;
            locate_tangent_edges = 0;
       	    OM_stat = om$send(mode = OM_e_wrt_message,
       			msg = message ECround.locate_concave_convex_edge(
			&msg_loc, response, response_data, prompt_string, 
			funcptr),
       	    	targetid = my_id);
            locate_tangent_edges = save_locate_tangent_edges;
      	}
      }
	
      /* This is done to check if the edge/fillet/selection option is changed.
      	If it's changed all the tmp edges are put or removed from perm list of
      	edges depending on the option being either selection/de-selection. In 
      	addition the user may have used the move-on button to process round */

      if((cur_edge_type != me->edge_type) || 
	  (cur_fil_type != me->fillet_type) ||   
	  (cur_sel_type != me->selection) ||
	  me->event.response == EX_RJT_MOVEON) {
            tmp_val = me->numed;
	    if(cur_sel_type) {	/* Selection */
             num_ele = om$dimension_of(varray = me->located_obj);
             if((me->numed + me->numtmped  + 1) >= num_ele) {
                    OM_stat = om$vla_set_dimension(varray = me->located_obj,
                        size = me->numtmped + 4 + me->numed);
             }
             if(me->numed) { 
              IGRboolean found;
              for(ii = 0; ii < me->numtmped; ii++) { 
               found = FALSE;
                for(jj = 0; jj < me->numed ; jj++) {
                if(me->bound_code[jj] &  EMSrnd_mark_ed_deleted) continue;
                  if(me->located_obj[jj] == me->tmp_located_obj[ii]) {
                    found = TRUE; break;
                  }
                }
                if(!found)
		  me->located_obj[tmp_val++ ] = me->tmp_located_obj[ii];
              }
              me->numed = tmp_val;
             }
             else { 
	    	me->numed += me->numtmped;
	        for(i = 0; i < me->numtmped; i++)  
			me->located_obj[tmp_val + i] = me->tmp_located_obj[i];
             }
	    }
	    else { /* De-selection */
		if(me->numtmped) {
/* added by vidya an arg end_edge_val to support variable radius */
		  EFrecompute_chains_radius(ME.COroot->ModuleInfo,me->numtmped,
		    &me->numtmp_chain_links,me->var_chain_edges,
                    me->tmp_located_obj,me->located_obj,
		    me->numed,me->edgeval_event,me->end_edgeval_event,
		    me->bound_code);

		    OM_stat = EFget_actual_edges_list(&msg_loc, 
			me->located_obj, me->tmp_located_obj, me->numed, 
			me->numtmped, osnum,
			me->bound_code);
		}
	    }
	    pre_tmp_ed = me->numtmped;
	    pre_bkp_entries = me->num_bkp_entries;
	    me->numtmped = 0;
            me->num_bkp_entries = 0;
      }

      /* The user could have changed the option using keyin, invoking
      	the status button/options icon */

      if(*response == STRING) ME.super_cmd->state = EDGE_SEL_OPT;
      else 
      if( *response == CMD_STRING  ) {
	 me->valid_inputdata = TRUE;
	 goto wrapup;
      }
      else 
      if(*response == EX_CMD_KEY  || *response == EX_POCKET)  {
		ME.super_cmd->state = EDGE_SEL_OPT; 
	    goto wrapup;
      }
      else if(*response == STATUS_DISP) {
		ME.super_cmd->state = EDGE_SEL_OPT; 
		goto wrapup;
      }
      else if(*response == CLEAR_STACK || *response == TERMINATE) {
        	goto wrapup;
      }
      else

      if(me->loc_event.response == EX_BACK_UP) 
		ME.super_cmd->state = EDGE_SEL_OPT;
      else if(me->loc_event.response == EX_RJT_MOVEON) {
     	    osnum = ME.COroot->ModuleInfo.md_id.osnum;
	    if(me->numed) ME.super_cmd->state = ROUND;
      }

      /* This situation occurs when the edge type option is changed in the 
	form, which results in the prompt string to be accordingly changed */
      else { /* Resetting the response */
	/* me->event.response = EX_DATA; */
	    ME.super_cmd->state = EDGE_SEL_OPT;
      }
      
      def_radius = me->active_rad;
      break;   

   /* Process round operation */

   case ROUND:
      {
      ex$message(msgnumb = EMS_P_ClearPromptField);
      ex$message(msgnumb = EMS_I_00003);

      dp$erase_hilite(msg = &msg);

      construct_list.msg = &msg;
      construct_list.env_info = &ME.COroot->ModuleInfo;
      construct_list.newflag = FALSE;
      construct_list.level = ME.COconst->ActiveLevel;
      construct_list.properties = GRIS_DISPLAYABLE | 
                                  GRIS_NEW |
                                  GRIS_LOCATABLE;
      construct_list.geometry = NULL;
      construct_list.display = &ME.COconst->ActiveDisplay;
      construct_list.class_attr = NULL;
      construct_list.name = NULL;


      {
        IGRint ii, num_vals;
        struct EMSvalue_info *edge_vals=NULL;
        struct EMSvalue_info *end_edge_vals=NULL;
        IGRushort rnd_opts;
        extern IGRboolean IGEstop();
        extern int ems_do_print_error_messages;

        /*Uniform edge vals?*/
	me->uniformval = -1;
        num_vals = (me->uniformval != -1) ? 1 : me->numed;

        edge_vals = (struct EMSvalue_info *) 
                    alloca(num_vals * sizeof(struct EMSvalue_info));
        if (!edge_vals)
         ERROR(OM_E_ABORT, EMS_E_NoStackMemory, "val_info", wrapup);

        end_edge_vals = (struct EMSvalue_info *) 
                    alloca(num_vals * sizeof(struct EMSvalue_info));
        if (!end_edge_vals)
         ERROR(OM_E_ABORT, EMS_E_NoStackMemory, "val_info", wrapup);

        for(ii=0; ii<num_vals; ii++)
        {
          edge_vals[ii].type = EMSdatainfo_event;
          edge_vals[ii].valevent = &me->edgeval_event[ii];
          edge_vals[ii].val = me->edgeval_event[ii].event.value;
          end_edge_vals[ii].type = EMSdatainfo_event;
          end_edge_vals[ii].valevent = &me->end_edgeval_event[ii];
          end_edge_vals[ii].val = me->end_edgeval_event[ii].event.value;
        }

        rnd_opts = me->associative ? NULL : EFrnd_cham_PLACE_NON_ASSOC;
        rnd_opts |= (me->uniformval != -1) ? EFrnd_cham_UNIFORM : NULL;

        {
         ems_do_print_error_messages = FALSE;
         rnd_edges = ( struct EMSrnd_boundary_input * ) alloca
                ( me->numed * sizeof( struct EMSrnd_boundary_input ) );
        grp_rnd_edges = ( struct EMSrnd_boundary_input * ) alloca
                ( me->numed * sizeof( struct EMSrnd_boundary_input ) );

         num_edges = 0;
         for( i = 0; i < me->numed; i++ )
         {
	    if(me->bound_code[i] & EMSrnd_mark_ed_deleted) continue;
            rnd_edges[num_edges].boundary_id.objid = me->located_obj[i];
            rnd_edges[num_edges].boundary_id.osnum = osnum;
            /* Following is used for simulating variable radius rounding */
               om$send( msg = message EMSedge.EMxyz_endpt( &msg, 0,
                                 &ME.COroot->ModuleInfo.md_env,
                                 0, 0,
                                 edge_ends[0], edge_ends[1], 0 ),
                        targetid = rnd_edges[num_edges].boundary_id.objid,
                        targetos = rnd_edges[num_edges].boundary_id.osnum );
                                 
	    if(me->fill_typ[i] == CONSTANT_TYPE) {
               OM_BLOCK_MOVE(&edge_vals[i], &rnd_edges[num_edges].radius,
                              sizeof(struct EMSvalue_info));
	    }
            else /* non-uniform case */
            {
               OM_BLOCK_MOVE( &edge_vals[i], &rnd_edges[num_edges].radius,
                              sizeof( struct EMSvalue_info ) );

               OM_BLOCK_MOVE( &end_edge_vals[i], &rnd_edges[num_edges].other_radius,
                              sizeof( struct EMSvalue_info ) );
            }
            rnd_edges[num_edges].props = me->bound_code[i];

	    if(me->fill_typ[i]  == VARYING_TYPE) {
//printf(" VARYING_TYPE \n");
new_chain_flag=0;
	    	rnd_edges[num_edges].props |= EMSfillet_is_variable_radius;
	    }
            rnd_edges[num_edges].rho_value.type = EMSdatainfo_undefined;
            rnd_edges[num_edges].options = 0;
            num_edges++;
         }
         local_options = me->associative ? 0 : EMS_RND_NON_ASSOCIATIVE;
         local_options |= operation_type == EMS_CHAMFER_OPR
                             ? EMS_RND_CHAMFER : 0;

	if(me->fillet_out)
		local_options |= EMS_RND_DONOT_MODIFY_MODEL;

	me->rnd_construct_id.osnum = osnum;

/* ----------------- jeff-----------------------------      */
/*  This is part of the code is to regroup connected groups */
new_chain_flag = 1;
for(i=0;i<num_edges;i++)
{
//printf(" ID - %d \n",rnd_edges[i].boundary_id.objid);
}
env_flag = getenv("ROUND_REORDER");
if(env_flag)
{
 if((strcmp(env_flag,"1")==0) && (new_chain_flag== 1))
   new_chain_flag = 1;
 else
   new_chain_flag = 0;
}
else
  new_chain_flag = 0;

if(new_chain_flag)
{
//printf(" ROUNDING REODERING ENABLED \n");
  numgroup = num_edges;
  for(i=0;i< numgroup;i++)
  {
     numround[i] =1;
     me->group_edge_info[i].group_id = i;
  }

        sts = OM_S_SUCCESS;
	// temporary assignment for loop
	for( i=0;i< numgroup ;i++)
	{
	  me->group_edge_info[i].edge_id = rnd_edges[i].boundary_id.objid;
	}

   for(ii=0;ii< numgroup ;ii++)
  {
  numround[ii] = 1 ;
   //printf(" %d  %d \n",ii,numround[ii]);
  }
        tmp_rnd_edges = ( struct EMSrnd_boundary_input * ) alloca
                ( num_edges * sizeof( struct EMSrnd_boundary_input ) );

	for(ii=0;ii<num_edges;ii++)
	{
  		sts = om$send (msg = message EMSedge.EMxyz_endpt(&msg,0,
                           &ME.COroot->ModuleInfo.md_env,
                           0,0,start_pt,end_pt,0),
                           targetid = rnd_edges[ii].boundary_id.objid,
			   targetos = rnd_edges[ii].boundary_id.osnum);

		for(jj=0;jj<num_edges;jj++)
		{
			dist=0.0;
			dist1=0.0;

			if( ! ( rnd_edges[ii].boundary_id.objid == 
				rnd_edges[jj].boundary_id.objid  ))
			{


       				sts = om$send (msg = 
					message EMSedge.EMxyz_endpt(&msg,NULL,
                       			&ME.COroot->ModuleInfo.md_env,
                       			NULL,NULL,start_pt1,end_pt1,NULL),
           			     targetid = rnd_edges[jj].boundary_id.objid,
			             targetos = rnd_edges[ii].boundary_id.osnum
                                	);

        			BSEXTRACTPAR(&bsrc,BSTOLCHRDHT,xyztol);
        			sqtol=(xyztol)*(xyztol);
sqtol= xyztol;
        			ref_pt[0]=start_pt[0];
				ref_pt[1]=start_pt[1];
				ref_pt[2]=start_pt[2];

        			for(i=0;i<2;i++)
        			{
 				   dist = BSdistptpt(&bsrc,ref_pt,start_pt1);

         //			   if(bsrc!=BSSUCC) goto wrapup;

         			   dist1 = BSdistptpt(&bsrc,ref_pt,end_pt1);
         //			   if(bsrc!=BSSUCC) goto wrapup;
				   if(dist <= sqtol || dist1 <= sqtol)
         			   {
				     if( ! ( me->group_edge_info[ii].group_id ==                                             me->group_edge_info[jj].group_id) )
				     {
//printf(" ii - %d   %lg %lg \n",ii,dist,dist1);
               
               orig_group_id= me->group_edge_info[ii].group_id;
               replace_group_id=me->group_edge_info[jj].group_id ;

               for(kk=0;kk<num_edges;kk++)
               {
                 if( me->group_edge_info[kk].group_id == replace_group_id  )
        	     me->group_edge_info[kk].group_id = orig_group_id;
               }

               for(kk=jj;kk< numgroup;kk++)
               {

                  numround[kk-1 ] =  numround[jj] ;
 
               }
               if(numgroup != 1 )
               numgroup -- ;

if(orig_group_id > replace_group_id)
{
 numround[replace_group_id] = numround[orig_group_id] +
                                numround[replace_group_id] ;
}
else
{
               numround[orig_group_id] = numround[orig_group_id] +  
				numround[replace_group_id] ; 
}

               for(kk=0;kk<num_edges;kk++)
               {

                 if( me->group_edge_info[kk].group_id >= replace_group_id )
	             me->group_edge_info[kk].group_id --;


                }


				/* all the processing must come here */
				}

         			}
         			ref_pt[0]=end_pt[0];
				ref_pt[1]=end_pt[1];
				ref_pt[2]=end_pt[2];
       			}
                   }

    		} /* end of jj for loop */

  	} /* end of ii for loop */
/* ------------------------------------------- end of regrouping edges */
  for(i=0;i<numgroup;i++)
  {
  //printf(" end of regrouping - %d \n",numround[i]);
   }
 tmp_numgroup = numgroup;
  for(jj=0;jj<tmp_numgroup;jj++)
  {
     if( numround[jj] == 0)
     {
       for(ii=jj;ii<numgroup;ii++)
       {
          numround[jj]=numround[jj+1];
       }
       numgroup--;
     }
  }
/* jeff START of spliting into groups incase of deselection */
/*
   num_processed=0;

   current_group=0;
first_edge=0;
last_edge=0;
modified=0;
   for(ii=0;ii< numgroup;ii++)
   {
      last_edge=first_edge + numround[ii];
modified=0;
      for(jj=0;jj< numround[ii];jj++)
      {
         left_edge[jj]=0;
         right_edge[jj]=0;
         first_end_flag=0;
	 second_end_flag=0;
         first_else=0;
         second_else=0;
	 processed_edges[edge_count]=rnd_edges[edge_count].boundary_id.objid;
   	 sts = om$send (msg = message EMSedge.EMxyz_endpt(&msg,0,
                           &ME.COroot->ModuleInfo.md_env,
                           0,0,start_pt,end_pt,0),
                           targetid = rnd_edges[edge_count].boundary_id.objid,
                           targetos = rnd_edges[edge_count].boundary_id.osnum);
dist_processed=FALSE;
dist1_processed=FALSE;
         for( kk =first_edge; kk<last_edge;kk++)
	 {
            dist=0.0;
            dist1=0.0;
            if(!( rnd_edges[edge_count].boundary_id.objid ==
				 rnd_edges[kk].boundary_id.objid
			  	) )
            {
               sts = om$send (msg =
                                        message EMSedge.EMxyz_endpt(&msg,NULL,
                                        &ME.COroot->ModuleInfo.md_env,
                                        NULL,NULL,start_pt1,end_pt1,NULL),
                                     targetid = rnd_edges[kk].boundary_id.objid,
                                     targetos = rnd_edges[kk].boundary_id.osnum
                                        );

               BSEXTRACTPAR(&bsrc,BSTOLCHRDHT,xyztol);
               sqtol=(xyztol)*(xyztol);

               ref_pt[0]=start_pt[0];
               ref_pt[1]=start_pt[1];
               ref_pt[2]=start_pt[2];

               for(i=0;i<2;i++)
               {
                  dist = BSdistptpt(&bsrc,ref_pt,start_pt1);
                  dist1 = BSdistptpt(&bsrc,ref_pt,end_pt1);
		  if( dist < sqtol)
		  {
		      if(dist_processed)  
		      {
			second_end_flag=1; 
			right_edge[jj]=1;
		      }
                      else 
                      {
			dist_processed=TRUE;
                      }
                     first_end_flag=1; 
                     left_edge[jj]=1;
                     already_processed = EFedgeprocessed(edge_count,
                               rnd_edges[kk].boundary_id.objid,processed_edges);
  		     if( (already_processed == FALSE))
  		     {
   		        if(end_flag == 2)
   		        {
                           current_group++;
                           modified=1;
	                   numgroup++;
                           end_flag=0;  
   		        }
                     }
                     me->group_edge_info[edge_count].group_id = current_group;
                  }
                  else
                  {
			first_else=1;
                  }
                  if( dist1 < sqtol)
                  {
		      if(dist1_processed) 
		      {
                        first_end_flag=1;
                         left_edge[jj]=1;
                      }
                      else
                      {
                          dist1_processed=TRUE;
                      }

                      second_end_flag=1;
                      right_edge[jj]=1;
                      already_processed = EFedgeprocessed(edge_count,
                              rnd_edges[kk].boundary_id.objid,processed_edges);
                      if( (already_processed == FALSE))
                      {
                         
                       //     if both end flags have been hit then the 
                    //      chain is closed. so we increment the current_group.
                  //         we assign the current group to the group id before 
           //               incrementing so that the next group will have the
           //               higher group number .
                         
                         if(end_flag == 2)
                         {
                            current_group++;
     			    modified=1;	
	                    numgroup++;  
                            end_flag=0;
                         }
                      }
                      me->group_edge_info[edge_count].group_id = current_group;
                   }
                   else
                   {
			second_else=1; 
                   }


                   ref_pt[0]=end_pt[0];
                   ref_pt[1]=end_pt[1];
                   ref_pt[2]=end_pt[2];
               }
            }
	 }

         if( first_end_flag == 0 && second_end_flag == 0)
         {
            me->group_edge_info[edge_count].group_id = current_group; 


            if( numround[current_group]==1 &&( edge_count==(num_edges-1)))
               me->group_edge_info[edge_count].group_id = current_group;
	    current_group++;
            modified=1;
            numgroup++; 


            for(aa=0;aa<numgroup;aa++)
            {
               numround[aa]=0;
               for( bb=0;bb<num_edges;bb++)
               {
                  if(me->group_edge_info[bb].group_id ==aa)
                  {
                     numround[aa]++;
                  }
                }
            }
            if( numround[current_group -1] == 1 )
            {
               numgroup--; 
            }
         }

         if( first_end_flag == 1 && second_end_flag == 0)
	 {
	    end_flag++;
	 }
	 if( first_end_flag == 0 && second_end_flag == 1)
	 {
	    end_flag++;
	 }
	 edge_count++;
      }
	first_edge=last_edge;
     //end of jj for loop 
      if(modified == 0) current_group++;             
   }  
*/
//end of ii for loop 
// END of spliting into groups incase of deselection 

// jeff

edge_count=0;

/* ------------- IMPORTANT ----------------
   sometimes there can be group without any edges. check for this has to be implemented . you can generate this by selecting two edges and slecting another edge this is connected to the second edge. then deselect the second edge 
*/
for(i=0;i<numgroup;i++)
{
//printf(" without - %d \n",numround[i]);
}
/*
  for(jj=0;jj<numgroup;jj++)
  {
     numround[jj]=0;
     for( ii=0;ii<num_edges;ii++)
     {
        if(me->group_edge_info[ii].group_id == jj)
        {
           numround[jj]++;
        } 
     }
  }
*/

  /* this for loop is to remove any group with zero edges.
     tmp_group is used since there could be consecutive zero groups in the 
     end of the chain list 
  */
for(i=0;i<numgroup;i++)
{
//printf("bef zero edges  numround[%d] - %d \n",i,numround[i]);
}
  tmp_numgroup = numgroup;

  for(jj=0;jj<tmp_numgroup;jj++)
  {
     if( numround[jj] == 0 && ( jj != tmp_numgroup) ) 
     {
       for(ii=jj;ii<numgroup;ii++)
       {
          numround[jj]=numround[jj+1];

       }
       numgroup--;
     }
     else
         numround[jj]=numround[jj]; 
//printf(" numgroup - %d  numround-jj - %d\n",numgroup,numround[jj]);
  }
for(i=0;i<numgroup;i++)
{
//printf(" before move  numround[%d] - %d \n",i,numround[i]);
}
/*  1008 jeff  to move the edges of a group together  */
for(jj=0;jj<numgroup;jj++)
{
first_group_edge=0;
     for( ii=0;ii<num_edges;ii++)
     {
        if(me->group_edge_info[ii].group_id == jj )
        {
          
          if( (ii != (prev_edge +1)) && ( first_group_edge == 1) )
          {
             tmp_rnd_edges[0]=rnd_edges[ii];
             tmp_group=me->group_edge_info[ii].group_id;
             for(kk=ii ;kk>prev_edge+1;kk--)
             {
             rnd_edges[kk]=rnd_edges[kk-1];
             me->group_edge_info[kk].group_id =
                                            me->group_edge_info[kk-1].group_id;
             
             }
             rnd_edges[prev_edge+1]=tmp_rnd_edges[0];
             me->group_edge_info[prev_edge+1].group_id =tmp_group;
             prev_edge = prev_edge +1;
           //  ii++;
          }
          else 
              prev_edge=ii;
            
          if(first_group_edge == 0) first_group_edge=1;
        }
     }
  }


// just a check for rnd71
for(jj=0;jj<numgroup;jj++)
{
}
//if(numgroup != 0) numgroup--;

/*

wrapup :

if(start_pt)
   om$dealloc(ptr=start_pt);
  if(end_pt)
   om$dealloc(ptr=end_pt);
  if(start_pt1)
   om$dealloc(ptr=start_pt1);
  if(end_pt1)
   om$dealloc(ptr=end_pt1);
*/
for(i=0;i<numgroup;i++)
{
//printf(" !!  numround[i] - %d \n",numround[i]);
}
tmp_count=0;
for(i=0;i<numgroup;i++)
        {
                for(j=0;j<numround[i];j++)
                {
                      me->group_edge_info[tmp_count].group_id = i;
                        tmp_count++;
                }

        }


tmp_grp_count =0;
	for(i=0;i<numgroup;i++)
	{
//printf(" i= %d  , numgroup = %d  numround - %d\n",i,numgroup,numround[i]);
		if( i == (numgroup )) 
		{
			grp_num_edges =   numround[i];
		}
		else 
		{
			grp_num_edges = numround[i];
		}

		for(j=0;j<grp_num_edges;j++)
		{
			grp_rnd_edges[j]= rnd_edges[tmp_grp_count];
			tmp_grp_count++;
		}
//printf(" before EMround_chamfer_edges \n");
for(j=0;j<num_edges;j++)
{
//printf(" ID - %d \n",grp_rnd_edges[j].boundary_id.objid);
}
         	OM_stat = EMround_chamfer_edges (&msg, 
                                 local_options,
                                 &ME.COroot->ModuleInfo,
                                 grp_num_edges,
                                 grp_rnd_edges,
                                 &round_error,
				 &me->rnd_construct_id);
//printf(" after EMround_chamfer_edges \n"); 
	}
}
else
{
//printf(" before EMround_chamfer_edges \n");
for(i=0;i<num_edges;i++)
{
//printf(" ID - %d \n",rnd_edges[i].boundary_id.objid);
}
	OM_stat = EMround_chamfer_edges (&msg,
                                 local_options,
                                 &ME.COroot->ModuleInfo,
                                 num_edges,
                                 rnd_edges,
                                 &round_error,
                                 &me->rnd_construct_id);
//printf(" after EMround_chamfer_edges \n");
}

/* ---------------------------- jeff ---------------------------- */

	me->uniformval = 2.0;
         ems_do_print_error_messages = TRUE;
        }

        if (IGEstop()) msg = EMS_I_Interrupt;
       }

      if (msg == EMS_I_Interrupt)
      {
        if (me->rnd_construct_id.objid != NULL_OBJID)
        {
	 /* Replaced GRdelete by Root.delete because the former causes
	    ripple effects on unsuspecting dependents. The dependency could
	    have been already established before rounding was
	    interrupted.
	    SM 10/12/92
	 */
	 /**************
          OM_stat = om$send(msg = message  GRgraphics.GRdelete(&msg,
                                 &ME.COroot->ModuleInfo),
                           targetid = me->rnd_construct_id.objid,
                           targetos = osnum);
         ***************/
          OM_stat = om$send(msg = message  Root.delete(TRUE), 
                    targetid = me->rnd_construct_id.objid, targetos = osnum);

             ERROR(OM_stat, msg, "GRdelete", wrapup);      
        }
        ex$message(msgnumb = EMS_I_Intrupt);
      	me->numed = 0;
	me->numtmped = me->num_bkp_entries = 0;
	me->numtmp_chain_links = 0;
	me->valid_inputdata = FALSE;
        ex$message(msgnumb = EMS_S_ClearStatusField);
      	ME.super_cmd->state = EDGE_SEL_OPT;
      	break;
      }

      ex$message(msgnumb = EMS_S_ClearStatusField);
      if (msg == EMS_I_RndGrExit || (!(1 & msg & OM_stat)))
      {
        ex$message(msgnumb = EMS_E_RndOprnFald)
	sleep(1);
      	me->numed = 0;
      	me->num_vertex = 0;
	me->numtmped = me->num_bkp_entries = 0;
	for(ii = 0; ii < me->numtmp_chain_links ; ii++ )
	  me->var_chain_edges[ii].numedges = 0;
	me->numtmp_chain_links = 0;
	me->valid_inputdata = FALSE;
      	ME.super_cmd->state = EDGE_SEL_OPT;
      	break;
     }

       ex$message(msgnumb = EMS_P_ClearPromptField);
 
       ME.super_cmd->state = UNDO;
       break;
   }

   /* Undo the round operation */

   case UNDO:
    {
      GRobjid    *display_ids = NULL;  /*DECL*/ 
      IGRint     display_count = 0;
      IGRushort  deactivate_option;    

      ex$message(msgnumb = EMS_P_AccwAnyEventBackupForUndo);
//printf("  UNDO \n");
      stat_func = co$getevent (msg = &msg,
        	event_mask = GRm_DATA | GRm_BACK_UP,
        	response = response,
        	response_data = response_data,
        	event = &me->event);

      ex$message(msgnumb = EMS_P_ClearPromptField);
      if (stat_func == FALSE) {
        	ex$message(msgnumb = EMS_E_FailInputProcExit);
        	*response = TERMINATE;
        	goto wrapup;
      }
      if (msg == GRw_no_value) {
        	ex$message(msgnumb = EMS_I_00006);
        	goto wrapup;
      }
      if (msg != MSSUCC) {
        goto wrapup;
      }
//printf(" switch \n");
      switch(me->event.response)
       {
        case EX_DATA:
           me->numed = 0;
           me->num_vertex = 0;
           ME.super_cmd->state = EDGE_SEL_OPT;
           goto wrapup;

        case EX_BACK_UP:

        /*Undo the rnd operation.*/
        deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY | EMS_DELETE_DPR;
        {
          IGRint invoke_cnt=0;
          OM_stat = om$send(msg = message EMSdpr.EMundo(&msg,
                                  &deactivate_option, &me->ModuleInfo,
                                  NULL, NULL, NULL,
                                  &display_ids, &display_count, &invoke_cnt),
                            targetid = me->rnd_construct_id.objid,
                            targetos = osnum);
        }
        ERROR(OM_stat, msg, "undo", wrapup);
 
        OM_stat = om$send (mode = OM_e_wrt_parent,
                           msg = message ECround.wakeup(NULL),
                  targetid = my_id );
        ERROR(OM_stat, msg, "ECround.wakeup", wrapup);

	if(me->edge_type == EDGE_VERTEX_TYPE)
   		ME.super_cmd->state = EDGE_VERTEX;
	else if(me->edge_type == CHAIN_TYPE)
   		ME.super_cmd->state = CHAIN;
	else if(me->edge_type == SURFACE_LOOP_TYPE)
   		ME.super_cmd->state = SURFACE_LOOP;
	else if(me->edge_type == FILLET_TYPE || me->edge_type == RADII_TYPE)
   		ME.super_cmd->state = FILLET_RADII;
	me->numtmped = pre_tmp_ed;
/*
	me->numed = me->numed - me->numtmped;
*/
	me->num_bkp_entries = pre_bkp_entries;
        dp$erase_hilite(msg = &msg);
//printf(" EFrestore_hilite_of_edges \n");
	  EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
        break;

        default:
       		goto wrapup;

     }
   }   /* UNDO */
    
   default:
     
     goto wrapup;
   } /* ME.super_cmd->state */

  }
  while (TRUE);

 wrapup: 

//printf(" wrapup \n");
  return(OM_stat);
}

/* 
DESCRIPTION
   	This function parses the input character to permit changing form 
	options. Cannot select option to do variable radius rounding when the 
	edge selection type is all convex or all concave. The opposite also 
	applies, i.e cannot select all convex or all concave edge types when 
	variable radius round is selected.

OPTIONS
	No options supported

ALGORITHM
	The character passed is checked against the valid types & if it's
	found, the rounding options are changed (edge selection type or fillet
	type or edge selection/deselection)

NOTES
	If the fillet type is varying & select mode is current then change 
	fillet option & automatically change edge selection option to 
	edge/vertex type.
*/

void EFparse_keyin(key_char, selection, edge_type, fillet_type, ret_type,st_val)
IGRchar 	*key_char;
IGRboolean  *selection;
IGRint 	*edge_type, *fillet_type, *ret_type;
IGRdouble *st_val;
{
	IGRchar *ch=NULL;
	IGRdouble chtol;
	IGRlong msg;

	BSEXTRACTPAR(&msg, BSTOLCHRDHT, chtol);
	*ret_type = 0; *st_val = 0;

	/* The user would have typed zero - Invalid data */

	if(isdigit(key_char[0]) || key_char[0] == '.') {
	    for(ch = key_char; *ch && *ch != '/' ; ch++);
	    if(*ch == '/') {
		ch++;
		*st_val = atof(key_char)/atof(ch);
	    }
	    else 
	      *st_val = atof(key_char);
	    if(*st_val < 0 || (*st_val < 10 * chtol)) {
		ex$message(msgnumb = EMS_S_RadValGreCht)
		*ret_type = 3;
	    }
            else *ret_type = 1;
		return;
	}
	key_char[0] = toupper(key_char[0]);
	if(key_char[0] == 'S') { 
          if(*fillet_type == VARYING_TYPE && 
  	     (*edge_type == FILLET_TYPE || *edge_type == RADII_TYPE))
               *ret_type = 2;	
	  else 
		*selection = TRUE;	
	}
	else if(key_char[0] == 'D') 
		*selection = FALSE;	
	else if(key_char[0] == 'N') 
		*edge_type = CHAIN_TYPE;
	else if(key_char[0] == 'E') 
		*edge_type = EDGE_VERTEX_TYPE;
	else if(key_char[0] == 'L') 
		*edge_type = SURFACE_LOOP_TYPE;
	else if(key_char[0] == 'F' ) {
		if(*selection == TRUE && *fillet_type == VARYING_TYPE)
			*ret_type = 2;
		else 
		*edge_type = FILLET_TYPE;
	}
	else if(key_char[0] == 'R' ) {
		if(*selection == TRUE && *fillet_type == VARYING_TYPE) 
			*ret_type = 2;
                else
		*edge_type = RADII_TYPE;
	}
	else if(key_char[0] == 'C') 
		*fillet_type = CONSTANT_TYPE;
	else if(key_char[0] == 'V') {
	    *fillet_type = VARYING_TYPE;
	    if((*edge_type == FILLET_TYPE || *edge_type == RADII_TYPE)
		&& *selection == TRUE)
		*edge_type = EDGE_VERTEX_TYPE;
	}
	else { /* None of the valid options but it's still a character input */
		*ret_type = 2;
	}
		return;
}



void EFcheck_strlen(key_char,st_len)
IGRchar *key_char;
IGRint *st_len;
{
	IGRint ii,beg,end1;
	*st_len = 0;
	if(isdigit(key_char[0]) || key_char[0] == '.') {
	  *st_len = 3;
          goto ret_end;
	}
	if(strlen(key_char) == 0) goto ret_end;
	beg = end1 = 0;
        for(ii =  0 ;ii < strlen(key_char); ii++)
          if(isalpha(key_char[ii])) { beg = ii;break;}

        for(ii = strlen(key_char)-1; ii >= 0 ;ii--)
          if(isalpha(key_char[ii])) {
                break;
          }
	  else end1++ ;
	if(strlen(key_char)-beg-end1 == 0) goto ret_end;
	if(strlen(key_char)-beg-end1 == 1) {*st_len = 1 ;goto ret_end;}
	*st_len = 2;
ret_end:
return;
	
}
void EFsubparse_keyin(key_char,ret_type)
IGRchar  *key_char;
IGRint 	 *ret_type;
{
	*ret_type = 0;	
	key_char[0] = toupper(key_char[0]);
        if(key_char[0] == 'S' || key_char[0] == 'D'
         || key_char[0] == 'C'
         || key_char[0] == 'E'
         || key_char[0] == 'L'
         || key_char[0] == 'F' 
         || key_char[0] == 'A' 
         || key_char[0] == 'N'
         || key_char[0] == 'V') 
	  *ret_type = 1;
	return;
           
}

/*
DESCRIPTION
	This functions parses the edge coming in with the edges in the 
	temporary/permanent list depending on either selection/deselection
	option.  

OPTIONS
	No options supported

ALGORITHM
	If the select mode is on, the array of edges coming in is checked to 
	see if it's already in permanent/temporary list. If it's in one of the 
	lists it's not considered (which means it's located) else it's taken 
	to be a valid edge.
	Similarly for deselecting edges it's checked against permanent list.
	If it's found in permanent list it is a valid edge (i.e the edge can 
	be selected). If it's found in temporary list it means that the edge 
	is already deselected & hence ignored.
*/

IGRlong EFparse_edges(msg, selection, edge_loc, tmp_edge_loc,
		num_ed, num_tmp_ed, act_edge_loc, os_num, act_num_ed,bnd_code)
IGRlong 	*msg;
IGRboolean 	*selection;
GRobjid 	edge_loc[];
GRobjid 	tmp_edge_loc[];
IGRint 		num_ed;
IGRint 		num_tmp_ed;
GRobjid 	act_edge_loc[];
OMuword 	os_num;
IGRint 		*act_num_ed;
IGRushort	bnd_code[];
{
	IGRlong sts = OM_S_SUCCESS;
	IGRint 	i, j, temp, f_co, count;
	GRobjid *tmp_ed = NULL;
	IGRboolean found;
	OM_S_CHANSELECT	chan_to_common_edge;
	OM_S_OBJECT_LINKAGE comm_edge;
	*msg = EMS_S_Success;
	
	f_co = *act_num_ed;
	sts = EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);
	
	temp = 0;
	tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * f_co);
	for(i = 0; i < f_co; i++) {
	    found = FALSE;
            sts = om$get_channel_objects(osnum = os_num,
               		objid = act_edge_loc[i],
               		p_chanselect = &chan_to_common_edge,
               		list = &comm_edge,
               		size = 1,
               		count = (OMuint *)&count);

            EMomerr_hndlr ( sts, ret_end, "get_channel_objects");

	    if(*selection) {
		for(j = 0; j < num_ed; j++) {
                    if(bnd_code[j] & EMSrnd_mark_ed_deleted)
                      continue;
		    if((IF_EQ_OBJID(act_edge_loc[i], edge_loc[j])) ||
		      (IF_EQ_OBJID(comm_edge.S_objid, edge_loc[j]))) {
			    act_edge_loc[i] = NULL_OBJID;
			    found = TRUE;
			    break;
		    }
		}
		for(j = 0; j < num_tmp_ed && !found; j++) {
		    if((IF_EQ_OBJID(act_edge_loc[i], tmp_edge_loc[j])) ||
		    (IF_EQ_OBJID(comm_edge.S_objid, tmp_edge_loc[j]))) { 
			    act_edge_loc[i] = NULL_OBJID;
			    found = TRUE;
			    break;
		    }
		}
		if(!found) {
		    tmp_ed[temp] = act_edge_loc[i];
		    temp++;
		}
	    }
	    else {
		for(j = 0; j < num_tmp_ed; j++) {
		    if((IF_EQ_OBJID(act_edge_loc[i], tmp_edge_loc[j])) ||
		      (IF_EQ_OBJID(comm_edge.S_objid, tmp_edge_loc[j]))) {
			    found = TRUE;
			    break;
		    }
		}
		for(j = 0; j < num_ed && !found; j++) {
                    if(bnd_code[j] & EMSrnd_mark_ed_deleted) continue;
		    if((IF_EQ_OBJID(act_edge_loc[i], edge_loc[j])) ||
		      (IF_EQ_OBJID(comm_edge.S_objid, edge_loc[j]))) {
			    tmp_ed[temp] = act_edge_loc[i];
			    temp++;
			    break;
		    }
		}
	    }
	}
	for(i = 0; i < temp; i++) 
		act_edge_loc[i] = tmp_ed[i];
	f_co = temp;
	*act_num_ed = f_co;

ret_end:
	if(tmp_ed) stackfree (ptr = tmp_ed);
	EMWRAPUP(*msg, sts, "EFparse edges");
	return(sts);
}

/*
DESCRIPTION
	This functions returns the actual edges selected for rounding. The
	edges which are deselected are removed from the list of edges earlier
	selected. The data associated with the edge (like radius etc.) is
	likewise removed 

OPTIONS
	No options supported

ALGORITHM
	Each edge of the temporary list array is taken & its' common edge
	obtained. If one of these edges is present in the permanent list of
	edges it's marked as removed from the permanent list.
        The next edge that follows,if it is the same group as the deleted
	one , the bound code is propagated
*/


IGRlong EFget_actual_edges_list(msg, edge_loc, tmp_edge_loc,
		num_ed, num_tmp_ed, os_num,bnd_code)
IGRlong 	*msg;
GRobjid 	edge_loc[];
GRobjid 	tmp_edge_loc[];
IGRint 		num_ed;
IGRint 		num_tmp_ed;
OMuword 	os_num;
IGRushort	bnd_code[];
{
	IGRlong sts = OM_S_SUCCESS;
	IGRint 	ii,i, j, count;
	OM_S_CHANSELECT	chan_to_common_edge;
	OM_S_OBJECT_LINKAGE comm_edge;

	*msg = EMS_S_Success;
	sts = EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);
	for(i = 0; i < num_tmp_ed; i++) {
            sts = om$get_channel_objects(
           		osnum = os_num,
               		objid = tmp_edge_loc[i],
               		p_chanselect = &chan_to_common_edge,
               		list = &comm_edge,
               		size = 1,
               		count = (OMuint *)&count);

            EMomerr_hndlr ( sts, ret_end, "get_channel_objects");

	    for(j = 0; j < num_ed; j++) {
		if((IF_EQ_OBJID(tmp_edge_loc[i], edge_loc[j])) ||
		   (IF_EQ_OBJID(comm_edge.S_objid, edge_loc[j]))) {

                     if(bnd_code[j] & EMSrnd_mark_ed_deleted) continue;

		      bnd_code[j] |= EMSrnd_mark_ed_deleted;

		     if(bnd_code[j] & EMSrnd_input_ed_grp_start) {
			 for(ii = j+1 ; ii < num_ed; ii++) {
                           if(bnd_code[ii] & EMSrnd_mark_ed_deleted) continue;
           	           bnd_code[ii] = 0;
                           bnd_code[ii] = EMSrnd_input_ed_grp_start;
                           break;
                         }
                     }
		    	break;
		}
	    }
	}


ret_end:
	return(sts);
}


/* 
	If one edge is in the chain, then a shift by one
	chain is to be made
	
	Recomputes the radius of each edge if the edge to
	be deselected is the intermediate link which results in
	formation of 2  new chains.
	
*/

#define ONE_EDGE 1
#define TWO_EDGE 2

void  EFrecompute_chains_radius(ModuleInfo,numtmped,num_link,chain_edges
			,tmp_obj,perm_obj,numed,edg_eve,endedg_eve,
                        bound_code)
struct GRmd_env ModuleInfo;
IGRint	numtmped;
IGRint  *num_link;
struct chain_edge_data *chain_edges;
GRobjid *tmp_obj;
GRobjid *perm_obj;
IGRint  numed;
struct GRevent *edg_eve;
struct GRevent *endedg_eve;
IGRushort *bound_code;
{

	IGRint num_links,tmp,tempp,temp,ii,jj,kk;
	IGRlong msg,sts;
	IGRdouble *rad_val;

	num_links = *num_link;
        for(ii = 0;ii < numtmped ; ii++) { 
         for(jj= 0; jj< num_links;jj++) {  
          for(kk=0; kk < chain_edges[jj].numedges;kk++) { 
	    if(chain_edges[jj].edge_id[kk] == tmp_obj[ii]){
	      switch(chain_edges[jj].numedges) {
		case ONE_EDGE :
		 {
		  for(temp = jj;temp < num_links;temp++){
	            chain_edges[temp].numedges= chain_edges[temp+1].numedges;
		    chain_edges[temp].chain_var_start=
				    chain_edges[temp+1].chain_var_start;
		    chain_edges[temp].chain_var_end=
				    chain_edges[temp+1].chain_var_end;
                    EFcreate_space_chain_edges(chain_edges[temp].numedges,
                       	    chain_edges[temp+1].numedges,
                       	    (GRobjid **)&chain_edges[temp].edge_id);
		    for(tmp = 0; tmp<chain_edges[temp+1].numedges; tmp++)
		       chain_edges[temp].edge_id[tmp]=
				   chain_edges[temp+1].edge_id[tmp];
	          }
		  if(num_links == 1) 
		    chain_edges[jj].numedges =0;
		  num_links--;
		  break;
		 }
		case TWO_EDGE :
		 {
		  for(tmp=0;tmp< numed;tmp++)
                    {
                    if(bound_code[tmp] & EMSrnd_mark_ed_deleted) continue;
	            if(tmp_obj[ii] == perm_obj[tmp]) 
                      {
		      EFchk_objid(tmp_obj[ii],chain_edges[jj].edge_id,
				   &chain_edges[jj].numedges);
                      bound_code[tmp] = 0;
                      bound_code[tmp] = EMSrnd_input_ed_grp_start;
		      edg_eve[tmp]= chain_edges[jj].chain_var_start;
		      endedg_eve[tmp]=chain_edges[jj].chain_var_end;
                      break;
		      }
                    }
		  break;
		 }
		default:
		 {
		  if(kk == 0 || (kk == (chain_edges[jj].numedges -1))) {
		    if(kk == 0)
		      sts =EFchk_objid( tmp_obj[ii], chain_edges[jj].edge_id,
				  &chain_edges[jj].numedges); 
	          else 
		    chain_edges[jj].numedges--;
		  rad_val = 
			  (IGRdouble *)stackalloc(sizeof(IGRdouble)*
				(1+chain_edges[jj].numedges));

		  if(chain_edges[jj].numedges >= 2) 
		     sts = EFchain_edge_rad_comp(&msg, ModuleInfo,
		             chain_edges[jj].numedges, chain_edges[jj].edge_id,
		             rad_val,
                	     chain_edges[jj].chain_var_start.event.value,
                	     chain_edges[jj].chain_var_end.event.value);
		  else 
                    {
		    rad_val[0]=chain_edges[jj].chain_var_start.event.value;
	            rad_val[1]=chain_edges[jj].chain_var_end.event.value;
		    }
		  for(temp=0;temp<chain_edges[jj].numedges;temp++)
		    for(tmp=0;tmp<numed;tmp++)
                      {
                      if(bound_code[tmp] & EMSrnd_mark_ed_deleted) continue;
		      if(perm_obj[tmp] == chain_edges[jj].edge_id[temp])
                        {
                        if(kk == 0 && temp == 0)
                          {
                          bound_code[tmp]=0;
                          bound_code[tmp] = EMSrnd_input_ed_grp_start;
                          }
			edg_eve[tmp].event.value =rad_val[temp];
			endedg_eve[tmp].event.value=rad_val[temp+1];
			break;
                        }
		      }
		  break;
		} /* kk=0 or last */
		 /* intermediate link is deselected */
		tmp = chain_edges[jj].numedges - kk - 1;
	        chain_edges[num_links].numedges=0;
                EFcreate_space_chain_edges( chain_edges[num_links].numedges,
                        tmp, (GRobjid **)&chain_edges[num_links].edge_id);
		num_links++;
		chain_edges[num_links - 1].numedges = tmp;
                chain_edges[num_links - 1].chain_var_end = 
			chain_edges[jj].chain_var_end;

		for(tempp=0; tempp< tmp;tempp++)
                  chain_edges[num_links - 1].edge_id[tempp] = 
		    chain_edges[num_links - 2].edge_id[kk + tempp + 1];
	        for(tmp=0;tmp< numed;tmp++)
                  if(tmp_obj[ii] == perm_obj[tmp]) {
                     chain_edges[num_links-1].chain_var_start = endedg_eve[tmp];
	             chain_edges[jj].chain_var_end= edg_eve[tmp];
		     break;
                  }
	      
	        chain_edges[jj].numedges = kk;

		/*recal rad values for old chain */
	        rad_val =
                       (IGRdouble *)stackalloc(sizeof(IGRdouble)*
                                (1+chain_edges[jj].numedges));

                if(chain_edges[jj].numedges >= 2)
                   sts = EFchain_edge_rad_comp(&msg, ModuleInfo,
                           chain_edges[jj].numedges, chain_edges[jj].edge_id,
			   rad_val,chain_edges[jj].chain_var_start.event.value,
                           chain_edges[jj].chain_var_end.event.value);
                else {
                  rad_val[0]= chain_edges[jj].chain_var_start.event.value;
                  rad_val[1]= chain_edges[jj].chain_var_end.event.value;
                }
		for(temp=0; temp<chain_edges[jj].numedges;temp++)
                  for(tmp=0;tmp<numed;tmp++)
                    if(perm_obj[tmp] == chain_edges[jj].edge_id[temp]){
                       edg_eve[tmp].event.value = rad_val[temp];
                       endedg_eve[tmp].event.value= rad_val[temp+1];
		       break;
                    }
		/* cal radii values for new chain */
		temp= num_links - 1;
		rad_val =
                       (IGRdouble *)stackalloc(sizeof(IGRdouble)* 
			(1+ chain_edges[temp].numedges));
                if(chain_edges[temp].numedges >= 2)
                   sts =EFchain_edge_rad_comp(&msg,ModuleInfo,
                          chain_edges[temp].numedges,
                          chain_edges[temp].edge_id,rad_val,
			  chain_edges[temp].chain_var_start.event.value,
                          chain_edges[temp].chain_var_end.event.value);
                else {
                  rad_val[0]= chain_edges[temp].chain_var_start.event.value;
                  rad_val[1]= chain_edges[temp].chain_var_end.event.value;
                }
                for(tempp=0; tempp<chain_edges[temp].numedges;tempp++)
                  for(tmp = 0;tmp < numed; tmp++)
                    {
                    if(bound_code[tmp] & EMSrnd_mark_ed_deleted) continue;
                    if(perm_obj[tmp] == chain_edges[temp].edge_id[tempp])
                      {
                      if(tempp == 0)
                        {
                        bound_code[tmp]=0;
                        bound_code[tmp] = EMSrnd_input_ed_grp_start;
                        }
                      edg_eve[tmp].event.value = rad_val[tempp];
                      endedg_eve[tmp].event.value= rad_val[tempp+1];
		      break;
                      }
                    }

		break;
	       } /* default */

             } /* switch */
	    break; 
	   } /* end of EQ_objid */
	  } /* kk loop */
	 } /* jj loop */
	} /* ii loop i.e numtmp */
	*num_link = num_links;
}
IGRboolean EFedgeprocessed(int count,int edge,int * edge_array)
{

	int i;
        IGRboolean flag;	
	for(i=0;i<count;i++)
	{
		if( edge == edge_array[i])
			flag=TRUE;
		else
			flag=FALSE;
	}
	return(flag);
}
/*
EFisFreeEdge(int edge_num)
{
		   first_end_flag=0;
		   second_end_flag=0;
   		   sts = om$send (msg = message EMSedge.EMxyz_endpt(&msg,0,
                           &ME.COroot->ModuleInfo.md_env,
                           0,0,start_pt,end_pt,0),
                           targetid = rnd_edges[edge_count].boundary_id.objid,
                           targetos = rnd_edges[edge_count].boundary_id.osnum);
                   for( kk =0; kk<num_edges;kk++)
                   {
                                dist=0.0;
                                dist1=0.0;

                      if(!( rnd_edges[edge_count].boundary_id.objid ==
                                 rnd_edges[kk].boundary_id.objid
                                ) )
                      {
                         sts = om$send (msg =
                                        message EMSedge.EMxyz_endpt(&msg,NULL,
                                        &ME.COroot->ModuleInfo.md_env,
                                        NULL,NULL,start_pt1,end_pt1,NULL),
                                     targetid = rnd_edges[kk].boundary_id.objid,
                                     targetos = rnd_edges[kk].boundary_id.osnum
                                        );

                          BSEXTRACTPAR(&bsrc,BSTOLCHRDHT,xyztol);
                          sqtol=(xyztol)*(xyztol);
                          ref_pt[0]=start_pt[0];
                          ref_pt[1]=start_pt[1];
                          ref_pt[2]=start_pt[2];

                          for(i=0;i<2;i++)
                          {
                             dist = BSdistptpt(&bsrc,ref_pt,start_pt1);
                             dist1 = BSdistptpt(&bsrc,ref_pt,end_pt1);

			     if( dist < sqtol)
 			     {
  				first_end_flag=1;

			     }
			     if(dist1 < sqtol)
			     {
  				second_end_flag=1;
			     }

			  }

                          ref_pt[0]=end_pt[0];
                          ref_pt[1]=end_pt[1];
                          ref_pt[2]=end_pt[2];
                           
                       }
                     }
                     if( first_end_flag == 0 && second_end_flag == 0)
                     {
                     }

}
*/
end implementation ECround;
