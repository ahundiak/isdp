/* $Id: VDCmdSctFnc.I,v 1.2 2002/01/10 21:18:50 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vddraw/func/VDCmdSctFnc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdSctFnc.I,v $
 *	Revision 1.2  2002/01/10 21:18:50  ylong
 *	TR5823, fixed by Ad.
 *	
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
# Revision 1.2  1995/08/07  20:28:06  pinnacle
# Replaced: vddraw/func/VDCmdSctFnc.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/28  20:36:44  pinnacle
# Created: vddraw/func/VDCmdSctFnc.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/01/95	adz		creation date
 *      01/20/95        R. Manem        Removed check for Model
 *					view ancestry
 *	02/12/95	adz		Add process info.
 *	06/01/95	adz		Add the offset to the VDdrw3dVw.
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdSctCts;

#include <stdio.h>
#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "FI.h"
#include "vdsollocdef.h"
#include "vderrmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "griodef.h"
#include "UOMdef.h"
#include "grio.h"
#include "griomacros.h"
#include "UOMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "macro.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vd_ve.h"
#include "v_edgedef.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_edgemacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

extern	GRclassid	OPP_VDdrw3dVw_class_id;
extern	GRclassid	OPP_VDdrw3d_class_id;
extern	GRclassid	OPP_VDmdlview_class_id;

/*
 * external stop request access function.
 */

extern	IGRboolean		IGEstop();

from	VDSroot		import	VDcreate , VDcompute ;
from	GRvg		import	GRgetattr, GRputattr ;

/* -------------------------------------------------------------------------- */

long	VD_crtSectionObjects(	msg,
				md_env,
				mvObj,
				volOffset,	/* Solid offset		*/
				comp3dVw,
				level3d,	/* Locatable levels	*/
				visual2d,	/* 2d support file	*/
				visual3d,	/* 3d support file	*/
				mdCount,
				mdList,
				batch1_inter0,	/* Process Type		*/
				drw3dVwId )

long			*msg ;
struct	GRmd_env	*md_env ;
struct	GRobj_env	*mvObj ;
IGRdouble			volOffset ;
int			comp3dVw ;
short			level3d ;
char			*visual2d ;
char			*visual3d ;
int			mdCount ;
struct	GRobj_env	*mdList ;
IGRboolean		batch1_inter0;
struct	GRid		*drw3dVwId ;
{

	IGRint			sts = OM_S_SUCCESS,
				cn_type = ND_COMP,
				nbAttr,
				nbRoots,
				EndLoop = 0,
				outCount,
				i, prop ;
	IGRchar			*visPtr ;
	IGRdouble		dbOffset ;
	GRname			echoProc ;
	struct GRid		Roots[2],
				*outList,
				drw3d;
	struct	ACrg_coll	*Attr = NULL ;
	IGRboolean		drw3dVwExist , drw3dExist ,
				doneVwConn = FALSE ;
	VDpartAttr		attr ;
	VD_drwMacInfo		*drwMacInfo ;

	SetProc( VD_crtSectionObjects ); Begin

	*msg		= MSSUCC ;
	nbRoots		= 1 ;
	drwMacInfo	= NULL ;
	outList		= NULL ;
	outCount	= 0 ;
	visPtr		= NULL ;

	__DBGpr_obj("Vol Object ", mvObj->_grid );
	__DBGpr_int("Number Obj ", mdCount );

	/*
	 * check the input files; First check against the 'visual3d' file;
	 * When this file is empty or pointer does not exist, we will
	 * check the 'visual2d' file, which is called for attribute setting
	 * for batch process.
	 */

	if(( visual3d ) && strlen( visual3d )){

		__DBGpr_str(" Support file ", visual3d );
		visPtr = visual3d ;
	}

	if( ! visPtr ){
	  if(( visual2d ) && strlen( visual2d )){

		__DBGpr_str(" Support file ", visual2d );
		visPtr = visual2d ;
	  }
	}

	if( visPtr ){

		/*
		 * Just to protect to read the visual file for batch
		 * preprocessing.
		 */
		VD_drwExecSectAddFunctions();
		VD_drwExecConfigAddFunctions();

		if( VD_drw_init_from_drawing_setup( visPtr, &drwMacInfo )){

#ifdef	vdsDEBUG
		  VD_drwMacInfo   *m ;
		  VD_drwAttrList  *a ;

		  if( drwMacInfo ){
                    __DBGpr_com(" START DUMP ") ;
                    for( m = drwMacInfo ; m ; m = m->next ) {
                      printf( "Mac <%s> \n", ( m->macDefName != NULL ) ?
					m->macDefName : "NULL" );
                      printf( "Drawing <%s>\n", (m->drwMacName != NULL) ?
					m->drwMacName : "NULL" ) ;
                      for( a = m->attrList ; a ; a = a->next ) {
                         printf( "\t\t<%s>\n", (a->attrName != NULL) ?
					a->attrName : "NULL" ) ;
                      }
                    }
                    __DBGpr_com("END DUMP" ) ;
        	  }
#endif
		}
		else{
		  if( drwMacInfo ) VD_drwFreeExtractMacInfo( drwMacInfo );
		  drwMacInfo = NULL ;
		}

		VD_drwExecSectRmFunctions();
		VD_drwExecConfigRmFunctions();
	}

