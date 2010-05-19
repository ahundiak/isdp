/* $Id: VDdrwObjuser.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwObjusr.I
 *
 * Description:
 *
 *      Implementation of user attributes methods
 *      
 *      Methods :
 *           VDSgetUsrAttributes
 *           VDSmodUsrAttributes
 *
 * Revision History :
 *	$Log: VDdrwObjuser.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
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
# Revision 1.2  1995/08/07  20:26:04  pinnacle
# Replaced: vddraw/imp/VDdrwObjuser.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  18:26:42  pinnacle
# Created: vddraw/imp/VDdrwObjuser.I by azuurhou for vds.240
#
 *
 * Notes :
 *
 * History:
 *      23/06/95	adz	creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwObj;

#include "string.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "vdparmacros.h"

#include "exproto.h"

#include "SMdef.h"
#include "ACrg_collect.h"

#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "AS_status.h"

from	ACrg_collect	import	AClist_attribute ,
				ACset_list_attribute;

/*
 * -------------------------------------------------------------------------
 */

/*+fe
  Function VDdrw_DelOneAttType

  Abstract
      The function deletes a given attribute (by name) from the list of
      attributes in the ACrg_coll list, as well as its correponding type
      from the types list.

  Arguments

      struct ACrg_coll  *l_att   I/O    list of attributes
      IGRchar           *name     I     name of attribute to be deleted

  Returns
         0    attribute not found in list
         1    attribute found and deleted from list

-fe*/

int VDdrw_DelOneAttType(struct ACrg_coll	*Att, 
			IGRint			*nbAtt,
			IGRchar			*Name )
{

IGRint  att_ind = 0, i;
 
   if( *nbAtt <= 0 )
   {
      printf("\nVDdrwDelOneAttType : No attributes in list");
      return 0;
   }

   for( i=0 ; i<*nbAtt; i++ )
      if( ! strcmp( Att[i].name, Name ) ) { att_ind = i; break; }

   if( i == *nbAtt ) return 0;

   if( att_ind + 1 < *nbAtt )
   {
      memcpy( &Att[att_ind], &Att[att_ind + 1], 
              (*nbAtt - att_ind - 1) * sizeof( struct ACrg_coll ) );
   }

   *nbAtt = *nbAtt - 1;

   return 1;
}

/*
 * -------------------------------------------------------------------------
 */

/*+fe
  Function VDdw_getAttrIndex

  Abstract
      The function returns the index of a named attribute from the given
      list of attributes.

  Arguments

      char              *name     I     attribute name 
      struct ACrg_coll  *att      I     list of attributes
      int               nbAtt     I     no of attributes in list
      int               *index    O     index of the attribute
      
  Returns
         1      attribute found
         0      attribute not found in list

-fe*/


int VDdrw_getAttrIndex(	char             *name,
			struct ACrg_coll *Att,
			int              nbAtt,
			int              *index )
{
   int i;

   *index = 0;
   for( i = 0 ; i < nbAtt ; i++ )
      if( !strcmp( name, Att[i].name ) )
      {
         *index = i;
         return 1;
      }
   return 0;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSgetUsrAttributes from VDSroot

  Abstract

        This method retrieves the user attributes of the structural
        surface  objects.

  Arguments

     IGRlong            *msg             O       completion code
     IGRint             *nbAttrs         O       No of user attributes
     struct ACrg_coll   **att            O       List of attributes
     struct GRmd_env    *md_env          I       Module environment of object

  Status
      OM_S_SUCCESS      if success
      OM_E_NODYNMEM     not enough dynamic memory
      OM_W_ABORT        if some other error

 -------------------------------------------------------------------------
-mo*/

method VDSgetUsrAttributes( IGRlong          *msg;
                            IGRint           *nbAttrs;
                            struct ACrg_coll **att;
                            struct GRmd_env  *md_env )
{
IGRint			sts = OM_S_SUCCESS ;
IGRint			cnt ;
struct	GRid		attObj;

	SetProc( VDdrwObj_VDSgetUsrAttributes ); Begin 

	*msg = MSSUCC ;
	*nbAttrs = 0;
	*att = NULL ;
   
	/*
	 * get the collector object from this object.
	 */
	attObj.objid = NULL_OBJID ;
	sts =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &attObj,
						1, NULL, 0, 0, &cnt ));
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	/*
	 * get the number of attributes of the object. All attributes are
	 * defined as user attributes. 
	 */
	sts =
	_VD_SEND_OBJN(	attObj,
			ACrg_collect.AClist_attribute( msg, 0, NULL, nbAttrs ));
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

	if( ! *nbAttrs )	goto wrapup ;
	__DBGpr_int( "nbAttrs" , *nbAttrs );

	/*
	 * allocate memory for the attributes.
	 */
	*att = _MALLOC(	*nbAttrs, struct ACrg_coll );
	if( *att == NULL ){
		*msg = MSFAIL ;
		sts = OM_E_NODYNMEM ;
		goto wrapup ;
	}

	sts =
	_VD_SEND_OBJ(	attObj,
			ACrg_collect.AClist_attribute(	msg,
							*nbAttrs,
							*att,
							nbAttrs ));
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

	wrapup:
		End ;
		return sts;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSmodUsrAttributes from VDSroot

  Abstract

        Adds user attributes to the object, modifies user attributes of the
        object, and deletes user attributes from the object according to the
        following logic :

               If the type of the attribute is VD_ATTRIB_DELETE, it is deleted.
               otherwise,
                   If the attribute exists, it is modified to reflect
                   the new type and value.
                   If the attribute does not exist, it is created with the
                   new type and value.

               It is not an error to delete an attribute that does not exist.

  Algorithm

       get the list of all attributes
      
       for each attribute to be modified

          get attribute by name

          if attr exists and is not a user attribute
             print error message, continue with next attribute

          if attr type = VD_ATTRIB_DELETE
             delete one attribute from list (SMDelOneAttType)
          else 
             if attribute exists
                modify it
             else
                add the attribute

       set the new list of attributes (SMResetAtt)

       Remarks :

  Arguments

     IGRlong            *msg             O       completion code
     IGRint             nbAttrs          I       No of user attributes to be
                                                 modified
     struct ACrg_coll   *att             I       List of attributes to be
                                                 modified
     struct GRmd_env    *md_env          I       Module environment of object


   Notes
        - the type of an attribute (att[i].desc.type) can have the following
          values :

              VD_ATTRIB_DELETE
              AC_ATTRIB_TEXT
              AC_ATTRIB_DOUBLE

  Status/Return Code
      OM_S_SUCCESS      always
      OM_E_NODYNMEM     not enough dynamic memory
      OM_W_ABORT        if some other error

 -------------------------------------------------------------------------
