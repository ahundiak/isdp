/* $Id: VDdrw2dVwov.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrw2dVwov.I
 *
 * Description:
 *
 * Dependencies:
 *	VDdrw3d.S
 *
 * Revision History:
 *	$Log: VDdrw2dVwov.I,v $
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
# Revision 1.3  1995/08/07  20:22:10  pinnacle
# Replaced: vddraw/imp/VDdrw2dVwov.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/06/27  21:01:00  pinnacle
# Replaced: vddraw/imp/VDdrw2dVwov.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

class implementation VDdrw2dVw ;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "bserr.h"
#include "bsparameters.h"
#include "exproto.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "refdef.h"
#include "madef.h"

#include "asbox.h"
#include "grerr.h"
#include "grgsdef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "ACrg_collect.h"

#include "vdparmacros.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"
#include "vds.h"
#include "VDmsg.h"

#include "AS_status.h"
#include "AS_debug.h"

from	ACrg_collect	import	ACset_list_attribute,
				ACshow_data,
				AClist_attribute;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACgive_structure from NDmacro

  Abstract
        This method guve attribute value of name.

 -------------------------------------------------------------------------
-mo*/

method ACgive_structure(int		*suc,
					*direct_index;
			char		*footname;
			struct ret_struct *ptr_rst;
			struct GRmd_env *md_env )
{
	/*
	 * find the structure from current object and if not found
	 * form it parents object.
	 */
	IGRint			sts = OM_S_SUCCESS ;

	SetProc( VDdrw2dVw_ACgive_structure ); Begin

	*suc = MSSUCC ;

	__DBGpr_str(" footname ", footname );

	sts =
	_VD_SEND_WRT_M( my_id, ACncpx.ACgive_structure(	suc,
							direct_index,
							footname,
							ptr_rst,
							md_env ));

	goto wrapup;	/* Avoid compile warning */

	wrapup:
		End ;
		return sts;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACfind_temp_obj from NDmacro

  Abstract
        This method give template object value.

 -------------------------------------------------------------------------
-mo*/

method ACfind_temp_obj(	int		*suc;
			char		*name;
			struct GRid	*temp_obj )
{
IGRint			sts;
IGRlong			msg;
struct	GRobj_env	ModObj;

	/*
	 * redirect to parents
	 */
	SetProc( VDdrw2dVw_ACfind_temp_obj ); Begin

	__DBGpr_str(" name ", name );

	sts =
	_VD_SEND_WRT_M( my_id, ACncpx.ACfind_temp_obj( suc, name, temp_obj ));

	if( !( sts & *suc & 1 )){

		/*
		 * find information from parent object.
		 */
		struct	GRid	parObj ;
		IGRint		count ;

		parObj.objid = NULL_OBJID ;
		sts =
		_VD_SEND_MY( NDnode.NDget_objects( ND_ROOT, &parObj,
						1, NULL, 1, 1, &count ));
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

		sts =
		_VD_SEND_OBJ(	parObj,
				NDmacro.ACreturn_foot(
						&msg,
						"",
						&ModObj._grid,
						&ModObj._matrix_type,
						ModObj._matrix ) );
		__CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup );

		ModObj._md_os = ModObj._osnum;

		sts =
		ex$get_modid(mod_osnum = ModObj._md_os,
                	     mod_id    = &ModObj._md_id );

		sts =
		_VD_SEND_OBJ(	ModObj._grid,
				ACcpx.ACfind_temp_obj( suc, name, temp_obj ));
	}

wrapup:

	End
	return sts ;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDprint from VDSroot

  Abstract
        This method prints object informatio.

