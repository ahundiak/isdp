/* $Id: VDgetownobj.I,v 1.11 2001/03/01 17:14:08 ylong Exp $  */


/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDgetownobj.I
 *
 * Description:
 *		The function described in this file does the sort the
 *		objects and keep only the owner object in the list.
 *		Input List will be output list.
 *		A second function is added to do the identical operations.
 *		on a graphical set.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgetownobj.I,v $
 *	Revision 1.11  2001/03/01 17:14:08  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.10  2001/02/15 21:42:51  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.9  2001/02/14 19:51:02  ramarao
 *	Modification related to __DBGpr_obj() macro.
 *	
 *	Revision 1.8  2001/02/05 18:05:14  anand
 *	CR JTS MP 4488
 *	
 *	Revision 1.7  2001/01/30 17:05:03  jayadev
 *	parent change detection problems; so always recompute to stay in sync
 *	
 *	Revision 1.6  2001/01/29 21:07:23  jayadev
 *	VDdrawingExtractFeatures() moved from VLcheckFunk.I to here
 *	
 *	Revision 1.5  2001/01/22 18:52:40  paul_noel
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/01/22 18:04:22  hans
 *	removed redeclared: extern som_objid_to_tag();
 *	
 *	Revision 1.3  2001/01/19 15:38:21  paul_noel
 *	Tools added to
 *	GetNodeType
 *	GetNodeName
 *	GetSetType
 *	GetSetName
 *	GetSetTree
 *
 *	Revision 1.2  2001/01/18 23:09:06  hans
 *	SP16 modifications
 *
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *
>>>>>>> 1.4
# Revision 1.27  2000/10/30  20:52:12  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.26  2000/09/24  15:59:42  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.25  2000/08/29  21:58:08  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.24  2000/08/26  16:17:54  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.23  2000/08/26  16:13:30  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.22  2000/08/24  14:55:04  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.21  2000/08/21  19:00:40  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.20  2000/08/21  15:30:00  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.19  2000/08/21  14:35:12  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by jpulapar for Service Pack
#
# Revision 1.18  2000/08/16  15:33:04  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.17  2000/08/15  22:21:06  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.16  2000/08/15  21:37:06  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.15  2000/08/15  16:28:42  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.14  2000/08/15  15:25:26  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.13  2000/08/11  22:38:24  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.12  2000/08/11  16:39:10  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.11  2000/08/10  23:46:24  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.10  2000/08/09  23:51:08  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.9  2000/08/08  18:25:14  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.8  2000/08/08  16:36:52  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.7  2000/08/04  22:27:22  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.6  2000/08/03  21:59:30  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.5  2000/08/01  23:00:18  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/08/01  22:12:42  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.3  2000/07/27  21:04:06  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/07/27  15:36:52  pinnacle
# Replaced: vds/vdmisc/VDgetownobj.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/06/15  16:49:02  pinnacle
# Created: vds/vdmisc/VDgetownobj.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/02/11  21:39:52  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by azuurhou for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.14  1996/05/21  19:41:04  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by v240_int for vds.240
#
# Revision 1.13  1996/05/16  16:11:24  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by svkadamb for vds.240
#
# Revision 1.12  1995/11/03  17:16:24  pinnacle
# Replaced: ./vdmisc/VDgetownobj.I for:  by azuurhou for vds.240
#
# Revision 1.10  1995/09/14  17:56:40  pinnacle
# Replaced: ./vdmisc/VDgetownobj.I for:  by azuurhou for vds.240
#
# Revision 1.9  1995/09/10  18:24:32  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/08/28  15:17:08  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by azuurhou for vds.240
#
# Revision 1.7  1995/08/25  20:52:58  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by rmanem for vds.240
#
# Revision 1.6  1995/08/17  22:53:48  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/07/11  20:17:12  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/06/27  18:33:46  pinnacle
# Replaced: vdmisc/VDgetownobj.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/31/95	adz		creation date
 *	06/05/95	adz		add indentical function for set.
 *					+ optional checking.
 *	08/16/95	adz		Add VDrelat_hdr checking option.
 *	08/25/95	rmn		Removed check for VDSroot ancestry
 *	09/28/95	adz		Generate Macro Call for Checking.
 *      02/11/98        adz             Add the frzPlate & frzBeam.
 *      06/14/00        Jayadev         changes for CR179901680
 *      08/01/00        Jayadev         general utility routines for drawings
 *				 	interfacing vd$review_drawing and 
 *					vd$drw_process macros
 *      09/24/00        Jayadev         TR179902038 
 *      10/30/00        Jayadev         VDaddAttr function changed 
 *      01/29/00        Jayadev         VDdrawingExtractFeatures moved from LOFT
 *					VLcheckFunk.I to here 
 *	02/05/01	Anand		Added two static globals and two new
 *					functions that will be called by PPLs
 *					to manipulate the static-globals. These
 *					variables will control what additional
 *					classes shall be excluded/included in
 *					querying.
 *	02/15/01	ylong		modified VDgetOccName
 ***************************************************************************/

class implementation VDSroot ;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "ACcheckin.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "asmacros.h"
#include "grgsmacros.h"
#include "EMSmsgdef.h"
#include "VDchn.h"
#include "VDobj.h"
#include "vddrwattr.h"
#include "vdsetmacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_drwprocess.h"
#include "vddrwattr.h"
#include "vdprdmacros.h"

#include "maidmx.h"
#include "mamulmx.h"

/*
#define vdsDEBUG        1
#define vdserrDEBUG     1

#include "v_dbgmacros.h"

#define DEBUG 1
*/

static struct GRobj_env *features;
static IGRint           *featState;
static IGRint            featCount;

/*
 * Includes of function prototypes.
 */
from	GRgrset		import	GSremove_member,
				GSobject_add;
from	ACheader	import	ACfind_model;
from	VDlink		import	ACget_model_list;
from    VDcontext       import VDget_extract_info;
from    VDcontext       import VDget_osname;
from    VDcontext       import VDset_osname;
from    ACrg_collect    import AClist_attribute;
from    ACrg_collect    import ACadd_list_attribute,ACmod_list_attribute;
from    GRcontext       import GRgetinstance;
from    ACcpx_defn      import ACgive_feet_desc,ACgive_name;

extern	GRclassid	OPP_VDSroot_class_id ;
extern	GRclassid	OPP_GRgrset_class_id ;
extern	GRclassid	OPP_VDdrawing_class_id ;
extern	GRclassid	OPP_VDdrw2d_class_id ;
extern	GRclassid	OPP_VDdrw2dVw_class_id ;
extern	GRclassid	OPP_VDdrw3dVw_class_id ;
extern	GRclassid	OPP_VDdrwGm_class_id ;
extern	GRclassid	OPP_VDgeom_class_id ;
extern	GRclassid	OPP_VDdrwTblHdr_class_id ;
extern	GRclassid	OPP_VDdrwTblRow_class_id ;
extern	GRclassid	OPP_VDrelat_hdr_class_id ;
extern  GRclassid       OPP_GRcontext_class_id ;
extern  GRclassid       OPP_VDcontext_class_id ;
extern	GRclassid	OPP_GRclhdr_class_id ;
extern	GRclassid	OPP_GRsmhdr_class_id ;


//extern  som_objid_to_tag();
/*----------------------------------------------------------------------------*/

	      /* Below lines added by Anand for JTS CR MP 4488 */

%safe
static	IGRboolean	bAddQueryParams=FALSE;
static	IGRlong		maskAdnlQryParam=0;
%endsafe

int VD_GetAdnlQryParams( IGRboolean *bQry, IGRlong *maskQry )
{
    SetProc( VD_GetAdnlQryParams ); Begin

    *bQry	= bAddQueryParams;
    *maskQry	= maskAdnlQryParam;

    End
    return OM_S_SUCCESS;
}

int VD_SetAdnlQryParams( IGRboolean bQry, IGRlong maskQry )
{
    SetProc( VD_SetAdnlQryParams ); Begin

    bAddQueryParams	= bQry;
    maskAdnlQryParam	= maskQry;

    End
    return OM_S_SUCCESS;
}

	      /* Above lines added by Anand for JTS CR MP 4488 */

/*----------------------------------------------------------------------------*/

int VD_CheckObjInList( obj, list1, cnt1, list2, cnt2 )

struct	GRid		obj ;
struct	GRobj_env	*list1 ;
int			cnt1 ;
struct	GRobj_env	*list2 ;
int			cnt2 ;

{
	/*
	 * Check if 'obj' is already defined in either 'list1' or 'list2'
	 * 'list2' can be optional defined.
	 * This function return TRUE when found in list, otherwise FALSE.
	 */
	int		i;

	if( list1 && cnt1 ){
	  for( i=0 ; i<cnt1 ; i++ )
		if( IF_EQ_GRID( obj, list1[i]._grid )) break ;
	  if( i != cnt1 ) return TRUE ;
	}

	if( list2 && cnt2 ){
	  for( i=0 ; i<cnt2 ; i++ )
		if( IF_EQ_GRID( obj, list2[i]._grid )) break ;
	  if( i != cnt2 ) return TRUE ;
	}

	return FALSE ;
}


/*----------------------------------------------------------------------------*/
int VD_CheckObjectFromListOrSet( msg,	setId,
					count, list,
					outCount, outList, option )

long			*msg ;
struct	GRid		*setId ;		/* set of objects. */
int			count ;		
struct	GRobj_env	*list ;
int			*outCount ;
struct	GRobj_env	**outList ;
int			option ;

