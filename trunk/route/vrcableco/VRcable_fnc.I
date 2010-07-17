/* $Id: VRcable_fnc.I,v 1.2 2001/02/20 01:11:51 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco / VRcable_fnc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcable_fnc.I,v $
 *	Revision 1.2  2001/02/20 01:11:51  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/04/03  23:58:06  pinnacle
# Replaced: vrcableco/VRcable_fnc.I for:  by msmanem for route240
#
# Revision 1.3  1996/01/17  05:44:54  pinnacle
# Replaced: vrcableco/VRcable_fnc.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/16  20:16:06  pinnacle
# Replaced: vrcableco/VRcable_fnc.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/03/96	AdZ	created
	08/08/94		Add reference file checking.
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	04/04/96	msm	changed malloc & free to _MALLOC, _FREE
 *
 *************************************************************************/

class implementation Root;

/* 
 * include files
 */

#define  vdsDEBUG
#define	 vdserrDEBUG

#include <stdio.h>
#include <string.h>

#include "FI.h"
#include "CIforms.h"
#include "ODE.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "GRtypedef.h"
#include "gr.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRcabledef.h"
#include "bserr.h"
#include "bstypes.h"

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"

#include "VRdimdef.h"
#include "AS_status.h"
#include "bsproj0.h"

#include "vrcablec_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG	1

from	VRGeneric	import	VRGetNeighbors;

struct	VRCbOrdList
{
	struct	GRid	ObjId;
	IGRint		flag;
	IGRint		IndexList[VR_MAX_CPTS];
	IGRint		NumIndexList;
};

/* ---------------------------------------------------------------------- */
/* CABLE_ACTIVE */
/* ---------------------------------------------------------------------- */
int	VRCb_Equip_Active( Obj_Name, Obj_Id )
/*
 * This routine checks if a cable is or isn't constructed in
 * in the drawing system.
 */
IGRchar		*Obj_Name;
struct	GRid	*Obj_Id;

/*.Object_Active*/
{
/*
 * local variables
 */
IGRchar		cur_path[CABLE_MAX_TXT];
IGRint		found, nb_obj,cur_deep, sts;
DIgrid		*cur_grid;
OM_S_OBJID	cur_id;
OMuword		cur_os;

  /* initial values */
  found = FALSE;
  cur_grid = NULL;
	
  ex$get_cur_mod( id = &cur_id, osnum = &cur_os );
  di$give_pathname( osnum = cur_os, pathname = cur_path );
  strcat( cur_path, ":usr");
	
  sts = di$find(	regexp	  = Obj_Name,
			start_dir = cur_path, 
			grids	  = &cur_grid,
			ptr	  = &nb_obj,
			deep	  = &cur_deep );

  /* " nb_obj %d \n", nb_obj */

  if( sts == DIR_S_SUCCESS ){
	if( nb_obj == 1 ){
		found = TRUE;
		Obj_Id->objid = cur_grid->objid;
		Obj_Id->osnum = cur_grid->osnum;
		/*" obj (%d/%d) \n", Obj_Id->objid, Obj_Id->osnum */
	}
  }
  else {
	if( cur_grid != NULL ) free( cur_grid );
	cur_grid = NULL;
  }

  if( ! found ){

	/*
	 * Try to find out if object is in reference file.
	 */
	DIchar		**refnames = NULL;
	GRspacenum	*ref_os	= NULL;
	IGRint		iref, nb_ref = 0;
	IGRchar		ref_path[DI_PATH_MAX];

	UI_status(" Looking in reference files ... ");
	if( cur_grid != NULL ) free( cur_grid );
	cur_grid = NULL;

	VDGetRefFiles( &ref_os, &refnames, &nb_ref );

	for( iref=0 ; iref<nb_ref ; iref++ ){

		sprintf( ref_path, "%s%s", refnames[iref], ":usr" );

		/* "ref_path: <%s> \n", ref_path */

		if( cur_grid != NULL ) free( cur_grid );
		cur_grid = NULL;

		sts = di$find(	regexp	  = Obj_Name,
				start_dir = ref_path, 
				grids	  = &cur_grid,
				ptr	  = &nb_obj,
				deep	  = &cur_deep );

		/*"nb_obj %d \n", nb_obj */
		if( sts != DIR_S_SUCCESS ){
			/* object not found in reference file. */
			if( cur_grid != NULL ) free( cur_grid );
			cur_grid = NULL;
		}
		else{
			if( nb_obj == 1 ){
				found = TRUE;
				Obj_Id->objid = cur_grid->objid;
				Obj_Id->osnum = cur_grid->osnum;
				break;
			}
		}
	}
  }

  if( cur_grid != NULL ) free( cur_grid );

  if(! found ){ 
    /*" object <%s> not in system\n", Obj_Name */
    return FALSE;
  }
return	TRUE;
}

