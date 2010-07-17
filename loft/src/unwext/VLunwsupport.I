/* $Id: VLunwsupport.I,v 1.3 2001/02/20 01:07:48 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwsupport.I
 *
 * Description: Link between command object and compute engine.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwsupport.I,v $
 *      Revision 1.3  2001/02/20 01:07:48  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:35  ramarao
 *      *** empty log message ***
 *
# Revision 1.4  2000/11/01  20:41:14  pinnacle
# Replaced: loft/src/unwext/VLunwsupport.I for:  by rchennup for Service Pack
#
# Revision 1.2  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.3  1998/01/23  15:26:18  pinnacle
# Replaced: src/unwext/VLunwsupport.I for:  by rchennup for loft
#
# Revision 1.2  1997/10/31  19:34:42  pinnacle
# Replaced: src/unwext/VLunwsupport.I for:  by rchennup for loft
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 10/28/97   Rama Rao     File Creation
 * 04/09/99   ah           Rama Rao SP08 Fixes
 * 05/21/00   Rama Rao	   Added Bevels as unwrap parents, if they have stock.
 *************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asmacros.h"
#include "VDobj.h"
#include "v_drw.h"
#include "vddrwattr.h"
#include "v_datamacros.h" 
#include "v_miscmacros.h" 
#include "vldbgmacros.h" 
#include "vlquerydef.h" 
#include "vlunfold.h" 
#include "vlunwext.h" 
#include "vlmsg.h" 

extern	GRclassid	OPP_VLunwFeat_class_id, OPP_ACrg_collect_class_id ;
extern  		VLgetMacrosAtStep();

from    GRgencs		import	GRgetmatrix;
from    GRcontext	import	GRgetmodule_env;
from 	ACrg_collect	import	ACadd_list_attribute, ACget_named_attribute;
from    VLunwObj	import	VDdeleteIfEmpty;

#define vdsDEBUG        1
#define vdserrDEBUG     1

/* -------------------------------------------------------------------------- */

/*+fe
Function   VLunw_ConstructFeat()

Abstract
	This function constructs a VLunwFeat object and set some
	instance values.

Arguments
	OUT	IGRlong		*msg		return status
	IN	IGRint		type		Object Type (see vddrwattr.h)
	IN/OUT	struct GRid	*elmId		Object Identifiers.
	IN	struct GRmd_env	*elmEnv		Module Environment
	INT	struct GRobj_env *dady		Parent object.
	
Return status
	OM_S_SUCCESS	oke.
	OM_E_ABORT	otherwise.

History
	06/06/95	adz		creation date
-fe*/

long VLunw_ConstructFeat( msg, elmId, elmEnv, dady )

IGRlong		*msg;			/* return status             */
struct GRid	*elmId;			/* Object Id.   	     */
struct GRmd_env	*elmEnv	;		/* Module Environment        */
struct GRobj_env *dady ;		/* Parent Object	     */
	
{
	/*
	 * Construct an new object and store instance data from the 
	 * parent object in the constructed object. 
	 */
	IGRint			sts = OM_S_SUCCESS;
	GRname			modMacro, modName, modDesign ;
	OMuword			classId=OPP_VLunwFeat_class_id ;
	VDdrwObjInfo		objInfo ;
	VDpartAttr		attr ;

	SetProc( VLunw_ConstructFeat  ); Begin

	*msg		= MSSUCC;

