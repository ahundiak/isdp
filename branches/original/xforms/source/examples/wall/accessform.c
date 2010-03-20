/*  void acc_form()
 *
 *  This function creates the form, modifies the button
 *  gadgets to be auto pop up, and creates some groups.
 *  
 *  NOTE:  to save some space, we are ORing the status
 *  returns of some groups of function calls and checking
 *  form an error once.  This is not neccessarily a
 *  recommendation of how to utilize the status returns;
 */

#include <stdio.h>
#include <X11/X.h>
#include <FI.h>
#include <FIdyn.h>
#include "ex1.h" 
#include "ex1gvare.h"

void notification_routine();

void acc_form()
{
  int sts;

/*
 *  Create the accessories form.  The form label is #defined
 *  in ex1.h as ACC_DESIGN_FORM.  The filename is accform.new.
 *  The name of the function which the Forms System will call
 *  when gadgets are manipulated is notification_routine.
 */
  printf("before loading in accform.new\n");
  sts = FIf_new( ACC_DESIGN_FORM, "accform.new", notification_routine, &acc_design );
  if ( chkerror( sts, "creating accessories form" ) )
    return;

  printf("after loading in accform.new\n");
/*
 *  Set the two style button to auto pop up just to save
 *  us some work.
 */
  sts = FIbtn_set_auto_pop_up_on( acc_design, LEFT_STYLE_BUTTON );
  sts |= FIbtn_set_auto_pop_up_on( acc_design, RIGHT_STYLE_BUTTON );
  if ( chkerror( sts, "setting style buttons to auto pop up" ) )
    return;

/*
 *  Create a group for the lock checklist, add all the
 *  checklist gadgets to it, and then set the group to
 *  single select.  That way, we do not have do unselect
 *  any gadgets ourselves.
 */
  sts = FIg_new( acc_design, FI_GROUP, LOCK_GROUP );
  sts |= FIg_add_to_group( acc_design, NONE_CHECKBOX, LOCK_GROUP );
  sts |= FIg_add_to_group( acc_design, STANDARD_CHECKBOX, LOCK_GROUP );
  sts |= FIg_add_to_group( acc_design, PADLOCK_CHECKBOX, LOCK_GROUP );
  sts |= FIg_add_to_group( acc_design, DEADBOLT_CHECKBOX, LOCK_GROUP );
  sts |= FIg_add_to_group( acc_design, CHAIN_CHECKBOX, LOCK_GROUP );
  sts |= FIgrp_set_single_select_on( acc_design, LOCK_GROUP );
  if ( chkerror( sts, "setting up lock group" ) )
    return;

/*
 *  Create a group for all gadgets concerned with designing
 *  the door and place them in it.  We do this so we can erase
 *  and display them with one function call.  Notice, we are
 *  including the lock group, which was set up above, into this
 *  group using FIgrp_add_to_group.
 */
  sts = FIg_new( acc_design, FI_GROUP, DOOR_GROUP );
  sts |= FIg_add_to_group( acc_design, DOOR_SUBTITLE, DOOR_GROUP );
  sts |= FIg_add_to_group( acc_design, DOOR_LOCK_SUBTITLE, DOOR_GROUP );
  sts |= FIg_add_to_group( acc_design, DOOR_LOCK_LINE1, DOOR_GROUP );
  sts |= FIg_add_to_group( acc_design, DOOR_LOCK_LINE2, DOOR_GROUP );
  sts |= FIg_add_to_group( acc_design, DOOR_LOCK_LINE3, DOOR_GROUP );
  sts |= FIg_add_to_group( acc_design, DOOR_LOCK_LINE4, DOOR_GROUP );
  sts |= FIgrp_add_to_group( acc_design, LOCK_GROUP, DOOR_GROUP );
  if ( chkerror( sts, "setting up door group" ) )
    return;

/*
 *  Just for symmetry, define a group for all gadgets associated
 *  with designing windows only.  Right now this happens to be
 *  just one text gadget.
 */  
  sts = FIg_new( acc_design, FI_GROUP, WINDOW_GROUP );
  sts |= FIg_add_to_group( acc_design, WINDOW_SUBTITLE, WINDOW_GROUP );
  if ( chkerror( sts, "setting up window group" ) )
    return;

/*
 *  Display the form and its gadgets.
 */
  sts = FIf_display ( acc_design );
  chkerror( sts, "displaying accessories form" );

}
