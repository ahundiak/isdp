/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class represents a drawing sheet.  The drawing sheet owns
   the active graphics and an entity which represents the drawing sheet 
   border.

History
   Gray Winn   07/20/88    Design and Coding Date.
\*/

class specification GRdrawsheet (1:0) of GRflxown;

override GRvg, GRflxown;

from GRowner inherit GRprismrel_owner;

override
   GRconstruct,               /* GRgraphics     -  class specific    */
   GRgetobjinfo,              /* GRgraphics     -  class specific    */
   GRdisyourself,             /* GRgraphics     -  class specific    */
   GRcopy,                    /* GRgraphics     -  class specific    */
   GRlocate_owner,            /* GRcmpowner     -  class specific    */
   GRadd_components,          /* GRowner        -  class specific    */
   GRget_locate_properties,   /* GRowner        -  class specific    */
   GRset_active_owner,        /* GRowner        -  class specific    */
   GRclear_active_owner,      /* GRowner        -  class specific    */
   GRis_component_removeable, /* GRowner        -  class specific    */
   GRget_owner_properties,    /* GRowner        -  class specific    */
   GRchg_owner_properties;    /* GRowner        -  class specific    */

/*\
Name
   GRget_drawsheet_description

Description
   This method returns the description of the drawing sheet.

Arguments
   *msg           IGRlong           o   return code
   *desc          IGRchar           o   description string

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRget_drawsheet_description (IGRlong *msg; IGRchar *desc);

/*\
Name
   GRput_drawsheet_description

Description
   This method puts a description into the drawing sheet.

Arguments
   *msg           IGRlong           o   return code
   *desc          IGRchar           i   description string

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRput_drawsheet_description (IGRlong *msg; IGRchar *desc);

end specification GRdrawsheet;
