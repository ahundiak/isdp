/* $Id: VSfeGetCL.I,v 1.2 2001/02/20 01:18:52 build Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsfeature/VSfeGetCL.I
 *
 * Description:
 *	Gets the support axis (centerline) of a beam; axis copied and
 *	translated for use with Extract Drawing process.
 *
 * Dependencies:
 *      This method expects the calling routine to allocate memory even
 *      though a pointer to pointer is specified.  Clean it up later.
 *
 * Revision History:
 *      $Log: VSfeGetCL.I,v $
 *      Revision 1.2  2001/02/20 01:18:52  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/20  15:52:48  pinnacle
# TR179801020
#
# Revision 1.1  1998/04/20  14:23:34  pinnacle
# TR179801020
#
 * Notes:
 *      This message has been introduced at the VDSroot level, to support the
 *      possibility to get the centerlines from I/ROUTE components.
 *      The message is rejected in VDSroot and is implemented in VRGeneric.
 *
 *	Only one centerline is obtained each time, although a list was
 *	originally specified.
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/14/97  ah      Override VDSroot.VDGetCenterLine
 * 01/07/98  ejm     TR 179701967: Associative Visualization Process
 *	   	     Copied some code from function, VSdrwCstBeamAxis,
 *		     (struct/vsdrawing/VSdrwcstbmax.I) to implement 
 *		     this method.
 * 03/11/98  Ming    TR179800619: Change one of the argument of VSptatpr()
 *                   and GRxform() from bm_env to &copyOE.mod_env. If the
 *                   pointer list is NULL, force to wrapup. Check if the 
 *                   pointer *list is null before allocating memory.
 * 03/15/98  ah      TR179800619 No longer allocate memory for returned list
 * 04/20/98  ah      TR179801020 Moved this routine from VSbeam since VSsubBeam
 *                   objects were not getting the message because of the class
 *                   heirachy
 ***************************************************************************/

class implementation VSfeature ;

/*
#define vsDEBUG 1
#define vserrDEBUG 1
*/

#include "VDtypedef.h"
#include "VDobj.h"

#include "vsgeommacros.h"	/* vs$grCopy */
#include "vsmiscmacros.h"	/* vs$bulk_delete */
#include "vsdbgmacros.h"	/* overrides vsdbgmacros.h in VDmaster.h */


/*
 * Includes of function prototypes.
 */
#include "bsmkvec.h"		/* BSmkvec	*/
#include "maidmx.h"		/* MAidmx	*/
#include "matypemx.h"		/* MAtypemx	*/
#include "vsdrwproto.h"		/* VSdrwGetCardinalPoint */
#include "vspratpt.h"		/* VSptatpr	*/
#include "vsvecmxproto.h"	/* VStranslatemx*/

extern IGRboolean       ASbroadcast_in_progress ;

from VSbeam import VSgetSupportAxis;

/*----------------------------------------------------------------------------*/

