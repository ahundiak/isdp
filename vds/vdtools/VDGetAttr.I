/* $Id: VDGetAttr.I,v 1.1.1.1 2001/01/04 21:09:30 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtools / VDGetAttr.I
 *
 * Description:
 *	Functions to get user or system attributes of an object. 
 *	Output is a list or a collection object. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGetAttr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:30  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/29  21:12:10  pinnacle
# Replaced: vdtools/VDGetAttr.I for:  by kddinov for vds
#
# Revision 1.3  1997/12/12  21:13:08  pinnacle
# Replaced: vdtools/VDGetAttr.I for:  by kddinov for vds
#
# Revision 1.2  1997/12/04  22:48:34  pinnacle
# Replaced: vdtools/VDGetAttr.I for:  by kddinov for vds
#
# Revision 1.1  1997/11/18  17:06:04  pinnacle
# Created: vdtools/VDGetAttr.I by kddinov for vds
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
*	10-97	KDD	VDSgetUsrAttr2, VDSgetSysAttr2
 *
 *************************************************************************/
class implementation Root;

/*
#define vdsDEBUG	1
*/

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "OMprimitives.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "nddef.h"
#include "VDmem.h"
#include "VDAttribMac.h"
#include "v_dbgmacros.h"
#include "vdparmacros.h"

from	ACcpx		import	ACfind_temp_obj;
from	ACrg_collect	import	AClist_attribute;
from	NDnode		import	NDget_objects;

/*------------------------------------------------------------------------------
* This function gets user attributes of an object.
* It returns attributes object ID and/or list.
------------------------------------------------------------------------------*/
IGRint VDSgetUsrAttr2(      IGRint           *NumUsrAttr,
                            struct ACrg_coll **UsrAttr,
                            struct GRid      *UsrParId,
                            struct GRid      object)
{
        IGRint  i;
 
   i = VDSgetAttributes2( NumUsrAttr,   NULL,   NULL,
                          UsrAttr,      NULL,   NULL,
                          UsrParId,     NULL,   NULL,   object);
 
return ( OM_S_SUCCESS );
}


/*------------------------------------------------------------------------------
* This function gets system attributes of an object.
* It returns attributes object ID and/or list.
*
*----------------------------
* Parameters:
*
* O: IGRint           *NumSysAttr - pointer to number of attributes in the 
*					User Collection.  Can be NULL.
* 
* O: struct ACrg_coll **SysAttr   - pointer to list of System attribues.
*					Can be NULL.
*
* O: struct GRid      *SysParId	  - pointer the object ID of the collection.
*					Can be NULL.
*
* I: struct GRid      object	  - Target ObjectID. 
------------------------------------------------------------------------------*/
IGRint VDSgetSysAttr2(      IGRint           *NumSysAttr,
                            struct ACrg_coll **SysAttr,
			    struct GRid	     *SysParId,
			    struct GRid      object)
{
   IGRint            last, i, totalNbAtt = 0;
   IGRlong           status = 1, *msg;
   struct GRid       dyn_box;


   msg = &status;

/*--------------------------
# Get System parameters object id. 
--------------------------*/
   status = om$send( msg      = message ACcpx.ACfind_temp_obj( (IGRint *)msg,
                                                         "syspara", &dyn_box ),
		     senderid = NULL_OBJID,
                     targetid = object.objid,
                     targetos = object.osnum );
   as$status();
   if( !(status & *msg & 1) ) goto wrapup;

   if ( SysParId ) *SysParId = dyn_box;
   if ( !SysAttr   ) { goto wrapup;} 

/*------------------------ 
# Get the number of user attributes. 
------------------------*/
   status = om$send( msg      = message ACrg_collect.AClist_attribute( msg, 0,
                                                           NULL, &totalNbAtt ),
		     senderid = NULL_OBJID,
                     targetid = dyn_box.objid,
                     targetos = dyn_box.osnum );

   as$status();
   if( !(status & *msg & 1) || !totalNbAtt ) goto wrapup;

   *SysAttr = _MALLOC( totalNbAtt, struct ACrg_coll ) ;
   if( SysAttr == NULL ) { status = OM_E_NODYNMEM; goto wrapup; }

   status = om$send( msg      = message ACrg_collect.AClist_attribute( msg, 
					    totalNbAtt, *SysAttr, &totalNbAtt),
		     senderid = NULL_OBJID,
                     targetid = dyn_box.objid,
                     targetos = dyn_box.osnum );

   as$status();
wrapup :

   if ( NumSysAttr) *NumSysAttr = totalNbAtt;

return status;
}


/*------------------------------------------------------------------------------
* This function gets user attributes of an object.
* It returns attributes object ID and/or list.
*
*----------------------------
* Parameters:
*
* O: IGRint           *NumUsrAttr - pointer to number of attributes in UsrAttr.
*                     *NumSysAttr       in SysAttr
*                     *NumMisAttr       in MisAttr
* 
* O: struct ACrg_coll **UsrAttr   - pointer to list of User attribs.Can be NULL.
*		      **SysAttr 		System attribs
*		      **MisAttr 		Missing attribs
*
* O: struct GRid      *UsrParId	  - pointer the object ID of the collection.
*		      *SysParId		System collection
*		      *MisParId		Missing collection
*
* I: struct GRid      object	  - Target ObjectID. 
*
*----------------------------
* NOTE:
*
* User attributes       = Dynamic attributes + Additional Attributes.
*
* Dynamic attributes    - user can change value only.
* Additional Attributes - user can change/remove attribute name + type + value.
------------------------------------------------------------------------------*/
IGRint VDSgetAttributes2( IGRint           	*NumUsrAttr,
                          IGRint           	*NumSysAttr,
                          IGRint           	*NumMisAttr,
                          struct ACrg_coll 	**UsrAttr,
                          struct ACrg_coll 	**SysAttr,
                          struct ACrg_coll 	**MisAttr,
		          struct GRid	     	*p_UsrParId,
		          struct GRid	     	*p_SysParId,
		          struct GRid	     	*p_MisParId,
		          struct GRid      	object)
{

