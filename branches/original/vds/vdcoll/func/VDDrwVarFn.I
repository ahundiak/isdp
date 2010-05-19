
/* $Id: VDDrwVarFn.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdcoll/func/VDDrwVarFn.I
 *
 * Description:
 *
 * Implementation file storage/retrieval of long attribute strings
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDrwVarFn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
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
# Revision 1.6  1995/09/19  17:15:50  pinnacle
# Replaced: vdcoll/func/VDDrwVarFn.I for:  by msbraju for vds.240
#
# Revision 1.5  1995/06/07  21:22:26  pinnacle
# Replaced: vdcoll/func/VDDrwVarFn.I by hverstee r#
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/06/95          HV            Cleaned up
 *
 * -------------------------------------------------------------------*/

class implementation Root;

/*
File : VDDrwVarFn.I

Doc : This file contains functions which are used by "Display Query
      Definitions/ Display Prefix Definitions/ Display Notes Variables"
      commands.

      The functions are

      o  VDgetVdCollId
      o  VDgetAttFromColl
      o  VDgetAttLenFromColl
      o  VDputAttInColl
      o  VDgetAttListFromColl

  It has been thought that maximum string length of 80( see ATTR_LEN in 
ACrg_coolect.h) is not sufficient for storing query definitions( which
may be longer than 80). So we have implemented following functions which
store and retrieve strings upto 256 chars( VD_ATTR_LEN).

  It is done the following way:

  ex 1. String length <= 75 ( see VD_PART_LEN in vdcolldef.h )

     Attribute name QUERY1,  value "VDequidef where color = blue"
  It is stored and retrieved in usual way.

  ex 2. String length > 75 ( see VD_PART_LEN in vdcolldef.h )

     Attribute name is EQUIPQUERY,  value is "VDequidef where color = blue &
 level = 1021 & weight = 2 & partnum = 1000 & partrev = 2".

     It will be stored in three attributes(i.e., strlen(value)/VD_PART_LEN + 2)

     They will be

	EQUIPQUERY[0] = "VDS_VAR_LENGTH_STRING2"
	EQUIPQUERY[1] = "VDequipdef where color = blue & level = 1021 & wei
ght = 2 & partnum = 1000 "
	EQUIPQUERY[2] = "& partrev = 2"

*/

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "vderrmacros.h"
#include "vdcolldef.h"
#include "vdcollmacros.h"

#define VD_SPL_ATTR_STR   "VDS_VAR_LENGTH_STRING"
#define VD_SPL_ATTR_LEN   21	/* length of "VDS_VAR_LENGTH_STRING" */

extern  OMuword  OPP_ACrg_collect_class_id;

from  GRvg	     import	GRputname;
from  ACrg_collect   import	ACget_named_attribute;
from  ACrg_collect   import	ACadd_list_attribute;
from  ACrg_collect   import	AClist_attribute;
from  ACrg_collect   import	ACget_attribute_at_index;
from  ACdiowner      import	ACrem_attribute;

/*+fe
Function :  VDgetVdCollId

Abstract
  This function finds if a collection exists with the given name. If exists
it returns id of the collection. If collection does not exist and the create
option is TRUE, it creates and returns its grid.

  There is also an option to specify if the given collection is fill name or
not. If not full name, the collection is assumed to be 
"filename:IGENOD:coll_name".

Arguments
  IGRlong		*msg		O    return status
  char			coll_name	I    name of collection.
  IGRboolean		full_name_flag	I    =TRUE, coll_name is full,
					     =FALSE, coll_name is false
  IGRboolean		create		I    =TRUE, create if collection does
					     not exist
					     =FALSE, do not create even if it
					     does not exist
  struct GRid		*coll_id	O    object id of the collection
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/

long  VDgetVdCollId (
 long			*msg,
 char			coll_name[],
 IGRboolean		full_name_flag,
 IGRboolean		create,
 struct GRid		*coll_id
)
{
long			sts;
char			coll_full_name[80];


  if ( !msg || !coll_name || !coll_id )
  {
	*msg = MSINARG;
	sts = OM_E_INVARG;
	goto wrapup;
  }

  *msg = MSSUCC;
  sts = OM_S_SUCCESS;

  if ( full_name_flag )
        strcpy ( coll_full_name, coll_name );
  else
  {
	VDSget_filename( coll_full_name );
	strcat ( coll_full_name, ":IGENOD:" );
	strcat ( coll_full_name, coll_name );
  }

  sts = di$translate(	objname = coll_full_name,
			p_objid = &(coll_id->objid),
			p_osnum = &(coll_id->osnum)  );

  if ( !(sts & OM_S_SUCCESS) && create )
  {
     struct GRid  mod_id;

     ex$get_cur_mod ( id = &mod_id.objid, osnum = &mod_id.osnum );

     coll_id->osnum = mod_id.osnum;
     sts = om$construct( classid = OPP_ACrg_collect_class_id,
			 osnum   = coll_id->osnum,
			 p_objid = &(coll_id->objid) );
     if(!(sts & OM_S_SUCCESS)) goto wrapup;

     /* Add a name */
     sts = om$send(	msg = message GRvg.GRputname( msg, coll_full_name ),
			senderid = NULL_OBJID,
			targetid = coll_id->objid,
			targetos = coll_id->osnum);
     VDS_ERR_HNDLR ( "GRvg.GRputname", sts, *msg, VD_VERBOSE, wrapup );
  }

