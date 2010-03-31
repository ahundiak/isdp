class specification NCcretp (1:0) of CEO_LOCATE;



#include "hnmill.h"
#include "hsncdef.h"

#define LOCAL_DISP_LIST_SIZE   5120
#define LOCAL_MAX_5AX_STEPS    150


instance NCcretp
{
   OM_S_OBJID           tp_id;                         /* the toolpath object */
                                                       /* id                  */

   int                  command_id;                    /* the command id      */
   IGRint               num_quadwords;                 /* the command size    */
   IGRdouble            command[LOCAL_DISP_LIST_SIZE]; /* the command itself  */
   struct GRid          curve_id;                      /* the curve osnum and */
                                                       /* objid               */

   struct IGRbsp_curve  *curve;                        /* the curve definition*/
   IGRint               num_orients;                   /* the 5-axis          */
                                                       /* orientation count   */

   IGRdouble            orient[LOCAL_MAX_5AX_STEPS];   /* the 5-axis step     */
                                                       /* orientations        */

   IGRint               tp_color_option;               /* the sub-toolpath    */
                                                       /* color mode          */

   IGRint               tp_trans_option;               /* the sub_toolpath    */
                                                       /* trans mode          */

   IGRint               tp_speed_option;               /* the sub-toolpath    */
                                                       /*  speed mode         */

   IGRint               color;                         /* the user-defined    */
                                                       /* color               */

   IGRint               trans_flag;                    /* tool translucency   */
                                                       /* mode                */

   IGRint               speed;                         /* the user-defined    */
                                                       /* speed   */
};


message create_tp_obj ( long * sts );

message del_tp_obj ( long * sts );

message print_tp_obj ( long * sts );

message get_options ( long * sts );

message get_color_options ( long * sts );

message get_trans_options ( long * sts );

message get_tool_trans ( long * sts );

message get_color_index ( long * sts );

message get_speed_options ( long * sts );

message get_speed ( long * sts );

message erase_hilight ( long * sts );

message chain_locate ( long * sts );

message classify_curve ( long * sts );

message process_curve ( long * sts );

message process_toolpath_orientation ( long * sts );

message assign_command ( long * sts );

end specification NCcretp;
