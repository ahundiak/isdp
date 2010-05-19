/* $Id: VDgetDgnPar.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */
/* VDS *************************************************************
 *
 * File:        vddgninfo/func/VDgetDgnPar.I
 *
 * Description:
 *      those functions are used for Design Setup parameter command
 *      VDdgnInfoInternal[]  
 *	VDdgnInfoDefault[]
 *	VD_dgnSt_GetInternStr
 *	VD_dgnSt_GetDefaultInfo	
 *      VD_dgnSt_SetInfoStr 
 *	VD_dgnSt_cvrtToString
 *	VDgetDgnStParam
 *	VDsetDgnDefColl
 * 
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgetDgnPar.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/07/17  14:16:12  pinnacle
# Replaced: vddgninfo/func/VDgetDgnPar.I for:  by yzhu for vds
#
# Revision 1.1  1997/07/08  16:11:40  pinnacle
# Created: vddgninfo/func/VDgetDgnPar.I by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	06/01/97	yzhu		create
 *	07/16/97	yzhu		add VDsetDgnDefColl
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

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vddgndef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "vderrmacros.h"

/*-LIST OF DESIGN SETUP KEYWORDS -----------------------------------------*/
/*
 * Keywords may be added before the end-of-list line.
 */

%safe

/* static list is used to store info for form VDdgnSrtPrm */ 
static VD_dgnInfoInternal VDdgnInfoInternal[] =
{
/* name in coll,   access index,      gadget,     variable type */   
 "symbDrFile"	,	1	,	17	,	5	,
 "symbDrStatus"	,	2	,	15	,	3	,
 "pidStatus"	,	3	,	13	,	3	,

/*
 * Closing Line of buffer.
 */
 NULL		,	0	,	0	,	0	

};

/* static list is used to store default value */
static VD_dgnInfoDefault VDdgnInfoDefault[] =
{
/* name in coll,   access index,   default value */
 "symbDrFile"   ,	1	,  "attr.symb"	,
 "symbDrStatus"	,	2	,	"0"	,
 "pidStatus"	,	3	,	"0"	,

/*
 * Closing Line of buffer.
 */
 NULL		,	0	,	NULL

};

%endsafe


/*
 * ----------------------------------------------------------------------
 */

from  ACrg_collect  	import  ACadd_list_attribute;
from  ACrg_collect	import  ACget_attribute_at_index;
from  NDmacro		import  ACgive_structure;
/*
 * ----------------------------------------------------------------------
 */

long	VD_dgnSt_GetInternStr( index, info )

int			index ;
VD_dgnInfoInternal	*info ;

{
VD_dgnInfoInternal	*lookup ;

     SetProc ( VD_dgnSt_GetInternStr ); Begin
     /*
      * find the attribute name.
      */
     for( lookup = VDdgnInfoInternal ; lookup->index ; lookup++ ) {
	if( lookup->index == index ) {
		info->text	= lookup->text ;
		info->index	= lookup->index ;
		info->gadget	= lookup->gadget ;
		info->type	= lookup->type ;
                End
		return TRUE ;
	}
     }

     End
     return FALSE ;
}

/*
 * ----------------------------------------------------------------------
 */
long    VD_dgnSt_GetDefaultInfo( index, info )

int                     index ;
VD_dgnInfoDefault       *info ;

{
VD_dgnInfoDefault       *lookup ;

     SetProc ( VD_dgnSt_GetDefaultInfo ); Begin
     /*
      * find the attribute name.
      */
     for( lookup = VDdgnInfoDefault; lookup->index ; lookup++ ) {
        if( lookup->index == index ) {
                info->ntext     = lookup->ntext ;
                info->vtext     = lookup->vtext ;
                info->index     = lookup->index ;
		End
                return TRUE ;
        }
     }

     End
     return FALSE ;
}
	

/*
 * ----------------------------------------------------------------------
 */

long	VD_dgnSt_SetInfoStr( retStr, type, index, info )

struct	ret_struct	*retStr;
int			type ;
int			index ;
VD_dgnStInfo		*info ;
	
{
char			*ptr ;

        SetProc ( VD_dgnSt_SetInfoStr ); Begin
	info->type = type ;
	ptr = retStr->var.text_st.text_string;

	switch( type ){

	case VD_dgnSt_Type_char : 

		info->val.cValue	= *ptr ;
		break ;

	case VD_dgnSt_Type_double : 

		info->val.dValue	= atof( ptr );
		break ;

	case VD_dgnSt_Type_short : 

		info->val.sValue	= atoi( ptr );
		break ;

	case VD_dgnSt_Type_int : 

		info->val.iValue	= atoi( ptr );
		break ;

	case VD_dgnSt_Type_string : 

		strcpy( info->val.sString, ptr );
		break ;

	case VD_dgnSt_Type_point : 

		info->val.point[index]	= atof( ptr );
		break ;

	case VD_dgnSt_Type_vec :

		info->val.vec[index]	= atof( ptr );
		break ;

	default: goto wrapup;
	}

        End
	return TRUE ;

wrapup:
        End
	return FALSE ;
}

/*
 * ----------------------------------------------------------------------
 */
long	VD_dgnSt_cvrtToString(  dgnInfo, index, buffer )