	__DBGpr_int(" LEVEL ", level3d );

	/*
	 * Make source from the external object and check if the 
	 * VDdrw3dVw object already exist.
	 */
	nbRoots  = 1;
        sts =
        as$make_source(	go_grid	= mvObj->_grid,
			mod_env	= &mvObj->mod_env,
			as_grid	= &Roots[0] );
	__CheckRC( sts, 1, "as$make_source", wrapup );

	drw3dVwId->objid	= NULL_OBJID;
	drw3dVwId->osnum	= md_env->_MD_OS ;

	/*
	 * check if there is already a VDdrw3dVw object connected
	 * with the solid.
	 */
	sts =
	VDchk_child_on_class(	msg, &(mvObj->_grid), &Roots[0],
				"VDdrw3dVw", drw3dVwId );

	drw3dVwExist = ( drw3dVwId->objid == NULL_OBJID ) ? FALSE : TRUE ;

	if( ! drw3dVwExist ){
		sts =
		VDdrwMgr_ConnectVw( msg, md_env, VD_O_drw3dVw, drw3dVwId );
	}

	/*
	 * recalculate the volOffset value to db_internal values.
	 */
	dbOffset = volOffset ;

	{
		IGRchar		type[UOM_K_MAX_TYPE] ,
				name[20] ;
		IGRshort	flag = 0 ,
				num_defaults ;
		GRIOalias_name	default_units[3] ;

		strcpy( type, GRIO_DISTANCE );
		co$get_default_units(	msg		= msg,
					table_name	= type,
					osnum		= md_env->md_id.osnum,
					flag		= &flag,
					num_defaults	= &num_defaults,
					default_units	= default_units );
		strcpy( name, default_units[0] );

		/*
		 * convert to database units.
		 */
		sts =
		uom$cvt_value_to_value(	msg		= msg,
					unit_type	= type,
					osnum		= md_env->md_id.osnum,
					alias_to_cvt_from = name ,
					alias_to_cvt_to	= NULL,
					num_vals	= 1,
					values_in	= &volOffset,
					values_out	= &dbOffset );

		__DBGpr_dbl(" Offset IN ", volOffset );
		__DBGpr_dbl(" Offset OUT",  dbOffset );
	}

