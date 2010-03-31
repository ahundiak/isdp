class implementation Root;


#include "OMminimum.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "DPdlist.h"

#include "HSdlist.h"

#include "EMSprop.h"

from GAcurve import GAis_msc;
from GAcurve import GAget_msc_component;
from EMSedge import EMget_props;

%safe
static IGRboolean common_edge_chandef_defined = FALSE;
static OM_S_CHANSELECT common_edge_chandef;
%endsafe

PROTO_HSdlist_is_msc
PROTO_HSdlist_get_msc_flags

/*--- HSdlist_is_msc -------------------------------------------------*/

void HSdlist_is_msc(
   OM_S_OBJID objid,
   OMuword osnum,
   int *flag )

/*
NAME
   HSdlist_is_msc

DESCRIPTION
   This function determines if an object is a model space counterpart

SYNOPSIS
   void HSdlist_is_msc(
      OM_S_OBJID objid,
      OMuword osnum,
      int *flag )

PARAMETERS
   objid (IN) - the object id to test
   osnum (IN) - the object space number
   flag (OUT) - TRUE, if objid is a MSC, FALSE otherwise

GLOBALS USED
   none

HISTORY
   08/??/93  Shridar Subramanian
      Creation Date
   09/10/93 S.P. Rogers
      Added header documentation 
*/

{
   IGRlong msg;

   *flag = FALSE;
   om$send( msg = message GAcurve.GAis_msc( &msg, flag ),
                  targetid = objid,
                  targetos = osnum,
                  senderid = NULL_OBJID );
} /* HSdlist_is_msc */

/*--- HSdlist_get_msc_flags -------------------------------------------*/

int HSdlist_get_msc_flags(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned int *flags )

/*
NAME
   HSdlist_get_msc_flags

DESCRIPTION
   This function determines the curve variable flags for a model
   space counterpart.

SYNOPSIS
   void HSdlist_get_msc_flags(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned int *flags )

PARAMETERS
   objid (IN) - the object id to test
   osnum (IN) - the object space number
   flags (OUT) - the curve flags for the model space counterpart

GLOBALS USED
   none

HISTORY
   09/10/93  S.P. Rogers
      Creation Date
*/

{
   int sts;
   IGRlong msg;
   OMuint count;
   OM_S_OBJID edge_objid;
   OMuword edge_os;
   IGRushort edge_prop_word, common_edge_prop_word = 0;
   OM_S_OBJECT_LINKAGE common_edge_linkage[1];

   *flags = 0;

   /* find the edge associated with the msc */
   sts = om$send( msg = message GAcurve.GAget_msc_component( &msg, &edge_objid, &edge_os ),
                  targetid = objid,
                  targetos = osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }

   sts = om$send( msg = message EMSedge.EMget_props( &msg, &edge_prop_word ),
                  targetid = edge_objid,
                  targetos = edge_os,
                  senderid = NULL_OBJID );
   
   if ( ! (1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }

   /* get the common edge and its properties word */
   if ( ! common_edge_chandef_defined )
   {
      common_edge_chandef_defined = TRUE;
      om$make_chanselect( channame = "EMSedge.to_common_edge",
                          p_chanselect = &common_edge_chandef );
   }

   sts = om$get_channel_objects( osnum = edge_os,
                                 objid = edge_objid,
                                 p_chanselect = &common_edge_chandef,
                                 list = common_edge_linkage,
                                 size = 1,
                                 count = &count );

   if ( ! (1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   if ( count )
   {
      sts = om$send( msg = message EMSedge.EMget_props( &msg, &common_edge_prop_word ),
                     targetid = common_edge_linkage[0].S_objid,
                     targetos = edge_os,
                     senderid = NULL_OBJID );

      if ( ! (1 & sts & msg) )
      {
         return( DLIST_E_ERROR );
      }
   }

   if ( (edge_prop_word | common_edge_prop_word) & EMED_TANGENT )
   {
      *flags |= DP_DLIST_CRV_TANGENT;
   }

   if ( (edge_prop_word | common_edge_prop_word) & EMED_SEAM )
   {
      *flags |= DP_DLIST_CRV_SEAM;
   }

   return( DLIST_S_SUCCESS );
} /* HSdlist_get_msc_flags */

end implementation Root;
