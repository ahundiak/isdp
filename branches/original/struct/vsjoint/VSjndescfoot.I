/* $Id: VSjndescfoot.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjndescfoot.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjndescfoot.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/01/23  18:54:00  pinnacle
# Replaced: vsjoint/VSjndescfoot.I for:  by impd for struct
#
# Revision 1.2  1997/11/14  13:26:08  pinnacle
# Replaced: vsjoint/VSjndescfoot.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "DIdef.h"
#include "vsglobalmsg.h"
#include "vswelddef.h"
#include "vsiomacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
#include "vsstrngproto.h"
#include "vsvirtualinf.h"
#include "vsdbgmacros.h"

extern long	VSgetWeldCodeDescr(),
		VSgetWeldProcessDescr() ;

#define	  VD_DEBUG
#include <VDdebug.h>
#include "VDweldsym.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*      ********************	GLOBAL VARIABLES  *****************************	*/
/* 	Defined in   :								*/
/*		vdweld/imp/weldtxt.I						*/
/* 	Used also in :								*/
/*		vdweld/cmd/VDweldcmd.I & vdweld/cmd/weldform.I			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern struct VDweld_gadget_sym	sym_char[];

extern int			VDread_weld_sym_char();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*----------------------------------------------------------------------------*/
method VSdescribeOutput( long *msg ; char *attrName, *description ) {

	long			sts ;
	int			ACrc,
				index = -1 ;
	double			val ;
	char			unit [DI_PATH_MAX],
				value[DI_PATH_MAX] ;
	struct ret_struct	rs ;
	struct GRid		myGRid ;
	struct GRmd_env		myEnv ;

	SetProc( VSdescribeOutput ); Begin
	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	VSgetVirtualInfo( msg, &myGRid, &myEnv, NULL ) ;

	sts = om$send(	msg	= message ACcpx.ACgive_structure(
					&ACrc, &index, attrName, &rs, &myEnv ),
			targetid= my_id ) ;
	if( !( sts & 1 & ACrc ) ) {
		strcpy( description, attrName ) ;
	} else {
		val = rs.var.root_pm_st.value ;
		VSdescribeJnFoot( OM_Gw_current_OS, attrName, val,
				  unit ) ;
		if( *unit ) {
			sprintf( value, " = %g (%s)", val, unit ) ;
		} else {
			sprintf( value, " = %g", val ) ;
		}
		strcat( description, value ) ;
	}

	*msg = MSSUCC ;
	End
	return OM_S_SUCCESS ;

} /* method VSdescribeOutput */
/*----------------------------------------------------------------------------*/
int VSdescribeJnFoot( osnum, name, val, unit )

OMuword	osnum ;
char	*name,
	*unit ;