/* ---------------------------------------------------------------------- */
/* CABLE_ACTIVE */
/* ---------------------------------------------------------------------- */
int	VRCb_Object_Active( Obj_Name, Obj_Id )
/*
 * This routine checks if a cable is or isn't constructed in
 * in the drawing system.
 */
IGRchar		*Obj_Name;
struct	GRid	*Obj_Id;

/*.Object_Active*/
{
/*
 * local variables
 */
IGRchar		cur_path[CABLE_MAX_TXT];
IGRint		found, nb_obj,cur_deep, sts;
DIgrid		*cur_grid;
OM_S_OBJID	cur_id;
OMuword		cur_os;

  /* initial values */
  found = FALSE;
	
  ex$get_cur_mod( id = &cur_id, osnum = &cur_os );
  di$give_pathname( osnum = cur_os, pathname = cur_path );
  strcat( cur_path, ":usr");
  /* " cur_path: <%s> \n", cur_path */
	
  cur_grid = NULL;
  sts = di$find(	regexp	  = Obj_Name,
			start_dir = cur_path, 
			grids	  = &cur_grid,
			ptr	  = &nb_obj,
			deep	  = &cur_deep );

  /* " nb_obj %d \n", nb_obj */

  if( sts != DIR_S_SUCCESS ){
	/*| object not found in system */
	if( cur_grid != NULL ) free( cur_grid );
	return FALSE;
  }
  else{
    if( nb_obj == 1 ){
        found = TRUE;
	Obj_Id->objid = cur_grid->objid;
	Obj_Id->osnum = cur_grid->osnum;

	/* " obj (%d/%d) \n", Obj_Id->objid, Obj_Id->osnum */
    }
  }

  if( cur_grid != NULL ) free( cur_grid );

  if(! found ){ 
    /*" object <%s> not in system\n", Obj_Name */
    return FALSE;
  }
return	TRUE;
}

/* ---------------------------------------------------------------------- */
/* VRCbGetProjectPnt 							- */
/* ---------------------------------------------------------------------- */

IGRint	VRCbGetProjectPnt( Pnt, Pnt_Vec, Next_Pnt, Win_Dir, Proj_Pnt )

