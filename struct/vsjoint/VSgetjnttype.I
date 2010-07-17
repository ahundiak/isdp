/* $Id: VSgetjnttype.I,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSgetjnttype.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSgetjnttype.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/14  13:21:28  pinnacle
# Created: vsjoint/VSgetjnttype.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "EMSmsgdef.h"
#include "vs.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define VS_K_ButtWeld 		1
#define VS_K_FilletWeld 	2

/*----------------------------------------------------------------------------*/
method VSgetJointType(	long			*msg ;
			struct GRobj_env	feature0 ;
			struct GRobj_env	feature1 ;
			int			*weldType ) {

	long			sts ;	/* OM return code		*/
	struct GRobj_env	bot0,	/* Bottom surface of plate #0	*/
				top0,	/* Top    surface of plate #0	*/
				bot1,	/* Bottom surface of plate #1	*/
				top1 ;	/* Top    surface of plate #1	*/

	unsigned long   fe0Type ;
	unsigned long   fe1Type ;
	int		opCount0 = 0,
			opCount1 = 0 ;
	VSoperator      *opList0 = NULL,
			*opList1 = NULL ;
	struct GRobj_env	plates[2] ;

	SetProc( VSjoint_VSgetJointType ) ; Begin ; __DBGpr_me() ;

#ifdef vsDEBUG
	printf( "\tfeature 0 " ) ; ShowObj( &feature0._grid ) ;
	printf( "\tfeature 1 " ) ; ShowObj( &feature1._grid ) ;
#endif
	sts = om$send(  msg     = message VSfeature.VSgetResultType(
                                                                msg, &fe0Type ),
                        targetid= feature0._objid,
			targetos= feature0._osnum ) ;

	sts = om$send(  msg     = message VSfeature.VSgetResultType(
                                                                msg, &fe1Type ),
                        targetid= feature1._objid,
                        targetos= feature1._osnum ) ;

 
	if( ( fe0Type & VS_m_PLATE ) && ( fe1Type & VS_m_PLATE ) ||
	    ( fe0Type & VS_m_BEAM  ) && ( fe1Type & VS_m_BEAM  ) ) {
        	if( ( ( fe0Type & VS_m_SUB_generic ) == VS_m_SUB_generic ) && 
		    ( ( fe0Type & VS_m_SUB_generic ) == VS_m_SUB_generic ) ) {
			 sts = om$send(  msg = message VSfeature.VSgetOperators(
								msg,
								&opCount0,
								&opList0 ),
					targetid = feature0._objid,
					targetos = feature0._osnum );
			__CheckRC( sts, *msg,"VSfeature.VSgetOperators",wrapup);

			 sts = om$send(  msg = message VSfeature.VSgetOperators(
								msg,
								&opCount0,
								&opList1 ),
					targetid = feature1._objid,
					targetos = feature1._osnum );
			__CheckRC( sts, *msg,"VSfeature.VSgetOperators",wrapup);

			if( IF_EQ_OBJID( opList0->id, opList1->id ) &&
			    opList0->os == opList1->os ) {
				*weldType = VS_K_ButtWeld ;
			} else {
				goto weld_type ;
			}
		} else if( ( fe0Type & VS_m_PLATE ) && 
			   ( fe1Type & VS_m_PLATE ) ) {
weld_type :
			plates[0] = feature0;
			plates[1] = feature1;
			sts = om$send( msg= message VSjoint.VSgetplplweldtype(
								msg,
								plates,
								weldType ),
					targetid= my_id );
			__CheckRC( sts, *msg, "VSjoint.VSgetplplweldtype", wrapup ) ;
		}
	}

	wrapup :
		_FREE( opList0 ) ; opList0 = NULL ; opCount0 = 0 ;
		_FREE( opList1 ) ; opList1 = NULL ; opCount1 = 0 ;

		End
                return sts ;

}/* method VSgetJointType */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

