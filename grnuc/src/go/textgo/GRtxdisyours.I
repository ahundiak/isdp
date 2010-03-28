/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:        GRtext

     METHOD NAME:        GRdisyourself

     Abstract:           This implementation file loads the data
                         necessary to display a graphics object.

-----
%SC%    

    VALUE = GRdisyourself(msg,type,matrix,mode,window,alt_symb,sp_info,range_key)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   ------------------------------------
     *type        IGRshort       type of matrix 
     matrix       IGRmatrix      environment transformation matrix
     *mode        GRdpmode       the display mode 
     *window      DPwindow       the window information necessary for
                                 displaying the object
     *alt_symb    struct IGRaltdisplay
                                 structure containing alternate display
                                 attributes.
     *sp_info     DP_information special display information needed by 
                                 the display routine
     range_key    OM_p_KEY_DESC  key to range in the R-tree

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg          IGRlong         completion code:
                                     MSSUCC - successful completion
                                     DPBADMODE - bad display mode
                                     MSFAIL - failure of routine
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
        GRdiselem

     Methods:
        GRgetrang
        GRgetgeom
-----
%RL%

     RELATIONS REFERENCED:
        none.
-----
%NB%

     NOTES:

        none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     05/15/86 : Design date.
        WBC     05/15/86 : Creation date.
        WBC     12/12/86 : Revised method so it won't update the
                           range if range key isn't NULL and matrix
                           type is identity.
        DEK     07/28/88 : Modified to use dp$build_dis_buffer. Added
                           view independence.
        SCW     07/22/92 : Removed copyright header
        MSM     01/11/93 : Modified the method to use different display
                           if it has symbology override.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method gathers all the information necessary to display a text
object.

----*/
/*EH*/

class implementation GRtext;

#include   "madef.h"
#include   "msdef.h"
#include   "OMmacros.h"
#include   "dperr.h"
#include   "dp.h"
#include   "dpmacros.h"
#include   "gocmacros.h"
#include   "grimport.h"
#include   "dpdef.h"
#include   "gotextdef.h"
#include   "DPdlist.h"

#define    CROSS_SIZE_FACTOR   0.5

method GRdisyourself(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
                     enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
                     struct DP_information *sp_info; OM_p_KEY_DESC range_key)

{
    extern     GRtransrange();
    IGRboolean world;                  /* compute range in local or      */
                                       /* world coordinates              */
    IGRlong    OMreturn;               /* OM return value                */
    IGRlong    msg2;                   /* local return message           */
    IGRdouble  range[6];               /* range of text                  */
    struct     DPele_header ele_header;  /* pointer to the structure for
                                         display function                */
    struct     IGResintx    text_info; /* text information               */
    struct     IGRestx      tx_attr;   /* text specific attributes       */
    struct     IGRlbsys     lbs_geom;  /* text's lbs geometry            */
    struct     IGRdisplay   disp_attr; /* display attributes             */
    struct     DPviewinfo   view_info; /* view information               */
    IGRpoint                origin;    /* origin of text object          */
    IGRshort                flags;     /* info for display               */
    int        sts;
    int dlist_flags;

    *msg = MSSUCC;                     /* initialize return codes        */
    OMreturn = OM_S_SUCCESS;
							  /* TR 90N1761 */
    /* Added support for single element display using display lists */
    if ( !(me^^GRtext.attr.flag & EMPTY_TEXT_FLAG) )
    {
       dlist_flags = sp_info->is_update ? 0 : DP_DLIST_DISPLAY_SINGLE_ELEMENT;
       sts = DPdlist_display_element( my_id, OM_Gw_current_OS, sp_info, matrix,
                                      *type, *mode, alt_symb, range_key, dlist_flags );
       if  (1 & sts )
       {
          goto wrapup;
       }
    }

