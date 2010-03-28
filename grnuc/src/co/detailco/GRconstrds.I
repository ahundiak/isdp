/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRconstruct_ds

Description
   This function is used to construct a drawing sheet object.

Arguments
   *msg           IGRlong              completion code
   *mod_env       struct GRmd_env      module environment
   level          IGRshort             level
   *display       struct IGRdisplay    display info
   properties     IGRushort            properties of the drawing sheet
   name[]         IGRchar              name of the drawing sheet
   proj_angle     IGRint               projection angle (first or third)
                                       -  DS_THIRD_ANGLE
                                       -  DS_FIRST_ANGLE
   sheet_size_x   IGRdouble            sheet size in x direction
   sheet_size_y   IGRdouble            sheet size in y direction
   *origin_event  struct GRevent       the event containing the origin
   border_type    IGRint               type of attachment
                                       -  DS_CELL_LIB
                                       -  DS_REFERENCE
                                       -  DS_NOBORDER
   border_file[]  IGRchar              file name that contains border
   border_name[]  IGRchar              save view name or cell name
   desc[]         IGRchar              drawing sheet description
   *ds_id         struct GRid          the drawing sheet object id

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   06/10/88    Creation date
   SCW         07/08/92    ANSI conversion
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "grcoordsys.h"
#include "csdef.h"
#include "exmacros.h"
#include "OMindex.h"
#include "detail.h"
#include "detaildef.h"
#include "coplcmac.h"
#include "grsymmacros.h"
#include "madef.h"
#include "dsdef.h"
#include "refdef.h"
#include "ref.h"
#include "grerr.h"
#include "grsymdef.h"
#include "grsym.h"
#include "OMerrordef.h"
#include "toolco.h"

#define  GR_E_NO_SYM 4
#define  GR_E_NO_REF 6

extern IGRint COtools_access_file();
extern IGRint COtools_same_file();

extern OMuword EX_dup_os_occured;

from GRgraphics   import   GRconstruct, GRdelete;

IGRint GRconstruct_ds ( msg, 
                        mod_env, 
                        level, 
                        display, 
                        properties, 
                        name,
                        proj_angle, 
                        sheet_size_x, 
                        sheet_size_y, 
                        origin_event, 
                        border_type, 
                        border_file, 
                        border_name,
                        desc, 
                        ds_id )
    IGRlong           *msg;
    struct GRmd_env   *mod_env;
    IGRshort          level;
    struct IGRdisplay *display;   
    IGRushort         properties;
    IGRchar           name[];
    IGRint            proj_angle;
    IGRdouble         sheet_size_x;
    IGRdouble         sheet_size_y;
    struct GRevent    *origin_event;
    IGRint            border_type;
    IGRchar           border_file[];
    IGRchar           border_name[];
    IGRchar           desc[];
    struct GRid       *ds_id;
{
    IGRlong                       om_msg;
    IGRlong                       ret_msg;
    IGRlong                       one = 1;
    IGRint                        lib_flag;
    IGRint                        lib_no;
    IGRshort                      four = 4;
    IGRuint                       ref_properties;
    IGRint                        polygon_created;
    IGRint                        border_created;
    IGRchar                       tempfile[OM_K_MAXOSNAME_LEN];
    IGRshort                      matrix_type;
    IGRdouble                     angle;
    IGRdouble                     scale[3];
    IGRpoint                      point1;
    IGRpoint                      sheet_size;
    IGRpoint                      tsheet_size;
    IGRmatrix                     window_matrix;
    IGRmatrix                     inv_matrix;
    GRspacenum                    lib_osnum;
    OM_S_OBJARRAY                 objarray;
    struct GRvg_construct         const_list;
    struct GRevent                *events[2];
    struct GRevent                event2;
    struct GRid                   polygon_id;
    struct GRid                   border_id;
    struct GRid                   sdh_id;
    struct GRdrawsheet_class_attr class_attr;
    struct GRmd_env               symbol_env;
    struct IGRlbsys               lb;
    struct GRrf_info              ref_info;
    struct IGRdisplay             new_display;
    IGRint                        asl_is_border = 0;

    *msg = MSSUCC;
    lib_flag = FALSE;
    polygon_created = FALSE;
    border_created = FALSE;

    /*
     * KLUDGE: Set a global flag indicating that a dup os attachment
     *         has not occurred. This will be check after the construct.
     *         In the future construct should return OM_I_DUPLICATE_OS.
     */
    EX_dup_os_occured = 0;    

    /*
     *  Get the window informaton.
     */
    GRget_window_matrix ( &ret_msg, 
                          origin_event->event.button.osnum,
                          origin_event->event.button.objid, 
                          window_matrix, 
                          NULL );

    /*
     * Transform the sheet size and border deltas to the window coordinate
     * system.
     */
    tsheet_size[0] = sheet_size_x;
    tsheet_size[1] = sheet_size_y;
    tsheet_size[2] = 0.0;