wrapup:
  return sts;

}


/*+fe
Function :  VDgetAttFromColl

Abstract
  This function gets attribute value from a collection given the name of
attribute. It will see if it is stored as one attribure or as more than
one attribute. It will get entire value.

Arguments
  IGRlong		*msg		O    return status
  struct GRid		coll_id		I    grid of collection
  char			AttrName[]	I    name of attribute whose value
					     is needed.
  char			AttrText[]	O    Text value of attribute.
					     Memory is provided by caller.
					     It is usually VD_ATTR_LEN long.
						(see vdcolldef.h).
  int			AttrTextArrLen	I    Length of AttrText. 
					     It is usually VD_ATTR_LEN (see
						vdcolldef.h).
  int			*nb_str		O    No. of attributes this attribute
					     is stored as. Used by command
					     object for removing the attribute.
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/

long   VDgetAttFromColl(
 long			*msg,
 struct GRid		coll_id,
 char			AttrName[],
 char			AttrText[],
 int			AttrTextArrLen,
 int			*nb_str
)
{
long			sts;
struct ACrg_coll	att;
int			tot_len, loc_nb_str, len, ii;
int			jj;

   sts = OM_S_SUCCESS;
   *msg = MSSUCC;

   *nb_str = 0;

   strcpy( att.name, AttrName );
   sts = om$send(msg = message ACrg_collect.ACget_named_attribute
			 ( msg, &att ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);

   if ( *msg != MSSUCC )
   {
     /*
      * attribute does not exist. quit
      */

     goto wrapup;
   }
   VDS_ERR_HNDLR( "ACrg_collect.ACget_named_attribute", sts, *msg, VD_VERBOSE,
		  wrapup );

   if(att.desc.type != AC_ATTRIB_TEXT)
   {
	*msg = MSFAIL;
	goto wrapup;
   }

   if ( !strncmp( VD_SPL_ATTR_STR, att.desc.value.att_txt, VD_SPL_ATTR_LEN ) )
   {
     sscanf ( &(att.desc.value.att_txt[VD_SPL_ATTR_LEN]), "%d", &loc_nb_str );
     tot_len = 0;
     AttrText[0] = '\0';

     for (ii=0; ii<loc_nb_str; ii++)
     {
	(*nb_str)++;

	sprintf ( att.name, "%s(%d)", AttrName, ii );
	sts = om$send(msg = message ACrg_collect.ACget_named_attribute
			 ( msg, &att ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);
	VDS_ERR_HNDLR( "ACrg_collect.ACget_named_attribute", sts, *msg,
			VD_VERBOSE,  wrapup );

	len = strlen (att.desc.value.att_txt) ;
	for (jj=0; jj<len; jj++)
	{
	  if (tot_len == AttrTextArrLen)
	  {
	     *msg = MSFAIL;
	     AttrText[AttrTextArrLen-1] = '\0';
	     goto wrapup;
	  }

	  AttrText[tot_len] = att.desc.value.att_txt[jj];

	  tot_len++;
	}
     }

     AttrText[tot_len] = '\0';
  }
  else
  {
	len = strlen (  att.desc.value.att_txt );
	if ( len > AttrTextArrLen )
	   att.desc.value.att_txt[AttrTextArrLen-1] = '\0';

	strcpy( AttrText, att.desc.value.att_txt );
	*nb_str = 0;
  }


wrapup:
  __DBGpr_str("VDgetAttFromColl : AttrText", AttrText );
  return sts;

}


