/* $Id: VDbatDrwMac.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/VDbatDrwmac.I
 *
 * Description:
 *		 File containing macros for interacting with Batch Data object
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDbatDrwMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  20:18:34  pinnacle
# UnInited Return code
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/11  15:36:06  pinnacle
# Replaced: vdbatch/imp/VDbatDrwMac.I for:  by msbraju for vds.240
#
# Revision 1.2  1995/08/31  21:49:04  pinnacle
# Replaced: ./vdbatch/imp/VDbatDrwMac.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:04:24  pinnacle
# Created: vdbatch/imp/VDbatDrwMac.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	raju		creation date
 *	10/30/97	ah		UnInit warning
 ***************************************************************************/

class implementation  VDbatData;

#include <stdio.h>
#include <math.h>
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "v_miscmacros.h"
#include "vderrmacros.h"
#include "vdbatdrwmac.h"

#include "bserr.h"
#include "bsparameters.h"

from GRgraphics   import   GRgetrang;
from GRgraphics   import   GRcopy;
from NDnode	  import   ASreturn_go;
from GRdrawview   import   GRget_model_matrix;


/*--------------------------------------------------------------------------
fe+  VDdrw_batch_process

Desc :  Given process status, this function gives the list of indices
	of dwg views with the given process status.

Return status  : OM status
Return message : MSSUCC : success
		 MSFAIL : failure
fe-
---------------------------------------------------------------------------*/
long  VDdrw_batch_process (
  long			*msg,		/* O - return message	*/
  VD_drwViewStatus	neededProcSts,  /* I - list of drawing views are
					 *     needed for this process status.
					 *     see vdbatdrw.h
					 */
  int			*nbDwgViews,	/* O - no. of dwg views with the
					 *     given process status
					 */
  int			**list		/* O - list of indices
					 *     = NULL, if not needed
					 */
)
{
long			sts1, ii;
struct GRid		dataObj;
VDdrwBatchInfo		*batchInfo = NULL;
long			nbDv;


  /* check input */
  if ( !nbDwgViews )
  {
     *msg = MSINARG;
     sts1 = OM_E_INVARG;
     goto wrapup;
  }

  sts1  = OM_S_SUCCESS;
  *msg = MSSUCC;

  sts1 = VDgetBatDataObj ( msg, &dataObj );
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE, wrapup );

  sts1 = om$send ( msg = message VDbatData.VDretrieveData (
						msg,
						&nbDv,
						&batchInfo,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL ),
		  senderid = NULL_OBJID,
		  targetid = dataObj.objid,
		  targetos = dataObj.osnum );
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE, wrapup );

  /*
   * find no. of drawing views which are of given type
   */
  *nbDwgViews = 0;
  for(ii=0; ii< nbDv; ii++)
     if ( batchInfo[ii].procSts == neededProcSts ) (*nbDwgViews)++;

  if ( *nbDwgViews == 0 ) goto wrapup;

  if ( list )
  {
    *list = (int *) malloc ( sizeof(int) * (*nbDwgViews) );

    *nbDwgViews = 0;
    for(ii=0; ii<nbDv; ii++)
	if ( batchInfo[ii].procSts == neededProcSts ) 
					(*list)[(*nbDwgViews)++] == ii;
  }

wrapup:
  if ( batchInfo ) free ( batchInfo );
  return sts1;

}

/*--------------------------------------------------------------------------
fe+  VDdrw_list_extract

Desc :  This function gives the list of indices
	of dwg views which are selected by the user for extarction.

Return status  : OM status
Return message : MSSUCC : success
		 MSFAIL : failure
fe-
---------------------------------------------------------------------------*/
long  VDdrw_list_extract (
  long			*msg,		/* O - return message	*/
  int			*nbDwgViews,    /* O - no. of dwg views which are
					 *     selected for extraction.
					 */
  int			**list		/* O - list of indices
					 *     = NULL, if not needed
					 */
)
{
long			sts1, nbDv;
int			ii;
struct GRid		dataObj;
VDdrwBatchInfo		*batchInfo = NULL;


  if ( !nbDwgViews )
  {
     *msg = MSINARG;
     sts1 = OM_E_INVARG;
     goto wrapup;
  }

  sts1  = OM_S_SUCCESS;
  *msg = MSSUCC;
  *nbDwgViews = 0;

  sts1 = VDgetBatDataObj ( msg, &dataObj );
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE, wrapup );

  sts1 = om$send ( msg = message VDbatData.VDretrieveData (
						msg,
						&nbDv,
						&batchInfo,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL  ),
		  senderid = NULL_OBJID,
		  targetid = dataObj.objid,
		  targetos = dataObj.osnum  );
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE, wrapup );

  /*
   * find no. of drawing views which are of given type
   */
  for(ii=0; ii<nbDv; ii++)
     if ( batchInfo[ii].props & VD_EXTR_EXTR ) (*nbDwgViews)++;

  if ( *nbDwgViews == 0 ) goto wrapup;

  if ( list )
  {
	*list = (int *) malloc ( sizeof(int) * (*nbDwgViews) );

	*nbDwgViews = 0;
	for(ii=0; ii<nbDv; ii++)
	  if ( batchInfo[ii].props & VD_EXTR_EXTR )
	  {
	    (*list)[*nbDwgViews] = ii;
	    (*nbDwgViews)++;
	  }
  }

