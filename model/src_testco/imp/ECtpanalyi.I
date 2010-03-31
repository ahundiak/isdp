/*
Description

    This file contains method implementations and functions for the
    command "Analyze Adjacency between Surfaces".
*/
class implementation ECtpanaly;

# include <stdio.h>
# include <alloca.h>
# include "EMSmsgdef.h"
# include "griomacros.h"
# include "exdef.h"
# include "igr.h"
# include "go.h"
# include "dp.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
# include "grmsg.h"
# include "emserr.h"
# include "dpmacros.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "ECmsg.h"
# include "exmacros.h"
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */
#include "EMSaction.h"  /* Structure definition for select handler */
#include "emsdef.h"
#include "EMSdpb.h"
#include "OMprimitives.h"
#include "bsparameters.h"
#include "bserr.h"

#include "TOinclude.h"
#include "TOdsl.h"
#include "TOtopology.h"
#include "TOproto_ds.h"
#include "TOproto_ta.h"
#include "ECmsg.h"


#define MESSAGE1 "Analyze Adjacency Between Surfaces"
#define MESSAGE_KEY1  EM_M_AnalyzABS

#define MESSAGE2 "All surfaces removed"
#define MESSAGE_KEY2  EMS_E_AllSR

#define MESSAGE3 "Accept with next surface to remove/Reject"
#define MESSAGE_KEY3  EMS_P_AccNR

#define MESSAGE4  "Identify surface to remove/Move on"
#define MESSAGE_KEY4 EMS_P_IdSR

#define ANG_DEFAULT 3.1415926/180.

from EMSsfdpr           import EMgetsolidclass;


extern OMuword  OPP_EMSsubbs_class_id,
                OPP_EMSsurface_class_id,
                OPP_EMSsolid_class_id,
                OPP_GRvg_class_id,
                OPP_GRbcsubbc_class_id,
                OPP_EMSedge_class_id;
  
%safe
/*
** default parameter block
** this block is used, when the command is initialized
*/
static struct TOPO_param topo_default_param = {
        /* option */     TOPO_DO_OUTER_BOUNDARY |
                         TOPO_MO_DISTANCE       |
                         TOPO_DO_INTERIOR_OF_CO,
        /* layer    */ {1000,1000,1000,1000,1000},
        /* color    */ {   8,  2,  3,  5, 10},
        /* weight   */ {   2,  2,  2,  2,  2},
        /* style    */ {   0,  0,  0,  0,  0},

        /* topology_tolerance */           0.1,
        /* diagnosis_distance_tolerance */ 0.01,
        /* diagnosis_angle_tolerance */    ANG_DEFAULT,
        /* diagnosis_radius_tolerance */   0.1,
        /* number_of_diagnosis_points */   5,

        /* distance */ 0.01,
        /* normal   */ ANG_DEFAULT,
        /* radius   */ 0.1,

        /* number_of_edge_match_points */ 20,

        /* edge_layer    */ {1000,1000,1000},
        /* edge_color    */ {   2,  3,  5},
        /* edge_weight   */ {   5,  5,  5},

        /* file_name*/ NULL,
        /* header_line*/ NULL,
        
        /* max_dist_viol */ 0.0,
        /* loc_dist_viol */ {0.0 ,0.0, 0.0},
        /* max_norm_viol */ 0.0,
        /* loc_norm_viol */ {0.0 ,0.0, 0.0},
        /* max_radi_viol */ 0.0,
        /* loc_radi_viol */ {0.0 ,0.0, 0.0},

        /* form_state */ FORM_STATE_NO,

        /* temporary_objects */ NULL,
        /* temporary_points */ NULL,
};
%endsafe


/*
** display_command_name
*/
static void display_command_name(int set)
{
   if(set)
   {
     ex$message(field = MESSAGE_FIELD,
		/* in_buff = MESSAGE1,.. "Analyze Adjacency Between Surfaces" */
                msgnumb = MESSAGE_KEY1
		);
   }
   else
   {
     ex$message(field = MESSAGE_FIELD,
		in_buff = ""
		);
   }
}



/*
** add_surface
**
** add a selected surface to list of all surfaces
** set recalculate, because we have to recalculate the
** topology
*/
static int add_surface(int *size, int *n, struct GRlc_info **s_list, 
	struct GRlc_info *new,
	int *recalculate)
{
   int i;

   for(i=0;i< *n;++i)
   if((*s_list)[i].located_obj.objid == new->located_obj.objid && 
      (*s_list)[i].located_obj.osnum == new->located_obj.osnum)
   {
#ifdef DBG
	 printf("Object %d already in list\n",new->located_obj.objid);
#endif
	return -2;
   }

   if(*size == 0)
   {
      *size = 100;
      *s_list = (struct GRlc_info *) malloc(sizeof(struct GRlc_info) * *size);
      if(*s_list == NULL) return -1;
   }
   else if( *n + 1 >= *size )
   {
      *size *= 2;
      *s_list = (struct GRlc_info *) 
		realloc(*s_list, sizeof(struct GRlc_info) * *size);
      if(*s_list == NULL) return -1;
   }

   memcpy( &(*s_list)[ *n ] , new, sizeof(struct GRlc_info) );
   ++ *n;
   
   *recalculate = TRUE;

/* for debug
   printf("There are %d surfaces located\n",*n);
   for(i=0;i< *n;++i)
   printf("%d, ",(*s_list)[i].located_obj.objid);
   printf("\n");
*/
   return 0;
}


/*
** delete_surface
**
** remove surface from list of selected surfaces
** set recalculate
*/
/*ARGSUSED*/
static int delete_surface(
	struct topology *topo,int *size, int *n, struct GRlc_info **s_list, 
	struct GRlc_info *new,
	int *recalculate,
	int *d_size, int *d_n, struct GRlc_info **d_list)
{
   int i;
#ifdef NOT_USED
   IGRlong stat_OM;
#endif
   *size = *size;
   for(i=0;i< *n;++i)
   if((*s_list)[i].located_obj.objid == new->located_obj.objid && 
      (*s_list)[i].located_obj.osnum == new->located_obj.osnum)
   {
	*recalculate = TRUE;

        if(topo->pa.temporary_objects->displayed_object.objid != NULL)
	{
	   /* add the deleted object to the list of deleted objects,
           ** so that this object may be redrawn, when the
           ** temporary object is deleted 
           */
           if(*d_size == 0)
           {
              *d_size = 100;
              *d_list = (struct GRlc_info *) 
		malloc(sizeof(struct GRlc_info) * *d_size);
              if(*d_list == NULL) return -1;
           }
           else if( *d_n + 1 >= *d_size )
           {
              *d_size *= 2;
              *d_list = (struct GRlc_info *) 
		        realloc(*d_list, sizeof(struct GRlc_info) * *d_size);
              if(*d_list == NULL) return -1;
           }

           memcpy( &(*d_list)[ *d_n ],&(*s_list)[i],sizeof(struct GRlc_info) );
           ++ *d_n;
		
        }

        (*s_list)[i] = (*s_list)[-- *n];

	return 0;
   }

   /* fprintf(stderr,"ERROR: objid %d not found\n", new->located_obj.objid); */
   return -1;
}

