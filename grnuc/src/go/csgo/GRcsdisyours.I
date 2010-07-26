/*
Name
        GRgencs.GRdisyourself

Description
        This method displays the coordinate system object as a triad with
        X, Y, and Z characters displayed at the end of the legs and the
        name of the coordinate system displayed starting at the origin.
        Since the triad has to be scale independent, some of the display
        is done using the basic libtools. The name and the X, Y, and Z
        characters are scale and view independent whereas the triad is
        only scale independent.

Notes
        The EMS 3 label fonts were chosen to coincide with the default font
        loaded by WL.  Therefore, the call to WLload_font really just
        retrieves the font id of the already-loaded font.  There seems to be
        no other way of retrieving that default font id.  The WL default font
        is defined in exec/wl/wl_internal.h as WLI_TEXT_FONT.

History
        Kumar Talluri   10/15/86    design and implementation
        mrm             04/28/87    use a polyline for the triad
        mrm             02/24/88    use input matrix with viewport matrix,
                                    use alt_symb if specified
        mrm             03/10/88    use directory macros for name
        mrm             04/14/88    make display independent of any scale in
                                    the instance matrix
        mrm             02/08/91    fix alt_sym usage
        dhm             07/14/92    ansi conversion.
        elp             02/08/93    integrate WL usage
        mrm             11/16/93    load font for labels on demand
*/

class implementation GRgencs;

#include "wl.h"
#include "grimport.h"
#include "msdef.h"
#include "dpmacros.h"
#include "gocmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "OMmacros.h"
#include "dpgraphics.h"

#define TRIAD_LENGTH    35.0

#if defined(ENV5)
#if 0
#define TEXT_FONT       "/usr/ip32/resrc/rfont/fix.9"                // EMS 2.2
#else
#define TEXT_FONT       "/usr/ip32/resrc/rfont/drake.10"             // EMS 3
#endif
#elif defined(X11)
#if 0 
#define TEXT_FONT       "-adobe-courier-medium-o-normal--10-100-*"   // EMS 2.2
#else
#define TEXT_FONT       "-*-*-medium-*-normal-*-15-*-*-*-*-*-*-*"    // EMS 3
#endif
#endif

static WLfont font_id;
static int coordsys_font_loaded;