-mo*/


method VDSmodUsrAttributes( IGRlong          *msg;
                            IGRint           nbAttrs;
                            struct ACrg_coll *att;
                            struct GRmd_env  *md_env )
{
int			i,
			cnt,
			index;
IGRint			nbAtt;
IGRlong			sts;
struct ACrg_coll	*aList = NULL;
struct GRid		foot, attObj;

	/*
	 * get the collector object from this object.
	 */
	SetProc( VDdrwObj_VDSmodUsrAttributes ); Begin 

	*msg = MSSUCC ;

	if( ! nbAttrs || att == NULL ){
		sts = OM_E_INVARG ;
		goto wrapup ;
	}

	attObj.objid = NULL_OBJID ;
	sts =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &attObj,
						1, NULL, 0, 0, &cnt ));
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	/*
	 * get the number of attributes of the object. All attributes are
	 * defined as user attributes. 
	 */
	sts =
	_VD_SEND_OBJN(	attObj,
			ACrg_collect.AClist_attribute( msg, 0, NULL, &nbAtt ));
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

	__DBGpr_int( "nbAtt  " , nbAtt );
	__DBGpr_int( "nbAttrs" , nbAttrs );

	/*
	 * allocate memory for the attributes if any process is needed.
	 */
	if( (nbAttrs + nbAtt) == 0 ){
		sts = OM_S_SUCCESS ;
		goto wrapup;
	}

	aList	= _MALLOC( (nbAttrs + nbAtt), struct ACrg_coll ) ;
	if( aList == NULL ){
		sts = OM_E_NODYNMEM;
		goto wrapup;
	}

	sts =
	_VD_SEND_OBJ(	attObj,
			ACrg_collect.AClist_attribute(	msg,
							nbAtt,
							aList,
							&nbAtt ));
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

	for( i=0 ; i<nbAttrs ; i++ ){

		/*
		 * Get the attribute, if it exists
		 */
		__DBGpr_str( "Attribute" , att[i].name );

		if( att[i].desc.type == VD_ATTRIB_DELETE ){
      
			/*
			 * Delete the attribute
			*/
			VDdrw_DelOneAttType( aList, &nbAtt, att[i].name );
		}
		else{
			/*
			 * get the index of the attribute in the list,
			 * if present
			 */
			if( VDdrw_getAttrIndex(	att[i].name,
						aList, nbAtt, &index )){
				/*
				 * modify the attribute
				 */
				aList[index] = att[i];
			}
			else{
				/* add the attribute */

				aList[nbAtt++] = att[i];
			}
		}
	}

	sts =
	_VD_SEND_OBJ(	attObj,
			ACrg_collect.ACset_list_attribute( msg, nbAtt, aList ));
	__CheckRC( sts, *msg, "ACrg_collect.ACset_list_attribute", wrapup );


	/*
	 * transfer the collector information to the foot.
	 */
	sts =
	_VD_SEND_MY(	NDmacro.ACreturn_foot( msg, "attr", &foot, NULL, NULL));
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );

	sts =
	_VD_SEND_OBJ(	foot,
			ACrg_collect.ACset_list_attribute( msg, nbAtt, aList ));
	__CheckRC( sts, *msg, "ACrg_collect.ACset_list_attribute", wrapup );

	/*
	 * Inform dependent object that you attribute data is modified.
	 */
	sts =
	_VD_SEND_MY(	VDSroot.VDcompute( msg, NULL ));
	__CheckRC( sts, *msg, "VDSroot.VDcompute", wrapup );

	wrapup :

		_FREE( aList );
		End ;
		return sts;
}

end implementation VDdrwObj;
 