        if( !(vd_$is_ancestry_valid(    object  = elmId,
                                        classid = classId ))){

		elmId->osnum	= elmEnv->_MD_OS ;
		elmId->objid	= NULL_OBJID ;
	
		sts =
		om$construct(	classid = OPP_VLunwFeat_class_id,
				osnum   = elmId->osnum,
				p_objid = &(elmId->objid) );
		__CheckRC( sts, 1, "om$construct", wrapup );
	
		attr.Iwant	 = VD_I_drwInitialization ;
		sts =
		_VD_SEND_OBJN(  *elmId, GRvg.GRputattr( msg, (char *)&attr ));
		__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );
	}

	/*
	 * Add the parent information to the object.
         *              - macro name,
         *              - occurence name,
         *              - design file name,
	 */
	sts =
	VD_drwGetObjFeetInfo( msg, dady, modMacro, modName, modDesign );
	__CheckRC( sts, *msg, "VD_drwGetObjFeetInfo", wrapup );

	attr.Iwant		= VD_I_drwAllObjInfo ;
	objInfo.objMacro	= modMacro ;
	objInfo.objName		= modName ;
	objInfo.objDesign	= modDesign ;
	attr.specific		= (void *) & objInfo ;
	sts =
	_VD_SEND_OBJN(  *elmId, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	wrapup :

		if( !(sts & *msg & 1 )){
		    if( elmId->objid != NULL_OBJID ){
			/*
			 * Delete object.
			 */
			sts =
			vd_$bulk_delete(	count	= 1,
						grids	= elmId,
						theEnv	= elmEnv );
			elmId->objid = NULL_OBJID ;
		    }
		}
		
		End ;
		return sts ;
}


/* -------------------------------------------------------------------------- */

long VLunw_InitObjInfo( msg, vwInfo )

IGRlong		*msg;			/* return status             */
VDdrw2dVwInfo	*vwInfo ;		/* Information structure     */
	
{
	/*
	 * Construct an new object 
	 */
	SetProc( VLunw_Init2dVwInfo  ); Begin

	*msg	= MSSUCC ;

        vwInfo->intName		= NULL ;
        vwInfo->visFile		= NULL ;
        vwInfo->trsFile		= NULL ;
        vwInfo->prjVec		= NULL ;
        vwInfo->prjPnt		= NULL ;
        vwInfo->objLev		= NULL ;
        vwInfo->drwLbsys	= NULL ;

	End ;
	return OM_S_SUCCESS ;
}

/* -------------------------------------------------------------------------- */

long VLunw_IntObjInfo( msg, objInfo )

IGRlong		*msg;			/* return status             */
VDdrwObjInfo	*objInfo ;		/* Information structure     */
	
{
	/*
	 * Construct an new object 
	 */

	SetProc( VLunw_InitVwInfo  ); Begin

	*msg	= MSSUCC ;

	objInfo->objMacro	= NULL ;
        objInfo->objName	= NULL ;
        objInfo->objDesign	= NULL ;

	End ;
	return OM_S_SUCCESS ;
}

long VLunw_ConstMacroVw ( msg, elmId, elmEnv, prop, 
				nbAttr, Attr, nbParents, parents )

IGRlong		 *msg;			/* return status             */
struct GRid	 *elmId;		/* Object Id.   	     */
struct GRmd_env	 *elmEnv;		/* Module Environment        */
IGRint		 prop;			/* Construction properties   */
IGRint		 nbAttr;		/* Number of Attributes	     */
struct ACrg_coll *Attr;			/* ACrg collection           */
IGRint		 nbParents;		/* Number of Roots connected */
struct GRid	 *parents;		/* List of Roots Objects     */
{
	/*
	 * Construct an macro object 
	 */
	IGRint			i, sts = OM_S_SUCCESS, loc_sts = OM_S_SUCCESS;
	IGRlong			loc_msg = OM_S_SUCCESS;
	struct GRid             roots[30];
	IGRint                  nb_roots;

	SetProc( VLunw_ConstMacroVw ); Begin

	*msg	= MSSUCC;

        nb_roots = nbParents + 1 ;
        roots[0].osnum = elmEnv->md_id.osnum;

        for( i=0 ; i<nbParents ; i++ ){ roots[1+i] = parents[i]; }

        sts =
        om$construct(   classid = OPP_ACrg_collect_class_id,
                        osnum   = roots[0].osnum,
                        p_objid = &roots[0].objid);
        __CheckRC( sts, 1, "om$construct", wrapup );

