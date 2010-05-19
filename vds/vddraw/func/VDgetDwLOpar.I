
/* $Id: VDgetDwLOpar.I,v 1.2 2002/05/20 15:19:25 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddraw/func/VDgetDwLOpar.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgetDwLOpar.I,v $
 *      Revision 1.2  2002/05/20 15:19:25  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/02/05  21:58:46  pinnacle
# Replaced: vddraw/func/VDgetDwLOpar.I for:  by yzhu for vds
#
# Revision 1.2  1997/10/07  15:16:34  pinnacle
# Replaced: vddraw/func/VDgetDwLOpar.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/07/28  20:37:34  pinnacle
# Created: vddraw/func/VDgetDwLOpar.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *	05/20/02	ylong		TR6281
 ***************************************************************************/

class implementation Root;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "grdpb.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vddlodef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "vderrmacros.h"

/*-LIST OF LAYOUT KEYWORDS ---------------------------------------------------*/
/*
 * Keywords may be added before the end-of-list line.
 */

%safe

static VD_drwInfoInternal VDdrwInfoInternal[] =
{

 "projPoint"	,	1	,	23	,	6	,
 "projVector"	,	2	,	26	,	7	,
 "sheetColor"	,	3	,	0	,	4	,
 "tblLevel"	,	4	,	30	,	3	,
 "tblColor"	,	5	,	39	,	3	,
 "tblTextColor"	,	6	,	41	,	3	,
 "tblAttColor"	,	7	,	42	,	3	,
 "tblModColor"	,	8	,	43	,	3	,
 "drvLevel"	,	9	,	46	,	3	,
 "objRep_"	,	10	,	49	,	5	,
 "frmHeight"	,	11	,	56	,	2	,
 "frmColor"	,	12	,	62	,	3	,
 "frmStyle"	,	13	,	58	,	4	,
 "frmWeight"	,	14	,	61	,	4	,
 "tblUsrValue"	,	15	,	71	,	4	,
 "tblLinedOut"	,	16	,	72	,	4	,

/*
 * Closing Line of buffer.
 */
 NULL		,	0	,	0	,	0	

};

%endsafe


/*
 * ----------------------------------------------------------------------
 */

from  ACrg_collect	import  ACget_attribute_at_index;
from  NDmacro		import  ACgive_structure;

/*
 * ----------------------------------------------------------------------
 */

long	VD_drwLO_GetInternStr( type, info )

int			type ;
VD_drwInfoInternal	*info ;

{
VD_drwInfoInternal	*lookup ;

     /*
      * find the attribute name.
      */
     for( lookup = VDdrwInfoInternal ; lookup->type ; lookup++ ) {
	if( lookup->type == type ) {
		info->text	= lookup->text ;
		info->var	= lookup->var ;
		info->gadget	= lookup->gadget ;
		info->type	= lookup->type ;
		return TRUE ;
	}
     }

     return FALSE ;
}

	

/*
 * ----------------------------------------------------------------------
 */

long	VD_drwLO_SetInfoStr( retStr, var, index, info )

struct	ret_struct	*retStr;
int			var ;
int			index ;
VD_drwLoInfo		*info ;
	
{
char			*ptr ;

	info->type = var ;
	ptr = retStr->var.text_st.text_string;

	switch( var ){

	case VD_drwLO_Type_char : 

		info->val.cValue	= *ptr ;
		break ;

	case VD_drwLO_Type_double : 

		info->val.dValue	= atof( ptr );
		break ;

	case VD_drwLO_Type_short : 

		info->val.sValue	= atoi( ptr );
		break ;

	case VD_drwLO_Type_int : 

		info->val.iValue	= atoi( ptr );
		break ;

	case VD_drwLO_Type_string : 

		strcpy( info->val.sString, ptr );
		break ;

	case VD_drwLO_Type_point : 

		info->val.point[index]	= atof( ptr );
		break ;

	case	VD_drwLO_Type_vec :

		info->val.vec[index]	= atof( ptr );
		break ;

	default: goto wrapup;
	}

	return TRUE ;

wrapup:
	return FALSE ;
}

/*
 * ----------------------------------------------------------------------
 */