{
	/*
	 * This function will check if object and object owners are both
	 * in the list. When this occurs, only the owner object will stay
	 * active.
	 * Object of class VDSroot will be accepted. 
	 * The 'option' field allows to filter out only a supgroup of object.
	 * The option list is given above.
	 */

	long			sts = OM_S_SUCCESS ;
	int			i, j,
				suc,
				envProperties = 0 ,
				dirIndex = -1,
				outCnt,
				newCount = 0 ,
				eqCount = 0,
				inCount,
				cpCount,
				wkCount ;
	IGRboolean		Route_Correction = TRUE ;
	IGRboolean		Struct_Helper = TRUE ;
	IGRboolean		Route_Component = TRUE ;
	IGRboolean		Struct_frzBeam = TRUE ;
	IGRboolean		Struct_frzPlate = TRUE ;
	OMuword			classVRCorrection,
				classVRComponent,
				classVSfrzBeam,
				classVSfrzPlate,
				classVShelper;
	struct	ret_struct	retStr ;
	struct	GRid		ownId ;
	struct	GRid		*cpList ;
	struct	GRobj_env	*inList, *wkList , *newList; /* Working List */

	SetProc( VD_CheckObjectFromListOrSet ); Begin

	*msg = MSSUCC ;

	wkList		= NULL ;	inList		= NULL ;
	wkCount		= 0 ;		inCount		= 0 ;
	cpList		= NULL ;	newList		= NULL ;
	cpCount		= 0 ;		newCount	= 0 ;
	outCnt		= 0 ;

	__DBGpr_int(" Additional classes for query?", bAddQueryParams );
	if( bAddQueryParams == TRUE )
	{
	    __DBGpr_com(" Including additional objects for query");
	    __DBGpr_int(" option before mask filter",option );
	    option ^= maskAdnlQryParam;
	    __DBGpr_int(" option after mask filter",option );
	}

	if(( setId ) &&
	   ( vd_$is_ancestry_valid(
                                object  = setId ,
                                classid = OPP_GRgrset_class_id ))){
		/*
		 * get the objects from the set.
		 */
		sts =
		gr$gsinqcount(  msg             = msg,
				senderid        = setId->objid,
				count           = &inCount ,
				object_id       = setId );
		__CheckRC( sts, *msg, "gr$gsinqcount", wrapup );

		if( ! inCount )        goto wrapup ;

		/*
		 * Allocate memory to check.
		 */
		if( !( inList = _MALLOC( inCount, struct GRobj_env )))
			vd_$mem_fail();

		sts =
	        gr$gsget_objects(msg            = msg,
	                        senderid        = setId->objid,
	                        array           = inList,
	                        size            = sizeof(struct GRobj_env) *
								inCount,
	                        count           = &inCount,
	                        object_id       = setId );

	}
	else{
		/*
		 * Input list is given
		 */
		if( ( list ) && ( count )){
			inList		= list ;
			inCount		= count ;

			*outCount	= 0 ;
			*outList	= NULL ;
		}
		else{	goto wrapup ;	}
	}

	/*
	 * Allocate and copy the object in a internal working buffer. The
	 * inList buffer will be used as check list.
	 */
	wkCount	= inCount ;
	if( !( wkList = _MALLOC( inCount, struct GRobj_env )))
		vd_$mem_fail();

	/*
	 * Copy the input list.
	 * Whenever an error occurs we stop processing and return 
	 * original list.
	 * for( i=0 ; i<wkCount ; i++ )	wkList[i] = inList[i] ;
	 */
	OM_BLOCK_MOVE( inList, wkList, wkCount * sizeof( struct GRobj_env ));

#ifdef	vdsDEBUG
	__DBGpr_int(" Number of Objects ", wkCount );
	for( i=0 ; i<wkCount ; i++ )	VD_ShowObj( &wkList[i]._grid );
#endif

	/*
	 * Check if subproducts are active. If so check for the 
	 * classes.
	 */
	sts =
	om$get_classid(	classname	= "VRComponent",
			p_classid	= &classVRComponent );
	if( !( sts&1 )){ Route_Component = FALSE ; }

	sts =
	om$get_classid(	classname	= "VRCorrection",
			p_classid	= &classVRCorrection );
	if( !( sts&1 )){ Route_Correction = FALSE ; }

	sts =
	om$get_classid(	classname	= "VShelper",
			p_classid	= &classVShelper );
	if( !( sts&1 )){ Struct_Helper = FALSE ; }

	sts =
	om$get_classid(	classname	= "VSfrzBeam",
			p_classid	= &classVSfrzBeam );
	if( !( sts&1 )){ Struct_frzBeam = FALSE ; }

	sts =
	om$get_classid(	classname	= "VSfrzPlate",
			p_classid	= &classVSfrzPlate );
	if( !( sts&1 )){ Struct_frzBeam = FALSE ; }

	/*
	 * Check for ownership of the located objects.
	 */
	if( option & VD_K_set_Chk_Owned ){

	    for( i=0 ; i<wkCount ; i++ ){

		/*
		 * Check the object before any action.
		 */
		suc = om$is_objid_valid(objid = wkList[i]._objid,
					osnum = wkList[i]._osnum ) ;
	 	if( !(suc&1)){
		    if( setId ){
                        sts =
                        _VD_SEND_OBJN(  *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		    }
		    wkList[i]._objid = NULL_OBJID ;
		    continue ;
		}
	        if(( Route_Correction )			&&
		   ( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = classVRCorrection ))){
			continue ;
		}

		if(( Struct_frzBeam )			&&
		   ( vd_$is_ancestry_valid(
				object  = & wkList[i]._grid,
				classid = classVSfrzBeam ))){
			continue ;
		}

		if(( Struct_frzPlate )			&&
		   ( vd_$is_ancestry_valid(
				object  = & wkList[i]._grid,
				classid = classVSfrzPlate ))){
			continue ;
		}

#ifdef NOT_NEEDED
		if( vd_$is_ancestry_valid(
				object	= & wkList[i]._grid ,
				classid = OPP_VDSroot_class_id )) continue ;
#endif

		ASget_as_owner( & wkList[i]._grid, &ownId );

		if( IF_NULL_OBJID( ownId.objid )) continue ;

		/*
		 * Check if owner object is in the original list.
		 */
		if( VD_CheckObjInList(	ownId,
					inList, inCount,
					newList, newCount )){
		
		    __DBGpr_obj( "Delete from List ", wkList[i]._grid );

		    if( setId ){
                        sts =
                        _VD_SEND_OBJN(  *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		    }
		    wkList[i]._objid = NULL_OBJID ;
		}
	    }
	}

	/*
	 * Starting from here we need to use the wkList as reference list.
	 * No more the input list.
	 */

	outCnt = 0 ;
	for( i=0 ; i<wkCount ; i++ ){

	    if( IF_NULL_OBJID( wkList[i]._objid )) continue ;

	    /** GRclhdr ************************************************/

	    if(( option & VD_K_set_Chk_Cell ) &&
	       ( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = OPP_GRclhdr_class_id ))){
		  /*
		   * delete the cell object from list.
		   */
		  __DBGpr_obj(" Delete the cell ", wkList[i]._grid );
		  if( setId ){
			sts =
                        _VD_SEND_OBJN( *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		  continue ;
	    }

	    /** GRsmhdr *************************************************/

	    if(( option & VD_K_set_Chk_Symbol ) &&
	       ( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = OPP_GRsmhdr_class_id ))){
	      if( ! (vd_$is_ancestry_valid(
				object	= & wkList[i]._grid,
				classid = OPP_VDrelat_hdr_class_id ))){
		  /*
		   * delete the symbol object from list.
		   */
		  __DBGpr_obj(" Delete the symbol", wkList[i]._grid );
		  if( setId ){
			sts =
                        _VD_SEND_OBJN( *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		  continue ;
	      }
	    }

	    /** VR*Comp -> dangle **************************************/

	    if( ( option & VD_K_set_Chk_Dangle )	&& 
		( Route_Component )			&&
		( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = classVRComponent ))) {

		/*
		 * Check of the object is a dangle ...
		 */
		sts =
		_VD_SEND_OBJN(	wkList[i]._grid,
				NDmacro.ACgive_structure(& suc,
							& dirIndex,
							"comp_code",
							& retStr,
							& wkList[i].mod_env ));
		if(( sts & suc & 1 )		&&
        	   ( retStr.type == text_type ) &&
		   ( strcmp( retStr.var.text_st.text_string,
			     "dangle" ) == 0 )){

		  if( setId ){
                        sts =
                        _VD_SEND_OBJN(  *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		  __DBGpr_obj("Found the dangle ", wkList[i]._grid );
		  continue ;
		}
	    }

	    /** VShelper ***********************************************/

	    if( ( option & VD_K_set_Chk_VShelper )	&&
		( Struct_Helper )			&&
		( vd_$is_ancestry_valid(
				object	= & wkList[i]._grid,
				classid = classVShelper ))){
		/*
		 * Found a  VShelper object.
		 */
		if( setId ){
			sts =
                        _VD_SEND_OBJN(  *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		}
		__DBGpr_obj("Found the VShelper ", wkList[i]._grid );
		continue ;
	    }

	    /** VDrelat_hdr ********************************************/

	    if( ( option & VD_K_set_Chk_RelHdr )	&&
		( vd_$is_ancestry_valid(
				object	= & wkList[i]._grid,
				classid = OPP_VDrelat_hdr_class_id ))){
		/*
		 * Found a  VDrelat_hdr object.
		 */
		struct	GRid	relObj, relList[5] ;
		int		iLen, len=5 ;
		int		del = FALSE ;

		sts =
		_VD_SEND_OBJN(	wkList[i]._grid,
                                ACheader.ACfind_model( msg, &relObj ));
		if( sts&*msg&1 ){
		  sts =
		  _VD_SEND_OBJN(relObj,
                                VDlink.ACget_model_list(msg,len,relList,&len));
		  if( sts&*msg&1 ){
		    /*
		     * Check the type of parent object.
		     * Generation of image objects result in images of the
		     * VSbeamAxis which are support objects and desired.
		     * (Ad) 08/16/95.
		     */
		    for( iLen=0 ; iLen<len ; iLen++ ){

		      if(( Struct_Helper )			&&
			 ( vd_$is_ancestry_valid(object = relList +iLen,
						classid = classVShelper ))){
				del = TRUE ; break ;
		      }
		    }
		    if( del ){
		      if( setId ){
			sts =
                        _VD_SEND_OBJN(  *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		      }
		      __DBGpr_obj("Found the VDrelat_hdr ", wkList[i]._grid );
		      continue ;
		    }
		  } /* VDlink.ACget_model_list */
		} /* ACheader.ACfind_model */
	    }

	    /** VR*Correction *******************************************/

	    if( ( option & VD_K_set_Chk_Correct )	&&
	        ( Route_Correction )			&&
		( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = classVRCorrection ))){

		  sts =
                  vd_$get_components(msg	= msg,
                                grobjId         = & wkList[i]._grid,
                                grobjEnv        = & wkList[i].mod_env,
                                number          = & cpCount,
                                components      = & cpList );

		  if( ! cpCount ) continue ;

		  if( newCount ){
			if( !( newList = _REALLOC(	newList,
							newCount + cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  } else {
			if( !( newList = _MALLOC(	cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  }

		  eqCount = 0;
		  __DBGpr_int(" NUMBER Comp ", cpCount );

		  for( j=0 ; j<cpCount ; j++ ){
		    /*
		     * Check if object all in list.
		     */
		    if( ! VD_CheckObjInList(	cpList[j],
						wkList, outCnt,
						newList, newCount )){
			/*
			 * Add object to list.
			 */
		  	__DBGpr_obj(" Add Comp ", cpList[j] );
			newList[newCount+eqCount]._grid   = cpList[j] ;
			newList[newCount+eqCount].mod_env = wkList[i].mod_env;
			eqCount++ ;

			if( setId ){
                          sts =
                          _VD_SEND_OBJN(*setId,
                                        GRgrset.GSobject_add(msg,
                                                        cpList +j,
                                                        &wkList[i].mod_env,
                                                        &envProperties,
                                                        NULL, NULL ));
			}
		    }
		  }
		  newCount += eqCount ;	/* Only for list needed */
		  _FREE( cpList );
		  cpCount = 0 ;

		  if( setId ){
			sts =
                        _VD_SEND_OBJN(  *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		  __DBGpr_obj("Found the Correction ", wkList[i]._grid );
		  continue ;
	    }

	    /** VDdrw3dVw ************************************************/

	    if( ( option & VD_K_set_Chk_drw3dVw )	&&
		( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = OPP_VDdrw3dVw_class_id ))) {

		  __DBGpr_obj(" Found Section Set Object ", wkList[i]._grid );

		  sts =
		  VDdrw_GetChannelObjects( msg, &wkList[i]._grid, 
						&wkList[i].mod_env,
						VD_O_drw3dObj,
						&cpCount,
						&cpList,
						NULL );
		  __CheckRC( sts, *msg, "VDdrw_GetChannelObjects", wrapup );

		  if( newCount ){
			if( !( newList = _REALLOC(	newList,
							newCount + cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  } else {
			if( !( newList = _MALLOC(	cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  }

		  eqCount = 0;
		  for( j=0 ; j<cpCount ; j++ ){
		    /*
		     * Check if object all in list.
		     */
		    if( ! VD_CheckObjInList(	cpList[j],
						wkList, outCnt,
						newList, newCount )){
			/*
			 * Add object to list.
			 */
			newList[newCount+eqCount]._grid   = cpList[j] ;
			newList[newCount+eqCount].mod_env = wkList[i].mod_env;
			eqCount++ ;

			if( setId ){
			  sts =
			  _VD_SEND_OBJN(*setId,
					GRgrset.GSobject_add(	msg,
							cpList +j,
							&wkList[i].mod_env,
							&envProperties,
							NULL, NULL ));
			}
		    }
		  }
		  newCount += eqCount ;	/* Only for list needed */
		  _FREE( cpList );	cpList = NULL ;
		  cpCount = 0 ;

		  /*
		   * delete the section object from list.
		   */
		  if( setId ){
		    sts =
		    _VD_SEND_OBJN(*setId,
				GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		
		  __DBGpr_obj(" Delete the Section Set ", wkList[i]._grid );
		  continue ;
	    }

	    /** VDdrw2dVw ************************************************/

	    if( ( option & VD_K_set_Chk_drw2dVw )	&&
		( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = OPP_VDdrw2dVw_class_id ))) {

		  __DBGpr_obj(" Found Section Set Object ", wkList[i]._grid );

		  sts =
		  VDdrw_GetChannelObjects( msg, &wkList[i]._grid, 
						&wkList[i].mod_env,
						VD_O_drw2dObj,
						&cpCount,
						&cpList,
						NULL );
		  __CheckRC( sts, *msg, "VDdrw_GetChannelObjects", wrapup );

		  if( newCount ){
			if( !( newList = _REALLOC(	newList,
							newCount + cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  } else {
			if( !( newList = _MALLOC(	cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  }

		  for( j=0 ; j<cpCount ; j++ ){
		    /*
		     * Check if object all in list.
		     */
		    if( ! VD_CheckObjInList(	cpList[j],
						wkList, outCnt,
						newList, newCount )){
			/*
			 * Add object to list.
			 */
			newList[newCount+eqCount]._grid   = cpList[j] ;
			newList[newCount+eqCount].mod_env = wkList[i].mod_env;
			 eqCount++ ;

			if( setId ){
			  sts =
			  _VD_SEND_OBJN(*setId,
					GRgrset.GSobject_add(	msg,
							cpList +j,
							&wkList[i].mod_env,
							&envProperties,
							NULL, NULL ));
			}
		    }
		  }
		  newCount += eqCount ;	/* Only for list needed */
		  _FREE( cpList );	cpList = NULL ;
		  cpCount = 0 ;

		  /*
		   * delete the section object from list.
		   */
		  if( setId ){
		    sts =
		    _VD_SEND_OBJN(*setId,
				GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		
		  __DBGpr_obj(" Delete the Drawing Set ", wkList[i]._grid );
		  continue ;
	    }
	    /********* addition for CR179901680 begins*****************/

	    /** VDdrawing ************************************************/

	    if(vd_$is_ancestry_valid(object  = & wkList[i]._grid,
                                classid = OPP_VDdrawing_class_id )) {

		  __DBGpr_obj(" Found Section Set Object ", wkList[i]._grid );
/*
		  sts = VDGetDrawingObjects(&wkList[i].obj_id,&cpCount,&cpList);
		  if(!(sts&1)) goto wrapup;
*/
                  sts = VDgetDrawingObjects(&wkList[i].obj_id,&cpCount,&cpList);
                  if(!(sts&1)) goto wrapup;
                  __DBGpr_int("cpCount",cpCount);
		  __DBGpr_objlist("cpList",cpCount,cpList);

		  if( newCount ){
			if( !( newList = _REALLOC(	newList,
							newCount + cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  } else {
			if( !( newList = _MALLOC(	cpCount,
							struct GRobj_env )))
				vd_$mem_fail();
		  }

		  for( j=0 ; j<cpCount ; j++ ){
		    /*
		     * Check if object all in list.
		     */
		    if( ! VD_CheckObjInList(	cpList[j],
						wkList, outCnt,
						newList, newCount )){
			/*
			 * Add object to list.
			 */
			newList[newCount+eqCount]._grid   = cpList[j] ;
			newList[newCount+eqCount].mod_env = wkList[i].mod_env;
			 eqCount++ ;

			if( setId ){
			  sts =
			  _VD_SEND_OBJN(*setId,
					GRgrset.GSobject_add(	msg,
							cpList +j,
							&wkList[i].mod_env,
							&envProperties,
							NULL, NULL ));
			}
		    }
		  }
		  newCount += eqCount ;	/* Only for list needed */
		  _FREE( cpList );	cpList = NULL ;
		  cpCount = 0 ;

		  continue ;
	    }
	    /********* addition for CR179901680 ends******************/
	    /** VDdrwGeom,VDgeom ******************************************/

	    if(( option & VD_K_set_Chk_drwGeom ) &&
	       (( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = OPP_VDdrwGm_class_id )) ||
		( vd_$is_ancestry_valid(
				object	= & wkList[i]._grid,
				classid = OPP_VDgeom_class_id )))){
		  /*
		   * delete the Geom Buffer of visualization objects.
		   */
		  __DBGpr_obj(" Delete the Geom Buffer", wkList[i]._grid );
		  if( setId ){
			sts =
                        _VD_SEND_OBJN( *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		  continue ;
	    }

	    /** VDdrwTblHdr **********************************************/

	    if(( option & VD_K_set_Chk_TblHdr ) &&
	       ( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = OPP_VDdrwTblHdr_class_id ))){
		  /*
		   * delete the table header object from list.
		   */
		  __DBGpr_obj(" Delete the table header ", wkList[i]._grid );
		  if( setId ){
			sts =
                        _VD_SEND_OBJN( *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		  continue ;
	    }

	    /** VDdrwTblRow *********************************************/

	    if(( option & VD_K_set_Chk_TblRow ) &&
	       ( vd_$is_ancestry_valid(
                                object  = & wkList[i]._grid,
                                classid = OPP_VDdrwTblRow_class_id ))){
		  /*
		   * delete the table row object from list.
		   */
		  __DBGpr_obj(" Delete the table row", wkList[i]._grid );
		  if( setId ){
			sts =
                        _VD_SEND_OBJN( *setId,
                              GRgrset.GSremove_member(msg, &wkList[i]._grid));
		  }
		  continue ;
	    }

	    /*
	     * Lucky object. Past all the constraints.
	     */
	    wkList[outCnt++] = wkList[i] ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	__DBGpr_int(" Number Aceepted Objects ", outCnt );

	if( ! setId ){
	  if( newCount ){
		/*
		 * See if we need to reallocate memory.
		 */
		__DBGpr_int(" Adding New Objects ", newCount );

		if( newCount + outCnt > inCount ){
			if( !( wkList = _REALLOC(	wkList,
							outCnt + newCount,
							struct GRobj_env )))
				vd_$mem_fail();
		}
		OM_BLOCK_MOVE(	newList, &wkList[outCnt],
				newCount * sizeof( struct GRobj_env ));
		outCnt += newCount ;
	  }
	}
			

	/*
	 * Only when a list is given we return a new list with resulting
	 * objects. When set was given, the set will be returned.
	 */
	if( ! setId ){

#ifdef	vdsDEBUG
	  	__DBGpr_int(" Number Objects ", outCnt );
		for( i=0 ; i<outCnt ; i++ ) VD_ShowObj( & wkList[i]._grid );
#endif

		*outCount	= outCnt ;
		*outList	= wkList ;
		wkList		= NULL ;

	}

	wrapup:

		if( !( sts & *msg & 1 )){
			if( !setId ){	_FREE(	*outList );
					*outList	= NULL ;
					*outCount	= 0 ;
			}
		}

                _FREE( wkList );    wkList = NULL;/*in case of errors*/
                _FREE( newList );   newList = NULL;
                _FREE( cpList );    cpList  = NULL;

		if( setId ) _FREE( inList );

		End
		return sts ;
}

/*----------------------------------------------------------------------------*/

int VD_MakeGRsetOfObject( msg, mdEnv, elmId, elmEnv, setId, setEnv, option )

long			*msg ;
struct	GRmd_env	*mdEnv ;	/* Current ModuleInfo		*/
struct	GRid		*elmId ;	/* Input Object			*/
struct	GRmd_env	*elmEnv ;	/* Input Environment		*/
struct	GRid		*setId ;	/* Set Output Object		*/
struct	GRmd_env	*setEnv ;	/* Set Output Environment	*/
int			option ;
{
	/*
	 * This function will check if object is an graphical set.
	 * If not, the object an graphical set will be made and the
	 * object will be added in this set as one component.
	 *
	 * Option:	For later use....
	 */
	long			sts = OM_S_SUCCESS ;
	int			i,
				envProperties = 0 ;
	struct	GRid		svSet ;

	SetProc( VD_MakeGRsetOfObject ); Begin

	*msg = MSSUCC ;
	i = option ;	/* to ignore compile error. */

	if( vd_$is_ancestry_valid(
			object	= elmId ,
			classid = OPP_GRgrset_class_id )) {

		/*
		 * Copy the object. 
		 */
		*setId	= *elmId ;
		*setEnv	= *elmEnv ;
		goto wrapup ;
	}
	else{
		/*
		 * Create an new set with the object.
		 */
		sts = LCgsinit( mdEnv, setId, &svSet );
		if( !(sts & 1 )){
			/*
			 * Return the input object.
			 */
			*setId  = *elmId ;
			*setEnv = *elmEnv ;
			goto wrapup ;
		}

		/*
		 * Add the object in the list.
		 */
		sts =
		_VD_SEND_OBJN(	*setId,
				GRgrset.GSobject_add(	msg,
							elmId,
							elmEnv,
							&envProperties,
							NULL, NULL ));
	}

	wrapup :
		End ;
		return sts ;
}
/* This function gets the VDdrawing objects for input VDdrawing under the 
 * same VDcontext as the input object - doesnot get all the drawings in view
 */
int VDGetDrawingObjects(struct GRid *drawing,int *outCount,struct GRid **outList)
{
	IGRint retFlag = 0,ii,tmpCount = 0;
	OM_S_CHANSELECT to_misc,to_children;
	OMuint  cnt = 0,childCount;
	GRobjlink       *List = NULL;
	IGRint          sts = OM_S_SUCCESS ;
	struct GRid     *pretList = NULL,*tmpList = NULL;
	struct GRid     contextId,drawingId; 

        sts =
        om$make_chanselect(     channame        = "GRcontext.to_misc",
                                p_chanselect    = &to_misc );
        __CheckRC( sts, 1, "make_chanselect", wrapup );
        sts =
        om$make_chanselect(     channame        = "NDchildren.children",
                                p_chanselect    = &to_children );
        __CheckRC( sts, 1, "make_chanselect", wrapup );

	contextId.objid = NULL_OBJID;
 	sts = VDGetContext(drawing,&contextId,NULL,0,0);
 	if((!(sts&1)) || (contextId.objid == NULL_OBJID)) goto wrapup;
	
	// No. of pretends on the channel
        sts =
        om$get_channel_count(   objid           = contextId.objid,
                                osnum           = contextId.osnum,
                                p_chanselect    = &to_misc,
                                count           = &cnt );
	if((!(sts&1)) || (!cnt)) goto wrapup;

	if( !( *outList = _MALLOC( cnt, struct GRid ))) goto wrapup;
	if( !( List = _MALLOC( cnt, GRobjlink ))) goto wrapup;
	if( !( pretList = _MALLOC( cnt, struct GRid ))) goto wrapup;
	if( !( tmpList  = _MALLOC( cnt, struct GRid ))) goto wrapup;

          sts =
          om$get_channel_objects(objid          = contextId.objid,
                                osnum           = contextId.osnum,
                                p_chanselect    = &to_misc,
                                size            = cnt,
                                list            = List,
                                count           = &cnt );	
	if(!(sts&1)) goto wrapup;
	for(ii=0;ii<cnt;ii++){
		pretList[ii].objid = List[ii].S_objid;
		pretList[ii].osnum = List[ii].osnum;
	}	

	for(ii=0;ii<cnt;ii++){
        	childCount = 0;
        	sts =
        	om$get_channel_count(objid      = pretList[ii].objid,
                                osnum           = pretList[ii].osnum,
                                p_chanselect    = &to_children,
                                count           = &childCount );
		if((!(sts&1)) || (!childCount)) goto wrapup;

          drawingId.objid = NULL_OBJID;
          sts =
          om$get_objid_at_index(objid           = pretList[ii].objid,
                                osnum           = pretList[ii].osnum,
                                p_chanselect    = &to_children,
                                index           = 0,
                                objidaddr       = &drawingId.objid,
                                osnumaddr       = &drawingId.osnum );
          if((!(sts&1)) || (drawingId.objid == NULL_OBJID)) continue;

	  tmpList[tmpCount].objid = drawingId.objid;
	  tmpList[tmpCount++].osnum = drawingId.osnum;
	}

	*outCount = tmpCount;
	for(ii=0;ii<tmpCount;ii++){
		(*outList)[ii].objid = tmpList[ii].objid;
		(*outList)[ii].osnum = tmpList[ii].osnum;
	}
	retFlag = 1;
wrapup:
	_FREE(List); List = NULL;
	_FREE(pretList); pretList = NULL;
	_FREE(tmpList); tmpList = NULL;
	return retFlag;
}
/* This function returns the VDcontext/ACpretend object for an input VDdrawing 
 * flag = 0 (VDcontext), flag = 1, ACpretend
 * chanIndex = 0 (VDdrawing) chanIndex = 1 (VDdrw2d)
 */
int VDGetContext(struct GRid *drwingId,struct GRid *ctxId, struct GRid *pretId ,int flag, int chanIndex) 
{
 	IGRint retFlag = 0;
	OMuint	cnt = 0;
	IGRint          sts = OM_S_SUCCESS ;
	struct GRid	pretendId,contextId;
	OM_S_CHANSELECT to_father,to_listeners;
	GRobjlink               *List = NULL;

	if((!ctxId) && (!pretId)) goto wrapup;

	if(ctxId) ctxId->objid = NULL_OBJID;
	if(pretId) pretId->objid = NULL_OBJID;

        sts =
        om$make_chanselect(     channame        = "NDfather.father",
                                p_chanselect    = &to_father );
        __CheckRC( sts, 1, "make_chanselect", wrapup );
        sts =
        om$make_chanselect(     channame        = "ASsource.listeners",
                                p_chanselect    = &to_listeners );
        __CheckRC( sts, 1, "make_chanselect", wrapup );

        sts =
        om$get_channel_count(   objid           = drwingId->objid,
                                osnum           = drwingId->osnum,
                                p_chanselect    = &to_father,
                                count           = &cnt );
        if((chanIndex == 1) && (cnt < 2)) goto wrapup;
        if( cnt && (sts&1) ){
	  pretendId.objid = NULL_OBJID;
          sts =
          om$get_objid_at_index(objid           = drwingId->objid,
                                osnum           = drwingId->osnum,
                                p_chanselect    = &to_father,
                                index           = chanIndex,
                                objidaddr       = &pretendId.objid,
                                osnumaddr       = &pretendId.osnum );
	  if((!(sts&1)) || (pretendId.objid == NULL_OBJID)) goto wrapup;
	  if(flag == 1)
	  {
		pretId->objid = pretendId.objid;
		pretId->osnum = pretendId.osnum;
		retFlag = 1;
		goto wrapup; 
	  } 
	}
	else goto wrapup;

	cnt = 0;
        sts =
        om$get_channel_count(   objid           = pretendId.objid,
                                osnum           = pretendId.osnum,
                                p_chanselect    = &to_listeners,
                                count           = &cnt );

        if( cnt && (sts&1) ){
          if( !( List = _MALLOC( cnt, GRobjlink ))) goto wrapup;
          sts =
          om$get_channel_objects(objid          = pretendId.objid,
                                osnum           = pretendId.osnum,
                                p_chanselect    = &to_listeners,
                                size            = cnt,
                                list            = List,
                                count           = &cnt );
	}
	else goto wrapup;

	ctxId->objid = List[0].S_objid;
	ctxId->osnum = List[0].osnum;
	
	retFlag = 1;
wrapup:
	_FREE(List); List = NULL;
	return retFlag;
}
/*----------------------------------------------------------------------------*/

// given a VDdrawing object, this function gets other VDdrawings in the view
int VDgetDrawingObjects(struct GRid *drawing,int *outCount,struct GRid **outList)
{
	IGRint retFlag = 0,ii,jj,kk,tmpCount = 0,numCtxs = 0,allocCnt = 0;
	OM_S_CHANSELECT to_misc,to_children;
	OMuint  cnt = 0,childCount;
	IGRlong sts1;
	GRobjlink       *List = NULL, *List1 = NULL;
	IGRint          sts = OM_S_SUCCESS,output = 0 ;
	struct GRid     *pretList = NULL,*tmpList = NULL;
	struct GRid     *contextIds = NULL,drawingId,contextId;
	IGRchar		node_name[50]; 
	IGRchar		**node_names; 
        IGRchar       className[DI_PATH_MAX];
	
        sts =
        om$make_chanselect(     channame        = "GRcontext.to_misc",
                                p_chanselect    = &to_misc );
        __CheckRC( sts, 1, "make_chanselect", wrapup );
        sts =
        om$make_chanselect(     channame        = "NDchildren.children",
                                p_chanselect    = &to_children );
        __CheckRC( sts, 1, "make_chanselect", wrapup );

	// get all the VDcontext objects for that particular drawing view
 	sts = VDGetctxs(drawing,&contextIds,&numCtxs);
 	if(!(sts&1)) goto wrapup;
	__DBGpr_int("Number of VDcontexts ",numCtxs);
/*
	strcpy(node_name,"jayadev");
 	sts = VDctxsetNodName(*drawing,node_name,NULL,NULL);
 	if(!(sts&1)) goto wrapup;
	
 	sts = VDctxgetNodNames(*drawing,&node_names,&contextIds,&numCtxs);
 	if(!(sts&1)) goto wrapup;
	
	for(jj=0; jj<numCtxs; jj++){
	 	__DBGpr_obj("context",contextIds[jj]);
		__DBGpr_str("NodeName",node_names[jj]);
	}
*/
	// get the underlying drawing objects for the above VDcontexts
	for(jj=0; jj<numCtxs; jj++){
		contextId.objid = contextIds[jj].objid;
		contextId.osnum = contextIds[jj].osnum;

		_FREE(List); List = NULL;
		_FREE(pretList); pretList = NULL;
	
		// No. of pretends on the channel
        	sts =
        	om$get_channel_count(   objid           = contextId.objid,
                                osnum           = contextId.osnum,
                                p_chanselect    = &to_misc,
                                count           = &cnt );
		if((!(sts&1)) || (!cnt)) continue;
	
		if( !( List = _MALLOC( cnt, GRobjlink ))) goto wrapup;
		if( !( pretList = _MALLOC( cnt, struct GRid ))) goto wrapup;

          	sts =
          	om$get_channel_objects(objid          = contextId.objid,
                                osnum           = contextId.osnum,
                                p_chanselect    = &to_misc,
                                size            = cnt,
                                list            = List,
                                count           = &cnt );	
		if(!(sts&1)) goto wrapup;
		__DBGpr_obj("Pretend list for VDcontext",contextId);
		for(ii=0;ii<cnt;ii++){
			pretList[ii].objid = List[ii].S_objid;
			pretList[ii].osnum = List[ii].osnum;
		__DBGpr_obj("Pretend",pretList[ii]);
		}
	
		if(!tmpList){
			if(!(tmpList= _MALLOC(cnt,struct GRid )))goto wrapup;
			allocCnt = cnt;
		}else{
			allocCnt += cnt;
			__DBGpr_int("allocCnt",allocCnt);
			if(!(tmpList= _REALLOC(tmpList,allocCnt,struct GRid )))goto wrapup;
		}


		for(ii=0;ii<cnt;ii++){
        		childCount = 0;
        		sts =
        		om$get_channel_count(objid      = pretList[ii].objid,
                                osnum           = pretList[ii].osnum,
                                p_chanselect    = &to_children,
                                count           = &childCount );
			if((!(sts&1)) || (!childCount)){
			__DBGpr_obj("Drawing object missing for pretend ",pretList[ii]);
			 	continue;
			}
/*
          		drawingId.objid = NULL_OBJID;
          		sts =
          		om$get_objid_at_index(objid   = pretList[ii].objid,
                                osnum           = pretList[ii].osnum,
                                p_chanselect    = &to_children,
                                index           = 0,
                                objidaddr       = &drawingId.objid,
                                osnumaddr       = &drawingId.osnum );
          		if((!(sts&1)) || (drawingId.objid == NULL_OBJID)) 
								continue;
	  		tmpList[tmpCount].objid = drawingId.objid;
	  		tmpList[tmpCount++].osnum = drawingId.osnum;
*/
                _FREE(List1); List1 = NULL;
                if( !( List1 = _MALLOC(childCount , GRobjlink ))) goto wrapup;
                sts =
                om$get_channel_objects(objid    = pretList[ii].objid,
                                osnum           = pretList[ii].osnum,
                                p_chanselect    = &to_children,
                                size            = childCount,
                                list            = List1,
                                count           = &childCount );
                if(!(sts&1)) continue;
                for(kk=0; kk<childCount; kk++)
                {
                  className[0] = '\0';
                  sts1 = om$get_classname( objid = List1[kk].S_objid,
                                        osnum = List1[kk].osnum,
                                        classname = className );
                  if(!strcmp(className,"VDdrawing"))
                  {
                        tmpList[tmpCount].objid = List1[kk].S_objid;
                        tmpList[tmpCount++].osnum = List1[kk].osnum;
                  }
                }
		}
	}

	if(tmpCount == 0) goto wrapup;
	if( !( *outList = _MALLOC( tmpCount, struct GRid ))) goto wrapup;
	//*outCount = tmpCount;

	__DBGpr_int("outCount",tmpCount);

	for(ii=0;ii<tmpCount;ii++){

                className[0] = '\0';
                sts1 = om$get_classname( objid = tmpList[ii].objid,
                                        osnum = tmpList[ii].osnum,
                                        classname = className );
                if(strcmp(className,"VDdrawing")) continue;

		(*outList)[output].objid = tmpList[ii].objid;
		(*outList)[output].osnum = tmpList[ii].osnum;
		output++ ;
		__DBGpr_obj("outList",tmpList[ii]);
	}
	*outCount = output;

	retFlag = 1;
wrapup:
	_FREE(List); List = NULL;
	_FREE(List1); List1 = NULL;
	_FREE(contextIds); contextIds = NULL;
	_FREE(pretList); pretList = NULL;
	_FREE(tmpList); tmpList = NULL;
/*
	if(numCtxs!=0){
	  if(node_names){
		  for(jj=0;jj<numCtxs;jj++)
		  {
		    _FREE(node_names[jj]); node_names[jj] = NULL;
		  }
	  }	
	}  
        _FREE(node_names); node_names = NULL;
*/
	__DBGpr_int("End VDgetDrawingObjects retFlag ",retFlag);
	return retFlag;
}

// function to return all the VDcontext objects given an extracted drawing 
// object for a drawing view
int VDGetctxs(struct GRid *drwingId,struct GRid **ctxIds, IGRint *numCtxs) 
{
 	IGRint retFlag = 0;
	IGRint ii,jj,tmpCount = 0;
	OMuint	cnt = 0;
	IGRint          sts = OM_S_SUCCESS ;
	struct GRid	pretendId,contextId,refctxId;
	OM_S_CHANSELECT to_father,to_listeners,to_nested;
	//struct GRid     *tmpList = NULL,tmpId;
	struct GRid     tmpList [1024],tmpId;
	GRobjlink               *List = NULL;
	OMuword		classID;
        IGRmatrix       ref_matrix,test_matrix;
	IGRboolean	mis_match = FALSE;
 	IGRdouble	delta = 0.001;

	// drawing - father - ACpretend - listeners - VDcontext(at index 0)
	//         ------->             ----------->
        sts =
        om$make_chanselect(     channame        = "NDfather.father",
                                p_chanselect    = &to_father );
        __CheckRC( sts, 1, "make_chanselect", wrapup );
        sts =
        om$make_chanselect(     channame        = "ASsource.listeners",
                                p_chanselect    = &to_listeners );
        __CheckRC( sts, 1, "make_chanselect", wrapup );
        sts =
        om$make_chanselect(     channame        = "GRcontext.to_nested_files",
                                p_chanselect    = &to_nested );
        __CheckRC( sts, 1, "make_chanselect", wrapup );

        sts =
        om$get_channel_count(   objid           = drwingId->objid,
                                osnum           = drwingId->osnum,
                                p_chanselect    = &to_father,
                                count           = &cnt );
        if( cnt && (sts&1) ){
	  pretendId.objid = NULL_OBJID;
          sts =
          om$get_objid_at_index(objid           = drwingId->objid,
                                osnum           = drwingId->osnum,
                                p_chanselect    = &to_father,
                                index           = 0,
                                objidaddr       = &pretendId.objid,
                                osnumaddr       = &pretendId.osnum );
	  if((!(sts&1)) || (pretendId.objid == NULL_OBJID)) goto wrapup;
	}
	else goto wrapup;

	cnt = 0;
        sts =
        om$get_channel_count(   objid           = pretendId.objid,
                                osnum           = pretendId.osnum,
                                p_chanselect    = &to_listeners,
                                count           = &cnt );

        if( cnt && (sts&1) ){
          if( !( List = _MALLOC( cnt, GRobjlink ))) goto wrapup;
          sts =
          om$get_channel_objects(objid          = pretendId.objid,
                                osnum           = pretendId.osnum,
                                p_chanselect    = &to_listeners,
                                size            = cnt,
                                list            = List,
                                count           = &cnt );
	}
	else goto wrapup;

  	om$get_classid(
    		objid = List[0].S_objid,
    		osnum = List[0].osnum,
    		p_classid = &classID
  	);
	// expecting a VDcontext object at this stage
	if(classID != OPP_VDcontext_class_id) goto wrapup;

	refctxId.objid = List[0].S_objid;
	refctxId.osnum = List[0].osnum;

	retFlag = VDgetctxmatrix(refctxId,ref_matrix);
	if(!(retFlag &1)){
		printf("\n VDgetctxmatrix failed \n");
		goto wrapup;
	} 
	// got one of the VDcontexts; get the underlying GRcontext and
        // the other VDcontexts from it
	// VDcontext - nest_files - GRcontext - nest_files - all VDcontexts
        //           ------------>            ------------>
	
	cnt = 0;
        sts = om$get_channel_count(objid     	   = List[0].S_objid,
                                   osnum           = List[0].osnum,
                                   p_chanselect    = &to_nested,
                                   count           = &cnt );
	
        if( cnt && (sts&1) ){
	  contextId.objid = NULL_OBJID;
          sts =
          om$get_objid_at_index(objid           = List[0].S_objid,
                                osnum           = List[0].osnum,
                                p_chanselect    = &to_nested,
                                index           = 0,
                                objidaddr       = &contextId.objid,
                                osnumaddr       = &contextId.osnum );
	  if((!(sts&1)) || (contextId.objid == NULL_OBJID)) goto wrapup;
	}
	else goto wrapup;
  	
	om$get_classid(
    		objid = contextId.objid,
    		osnum = contextId.osnum,
    		p_classid = &classID);

	// expecting a GRcontext/VDcontext object at this stage
	if((classID != OPP_GRcontext_class_id) && 
	  (classID != OPP_VDcontext_class_id)) goto wrapup;

	_FREE(List); List = NULL;
	cnt = 0;
        sts = om$get_channel_count(objid     	   = contextId.objid,
                                   osnum           = contextId.osnum,
                                   p_chanselect    = &to_nested,
                                   count           = &cnt );
        if( cnt && (sts&1) ){
          if( !( List = _MALLOC( cnt, GRobjlink ))) goto wrapup;
          sts =
          om$get_channel_objects(objid          = contextId.objid,
                                osnum           = contextId.osnum,
                                p_chanselect    = &to_nested,
                                size            = cnt,
                                list            = List,
                                count           = &cnt );
	}
	else goto wrapup;

	//if( !( tmpList  = _MALLOC( cnt, struct GRid ))) goto wrapup;

	__DBGpr_obj("refctxId",refctxId);

	for(ii=0; ii<cnt; ii++){
		tmpId.objid = List[ii].S_objid;
		tmpId.osnum = List[ii].osnum;
		__DBGpr_obj("VDcontext or GRcontext",tmpId);
	}
	// filter the VDcontexts from the list of objects
	for(ii=0; ii<cnt; ii++){
		om$get_classid(
    			objid = List[ii].S_objid,
    			osnum = List[ii].osnum,
    			p_classid = &classID);
		mis_match = FALSE;
		if(classID == OPP_VDcontext_class_id){
		  if((List[ii].S_objid == refctxId.objid) &&
			(List[ii].osnum == refctxId.osnum))
		  {
			tmpList[tmpCount].objid = List[ii].S_objid;
			tmpList[tmpCount].osnum = List[ii].osnum;
			tmpCount++; 
		  }
		  else
		  {
			tmpId.objid = NULL_OBJID;
			tmpId.objid = List[ii].S_objid;
			tmpId.osnum = List[ii].osnum;

			__DBGpr_obj("object is VDcontext",tmpId);
			retFlag = VDgetctxmatrix(tmpId,test_matrix);
			if(!(retFlag &1)){
				printf("\n VDgetctxmatrix failed \n");
				goto wrapup;
			}
 			for(jj=0;jj<16;jj++){
    				if(fabs(ref_matrix[jj]-test_matrix[jj]) > delta)
				{
					 mis_match = TRUE; 
				}
			}
			if(!mis_match){ 
			__DBGpr_obj("matching VDcontext",tmpId);
				tmpList[tmpCount].objid = List[ii].S_objid;
				tmpList[tmpCount].osnum = List[ii].osnum; 
				tmpCount++; 
			}		
		  }
		}
	}
	__DBGpr_com("Final VDcontext list after filtering for the same matrix");
	if( !( *ctxIds = _MALLOC( tmpCount, struct GRid ))) goto wrapup;

	__DBGpr_int("tmpCount",tmpCount);
	__DBGpr_objlist("tmpList",tmpCount,tmpList);
	
	*numCtxs = tmpCount;
	for(ii=0;ii<tmpCount;ii++){
		(*ctxIds)[ii].objid = tmpList[ii].objid;
		(*ctxIds)[ii].osnum = tmpList[ii].osnum;
	}
	
	retFlag = 1;
wrapup:
	_FREE(List); List = NULL;
	//_FREE(tmpList); tmpList = NULL;
	__DBGpr_int("End VDgetctxs retFlag",retFlag);
	return retFlag;
}

// function to get model objects for VDdrawing and visualization objects
// if chanIndex == 0 VDdrawing object (created from extract drawing)
// if chanIndex == 1 VDdrw2d   objec  (created from visualization process)

int VDgetModelObjs(struct GRid drwingId[],IGRint drwCnt,struct GRid modObj[],IGRint chanIndex) 
{
 	IGRint retFlag = 0;
	IGRint ii;
	OMuint	cnt = 0;
	IGRint          sts = OM_S_SUCCESS ;
	struct GRid	pretendId;
	OM_S_CHANSELECT to_father,to_listeners;
	GRobjlink       *List = NULL;

	__DBGpr_com("VDgetModelObjs begin");
	// drawing - father - ACpretend - listeners - Model Object
	//         ------->             ----------->
        sts =
        om$make_chanselect(     channame        = "NDfather.father",
                                p_chanselect    = &to_father );
        __CheckRC( sts, 1, "make_chanselect", wrapup );
        sts =
        om$make_chanselect(     channame        = "ASsource.listeners",
                                p_chanselect    = &to_listeners );
        __CheckRC( sts, 1, "make_chanselect", wrapup );

	for(ii=0;ii<drwCnt;ii++){
        sts =
        om$get_channel_count(   objid           = drwingId[ii].objid,
                                osnum           = drwingId[ii].osnum,
                                p_chanselect    = &to_father,
                                count           = &cnt );
	__DBGpr_int("chanCount to_father",cnt);
	
	// VDdrw2d has ACrg_collector and pretends
	// VDdrawing has only pretend

	if(chanIndex == 1)
		if(cnt<2) goto wrapup;

        if( cnt && (sts&1) ){
	  pretendId.objid = NULL_OBJID;
          sts =
          om$get_objid_at_index(objid           = drwingId[ii].objid,
                                osnum           = drwingId[ii].osnum,
                                p_chanselect    = &to_father,
                                index           = chanIndex,
                                objidaddr       = &pretendId.objid,
                                osnumaddr       = &pretendId.osnum );
	  if((!(sts&1)) || (pretendId.objid == NULL_OBJID)) goto wrapup;
	}
	else{ 
		// failed to find the model object for the drawing
		__DBGpr_com("failed to find model obj for drawing cnt<2");
		modObj[ii].objid = NULL_OBJID;
		modObj[ii].osnum = 2;
		continue;
	}

	cnt = 0;
        sts =
        om$get_channel_count(   objid           = pretendId.objid,
                                osnum           = pretendId.osnum,
                                p_chanselect    = &to_listeners,
                                count           = &cnt );
	if(cnt<2) // should have VDcontext and model objects
	{ 
		// failed to find the model object for the drawing
		__DBGpr_com("failed to find model obj for drawing cnt<2");
		modObj[ii].objid = NULL_OBJID;
		modObj[ii].osnum = 2;
		continue;
	}
	__DBGpr_int("chanCount to_listeners",cnt);
        if( cnt && (sts&1) ){
          if( !( List = _MALLOC( cnt, GRobjlink ))) goto wrapup;
          sts =
          om$get_channel_objects(objid          = pretendId.objid,
                                osnum           = pretendId.osnum,
                                p_chanselect    = &to_listeners,
                                size            = cnt,
                                list            = List,
                                count           = &cnt );

		modObj[ii].objid = List[1].S_objid;
		modObj[ii].osnum = List[1].osnum;
	}
	else{ 
		// failed to find the model object for the drawing
		__DBGpr_com("failed to find model object for drawing");
		modObj[ii].objid = NULL_OBJID;
		modObj[ii].osnum = 2;
	}
	}
	// Done
	retFlag = 1;
wrapup:
	_FREE(List); List = NULL;
	__DBGpr_int("End VDgetModelObjs retFlag ",retFlag);
	return retFlag;
}
/*----------------------------------------------------------------------------*/

/* This function returns the matrix associted with a context object  
 */ 
IGRint VDgetctxmatrix(struct GRid ctx,IGRmatrix matrix)
{
  IGRint retFlag = 0,ii;
  IGRlong status,loc_msg;
  IGRshort        mx_type, flag;
  GRspacenum      ref_osnum;
  struct GRid     ctx_id;

   status = om$send( msg = message GRcontext.GRgetinstance
                    (&loc_msg,&mx_type,matrix,&ref_osnum,
                     &flag,&ctx_id),
                senderid = NULL_OBJID,
                targetid = ctx.objid,
                targetos = ctx.osnum);
   if(!(status&loc_msg&1))
   {
	__DBGpr_obj("GRcontext.GRgetinstance failed for",ctx);
	goto wrapup;
   }
	
	__DBGpr_obj("VDcontext",ctx);
#ifdef DEBUG
        pr_mat( "GRcontext.GRgetinstance.matrix", 4, 4, matrix );
#endif

   retFlag = 1;
wrapup:
return retFlag;
}
/* This function sets the supplied nodename to all the VDcontext objects 
 * related to the drawing view supplied by the drwId; also the number of 
 * VDcontext objects in the drawing view can be retrieved (for VDdrawings)
 */

IGRint VDctxsetNodName(struct GRid drwId, IGRchar *node_name, struct GRid **vdctxList, IGRint *vdctxCnt)
{
  IGRint retFlag = 0,ii,numCtxs = 0;
  IGRint          sts = OM_S_SUCCESS ;
  struct GRid     *contextIds = NULL,vdctxId; 
  IGRlong status, msg;

  if(node_name ==  NULL) goto wrapup;
  if(drwId.objid == NULL_OBJID) goto wrapup;

  // get all the VDcontext objects for the drawing view which has drwId
 	sts = VDGetctxs(&drwId,&contextIds,&numCtxs);
 	if(!(sts&1)) goto wrapup;
	if(numCtxs == 0){
		printf("\n VDcontext objects not found to VDctxsetNodName \n");
		goto wrapup;
	}
	if(vdctxList){
		*vdctxCnt  = numCtxs;
		*vdctxList = _MALLOC(numCtxs,struct GRid);
		for(ii=0;ii<numCtxs;ii++){
			(*vdctxList)[ii].objid = contextIds[ii].objid;
			(*vdctxList)[ii].osnum = contextIds[ii].osnum;
        	}
	}

	for(ii=0;ii<numCtxs;ii++){
		vdctxId.objid = contextIds[ii].objid;
		vdctxId.osnum = contextIds[ii].osnum;

   		status =om$send(msg= message VDcontext.VDset_osname(node_name),
                    	senderid = NULL_OBJID,
                    	targetid = vdctxId.objid,
                    	targetos = vdctxId.osnum);
        	if(!(status&1)){
         		printf("\n VDcontext.VDset_osname failed \n");
         		goto wrapup;
        	}
	}
  // Done
  retFlag = 1;
wrapup:
__DBGpr_int("VDctxsetNodName retFlag",retFlag);
_FREE(contextIds); contextIds = NULL;
return retFlag;
}
/* This function gets the nodename of all the VDcontext objects(for VDdrawings) 
 * related to the drawing view supplied by the drwId; list of VDcontexts and
 * count is also the optional output
 */

IGRint VDctxgetNodNames(struct GRid drwId, IGRchar ***node_names, struct GRid **vdctxList, IGRint *numctxs)
{
  IGRint retFlag = 0,ii,numCtxs = 0;
  IGRint          sts = OM_S_SUCCESS ;
  struct GRid     *contextIds = NULL,vdctxId; 
  IGRlong status, msg;
  IGRchar	  node_name[256];

  if(drwId.objid == NULL_OBJID) goto wrapup;

  // get all the VDcontext objects for the drawing view which has drwId
 	sts = VDGetctxs(&drwId,&contextIds,&numCtxs);
 	if(!(sts&1)) goto wrapup;
	if(numCtxs == 0){
		printf("\n VDcontext objects not found to VDctxgetNodName \n");
		goto wrapup;
	}
	if(vdctxList){
		*numctxs = numCtxs;
		*vdctxList = _MALLOC(numCtxs,struct GRid);
		for(ii=0;ii<numCtxs;ii++){
			(*vdctxList)[ii].objid = contextIds[ii].objid;
			(*vdctxList)[ii].osnum = contextIds[ii].osnum;
        	}
	}

	*node_names = _MALLOC(numCtxs, IGRchar *);

	for(ii=0;ii<numCtxs;ii++){
		vdctxId.objid = contextIds[ii].objid;
		vdctxId.osnum = contextIds[ii].osnum;

   		status =om$send(msg= message VDcontext.VDget_osname(node_name),
                    	senderid = NULL_OBJID,
                    	targetid = vdctxId.objid,
                    	targetos = vdctxId.osnum);
        	if(!(status&1)){
         		printf("\n VDcontext.VDset_osname failed \n");
         		goto wrapup;
        	}
		(*node_names)[ii] = _MALLOC((strlen(node_name)+1), IGRchar);
		strcpy((*node_names)[ii], node_name);
		__DBGpr_obj("VDcontext",vdctxId);
		__DBGpr_str("node_name",node_name);
	}
  // Done
  retFlag = 1;
wrapup:
__DBGpr_int("VDctxgetNodName retFlag",retFlag);
_FREE(contextIds); contextIds = NULL;
return retFlag;
}

/* Function to add/modify attributes to the VDdrw2d ,
 * or VDdrw3d or (node_path for)VDdrw2dVw object; the attribute name, value,
 * and type are inputs; collector (0 - parent ACrg and 1 - foot ACrg);
 * (chnIndex = 0, 1, 2 ) indicate ACrg collector index in the parent/feet list
 */

IGRint VDaddAttr(struct GRid drwObj, struct ACrg_coll list_att, IGRint collector, IGRint chnIndex)
{
  IGRint retFlag = 0,ii;
  struct GRid colID;
  IGRint sts = OM_E_INVARG,colInfo = VDCHN_IDX_PARENT;
  IGRlong msg;

  colID.objid = NULL_OBJID;

  if(collector == 0) colInfo = VDCHN_IDX_PARENT;
  else if(collector == 1) colInfo = VDCHN_IDX_TO_COMPONENTS;
  
  // Get the collector info
  vdchn$Get2(objID  = &drwObj,
           chnIDx = colInfo,
           nth    = chnIndex,
           outID  = &colID );
  if(colID.objid == NULL_OBJID) goto wrapup;

  sts =
  om$send(msg = message ACrg_collect.ACmod_list_attribute(&msg,
                               1, &list_att),
          senderid = NULL_OBJID,
         targetid = colID.objid,
         targetos = colID.osnum);
 if(!(sts&msg&1)){

	sts =
	om$send(msg = message ACrg_collect.ACadd_list_attribute
  	                       		(&msg, 1, &list_att),
       			       senderid = NULL_OBJID,
       			       targetid = colID.objid,
              		       targetos = colID.osnum);
  }
  if(!(sts&msg&1)) goto wrapup;
  retFlag = 1;
wrapup:
__DBGpr_int("VDaddAttr retFlag",retFlag);
return retFlag;
}
/* The following is the function to get the occurence attribute from VDdrw2d 
 * or VDdrw3d or (node_path for)VDdrw2dVw object; the attribute name, value,
 * and type are inputs; collector (0 - parent ACrg and 1 - foot ACrg);
 * (chnIndex = 0, 1, 2 ) indicate ACrg collector index in the parent/feet list
 * This function currently handles only the text attributes
 */

IGRint VDgetAttr(struct GRid drwObj, GRname attr_name, GRname attr_value, IGRint attr_type, IGRint collector, IGRint chnIndex)
{
  IGRint retFlag = 0;
  struct GRid colID;
  struct ACrg_coll list_att[20];
  int    numAtt,index,ii,text_len = 0;
  IGRint sts = OM_E_INVARG,colInfo = VDCHN_IDX_PARENT;
  IGRlong msg;
 
 
  if(collector == 0) colInfo = VDCHN_IDX_PARENT;
  else if(collector == 1) colInfo = VDCHN_IDX_TO_COMPONENTS;

  colID.objid = NULL_OBJID;
  
  // Get the collector info
  vdchn$Get2(objID  = &drwObj,
           chnIDx = colInfo,
           nth    = chnIndex,
           outID  = &colID );
  if(colID.objid == NULL_OBJID) goto wrapup;

  numAtt = 0;
  sts = om$send(msg = message
        ACrg_collect.AClist_attribute(&msg,
                                      20, 
                                      list_att,
                                      &numAtt),
        senderid = NULL_OBJID,
        targetid = colID.objid,
        targetos = colID.osnum);

  if(!(sts&msg&1)) goto wrapup;
  __DBGpr_int("Num Attrs for parent collector",numAtt);


  for(ii=0;ii<numAtt;ii++){
    if(list_att[ii].desc.type == AC_ATTRIB_TEXT){
	if(!strcmp(list_att[ii].name,attr_name))
	{
   		strcpy(attr_value, list_att[ii].desc.value.att_txt);
   		retFlag = 1;
   		goto wrapup;
   	}
    }
  }
  retFlag = 1;
wrapup:
__DBGpr_int("VDdrwgetOccAttr retFlag",retFlag);
return retFlag;
}

/* This function is interfaced by vd$review_drawing macro */
IGRint VDreviewDrawing(struct PrcInfo *curList, int curCnt, struct GRobj_env *newList, int newCnt, struct PrcInfo **outList, int *outCnt)
{
  IGRint 	retFlag = 0,ret,tmpCount = 0,ii,jj;
  IGRlong 	sts, msg, isConsumed = 0;
  struct GRobj_env   childEnv; 	
  OMuword   	classID;
  IGRboolean    foundFlag = 0;
  OMuint 	*tag,Tag;
  OMuword 	*version,Version;
  GRname        *modNames = NULL; // names of the model objs in newList
  IGRchar       className[DI_PATH_MAX];

  if((!curList) || (curCnt == 0) || (!newList) || (newCnt == 0)) goto wrapup;

 
  tag     = _MALLOC(curCnt,OMuint); 
  version = _MALLOC(curCnt,OMuword); 
  modNames= _MALLOC(newCnt,GRname); 

  for(ii=0; ii<newCnt; ii++)
  {
    modNames[ii][0] = '\0';
    ret = VDgetOccName(newList[ii].obj_id,modNames[ii]);
    if((!(ret&1)) || modNames[ii][0] == '\0')
	__DBGpr_obj("failed VDgetOccName for",newList[ii].obj_id);	

  }

  *outList = _MALLOC((curCnt+newCnt), struct PrcInfo);
  features = _MALLOC(curCnt, struct GRobj_env);
  featState= _MALLOC(curCnt, IGRint);
  featCount= 0;

  for(ii=0; ii<(curCnt+newCnt); ii++){
	(*outList)[ii].model.obj_id.objid = NULL_OBJID;
	(*outList)[ii].model.obj_id.osnum = 2;
	(*outList)[ii].modelNew.obj_id.objid = NULL_OBJID;
	(*outList)[ii].modelNew.obj_id.osnum = 2;
  }


  // process the curList and decide the state of the parent (processed, ...)

    
    // debug stuff

__DBGpr_com("before VDprocCurList ");
	retFlag = VDprocCurList(curList,curCnt,tag,version,modNames,newList,newCnt);
 	if(!(retFlag&1)){
		__DBGpr_com("Failed in VDprocCurList ");
		goto wrapup;
	}
	
__DBGpr_com("after VDprocCurList ");
	__DBGpr_com("+++++++++++++++++++++++++++++++++++++++++++++++");
	__DBGpr_int("No. of elements in curList",curCnt);
  	for(ii=0; ii<curCnt; ii++){
		__DBGpr_int("Attributes of element ",ii);
		__DBGpr_obj("Drawing object",curList[ii].drwtbl.obj_id);
		__DBGpr_int("Process ",curList[ii].process);
		__DBGpr_obj("Model Object",curList[ii].model.obj_id);
		__DBGpr_obj("New Model Obj",curList[ii].modelNew.obj_id);
	}
	__DBGpr_com("+++++++++++++++++++++++++++++++++++++++++++++++");
        __DBGpr_com("Grabbing feature objects");
        for(ii=0; ii<curCnt; ii++){
                className[0] = '\0';
                sts = om$get_classname( objid = curList[ii].model.obj_id.objid,
                                        osnum = curList[ii].model.obj_id.osnum,
                                        classname = className );
                if((!strcmp(className,"VLmrkLine")) ||
                   (!strcmp(className,"VLwatLine")))
                {
                  if(curList[ii].process == MODIFY)
                  {
                        features[featCount] = curList[ii].drwtbl;
                        featState[featCount]= MODIFY;
                        featCount ++;
                  }
                }
        }
        __DBGpr_int("No. of features",featCount);
        for(ii=0; ii<curCnt; ii++) __DBGpr_obj("Features",features[ii].obj_id);

	__DBGpr_int("New List of Objs count",newCnt);
  	for(jj=0; jj<newCnt; jj++){
		__DBGpr_int("Object",jj);
		__DBGpr_obj("[id,os]",newList[jj].obj_id);
	}
	__DBGpr_com("+++++++++++++++++++++++++++++++++++++++++++++++");

  // start comparing each model obj in newList with all those in the current 
  // list and fill the output list accordingly
  for(jj=0; jj<newCnt; jj++){
	foundFlag = 0;
	
	// check if the new list object is not in the current list
	__DBGpr_obj("checking for newList object",newList[jj].obj_id);

	for(ii=0;ii<curCnt; ii++){
	  if(((newList[jj].obj_id.objid == curList[ii].model.obj_id.objid) &&
	      (newList[jj].obj_id.osnum == curList[ii].model.obj_id.osnum))
	      ||
	      ((newList[jj].obj_id.objid == curList[ii].modelNew.obj_id.objid)&&
	      (newList[jj].obj_id.osnum == curList[ii].modelNew.obj_id.osnum)))
	  {
		foundFlag =1;
		__DBGpr_obj("Found newList obj in curList",newList[jj].obj_id);
	  }
        }
	if(!foundFlag){
		   (*outList)[tmpCount].model.obj_id = newList[jj].obj_id;
		   (*outList)[tmpCount].model.mod_env = newList[jj].mod_env;
		   (*outList)[tmpCount].process      = NEW_MODEL;
		   __DBGpr_obj("NEW_MODEL",(*outList)[tmpCount].model.obj_id);
		   (*outList)[tmpCount].drwtbl.obj_id.objid  = NULL_OBJID;
		   (*outList)[tmpCount].drwtbl.obj_id.osnum  = 2;
		   (*outList)[tmpCount].pretend.objid  = NULL_OBJID;
		   (*outList)[tmpCount].pretend.osnum  = 2;
		   tmpCount++;
		   continue;

	}


	foundFlag = 0;
	
	for(ii=0;ii<curCnt; ii++){
	  switch(curList[ii].process){

	    case CONNECT :

	      if((newList[jj].obj_id.objid == curList[ii].modelNew.obj_id.objid)	      &&
	      (newList[jj].obj_id.osnum == curList[ii].modelNew.obj_id.osnum))
		{
		   __DBGpr_com("case CONNECT");
		   __DBGpr_obj("NewList",newList[jj].obj_id);

		   (*outList)[tmpCount].model.obj_id = curList[ii].model.obj_id;
		   (*outList)[tmpCount].modelNew.obj_id = newList[jj].obj_id;
		   (*outList)[tmpCount].modelNew.mod_env = newList[jj].mod_env;
		   (*outList)[tmpCount].process      = CONNECT;
		   (*outList)[tmpCount].application  = curList[ii].application;
		   (*outList)[tmpCount].drwtbl.obj_id= curList[ii].drwtbl.obj_id;
		   (*outList)[tmpCount].pretend = curList[ii].pretend;
		   tmpCount++;
		   foundFlag = 1;
		}

				break;

		case MIGRATE :
	      if((newList[jj].obj_id.objid == curList[ii].modelNew.obj_id.objid)	      &&
	      (newList[jj].obj_id.osnum == curList[ii].modelNew.obj_id.osnum))
		{
		   __DBGpr_com("case MIGRATE");
		   __DBGpr_obj("NewList",newList[jj].obj_id);

		   (*outList)[tmpCount].model.obj_id = curList[ii].model.obj_id;
		   (*outList)[tmpCount].modelNew.obj_id = newList[jj].obj_id;
		   (*outList)[tmpCount].modelNew.mod_env = newList[jj].mod_env;
		   (*outList)[tmpCount].process      = MIGRATE;
		   (*outList)[tmpCount].application  = curList[ii].application;
		   (*outList)[tmpCount].drwtbl.obj_id= curList[ii].drwtbl.obj_id;
		   (*outList)[tmpCount].pretend = curList[ii].pretend;
		   tmpCount++;
		   foundFlag = 1;
		}

				break;
		case MODIFY :
	      if((newList[jj].obj_id.objid == curList[ii].model.obj_id.objid)	      		&&
	      (newList[jj].obj_id.osnum == curList[ii].model.obj_id.osnum))
		{
		   __DBGpr_com("case MODIFY");
		   __DBGpr_obj("NewList",newList[jj].obj_id);

		  som_objid_to_tag(newList[ii].obj_id.osnum,
				   newList[ii].obj_id.objid,
				   &Tag,
				   &Version,NULL,NULL,NULL,NULL);

		  __DBGpr_int("Old tag",tag[ii]);
		  __DBGpr_int("Old version",version[ii]);
		  __DBGpr_int("New tag",Tag);
		  __DBGpr_int("New Version",Version);
                className[0] = '\0';
                sts = om$get_classname( objid = curList[ii].model.obj_id.objid,
                                        osnum = curList[ii].model.obj_id.osnum,
                                        classname = className );
                if((Tag != tag[ii]) || (Version != version[ii]) ||
                   !(strcmp(className,"VSsubPlate")))
		{
		   (*outList)[tmpCount].model.obj_id = curList[ii].model.obj_id;
		   (*outList)[tmpCount].model.mod_env=curList[ii].model.mod_env;
		   (*outList)[tmpCount].process      = MODIFY;
		   (*outList)[tmpCount].application  = curList[ii].application;
		   (*outList)[tmpCount].drwtbl.obj_id= curList[ii].drwtbl.obj_id;
		   (*outList)[tmpCount].pretend = curList[ii].pretend;
		   tmpCount++;
		   foundFlag = 1;
	           break;
		}
		else curList[ii].process = UNCHANGED;
		}

	    case UNCHANGED :
	      if((newList[jj].obj_id.objid == curList[ii].model.obj_id.objid)	      		&&
	      (newList[jj].obj_id.osnum == curList[ii].model.obj_id.osnum))
		{
		   __DBGpr_com("case UNCHANGED");
		   __DBGpr_obj("NewList",newList[jj].obj_id);

		   (*outList)[tmpCount].model.obj_id = curList[ii].model.obj_id;
		   (*outList)[tmpCount].model.mod_env=curList[ii].model.mod_env;
		   (*outList)[tmpCount].process      = UNCHANGED;
		   (*outList)[tmpCount].application  = curList[ii].application;
		   (*outList)[tmpCount].drwtbl.obj_id= curList[ii].drwtbl.obj_id;
		   (*outList)[tmpCount].pretend = curList[ii].pretend;
		   tmpCount++;
		   foundFlag = 1;
		}

				break;
	  }
	  if(foundFlag) break; // break out of the inner for loop
	}
  }
	__DBGpr_com("+++++++++++++++++++++++++++++++++++++++++++++++");
	__DBGpr_int("No. of elements in outList (intermediate)",tmpCount);
  	for(ii=0; ii<tmpCount; ii++){
		__DBGpr_int("Attributes of element ",ii);
		__DBGpr_obj("Drawing object",(*outList)[ii].drwtbl.obj_id);
		__DBGpr_int("Process ",(*outList)[ii].process);
		__DBGpr_obj("Model Object",(*outList)[ii].model.obj_id);
		__DBGpr_obj("New Model Obj",(*outList)[ii].modelNew.obj_id);
	}
	__DBGpr_com("+++++++++++++++++++++++++++++++++++++++++++++++");
  // fill the drawings to be deleted at the end 
  for(ii=0;ii<curCnt; ii++){

	if(curList[ii].process == DELETE){
		(*outList)[tmpCount].model.obj_id.objid = NULL_OBJID;
		(*outList)[tmpCount].modelNew.obj_id.objid = NULL_OBJID;
		(*outList)[tmpCount].drwtbl.obj_id = curList[ii].drwtbl.obj_id;
		(*outList)[tmpCount].process = DELETE;
		tmpCount ++;
	}
  }
	*outCnt = tmpCount;

	__DBGpr_com("+++++++++++++++++++++++++++++++++++++++++++++++");
	__DBGpr_int("No. of elements in outList(final)",*outCnt);
  	for(ii=0; ii<*outCnt; ii++){
		__DBGpr_int("Attributes of element ",ii);
		__DBGpr_obj("Drawing object",(*outList)[ii].drwtbl.obj_id);
		__DBGpr_int("Process ",(*outList)[ii].process);
		__DBGpr_obj("Model Object",(*outList)[ii].model.obj_id);
		__DBGpr_obj("New Model Obj",(*outList)[ii].modelNew.obj_id);
	}
	__DBGpr_com("+++++++++++++++++++++++++++++++++++++++++++++++");
  
  retFlag = 1;
wrapup:
__DBGpr_int("VDreviewDrawing retFlag",retFlag);
	_FREE(tag); tag = NULL;
	_FREE(version); version = NULL;
	_FREE(modNames);modNames= NULL;
return retFlag;
}

IGRstat VDfindAndExtract(struct GRobj_env plate, struct GRid context)
{
  IGRstat retFlag = 0;
  IGRlong status,msg,sts;
  IGRint                  i,ii,nbline=0;
  IGRint obj_level[32];
  IGRdouble               exp_factor;
  GRclassid               classids[7];
  GRrange                 range, new_range;
  struct GRobj_env        *lines=NULL, gensolOE;
  struct GRmd_env         md_env,modEnv;
  BSrc            rc;
  IGRshort        four=4, trs_type;
  IGRdouble       ctx_matrix[16],trs_matrix[16];
  double point[3],vector[3];
  struct IGRlbsys        obj_lbs;
  struct GRobj_env pretendOE;
  struct GRid as_grid;
  struct PrcInfo prcInfo;
  OMuword    classVLmrkLine,classVLwatLine;
 
  if(context.objid == NULL_OBJID) goto wrapup;
  if(plate.obj_id.objid == NULL_OBJID) goto wrapup;
  
  __DBGpr_com("VDfindAndExtract begin");
  
	sts =
	om$get_classid(	classname	= "VLmrkLine",
			p_classid	= &classVLmrkLine );
	if( !( sts&1 )){ UI_status("Loft not loaded"); goto wrapup; }
	sts =
	om$get_classid(	classname	= "VLwatLine",
			p_classid	= &classVLwatLine );
	if( !( sts&1 )){ UI_status("Loft not loaded"); goto wrapup; }

  gr$get_module_env(buffer = &md_env );
  ex$get_cur_mod( id    = &md_env.md_id.objid,
		  osnum = &md_env.md_id.osnum );
  
  vdobj$GetFoot(  objOE    = &plate,
		  footName = "plate",
		  footOE   = &gensolOE );
  if( gensolOE.obj_id.objid == NULL_OBJID )
    {
      vdobj$GetFoot(  objOE    = &plate,
		      footName = "",
		      footOE   = &gensolOE );
      if( gensolOE.obj_id.objid == NULL_OBJID ) goto wrapup;
    }
  __DBGpr_obj("Graphic Object ", gensolOE.obj_id );
  
  vd_$getRangeOfComposite( msg       = &msg,
			  composite = &gensolOE,
			  range     = range       );

  classids[0] = classVLmrkLine; 
  classids[1] = classVLwatLine; 

  exp_factor = 0.05;
  
  for(i=0;i<3;i++)
    new_range[i] = ((1.0+exp_factor)*range[i]) - (exp_factor*range[i+3]);
  
  for(i=0;i<3;i++)
    new_range[i+3] = -(exp_factor*range[i]) + ((1.0+exp_factor)*range[i+3]);
  
  sts = VD_findall_objects_in_range( new_range, 2, classids, TRUE, md_env, &nbline, &lines );
  if(!(sts&msg&1)) goto wrapup;
  __DBGpr_int("Number of lines returned ", nbline );
  if( nbline == 0 ) goto wrapup;
  for(i=0; i<nbline; i++) __DBGpr_obj("feature line",lines[i].obj_id);
  
  // do extract drawing for each feature object
  for(i=0; i<nbline; i++)
    {
      
      MAidmx( &msg, trs_matrix) ;
      MAidmx( &msg, ctx_matrix) ;
      
      retFlag = VDgetctxmatrix(context,ctx_matrix);
      if(!(retFlag &1)){
	__DBGpr_obj("VDgetctxmatrix failed for",context);
	goto wrapup;
      }
      
      MAmulmx ( &rc, &four, &four, &four, lines[i].mod_env.md_env.matrix, ctx_matrix, trs_matrix);
      MAtypemx( &rc, trs_matrix, &trs_type);
      
      modEnv = lines[i].mod_env;
      for(ii=0; ii<16; ii++) modEnv.md_env.matrix[ii] = trs_matrix[ii];
      modEnv.md_env.matrix_type = trs_type;
      
      __DBGpr_mat(" feature matrix ", lines[i].mod_env.md_env.matrix);
      __DBGpr_mat(" context matrix ", ctx_matrix);
      __DBGpr_mat(" transformation matrix ", trs_matrix);
      as$make_source( go_grid         = lines[i].obj_id,
		      mod_env         = &modEnv,
		      as_grid         = &as_grid ) ;
      if(as_grid.objid == NULL_OBJID)
        {
          __DBGpr_obj("make_source failed on",lines[i].obj_id);
          continue ;
        }
      prcInfo.model = lines[i];
      prcInfo.pretend = as_grid;
      
      retFlag = VDextrDrawing(&prcInfo,context);
      if(!(retFlag&1))
        {
          __DBGpr_obj("fail VDextrDrawing for",prcInfo.model.obj_id);
          continue ;
        }
      __DBGpr_obj("new feature object",prcInfo.model.obj_id);
      __DBGpr_obj("extracted VDdrawing object",prcInfo.drwtbl.obj_id);
    }
  
  
  retFlag = 1;
 wrapup:
  _FREE(lines); lines = NULL;
  __DBGpr_int("VDfindAndExtract retFlag",retFlag);
  return retFlag;
}

/* Features line extraction function for drawings */
IGRstat VDdrawingExtractFeatures(struct GRid refID,struct PrcInfo procList[],int procCnt)
{
  IGRstat retFlag = 0, ret,sts;
  IGRint ii;
  IGRchar mesg[DI_PATH_MAX];
  OMuword classID,classVSplate;
 
  __DBGpr_com("VDdrawingExtractFeatures begin");
 
	sts =
	om$get_classid(	classname	= "VSplate",
			p_classid	= &classVSplate );
	if( !( sts&1 )){ UI_status("Struct not loaded"); goto wrapup; }
  for(ii=0; ii<procCnt; ii++)
    {
      if(procList[ii].process != DELETE){ // features to be extracted for this
        om$get_classid(
		       objid = procList[ii].model.obj_id.objid,
		       osnum = procList[ii].model.obj_id.osnum,
		       p_classid = &classID);
	
	if( om$is_ancestry_valid( superclassid   = classVSplate,
				  subclassid     = classID ) == OM_S_SUCCESS ){
	  // see if the plate drawing is extracted
	  if(procList[ii].drwtbl.obj_id.objid == NULL_OBJID) continue;
 
	  __DBGpr_obj("VDfindAndExtract features for plate",procList[ii].model.obj_id); 
	  ret = VDfindAndExtract(procList[ii].model,refID);
	  if(!ret) __DBGpr_obj("Failed feature extraction for",procList[ii].model.obj_id);
	  
	}
      }
    } 
  retFlag = 1;
 wrapup:
  __DBGpr_int("VDdrawingExtractFeatures retFlag",retFlag);
  return retFlag;
}
/* This function takes care of updating the drawings w.r.t the latest 
 * changes to the model objects
 * This function is interfaced by vd$drw_process() macro 
 */
IGRint VDprocessDrawing(struct GRid refID,struct PrcInfo procList[],int procCnt)
{
  IGRint retFlag = 0,cn_type,b_mod;
  IGRint stat,ii,recompCnt = 0,classFlag = 0;
  IGRlong ret = 0,msg;
  struct GRid *recompList = NULL; 
  struct GRmd_env cur_env;
  OMuword classID;
  
  recompList = _MALLOC(procCnt,struct GRid);
  
  ret = gr$get_module_env(  buffer = &cur_env );
  
  // find what we are working on - VDdrawings or VDdrw2d objects
  for(ii=0;ii<procCnt;ii++)
    {
      if(procList[ii].drwtbl.obj_id.objid != NULL_OBJID)
	{
	  om$get_classid(
			 objid = procList[ii].drwtbl.obj_id.objid,
			 osnum = procList[ii].drwtbl.obj_id.osnum,
			 p_classid = &classID);
	  
	  if(classID == OPP_VDdrawing_class_id)
	    {
	      classFlag = 0;
	      break;
	    }
	  else if(classID == OPP_VDdrw2d_class_id)
	    {
	      classFlag = 1;
	      break;
	    }
	}
    } 
  
  for(ii=0;ii<procCnt;ii++) 
    {
      switch(procList[ii].process)
	{
	  __DBGpr_obj("processing drawing",procList[ii].drwtbl.obj_id);
	case NEW_MODEL : // extract the drawing
	  __DBGpr_com("NEW MODEL STATE");
	  
	  ret = VDextractDrawing(refID,&procList[ii],classFlag);
	  if(!(ret&1))
	    {
	      __DBGpr_obj("VDextractDrawing failed for",procList[ii].modelNew.obj_id);
	    }
	  __DBGpr_obj("Newly extracted drawing",procList[ii].drwtbl.obj_id);
	  
	  
	  break; 
	// recompute the drawing
	case MODIFY    : 
	case UNCHANGED  : 
	  __DBGpr_obj("MODIFY for",procList[ii].drwtbl.obj_id);
	  recompList[recompCnt++] = procList[ii].drwtbl.obj_id;
	  
	  break;
	  
	case MIGRATE   : // attach to new parent and recompute drawing
	  __DBGpr_obj("MIGRATE for",procList[ii].drwtbl.obj_id);
	case CONNECT   : // attach to new parent and recompute drawing
	  __DBGpr_obj("CONNECT for",procList[ii].drwtbl.obj_id);
	  
	  // disconnect from old parent and connect to new one
	  ret = VDupdateParent(procList[ii],refID);
	  if(!(ret&1))
	    {
	      __DBGpr_obj("Failed changing parent",procList[ii].drwtbl.obj_id);
	      break;
	    }
	  
	  // recompute the drawing
	  recompList[recompCnt++] = procList[ii].drwtbl.obj_id;
	  
	  break;
	case DELETE    : // delete the drawing 
	  __DBGpr_obj("DELETE for",procList[ii].drwtbl.obj_id);
	  
	  stat= om$send(msg  = message GRgraphics.GRdelete( &msg,
							    &cur_env),
			senderid = NULL_OBJID,
                        targetid =   procList[ii].drwtbl.obj_id.objid,
                        targetos =   procList[ii].drwtbl.obj_id.osnum  );
	  
	  if(!(stat&msg&1)) __DBGpr_obj("failed delete of drawing",procList[ii].drwtbl.obj_id);
	  break;
	  
	  
	default        : // do nothing
	  __DBGpr_obj("DEFAULT for",procList[ii].drwtbl.obj_id);
	}
    }
  // add the feature objects for recompute
  if(featCount > 0)
    {
      __DBGpr_int("featCount",featCount);
      recompList = _REALLOC(recompList,procCnt+featCount,struct GRid);
      for(ii=0;ii<featCount;ii++)
	recompList[recompCnt++] = features[ii].obj_id;
    }
  __DBGpr_int("recompCnt",recompCnt);
  for(ii=0; ii<recompCnt; ii++)
    __DBGpr_obj("recompList",recompList[ii]);
  
  cn_type   = ND_COMP;
  nd$wait_batch(  type       = GR_GEOM_POSTED,
		  nb_obj     = recompCnt,
		  l_object   = recompList,
		  l_obj_info = &cn_type );
  nd$mod_batch( request     = ND_INQ,
		p_ret_mode  = &b_mod );
  if( b_mod != ND_DEFER ) nd$exec_batch();
  // extract the features for new model objects
  
  ret = VDdrawingExtractFeatures(refID, procList, procCnt);
  if(!(ret&1)) __DBGpr_com("Failed extract features for new model objects");
  
  
  retFlag = 1 ;
 wrapup:
  _FREE(recompList); recompList = NULL;
  _FREE(features); features = NULL;
  _FREE(featState); featState = NULL;
  featCount = 0;
  
  __DBGpr_int("VDprocessDrawing retFlag",retFlag);
  return retFlag;
}


IGRint VDprocCurList(struct PrcInfo *curList,int curCnt,OMuint tag[],OMuword version[],GRname modNames[], struct GRobj_env newList[],int newCnt)
{
  IGRint 	retFlag = 0,ret,tmpCount = 0,ii,jj,kk;
  IGRlong 	sts, msg, isConsumed = 0;
  struct GRobj_env   childEnv; 	
  struct GRid modelObj;
  OMuword   	classID;
  OMuint 	Tag;
  OMuword 	Version;
  GRname        myModel;
  IGRboolean    nameFound,modelFound ;
  IGRint        matchIndex = -1;
  IGRchar       *syntax, className[DI_PATH_MAX];
  
  for(jj=0;jj<newCnt;jj++) __DBGpr_str("modelNames",modNames[jj]);
  
  for(ii=0; ii<curCnt; ii++){
    nameFound = 0;
    syntax    = NULL;
    __DBGpr_obj("Processing Drawing",curList[ii].drwtbl.obj_id);
 
    if(curList[ii].model.obj_id.objid == NULL_OBJID)
      {
	// model object not found for the drawing (connect, delete)
	// get the model object name and search in the objOS for that name
	myModel[0] = '\0';
	ret = VDgetModelName(curList[ii].drwtbl.obj_id,myModel); 
	if((!(ret&1)) || (myModel[0] == '\0'))
	  {
	    __DBGpr_obj("failed VDgetModelName for drawing",curList[ii].drwtbl.obj_id);
	    goto delete_case;
	  }
	syntax = strrchr(myModel,':');
	if(syntax)
	  {
	    syntax++;
	    strcpy(myModel,syntax);
	    __DBGpr_str("syntax",syntax);
          }
	syntax = NULL;
	
	for(jj=0;jj<newCnt;jj++)
	  {
	    syntax = strrchr(modNames[jj],':');
	    if(syntax)
	      {
		syntax++;
		strcpy(modNames[jj],syntax);
		__DBGpr_str("syntax",syntax);
	      }
	    if(!strcmp(myModel,modNames[jj]))
	      {
		nameFound = 1;
		matchIndex= jj;
		__DBGpr_int("matchIndex",matchIndex);
		break;
	      }	
	  }
	if(nameFound) 
	  {
	    curList[ii].process = CONNECT;
	    curList[ii].modelNew.obj_id = newList[matchIndex].obj_id;
	  }
	else
	  {
	  delete_case:
	    curList[ii].process = DELETE;
	    curList[ii].modelNew.obj_id.objid = NULL_OBJID;
	    curList[ii].modelNew.obj_id.osnum = 2;
	  }
      }
    else
      {
	childEnv.obj_id.objid = NULL_OBJID;
	// model object found  for drawing(migrate, modified, unchanged,..)
	sts =om$send(msg = message NDmacro.ACtest_consumed(&isConsumed),
		     senderid = NULL_OBJID,
		     targetid = curList[ii].model.obj_id.objid, 
		     targetos = curList[ii].model.obj_id.osnum );
	if(!isConsumed){
	  curList[ii].process = MODIFY; // might have been modified
	  curList[ii].modelNew.obj_id.objid = NULL_OBJID;
	  curList[ii].modelNew.obj_id.osnum = 2;
	  som_objid_to_tag(curList[ii].model.obj_id.osnum,
			   curList[ii].model.obj_id.objid,
			   &Tag,
			   &Version,NULL,NULL,NULL,NULL);
	  tag[ii]    = Tag;
	  version[ii]= Version;
	}
	else
	  {  
	    VDatGetConsumingChild( &curList[ii].model, &childEnv );
	    if(childEnv.obj_id.objid == NULL_OBJID){
	      curList[ii].process = UNCHANGED ; //better not change drawing
	      curList[ii].modelNew.obj_id.objid = NULL_OBJID;
	      curList[ii].modelNew.obj_id.osnum = 2;
	      continue;
	    }	
	    __DBGpr_obj("CHILD",childEnv.obj_id);
	    
	    className[0] = '\0';
	    sts = om$get_classname( objid = childEnv.obj_id.objid,
				    osnum = childEnv.obj_id.osnum,
				    classname = className );
	    
	    if((strcmp(className,"VSbooPlate")) && 
	       (strcmp(className,"VSholPlate")) && 
	       (strcmp(className,"VSsubPlate")) &&
	       (strcmp(className,"VSbooBeam"))) 
	      {
		curList[ii].process = UNCHANGED ; //better not change drawing
		curList[ii].modelNew.obj_id.objid = NULL_OBJID;
		curList[ii].modelNew.obj_id.osnum = 2;
		continue;
	      }
	    curList[ii].modelNew.obj_id = childEnv.obj_id;
	    curList[ii].process	      = MIGRATE;	
	  }
	// see if the model object is part of the newList; 
        // if not delete the drawing - TR179902038
	__DBGpr_com("see if the model object is part of the newList");
	modelObj.objid = NULL_OBJID;
	modelObj.osnum = 2;
	
	if((curList[ii].process = UNCHANGED) || (curList[ii].process = MODIFY)) modelObj = curList[ii].model.obj_id;
	else modelObj = curList[ii].modelNew.obj_id; //MIGRATE
	
	modelFound = FALSE;
	for(kk=0; kk<newCnt; kk++)
	  {
	    
	    if((newList[kk].obj_id.objid == modelObj.objid) && (newList[kk].obj_id.osnum == modelObj.osnum))
	      {
		
		modelFound = TRUE;
		break;
	      }	
	  }
	if(!modelFound)
	  {
__DBGpr_obj("Model Object not found for drawing in newlist",curList[ii].drwtbl.obj_id);	    
	    curList[ii].process = DELETE;
	    curList[ii].modelNew.obj_id.objid = NULL_OBJID;
	    curList[ii].modelNew.obj_id.osnum = 2;
	  }
      }
    
  } // processing of the current List is complete
  __DBGpr_int("No. of elements in curList",curCnt);
  for(ii=0; ii<curCnt; ii++){
    __DBGpr_int("Attributes of element ",ii);
    __DBGpr_obj("Drawing object",curList[ii].drwtbl.obj_id);
    __DBGpr_int("Process ",curList[ii].process);
    __DBGpr_obj("Model Object",curList[ii].model.obj_id);
    __DBGpr_obj("New Model Obj",curList[ii].modelNew.obj_id);
  }
  retFlag  = 1;
 wrapup:
  __DBGpr_int("VDprocCurList",retFlag);
  return retFlag;
}

IGRint VDgetOccName(struct GRid modelObj,GRname name)
{
  IGRint retFlag = 0;
  IGRchar    piecePath[DI_PATH_MAX];
  IGRchar   *p;
  IGRstat msg;
  
  if(modelObj.objid == NULL_OBJID) goto wrapup;
  
  // Get the path
  *piecePath = 0;
  om$send(
	  msg = message GRgraphics.GRgetname(&msg,piecePath),
	  senderid = NULL_OBJID,
	  targetid = modelObj.objid,
	  targetos = modelObj.osnum
	  );
  
  // Drop any ref file info
  p = strstr(piecePath,":ref:");
  if (p) strcpy(piecePath,p+4);
  
  // Protect against long paths, hope it won't be a problem later
  *(piecePath+78) = 0;
  
  strcpy(name,piecePath);
  
  retFlag = 1;
 wrapup:
  return retFlag;
}

/* This function sets the nodename to VDcontext for VDdrawings
 *                                 to VDdrw2dVw for VDdrw2d objects
 */
IGRint VDdrwSetNodName(struct GRid drwId, GRname nod_name)
{
  IGRint retFlag = 0,ret = 0;
  IGRlong status,msg;
  OMuword	classID;
  struct GRid vdctx, drwVwId;
  IGRint sts = OM_S_SUCCESS,attr_type ;
  GRname       attr_name;
  struct ACrg_coll attribute;
  
  vdctx.objid = NULL_OBJID;
  drwVwId.objid = NULL_OBJID;
  
  om$get_classid(
		 objid = drwId.objid,
		 osnum = drwId.osnum,
		 p_classid = &classID
		 );
  
  if(classID == OPP_VDdrawing_class_id)
    {
      __DBGpr_com("classID == OPP_VDdrawing_class_id");
      // add the node name information to the VDcontext object
      ret = VDGetContext(&drwId,&vdctx,NULL,0,0);
      if((!(ret & 1)) || (vdctx.objid == NULL_OBJID))
	{
	  __DBGpr_obj("failed getting VDcontext for",drwId); 
	  goto wrapup;
	}
      status =om$send(msg= message VDcontext.VDset_osname(nod_name),
		      senderid = NULL_OBJID,
		      targetid = vdctx.objid,
		      targetos = vdctx.osnum);
      if(!(status&1)){
	__DBGpr_obj("VDcontext.VDset_osname failed for ",vdctx);
	goto wrapup;
      }
    }
  else if(classID == OPP_VDdrw2d_class_id)
    {
      // add the node name information to the VDdrw2dVw object
      __DBGpr_com("classID == OPP_VDdrw2d_class_id");
      sts =
        VDdrw_GetChannelOwner(&msg, &drwId, VD_O_drw2d, &drwVwId );
      if(!(sts&msg&1) || (drwVwId.objid == NULL_OBJID)) 
	{
	  __DBGpr_obj("failed getting VDdrw2dVw for",drwId); 
	  goto wrapup;
	}
      __DBGpr_obj("SetNodName for drwVwId",drwVwId);
      strcpy(attribute.name,"node_name");
      attribute.desc.type = AC_ATTRIB_TEXT;
      strcpy(attribute.desc.value.att_txt,nod_name);
      
      ret = VDaddAttr(drwVwId, attribute, 0, 0);
      if(!(ret & 1))
	{
	  __DBGpr_str("attribute",nod_name);
	  __DBGpr_obj("failed VDaddAttr for",drwVwId); 
	  goto wrapup;
	}
      
    }
  else
    {
      //unknown class for this routine
      __DBGpr_com("unknown class for this routine");
      retFlag = 0;
      goto wrapup;
    }
  
  retFlag = 1;
 wrapup:
  __DBGpr_int("VDdrwSetNodName retFlag",retFlag);
  return retFlag;
}
/* This function gets the nodename of VDcontext for VDdrawings
 *                                 of VDdrw2dVw for VDdrw2d objects
 */
IGRint VDdrwGetNodName(struct GRid drwId, GRname nod_name)
{
  IGRint retFlag = 0,ret = 0;
  IGRlong status,msg;
  OMuword	classID;
  struct GRid vdctx, drwVwId;
  IGRint sts = OM_S_SUCCESS,attr_type ;
  GRname       attr_name;
  
  vdctx.objid = NULL_OBJID;
  drwVwId.objid = NULL_OBJID;
  
  om$get_classid(
		 objid = drwId.objid,
		 osnum = drwId.osnum,
		 p_classid = &classID
		 );
  nod_name[0] = '\0';
  
  if(classID == OPP_VDdrawing_class_id)
    {
      // get the node name information from the VDcontext object
      __DBGpr_com("classID == OPP_VDdrawing_class_id");
      ret = VDGetContext(&drwId,&vdctx,NULL,0,0);
      if((!(ret & 1)) || (vdctx.objid == NULL_OBJID))
	{
	  __DBGpr_obj("failed getting VDcontext for",drwId); 
	  goto wrapup;
	}
      status =om$send(msg= message VDcontext.VDget_osname(nod_name),
		      senderid = NULL_OBJID,
		      targetid = vdctx.objid,
		      targetos = vdctx.osnum);
      if(!(status&1)){
	__DBGpr_obj("VDcontext.VDget_osname failed for ",vdctx);
	goto wrapup;
      }
    }
  else if(classID == OPP_VDdrw2d_class_id)
    {
      __DBGpr_com("classID == OPP_VDdrw2d_class_id");
      // get the node name information from the VDdrw2dVw object
      sts =
        VDdrw_GetChannelOwner(&msg, &drwId, VD_O_drw2d, &drwVwId );
      if(!(sts&msg&1) || (drwVwId.objid == NULL_OBJID)) 
	{
	  __DBGpr_obj("failed getting VDdrw2dVw for",drwId); 
	  goto wrapup;
	}
      __DBGpr_obj("GetNodName for drwVwId",drwVwId);
      strcpy(attr_name,"node_name");
      attr_type = AC_ATTRIB_TEXT;
      
      ret = VDgetAttr(drwVwId, attr_name, nod_name, attr_type, 0, 0);
      if(!(ret & 1))
	{
	  __DBGpr_obj("failed getting VDgetAttr for",drwVwId); 
	  goto wrapup;
	}
      
    }
  else
    {
      //unknown class for this routine
      __DBGpr_com("unknown class for this routine");
      retFlag = 0;
      goto wrapup;
    }
  
  retFlag = 1;
 wrapup:
  __DBGpr_int("VDdrwGetNodName retFlag",retFlag);
  return retFlag;
}
/* Given a drawing object (VDdrawing/VDdrw2d) this function gives the name
 * of the model object for the drawing
 */

IGRint VDgetModelName(struct GRid drawing,GRname model)
{
  IGRint  retFlag = 0;
  OMuword classID;
  int     attr_type,index = 0;
  GRname  attr_name;
  int     sts = OM_E_INVARG, status ;
  struct  ret_struct RetStr ;
  struct  GRmd_env   MdEnv;          //current mod env
  
  model[0] = '\0';
  
  if(drawing.objid == NULL_OBJID) goto wrapup;
  
  status = ex$get_cur_mod( osnum = &(MdEnv.md_id.osnum),
			   id = &(MdEnv.md_id.objid) );
  if(!(status&1)) goto wrapup;
  __DBGpr_obj( "module info", MdEnv.md_id ) ;
  
  om$get_classid(
		 objid = drawing.objid,
		 osnum = drawing.osnum,
		 p_classid = &classID);
  if(classID == OPP_VDdrawing_class_id)
    {
      
      status = om$send( msg = message NDmacro.ACgive_structure( &sts,
                                                                &index,
                                                                "occurence",
                                                                &RetStr,
                                                                &MdEnv ),
			senderid        = NULL_OBJID,
			targetid        = drawing.objid ,
			targetos        = drawing.osnum) ;
      if(!(status&sts&1))
	{
	  __DBGpr_obj("Failed NDmacro.ACgive_structure",drawing);
	  goto wrapup;
	} 
      if(RetStr.var.text_st.text_string[0] != '\0'){
	strcpy(model,RetStr.var.text_st.text_string);
	__DBGpr_str("modelName ",model);
      }
      else goto wrapup;
      
    }
  else if(classID == OPP_VDdrw2d_class_id)
    {
      strcpy(attr_name,"occurence");
      attr_type = AC_ATTRIB_TEXT;
      
      sts = VDgetAttr(drawing, attr_name, model, attr_type, 0, 0);
      if((!(sts & 1)) || (model[0] == '\0'))
	{
	  __DBGpr_obj("failed getting VDgetAttr for",drawing); 
	  goto wrapup;
	}
    }
  else
    {
      __DBGpr_com("unknown class for the routine");
      retFlag = 0;
      goto wrapup;
    }
  
  retFlag = 1;
 wrapup:
  __DBGpr_int("VDgetModelName retFlag",retFlag);
  return retFlag;
}
/* This function disconnects the drawing from its old parent and connects it
 * to the new parent
 */

IGRint VDupdateParent(struct PrcInfo  drawing,struct GRid context)
{
  IGRint   retFlag = 0, ii;
  IGRlong  sts,msg;
  struct GRid modObj, as_grid;
  struct GRmd_env modEnv;
  BSrc            rc;
  IGRshort        four=4, trs_type;
  IGRdouble       ctx_matrix[16],trs_matrix[16];
  
  as_grid.objid = NULL_OBJID;
  __DBGpr_com("Entered VDupdateParent");
  __DBGpr_obj("Context ",context);
  
  /*
    sts = om$send(msg = message NDmacro.ACreturn_foot(&msg, 
    "",
    &modObj,
    &modEnv.md_env.matrix_type,
    modEnv.md_env.matrix ),
    senderid = NULL_OBJID,
    targetid = drawing.pretend.objid,
    targetos = drawing.pretend.osnum);
    if(!(sts&msg&1))
    {
    __DBGpr_obj("NDmacro.ACreturn_foot failed for",drawing.pretend);
    goto wrapup;
    }
    
    modEnv._MD_OS = modObj.osnum;
    sts = ex$get_modid(     mod_osnum = modEnv._MD_OS,
    mod_id    = &modEnv._MD_ID );
  */
  MAidmx( &msg, trs_matrix) ;	
  MAidmx( &msg, ctx_matrix) ;	
  
  retFlag = VDgetctxmatrix(context,ctx_matrix);
  if(!(retFlag &1)){
    __DBGpr_obj("VDgetctxmatrix failed for",context);
    goto wrapup;
  }
  
  MAmulmx ( &rc, &four, &four, &four, drawing.modelNew.mod_env.md_env.matrix, ctx_matrix, trs_matrix);
  MAtypemx( &rc, trs_matrix, &trs_type);
  
  modEnv = drawing.modelNew.mod_env;
  for(ii=0; ii<16; ii++) modEnv.md_env.matrix[ii] = trs_matrix[ii];
  modEnv.md_env.matrix_type = trs_type;
  
  __DBGpr_mat(" model matrix ", drawing.modelNew.mod_env.md_env.matrix);
  __DBGpr_mat(" context matrix ", ctx_matrix);
  __DBGpr_mat(" transformation matrix ", trs_matrix);
  
    modEnv._MD_OS = drawing.modelNew.obj_id.osnum;
    sts = ex$get_modid(     mod_osnum = modEnv._MD_OS,
    mod_id    = &modEnv._MD_ID );
  as$make_source( go_grid         = drawing.modelNew.obj_id,
		  mod_env         = &modEnv,
		  as_grid         = &as_grid ) ;
  if(as_grid.objid == NULL_OBJID)
    {
      __DBGpr_obj("make_source failed on",drawing.modelNew.obj_id);
      goto wrapup;
    }
  sts = om$send(  msg     = message NDnode.NDchange_connect(1, &drawing.pretend, &as_grid ),
		  senderid= NULL_OBJID,
		  targetid= drawing.drwtbl.obj_id.objid,
		  targetos= drawing.drwtbl.obj_id.osnum ) ;
  if(!(sts&1))
    {
      __DBGpr_obj("NDnode.NDchange_connect failed",drawing.drwtbl.obj_id);
      goto wrapup;
    }
  retFlag = 1;
 wrapup:
  __DBGpr_int("VDupdateParent retFlag ",retFlag);
  return retFlag;
}

/* This function does the drawing extraction process for new model objects
 * classFlag = 0 => VDdrawing objects
 * classFlag = 1 => VDdrw2d objects
 */ 

IGRint VDextractDrawing(struct GRid refID, struct PrcInfo *prcInfo, IGRint classFlag)
{
  IGRint retFlag = 0,nb_obj = 0,ii;
  int obj_level[32],index = -1,ret,outCount =0;
  IGRlong status,msg,sts;
  double point[3],vector[3];
  struct IGRlbsys        obj_lbs;
  struct GRobj_env pretendOE;
  struct GRid *obj_list = NULL,as_grid;
  struct GRmd_env cur_env,modEnv;
  IGRboolean    pretFlag = FALSE;
  OMuword classID;
  
  IGRchar  setupName[128];
  BSrc            rc;
  IGRshort        four=4, trs_type;
  IGRdouble       ctx_matrix[16],trs_matrix[16];
  
  __DBGpr_com("Entered VDextractDrawing");
  
  strcpy(setupName,"ucm_setup"); 
  //VDdrwGetSetupFileName(setupName); 
  __DBGpr_str("Drawing setupFile ",setupName);
  ret = gr$get_module_env(  buffer = &cur_env );
  
  if(refID.objid == NULL_OBJID) goto wrapup;
  
  MAidmx( &msg, trs_matrix) ;	
  MAidmx( &msg, ctx_matrix) ;	
  //MAidmx( &msg, prcInfo->model.mod_env.md_env.matrix) ;	
  
  retFlag = VDgetctxmatrix(refID,ctx_matrix);
  if(!(retFlag &1)){
    __DBGpr_obj("VDgetctxmatrix failed for",refID);
    goto wrapup;
  }
  
  MAmulmx ( &rc, &four, &four, &four, prcInfo->model.mod_env.md_env.matrix, ctx_matrix, trs_matrix);
  MAtypemx( &rc, trs_matrix, &trs_type);
  
  modEnv = prcInfo->model.mod_env;
  for(ii=0; ii<16; ii++) modEnv.md_env.matrix[ii] = trs_matrix[ii];
  modEnv.md_env.matrix_type = trs_type;
  
  __DBGpr_mat(" model matrix ", prcInfo->model.mod_env.md_env.matrix);
  __DBGpr_mat(" context matrix ", ctx_matrix);
  __DBGpr_mat(" transformation matrix ", trs_matrix);
    
    modEnv._MD_OS = prcInfo->model.obj_id.osnum;
    sts = ex$get_modid(     mod_osnum = modEnv._MD_OS,
    mod_id    = &modEnv._MD_ID );
  
  as$make_source( go_grid         = prcInfo->model.obj_id,
		  mod_env         = &modEnv,
		  as_grid         = &as_grid ) ;
  if(as_grid.objid == NULL_OBJID)
    {
      __DBGpr_obj("make_source failed on",prcInfo->model.obj_id);
      goto wrapup;
    }
  
  pretendOE.obj_id = as_grid;
  pretendOE.mod_env= cur_env;
  
  prcInfo->pretend = as_grid;
  
  status = om$send(msg = message VDcontext.VDget_extract_info
		   (&obj_list,&nb_obj,vector,point,obj_level,&obj_lbs),
		   senderid = NULL_OBJID,
		   targetid = refID.objid,
		   targetos = refID.osnum);
  if((!(status&1)) || (nb_obj == 0)){
    printf("\n VDcontext.VDget_extract_info failed \n");
         goto wrapup;
  }
  
  if(classFlag == 1)
    {
      ret =
        VDdrw_Create2dObjects(  &status,                /* Return code  */
                                index,                  /* Batch contr  */
                                &cur_env,        	/* Environment  */
                                1,                	/* Number objs  */
                                &pretendOE,     	/* List of objs */
                                point,                  /* Project pnt  */
                                vector,                 /* Project vec  */
                                obj_level,              /* PRoject Lev  */
                                setupName,         	/* visualization*/
                                NULL,                   /* Trans Setup  */
                                0,           		/* Select/Trans */
                                0,              	/* Like To Post */
                                &outCount,              /* Nb found     */
                                &prcInfo->drwtbl.obj_id);/* new VDdrw2d  */
      if((!(status&ret&1)) || (prcInfo->drwtbl.obj_id.objid == NULL_OBJID))
	{
	  __DBGpr_obj("fail VDdrw_Create2dObjects for",prcInfo->model.obj_id);
	  goto wrapup;
	} 
      __DBGpr_obj("new Model object",prcInfo->model.obj_id);
      __DBGpr_obj("extracted VDdrw2d object",prcInfo->drwtbl.obj_id);
      prcInfo->drwtbl.mod_env = cur_env;   
    }
  else if( classFlag == 0)
    {
      retFlag = VDextrDrawing(prcInfo,refID);
      if(!(retFlag&1))
	{
	  __DBGpr_obj("fail VDextrDrawing for",prcInfo->model.obj_id);
	  goto wrapup;
	} 
      __DBGpr_obj("new Model object",prcInfo->model.obj_id);
      __DBGpr_obj("extracted VDdrawing object",prcInfo->drwtbl.obj_id);
      prcInfo->drwtbl.mod_env = cur_env;   
    }
  else
    {
      __DBGpr_com("Unknown object");
      goto wrapup;
    }
  retFlag = 1;
 wrapup:
  __DBGpr_int("VDextractDrawing retFlag",retFlag);
  _FREE(obj_list); obj_list = NULL;
  return retFlag;
}

/* This function extracts the drawing for VDdrawing objects */
IGRint VDextrDrawing(struct PrcInfo *drawing,struct GRid context)
{
  long loc_msg,status,msg,sts,error;
  int i_obj,i,count, retFlag = 0,ret;
  IGRint nb_obj = 0,ii,nb_attachement = 1,nb_created;
  char *model_def_name, setupName[128];
  struct GRid model_obj,model_def,drawing_def,drawing_obj,*feet = NULL;
  int i_macro,nb_drawing_macros = 0;
  char **drawing_macros = NULL;
  char dir_name[DI_PATH_MAX];
  int nb_feet,feet_size = 0;
  struct myfeet *feet_desc; 
  struct GRmd_env model_env,cur_env,modEnv;
  enum GRdpmode dp_mode = GRbd;
  struct ACdb_info db_info;
  int level[32];
  double vector[3],point[3];
  
  int obj_level[32],outCount =0;
  struct IGRlbsys        obj_lbs;
  struct GRid *obj_list = NULL,as_grid;
  OMuword classID;
  
  BSrc            rc;
  IGRshort        four=4, trs_type;
  IGRdouble       ctx_matrix[16],trs_matrix[16];
  
  __DBGpr_com("Entered VDextrDrawing ");
  
  ret = gr$get_module_env(  buffer = &cur_env );
  cur_env._MD_OS = context.osnum;
  sts = ex$get_modid(     mod_osnum = cur_env._MD_OS,
			  mod_id    = &cur_env._MD_ID );
  
  __DBGpr_obj("cur_env.md_id",cur_env.md_id);
  
  as_grid = drawing->pretend;
  __DBGpr_obj("as_grid",as_grid);
  
  /* Get displayable level and view definition */
  status = om$send(msg = message VDcontext.VDget_extract_info
		   (&obj_list,&nb_obj,vector,point,obj_level,&obj_lbs),
		   senderid = NULL_OBJID,
		   targetid = context.objid,
		   targetos = context.osnum);
  
  if((!(status&1)) || (nb_obj == 0)){
    printf("\n VDcontext.VDget_extract_info failed \n");
    goto wrapup;
  }
  __DBGpr_vec("Vector",vector); 
  __DBGpr_vec("Point",point); 
  /* Get drawing macro */
  
  status = di$give_pathname ( osnum =  cur_env.md_id.osnum,
                              pathname =  dir_name);
  strcat(dir_name,":constructs:*");
  
  di$ls(regexp=dir_name,
	lines = &drawing_macros,
	ptr = &nb_drawing_macros,
	options = 0);
  
  
  model_env.md_id.objid = NULL_OBJID;
  
  /* 
     add in the context object info like model file name, displayable level
     and view definition by changing its class to VDcontext
  */
  
  status = VDstore_levels_and_vol( &as_grid, 1, 
				   obj_level, point, vector, &cur_env);
  if(!(status&1))
    {
      __DBGpr_obj("VDstore_levels_and_vol failed for",as_grid);
      goto wrapup;
    } 
  
  
  nb_created = 0;
  for(i_obj=0 ; i_obj < nb_attachement ; i_obj++)
    {
      /* 
	 Get macro definition of the selected object and search if there is a 
	 drawing macro definition valid for this type of macro to know which 
	 attributes should be extracted
      */
      
      status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
							   &model_obj,&model_env.md_env.matrix_type,
							   model_env.md_env.matrix),
		       senderid = NULL_OBJID,
		       targetid = as_grid.objid,
		       targetos = as_grid.osnum);
      model_env.md_id.osnum = model_obj.osnum;
      if(!(status&loc_msg&1)) continue;
      
      __DBGpr_obj("modelObj",model_obj);
      
      status = om$send(msg = message ACcpx.find_macro(&model_def),
		       senderid = NULL_OBJID,
		       targetid = model_obj.objid,
		       targetos = model_obj.osnum);
      if(!(status&1)) 
	{
	  __DBGpr_obj("ACcpx.find_macro failed for",model_obj);
	  goto wrapup;
	} 
      status = om$send(msg = message ACcpx_defn.ACgive_name(&model_def_name),
		       senderid = NULL_OBJID,
		       targetid = model_def.objid,
		       targetos = model_def.osnum);
      if(!(status&1)) 
	{
	  __DBGpr_obj("ACcpx_defn.ACgive_name failed for",model_def);
	  goto wrapup;
	} 
      
      
      for(i_macro=0;i_macro<nb_drawing_macros;i_macro++)
	{
	  status = di$translate(objname = drawing_macros[i_macro],
				p_objid = &drawing_def.objid,
				p_osnum = &drawing_def.osnum);
	  
	  if(!(status&1)) continue;
	  status=om$send(msg = message ACcpx_defn.ACgive_feet_desc
			 (&nb_feet,&feet_desc),
			 senderid = NULL_OBJID,
			 targetid = drawing_def.objid,
			 targetos = drawing_def.osnum);
	  if(!(status&1)) continue;
	  if(nb_feet < 1) continue; /* facking macro for leader line */
	  if(ASmatchRE(feet_desc[nb_feet-1].name,model_def_name)) break;
	}
      if(nb_feet>feet_size)
	{
	  if(feet) om$dealloc(ptr = feet);
	  feet_size=nb_feet;
	  feet=_MALLOC(nb_feet,struct GRid);
	}
      /*
       * Check if occurence already exist of input object.
       */
      drawing_obj.objid = NULL_OBJID ;
      status = VDchk_child_on_class(	&loc_msg,
					&model_obj,
					&as_grid,
					"VDdrawing",
					&drawing_obj );
      if( drawing_obj.objid == NULL_OBJID ){
	
	__DBGpr_com(" Construct New Macro " );
	
	/* initialize the drawing macro with this */
	status =
	  om$construct(classid = OPP_VDdrawing_class_id,
		       osnum = cur_env.md_id.osnum,
		       msg = message NDnode.NDconnect(1,&as_grid,
						      NULL_GRID,ND_NEW),
		       p_objid = &drawing_obj.objid);
	if(!(status&1)) continue;
	
	drawing_obj.osnum = cur_env.md_id.osnum;
	
	__DBGpr_obj("drawing_obj",drawing_obj);
	
	status =
	  om$send(msg = message ACcpx.ACload_macro(drawing_def),
		  senderid = NULL_OBJID,
		  targetid = drawing_obj.objid, 
		  targetos = drawing_obj.osnum);
	nb_created++;
      }
      else{
	__DBGpr_obj("Object already has a VDdrawing",drawing_obj);
	retFlag = 1;
	goto wrapup;
      }
      
      /* Initialize db_info for the drawing part */
      status =
	om$send(msg = message ACdb_info.ACcheckin_candidate
		(VDS_NORMAL_CHECKIN,(int *)&loc_msg),
		senderid = NULL_OBJID,
		targetid = model_obj.objid,
		targetos = model_obj.osnum);
      if(!(status&loc_msg&1))
	status =
	  om$send(msg = message ACdb_info.ACcheckin_candidate
		  (VDS_FAST_CHECKIN,(int *)&loc_msg),
		  senderid = NULL_OBJID,
		  targetid = model_obj.objid,
		  targetos = model_obj.osnum);
      
      if(status&loc_msg&1){
	status =
	  om$send(msg=message ACdb_info.ACget_db_info(&loc_msg,&db_info),
		  senderid = NULL_OBJID,
		  targetid = model_obj.objid,
		  targetos = model_obj.osnum);
	if(!(status&loc_msg&1)){
	  /*
	   * ad/alain: Instead of stopping the drawing extraction, give warning
	   *	     for current object without database information and
	   *	     continue with drawing extraction.
	   */
	  
	  IGRchar	classname[100];
	  
	  om$get_classname(	objid	= model_obj.objid,
				osnum	= model_obj.osnum,
				classname = classname );
	  
	  printf("WARNING: %s [%d,%d] no db_info found.\n",
		 classname, model_obj.objid, model_obj.osnum );
	  
	  /* return OM_W_ABORT; */
	  
	  goto wrapup;	
	}
	status =
	  om$send(msg = message ACdb_info.ACset_db_info(&loc_msg,&db_info),
		  senderid = NULL_OBJID,
		  targetid = drawing_obj.objid,
		  targetos = drawing_obj.osnum);
	
	status =
	  om$send(msg = message ACdb_info.ACput_serial_no(db_info.serial_no),
		  senderid = NULL_OBJID,
		  targetid = drawing_obj.objid,
		  targetos = drawing_obj.osnum);
      }
    } /* for ... */
  
  /* Now compute the initialized drawing macro, affect them db_info and display*/
  
  for(i_obj=0 ; i_obj < nb_created ; i_obj++)
    {
      status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,&as_grid,1,NULL,
							  0,OM_K_MAXINT,&count),
		       senderid = NULL_OBJID,
		       targetid = drawing_obj.objid,
		       targetos = drawing_obj.osnum);
      if(!(status&1))
	{
	  __DBGpr_obj("NDnode.NDget_objects failed for ",drawing_obj);
	  goto wrapup;
	}
      __DBGpr_obj("NDnode.NDget_objects ",as_grid);
      __DBGpr_obj("cur_env.md_id",cur_env.md_id);
      status = om$send(msg = message ACncpx.ACconstruct_feet(&loc_msg,0,1,&as_grid,
							     &cur_env,&nb_feet,feet),
		       senderid = NULL_OBJID,
		       targetid = drawing_obj.objid,
		       targetos = drawing_obj.osnum);
      
      if(status & loc_msg &1)
	{
	  
	  __DBGpr_com("ACncpx.ACconstruct_feet successful ");
	  
	  status = om$send(msg = message ACncpx.ACchange_feet
			   (nb_feet,feet,&cur_env),
			   senderid = NULL_OBJID,
			   targetid = drawing_obj.objid,
			   targetos = drawing_obj.osnum);
	  if(status&1) { __DBGpr_com("ACncpx.ACchange_feet successful "); }
	  else goto wrapup;
	  
	  status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
							      &cur_env.md_env.matrix_type,
							      cur_env.md_env.matrix,
							      &dp_mode,&cur_env.md_id),
			   senderid = NULL_OBJID,
			   targetid = drawing_obj.objid,
			   targetos = drawing_obj.osnum);
	  
	  drawing->drwtbl.obj_id = drawing_obj;
	}
      else
	{
	  __DBGpr_obj("ACncpx.ACconstruct_feet failed for",drawing_obj);
	  status = om$send(msg = message GRgraphics.GRdelete
			   (&loc_msg,&cur_env),
			   senderid = NULL_OBJID,
			   targetid = drawing_obj.objid,
			   targetos = drawing_obj.osnum);
	  goto wrapup;
	}
    }
  
  __DBGpr_com("Freeing drawing_macros");
  if(drawing_macros && nb_drawing_macros)
    di$free(lines = drawing_macros,
	    count = nb_drawing_macros);
  
  retFlag = 1;
 wrapup:
  _FREE(model_def_name); model_def_name = NULL;
  _FREE(feet); feet = NULL;
  
  __DBGpr_int("VDextrDrawing retFlag",retFlag);
  return retFlag;
}

IGRint reviewDrawingsInFile(struct PrcInfo **review,IGRint *drwCount)
{
  
  IGRint retFlag, sts,ii;
  struct GRid *drawings = NULL, *modelObjs = NULL;
  IGRint count ;
  struct GRmd_env cur_env;
  uword     Class[1];
  int           cntClass;
  OM_S_OBJID objs[2048];
  struct PrcInfo *reviewList = NULL;
    
  retFlag =0;
  count = 0;
  cntClass = 1;

  *drwCount = 0;
  *review = NULL;
  
  gr$get_module_env(buffer= &cur_env);  
  om$get_classid( classname = "VDdrawing", p_classid = &Class[0] );
  
  //get all the VDdrawing objects in the design file
  sts = VDpms_findall_ancestryobjects(cur_env.md_id.osnum,cntClass,Class,&count,objs);
  if(!(sts&1)) goto wrapup; 
  if(count == 0) goto wrapup;
  
  __DBGpr_int("VDdrawing count in file ",count);
  
  drawings = _MALLOC(count,struct GRid);
  modelObjs = _MALLOC(count,struct GRid);
  
  for(ii = 0; ii<count; ii=ii++)
    {
      drawings[ii].objid = objs[ii];
      drawings[ii].osnum = cur_env.md_id.osnum;
    }
  for(ii = 0; ii<count; ii=ii++) __DBGpr_obj("drawing",drawings[ii]);
  
  sts = VDgetModelObjs(drawings,count,modelObjs,0);
  if(!(sts&1))
    {
      __DBGpr_com("Failed in VDgetModelObjs ");
      goto wrapup;
    }  
  for(ii = 0; ii<count; ii=ii++) __DBGpr_obj("ModelObj",modelObjs[ii]);
  reviewList = _MALLOC(count,struct PrcInfo);
  
  for(ii = 0; ii<count; ii=ii++)
    {
      reviewList[ii].drwtbl.obj_id = drawings[ii];
      reviewList[ii].model.obj_id  = modelObjs[ii];
    }
  
  sts = reviewDrawingObjs(reviewList,count);
  if(!(sts&1))
    {
      __DBGpr_com("Failed in reviewDrawingObjs");
      goto wrapup;
    }
  *review = reviewList;
  *drwCount = count;

  //Done
  retFlag = 1;
  
 wrapup:
  _FREE(drawings);
  _FREE(modelObjs);
  return retFlag;  
}

IGRint reviewDrawingObjs(struct PrcInfo *curList,int curCnt)
{
  IGRint 	ret,ii,jj,retFlag = 0;
  IGRlong 	sts, msg, isConsumed = 0;
  struct GRobj_env   childEnv; 	
  IGRchar className[DI_PATH_MAX];
  
  if(curCnt == 0) goto wrapup;
  if(!curList) goto wrapup;
  
  
  for(ii=0; ii<curCnt; ii=ii+1){
    
    if(curList[ii].model.obj_id.objid == NULL_OBJID)
      {
	// model object not found for the drawing (connect, delete)
	curList[ii].process = DELETE;
	curList[ii].modelNew.obj_id.objid = NULL_OBJID;
	curList[ii].modelNew.obj_id.osnum = 2;
	
      }
    else
      {
	childEnv.obj_id.objid = NULL_OBJID;
	// model object found  for drawing(migrate,unchanged)
	sts =om$send(msg = message NDmacro.ACtest_consumed(&isConsumed),
		     senderid = NULL_OBJID,
		     targetid = curList[ii].model.obj_id.objid, 
		     targetos = curList[ii].model.obj_id.osnum );
	if(!isConsumed){
	  curList[ii].process = UNCHANGED; // might have been modified
	  curList[ii].modelNew.obj_id.objid = NULL_OBJID;
	  curList[ii].modelNew.obj_id.osnum = 2;
	}
	else
	  {  
	    VDatGetConsumingChild( &curList[ii].model, &childEnv );
	    if(childEnv.obj_id.objid == NULL_OBJID){
	      curList[ii].process = UNCHANGED ; //better not change drawing
	      curList[ii].modelNew.obj_id.objid = NULL_OBJID;
	      curList[ii].modelNew.obj_id.osnum = 2;
	      continue;
	    }	
	    __DBGpr_obj("CHILD",childEnv.obj_id);
	    
	    className[0] = '\0';
	    sts = om$get_classname( objid = childEnv.obj_id.objid,
				    osnum = childEnv.obj_id.osnum,
				    classname = className );
	    
	    if((strcmp(className,"VSbooPlate")) && 
	       (strcmp(className,"VSholPlate")) && 
	       (strcmp(className,"VSsubPlate")) &&
	       (strcmp(className,"VSbooBeam"))) 
	      {
		curList[ii].process = UNCHANGED ; //better not change drawing
		curList[ii].modelNew.obj_id.objid = NULL_OBJID;
		curList[ii].modelNew.obj_id.osnum = 2;
		continue;
	      }
	    curList[ii].modelNew.obj_id = childEnv.obj_id;
	    curList[ii].process	      = MIGRATE;	
	  }
      } 
  } // processing of the current List is complete
  __DBGpr_int("No. of elements in curList",curCnt);
  for(ii=0; ii<curCnt; ii++){
    __DBGpr_int("Attributes of element ",ii);
    __DBGpr_obj("Drawing object",curList[ii].drwtbl.obj_id);
    __DBGpr_int("Process ",curList[ii].process);
    __DBGpr_obj("Model Object",curList[ii].model.obj_id);
    __DBGpr_obj("New Model Obj",curList[ii].modelNew.obj_id);
  }
  retFlag  = 1;
 wrapup:
  __DBGpr_int("VDprocCurList",retFlag);
  return retFlag;
}
end implementation VDSroot ;

