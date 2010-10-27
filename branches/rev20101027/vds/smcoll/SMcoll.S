/* $Id: SMcoll.S,v 1.1.1.1 2001/01/04 21:07:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smcoll / SMcoll.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMcoll.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:32  cvs
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
/*---------------------------------------------------------------------------
/*  SMcoll.S
/*  Jean Jasinczuk 
/*
/*  Abstract:
/*	This class manage a collection of dynamic attributes and database 
/*      attributes with a cache. 
/*      If an attribute is user, it's directly retrieve in the collection
/*      If it's fail an database key exists, it's retreive through the cache
/*	
/*
/*
/*  History:
/*  17 August 93 : creation date
/*  
/*---------------------------------------------------------------------------*/

class specification SMcoll (0:1) of ACdyn_col;

/*---------------------------------------------------------------------*/

message SMGetDbInfo(IGRlong *msg; char *object_type; char *family;
		    char *partno; char *partrev);

/* 
 *  SMGetDbInfo 
 *
 *  Get the object_type,family,partno,partrev attributes. 
 *
 *  Argument description:
 *  --------------------
 *
 *  IGRlong             *msg            O : Completion code.
 *  char                *object_type    I : The cache will be in directory
 *                                          IGENOD:object_type
 *  char                *family         I : family part  
 *  char                *partno         I : part number
 *  char                *partrev        I : part revision 	
*/

/*---------------------------------------------------------------------*/

message SMSetDbInfo(IGRlong *msg; char *object_type; char *family;
		    char *partno; char *partrev);

/* 
 *  SMSetDbInfo 
 *
 *  Set the object_type,family,partno,partrev attributes. 
 *  If this attributes are defined, for each operation, the collection
 *  will look in database to found the corresponding cache.
 *  This is the only method to change the database parameters.
 *  To change this parameter with ACadd_attribute will not work.
 *
 *  Argument description:
 *  --------------------
 *
 *  IGRlong             *msg            O : Completion code.
 *  char                *object_type    O : The cache will be in directory
 *                                          IGENOD:object_type
 *  char                *family         O : family part  
 *  char                *partno         O : part number
 *  char                *partrev        O : part revision 	
*/

/*---------------------------------------------------------------------*/

override AClist_attribute;
 
/* 
 *  AClist_attribute
 *
 *  Override to return attributes which are in cache an in collection 
 *
*/

override ACadd_list_attribute;

/*
 *  ACadd_list_attribute
 *
 *  Override to only add an attributes if not already in the cache.
 *
*/


override ACmod_list_attribute;

/*
 *  ACmod_list_attribute
 *
 *  Override to only modify an attributes if not already in the cache.
 *
*/

override ACset_att_prop;

/*
 *  ACset_list_attribute
 *
 *  Override to only set an attributes properties if not already in the cache.
 *
*/


override ACget_named_attribute;
 
/*
 *  AClist_attribute
 *
 *  Look for name attribute in cache and in ACrg collection
 *
*/

override ACget_attribute_at_index;
 
/*
 *  ACget_attribute_at_index
 *
 *  Look for attribut at index : by definition lower index are in 
 *  my own collection and higher are in cache.
 *
*/

override ACgive_structure;

/*
 *  ACgive_structure 
 *
 *  Look for Acgive_structure in collection and in cache
 *
*/

override ACset_list_attribute;

/*
 *  ACset_list_attribute
 *
 *  Override to only add an attributes if not already in the cache.
 *
*/

override ACget_att_prop;




end specification SMcoll;

