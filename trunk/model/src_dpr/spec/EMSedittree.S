/* ###################   APOGEE COMPILED   ################## */
class specification EMSedittree (1:0) of NDnode, GRvg;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMStypedef.h"
#include "emsdef.h"
#include "EMSprop.h"

/*
 * Subclassing from NDnodein too.
 * pp 08/11/91
 */

instance EMSedittree
{
  GRobjid node_id;
  GRobjid nodes_owner_id;
  OMuword node_os;
  IGRushort props;
};

message EMinit(IGRlong *EMmsg; GRobjid node_id; OMuword node_os);

override
    GRcopy,
    GRxform,
    GRdelete,
    GRdisyourself,
    GRdisplay;


/***************
reject
    GRlocaldp,
    GRgetobjinfo,
    GRapprojpt,
    GRptproject,
    GRlnproject,
    GRlocate,
    GRlocate_processing,
    GRclip,
    GRcptform,
    GRgetprops,
    GRchgprops,
    GRgethprops,
    GRconstruct,
    GRaltconstruct,
    GRformatele,
    GRplotyourself,
    GRaddwrng,
    GRremwrng,
    GRgentform,
    GRcpforundo,
    GRundocp,
    GRfunction,
    GRprismrel,
    GRidchanged,
    GRgetrang,
    GRlevelcount,
    GRptprocess,
    GRlnprocess,
    GRplotprep,
    GRplotobject,
    GRrcopy;
**********************/

override NDselect_copy,
         NDget_objects,
         NDgive_structure,
         NDdisplay;

reject NDcopy_graph,
       NDconnect,
       NDdisconnect,
       NDchange_connect,
       NDconnect_graph,
       NDcopy_graph,
       NDcopy,
       NDcopy_to_root,
       NDmove_to_root;

end specification EMSedittree;