/*
** highlight_surfaces
**
** this method highlights all selected surfaces
** or redisplayes them
*/
method highlight_surfaces(int mode; int also_deleted)
{
  int   ii;
  long  loc_msg = EMS_S_Success, sts = OM_S_SUCCESS;

   /* printf("highlight %d elements\n",me->n_surface_list); */

  for(ii = 0; ii < me->n_surface_list; ii ++)
  {
    IGRlong     loc_mx_type;
    IGRmatrix   *loc_mx_ptr;

    loc_mx_type = (IGRlong) me->surface_list[ii].
                            module_info.md_env.matrix_type;
    loc_mx_ptr = &me->surface_list[ii].
                            module_info.md_env.matrix;

    sts = dp$display(msg = &loc_msg,
                     mtx_type = &loc_mx_type,
                     matrix = &loc_mx_ptr,
		     oids = &me->surface_list[ii].located_obj,
                     mode = mode);
    if(! (1 & sts & loc_msg)) goto wrapup;
  }

  if(! also_deleted) goto wrapup;

  /* redisplay the deleted surfaces and reset number of
  ** deleted surface to 0! */
  for(ii = 0; ii < me->n_del_sur_list; ii ++)
  {
    IGRlong     loc_mx_type;
    IGRmatrix   *loc_mx_ptr;

    loc_mx_type = (IGRlong) me->del_sur_list[ii].
                            module_info.md_env.matrix_type;
    loc_mx_ptr = &me->del_sur_list[ii].
                            module_info.md_env.matrix;

    sts = dp$display(msg = &loc_msg,
                     mtx_type = &loc_mx_type,
                     matrix = &loc_mx_ptr,
		     oids = &me->del_sur_list[ii].located_obj,
                     mode = mode);
    if(! (1 & sts & loc_msg)) goto wrapup;

  }
  me->n_del_sur_list = 0;



wrapup:
  EMWRAPUP(loc_msg, sts, "ECtpanaly.highlight_surfaces");
  return sts;
}

/*
Name

    method init(int type;char *str_ptr)

Abstract

    This is the init method for the command ECtpanaly

Synopsis

    method init(int type;char *str_ptr)

    int type        - 0 preliminary version,
                        no ramification curves
                      1 full version. (not fully implemented)

    char *str_ptr   - unused

Description

    This method initializes the form for ECtpanaly

Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    15 Feb 94   GWW     Creation
    15 Jun 94   B.Burkhardt Initialization of tolerances wrt cht_tol
    20 Jul 94   B.Burkhardt Set default for the layer wrt the current one
*/
method init(int type;char *str_ptr)
{

   BSrc            rc;
   IGRdouble       cht_tol;
   IGRint          sts, msg;
   IGRshort        layer;
   IGRint          i;

   /* save type:
   **   0 - standard invocation. Currently only restricted
   **       command set
   **   1 - full invocation. Allows also
   **       features, which are not completed
   */
   me->version = type;

   /* no form is yet up */
   me->form1_visible = FORM1_DOES_NOT_EXISTS;

   /* allocate space for temporary objects */
   topo_default_param.temporary_objects = 
	(struct Ext_data_tmp *) malloc(sizeof(struct Ext_data_tmp));
   topo_default_param.temporary_points = 
	(struct Ext_data_tmp *) malloc(sizeof(struct Ext_data_tmp));

   /* referenced_object is the command objects */
   topo_default_param.temporary_objects->referenced_object.objid = my_id;
   topo_default_param.temporary_objects->referenced_object.osnum = 
							OM_Gw_current_OS;
   topo_default_param.temporary_points->referenced_object.objid = my_id;
   topo_default_param.temporary_points->referenced_object.osnum = 
							OM_Gw_current_OS;
   /* displayed_object will become the graphic group of all
   ** temporary objects
   */
   topo_default_param.temporary_objects->displayed_object.objid = NULL;
   topo_default_param.temporary_points->displayed_object.objid = NULL;

   topo_default_param.form_state = FORM_STATE_NO;

   /* set default parameter for form */
   memcpy( &me->top.pa , &topo_default_param, sizeof( struct TOPO_param));

   /* initialize the topology structure */
   TOinit( &me->top);

   /* save the parameter for reapplying */
   memcpy( &me->save_param , &me->top.pa , sizeof( struct TOPO_param));

   /*get the values for chordheigth and basis tolerance*/
   BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
   if(rc != BSSUCC)
   {
#ifdef DBG
      printf("cht could not be extracted\n");
#endif
      return(-3);
   }
   me->top.pa.topology_tolerance = 10.0*cht_tol;
   me->top.pa.diagnosis_distance_tolerance = cht_tol;
   me->top.pa.distance = cht_tol;

/* get the current layer; use it as default */

   sts = gr$get_active_layer(msg = &msg, buffer = &layer);
  
   for(i=0;i<5;i++) 
      me->top.pa.layer[i]=layer;

   for(i=0;i<3;i++) 
      me->top.pa.edge_layer[i]=layer;

   /* there is no surface selected */
   me->alloc_surface_list = 0;
   me->n_surface_list = 0;

   me->alloc_del_sur_list = 0;
   me->n_del_sur_list = 0;

   /* there is no edge selected */
   me->n_edge    = NULL;
   me->ed_list   = NULL;
   me->n_ed_list = NULL;
   me->ed[0]     = NULL;
   me->ed[1]     = NULL;

   return OM_S_SUCCESS;
}



