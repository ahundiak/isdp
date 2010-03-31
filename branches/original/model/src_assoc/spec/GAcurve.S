/* ###################   APOGEE COMPILED   ################## */
/* #################   APOGEE  COMPILED   ######################### */
class specification GAcurve (2:0) of EMSassoc,GRcurve;

#include "EMSasdef.h"
#include "EMSas.h"
#include "REcurve.h"

/* ************************************************************************
Description

 This class provides for
  a) common functionality with regards to implementation of 
     associativity in EMS for all curve objects.
  b) common message declarations for supporting associativity.

 This is an abstract class.

 It currently inherits the following channels:
 a) father channel (restricted) declared at NDnodein.
 b) children  channel  (restricted)  declared at NDnodein.
 c) vla to store the syntax that is necessary for recomputation.
 d) Instance data that is inherited by GRcurve.

History
    PP : 03/02/91 : Creation 
    WBC: 03/21/91 : Overrode EMconstruct_associative, EMget_info and
                    EMput_info.
    WBC: 04/16/91 : Overrode NDgive_structure.
    WBC: 06/27/91 : Overrode GRcopy.
    WBC: 05/14/93 : Overrode GRcpparallel to change the class of the copied
                    object from GAxxx to GRxxx (make it non-associative).
    dfl: 01/10/95 : added message EMofcvdim for autodimensioning the distance
                    between associative offset curves and original curves.
   ************************************************************************ */

message GAreturn_yourself(IGRlong *EMmsg; struct GRid *edge_GRid;
                          struct GRid *msc_GRid);

message GAget_msc_component(IGRlong *EMmsg; GRobjid *component_id;
                            OMuword *component_os);

/* ***********************************************************
Description
  This method returns the associative model-space counterpart's component
(edge or loop) object id and object space number.

Arguments
    name         I/O                         description
---------------- ---   ------------------------------------------------------
  EMmsg           O    Return message; EMS_S_Success if the component is
                       returned, EMS_E_Fail otherwise
  component_id    O    the objid of the edge or loop from which this MSC
                       was created
  component_os    O    the osnum of the edge or loop from which this MSC
                       was created
**************************************************************/

message GAis_msc(IGRlong *EMmsg; int *flag);

/* ***************************************************************
Description
 This message when sent to an associative curve will indicate whether
 the same is a model space counterpart or not.

Arguments

 EMmsg : O : Completion code
 flag  : O : TRUE: If the entity is a model space counterpart
             FALSE : If the entity is not a model space counterpart

Notes
 Upon exit the completion code will be:
  EMS_S_Success: If all goes well
  EMS_E_Fail : If things do not go well

********************************************************************* */

message EMofcvdim(IGRlong *EMmsg; unsigned int octrl;
                  struct GRmd_env *md_env);

/* ***************************************************************
Description
The method for this message will construct an object of class 
EMSdimoff1, which links the autodimensioning objects to the
offset curve element which is of type GAcurve.

Arguments
 octrl : I : contains information about the characteristics of the 
             offset curve
 md_env: I : the module environment
 
 EMmsg : O : Completion code
 flag  : O : TRUE: If successful
             FALSE : If not successful

Notes
 Upon exit the completion code will be:
  EMS_S_Success: If all goes well
  EMS_E_Fail : If things do not go well

********************************************************************* */

override EMconstruct_associative,
         NDselect_copy,
         GRdetplane,
         ASreturn_go,
         NDgive_structure,
         EMstore_key_from_id,
         EMstore_id_from_key,
         EMstore_id, 
         NDmove_to_root,
         NDcopy_graph,
         GRcopy,
         debug,
         GRcpparallel,
	 GRadd_to_display_list;

end specification GAcurve;