       sts = _VD_SEND_OBJN( roots[0], NDnode.NDchg_state(
                                                ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL ));
        __CheckRC( sts, 1, "NDnode.NDchg_state", wrapup );

       if( Attr ){
                sts = _VD_SEND_OBJN(  roots[0],
                                ACrg_collect.ACadd_list_attribute(
                                                        msg,
                                                        nbAttr,
                                                        Attr ));
                __CheckRC( sts, 1, "ACrg_collect.ACadd_list_attr", wrapup );
                *msg = MSSUCC ;
        }

        /*
         * delete macro if one of the parent is deleted
         */
        sts =
        _VD_SEND_OBJN( *elmId, NDnode.NDchg_state( 
					ND_DONT_MVRT, ND_DONT_MVRT ));
        __CheckRC( sts, 1, "NDnode.NDchg_state", wrapup );

        sts =
        _VD_SEND_OBJN( *elmId, ACncpx.ACmplace(   
					(int *)msg,
                                        prop,
                                        0,
                                        "VLunwObj",
                                        nb_roots,
                                        roots,
                                        elmEnv ));
	if( !(sts&(*msg)&1) )
	{
           loc_sts =
           _VD_SEND_OBJN(  *elmId,
                         VLunwObj.VDdeleteIfEmpty( &loc_msg, elmEnv ));
           __CheckRC( loc_sts, loc_msg, "VLunwObj.VDdeleteIfEmpty", wrapup );
           __CheckRC( sts, *msg, "ACncpx.ACmplace", wrapup );
	}

	wrapup:

		End;
		return sts ;
}


VLunw_CrtViewSetOfList(	msg, plate, mdEnv, inCount, inList, visName,
			prjPnt, prjVec, objLevels, addToNewVw )

