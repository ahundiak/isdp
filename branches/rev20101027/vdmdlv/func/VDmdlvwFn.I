/* $Id: VDmdlvwFn.I,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdmdlv/func / VDmdlvwFn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmdlvwFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  18:49:48  pinnacle
# UnInit Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/08/23  23:39:18  pinnacle
# Replaced: vdmdlv/func/*.I for:  by tlbriggs for vds.240
#
 *
 * History:
 *	11-20-1994  Raju   	Creation
 *    	08/23/95    tlb		Modified to use _MALLOC, _FREE
 *	10/31/97    ah          UnUsed warnings
 *************************************************************************/
class implementation  VDmdlview;

/*+fe
Internal Function	VDgetMdlvwObjects

Abstract
  This function gets objects having given relation with given volumes and
  also qualify for given query filters.

Algorithm
  This function first gets all objects having specified relation with
  all volumes. Then each of the objects is seen if it adheres to any of
  the queries.

Arguments
 long			*msg		O - return message.
 int			num_vvol	I - no. of view volumes.
					    Atleast one view volumes should
					    be input to this function.
 struct GRid		*vvol_list	I - id list of view volumes.
 struct GRmd_env	*vvol_env	I - env list of view volumes.
 int			num_qry		I - no. of queries.
 struct GRid		*qry_list	I - id list of queries.
 char			rln_needed      I - objects having this relation
					    with solids will be obtained.
					    see vdsollocdef.h.
 int			*no_obj		O - no. of objects found.
 struct GRobj_env	**obj_list	O - list of selected objects.

Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-20-1994  Raju   Creation
-fe*/
#include "exdef.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "madef.h"
#include "bserr.h"
#include "ex.h"
#include "msmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "growner.h"

#include "vderrmacros.h"
#include "vdsollocdef.h"
#include "vdparmacros.h"
#include "VDmem.h"

#define  VD_LIST_INCR  50

long  VDgetMdlvwObjects(
 long			*msg,
 int			num_vvol,
 struct GRid		*vvol_list,
 struct GRmd_env	*vvol_env,
 int			num_qry,
 struct GRid		*qry_list,
 char			rln_needed,
 int			*no_obj,
 struct GRobj_env	**obj_list
)
{
long			sts;
struct  GRobj_env	*after_vvol_list = NULL;
int			AftVvolNb,
			ii, jj, kk, ListSize;
#if 0
// No longer used
struct  GRobj_env	*after_qry_list = NULL;
int			AftQryNb;
#endif

     *msg = MSSUCC;
     sts = OM_S_SUCCESS;

     if ( num_vvol == 0 )
     {
	*no_obj = 0;
	goto wrapup;
     }

     ListSize = VD_LIST_INCR;
     after_vvol_list = _MALLOC( ListSize, struct GRobj_env);
     _CheckMem (after_vvol_list, sts, *msg, wrapup);

     AftVvolNb = 0;

     /*
      * get list of objects which are located by view volumes
      */
     for (ii=0; ii<num_vvol; ii++)
     {
	struct GRid		solid;
	int			NbSolObj;
	struct GRobj_env	*sol_obj_list = NULL;
	char			found;

	sts = om$send ( msg = message NDnode.ASreturn_go (
					&solid, NULL, NULL ),
			targetid = vvol_list[ii].objid,
			targetos = vvol_list[ii].osnum,
			senderid = NULL_OBJID );
	VDS_ERR_CONTINUE("NDnode.ASreturn_go", sts, 1, VD_VERBOSE );
	__DBGpr_obj ( "solid_copy", solid );

	NbSolObj = 0;
	sts = VDlocateWithSolid ( msg,
				  1,
				  &solid,
				  &vvol_env[ii],
				  num_qry,
				  qry_list,
				  rln_needed,
				  VD_LIST_OF_OBJS,
				  NULL,			/* window id */
				  &NbSolObj,
				  &sol_obj_list,
				  "Processing .." );
	VDS_ERR_CONTINUE("VDlocateWithSolid", sts, *msg, VD_VERBOSE);
	__DBGpr_int( "No. of objects wrt solid", NbSolObj );

	for(jj=0; jj<NbSolObj; jj++)
	{
	   found = FALSE;
	   for(kk=0; kk<AftVvolNb; kk++)
	     if ( sol_obj_list[jj].obj_id.objid == 
			after_vvol_list[kk].obj_id.objid &&
		  sol_obj_list[jj].obj_id.osnum == 
			after_vvol_list[kk].obj_id.osnum    )
	     {
		found = TRUE;
		break;
	     }
	   if ( !found )
	   {
	     if ( AftVvolNb == ListSize )
	     {
		ListSize += VD_LIST_INCR;
		after_vvol_list = _REALLOC( after_vvol_list, ListSize,
							struct GRobj_env);
	     }
	     after_vvol_list[AftVvolNb] = sol_obj_list[jj];
	     AftVvolNb++;
	   }
	} /* for(jj=0; jj<NbSolObj; jj++) */

	_FREE (sol_obj_list); 

     } /* for (ii=0; ii<num_vvol; ii++) */

     if ( obj_list )	*obj_list = after_vvol_list;
     else		_FREE ( after_vvol_list );

     *no_obj  = AftVvolNb;

#if 0
     if ( num_qry == 0 )
     {
	if ( obj_list )	   *obj_list  = after_vvol_list;
	else	   	   _FREE ( after_vvol_list );
	*no_obj    = AftVvolNb;
	goto wrapup;
     }

     /*
      * process the list of objects for the given queries
      */

     ListSize = VD_LIST_INCR;
     after_qry_list = _MALLOC( ListSize, struct GRobj_env);
     _CheckMem (after_qry_list, sts, *msg, wrapup);

     AftQryNb = 0;
     for( ii=0; ii< AftVvolNb; ii++ )
     {
	struct GRid   obj;
	int	      nb_fnd;

	obj = after_vvol_list[ii].obj_id;
	nb_fnd = 0;
	sts = vd$qry_process (	sts     =  msg,
				objects =  &obj,
				nb_objects = 1,
				queries	=  qry_list,
				nb_queries = num_qry,
				nb_found = &nb_fnd   );
	VDS_ERR_CONTINUE("vd$qry_process", sts, *msg, VD_VERBOSE);

	if ( nb_fnd )
	{
	  if ( AftQryNb == ListSize )
	  {
	    ListSize += VD_LIST_INCR;
	    after_qry_list = _REALLOC( after_qry_list, ListSize, 
						struct GRobj_env); 
	  }
	  after_qry_list[AftQryNb] = after_vvol_list[ii];
	  AftQryNb++;
	}
    }
    _FREE ( after_vvol_list );
    
    if ( obj_list ) *obj_list  = after_qry_list;
    else	    _FREE ( after_qry_list );
    *no_obj    = AftQryNb;
#endif

wrapup:
   return sts;
}

end implementation  VDmdlview;
