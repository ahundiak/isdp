
/* $Id: VRCOPFunc3i.I,v 1.2 2002/04/10 15:04:37 louis Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        route/vrco/VRCOPFunc3i.I
 *
 * Description:
 *
 * Implementation file for VRCO service functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRCOPFunc3i.I,v $
 *      Revision 1.2  2002/04/10 15:04:37  louis
 *      TR5649-standardize tolerances
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/02/21  20:51:38  pinnacle
# Replaced: vrco/VRCOPFunc3i.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/03/20  00:10:38  pinnacle
# Replaced: vrco/VRCOPFunc3i.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/04  21:40:56  pinnacle
# Replaced: vrco/VRCOPFunc3i.I for:  by hverstee for route240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/02/91          ON            New
 *      01/04/96          HV            Cleanup
 *      02/14/00          law           tr179900985-cannot use == with doubles
 *      04/05/02          law           TR5649-standardize tolerance with
 *                                       VRGetTol
 *
 * -------------------------------------------------------------------*/

class implementation VRCOProduct;

#include "nddef.h"
#include "ndmacros.h"
#include "exmacros.h"
#include "VRMath.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbParamDef.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "MS.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bsparameters.h"
%safe
#include <math.h>
%endsafe

#define AS_DEBUG
/*
#define MY_DEBUG
*/

from 	ACncpx		import	ACgive_structure;
from 	ACrg_collect	import	ACmod_list_attribute;
from 	VRGeneric	import	VRGetCompDesc;

/* ====================================================================	*/

IGRint VRUpdateParameterBox (IGRlong    *msg, /* return code          */
                      struct ACrg_coll  *Collection, /* Just one collection  */
                      struct GRid       *ParameterBoxId)/* Old Parameter Box */
/*.VRUpdateParameterBox */
{
  IGRlong			status;

  status =
  VR$ModifyCollection( p_msg                   = msg,
                       Operation               = VR_UPDATE_COLL,
		       p_ParamsListToModify    = Collection,
         	       NbParamsToModify        = 1,
                       p_OutputCollectionId    = ParameterBoxId);
  as$status();

  return OM_S_SUCCESS;

} /* end function VRUpdateParameterBox */

/* ====================================================================	*/

IGRint VRCheckReducingConsistency (IGRshort    nProduct,
                            struct GRid       *ParamBoxId,
                            struct GRmd_env   *pMdEnv)
