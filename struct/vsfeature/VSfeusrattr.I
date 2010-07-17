/* $Id: VSfeusrattr.I,v 1.1.1.1 2001/01/04 21:10:37 cvs Exp $ */

/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsfeature/VSfeusrattr.I
 *
 * Description: Struct attribute manipulation functions
 *
 * Dependencies:
 *
 * Notes:
 *   No ACrg_collect object created during element creation. Must be created
 *     and connected to parent element.
 *   Struct name for ACrg_collect is "usrAttr()" which is placed under
 *     parent element's directory.
 *   Deleting usrAttr() will delete it's parent element! 
 *
 * Revision History:
 *      $Log: VSfeusrattr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:37  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/05/28  13:59:28  pinnacle
# TR_179900582
#
# Revision 1.2  1998/11/25  19:49:38  pinnacle
# TR_179801763: Modified VDSmodUsrAttributes, added VS_coll_create, to allow tpe change with Struct
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  11/11/98  ejm     TR_179801763: Modify User Attributes command
 *                    Form disallows changing a dbl attribute to a txt 
 *		      attribute for struct items.
 *		      Modified method VDSmodUsrAttributes to allow type change.
 *		      Added function VS_coll_create.
 *  05/28/99  ejm     TR_179900582: Modify Attributes of Structural Elements
 *		      Removed printf statements
 ***************************************************************************/

class implementation VSfeature ;

#include <stdlib.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
/*
#define  vsDEBUG
*/
#include "vsdbgmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vdpardef.h"

#include "DIprims.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

extern struct GRid	NULL_GRID ;

extern int VDgetAttrIndex();
extern int VDDelOneAttrib();

from ACdiowner		import	ACadd_attribute,
				ACrem_attribute ;
from ACrg_collect	import	AClist_attribute, ACmod_list_attribute,
				ACadd_list_attribute, ACset_list_attribute ;
