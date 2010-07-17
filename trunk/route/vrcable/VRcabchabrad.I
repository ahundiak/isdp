/* $Id: VRcabchabrad.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / VRcabchabrad.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcabchabrad.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/05/15  22:19:10  pinnacle
# Replaced: vrcable/VRcabchabrad.I for:  by r241_int for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/16  20:04:00  pinnacle
# Replaced: vrcable/VRcabchabrad.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
class implementation VRcable;

//%safe
#include <math.h>
//%endsafe
#include "OMmacros.h"
#include "OMprimitives.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "bsparameters.h"
#include "parametric.h"
#include "bs_values.h"
#include "bserr.h"
#include "bstypes.h"
#include "msdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "comiscmac.h"
#include "mautoparm.h"

#define AS_DEBUG 	1

/* extern		ACget_def_NVrep(); */
extern		NDexec_batch(), NDwait_batch();

/*----------------------------------------------------------------------------*/
/* method VRCbChaBendRad						     -*/
/*----------------------------------------------------------------------------*/
method VRCbChaBendRad(	IGRlong		*msg;
			struct GRmd_env *md_env;
			IGRboolean	global;
			IGRdouble	*rad;
			IGRdouble	*point;
			IGRdouble	*view )
{
struct IGRbsp_curve *curve;
struct GRid	mygrid, line_id;
IGRint		size, cn_type;
IGRint		status = OM_S_SUCCESS;
IGRlong		segnum, i, index;
IGRpoint	ProjPnt, DummyPnt;
IGRdouble	tparm, DummyDbl, BorePnts[6];
struct GRparms	parms;
struct IGRline	BoreLine;

  /* initialize variables */
  *msg	= MSSUCC;
  line_id.objid = NULL_OBJID;
  line_id.osnum = OM_Gw_current_OS;
  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  /*" cable id : %d\n", mygrid.objid */
  /*" global   : %d\n", global */

  if( ! global ){

    /*| get the linestring component of the cable object */
    status = om$get_objid_at_index( objid        = mygrid.objid,
				    p_chanselect = &AS_to_comp,
				    index        = 0,
				    objidaddr    = &line_id.objid,
				    osnumaddr    = &line_id.osnum );
    as$status(action = RET_STATUS, value = wrapup );
    /*^
	printf(" line_id:[%d,%d]\n", line_id.objid, line_id.osnum);
     */
    BoreLine.point1 = &( BorePnts[0] );
    BoreLine.point2 = &( BorePnts[3] );

    for( i=0; i<3; i++){
      BorePnts[i]   = point[i];
      BorePnts[i+3] = point[i] + view[i];
    }

    /*| msg GRgraphics.GRlnproject */
    status = om$send( msg = message GRgraphics.GRlnproject(
                        msg,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,
			&BoreLine,
			DummyPnt,
                        ProjPnt,
                        &DummyDbl,
                        &parms ),
		   senderid = NULL_OBJID,
	           targetid = line_id.objid,
                   targetos = line_id.osnum );

    if( ! (status&1) || ! (*msg&1) ){
      /*| msg GRgraphics.GRptproject failed */
      as$status( action = RET_STATUS, value = wrapup );
    }
    /*^
      printf( " parms : %4.2f\n", parms.u );
      printf( " vertex: %f, %f, %f\n",ProjPnt[0],ProjPnt[1],ProjPnt[2] );
     */

    /*| Retrieve the geometry */
    curve  = NULL;
    status = om$send( msg    = message GRvg.GRgenabsg(	
				msg,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				(IGRchar **)&curve  ) ,
		   senderid = NULL_OBJID,
	           targetid = line_id.objid,
                   targetos = line_id.osnum );
    as$status( action = RET_STATUS, value = wrapup );    

    /*^
      printf(" num_seg   : %d\n", curve->num_poles );
     */

    /*| determine which vertex to change */
    if( 1&MAutoparms( msg, curve, &parms.u, &segnum, &tparm) ){
      /*^
	printf(" segnum : %d \n", segnum );
	printf(" tparm  : %f \n", tparm );
       */
      if(((segnum == 1) && ( tparm <= 0.5 )) || 
	 ((segnum == curve->num_poles ) && (tparm >= 0.5)) ){

	/*| selection one of the end Pnts */
	goto wrapup;
      }
      else{
	if( tparm <= 0.5 )	index = segnum - 2;
	else 			index = segnum - 1;
      }
      /*" index : %d \n", index */
    }
    else{
      /*| function MAuto.. failed */ 
      goto wrapup;
    } /* MAuto.. */
  } /* if (!global ) */


  /*| modify the bendtable value */
  if( *rad < me->sect_radius ){
    /*| bend radius is to small */
    goto wrapup;
  }

  size = om$dimension_of( varray = me->bend_table );
  /*" bend_table size : %d\n", size */

  if( global ){
    for(i=0;i<size;i++) me->bend_table[i] = *rad;
  }
  else{
    if( index < 0 || index > size-1 )	goto wrapup;

    /* set the bend radius value */
    me->bend_table[index] = *rad;
  }
  /*^
    for(i=0;i<size;i++)
      printf(" btab[%d] : %f \n", i, me->bend_table[i] );
   */

  /*| put the object onto the batch */
  cn_type = ND_COMP;
  nd$wait_batch(type 	   = GR_GEOM_POSTED,
		l_object   = &mygrid,
		l_obj_info = &cn_type,
		nb_obj     = 1 );

  /*| execute the new object */
  nd$exec_batch();

  /*| remove geometry */
  GRabsg_del(curve);

  *msg = MSSUCC;
  return(OM_S_SUCCESS);

wrapup:
  /*| wrapup area */

  /*| remove geometry */
  GRabsg_del(curve);

  *msg = MSFAIL;
  return(OM_S_SUCCESS);

} /* VRCbChaBendRad */ 

/*--------------------------------------------------------------------------*/
/* end of file								    */
/*--------------------------------------------------------------------------*/
end implementation VRcable;