/*.VRCheckReducingConsistency */
{
  IGRlong		status;
  IGRint 		FootIndex = -1, retstatus;
  IGRint                retcode;
  IGRdouble		dGDiam, dRDiam;
  IGRdouble		dWidthGreen, dDepthGreen, dWidthRed, dDepthRed;
  struct ret_struct	ParamAttr;

  if (nProduct == VR_PIPING)
  {
    /* Process for Piping */
    status = om$send( msg      = message ACncpx.ACgive_structure
			       ( &retstatus, &FootIndex, VR_N_GDIAMETER_DB,
				 &ParamAttr, pMdEnv),
		    senderid = NULL_OBJID,
		    targetid = ParamBoxId->objid,
		    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dGDiam = ParamAttr.var.root_pm_st.value;

    status = om$send( msg      = message ACncpx.ACgive_structure
			       ( &retstatus, &FootIndex, VR_N_RDIAMETER_DB,
				 &ParamAttr, pMdEnv),
		    senderid = NULL_OBJID,
		    targetid = ParamBoxId->objid,
		    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dRDiam = ParamAttr.var.root_pm_st.value;
    /*"Green and Red got from ParamBox are %lf,%lf\n", dGDiam, dRDiam */

    retcode = (dGDiam > dRDiam) ? TRUE : FALSE;
  }
  else
  {
    /*| Process for Hvac and for Race Way */
    status = om$send( msg      = message ACncpx.ACgive_structure
			       ( &retstatus, &FootIndex, VR_N_WIDTH1_DB	,
				 &ParamAttr, pMdEnv),
		      senderid = NULL_OBJID,
		      targetid = ParamBoxId->objid,
		      targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dWidthGreen = ParamAttr.var.root_pm_st.value;
    status = om$send( msg      = message ACncpx.ACgive_structure
			       ( &retstatus, &FootIndex, VR_N_DEPTH1_DB	,
				 &ParamAttr, pMdEnv),
		    senderid = NULL_OBJID,
		    targetid = ParamBoxId->objid,
		    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dDepthGreen = ParamAttr.var.root_pm_st.value;
    status = om$send( msg      = message ACncpx.ACgive_structure
			       ( &retstatus, &FootIndex, VR_N_WIDTH2_DB	,
				 &ParamAttr, pMdEnv),
		    senderid = NULL_OBJID,
		    targetid = ParamBoxId->objid,
		    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dWidthRed = ParamAttr.var.root_pm_st.value;
    status = om$send( msg      = message ACncpx.ACgive_structure
			       ( &retstatus, &FootIndex, VR_N_DEPTH2_DB	,
				 &ParamAttr, pMdEnv),
		    senderid = NULL_OBJID,
		    targetid = ParamBoxId->objid,
		    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dDepthRed = ParamAttr.var.root_pm_st.value;

    /*"WidthGreen and WidthRed got are %lf,%lf\n", dWidthGreen, dWidthRed */
    /*"DepthGreen and DepthRed got are %lf,%lf\n", dDepthGreen, dDepthRed */
 
    /**** TR179900985-
      Checking if dWidthGreen == dWidthRed and dDepthGreen == dDepthRed
    *****************/
    if((fabs(dWidthGreen - dWidthRed) < VRGetTol(VR_DIST_TOL)) &&
       (fabs(dDepthGreen - dDepthRed) < VRGetTol(VR_DIST_TOL)) )
       retcode = FALSE;
    else
       retcode = TRUE;
    /****** ERROR-cannot use == with doubles *******
    retcode = ((dWidthGreen == dWidthRed) && (dDepthGreen == dDepthRed)) ?
                 FALSE : TRUE;
    ***********************************************/
  }

  return (retcode);
} /* end function VRCheckReducingConsistency */

/* ====================================================================	*/
/* This function retrieves CompTopo and CompType of Component.		*/

IGRint VRGetSpecialInformations (IGRlong     *msg,
                                 IGRshort    *nCompTopo,
                                 IGRshort    *nCompType,
                          struct GRid        *CompId,
                          struct GRmd_env    *MdEnv)

/*.VRGetSpecialInformations */
{
  struct ACrg_coll	Collection;
  IGRlong               status;

  *msg = MSSUCC;

  if (*nCompTopo)
  {
    strcpy ( Collection.name , VR_N_COMP_TOPO_IN ); 
    Collection.desc.type = AC_ATTRIB_DOUBLE;
    status =
    om$send( msg = message VRGeneric.VRGetCompDesc ( msg, &Collection, MdEnv),
        senderid = NULL_OBJID,
        targetid = CompId->objid,
        targetos = CompId->osnum );
    as$status();
    as$status (sts = *msg);
    *nCompTopo = (IGRshort) Collection.desc.value.att_exp;
  }

  if (*nCompType)
  {
    strcpy ( Collection.name , VR_N_COMP_TYPE_IN ); 
    Collection.desc.type = AC_ATTRIB_DOUBLE;
    status =
    om$send( msg = message VRGeneric.VRGetCompDesc ( msg, &Collection, MdEnv),
        senderid = NULL_OBJID,
        targetid = CompId->objid,
        targetos = CompId->osnum );
    as$status();
    as$status (sts = *msg);
    *nCompType = (IGRshort) Collection.desc.value.att_exp;
  }

  return OM_S_SUCCESS;

} /* end function VRGetSpecialInformations */

/* ==================================================================== */

IGRint VREqualSizeForce (IGRshort    nProduct,
                  struct GRid       *ParamBoxId,
                  struct GRmd_env   *pMdEnv)
/*.VREqualSizeForce*/
{
  IGRlong               status;
  IGRlong               retmsg;
  IGRint                FootIndex = -1, retstatus;
  IGRdouble             dGDiam, dRDiam;
  IGRdouble             dWidthGreen, dDepthGreen, dWidthRed, dDepthRed;
  struct ret_struct     ParamAttr;
  struct ACrg_coll      ModAttr;

  if (nProduct == VR_PIPING)
  {
    /* Process for Piping */
    status = om$send( msg      = message ACncpx.ACgive_structure
                               ( &retstatus, &FootIndex, VR_N_GDIAMETER_DB,
                                 &ParamAttr, pMdEnv),
                    senderid = NULL_OBJID,
                    targetid = ParamBoxId->objid,
                    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dGDiam = ParamAttr.var.root_pm_st.value;

    status = om$send( msg      = message ACncpx.ACgive_structure
                               ( &retstatus, &FootIndex, VR_N_RDIAMETER_DB,
                                 &ParamAttr, pMdEnv),
                    senderid = NULL_OBJID,
                    targetid = ParamBoxId->objid,
                    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dRDiam = ParamAttr.var.root_pm_st.value;
    /*"Green and Red got from ParamBox are %lf,%lf\n", dGDiam, dRDiam */

    /*  force gdia to be equal to rdia  */

    strcpy (ModAttr.name, VR_N_GDIAMETER_DB);
    ModAttr.desc.type = AC_ATTRIB_DOUBLE;
    ModAttr.desc.value.att_exp = dRDiam;

    status =
    om$send( msg = message ACrg_collect.ACmod_list_attribute
                                        (&retmsg, 1, &ModAttr),
        senderid = NULL_OBJID,
        targetid = ParamBoxId->objid,
        targetos = ParamBoxId->osnum );
    as$status();
  }
  else
  {
    /*| Process for Hvac and for Race Way */
    status = om$send( msg      = message ACncpx.ACgive_structure
                               ( &retstatus, &FootIndex, VR_N_WIDTH1_DB ,
                                 &ParamAttr, pMdEnv),
                      senderid = NULL_OBJID,
                      targetid = ParamBoxId->objid,
                      targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dWidthGreen = ParamAttr.var.root_pm_st.value;
    status = om$send( msg      = message ACncpx.ACgive_structure
                               ( &retstatus, &FootIndex, VR_N_DEPTH1_DB ,
                                 &ParamAttr, pMdEnv),
                    senderid = NULL_OBJID,
                    targetid = ParamBoxId->objid,
                    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dDepthGreen = ParamAttr.var.root_pm_st.value;
    status = om$send( msg      = message ACncpx.ACgive_structure
                               ( &retstatus, &FootIndex, VR_N_WIDTH2_DB ,
                                 &ParamAttr, pMdEnv),
                    senderid = NULL_OBJID,
                    targetid = ParamBoxId->objid,
                    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dWidthRed = ParamAttr.var.root_pm_st.value;
    status = om$send( msg      = message ACncpx.ACgive_structure
                               ( &retstatus, &FootIndex, VR_N_DEPTH2_DB ,
                                 &ParamAttr, pMdEnv),
                    senderid = NULL_OBJID,
                    targetid = ParamBoxId->objid,
                    targetos = ParamBoxId->osnum );
    as$status( action = RET_STATUS );
    dDepthRed = ParamAttr.var.root_pm_st.value;

    /*"WidthGreen and WidthRed got are %lf,%lf\n", dWidthGreen, dWidthRed */
    /*"DepthGreen and DepthRed got are %lf,%lf\n", dDepthGreen, dDepthRed */

    /*  force width1 to be equal to width2  */

    strcpy (ModAttr.name, VR_N_WIDTH1_DB);
    ModAttr.desc.type = AC_ATTRIB_DOUBLE;
    ModAttr.desc.value.att_exp = dWidthRed;

    status =
    om$send( msg = message ACrg_collect.ACmod_list_attribute
                                        (&retmsg, 1, &ModAttr),
        senderid = NULL_OBJID,
        targetid = ParamBoxId->objid,
        targetos = ParamBoxId->osnum );
    as$status();

#ifdef MY_DEBUG
    printf (" force width1 to %f\n",dWidthRed);
#endif

    /*  force depth1 to be equal to depth2  */

    strcpy (ModAttr.name, VR_N_DEPTH1_DB);
    ModAttr.desc.type = AC_ATTRIB_DOUBLE;
    ModAttr.desc.value.att_exp = dDepthRed;

    status =
    om$send( msg = message ACrg_collect.ACmod_list_attribute
                                        (&retmsg, 1, &ModAttr),
        senderid = NULL_OBJID,
        targetid = ParamBoxId->objid,
        targetos = ParamBoxId->osnum );
    as$status();

#ifdef MY_DEBUG
    printf (" force depth1 to %f\n",dDepthRed);
#endif
  }

  return (OM_S_SUCCESS);
} /* end function VREqualSizeForce*/


end implementation VRCOProduct;