    if (((me^^GRgraphics.properties & GRIS_DISPLAYABLE) ||(*mode == GRbeheo)||
        (*mode == GRhdo) || (*mode == GRheo) || (*mode == GRhhdo)) &&
        (DPlevel_on(me->level,sp_info)))
    {
        /*
         *  get range in proper format
         */

        if ((range_key) && (*type == MAIDMX))
        {
            if (!GRtransrange(&msg2,range_key,range))
            {
                *msg = MSFAIL;
                OMreturn = OM_W_ABORT;
                goto wrapup;
            }

            if ( DPis_fit(sp_info))
            {
                ele_header.range = range;
                ele_header.level = NULL;

                dp$dispelem(msg = msg, 
                            buffer = &ele_header, 
                            mode = *mode, 
                            dp_info = sp_info);

                if ( ! (1 & *msg))
                {
                    OMreturn = OM_W_ABORT;
                }
                goto wrapup;
            }
        }
        else
        {
            world = TRUE;
            OMreturn = om$send(mode = OM_e_wrt_object,
                               msg = message GRvg.GRgetrang(&msg2,type,matrix,
                                                            &world,range),
                               senderid = my_id,
                               targetid = my_id);
            if (!(1 & OMreturn))                /* get range failed       */
            {
                *msg = MSFAIL;
                OMreturn = OM_W_ABORT;
                goto wrapup;
            }
        }
      if ((me->properties & DEHAS_OVERRIDE) && (DPis_wireframe(sp_info)))
        {
          om$send ( msg = message GRvg.DEdisyourself( msg, type, matrix, mode,
                                                      alt_symb, sp_info, &range_key ),
                    targetid = my_id );
          if (*msg == MSSUCC)
            goto wrapup;
        }


        /* get geometry of the local bounded system   */

        OMreturn = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgetgeom(&msg2,type,
                                 matrix, (IGRchar *) &lbs_geom),
                           senderid = my_id,
                           targetid = my_id);

        if (! (1 & msg2) || ! (1 & OMreturn))        /* method failed */
        {
            *msg = MSFAIL;
            OMreturn = OM_W_ABORT;
            goto wrapup;
        }

        origin[0] = lbs_geom.matrix[3];
        origin[1] = lbs_geom.matrix[7];
        origin[2] = lbs_geom.matrix[11];

        if (alt_symb)                   /* window has alternate         */
        {                               /* symbology associated with it */
            disp_attr.color = (alt_symb->color ? *alt_symb->color :
                                   me->display_attr.color);
            disp_attr.weight = (alt_symb->weight ? *alt_symb->weight :
                                   me->display_attr.weight);
            disp_attr.style = (alt_symb->style ? *alt_symb->style :
                                   me->display_attr.style);
        }
        else                            /* assign the objects symbology */
        {
            disp_attr = me->display_attr;
        }

        flags = ((me->properties & GRFILLED_DISPLAY) ? DPPOLY_FILL : 0);

        /*
         * assign element specific attributes
         */

        text_info.estx = &tx_attr;

        text_info.estx->font        = me^^GRtext.attr.font;
        text_info.estx->just        = me^^GRtext.attr.just;
        text_info.estx->width       = me^^GRtext.attr.width;
        text_info.estx->height      = me^^GRtext.attr.height;
        text_info.estx->flag        = me^^GRtext.attr.flag;
        text_info.estx->num_char    = me^^GRtext.attr.num_char;
        text_info.estx->line_spac   = me^^GRtext.attr.line_spac;
        text_info.estx->char_spac   = me^^GRtext.attr.char_spac;
        text_info.estx->text_length = me^^GRtext.attr.text_length;

        text_info.font_id           = OM_Gw_current_OS;
        text_info.flags             = 0;
        text_info.prev_font         = me^^GRtext.attr.font;
        text_info.text_string       = (IGRchar *)me^^GRtext.text_string;

        dp$build_dis_buffer(buffer = &ele_header,
                            tag = *((DPtag *) &my_id),
                            type = IGRLB,
                            flags = flags,
                            range = range,
                            level = NULL,
                            display_att = &disp_attr,
                            ele_spec_att = &text_info,
                            geometry = &lbs_geom);

