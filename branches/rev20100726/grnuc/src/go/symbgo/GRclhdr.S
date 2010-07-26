/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRclhdr

Description
        The cell header class (GRclhdr) groups the graphics objects
        which are members of a cell.  A cell has the following
        properties:

        o  Cells may be nested to any depth.
        o  Cells may be named.
        o  Cells are not in the range tree (but the components are).
        o  Cell compononents cannot be modified.
        o  Cells are located indirectly by having a component object
           send up a message that the component object is located.

Notes
        Classes which do not wish to inherit the 3-d double instance
        data should reject the instance data of this class and override
        the GRgenabsg, GRpostabsg, GRchg_owner_properties, and
        GRget_owner_properties methods.

History
        HGW/DKM 05/30/86    Creation date and Design Date
        HGW     08/05/86    Change terminology and cleanup
        HGW     11/10/87    Changes for version 1.1  
        mrm     04/24/89    override GRlocate_processing
                09/09/91    add relative layer
*/

class specification GRclhdr (1:0) of GRlbsys, GRsymbol, GRowner;

instance GRclhdr
{
    IGRshort relative_layer;    /* layer upon which the cell was placed;     */
                                /* this value will be added to each          */
                                /* component's layer for placement and       */
                                /* replacement                               */
    IGRshort owner_properties;  /* bit 0    -  GR_ORPHAN                     */
                                /*             if set defines the group      */
                                /*             as an orphan.                 */
                                /* bit 1    -  GR_RECALCULATE_GEOM           */
                                /*             if set recalculate extents    */
                                /* bit 2,3  -  Reserved for future use.      */
                                /* bit 4-15 -  For subclass use.             */
    IGRdouble matrix[9];        /* local to world transformation matrix      */
    IGRdouble origin[3];        /* cell origin                               */
    IGRdouble diag_pt1[3];      /* range block diagonal pt 1                 */
    IGRdouble diag_pt2[3];      /* range block diagonal pt 2                 */
};

override GRvg;  /* remove the symbology and level inherited the GRvg class */

from GRlbsys inherit GRgetrang,
                     GRptproject,
                     GRlnproject,
                     GRkeypoint,
                     GRgetsize,
                     GRgetgeom,
                     GRdetplane,
                     GRprismrel,
                     GRinplane;

override
   GRgetobjinfo,              /* GRgraphics  -  class specific          */
   GRconstruct,               /* GRgraphics  -  class specific          */
   GRgenabsg,                 /* GRvg        -  class specific          */
   GRpostabsg,                /* GRvg        -  class specific          */
   GRlocate_processing,       /* GRowner     -  locate header or comps  */
   GRadd_components,          /* GRowner     -  add components to cell  */
   GRremove_components,       /* GRowner     -  remove cell components  */
   GRprismrel_owner,          /* GRowner     -  call the lbs prismrel   */
   GRxform_owner,             /* GRowner     -  Transform cell geometry */
   GRcopy_owner,              /* GRowner     -  Transform cell geometry */
   GRpost_clip_owner,         /* GRowner     -  Update geometry         */
   GRget_locate_properties,   /* GRowner     -  class specific          */
   GRchg_owner_properties,    /* GRowner     -  class specific          */
   GRreplace,                 /* GRowner     -  class specific          */
   GRget_owner_properties;    /* GRowner     -  class specific          */

end specification GRclhdr;