IGRlong			*msg ;
struct  GRobj_env       *plate ;
struct	GRmd_env	*mdEnv ;
IGRint			inCount ;
struct	GRid		*inList ;
IGRchar			*visName ;
IGRdouble		*prjPnt ;	/* Projection Point	 */
IGRdouble		*prjVec ;	/* Projection Vector	 */
IGRint                  *objLevels ;    /* Object Levels         */
IGRint			addToNewVw ;	/* Local storage option. */
{
	/*
	 * This function will check the context origin of the VLunwFeat object
	 * and related to that add them in a predefined group to process.
	 * When new context environments are found, a new control object will
	 * be created.
	 * In case 'addToNewVw' is TRUE the object will created in a new set
	 * of objects and the all visualization process information
	 * will be stored there.
	 */
	IGRint			sts = OM_S_SUCCESS ,
				i, j,
				prop,
				drwIndex,
				vwCount,
				infoCount, mxCount ;
	struct	GRid		drw2d, connVw,
				*vwList ;
	struct	GRmd_env	ctxEnv ;
	VDpartAttr		attr ;
	VDdrw2dVwInfo		vwInfo ;
	VDdrwMgrInfo		*mgrInfo ;

	SetProc( VLunw_CrtViewSetOfList ); Begin

	*msg	= MSSUCC ;
	vwCount	= 0 ;
	mxCount	= 0 ;
	vwList	= NULL ;
	mgrInfo	= NULL ;

	/*
	 * See how many objects are connect to the drawing manager.
	 */
	sts =
	VLunwMgrGetInfo(msg, mdEnv, (IGRchar *)NULL, (IGRushort *) NULL, 
			&vwCount, &vwList, (struct GRobj_env **) NULL );
	__CheckRC( sts, *msg, "VLunwMgrGetInfo", wrapup );

	__DBGpr_int(" Number of VLunwObj ", vwCount );

	/*
	 * Find from each group the corresponding reference file context.
	 */
	infoCount	= 0 ;
	mxCount		= vwCount + 10 ; /* Allocate more then needed.	*/

	if( !( mgrInfo = _MALLOC( mxCount, VDdrwMgrInfo )))
		vd_$mem_fail();

   	for( i=0; i<vwCount ; i++ ){

		__DBGpr_obj(" List ",  vwList[i] );

		sts =
		VLunw_GetOneChannelObject( msg, vwList +i, mdEnv,&drw2d, NULL );
		CheckRC( sts, *msg );
		if( !(sts & *msg & 1 )){
//			__DBGpr_com(" FOUND LIST WITHOUT ELEMENT ");
			sts = *msg = MSSUCC;
			continue ;
		}

		attr.Iwant = VD_I_drwParentCtx ;
		attr.obj._objid = NULL_OBJID ;
		sts =
		_VD_SEND_OBJN(	drw2d, GRvg.GRgetattr( msg, (char *) &attr ));
		CheckRC( sts, *msg );
		if(    !(sts & *msg & 1 )
		    || ( attr.obj._objid == NULL_OBJID )){
			__DBGpr_com(" GetAttr FAILED ");
			continue ;
		}

		__DBGpr_obj(" Context ", attr.obj._grid );

		sts =
		_VD_SEND_OBJN(	attr.obj._grid,
				GRcontext.GRgetmodule_env(msg, &ctxEnv ));
		CheckRC( sts, *msg );
		if(  !(sts & *msg & 1 )){
			__DBGpr_com(" GRgetmodule_env FAILED ");
			continue ;
		}	

		/*
		 * Store the information in a structure.
		 */
		mgrInfo[infoCount].VwId    = vwList[i] ;
		mgrInfo[infoCount].mtxType = ctxEnv._MATRIX_TYPE ;
		for(j=0;j<16;j++) mgrInfo[infoCount].mtx[j] = ctxEnv._MATRIX[j];
		__DBGpr_mat(" Matrix ", mgrInfo[infoCount].mtx );

		infoCount++ ;
		__DBGpr_int(" infoCt ", infoCount );

	} /* for .. vwCount */

	/*
	 * Check all the VLunwFeat objects if they can be connected to 
	 * an existed group or that a new group needs to be created.
	 */
	for( i=0 ; i<inCount ; i++ ){

		/*
		 * Get the context environment of the input object.
		 */
		__DBGpr_obj(" inList ", inList[i] );

		attr.Iwant = VD_I_drwParentCtx ;
		attr.obj._objid = NULL_OBJID ;
		sts =
		_VD_SEND_OBJN(	inList[i],
				GRvg.GRgetattr( msg, (char *) &attr ));
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

		if( attr.obj._objid == NULL_OBJID ) continue ;

		__DBGpr_obj(" Context ", attr.obj._grid );

		sts =
		_VD_SEND_OBJN(	attr.obj._grid,
				GRcontext.GRgetmodule_env(msg, &ctxEnv ));
		__CheckRC( sts, *msg, "GRcontext.GRgetmodule_env", wrapup );

		sts =
		VDdrw_FindCtxFromVwList(msg, &ctxEnv,
					&drwIndex, infoCount, mgrInfo );
		__CheckRC( sts, *msg, "VDdrw_FindCtxFromVwList", wrapup );

		if( drwIndex == VD_I_drwIndexNotFound ){

		  /*
		   * Create New entree for object.
		   */
		  sts =
		  VLunwMgr_ConnectVw( msg, mdEnv, &connVw );
		  __CheckRC( sts, *msg, "VLunwMgr_ConnectVw", wrapup );

//		  prop = AChdr_nodisplay | AChdr_nocompute ;
  		  prop = AChdr_noprotect ;
		  sts =
		  VLunw_ConstMacroVw( msg, &connVw, mdEnv,
                                      prop, 0, NULL, 1, &plate->obj_id );
		  __CheckRC( sts, *msg, "VLunw_ConstMacroVw", wrapup );

		  VLunw_InitObjInfo( msg, &vwInfo );
		  vwInfo.visFile  = visName ;
		  vwInfo.prjVec   = prjVec ;
		  vwInfo.prjPnt   = prjPnt ;
		  vwInfo.objLev   = objLevels ;

		  attr.Iwant = VD_I_drwProjAllInfo ;
		  attr.specific = (void *) &vwInfo ;
		  sts =
		  _VD_SEND_OBJN(connVw, GRvg.GRputattr( msg, (char *)&attr ));
		  __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );
		}
		else	connVw = mgrInfo[drwIndex].VwId ;

		/*
		 * Connect the drawing object with the VLunwObj
		 */
		sts =
		VLunwMgr_ConnectObjectsToVw(	msg, mdEnv, 
						&connVw, 1, inList +i );
		__CheckRC( sts, *msg, "VLunwMgr_ConnectObjectsToVw", wrapup );

		/*
		 * When VLunwObj in list continue ;
		 */
		if( drwIndex != VD_I_drwIndexNotFound )	continue ;

		/*
		 * Add the new one in the list.
		 */
		__DBGpr_obj(" New VLunwObj ",  connVw );

		/*
		 * Store the information in a structure.
		 */
		if( infoCount >= mxCount ){

		  mxCount += 10 ;
		  if( !( mgrInfo = _REALLOC( mgrInfo, mxCount, VDdrwMgrInfo )))
                        vd_$mem_fail() ;
		}

		mgrInfo[infoCount].VwId    = connVw ;
		mgrInfo[infoCount].mtxType = ctxEnv._MATRIX_TYPE ;
		for(j=0;j<16;j++) mgrInfo[infoCount].mtx[j] = ctxEnv._MATRIX[j];

		infoCount++ ;
	}

	wrapup:

		_FREE( vwList );
		_FREE( mgrInfo );
		End ;
		return TRUE ;
}