        if (me^^GRgraphics.properties & GRIS_VIEW_INDEP)
        {
           dp$set_view_ind(type = ROTATION_IND,
                           point = origin,
                           dp_info = sp_info,
                           old = &view_info);

           dp$dispelem(msg = msg, 
                       buffer = &ele_header, 
                       mode = *mode, 
                       dp_info = sp_info);

           dp$reset_view_ind(dp_info = sp_info,
                             old = &view_info);
        }
        else
        {
           dp$dispelem(msg = msg, 
                       buffer = &ele_header, 
                       mode = *mode, 
                       dp_info = sp_info);

        }

        if (!(1 & *msg))
        {
            OMreturn = OM_W_ABORT;
        }
        else
        {
            if (*msg == DPSTOPDRAW)
            {
                *msg = MSSUCC;
                OMreturn =  OM_I_STOP_SENDING;
            }

            if (me^^GRtext.attr.flag & EMPTY_TEXT_FLAG)
            {
                struct    IGRpolyline  polyline, polyline2;
                struct    DPele_header polyline_buffer[2];
                IGRdouble              point[12];  /* points in cross      */
                IGRint                 num_points; /* # pts to xform       */

                /*
                 *  if this is an empty text object, display a cross at its
                 *  origin; build the buffer used in displaying the cross
                 */

                polyline.num_points = 2;
                polyline.points = point;
                ele_header.dis_att->weight = 0;
                ele_header.dis_att->style = 0;

                /*
                 *  create the "vertical" cross-piece
                 */

                point[0] = 0;
                point[1] = CROSS_SIZE_FACTOR * me^^GRtext.attr.height;
                point[2] = 0;
                point[3] = 0;
                point[4] = -point[1];
                point[5] = 0;

                dp$build_dis_buffer(buffer = polyline_buffer,
                                    type = IGRPY,
                                    display_att = ele_header.dis_att,
                                    geometry = &polyline);

                /*
                 *  create the "horizontal" cross-piece
                 */

                polyline2.num_points = 2;
                polyline2.points = &point[6];

                point[6] = CROSS_SIZE_FACTOR * me^^GRtext.attr.width;
                point[7] = 0;
                point[8] = 0;
                point[9] = -point[6];
                point[10] = 0;
                point[11] = 0;

                polyline_buffer[1] = polyline_buffer[0];
                polyline_buffer[1].geometry.polyline = &polyline2;

                /*
                 *  multiply the polyline points by the local bounded
                 *  system matrix
                 */

                num_points = 4;
                MAptsxform(&msg2,&num_points,lbs_geom.matrix,point,point);

                /*
                 * display the cross at the empty text's orgin
                 */

                if (me^^GRgraphics.properties & GRIS_VIEW_INDEP)
                {
                   dp$set_view_ind(type = ROTATION_IND,
                                   point = origin,
                                   dp_info = sp_info,
                                   old = &view_info);

                   dp$dispelem(msg = msg, 
                               buffer = polyline_buffer,
                               mode = *mode, 
                               dp_info = sp_info);

                   dp$dispelem(msg = msg, 
                               buffer = &polyline_buffer[1],
                               mode = *mode, 
                               dp_info = sp_info);

                   dp$reset_view_ind(dp_info = sp_info,
                                     old = &view_info);
                }
                else
                {

                   dp$dispelem(msg = msg, 
                               buffer = polyline_buffer,
                               mode = *mode, 
                               dp_info = sp_info);

                   dp$dispelem(msg = msg, 
                               buffer = &polyline_buffer[1],
                               mode = *mode, 
                               dp_info = sp_info);
                }
            }
        }
        GR_NOTIFY_LISTENERS(msg,&OMreturn,GR_DISPLAYED);

        if (!(OMreturn & 1))
        {
            OMreturn = OM_W_ABORT;
        }
    }

wrapup:

    return (OMreturn);
}

end implementation GRtext;
