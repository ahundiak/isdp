/* $Id: VDquery.S,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/imp / VDquery.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDquery.S,v $
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
# Revision 1.2  1995/07/07  15:54:12  pinnacle
# Replaced: vdpocket/imp/VDquery.S for:  by yzhu for vds.240
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
 *     7/6/95          YZ              add message VDgetPfxInfo
 *                                                  VDsetPfxInfo
 *						    VDdelPfxInfo
 * -------------------------------------------------------------------*/

/*

Name
  VDquery.S

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


class specification VDquery (0:1) of ACrg_collect ;

/*
 * The storage of the information will be done by using a collection.
 *
 * The types will be predefined and contains that way all the information
 * to be storaged.
 * This allows users also to add there own user attributes, which can be
 * specific for a query.
 *
 * Attribute types:	AC_ATTRIBUT_TEXT.
 * Attribute names:	description:		shortname of query.
 *			select[0-n]:		total string of query.
 *			comment[0-n]:		total string of comment.
 *			 
 */ 

instance VDquery 
{
}; 


override	GRgetobjinfo,		/* give object information        */

		DIgive_output,		/* give info for directory form   */

		ACadd_attribute,	/* add attributes to list         */

		ACrem_attribute,	/* remove attribute based on name */

		ACmod_attribute;	/* modify an attribute		  */


/*+mi
  Private Message
        VDcreate_query

  Abstract
        Given the query information, this method regenerates the attributes
        values according to the given input.he creation will be refused
        when the object does not have a select criteria.

  Arguments
        IGRlong                 * msg ;
        IGRchar                 * select ;
        IGRchar                 * where ;
        IGRchar                 * comment ;

  Status/Return Code
      status == OM_S_SUCCESS    if success;

-mi*/

message		VDcreate(		IGRlong		* msg;
					IGRchar		* select ;
					IGRchar		* where ;
					IGRchar		* comment );


message		VDmodify(		IGRlong		* msg;
					IGRchar		* select ;
					IGRchar		* where ;
					IGRchar		* comment );

message		VDname_query(		IGRlong		* msg;
					IGRchar		* name );

message		VDgive_query(		IGRlong		* msg;
					IGRchar		** select ;
					IGRchar		** where ;
					IGRchar		** comment );

message		VDgive_structure(       IGRlong         * msg ;
					IGRchar         * name ;
					IGRchar         ** string );

message         VDgetPfxInfo(   IGRlong                 *msg;
                                IGRint                  *PfxIndex;
                                IGRchar                 *PfxName);

message         VDsetPfxInfo(   IGRlong                 *msg;
                                IGRint                  *PfxIndex;
                                IGRchar                 *PfxName);

message         VDdelPfxInfo(   IGRlong                 *msg );

end specification VDquery;