wrapup:
  if ( batchInfo )  free ( batchInfo );
  return sts1;

}

/*--------------------------------------------------------------------------
fe+  VDdrw_batch_info

Desc :  Function for enquiring or setting batch control data for a given
	index of drawing view.
	See vdbatdrw.h for attributes which can enquired or set.

Return status  : OM status
Return message : MSSUCC : success
		 MSFAIL : failure
fe-
---------------------------------------------------------------------------*/
long VDdrw_batch_info (
	long		*msg,		/* O - return status */
	int		set_inq,	/* I - either	VD_B_drw_INQUIRE or
					 *		VD_B_drw_SET
					 */
	int		index,		/* I - index of drawing view for which
					 *     attribute needs to be inquired or
					 *     set
					 */
	long		type,		/* I - attr type which is inquired */
	VDdrwBatchInfo  *info		/* I/O-Input->set, Output->inquired */
)
{
	long			sts, nbDv;
	struct GRid		dataObj;
	VDdrwBatchInfo		*batchInfo = NULL;

	SetProc( VDdrw_batch_info ); Begin

	/*
	 * check input arguments
	 */
	if ( !info ){
		*msg = MSINARG;
		sts = OM_E_INVARG;
		goto wrapup;
	}

	sts  = OM_S_SUCCESS;
	*msg = MSSUCC;

	sts = VDgetBatDataObj ( msg, &dataObj );
	VDS_ERR_HNDLR ( "VDgetBatDataObj", sts, *msg, VD_VERBOSE, wrapup );

	__DBGpr_obj(" dataObj ", dataObj );

	sts =
	_VD_SEND_OBJN(	dataObj,
			VDbatData.VDretrieveData (
						msg,
						&nbDv,
						&batchInfo,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL  ));
	VDS_ERR_HNDLR ( "VDgetBatDataObj", sts, *msg, VD_VERBOSE, wrapup );

	if( index < 0 || index > nbDv-1 ){

		*msg = MSFAIL;
		goto wrapup;
	}

	if( set_inq == VD_B_drw_INQUIRE ){

	  if ( type & VD_B_drw_DrwView )
			info->dv	= batchInfo[index].dv;

	  if ( type & VD_B_drw_SolProp )
			info->props	= batchInfo[index].props;

	  if ( type & VD_B_drw_Solid )
			info->solid	= batchInfo[index].solid;

	  if ( type & VD_B_drw_SetupFile )
			strcpy( info->setupFile, batchInfo[index].setupFile );

	  if ( type & VD_B_drw_Layer )
			info->layer	= batchInfo[index].layer;

	  if ( type & VD_B_drw_SolOffset ) 
			info->offset	= batchInfo[index].offset;

	  if ( type & VD_B_drw_3dVw  )
			strcpy( info->drw3dVw, batchInfo[index].drw3dVw );

	  if ( type & VD_B_drw_2dVw  )
			strcpy( info->drw2dVw, batchInfo[index].drw2dVw );
	}

	else if ( set_inq == VD_B_drw_SET ){

	  if ( type & VD_B_drw_SolProp )
			batchInfo[index].props = info->props;

	  if ( type & VD_B_drw_3dVw  )
			strcpy( batchInfo[index].drw3dVw, info->drw3dVw );

	  if ( type & VD_B_drw_2dVw  )
			strcpy( batchInfo[index].drw2dVw, info->drw2dVw );

	  if ( type & VD_B_drw_ProcSts )
			batchInfo[index].procSts = info->procSts ;

	  sts =
	  _VD_SEND_OBJN(dataObj,
			VDbatData.VDpostData(	msg,
						nbDv,
						batchInfo,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL ));
	  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts, *msg, VD_VERBOSE, wrapup );
	}

	wrapup:

		_FREE ( batchInfo );
		return sts;
}