 -------------------------------------------------------------------------
-mo*/

method VDprint( long * sts )
{
	/*
	 * print the information from object and connected VDdrw2d objects.
	 */

	IGRint			status = OM_S_SUCCESS,
				type = VD_O_drw2dObj,
				i, count ;
	struct	GRid		myGRid, rgObj ;
	struct	GRobj_info	info ;
	struct	GRid		*grids = NULL ;

	SetProc( VDdrw2dVw_VDprint ); Begin

	*sts = OM_S_SUCCESS ;

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	VD_ShowObj( &myGRid );

	/*
	 * find information from parent object.
	 *
	 * Not CHECKED.
	 *
	rgObj.objid = NULL_OBJID ;
	status =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &rgObj,
						1, NULL, 0, 0, &count ));
	__CheckRC( status, 1, "NDnode.NDget_objects", wrapup );

	VD_ShowObj( &rgObj );

	status =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &tmpObj,
						1, NULL, 1, 1, &count ));
	if( status & 1 ){
	  status =
	  _VD_SEND_OBJN(tmpObj,
			NDmacro.ACreturn_foot(
					sts,
					"",
					&ModObj._grid,
					&ModObj._matrix_type,
					ModObj._matrix ) );
	  if( status & *sts & 1 ){
		VD_ShowObj( &tmpObj );
		VD_ShowObj( &ModObj._grid );
	  }
	}
	 *
	 * END NOT CHECKED.
	 */

	for( i=0 ; i <= (VD_I_drwNoteOther2-VD_I_drwNoteName) ; i++ )
        	printf("\tINFO[%d]: %s\n", i, &me->note[ me->indx[i]] );

	printf("\tvisual_2d   :\t%s\n",	me->visual_2d );
	printf("\ttransp_2d   :\t%s\n", me->transp_2d );
	printf("\tdetach_2d   :\t%s\n", me->detach_2d );
	printf("\n");

	status =
	_VD_SEND_OBJ(	rgObj, ACrg_collect.ACshow_data( sts ));

	printf("\n\t------------------------------------------\n\n\n");

	status =
	VDdrw_GetChannelObjects( sts, &myGRid, NULL, type,&count,&grids,NULL);
	__CheckRC( status, *sts, "VDdrw_GetChannelObjects", wrapup );

	for( i=0 ; i<count; i++ ){

		status =
		om$send(msg	= message GRgraphics.GRgetobjinfo( sts, &info ),
			targetid= grids[i].objid,
			targetos= grids[i].osnum,
			senderid= grids[i].objid );
		printf("\tVDdrw2d [%d]: %d,%d\t%s\n",i,
				grids[i].objid, grids[i].osnum , info.type );
	}

	wrapup:

		_FREE( grids );

		*sts = MSSUCC ;
		End ;
		return	OM_S_SUCCESS ;
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
IGRint			count ;
struct	GRid		attObj;

	SetProc( VDdrw2dVw_VDSgetUsrAttributes ); Begin

	*msg	= MSSUCC ;
	*att	= NULL ;
	*nbAttrs = 0;
   
	/*
	 * get the collector object from this object.
	 */
	attObj.objid = NULL_OBJID ;
	sts =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &attObj,
						1, NULL, 0, 0, &count ));
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	/*
	 * get the number of attributes of the object. All attributes are
	 * defined as user attributes. 
	 */
	sts =
	_VD_SEND_OBJ(	attObj,
			ACrg_collect.AClist_attribute( msg, 0, NULL, nbAttrs ));
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

	__DBGpr_int( "nbAttrs" , *nbAttrs );
	if( ! *nbAttrs )	goto wrapup ;

	/*
	 * allocate memory for the attributes.
	 */
	*att = _MALLOC( *nbAttrs, struct ACrg_coll );
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
			index;
IGRint			count,
			nbAtt;
IGRlong			sts;
struct ACrg_coll	*aList = NULL;
struct	GRid		foot, attObj;

	/*
	 * get the collector object from this object.
	 */
	SetProc( VDdrw2dVw_VDSmodUsrAttributes ); Begin 

	*msg = MSSUCC ;

	if( nbAttrs == 0 || att == NULL ){
		sts = OM_E_INVARG ;
		goto wrapup ;
	}
	
	attObj.objid = NULL_OBJID ;
	sts =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &attObj,
						1, NULL, 0, 0, &count ));
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	/*
	 * get the number of attributes of the object. All attributes are
	 * defined as user attributes. 
	 */
	sts =
	_VD_SEND_OBJN(	attObj,
			ACrg_collect.AClist_attribute( msg, 0, NULL, &nbAtt ));
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

	__DBGpr_int( "nbAttrs" , nbAtt );
	__DBGpr_int( "nbAttrs" , nbAttrs );

	/*
	 * allocate memory for the attributes if any process is needed.
	 */
	if( (nbAttrs + nbAtt) == 0 ){
		sts = OM_S_SUCCESS ;
		goto wrapup;
	}

	aList = _MALLOC( (nbAttrs + nbAtt), struct ACrg_coll ) ;
	if( aList == NULL ){
		sts = OM_E_NODYNMEM;
		goto wrapup;
	}

	sts =
	_VD_SEND_OBJN(	attObj,
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

end implementation VDdrw2dVw;