/*----------------------------------------------------------------------------*/
method VSputUsrAttributes( long *msg ; struct GRid *UsrAttr ) {

	long		sts ; 		/* OM return code		*/
	struct GRid	oldUA,		/* Old user attributes		*/
			UAinMyOS ;	/* Copy if not in same OS	*/
	unsigned long	type ;

	/*
	 * If input collection of user attributes is not in the same object
	 * space as us we create a copy of it. The matrices for copy is
	 * not important since the collection contains no graphic objects.
	 */
	if(    ! IF_NULL_OBJID( UsrAttr->objid )
	    && UsrAttr->osnum != OM_Gw_current_OS ) {
		struct GRmd_env	frEnv,
				toEnv ;

		MAidmx( msg, frEnv._MATRIX ) ;
		frEnv._MATRIX_TYPE = MAIDMX ;
		frEnv._MD_OS = UsrAttr->osnum ;

		MAidmx( msg, toEnv._MATRIX ) ;
		toEnv._MATRIX_TYPE = MAIDMX ;
		toEnv._MD_OS = OM_Gw_current_OS ;

		sts = om$send( msg	= message NDnode.NDcopy(msg,
								0,
								&frEnv,
								&toEnv,
								&UAinMyOS ),
				targetid= UsrAttr->objid,
				targetos= UsrAttr->osnum ) ;
		__CheckRC( sts, *msg, "NDnode.NDcopy", wrapup ) ;

		 UsrAttr = &UAinMyOS ;
	}
	/*
	 * Note that it is here assumed that the collection of user attributes
	 * is the LAST parent; if not the collapsing of the channel upon
	 * disconnection will change the ordering of the other parents.
	 */
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
						msg, VS_K_prUsrAttr, &oldUA ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) {
		oldUA.objid	= NULL_OBJID ;
		sts		= OM_S_SUCCESS ;
		*msg		= EMS_I_Fail ;
	} else {
		*msg = IF_NULL_OBJID( oldUA.objid ) ? EMS_I_Fail : MSSUCC ;
	}

	om$send(msg	= message VSfeature.VSgetResultType( msg, &type ),
		targetid= my_id ) ;

	if( IF_NULL_OBJID( oldUA.objid ) ) {
		
		/*
		 * Had no collection before: connect. Note that object will
		 * be connected at the end of the channel: object must have
		 * the collection of user-attributes defined as its last
		 * input and all the other inputs before the last one must
		 * be present.
		 */

		if( !IF_NULL_OBJID( UsrAttr->objid ) ) {
			if( type & VS_m_IMG_generic ) {
			sts = om$send(	msg	= message NDnode.NDconnect(
								1,
								UsrAttr,
								NULL_GRID,
								ND_ADD ),
					targetid= my_id ) ;
			} else {
			sts = om$send(	msg	= message VSfeature.VSforwardToSource(
						msg,
						OM_e_wrt_object,
						message NDnode.NDconnect(
								1,
								UsrAttr,
								NULL_GRID,
								ND_ADD ) ),
					targetid= my_id ) ;
			}
			*msg = sts & 1 ? MSSUCC : MSFAIL ;
			__CheckRC( sts, *msg, "NDnode.NDconnect", wrapup ) ;
		}
	} else {
		/*
		 * Had a collection before: replace or remove.
		 */
		if( !IF_NULL_OBJID( UsrAttr->objid ) ) {
			if( type & VS_m_IMG_generic ) {
				sts = om$send( 
					msg	= message NDnode.NDchange_connect(
							1,
							&oldUA,
							UsrAttr ),
					targetid = my_id ) ;
			} else {
				sts = om$send(
					msg	= message VSfeature.VSforwardToSource(
							msg,
							OM_e_wrt_object,
							message NDnode.NDchange_connect(
								1,
								&oldUA,
								UsrAttr ) ),
					targetid= my_id ) ;
			}	
			*msg = sts & 1 ? MSSUCC : MSFAIL ;
			__CheckRC( sts, *msg, "NDnode.NDchange_connect", wrapup ) ;
		} else {
			if( type & VS_m_IMG_generic ) {
				sts = om$send(
					msg = message NDnode.NDdisconnect(
								1, &oldUA ),
					targetid = my_id ) ;
			} else {
				sts = om$send(
					msg	= message VSfeature.VSforwardToSource(
							msg,
							OM_e_wrt_object,
							message NDnode.NDdisconnect( 1, &oldUA ) ),
					targetid= my_id ) ;
			}
			*msg = sts & 1 ? MSSUCC : MSFAIL ;
			__CheckRC( sts, *msg, "NDnode.NDdisconnect", wrapup ) ;
		}
	}
	wrapup :
		return sts ;

} /* method VSputUsrAttributes */
/*----------------------------------------------------------------------------*/
method VSgetUsrAttributes( long *msg ; struct GRid *p_UsrAttr ) {

	long		sts ;	/* OM return code	*/

	sts = om$send(	msg	= message VSfeature.VSfindCollection(
					msg, VS_K_prUsrAttr, p_UsrAttr ),
			targetid= my_id ) ;

	if( !( sts & 1 & *msg ) ) {
		/*
		 * No user attributes.
		 */
		p_UsrAttr->objid = NULL_OBJID ;
		*msg	= EMS_I_Fail ;
		sts	= OM_S_SUCCESS ;
	} else {
		if( IF_NULL_OBJID( p_UsrAttr->objid ) ) {
			*msg = EMS_I_Fail ;
		} else {
			*msg = MSSUCC ;
		}
	}

	return sts ;

} /* method VSgetUsrAttributes */
/*----------------------------------------------------------------------------*/
method VSmodUsrAttributes(	long		*msg ;
				int		nbAttrs ;
				char		*attrNames[],
						*attrValues[] ) {

	long		sts ;		/* OM return code	*/
	struct GRid	myOldUA,	/* Previous collection	*/
			myNewUA ;	/* My new collection	*/
	struct GRmd_env toEnv ;		/* For NDcopy		*/
	char		**nToAdd,
			**vToAdd,
			**nToRm ;
	int		i,
			nbToAdd,
			nbToRm ;


	nToAdd = vToAdd = nToRm = NULL ; nbToAdd = nbToRm = 0 ;

	if( !nbAttrs ) { *msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ; }

	/*
	 * NOTE attributes whose name is preceeded by '!' are to be removed.
	 */
	for( i = 0 ; i < nbAttrs ; i++ ) {
		if( *attrNames[i] == '!' ) nbToRm++ ;
		else nbToAdd ++ ;
	}

	if( nbToRm ) {
		int	u, v ;
		nToRm = _MALLOC( nbToRm , char * ) ;
		if( !nToRm ) vs$mem_fail() ;
		if( nbToAdd ) {
			nToAdd= _MALLOC( nbToAdd, char * ) ;
			vToAdd= _MALLOC( nbToAdd, char * ) ;
			if( !( nToAdd && vToAdd ) ) vs$mem_fail() ;
		}
		for( i = u = v = 0 ; i < nbAttrs ; i++ ) {
			if( *attrNames[i] == '!' ) {
				nToRm[u++] = attrNames[i] ;
			} else {
				nToAdd[v  ]= attrNames [i] ;
				vToAdd[v++]= attrValues[i] ;
			}
		}
	} else {
		nbToAdd = nbAttrs ;
		nToAdd  = attrNames ;
		vToAdd  = attrValues ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetUsrAttributes(
							msg, &myOldUA ),
			targetid= my_id ) ;

	/*
	 * Only need the module osnum of the to-env. to be set for NDcopy of
	 * an ACrg_collect.
	 */
	toEnv._MD_OS = OM_Gw_current_OS ;

	if( IF_NULL_OBJID( myOldUA.objid ) ) {
		struct GRid	activeUA ;
		OMuword		curModOs ;

		/*
		 * We here use the macro which serves to create an active
		 * collection of user-attributes (out of laziness ), possibly
		 * copying it if we are not in the active design file.
		 * Remember that unused active collections delete themselves
		 * automatically at sleep time; so do not bother getting rid
		 * of it.
		 */
		sts = vs$makeActiveUsrAttr(
					msg		= msg,
					basename	= VS_K_TmpUAttr,
					nbEntries	= nbToAdd,
					names		= nToAdd,
					syntaxes	= vToAdd,
					p_activeUA	= &activeUA ) ;
		__CheckRC( sts, *msg, "vs$makeActiveUsrAttr", wrapup ) ;

		ex$get_cur_mod( osnum = &curModOs ) ;

		if( curModOs != OM_Gw_current_OS ) {
			sts = om$send(	msg	= message NDnode.NDcopy(
				 				msg, 0, NULL,
				 				&toEnv,
				 				&myNewUA ),
		 			targetid= activeUA.objid,
		 			targetos= activeUA.osnum ) ;
			__CheckRC( sts, *msg, "NDnode.NDcopy", wrapup );
		} else {
			myNewUA = activeUA ;
		}
	} else {
		int	nbOldAttrs,
			hasTmpAttr = FALSE,
			nbAdded,
			nbRmved,
			ia ;
		char	*tmpAttrName = "StRuCtTmPaTrIb" ;

		/*
		 * Copy old collection to a new one.
		 */
		 sts = om$send(	msg	= message NDnode.NDcopy(
						msg, 0, NULL, &toEnv, &myNewUA),
		 		targetid= myOldUA.objid,
		 		targetos= myOldUA.osnum ) ;
		 __CheckRC( sts, *msg, "NDnode.NDcopy", wrapup ) ;

		 /*
		  * Now add new attributes, if attribute already exists we
		  * replace it by the new one. Since ACmod_attribute does not
		  * allow for attribute type change, we first delete it then
		  * add it with its new value. Note that since the objects
		  * deletes itself when the last attribute is removed, we
		  * must take care of this case if need be to avoid that
		  * deletion.
		  */
		 sts = om$send(	msg	= message ACrg_collect.AClist_attribute(
                            msg, 0, NULL, &nbOldAttrs ),
		 		targetid= myNewUA.objid,
		 		targetos= myNewUA.osnum ) ;
		 __CheckRC( sts, *msg, "NDnode.NDcopy", wrapup ) ;

		 if( nbOldAttrs <= nbToAdd ) {
		 	/*
		 	 * We may run into the case when the object auto-deletes
		 	 * so we create a temporary attribute for safety.
		 	 */
		 	sts = om$send(	msg	= message ACdiowner.ACadd_attribute(
		 					msg,
		 					tmpAttrName,
		 					"AnythingGoes" ),
		 			targetid= myNewUA.objid,
		 			targetos= myNewUA.osnum ) ;
		 	if( sts & 1 & *msg ) hasTmpAttr = TRUE ;
		 }
		 /*
		  * Loop on input attributes, deleting old attributes bearing
		  * the same names if any (they may not exist, so do not check
		  * return codes ...), then add new ones.
		  */
		nbAdded = 0 ;
		for( ia = 0 ; ia < nbToAdd ; ia++ ) {
			om$send(msg	= message ACdiowner.ACrem_attribute(
							msg, nToAdd[ia] ),
				targetid= myNewUA.objid,
		 		targetos= myNewUA.osnum ) ;
		 	sts = om$send(	msg	= message ACdiowner.ACadd_attribute(
		 					msg,
		 					nToAdd[ia],
		 					vToAdd[ia] ),
		 			targetid= myNewUA.objid,
		 			targetos= myNewUA.osnum ) ;
		 	if( sts & 1 & *msg ) nbAdded++ ;
		}

		/*
		 * Now get rid of those to remove. Do not check return codes
		 * because some may not be there...
		 */
		nbRmved = 0 ;
		for( ia = 0 ; ia < nbToRm ; ia++ ) {
			/*
			 * Beware: there may be nothing to eat after the '!'.
			 */
			if( !nToRm[ia][1] ) continue ;
			om$send(msg	= message ACdiowner.ACrem_attribute(
							msg, nToRm[ia] + 1 ),
				targetid= myNewUA.objid,
		 		targetos= myNewUA.osnum ) ;
		 	if( sts & 1 & *msg ) nbRmved++ ;
		}
		 
		if( !nbAdded && !nbRmved ) {
			/*
			 * No luck ! Get rid of copy.
			 */
			om$send(msg	= message NDnode.NDdelete( &toEnv ),
				targetid= myNewUA.objid,
				targetos= myNewUA.osnum ) ;
			*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
		}
		/*
		 * Remove temporary attribute if any.
		 */
		if( hasTmpAttr ) {
			om$send(msg	= message ACdiowner.ACrem_attribute(
							msg, tmpAttrName ),
				targetid= myNewUA.objid,
				targetos= myNewUA.osnum ) ;
		}
		*msg = nbAdded == nbToAdd && nbRmved == nbToRm ? MSSUCC
							       : EMS_I_Fail ;
		sts  = OM_S_SUCCESS ;
	}

	/*
	 * Put new collection to self.
	 */
	sts = om$send(	msg	= message VSfeature.VSputUsrAttributes(
								msg, &myNewUA ),
			targetid= my_id ) ;

	wrapup :
		_FREE( nToRm ) ;
		if( nToAdd != attrNames  ) _FREE( nToAdd ) ;
		if( vToAdd != attrValues ) _FREE( vToAdd ) ;
		return sts ;

} /* method VSmodUsrAttributes */
/*----------------------------------------------------------------------------*/
method VDSgetUsrAttributes (
 IGRlong 		*msg;
 IGRint			*nbAttrs;
 struct ACrg_coll	**att;
 struct GRmd_env	*md_env      )
{

