/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COcrefunc

Description
        This file contains functions used by the create plotfile commands.
*/

class implementation CEO_LOCATE;

#include "coimport.h"
#include "msdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "transerr.h"
#include "grmessage.h"
#include "pidef.h"
#include "plotmsg.h"
#ifdef INTERSCRIPT
/* #include "plot_def.h" */
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#endif

extern OMuword OPP_IGEgragad_class_id;

/*
Name
        COcreate_plotfile

Description
        This function creates a plotting metafile consisting of
        elements within the input range.

Return Values
        IGRint ()       TRUE - successful
                        FALSE - unsuccessful
        IGRlong msg     MSSUCC - successful
                        MSINARG - invalid plotfile type
                        GUREAD_ERROR - cannot create plot file
                        GUNOFILE - cannot open plot file
                        GUNOSEEDFILE - cannot open seedfile
                        GUWRITE_ERROR - cannot create plot file
                        GUELEMENT_OVERFLOW - integer overflow; elements skipped
                        GUVIEW_OVERFLOW - integer overflow; view not converted

History
        mrm     01/05/88    creation
                04/11/88    added buffer argument - returns a status message
                10/21/88    added type arg, call to create IGM-format file
                11/10/88    allow seedfile and color_table to be NULL pointers
                            in addition to pointers to NULL values
                02/17/89    added cvprism argument
                08/18/89    added cvprism and bgflood args to GUplot_OBJECT
                12/20/89    added calls for raster plotting
                09/12/91    added filter args
        scw     07/17/92    Ansi conversion
*/


#argsused
IGRint COcreate_plotfile (msg, filetype, mod, dbtype, range, window, cvprism,
                          filename, seedfile, color_table, color_index, 
                          filter_function, filter_data, buffer)

IGRlong *msg;                   /* return code */
IGRint filetype;                /* IGDS or IGM */
struct GRmd_env *mod;           /* current module information */
IGRchar *dbtype;                /* current database type */
IGRdouble *range;               /* range to plot */
struct GRid *window;            /* window associated with plot */
struct IGRcv_prism *cvprism;    /* associated with a fence */
IGRchar *filename;              /* name for plotfile */
IGRchar *seedfile;              /* plotting seedfile to use */
IGRchar *color_table;           /* IGDS color table file */
IGRint color_index;             /* for IGM background flood color */
IGRint (*filter_function)();    /* pointer to a function which will
                                   be called prior to placing each element
                                   in the plotfile */
IGRchar *filter_data;           /* pointer to data to be passed to the
                                   filter function */
IGRchar *buffer;                /* returns message which displays
                                   degree of success */

