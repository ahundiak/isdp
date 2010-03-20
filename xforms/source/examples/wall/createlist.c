/*  void create_list()
 *
 */
 
#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "ex1.h" 
#include "ex1gvare.h"

void create_list()
{
  int sts;

/*
 *  Create the materials field.
 */
  sts = FIg_new( wall_design, FI_FIELD, MATERIAL_FIELD );
  chkerror( sts, "creating materials field" );

/*
 *  Set the standard variables for the materials field.
 */  
  std_var.attr_mask = FI_NOT_DISPLAYED; 
  std_var.xlo = 400;
  std_var.ylo = 200;
  std_var.xhi = 600;
  std_var.yhi = 220;
  std_var.bodysize = 15.0;
  std_var.fontname =  "mono821";
  std_var.off_color = FI_BLACK;
  std_var.on_color = FI_YELLOW;
  sts = FIg_set_standard_variables( wall_design, MATERIAL_FIELD, &std_var );
  chkerror( sts, "setting materials field variables" );

/*
 *  Set the field attributes to include a persistant list
 *  with dismiss on select and validation.
 */

  sts = FIfld_set_attr( wall_design, MATERIAL_FIELD, 0, FI_ASSOCIATED_LIST);
 

  chkerror( sts, "setting materials field attributes" );

/*
 *  Set the mode of the materials field.
 */
  sts = FIfld_set_mode( wall_design, MATERIAL_FIELD, 0, FI_APPEND );

/*
 *  Set the field to allow only alpha characters.
 */
  sts = FIfld_set_type( wall_design, MATERIAL_FIELD, 0, FI_ALPHA );
  chkerror( sts, "setting materials field type" );

/*
 *  Set the maximun number of rows in the material field.
 */
  sts = FIfld_set_max_num_rows( wall_design, MATERIAL_FIELD, 0, 1 );
  chkerror( sts, "setting materials field num rows" );


  sts = FIfld_set_list_location( wall_design, MATERIAL_FIELD, 0, 400, 230 );
  chkerror( sts, "setting list location" );

  
  sts = FIfld_set_list_num_rows( wall_design, MATERIAL_FIELD, 0, 5 );
  chkerror( sts, "setting list num rows" );

  sts = FIfld_set_list_text( wall_design, MATERIAL_FIELD, 0, 0, "wood", FALSE );
  sts |= FIfld_set_list_text( wall_design, MATERIAL_FIELD, 1, 0, "brick", FALSE );
  sts |= FIfld_set_list_text( wall_design, MATERIAL_FIELD, 2, 0, "concrete", FALSE );
  sts |= FIfld_set_list_text( wall_design, MATERIAL_FIELD, 3, 0, "steel", FALSE );
  sts |= FIfld_set_list_text( wall_design, MATERIAL_FIELD, 4, 0, "aluminum", FALSE );
  chkerror( sts, "setting list text" );

  sts = FIfld_set_list_mode( wall_design, MATERIAL_FIELD, 0, FI_SINGLE_SELECT );
  chkerror( sts, "setting list mode" );

  sts = FIfld_set_list_size( wall_design, MATERIAL_FIELD, 0, 100, 200 );
  chkerror( sts, "setting list size" );

/*
 *  Set the number of rows in the material field.
 */
  sts = FIfld_set_num_rows( wall_design, MATERIAL_FIELD, 1 );
  chkerror( sts, "setting materials field num rows" );

/*
 *  Tell Forms System to load the needed fonts and symbols.
 */

  sts = FIg_activate( wall_design, MATERIAL_FIELD );
  chkerror( sts, "activating materials field" );
}
