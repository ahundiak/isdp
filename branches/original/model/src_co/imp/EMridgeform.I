/*
  FILE OVERVIEW

     This file consists methods and helper functions for FORM manipulation
     of Add/Remove material functionality. 

  HISTORY

     Rustagi            Creation
     Sanjay             Re-Wrire
     Sanjay  09/06/95   Modified the command to not to ask for "start point"
                        in case of projected finite option. 
*/

class implementation ECridge;

#ifdef DEBUG
#include <stdio.h>
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igrdef_include
#include "igrdef.h"
#endif

#ifndef igrdp_include
#include "igrdp.h"
#endif

#ifndef igewinmacros_include
#include "igewinmacros.h"
#endif

#ifndef exmacros_include
#include "exmacros.h"
#endif

#ifndef exdef_include
#include "exdef.h"
#endif

#ifndef griomacros_include
#include "griomacros.h"
#endif

#include "comisc.h"
#include "EC_M.h"
#include "EC_E.h"

/* define the gadget label for form */
#define FORM1       1 
#define FORM2       2

#define PLACE_PROTRUSION 2 
#define PLACE_CUTOUT 3

/* LABELS FOR ADD MATERIAL */

#define ADD_PROJECTED 13
#define ADD_REVOLVED  12
#define ADD_SKINNED   14
#define ADD_TO_NEXT   18
#define ADD_FROM_TO   15
#define ADD_FINITE    16
#define ADD_ONE_SIDED 20
#define ADD_SYMMETRIC 17
#define ADD_NORMAL_TOG 27

/* LABELS FOR REMOVE MATERIAL */

#define REM_PROJECTED 13
#define REM_REVOLVED  12
#define REM_SKINNED   14
#define REM_THRU_ALL  18
#define REM_THRU_NEXT 15
#define REM_FROM_TO   16
#define REM_FINITE    26
#define REM_ONE_SIDED 20
#define REM_SYMMETRIC 17
#define REM_NORMAL_TOG 27

/* for me->const_state use */
 
#define INIT 0
#define EXEC 1
#define DONE 2
#define UNDO 3
#define DNUD 4

/* command states */

#define BEGIN_STATE                       0
#define SELECT_PROFILE                    1
#define SELECT_ADD_MAT_SIDE               2
#define ENT_2nd_PT_OF_PRJ_VEC             3
#define SELECT_PRJ_SIDE                   4
#define SELECT_REV_SIDE                   5
#define SELECT_FROM_SURF_OR_REF_PLN       6
#define SELECT_TO_SURF_OR_REF_PLN         7
#define ENTER_START_PLANE                 8
#define ENTER_SYMMETRIC_DIST              9
#define ENTER_DISTANCE                    10
#define SELECT_AXIS                       11
#define ENTER_START_ANGLE                 12
#define ENT_SYMM_SWEEP_ANG                13
#define ENT_SWEEP_ANGLE                   14
#define SELECT_TRACE_CURVE                15
#define SELECT_SOLID                      16
#define FEATURE_PLACEMENT_STATE           17


#define ADD_SAVE     		1
#define ADD_CONVERT_TO_WINDOW	5

#define REM_SAVE                1
#define REM_CONVERT_TO_WINDOW   5


#ifndef DEBUG
#define DEBUG 0  /* Set to 1 if want error strings printed. */
#endif

#ifdef DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number)) \
   { \
      printf("\n%s\n", error_message); \
      goto ret_end; \
   } \
}
#else
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number))  goto ret_end; \
}
#endif

/*
  DESCRIPTION

     Given present options and state in progress and the option selected, 
     it returns the state to which it should go for the  option selected.
     The state to which it should go is an optimized state i.e. the input
     once got will not be asked for again.

  NOTES

     Whenever there is a change in the flow of the command states,  that 
     should reflect here. Anybody who changes the flow  of  the  command 
     must also change here also.
*/