IGRlong VLunw_CreateUnwrapObj( 	long                    *msg,
				struct  GRobj_env       *plate,
				struct  GRmd_env        *mdEnv,
				struct  GRid		cs_obj,
				IGRdouble               *options,
				IGRchar                 *setup_file,
				struct GRid		*unw_obj,
				IGRint                  *featCount,
				struct  GRid            *featList[] )
{
   IGRlong                 sts ;
   IGRdouble               prjPnt[3], prjVec[3], toMat[16];
   IGRint                  i, prop, numObjects = 0, nb_edge=0, featCnt=0;
   IGRchar         	   macName[128];
   struct GRobj_env        org_plate, *list_obj  = NULL, *featObjs=NULL;
   struct GRid             connVw, box, *root_list = NULL ;
   struct  ACrg_coll       attrib, ACrg[UNFOLD_NB_OPT] ;
   VDdrw2dVwInfo   	   vwInfo ;
   VDpartAttr              attr ;
   VD_drwMacInfo           *drwMacInfo=NULL ;
   IGRint                  wtBatch;
   IGRint                  cnType;
   extern IGRboolean       ASbroadcast_in_progress ;
   IGRboolean              saveBroad;
   FILE			   *file_p=NULL;

        SetProc( VLunw_CreateUnwrapObj ); Begin

        *msg = MSSUCC ;

        if( featCount ) 	*featCount       = 0 ;
        if( featList  )		*featList        = NULL ;
	if( unw_obj   )		unw_obj->objid   = NULL_OBJID;

        prjVec[0] = 0 ;    prjVec[1] = 0 ;    prjVec[2] = 1 ;
        prjPnt[0] = 0 ;    prjPnt[1] = 0 ;    prjPnt[2] = 0 ;

	strcpy( attrib.name, "stock_value" );

	org_plate = *plate;
        as$make_source( go_grid  = plate->obj_id,
                        mod_env  = &plate->mod_env,
                        as_grid  = &plate->obj_id      );

        connVw.objid    = NULL_OBJID ;
        sts = VLunwMgr_ConnectVw( msg, mdEnv, &connVw );
        __CheckRC( sts, *msg, "VLunwMgr_ConnectVw", wrapup );

        VLunw_InitObjInfo( msg, &vwInfo );