	long		sts = OM_S_SUCCESS;
	struct GRid 	p_UsrAttr;

	if ( !msg || !nbAttrs || !att )
	{
	  sts = OM_E_INVARG;
	  *msg = MSINARG;
	  goto wrapup;
	}

	*msg = MSSUCC;
	sts = om$send( msg = message VSfeature.VSgetUsrAttributes (
						msg, &p_UsrAttr ),
		     targetid  = my_id  );
      __CheckRC( sts, *msg, "VSfeature.VSgetUsrAttributes", wrapup ) ;

	sts = om$send( msg = message ACrg_collect.AClist_attribute
					( msg, 0, NULL, nbAttrs ),
			targetid = p_UsrAttr.objid,
			targetos = p_UsrAttr.osnum,
			senderid = NULL_OBJID );
	__CheckRC( sts, *msg, "AClist_attribute", wrapup ) ;

        *att = ( struct ACrg_coll *)malloc( (*nbAttrs) * sizeof(struct ACrg_coll ) );
	if( !(*att) ) vs$mem_fail() ;

	sts = om$send(msg = message ACrg_collect.AClist_attribute
					( msg, *nbAttrs, *att, nbAttrs ),
		 	senderid = NULL_OBJID,
		 	targetid = p_UsrAttr.objid,
                        targetos = p_UsrAttr.osnum);
	__CheckRC( sts, *msg, "AClist_attribute", wrapup ) ;
      

wrapup:
	return sts;
}/* method VDSgetUsrAttributes  */


