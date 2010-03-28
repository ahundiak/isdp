/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        COdiscoords

Description
        This function converts a point to the active coordinate system
        and displays the coordinates in the input field.

Synopsis
        IGRint COdiscoords (msg, button, module, field)

        IGRlong             *msg;       return code
        struct EX_button    *button;    containing coordinate to display
        struct GRmd_env     *module;    of active coordinate system
        IGRint               field;     in which to display coordinate
        IGRint               just;      justification for coordinate

Return Codes
        IGRlong *msg = MSSUCC if successful (coordinates are displayed)
                     = MSFAIL if failure (coordinates are illegal
                              or too long to display)
History
        mrm     03/01/87    creation
                12/10/87    display in active system coordinates
        scw     07/13/92    ansi conversion
*/

class implementation COevgen;

#include "coimport.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"

#define BUF_SIZ     64

from GRcsmgr  import GRget_query_info;
from GRcoords import GRcvt_to_lcl_coords;

IGRint COdiscoords (msg, button, module, field, just)

IGRlong             *msg;       /* return code */
struct EX_button    *button;    /* containing coordinate to display */
struct GRmd_env     *module;    /* of active coordinate system */
IGRint               field;     /* in which to display coordinate */
IGRint               just;      /* justification for coordinate */

{
    IGRshort                i, j;               /* just variables */
    IGRshort                type;               /* of active cs */
    IGRchar                 a_buf[BUF_SIZ];     /* string for 1st coordinate */
    IGRchar                 b_buf[BUF_SIZ];     /* string for 2nd coordinate */
    IGRchar                 c_buf[BUF_SIZ];     /* string for 3rd coordinate */
    IGRchar                 out_buf[BUF_SIZ];   /* string to display */
    IGRchar                 tmp_buf[BUF_SIZ];   /* temporary string */
    IGRchar                 *a_ptr;             /* pts past leading blanks */
    IGRchar                 *b_ptr;             /* pts past leading blanks */
    IGRchar                 *c_ptr;             /* pts past leading blanks */
    IGRchar                 *a_end;             /* end of 1st coord string */
    IGRchar                 *b_end;             /* end of 2nd coord string */
    IGRchar                 *c_end;             /* end of 3rd coord string */
    IGRchar                 cstype[MAX_CS_TYPE];/* active coord sys type */
    IGRlong                 sts;                /* return code */
    IGRlong                 size;               /* for dpb call */
    IGRpoint                point;              /* to be displayed */
    struct GRid             csmgr;              /* coordinate system manager */
    struct GRid             acs;                /* active coordinate system */
    struct GRcsquery_info   *query_info;        /* contains unit types */

    *msg = MSSUCC;
    point[0] = button->x;
    point[1] = button->y;
    point[2] = button->z;

    /*
     *  get the coordinate system manager id
     */

    sts = ex$get_super (mod_id = module->md_id.objid,
                        mod_osnum = module->md_id.osnum,
                        super_name = CoordSysMgr,
                        create = TRUE,
                        super_class = CoordSysMgrClass,
                        super_id = &csmgr.objid,
                        super_osnum = &csmgr.osnum);

    if (!(sts & *msg & 1)) goto finish;

    /*
     *  get the active coordinate system type
     */

    size = sizeof (cstype);

    sts = gr$get_cs_type (msg = msg,
                          sizbuf = &size,
                          buffer = cstype,
                          nret = &size);

    if (!(sts & *msg & 1)) goto finish;

    /*
     *  get active coordinate system id & the unit types for conversion
     */

    sts = om$send (msg = message GRcsmgr.GRget_query_info
                        (msg, NULL, cstype, &i, &query_info, &acs),
                   senderid = NULL_OBJID,
                   targetid = csmgr.objid,
                   targetos = csmgr.osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COdiscoords: GRcsmgr.GRget_query_info failed\n");
#endif
        goto finish;
    }

    /*
     *  convert the world point into the active coordinate system
     */

    sts = om$send (msg = message GRcoords.GRcvt_to_lcl_coords
                        (msg, cstype, 1, point, point),
                   senderid = NULL_OBJID,
                   targetid = acs.objid,
                   targetos = acs.osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COdiscoords: GRcoords.GRcvt_to_lcl_coords failed\n");
#endif
        goto finish;
    }

    /*
     *  convert the point to working unit strings
     */

    i = 1;
    j = sizeof(IGRchar) * BUF_SIZ;

    sts = co$cvt_imp_to_alias (msg = msg,
                               unit_type = query_info[0].unit_type,
                               osnum = button->osnum,
                               working_units = point,
                               num_alias = &i,
                               num_conversions = 1,
                               field_size = &j,
                               inverse_scale_flag = GRIO_NO_SCALE,
                               cvt_list = a_buf);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COdiscoords: co$cvt_imp_to_alias #1 failed\n");
#endif
        goto finish;
    }

    sts = co$cvt_imp_to_alias (msg = msg,
                               unit_type = query_info[1].unit_type,
                               osnum = button->osnum,
                               working_units = &point[1],
                               num_alias = &i,
                               num_conversions = 1,
                               field_size = &j,
                               inverse_scale_flag = GRIO_NO_SCALE,
                               cvt_list = b_buf);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COdiscoords: co$cvt_imp_to_alias #2 failed\n");
