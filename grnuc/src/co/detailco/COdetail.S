class specification COdetail (1:0) of COtools, CEO_GSLOCATE;



#ifdef SUNOS 
#include "sunlimits.h"
#endif

#include <stdio.h>
#include <limits.h>
#include <sys/param.h>
#include <igr.h>
#include <madef.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <madef.h>
#include <dp.h>
#include <dpmacros.h>
#include <dpdef.h>
#include <grgsmacros.h>
#include <cotxmacros.h>
#include <detaildef.h>
#include <OMindex.h>
#include <ref.h>
#include <refdef.h>
#include <growner.h>
#include <grownmacros.h>
#include <csdef.h>
#include <msdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include "detailco.h"
#include "dsdef.h"
#include "ds.h"
#include "dsmacros.h"
#include <refdef.h>
#include <ref.h>
#include <griodef.h>
#include <grio.h>
#include <griomacros.h>
#include <COerr.h>


instance COdetail
{
    int                orientation;
    int                projection_angle;
    int                layer_mask_buffer [DP_NUM_OF_LEVELS/32 + 1];
    char               model [MAXPATHLEN];
    char               view [MAXPATHLEN];
    char               text_scale [80];
    char               text_name [MAXPATHLEN];
    char               name [DI_PATH_MAX];
    char               desc [80];
    IGRpoint           origin;
    IGRpoint           point1;
    IGRpoint           point2;
    IGRpoint           normal_point1;
    IGRpoint           normal_point2;
    IGRpoint           vector;
    double             scale;
    IGRmatrix          matrix;
    IGRmatrix          window_matrix;
    struct IGRlbsys    model_lbsys;
    struct GRid        window_id;
    struct GRid        cs_id;
    struct GRid        dv_id1;
    struct GRid        dv_id2;
    struct IGRline     normal;
    struct GRevent     line_base;
    struct GRrf_info   ref_info;
    struct IGRlbsys    dyn_lbsys;
    struct ds_sheet    sheet;         /* Currently selected sheet */
    struct ds_sheet    tmp_sht;       /* Subform sheet */
    struct ds_standard tmp_std;       /* Subform standard */
    int                active_form;   /* Currently active form */
    int                subform_mode;  /* Add/Modify subform */
    IGRboolean         auto_fit;      /* Fit the sheet to window? */
    IGRboolean         auto_active;   /* Make the sheet active owner? */
    struct GRid        ref_id;
    char               directory [MAXPATHLEN];
    int                option;
    int                cmd_mode;
    char               mode;
};


message set_option (int mode);

message options_mode (int mode; char * info);

message options_notify (int form_label; 
                       int gadget_label; 
                       double value; 
                       char * form_ptr);

message query_file (long * msg; char * filename);

override form_notification;

message set_defaults ();

message set_gadgets ();

message send_foreign (int mess);

message review_elements_exist ();

message review_set_gadgets ();

message review_notify ( int form_label; 
                       int gadget_label; 
                       double value; 
                       char * form_ptr );

override arg_name_to_value;

message construct_drawsheet ();

message set_active_owner ( OM_S_CHANSELECT * p_chansel );

message attach_model ( long * sts );

override dynamics;

message xcopy_drawview ( long * sts );

message construct_text ( int type );

message get_drawview_info ( long * sts );

message get_auxview_normal ( long * sts );

message get_auxview_matrix ( long * sts );

message get_principal_drawview_matrix ( long * sts );

message get_name_from_matrix ( long * sts );

message construct_default_cs ( long * sts );

message construct_x_aligned_cs ( long * sts );

message transform_cs ( long * sts );

message construct_drawview ( long * sts );

message align_drawing_views ( long * sts );

message define_drawview_orientation ( long * sts );

message build_drawview_layers ( long * sts );

message store_reference_file_scale ( long * sts );

message scale_reference_file ( long * sts );

message change_drawview_layers (int *sts; int flag);

message scale_drawview (long *sts; int flag);

message echo_mode ( long * sts );

override status_disp;

end specification COdetail;
