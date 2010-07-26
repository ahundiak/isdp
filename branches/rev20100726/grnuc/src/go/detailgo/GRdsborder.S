/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class represents the drawing border object.

History
   Gray Winn   07/25/88    Design and Coding Date.
\*/

class specification GRdsborder (1:0) of GRdrawsheet;

/*
 *  The properties word inherited from GRflxown has the following
 *  bit settings:
 *    bit 0 - 3 are reserved by the GRflxown class.
 *    bit 4
 *       if 1  -  first angle projection (GR_DS_FIRST_ANGLE)
 *       if 0  -  third angle projection (GR_DS_THIRD_ANGLE)
 */

instance GRdsborder
{
   variable IGRchar  desc[];
};

override GRvg;

from GRowner   inherit  GRis_component_removeable, GRget_channel_type,
                        GRadd_components;
from GRflxown  inherit  GRget_owner_properties, GRchg_owner_properites;

override 
   GRconstruct,                  /* GRgraphics  -  class specific */
   GRgetobjinfo,                 /* GRgraphics  -  class specific */
   GRlocate_processing,          /* GRgraphics  -  class specific */
   GRdisyourself,                /* GRgraphics  -  class specific */
   GRcopy,                       /* GRgraphics  -  class specific */
   GRlocate_owner,               /* GRcmpowner  -  class specific */ 
   GRget_locate_properties,      /* GRowner     -  class specific */ 
   GRadd_to_active_owner,        /* GRowner     -  class specific */
   GRset_active_owner,           /* GRowner     -  class specific */ 
   GRclear_active_owner,         /* GRowner     -  class specific */ 
   GRput_drawsheet_description,  /* GRdrawsheet -  class specific */ 
   GRget_drawsheet_description;  /* GRdrawsheet -  class specific */ 

end specification GRdsborder;
