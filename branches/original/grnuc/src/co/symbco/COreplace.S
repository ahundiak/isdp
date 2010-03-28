class specification COreplace (1:0) of CEO_GSLOCATE;




#include "msdef.h"
#include "igrmacros.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "codef.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "grgsdef.h"
#include "growner.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "var.h"
#include "grsymdef.h"


instance COreplace
{
   IGRint                        asl_count;
   IGRint                        lsl_count;
   IGRint                        cell_count;
   IGRint                        cmpflag;
   IGRchar                       cell_name[MAX_SYMBOL_DEF_NAME];
   struct GRmd_env               asl_env;
   variable OM_S_BTREE_CONTENTS  asl_objids[];
   variable OM_S_BTREE_CONTENTS  lsl_objids[];
   variable IGRchar              lsl_sd_inuse[];
   variable struct GRobj_env     cell_objids[];
   variable IGRchar              char_array[];
};


message get_asl_env ( IGRlong *sts );

message get_all_sd_in_asl ( IGRlong *sts );

message get_all_sd_in_lsl ( IGRlong *sts );

message get_all_cells_in_module ( IGRlong *sts );

message locate_sd_in_asl_by_name ( IGRlong *sts );

message locate_sd_in_lsl_by_name ( IGRlong *sts );

message locate_cells_by_name ( IGRlong *sts );

message erase_sd ( IGRlong *sts );

message highlight_sd ( IGRlong *sts );

message draw_sd ( IGRlong *sts );

message erase_objects ( IGRlong *sts );

message draw_objects ( IGRlong *sts );

message erase_highlight ( IGRlong *sts );

message empty_channel ( IGRlong *sts );

message get_cell_names ( IGRlong *sts );

message replace_sd ( IGRlong *sts );

message replace_cells ( IGRlong *sts );

message parse_y_or_n ( IGRlong *sts );

message increment_inuse ( IGRlong *sts );

message replace_prompt ( IGRlong *sts );

message put_event_on_queue ( IGRlong *sts );

message delete_symbol_definition ( IGRlong *sts );

message delete_status ( IGRlong *sts );

message delete_prompt ( IGRlong *sts );

message save_asl ( IGRlong *sts );

message clear_symbol_symbology_properties ( IGRlong *sts );

end specification COreplace;