int GetState
(
int        type,
int        state,
IGRboolean projected,
IGRboolean revolved,
IGRboolean skinned,
IGRboolean is_close,
IGRboolean normal,
IGRboolean tonext,
IGRboolean fromto,
IGRboolean finite,
IGRboolean symmetric,
int        option 
)
{
  int ret_state=state;
 
  if(state != BEGIN_STATE && 
     state != SELECT_PROFILE && 
     (is_close ? TRUE : (state != SELECT_ADD_MAT_SIDE))) 
  { 
    if( (type == PLACE_PROTRUSION) ? (option == ADD_PROJECTED) : (option == REM_PROJECTED) ) 
    { 
      ret_state = SELECT_PRJ_SIDE; 
    } 
    else if( (type == PLACE_PROTRUSION) ? (option == ADD_REVOLVED) : (option == REM_REVOLVED) ) 
    { 
      ret_state = SELECT_AXIS; 
    } 
    else if( (type == PLACE_PROTRUSION) ? (option == ADD_SKINNED) : (option == REM_SKINNED) ) 
    {
      if (is_close) 
        ret_state = SELECT_TRACE_CURVE; 
      else
        ret_state = SELECT_PROFILE;
    } 
    else if((type == PLACE_PROTRUSION) ? (option == ADD_NORMAL_TOG) : (option == REM_NORMAL_TOG) ) 
    { 
      if(normal) 
      {
        if (tonext)
          ret_state = SELECT_PRJ_SIDE; 
        else if (fromto)
          ret_state = SELECT_FROM_SURF_OR_REF_PLN; 
        else if (finite)
          ret_state = ENTER_START_PLANE; 
      }
      else 
        ret_state = ENT_2nd_PT_OF_PRJ_VEC; 
    } 
    else if( (type == PLACE_PROTRUSION) ? FALSE : (option == REM_THRU_ALL) ) 
    { 
      ret_state = SELECT_SOLID; 
    } 
    else if( (type == PLACE_PROTRUSION) ? (option == ADD_TO_NEXT) :  (option == REM_THRU_NEXT) ) 
    { 
      if(projected && state != SELECT_PRJ_SIDE) 
      { 
        if(normal) 
          ret_state = SELECT_PRJ_SIDE; 
        else if( state != ENT_2nd_PT_OF_PRJ_VEC ) 
          ret_state = SELECT_SOLID; 
      } 
      else if(revolved && state != SELECT_AXIS) 
      { 
        ret_state = SELECT_REV_SIDE; 
      } 
      else if(skinned && state != SELECT_TRACE_CURVE) 
      { 
        ret_state = SELECT_SOLID; 
      } 
    } 
    else if( (type == PLACE_PROTRUSION) ? (option == ADD_FROM_TO) : ( option == REM_FROM_TO ) ) 
    { 
      if(projected &&  state != ENT_2nd_PT_OF_PRJ_VEC ) 
      { 
        ret_state = SELECT_FROM_SURF_OR_REF_PLN; 
      } 
      else if(revolved && state != SELECT_AXIS) 
      { 
        ret_state = SELECT_FROM_SURF_OR_REF_PLN; 
      } 
      else if(skinned && state != SELECT_TRACE_CURVE) 
      { 
        ret_state = SELECT_FROM_SURF_OR_REF_PLN; 
      } 
    } 
    else if( (type == PLACE_PROTRUSION) ? (option == ADD_FINITE ) :  (option == REM_FINITE) ) 
    { 
      if(projected)
      { 
        ret_state = ENTER_START_PLANE; 
      } 
      else if(revolved && state != SELECT_AXIS ) 
      { 
         if(symmetric) 
           ret_state = ENT_SYMM_SWEEP_ANG; 
         else 
           ret_state = SELECT_REV_SIDE; 
      }
      else if(skinned && state != SELECT_TRACE_CURVE)
      {
         ret_state = SELECT_SOLID; 
      } 
    }
    else if( (type == PLACE_PROTRUSION) ? (option == ADD_SYMMETRIC) :  (option == REM_SYMMETRIC) )
    {
      if(projected && state != ENTER_START_PLANE)
      {
        ret_state = ENTER_START_PLANE; 
      }
      else if(revolved && state != SELECT_AXIS)
      {
        ret_state = ENT_SYMM_SWEEP_ANG;
      }
      else if(skinned && state != SELECT_TRACE_CURVE)
      {
        ret_state = SELECT_SOLID;
      }
    } 
    else if( (type == PLACE_PROTRUSION) ? (option == ADD_ONE_SIDED ) :  (option == REM_ONE_SIDED) )
    {
      if(projected && state != ENTER_START_PLANE)
      {
        ret_state = ENTER_START_PLANE; 
      }
      else if(revolved && state != SELECT_AXIS )
      {
        ret_state = SELECT_REV_SIDE;
      }
      else if(skinned && state != SELECT_TRACE_CURVE)
      {
         ret_state = SELECT_SOLID;
      }
    }
  }

  return ret_state;

} /* GetState() */


