/* $Id: SMSolUtil.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMSolUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSolUtil.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/02/27  17:07:42  pinnacle
# Replaced: smspace/func/SMSolUtil.I for:  by impd for vds
#
# Revision 1.2  1998/02/24  20:56:24  pinnacle
# Replaced: smspace/func/SMSolUtil.I for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/03/21  21:47:24  pinnacle
# Replaced: smspace/func/SMSolUtil.I for:  by jwfrosch for vds.240
#
# Revision 1.6  1996/03/20  18:50:06  pinnacle
# Replaced: smspace/func/SMSolUtil.I for:  by jwfrosch for vds.240
#
# Revision 1.5  1996/03/18  15:30:22  pinnacle
# Replaced: smspace/func/SMSolUtil.I for:  by jwfrosch for vds.240
#
# Revision 1.4  1995/11/01  06:43:06  pinnacle
# Replaced: smspace/func/SMSolUtil.I for:  by rgade for vds.240
#
# Revision 1.3  1995/08/02  19:18:22  pinnacle
# Replaced: smspace/func/SMSolUtil.I for:  by azuurhou for vds.240
#
# Revision 1.2  1994/12/21  22:13:52  pinnacle
# Replaced: smspace/func/SMSolUtil.I by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	03/11/96	HF	Loop once more for the failed split surfaces,
 *				(as a last resort, if everything has failed so far,)
 *				but now execute the older bspmath functionality
 *				in SMextentSrfRg() !!!
 *				(controlled by global var: SMExtSrf_OLD_CODE)
 *
 *				TR : 179600808 179600185 179525874 179528620
 *				    (179418916 179525583 179525758 179525577
 *				     179421367)
 *
 *	02/24/98	HF	Introduced _Pathway_ functionality in order to fix
 *				boolean (union) problems with "Split Volume"
 *				
 *				Changed SMBndS1BySfs() to FIRST use OLD_CODE 
 *				for SMSplS1ByS2() ==>> EMSsurface.EMintsurf_saveside()
 *				and change to NEW_CODE if this fails.
 *				
 *				TR : 179800712 179800665 179800556 179702206
 *				
 *				
 *				
 * -------------------------------------------------------------------*/

/*
 *  History :
 *	CH  : 16 Oct 92	  creation date.
 *
 *      Ravi: 11/01/95   scale is increased to 2.0 from 1.1 in SMExtPlane()
 *                       for the TR #179423574
 */

class implementation    Root;

#include <stdio.h>
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSssprops.h"
#include "bserr.h"

#include "DItypedef.h"
#include "DIdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h"
#include "vdsmacros.h"
#include "v_miscmacros.h"

#include "AS_status.h"

#define VD_DEBUG

#include "VDdebug.h"

#define AS_DEBUG

#define MAX_ROOT 14		       /* Maximum number of roots */

from	GRgraphics	import	GRcopy, GRconstruct, GRgetrang, GRdelete;
from	GRvg		import	GRgeomprops, GRdetplane, GRputsymb, GRgenabsg;
from	EMSdpr		import	EMmake_primitive1;
from    EMSsurface      import  EMgetactiveid, EMintsurf_saveside;
from    EMSsurface      import  EMcompressed_copy;
from    EMSsubbs        import  EMreduce_range, EMmk_nat_bdry;
from    EMSsubbs        import  EMset_props, EMget_props;
from    GRowner		import	GRget_number_components, GRget_components;
from    NDnode		import  ASreturn_go;

extern short _Pathway, _pathway_trim, _pathway_orient;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				GLOBAL VARIABLES				*/
/* 			Defined in: smutil/func/SMxtglbldf.c			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern int	SMExtSrf_OLD_CODE;	/*
					 * Controls execution of OLD or NEW [=default] code
					 * NEW code = execute BSxgmsfdst() in SMextentSrfRg()
					 * OLD code = execute BSsfxttpt () in SMextentSrfRg()
					 *
					 * Obsolete:
					 * ci=toggle_old : toggles SMExtSrf_OLD_CODE
					 */

extern int	SMExtSrf_Fil_Nm;	/*
					 * To control the extension of the names of the
					 * "extent.srf_<nn>" files which are created
					 * when VD_DEBUG == TRUE
					 */

extern int	SMExtSrf_Ext_Opt;	/*
					 * To control "ext_option" for BSxgmsfdst()
					 * in SMextentSrfRg() from within SMBndS1BySfs()
					 */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 *  SMFillDataselect
 *
 *  Function that fills the EMSdataselect structure given the GRid.
 *  Copy the object (will be deleted if success when reducing the range).
 *
 *  PlaneDef is used to avoid doing dynamic memory allocation when planes.
 *  Same for CpObj.
 *
 *  if SupExt is TRUE, this means that if Surf is non planar (and not a
 *  composite or solid) it has to be extended to be sure to cut Surf.
 *
 *  Because the split and save side method does not take into account
 *  the EMSIS_NRML_REVERSED property. Therefore we do it and Rev can be
 *  modified.
 *
 *  Modif to handle surface of EMScomposite which are not really composite
 *  to be manage has there are. To make it working, we start by making
 *  a copy an a compress tree !!!.
 *
 *  Algo:
 *	- get_props(SfProps) of Surf
 *	- copy Surf -> CpObj
 *	- EMgetactiveid on CpObj ->active_id  (if fails active_id=CpObj)
 *	- EMmake_primitive1 on active_id -> tmp_id (if fails tmp_id = active_id)
 *	- TmpSurf = tmp_id
 *	- EMget_props(CSfProps) to TmpSurf
 *	- if (SfProps & NRML_REVERSE) ^ (CSfProps & NRML_REVERSE) means the
 *	  normal has been reversed by the copy (nothing is done)
 *	- Surf2 = CpObj = TmpSurf
 *	- SMGetType(Surf2 ->type) (SOL, COMP_SF, PLAN, SURF)
 *	- if PLAN GRdetplane to Surf2 ->PlaneDef
 *		(fill DataSelect(EMSdata_plane, PlaneDef))
 *	- if SURF && SrfExt (extend the surface to the support )
 *		- Getrange (SupRng) to Sup
 *		- Getrange (SurfRng) to Surf2
 *		- SMextentObjSrfRg(&CpObj)
 *			if fails CpObj = TmpSurf
 *			else GRdelete to Surf2
 *		- Fill DataSelect (EMSdata_object, CpObj)
 *	- else (no extent surf, composite or solid)
 *		- CpObj = TmpSurf
 *		- Fill DataSelect (EMSdata_object, CpObj)
 *	if( not PLAN)
 *		- if not SURF (composite)
 *			- get_objid_at_index on AS_to_comp of CpObj => CompId
 *		- else CompId = CpObj
 *		- EMget_props(&CpProps) to CompId
 *		- if CpProps & NRML_REVERSE   (Change *Rev)
 *			if (*Rev) *Rev = 0
 *			else      *Rev = 1
 *	else (PLAN )
 *		- GRdelete to Surf2
 *
 */

SMFillDataselect
 ( Cnst, Surf, DataSelect, Rev, PlanInf, Sup, SrfExt, PlaneDef, CpObj )
  struct GRvg_construct  *Cnst;	       /* (I) construction list			*/
  struct GRobj_env       *Surf, *Sup;  /* (I) surface for data			*/
  struct EMSdataselect   *DataSelect;  /* (O) structure to fill about Surf	*/
  IGRint                 *Rev;	       /* (I/O) reverse flag for Surf		*/
  IGRboolean              PlanInf;     /* (I)True if plan as infinite		*/
  IGRboolean              SrfExt;      /* (I)True if surface extend		*/
  struct IGRplane        *PlaneDef;    /* (O) plane def of Surf if plane	*/
  struct GRid            *CpObj;       /* (O) output object			*/
{
  IGRlong                 status, loc_msg;
  IGRint                  type;
  unsigned char           SfProps, CSfProps, CpProps;
  IGRboolean              world;
  IGRdouble               SupRng[6], SurfRng[6];
  IGRushort               options;
  struct GRobj_env       *Surf2, TmpSurf;

  struct GRid             active_id, top_lm_id, tmp_id;

  __enterFunction ( name = "SMFillDataselect" );

  options = 0;
  CpObj->osnum = Cnst->env_info->md_id.osnum;
  CpObj->objid = NULL_OBJID;

  /*
   * Because the copy does not always keep the reversed normal flag (case
   * of comp surface), this needs to be verified.
   */

