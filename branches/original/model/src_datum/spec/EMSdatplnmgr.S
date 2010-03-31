/* ###################   APOGEE COMPILED   ################## */

class specification EMSdatplnmgr (1:1) of global_class;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "exfi.h"
#include "msdef.h"
#include "asbox.h"
#include "EMSdatumdef.h"

/* **************************************************************************

Abstract
  This class is designed to store the datum planes that exist
  in the system and store the active datum plane.

Notes

History
      PP   :      07/04/91         Creation
*************************************************************************** */


instance EMSdatplnmgr
{
 int num_datums; /* Number of datums managed by the datum plane manager */
 IGRdouble default_size; /* Default size of the datum plane */
 unsigned short props; /* Properties */
 OM_S_OBJID active_datum; /* Objectid of the active datum */
 variable OM_S_OBJID datum_id[3]; /* List of datum ids being managed */
};

message EMget_info (IGRlong *EMmsg; 
                    unsigned int options;
                    unsigned int *props;
                    IGRdouble *default_size;
                    OM_S_OBJID *active_datum;
                    int *num_datums);
/* ************************************************************************
Description
 This message gets information stored in the datum plane manager.

Arguments
 EMmsg : Completion code
 options : Can be set to NULL for now
 props : If non-NULL properties will be returned.
 default_size : If non-NULL the default size of the datum plane will be
                returned.
 active_datum : If non-NULl the active datum id will be returned.
 num_datums : Number of datums that are being managed will be returned if
              the same is not NULL.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is some form of failure
*************************************************************************** */

message EMactivate(IGRlong *EMmsg;
                   unsigned int options;
                   OM_S_OBJID *new_datum;
                   OM_S_OBJID *old_datum);

/* *******************************************************************
Description
 This message makes the datum plane entity that is being passed in 
 as the active plane. 

Arguments
 EMmsg : Completion message
 new_datum : The new datum that has to be activated.
 old_datum : Object id of the old active datum will be optionally
             returned if this is not set to NULL

Notes
 Upon exit the completion code will be one of the following:

 MSSUCC : If all goes well
 MSFAIL : If there is failure

********************************************************************** */

message EMget_datums(IGRlong *EMmsg;
                     unsigned int options;
                     int *datum_count;
                     struct GRid *datum_GRids);

/* *******************************************************************
Description
 This message gets the datums managed by the datum plane manager.
 The following options are supported:
  EMS_OPT_OFF_DATUMS:  Datums whose display has been turned off.
  EMS_OPT_ON_DATUMS :  Datums whose display has been turned on

Arguments
 EMmsg : Completion code
 options : See above.
 datum_count : The number of datums that meet the specified option criteria
 datum_GRids : The grids of datums. Can be set to NULL if not interested.
               Otherwise enough memory is assumed to have been passed.

Related files:
 EMSdatumdef.h

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure
********************************************************************** */

message EMmanage_datum_entry(IGRlong *EMmsg;
                             unsigned int options;
                             OM_S_OBJID datum_id);
/* *******************************************************************

Description
 This message adds/deletes a datum  entry in the datum plane manager.

Arugments
 EMmsg : Completion code
 options : The following options are supported:
           EMS_OPT_ADD : Add an entry.      
           EMS_OPT_DELETE : Delete an entry
           EMS_OPT_ACTIVATE : Makes the added entry the active datum plane.
 datum_id :the id to be added or deleted.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC : If all goes well.
  MSFAIL : If there is failure
********************************************************************** */


override 
/*
 * Returns success
 */
         wake_up,
/*
 * Constructs the base datum features by default and initialises the dpb.
 */
         super_construct,
/*
 * Returns success.
 */
         sleep,
/*
 * This object cannot be deleted.
 */
         delete;

end specification EMSdatplnmgr;
 