/*---------------------------------------------------------------------------*/

/* 
 * Create Collector Object
 * GRgraphics.GRputname not used here since collector object is named and
 *    placed by VSfeature.VSputUsrAttributes in VDSmodUsrAttributes.
 */
IGRboolean VS_coll_create(
  IGRlong	   *msg,	/* I */
  struct GRobj_env *itemOE,	/* I */
  IGRchar	   *collPath,	/* I */
  IGRchar	   *collName,	/* I */
  struct GRobj_env *collOE	/* O */
)
{
  IGRboolean  retFlag;
  IGRlong     sts,suc;
/*
  IGRchar curPath[DI_PATH_MAX];
*/
  struct GRid sourceID;

  OM_S_CHANSELECT   parentCHN;
  OM_S_CHANSELECT childrenCHN;

  struct ACrg_coll attr;

  // Init
  SetProc( VS_coll_create ); Begin
  *msg    = 0;
  retFlag = 0;

  if ((itemOE == NULL) || (itemOE->obj_id.objid == NULL_OBJID)) {
        __DBGpr_str ("Application object", "NULL");
        }
  else {
        __DBGpr_obj( "Application object", itemOE->obj_id );
        }

#ifdef USE
  __DBGpr_str("Directory path", collPath);
  __DBGpr_str("Collector name", collName);

  // Save current directory
  di$pwd(dirname = curPath);
#endif

  // Use current enviroment
  sts = gr$get_module_env(buffer = &collOE->mod_env);
  __CheckRC (sts,1,"gr$get_module_env",wrapup);

  // Create the object
  collOE->obj_id.osnum = collOE->mod_env.md_id.osnum;
  collOE->obj_id.objid = NULL_OBJID;

  sts = om$construct(
    classname = "ACrg_collect",
    osnum     =  collOE->obj_id.osnum,
    p_objid   = &collOE->obj_id.objid
  );
  __CheckRC (sts,1,"om$construct.ACrg_collect",wrapup);

#ifdef USE
  if ((collPath != NULL) && (*collPath != 0)) di$cd (dirname = collPath);

  // Name it
  sts = om$send(
    msg = message GRgraphics.GRputname(&suc,collName),
    senderid = NULL_OBJID,
    targetid = collOE->obj_id.objid,
    targetos = collOE->obj_id.osnum
  );
  __CheckRC (sts,suc,"GRgraphics.GRputname",wrapup);
#endif

  // Have an object to connect?
  if ((itemOE == NULL) || (itemOE->obj_id.objid == NULL_OBJID)) {
    goto all_done;
  }

  // Source It
  sourceID.objid = NULL_OBJID;
  sts = as$make_source(
    go_grid =  itemOE->obj_id,
    mod_env = &itemOE->mod_env,
    as_os   =  itemID->osnum,
    as_grid = &sourceID
  );
  if (sourceID.objid == NULL_OBJID) goto wrapup;

  // Make channels
  sts = om$make_chanselect(
    channame     = "NDfather.father",
    p_chanselect = &parentCHN
  );
  __CheckRC (sts,1,"om$make_chanselect father",wrapup);

  sts = om$make_chanselect(
    channame     = "NDchildren.children",
    p_chanselect = &childrenCHN
  );
  __CheckRC (sts,1,"om$make_chanselect children",wrapup);

  // Connect up
  sts = om$send(
    msg = message Root.connect(
      parentCHN,  OM_K_MAXINT,
      sourceID.objid,
      sourceID.osnum,
      childrenCHN,OM_K_MAXINT
    ),
    senderid = NULL_OBJID,
    targetid = collOE->obj_id.objid,
    targetos = collOE->obj_id.osnum
  );
  if (!(sts & 1)) {
    printf("Parent Connection Failed\n");
    goto wrapup;
  }

  // Done
all_done:
  __DBGpr_obj("Collector created", collOE->obj_id);
  *msg    = 1;
  retFlag = 1;

wrapup:

/*
  // Back to original directory
  di$cd (dirname = curPath);
*/

  End
  return retFlag;
}

