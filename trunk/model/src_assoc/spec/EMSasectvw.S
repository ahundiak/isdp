/* ###################   APOGEE COMPILED   ################## */
class specification EMSasectvw (2:0) of EMSagrp;


/* ************************************************************************
Description
 This class provides implementation for support of associative sectional
 view objects.

History
 09/21/91 : WBC : Creation
 11/05/92 : WBC : Added the message EMget_sv_dvattach_id.

 ************************************************************************ */

message EMget_sv_dvattach_id (IGRlong *EMmsg;
                              struct GRid *dvattach_id;
                              OMuint *chan_index);

/* *******************************************************************

Description
 This message returns the id of the Section View's parent drawing view
attachment.

Arguments
 Input

 Output
    dvattach_id:  The object id and osnum of the drawing view attachment
                  which is the parent of the Section View.
    chan_index:  (Optional) The channel index at which the drawing view
                 attachment is connected to the Section View's father channel;
                 a NULL pointer may be passed in if this information is not
                 needed.
Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success:   If all goes well.
 EMS_E_NotFound:  If the drawing view attachment is not found.
  ******************************************************************* */


override EMconstruct_associative,
         GRgetobjinfo,
         EMget_parent_type,
         NDparent_deleted,
         GRdelete,
	 GRdrop,
	 GRxform,
         NDupdate;

end specification EMSasectvw;