    MAtrnmx(msg, &four, window_matrix, inv_matrix);
    MAtypemx(msg, inv_matrix, &matrix_type);
    MAoptsxform ( msg, &one, &matrix_type, inv_matrix, tsheet_size, sheet_size);

    /*
     *  Construct the block object.
     */
    events[0] = origin_event;
    events[1] = &event2;
 
    event2 = *origin_event;
    event2.event.button.x = origin_event->event.button.x + sheet_size[0];
    event2.event.button.y = origin_event->event.button.y + sheet_size[1];
    event2.event.button.z = origin_event->event.button.z + sheet_size[2];
    new_display = *display;
    new_display.weight = 0;
   
    om_msg = co$place_block ( msg = &ret_msg,
                              newflag = (IGRboolean)FALSE,
                              events = events,
                              module = mod_env,
                              symbology = &new_display,
                              level = &level,
                              grid = &polygon_id,
                              classname = "GR3dorthpoly",
                              cob_id = (OM_S_OBJID)NULL_OBJID,
                              cob_os = (GRspacenum)NULL );

    if (om_msg & 1)
    {
        polygon_created = TRUE;

        /*****************************************************************/
        /*                      Cell Library                             */
        /*****************************************************************/
        if (border_type == DS_CELL_LIB)
        {
            struct GRsymbol_lib_file asl_file;
            struct GRmd_env          asl_env;
            IGRuint                  permission;

            /*
             * Get the fullpath for the file and it's access
             * permissions.
             */
            COtool_access_file ( &permission, border_file, tempfile ); 

            /*
             * If the file exists, isn't a directory and can be read.
             */
            if ( (permission & CO_file_exists) &&
                 (permission & CO_file_reg) &&
                 (permission & CO_file_read) )
            {

                /*
                 *  See if the active symbol library is the same as the border
                 *  library if so use it.
                 */
                om_msg = gr$symget_asl_info ( msg = &ret_msg,
                                              file = &asl_file );
 
                if ( (om_msg & ret_msg & 1) &&
                     COtool_same_file(tempfile, asl_file.file_name) )
                {
                    om_msg = gr$symget_asl_env ( msg = &ret_msg,
                                                 asl_env = &asl_env );
                    asl_is_border = TRUE;
                    lib_no = asl_file.file_no;
                    lib_osnum = asl_env.md_id.osnum;
                }
                else
                {
                    /*
                     *  Read in the cell library.
                     */
                    om_msg = gr$symretrieve_cell_library ( filename = tempfile,
                                                           flag = EX_read_only, /* EX_read_write */
                                                           fstat = EX_old_module, 
                                                           file_no = &lib_no, 
                                                           mod_osnum = &lib_osnum );
                }
            }
            else if (! (permission & CO_file_exists))
                om_msg = OM_E_ABORT;

            /*
             * If the cell lib was found and opened get the cell def.
             */
            if (om_msg & ret_msg & 1)
            {
                lib_flag = TRUE;

                /*
                 *  Find the specified cell definition      
                 */
                objarray.size = sizeof (OM_S_OBJARRAY);
                objarray.tree_type = KEY_STRING;
                om_msg = gr$symsd_locate ( msg = &ret_msg,
                                           num_OS = 1, 
                                           p_OS = &lib_osnum, 
                                           sd_name = border_name,
                                           p_OBJARRAY = &objarray, 
                                           p_loc_OS = &lib_osnum );

                if ((om_msg & 1) && objarray.count)
                {
                    sdh_id.osnum = lib_osnum;
                    sdh_id.objid = objarray.array[0];

                    /*
                     *  Place the cell.
                     */
                    scale[0] = 1.0;
                    scale[1] = 1.0;
                    scale[2] = 1.0;
                    angle = 0.0;
                    symbol_env.md_id.osnum = lib_osnum;
                    symbol_env.md_id.objid = NULL_OBJID;
                    symbol_env.md_env.matrix_type = MAIDMX;
                    MAidmx(&ret_msg, symbol_env.md_env.matrix);
                    point1[0] = origin_event->event.button.x;
                    point1[1] = origin_event->event.button.y;
                    point1[2] = origin_event->event.button.z;

                    om_msg = gr$sym_gg_place ( msg = &ret_msg,
                                               origin = point1,
                                               angle = &angle,
                                               scale = scale,
                                               properties = properties,
                                               rot_matrix = window_matrix,
                                               symbol_env = &symbol_env,
                                               target_env = mod_env,
                                               sdh_id = &sdh_id,
                                               classname = "GRdvgrgrp",
                                               gg_id = &border_id);
                }
                else 
                { /* symbol not found */
                    om_msg = OM_E_ABORT;
                    *msg = GR_E_NO_SYM;
                }
            }
            else 
            { /* symbols lib not found */
                *msg = GR_E_NO_FILE;
            }

        /*****************************************************************/
        /*                       Reference File                          */
        /*****************************************************************/
        }
        else if (border_type == DS_REFERENCE)
        {
            /*
             *  Build construct arguments.
             */
            const_list.msg = msg;
            const_list.newflag = FALSE;
            const_list.env_info = mod_env;
            const_list.properties = properties;
            const_list.geometry = (IGRchar *)&lb;
            const_list.display = display;
            const_list.level = level;
            const_list.class_attr = (IGRchar *)&ref_info;
            const_list.name = NULL;

            /*
             *  Build matrix of the local bounded system.
             */
            lb.matrix[0]  =  window_matrix[0];
            lb.matrix[1]  =  window_matrix[4];
            lb.matrix[2]  =  window_matrix[8];
            lb.matrix[3]  =  origin_event->event.button.x;
            lb.matrix[4]  =  window_matrix[1];
            lb.matrix[5]  =  window_matrix[5];
            lb.matrix[6]  =  window_matrix[9];
            lb.matrix[7]  =  origin_event->event.button.y;
            lb.matrix[8]  =  window_matrix[2];
            lb.matrix[9]  =  window_matrix[6];
            lb.matrix[10] =  window_matrix[10];
            lb.matrix[11] =  origin_event->event.button.z;
            lb.matrix[12] =  window_matrix[12];
            lb.matrix[13] =  window_matrix[13];
            lb.matrix[14] =  window_matrix[14];
            lb.matrix[15] =  window_matrix[15];

            /*
             *  The diagonal points have no meaning when a clip polygon is
             *  defined or a saved view was defined or a clip polygon was
             *  specified.
             */
            lb.diag_pt1[0] = lb.diag_pt1[1] = lb.diag_pt1[2] = 
                             ((double)GRDGNLIMITS_MIN_D + 1.0);
            lb.diag_pt2[0] = lb.diag_pt2[1] = lb.diag_pt2[2] = 
                             ((double)GRDGNLIMITS_MAX_D - 1.0);

            ref_info.prism_classname   = NULL;
            ref_info.filename          = border_file;
            ref_info.named_view        = border_name;
            ref_info.description       = NULL;
            ref_info.clip_poly         = NULL;
            ref_info.scale             = NULL;
            ref_properties = GRIS_MODEL_ATTACHMENT | GRRF_IS_READ_ONLY;
            ref_info.ref_properties    = &ref_properties;

            /*
             *  Construct the reference file object.
             */   
            border_id.osnum = mod_env->md_id.osnum;
            om_msg = om$construct ( osnum = mod_env->md_id.osnum,
                                    classname = "GRreffile",
                                    msg = message GRgraphics.GRconstruct(&const_list),
                                    p_objid = &border_id.objid );
            if ( !(om_msg & 1) ) *msg = GR_E_NO_REF;
        }
        /*****************************************************************/
        /*                       No Border                               */
        /*****************************************************************/
        else if (border_type == DS_NOBORDER)
        {
            border_id.objid = NULL_OBJID;
        }

        if (om_msg & 1)
        {
            border_created = TRUE;

            /*
             *  Construct the drawing sheet.
             */
            if (proj_angle == DS_FIRST_ANGLE)
            {
                class_attr.db_class_attr.proj_angle = GR_DS_FIRST_ANGLE;
            }
            else
            {
                class_attr.db_class_attr.proj_angle = GR_DS_THIRD_ANGLE;
            }

            class_attr.db_id.objid = NULL_OBJID;
            class_attr.db_class_attr.desc = desc;
            class_attr.db_class_attr.polygon_id = polygon_id;
            class_attr.db_class_attr.border_id = border_id;

            const_list.msg = msg;
            const_list.newflag = FALSE;
            const_list.env_info = mod_env;
            const_list.properties = properties;
            const_list.geometry = NULL;
            const_list.display = NULL;
            const_list.level = NULL;
            const_list.name = name;
            const_list.class_attr = (IGRchar *)&class_attr;

            ds_id->osnum = mod_env->md_id.osnum;
            om_msg = om$construct ( osnum = mod_env->md_id.osnum,
                                    classname = "GRdrawsheet", 
                                    p_objid = &ds_id->objid,
                                    msg = message GRgraphics.GRconstruct(&const_list));
        }
    }

    if (!(om_msg & 1))
    {
        if (*msg & 1) *msg = MSFAIL;
        om_msg = OM_E_ABORT;

        if (polygon_created)
        {
            om$send ( msg = message GRgraphics.GRdelete (&ret_msg, mod_env),
                      senderid = NULL_OBJID,
                      targetid = polygon_id.objid,
                      targetos = polygon_id.osnum);
        }

        if (border_created)
        {
            if (border_id.objid != NULL_OBJID)
            {
                om$send ( msg = message GRgraphics.GRdelete (&ret_msg, mod_env),
                          senderid = NULL_OBJID,
                          targetid = border_id.objid,
                          targetos = border_id.osnum);
            }
        }
    }

    if (lib_flag && !asl_is_border) 
    {
        gr$symclose_cell_library (file_no = lib_no);
    }

    if ((om_msg & *msg & 1) && EX_dup_os_occured)
    {
        *msg = OM_I_DUPLICATE_OS;
    }

    return(om_msg);
}
end implementation Root;
