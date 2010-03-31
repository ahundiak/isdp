
class implementation EMSsubbs;

#include "EMS.h"
#include "EMSbnddef.h"	/* Required by EMSbnd.h */
#include "EMSbnd.h"	/* Required by one of the messages */
#include "EMSlm.h"	/* Has the ambiguous grouping structure */
#include "EMSlmdef.h"	/* Make face defines */
#include "EMSlift.h"	/* for struct EMSdlft_info.. */
#include "EMSmsgdef.h"	/* EMS_I_NeedGrpInfo is defined here */
#include "EMSopt.h"	/* for EMS_DO_DISPLAY... */
#include "emsdef.h"	/* for MAXINT */
#include "bsicmpcvoff.h"	/* for BSCONSTOFF */
#include "bstagsort.h"


#if DEBUG
#define ERROR(sts, msg, errmsg) \
{ \
    if( !(1 & sts & msg) ) \
    { \
	printf("\nIn EFrapid_make_and_lift_face_w_draft : %s\n", errmsg); \
	goto wrapup; \
    } \
}
#else
#define ERROR(sts, msg, errmsg) \
{ \
    if( !(1 & sts & msg) )  goto wrapup; \
}
#endif

extern OMuword OPP_EMSsubbs_class_id;


from GRowner        import  GRget_number_components;
from EMSsfdlift     import  EMlift_face;
from EMSboundary    import  EMget_edges;
from EMSloopset     import  EMget_loops;
from EMSsfdpr       import  EMadd;



struct	rlw_temp_sort
 {
  IGRlong	number_of_curves;
  struct	GRlc_info *curves;
  IGRdouble	distance;
 };

IGRlong EFrapid_make_and_lift_face_w_draft(
		/* Input arguments */
 md_env,			/* Module enviroment of the datum surface */
 datum_surface,			/* Surface on which makes are to take place */
 number_of_curves,		/* Number of curves to impose as boundaries */
 curves,			/* The curves which are used to make faces */
 lift_distances,		/* The distances the faces are to be lifted */
 lift_vec,			/* The vector the faces are to be lifted */
 draft_angle,			/* The draft angle */
 construct_list,		/* Standard list used to build new sf's */
 top_state_before,		/* Top node in the state tree before */
 display_env,			/* Enviroment in which displays take place */
 my_stupid_id,			/* Caller's object id */
		/* Output arguments */
 top_state_after,		/* Top node after makes and lifts */
 last_lift,			/* The id of the last lifted surface */
 msg)				/* Errror return code */

struct		GRmd_env *md_env;
struct		GRid *datum_surface;
IGRlong		number_of_curves;
struct		GRlc_info curves[];
IGRdouble	*lift_distances;
IGRdouble	*lift_vec;
IGRdouble	draft_angle;
struct		GRvg_construct *construct_list;
struct		GRid *top_state_before;
struct		GRmd_env *display_env;
GRobjid		my_stupid_id;
struct		GRid *top_state_after;
struct		GRid *last_lift;
IGRlong		*msg;

/*
 Description

 Given a surface and a set of curves with distances this routine
 will use the set of curves to make faces on the surface and then
 lift the drafted faces by the specified distances and draft angle.  
 Curves with the same lift distance will be placed on the same face.

 The drafted vector, along which the surface is lifted, is determined
 by the normal vector of the surface.  As such, this function
 will only do something meaningful for planar surfaces.

 If the sign of the lift distance is positive then material is
 added.  If the sign of the lift distance is negative then
 material is removed.

 Limitations

 It is expected that the input curves are closed and planar.
 Ambiguous grouping conditions are not supported and if this
 condition arises it is considered to be an error.
 This function is very much a subset of the functionality provided
 for in the make face command.  It was intended to work for
 a very simple subset of the general problem.

 Thoughts

 It would be rather easy to add support for lifting a face through the
 part if the lift methods supported such functionality.

 History

 BL:	10/10/89:	Creation date, most of the code is copied from
			EFrapid_make_and_lift_face().
 Inasu: 19/04/90:       Fix for TR 90N0601.

 Sudha  07/02/93:       Modified for BSprototypes ansification

 */