/*
Name

    method locate_surfaces

Abstract

    locate surfaces for analyze topology

Synopsis

    method locate_surfaces(int *msg_loc; int *response; char *response_data;
             int typ)

Description

    typ            -    0 do not locate objects in list
                          and add located surfaces to list of all surfaces
                        1 locate only objects in list
                          and delete objects from list of all surfaces


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    17 Feb 94   GWW     Creation
*/
method locate_surfaces(int *msg_loc; int *response; char *response_data;
	int option)
{
 /* see $MODEL/src_testco/imp/ECmkcompsfi.I */
 IGRlong             sts = OM_S_SUCCESS;
 IGRint              locate_mask, accept_mask /* , token */;
 IGRint              display_flag;
 IGRlong             loc_key, acc_key, reloc_key;
 struct GRlc_locate  attr;
 OM_S_CLASSLIST      rtree_classes, elig_classes;
 OMuword             rclass, eliclass;
 IGRlong             loc_msg = EMS_S_Success;
 IGRlong             msg = EMS_S_Success;
 IGRlong             size = sizeof (struct GRevent);
 int response_state;


#ifdef DBG
         printf(".. locate surface(s) \n");
#endif


        /*Set proper locate prompt*/
        locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_RJT_MOVEON;
        display_flag = ALL_WINDOWS | ELEM_HILIGHT | LC_ACCEPT_CURSOR |
		   NO_PROJ_ACCEPT_POINT | LC_ERASE_LOC_ELEMENT;
        if (me->n_surface_list < 1) 
        {
          loc_key = EMS_P_00031;  /* Identify surface */
        }
        else
        {
          locate_mask |= GRm_RJT_MOVEON;
          if(option == 0)
           loc_key = EMS_P_Identify_surf_move; /* Identify surface/Move on   */
	  else
	   loc_key = MESSAGE_KEY4; /* Identify surface to remove/Move on */
        }
        reloc_key = EMS_I_00011;/* Surface not found */

        if(option == 0)
          acc_key = EMS_P_AccwSf; /* Accept with next surface/Reject */
        else
          acc_key = MESSAGE_KEY3;/* Accept with next surface to remove/Reject */

        /*Set proper accept prompt*/
        accept_mask = GRm_DATA;

        attr.properties =
         LC_LC_ONLY         |       /* Locate locatable objects */
         LC_DP_ONLY         |       /* Locate displayable objects */
         IGN_MOD_BIT        |       /* Ignore modified and new props */
         IGN_PLANAR_BIT     |       /* Ignore planar checks */
         LC_WRITE_ONLY;             /* I am going to change is guy */
        attr.owner_action =
         LC_ASSOCIATIVE     |       /* Associative elements */
         LC_EXTERN_CONSTRAINED |    /* Externally constrained assoc elements */
         LC_RIGID_OWNER     |       /* Composites */
         LC_FLEX_OWNER      |       /* Graphic groups, etc. */
         LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
         LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
         LC_NO_REF_HEADER;          /* No reference file headers */
/*
 rlw : 06/02/88 : Replaced the code in this comment block with
                  the above code.

        attr.properties = 0x11 | LC_RW;
        attr.owner_action = 0x6;
        strcpy(attr.classes, "EMSsurface");
 */
        rtree_classes.w_count = 1;
        elig_classes.w_count = 1;
        rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

        rclass = OPP_EMSsubbs_class_id;
        eliclass = OPP_EMSsurface_class_id;

        rtree_classes.p_classes = &rclass;
        elig_classes.p_classes = &eliclass;
/*
 * Call the graphic set deposit function.  This will help
 * us weed out garbage from the fence.
 */
        sts = gr$gsput_locate_criteria(
          msg = &msg,
          attributes = &attr,
          rtree_classes = &rtree_classes,
          eligible_classes = &elig_classes);
/*
     ERRORs(sts, msg, "ECmkcompsf_exec gsput_locate_criteria", wrapup);
 * End of graphic set deposit
 */
#   if DEBUG
        (void)print_queue ();
#   endif
   {
    extern      IGRlong EFlocate_action_handler();
    struct      EMSaction_handler already_located;
    struct GRid *list = alloca(sizeof(struct GRid ) * me->n_surface_list);
    int i;

    for(i=0;i<me->n_surface_list;++i)
        list[i] = me->surface_list[i].located_obj;

    already_located.next = NULL;
    already_located.option = option;
    already_located.type = 1; 
    already_located.num_objects = me->n_surface_list;
    already_located.objects.id = list;

#ifdef DBG
 printf("action_handler,option=%d, #=%d\n",option,me->n_surface_list);
#endif


    me->locate_stack.num_entries = 0;

    lc$locate(rc = &loc_msg,
              event1 = &me->locate_event,
              event2 = &me->accept_event,
              mask1 = locate_mask,
              mask2 = accept_mask,
              eventsize= &size,
              display_flag = display_flag,
              response = response,
              response_data = response_data,
/*
              hilight_mode = 
		(enum GRdpmode) ((option==0) ? GRhd : GRheo),
*/
              unhilight_mode = 
		(enum GRdpmode) ((option==0) ? HIGHLIGHT_MODE : HIGHLIGHT_MODE),
              locate_key = loc_key,
              acc_key = acc_key,
              relocate_key = reloc_key,
              attributes = &attr,
              act_handler = EFlocate_action_handler,
              act_args = &already_located,
              stack = &me->locate_stack,
              rtree_classes = &rtree_classes,
              eligible_classes = &elig_classes);

#ifdef NOT_USED
fprintf(stderr,"ECtpanaly: after lc$locate msg=%d\n",loc_msg);
    fprintf(stderr,"loc_event.response = %d\n", me->locate_event.response);
    fprintf(stderr,"acc_event.response = %d\n", me->accept_event.response);
    fprintf(stderr,"loc_event.objid0= %d\n", 
			me->locate_event.located_object[0].located_obj.objid);
    fprintf(stderr,"loc_event.objid1= %d\n", 
			me->locate_event.located_object[1].located_obj.objid);
    fprintf(stderr,"acc_event.objid0= %d\n", 
			me->accept_event.located_object[0].located_obj.objid);
    fprintf(stderr,"acc_event.objid1= %d\n", 
			me->accept_event.located_object[1].located_obj.objid);
    fprintf(stderr,"loc_stk.#entries = %d\n", me->locate_stack.num_entries);
    fprintf(stderr,"loc_stk.#loc = %d\n", me->locate_stack.number_located);
    fprintf(stderr,"stackobj = %d\n", 
			me->locate_stack.entry[0].located_obj.objid);
#endif

   }

#ifdef NOT_USED
        if(! (1 & sts)) { *response = TERMINATE; goto wrapup; }

        if(loc_msg == LC_OBJS_IN_STACK)
        {
           me->accept_event.located_object[0].located_obj =
                me->locate_stack.entry[0].located_obj;
        }
        else if(loc_msg == LC_OBJ_LOCATED)
        {
           if(me->accept_event.located_object[0].located_obj
		.objid == 0)
           me->accept_event.located_object[0].located_obj =
		me->locate_event.located_object[0].located_obj;
        }
#endif

        /*
         * Half highlight the located object (if one was located)
         * (or erase highlighting)
         */
        if(loc_msg)
        {
          IGRlong     loc_mx_type;
          IGRmatrix   *loc_mx_ptr;

          loc_mx_type = (IGRlong) me->accept_event.
                                  located_object[0].module_info.md_env.
                                  matrix_type;
          loc_mx_ptr = &me->accept_event.
                        located_object[0].module_info.md_env.matrix; 

          sts = dp$display(msg = &loc_msg,
                           mtx_type = &loc_mx_type,
                           matrix = &loc_mx_ptr,
                           oids = &me->accept_event.
                                   located_object[0].located_obj,
                           mode = option == 0 ? HIGHLIGHT_MODE : GRhe);
          /* if(! (1 & sts & loc_msg)) { *response = TERMINATE; goto wrapup; }*/
        }
        else loc_msg = EMS_S_Success; /* Reset loc_msg */

        /*
         * Set state based on response:
         *  DATA: locate the next surface
         *  D_RESET: ignore the last locate
         *  RESET: go to the next state
         * If the accept event is unknown, the locate event is checked.
         */
        /* response_state = me->locate_event.response; */
        response_state = me->accept_event.response;
#ifdef DBG
   printf(".. response=%d\n",response_state);
#endif

        if(response_state == DATA || response_state == SPECIFIED_OBJ)
	{
           OMuint           count = 0;
           IGRlong          num_objects = 0, ii;
	   struct GRlc_info *objects = NULL;
           IGRlong          num_objs = 0, jj;
	   struct GRlc_info *objs = NULL;
           IGRboolean       is_primitive_surface = FALSE;
           OM_S_CHANSELECT  to_loopset;
#ifdef DBG
        printf(".. response=specified object\n");
#endif
           /* remove solids; they are not allowed */
           sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
           if(sts != OM_S_SUCCESS)
              goto wrapup;
           sts = om$get_channel_count(
                 objid = me->accept_event.located_object[0].located_obj.objid,
                 osnum = me->accept_event.located_object[0].located_obj.osnum,
                 p_chanselect = &to_loopset,
                 count = &count);
           is_primitive_surface = (1 & sts); /* Will fail if not primitive */

           /* Determine if the element located was a solid.  */
           if (! is_primitive_surface)     /* Not a primitive surface */
           {
              OMuword         comp_classid;
     
              sts = om$get_classid(
                 objid = me->accept_event.located_object[0].located_obj.objid,
                 osnum = me->accept_event.located_object[0].located_obj.osnum,
                 p_classid = &comp_classid);
              if(sts != OM_S_SUCCESS)
              {
#ifndef DBG
                 printf(" error om$get_classid \n"); 
#endif
                 goto wrapup;
              }
              sts = om$is_ancestry_valid(
                    subclassid = comp_classid,
                    superclassid = OPP_EMSsolid_class_id);
              if (sts == OM_S_SUCCESS)
              {
                 IGRlong     loc_mx_type;
                 IGRmatrix   *loc_mx_ptr;

                 ex$message(msgnumb = EMS_I_SolidNtAllw);

                 /* erase highlighting if solid was selected*/
                 loc_mx_type = (IGRlong) me->accept_event.
                                         located_object[0].module_info.md_env.
                                         matrix_type;
                 loc_mx_ptr = &me->accept_event.
                               located_object[0].module_info.md_env.matrix;
                 sts = dp$display(msg = &loc_msg,
                                  mtx_type = &loc_mx_type,
                                  matrix = &loc_mx_ptr,
                                  oids = &me->accept_event.
                                          located_object[0].located_obj,
                                  mode = GRhe);
                 goto wrapup;
              }
     
           } /* Find out if we located a solid */
	  /* get the located objects from the graphic set */
	  sts = EMunwind_stupid_sets(
		&me->accept_event.located_object[0],
		TRUE, TRUE, my_id, &num_objects, &objects, &loc_msg);
#ifdef DBG
          printf("EMunwind sts= %d number of objects= %d \n",sts,num_objects);
#endif
	  /* put the info in the accept_events array */
	  for(ii = 0; ii < num_objects; ii ++)
	  {
             /* look for solids again; may be fence selection was used and
                solids are in the set*/
             sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
             if(sts != OM_S_SUCCESS)
                goto wrapup;
             sts = om$get_channel_count(
                   objid = objects[ii].located_obj.objid,
                   osnum = objects[ii].located_obj.osnum,
                   p_chanselect = &to_loopset,
                   count = &count);
             is_primitive_surface = (1 & sts); /* Will fail if not primitive */
  
             /* Determine if the element located was a solid.  */
             if (! is_primitive_surface)     /* Not a primitive surface */
             {
                OMuword         comp_classid;
                sts = om$get_classid(
                   objid = objects[ii].located_obj.objid,
                   osnum = objects[ii].located_obj.osnum,
                   p_classid = &comp_classid);
                if(sts != OM_S_SUCCESS)
                {
#ifdef DBG
                   printf(" error om$get_classid \n"); 
#endif
                   goto wrapup;
                }
                sts = om$is_ancestry_valid(
                      subclassid = comp_classid,
                      superclassid = OPP_EMSsolid_class_id);
                if (sts == OM_S_SUCCESS)
                {
                    IGRlong     loc_mx_type;
                    IGRmatrix   *loc_mx_ptr;
   
                    ex$message(msgnumb = EMS_I_SolidNtAllw);
   
                    /* erase highlighting if solid was selected*/
                    loc_mx_type = (IGRlong) me->accept_event.
                                  located_object[0].module_info.md_env.
                                  matrix_type;
                    loc_mx_ptr = &me->accept_event.
                                  located_object[0].module_info.md_env.matrix;
                    sts = dp$display(msg = &loc_msg,
                                     mtx_type = &loc_mx_type,
                                     matrix = &loc_mx_ptr,
                                     oids = &me->accept_event.
                                             located_object[0].located_obj,
                                     mode = GRhe);
                   continue;
                }
                else
                {
	           /* get the located objects from the graphic set */
	           sts = EMunwind_stupid_sets( &objects[ii],
		         TRUE, TRUE, my_id, &num_objs, &objs, &loc_msg);
	           for(jj = 0; jj < num_objs; jj ++)
	           {

                      if(option == 0)
                      sts = add_surface(&me->alloc_surface_list,
	                                &me->n_surface_list,
	     	                        &me->surface_list, 
		                        &objs[jj],
		                        &me->recalculate);
                      else
 	              sts = delete_surface(&me->top, &me->alloc_surface_list,
		                           &me->n_surface_list,
		                           &me->surface_list, 
		                           &objs[jj],
		                           &me->recalculate,
		                           &me->alloc_del_sur_list,
		                           &me->n_del_sur_list,
		                           &me->del_sur_list);
	           }
                }/*if (sts == OM_S_SUCCESS)*/ 
             }
             else /* Find out if we located a solid */
             {
                if(option == 0)
                sts = add_surface(&me->alloc_surface_list,
	              &me->n_surface_list,
	     	         &me->surface_list, 
			   &objects[ii],
		         &me->recalculate);
                else
 	        sts = delete_surface(&me->top, &me->alloc_surface_list,
		                     &me->n_surface_list,
		                     &me->surface_list, 
			               &objects[ii],
		                     &me->recalculate,
		                     &me->alloc_del_sur_list,
		                     &me->n_del_sur_list,
		                     &me->del_sur_list);
	     }
	  }/* for(ii = 0; ii < num_objects; ii ++)*/
          if(response_state == DATA && me->n_surface_list > 0 && sts == 0)
          {
            /* put the accept event on the queue */
           sts = ex$putque(
             	msg = &msg,
             	response = response,
             	byte = &size,
             	buffer = (IGRchar *) &me->accept_event.event);
          }

	  if(objects != NULL) om$dealloc(ptr = objects);
	  if(objs != NULL) om$dealloc(ptr = objs);
        }
        else if(response_state == D_RESET)
        {
#ifdef NOT_USED
          printf(".. response=D_RESET\n");
          we should remove the last located element, which is that?
          if(me->num_locates) me->num_locates --;
#endif
        }
        else if(response_state == RESET)
        {
/* printf(".. response=RESET\n"); */
          me->state = STATE_SETUP_FORM;
        }
        else if(response_state == GR_UNKNOWN_TYPE) 
        {
/* printf(".. response=GR_UNKNOWN_TYPE\n"); */
           /* this event may happen, by a ex$putque, when
           ** the state is changed from the form or when
           ** the user enters any other input, so leave execute 
           ** method
           */
          goto wrapup; 
        }
        else
        {
/* printf(".. response=%d\n",response_state); */
	  goto wrapup;
        }
   *msg_loc = 0;
   return sts;

wrapup:
   *msg_loc = 1;
   return sts;
}