/*+fe
Function :  VDgetAttLenFromColl

Abstract
  This function gets the total attribute length from a collection given
the name of the attribute.
  It will see if it is stored as one or more attribute strings.

Arguments
  IGRlong               *msg            O    return status
  struct GRid           coll_id         I    grid of collection
  char                  AttrName[]      I    name of attribute whose value
                                             is needed.
  int                   *nb_chr         O    No. of characters for total
                                             attribute.
  int                   *nb_str         O    No. of attributes this attribute
                                             is stored as. Used by command
                                             object for removing the attribute.
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   06-06-1995  Henk   Creation
-fe*/

long   VDgetAttLenFromColl(
 long                   *msg,
 struct GRid            coll_id,
 char                   AttrName[],
 int                    *nb_chr,
 int                    *nb_str
)
{
  long                    sts;
  struct ACrg_coll        att;
  int                     loc_nb_str, len, ii;

  *nb_str = 0;
  *nb_chr = 0;

  strcpy( att.name, AttrName );
  sts =
  om$send(msg = message ACrg_collect.ACget_named_attribute (msg, &att),
     senderid = NULL_OBJID,
     targetid = coll_id.objid,
     targetos = coll_id.osnum);

  /*
   * attribute does not exist. quit
   */

  if ( *msg != MSSUCC ) goto wrapup;

  if(att.desc.type != AC_ATTRIB_TEXT)
  {
    *msg = MSFAIL;
    goto wrapup;
  }

  if ( !strncmp( VD_SPL_ATTR_STR, att.desc.value.att_txt, VD_SPL_ATTR_LEN ) )
  {
    sscanf ( &(att.desc.value.att_txt[VD_SPL_ATTR_LEN]), "%d", &loc_nb_str );

    for (ii=0; ii<loc_nb_str; ii++)
    {
      (*nb_str)++;

      sprintf ( att.name, "%s(%d)", AttrName, ii );
      sts =
      om$send(msg = message ACrg_collect.ACget_named_attribute (msg, &att),
         senderid = NULL_OBJID,
         targetid = coll_id.objid,
         targetos = coll_id.osnum);

      len = strlen (att.desc.value.att_txt);

      *nb_chr += len;
    }
/*
    (*nb_chr)++;
*/
  }
  else
  {
    *nb_chr = strlen (  att.desc.value.att_txt );
    *nb_str = 1;
  }

  wrapup:
  return sts;
}


