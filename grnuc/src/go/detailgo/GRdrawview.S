/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class represents a drawing view.  The drawing view owns
   an entity which represents the attachment information and the
   active graphics.

History
   Gray Winn   06/20/88    Design and Coding Date.
\*/

class specification GRdrawview (1:0) of GRlbsys, GRflxown;

override GRvg, GRflxown;      /* Do not inherit the instance data       */
                              /* from GRvg or GRflxown.                 */

from GRlbsys      inherit  GRgetsize, GRgetgeom;
from GRowner      inherit  GRprismrel_owner;

override
   GRconstruct,               /* GRgraphics  -  class specific          */
   GRgetobjinfo,              /* GRgraphics  -  class specific          */
   GRdisyourself,             /* GRgraphics  -  class specific          */
   GRcopy,                    /* GRgraphics  -  class specific          */
   GRlocate_owner,            /* GRcmpowner  -  class specific          */
   GRcomponent_disconnecting, /* GRcmpowner  -  class specific          */
   GRgenabsg,                 /* GRvg        -  class specific          */
   GRdrop,                    /* GRowner     -  class specific          */
   GRadd_components,          /* GRowner     -  class specific          */
   GRget_channel_type,        /* GRowner     -  class specific          */
   GRget_locate_properties,   /* GRowner     -  class specific          */
   GRadd_to_active_owner,     /* GRowner     -  class specific          */
   GRis_component_removeable, /* GRowner     -  class specific          */
   GRset_active_owner,        /* GRowner     -  class specific          */
   GRclear_active_owner;      /* GRowner     -  class specific          */