/*
Name

    method locate_edges

Abstract

    locate an edge pair for the Investigate Edge Match function

Synopsis

    method locate_edges(int *msg_loc; int *response; char *response_data;
             int typ)

    response        - response from last event when command returns
                      control to command services

    response_data   - response data from last event when command returns
                      control to command services

    typ                 1 locate only objects in list

Description
    only the displayed objects topological edges of the Adjacency Analysis
    are allowed for selection
    from displayed objects there will be found the edge pointer
    in the topological data structure and the pointer to the referenced
    object for further investigations

Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    21 Jun 94   B.Burkhardt     Creation as modification of method
                                locate_surfaces
*/
method locate_edges(int *msg_loc; int *response; char *response_data;
	int option)
{
   IGRlong             sts = OM_S_SUCCESS;
   IGRint              locate_mask, accept_mask /* , token */;
   IGRint              display_flag;
   IGRlong             loc_key, acc_key, reloc_key;
   struct GRlc_locate  attr;
   OM_S_CLASSLIST      rtree_classes, elig_classes;
   OMuword             rclass, eliclass;
   IGRlong             loc_msg = EMS_S_Success;
   IGRlong             msg = EMS_S_Success;
   IGRlong             size = sizeof (struct GRevent);
   int response_state;
   struct telist   *tetmp;

#ifdef DBG
 printf(".. locate edges(s) \n");
#endif


   /*Set proper locate prompt*/
   locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_RJT_MOVEON;
   display_flag = ALL_WINDOWS | ELEM_HILIGHT | LC_ACCEPT_CURSOR |
   NO_PROJ_ACCEPT_POINT | LC_ERASE_LOC_ELEMENT;
   locate_mask |= GRm_RJT_MOVEON;
   loc_key = EMS_P_IdE;   /* Identify edge */
   acc_key = EMS_P_AccER; /* Accept Edge/Reject*/
   reloc_key = EMS_E_NoEdFo; /* Edge not found */

   /*Set proper accept prompt*/
   accept_mask = GRm_DATA;

   attr.properties =
   LC_LC_ONLY         |       /* Locate locatable objects */
   LC_DP_ONLY         |       /* Locate displayable objects */
   IGN_MOD_BIT        |       /* Ignore modified and new props */
   IGN_PLANAR_BIT     |       /* Ignore planar checks */
   LC_WRITE_ONLY;             /* I am going to change is guy */
  attr.owner_action =
   LC_ASSOCIATIVE     |       /* Associative elements */
   LC_EXTERN_CONSTRAINED |    /* Externally constrained assoc elements */
   LC_RIGID_OWNER     |       /* Composites */
   LC_FLEX_OWNER      |       /* Graphic groups, etc. */
   LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
   LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
   LC_NO_REF_HEADER;          /* No reference file headers */
   rtree_classes.w_count = 1;
   elig_classes.w_count = 2;
   rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

   rclass = OPP_GRvg_class_id;
   eliclass = OPP_GRbcsubbc_class_id;

   rtree_classes.p_classes = &rclass;
   elig_classes.p_classes  = &eliclass;
/*
 * Call the graphic set deposit function.  This will help
 * us weed out garbage from the fence.
 */
        sts = gr$gsput_locate_criteria(
          msg = &msg,
          attributes = &attr,
          rtree_classes = &rtree_classes,
          eligible_classes = &elig_classes);
#   if DEBUG
        (void)print_queue ();
#   endif
   {
   extern      IGRlong EFlocate_action_handler();
   struct      EMSaction_handler already_located;
   int i      = NULL;
   struct top_edge *tetemp = NULL;
   struct elist    *tltemp = NULL;
   

   tetemp = me->top.te.tehead;
/*
   return  if list is empty
*/
   if(tetemp->next == me->top.te.tetail)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoToAna);
      *msg_loc = 1;
      me->form1_visible = FORM1_INVISIBLE; 
      me->state = STATE_SETUP_FORM2;
      me->top.pa.form_state = FORM_STATE_AA;
      return(0);
   }
   /* for the first time create a list of all edge which are belonging
      to a top_edge (use only two edges of the top edge)
      these are the selectable objects */
   if(!me->n_ed_list)
   {
      me->edge_list = (struct GRid *)
                      om$malloc(size = (sizeof(struct GRid ) *
                                        me->top.te.num_te*2));
      me->ed_list   = (struct edge **)
                      om$malloc(size = (sizeof(struct edge *) *
                                        me->top.te.num_te*2));
      while((tetemp=tetemp->next) != me->top.te.tetail)
      {
         if(tetemp->elehead->next != tetemp->eletail)
         {
            IGRint j= NULL;
            tltemp = tetemp->elehead;
            while((tltemp = tltemp->next) != tetemp->eletail && j<2)
            {
               j++;
               me->edge_list[i] = tltemp->ied->ext->displayed_object;
               me->ed_list[i++] = tltemp->ied;
            }
         }
      }
      me->n_ed_list = i;
   }/*if(!me->n_ed_list)*/
    already_located.next = NULL;
    already_located.option = option;
    already_located.type = 1; 
    already_located.num_objects =me->n_ed_list;
    already_located.objects.id = me->edge_list;
