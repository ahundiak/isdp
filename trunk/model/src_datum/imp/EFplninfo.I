/*

Name
  EFplninfo.I

Description
  This file containing one or more function interfaces for the datum plane
  (reference plane) methods.  These may be stubbed at the GRNUC level.
  
 */

class implementation Root;

#include "OMerrordef.h"
#include "EMSdpb.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "FI.h"
#include "grdpbdef.h"
#include "msdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "emsdef.h"


/*

Name
  EFget_pln_info

Abstract
  This function is a wrapper for the message EMSdatpln.EMget_pln_info for
  a specified datum plane (if no datum plane specified (NULL), then the 
  active datum plane is assumed).

Synopsis
  long EFget_pln_info ( struct GRid *p_datum_plane;
                        unsigned int options;
                        struct GRmd_env *env;
                        double *xdir;
                        double *ydir;
                        double *zdir;
                        double *origin;
                        unsigned int *props)

  p_datum_plane : I : objid/osnum of datum plane to be queried
  options       : I : Ubiquitous options field. Currently not supported
  env           : I : Module environment
  xdir          : O : if non-null xdirection of the datum plane is returned
  ydir          : O : if non-null ydirection of the datum plane is returned
  zdir          : O : if non-null zdirection of the datum plane is returned
  origin        : O : if non-null origin of the datum plane is returned
  props         : O : if non-null properties of the datum plane are returned.

Return Value
  MSSUCC: If all goes well
  MSFAIL : If there is some form of failure

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is some form of failure

Index

Keywords
  function,get

History
  05/20/93 : Shelley R. Heard : created because needed by Smart Sketch

 */

from EMSdatpln import EMget_pln_info;

IGRlong EFget_pln_info( p_datum_plane,
                        options,
                        env,
                        xdir,
                        ydir,
                        zdir,
                        origin,
                        props )
  struct GRid *p_datum_plane;
  unsigned int options;
  struct GRmd_env *env;
  IGRdouble *xdir;
  IGRdouble *ydir;
  IGRdouble *zdir;
  IGRdouble *origin;
  unsigned int *props;
{
  int OMsts = OM_S_SUCCESS;
  IGRlong msg = MSSUCC;
  struct GRid local_plane,
              *p_plane;
  
  if (p_datum_plane == NULL)
  {
    p_plane = &local_plane;
    p_plane->objid = NULL_OBJID;
    ems$get_active_datum_plane ( msg = &msg, 
				 datpln = p_plane );
  }
  else
  {
    p_plane = p_datum_plane;
  }

  if (p_plane->objid != NULL_OBJID && (msg & 1))
  {
    int Four = 4;

    OMsts = om$send ( msg = message EMSdatpln.EMget_pln_info ( 
                              &msg,
                              options,
                              env, 
                              xdir,
                              ydir,
                              zdir,
                              origin,
                              props ), 
                       targetid = p_plane->objid, 
                       targetos = p_plane->osnum, 
                       senderid = NULL_OBJID );
  }
  return (msg);
}

end implementation Root;