/*--------------------------------------------------------------------------
fe+  VDdrwBatSolidsFromData

Desc :  Given the data of dwg view such as solid, props and offset
	this function optionally gives back solid and offset solid
	of the drawing view which need to be used for locate and
	section cuts.

Return status  : OM status
Return message : MSSUCC : success
		 MSFAIL : failure
fe-
---------------------------------------------------------------------------*/
long VDdrwBatSolidsFromData(
 long			*msg,		/* O - return message */
 struct GRobj_env	*dvSol,		/* I - solid to be used for locating
					 *     objects of DwgView.
					 *     Solid can be DwgView, Solid,
					 *     View vol, Mdl View.
					 */
 long			props,		/* I - properties of the dwg view */
 double			offset,		/* I - offset needed		  */
 struct GRobj_env	*solid,		/* O - solid before offsetting
					 *      = NULL, if not needed
					 */
 struct GRobj_env	*offsetSol	/* O - offset solid for the dwg view
					 *	= NULL, if not needed
					 */
)
{
long			sts1;

struct GRmd_env		modEnv;
struct IGRdisplay	disp;
short			level;
struct GRvg_construct	cst;
struct GRid		tmpSol;
struct GRmd_env		tmpSolEnv;
int			sizbuf,
			NoBytesRet;
GRrange			range;
IGRboolean		world;

struct GRid		dvobj, vvobj, mvobj;
double			chtol;

  /* check input */
  if (  !dvSol  ||  (!offsetSol && !offsetSol)  )
  {
     *msg = MSINARG;
     sts1 = OM_E_INVARG;
     goto wrapup;
  }

  sts1  = OM_S_SUCCESS;
  *msg = MSSUCC;

  /*
   * fill construction list
   */
  sizbuf = sizeof ( struct GRmd_env );
  gr$get_module_env(
		   msg    = msg,
		   sizbuf = &sizbuf,
		   buffer = &modEnv,
		   nret   = &NoBytesRet );
/*
  modEnv.md_id.objid = NULL_OBJID;
*/

  sizbuf = sizeof ( struct IGRdisplay );
  gr$get_active_display(
		   msg    = msg,
		   sizbuf = &sizbuf,
		   buffer = &disp,
		   nret   = &NoBytesRet );

  sizbuf = sizeof ( short );
  gr$get_active_level(
		   msg    = msg,
		   sizbuf = &sizbuf,
		   buffer = &level,
		   nret   = &NoBytesRet );

  cst.msg      = msg;
  cst.env_info = &modEnv;
  cst.display  = &disp;
  cst.level    = level;
  cst.geometry = NULL;
  cst.newflag  = FALSE;
  cst.properties = 0;
  cst.class_attr = NULL;
  cst.name       = NULL;

  /*
   * get solid for boolean operations
   */
  if ( props & VD_DV )
  {
    /* construct solid from range */

    dvobj = dvSol->obj_id;

    world = 1;
    sts1 = om$send ( msg = message GRgraphics.GRgetrang (
					msg,
					&modEnv.md_env.matrix_type,
					modEnv.md_env.matrix,
					&world,
					range ),
		     senderid = NULL_OBJID,
		     targetid = dvobj.objid,
		     targetos = dvobj.osnum  );
    VDS_ERR_HNDLR( "GRgraphics.GRgetrang", sts1, *msg, VD_VERBOSE, wrapup );

    sts1 = VDconstruct_box( msg, range, &range[3], &cst, &tmpSol );
    VDS_ERR_HNDLR( "VDconstruc_box", sts1, *msg, VD_VERBOSE, wrapup );
    tmpSolEnv = *(cst.env_info);
  }
  else if ( props & VD_SOLID )
  {
    tmpSol = dvSol->obj_id;
    tmpSolEnv = dvSol->mod_env;
  }
  else if ( props & VD_VV )
  {
     vvobj = dvSol->obj_id;
     sts1 = om$send ( msg = message NDnode.ASreturn_go (
					&tmpSol,
					NULL,
					NULL ),
			    senderid = NULL_OBJID,
			    targetid = vvobj.objid,
			    targetos = vvobj.osnum  );
     VDS_ERR_HNDLR( "NDnode.ASreturn_go", sts1, 1, VD_VERBOSE, wrapup );
     tmpSolEnv = dvSol->mod_env;
  }
  else if ( props & VD_MDLV )
  {
     mvobj = dvSol->obj_id;
     sts1 = om$send ( msg = message NDnode.ASreturn_go (
					&tmpSol,
					NULL,
					NULL ),
			    senderid = NULL_OBJID,
			    targetid = mvobj.objid,
			    targetos = mvobj.osnum  );
     VDS_ERR_HNDLR( "NDnode.ASreturn_go", sts1, 1, VD_VERBOSE, wrapup );
     tmpSolEnv = dvSol->mod_env;
  }
  else
  {
     printf("Error at line %d in file %s", __LINE__, __FILE__ );
  }

  if ( solid )
  {
     solid->obj_id = tmpSol;
     solid->mod_env = tmpSolEnv;
  }

  if ( offsetSol )
  {
    /*
     * construct the offset solid
     */
    BSEXTRACTPAR ( msg, BSTOLCHRDHT, chtol );
    if ( *msg == BSSUCC )
	*msg = MSSUCC;
    else
    {
	printf("%s[%d] : BSEXTRACTPAR ERROR", __FILE__, __LINE__);
	*msg = MSFAIL;
	goto wrapup;
    }

    if ( fabs( offset ) < chtol * 2.0 )
    {
       sts1 = om$send ( msg = message GRgraphics.GRcopy (
					msg,
					&tmpSolEnv,
					cst.env_info,
					&offsetSol->obj_id.objid ),
			targetid = tmpSol.objid,
			targetos = tmpSol.osnum,
			senderid = NULL_OBJID   );
       VDS_ERR_HNDLR( "GRcopy", sts1, *msg, VD_VERBOSE, wrapup );

       offsetSol->obj_id.osnum	= cst.env_info->md_id.osnum;
       offsetSol->mod_env	= *(cst.env_info);
    }
    else
    {
       sts1 = VDoffsetSolid(	msg, &tmpSol, &tmpSolEnv, &cst, offset,
				&offsetSol->obj_id.objid );
       VDS_ERR_HNDLR( "VDoffsetSolid", sts1, *msg, VD_VERBOSE, wrapup );
       offsetSol->obj_id.osnum = cst.env_info->md_id.osnum;

       offsetSol->mod_env = *( cst.env_info );
    }
  } /* if ( offsetSol ) */

  if ( !solid && (props & VD_DV) )
  {
       gr$delete_object ( msg	 = msg,
			  md_env = &tmpSolEnv,
			  object_id = &tmpSol  );
       VDS_ERR_HNDLR( "VDoffsetSolid", sts1, *msg, VD_VERBOSE, wrapup );
  }

wrapup:
  return sts1;
}