	/*
	 * put information in the object.
	 */
	attr.Iwant	= VD_I_drwCompute ;
	attr.aInt	= comp3dVw ;
	sts = _VD_SEND_OBJN( *drw3dVwId, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	attr.Iwant	= VD_I_drwOffset ;
	attr.aValue	= dbOffset ;
	sts = _VD_SEND_OBJN( *drw3dVwId, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	attr.Iwant	= VD_I_drwVisual ;
	if( visual3d )	strcpy( attr.aString, visual3d );
	else		strcpy( attr.aString, "" );
	sts = _VD_SEND_OBJN( *drw3dVwId, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	attr.Iwant	= VD_I_drwLevel ;
	attr.aType	= level3d ;
	sts = _VD_SEND_OBJN( *drw3dVwId, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	if( ! drw3dVwExist ){

		prop = AChdr_nodisplay ;
		sts =
		VDdrw_ConstMacroVw( msg, VD_O_drw3d, drw3dVwId, md_env,
					prop, nbRoots, Roots );
       		 __CheckRC( sts, *msg, "VDdrw_ConstMacroVw", wrapup );
	}
	else{
        	sts =
		_VD_SEND_OBJN(	*drw3dVwId,
				VDSroot.VDcompute( msg, &cn_type ));
        	__CheckRC( sts, *msg, "VDSroot.VDcompute", wrapup );
	}




	/*
	 * Filter out objects which are no more needed and create the
	 * VDdrw3d objects without computing them.
	 */

	outCount = 0 ;
	if( !( outList = _MALLOC( mdCount, struct GRid )))
		vd_$mem_fail();

	for( i=0 ; i<mdCount ; i++ ){

		/*
		 * Ask for signal.
		 */
		if( ( EndLoop = IGEstop()) != 0 ){
			/*
			 * Request to stop process.
			 */
			*msg = MSFAIL ;
			goto wrapup ;
		}
			
		/*
		 * inform process status in echo field.
		 */
		sprintf(echoProc,
			"Pre-Processing %.0f%% ",(double)(i*100./mdCount));
		UI_echo( echoProc );
		UI_status( "" );

#ifdef	vdsDEBUG
		VD_ShowObj( & mdList[i]._grid );
#endif

		/*
		 * make_source for object.
		 */
		Roots[0].objid = NULL_OBJID ;
		sts =
		as$make_source(	go_grid	= mdList[i]._grid,
				mod_env	= &mdList[i].mod_env,
				as_grid	= &Roots[0] );
		__CheckRC( sts, 1, "as$make_source", wrapup );

		drw3d.objid	= NULL_OBJID ;
		drw3d.osnum	= md_env->_MD_OS ;

		sts =
		VDchk_child_on_class(	msg, &mdList[i], &Roots[0], "VDdrw3d",
					&drw3d );

		drw3dExist = ( drw3d.objid == NULL_OBJID ) ? FALSE : TRUE ;

		if( drw3dExist ){

		  /*
		   * check if existing drwSect object is own by
		   * current VDdrw3dVw object.
		   */

		  struct GRid	tmp3dVw ;

		  __DBGpr_obj(" Temp VDdrw3d ", drw3d );
			
		  sts =
		  VDdrw_GetChannelOwner( msg, &drw3d, VD_O_drw3d, &tmp3dVw );
		  if( !(sts & *msg & 1)){
		  	__DBGpr_obj(" Invalid Model object  ", mdList[i]._grid );
		  	__DBGpr_obj(" Invalid Pretendin     ", Roots[0] );
		  	__DBGpr_obj(" Invalid Child VDdrw3d ", drw3d );
			drw3dExist = FALSE;
			tmp3dVw.objid = NULL_OBJID ;
			continue;
	          }	
			

		  __DBGpr_obj(" Temp VDdrw3dVw ", tmp3dVw );

		  if( IF_EQ_GRID( *drw3dVwId, tmp3dVw )){
			__DBGpr_com(" Imposible Case ");
		        continue ;
		  }
		  else{
			/*
			 * Not existing VDdrw3d object for Current Object.
			 */
			drw3dExist = FALSE ;
		  }
		}

		if( ! drw3dExist ){
		  /*
		   * construct the object.
		   */
		  drw3d.objid = NULL_OBJID ;
		  sts =
		  VDdrw_ConstructVDdrw( msg, VD_O_drw3d, &drw3d, 
					md_env,&mdList[i]);
		  __CheckRC( sts, *msg, "VDdrw_ConstructVDdrw", wrapup );

	          /*
		   * check the parent attributes and set them in the
		   * collector.
		   * find the macro definition of parent and check with
		   * attribute list from the setup files.
		   */
		  if( drwMacInfo ){

			  _FREE(  Attr );
			  nbAttr	= 0 ;
			  Attr		= NULL ;

               	 	  sts =
                	  VD_drw_GiveObjAttrList(	msg,
							mdList +i,
							drwMacInfo,
							&nbAttr,
							&Attr );
			  if( !(sts&*msg&1)){
				__DBGpr_com("FAILED: VD_drw_GiveObjAttrList ");
                        	vd_$bulk_delete(count   = 1,
						theEnv  = md_env,
						grids   = &drw3d );
				continue ;
			  }
		  }

		  /*
		   * when object does not exit, we will create
		   * the object but compute it later.
		   */

		  sts =
		  _VD_SEND_OBJN(drw3d,
				VDSroot.VDcreate(msg,
						nbAttr, Attr,
						VDdrw_M_3d,
						AChdr_nodisplay|AChdr_nocompute,
						nbRoots, Roots ));
		  if( !(sts & *msg & 1)){
			__DBGpr_com("FAILED: VDcreate ");
                       	vd_$bulk_delete(count   = 1,
					theEnv  = md_env,
					grids   = &drw3d );
			continue ;
		  }

		  if( drwMacInfo ){
			  _FREE(  Attr );
			  nbAttr	= 0 ;
			  Attr		= NULL ;
		  }
		}

		outList[outCount] = drw3d ;
		outCount ++ ;
	}

	__DBGpr_int( "Number of VDdrw3d objects", outCount );

	/*
	 * Connect all the objects to the VDdrw3dVw control object.
	 */
	sts =
	VDdrwMgr_ConnectObjectsToVw(	msg, md_env, VD_O_drw3d, 
					drw3dVwId, outCount, outList );
	__CheckRC( sts, *msg, "VDdrwMgr_ConnectObjectsToVw", wrapup );

	doneVwConn = TRUE ;

	/*
	 * Compute the result of the objects.
	 */
	sts =
	VDdrw_ProcessVDdrw_Objects(	msg,
					md_env,
					VD_O_drw3d, 
					(batch1_inter0) ? VD_P_drw_PREPROCESS
							: VD_P_drw_INTERACTIVE,
					outCount,
					outList );
	__CheckRC( sts, *msg, "VDdrw_ProcessVDdrw_Objects", wrapup );

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup:

		/*
		 * Cleanup the fields.
		 */
		UI_echo( "" );
		UI_status( "" );

		if( drwMacInfo ) VD_drwFreeExtractMacInfo( drwMacInfo );
		drwMacInfo = NULL ;

	 	if( !( sts & *msg & 1 )){
		  /*
		   * Invalid processing.
		   */
		  if( drw3dVwId->objid != NULL_OBJID ){

			__DBGpr_com(" Invalid Process -> Delete All ");

			vd_$bulk_delete(count   = 1,
					theEnv  = md_env,
               		                grids   = drw3dVwId );

			if( ! doneVwConn ){
			  vd_$bulk_delete(count = outCount,
					theEnv  = md_env,
               		                grids   = outList );
			}
		  }
		}

		_FREE( outList );
		_FREE( Attr );
		_FREE( outList );
	
		End ;
		return	sts;
}

end implementation VDCmdSctCts;
