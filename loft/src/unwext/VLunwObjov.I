/* $Id: VLunwObjov.I,v 1.4 2001/02/20 01:07:35 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwObjov.I
 *
 * Description: Overridden methods for Unwrap Object like
 *		ACgive_structure, ACfind_tmp_obj, VDprint,
 *		VDSgetUsrAttributes, VDSmodUsrAttributes...
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwObjov.I,v $
 *      Revision 1.4  2001/02/20 01:07:35  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.3  2001/01/18 17:40:37  ramarao
 *      Overridden NDparent_deleted method for VLunwObj object.
 *
 *      Revision 1.2  2001/01/16 20:01:22  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/05/02  23:20:06  pinnacle
# Created: loft/src/unwext/VLunwObjov.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1998/04/22  10:48:24  pinnacle
# Replaced: src/unwext/VLunwObjov.I for:  by rchennup for loft
#
# Revision 1.1  1997/10/28  15:29:54  pinnacle
# Created: src/unwext/VLunwObjov.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *************************************************************************/


class implementation VLunwObj ;

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
#include "vldbgmacros.h"
#include "vddrwattr.h"
#include "vds.h"
#include "VDmsg.h"

#include "AS_status.h"
#include "AS_debug.h"

from	ACrg_collect	import	ACset_list_attribute,
				ACshow_data,
				AClist_attribute;

from    ACpretend	import	ACfind_parent;

extern GRclassid	OPP_VSplate_class_id;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACgive_structure from NDmacro

  Abstract
        This method gives attribute value of name.

 -------------------------------------------------------------------------
-mo*/

method ACgive_structure(	int			*suc,
							*direct_index;
				char			*footname;
				struct ret_struct	*ptr_rst;
				struct GRmd_env		*md_env )
{
	IGRint			sts = OM_S_SUCCESS ;

	/*
	 * find the structure from current object and if not found
	 * form it parents object.
	 */

	IGRlong			msg ;
	struct	GRid		ftObj ;
	IGRshort		mtxTyp ;
	IGRmatrix		mtx ;

	SetProc( VLunwObj_ACgive_structure ); Begin

	__DBGpr_str(" Name ", footname );

	sts =
	_VD_SEND_MY( NDmacro.ACreturn_foot( &msg,"attr",&ftObj,&mtxTyp, mtx ));
	if( sts&1 && msg&1 ){

		sts =
		_VD_SEND_OBJ(	ftObj,
				NDmacro.ACgive_structure( 
						suc, direct_index,
						footname, ptr_rst, md_env ));
		if( sts & *suc & 1 ) goto wrapup ;
	}

	sts =
	_VD_SEND_WRT_M( my_id,
			VDSroot.ACgive_structure(suc,
						direct_index,
						footname,
						ptr_rst,
						md_env ));
	if( !( sts & *suc & 1 )){

		/*
		 * find information from parent object.
		 */
		struct	GRid		list[20], parObj, parent ;
		struct	GRobj_env	ModObj;
		IGRint			i, cnt ;
		IGRlong			msg;

		__DBGpr_com(" VLunwObj_Get_Parent ");

		parObj.objid = NULL_OBJID ;
		sts =
		_VD_SEND_MY( NDnode.NDget_objects( ND_ROOT, list,
			20, NULL, 0, OM_K_MAXINT, &cnt ));
		if( (!( sts&1 ) )){
			sts = MSSUCC ;
			goto wrapup ;
		}

		for( i=2; i<cnt; ++i )
		{
		  VDobjGetPretendParent( list+i, &parent );
		  if( parent.objid != NULL_OBJID )  list[i] = parent ;
		
		  if( vd_$is_ancestry_valid( object  = list+i,
					     classid = OPP_VSplate_class_id ) )
		  {
			parObj = list[i];
			break ;
		  }
		}

	        if( parObj.objid == NULL_OBJID ) parObj = list[1] ;

		sts =
		_VD_SEND_OBJN(	parObj, 
				NDmacro.ACreturn_foot(
						&msg,
						"",
						&ModObj._grid,
						&ModObj._matrix_type,
						ModObj._matrix ) );
		if( !( sts&msg&1 )){
			sts = MSSUCC ;
			goto wrapup ;
		}

		ModObj._md_os = ModObj._osnum;

		sts =
		ex$get_modid(mod_osnum = ModObj._md_os,
                	     mod_id    = &ModObj._md_id );

		sts =
		_VD_SEND_OBJN(	ModObj._grid,
				NDmacro.ACgive_structure(suc,
							direct_index,
							footname,
							ptr_rst,
							&ModObj.mod_env ));
	}

	wrapup :
		End;
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
	SetProc( VLunwObj_ACfind_temp_obj ); Begin

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
				i, count ;
	struct	GRid		myGRid, rgObj ;
	struct	GRobj_info	info ;
	struct	GRid		*grids = NULL ;

	SetProc( VLunwObj_VDprint ); Begin

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

	printf("\tvisual   :\t%s\n",	me->visual );
	printf("\n");

	status =
	_VD_SEND_OBJ(	rgObj, ACrg_collect.ACshow_data( sts ));

	printf("\n\t------------------------------------------\n\n\n");

	status =
	VLunw_GetChannelObjects( sts, &myGRid, NULL, &count,&grids,NULL);
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

	SetProc( VLunwObj_VDSgetUsrAttributes ); Begin

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
	SetProc( VLunwObj_VDSmodUsrAttributes ); Begin 

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

method NDparent_deleted(IGRlong *msg;
                           IGRint count_deleted; struct GRid list_deleted [];
                           struct GRid *new_obj; struct GRmd_env *md_env)
{
 int            i;
 long           status;
 IGRboolean     mvto_root;
 char           clsName[50];
 GRclassid      clsID;
 struct GRid    parentID;

  status = om$get_classname( objid = my_id,
                             osnum = OM_Gw_current_OS,
                             classname = clsName );

  mvto_root = TRUE;
  if( !strcmp( clsName, "VLunwObj" ) )
  {
     mvto_root = FALSE;
     for( i=0; i<count_deleted; ++i )
     {
        om$get_classid( objid = list_deleted[i].objid,
                        osnum = list_deleted[i].osnum,
                        p_classid = &clsID );
        if( om$is_ancestry_valid( subclassid   = clsID,
                       superclassid = OPP_ACpretend_class_id) == OM_S_SUCCESS )
        {
           status = om$send( msg = message ACpretend.ACfind_parent(
                                &parentID, NULL, NULL ),
                targetid = list_deleted[i].objid,
                targetos = list_deleted[i].osnum );
           if( !( status&1) )   parentID = list_deleted[i];
        }
        else parentID = list_deleted[i];

        om$get_classname( objid = parentID.objid,
                          osnum = parentID.osnum,
                          classname = clsName );

        if( strstr( clsName, "Plate" ) || !strcmp( clsName, "ACrg_collect" ) )
        {
           mvto_root = TRUE;
        }
        status = MSSUCC;
     }
  }

  if( mvto_root == TRUE )
  {
   status = om$send(msg = message NDnode.NDmove_to_root (msg, new_obj, md_env),
                  targetid = my_id);
  }
  return status;
}

end implementation VLunwObj;