double	val ;
{
	long	msg = 0;
	char	*Unit ;

  __enterFunction ( name = "VSdescribeJnFoot", argfmt = "name = <%s>, val  = %lg", args = `name, val` );

#define EQ_STRING( s1, s2 ) !strcmp( (s1), (s2) )

	if( EQ_STRING( name, VS_K_jnWldCodAttr ) )
	{
	  if ( sym_char[0].fill )	// If $VDS/config/weld_symbols exists & has been read !!!
	  {
	    if ( (int)val < sym_char[0].fill )
	    {
		strcpy ( unit, sym_char[(int)val].desc );
	    }
	    else	// Read from hardcoded static list
	    {
		msg = VSgetWeldCodeDescr( (int) val ) ;
		strcpy( unit, VSmsgkey2string( msg ) ) ;
	    }
	  }
	  else		// Read from hardcoded static list
	  {
		msg = VSgetWeldCodeDescr( (int) val ) ;
		strcpy( unit, VSmsgkey2string( msg ) ) ;
	  }

	} else if( EQ_STRING( name, VS_K_jnWldPrcAttr ) ) {

		msg = VSgetWeldProcessDescr( (int) val ) ;
		strcpy( unit, VSmsgkey2string( msg ) ) ;

	} else if( EQ_STRING( name, VS_K_jnWldInfAttr ) ) {
		int	mask = (int) val,
			n = 0 ;
#define _M( f ) VSmsgkey2string( VS_gI_wld##f )

		*unit = '\0' ;

		if( mask & VS_m_wldWeldAllAround	)
			n += sprintf( unit + n, "%s,", _M( WeldAllAround  ) ) ;
		if( mask & VS_m_wldFieldWeld	)
			n += sprintf( unit + n, "%s,", _M( FieldWeld      ) ) ;
		if( mask & VS_m_wldMeltThru	)
			n += sprintf( unit + n, "%s,", _M( MeltThru       ) ) ;
		if( mask & VS_m_wldFlushContour	)
			n += sprintf( unit + n, "%s,", _M( FlushContour   ) ) ;
		if( mask & VS_m_wldConvexContour	)
			n += sprintf( unit + n, "%s,", _M( ConvexContour  ) ) ;
		if( mask & VS_m_wldConcaveContour	)
			n += sprintf( unit + n, "%s,", _M( ConcaveContour ) ) ;
		if( n ) unit[n-1] = '\0' ;

	} else if( EQ_STRING( name, VS_K_jnWldSidAttr ) ) {

		int	side = (int) val ;

		switch( side ) {
			/*
			 * For new objects it is treated as Left Side
			 */
			case VS_K_wldLeftSide	:
			/*	case VS_K_wldArrowSide 	*/
				strcpy( unit, _M( LeftSide ) ) ; break ;
			case VS_K_wldRightSide	:
			/* case VS_K_wdlOtherSide	:  */
				strcpy( unit, _M( RightSide ) ) ; break ;
			case VS_K_wldBothSides	:
				strcpy( unit, _M( BothSides ) ) ; break ;
			default			: *unit = '\0' ;
		}
 	} else if( EQ_STRING( name, VS_K_jnWldPosAttr ) ) {
 
                int     side = (int) val ;
 
                switch( side ) {
                        case VS_K_wldFloorPos   :
                                strcpy( unit, _M( FloorPos ) ) ; break ;
                        case VS_K_wdlHorzPos    :
                                strcpy( unit, _M( HorzPos ) ) ; break ;
                        case VS_K_wldCeilPos    :
                                strcpy( unit, _M( CeilPos ) ) ; break ;
                        case VS_K_wldVertPos    :
                                strcpy( unit, _M( VertPos ) ) ; break ;
                        default                 : *unit = '\0' ;
                }
#undef _M
	} else if(    EQ_STRING( name, VS_K_jnAllwncAttr )
	           || EQ_STRING( name, VS_K_jnPitchAttr  )
	           || EQ_STRING( name, VS_K_jnIncrLnAttr )
	           || EQ_STRING( name, VS_K_jnWldLenAttr ) 
		   || EQ_STRING( name, VS_K_jnShrnkAttr  )
		   || EQ_STRING( name, VS_K_jnWldSizAttr) ) {

			vs$system_to_unit(	msg	= &msg,
						value	= val,
						osnum	= osnum,
						p_unit	= &Unit ) ;
			if( msg & 1 ) {
				strcpy( unit, VSstripString( Unit ) ) ;
			} else {
				*unit = '\0' ;
			}

	} else if( EQ_STRING( name, VS_K_jnGrvAngAttr ) ) {

			vs$system_to_unit(	msg	= &msg,
						value	= val,
						osnum	= osnum,
						type	= GRIO_ANGLE,
						p_unit	= &Unit ) ;
			if( msg & 1 ) {
				strcpy( unit, VSstripString( Unit ) ) ;
			} else {
				*unit = '\0' ;
			}

	} else {
		*unit = '\0' ;
	}

  __exitFunction ( name = "VSdescribeJnFoot", argfmt = "name = <%s>, unit = <%s>", args = `name, unit` );

	return 1 ;

} /* VSdescribeJnFoot */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