method VDGetCenterLine(
  IGRlong   *msg;	/* O : Return code.		   */
  TGRmd_env *bm_env;	/* I : Object mod environment.     */
  IGRint    *count;	/* O : Number of objects found.    */
  TGRid     **list;	/* O : List of centerline objects,    */
                        /*     Calling routine allocates even though have pointer to pointer */  
)
{
  long			sts=OM_S_SUCCESS; /* OM completion code.        */
  IGRlong               NumberOfBytes,    /* Buffer size,get_module_env */
                        BytesReceived;    /* Return size,get_module_env */
  struct GRid		*list_ptr=NULL;   /* Pointer to list of axes.   */
  struct GRid		wfAxis; 	  /* Wireframe of the axis.     */
  struct GRid		bmId;   	  /* Beam objid and osnum       */
  double                cardPnt[3],       /* Cardinal point of beam.    */
                        midPnt[3],        /* Middle point of axis.      */
                        transVec[3],      /* Translation vector.        */
                        transMx[16] ;     /* Translation matrix.        */
  short                 transMxType ;     /* Type of translation matrix.*/
  TGRobj_env		axisOE,copyOE;    /* object environment struct  */
  struct GRmd_env 	axisEnv;          /* module environment struct  */
  IGRboolean		saveBroadcast;



  SetProc( VDGetCenterLine ); Begin

  // Return Code
  *msg = MSSUCC ;

  // Always have this pointer
  if( count == NULL )
  {
    *msg = MSFAIL;
    goto wrapup;
  }

  // Only getting one at most, fail will return 0
  *count = 0;

  // All that was wanted was the count
  if( list == NULL ) {
    *count = 1;
    goto wrapup;
  }
  
  // Originally, this routine would allocate but now the
  // calling program does
  if (*list == NULL) {
    *msg = MSFAIL;
    goto wrapup;
  }
  
  wfAxis.objid = NULL_OBJID ;

  __DBGpr_int( "Current Beam", my_id) ;
  __DBGpr_obj( "bm_env md_id",       bm_env->md_id ) ;
  __DBGpr_int( "bm_env matrix_type", bm_env->md_env.matrix_type ) ;
  __DBGpr_mat( "bm_env matrix",      bm_env->md_env.matrix ) ;

  NumberOfBytes = sizeof(copyOE.mod_env);

  gr$get_module_env(
                msg    = msg,
                sizbuf = &NumberOfBytes,
                buffer = &copyOE.mod_env,
                nret   = &BytesReceived);

  if( !(*msg&1) ){
    printf("\n   gr$get_module_env error\n\n");
    goto wrapup;
  }

  axisOE.mod_env.md_id  = bm_env->md_id;
  axisOE.mod_env.md_env = bm_env->md_env;

  /* Get axis of beam. */
  sts = om$send(
    msg = message VSbeam.VSgetSupportAxis(
      msg,
      bm_env,
      &axisOE
    ),
    senderid = my_id,
    targetid = my_id,
    targetos = OM_Gw_current_OS
  );
  __CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

  axisEnv.md_id = axisOE.mod_env.md_id ;
  VSmulmx( axisOE.mod_env.md_env.matrix, bm_env->md_env.matrix,
	   axisEnv.md_env.matrix, &axisEnv.md_env.matrix_type );

  __DBGpr_obj( "axisEnv md_id",       axisEnv.md_id ) ;
  __DBGpr_int( "axisEnv matrix_type", axisEnv.md_env.matrix_type ) ;
  __DBGpr_mat( "axisEnv matrix",      axisEnv.md_env.matrix ) ;

  /*
   * Copy axis.
  */
  saveBroadcast = ASbroadcast_in_progress ;
  ASbroadcast_in_progress = TRUE ;

  sts = vs$grCopy(
    msg   = msg,
    frEnv = &axisEnv,
    frObj = &axisOE.obj_id,
    toEnv = &copyOE.mod_env,
    toObj = &copyOE.obj_id
  ) ;
  __CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

  ASbroadcast_in_progress = saveBroadcast;

  wfAxis = copyOE.obj_id;  /* Wireframe of axis */

  /*
   * Translate axis to cardinal point of beam.
   */
  bmId.objid = my_id;
  bmId.osnum = OM_Gw_current_OS;

  sts = VSdrwGetCardinalPoint( msg,
  			     &bmId,
  			     bm_env,
  			     0.5,
  			     cardPnt ) ;

  __CheckRC( sts, *msg, "VSdrwGetCardinalPoint", wrapup ) ;

  __DBGpr_vec( "Cardinal point", cardPnt ) ;

  sts = VSptatpr( msg,
  		&copyOE.mod_env,
  		wfAxis.objid,
  		0.5,
  		midPnt ) ;

  __CheckRC( sts, *msg, "VSptatpr", wrapup ) ;

  __DBGpr_vec( "Middle point of axis", midPnt ) ;

  BSmkvec( msg, transVec, midPnt, cardPnt ) ;

  __DBGpr_vec( "Translation vector", transVec ) ;

  /*
   * Translate axis.
   */
  MAidmx( msg, transMx ) ;
  VStranslatemx( transVec, transMx, transMx ) ;
  MAtypemx( msg, transMx, &transMxType ) ;

  sts = om$send( msg	= message GRgraphics.GRxform( msg,
  						      &copyOE.mod_env,
  						      &transMxType,
  						      transMx,
  						      &wfAxis.objid ),
  	       senderid = wfAxis.objid,
  	       targetid = wfAxis.objid,
  	       targetos = wfAxis.osnum ) ;

  __CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup ) ;

  __DBGpr_obj( "Centerline (translated axis)", wfAxis ) ;

  /* Put centerline into list */
  if( *list == NULL )
  {
    // Already checked but leave for now
    //*list = (struct GRid *)malloc(sizeof(struct GRid) * (*count) );
    goto wrapup;
    
  }
  list_ptr = *list;
  list_ptr[0] = wfAxis;
  *count = 1;
  
  __DBGpr_obj( "list_ptr[0]", list_ptr[0] ) ;

  wrapup :

	End
	return sts ;

} /* VDGetCenterLine */

end implementation VSfeature ;