{
    IGRchar         seed[128];      /* seedfile */
    IGRchar         ctable[128];    /* color table */
    IGRint          msgnumb = 0;    /* msg number for output buffer */
    IGRlong         sts, msg2;      /* return code */
    IGRboolean      bsts;           /* boolean return code */
    struct GRid     view[8];        /* for metafile view info */
    struct GRid     clip_obj;       /* object needed for clipping to range */
#ifdef INTERSCRIPT
    struct IGEvlt   rgb_value;      /* for background flood color */
    struct IGMbg_flood_color bgf;   /* background flood color */
    struct IGMbg_flood_color *p_bgf;/* background flood color */
#endif

    sts = bsts = TRUE;
    *msg = MSSUCC;

    /*
     *  fill in view information
     */

    view[0].objid = window->objid;
    view[0].osnum = window->osnum;
    view[1].objid = NULL;           /* NULL out view id's so only on IGDS */
    view[2].objid = NULL;           /* view will be translated            */
    view[3].objid = NULL;
    view[4].objid = NULL;
    view[5].objid = NULL;
    view[6].objid = NULL;
    view[7].objid = NULL;

    /*
     *  create a temporary object for clipping
     */

    clip_obj.osnum = mod->md_id.osnum;

    sts = om$construct (classname = "LCcmd_iso",
                        osnum = clip_obj.osnum,
                        p_objid = &clip_obj.objid);

    if (!(sts & 1)) goto finish;

#ifdef DEBUG
    printf ("COcreate_plotfile: range = \n");
    printf ("\t%g, %g, %g; %g, %g, %g\n",
            range[0], range[1], range[2], range[3], range[4], range[5]);
    printf ("\t%g, %g, %g; %g, %g, %g\n",
            range[6], range[7], range[8], range[9], range[10], range[11]);
#endif

    /*
     *  call a function to translate the desired volume
     */

#ifndef IDRAW
#ifdef INTERSCRIPT
    if (filetype == PI_IGM_FILE)
    {
        p_bgf = NULL;
        if (color_index >= 0 && color_index < 256)
        {
            /* get the rgb values corresponding to the color index */

            sts = ige$get_rgb_value (log_color = color_index,
                                     rgb_value = &rgb_value,
                                     flags = 0,
                                     mod_id = mod->md_id.objid,
                                     mod_osnum = mod->md_id.osnum);
            if (sts & 1)
            {
                bgf.length = sizeof (unsigned short) * 3;
                bgf.red = rgb_value.red;
                bgf.green = rgb_value.green;
                bgf.blue = rgb_value.blue;
                p_bgf = &bgf;
            }
#ifdef DEBUG
            else
            {
                printf ("COcreate_plotfile: ige$get_rgb_value: %x\n", sts);
            }
#endif
        }

#ifdef DEBUG
        printf ("COcreate_plotfile: creating IGM metafile\n");
#endif

        sts = GUplot_OBJECT (msg, filename, mod, &clip_obj, view, range,
                             cvprism, p_bgf);
    }
    else if (filetype == PI_IGDS_FILE)
    {
#endif INTERSCRIPT
#endif IDRAW
        /* set up the seedfile and color table args */

        if (seedfile)
            strncpy (seed, seedfile, 128);
        else
            seed[0] = NULL;

        if (color_table)
            strncpy (ctable, color_table, 128);
        else
            ctable[0] = NULL;

        /* set up the auxiliary raster file */

        sts = COinitraspf (msg, filename);

        if (!(sts & 1))
        {
#ifdef DEBUG
            printf ("COcreate_plotfile: COinitraspf: %#x, %#x\n", sts, *msg);
#endif
            goto finish;
        }

#ifdef DEBUG
        printf ("COcreate_plotfile: creating IGDS metafile\n");
#endif
        sts = GUplot_IGDS (msg, filename, dbtype, mod, &clip_obj, seed,
                           view, range, cvprism, filter_function, filter_data);

        if ((sts & 1) && strlen(ctable))
        {
            bsts = GUsetmetactb (msg, filename, ctable);
        }

        /* close the raster file */

        bsts = COcloseraspf (&msg2);

#ifdef DEBUG
        if (!(bsts & 1))
        {
            printf ("COcreate_plotfile: COcloseraspf: %#x, %#x\n", bsts, msg2);
        }
#endif

#ifndef IDRAW
#ifdef INTERSCRIPT
    }
    else
    {
        *msg = MSINARG;
    }
#endif INTERSCRIPT
#endif IDRAW

    switch (*msg)
    {
      case GUsuccess:
      case MSSUCC:
        msgnumb = PI_I_MtflCrtd;
        *msg = MSSUCC;
        break;

      case GUREAD_ERROR:
        msgnumb = (bsts) ? PI_E_RdErrCantCrtMtfl : PI_E_CantRdCoTbl;
        break;

      case GUELEMENT_OVERFLOW:
        msgnumb = PI_E_IntOvfEleSkp;
        break;

      case GUVIEW_OVERFLOW:
        msgnumb = PI_E_IntOvfVwNotCnv;
        break;

      case GUNOSEEDFILE:
        msgnumb = PI_E_CantOpnSdfl;
        break;

      case GUNOFILE:
        msgnumb = PI_E_CantOpnMtfl;
        break;

      case GUCANTOPNMTFL:
        msgnumb = PI_E_CantOpenPltFl;
        break;

      case GUCANTOPNFL:
        msgnumb = PI_E_CantOpenCoTbl;
        break;

      case GUNOTPLTMTFL:
        break;

      case GUWRITE_ERROR:
        msgnumb = PI_E_CantUseCoTbl;
        break;

      default:
        msgnumb = PI_E_CantCrtMtfl;
        break;
    }

    ex$message (msgnumb = msgnumb, buff = buffer);

    /*
     *  delete the temporary clipping object
     */

    sts = om$send (msg = message Root.delete (FALSE),
                   senderid = NULL_OBJID,
                   targetid = clip_obj.objid,
                   targetos = clip_obj.osnum);

finish:

#ifdef DEBUG
    printf ("COcreate_plotfile: %s\n", buffer);
#endif

    return ((sts & 1) && (*msg == MSSUCC));
}

