class specification NCdistp (1:0) of CEO_LOCATE;



#include "gr.h"
#include "godef.h"
#include "go.h"

#include "igrtypedef.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "igrdp.h"
#include "griodef.h"
#include "grio.h"

#include "hsncdef.h"
#include "hsncmacros.h"
#include "hnmill.h"
#include "wl.h"
#include "growner.h"

#define MAX_NUM_PARTS    100
#define MAX_NUM_BGOBJS   100


instance NCdistp
{
   WLhwin_no           hwin_no;
   WLuint32            lwin_no;
   IGRint              gpipe_id;
   IGRint              vlt_no;
   IGRboolean          edgeII_mode;
   IGRchar             win_classname[OM_K_MAXCLASS_LEN];
   IGRchar             gragad_name[32];
   IGRboolean          was_shading;
   struct gragad_inst  gadget_stuff;
   struct GRid         gragad;

           /* variable length array   */
   variable IGRdouble          disp_list[HSNC_DISP_LIST_SIZE]; 

   IGRint                      num_quadwords;
   IGRchar                     filename[132];
   struct GRid                 win_ids[40];
   IGRint                      num_part_objenvs;
   struct GRobj_env            part_objenv;
   variable struct GRobj_env   part_objenvs[0];
   IGRint                      num_bg_objenvs;
   struct GRobj_env            background_objenv;
   variable struct GRobj_env   background_objenvs[0];
   struct GRobj_env            toolpath_objenv;
};


message init_env ( long * sts );

message erase_hilight ( long * sts );

message get_tp_id_from_name ( long * sts );

message classify_toolpath ( long * sts );

message verify_window ( long * sts );

message process_window ( long * sts );

message restore_window ( long * sts );

message classify_part ( long * sts );

message classify_bgobj ( long * sts );

message get_components (struct GRid **comp_ids;
                        IGRint      *num_components);

message get_bg_components ( struct GRid **comp_ids;
                            IGRint *num_components);

message process_part ( long * sts );

message process_background_objects ( long * sts );

message get_tp_commands ( long * sts );

message display_tool (struct IGRbsp_curve  *new_tool;
                    IGRdouble            rot[3][3];
                    IGRpoint             loc);

message execute_toolpath ( long * sts );

message move_tool ( IGRpoint               new_loc;
                  IGRdouble              rot[3][3];
                  struct IGRbsp_surface  *surf);

message rotate_curve (IGRdouble            rot[3][3];
                    struct IGRbsp_curve  *curve);

message execute_snap ( long * sts );

message get_object_env ( long * sts );

override debug;

end specification NCdistp;