#ifdef DBG
    printf("action_handler,option=%d, #=%d\n",option,me->n_ed_list);
#endif
    if(me->n_edge == 2)
    {
       loc_key = EMS_P_IdSE;
    }
    me->locate_stack.num_entries = 0;

    lc$locate(rc = &loc_msg,
              event1 = &me->locate_event,
              event2 = &me->accept_event,
              mask1 = locate_mask,
              mask2 = accept_mask,
              eventsize= &size,
              display_flag = display_flag,
              response = response,
              response_data = response_data,
/*
              hilight_mode = 
		(enum GRdpmode) ((option==0) ? GRhd : GRheo),
*/
              unhilight_mode = 
		(enum GRdpmode) ((option==0) ? HIGHLIGHT_MODE : HIGHLIGHT_MODE),
              locate_key = loc_key,
              acc_key = acc_key,
              relocate_key = reloc_key,
              attributes = &attr,
              act_handler = EFlocate_action_handler,
              act_args = &already_located,
              stack = &me->locate_stack,
              rtree_classes = &rtree_classes,
              eligible_classes = &elig_classes);
#ifdef DBG
    fprintf(stderr,"ECtpanaly: after lc$locate msg=%d\n",loc_msg);
    fprintf(stderr,"loc_event.response = %d\n", me->locate_event.response);
    fprintf(stderr,"acc_event.response = %d\n", me->accept_event.response);
    fprintf(stderr,"loc_event.objid0= %d\n", 
			me->locate_event.located_object[0].located_obj.objid);
    fprintf(stderr,"loc_event.objid1= %d\n", 
			me->locate_event.located_object[1].located_obj.objid);
    fprintf(stderr,"acc_event.objid0= %d\n", 
			me->accept_event.located_object[0].located_obj.objid);
    fprintf(stderr,"acc_event.objid1= %d\n", 
			me->accept_event.located_object[1].located_obj.objid);
    fprintf(stderr,"loc_stk.#entries = %d\n", me->locate_stack.num_entries);
    fprintf(stderr,"loc_stk.#loc = %d\n", me->locate_stack.number_located);
    fprintf(stderr,"stackobj = %d\n", 
			me->locate_stack.entry[0].located_obj.objid);