IGRdouble	*Pnt;
IGRdouble	*Pnt_Vec;
IGRdouble	*Next_Pnt;
IGRdouble	*Win_Dir;
IGRdouble	*Proj_Pnt;
/*.VRCbGetProjectPnt*/
{
IGRint			i;
IGRlong			rc;
IGRdouble		dist, int_pnt[6], tmp_pnt[6];
IGRdouble		line_pt0[3], line_pt1[3];
struct	IGRline		line0, line1;
struct	IGRline		*line[2];

  line0.point1 = Pnt;
  line0.point2 = line_pt0;
  line1.point1 = Next_Pnt;
  line1.point2 = line_pt1;
  line[0]      = &line0;
  line[1]      = &line1;

  for(i=0;i<3;i++){
	  line_pt0[i] = Pnt[i]      + 100 * Pnt_Vec[i];
	  line_pt1[i] = Next_Pnt[i] + 100 * Win_Dir[i];
  }
	
  /*^
    printf(" l0p1: %f %f %f\n", line0.point1[0], line0.point1[1],line0.point1[2]);
    printf(" l0p2: %f %f %f\n", line0.point2[0], line0.point2[1],line0.point2[2]);
    printf(" l1p1: %f %f %f\n", line1.point1[0], line1.point1[1],line1.point1[2]);
    printf(" l1p2: %f %f %f\n", line1.point2[0], line1.point2[1],line1.point2[2]);
   */

  BSint2lns( line, int_pnt, &dist, &rc );
  /*" dist : %f \n", dist */
  if( rc == BSPARALLEL ){
    /*| lines are parallel */
    /*  Getting Projection point of Next_Pnt on line1 */

    for(i=0;i<3;i++) tmp_pnt[i] = Pnt[i];
    for(i=0;i<3;i++) tmp_pnt[i+3] = line_pt0[i];

    BSproj0(&rc, Next_Pnt, (IGRpoint *)tmp_pnt, int_pnt );
    if( rc != BSSUCC ){
      /*| Can't get a Proj_pnt */
      return( FALSE );
    }
  }

  for(i=0;i<3;i++) Proj_Pnt[i] = int_pnt[i];

  /*" Proj_Pnt : %f %f %f\n", Proj_Pnt[0], Proj_Pnt[1], Proj_Pnt[2] */

return( TRUE );
}

/* ---------------------------------------------------------------------- */
/* VRCbGetSeqList 							- */
/* ---------------------------------------------------------------------- */

