/* $Id: VDqueryi.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/imp / VDqueryi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDqueryi.I,v $
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
   VDqueryi.I

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
*/


class implementation VDquery ; 

#include	"vdqrydef.h"
#include	"AS_status.h"

/*+mo
  Overridden Message
        GRgetobjinfo from GRgraphics

  Abstract
        Give the object name for selection and add the query descrioption
	to the name.

  Arguments
	IGRlong			*msg
	struct	GRobj_info	*info;

  Status/Return Code
      status == OM_S_SUCCESS	if success;

-mo*/
method	GRgetobjinfo(	IGRlong			*msg;
			struct GRobj_info	*info )
{
IGRlong			status = OM_S_SUCCESS ;
IGRint			directIndex = 0,
			rc;
struct	ret_struct	retStr;
IGRchar			name[DI_PATH_MAX];

        *msg = MSSUCC;

	strcpy( info->type, VD_qry_nmObject );
	strcpy( name, VD_qry_nmName );

	status =
	om$send( msg = message ACrg_collect.ACgive_structure(
							&rc,
							&directIndex,
							name,
							&retStr,
							NULL ),
		targetid = my_id,
		mode	 = OM_e_wrt_message );

	if( status & rc & 1 ){
		sprintf( info->type, "%s [%s]",
					info->type,
					retStr.var.text_st.text_string );
	}

	*msg = MSSUCC;
	return OM_S_SUCCESS;
}

/*+mo
  Overridden Message
	DIgive_output from ACncpx

  Abstract
	give desctiption of object for the directory command form.

  Arguments
	IGRchar			*formula


  Status/Return Code
      status == OM_S_SUCCESS	if success;

-mo*/

method	DIgive_output(	IGRchar	* formula )
{
IGRlong			status = OM_S_SUCCESS;

	/*
	 * give object type to object for explanation.
	 */
	strcat( formula, "[" );
	strcat( formula, VD_qry_nmObject );
	strcat( formula, "]" );

	return	status ;
}

/*+mo
  Overridden Message
        ACrem_attribute from ACdiowner

  Abstract
	Predefined attributes name can use mutiple lines in the collector.
	Whenever one of these lines is called, all lines will be removed.
	
  Arguments
	IGRlong		* rc;
	IGRchar		* name ;

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_ABORT	name not found.

-mo*/

method	ACrem_attribute(	IGRlong	* msg;
				IGRchar	* name )
{
IGRlong			status = OM_S_SUCCESS;
GRname			attrName,
			remName;		/* argument name to use. */
IGRshort		index = 0;

	/*
	 * give attribute name and remove all lines,
	 */

	*msg = MSSUCC;

	if( ! name ){
		*msg = OM_E_ABORT ;
		return status ;
	}


	/*
	 * test if we like to delete the "select" or the "where" clause of
	 * the query.
	 */

	if( VDqryNameFromAttrList( name, remName )){

	    while( status & *msg & 1 ){

		sprintf( attrName, "%s%d", remName, index++ );
		status =
		om$send( msg = message ACrg_collect.ACrem_attribute(
						msg,
						attrName ),
			targetid = my_id,
			mode	 = OM_e_wrt_message );
	    }
	    if( *msg == OM_E_ABORT ){
		/*
		 * no name with index found.
		 */
		*msg = MSSUCC;
	    }
	}
	else{
		
		/*
		 * remove any other attribute.
		 */
		status =
		om$send( msg = message ACrg_collect.ACrem_attribute(
							msg,
							name ),
			targetid = my_id,
			mode	 = OM_e_wrt_message );
	
		as$status( action = RET_STATUS );	 
	}
	return	status ;
}


/*+mo
  Overridden Message
        ACmod_attribute from ACdiowner

  Abstract
	Modify the value from any query attribute.

  Algorithm

  Arguments
	IGRlong			* msg;
	IGRchar			* name;
	IGRchar			* value;

  Notes/Remarks
	If "name" is part of the predefined attribute names, the total list
	will be remove and recreated with the string defined in "value".

  Examples

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_xxx	...

-mo*/

