/*
Name
   GRsmdfhdr

Description
   The class GRsmdfhdr owns the graphics objects which are components 
   of the symbol definition.  GRsmdfhdr has the followings properties:

   o  The symbol definition header is a member of the Primary
      channel via the symbol definiton index object (a B-Tree whose 
      keys are symbol definition names); however the symbol definition
      is not on the Primary channel by range or by object name.  Symbol
      definition headers are located directly via the symbol index object.
      Symbol definition headers may also be located indirectly via the
      symbol headers which refer to it.

   o  Symbol definitions may contain other symbols or cells.  When a cell
      is nested, a new cell object and its components are used, with the
      cell  becoming a component to the grouping provided by the symbol
      definition header object.  When a symbol is nested, a new symbol
      object becomes a component of the grouping provided by the symbol
      definition header object; the associated symbol definition becomes 
      a member of the symbol definition index object.

   o  The symbol definition header forms a rigid grouping for channel
      connections (i.e. components of the symbol definition cannot be 
      owned by other groupings).

   o  The symbol definition header forms a rigid grouping for locate
      operations (i.e. components can only be located for read-only
      operations).

   o  Symbol definition headers contain extents which represent the
      volume of the symbol definition in the symbol definition 
      coordinate system.

   o  The "to_components" channel is used to own the components of 
      the symbol definition.

   o  The symbol definition is used in both the local cell library 
      and the cell library.

Notes
   Classes which do not wish to inherit the 3-d double instance data
   should reject the instance data of this class and override the 
   GRgenabsg and GRpostabsg methods.

History
   DKM/HGW    05/30/86:   Design date.
   HGW        07/02/86:   Added time stamp.
   HGW        08/05/86:   Change terminology and cleanup
   HGW        10/05/87:   Changed for version 1.1
   mrm        02/23/89    I/DRAW changes
*/

class specification GRsmdfhdr (1:0) of GRsymbol, GRowner;

instance GRsmdfhdr  /* Class GRsmdfhdr */
{
   IGRdouble     diag_pt1[3];  /* range block diagonal pt 1 */
   IGRdouble     diag_pt2[3];  /* range block diagonal pt 2 */
};

/*
 *  Reject symbology, level, and the notify channel.
 */

override GRvg, GRnotify;

/*
 *  Override the following messages:
 */

override GRcopy,           /* GRgraphics  -  Special copy of sm def     */
         GRdelete,         /* GRgraphics  -  Delete the sd if not       */
                           /*                owned by any symbol headers*/
         GRownaddwrng,     /* GRcmpowner  -  DO NOT ADD COMPONENTS      */
         GRownremwrng,     /* GRcmpowner  -  DO NOT REMOVE COMPONENTS   */
         GRconstruct,      /* GRgraphics  -  Construct the sdh          */
         GRgetrang,        /* GRgraphics  -  Return the extents         */
         GRdelete_owner,   /* GRowner     -  Delete the sdh             */
         GRcopy_owner,     /* GRowner     -  Copy the sdh               */
         GRgetsize,        /* GRvg        -  The size of  IGRsymboldef  */
         GRpostabsg,       /* GRvg        -  Posts the sdh              */
         GRgenabsg,        /* GRvg        -  Gets the absg sdh          */
         GRadd_components, /* GRowner     -  Add components to sm def   */
         GRget_context,    /* GRowner     -  Set up environment context */
         GRreplace,        /* GRowner     -  Replace definition         */
         GRplotyourself;   /* GRowner     -  Send GUprocessplot to comps*/

message GRcp_sd_to_ams (IGRlong *msg; IGRmatrix place_matrix; 
                        struct IGRaltdisplay *display_attr;
                        struct GRid *target_id; 
                        struct GRmd_env *lsl_env;
                        struct GRmd_env *mod_env );
/*\
Name
   GRcp_sd_to_ams

Description
   This method will copy a symbol definition to the specified 
   active module space.  This method will add the components to 
   the index objects for that space.

   *msg           IGRlong              return code 
   place_matrix   IGRmatrix            matrix defining transformation
   *display_attr  struct IGRaltdisplay (Optional) display attributes 
   *target_id     struct GRid          (Optional) owner for components.
   *lsl_env       struct GRmd_env      Object's present environment
   *ams_env       struct GRmd_env      Object's target environment

Notes
   If the target id is NULL then the objects will not be connected.
   If the display_attr is NULL then the objects will not be changed.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRdisplay_all_instances (IGRlong *msg; IGRshort *matrix_type; 
                                 IGRmatrix matrix; enum GRdpmode *mode;
                                 struct GRid *display_id);

/*\
Name
   GRdisplay_all_instances

Description
   This method sends a display method out its to_owners channel.  Thus,
   displaying all instances of itself.

   *msg           IGRlong           return code 
   *mx_type       IGRshort          type of matrix 
   matrix         IGRmatrix         environment transformation matrix
   *mode          enum GRdpmode     the display mode 
   *display_id    struct GRid       The display object.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRrename_sd (IGRlong *msg; IGRchar *new_name; IGRchar *new_desc);

/*\
Name
   GRrename_sd

Description
   This method will rename a symbol definition header.

   *msg           IGRlong         return code 
   *new_name      IGRchar         The new name for the sdh.
   *new_desc      IGRchar         The new desc for the sdh.

Notes
   If the new_name argument is supplied it replaces the current
   name.  If the new_desc argument is supplied it replaces the
   current descripition.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

reject   GRclip,
         GRremwrng,
         GRaddwrng,
         GRchghprops,
         GRchgcolor,
         GRchgdp,
         GRchglevel,
         GRchgstyle,
         GRchgweight,
         GRputsymb,
         GRxform,
         GRxform_owner,
         GRprismrel_owner,
         GRprismrel,
         GRgetobjinfo,
         GRclipto,
         GRgetname,
         GRputname,
         GRputrang,
         GRntfyconn,
         GRntfydisconn,
         GRmodify,
         GRdrop,
         GRremove_components;

end specification GRsmdfhdr;