/*\
Name
   GRcomponent_add

Description
   This method is used to add a component to the drawing view object.
   The type of component being added is specified by a selector.

Arguments
   *msg        IGRlong           o   return code
   *mod_env    struct GRmd_env   i   module environment
   *comp_id    struct GRid       i   component id to add
   selector    IGRint            i   flag specifing type of component
                                       -  GR_DV_REFFILE
                                       -  GR_DV_TEXTNAME
                                       -  GR_DV_TEXTSCALE
                                       -  GR_DV_CS

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRcomponent_add (IGRlong *msg; struct GRmd_env *mod_env;
                         struct GRid *comp_id; IGRint selector);

/*\
Name
   GRcomponent_delete

Description
   This method is used to delete a component from the drawing view object.
   The type of component being deleted is specified by a selector.

Arguments
   *msg        IGRlong           o   return code
   *mod_env    struct GRmd_env   i   module environment
   selector    IGRint            i   flag specifing type of component
                                       -  GR_DV_REFFILE
                                       -  GR_DV_TEXTNAME
                                       -  GR_DV_TEXTSCALE
                                       -  GR_DV_CS

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRcomponent_delete (IGRlong *msg; struct GRmd_env *mod_env;
                            IGRint selector);

/*\
Name
   GRcomponent_pass

Description
   This method is used to pass a message to a specific component of the
   drawing view.

Arguments
   *msg        IGRlong           o   return code
   pass_msg    OM_p_MESSAGE      i   message to be passed
   selector    IGRint            i   flag specifing type of component
                                       -  GR_DV_REFFILE
                                       -  GR_DV_TEXTNAME
                                       -  GR_DV_TEXTSCALE
                                       -  GR_DV_CS

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRcomponent_pass (IGRlong *msg; OM_p_MESSAGE pass_msg;
                          IGRint selector);

/*\
Name
   GRget_component_id

Description
   This method is used to get the objet id of the drawing view components.

Arguments
   *msg        IGRlong           o   return code
   selector    IGRint            i   flag specifing type of component
                                       -  GR_DV_REFFILE
                                       -  GR_DV_TEXTNAME
                                       -  GR_DV_TEXTSCALE
                                       -  GR_DV_CS
   count       IGRint            i   size of arrays
   ids[]       struct GRid       o   an array of ids
   types[]     IGRint            o   an array containing the type of ids
                                       -  GR_DV_REFFILE
                                       -  GR_DV_TEXTNAME
                                       -  GR_DV_TEXTSCALE
                                       -  GR_DV_CS

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRget_component_id (IGRlong *msg; IGRint selector; IGRint count;
                            struct GRid ids[]; IGRint types[]);

/*\
Name
   GRdisplay_drawing_views

Description
   This method displays all drawing views associated with this
   drawing view.

Arguments
   *msg           IGRlong           o   return code
   *matrix_type   IGRshort          i   matrix type
   matrix         IGRmatrix         i   display matrix
   *dpmode        enum GRdpmode     i   display mode
   *display_id    struct GRid       i   display object
   display_flag   IGRint            i   if 1 display drawing view
                                        if 0 display drawing attachment

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRdisplay_drawing_views (IGRlong *msg; IGRshort *matrix_type;
                                 IGRmatrix matrix; enum GRdpmode *dpmode;
                                 struct GRid *display_id; 
                                 IGRint display_flag);

/*\
Name
   GRdrop_alignment

Description
   This method drops the drawing view alignment between all drawing
   views.

Arguments
   *msg           IGRlong           o   return code

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRdrop_alignment (IGRlong *msg);

/*\
Name
   GRscale_drawing_view

Description
   This method scales a drawing view.  The drawing view scale is replaced
   by the new drawing view scale.

Arguments
   *msg           IGRlong           o   return code
   *mod_env       struct GRmd_env   i   module environment
   *flag          IGRint            i   if 0 scale about origin
                                        if 1 scale about point
   *scale         IGRchar           i   scale string
   point          IGRpoint          i   point to scale about

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRscale_drawing_view (IGRlong *msg; struct GRmd_env *mod_env;
                              IGRint *flag; IGRchar *scale; 
                              IGRpoint point);

/*\
Name
   GRget_drawview_scale

Description
   This method returns the scale of the drawing view.

Arguments
   *msg           IGRlong           o   return code
   *mod_env       struct GRmd_env   i   module environment
   *scale_string  IGRchar           o   scale string
   *scale         IGRdouble         o   x,y,z scale values

Notes
   Either scale_string or scale can be NULL.
   
Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRget_drawview_scale (IGRlong *msg; struct GRmd_env *mod_env;
                              IGRchar *scale_string; IGRdouble *scale);

/*\
Name
   GRget_drawview_description

Description
   This method returns the description of the drawing view.

Arguments
   *msg           IGRlong           o   return code
   *desc          IGRchar           o   description string

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRget_drawview_description (IGRlong *msg; IGRchar *desc);

/*\
Name
   GRput_drawview_description

Description
   This method puts a description into the drawing view.

Arguments
   *msg           IGRlong           o   return code
   *desc          IGRchar           i   description string

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRput_drawview_description (IGRlong *msg; IGRchar *desc);

/*\
Name
   GRget_drawview_label

Description
   This method returns the label of the drawing view.

Arguments
   *msg           IGRlong           o   return code
   *label         IGRchar           o   label string

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRget_drawview_label (IGRlong *msg; IGRchar *label);

/*\
Name
   GRdetach_model

Description
   This method detaches a model from teh drawing view.

Arguments
   *msg           IGRlong           o   return code
   *mod_env       struct GRmd_env   i   module environment

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRdetach_model (IGRlong *msg; struct GRmd_env *mod_env);

/*\
Name
   GRattach_model

Description
   This method attaches a model to the drawing view.

Arguments
   *msg              IGRlong           o   return code
   *mod_env          struct GRmd_env   i   module environment
   *filename         IGRchar           i   model file name
   *saveview_name    IGRchar           i   model save view name
   graphic_props     IGRint            i   graphic properties
   reference_props   IGRint            i   reference file properties
   level             IGRchar           i   reference file level
   *display          struct IGRdisplay i   reference file display info
                                          
Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRattach_model (IGRlong *msg; struct GRmd_env *mod_env; 
                        IGRchar *filename; IGRchar *saveview_name;
                        IGRint graphic_props; IGRint reference_props;
                        IGRshort level; struct IGRdisplay *display);

/*\
Name
   GRget_model_matrix

Description
   This method is used to generate a matrix which defines the orientation
   of the drawing view with respect to the model.

Arguments
   *msg           IGRlong           o   return code
   *mod_env       struct GRmd_env   i   module environment
   no_scale_flag  IGRint            i   flag signifing whether to remove
                                        scale from the matrix.
   matrix         IGRmatrix         o   matrix defining model coordinates

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRget_model_matrix (IGRlong *msg; struct GRmd_env *mod_env;
                            IGRint no_scale_flag; IGRmatrix matrix);

/*\
Name
   GRget_model_geometry

Description
   This method is used to generate the local bounded system which 
   represents the local bounded system of the model.

Arguments
   *msg           IGRlong           o   return code
   *mod_env       struct GRmd_env   i   module environment
   *lb            struct IGRlbsys   o   local bounded system (model volume)

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRget_model_geometry (IGRlong *msg; struct GRmd_env *mod_env;
                              struct IGRlbsys *lb);

/*\
Name
   GRcopy_drawing_view

Description
   This method is used to copy a drawing view.

Arguments
   *msg           IGRlong              o   completion code 
   *mod_env       struct GRmd_env      i   The module environment
   *target_env    struct GRmd_env      i   The target environment
   *dv_id         GRobjid              o   The new drawing view

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRcopy_drawing_view (IGRlong *msg; struct GRmd_env *mod_env;
                             struct GRmd_env *target_env; GRobjid *dv_id);

/*\
Name
   GRget_drawing_attachment_id

Description
   This method gets the object id of the drawing attachment.

Arguments
   *msg           IGRlong              o   completion code 
   *da_id         GRobjid              o   The drawing attachment id

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRget_drawing_attachment_id (IGRlong *msg; struct GRid *da_id);

/*\
Name
   GRget_projection_angle

Description
   This method returns the projection angle.

Arguments
   *msg           IGRlong              o   completion code 
   *angle         IGRint               o   projection angle
                                           -  GR_DS_FIRST_ANGLE
                                           -  GR_DS_THIRD_ANGLE

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRget_projection_angle (IGRlong *msg; IGRint *angle);

/*\
Name
   GRget_alignment_count

Description
   This method returns the number of drawing views aligned with this
   drawing view.

Arguments
   *msg           IGRlong              o   completion code 
   *count         IGRint               o   number of drawing views aligned

Notes
   Initialize count to zero

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRget_alignment_count (IGRlong *msg; IGRint *count);

/*\
Name
   GRget_alignment_objects

Description
   This method returns the drawing views aligned with this drawing view.

Arguments
   *msg           IGRlong              o   completion code 
   size           IGRint               i   number of GRids
   *count         IGRint               o   number of GRids returned
   objects[]      struct GRid          o   the drawing views

Notes
   Initialize count to zero

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRget_alignment_objects (IGRlong *msg; IGRint size; IGRint *count;
                                 struct GRid objects[]);

/*\
Name
   GRrealign_drawing_view

Description
   This method realigns a drawing view with another drawing view.

Arguments
   *msg              IGRlong              o   completion code
   *mod_env          struct GRmd_env      i   module environment
   *window_matrix    IGRdouble            i   window rotation matrix
   *dv_id            struct GRid          i   drawing view object id

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRrealign_drawing_view (IGRlong *msg; struct GRmd_env *mod_env;
                                IGRdouble *window_matrix; 
                                struct GRid *dv_id);

/*\
Name
   GRrealign_compare

Description
   This method compares the informatin from one drawing view to its 
   information to see if the drawing views can be aligned.

Arguments
   *msg              IGRlong              o   completion code
   *mod_env          struct GRmd_env      i   module environment
   *orientation      IGRint               i   orientation
   *filename         IGRchar              i   model filename 
   *saveview         IGRchar              i   model save view
   *scale            IGRchar              i   scale string

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRrealign_compare (IGRlong *msg; struct GRmd_env *mod_env;
                           IGRint *orientation; IGRchar *filename;
                           IGRchar *saveview; IGRchar *scale);


/*
Name
   GRdv_coord_sys_display


Description
   This method will find out if the tangent edge display for
   this drawing view is on or off.  If it is off, the display
   for it's coordinate system will be changed.  Increase the
   weight and change the style.  The restore parm is used to
   specify the call is to restore the c.s. display.

Arguments
   *msg           IGRlong          completion code 
    style         IGRint           new style for the coordinate system   
    weight        IGRint           new weight for the coordinate system
   *md_env        struct GRmd_env  module environment to display in
   *window        struct GRid      window the dv was located in
    flag          IGRint           what to do; defined in detaildef.h


History
   Jack  07/02/92  Creation

*/
message GRdv_coord_sys_display(IGRlong *msg;
                               IGRuchar  style;
                               IGRuchar  weight;
                               struct GRmd_env *md_env;
                               struct GRid *window;
                               IGRint  flag);


/*
Name
   GRdv_sync_tan_ed_disp


Description
   IGRint orient is in the instance for GRdvattach.  Two of its bits
   are : GR_DV_TAN_ED_DIS_OFF_CURRENT and GR_DV_TAN_ED_DIS_OFF_AFTER_PDD.
   This method will assign the value of the second to the first.
   This will only occur if the layer for this drawing view is turned on.

Arguments
   *msg           IGRlong          completion code 
   *window        struct GRid      window for the tangent edge display

History
   Jack  07/10/92  Creation

*/
message GRdv_sync_tan_ed_disp( IGRlong *msg;
                               struct GRid *window );


reject   
   GRchg_owner_properties,
   GRget_owner_properties;

end specification GRdrawview;