/*
  DESCRIPTION

     This method handles all the input that the gadget(s) of form received. 
     This method will be in-action whenever the options form is invoked.

  NOTES

     None.
*/

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
        IGRdouble value)
{  
 IGRlong  	sts, event_size, bufsiz;
 int 		ret, previous_state, response = EX_FORM_FINISHED;
 struct GRevent event;
 IGRboolean     modified=FALSE;

 bufsiz = sizeof(struct GRevent) - 2 * sizeof(IGRint) ;

 sts = OM_S_SUCCESS;
 event_size = sizeof(struct GRevent);

 if(form_label == 1) 
 {
  switch(gadget_label)
  {
   case ADD_PROJECTED:
    if( !me->projected )
    {
      me->projected = TRUE;
      me->revolved = FALSE;
      me->skinned = FALSE; 
      me->to_next = TRUE;
      me->thru_next = TRUE;
      me->from_to = FALSE;
      me->finite = FALSE;
      me->symmetric = FALSE;
      FIg_display(ME.ECridge->form1, ADD_NORMAL_TOG);
      FIg_erase(ME.ECridge->form1, ADD_SYMMETRIC);
      FIg_erase(ME.ECridge->form1, ADD_ONE_SIDED);
      FIg_set_state_on(ME.ECridge->form1, ADD_PROJECTED);
      FIg_set_state_off(ME.ECridge->form1, ADD_REVOLVED);
      FIg_set_state_off(ME.ECridge->form1, ADD_SKINNED);
      FIg_enable(ME.ECridge->form1, ADD_TO_NEXT);
      FIg_enable(ME.ECridge->form1, ADD_FROM_TO);
      FIg_enable(ME.ECridge->form1, ADD_FINITE);
      FIg_set_state_on(ME.ECridge->form1, ADD_TO_NEXT);
      FIg_set_state_off(ME.ECridge->form1, ADD_FROM_TO);
      FIg_set_state_off(ME.ECridge->form1, ADD_FINITE);
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_PROJECTED );
      modified = TRUE;
    }
    else
      FIg_set_state_on(ME.ECridge->form1, ADD_PROJECTED);
    break;

   case ADD_REVOLVED:
    if( !me->revolved )
    {
      me->projected = FALSE;
      me->revolved = TRUE;
      me->skinned = FALSE;
      me->finite = TRUE;
      me->symmetric = FALSE;
      me->to_next = FALSE;
      me->thru_next = FALSE;
      me->from_to = FALSE;
      FIg_erase(ME.ECridge->form1, ADD_NORMAL_TOG);
      FIg_display(ME.ECridge->form1, ADD_SYMMETRIC);
      FIg_display(ME.ECridge->form1, ADD_ONE_SIDED);
      FIg_set_state_off(ME.ECridge->form1, ADD_PROJECTED);
      FIg_set_state_on(ME.ECridge->form1, ADD_REVOLVED);
      FIg_set_state_off(ME.ECridge->form1, ADD_SKINNED);
      FIg_enable(ME.ECridge->form1, ADD_TO_NEXT);
      FIg_enable(ME.ECridge->form1, ADD_FROM_TO);
      FIg_enable(ME.ECridge->form1, ADD_FINITE);
      FIg_set_state_on(ME.ECridge->form1, ADD_FINITE);
      FIg_set_state_on(ME.ECridge->form1, ADD_ONE_SIDED);
      FIg_set_state_off(ME.ECridge->form1, ADD_SYMMETRIC);
      FIg_set_state_off(ME.ECridge->form1, ADD_TO_NEXT);
      FIg_set_state_off(ME.ECridge->form1, ADD_FROM_TO);
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_REVOLVED );
      modified = TRUE;
    }
    else
      FIg_set_state_on(ME.ECridge->form1, ADD_REVOLVED);
    break;

   case ADD_SKINNED:
    if( !me->skinned )
    {
      me->projected = FALSE;
      me->revolved = FALSE;
      me->skinned = TRUE;
      me->to_next = FALSE;
      me->thru_next = FALSE;
      me->finite = TRUE;
      me->symmetric = FALSE;
      me->from_to = FALSE;
      FIg_erase(ME.ECridge->form1, ADD_NORMAL_TOG);
      FIg_erase(ME.ECridge->form1, ADD_SYMMETRIC);
      FIg_erase(ME.ECridge->form1, ADD_ONE_SIDED);
      FIg_set_state_off(ME.ECridge->form1, ADD_PROJECTED);
      FIg_set_state_off(ME.ECridge->form1, ADD_REVOLVED);
      FIg_set_state_on(ME.ECridge->form1, ADD_SKINNED);
      FIg_set_state_off(ME.ECridge->form1, ADD_TO_NEXT);
      FIg_set_state_on(ME.ECridge->form1, ADD_FINITE);
      FIg_disable(ME.ECridge->form1, ADD_FROM_TO);
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_SKINNED );
      modified = TRUE;
    }
    else
      FIg_set_state_on(ME.ECridge->form1, ADD_SKINNED);
    break;

   case ADD_TO_NEXT:
    previous_state = me->to_next || me->thru_next;
    me->to_next = TRUE;
    me->thru_next = TRUE;
    me->from_to = FALSE;
    me->finite = FALSE;
    FIg_erase(ME.ECridge->form1, ADD_SYMMETRIC);
    FIg_erase(ME.ECridge->form1, ADD_ONE_SIDED);
    FIg_set_state_on(ME.ECridge->form1, ADD_TO_NEXT);
    FIg_set_state_off(ME.ECridge->form1, ADD_FROM_TO);
    FIg_set_state_off(ME.ECridge->form1, ADD_FINITE);
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_TO_NEXT );
      modified = TRUE;
    }
    break;

   case ADD_FROM_TO:
    previous_state = me->from_to;
    me->to_next = FALSE;
    me->thru_next = FALSE;
    me->from_to = TRUE;
    me->finite = FALSE;
    FIg_erase(ME.ECridge->form1, ADD_SYMMETRIC);
    FIg_erase(ME.ECridge->form1, ADD_ONE_SIDED);
    FIg_set_state_off(ME.ECridge->form1, ADD_TO_NEXT);
    FIg_set_state_on(ME.ECridge->form1, ADD_FROM_TO);
    FIg_set_state_off(ME.ECridge->form1, ADD_FINITE);
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_FROM_TO );
      modified = TRUE;
    }
    break;

   case ADD_FINITE:
    previous_state = me->finite;
    me->to_next = FALSE;
    me->thru_next = FALSE;
    me->from_to = FALSE;
    me->finite = TRUE;
    me->symmetric = FALSE;
    if( !me->skinned )
    {
      FIg_display(ME.ECridge->form1, ADD_SYMMETRIC);
      FIg_display(ME.ECridge->form1, ADD_ONE_SIDED);
      FIg_set_state_on(ME.ECridge->form1, ADD_ONE_SIDED);
    }
    FIg_set_state_on(ME.ECridge->form1, ADD_FINITE);
    FIg_set_state_off(ME.ECridge->form1, ADD_TO_NEXT);
    FIg_set_state_off(ME.ECridge->form1, ADD_FROM_TO);
    FIg_set_state_off(ME.ECridge->form1, ADD_SYMMETRIC);
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_FINITE );
      modified = TRUE;
    }
    break;

   case ADD_SYMMETRIC:
    previous_state = me->symmetric;
    FIg_set_state_on(ME.ECridge->form1, ADD_SYMMETRIC);
    FIg_set_state_off(ME.ECridge->form1, ADD_ONE_SIDED);
    me->symmetric = TRUE;
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state,
                         me->projected, me->revolved, me->skinned,
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_SYMMETRIC );
      modified = TRUE;
    }
    break;

   case ADD_ONE_SIDED:
    previous_state = !me->symmetric;
    FIg_set_state_on(ME.ECridge->form1, ADD_ONE_SIDED);
    FIg_set_state_off(ME.ECridge->form1, ADD_SYMMETRIC);
    me->symmetric = FALSE;
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state,
                         me->projected, me->revolved, me->skinned,
                         me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, ADD_ONE_SIDED );
      modified = TRUE;
    }
    break;

   case ADD_NORMAL_TOG:
    me->normal = !me->normal;
    ME.super_cmd->state = GetState( 
                       ME.super_cmd->mytype, ME.super_cmd->state, 
                       me->projected, me->revolved, me->skinned, 
                       me->is_close, me->normal, me->to_next, me->from_to,
                         me->finite, me->symmetric, 
                       ADD_NORMAL_TOG );
    modified = TRUE;
    break;

   case ADD_SAVE:
    FIg_set_state_off(ME.ECridge->form1, ADD_SAVE);
    ret = FIf_erase(ME.ECridge->form1);
    me->form_displayed = FALSE;
    break;

