class specification IGEcolor2 (1:0) of global_class;

#ifndef BASE_EMS
#ifndef X11
#include <tools.h>
#endif
#include "wl.h"
#endif
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igecolor.h"
#include "igecolordef.h"

%undef sleep

/*   IGEcolor2 deals mostly with the logical color table and only a*/
/*few methods make changes to the hardware color table.  This object is*/
/*currently in GRNUC and establishes channels to the application color*/
/*objects.  These objects, which are stored away with the file, give*/
/*information on how the color table should be set up and what these*/
/*values represent. */

instance IGEcolor2
{
      IGRshort  num_bg_log_hl_colors;  
      variable  IGRint   bg_log_hl_colors[DEFAULT_NUM_BG_LOG_HL];  
/*
bg_log_hl_colors
                  l=num_bg_log_hl_colors        l-2 l-1 
  0   1   2   ...                               254 255 
+---+---+---+---+---+--------------------------+---+---+
|   |   |   |   |   | ...                      |   |   |
+---+---+---+---+---+--------------------------+---+---+
  bg <-------------------------------------------->  hl 
      1   2   ...                               254
*/
      IGRshort  num_names;    /* Number of names of colors */
      variable  struct IGEcol_names   names[7];   
         /* the names of named colors[24 char] and logical color index*/
      channel   { (rel_ordered, one_to_many,initial = 1, increment = 1) 
         IGEuserramp; } to_IGEuserramp;
      channel   { (rel_ordered, one_to_many,initial = 1, increment = 1) 
         APPcolor2; } to_APPcolor2;
      channel   { (one_to_many,initial = 1, increment = 1) IGEcolsup; } 
         notify;
           variable IGRdouble tolerance_pct[1];
      /* tolerance of rgb values to match another color 
         per device and possible per component*/
      variable IGRdouble gamma[3]; /* gamma value for 3 guns */

      variable char data[0]; /* this data will used as the structure IGEcolor2_data */
      /* struct IGEcolor2_data                                     */
      /* int version                                                  */
      /* int user_cube_size default,max,max-1,min+1,min               */
      /* int num_ramp_colors number of colors to try when using ramps */
   };

#ifndef BASE_EMS
   override wake_up,super_construct,debug,sleep;
   message app_con(IGRint type; GRobjid appcolor_objid; 
                 GRspacenum appcolor_osnum);

   message set_data_for_IGEcolor2(IGRshort num_colors;
         IGRint *colors;
         IGRshort num_names;
         struct IGEcol_names *names;
         IGRint num_ramp_colors);

   message configure_table(WLuint32 context_no);
   message change_clr_tbl(   IGRshort start_color; IGRshort num_bg_log_hl_colors;  
         IGRchar *bg_log_hl_colors; IGRint flags);
   message change_clr_nam(   IGRshort num_names; struct IGEcol_names *names;
         IGRint flags);
   message delete_clr_nam(   IGRshort num_names; IGRint *name_indexes);

   message read_clr_nam(   IGRshort *num_names;  struct IGEcol_names *names);
   message get_name_from_color(IGRshort color; IGRchar *name);
   message get_color_from_name(IGRchar *name; IGRshort *color);
   message get_rgb_value( IGRushort color; IGRchar *rgb_value; IGRint flags);
   message add_context(WLuint32 context_no);
   message delete_context(WLuint32 context_no);
   message get_color_functions(struct WLcontext_info *context_info; int (**cmap_color_to_index)();
      int (**cmap_color_to_rgb)(); int (**cmap_init)() );
   message set_inq_color_params(IGRint inq0_set1;IGRdouble *tolerance_pct;IGRdouble *gamma_correction;
      IGRint *num_ramp_colors;IGRint *user_cube_size);
   message remap_logical_color_table( int start_color; int num_changed_colors );
#endif

   message read_clr_tbl(   IGRshort *num_bg_log_hl_colors;  IGRchar *bg_log_hl_colors; IGRint flags);

end specification IGEcolor2;