method GRdisyourself(IGRlong               *msg;
                     IGRshort              *mx_type;
                     IGRmatrix              matrix;
                     enum GRdpmode         *mode;
                     struct IGRaltdisplay  *alt_symb;
                     struct DP_information *sp_info;
                     OM_p_KEY_DESC          range_key)
{
    IGRchar             pathname[DI_PATH_MAX]; /* full cs pathname */
    IGRchar             name[DI_PATH_MAX];     /* cs name */
    IGRlong             i;                  /* index */
    IGRshort            ii;                 /* iindex */
    IGRlong             sts;                /* return code */
    IGRdouble           length;             /* of triad leg */
    IGRdouble           scale;              /* to apply to triad leg */
    IGRdouble           triad_coords[15];   /* triad legs in coords */
    IGRdouble           tmp_coords[15];     /* to calculate scale */
    IGRmatrix           local_to_world;     /* to take triad to world */
    struct IGRdisplay   dis_attr;           /* display attributes */
    struct IGRpolyline  polyline;           /* triad legs */
    struct DPele_header display_buffer;     /* to display triad */
    IGRboolean		is_hidden_line;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;
    

    /*
     *  if ((cs is displayable or request mode is an override)
     *          AND
     *      (level is on))
     *  then
     *      display self
     */

    is_hidden_line = sp_info->is_hidden_line;
    sp_info->is_hidden_line = FALSE;

    if (   (   (me->properties & GRIS_DISPLAYABLE)
            || (*mode == GRhdo)
            || (*mode == GRhhdo)
            || (*mode == GRheo)
            || (*mode == GRbdheo)
            || (*mode == GRbeheo))
        && (DPlevel_on(me->level, sp_info)))
    {
        if (DPis_fit(sp_info))
        {
            sts = GRprocessfit(msg, mx_type, matrix, sp_info, range_key,
                               0, 0, &my_id);
            goto finish;
        }

        /*
         *  get the local_to_world matrix -- multiply input matrix and
         *  instance data local-to-world matrix
         */

        ii = 4;
        MAmulmx(msg, &ii, &ii, &ii, matrix, me->matrix, local_to_world);

        /*
         *  set up the triad
         */

        for (i = 0; i < 15; ++i) triad_coords[i] = 0.0;   /* zero out points */

        triad_coords[0] = 1.0;       /* assign x, y, and z axis points */
        triad_coords[7] = 1.0; 
        triad_coords[14] = 1.0;

        /*
         *  transform the triad from local to world coordinates, factoring
         *  out any scale embedded in me->matrix
         */

        i = 5;
        MAptsxform(msg, &i, local_to_world, triad_coords, tmp_coords);

        for (i = 0; i < 18; i += 6)
        {
            MA2ptdis(msg, &tmp_coords[i], &tmp_coords[3], &length);

            scale =
                (TRIAD_LENGTH / length) / sp_info->gragad->vvol_viewport_scale;

            MAscalvc(msg, &scale, &triad_coords[i], &triad_coords[i]);
        }

        i = 5;
        MAptsxform(msg, &i, local_to_world, triad_coords, triad_coords);

        /*
         *  display the triad
         */

        polyline.num_points = 5;
        polyline.points = triad_coords;

        if (alt_symb)
        {
            dis_attr.color =
                alt_symb->color ? *alt_symb->color : me->display_attr.color;
            dis_attr.weight = 
                alt_symb->weight ? *alt_symb->weight : me->display_attr.weight;
            dis_attr.style = 
                alt_symb->style ? *alt_symb->style : me->display_attr.style;
        }
        else 
        {
            dis_attr = me->display_attr;
        }

        WLset_active_symbology(sp_info->win_no,
                               dis_attr.color,
                               dis_attr.style,
                               0,
                               dis_attr.weight,
                               WL_SYMB_CHANGE_COLOR |
                               WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT);

        dp$build_dis_buffer(buffer = &display_buffer,
                            type = IGRPY,
                            display_att = &dis_attr,
                            geometry = &polyline);

        dp$dispelem(msg = msg,
                    buffer = &display_buffer,
                    mode = *mode,
                    dp_info = sp_info);

        /*
         *  transform the triad from world to screen coordinates
         */

        MAptsxform(msg, &i, sp_info->gragad->wld_to_viewport, 
                   triad_coords, triad_coords);

        /*
         *  output the axis labels and the name of the coordinate system
         */

        if (!coordsys_font_loaded)
        {
            WLuint16 lscreen_no;

            WLget_window_screen(sp_info->win_no, &lscreen_no);
            WLload_font(lscreen_no, TEXT_FONT, &font_id);
            coordsys_font_loaded = 1;
        }

        WLset_active_font(sp_info->win_no, font_id);
 
        WLdraw_text(sp_info->win_no,
                    (int) triad_coords[0]+4, (int) triad_coords[1], "x", 1);
        WLdraw_text(sp_info->win_no,
                    (int) triad_coords[6]+4, (int) triad_coords[7], "y", 1);
        WLdraw_text(sp_info->win_no,
                    (int) triad_coords[12]+4, (int) triad_coords[13], "z", 1);

        sts = di$untranslate(objid = my_id,
                             osnum = OM_Gw_current_OS,
                             objname = pathname);
        if (sts & 1)
        {
#ifdef DEBUG
            printf("GRcsdisyours: displaying %s (%d)\n", pathname, my_id);
#endif
            di$split(pathname = pathname, name = name);
            i = strlen(name);
            WLdraw_text(sp_info->win_no,
                        (int) triad_coords[3]+5, (int) triad_coords[4]-15,
                        name, i);
        }

        /*
         *  ignore sts; cs may not have a name
         */

        sts = OM_S_SUCCESS;
        WLflush(sp_info->win_no);
    }

    GR_NOTIFY_LISTENERS(msg, &sts, GR_DISPLAYED);

finish:
    sp_info->is_hidden_line = is_hidden_line;

    return(sts);
}

end implementation GRgencs;