/*+fe
Function :  VDputAttInColl

Abstract
  This function puts an attribute into a coolection. It will see if it is stored as one attribure or as more than
one attribute. It will correpsondingly get the value. If already an attribute
exists with the name, old attribute is removed.

Arguments
  IGRlong		*msg		O    return status
  struct GRid		coll_id		I    grid of collection
  char			AttrName[]	I    name of attribute whose value
					     is needed.
  char			AttrText[]	I    Text value of attribute.
					     Memory is provided by caller.
					     It is usually VD_ATTR_LEN long
						(see vdcolldef.h).
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/
long   VDputAttInColl(
 long			*msg,
 struct GRid		coll_id,
 char			AttrName[],
 char			AttrText[]
)
{
long			sts;
struct ACrg_coll	att, *attr_list = NULL;
int			tot_len, loc_nb_str, len, ii;
int			start_pos, end_pos;
char			TmpStr[VD_ATTR_LEN];


   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   strcpy( att.name, AttrName );
   sts = om$send(msg = message ACrg_collect.ACget_named_attribute
			 ( msg, &att ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);


   if ( sts & OM_S_SUCCESS & *msg )
   {
     /*
      * attribute exists. remove it.
      */
     VDS_ERR_HNDLR( "ACrg_collect.ACget_named_attribute", sts, *msg,
		    VD_VERBOSE, wrapup );
     if ( !strncmp( VD_SPL_ATTR_STR, att.desc.value.att_txt, VD_SPL_ATTR_LEN ))
     {
	sscanf ( &(att.desc.value.att_txt[VD_SPL_ATTR_LEN]),"%d", &loc_nb_str);
	for (ii=0; ii<loc_nb_str; ii++)
	{
	   sprintf( TmpStr, "%s(%d)", AttrName, ii);
	   sts = om$send(msg = message ACdiowner.ACrem_attribute
			 ( msg, TmpStr ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);
	   VDS_ERR_HNDLR( "ACdiowner.ACrem_attribute", sts, *msg,
		    VD_VERBOSE, wrapup );
	}
     }
	
     sts = om$send(msg = message ACdiowner.ACrem_attribute
			 ( msg, AttrName ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);
     VDS_ERR_HNDLR( "ACdiowner.ACrem_attribute", sts, *msg,
		    VD_VERBOSE, wrapup );
   }

   tot_len = strlen( AttrText );
   if ( tot_len > VD_ATTR_PART_LEN )
   {
       /*
	* find no. of strings
	*/
	loc_nb_str = 0;
	start_pos = 0;
	while ( TRUE )
	{
	   len = strlen ( &AttrText[start_pos] );
	   if ( len <= VD_ATTR_PART_LEN )
	   {
		loc_nb_str++;
		break;
	   }
	   else
	   {
		end_pos = VD_ATTR_PART_LEN - 1;
		/* find position of space character */
		while ( !isspace(AttrText[start_pos+end_pos]))
                {
		  end_pos--;

		  if ( end_pos == 0 )
		  {
                    end_pos = VD_ATTR_PART_LEN - 1;
                    break;
		  }
		}

		loc_nb_str++;
		start_pos = start_pos + end_pos + 1;
	   }
	}

	/* allocate memory */
	attr_list = (struct ACrg_coll *) malloc( sizeof(struct ACrg_coll) *
						 (loc_nb_str+1) );

	strcpy( attr_list[0].name, AttrName );
	attr_list[0].desc.type = AC_ATTRIB_TEXT;
	sprintf( attr_list[0].desc.value.att_txt, "%s%d",
		 VD_SPL_ATTR_STR, loc_nb_str );

	ii = 0;
	start_pos = 0;
	while ( TRUE )
	{
	   len = strlen ( &AttrText[start_pos] );
	   if ( len <= VD_ATTR_PART_LEN )
	   {
		sprintf( attr_list[ii+1].name, "%s(%d)", AttrName, ii );
		attr_list[ii+1].desc.type = AC_ATTRIB_TEXT;
		sprintf( attr_list[ii+1].desc.value.att_txt, "%s",
			 &AttrText[start_pos] );
		break;
	   }
	   else
	   {
		end_pos = VD_ATTR_PART_LEN-1;
		/* find position of space character */
		while ( !isspace(AttrText[start_pos+end_pos]))
                {
		  end_pos--;

		  if ( end_pos == 0 )
		  {
                    end_pos = VD_ATTR_PART_LEN - 1;
                    break;
		  }
		}

		strncpy ( TmpStr, &AttrText[start_pos], end_pos+1 );
		TmpStr[ end_pos+1 ] = '\0';

		sprintf( attr_list[ii+1].name, "%s(%d)", AttrName, ii );
		attr_list[ii+1].desc.type = AC_ATTRIB_TEXT;
		sprintf( attr_list[ii+1].desc.value.att_txt, "%s", TmpStr );
		ii++;

		start_pos = start_pos + end_pos + 1;
	    }
	}

	sts = om$send(msg = message ACrg_collect.ACadd_list_attribute
			 ( msg, loc_nb_str+1, attr_list ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);

	VDS_ERR_HNDLR( "ACrg_collect.ACadd_list_attribute", sts, *msg,
		    VD_VERBOSE, wrapup );
  }
  else
  {
	att.desc.type = AC_ATTRIB_TEXT;
	strcpy( att.desc.value.att_txt, AttrText );

	sts = om$send(msg = message ACrg_collect.ACadd_list_attribute
			 ( msg, 1, &att ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);

	VDS_ERR_HNDLR( "ACrg_collect.ACadd_list_attribute", sts, *msg,
		    VD_VERBOSE, wrapup );
  }

wrapup:
  if ( attr_list ) free ( attr_list );
  return sts;
}

/*+fe
Function :  VDgetAttListFromColl

Abstract
  This function gets all the attributes given name of collection. Memory for
attribute names and texts should be provided by caller. It is assumed that
full name of collection is "filename:IGENOD:CollName".

Arguments
  IGRlong		*msg		O    return status
  char			CollName[]	I    name of collection
  char			*nb_rows	O    no. of rows found in the
					     collection
  char			**AttrNameList	O    List of attribute names.
					     Memory is provided by caller.
  char			**AttrTextList  O    List of attribute values.
					     Memory is provided by caller.
					     It is usually 
						txtlist[][VD_ATTR_LEN]
  int			ListSize	I    size of attribute name and text
					     lists.
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/
long   VDgetAttListFromColl(
 long			*msg,
 char			CollName[],
 int			*nb_rows,
 char			**AttrNameList,
 char			**AttrTextList,
 int			ListSize
)
{
long			status;
char			AttrText[VD_ATTR_LEN];
struct GRid		coll_id;
int			nb_attrs, ii, nb_str;
struct ACrg_coll	att;


      if ( !msg || !CollName || !nb_rows )
      {
	*msg = MSINARG;
	status = OM_E_INVARG;
	goto wrapup;
      }

      *nb_rows = 0;

      status = VDgetVdCollId ( msg, CollName, FALSE, FALSE, &coll_id );

      if ( !(status & OM_S_SUCCESS) )  goto wrapup;

      status = om$send( msg = message ACrg_collect.AClist_attribute(
					msg,
					0,
					NULL,
					&nb_attrs ),
			targetid = coll_id.objid,
			targetos = coll_id.osnum,
			senderid = NULL_OBJID );
      VDS_ERR_HNDLR( "ACrg_collect.AClist_attribute", status, *msg,
		     VD_VERBOSE,  wrapup );

      for(ii=0; ii<nb_attrs; ii++)
      {
	status = om$send(msg = message ACrg_collect.ACget_attribute_at_index(
						 msg, ii, &att ),
			targetid = coll_id.objid,
			targetos = coll_id.osnum,
			senderid = NULL_OBJID );
	VDS_ERR_HNDLR( "ACrg_collect.ACget_attribute_at_index", status, *msg,
			VD_VERBOSE,  wrapup );

	status = VDgetAttFromColl ( msg, coll_id, att.name, AttrText,
				    VD_ATTR_LEN, &nb_str );
	VDS_ERR_HNDLR( "VDgetAttFromColl", status, *msg, VD_VERBOSE, wrapup );
        if ( (AttrNameList || AttrTextList) && (ListSize == *nb_rows) )
		break;

	if ( AttrNameList ) strcpy( AttrNameList[*nb_rows], att.name );
	if ( AttrTextList ) strcpy( AttrTextList[*nb_rows], AttrText );

	(*nb_rows)++;
	ii = ii + nb_str;
      }

wrapup:
  return status;

}

#if 0
void  tmp_get_list( char *tablename )
{
long	sts, msg;
int	nb_rows, ii;
char    **attrNameList = NULL, **attrTextList = NULL;

  sts = vd$get_list_from_coll(  msg       =  &msg,
				coll_name =  tablename,
				nb_rows   =  &nb_rows   );

  VDmalloc_str_list( &attrNameList, nb_rows, 256 );
  VDmalloc_str_list( &attrTextList, nb_rows, 256 );

  sts = vd$get_list_from_coll(  msg		= &msg,
				coll_name	= tablename,
				nb_rows		= &nb_rows,
				attr_name_list	= attrNameList,
				attr_text_list	= attrTextList,
				list_size	= nb_rows   );

  for ( ii=0; ii<nb_rows; ii++ )
     printf("%d,name[%.15s] = [%s]\n", ii, attrNameList[ii], attrTextList[ii] );

  VDfree_str_list ( attrNameList, nb_rows );
  VDfree_str_list ( attrTextList, nb_rows );

}
#endif

end implementation Root;