/*--------------------------------------------------------------------------
fe+  VDdrwBatSolidsFromIndex

Desc :  Given dwg view index , this function optionally gives back
	solid and offset solid of the drawing view

Return status  : OM status
Return message : MSSUCC : success
		 MSFAIL : failure
fe-
---------------------------------------------------------------------------*/
long VDdrwBatSolidsFromIndex (
 long			*msg,		/* O - return message */
 int			index,		/* I - index of drawing view */
 struct GRobj_env	*solid,		/* O - solid before offsetting 
					 *     = NULL, if not needed
					 */
 struct GRobj_env	*offsetSol	/* O - offset solid for the dwg view
					 *     = NULL, if not needed
					 */
)
{
long			sts1, nbDv;
struct GRid		dataObj;
VDdrwBatchInfo		*batchInfo = NULL;

  /* check input */
  if ( !solid && !offsetSol )
  {
     *msg = MSINARG;
     sts1 = OM_E_INVARG;
     goto wrapup;
  }

  sts1  = OM_S_SUCCESS;
  *msg = MSSUCC;

  sts1 = VDgetBatDataObj ( msg, &dataObj );
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE, wrapup );

  sts1 = om$send ( msg = message VDbatData.VDretrieveData (
						msg,
						&nbDv,
						&batchInfo,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL ),
		  senderid = NULL_OBJID,
		  targetid = dataObj.objid,
		  targetos = dataObj.osnum  );
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE, wrapup );

  if ( index < 0 || index > nbDv-1 )
  {
     *msg = MSFAIL;
     goto wrapup;
  }

  sts1 = vd$drw_solids_from_data( 
			msg 	= msg,
			dv_sol  = &batchInfo[index].solid,
			props	= batchInfo[index].props,
			offset	= batchInfo[index].offset,
			solid	= solid,
		     offset_sol = offsetSol );
  VDS_ERR_HNDLR( "vd$drw_solids_from_data", sts1, *msg, VD_VERBOSE, wrapup );

	wrapup:
		_FREE( batchInfo );
		return sts1;
}