/***************
   case ADD_CONVERT_TO_WINDOW:
     FIg_set_state_off(ME.ECridge->form1, ADD_CONVERT_TO_WINDOW);
     break;
*******************/

   default:
    return (OM_E_ABORT);

  } /* switch (gadget_label) */

 } /* if (form_lable == 1) */ 

 else if(form_label == 2)
 {
  switch(gadget_label)
  {

   case REM_PROJECTED:
    if( !me->projected )
    {
      me->projected = TRUE;
      me->revolved = FALSE;
      me->skinned = FALSE; 
      me->thru_all = TRUE;
      me->to_next = FALSE;
      me->thru_next = FALSE;
      me->from_to = FALSE;
      me->finite = FALSE;
      me->symmetric = FALSE;
      FIg_display(ME.ECridge->form1, REM_NORMAL_TOG);
      FIg_erase(ME.ECridge->form1, REM_SYMMETRIC);
      FIg_erase(ME.ECridge->form1, REM_ONE_SIDED);
      FIg_set_state_on(ME.ECridge->form1, REM_PROJECTED);
      FIg_set_state_off(ME.ECridge->form1, REM_REVOLVED);
      FIg_set_state_off(ME.ECridge->form1, REM_SKINNED);
      FIg_enable(ME.ECridge->form1, REM_THRU_ALL);
      FIg_enable(ME.ECridge->form1, REM_THRU_NEXT);
      FIg_enable(ME.ECridge->form1, REM_FROM_TO);
      FIg_enable(ME.ECridge->form1, REM_FINITE);
      FIg_set_state_on(ME.ECridge->form1, REM_THRU_ALL);
      FIg_set_state_off(ME.ECridge->form1, REM_THRU_NEXT);
      FIg_set_state_off(ME.ECridge->form1, REM_FROM_TO);
      FIg_set_state_off(ME.ECridge->form1, REM_FINITE);
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                         REM_PROJECTED );
      modified = TRUE;
    }
    else
      FIg_set_state_on(ME.ECridge->form1, REM_PROJECTED);
    break;

   case REM_REVOLVED:
    if( !me->revolved )
    {
      me->projected = FALSE;
      me->revolved = TRUE;
      me->skinned = FALSE;
      me->finite = TRUE;
      me->symmetric = FALSE;
      me->thru_all = FALSE;
      me->to_next = FALSE;
      me->thru_next = FALSE;
      me->from_to = FALSE;
      FIg_erase(ME.ECridge->form1, REM_NORMAL_TOG);
      FIg_display(ME.ECridge->form1, REM_SYMMETRIC);
      FIg_display(ME.ECridge->form1, REM_ONE_SIDED);
      FIg_set_state_off(ME.ECridge->form1, REM_PROJECTED);
      FIg_set_state_on(ME.ECridge->form1, REM_REVOLVED);
      FIg_set_state_off(ME.ECridge->form1, REM_SKINNED);
      FIg_enable(ME.ECridge->form1, REM_THRU_ALL);
      FIg_enable(ME.ECridge->form1, REM_THRU_NEXT);
      FIg_enable(ME.ECridge->form1, REM_FROM_TO);
      FIg_enable(ME.ECridge->form1, REM_FINITE);
      FIg_enable(ME.ECridge->form1, REM_FINITE);
      FIg_set_state_on(ME.ECridge->form1, REM_FINITE);
      FIg_set_state_on(ME.ECridge->form1, REM_ONE_SIDED);
      FIg_set_state_off(ME.ECridge->form1, REM_THRU_ALL);
      FIg_set_state_off(ME.ECridge->form1, REM_THRU_NEXT);
      FIg_set_state_off(ME.ECridge->form1, REM_FROM_TO);
      FIg_set_state_off(ME.ECridge->form1, REM_SYMMETRIC);
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                         REM_REVOLVED );
      modified = TRUE;
    }
    else
      FIg_set_state_on(ME.ECridge->form1, REM_REVOLVED);
    break;

   case REM_SKINNED:
    if( !me->skinned )
    {
      me->projected = FALSE;
      me->revolved = FALSE;
      me->skinned = TRUE;
      me->thru_all = FALSE;
      me->to_next = FALSE;
      me->thru_next = FALSE;
      me->from_to = FALSE;
      me->finite = TRUE;
      me->symmetric = FALSE;
      FIg_erase(ME.ECridge->form1, REM_NORMAL_TOG);
      FIg_erase(ME.ECridge->form1, REM_SYMMETRIC);
      FIg_erase(ME.ECridge->form1, REM_ONE_SIDED);
      FIg_set_state_off(ME.ECridge->form1, REM_PROJECTED);
      FIg_set_state_off(ME.ECridge->form1, REM_REVOLVED);
      FIg_set_state_on(ME.ECridge->form1, REM_SKINNED);
      FIg_set_state_off(ME.ECridge->form1, REM_THRU_ALL);
      FIg_set_state_off(ME.ECridge->form1, REM_THRU_NEXT);
      FIg_set_state_on(ME.ECridge->form1, REM_FINITE);
      FIg_disable(ME.ECridge->form1, REM_THRU_ALL);
      FIg_disable(ME.ECridge->form1, REM_FROM_TO);
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                         REM_SKINNED );
      modified = TRUE;
    }
    else
      FIg_set_state_on(ME.ECridge->form1, REM_SKINNED);
    break;

   case REM_THRU_ALL:
    previous_state = me->thru_all;
    me->thru_all = TRUE;
    me->to_next = FALSE;
    me->thru_next = FALSE;
    me->finite = FALSE;
    me->from_to = FALSE;
    FIg_erase(ME.ECridge->form1, REM_SYMMETRIC);
    FIg_erase(ME.ECridge->form1, REM_ONE_SIDED);
    FIg_set_state_on(ME.ECridge->form1, REM_THRU_ALL);
    FIg_set_state_off(ME.ECridge->form1, REM_THRU_NEXT);
    FIg_set_state_off(ME.ECridge->form1, REM_FROM_TO);
    FIg_set_state_off(ME.ECridge->form1, REM_FINITE);
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                         REM_THRU_ALL );
      modified = TRUE;
    }
    break;

   case REM_THRU_NEXT:
    previous_state = me->thru_next || me->to_next;
    me->thru_all = FALSE;
    me->to_next = TRUE;
    me->thru_next = TRUE;
    me->from_to = FALSE;
    me->finite = FALSE;
    FIg_erase(ME.ECridge->form1, REM_SYMMETRIC);
    FIg_erase(ME.ECridge->form1, REM_ONE_SIDED);
    FIg_set_state_on(ME.ECridge->form1, REM_THRU_NEXT);
    FIg_set_state_off(ME.ECridge->form1, REM_THRU_ALL);
    FIg_set_state_off(ME.ECridge->form1, REM_FROM_TO);
    FIg_set_state_off(ME.ECridge->form1, REM_FINITE);
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                         REM_THRU_NEXT );
      modified = TRUE;
    }
    break;

   case REM_FROM_TO:
    previous_state = me->from_to;
    me->thru_all = FALSE;
    me->to_next = FALSE;
    me->thru_next = FALSE;
    me->from_to = TRUE;
    me->finite = FALSE;
    FIg_erase(ME.ECridge->form1, REM_SYMMETRIC);
    FIg_erase(ME.ECridge->form1, REM_ONE_SIDED);
    FIg_set_state_off(ME.ECridge->form1, REM_THRU_ALL);
    FIg_set_state_off(ME.ECridge->form1, REM_THRU_NEXT);
    FIg_set_state_on(ME.ECridge->form1, REM_FROM_TO);
    FIg_set_state_off(ME.ECridge->form1, REM_FINITE);
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                         REM_FROM_TO );
      modified = TRUE;
    }
    break;

   case REM_FINITE:
    previous_state = me->finite;
    me->thru_all = FALSE;
    me->to_next = FALSE;
    me->thru_next = FALSE;
    me->from_to = FALSE;
    me->finite = TRUE;
    me->symmetric = FALSE;
    if( !me->skinned )
    {
      FIg_display(ME.ECridge->form1, REM_SYMMETRIC);
      FIg_display(ME.ECridge->form1, REM_ONE_SIDED);
      FIg_set_state_on(ME.ECridge->form1, REM_ONE_SIDED);
    }
    FIg_set_state_on(ME.ECridge->form1, REM_FINITE);
    FIg_set_state_off(ME.ECridge->form1, REM_THRU_ALL);
    FIg_set_state_off(ME.ECridge->form1, REM_THRU_NEXT);
    FIg_set_state_off(ME.ECridge->form1, REM_FROM_TO);
    FIg_set_state_off(ME.ECridge->form1, REM_SYMMETRIC);
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state, 
                         me->projected, me->revolved, me->skinned, 
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                         REM_FINITE );
      modified = TRUE;
    }
    break;

   case REM_SYMMETRIC:
    previous_state = me->symmetric;
    FIg_set_state_on(ME.ECridge->form1, REM_SYMMETRIC);
    FIg_set_state_off(ME.ECridge->form1, REM_ONE_SIDED);
    me->symmetric = TRUE;
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state,
                         me->projected, me->revolved, me->skinned,
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric,
                         REM_SYMMETRIC );
      modified = TRUE;
    }
    break;

   case REM_ONE_SIDED:
    previous_state = !me->symmetric;
    FIg_set_state_off(ME.ECridge->form1, REM_SYMMETRIC);
    FIg_set_state_on(ME.ECridge->form1, REM_ONE_SIDED);
    me->symmetric = FALSE;
    if( !previous_state )
    {
      ME.super_cmd->state = GetState( 
                         ME.super_cmd->mytype, ME.super_cmd->state,
                         me->projected, me->revolved, me->skinned,
                         me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric,
                         REM_ONE_SIDED );
      modified = TRUE;
    }
    break;

   case REM_NORMAL_TOG:
    me->normal = !me->normal;
    ME.super_cmd->state = GetState( 
                       ME.super_cmd->mytype, ME.super_cmd->state, 
                       me->projected, me->revolved, me->skinned, 
                       me->is_close, me->normal, me->thru_next, 
                         me->from_to, me->finite, me->symmetric, 
                       REM_NORMAL_TOG );
    modified = TRUE;
    break;

   case REM_SAVE:
     FIg_set_state_off(ME.ECridge->form1, REM_SAVE);
     ret = FIf_erase(ME.ECridge->form1);
     me->form_displayed = FALSE;
     break;

   default:
    return (OM_E_ABORT);

   } /* switch (gadget_label) */

 } /* if (form_label == 2) */

 if( modified )
 {
   ex$putque( msg = msg, response = &response, byte = &bufsiz,
              buffer = (IGRchar *) &event.event );
 }

 return(sts);

} /* do_form() */