#endif
        goto finish;
    }

    sts = co$cvt_imp_to_alias (msg = msg,
                               unit_type = query_info[2].unit_type,
                               osnum = button->osnum,
                               working_units = &point[2],
                               num_alias = &i,
                               num_conversions = 1,
                               field_size = &j,
                               inverse_scale_flag = GRIO_NO_SCALE,
                               cvt_list = c_buf);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COdiscoords: co$cvt_imp_to_alias #3 failed\n");
#endif
        goto finish;
    }

    /*
     *  determine cstype
     */

    if (!(strcmp (cstype, Rectangular)))
    {
        type = RECTANGULAR;
    }
    else if (!(strcmp (cstype, Spherical)))
    {
        type = SPHERICAL;
    }
    else if (!(strcmp (cstype, Cylindrical)))
    {
        type = CYLINDRICAL;
    }
    else
    {
        type = UNKNOWN_CS_TYPE;
    }

    /*
     *  strip blanks & units according to type
     */

    a_ptr = a_buf;                      /* initialize start pointers */
    b_ptr = b_buf;
    c_ptr = c_buf;

    while (*a_ptr == ' ') a_ptr++;      /* scan past leading blanks */
    while (*b_ptr == ' ') b_ptr++;
    while (*c_ptr == ' ') c_ptr++;

    a_end = a_ptr;                      /* initialize stop pointers */
    b_end = b_ptr;
    c_end = c_ptr;

    while (*a_end != ' ') a_end++;      /* scan past numbers */
    while (*b_end != ' ') b_end++;
    while (*c_end != ' ') c_end++;

    switch (type)
    {
        case RECTANGULAR:
            *a_end = '\0';              /* don't use x-unit */
            *b_end = '\0';              /* don't use y-unit */
            c_end++;                    /* scan past unit */
            while (*c_end != ' ') c_end++;
            *c_end = '\0';
            break;

        case SPHERICAL:
        case CYLINDRICAL:
            *a_end = '\0';
            *b_end = '\0';
            *c_end = '\0';
            sprintf (tmp_buf, "%s %s", c_ptr,
                     (type == SPHERICAL) ? "(spherical)" : "(cylindrical)");
            c_ptr = tmp_buf;
            break;

        case UNKNOWN_CS_TYPE:
        default:
            *a_end = '\0';              /* don't use any units */
            *b_end = '\0';
            *c_end = '\0';
            break;
    }

    /*
     *  update the current point form
     */

#ifndef IDRAW
    co$update_current_point_form (msg = msg);
#endif

    /*
     *  if coordinates will fit in the keyin field, put them in one
     *  buffer and echo them to the user
     */

    if ((strlen(a_ptr) + strlen(b_ptr) + strlen(c_ptr)) < sizeof (out_buf) + 4)
    {
        sprintf (out_buf, "%s, %s, %s", a_ptr, b_ptr, c_ptr);

        ex$message (field = field,
                    justification = just,
                    in_buff = out_buf);  /* does this make sense or what? */
    }
    else
    {
        *msg = MSFAIL;
    }

finish:

    return (sts & *msg & 1);
}

end implementation COevgen;