/*--------------------------------------------------------------------------*/
/* Manipulate an element's attribute collector list.
 * Based on Modify User Attributes command and it's form, VDmodUsrAtt.
 * Algorithm:
    Get collector object
    If non-existant,
	Create new collector
	Add input attributes
	Connect collector to parent
    Else
	Get collector's list
	Create pointer to new list
	If type = DELETE, remove attribute
	Else Compare names for matches
	  If exists, replace it to change type and/or value in new list
	  Else append new attribute to end of new list
	Call ACset_list_attribute to replace old list with new list
*/

method VDSmodUsrAttributes (
 IGRlong			*msg;       /* O */
 IGRint 			 nbAttrs;   /* I Number of attrs to process */
 struct ACrg_coll		*att;       /* I Attribute name,type,value  */
 struct GRmd_env		*md_env  )  /* I Element environment        */ 
{

  long		sts = OM_S_SUCCESS;
  int		ii, i, j, index;

  struct GRid        collID;      /* Existing collector          */
  struct GRobj_env   attObjOE,    /* Collector's parent object   */
		     collOE;      /* New collector	         */	
  IGRint	     nbCurAtt,    /* existing attributes         */
		     maxAttrs;    /* input + existing attributes */
  IGRboolean	     found;	  /* If attribute found by name  */
  struct ACrg_coll  *CurAtt=NULL; /* Pointer to new collector list   */