{
 IGRint  i;
 IGRlong  sts, loc_msg, *indices, number_of_groups, last_face_index = 0;
 GRobjid  *lp_ids;
 struct	rlw_temp_sort  *sorted;
 struct	GRlc_info  *new_curves;
 struct GRid  *ed_GRids; 
 struct EMSdlft_lp_info  *lp_info, *lps_info;
 struct EMSdlft_ed_info  *ed_info, *eds_info;

 /* Initialize */
 *msg = EMS_S_Success;
 indices = NULL;
 sorted = NULL;
 new_curves = NULL;
 lp_ids = NULL;
 ed_GRids = NULL;
 lp_info = lps_info = NULL;
 ed_info = eds_info = NULL;

 /*
  * Build up a data structure which will tell us which
  * curves should be placed on the same face.  This is
  * done by sorting the distances and then grouping
  * curves with the same distance together.
  */

 {
  IGRboolean	status;
  IGRlong	search_index, index, add_group;
  IGRdouble	distance, previous_distance = 0.0;

  indices = (IGRlong *) malloc(number_of_curves * sizeof(IGRlong));
  if(! indices)
  {
     *msg = EMS_E_NoDynamicMemory;
     goto wrapup;
  }

  status = BStagsort(&loc_msg, (IGRint *)&number_of_curves, lift_distances, (IGRint *)indices);
  if(! status)
  {
     *msg = EMS_E_BSerror;
     goto wrapup;
  }

  new_curves = (struct GRlc_info *) malloc(number_of_curves *
	sizeof(struct GRlc_info));
  if(! new_curves)
  {
     *msg = EMS_E_NoDynamicMemory;
     goto wrapup;
  }

  sorted = (struct rlw_temp_sort *) malloc(number_of_curves *
    	sizeof(struct rlw_temp_sort));
  if(! sorted)
  {
     *msg = EMS_E_NoDynamicMemory;
     goto wrapup;
  }

  number_of_groups = 0;
  search_index = number_of_curves - 1; /* Find out where the last curve went */

  for(i = 0; i < number_of_curves; i++)
  {
     index = indices[i];
     new_curves[i] = curves[index];
     distance = lift_distances[index];
     if(i && (distance == previous_distance))
     {
      	add_group = number_of_groups - 1;
      	sorted[add_group].number_of_curves++;
     }
     else
     {
      	add_group = number_of_groups;
      	sorted[number_of_groups].number_of_curves = 1;
      	sorted[number_of_groups].curves = &new_curves[i];
      	sorted[number_of_groups].distance = distance;
      	previous_distance = distance;
      	number_of_groups++;
     }
     if(index == search_index) last_face_index = add_group;

   } /* for (i = 0; i < number_of_curves; i++) */
 }

 /*
  * For each group of curves make the required face
  * and then lift it.
  */

 {
  IGRushort  add_option;
  IGRint  j, k, buf_size, array_size, depth;
  OMuint  count;
  IGRint  num_lps, cum_num_eds, num_lp_eds, cur_ed;
  struct GRlc_info  surface_for_make_face;
  struct GRid  before, made_face;
  struct EMSdlft_info  dlift_info;
  OM_S_CHANSELECT  sf_ls_chan;
  OM_S_OBJECT_LINKAGE  ls_list;
  extern IGRlong  EFrapid_make_face();

  surface_for_make_face.module_info = *md_env;
  surface_for_make_face.located_obj = *datum_surface;
  before = *top_state_before;
  add_option = NULL;

  for(i = 0 ; i < number_of_groups ; i++)
  {
    sts = EFrapid_make_face(
      	&surface_for_make_face,
      	sorted[i].number_of_curves,
      	sorted[i].curves,
      	construct_list,
      	&before,
      	my_stupid_id,
      	top_state_after,
      	&made_face,
      	msg);
    if(1 & *msg)
    {
      before = *top_state_after;

      /*
       * The following code deals with lift_face_w_draft stuff
       */

      for(j = 0 ; j < 3 ; ++j)
           dlift_info.draft_vec[j] = lift_vec[j] * sorted[i].distance;

      sts = EMmake_chanselect(EMSsubbs_to_loopset, &sf_ls_chan);
      ERROR(sts, 1, "EMmake_chanselect error");

      sts = om$get_channel_count(
		objid = made_face.objid,
            	osnum = made_face.osnum,
            	p_chanselect = &sf_ls_chan,
            	count = &count);
      ERROR(sts, 1, "get_channel_count error");
      if(!count)
      {
          sts = om$send(msg = message EMSsurface.EMmk_nat_bdry(msg, 
		&md_env->md_env, NULL),
		senderid = my_stupid_id,
                targetid = made_face.objid,
                targetos = made_face.osnum);
      	  ERROR(sts, *msg, "EMSsurface.EMmk_nat_bdry error");
      } /* if(!count) */

      sts = om$get_channel_objects(
                  objid = made_face.objid,
                  osnum = made_face.osnum, 
                  p_chanselect = &sf_ls_chan,
                  list = &ls_list, size = 1, count = &count);
      ERROR(sts, 1, "get_channel_objects error");

      depth = MAXINT;
      lp_ids = NULL;
      buf_size = num_lps = 0;

      sts = om$send(msg = message EMSloopset.EMget_loops(
		msg, EMS_OPT_ALL, &depth, &lp_ids, 
                NULL, &buf_size, &num_lps),
		senderid = my_stupid_id,
                targetid = ls_list.S_objid,
                targetos = ls_list.osnum);
      ERROR(sts, *msg, "EMSloopset.EMget_loops error");

      lps_info = (struct EMSdlft_lp_info *) om$malloc(size = num_lps *
		sizeof(struct EMSdlft_lp_info));
      if(!lps_info)
      {
     	*msg = EMS_E_NoDynamicMemory;
     	goto wrapup;	
      }

      dlift_info.num_lps = num_lps;
      dlift_info.lps_info = lps_info;
      dlift_info.sf_GRid = made_face;

      array_size = cum_num_eds = 0;
      ed_GRids = NULL;

      for(j = 0 ; j < num_lps ; ++j)
      {
        lp_info = &lps_info[j];
        lp_info->lp_GRid.objid = lp_ids[j];
        lp_info->lp_GRid.osnum = made_face.osnum;
                   
        num_lp_eds = 0;
        sts = om$send(msg = message EMSboundary.EMget_edges(
                msg, 1, EMS_OPT_NONDEG_NONSEAM, 
                NULL, &array_size, &num_lp_eds),
		senderid = my_stupid_id,
                targetid = lp_ids[j],
                targetos = made_face.osnum);
      	ERROR(sts, *msg, "EMSboundary.EMget_edges(1) error");

        cum_num_eds +=  num_lp_eds;

      } /* for */

      dlift_info.num_ed_infos = cum_num_eds;

      eds_info = (struct EMSdlft_ed_info *) om$malloc(size = cum_num_eds *
		sizeof(struct EMSdlft_ed_info));
      if(!eds_info)
      {
     	*msg = EMS_E_NoDynamicMemory;
     	goto wrapup;		
      }

      cur_ed = 0;
      for(j = 0 ; j < num_lps ; ++j)
      {
         num_lp_eds = 0;
         sts = om$send(msg = message EMSboundary.EMget_edges(
                   msg, 1, EMS_OPT_NONDEG_NONSEAM, 
                   &ed_GRids, &array_size, &num_lp_eds),
		   senderid = my_stupid_id,
                   targetid = lp_ids[j],
                   targetos = made_face.osnum);
      	 ERROR(sts, *msg, "EMSboundary.EMget_edges(2) error");

         lp_info = &dlift_info.lps_info[j];
         lp_info->eds_info = &eds_info[cur_ed];
         lp_info->num_eds = num_lp_eds;

         for(k = 0 ; k < num_lp_eds ; ++k, cur_ed++)
                eds_info[cur_ed].ed_GRid = ed_GRids[k];

      } /* for(j = 0; j < num_lps; j++) */
                 
      if(lp_ids) om$dealloc(ptr = lp_ids);
      if(ed_GRids) om$dealloc(ptr = ed_GRids);

      for(j = 0 ; j < dlift_info.num_lps ; ++j)
      { 
         lp_info = &lps_info[j];
         lp_info->is_uniform = TRUE;
         lp_info->draft_angle = draft_angle;
              
         for(k = 0 ; k < lps_info[j].num_eds ; ++k)
         {
            ed_info = &lp_info->eds_info[k];
            ed_info->draft_angle = draft_angle;
            ed_info->offset_code = BSCONSTOFF;

         } /* for */

      } /* for(j = 0; j < me->slift_info.num_lps; ++j) */
            
      dlift_info.mx_exlp_dangle = draft_angle;

      sts = om$send(msg = message EMSsurface.EMlift_face_w_draft(msg,
              	message EMSsfdlift.EMlift_face(&loc_msg, display_env,
              	construct_list, &dlift_info, EMS_DO_DISPLAY, NULL, NULL),
              	top_state_after),
	  	senderid = my_stupid_id,
          	targetid = before.objid,
          	targetos = before.osnum);
      if(!(1 & loc_msg & sts))
      {
	 *msg = 0;
	 goto wrapup;
      }

/* The following 5 lines were added fix TR 90N0601

     if(loc_msg == EMS_I_InvalidArg) 
     {
        *msg = 0;
         break; 
     }
      ERROR(sts, (*msg & loc_msg), "EMlift_face_w_draft error");

*/

      /* I modified EMSsfdlift.EMlift_face() such that the draft surface
	 will be returned in struct dlift_info.sf_GRid */

      if(i == last_face_index) *last_lift = dlift_info.sf_GRid;

      sts = om$send(msg = message EMSsfdpr.EMadd(msg, 
                &before, NULL, display_env, &add_option),
		senderid = my_stupid_id,
                targetid = top_state_after->objid,
                targetos = top_state_after->osnum);
      ERROR(sts, *msg, "EMSsfdpr.EMadd error");

      before = *top_state_after;

     } /* (1 & *msg) for EFrapid_make_face() */
     else  i = number_of_groups; /* exit for loop */
 
   } /* for(i = 0; i < number_of_groups; i++) */
 }

 /*
  * If one of the make or lifts failed then
  * attempt to recover the model to it's state prior
  * to entering this routine.
  */

 if(! (1 & *msg))
 {
   IGRushort	deactivate_option;
   IGRint	display_count, invoke_count;
   GRobjid	*display_ids;

   deactivate_option = EMS_UNDO_DELETE |  EMS_DO_DISPLAY;
   display_ids = NULL;
   display_count = invoke_count = 0;
   
   sts = om$send(msg = message EMSsurface.EMmake_active_state(
      	&loc_msg,
      	&deactivate_option,
      	md_env,
      	NULL,		/* Active ids after undo */
      	NULL,		/* Number of active ids - better be 1 */
      	NULL,		/* Space manager for memory on active ids */
      	&display_ids,	/* Used for internal management */
      	&display_count,	/* Used for internal management */
      	&invoke_count),	/* Used for internal management */
     	senderid = my_stupid_id,
     	targetid = top_state_before->objid,
     	targetos = top_state_before->osnum);
   ERROR(sts, loc_msg, "EMSsurface.EMmake_active_state error");

   *top_state_after = *top_state_before;

 } /* if(! (1 & *msg)) */

wrapup:
 if(indices)  free(indices);
 if(sorted)  free(sorted);
 if(new_curves)  free(new_curves);
 if(lps_info)  free(lps_info);
 if(eds_info)  free(eds_info);

 if(! (1 & *msg))  return(FALSE);
 else  return(TRUE);

} /* EFrapid_make_and_lift_face_w_draft */

end implementation EMSsubbs; 
