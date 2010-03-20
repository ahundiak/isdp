#include "stdio.h"
#include "FI.h"
#include "FIdyn.h"
#include "ex1.h" 
#include "ex1gvare.h"

void create_multi()
{
  /* Create the materials field and list */

  FIg_new( wall_design, FI_MULTI_COL, SUPPLIER_FIELD );

  std_var.attr_mask = FI_NOT_DISPLAYED; 
  std_var.xlo = 400;
  std_var.ylo = 300;
  std_var.xhi = 670;
  std_var.yhi = 394;
  std_var.bodysize = 12.0;
  std_var.fontname =  "mono821";
  std_var.off_color = FI_BLACK;
  std_var.on_color = FI_YELLOW;

  FIg_set_standard_variables( wall_design, SUPPLIER_FIELD, &std_var );

  FImcf_set_num_cols( wall_design, SUPPLIER_FIELD, 2 );
  FImcf_set_col_size( wall_design, SUPPLIER_FIELD, 0, 120, 90 );
  FImcf_set_col_size( wall_design, SUPPLIER_FIELD, 1, 120, 90 );

  FIfld_set_mode( wall_design, SUPPLIER_FIELD, 0, FI_SINGLE_SELECT );
  FIfld_set_mode( wall_design, SUPPLIER_FIELD, 1, FI_SINGLE_SELECT );

  FIfld_set_type( wall_design, SUPPLIER_FIELD, 0, FI_ALPHA );
  FIfld_set_type( wall_design, SUPPLIER_FIELD, 1, FI_ALPHA );


  FIfld_set_num_rows( wall_design, SUPPLIER_FIELD, 10 );

  FIfld_set_text( wall_design, SUPPLIER_FIELD, 0, 0, "supplier1...", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 1, 0, "supplier2...", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 2, 0, "supplier3...", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 3, 0, "supplier4...", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 4, 0, "supplier5...", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 5, 0, "supplier6...", FALSE );

  FIfld_set_text( wall_design, SUPPLIER_FIELD, 0, 1, "The Home Depot", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 1, 1, "Wilson Lumber", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 2, 1, "Walls R us!", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 3, 1, "R.C. Owens", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 4, 1, "Wicks lumber", FALSE );
  FIfld_set_text( wall_design, SUPPLIER_FIELD, 5, 1, "Tri-State", FALSE );

  FIfld_set_num_vis_rows (wall_design, SUPPLIER_FIELD, 6);

  FIg_activate( wall_design, SUPPLIER_FIELD );
}
