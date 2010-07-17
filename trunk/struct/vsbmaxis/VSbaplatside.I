/* $Id: VSbaplatside.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbaplatside.I
 *
 * Description: Various attribute acces methods
 *		
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbaplatside.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/02/20  18:24:18  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 01/22/98  adz       Data reduction to final curve.
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 * 02/20/98  ah        CR179800677 - Option to force paramertization to follow
 *                                   parent support curve vice surface
 *                     I added all the new attribute methods to this file
 ***************************************************************************/

class implementation VSbeamAxis ;

#include <stdio.h>
#include "vsbmaxisdef.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
/* I really don't understand what is going on here
 * It should be simply setting the right most bit
 * for top of plate.
 *
 * Should simply test whichSide then |= or &=
 * Leave alone for now, verify that switching plate side does not
 * mess up new atributes
 */
method VSputPlateSide( long	*msg ;
		       int	whichSide ) {

	SetProc( VSbeamAxis_VSputPlateSide ) ; Begin ; __DBGpr_me() ;

	me->flagAttr |= whichSide ;

	/*
	 * Remove the opposite flag.
	 */
	switch( whichSide ) {
		case VS_K_baOnTopOfPlate :
			me->flagAttr &= ~VS_K_baOnBotOfPlate ;
			break ;

		case VS_K_baOnBotOfPlate :
			me->flagAttr &= ~VS_K_baOnTopOfPlate ;
			break ;
	}

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSputPlateSide */

/* CR179800676
 * I added this mainly for consistency, at various points
 * checks are being made using the VS_K_baExtendAxis mask to determine
 * plate side.  Don't know why.
 *
 * If something has been broken than this is where the problem lies
 */
method VSgetPlateSide( long	*msg ;
		       int	*whichSide ) {

	SetProc( VSbeamAxis_VSgetPlateSide ) ; Begin ; __DBGpr_me() ;

	if (me->flagAttr & VS_K_baOnTopOfPlate) *whichSide = VS_K_baOnTopOfPlate;
	else                                    *whichSide = VS_K_baOnBotOfPlate;
	
	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSgetPlateSide */

/*----------------------------------------------------------------------------
 * CR179800676
 */
method VSputExtend( long *msg ;
		    int	  extend0;
		    int   extend1
) 
{

	SetProc( VSbeamAxis_VSputExtend ) ; Begin ; __DBGpr_me() ;

	if (extend0) me->flagAttr |=  VS_K_baExtend0;
	else         me->flagAttr &= ~VS_K_baExtend0;

	if (extend1) me->flagAttr |=  VS_K_baExtend1;
	else         me->flagAttr &= ~VS_K_baExtend1;
	
	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSputExtend */

/*----------------------------------------------------------------------------*/
method VSgetExtend( long *msg ;
		    int	 *extend0;
		    int  *extend1
) 
{

	SetProc( VSbeamAxis_VSgetExtend ) ; Begin ; __DBGpr_me() ;

	if (me->flagAttr & VS_K_baExtend0) *extend0 = 1;
	else                               *extend0 = 0;
	
	if (me->flagAttr & VS_K_baExtend1) *extend1 = 1;
	else                               *extend1 = 0;
	
	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSputExtend */

/* ---------------------------------------------------------------------------
 * CR179800677
 */

method VSputByCurve(long *msg ;
		    int	  flag) 
{

  SetProc( VSbeamAxis_VSputByCurve ) ; Begin ; __DBGpr_me() ;

  if (flag) me->flagAttr |=  VS_K_baByCurve;
  else      me->flagAttr &= ~VS_K_baByCurve;
	
  *msg = MSSUCC ;

  return OM_S_SUCCESS ;

} /* method VSputByCurve */

/*----------------------------------------------------------------------------*/
method VSgetByCurve( long *msg ;
		    int	 *flag) 
{

  SetProc( VSbeamAxis_VSgetByCurve ) ; Begin ; __DBGpr_me() ;

  if (me->flagAttr & VS_K_baByCurve) *flag = 1;
  else                               *flag = 0;
	
  *msg = MSSUCC ;

  return OM_S_SUCCESS ;

} /* method VSputByCurve */

/* ----------------------------------------------------------------------------
 * No CR, might be useful later
 */
method VSputSpare(long *msg ;
	          int	flag) 
{

  SetProc( VSbeamAxis_VSputSpare ) ; Begin ; __DBGpr_me() ;

  if (flag) me->flagAttr |=  VS_K_baSpare;
  else      me->flagAttr &= ~VS_K_baSpare;
	
  *msg = MSSUCC ;

  return OM_S_SUCCESS ;

} /* method VSputSpare */

/*----------------------------------------------------------------------------*/
method VSgetSpare(long *msg ;
		  int  *flag) 
{

  SetProc( VSbeamAxis_VSgetSpare ) ; Begin ; __DBGpr_me() ;

  if (me->flagAttr & VS_K_baSpare) *flag = 1;
  else                             *flag = 0;
	
  *msg = MSSUCC ;

  return OM_S_SUCCESS ;

} /* method VSputSpare */

end implementation VSbeamAxis ;
