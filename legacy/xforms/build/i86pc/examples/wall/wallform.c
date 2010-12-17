/*  void wall_form()
 *
 *  This function creates the wall form, creates a few gadgets
 *  dynamically, and sets up some groups.
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
void continuous_routine();

int wall_form()
{
  int sts = FI_SUCCESS;

/*
 *  Create the wall design form.  The form label is #defined
 *  in ex1.h as WALL_DESIGN_FORM.  The filename is wallform.new.
 *  The name of the function which the Forms System will call
 *  when gadgets are manipulated is notification_routine.
 *  Also, set the wall create flag to true.
 */
  sts = FIf_new ( WALL_DESIGN_FORM, "wallform.new", notification_routine, &wall_design );
  if ( chkerror( sts, "creating wall form" ) )
    return sts;
  wall_created = TRUE;

/*
 *  Create a group for the supplier, design accessories,
 *  and materials buttons and set the group to single
 *  select.
 */
  sts = FIg_new( wall_design, FI_GROUP, ACTION_GROUP );
  sts |= FIg_add_to_group( wall_design, SUPPLIER_BUTTON, ACTION_GROUP );
  sts |= FIg_add_to_group( wall_design, ACCESS_BUTTON, ACTION_GROUP );
  sts |= FIg_add_to_group( wall_design, MATERIAL_BUTTON, ACTION_GROUP );
  sts |= FIgrp_set_single_select_on( wall_design, ACTION_GROUP );
  chkerror( sts, "creating action group" );

/*
 *  Set the two dimension slider to display only their high
 *  and low values (we will display the current value
 *  ourself.  Set the continuous routine for the two sliders.
 */
  sts = FIg_set_display( wall_design, HEIGHT_SLIDER, FI_LOW_VALUE | FI_HIGH_VALUE );
  sts |= FIg_set_continuous_routine( wall_design, HEIGHT_SLIDER, continuous_routine );
  sts |= FIg_set_display( wall_design, LENGTH_SLIDER, FI_LOW_VALUE | FI_HIGH_VALUE );
  sts |= FIg_set_continuous_routine( wall_design, LENGTH_SLIDER, continuous_routine );
  chkerror( sts, "modifying the sliders" );

/*
 *  Creat the materials field and associated list.
 */
  create_list();

/*
 *  Create the material group and include the material subtitle
 *  and field.
 */
  sts = FIg_new( wall_design, FI_GROUP, MATERIAL_GROUP );
  sts |= FIg_add_to_group( wall_design, MATERIAL_SUBTITLE, MATERIAL_GROUP );
  sts |= FIg_add_to_group( wall_design, MATERIAL_FIELD, MATERIAL_GROUP );
  chkerror( sts, "setting up material group" );

/*
 *  Create the supplier field.
 */
  create_multi();
  
/*
 *  Create the supplier group and include the supplier subtitle,
 *  the supplier toggle and, when it finally works, the multi-
 *  column supplier field.
 */
  sts = FIg_new( wall_design, FI_GROUP, SUPPLIER_GROUP );
  sts |= FIg_add_to_group( wall_design, SUPPLIER_SUBTITLE, SUPPLIER_GROUP );
  sts |= FIg_add_to_group( wall_design, SUPPLIER_TOGGLE, SUPPLIER_GROUP );
  sts |= FIg_add_to_group( wall_design, SUPPLIER_FIELD, SUPPLIER_GROUP );
  chkerror( sts, "setting up the supplier group" );

/*
 *  Display the wall design form and set the displayed
 *  flag to TRUE.
 */
  sts = FIf_display ( wall_design );
  chkerror( sts, "displaying the wall design form" );
  wall_displayed = TRUE;
  return sts;
}