	/*--- System parameters are buffer[0] ---*/
	/*--- User parameters are buffer[1]   ---*/
	/*--- Missing parameters are buffer[2]---*/

  IGRint          status, NbRoots = 0, flag = 0, i;
  struct GRid     *buffer = NULL;
  IGRchar	  classname[128];
  struct GRid	     	UsrParId, SysParId, MisParId;
 
  SysParId.objid      = NULL_OBJID;
  UsrParId.objid      = NULL_OBJID;
  MisParId.objid      = NULL_OBJID;

	    
/*-------------------------
#2. Get collection IDs.
-------------------------*/
  status = om$send( msg      = message NDnode.NDget_objects(
                                                ND_ROOT | ND_IN_BUF,
                                                NULL,
                                                0,
                                                &buffer,
                                                0,
                                                OM_K_MAXINT,
                                                &NbRoots ),
                    senderid = NULL_OBJID,
                    targetid = object.objid,
                    targetos = object.osnum );
  as$status( action = RET_STATUS );
 
__DBGpr_obj("Object                ", object);
__DBGpr_int("Number of roots       ", NbRoots);

  for ( i = 0; (i < NbRoots) && (flag < 3) ; i++ ) { 
      om$get_classname( osnum     = buffer[i].osnum,
		        objid     = buffer[i].objid,
		        classname = classname); 

__DBGpr_obj(classname, buffer[i]); 

      if (om$is_ancestry_valid(subclassname   = classname,
			       superclassname = "ACrg_collect")== OM_S_SUCCESS){

	 switch (flag) {
	   case 0: 	SysParId = buffer[i];
			break;

	   case 1: 	UsrParId = buffer[i];
			break;

	   case 2: 	MisParId = buffer[i];
			break;

	 }

	 flag++;
      }
  }
	    
/*-------------------------
#2. Check if Parameter lists are wanted.
-------------------------*/
  if ((SysAttr)&&(NumSysAttr) && (SysParId.objid != NULL_OBJID)){

	VD$ModifyCollection( p_msg                = (IGRlong*) &status, 
			     Operation            = VD_MERGE_COLL,
			     p_InputCollectionId  = &SysParId,
			     OutNumPar            = NumSysAttr,
			     OutParList           = SysAttr); 
  }

  if ((UsrAttr)&&(NumUsrAttr) && (UsrParId.objid != NULL_OBJID)){
 
        VD$ModifyCollection( p_msg                = (IGRlong*) &status,
                             Operation            = VD_MERGE_COLL,
                             p_InputCollectionId  = &UsrParId,
                             OutNumPar            = NumUsrAttr,
                             OutParList           = UsrAttr); 
  }


  if ((MisAttr)&&(NumMisAttr) && (MisParId.objid != NULL_OBJID)){
 
        VD$ModifyCollection( p_msg                = (IGRlong*) &status,
                             Operation            = VD_MERGE_COLL,
                             p_InputCollectionId  = &MisParId,
                             OutNumPar            = NumMisAttr,
                             OutParList           = MisAttr); 
  }

wrapup :
  if ( p_SysParId )      *p_SysParId      = SysParId;
  if ( p_UsrParId )      *p_UsrParId      = UsrParId;
  if ( p_MisParId )      *p_MisParId      = MisParId;

return ( OM_S_SUCCESS );
}


/*------------------------------------------------------------------------------
* This macro gets system attributes of an object.
*       Suitable for all VDSroot objects.
*       It subtracts the system parameters out of the whole list of parameters.
*
* 10-97 KDD
* vd$getSysAttributes --> VDgetSysAttrs
*----------------------------
* Parameters:
*
* O: IGRlong          *sts        - return status. if != 1 error.
*
* O: IGRint           *nbAttrs    - pointer to number of attributes in the
*                                       User Collection.  Can be NULL.
*
* O: struct ACrg_coll **att       - pointer to list of System attribues.
*                                   Can be NULL.
*                                   The Program allocates memory.
*                                   The caller must free the memory _FREE(attr).
*
* I: struct GRmd_env  *md_env     - module env of an object.
*
* I: struct GRid      object      - Target ObjectID.
------------------------------------------------------------------------------*/
IGRlong VDgetSysAttrs 	        ( IGRlong          *sts,
                                  struct GRid      object,
                                  struct GRmd_env  *md_env,
                                  IGRint           *nbAttrs,
                                  struct ACrg_coll **att )
{
    IGRlong		status = 1;
    IGRint		i, NumUsrAttr = 0;
    struct ACrg_coll	*UsrAttr = NULL;

    if ( !nbAttrs || !att ) goto wrapup;

    status = vd$get_params( sts 	= sts,
                            object	= &object,
                            md_env	= md_env,
                            count	= nbAttrs,
                            plist 	= att)

    status = vd$getUsrAttributes( sts     = sts,
                                  object  = object,
				  md_env  = md_env,
                                  nbAttrs = &NumUsrAttr,
                                  att     = &UsrAttr );

    VD$ModifyCollection( p_msg                 = sts,
                         Operation             = VD_SUBSTR_COLL,
                         p_ParamsListToModify  = UsrAttr,
                         NbParamsToModify      = NumUsrAttr,
                         OutParList            = att,
                         OutNumPar             = nbAttrs );

wrapup:
   if ( UsrAttr) _FREE(UsrAttr);
}


end implementation Root;