#endif
   }

        /*
         * Half highlight the located object (if one was located)
         * (or erase highlighting)
         */
        if(loc_msg)
        {
          IGRlong     loc_mx_type;
          IGRmatrix   *loc_mx_ptr;
          loc_mx_type = (IGRlong) me->accept_event.
                                  located_object[0].module_info.md_env.
                                  matrix_type;
          loc_mx_ptr = &me->accept_event.
                        located_object[0].module_info.md_env.matrix; 

          sts = dp$display(msg = &loc_msg,
                           mtx_type = &loc_mx_type,
                           matrix = &loc_mx_ptr,
                           oids = &me->accept_event.
                                   located_object[0].located_obj,
                           mode = option == 0 ? HIGHLIGHT_MODE : GRhe);
          /* if(! (1 & sts & loc_msg)) { *response = TERMINATE; goto wrapup; }*/
        }
        else loc_msg = EMS_S_Success; /* Reset loc_msg */

        /*
         * Set state based on response:
         *  DATA: accept the selected edge
         *  D_RESET: ignore the last locate
         *  RESET: go to the next state
         * If the accept event is unknown, the locate event is checked.
         */
        /* response_state = me->locate_event.response; */
        response_state = me->accept_event.response;
#ifdef DBG
        printf(".. response=%d\n",response_state); 
#endif

        if(response_state == DATA || response_state == SPECIFIED_OBJ)
	{
          IGRlong		num_objects = 0, ii;
	  struct GRlc_info	*objects = NULL;

#ifdef DBG
          printf(".. response=specified object\n"); 
#endif
	  /* get the located objects from the graphic set */
	  sts = EMunwind_stupid_sets(
		&me->accept_event.located_object[0],
		TRUE, TRUE, my_id, &num_objects, &objects, &loc_msg);
#ifdef DBG
          printf("EMunwind sts= %d number of objects= %d \n",sts,num_objects);
#endif
	  /* put the info in the accept_events array */
          me->n_edge = 0; 
          if(num_objects >1)
          {
             IGRlong     loc_mx_type;
             IGRmatrix   *loc_mx_ptr;
             loc_mx_type = (IGRlong) me->accept_event.
                                     located_object[0].module_info.md_env.
                                     matrix_type;
             loc_mx_ptr = &me->accept_event.
                           located_object[0].module_info.md_env.matrix;

             ex$message(field = ERROR_FIELD,
                        msgnumb = EMS_E_NoEdFo); /* Edge not found */
             sts = dp$display(msg      = &loc_msg,
                              mtx_type = &loc_mx_type,
                              matrix   = &loc_mx_ptr,
                              oids     = &me->accept_event.
                                         located_object[0].located_obj,
                              mode     = GRhe);
          /* if(! (1 & sts & loc_msg)) { *response = TERMINATE; goto wrapup; }*/
             goto wrapup;
          }
	  for(ii = 0; ii < me->n_ed_list; ii ++)
	  {
             if(objects[0].located_obj.objid == me->edge_list[ii].objid && 
                (tetmp = me->ed_list[ii]->elehead->next) !=
                 me->ed_list[ii]->eletail)
             {
                me->n_edge++;
                if(tetmp->ied->elehead->next != tetmp->ied->eletail)
                me->ed[0] = tetmp->ied->elehead->next->ied;
                if(tetmp->ied->elehead->next->next != tetmp->ied->eletail)
                {
                   me->ed[1] = tetmp->ied->elehead->next->next->ied;
                   me->n_edge++;
                }
                break;
             }
          } 
          if(response_state == DATA && me->n_edge == 2 )
          {
#ifdef DBG
             printf(".. response=DATA n_edge = 2\n");
#endif
             me->state = STATE_SETUP_FORM;
             ex$message(msgnumb = EMS_I_ClearStatusField);
             ex$message(msgnumb = EMS_P_ClearPromptField);
          }

	  if(objects != NULL) om$dealloc(ptr = objects);
        }
        else if(response_state == D_RESET)
        {
#ifdef NOT_USED
          printf(".. response=D_RESET\n");
          we should remove the last located element, which is that?
          if(me->num_locates) me->num_locates --;
#endif
        }
        else if(response_state == RESET && me->n_edge == 2 )
        {
#ifdef DBG
          printf(".. response=RESET\n");
#endif
          me->state = STATE_SETUP_FORM;
        }
        else if(response_state == GR_UNKNOWN_TYPE) 
        {
#ifdef DBG
          printf(".. response=GR_UNKNOWN_TYPE\n");
#endif
           /* this event may happen, by a ex$putque, when
           ** the state is changed from the form or when
           ** the user enters any other input, so leave execute 
           ** method
           */
          goto wrapup; 
        }
        else
        {
#ifdef DBG
          printf(".. response=%d\n",response_state);
#endif
	  goto wrapup;
        }
   *msg_loc = 0;
   return sts;

