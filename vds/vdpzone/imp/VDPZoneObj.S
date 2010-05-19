/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdpzone/imp / VDPZoneObj.S
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *
 * -------------------------------------------------------------------------
 */


class specification VDPZoneObj (1:0) of VDSnode;

/*+v
*/

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "growner.h"
#include "gr.h"
#include "msdef.h"
#include "VDPdef.h"
#include "VDPzone.h"

	
instance VDPZoneObj
{
    int			ZoneType;
    struct VDPCtxInfo	ZoneCtx;
};

/*
-v*/

reject GRgetobjinfo;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
	NDplace from NDnode

  Abstract
	Do nothing.  No graphical components

  Arguments
	struct GRas	*assoc_list	I	associative information
	struct GRmd_env	*md_env		I	module env
	char		*go_cnst_lis	I	full construction for the
						corresponding graphic object

 ---------------------------------------------------------------------------
-mo*/

override	NDplace;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDcompute_node from NDnode

  Abstract
        Do nothing.  No graphical components

  Arguments
	IGRlong		*msg		O	return code
	IGRint		cn_type		I	reserved
	IGRint		count		I	number of roots
	struct GRid	*list		I	list of roots
        struct GRmd_env *md_env         I       module env

 ---------------------------------------------------------------------------
-mo*/

override        NDcompute_node;


/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDmove_to_root from NDnode

  Abstract
	When any of the parents is deleted, this message is received.
	Get the new list of parents. If one or more, put myself in the
	wait_batch, so that the dependent row object will recompute.  Else
	send VDparentSetEmpty message to the row object.

  Arguments
	IGRlong		*msg		O	return code
	struct GRid	*src_grid	O	GRid of the created object
        struct GRmd_env *md_env         I       module env
 ---------------------------------------------------------------------------
-mo*/

override        NDmove_to_root;

/*+me
 ---------------------------------------------------------------------------
  
  Public Message VDPSetInstance 
  Abstract
        This method sets the instance of the Zone Object created

  Arguments
        IGRlong         *msg            O       Return code
	struct VDPzone	ZoneInfo	I

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDPSetInstance( IGRlong   *msg; struct VDPzone	ZoneInfo );

/*+me
 ---------------------------------------------------------------------------
  
  Public Message VDPGetInstance 
  Abstract
        This method gets the instance of the Zone Object

  Arguments
        IGRlong         *msg            O       Return code
	struct VDPzone	*ZoneInfo	O

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDPGetInstance( IGRlong   *msg; struct VDPzone	*ZoneInfo );

end specification VDPZoneObj;

