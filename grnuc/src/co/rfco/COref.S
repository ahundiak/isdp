class specification COref (1:0) of COtools, CEO_GSLOCATE;



#include <OMindex.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DImacros.h>
#include <DIprims.h>
#include <FI.h>
#include <grerr.h>
#include <refdef.h>
#include <ref.h>
#include <referr.h>
#include <dpmacros.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"


instance COref
{
    /*
     * This is required for the following commands.
     *
     *      ATTACH REFERENCE FILE
     *      DETACH REFEFENCE FILE
     */
    char                 filename [DI_PATH_MAX];
    char                 name [DI_PATH_MAX];
    char                 view [DI_PATH_MAX];
    char                 scale [DI_PATH_MAX];
    char                 mode;
    struct GRevent          origin_event;
    int                  origin_flag;
    int                  ref_id_count,option;
    variable struct GRid    ref_id[1];
    char                 ref_dir[DI_PATH_MAX];

    /*
     * This data is required by the following commands.
     *
     * DROP REFERENCE FILE SYMBOLOGY
     * MODIFY CLIPPING POLYGON DEPTH
     */
    struct GRid      reffile;         /* Reference file */
    struct GRid      clippoly;        /* Clipping polygon to be modified */
    struct GRparms   clippoly_parms;  /* Geometric parms of clippoly */

    struct GRid      object;          /* Generic object */

    struct GRmd_env  mod_info;        /* Module information */

    long          from_window,     /* Window modify started in */
                     to_window;       /* Window modify completed in */
    IGRpoint         from_point,      /* From modify point */
                     to_point;        /* To modify point */
    char             ref_mode;
    IGRulong         ref_properties;  /* optional properties GRRF_BACKGROUND
                                         and GRRF_SHRINK_WRAP */
    int              token;
};


message construct_reference_file ( long * sts );

message options_mode (int mode; char * info);

message change_reference_filename ( long * sts );

message save_clippoly ();

message save_from_info ();

message modify_clippoly ( long * sts );

override dynamics;

message drop_ref_symbology ( long * sts );

message echo_mode ( long * sts );

message file_mode ( long * sts );

message assign_filename ( char *fname );

message assign_name ( char *fname );

message assign_scale ( char *scale );

message assign_view ( char *vname );

message assign_origin_flag ( int flag );

message assign_origin_event ();

message assign_grid ();

message assign_defaults ();

message set_gadgets ();

override status_disp;

override form_notification;

message is_associative ();

end specification COref;