wrapup:
   *msg_loc = 1;
   return sts;
}

/*
Name

    method execute

Abstract

    This is the execute method for the command ECtpanaly

Synopsis

    method execute(int *response; char *response_data; int pos)

    response        - response from last event when command returns
                      control to command services

    response_data   - response data from last event when command returns
                      control to command services

    pos             - unused

Description

    This method gathers the user's input and calls appropriate routines

Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    01 DEC 93   GWW     Creation
*/
method execute(int *response; char *response_data; int pos )
{
  IGRlong   sts = OM_S_SUCCESS;
  IGRlong   loc_msg = EMS_S_Success;
  IGRint    stat_OM;
  int       msg_loc;

#ifdef DBG
   printf("..started execute method\n");
#endif

  while (1)
  {
#ifdef DBG
     printf(".. state=%d\n",me->state);
#endif
    switch(me->state)
    {
      /*  
       * startup the command
       */
      case STATE_START:
           me->state = STATE_INVOKE;

      /*
       * Locate the surfaces.
       */
      case STATE_INVOKE:
         /* locate surfaces */
         stat_OM = om$send(
	           msg = message ECtpanaly.locate_surfaces(
				 &msg_loc, response, response_data,0),
	           senderid = NULL_OBJID,
	           targetid = my_id);

         if(!(stat_OM & 1))
         {
#ifdef DBG
            printf("error locate surfaces\n");
#endif
            goto wrapup;
         }
         if(msg_loc == 1) goto wrapup;
	
      break;

      case STATE_SETUP_FORM:
      {
#ifdef DBG
         printf(".. state setup_form\n");
#endif
         stat_OM = om$send(
	    msg = message ECtpanaly.setup_form(),
	    senderid = NULL_OBJID,
	    targetid = my_id
	    );

        /* determine the next status depending of the
        ** state as setup from the setup form 
        */
        if(me->state == STATE_SETUP_FORM)
	{
#ifdef DBG
	   printf("something is wrong, state not changed, ...\n"); 
#endif
	  me->state = STATE_ADD_SURFACES;
 	}

        if(!(stat_OM & 1))
        {
#ifdef DBG
           printf("error setup_form\n");
#endif
           goto wrapup;
        }
         
      }
      break;

      case STATE_SETUP_FORM2:
      {
#ifdef DBG
         printf(".. state setup_form2\n");
#endif
         me->top.pa.form_state = FORM_STATE_NO;
         stat_OM = om$send(
	    msg = message ECtpanaly.setup_form(),
	    senderid = NULL_OBJID,
	    targetid = my_id
	    );

        /* determine the next status depending of the
        ** state as setup from the setup form 
        */
        if(me->state == STATE_SETUP_FORM2)
	{
#ifdef DBG
	   printf("something is wrong, state not changed, ...\n"); 
#endif
	  me->state = STATE_ADD_SURFACES;
 	}

        if(!(stat_OM & 1))
        {
#ifdef DBG
           printf("error setup_form\n");
#endif
           goto wrapup;
        }
         
      }
      break;

      case STATE_ADD_SURFACES:
        {
#ifdef DBG
          printf(".. state to add further surfaces\n");
#endif
         /* locate surfaces */
         stat_OM = om$send(
	    msg = message ECtpanaly.locate_surfaces(
				&msg_loc, response, response_data,0),
	    senderid = NULL_OBJID,
	    targetid = my_id
	    );

         if(!(stat_OM & 1))
         {
#ifdef DBG
           printf("error locate surfaces\n");
#endif
           goto wrapup;
         }
         if(msg_loc == 1) goto wrapup;

        }
	break;

      case STATE_DELETE_SURFACES:
      {
#ifdef DBG
         printf(".. state to delete surfaces(currently process)\n");
#endif

         if(me->n_surface_list == 0)
         {
	    me->recalculate = TRUE;
	    me->state = STATE_INVOKE;
            ex$message( field = ERROR_FIELD,
		 /* in_buff = MESSAGE2, .. "All surfaces removed") */
                 msgnumb = MESSAGE_KEY2
		 );

           /* call notification routine, to switch to add_surface */

            FIg_set_state_on(me->form1_form,BUTTON1);
            stat_OM = om$send (msg = message ECtpanaly.form1_do_form 
				    (&loc_msg,
				    TOP_FORM1,
                                    BUTTON1, 
                                    1.0,
				    me->form1_form),
                     senderid = NULL_OBJID, 
                     targetid = my_id);
            if(! (stat_OM & 1)) goto wrapup;
            FIg_disable(me->form1_form,BUTTON3);
            stat_OM = om$send (msg = message ECtpanaly.form1_do_form 
				    (&loc_msg,
				    TOP_FORM1,
                                    BUTTON3, 
                                    1.0,
				    me->form1_form),
                     senderid = NULL_OBJID, 
                     targetid = my_id);
            if(! (stat_OM & 1)) goto wrapup;

	   break;
        }

        /* allow selection of surfaces only within already located
        ** object ids 
        */

        stat_OM = om$send(
	    msg = message ECtpanaly.locate_surfaces(
				&msg_loc, response, response_data,1),
	    senderid = NULL_OBJID,
	    targetid = my_id
	    );

        if(!(stat_OM & 1))
        {
#ifdef DBG
           printf("error locate surfaces\n");
#endif
           goto wrapup;
        }
        if(msg_loc == 1) goto wrapup;

        break;
      }
 


      case STATE_IDENTIFY_EDGE:
      {
         /* Identify one of the edges */
         /* ... */
         /* locate edge */
         stat_OM = om$send( msg = message ECtpanaly.locate_edges(
                                  &msg_loc, response, response_data,1),
                   senderid = NULL_OBJID,
                   targetid = my_id);

         if(!(stat_OM & 1))
         {
#ifdef DBG
            printf("error locate edges\n");
#endif
            goto wrapup;
         }
         if(msg_loc == 1) goto wrapup;
      break;
      }

      default:
#ifdef DBG
         printf("Invalid state %d in execute method.\n",me->state); 
#endif
         sts = OM_E_ABORT;
         loc_msg = EMS_E_Fail;
         *response = TERMINATE;
         goto wrapup;
      }
         
   }

wrapup:
  EMWRAPUP(sts, loc_msg, "ECtpanaly.execute");
  return sts;
}

