/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class represents the drawing view attachment.

History
   Gray Winn   06/20/88    Design and Coding Date.
   Jack        06/15/92    Added message GRget_put_orientation.
\*/

class specification GRdvattach (1:0) of GRdrawview;

override GRvg, GRflxown;      /* Do not inherit the instance data       */
                              /* from GRvg or GRflxown.                 */

instance GRdvattach
{
   IGRint            orientation;      /* Drawing view orientation   */
   IGRdouble         matrix[9];        /* Drawing view matrix        */
                                       /* Does not contain scale     */
   IGRdouble         origin[3];        /* Drawing view origin        */
   variable IGRchar  scale[];          /* Drawing view scale string  */
   variable IGRchar  desc[];           /* Drawing view description   */
};

from GRowner inherit GRget_channel_type, GRdrop, GRis_component_removeable,
                     GRcomponent_disconnecting, GRadd_components;

override
   GRconstruct,                  /* GRgraphics  -  class specific       */
   GRgetobjinfo,                 /* GRgraphics  -  class specific       */
   GRdisyourself,                /* GRgraphics  -  class specific       */
   GRlocate_processing,          /* GRgraphics  -  class specific       */
   GRlocate_owner,               /* GRcmpowner  -  class specific       */
   GRgenabsg,                    /* GRvg        -  class specific       */
   GRpostabsg,                   /* GRvg        -  class specific       */
   GRxform_owner,                /* GRowner     -  Transform geometry   */
   GRcopy_owner,                 /* GRowner     -  Remove description   */
   GRadd_to_active_owner,        /* GRowner     -  class specific       */
   GRcomponent_add,              /* GRdrawview  -  class specific       */
   GRcomponent_delete,           /* GRdrawview  -  class specific       */
   GRcomponent_pass,             /* GRdrawview  -  class specific       */
   GRget_component_id,           /* GRdrawview  -  class specific       */
   GRdisplay_drawing_views,      /* GRdrawview  -  class specific       */
   GRdrop_alignment,             /* GRdrawview  -  class specific       */
   GRscale_drawing_view,         /* GRdrawview  -  class specific       */
   GRget_drawview_scale,         /* GRdrawview  -  class specific       */
   GRget_drawview_description,   /* GRdrawview  -  class specific       */
   GRput_drawview_description,   /* GRdrawview  -  class specific       */
   GRget_drawview_label,         /* GRdrawview  -  class specific       */
   GRdetach_model,               /* GRdrawview  -  class specific       */
   GRattach_model,               /* GRdrawview  -  class specific       */
   GRget_model_matrix,           /* GRdrawview  -  class specific       */
   GRget_model_geometry,         /* GRdrawview  -  class specific       */
   GRcopy_drawing_view,          /* GRdrawview  -  class specific       */
   GRget_alignment_count,        /* GRdrawview  -  class specific       */
   GRget_alignment_objects,      /* GRdrawview  -  class specific       */
   GRget_drawing_attachment_id,  /* GRdrawview  -  class specific       */
   GRrealign_drawing_view,       /* GRdrawview  -  class specific       */
   GRrealign_compare;            /* GRdrawview  -  class specific       */

/*\
Name
   GRget_drawing_view_id

Description
   This method gets the object id of the drawing view.

Arguments
   *msg           IGRlong              o   completion code 
   *dv_id         GRobjid              o   The drawing view id

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRget_drawing_view_id (IGRlong *msg; struct GRid *dv_id);

/*
Name
   GRget_put_orientation

Description
   Depending on the get_put flag, this method will get the
   value of the drawing view attachment's orientation or set
   it.

Arguments
   *msg           IGRlong    o   completion code 
    get_flag      IGRint     o   1/read, 0/write
   *orient        IGRint     o   the orientation of the dr. view attachment


Return Values
   MSSUCC   -  Too simple to fail.

*/
message GRget_put_orientation(IGRlong *msg;
                              IGRint   get_flag;
                              IGRint  *orient);

end specification GRdvattach;
