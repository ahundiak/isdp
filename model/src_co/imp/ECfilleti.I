/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the perform construction, 
 and perform duty methods for the fillet with
 automatic trim command.

 History

 09/01/88 : rlw : Creation Date
 09/06/88 : rlw : Fixed a problem reported by Gupta
 */

class implementation ECfillet;

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "EMSopt.h"		/* Options for make solid */
#include "EC_I.h"		/* Message keys for status strings */
#include "EC_F.h"		/* Message keys for fatal strings */

#define PRODUCTION 1

#if PRODUCTION
from EMSsfround import EMfillet_auto_trim;
#endif
from EMSsurface import EMlmround, EMgetactiveid;
from EMSsfdpr import EMadd;

method perform_construction()
{
 IGRlong	*my_msg, sts;
 GRobjid	*my_constructed_object;
/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_constructed_object = &me->constructed_object;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;
 me->have_a_constructed_object = FALSE;
/*
 * Extract all the placement information
 * from the events which were input
 */
 {
  extern	void EFextract_points();
  OMuword	space_number;
  IGRboolean	natural_normal_1, natural_normal_2;
  IGRboolean	add_surface_1_to_state_tree, add_surface_2_to_state_tree;
  IGRdouble	starting_radius, ending_radius, rho;
  IGRpoint	starting_point, ending_point;
  struct	GRid round_object, *s1, *s2;
  struct	GRmd_env *md_env;
  struct	GRlc_info *surface_1, *surface_2;

  surface_1 = &me->events[0].located_object[0];
  natural_normal_1 = surface_1->geom_parms.polygon_inx;
  s1 = &surface_1->located_obj;
  surface_2 = &me->events[2].located_object[0];
  natural_normal_2 = surface_2->geom_parms.polygon_inx;
  s2 = &surface_2->located_obj;
  EFextract_points(
   1,
   &me->events[4],
   starting_point);
  starting_radius = me->events[5].event.value;
  EFextract_points(
   1,
   &me->events[6],
   ending_point);
  if (me->events[7].response == EX_MAX_RESPONSE)
   ending_radius = starting_radius;
  else
   ending_radius = me->events[7].event.value;
  rho = me->events[8].event.value;
/*
 * The fillet must be constructed in the same object
 * space as the input surfaces.
 */
  md_env = &surface_1->module_info;
  me->construct_list.env_info = md_env;
  space_number = s1->osnum;
/*
 * Perform the round
 */
#if PRODUCTION
  sts = om$send(
    msg = message EMSsurface.EMlmround(
     my_msg,
     message EMSsfround.EMfillet_auto_trim(
      my_msg,
      md_env,
      s1->objid,
      s2->objid,
      natural_normal_1,
      natural_normal_2,
      starting_point,
      starting_radius,
      ending_point,
      ending_radius,
      rho,
      &add_surface_1_to_state_tree,
      &add_surface_2_to_state_tree,
      &me->construct_list),
     &round_object),
    targetid = s1->objid,
    targetos = space_number);
#else
  sts = 0;
#endif
  if ( ! ((1 & sts) && (1 & *my_msg)))
   {
    me->have_a_constructed_object = TRUE;
    *my_msg = MSFAIL;
    goto wrapup;
   }
/*
 * Add the round to the state tree.
 * Note that we do not need to add surface 2's
 * top state to the DPR if the surfaces are in
 * the same solid/composite surface.
 */
  {
   IGRushort    add_option = NULL;
   struct	GRid top_state_surface_1;
   struct	GRid top_state_surface_2;

   if (add_surface_1_to_state_tree)
    {
     sts = om$send(
       msg = message EMSsurface.EMgetactiveid(
        my_msg,
        &top_state_surface_1,
        NULL),
       targetid = s1->objid,
       targetos = s1->osnum);
      if (! (1 & *my_msg)) goto wrapup;
    } /* if (add_surface_1_to_state_tree) */
   if (add_surface_2_to_state_tree)
    {
     sts = om$send(
       msg = message EMSsurface.EMgetactiveid(
        my_msg,
        &top_state_surface_2,
        NULL),
       targetid = s2->objid,
       targetos = s2->osnum);
      if (! (1 & *my_msg)) goto wrapup;
    } /* if (add_surface_2_to_state_tree) */
   if (add_surface_1_to_state_tree) /* rlw - Cannot combine with above if */
    {
     sts = om$send(
       msg = message EMSsfdpr.EMadd(
        my_msg,
        &top_state_surface_1,
        NULL,
        md_env,
        &add_option),
       targetid = round_object.objid,
       targetos = round_object.osnum);
      if (! (1 & *my_msg)) goto wrapup;
    } /* if (add_surface_1_to_state_tree) */
   if (add_surface_2_to_state_tree &&
      (top_state_surface_1.objid != top_state_surface_2.objid))
    {
     sts = om$send(
       msg = message EMSsfdpr.EMadd(
        my_msg,
        &top_state_surface_2,
        NULL,
        md_env,
        &add_option),
       targetid = round_object.objid,
       targetos = round_object.osnum);
      if (! (1 & *my_msg)) goto wrapup;
    } /* if (add_surface_2_to_state_tree && ...) */
  } /* Add the round to the state tree */
/*
 * Form a solid, if the rounded surfaces form a
 * closed volume
 */
  {
   extern	IGRint EFmksolid();
   IGRushort    options;
   IGRdouble	response_data[EX_RESPONSE_DATA_SIZE / 8 + 1]; /* Aligned */
   IGRint	response;
   struct	GRevent event;
   static	IGRint Tokens[6] =
    {
     EX_BACK_UP, DATA, VALUE, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
    };

   options = EMS_CHECK_CLOSURE;
   sts = EFmksolid(
     my_msg,
     md_env,
     &me->display,
     &round_object,
     &event,
     &response,
     response_data,
     Tokens,
     options,
     "EMSslround");
    if (! (1 & *my_msg)) goto wrapup;
  } /* Form a solid, if possible */
 }
/*
 * Wrap up our work
 */
wrapup:
 if (! (1 & *my_msg))
  {
   ex$message(msgnumb = EMS_I_00002)	/* Construction failed */
   *my_msg = MSSUCC;
  }
 else
  {
   ex$message(msgnumb = EMS_I_00000)	/* Clear field */
  }
 return(OM_S_SUCCESS);
}
/*
 * Perform duty method
 */
method perform_duty()
{
 IGRlong	sts;
/*
 * Construct the desired object
 */
 sts = om$send(
   msg = message ECconstruct.perform_construction(),
   targetid = my_id);
/*
 * eof
 */
 return(sts);
}

end implementation ECfillet;