/*
Name

    method sleep

Abstract

    This is the sleep method for the command ECtpanaly.

Synopsis

    method sleep(int pos)

    pos             - unused

Description

    This method erases the highlight plane.

Return Value

    OM_S_SUCCESS

Notes

    dp$erase_hilite may be on its last legs. dp$display with mode GRhdbe
    for each element may need to be used in its place.

Index

Keywords

History

    22 Nov 93   AIC     Creation
*/
method sleep(int pos)
{
  IGRlong   loc_msg = EMS_S_Success;
  IGRint    stat_OM;
#ifdef DBG
  printf("sleep method\n");
#endif

  /*
   * Erase everything
  */
  dp$erase_hilite(msg = &loc_msg);
   /* remove highlight surfaces 
   stat_OM = om$send(
	    msg = message ECtpanaly.highlight_surfaces( GRhe, FALSE ),
	    senderid = NULL_OBJID,
	    targetid = my_id
	    );
  */

  if(me->form1_visible == FORM1_VISIBLE)
  {
	     FIf_erase(me->form1_form);
  }

  /* remove command name */
  display_command_name(FALSE);

  /* unhighlight status display button */
  GRstatus_display_button(FALSE);

/*
wrapup:
  EMWRAPUP(loc_msg, sts, "ECtpanaly.sleep");
*/
  return OM_S_SUCCESS;
}

/*
Name

    method wakeup

Abstract

    This is the wakeup method for the command ECtpanaly.

Synopsis

    method wakeup(int pos)

    pos             - unused

Description

    This method highlight the elements that have already been located.

Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    22 Nov 93   AIC     Creation
*/
method wakeup(int pos)
{
   IGRint    stat_OM;

   /* redisplay command message */
   display_command_name(TRUE);

   if(me->form1_visible == FORM1_VISIBLE)
   {
    FIf_display(me->form1_form);
   }

  /* highlight status display button */
  GRstatus_display_button(TRUE);

   /* highlight surfaces */
   stat_OM = om$send(
	    msg = message ECtpanaly.highlight_surfaces( HIGHLIGHT_MODE,FALSE ),
	    senderid = NULL_OBJID,
	    targetid = my_id
	    );
  return stat_OM;
}

/*
Name

    method delete

Abstract

    delete all allocated space

Synopsis

     method delete (int f_defer_flag)


Description


Return Value

    OM_S_SUCCESS

Notes


Index

Keywords

History

    15 Feb 94   GWW     Creation
*/
method delete (int f_defer_flag)
{
   int status;
   char *text1;

#ifdef DBG
    printf("..delete\n");
#endif

   /* save the default parameters for use in next command invocation
   */
   memcpy( &topo_default_param, &me->top.pa , sizeof( struct TOPO_param));

   /* delete topology info */
   ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_DelTop /* Delete Topological Information */);

   TOdelete_topology(&me->top);
   ex$message(msgnumb = EMS_I_ClearStatusField);

   /* delete all allocated space */
   if(me->top.pa.file_name != NULL)
   {
      if(topo_default_param.file_name != NULL)
      {
         text1 = (char *)strdup(topo_default_param.file_name);
         free(me->top.pa.file_name);
         topo_default_param.file_name = (char *)strdup(text1);
      }
      else
         free(me->top.pa.file_name);
      me->top.pa.file_name = NULL;
   }
   if(me->top.pa.header_line != NULL)
   {
      if(topo_default_param.header_line != NULL)
      {
         text1 = (char *)strdup(topo_default_param.header_line);
         free(me->top.pa.header_line);
         topo_default_param.header_line = (char *)strdup(text1);
      }
      else
         free(me->top.pa.header_line);
      me->top.pa.header_line = NULL;
   }
   if(me->top.pa.temporary_objects != NULL)
   {
		free((char *)me->top.pa.temporary_objects);
   		me->top.pa.temporary_objects = NULL;
   }
   if(me->top.pa.temporary_points != NULL)
   {
		free((char *)me->top.pa.temporary_points);
   		me->top.pa.temporary_points = NULL;
   }

   /* delete surface buffer */
   if(me->alloc_surface_list > 0) free(me->surface_list);

   if(me->alloc_del_sur_list > 0) free(me->del_sur_list);

   /* delete edge buffer
   if(me->ed[0] > NULL) free(me->ed[0]);
   if(me->ed[1] > NULL) free(me->ed[1]); */
   me->ed[0] = NULL;
   me->ed[1] = NULL;
   
   /* delete window object */

   status = om$send(
			mode = OM_e_wrt_message, 
			msg = message Root.delete(f_defer_flag), 
			senderid = my_id, 
			targetid = my_id );

   if ( ! ( 1 & status ) )
   {
		om$report_error(sts = status );
   }
  return status;
}



/*
Name

    method status_disp

Abstract

    bring up form

Synopsis

    method status_disp()


Description

    This method brings up the status form

Return Value

    OM_S_SUCCESS

Notes

    Event handling is not done well.

Index

Keywords

History

    15 Feb 94   GWW     Creation
*/
method status_disp() 
{
    IGRint stat_OM;

#ifdef DBG
    printf("in status_disp\n");
#endif

    stat_OM = om$send(
	msg = message ECtpanaly.setup_form(),
	senderid = NULL_OBJID,
	targetid = my_id
	);

    if(!(stat_OM & 1))
    {
#ifdef DBG
    printf("error setup_form\n");
#endif
       return OM_E_ABORT;
    }

    return OM_S_SUCCESS;

}

end implementation ECtpanaly;