  status = om$send ( msg = message EMSsubbs.EMget_props ( &loc_msg, &SfProps ),
		     senderid = NULL_OBJID,
		     targetid = Surf->obj_id.objid,
		     targetos = Surf->obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
    goto wrapup;

  /*
   *  This does not work well !!!!
   *  therefore => copy + compress tree
   *  status = om$send(msg = message EMSsurface.EMcompressed_copy(&loc_msg,
   *				&Surf->mod_env, Cnst->env_info,
   *				&CpObj->objid, options),
   *			senderid = NULL_OBJID,
   *			targetid = Surf->obj_id.objid,
   *			targetos = Surf->obj_id.osnum);
   */

  if ( 0 )
  {
    /*
     * A frame is a special object and it does nothing on a
     * GRcopy !!!!.
     * Therefore kludge on top of a kludge ...
     * Add one level of return_go.
     * Waiting to solve the pb in the frame object .
     *
     */

    status = om$send ( msg = message NDnode.ASreturn_go ( &TmpSurf.obj_id,
							  &TmpSurf.mod_env.md_env.matrix_type,
							  TmpSurf.mod_env.md_env.matrix ),
		       senderid = NULL_OBJID,
		       targetid = Surf->obj_id.objid,
		       targetos = Surf->obj_id.osnum );
    if ( !( status & 1 ) )
    {
      /*
       * Don't worry and take the original
       */
      TmpSurf = *Surf;
    }
    else
    {
      /*
       * Don't forget the md_id ...
       */
      TmpSurf.mod_env.md_id.objid = NULL_OBJID;
      TmpSurf.mod_env.md_id.osnum = TmpSurf.obj_id.osnum;
    }
    /*
     * If this kludge is added again, change in the copy Surf by TmpSurf
     * End of kludge for the GRcopy of SMframe objects
     */
  }

  status = om$send ( msg = message GRgraphics.GRcopy ( &loc_msg, &Surf->mod_env,
						       Cnst->env_info, &CpObj->objid ),
		     senderid = NULL_OBJID,
		     targetid = Surf->obj_id.objid,
		     targetos = Surf->obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
    goto wrapup;

  /*
   * For the following a function should be written but it should
   * disappear when EMcompressed_copy will work.
   */

  status = om$send ( msg = message EMSsurface.EMgetactiveid ( &loc_msg,
							      &active_id, &top_lm_id ),
		     senderid = NULL_OBJID,
		     targetid = CpObj->objid,
		     targetos = CpObj->osnum );
  if ( !( status & loc_msg & 1 ) )
  {
    __prints ( "Warning getting the top dpr" );
    active_id = *CpObj;
  }

  status = om$send ( msg = message EMSdpr.EMmake_primitive1 ( &loc_msg,
							      Cnst->env_info, &tmp_id ),
		     senderid = NULL_OBJID,
		     targetid = active_id.objid,
		     targetos = active_id.osnum );
  if ( !( status & 1 ) )
  {
    /*
     * Sometimes it fails and
     * I don't know why, but it does not seem important.
     * printf("Warning SMFillDataselect (EMmake_primitive1) \n");
     */
    tmp_id = active_id;
  }

  /*
   * Reduce range has a very strange behaviour:
   *  If the object is in the Rtree the return object (active_id) is not
   *  the good one (first component of a composite surface !!!).In this case
   *  the object (tmp_id) is the good one.
   *  Which a plane (tmp_id) is not in the range tree, it kill the one
   *  which recieved it (tmp_id) and the returned object (active_id) is
   *  the good one !!!!.
   */

  if ( 1 )
  {
    /*
     * We no longer call the EMreduce_range because afterwards the
     * computation of the mass properties are wrong.
     */
    active_id.osnum = tmp_id.osnum ;
    status = om$send ( msg = message EMSsubbs.EMreduce_range ( &loc_msg,
							       Cnst->env_info, &active_id.objid, 0 ),
		       senderid = NULL_OBJID,
		       targetid = tmp_id.objid,
		       targetos = tmp_id.osnum );
    if ( !( status & loc_msg & 1 ) )
    {
      __prints ( "Warning SMFillDataselect, range not reduced" );
      TmpSurf.obj_id = tmp_id;
    }
    else
    {
      if ( om$is_objid_valid(	objid = tmp_id.objid,
				osnum = tmp_id.osnum ) == OM_S_SUCCESS )
	TmpSurf.obj_id = tmp_id;
      else
	TmpSurf.obj_id = active_id;
    }
  }
  else
  {
    TmpSurf.obj_id = tmp_id;
  }

  status = om$send ( msg = message EMSsubbs.EMget_props ( &loc_msg, &CSfProps ),
		     senderid = NULL_OBJID,
		     targetid = TmpSurf.obj_id.objid,
		     targetos = TmpSurf.obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
    goto wrapup;
  if ( ( SfProps & EMSIS_NRML_REVERSED ) ^ ( CSfProps & EMSIS_NRML_REVERSED ) )
  {
    __prints ( "Normal reversed by the copy !!!" );
  }

  TmpSurf.mod_env = *( Cnst->env_info );
  Surf2 = &TmpSurf;
  *CpObj = TmpSurf.obj_id;

  /*
   * Don't use SMGetType2 because already working on the good object
   */
  if ( !( SMGetType ( Surf2, &type, PlanInf ) & 1 ) )
    goto wrapup;
    
  if ( type == PLAN )
  {
    status = om$send ( msg = message GRvg.GRdetplane ( &loc_msg,
						       &Surf2->mod_env.md_env.matrix_type,
						       Surf2->mod_env.md_env.matrix,
						       PlaneDef ),
		       senderid = NULL_OBJID,
		       targetid = Surf2->obj_id.objid,
		       targetos = Surf2->obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
    {
      __print_goto ( "wrapup: Error getting the plane definition" );
      goto wrapup;
    }

    DataSelect->datatype = EMSdata_plane;
    DataSelect->data.plane = PlaneDef;
  }
  else if ( type == SURF && SrfExt == TRUE )
  {
    /*
     * Extention of the SURFACE to the range of the spit surface
     * Get the split surface range
     * Get the splitting surface range
     * If spliiting range greater than split range => extend
     */
    world = TRUE;
    status = om$send ( msg = message GRgraphics.GRgetrang ( &loc_msg,
							    &Sup->mod_env.md_env.matrix_type,
							    Sup->mod_env.md_env.matrix,
							    &world, SupRng ),
		       senderid = NULL_OBJID,
		       targetid = Sup->obj_id.objid,
		       targetos = Sup->obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
    {
      __print_goto ( "wrapup: Error getting range" );
      goto wrapup;
    }

    world = TRUE;
    status = om$send ( msg = message GRgraphics.GRgetrang ( &loc_msg,
							    &Surf2->mod_env.md_env.matrix_type,
							    Surf2->mod_env.md_env.matrix,
							    &world, SurfRng ),
		       senderid = NULL_OBJID,
		       targetid = Surf2->obj_id.objid,
		       targetos = Surf2->obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
    {
      __print_goto ( "wrapup: Error getting range" );
      goto wrapup;
    }

    /*
     * The function makes the extention only if needed
     */
    if ( !( SMextentObjSrfRg ( &loc_msg, Surf2, SupRng, Cnst, TRUE, CpObj ) & 1 ) )
    {
      /*
       * The extention did not work therefore, take the copy
       */
      __prints ( "Warning, surface extention problem" );
      *CpObj = TmpSurf.obj_id;
    }
    else
    {
      /*
       * We are already working on a copy
       * The extention worked and we have to delete the copied object *Surf2
       */
      om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, &Surf2->mod_env ),
		senderid = NULL_OBJID,
		targetid = Surf2->obj_id.objid,
		targetos = Surf2->obj_id.osnum );
      if ( !( status & 1 ) )
	__prints ( "Error SMFillDataselect (delete 555)" );
    }
    DataSelect->datatype = EMSdata_object;
    DataSelect->data.object = CpObj;

    /*
     * Notes: for the planes, we don't need to take into account the reverse
     * flag because  the plane definition already take it into account
     * (GRdetplane method).
     */

  }
  else
  {
    /*
     * Surf without extent, composite surf or solid
     * The copied surface has to be used because it is deleted by the method
     * afterward
     */

    *CpObj = TmpSurf.obj_id;

    DataSelect->datatype = EMSdata_object;
    DataSelect->data.object = CpObj;
  }

  if ( type != PLAN )
  {
    struct GRid             CompId;

    /*
     * This is not done for planes because now the detplane takes into account
     * the reverse normal propertiy (new 2.0).
     */

    if ( type != SURF )
    {
      /*
       * This is a comp surf or a solid and we need to get the first
       * component to be sure that the normal has not been reversed.
       */

      status = om$get_objid_at_index ( objid = CpObj->objid,
				       osnum = CpObj->osnum,
				       p_chanselect = &AS_to_comp,
				       index = 0,
				       objidaddr = &CompId.objid,
				       osnumaddr = &CompId.osnum );
      if ( !( status & 1 ) )
	goto wrapup;
    }
    else
    {
      CompId = *CpObj;
    }

    status = om$send ( msg = message EMSsubbs.EMget_props ( &loc_msg, &CpProps ),
		       senderid = NULL_OBJID,
		       targetid = CompId.objid,
		       targetos = CompId.osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;

    /*
     * The split does not take into account the reversed flag, therefore
     * just do it by hand.
     * Another check has been done if the normal has been reversed
     * during all the copies, extent or others ..
     */

    /*
     * if((SfProps & EMSIS_NRML_REVERSED) ^ (CpProps & EMSIS_NRML_REVERSED))
     * {
     * A reversed occurs somewhere, stange !!!
     * In fact, for a composite surf, it is the reversed flag of the first
     * component that it taken into account and it not necessary matches
     * the reversed flag given by the comp surf itself.
     * Therefore it is sometime regular !!!.
     * }
     */

    if ( CpProps & EMSIS_NRML_REVERSED )
    {
      /*
       * Must reverse the normal flag
       */
      if ( *Rev )
	*Rev = 0;
      else
	*Rev = 1;
    }
  }
  else
  {
    /*
     * If it is a plane, we have to delete the copy ....
     */
    status = om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, &Surf2->mod_env ),
		       senderid = NULL_OBJID,
		       targetid = Surf2->obj_id.objid,
		       targetos = Surf2->obj_id.osnum );
    if ( !( status & 1 ) )
      __prints ( "Error SMFillDataselect (delete 666)" );
  }

  __exitFunction ( name = "SMFillDataselect", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMFillDataselect", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * SMSplS1ByS2:
 *
 *	Split the surface S1 by S2.
 * Algo:
 *
 *	- EMget_props (S1Props) to S1
 *	- SMFillDataSelect(S2->DataSelect2) -> &TmpObj
 *	- if NeedCopy GRcopy (&CpObj) to S1
 *	- else CpObj = S1
 *	- SMDontDoIt (don't do it if 2 colinear planes) -> DoIt
 *	- if not DoIt NewSf = S1; return 0;
 *	- if DataSelect2 = PLANE
 *		- saveside = savept
 *		- if Rev2 savept = plane.point - plane.normal
 *		- else    savept = plane.point + plane.normal
 *		NaturalNormal = 2 (use pt)
 *	- else
 *		- saveside = NULL
 *		- if Rev2 NaturalNormal = 0 (reverse)
 *		- else    NaturalNormal = 1 (natural)
 *	EMintsurf_saveside(dataSelect2, saveside, NaturalNormal ...) to CpObj
 *	if fails goto wrapup;
 *	EMgetactiveid (&active_id) to CpObj  if fails active_id = CpObj
 *	EMmake_primitive1(&tmp_id) to active_id
 *	if fails or active_id = CpObj
 *		if DataSelect2.object is valid GRdelete it
 *	NewSf = active_id = tmp_id
 *	EMget_props(SfProps) to NewSf
 *	if (SfProps & REVERSE)^(S1Props & REVERSE) do nothing
 *	return 1
 *
 *	wrapup: NewSf = NULL_OBJID; return 0
 *
 */

int SMSplS1ByS2 ( Cnst, S1, S2, S2Inf, S2Ext, Rev2, NeedCopy, NewSf )
  struct GRvg_construct  *Cnst;	       /* (I) construction list				*/
  struct GRobj_env       *S1, *S2;     /* (I) surfaces to split				*/
  IGRboolean              S2Inf;       /* (I) True if planar as infinite		*/
  IGRboolean              S2Ext;       /* (I) True if surface as extended		*/
  IGRint                  Rev2;	       /* (I) 1 if splitting surf is reversed		*/
  IGRboolean              NeedCopy;    /* (I) True if the support need to be copied	*/
  struct GRid            *NewSf;       /* (O) New surface (S1 after split )		*/
{
  IGRlong                 status, loc_msg;
  struct IGRplane         PlaneDef2;
  struct EMSdataselect    DataSelect2;
  IGRdouble               pt[6];
  IGRushort               options;
  struct GRid             CpObj, TmpObj;
  struct GRid             tmp_id;
  struct GRid             active_id, top_lm_id;
  IGRdouble              *saveside, savept[3];
  IGRint                  i, NaturalNormal;
  IGRboolean              Work, DoIt;
  unsigned char           S1Props, SfProps;

  __enterFunction ( name = "SMSplS1ByS2", argfmt = "S1 = [%d,%d], S2 = [%d,%d]",
		    args = `S1->obj_id.osnum, S1->obj_id.objid, S2->obj_id.osnum, S2->obj_id.objid` );

  PlaneDef2.point = &pt[0];
  PlaneDef2.normal = &pt[3];

  /*
   * Store if the original is reversed or not for latest varification
   */
  status = om$send ( msg = message EMSsubbs.EMget_props ( &loc_msg, &S1Props ),
		     senderid = NULL_OBJID,
		     targetid = S1->obj_id.objid,
		     targetos = S1->obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
    goto wrapup;

  if ( !( SMFillDataselect ( Cnst, S2, &DataSelect2, &Rev2, S2Inf, S1, S2Ext,
			     &PlaneDef2, &TmpObj ) & 1 ) )
  {
    __print_goto ( "wrapup: Error SMFillDataselect (2)" );
    goto wrapup;
  }

  __printf("DataSelect2.data.object = [%d,%d]", `DataSelect2.data.object->osnum,DataSelect2.data.object->objid`);

  if ( NeedCopy )
  {
    /*
     * The support has to be copied
     */
    CpObj.osnum = Cnst->env_info->md_id.osnum;

    status = om$send ( msg = message GRgraphics.GRcopy ( &loc_msg, &S1->mod_env,
							 Cnst->env_info, &CpObj.objid ),
		       senderid = NULL_OBJID,
		       targetid = S1->obj_id.objid,
		       targetos = S1->obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;
  }
  else
    CpObj = S1->obj_id;

  /*
   * Don't do it if 2 colinear planes
   */

  SMDontDoIt ( S1, S2, &DoIt );
  if ( DoIt != TRUE )
  {
    *NewSf = S1->obj_id;
    goto wrapup;
  }

  /*
   * For plane, Just to see if it work better with a point instead of normal
   */
  if ( ( DataSelect2.datatype == EMSdata_plane ) /*&& 0  */  )
  {
    saveside = savept;

    for ( i = 0; i < 3; i++ )
    {
      if ( Rev2 )
	savept[i] = DataSelect2.data.plane->point[i] - DataSelect2.data.plane->normal[i];
      else
	savept[i] = DataSelect2.data.plane->point[i] + DataSelect2.data.plane->normal[i];
    }
    NaturalNormal = 2;		       /* Use point */
  }
  else
  {
    saveside = NULL;
    if ( Rev2 )
      NaturalNormal = 0;	       /* Reverse */
    else
      NaturalNormal = 1;	       /* Natural */
  }

  options = EMSsfbool_opt_OpenIntPossible |
	    EMSsfbool_opt_doublecheck     |  /* Only if it fails */
	    EMSsfbool_opt_noredraw |
	    EMSsfbool_opt_HandleStop;

  /*
   * Something really strange when it fails the first time even if I don't
   * Modify the option, it will succeed the second time.
   */
  Work = TRUE;
  while ( Work )
  {
    short sav_pathway_trim = _pathway_trim, sav_pathway_orient = _pathway_orient;

    Work = FALSE;		       /* No longer try with the EMSsfbool_opt_doublecheck option */

    _pathway_trim   = 1;
    _pathway_orient = 1;

    status = om$send ( msg = message EMSsurface.EMintsurf_saveside ( &loc_msg,
								     Cnst,
								     &DataSelect2,
								     Cnst->env_info,
								     saveside,	/* saveside point */
								     NaturalNormal,
								     options,
								     NULL,	/* *intobj     */
								     NULL,	/* *auxobj     */
								     TRUE,	/* want status */
								     NULL	/* parent      */  ),
		       senderid = NULL_OBJID,
		       targetid = CpObj.objid,
		       targetos = CpObj.osnum );

    _pathway_trim   = sav_pathway_trim;
    _pathway_orient = sav_pathway_orient;

    if ( !( status & loc_msg & 1 ) )
    {
      /*
       *if(Work)
       * {
       *  Work = FALSE;
       *  options |= EMSsfbool_opt_doublecheck;
       *  printf("Try again\n");
       *  continue;
       * }
       * printf("Error in EMintsurf_saveside\n");
       */
      __print_goto ( "wrapup: Error in EMintsurf_saveside" );
      goto wrapup;
    }
    else
    {
      break;
    }
  }
  
  status = om$send ( msg = message EMSsurface.EMgetactiveid ( &loc_msg,
							      &active_id, &top_lm_id ),
		     senderid = NULL_OBJID,
		     targetid = CpObj.objid,
		     targetos = CpObj.osnum );
  if ( !( status & loc_msg & 1 ) )
  {
    __prints ( "Warning getting the top dpr" );
    active_id = CpObj;
  }

  if ( active_id.objid != CpObj.objid )
  {
    status = om$send ( msg = message EMSdpr.EMmake_primitive1 ( &loc_msg,
								Cnst->env_info, &tmp_id ),
		       senderid = NULL_OBJID,
		       targetid = active_id.objid,
		       targetos = active_id.osnum );
  }

  if ( active_id.objid == CpObj.objid || !( status & 1 ) )
  {
    /*
     * Delete intermediate constructed object
     */
    if ( DataSelect2.datatype == EMSdata_object )
    {
      /*
       * If all has been succesfull the object has been deleted by the message
       * EMmake_primitive1. Therefore only to delete when something went wrong
       */
      if ( 1 )	// For testing purpose set to 0 to keep the object
      {
	if ( om$is_objid_valid ( osnum = DataSelect2.data.object->osnum,
				 objid = DataSelect2.data.object->objid ) == OM_S_SUCCESS )
	{
	  om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, Cnst->env_info ),
		    senderid = NULL_OBJID,
		    targetid = DataSelect2.data.object->objid,
		    targetos = DataSelect2.data.object->osnum );

	  /* delete the object */
	}
      }
      else
      {
	__printf("Temporarily disable delete: object = [%d,%d]", `DataSelect2.data.object->osnum,DataSelect2.data.object->objid`);
      }
    }
    if ( !( status & 1 ) )
      goto wrapup;
    else
      tmp_id = active_id;
  }

  /*
   * Reduce range has a very strange behaviour:
   *  If the object is in the Rtree the return object (active_id) is not
   *  the good one (first component of a composite surface !!!).In this case
   *  the object (tmp_id) is the good one.
   *  Which a plane (tmp_id) is not in the range tree, it kill the one
   *  which recieved it (tmp_id) and the returned object (active_id) is
   *  the good one !!!!.
   */

  active_id.osnum = tmp_id.osnum;
  if ( 1 )
  {
    /*
     * We no longer call the EMreduce_range because afterwards the
     * computation of the mass properties are wrong.
     */
    status = om$send ( msg = message EMSsubbs.EMreduce_range ( &loc_msg,
							       Cnst->env_info, &active_id.objid, 0 ),
		       senderid = NULL_OBJID,
		       targetid = tmp_id.objid,
		       targetos = tmp_id.osnum );
    if ( !( status & loc_msg & 1 ) )
    {
      __prints ( "Warning range not reduced" );
      *NewSf = tmp_id;
    }
    else
    {
      if ( om$is_objid_valid (  objid = tmp_id.objid,
				osnum = tmp_id.osnum ) == OM_S_SUCCESS )
	*NewSf = tmp_id;
      else
	*NewSf = active_id;
    }
  }
  else
  {
    *NewSf = tmp_id;
  }

  /*
   * Verify that the orientation is still the same (better to be carefull with EMS)
   */
  status = om$send ( msg = message EMSsubbs.EMget_props ( &loc_msg, &SfProps ),
		     senderid = NULL_OBJID,
		     targetid = NewSf->objid,
		     targetos = NewSf->osnum );
  if ( !( status & loc_msg & 1 ) )
    goto quit;			/* Do we need to go to QUIT or to WRAPUP ??? */

  if ( ( SfProps & EMSIS_NRML_REVERSED ) ^ ( S1Props & EMSIS_NRML_REVERSED ) )
  {
    /*
     * It seems that it only happens for solid (normal inside) and it is not
     * good to reverse it again.
     * If it is reversed again, a print in the computation of the mass
     * prop (Total volume is negative) appears (because of the normal).
     * Will see.
     * printf("Normal reversed by the split !!!\n");
     * printf("Reverse it again\n");
     * status = om$send(msg = message EMSsubbs.EMset_props(&loc_msg,
     *						(char) EMSIS_NRML_REVERSED,
     *						EMS_O_TOGGLE),
     *			senderid = NULL_OBJID,
     *                    targetid = NewSf->objid,
     *	                targetos = NewSf->osnum);
     * if(!(status & loc_msg & 1)) return 0;
     */
  }

quit:

  __exitFunction ( name = "SMSplS1ByS2", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMSplS1ByS2", argfmt = "%s",  args = "Error Exit" );

  NewSf->objid = NULL_OBJID;
  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

SMGetType ( Surf, Type, WantPlane )
  struct GRobj_env       *Surf;	       /* Surf def			  (O) */
  IGRint                 *Type;	       /* Surface type			  (O) */
  IGRboolean              WantPlane;   /* True return plan if planar	  (I) */
{
  IGRlong                 status, loc_msg;
  GRclassid               ObjClass;
  struct GRprops          properties;
  extern GRclassid        OPP_EMScompsurf_class_id, OPP_EMSplane_class_id;
  extern GRclassid        OPP_EMSsurface_class_id, OPP_EMSsolid_class_id;

  __enterFunction ( name = "SMGetType" );

  status = om$get_classid ( osnum = Surf->obj_id.osnum,
			    objid = Surf->obj_id.objid,
			    p_classid = &ObjClass );

  if ( om$is_ancestry_valid ( subclassid   = ObjClass,
			      superclassid = OPP_EMSsolid_class_id ) == OM_S_SUCCESS )
  {
    *Type = SOL;
  }
  else if ( om$is_ancestry_valid ( subclassid   = ObjClass,
				   superclassid = OPP_EMScompsurf_class_id ) == OM_S_SUCCESS )
  {
    *Type = COMP_SF;
  }
  else if ( om$is_ancestry_valid ( subclassid   = ObjClass,
				   superclassid = OPP_EMSplane_class_id ) == OM_S_SUCCESS )
  {
    *Type = PLAN;
  }
  else if ( om$is_ancestry_valid ( subclassid   = ObjClass,
				   superclassid = OPP_EMSsurface_class_id ) == OM_S_SUCCESS )

  {
    if ( WantPlane )
    {
      status = om$send ( msg = message GRvg.GRgeomprops ( &loc_msg,
							  &Surf->mod_env.md_env.matrix_type,
							  Surf->mod_env.md_env.matrix,
							  &properties ),
			 senderid = NULL_OBJID,
			 targetid = Surf->obj_id.objid,
			 targetos = Surf->obj_id.osnum );
      if ( !( status & loc_msg & 1 ) )
	goto wrapup;
      if ( properties.planar == TRUE )
	*Type = PLAN;
      else
	*Type = SURF;
    }
    else
      *Type = SURF;
  }
  else
  {
    __print_goto ( "wrapup: Bad object type" );
    goto wrapup;
  }

  __exitFunction ( name = "SMGetType", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMGetType", argfmt = "%s",  args = "Error Exit" );

  return 0;

}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

SMExtPlane ( cst, sf, range, ExtSf )
  struct GRvg_construct  *cst;
  struct GRobj_env       *sf;
  IGRdouble              *range;
  struct GRid            *ExtSf;
{
  IGRlong                 status, loc_msg;
  BSrc                    rc;
  struct IGRbsp_surface   plane;
  IGRboolean              InRange;
  struct IGRplane         PlaneDef, PlaneDef2;
  IGRdouble               scale;
  IGRdouble               pt[12], val, BSdotp ();
  IGRdouble               pl_poles[12];		/* 4 poles   */
  IGRdouble               pl_u_knots[12];	/* 4 u_knots */
  IGRdouble               pl_v_knots[12];	/* 4 v_knots */
  extern GRclassid        OPP_EMSplane_class_id;

  __enterFunction ( name = "SMExtPlane" );

  PlaneDef .point  = &pt[0];
  PlaneDef .normal = &pt[3];
  PlaneDef2.point  = &pt[6];
  PlaneDef2.normal = &pt[9];

  status = om$send ( msg = message GRvg.GRdetplane ( &loc_msg,
						     &sf->mod_env.md_env.matrix_type,
						     sf->mod_env.md_env.matrix,
						     &PlaneDef ),
		     senderid = NULL_OBJID,
		     targetid = sf->obj_id.objid,
		     targetos = sf->obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
  {
    __print_goto ( "wrapup: Error getting the plane definition" );
    goto wrapup;
  }

  /*
   * Alloc the surface space 4 poles, 4 u_knots, 4 v_knots
   */
  plane.poles = &pl_poles[0];
  plane.u_knots = &pl_u_knots[0];
  plane.v_knots = &pl_v_knots[0];
  plane.weights = NULL;
  plane.bdrys = NULL;

  scale = 2.0;
  BSplptnorrg ( &range[0], &range[3], PlaneDef.point, PlaneDef.normal, scale,
		&InRange, &plane, &rc );
  if ( rc != BSSUCC )
    goto wrapup;

  if ( InRange != TRUE )
  {
    __prints ( "Warning, bad extention when making the extention plane" );
  }

  /*
   * Construct the plane object
   */
  ExtSf->osnum = cst->env_info->md_id.osnum;
  status = om$construct ( classid = OPP_EMSplane_class_id,
			  p_objid = &ExtSf->objid,
			  osnum = ExtSf->osnum );

  cst->geometry = ( IGRchar * ) & plane;
  status = om$send ( msg = message GRgraphics.GRconstruct ( cst ),
		     senderid = NULL_OBJID,
		     targetid = ExtSf->objid,
		     targetos = ExtSf->osnum );
  if ( !( status & 1 ) )
    goto wrapup;

  cst->geometry = NULL;

  /*
   * Verify that the normal is well oriented
   */
  status = om$send ( msg = message GRvg.GRdetplane ( &loc_msg,
						     &cst->env_info->md_env.matrix_type,
						     cst->env_info->md_env.matrix,
						     &PlaneDef2 ),
		     senderid = NULL_OBJID,
		     targetid = ExtSf->objid,
		     targetos = ExtSf->osnum );
  if ( !( status & loc_msg & 1 ) )
    goto wrapup;

  val = BSdotp ( &rc, PlaneDef2.normal, PlaneDef.normal );
  if ( rc != BSSUCC )
    goto wrapup;

  if ( val < 0 )
  {
    /*
     * Reverse the normal
     */
    status = om$send ( msg = message EMSsubbs.EMset_props ( &loc_msg,
							    ( char ) EMSIS_NRML_REVERSED,
							    EMS_O_TOGGLE ),
		       senderid = NULL_OBJID,
		       targetid = ExtSf->objid,
		       targetos = ExtSf->osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;
  }

  __exitFunction ( name = "SMExtPlane", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMExtPlane", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

SMGetBigRange ( NbSf, Sf, S1, range )
  IGRint                  NbSf;
  struct GRobj_env       *Sf;
  struct GRobj_env       *S1;	       /* Support (NULL if not used)  */
  IGRdouble              *range;
{
  IGRlong                 status, loc_msg;
  IGRint                  i, k;
  IGRboolean              world;
  IGRdouble               r[6], fabs ();

  __enterFunction ( name = "SMGetBigRange" );

  for ( i = 0; i < NbSf; i++ )
  {
    world = TRUE;
    status = om$send ( msg = message GRgraphics.GRgetrang ( &loc_msg,
							    &Sf[i].mod_env.md_env.matrix_type,
							    Sf[i].mod_env.md_env.matrix,
							    &world, r ),
		       senderid = NULL_OBJID,
		       targetid = Sf[i].obj_id.objid,
		       targetos = Sf[i].obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;

    if ( i == 0 )
    {
      for ( k = 0; k < 6; k++ )
	range[k] = r[k];
      continue;
    }

    for ( k = 0; k < 3; k++ )
    {
      if ( r[k + 0] < range[k + 0] )
	range[k + 0] = r[k + 0];
      if ( r[k + 3] > range[k + 3] )
	range[k + 3] = r[k + 3];
    }
  }

  if ( S1 )
  {
    world = TRUE;
    status = om$send ( msg = message GRgraphics.GRgetrang ( &loc_msg,
							    &S1->mod_env.md_env.matrix_type,
							    S1->mod_env.md_env.matrix,
							    &world, r ),
		       senderid = NULL_OBJID,
		       targetid = S1->obj_id.objid,
		       targetos = S1->obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;

    for ( k = 0; k < 3; k++ )
    {
      if ( r[k + 0] < range[k + 0] )
	range[k + 0] = r[k + 0];
      if ( r[k + 3] > range[k + 3] )
	range[k + 3] = r[k + 3];
    }
  }

  __exitFunction ( name = "SMGetBigRange", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMGetBigRange", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * SMKkSlSpSf:
 *
 * Make a solid by split surfaces or return all the splitted surfaces.
 * Return the splitted surfaces only if there is no solid as root...
 *
 */

SMMkSlSpSf ( Cnst, FlCl, NbSf, Sf, SfInf, SfExt, Rev, SurfRev, SpltSf, NewSol )
  struct GRvg_construct  *Cnst;
  IGRboolean              FlCl;		/* floor and ceiling defined		*/
  IGRint                  NbSf;
  struct GRobj_env        Sf[];		/* Surface array			*/
  IGRboolean              SfInf;	/* True, take planar surf as infinit    */
  IGRboolean              SfExt;	/* True, try surface extend		*/
  IGRint                  Rev[];	/* take split as reversed		*/
  IGRboolean              SurfRev[];	/* True => face normal reversed		*/
  struct GRid             SpltSf[];	/* NULL => make a volume		*/

 /* Array of MAX_ROOT just get surfaces */
  struct GRid            *NewSol;	/* Output result			*/

{
  IGRlong                 loc_msg;
  struct GRobj_env        Surf[MAX_ROOT];
  IGRint                  i, k, index;
  IGRint                  Type, SRev[MAX_ROOT];
  struct GRid             NewSrf[MAX_ROOT];
  GRobjid                 ObjId[MAX_ROOT];
  struct GRsymbology      Symb;

  short sav_pathway_trim = _pathway_trim, sav_pathway_orient = _pathway_orient;

  __enterFunction ( name = "SMMkSlSpSf", argfmt = "_pathway_trim = %d, _pathway_orient = %d",  args = `_pathway_trim, _pathway_orient` );

  _pathway_trim   = 1;
  _pathway_orient = 1;

  /*
   *  If one surface is a solid, just split it by other objects
   */
  if ( NbSf > MAX_ROOT )
    NbSf = MAX_ROOT;

  index = -1;
  k = 0;
  for ( i = 0; i < NbSf; i++ )
  {
    if ( !( SMGetType ( &Sf[i], &Type, FALSE ) & 1 ) )
      goto wrapup;
    if ( Type != SOL || index >= 0 )
    {
      Surf[k] = Sf[i];
      SRev[k++] = Rev[i];
    }
    else
      index = i;
  }

  if ( index >= 0 )
  {
    if ( !( SMBndS1BySfs ( Cnst, &Sf[index], TRUE, NbSf - 1, Surf, SRev,
			   SfInf, SfExt, SurfRev[index], NewSol ) & 1 ) )
    {
      /*
       * Bad luck ...
       */
      goto wrapup;
    }
    goto quit;
  }

  /*
   * when floor & ceiling, does not intersect them
   */

  /*
   * No solid, split each faces
   */
  for ( i = 0; i < NbSf; i++ )
  {
    index = 0;
    for ( k = 0; k < NbSf; k++ )
    {
      if ( k == i )
	continue;
      if ( FlCl == TRUE && ( ( i == 0 && k == 1 ) || ( i == 1 && k == 0 ) ) )
	continue;
      Surf[index] = Sf[k];
      SRev[index++] = Rev[k];
    }
    /*
     * The support is always seens as planar (why not) ....
     */
    if ( !( SMBndS1BySfs ( Cnst, &Sf[i], TRUE, index, Surf, SRev,
			   SfInf, SfExt, SurfRev[i], &NewSrf[i] ) & 1 ) )
    {
      /*
       * Bad luck ...
       */
      __print_goto ( "wrapup: Error making a bounded surface" );
      goto wrapup;
    }
  }

  Symb.display_attr = *( Cnst->display );
  Symb.level = Cnst->level;
  if ( SpltSf != NULL )
  {
    om$send ( msg = message GRvg.GRputsymb ( &loc_msg, &Symb ),
	      senderid = NULL_OBJID,
	      targetid = NewSol->objid,
	      targetos = NewSol->osnum );
    /*
     * Just return the splitted surfs
     */
    for ( i = 0; i < NbSf; i++ )
    {
      SpltSf[i] = NewSrf[i];
      om$send ( msg = message GRvg.GRputsymb ( &loc_msg, &Symb ),
		senderid = NULL_OBJID,
		targetid = SpltSf[i].objid,
		targetos = SpltSf[i].osnum );
    }
    goto quit;
  }

  /*
   * Try to make the volume
   */
  for ( i = 0; i < NbSf; i++ )
    ObjId[i] = NewSrf[i].objid;

  if ( !( SMmakeLtdVolume ( &loc_msg, ObjId, NbSf, Cnst, NewSol ) & 1 ) )
  {
    __print_goto ( "wrapup: Failing when making the solid" );
    /*
     * the bounded surfaces have already been deleted
     */
    goto wrapup;
  }

  /*
   * Set to the right symbology
   */
  om$send ( msg = message GRvg.GRputsymb ( &loc_msg, &Symb ),
	    senderid = NULL_OBJID,
	    targetid = NewSol->objid,
	    targetos = NewSol->osnum );

quit:

  _pathway_trim   = sav_pathway_trim;
  _pathway_orient = sav_pathway_orient;

  __exitFunction ( name = "SMMkSlSpSf", argfmt = "Success Exit : _pathway_trim = %d, _pathway_orient = %d",
		   args = `_pathway_trim, _pathway_orient` );

  return 1;

wrapup:

  _pathway_trim   = sav_pathway_trim;
  _pathway_orient = sav_pathway_orient;

  __exitFunction ( name = "SMMkSlSpSf", argfmt = "Error Exit : _pathway_trim = %d, _pathway_orient = %d",
		   args = `_pathway_trim, _pathway_orient` );

  NewSol->objid = NULL_OBJID;
  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * SMGetInnerPt
 *
 * Get a point on a the side of a planar curve
 *
 * Just take care that in some special case it will not work (break point).
 * Therefore it should be better to call it at least twice will deferent
 * u parameters.
 */

SMGetInnerPt ( Cv, md_env, u, Vz, Delta, RevNor, Pt )
  struct GRid            *Cv;		/* Curve Id				(I) */
  IGRdouble               u;		/* Parameter to be used			(I) */
  struct GRmd_env        *md_env;	/* Curve mod env			(I) */
  IGRdouble               Vz[];		/* Normal to the planar curve		(I) */
  IGRdouble               Delta;	/* Distance used to set the point	(I) */
  IGRboolean              RevNor;	/* True reverse the side		(I) */
  IGRdouble               Pt[];		/* Inner point				(O) */

{
  IGRint                  i;
  IGRlong                 status, loc_msg;
  struct IGRbsp_curve    *geom;
  IGRdouble               PtCrv[6], NorVect[3];
  BSrc                    rc;

  __enterFunction ( name = "SMGetInnerPt" );

  status = om$send ( msg = message GRvg.GRgenabsg ( &loc_msg,
						    &md_env->md_env.matrix_type,
						    md_env->md_env.matrix,
						    ( IGRchar ** ) & geom ),
		     senderid = NULL_OBJID,
		     targetid = Cv->objid,
		     targetos = Cv->osnum );
  if ( !( status & loc_msg & 1 ) )
  {
    __print_goto ( "wrapup: Error in GRgenabsg" );
    goto wrapup;
  }

  /*
   * Find corresponding point and tangent at u parameters
   */
  BScveval ( geom, u, 1, PtCrv, &rc );
  if ( rc != BSSUCC )
  {
    __print_goto ( "wrapup: Error in BScveval" );
    goto wrapup;
  }

  BSnorvec ( &rc, &PtCrv[3] );
  if ( rc != BSSUCC )
  {
    __print_goto ( "wrapup: Error in BSnorvec" );
    goto wrapup;
  }

  BScrossp ( &rc, &PtCrv[3], Vz, NorVect );
  if ( rc != BSSUCC )
  {
    __print_goto ( "wrapup: Error in BScrossp" );
    goto wrapup;
  }

  if ( RevNor )
    for ( i = 0; i < 3; i++ )
      Pt[i] = PtCrv[i] - Delta * NorVect[i];
  else
    for ( i = 0; i < 3; i++ )
      Pt[i] = PtCrv[i] + Delta * NorVect[i];

  __exitFunction ( name = "SMGetInnerPt", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMGetInnerPt", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * SMPtInside:
 *
 *  Given a closed planar curved and a point, In = TRUE if the point is inside
 *  else FALSE.
 *
 */

SMPtInside ( Cv, md_env, Pt, Inside )
  struct GRid            *Cv;		/* Curve Id				(I) */
  struct GRmd_env        *md_env;	/* Curve mod env			(I) */
  IGRdouble               Pt[];		/* Point				(I) */
  IGRint                 *Inside;	/* 1=> inside, 2 => on, 0 => outside	(O) */

{
  IGRlong                 status, loc_msg;
  struct IGRbsp_curve    *geom;
  BSrc                    rc;
  IGRboolean              OrientKnow, Orient;

  __enterFunction ( name = "SMPtInside" );

  status = om$send ( msg = message GRvg.GRgenabsg ( &loc_msg,
						    &md_env->md_env.matrix_type,
						    md_env->md_env.matrix,
						    ( IGRchar ** ) & geom ),
		     senderid = NULL_OBJID,
		     targetid = Cv->objid,
		     targetos = Cv->osnum );
  if ( !( status & loc_msg & 1 ) )
  {
    __print_goto ( "wrapup: Error in GRgenabsg" );
    goto wrapup;
  }

  /*
   * This works only on xy plane.
   * We have made this assumption.
   */

  OrientKnow = FALSE;
  BSpt_in_cv ( geom, Pt, OrientKnow, &Orient, Inside, &rc );
  if ( rc != BSSUCC )
  {
    __print_goto ( "wrapup: Error in BSpt_in_cv" );
    goto wrapup;
  }

  __exitFunction ( name = "SMPtInside", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMPtInside", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

SMExtRng ( Range, offset )
  IGRdouble               Range[];	/* Range to extend		(I/O) */
  IGRdouble               offset;	/* How musch (0=> same)		 (I)  */

{
  IGRint                  i;
  BSrc                    rc;
  IGRdouble               vect[3];

  __enterFunction ( name = "SMExtRng" );

  BSmkvec ( &rc, vect, &Range[0], &Range[3] );
  if ( rc != BSSUCC )
    goto wrapup;

  BSnorvec ( &rc, vect );
  if ( rc != BSSUCC )
    goto wrapup;

  for ( i = 0; i < 3; i++ )
  {
    Range[i + 0] = Range[i + 0] - offset * vect[0];
    Range[i + 3] = Range[i + 3] + offset * vect[0];
  }

  __exitFunction ( name = "SMExtRng", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMExtRng", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

SMDontDoIt ( S1, S2, DoIt )
  struct GRobj_env       *S1, *S2;
  IGRboolean             *DoIt;
{
  IGRlong                 status, loc_msg;
  IGRint                  Type1, Type2;
  struct IGRplane         PlaneDef1, PlaneDef2;
  IGRdouble               pt[12], dotp, fabs (), BSdotp ();
  struct GRobj_env        CS1, CS2;
  BSrc                    rc;

  __enterFunction ( name = "SMDontDoIt" );

  PlaneDef1.point = &pt[0];
  PlaneDef1.normal = &pt[3];
  PlaneDef2.point = &pt[6];
  PlaneDef2.normal = &pt[9];

  *DoIt = TRUE;

  if ( !( SMGetType2 ( S1, &Type1, TRUE, TRUE, &CS1 ) & 1 ) )
    goto wrapup;
  if ( !( SMGetType2 ( S2, &Type2, TRUE, TRUE, &CS2 ) & 1 ) )
    goto wrapup;

  if ( Type1 == PLAN && Type2 == PLAN )
  {
    status = om$send ( msg = message GRvg.GRdetplane ( &loc_msg,
						       &CS1.mod_env.md_env.matrix_type,
						       CS1.mod_env.md_env.matrix,
						       &PlaneDef1 ),
		       senderid = NULL_OBJID,
		       targetid = CS1.obj_id.objid,
		       targetos = CS1.obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;

    status = om$send ( msg = message GRvg.GRdetplane ( &loc_msg,
						       &CS2.mod_env.md_env.matrix_type,
						       CS2.mod_env.md_env.matrix,
						       &PlaneDef2 ),
		       senderid = NULL_OBJID,
		       targetid = CS2.obj_id.objid,
		       targetos = CS2.obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;

    dotp = BSdotp ( &rc, PlaneDef1.normal, PlaneDef2.normal );

    if ( fabs ( dotp ) > 0.99999 )
      *DoIt = FALSE;
  }

  /*
   * Should test the range when non infinit planes
   */

  __exitFunction ( name = "SMDontDoIt", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMDontDoIt", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 *  SMGetType2 ...
 *
 *  Given a surface/volume, return if it is a solid, composite surface,
 *  a plane or determine if the surface is planar or not.
 *
 *  The WantReal has been added because this @&%!\% EMS make some
 *  regular surfaces or planes to look like composite surfaces. This
 *  obviously spoils some of the SMAN algorithms (split, ...).
 *
 *  In fact it just calls SMGetType and if the type is SURF but it has
 *  one component -> return the type of that component.
 */

SMGetType2 ( Surf, Type, WantPlane, WantReal, CmpSurf )
  struct GRobj_env       *Surf;	       /* Surf object			(I) */
  IGRint                 *Type;	       /* Surface type			(O) */
  IGRboolean              WantPlane;   /* True return plan if planar	(I) */
  IGRboolean              WantReal;    /* true return real surf type	(I) */
  struct GRobj_env       *CmpSurf;     /* if not null, return the
				        * comp or if not the obj itself	(O)
				        */
{
  IGRlong                 status, loc_msg;
  IGRint                  NbCmp;
  struct GRobj_env        CmpId;

  __enterFunction ( name = "SMGetType2" );

  if ( CmpSurf )
    CmpSurf->obj_id.objid = NULL_OBJID;

  if ( !( SMGetType ( Surf, Type, WantPlane ) & 1 ) )
    goto wrapup;

  if ( CmpSurf )
    *CmpSurf = *Surf;
  if ( WantReal == FALSE || *Type == PLAN ||
       ( *Type == SURF && WantPlane == FALSE ) )
    goto quit;

  /*
   * Have a look at what it is ....
   * Get the components and test if one and what type !!!!
   */

  status = om$send ( msg = message GRowner.GRget_number_components ( &loc_msg,
								     &NbCmp ),
		     senderid = NULL_OBJID,
		     targetid = Surf->obj_id.objid,
		     targetos = Surf->obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
    goto quit;
  if ( NbCmp != 1 )
    goto quit;

  status = om$send ( msg = message GRowner.GRget_components ( &loc_msg,
							      &Surf->mod_env, &CmpId.obj_id, 1, &NbCmp, 0, 0 ),
		     senderid = NULL_OBJID,
		     targetid = Surf->obj_id.objid,
		     targetos = Surf->obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
    goto wrapup;

  if ( NbCmp != 1 )
    goto wrapup;
  CmpId.mod_env = Surf->mod_env;
  if ( !( SMGetType ( &CmpId, Type, WantPlane ) & 1 ) )
    goto wrapup;
  if ( CmpSurf )
    *CmpSurf = CmpId;

quit:

  __exitFunction ( name = "SMGetType2", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SMGetType2", argfmt = "%s",  args = "Error Exit" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 *  Just a useful function to test the intsurf_saveside method (ppl IntSvSide.u)
 */

int SplitSurfSvSide ( Cnst, S1, S2, Rev2 )
  struct GRvg_construct  *Cnst;
  struct GRobj_env       *S1;
  struct GRobj_env       *S2;
  IGRint                  Rev2;
{
  IGRlong                 status, loc_msg;
  struct GRid             CpObj1, CpObj2;
  struct IGRplane         PlaneDef2;
  struct EMSdataselect    DataSelect2;
  IGRdouble               pt[6];
  IGRushort               options;
  IGRdouble              *saveside, savept[3];
  IGRint                  i, NaturalNormal;
  GRobjid                 intobj, auxobj;
  GRclassid               class_id;
  extern GRclassid        OPP_EMSplane_class_id;

  __enterFunction ( name = "SplitSurfSvSide" );

  PlaneDef2.point = &pt[0];
  PlaneDef2.normal = &pt[3];

  __printf ( "SplitSurfSvSide S1: %d, %d  by S2: %d, %d  with Rev2 = %d",
			`S1->obj_id.objid, S1->obj_id.osnum,
			 S2->obj_id.objid, S2->obj_id.osnum, Rev2` );

  CpObj1.osnum = Cnst->env_info->md_id.osnum;
  CpObj2.osnum = Cnst->env_info->md_id.osnum;
  CpObj2.objid = S2->obj_id.objid;

  status = om$send ( msg = message GRgraphics.GRcopy ( &loc_msg, &S1->mod_env,
						       Cnst->env_info, &CpObj1.objid ),
		     senderid = NULL_OBJID,
		     targetid = S1->obj_id.objid,
		     targetos = S1->obj_id.osnum );
  if ( !( status & loc_msg & 1 ) )
    goto wrapup;

  __printf ( "CpObj1: %d, %d", `CpObj1.objid, CpObj1.osnum` );

  status = om$get_classid ( osnum = CpObj2.osnum,
			    objid = CpObj2.objid,
			    p_classid = &class_id );
  if ( !( status & 1 ) )
  {
    __print_goto ( "wrapup: ERROR om$get_classid error" );
    goto wrapup;
  }

  if ( om$is_ancestry_valid ( subclassid = class_id,
			      superclassid = OPP_EMSplane_class_id ) == OM_S_SUCCESS )
  {
    __prints ( "TYPE -> EMSdata_plane" );

    status = om$send ( msg = message GRvg.GRdetplane ( &loc_msg,
						       &S2->mod_env.md_env.matrix_type,
						       S2->mod_env.md_env.matrix,
						       &PlaneDef2 ),
		       senderid = NULL_OBJID,
		       targetid = CpObj2.objid,
		       targetos = CpObj2.osnum );
    if ( !( status & loc_msg & 1 ) )
    {
      __print_goto ( "wrapup: Error getting the plane definition" );
      goto wrapup;
    }

    __printf ( "PlaneDef2. point : %lf, %lf, %lf", `PlaneDef2.point[0] , PlaneDef2.point[1] , PlaneDef2.point[2]` );
    __printf ( "PlaneDef2.normal : %lf, %lf, %lf", `PlaneDef2.normal[0], PlaneDef2.normal[1], PlaneDef2.normal[2]` );

    DataSelect2.datatype = EMSdata_plane;
    DataSelect2.data.plane = &PlaneDef2;

  }
  else
  {
    __prints ( "TYPE -> EMSdata_object" );

    status = om$send ( msg = message GRgraphics.GRcopy ( &loc_msg, &S2->mod_env,
							 Cnst->env_info, &CpObj2.objid ),
		       senderid = NULL_OBJID,
		       targetid = S2->obj_id.objid,
		       targetos = S2->obj_id.osnum );
    if ( !( status & loc_msg & 1 ) )
      goto wrapup;

    __printf ( "CpObj2: %d, %d", `CpObj2.objid, CpObj2.osnum` );

    DataSelect2.datatype = EMSdata_object;
    DataSelect2.data.object = &CpObj2;

    __printf ( "EMSdata_object: %d, %d", `CpObj2.objid, CpObj2.osnum` );
  }

  if ( ( DataSelect2.datatype == EMSdata_plane ) )
  {
    saveside = savept;

    for ( i = 0; i < 3; i++ )
    {
      if ( Rev2 )
	savept[i] = DataSelect2.data.plane->point[i] - DataSelect2.data.plane->normal[i];
      else
	savept[i] = DataSelect2.data.plane->point[i] + DataSelect2.data.plane->normal[i];
    }
    NaturalNormal = 2;		       /* Use point */

    __printf ( "EMSdata_plane : %f,%f,%f", `savept[0], savept[1], savept[2]` );
  }
  else
  {
    saveside = NULL;
    if ( Rev2 )
      NaturalNormal = 0;	       /* Reverse */
    else
      NaturalNormal = 1;	       /* Natural */

    __printf ( "EMSdata_object : NaturalNormal = %d", NaturalNormal );
  }

  options = EMSsfbool_opt_OpenIntPossible |
	 /* EMSsfbool_opt_doublecheck     |  Only if it fails */
	    EMSsfbool_opt_noredraw |
	    EMSsfbool_opt_HandleStop;

  status = om$send ( msg = message EMSsurface.EMintsurf_saveside ( &loc_msg,
								   Cnst,
								   &DataSelect2,
								   Cnst->env_info,
								   saveside,	/* saveside point */
								   NaturalNormal,
								   options,
								   &intobj,	/* *intobj     */
								   &auxobj,	/* *auxobj     */
								   TRUE,	/* want status */
								   NULL		/* parent      */  ),
		     senderid = NULL_OBJID,
		     targetid = CpObj1.objid,
		     targetos = CpObj1.osnum );
  if ( !( status & loc_msg & 1 ) )
  {
    as$status ();
    __printf ( "status: %d, msg: %d", `status, loc_msg` );
    __prints ( "ERROR  EMSsurface.EMintsurf_saveside" );

    if ( loc_msg == EMS_I_NoIntersection )
    {
      __prints ( "msg = EMS_I_NoIntersection" );
    }

    goto wrapup;
  }
  __printf ( "intobj: %d, auxobj: %d", `intobj, auxobj` );

  __exitFunction ( name = "SplitSurfSvSide", argfmt = "%s",  args = "Success Exit" );

  return 1;

wrapup:

  __exitFunction ( name = "SplitSurfSvSide", argfmt = "%s",  args = "Error Exit" );

  return 0;

}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 *  Function : prepare arguments for call to SMSplS1ByS2()
 */

IGRint SMPrepS1BySfs
(
  struct GRvg_construct  *Cnst,		/* (I) construction list		*/
  struct GRobj_env       *Sf,		/* (I) the surfaces			*/
  IGRint                  Rev[],	/* (I) take split on reverse side	*/
  IGRint                 *type,		/* (I) */
  IGRint                 *ErrTab,	/* (I) */
  IGRint                  ErrIndex,	/* (I) */
  IGRint                 *NbDone,	/* (I/O)  */
  IGRboolean             *NeedCopy,	/* (I/O)  */
  IGRboolean              SurfInf,	/* (I) True if plan as infinite		*/
  IGRboolean              SurfExt,	/* (I) True if surfaces as extended	*/
  struct GRid            *NewSf,	/* (O) Output result */
  struct GRobj_env       *Surf		/* (O) Output result */
)
{
  IGRlong                 loc_msg;
  IGRint                  i, j, TstType, TstType2, NbTime, sts = OM_S_SUCCESS;

  __enterFunction ( name = "SMPrepS1BySfs" );

    for ( NbTime = 0; NbTime < 4; NbTime++ )
    {
      if ( NbTime == 0 )
      {
	TstType  = SOL;
	TstType2 = SOL;
      }
      else if ( NbTime == 1 )
      {
	TstType  = PLAN;
	TstType2 = PLAN;
      }
      else if ( NbTime == 2 )
      {
	if ( SurfExt )
	{
	  TstType  = SURF;
	  TstType2 = SURF;
	}
	else
	{
	  TstType  = SURF;
	  TstType2 = COMP_SF;
	}
      }
      else if ( NbTime == 3 )
      {
	if ( SurfExt )
	{
	  TstType  = COMP_SF;
	  TstType2 = COMP_SF;
	}
	else
	  break;
      }
      else
	break;

      for ( j = 0; j < ErrIndex; j++ )
      {
	i = ErrTab[j];

	if ( type[i] == TstType || type[i] == TstType2 )
	{
	  sts = SMSplS1ByS2 ( Cnst, Surf, &Sf[i], SurfInf, SurfExt, Rev[i], *NeedCopy, NewSf );
	  if ( ! ( sts & 1 ) )
	  {
	    /*
	     * May be still good
	     */
	    *NewSf = Surf->obj_id;
	    continue;
	  }
	  /*
	   * Should only do the copy once but the result is strange ....
           * NeedCopy = FALSE;
           */
	  if ( *NbDone > 0 && *NeedCopy == TRUE )
	  {
	    /*
	     * Delete the original support
	     */
	    om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, &Surf->mod_env ),
		      senderid = NULL_OBJID,
		      targetid = Surf->obj_id.objid,
		      targetos = Surf->obj_id.osnum );
	  }
	  (*NbDone)++;
	  *NeedCopy = FALSE;
	  Surf->obj_id  = *NewSf;
	  Surf->mod_env = *( Cnst->env_info );
	}
      }
    }

  __exitFunction ( name = "SMPrepS1BySfs", argfmt = "%s Exit: sts = %d",
			args = `(sts == OM_S_SUCCESS) ? "Success" : "Error", sts` );

  return ( sts );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * SMBndS1BySfs:
 *
 * Bound S1 by all the Sf using split surface
 *  (rev indicate if the surface need to be reversed).
 *
 *  Algo:
 *	- SMGetType2(S1->type1)
 *	- if PLAN & Inf
 *		- SMGetBigRange then SMExtPlane on S1
 *			-> Surf NeddCopy = FALSE
 *	- else		-> Surf = S1 NeddCopy = TRUE
 *	SMGetType2 on each Sf -> type[]
 *
 */

SMBndS1BySfs ( Cnst, S1, Inf, NbSf, Sf, Rev, SurfInf, SurfExt, SurfRev, NewSf )
  struct GRvg_construct  *Cnst;		/* (I) construction list			*/
  struct GRobj_env       *S1, Sf[];	/* (I) the surfaces				*/
  IGRboolean              Inf;		/* (I) If S1 Planar && Inf == TRUE => S1 as infinite*/
  IGRint                  NbSf;		/* (I) nb surf in Sf				*/
  IGRint                  Rev[];	/* (I) take split on reverse side		*/
  IGRboolean              SurfInf;	/* (I) True if plan as infinite			*/
  IGRboolean              SurfExt;	/* (I) True if surfaces as extended		*/
  IGRboolean              SurfRev;	/* (I) True if the output normal reversed	*/
  struct GRid            *NewSf;	/* (O) Output result */

{
  IGRlong                 loc_msg;
  IGRint                  i, type[MAX_ROOT], type1, TstType, TstType2, NbTime, NbDone;
  IGRint                 *ErrTab, ErrIndex;
  IGRint                  sts = OM_S_SUCCESS;
  IGRboolean              NeedCopy;
  IGRdouble               range[6];
  struct GRobj_env        Surf;

  __enterFunction ( name = "SMBndS1BySfs", argfmt = "S1 = [%d,%d]",  args = `S1->obj_id.osnum, S1->obj_id.objid` );

  /*
   * Just to avoid a warning at compilation time
   */
  SurfRev = FALSE;
  ErrTab  = NULL;

  if ( !( SMGetType2 ( S1, &type1, TRUE, TRUE, (struct GRobj_env *)NULL ) & 1 ) )
    goto wrapup;

  if ( type1 == PLAN && Inf )
  {
    /*
     * Extend to the range of all surfaces
     */
    if ( !( SMGetBigRange ( NbSf, Sf, S1, range ) & 1 ) )
    {
      __print_goto ( "wrapup: Error in SMGetBigRange" );
      goto wrapup;
    }
    if ( !( SMExtPlane ( Cnst, S1, range, &Surf.obj_id ) & 1 ) )
    {
      __print_goto ( "wrapup: Error in SMExtPlane" );
      goto wrapup;
    }
    Surf.mod_env = *( Cnst->env_info );
    NeedCopy = FALSE;
  }
  else
  {
    Surf = *S1;
    NeedCopy = TRUE;
  }

  /* ---------------------------------------------------------
   * Algorithm:
   *
   *		 Split and save side which solids.
   *		 Split and save side which planes.
   *		 Split and save side which surfaces.
   *
   * If the surface extend flag is set the extendable (none composite)
   * surfaces are used first (sometime difficult to know the difference
   * between a composite surf and a solid).
   */

  /*
   * Store the type of the surface to do it once ...
   */
  for ( i = 0; i < NbSf; i++ )
  {
    if ( !( SMGetType2 ( &Sf[i], &type[i], TRUE, TRUE, (struct GRobj_env *)NULL ) & 1 ) )
      goto wrapup;
  }

  NbTime   = 0;
  ErrIndex = 0;
  NbDone   = 0;

  ErrTab = _MALLOC ( NbSf, int );
  if ( !ErrTab )
  {
    __print_goto ( "wrapup: Error: allocation problem" );
    goto wrapup;
  }

  /*
   * Initialize the global variables
   *
   *	  SMExtSrf_Ext_Opt = 1;		Polynomial Extend
   *	  SMExtSrf_Fil_Nm  = 0;
   *
   * for BSxgmsfdst() in SMextentSrfRg() ...
   */

  VDExtentSrf_Glbl_Inits();
  
  __printf ( "Extending Surfaces : 1st try ... Ext_Opt = %d, OLD_CODE = %d", `SMExtSrf_Ext_Opt, SMExtSrf_OLD_CODE` );

  for ( NbTime = 0; NbTime < 4; NbTime++ )
  {
    if ( NbTime == 0 )
    {
      TstType  = SOL;
      TstType2 = SOL;
    }
    else if ( NbTime == 1 )
    {
      TstType  = PLAN;
      TstType2 = PLAN;
    }
    else if ( NbTime == 2 )
    {
      if ( SurfExt )
      {
	TstType  = SURF;
	TstType2 = SURF;
      }
      else
      {
	TstType  = SURF;
	TstType2 = COMP_SF;
      }
    }
    else if ( NbTime == 3 )
    {
      if ( SurfExt )
      {
	TstType  = COMP_SF;
	TstType2 = COMP_SF;
      }
      else
	break;
    }
    else
      break;

    for ( i = 0; i < NbSf; i++ )
    {
      if ( type[i] == TstType || type[i] == TstType2 )
      {
	int sts = 0;

	/*
	 * HF: 02/20/98 - 02/27/98 Try OLD_CODE FIRST
	 * The problem has been fixed with a new version of BSextpolcv0() (file "emsfixes/bs/bsextpolcv0.c")
	 * It turns out though, that executing the OLD_CODE is substantially faster in this case :
	 * (cutting a rather complex Bounded Volume from : hull - weather_deck - main_deck - fore & aft planar limits);
	 */

	SMExtSrf_OLD_CODE = 1;

	sts = SMSplS1ByS2 ( Cnst, &Surf, &Sf[i], SurfInf, SurfExt , Rev[i], NeedCopy, NewSf );

	SMExtSrf_OLD_CODE = 0;	////////// If FAIL, continue with NEW BSmath

	if ( !( sts & 1) )
	{
	  sts = SMSplS1ByS2 ( Cnst, &Surf, &Sf[i], SurfInf, SurfExt, Rev[i], NeedCopy, NewSf );
	}

	if ( !( sts & 1 ) )
	{
	  /*
	   * May be still good
	   */
	  *NewSf = Surf.obj_id;

	  /*
	   * AZ/PL : 27 APR 94 : Remove NbDone increment to restart test
	   *			with non splitable surfaces.
	   */
	  if ( ErrTab )
	  {
	    ErrTab[ErrIndex] = i;
	    ErrIndex++;
	  }
	  continue;
	}
	/*
	 * Should only do the copy one but the result is strange ....
         * NeedCopy = FALSE;
         */
	if ( NbDone > 0 && NeedCopy == TRUE )
	{
	  /*
	   * Delete the original support
	   */
	  om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, &Surf.mod_env ),
		    senderid = NULL_OBJID,
		    targetid = Surf.obj_id.objid,
		    targetos = Surf.obj_id.osnum );
	}

	NbDone++;
	NeedCopy = FALSE;
	Surf.obj_id  = *NewSf;
	Surf.mod_env = *( Cnst->env_info );

      }
    }
  }

  /*
   * Loop once more for the failed split surfaces.
   * (Does this make sense; seems to be only repeating 1st try ...???)
   */

  if ( ErrIndex )
  {
    UI_status ( "Special Processing (Polynomial Extend !)..." );

    __prints ( "Extending Surfaces (Polynomial Extend): 2nd try ..." );

    SMExtSrf_Fil_Nm = 1;

    sts = SMPrepS1BySfs (Cnst,		/* (I) construction list		*/
			 Sf,		/* (I) the surfaces			*/
			 Rev,		/* (I) take split on reverse side	*/
			 type,		/* (I) */
			 ErrTab,	/* (I) */
			 ErrIndex,	/* (I) */
			&NbDone,	/* (I/O)  */
			&NeedCopy,	/* (I/O)  */
			 SurfInf,	/* (I) True if plan as infinite		*/
			 SurfExt,	/* (I) True if surfaces as extended	*/
			 NewSf,		/* (O) Output result */
			&Surf		/* (O) Output result */
			);
  }

  /*
   * HF	03/21/96
   *
   * Loop once more for the failed split surfaces, but now with: Linear Extend
   */

  if ( ! ( sts & 1 ) && ErrIndex )
  {
    UI_status ( "Special Processing (Linear Extend !)..." );

    __prints ( "Extending Surfaces (Linear Extend): 3rd try ..." );

    SMExtSrf_Fil_Nm = 2;

    SMExtSrf_Ext_Opt = 0;	/* Linear Extend */

    sts = SMPrepS1BySfs (Cnst,		/* (I) construction list		*/
			 Sf,		/* (I) the surfaces			*/
			 Rev,		/* (I) take split on reverse side	*/
			 type,		/* (I) */
			 ErrTab,	/* (I) */
			 ErrIndex,	/* (I) */
			&NbDone,	/* (I/O)  */
			&NeedCopy,	/* (I/O)  */
			 SurfInf,	/* (I) True if plan as infinite		*/
			 SurfExt,	/* (I) True if surfaces as extended	*/
			 NewSf,		/* (O) Output result */
			&Surf		/* (O) Output result */
		  );

    SMExtSrf_Ext_Opt = 1;	/* Reset to default: Polynomial Extend */
  }

  /*
   * HF	11/02/94
   *
   * Loop once more for the failed split surfaces, but now with: 'SurfExt = FALSE'
   * if 'SurfExt = TRUE' was the starting value !!!
   */

  if ( ! ( sts & 1 ) && ErrIndex && SurfExt )
  {
    IGRboolean sav_SurfExt = SurfExt;

    UI_status ( "Special Processing (No Extend !)..." );

    SurfExt = FALSE;

    __prints ( "Special Processing (No Extend !) : 4th try ... " );

    sts = SMPrepS1BySfs (Cnst,		/* (I) construction list		*/
			 Sf,		/* (I) the surfaces			*/
			 Rev,		/* (I) take split on reverse side	*/
			 type,		/* (I) */
			 ErrTab,	/* (I) */
			 ErrIndex,	/* (I) */
			&NbDone,	/* (I/O)  */
			&NeedCopy,	/* (I/O)  */
			 SurfInf,	/* (I) True if plan as infinite		*/
			 SurfExt,	/* (I) True if surfaces as extended	*/
			 NewSf,		/* (O) Output result */
			&Surf		/* (O) Output result */
		  );

    SurfExt = sav_SurfExt;
  }

  /*
   * HF	03/11/96
   *
   * As a last resort, if everything has failed so far,
   * loop once more for the failed split surfaces,
   * but now execute the older bspmath functionality in SMextentSrfRg() !!!
   * (controlled by global var: SMExtSrf_OLD_CODE)
   */

  if ( ! ( sts & 1 ) && ErrIndex && SMExtSrf_OLD_CODE == FALSE )
  {
    UI_status ( "Special Processing (Alternate bspmath functions)..." );

    SMExtSrf_Fil_Nm   = 3;
    SMExtSrf_OLD_CODE = TRUE;

    __printf ( "Extending Surfaces : 5th try ... OLD_CODE = %d", `SMExtSrf_OLD_CODE` );

    sts = SMPrepS1BySfs (Cnst,		/* (I) construction list		*/
			 Sf,		/* (I) the surfaces			*/
			 Rev,		/* (I) take split on reverse side	*/
			 type,		/* (I) */
			 ErrTab,	/* (I) */
			 ErrIndex,	/* (I) */
			&NbDone,	/* (I/O)  */
			&NeedCopy,	/* (I/O)  */
			 SurfInf,	/* (I) True if plan as infinite		*/
			 SurfExt,	/* (I) True if surfaces as extended	*/
			 NewSf,		/* (O) Output result */
			&Surf		/* (O) Output result */
		  );

    SMExtSrf_OLD_CODE = FALSE;		/* RESET to default value */
  }

  if ( NbDone != NbSf )
  {
    __prints ( "Warning, surfaces outside split area" );
  }

  /*
   * Set to the right symbology
   */
  {
    struct GRsymbology      Symb;

    Symb.display_attr = *( Cnst->display );
    Symb.level = Cnst->level;

    om$send ( msg = message GRvg.GRputsymb ( &loc_msg, &Symb ),
	      senderid = NULL_OBJID,
	      targetid = NewSf->objid,
	      targetos = NewSf->osnum );
  }

  __exitFunction ( name = "SMBndS1BySfs", argfmt = "%s",  args = "Success Exit" );

  _FREE ( ErrTab );
  return 1;

wrapup:

  __exitFunction ( name = "SMBndS1BySfs", argfmt = "%s",  args = "Error Exit" );

  _FREE ( ErrTab );
  return 0;

}

end implementation      Root;