/*--------------------------------------------------------------------------
fe+  VDdrw_get_globInfo

Desc :  Gets the global information of batch extraction such as
	queue name, login, passwd, process status and locate window.

Return status  : OM status
Return message : MSSUCC : success
		 MSFAIL : failure
fe-
---------------------------------------------------------------------------*/
long  VDdrw_get_globInfo (
  long		*msg,		/* O - return status */
  char		*queue,		/* O - queue name    */
				/*     = NULL, if not required */
  char		*login,		/* O - local login   */
				/*     = NULL, if not required */
  char		*passwd,	/* O - passwd for login */
				/*     = NULL, if not required */
  IGRboolean	*procType,	/* O - process type ( VD_BATCH_PROC or
				 *     VD_INTER_PROC )
				 *     = NULL, if not required.
				 */
  struct GRid	*locateWin	/* O - locate window */
				/*     = NULL, if not required */
)
{
struct  GRid	dataObj;
long		nbDv,
		sts1;
IGRboolean	prType ;

  sts1 = VDgetBatDataObj ( msg, &dataObj );
  VDS_ERR_RPT ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE );

  sts1 = om$send ( msg = message VDbatData.VDretrieveData (
						msg,
						&nbDv,
						NULL,
						queue,
						login,
						passwd,
						&prType,
						locateWin ),
		  senderid = NULL_OBJID,
		  targetid = dataObj.objid,
		  targetos = dataObj.osnum  );
  VDS_ERR_RPT ( "VDgetBatDataObj", sts1, *msg, VD_VERBOSE );

  if ( procType ) *procType = prType ;

  return sts1;

}


long   VDselObjOfDV(
  long			*msg,
  struct GRid		*dvId,
  struct GRmd_env	*dvEnv,
  int			*nbObj,
  struct GRobj_env	*objects
)
{
long			sts1 = OM_E_INVARG;  // Fix return code warning
struct GRobj_env	*tmpObjs = NULL;
IGRmatrix		dvMatrix;
IGRboolean		match;
int			ii, jj, count;
double			*tmpMatrix = NULL;
			/* tmp variable, should not be freed */

   if ( !dvId || !dvEnv || !nbObj || !objects )
   {
     *msg = MSINARG;
     sts1 = OM_E_INVARG;
     goto wrapup;
   }

   if ( ! *nbObj ) goto wrapup;

   tmpObjs = (struct GRobj_env *) malloc ( sizeof(struct GRobj_env) *
					   (*nbObj) );
   if ( !tmpObjs )
   {
      *msg = MSFAIL;
      goto wrapup;
   }

   /*
    * copy objects to tmpobjs
    */
   for ( ii=0; ii< *nbObj; ii++ ) tmpObjs[ii] = objects[ii];

   __DBGpr_mat ( "matrix of object1", objects[0].mod_env.md_env.matrix );

   /*
    * get matrix of dwg view
    */
   sts1 = om$send ( msg = message GRdrawview.GRget_model_matrix
				  ( msg, dvEnv, 0, dvMatrix ),
		    targetid = dvId->objid,
		    targetos = dvId->osnum,
		    senderid = NULL_OBJID   );
   VDS_ERR_HNDLR ( "GRget_model_matrix", sts1, *msg, VD_VERBOSE, wrapup );
   __DBGpr_mat( "dv matrix", dvMatrix );

   /*
    * for each object find if it has the same matrix that of dv.
    * If yes add to list.
    */
   count = 0;
   for(ii=0; ii<*nbObj; ii++)
   {
	match = 1;
	tmpMatrix = tmpObjs[ii].mod_env.md_env.matrix;
	for(jj=0; jj<16; jj++)
	{
	   if ( fabs(tmpMatrix[jj] - dvMatrix[jj]) > 1.0E-06 )
	   {
		match = 0;
		break;
	   }
	}

	/* matrices are same */
	if ( match )
	{
	   objects[count] = tmpObjs[ii];
	   count++;
	}
   }

   objects = (struct GRobj_env *) realloc ( objects,
					    sizeof(struct GRmd_env) * count );

   *nbObj = count;

wrapup:
   if ( tmpObjs ) free ( tmpObjs );
   return sts1;

}

end implementation VDbatData;