method	ACmod_attribute(	IGRlong		* msg ;
				IGRchar		* name ;
				IGRchar		* value )
{
IGRlong			status = OM_S_SUCCESS;
GRname			modName,
			addName,
			prtValue;
IGRshort		index = 0;
IGRint			szValue;
IGRchar			*pValue;

	*msg = MSSUCC;

	if( ! name ){
		*msg = OM_E_ABORT ;
		return status ;
	}

	/*
	 * test if we like to delete the "select" or the "where" clause of
	 * the query.
	 */

	if( VDqryNameFromAttrList( name, modName )){

		/*
		 * remove any other attribute.
		 */
		status =
		om$send(msg = message VDquery.ACrem_attribute(
							msg,
							modName ),
			targetid = my_id );
		as$status( action = RET_STATUS );

		/*
		 * recreate new list, based on attribute name
		 */

		szValue = strlen( value );
		pValue  = value ;

		while ( szValue > VD_qry_szLine	){

			strncpy( prtValue, pValue, VD_qry_szLine );
			prtValue[VD_qry_szLine] = '\0';
			sprintf( addName, "%s%d", modName, index++ );
			
			status =
			om$send(msg = message 
					ACrg_collect.ACadd_attribute_by_type(
								msg,
								AC_ATTRIB_TEXT,
								addName,
								prtValue ),
				targetid = my_id ,
				mode = OM_e_wrt_message );
			as$status( action = RET_STATUS );

			pValue  += VD_qry_szLine ;
			szValue -= VD_qry_szLine ;
		}

		/*
		 * add the last string to list.
		 */
		strcpy( prtValue, pValue );
		sprintf( addName, "%s%d", modName, index++ );

		status =
		om$send(msg = message ACrg_collect.ACadd_attribute_by_type(
								msg,
								AC_ATTRIB_TEXT,
								addName,
								prtValue ),
			targetid = my_id,
			mode     = OM_e_wrt_message );
		as$status( action = RET_STATUS );
	}
	else{
		/*
		 * modify any other attribute.
		 */
		status =
		om$send(msg = message ACrg_collect.ACmod_attribute(
							msg,
							name,
							value ),
			targetid = my_id,
			mode	 = OM_e_wrt_message );
		as$status( action = RET_STATUS );	 
	}

	return status ;

}

/*+mo
  Overridden Message
        ACadd_attribute from ACdiowner

  Abstract
	Add attribute in collectors. The string can be longer then the
	instance buffer length. In that case the string for "select", 
	"comment" and "where" will be split into sub-attributes.

  Algorithm
	See ACadd_attribute from ACdiowner.

  Arguments
	IGRlong			* msg ;
	IGRchar			* name ;
	IGRchar			* text ;

  Notes/Remarks
	Special treatment for predefined attributes.

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_xxx	...

-mo*/

method	ACadd_attribute(	IGRlong		* msg ;
				IGRchar		* name ;
				IGRchar		* text )
{
IGRlong			status = OM_S_SUCCESS;
GRname			addName;

	*msg = MSSUCC;

	if( ! name ){
		*msg = OM_E_ABORT ;
		return status ;
	}

	/*
	 * test if we like to delete the "select" or the "where" clause of
	 * the query.
	 */

	if( VDqryNameFromAttrList( name, addName )){

		/*
		 * remove any other attribute.
		 */
		status =
		om$send(msg = message VDquery.ACmod_attribute(
							msg,
							addName,
							text ),
			targetid = my_id );
		as$status( action = RET_STATUS );
	}
	else{
		/*
		 * add any other attribute.
		 */
		status =
		om$send(msg = message ACrg_collect.ACadd_attribute(
							msg,
							name,
							text ),
			targetid = my_id,
			mode	 = OM_e_wrt_message );
		as$status( action = RET_STATUS );	 
	}

	return status ;
}


end implementation VDquery;
