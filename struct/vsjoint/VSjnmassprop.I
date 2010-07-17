/* $Id: VSjnmassprop.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */
/***************************************************************************
* I/STRUCT
*
* File: vsjoint/VSjnmassprop.I
*
* Description: The method VSgetMassProperties() gets the mass properties for 
*              welded joint
*
* Dependencies:
*
* Revision History:
*      $Log: VSjnmassprop.I,v $
*      Revision 1.1.1.1  2001/01/04 21:10:47  cvs
*      Initial import to CVS
*
# Revision 1.2  2000/03/15  15:47:26  pinnacle
# Replaced VSjnmassprop.I by jpulapar for TR179900519
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      07/26/99  Jayadev Commented code to get proper weld length for 
*                TR#179900519
*      11/16/99  Jayadev The weld length is to be doubled only for stiffeners
*                TR#179900519
***************************************************************************/
class implementation VSjoint ;

#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmeasmacros.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsdpbmacros.h"
#include "vswelddef.h"

#define TRUE  1
#define FALSE 0
from GRcurve	import GRtotlength ;
extern  GRclassid  OPP_VSbeam_class_id;
/*----------------------------------------------------------------------------*/
method VSgetMassProperties(	long		*msg ;
				struct GRmd_env	*myEnv ;
				VSintegral	*mp ) {
  
  long			sts ;	/* OM return code		*/
  int			i ;	/* Our favorite loop index	*/
  struct GRid		myGRid ;/* Moi !			*/
  VSpartAttr		part ;	/* My part attributes		*/
  VSjointAttr		joint ;	/* My joint attributes		*/
  struct GRobj_env	jnd1,	/* First  element joined	*/
    jnd2 ;	/* Second element joined	*/
#if 0
  VSdspRep        	Rep1 ,
                        Rep2 ; 	/* My display representation    */
  int			jType ;	/* Junction type		*/
#endif
  OMuword                 StiffObjClass;
  IGRint                  stiffFlag = FALSE;
  
  SetProc( VSjoint_VSgetMassProperties ) ; Begin ; __DBGpr_me() ;
  jnd2.obj_id.objid = NULL_OBJID;
  mp->area	= 0 ;
  mp->volume	= 0 ;
  mp->mass	= 0 ;
  for( i = 0 ; i < 6 ; i++ ) {
    mp->MofI.array[i] = 0 ;
  }
  for( i = 0 ; i < 3 ; i++ ) {
    mp->dims[i]	= 0 ;
    mp->centroid[i]	= 0 ;
  }
  
  myGRid.objid = my_id ; myGRid.osnum = OM_Gw_current_OS ;
  // This call was uncommented for TR179900519
  
  sts = om$send(	msg	= message VSjoint.VSgetJoinedFeatures(msg, &jnd1, &jnd2, NULL ),
			targetid= my_id ) ;
#if 0
  
  sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &Rep1 ),
		  targetid= jnd1._objid,
		  targetos= jnd1._osnum ) ;
  sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &Rep2 ),
		  targetid= jnd2._objid,
		  targetos= jnd2._osnum ) ;
#endif
  
  sts = VSjointLength( msg, &myGRid, myEnv, mp->dims + 0 ) ;
  if( !( sts & 1 & *msg ) ) mp->dims[0] = 0 ;
  
  //	if(!( Rep1 & AC_2D_REP ) && !( Rep2 & AC_2D_REP ) )
  //		mp->dims[0] = mp->dims[0]/2; Commented for TR#179900519
  
  __DBGpr_dbl( "Weld length", mp->dims[0] ) ;
  
  part.Iwant	= VS_m_WeldAttr ;
  part.specific	= (void *) &joint ;
  
  sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &part ),
			targetid= my_id ) ;
  // This class check has been added for TR179900519
  if(jnd2.obj_id.objid != NULL_OBJID)
  {
    om$get_classid ( osnum   = jnd2.obj_id.osnum,
		     objid    = jnd2.obj_id.objid,
		     p_classid      = &StiffObjClass ) ;
    
    if( om$is_ancestry_valid( superclassid  = OPP_VSbeam_class_id,
			      subclassid = StiffObjClass ) == OM_S_SUCCESS )
      stiffFlag = TRUE;
  }

  if( ( joint.weldAttr.info & VS_m_wldWeldAllAround )||
      ( joint.weldAttr.side == VS_K_wldBothSides ) ) {
    /*
     * Multiply length by 2.
     * after checking if the second element is a stiffener
     * for TR179900519
     */
    if(stiffFlag == TRUE)
      mp->dims[0] *= 2 ;
  }
  
#if 0
  
  sts = om$send(	msg	= message VSjoint.VSgetJoinedFeatures(
    msg, &jnd1, &jnd2, NULL ),
			targetid= my_id ) ;
  
  sts = vs$getJunctionType(	msg		= msg,
				elToJoin1	= &jnd1,
				elToJoin2	= &jnd2,
				junctionType	= &jType ) ;
  switch( jType ) {
    /*
     * For a beam/stiffener joiend to a plate, we divided by 2
     * since the weld curve probably goes around the, say bottom
     * of the stiffener's web.
     */
    case VS_K_J_BM_PL :
    case VS_K_J_PL_BM :
    case VS_K_J_ST_TP :
    case VS_K_J_ST_BT :
    case VS_K_J_BT_ST :
    case VS_K_J_TP_ST :
      mp->dims[0] *= 0.5 ; break ;
  }
#endif
  
  /*
   * Success no matter what.
   */
  *msg	= MSSUCC ;
  sts	= OM_S_SUCCESS ;
wrapup:
  End
  return sts ;
  
} /* method VSgetMassProperties */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

