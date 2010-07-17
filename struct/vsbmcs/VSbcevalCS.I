/* $Id: VSbcevalCS.I,v 1.1.1.1 2001/01/04 21:10:16 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbmcs/VSbcevalCS.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbcevalCS.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:16  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/21  19:03:18  pinnacle
# TR179702512
#
# Revision 1.2  1997/09/29  14:14:00  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 *      01/21/98 ah     Added VSbeamGetState()
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Inludes of function prototypes.
 */
#include "vsbeamproto.h"
#include "vsvecmxproto.h"

/* -------------------------------------------------
 * TR179700969 
 * TR179702512 
 * Wrapper for getting beam state
 */ 
long VSbeamGetState(struct GRid *beamId, int *state)
{
  long          notUsed ;
  long          sts,msg;
  unsigned long myType ;

  *state = 0;

  sts = om$send(msg = message VSfeature.VSgetResultType(&msg, &myType ),
    senderid = beamId->objid, 
    targetid = beamId->objid, 
    targetos = beamId->osnum 
  );

  if( !( myType & VS_m_SRC_generic ) ) {            	
    sts = om$send( 
      msg = message VSfeature.VSforwardToSource(
        &notUsed, 
        OM_e_wrt_object,
        message ACncpx.ACget_STATE(state)),
        senderid = beamId->objid, 
        targetid = beamId->objid, 
        targetos = beamId->osnum 
      );
  } else {
    sts = om$send( msg = message ACncpx.ACget_STATE(state ),
      senderid = beamId->objid, 
      targetid = beamId->objid, 
      targetos = beamId->osnum 
    );
  }
  return 1;
}

/*----------------------------------------------------------------------------*/
long VSevalBeamCS( msg, beam, endno, cardPt, CS )

long			*msg ;
struct GRobj_env	*beam ;
int			endno ;
enum VScardinal_point	cardPt ;
IGRmatrix		CS ; {

	long		sts ;		/* OM return code		*/
	struct GRid	profDef ;	/* Profile definition		*/
	VSsuppList	supports ;	/* Beam's supports		*/
	int		count ;		/* ... of supports		*/
	int		invx,		/* Must inverse x-axis ?	*/
			invy ;		/* Must inverse y-axis ?	*/
	IGRvector	origin ;

	sts = om$send(	msg	= message VSbeam.VSgetProfileDef( msg, &profDef ),
			targetid= beam->_objid,
			targetos= beam->_osnum,
			senderid= beam->_objid ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	sts = om$send(	msg	= message VSpart.VSgetSupports(
					msg, &beam->mod_env, &count, supports ),
			targetid= beam->_objid,
			targetos= beam->_osnum,
			senderid= beam->_objid ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
							msg,
							&beam->mod_env,
							supports + 0,
							supports + 1,
							(double) endno,
							&profDef,
							CS ),
			targetid= beam->_objid,
			targetos= beam->_osnum,
			senderid= beam->_objid ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

/* TR179700969 */
/* TR179702512 */
  {	
    IGRboolean cardOpt = FALSE ;
    int        state ;

    VSbeamGetState(&beam->obj_id,&state);

    if( state & VS_m_NdState ) cardOpt = TRUE ;

    VScardpt_to_point( &beam->mod_env, profDef, &cardOpt, cardPt, origin ) ;

  }


	VSmxprodpt( CS, origin, origin ) ;

	for( count = 0 ; count < 3 ; count++ ) {
		CS[count*4+3] = origin[count] ;
	}

	switch( cardPt ) {
		case VS_e_BOT_LEFT : invx = FALSE  ; invy = FALSE  ; break ;
		case VS_e_BOT_RGHT : invx = TRUE   ; invy = FALSE  ; break ;
		case VS_e_UPP_LEFT : invx = FALSE  ; invy = TRUE   ; break ;
		case VS_e_UPP_RGHT : invx = TRUE   ; invy = TRUE   ; break ;
		default		   : *msg = MSINARG ; sts = OM_E_INVARG ;
				     goto wrapup ;
	}

	if( invx ) {
		int i ;

		for( i = 0 ; i < 3 ; i++ ) {
			CS[i*4+0] *= -1. ;
		}
	}
	if( invy ) {
		int i ;

		for( i = 0 ; i < 3 ; i++ ) {
			CS[i*4+1] *= -1. ;
		}
	}
	if( ( invx || invy ) && !( invx && invy ) ) {
		int i ;

		for( i = 0 ; i < 3 ; i++ ) {
			CS[i*4+2] *= -1. ;
		}
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSevalBeamCS */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