VD_dgnStInfo		*dgnInfo ;
IGRint			index ;
IGRchar			*buffer ;
{

        SetProc ( VD_dgnSt_cvrtToString ); Begin
	switch( dgnInfo->type ){

	case VD_dgnSt_Type_char   : 

		sprintf( buffer, "%c", dgnInfo->val.cValue );
		break ;

	case VD_dgnSt_Type_double :

		sprintf( buffer, "%f", dgnInfo->val.dValue );
		break ;

	case VD_dgnSt_Type_short  :

		sprintf( buffer, "%d", dgnInfo->val.sValue );
		break ;

	case VD_dgnSt_Type_int    :

		sprintf( buffer, "%d", dgnInfo->val.iValue );
		break ;

	case VD_dgnSt_Type_string :

		sprintf( buffer, "%s", dgnInfo->val.sString );
		break ;

	case VD_dgnSt_Type_point  :

		sprintf( buffer, "%f", dgnInfo->val.point[index] );
		break ;

	case VD_dgnSt_Type_vec    :

		sprintf( buffer, "%f", dgnInfo->val.vec[index] );
		break ;

	default:
		strcpy( buffer, "" );

	}

	End
	return TRUE ;
}

/*
 * ----------------------------------------------------------------------
 */

long   VDgetDgnStParam(	msg, index,  info )

long			*msg;		/* Return message	*/
int			index;		/* index		*/
VD_dgnStInfo		*info;		/* Output Structure	*/

{
IGRint			rc ,
			type = 0,
			dirIndex = -1;
struct	ret_struct	retStr ;

long			sts;
IGRchar			*name ;
GRname			AttrName;
struct GRid		collId;
struct GRmd_env		mdEnv ;
VD_dgnInfoInternal	*lookup ;

     SetProc( VDgetDgnStParam ); Begin

     sts = OM_S_SUCCESS;
     *msg = MSSUCC;

     if( ! index ){	
	/*
	 * collector index does not exist.
	 */
	*msg = MSFAIL ; goto wrapup ;
     }

     /* get collector object */
     sts = VDgetVdCollId ( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );

     if ( !(sts & 1) )
     {
	/* collector does not exist */
	*msg = MSFAIL ; 
	return VD_UNDEFINED;
     }

     /*
      * find the attribute name.
      */
     name = NULL ;
     for( lookup = VDdgnInfoInternal ; lookup->index ; lookup++ ) {
	if( lookup->index == index ) {
		name = lookup->text ;
		type = lookup->type ;
		break ;
	}
     }

     if( ! name ){
	/*
	 * Attribute Name for Type not found.
	 */
	*msg = MSFAIL ; goto wrapup ;
     }

     strcpy( AttrName, name );

     sts = _VD_SEND_OBJN(	collId,
			NDmacro.ACgive_structure( &rc, &dirIndex, AttrName,
						  &retStr, &mdEnv ));


     if(( ! (sts&rc&1 )) ||
	   ( !strcmp (retStr.var.text_st.text_string, VD_UNDEFINED_STR) ))
     {
	   *msg = MSFAIL ; 
	   return VD_UNDEFINED;
     }

     sts = VD_dgnSt_SetInfoStr( &retStr, type, 0, info );
     if( ! (sts&1 )){ *msg = MSFAIL ; goto wrapup ; }

wrapup:

     End
     return sts;
}
/************************************************************************
 * dgnColl: need to free in calling function.
 * return code:  
 *     status       = MFAIL( 0 ),   		not success 
 *     status       = OM_S_SUCCESS( 1 ),  	success 
 ***********************************************************************/

long   VDsetDgnDefColl( msg, dgnColl, collId )
long                    *msg;           /* Return message        */
struct  ACrg_coll       *dgnColl;       /* (OUT) collector  list */
struct  GRid            *collId ;       /* (OUT) collector id    */ 
{
int			status, i; 	
VD_dgnInfoDefault       defInfo ;

     SetProc( VDsetDgnDefColl ); Begin

     *msg = MSSUCC;
     status = OM_S_SUCCESS;

     dgnColl = NULL;
     /*
      * check if design collector exists or not.
      */
     collId->objid = NULL_OBJID ;
     status =
     VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, collId );
     if( ! (status&*msg&1)){
     	/*
      	 *  force to generate a default collector
      	 */
        status =
        VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, TRUE, collId );
        if( ! (status&*msg&1)){
             /*
              * stop processing. There is something wrong.
              */
              *msg = MSFAIL ;
              status = MSFAIL;
              goto wrapup ;
        }
        /* allocate memory */
        dgnColl = _MALLOC( VD_K_dgnSt_MaxAttr, struct ACrg_coll);

        /*
         * Get default information.
         */

        for( i=1 ; i<= VD_K_dgnSt_MaxAttr ; i++ ){

            if( ! (VD_dgnSt_GetDefaultInfo( i, &defInfo ))) continue ;

            dgnColl[i-1].desc.type = AC_ATTRIB_TEXT;
            strcpy( dgnColl[i-1].name, defInfo.ntext );
            strcpy( dgnColl[i-1].desc.value.att_txt, defInfo.vtext );
        }

        /* set default value to collector */
        status =
        _VD_SEND_OBJN(  *collId,
                  ACrg_collect.ACadd_list_attribute( msg, 
						VD_K_dgnSt_MaxAttr,
                                           	dgnColl ));
        if( ! (status&*msg&1)){
             /*
              * stop processing. There is something wrong.
              */
              *msg = MSFAIL ;
              status = MSFAIL;
              goto wrapup ;
        }

     }
wrapup:
     End
     return status;
}
end implementation Root;

