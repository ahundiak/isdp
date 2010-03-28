#include <math.h>
#include "bsvalues.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "exmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"


/*

Name
  SSGetElementType

Abstract

Synopsis
  int SSGetElementType ( objid, osnum, p_type )
  GRobjid      objid   objid of element to be typed
  GRspacenum   osnum   osnum of element to be typed (if 0, master OS assumed)
  int         *p_type  type of element (see SSdef.h) Note: if not one of the
		       elements known to Smart Sketch, a type of SSUNKNOWN is
		       passed back.

Description

Return Value
  OM_S_SUCCESS - successfully found what type of element the object is
  OM_E_INVARG  - type of element is unknown to this application

Notes
  Private

Index

Keywords
  smart-sketch

History
  09/07/93 : Shelley R. Heard : created

 */

int SSGetElementType( objid, osnum, p_type )
  GRobjid      objid;
  GRspacenum   osnum;
  int         *p_type;
{
  int         rc = OM_S_SUCCESS;
  OMuword     class_id = 0;
  GRspacenum  loc_osnum;
  
  /* 
   * GRNUC based class id's; other applications classes must be
   * referenced by class names.
   */
  extern OMuword 
    OPP_GR3dlineseg_class_id, 
    OPP_GR3dpoint_class_id, 
    OPP_GR3dcirarc_class_id, 
    OPP_GR3dcircle_class_id;

  /*
   * get class id of element from Rtree; osnum defaults to master OS 
   */
  if ( osnum )
  {
    loc_osnum = osnum;
  }
  else
  {
    ex$get_cur_mod ( osnum = &loc_osnum );
  }

  om$get_classid ( osnum     = loc_osnum, 
                   objid     = objid,
                   p_classid = &class_id );

  /*
   * set the type of element according to it's classid
   */
  if (om$is_ancestry_valid ( 
        subclassid = class_id,
         superclassid = OPP_GR3dlineseg_class_id ) == OM_S_SUCCESS)
  {
    *p_type = SSLINE;
  }
  else if (om$is_ancestry_valid ( 
           subclassid = class_id,
           superclassid = OPP_GR3dcircle_class_id ) == OM_S_SUCCESS)
  {
    *p_type = SSCIRCLE;
  }
  else if (om$is_ancestry_valid ( 
            subclassid = class_id,
            superclassid = OPP_GR3dcirarc_class_id ) == OM_S_SUCCESS)
  {
    *p_type = SSARC; 
  }
  else if (om$is_ancestry_valid (
            subclassid = class_id,
            superclassid = OPP_GR3dpoint_class_id) == OM_S_SUCCESS)
  {
    *p_type = SSPOINT;
  }
  else if (om$is_ancestry_valid (
             subclassid = class_id,
             superclassname = "GRbcsubbc" ) == OM_S_SUCCESS)
  {
    *p_type = SSBSCURVE; 
  }
  else 
  {
    *p_type = SSUNKNOWN;
    rc   = OM_E_INVARG;
  }

  return rc;
}