long	VD_drwLO_cvrtToString(  drwInfo, index, buffer )

VD_drwLoInfo		*drwInfo ;
IGRint			index ;
IGRchar			*buffer ;
{

	switch( drwInfo->type ){

	case VD_drwLO_Type_char   : 

		sprintf( buffer, "%c", drwInfo->val.cValue );
		break ;

	case VD_drwLO_Type_double :

		sprintf( buffer, "%f", drwInfo->val.dValue );
		break ;

	case VD_drwLO_Type_short  :

		sprintf( buffer, "%d", drwInfo->val.sValue );
		break ;

	case VD_drwLO_Type_int    :

		sprintf( buffer, "%d", drwInfo->val.iValue );
		break ;

	case VD_drwLO_Type_string :

		sprintf( buffer, "%s", drwInfo->val.sString );
		break ;

	case VD_drwLO_Type_point  :

		sprintf( buffer, "%f", drwInfo->val.point[index] );
		break ;

	case VD_drwLO_Type_vec    :

		sprintf( buffer, "%f", drwInfo->val.vec[index] );
		break ;

	default:
		strcpy( buffer, "" );

	}

	return TRUE ;
}



/*
 * ----------------------------------------------------------------------
 */

long   VDgetDwgLOparam(	msg, type, rep, info )

long			*msg;		/* Return message	*/
int			type;		/* Request type		*/
char			*rep;		/* Request of Repr. Typ */
VD_drwLoInfo		*info;		/* Output Structure	*/