  SetProc( VDSmodUsrAttributes ); Begin


  if ( !msg || !( nbAttrs && att ) ) {
	sts = OM_E_INVARG;
  	*msg = MSINARG;
  	goto wrapup;
  }

#ifdef vsDEBUG
  __DBGpr_com("Incoming Modified, New, Deleted attributes:");
  __DBGpr_int("  nbAttrs", nbAttrs);
  for ( ii=0 ; ii< nbAttrs; ii++ ) 
  {
    printf("\t  att[%d] name: %s  type: %d", ii, att[ii].name, att[ii].desc.type);
    if ( att[ii].desc.type == AC_ATTRIB_DOUBLE )
      __DBGpr_dbl("att_exp", att[ii].desc.value.att_exp);
    else 
      __DBGpr_str("att_txt", att[ii].desc.value.att_txt);
  }
#endif


  *msg = MSSUCC;

  if ( !nbAttrs ) goto wrapup;


  /* Get collector object */

  sts = om$send(
  msg = message VSfeature.VSgetUsrAttributes( msg, &collID ),
		targetid= my_id ) ;

  if( IF_NULL_OBJID( collID.objid ) )
  /* No collector object exists ********************************************* */
  {
    /* New attributes, no existing attributes */
    ex$get_cur_mod( osnum = &attObjOE.obj_id.osnum );

    attObjOE.obj_id.objid = my_id;
    attObjOE.mod_env  = *md_env;

    /* Create a collector for element (do not name) */
    sts = VS_coll_create( msg, &attObjOE, "", "", &collOE );
    __CheckRC( sts, *msg, "VS_coll_create", wrapup ) ;

    // Add new attributes
    sts = om$send(
    msg = message ACrg_collect.ACadd_list_attribute(msg,nbAttrs,att),
      senderid = NULL_OBJID,
      targetid = collOE.obj_id.objid,
      targetos = collOE.obj_id.osnum
    );
    __CheckRC(sts,*msg,"ACadd_list_attribute",wrapup);

    /*
     * Put new collection to self, ie., put collector object under
     * my_id's directory.
     */
    sts = om$send(
    msg = message VSfeature.VSputUsrAttributes( msg, &collOE.obj_id ),
      targetid= my_id ) ;
    __CheckRC(sts,*msg,"VSputUsrAttributes",wrapup);
  }
  else  /* An attribute collector object exists ***************************** */
  {
    __DBGpr_int("Existing collector object", collID.objid);

    /* ACmod_list_attribute doesn't allow changing types !!! */
    /* ACset_list_attribute deletes existing attributes and adds new list */

    /* Get number of attributes in collector */

    nbCurAtt=0;

    sts = om$send(
    msg = message ACrg_collect.AClist_attribute( msg, 0, NULL, &nbCurAtt),
      targetid = collID.objid,
      targetos = collID.osnum );
    __CheckRC(sts,*msg,"AClist_attribute_1",wrapup);

    __DBGpr_int("Total number of existing attributes", nbCurAtt);

    maxAttrs = nbAttrs + nbCurAtt;

    /* Allocate space for list of attributes */

    CurAtt = (struct ACrg_coll *)
             om$malloc( size = (sizeof( struct ACrg_coll ) * (maxAttrs) ));

    if( CurAtt == NULL )
    {
      *msg = MSFAIL;
      sts = OM_E_NODYNMEM;
      goto wrapup;
    }

    /* Get the list of attributes */
  
    sts = om$send(
    msg = message ACrg_collect.AClist_attribute( msg,
                                                 maxAttrs,
                                                 CurAtt,
                                                &nbCurAtt ),
          targetid = collID.objid,
          targetos = collID.osnum );
    __CheckRC(sts,*msg,"AClist_attribute_2",wrapup);

    /* Compare incoming attributes to current attributes */
    /* Delete, modify or add incoming attributes to list */

    for( i = 0 ; i < nbAttrs ; i++ )
    {
      if( att[i].desc.type == VD_ATTRIB_DELETE )
      {
        /* delete the attribute */
	__DBGpr_str("Delete", att[i].name);
        VDDelOneAttrib( CurAtt, &nbCurAtt, att[i].name );
      }
      else
      {
        /* Get the index of the attribute in the list, if present */
        found = VDgetAttrIndex( att[i].name, CurAtt, nbCurAtt, &index );
        if( found )
        {
          /* Modify the attribute */
          /* Replacement simpler than comparing */
	  __DBGpr_str("Modify", att[i].name);
          CurAtt[index] = att[i];
        }
        else
        {
          /* Add the attribute */
	  __DBGpr_str("Add", att[i].name);
          CurAtt[nbCurAtt++] = att[i];
        }
      } /* else not VD_ATTRIB_DELETE */
    } /* For loop for input attributes, nbAttrs */

    /* Replace existing attribute list with new list */

    __DBGpr_int("Number of attributes in new list", nbCurAtt);

    sts = om$send(
    msg = message ACrg_collect.ACset_list_attribute( msg, nbCurAtt, CurAtt ),
      targetid = collID.objid,
      targetos = collID.osnum );
    __CheckRC(sts,*msg,"ACset_list_attribute",wrapup);

  } /* else collector object exists ***************************************** */


wrapup:

  _FREE( CurAtt );

  End

  return OM_S_SUCCESS;

} /* method VDSmodUsrAttributes  */


/*---------------------------------------------------------------------------*/

end implementation VSfeature ;
