/* $Id: VDqryprvmsg.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/imp / VDqryprvmsg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDqryprvmsg.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/08/30  15:36:18  pinnacle
# Replaced: vdpocket/imp/VDqryprvmsg.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/04/28  17:45:36  pinnacle
# Replace: vdpocket/imp/VDqryprvmsg.I by yzhu for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* 
Name
   VDqryprmsg.I

Description

   This class is an object class containing definitions of queries, which
   will used to define locate criteria's or display criterias.

Notes

abstract

   This class is an abstract class for object having a value.
   In the following methods, a return code  different from EXP_SUCCESS means
   that the job has not been done.

history

   16/08/94 : ADZ - First inplementation.
   28/04/95 : yzhu - Modify VDgive_structure for reallocate problem.
                     original code only work for less then 210 characters
                     after that, need to reallocate string, but allocating 
                     is not work very vell. 
*/


class implementation VDquery ; 

#include	"vdqrydef.h"
#include	"v_miscmacros.h"
#include	"v_dbgmacros.h"
#include	"VDmem.h"
#include	"AS_status.h"

#define _REALLOC( ptr, nelem, type ) \
	(type *) realloc( (ptr), (unsigned) ( (nelem) * sizeof( type ) ) )

/*+mi
  Private Message
	VDcreate

  Abstract
	Given the query information, this method regenerates the attributes
	values according to the given input. The creation will be refused 
	when the object does not have a select criteria.

  Arguments
	IGRlong			* msg ;
	IGRchar			* select ;
	IGRchar			* where ;
	IGRchar			* comment ;

  Status/Return Code
      status == OM_S_SUCCESS	if success;

-mi*/
method	VDcreate(	IGRlong			* msg;
			IGRchar			* select ;
			IGRchar			* where ;
			IGRchar			* comment )
{
IGRlong			status = OM_S_SUCCESS ;

        SetProc( VDcreate ); Begin
        *msg = MSSUCC;

	if( ! select ) {
		*msg = OM_E_ABORT ;
		return OM_S_SUCCESS ;
	}

	/*
	 * threat the creation the same as modify.
	 */

	status =
	om$send(msg = message VDquery.VDmodify(		msg,
							select,
							where,
							comment ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	*msg = MSSUCC;
        End
	return OM_S_SUCCESS;
}

/*+mi
  Private Message
	VDmodify

  Abstract
	Given the query information, this method regenerates the attributes
	values according to the given input.

  Arguments
	IGRlong			* msg ;
	IGRchar			* select ;
	IGRchar			* where ;
	IGRchar			* comment ;

  Status/Return Code
      status == OM_S_SUCCESS	if success;

-mi*/
method	VDmodify(	IGRlong			* msg;
			IGRchar			* select ;
			IGRchar			* where ;
			IGRchar			* comment )
{
IGRlong			status = OM_S_SUCCESS ;
GRname			name;
	SetProc( VDmodify ); Begin
        *msg = MSSUCC;

	if( select ){
		/*
		 * modify the "select" string of the query.
		 */

		strcpy( name, VD_qry_nmSelect );
		status =
		om$send(msg = message VDquery.ACadd_attribute(	msg,
								name,
								select ),
			targetid = my_id );
		as$status( action = RET_STATUS );
	}

	if( where ){
		/*
		 * modify the "where" string of the query.
		 */

		strcpy( name, VD_qry_nmWhere );
		status =
		om$send(msg = message VDquery.ACadd_attribute(
							msg,
							name,
							where ),
			targetid = my_id );
		as$status( action = RET_STATUS );
	}

	if( comment ){
		/*
		 * modify the "comment" string of the query.
		 */

		strcpy( name, VD_qry_nmComment );
		status =
		om$send(msg = message VDquery.ACadd_attribute(
							msg,
							name,
							comment ),
			targetid = my_id );
		as$status( action = RET_STATUS );
	}

	*msg = MSSUCC;
        End
	return OM_S_SUCCESS;
}

/*+mi
  Private Message
	VDgive_query

  Abstract
	This method return the query information, based on the requested
	pointers of the arguments. This interface is only usefull for the
	three predefined attributes. 

  Arguments
	IGRlong			* msg ;
	IGRchar			** select ;
	IGRchar			** where ;
	IGRchar			** comment ;

  Status/Return Code
      status == OM_S_SUCCESS	if success;

-mi*/
method	VDgive_query(	IGRlong			* msg;
			IGRchar			** select ;
			IGRchar			** where ;
			IGRchar			** comment )
{
IGRlong			status = OM_S_SUCCESS ;
IGRchar			name[DI_PATH_MAX];
        SetProc( VDgive_query ); Begin
        *msg = MSSUCC;

	if( select ){
		/*
		 * set the total "select" string of the query.
		 */

		strcpy( name, VD_qry_nmSelect );
		status =
		om$send(msg = message VDquery.VDgive_structure(
							msg,
							name,
							select ),
			targetid = my_id );
		as$status( action = RET_STATUS );
	}

	if( where ){
		/*
		 * get the total "where" string of the query.
		 */

		strcpy( name, VD_qry_nmWhere );
		status =
		om$send(msg = message VDquery.VDgive_structure(
							msg,
							name,
							where ),
			targetid = my_id );
		as$status( action = RET_STATUS );
	}

	if( comment ){
		/*
		 * get the total "comment" string of the query.
		 */

		strcpy( name, VD_qry_nmComment );
		status =
		om$send(msg = message VDquery.VDgive_structure(
							msg,
							name,
							comment ),
			targetid = my_id );
		as$status( action = RET_STATUS );
	}
        End
	return	status ;
}

/*+mi
  Private Message
	VDgive_structure

  Abstract
	This method return the query information, based on the requested
	pointers of the arguments. This interface is only usefull for the
	three predefined attributes. 

  Arguments
	IGRlong			* msg ;
	IGRchar			* name ;
	IGRchar			** string ;

  Status/Return Code
      status == OM_S_SUCCESS	if success;

-mi*/
method	VDgive_structure(	IGRlong		* msg ;
				IGRchar		* name ;
				IGRchar		** string )
{
IGRlong			status = OM_S_SUCCESS ;
IGRchar			gvName[DI_PATH_MAX];
IGRint			directIndex = 0,
			szString = 0,
			szBuffer = 0,
			index = 0,
			rc;
struct	ret_struct	retStr;
struct	GRmd_env	mdEnv;

        SetProc( VDgive_structure ); Begin
        *msg = MSSUCC;

	_FREE( *string );
	*string = NULL ;

	if( ! VDqryNameFromAttrList( name, gvName ) ){
		/*
		 * only the predefine attribute names are having access here.
		 */
		*msg = OM_E_ABORT;
		return status ;
	}
		
	while( status & *msg & 1 ){

		sprintf( gvName, "%s%d", name, index++ );
		status =
		om$send(msg = message ACrg_collect.ACgive_structure(
								&rc,
								&directIndex,
								gvName,
								&retStr,
								&mdEnv ),
			mode     = OM_e_wrt_message,
			targetid = my_id );
		if(! ( status & rc & 1 )){

			/*
			 * no more occurence found.
			 */
			status = OM_S_SUCCESS;
			*msg = MSSUCC;
			break;
		}

		/*
		 * create and concatenate the string
		 */
		if( ! *string ){
			szBuffer = 3 * VD_qry_szLine ;
			if( !(  *string = _MALLOC( szBuffer, IGRchar ))){
				*msg = MSFAIL ;
				goto quit ;
			}
			*string[0] = '\0';
		}

		szString += strlen( retStr.var.text_st.text_string );

		if( szString >= szBuffer ){
			szBuffer += VD_qry_szLine ;
			if( !( *string = _REALLOC( *string, szBuffer, char ))){
				*msg = MSFAIL ;
				goto quit ;
			}
		}

		strcat( *string, retStr.var.text_st.text_string );
	}

quit:
        End
	return status ;
}

/*+mi
  Private Message
	VDname_query

  Abstract
	Thsi method creates and/or modify the name of the query. The query
	name is a limited string.

  Arguments
	IGRlong			* msg ;
	IGRchar			* name ;

  Status/Return Code
      status == OM_S_SUCCESS	if success;

-mi*/

method	VDname_query(	IGRlong			* msg;
			IGRchar			* name )
{
IGRlong			status = OM_S_SUCCESS ;
GRname			gvName;
struct	ret_struct	retStr;
struct	GRmd_env	mdEnv;
IGRint			rc,
			directIndex = 0;

        SetProc( VDname_query); Begin
        *msg = MSSUCC;

	strcpy( gvName, VD_qry_nmName );

	status =
	om$send(msg = message ACrg_collect.ACgive_structure(	&rc,
								&directIndex,
								gvName,
								&retStr,
								&mdEnv ),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	if(! ( status & rc & 1 )){

		/*
		 * does not exist -> create attribute.
		 */
		status =
		om$send(msg = message ACrg_collect.ACadd_attribute_by_type(
								msg,
								AC_ATTRIB_TEXT,
								gvName,
								name ),
			mode     = OM_e_wrt_message,
			targetid = my_id );
		as$status( action = RET_STATUS );
	}
	else{
		/*
		 * does exist -> modify attribute.
		 */
		status =
		om$send(msg = message ACrg_collect.ACmod_attribute(
								msg,
								gvName,
								name ),
			mode     = OM_e_wrt_message,
			targetid = my_id );
		as$status( action = RET_STATUS );
	}

        End
	return status ;
}
end implementation VDquery;
