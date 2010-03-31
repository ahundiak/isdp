class implementation EMconstr;
/*

Name
  EMdelete.I

Description
  This file has the the functions to delete
  assembly constraints.

Notes
 05/27/93 : Kapil Singh (KS): created

 */

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
#include "exmacros.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "AS_status.h"
#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>
#include <assemconstr.h>

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

extern GRclassid OPP_EMmate_class_id;
extern GRclassid OPP_EMalign_class_id;
extern GRclassid OPP_EMinsert_class_id;
extern GRclassid OPP_EMground_class_id;

from EMinstance import EMconstr_deleted, EMget_incident_constr, EMupdatebasis;
from GRgraphics import GRchgprops ;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMdelete_constraint                                             |
 |                                                                           |
 | This function delete a  assembly constraint                               |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid *constr_grid The constraint to be deleted              |
 | Output:								     |
 |        long     *rc      return code.                                     |
 +---------------------------------------------------------------------------*/

IGRlong EMdelete_constraint ( rc, constr_grid )
IGRlong *rc;
struct GRid *constr_grid; /* The constraint to be deleted */
{
  IGRlong status, msg_loc;
  struct GRid part_grid;

  *rc = EMS_S_Success;  
  status = om$send (msg = message EMconstr.EMgetpart (&msg_loc, TRUE, &part_grid), 
                     senderid = NULL_OBJID,
                     targetid = constr_grid->objid,
                     targetos = constr_grid->osnum);
  EMerr_hndlr (EMSerror (status & msg_loc), status, EMS_E_Fail, wrapup);

  status = om$send (msg = message 
                     EMinstance.EMconstr_deleted(&msg_loc, *constr_grid), 
                     senderid = NULL_OBJID,
                     targetid = part_grid.objid,
                     targetos = part_grid.osnum);
  EMerr_hndlr (EMSerror (status & msg_loc), status, EMS_E_Fail, wrapup);
   
  status = om$send(msg = message NDnode.NDdisconnect(0,NULL),
                     senderid = NULL_OBJID,
                     targetid = constr_grid->objid,
                     targetos = constr_grid->osnum);
  EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, wrapup);

  status = om$send(msg = message  Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = constr_grid->objid,
                     targetos = constr_grid->osnum);
  EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, wrapup);

/*
 * If this is the last constraint on the incident part,
 * Unset the GRprops of the incident part so that the part is 
 * located by operations such as move, rotate etc., 
 */
  {
    IGRlong  msg;
    IGRshort action = 0; /* This means clear the bits. */
    IGRint   num = 0;
    struct   GRid inc_cnstr[MAX_INCIDENT_CONSTR];
    IGRshort props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

    status = om$send (msg = message EMinstance.EMget_incident_constr
                              (&msg, &num, inc_cnstr ),
                              senderid = part_grid.objid,
                              targetid = part_grid.objid,
                              targetos = part_grid.osnum);

    if( !(status & msg & 1) )
      goto wrapup;

    if( num == 0 ) /* No more constraints on the part */
    {
      status = om$send (msg = message GRgraphics.GRchgprops (&msg, &action, &props),
                        senderid = part_grid.objid,
                        targetid = part_grid.objid,
                        targetos = part_grid.osnum);
      if( !( status & msg & 1 ))
      {
        verbose(printf("GRchgprops failed\n"));
      }
    }
  }
wrapup:
  EMWRAPUP (status, status, "In EMdelete_constraint" );
  return(status);
}



end implementation EMconstr;