       	sts = _VD_SEND_OBJN( cs_obj, GRgencs.GRgetmatrix( msg, toMat ));
        __CheckRC( sts, *msg, "GRgencs.GRgetmatrix", wrapup );

	/* Slight tweak, print if no 1.0 */
	if (toMat[15] != 1.0) {
	  printf("\n==============\n toMat[15] = %g\n", toMat[15] );
	}
	
    	attr.Iwant = VL_I_toMat ;
    	attr.specific = (void *) toMat ;
    	sts = _VD_SEND_OBJN( connVw, GRvg.GRputattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	if( !( file_p = VLunwOpenSetupFilex( setup_file, NULL ) ))
	{
	    printf("Can not open setup file: [%s]. Opening default unwrap_setup file\n", setup_file );
	    strcpy( setup_file, "unwrap_setup" );
	}
	else fclose( file_p );

	vwInfo.visFile  = setup_file ;
        vwInfo.prjVec   = prjVec ;
        vwInfo.prjPnt   = prjPnt ;
        vwInfo.objLev   = NULL;
        attr.Iwant = VD_I_drwProjAllInfo ;
        attr.specific = (void *) &vwInfo ;
        sts = _VD_SEND_OBJN(  connVw, GRvg.GRputattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

 	attr.Iwant = VD_I_drwVisual ;
	strcpy( attr.aString, setup_file );
	_VD_SEND_OBJN(connVw, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

        sts = VLunwext_LoadKeyWords();
        if ( !(1 & sts)) {
           goto wrapup;
        }

	VD_drw_init_from_drawing_setup ( setup_file,  &drwMacInfo );

	VD_drwExecConfigRmFunctions();

        VLbrowseFctInTree( &org_plate, VL_Q_TOP_SOURCE, NULL,
                           VL_Q_DOWN_DIRECT,
                           VLgetMacrosAtStep,
                           &numObjects,
                           &list_obj );
	nb_edge = 0;
	for( i=0; i<numObjects; ++i )
        {
	    vdobj$Get(	objOE 	= &list_obj[i],
			macName = macName );
	    if(  !strcmp( macName, "Bevel" )     ||
		 !strcmp( macName, "EJ_Bevel" )  ||
		 !strcmp( macName, "Fab_Stock" ) )
	    {
        	// find the box
        	sts = om$send( msg     = message  ACcpx.ACfind_exp_temp_obj(
                                                         (IGRint *)msg,
                                                         0,
                                                         &box ),
                    senderid = NULL_OBJID,
                    targetid = list_obj[i]._objid,
                    targetos = list_obj[i]._osnum );
        	if(!(sts&(*msg)&1) ) continue;

        	sts = om$send(msg = message 
			  ACrg_collect.ACget_named_attribute( msg, &attrib ) ,
                       senderid = NULL_OBJID,
                       targetid = box.objid,
                       targetos = box.osnum);
		if(!(sts&(*msg)&1) ) continue;

		if( attrib.desc.value.att_exp > 0.00001 ) 
			list_obj[nb_edge++] = list_obj[i] ;
	    }
        }

   	if( !(root_list = _MALLOC( nb_edge+1, struct GRid )) )
		vd_$mem_fail();

	if( nb_edge )
	{
	   for( i=0; i<nb_edge; ++i )
	   {
		as$make_source( go_grid  = list_obj[i].obj_id,
				mod_env  = &list_obj[i].mod_env,
				as_grid	 = &root_list[i+1] );
	   }
	}

        as$make_source( go_grid  = plate->obj_id,
                        mod_env  = &plate->mod_env,
                        as_grid  = &root_list[0]      );

        /* Prepare ACrg collection */
	i=0;

	strcpy(ACrg[i].name,UNFOLD_ATT_FIB_RATIO);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_FIB_RATIO];
	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_X_EXPANSION);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_X_EXPANSION];
	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_Y_EXPANSION);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_Y_EXPANSION];
  	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_SRFWANTED);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_SRFWANTED];
	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_EXPTYPE);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_EXPTYPE];
	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_TESSELATION);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_TESSELATION];
	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_LINES);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_LINES];
	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_WATONPLATE);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_WATONPLATE];
	i++;

	strcpy(ACrg[i].name,UNFOLD_ATT_SIDE);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_SIDE];
	i++;

        strcpy(ACrg[i].name,UNFOLD_ATT_UNWOPT);
        ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[i].desc.value.att_exp = options[UNFOLD_ATT_IDX_UNWOPT];
        i++;

        prop = AChdr_noprotect ;
        sts = VLunw_ConstMacroVw(msg, &connVw, mdEnv, prop, i, ACrg,
				nb_edge+1, root_list );
        __CheckRC( sts, *msg, "VLunw_ConstMacroVw", wrapup );

         sts = VLunw_GetChannelObjects( msg, &connVw, mdEnv,
                                           &featCnt, NULL, &featObjs );
         __CheckRC( sts, *msg, "VLunw_GetChannelObjects", wrapup );

	cnType = ND_COMP;

	for( i=0; i<featCnt; ++i )
	{
		saveBroad = ASbroadcast_in_progress ;

		sts = nd$wait_batch(  type       = GR_GEOM_POSTED,
               			      l_object   = &featObjs[i].obj_id,
               			      l_obj_info = &cnType,
               		      	      nb_obj     = 1 );

		nd$mod_batch(   request    = ND_INQ,
        	       		p_ret_mode = &wtBatch);

		ASbroadcast_in_progress = FALSE ;
		if( wtBatch != ND_DEFER ) /* else nothing to do */
     		    nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);

		ASbroadcast_in_progress = saveBroad ;
	}