/*
Name
        COplot_get_window_range

Description
        This function returns the range of a window identified by either a
        data point or a keyin.

History
        mrm     03/25/92    Call MAinvmx with dimension declared as short
        TW      05/26/92    Tiesheng Wang added the perspective range code.
        scw     07/17/92    Ansi conversion
*/

IGRint COplot_get_window_range (msg, event, window, world, view)

IGRlong             *msg;
struct GRevent      *event;
struct GRid         *window;
IGRdouble           *world;
IGRdouble           *view;

{
    OMuword             win_classid;        /* class of located window */
    IGRshort            dim;                /* matrix dimension */
    IGRint              i;                  /* just a variable */
    IGRint              num_id;             /* num of ids found from keyin */
    IGRlong             size;               /* size of arguments */
    IGRint              sts;                /* return code */
    struct GRid         windows[8];         /* for keyin id's */
    struct IGRlbsys     lbsys;              /* represents window range */
    struct var_list     var_list[4];        /* for gragad inquiry */
    IGRint              gg_flags;           /* gragad flags */

    *msg = MSSUCC;
    window->objid = NULL_OBJID;

    switch (event->response)
    {
        case EX_DATA:
            window->objid = event->event.button.objid;
            window->osnum = event->event.button.osnum;
            break;

        case EX_STRING:
            num_id = 0;
            dp$get_gragad_id (msg = msg,
                              name = event->event.keyin,
                              array_size = 1,
                              numberofids = &num_id,
                              found_GRids = windows);

            if (num_id == 0) /* no windows found */
            {
                *msg = PI_F_NOWINDOW;
            }
            else /* at least one window identified */
            {
                window->objid = windows[0].objid;
                window->osnum = windows[0].osnum;
            }
            break;

        default:
            *msg = MSINARG;
            break;
    }

    if (window->objid != NULL_OBJID)
    {
        /*
         *  check for special window types (make sure window is
         *  a subclass of IGEgragad)
         */

        om$get_classid (osnum = window->osnum,
                        objid = window->objid,
                        p_classid = &win_classid);

        sts = om$is_ancestry_valid (subclassid = win_classid,
                                    superclassid = OPP_IGEgragad_class_id);

        if (sts == OM_S_SUCCESS)
        {
            /*
             *  get the translate limits in view coordinates
             */

            var_list[0].var = WLD_TO_VIEW;
            var_list[0].var_ptr = (IGRchar *)&lbsys.matrix[0];
            var_list[0].num_bytes = sizeof (lbsys.matrix);
            var_list[0].bytes_returned = &size;
            var_list[1].var = VW_VOLUME;
            var_list[1].var_ptr = (IGRchar *)view;
            var_list[1].num_bytes = sizeof (IGRmatrix);
            var_list[1].bytes_returned = &size;
            var_list[2].var = GRAGAD_FLAGS;
            var_list[2].var_ptr = (IGRchar *)&gg_flags;
            var_list[2].num_bytes = sizeof (gg_flags);
            var_list[2].bytes_returned = &size;
            var_list[3].var = END_PARAM;
   
            sts = dp$inq_set_gragad (msg = msg,
                                     osnum = window->osnum,
                                     gragad_objid = window->objid,
                                     which_error = &i,
                                     var_list = var_list);
            if (sts & *msg & 1)
            {
                /*
                 *  get the translate limits in world coordinates --
                 *  use the inverse of the world to view matrix and the
                 *  view volume to form a local bounded system, then
                 *  get the extents of the lbsys for the trans limits
                 */

                if(gg_flags & IS_PERSP)
                {
                    /* get the translate range determined by the far plane */
                    COget_persvw_range(msg,window,view,world,2);

                }
                else  /* parallel view */
                {
                    lbsys.diag_pt1[0] = view[0];
                    lbsys.diag_pt1[1] = view[1];
                    lbsys.diag_pt1[2] = view[2];
                    lbsys.diag_pt2[0] = view[3];
                    lbsys.diag_pt2[1] = view[4];
                    lbsys.diag_pt2[2] = view[5];

                    dim = 4;
                    if (MAinvmx (msg, &dim, lbsys.matrix, lbsys.matrix))
                    {
                        MAlbextents (msg, &lbsys, world, &world[3]);
                    }
                }
            }
        }
        else
        {
            *msg = PI_F_BADWINDOW;
        }
    }
    return (*msg & 1);
}

end implementation CEO_LOCATE;