/*
  DESCRIPTION

     Function which get's command id and os and fires the form method.

  NOTES

     None.
*/ 

IGRint ECridge_process_form(form_label, gadget_label, value, form_ptr) 
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
 IGRint		stat_func=OM_S_SUCCESS, stat_OM=OM_S_SUCCESS;
 IGRlong 	msg_loc;
 GRobjid 	cmdobj;
 GRspacenum 	cmdos;

 stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 if(stat_func)
  return (OM_E_ABORT);
 stat_OM = om$send (msg = message ECridge.do_form (&msg_loc, form_label,
                gadget_label, value),
            senderid = NULL_OBJID, 
            targetid = cmdobj,
            targetos = cmdos);
 if(! (stat_OM & 1)) return (OM_E_ABORT);
 return(OM_S_SUCCESS);

} /* ECridge_process_form() */


/*
  DESCRIPTION

     This method sets up the instance data needed by the form_input method. 

  NOTES
  
     None.
*/

method status_disp()
{
  IGRlong  	sts=OM_S_SUCCESS;
  IGRint        ret;
  IGRint 	ECridge_process_form();

 if(me->const_state != DONE)
 {
   ex$message(msgnumb = EMS_I_InvkStatusFrm)
   GRstatus_display_button(1);
 }

 /* Invoke the form after the command being invoked */
 if(!me->form_displayed)
 {
    ret = FIf_set_cmd_oid_os(ME.ECridge->form1, my_id, OM_Gw_current_OS);
    if(ret) return (OM_E_ABORT);
    ret = FIf_display (ME.ECridge->form1);
    if(ret) return (OM_E_ABORT);
    me->form_displayed = TRUE;
 }

 return(sts);

} /* status_disp() */

end implementation ECridge;