IGRint VRCbGetSeqList( NumListId, ListId, SeqList )
IGRint			*NumListId;
struct	GRobj_env	*ListId;
struct	GRobj_env	*SeqList;
/*.VRGetSeqList*/
{
IGRint		i, j, k, status, ret;
IGRint		NumNeiId, NumEndPts, EndPnt[VR_MAX_CPTS];
IGRint		prev, curr, succ, NumObjects;
IGRlong		msg;
IGRshort	NeiCpNum;
struct	GRid    NeiId[VR_MAX_CPTS];
struct	VRCbOrdList	*OrdList;
	
	ret	= TRUE;
	status	= TRUE;
	OrdList = NULL;
	NumObjects = *NumListId;
	/*" NumObjects : %d\n", NumObjects */

	/*| alloc memory */
	/* OrdList = (struct VRCbOrdList *)malloc
	 *	     (NumObjects * sizeof(struct VRCbOrdList) );
	 */

	if( NumObjects ) {
	 OrdList = _MALLOC (NumObjects, struct VRCbOrdList);
	 if( OrdList == NULL ){
		/*| Error in malloc */
		ret = FALSE;
		goto wrapup;
	 }
	}

	/*| fill in the array */
	for( i=0; i<NumObjects; i++ ){
	  OrdList[i].ObjId = ListId[i].obj_id;
	  OrdList[i].flag  = VRCAB_OUT_LIST;
	  OrdList[i].NumIndexList= 0;
	  for(k=0;k<VR_MAX_CPTS;k++)  OrdList[i].IndexList[k] = -1;

	  status = om$send( msg = message VRGeneric.VRGetNeighbors(
					&msg,
					0,
					VR_MAX_CPTS,
					&NumNeiId,
					NeiId,
					&NeiCpNum,
					&ListId[i].mod_env ),
				targetid = ListId[i].obj_id.objid,
				targetos = ListId[i].obj_id.osnum,
				senderid = NULL_OBJID );
	
	  for(j=0;j<NumNeiId;j++ ){
	    /*" check NeiId[%d]=%d in List \n", j, NeiId[j].objid */

	    for(k=0;k<NumObjects;k++){
	      if( NeiId[j].objid == ListId[k].obj_id.objid &&
		  NeiId[j].osnum == ListId[k].obj_id.osnum )
		OrdList[i].IndexList[OrdList[i].NumIndexList++] = k;
	    }		
	  }
	}
/*^
	for(i=0; i<NumObjects; i++){
		printf(" OrdList[%d].ObjId(%d/%d) \n", i, 
			OrdList[i].ObjId.objid, OrdList[i].ObjId.osnum );
		printf(" OrdList[%d].NumIndexList : %d \n", i, OrdList[i].NumIndexList );
		printf(" OrdList[%d].Index : ", i);
		for(k=0;k<VR_MAX_CPTS;k++) printf(" %d ;", OrdList[i].IndexList[k] );
		printf("\n");
	}
*/
	/*| test the input information */
	NumEndPts = 0;
	for(i=0; i<NumObjects; i++){
	  if(( OrdList[i].NumIndexList == 0 ) ||
 	     ( OrdList[i].NumIndexList > 2  )){
	    /*" error OrdList[%d]Num: %d \n",i, OrdList[i].NumIndexList */
	    ret = FALSE;
	    goto wrapup;
	  }
	  if( OrdList[i].NumIndexList == 1 ) EndPnt[NumEndPts++]= i;
	}
/*^
	for(i=0;i<NumEndPts;i++){
	  printf(" EndPts[%d] = %d \n", i, EndPnt[i] );
	}
*/
	/*| create list */
	prev = -1;
	curr = EndPnt[0];
	succ = OrdList[curr].IndexList[0];
	SeqList[0].obj_id = OrdList[curr].ObjId;
	OrdList[curr].flag = VRCAB_IN_LIST;
	
	i=1;
	while( i<NumObjects ){
	  /*" i: %d; prev: %d; curr: %d; succ: %d\n", i, prev, curr, succ */
	  if( succ == -1 ) break;

	  if( OrdList[succ].NumIndexList == 1 &&  
	      OrdList[succ].IndexList[0] == curr ){
	    /*| end pnt of cable */
	    SeqList[i++].obj_id = OrdList[succ].ObjId;
	    OrdList[succ].flag = VRCAB_IN_LIST;
	    succ = -1;
	  }

	  if( OrdList[succ].NumIndexList == 2 ){

	    if(( OrdList[succ].IndexList[0] == curr ) &&
	       ( OrdList[OrdList[succ].IndexList[1]].flag == VRCAB_OUT_LIST )){
		/*| set in list index 1 */
		SeqList[i++].obj_id = OrdList[succ].ObjId;
		OrdList[succ].flag = VRCAB_IN_LIST;
		prev = curr;
		curr = succ;
		succ = OrdList[succ].IndexList[1];
	    }
	    else if(( OrdList[succ].IndexList[1] == curr ) &&
	            ( OrdList[OrdList[succ].IndexList[0]].flag == VRCAB_OUT_LIST )){
		/*| set in list index 2 */
		SeqList[i++].obj_id = OrdList[succ].ObjId;
		OrdList[succ].flag = VRCAB_IN_LIST;
		prev = curr;
		curr = succ;
		succ = OrdList[succ].IndexList[0];
	    }
	    else {
		/*| error in OrdList */
		succ = -1;
	    }
	  }
	}
	/*" value i:%d; Num:%d \n", i, NumObjects */
	if( i < NumObjects ){
	  *NumListId = i;
	  /*" NumListList : %d \n", *NumListId */
	}
/*^
	for(i=0; i<*NumListId; i++){
	  printf(" SeqList[%d].ObjId(%d/%d) \n", i, 
		SeqList[i].obj_id.objid, SeqList[i].obj_id.osnum );
	}
*/
wrapup:
	/* if( OrdList != NULL )	free( OrdList );
	 */
	_FREE( OrdList );
	return( ret );
}


/* ---------------------------------------------------------------------- */
/* CABLE_PR_DEFINED */
/* ---------------------------------------------------------------------- */

int	VRCb_Pr_Defined( File_Ptr, Obj_Name, Length )
/*
 * This routine checks if a cable is or isn't constructed in
 * in the drawing system.
 */
FILE		*File_Ptr;
IGRchar		*Obj_Name;
IGRdouble	Length;
/*.Cable_Pr_Defined*/
{
	/*| Fct CABLE_PR_DEFINED */
/*
 * print result in output file
 */
	fprintf( File_Ptr,
	"update branches set kva_or_length=%.6f where branch_label='%s';\n",
				Length, Obj_Name );
	
return( TRUE );
}

end implementation Root;