{
IGRint			rc ,
			var = 0,
			dirIndex = -1;
struct	ret_struct	retStr ;

long			sts;
IGRchar			*name ;
GRname			AttrName;
struct GRid		collId;
struct GRmd_env		mdEnv ;
VD_drwInfoInternal	*lookup ;
short			actLevel;
struct IGRdisplay	actDisp;
int			sizebuf, bytesRet;
struct GRdpb_text_symb  text_sym;
     SetProc( VDgetDwgLOparam ); Begin

     sts = OM_S_SUCCESS;
     *msg = MSSUCC;

     if( ! type		||
	 ! info		||
	(( type == VD_K_drwLO_objRep ) && ( ! rep )) ){
	/*
	 * collector Type does not exist.
	 */
	*msg = MSFAIL ; goto wrapup ;
     }

     sts = VDgetVdCollId ( msg, VD_DRWLO_DIR_NAME, FALSE, FALSE, &collId );

     if ( !(sts & 1) )
     {
	/* collector does not exist */
	rc = MSFAIL ;
	*msg = MSFAIL ; goto set_default;
     }

     /*
      * find the attribute name.
      */
     name = NULL ;
     for( lookup = VDdrwInfoInternal ; lookup->type ; lookup++ ) {
	if( lookup->type == type ) {
		name = lookup->text ;
		var  = lookup->var ;
		break ;
	}
     }

     if( ! name ){
	/*
	 * Attribute Name for Type not found.
	 */
	*msg = MSFAIL ; goto wrapup ;
     }

     if( type == VD_K_drwLO_projPoint	||
	 type == VD_K_drwLO_projVector	){

	/*
	 * get the names for the vector or point.
	 */
	GRname	xName, yName, zName ;

	sprintf( xName, "%s_X", name );
	sprintf( yName, "%s_Y", name );
	sprintf( zName, "%s_Z", name );

	sts = _VD_SEND_OBJN(	collId,
			NDmacro.ACgive_structure( &rc, &dirIndex, xName,
						  &retStr, &mdEnv ));
	if( ! (sts&rc&1 )){ *msg = MSFAIL ; goto wrapup ; }

	sts = VD_drwLO_SetInfoStr( &retStr, var, 0, info );
	if( ! (sts&1 )){ *msg = MSFAIL ; goto wrapup ; }
	
	sts = _VD_SEND_OBJN(	collId,
			NDmacro.ACgive_structure( &rc, &dirIndex, yName,
						  &retStr, &mdEnv ));
	if( ! (sts&rc&1 )){ *msg = MSFAIL ; goto wrapup ; }

	sts = VD_drwLO_SetInfoStr( &retStr, var, 1, info );
	if( ! (sts&1 )){ *msg = MSFAIL ; goto wrapup ; }

	sts = _VD_SEND_OBJN(	collId,
			NDmacro.ACgive_structure( &rc, &dirIndex, zName,
						  &retStr, &mdEnv ));
	if( ! (sts&rc&1 )){ *msg = MSFAIL ; goto wrapup ; }

	sts = VD_drwLO_SetInfoStr( &retStr, var, 2, info );
	if( ! (sts&1 )){ *msg = MSFAIL ; goto wrapup ; }
     }
     else{

	strcpy( AttrName, name );

	if( type == VD_K_drwLO_objRep ){
	  sprintf( AttrName, "%s_%s", name, rep );
	}

	sts = _VD_SEND_OBJN(	collId,
			NDmacro.ACgive_structure( &rc, &dirIndex, AttrName,
						  &retStr, &mdEnv ));

set_default :

	if(( ! (sts&rc&1 )) ||
	   ( !strcmp (retStr.var.text_st.text_string, VD_UNDEFINED_STR) ))
	{
	   switch ( type )
	   {
		case  VD_K_drwLO_sheetColor	:
		case  VD_K_drwLO_tblColor	:
		case  VD_K_drwLO_tblTextColor	:
		case  VD_K_drwLO_tblAttColor	:
		case  VD_K_drwLO_tblModColor	:
		case  VD_K_drwLO_frmColor	:
			sizebuf = sizeof ( struct IGRdisplay );
			sts = gr$get_active_display (
				msg 	= msg,
				sizbuf = &sizebuf,
				buffer  = &actDisp,
				nret	= &bytesRet );
		
			info->type = var;
			info->val.sValue = (short) actDisp.color;
                        __DBGpr_int ( "Color", info->val.sValue);
			break;

		case  VD_K_drwLO_tblLevel	:
		case  VD_K_drwLO_drvLevel	:
			sizebuf = sizeof ( short );
			sts = gr$get_active_level (
				msg 	= msg,
				sizbuf = &sizebuf,
				buffer  = &actLevel,
				nret	= &bytesRet );
			info->type = var;
			info->val.sValue = actLevel;
                        __DBGpr_int ( "Level", info->val.sValue);
			break;

                case  VD_K_drwLO_frmStyle       :
     			sizebuf = sizeof ( struct IGRdisplay );
                        sts = gr$get_active_display (
                                msg     = msg,
                                sizbuf = &sizebuf,
                                buffer  = &actDisp,
                                nret    = &bytesRet );

                        info->type = var;
                        info->val.iValue = (int) actDisp.style;
                        __DBGpr_int ( "frmStyle", info->val.iValue);
                        break;


                case  VD_K_drwLO_frmWeight       :
                        sizebuf = sizeof ( struct IGRdisplay );
                        sts = gr$get_active_display (
                                msg     = msg,
                                sizbuf = &sizebuf,
                                buffer  = &actDisp,
                                nret    = &bytesRet );

                        info->type = var;
                        info->val.iValue = (int) actDisp.weight;
                        __DBGpr_int ( "frmWeight", info->val.iValue);
                        break;


                case  VD_K_drwLO_frmHeight       :
			/* if can find the active text size */
                        gr$get_text_symb(buffer = &text_sym);
                        info->type = var;
                        info->val.dValue = text_sym.Active_height;
                        __DBGpr_dbl( "frmHeight", info->val.dValue);
                        break;
                case  VD_K_drwLO_tblUsrValue       :
                case  VD_K_drwLO_tblLinedOut       :
			/* if reserve lined out and/or user values */
                        info->type = var;
			info->val.iValue = 0;
                        break;
                default:
                        return VD_UNDEFINED;

	   }
	   return OM_S_SUCCESS;
          // return VD_UNDEFINED; It is a bug. User never can set defualt value
	}

	sts = VD_drwLO_SetInfoStr( &retStr, var, 0, info );
	if( ! (sts&1 )){ *msg = MSFAIL ; goto wrapup ; }
     }

wrapup:

	End
	return sts;
}

end implementation Root;

