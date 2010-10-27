/* $Id: ASindexpti.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdassoc/ASindexpti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: ASindexpti.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/02/27  16:04:18  pinnacle
# Created: vdassoc/ASindexpti.I by mdong for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/24/98        Ming            Correct the NDcompute_node.
 *
 *    The method NDcompute_node() has been modified from GRNUC.
 *
 * -------------------------------------------------------------------*/

class implementation ASindexpt;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "ASmsg.h"
#include "msmacros.h"
#include "masubvc.h"
#include "mamulmx.h"
#include "bsptsdlcv.h"
#include "bscveval.h"

/* ----------------------------------------------------------------------
  compute the index point
------------------------------------------------------------------------ */
method NDcompute_node(IGRlong *msg;IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)
{
  struct ret_struct  pardef[4],
		     objdef;
  IGRint icount;
  IGRdouble point[4];   /* be carrefull index_point uses a 4 double point */
  IGRint status;
  IGRboolean track;
  double pt_track[3];
  int quel_cas;

  if(count<1 || count>4)
  {
    printf("ASindexpt.compute_node bad parent number \n");
    return(0);
  }

  /*" obj %d, bary %lf\n",my_id,me->bary_fact */

  for (icount=0 ; icount<count ; icount++)
    {
     status = om$send(msg = message NDnode.NDgive_structure 
						 (msg,&pardef[icount],md_env),
	    	      targetid = list[icount].objid,
	    	      targetos = list[icount].osnum);
     as$status(action = RET_STATUS);
    }
  if( count == 4 || ( count == 3 && (pardef[0].type & point_generic) )
          || ( count == 2 && (pardef[0].type & ~point_generic) ) )
   {
    /*| there is a track point */
    track = TRUE;
    quel_cas = count -1;
   }
  else
   {
    /*| there is no track point */
    track = FALSE;
    quel_cas = count;
   }

  if(pardef[0].type & line_generic) quel_cas = quel_cas + 10;
							 /* specific on line*/
  else if(pardef[0].type & conic_generic) quel_cas = quel_cas + 20;
							 /* specific on circle*/
  else if(pardef[0].type & point_generic) quel_cas = quel_cas + 30;
							 /* specific on point*/

  /*
     compute graphic point from barycentric coordinate (regular compute)
     or barycentric coordinate from graphic object. It's the case when
     the index point has received an GRxform or GRmodify message
  */

  status = 
  om$send( msg      = message NDnode.NDgive_structure(msg, &objdef, md_env),
           targetid = my_id );
  as$status(action = RET_STATUS);

  if( track ) v_equal( pardef[count-1].var.point_st.pt, pt_track );
  else        v_equal( objdef.var.point_st.pt, pt_track );

  status = 
  om$send( msg = message ASindexpt.ASindex_bary(quel_cas,
						md_env,
                                         	pardef,
						list,
                                         	objdef.var.point_st.pt,
                                         	pt_track,
                                         	&me->bary_fact,
						point),
           targetid = my_id );
  if( status != OM_S_SUCCESS )
  {
    printf( "ASindexpt compute_node error. index point not updated\n" );
    return( OM_S_SUCCESS );
  }

  status = 
  ASindex_point( quel_cas, md_env, pardef, list, me->bary_fact, point );
  if( status != OM_S_SUCCESS )
  {
    printf( "ASindexpt compute_node error. index point not updated\n" );
    return( OM_S_SUCCESS );
  }

{
 struct GRpost_info post_info;
 GRobjid newobjid;
 struct IGRpolyline polyline;

 polyline.num_points = 1;
 polyline.points = point;
 post_info.construct_flag = FALSE;

 status = om$send(msg=message GRlinear.GRputpolyline
                                   (msg,md_env,&post_info,&polyline,&newobjid),
                  p_chanselect = &AS_to_comp );
 as$status(action = RET_STATUS);
 }

  

  return(OM_S_SUCCESS);
}    /* end of compute_nod method */

end implementation ASindexpt;