wrapup:
  VD_drwFreeExtractMacInfo( drwMacInfo ) ;
  _FREE( list_obj );
  _FREE( featObjs );
  _FREE( root_list );
  return sts;
}

long	VLunw_ProcessFeat_Objects(	msg, mdEnv, cn_type,
					inCount, inList )

long			*msg ;
struct	GRmd_env	*mdEnv ;
IGRint			cn_type ;
IGRint			inCount ;
struct	GRid		*inList ;
{
	IGRint			sts = OM_S_SUCCESS,
				i, 
				nbFeets ,
				nbRoots ;
	struct	GRid		Roots[20],
				Feets[20];	/* VLunwFeat has 1 feet(s)  */

	SetProc( VLunw_ProcessFeat_Objects ); Begin 

	*msg = MSSUCC ;
	
	__DBGpr_int(" inCount         ", inCount );

	UI_echo( "" );
	UI_status( "" );

	for( i=0 ; i<inCount ; i++ ){

	    __DBGpr_obj( "FeatObj ", inList[i] );

	    nbRoots = 0 ;

	    sts = _VD_SEND_OBJN(	inList[i],
				NDnode.NDget_objects(	ND_ROOT,
                                                        Roots,
                                                        20,
							NULL,
                                                        0,
							OM_K_MAXINT,
                                                        &nbRoots ));
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

            sts =
	    _VD_SEND_OBJN(	inList[i],
				ACncpx.ACconstruct_feet(msg,
							0x8000,
                                                        nbRoots,
							Roots,
                                                        mdEnv,
                                                        &nbFeets,
                                                        Feets ));

            if( sts&*msg&1 ){
		sts =
		_VD_SEND_OBJN(	inList[i],
				ACncpx.ACchange_feet(	nbFeets,
							Feets,
							mdEnv ));

		sts =
		vd_$bulk_display(	dpmode	= GRbd,
					count	= 1,
					grids	= inList +i,
					theEnv	= mdEnv );
	    }
            else{ 
		sts =
		vd_$bulk_delete(	count	= 1,
					grids	= inList +i,
					theEnv	= mdEnv );
		inList[i].objid	= NULL_OBJID ;
	    }
	} /* for ( .. inCount ) */

	UI_echo("");

	*msg = MSSUCC ;

	wrapup:
		End ;
		return sts ;
}

end implementation VDSroot;
 
