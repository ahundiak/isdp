/* $Id: VRPCorentiti.I,v 1.8 2002/04/11 21:18:56 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrcorrection / VRPCorentiti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRPCorentiti.I,v $
 *  Revision 1.8  2002/04/11 21:18:56  louis
 *  Move piping exclusive functionality from VRCorrecti.I to the new VREvalComponent method in VRPCorentiti.I
 *
 *  Revision 1.7  2002/04/11 19:21:40  anand
 *  VREvalComponent in VRPCorentity
 *
 *  Revision 1.6  2002/04/11 19:08:11  louis
 *  Move piping exclusive functionality from VRCorrecti.I to the new
 *  VREvalComponent method in VRPCorentiti.I
 *
 *  Revision 1.5  2001/09/24 15:17:44  anand
 *  TR 5468
 *
 *  Revision 1.4  2001/02/21 00:24:10  anand
 *  JTS TR MP 4487
 *
 *  Revision 1.3  2001/02/20 01:13:20  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/12 16:05:59  anand
 *  SP merge
 *
# Revision 1.1  2000/04/25  18:26:32  pinnacle
# Created: route/vrcorrection/VRPCorentiti.I by apazhani for Service Pack
#
# Revision 1.7  1999/05/04  13:44:58  pinnacle
# Replaced: vrcorrection/VRPCorentiti.I for:  by sbilla for route
#
# Revision 1.6  1998/10/24  05:28:34  pinnacle
# Replaced: vrcorrection/VRPCorentiti.I for:  by apazhani for route
#
# Revision 1.4  1998/09/14  15:02:28  pinnacle
# Replaced: vrcorrection/VRPCorentiti.I for:  by apazhani for route
#
# Revision 1.3  1998/09/11  18:09:38  pinnacle
# Replaced: vrcorrection/VRPCorentiti.I for:  by apazhani for route
#
# Revision 1.2  1998/09/11  18:04:52  pinnacle
# Replaced: vrcorrection/VRPCorentiti.I for:  by apazhani for route
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
# Revision 1.4  1996/04/16  14:22:22  pinnacle
# Replaced: vrcorrection/VRPCorentiti.I for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  23:26:28  pinnacle
# Replaced: vrcorrection/VRPCorentiti.I for:  by r240_int for route240
#
 *
 * History:
 *  ?    momo  creation
 *  06/14/95        Lori    Modified VRGetCorCmpAttrs to not
 *                                make a copy of the system collection
 *                                if the dimensional attributes 
 *                                of the correction component were the 
 *                                same as the current collection. 
 *                                TR#179420979
 *
 *  01/15/96  tlb  	Add VX_FIproto.h, prototypes
 *  09/11/98  Alwin     Modified method VREvaluate, for TR179701247.
 *  10/12/98  Alwin     Modified to declare the function globally.
 *
 *  05/04/99  Reddy     Doble value comparision corrected
 *  04/25/00  Alwin     Corrected two Double equality checking conditions for
 *			TR179901083. Wrote few lines of comments explaning the
 *			Why the function VR_ChkFlangeCmps was written.
 *  02/20/01  Anand     Removed a goto statement that prevented checks for some
 *  			valid conditions. TR JTS MP 4487.
 *  09/21/01  Anand     TR 5468
 *  04/11/02  law       NoTR-Conditional code for VREvalComponent in
 *                      VRCorrecti.I was removed and the method was cloned
 *                      under the VRPCorentity class
 *************************************************************************/

class implementation VRPCorentity;


#include <math.h>
#include "OMmacros.h"
#include "nddef.h"
#include "VRparamdef.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "parametric.h"
#include "VRmacros.h"
#include "VRMath.h"
#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "AS_status.h"
#include "bsparameters.h"
#include "VDmem.h"
#include "vrtools_pto.h"
#include "VRDbParamDef.h"
#include "vrdbgmacros.h"
//#include "vrcorrec_pto.h"

/* defined in DB, as "comp_cat". Stored in Model as "comp_type". Alwin */
#define  VR_FLANGE_COMP_TYPE    5
#define  VR_VALVE_COMP_TYPE     4

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG

#define VR_NE_( a, b )  ( fabs ((a)-(b)) > BSBASISVAL )

from  ACncpx     import  ACset_NV_rep;
from  ACncpx     import  ACget_NV_rep;
from  VRGeneric  import  VRGetParams;
from  VRGeneric  import  VRGetCptProp;
from  VRGeneric  import  VRGetCptGeom;
from  VRGeneric  import  VRGetNextOnCpt,
			 VRGetSysType,
			 VRGetInstance,
			 VRSetInstance,
			 VRGetModel;
extern  IGRboolean    verify();
extern  GRclassid OPP_VRCptIn_class_id;
extern  GRclassid OPP_VRPNozz_class_id;

/*****************************************************************************/

method VREvaluate( IGRlong       *msg;
                   IGRint         count;
           struct  GRid          *list;
           struct  GRmd_env      *md_env;
           union   VRparam_attr  *PipeParams;
           union   VRparam_attr  *Father0Params;
           union   VRparam_attr  *Father1Params;
           struct  VRPlaceStr    *PlaceStr )
{
  IGRchar        Father0Rep, Father1Rep;
  IGRshort       ByCpt0 = 0, ByCpt1 = 1;
  IGRshort       NbVia=0, PipeEndPrep = 301;
  IGRshort       PipeIndex = 0, RedIndex = 0, NbCmp = 0;
  IGRlong        ChanPos = 0;
  IGRlong        status=OM_S_SUCCESS, retcode=MSSUCC, 
                 HaveToCorrectCmp0, HaveToCorrectCmp1;
  IGRdouble      PipeWidth;

  struct  VRcp_attr     ConProp0, ConProp1;

  //added by alwin
  IGRshort      nSysType;
  IGRint 	nFirstParentType, nSecondParentType;
  IGRint	VR_ChkFlangeCmps();

  SetProc( Md VREvaluate ); Begin

  *msg    = MSSUCC;

  me->my_state   &= VR_COR_INIT;
  me->my_NbCorCmp = 0;

  if( ( me->my_state & VR_FIT_TO_FIT ) &&
      ( me->my_state & VR_COR_PID_REP ) ) 
  {
     End
     return OM_S_SUCCESS;
  }

  /*| Get my parents connect points attributs */
  status =
  om$send( msg = message VRCorrection.VRGetCptsInfo
                              ( &retcode, count, list, md_env, &NbVia,
                                &me->my_CmpCptIndex[0], &me->my_CmpCptIndex[1],
                                 NULL, NULL,
                                &HaveToCorrectCmp0, &HaveToCorrectCmp1,
                                &ConProp0, &ConProp1 ),
       targetid = my_id );
  as$status( action = RET_STATUS );

  if( retcode == MSFAIL )
  {
    /*| When my parents don't have a common support */

    *msg = MSFAIL;
    End
    return OM_S_SUCCESS;
  }

  if( ! ( me->my_state & VR_COR_PID_REP ) ) //added for TR179801744
  {
    IGRint direct_index=-1;
    struct GRid ModelId;
    struct ret_struct comp_type;
    GRclassid Classid;

    /* Get the system type of both the parents and check whether one them is
    a FLANGED COMPONENT. Alwin */

    status = om$get_classid (   objid = list[0].objid,
                                osnum = list[0].osnum,
                                p_classid = &Classid );

    if( Classid == OPP_VRCptIn_class_id )
    {
        __DBGpr_obj( " Original ParentId ", list[0] );
        status =
        om$send ( msg = message NDnode.ASreturn_go(
                            &list[0], &md_env->md_env.matrix_type,
                            md_env->md_env.matrix ),
                      targetid = list[0].objid,
                      targetos = list[0].osnum );
        __DBGpr_obj( "Real First Parent Id ", list[0] );
    }

    ModelId.objid = NULL_OBJID;
    status =
    om$send ( msg = message VRGeneric.VRGetModel( &retcode, &ModelId, md_env ),
                  targetid = list[0].objid,
                  targetos = list[0].osnum );
    __DBGpr_obj( " First Parent's ModelId ", ModelId );

    status =
    om$send (msg = message VRGeneric.ACgive_structure
                 ( (IGRint *) &retcode, &direct_index,
                   VR_N_COMP_TYPE_IN, &comp_type, md_env ),
                   targetid = ModelId.objid,
                   targetos = ModelId.osnum );
    as$status ( action = RET_STATUS );
    __DBGpr_dbl( " First Parent: Component type ", 
				comp_type.var.root_pm_st.value );
    nFirstParentType = (IGRint) comp_type.var.root_pm_st.value;

    status = om$get_classid (   objid = list[1].objid,
                                osnum = list[1].osnum,
                                p_classid = &Classid );

    if( Classid == OPP_VRCptIn_class_id )
    {
        __DBGpr_obj( " Original ParentId ", list[1] );
        status =
        om$send ( msg = message NDnode.ASreturn_go(
                            &list[1], &md_env->md_env.matrix_type,
                            md_env->md_env.matrix ),
                  targetid = list[1].objid,
                  targetos = list[1].osnum );
        __DBGpr_obj( " Real ParentId ", list[1] );
    }

    ModelId.objid = NULL_OBJID;
    status =
    om$send ( msg = message VRGeneric.VRGetModel( &retcode, &ModelId, md_env ),
                  targetid = list[1].objid,
                  targetos = list[1].osnum );
    __DBGpr_obj( " Second Parent's ModelId ", ModelId );

    status =
    om$send (msg = message VRGeneric.ACgive_structure
                 ( (IGRint *) &retcode, &direct_index,
                   VR_N_COMP_TYPE_IN, &comp_type, md_env ),
                   targetid = ModelId.objid,
                   targetos = ModelId.osnum );
    as$status ( action = RET_STATUS );
    __DBGpr_dbl( " Second Parent: Component type ", 
				comp_type.var.root_pm_st.value );
    nSecondParentType = (IGRint) comp_type.var.root_pm_st.value;
  }

  /*"CmpCptIndex = %d %d\n", me->my_CmpCptIndex[0], me->my_CmpCptIndex[1] */
  /*"NbVia       = %d\n", NbVia */

  if( NbVia ) me->my_state &= ~VR_FIT_TO_FIT;

  PipeWidth = PipeParams->piping_attr.G_diameter;

  /*| Start evaluation */

  if( me->my_state & VR_FIT_TO_FIT )
  {
    /*| my parents will be fitting to fitting */

    if( HaveToCorrectCmp0 == MSSUCC &&  HaveToCorrectCmp1 == MSSUCC )
    {
      PipeParams->piping_attr.G_diameter = ConProp0.width;
      Father1Params->piping_attr.G_diameter = ConProp1.width;


      if( VR_NE_(ConProp0.width, ConProp1.width) )
      {
        /*| cmp 0 and 1 don't have the same diam. ==> we place reducer */
 
        /*"cp0 dima. = %f .. cp1 dima. = %f\n",ConProp0.width, ConProp1.width */
        /*| Add VR_REDUCER1 */
        me->my_state = me->my_state | VR_REDUCER1;
        me->my_NbCorCmp += 1;

        /* I HardCode endprep of reducer for now ==> use Evaluate later */

        if( !verify( ConProp0.end_prep, PipeEndPrep ) )
        {
          /*| Add VR_ADAPTER0 */
          me->my_state = me->my_state | VR_ADAPTER0;
          me->my_NbCorCmp += 1;
        }

        if( !verify( ConProp1.end_prep, PipeEndPrep ) )
        {
          /*| Add VR_ADAPTER1 */
          me->my_state = me->my_state | VR_ADAPTER1;
          me->my_NbCorCmp += 1;
        }
      }
      else
      if( !verify( ConProp0.end_prep , ConProp1.end_prep ) )
      {
        /*| cmp 0 and 1 not compatable  ==> we place a flange  */

        /*"cp0 ep = %d  cp1 ep = %d\n", ConProp0.end_prep, ConProp1.end_prep */

        if( !verify( ConProp0.end_prep, PipeEndPrep ) )
        {
          /*| Add VR_ADAPTER0 */
          me->my_state = me->my_state | VR_ADAPTER0;
          me->my_NbCorCmp += 1;
        }
        else
        {
          /*| Add VR_ADAPTER1 */
          me->my_state = me->my_state | VR_ADAPTER1;
          me->my_NbCorCmp += 1;
        }
      }

      if( VR_NE_(ConProp0.width, ConProp1.width) && 
          !( me->my_state & VR_REDUCER1 ) )
      {
        /*| cmp 0 and 1 don't have the same diam. ==> we place reducer */
 
        /*"cp0 dima. = %f .. cp1 dima. = %f\n",ConProp0.width, ConProp1.width */

        /*| Add VR_REDUCER1 */
        me->my_state = me->my_state | VR_REDUCER1;
        me->my_NbCorCmp += 1;
      }
    }
  }
  else
  {
    /*| my parents are not fitting to fitting */

    if( ! ( me->my_state & VR_COR_PID_REP ) )
    {
      status = VR_ChkFlangeCmps( &retcode, HaveToCorrectCmp0, HaveToCorrectCmp1,
                                 &me->my_state, &me->my_NbCorCmp,
                                 nFirstParentType, nSecondParentType,
                                 ConProp0, ConProp1,
                                 Father0Params, Father1Params,
                                 PipeParams );
    }

    if( HaveToCorrectCmp0 == MSSUCC )
    {    
      if( ! ( nFirstParentType == VR_FLANGE_COMP_TYPE ) &&
          ! ( nFirstParentType == VR_VALVE_COMP_TYPE  ) )
      {
	  /* Removed a goto statement at this point. See comment for goto
	   * statement below.
	   *				-Anand for JTS TR MP 4487
	   */

      /* The below is the old portion of the code which still remains untouched
      and above case is added to solve the TR179701247. Alwin */

	 if( me->my_state & VR_UPDATE_PIPE )
	 {
	   /*" Update Pipe width to %f\n", ConProp0.width*/

	   PipeWidth = ConProp0.width;
	   PipeParams->piping_attr.G_diameter = ConProp0.width;
	 }

	 if( ! ( me->my_state & VR_COR_PID_REP ) )
	 {
	   Father0Params->piping_attr.G_diameter = ConProp0.width;

	   if( !verify( ConProp0.end_prep , PipeEndPrep ) )
	   {
	     /*|component 0 and pipe are not compatable==> we place a flange  */

	     /*"pipe ep=%d ... cp0 ep = %d", PipeEndPrep, ConProp0.end_prep */

	     me->my_state = me->my_state | VR_ADAPTER0;
	     me->my_NbCorCmp += 1;
	   }

	   if( VR_NE_(ConProp0.width, PipeWidth) )
	   {
	     /*|cmp 0 and pipe don't have the same diam.==> we place reducer */

	     /*"pipe diam = %f . cp0 dima. = %f\n", PipeWidth, ConProp0.width */

	     me->my_state = me->my_state | VR_REDUCER0;
	     me->my_NbCorCmp += 1;
	   }
	 }
      }
    }

    if( ! ( me->my_state & VR_COR_PID_REP ) )
    {
      if( HaveToCorrectCmp1 == MSSUCC )
      {    
        if( ( nSecondParentType == VR_FLANGE_COMP_TYPE ) ||
            ( nSecondParentType == VR_VALVE_COMP_TYPE  ) )
        {
	    /* A good place to put a lesson: AVOID gotos!! The below lines were
	     * a cut& paste of the prev. if-else condition (ie., if
	     * HaveToCorrectCmp0 == MSSUCC) - ie., there USED TO be a similar
	     * goto skip statement when the check for nFirstParentType being
	     * VALVE or FLANGE was true. The result? If the First Parent was a
	     * Flange or a Valve, the code never came here!!
	     *
	     *		     SUMMARY: AVOID USING gotos!!!
	     *
	     *					- Anand for JTS TR MP 4487
	     */
            goto skip;
        }

        Father1Params->piping_attr.G_diameter = ConProp1.width;

        if( !verify( ConProp1.end_prep , PipeEndPrep ) )
        {
          FILE   *ffptr;

          /*"pipe ep = %d ... cp1 ep = %d\n", PipeEndPrep, ConProp1.end_prep */

          me->my_state = me->my_state | VR_ADAPTER1;
          me->my_NbCorCmp += 1;

          ffptr = fopen ("/usr/tmp/flgdebug.txt","a");
          /*| cmp 1 and pipe are not compatible  ==> we place a flange  */

          if (ffptr != NULL)
          {
            fprintf (ffptr," .. To flange.. epreps = %d %d\n",
                                PipeEndPrep, ConProp1.end_prep);
            fprintf (ffptr," .. My state = %d\n",me->my_state);

            fprintf (ffptr," -- number of corr comp %d\n",me->my_NbCorCmp);

            fclose (ffptr);
          }

        }
      }

      if( VR_NE_(Father1Params->piping_attr.G_diameter, PipeWidth) )
      {
        /*| cmp 1 and pipe don't have the same diam. ==> we place reducer */

        /*"pipe diam = %f ... cp1 dima. = %f\n", PipeWidth, ConProp1.width */

        me->my_state = me->my_state | VR_REDUCER1;
        me->my_NbCorCmp += 1;
      }
    }
  }

skip : /* added by alwin */
  /*"NbCorCmp = %d\n", me->my_NbCorCmp */

  if( me->my_NbCorCmp >= 1 )
  {  
    om$vla_set_dimension(   varray = me->my_StrCmpList,
                            size   = me->my_NbCorCmp );

      /*^
          IGRlong size1;
          size1 = om$dimension_of( varray = me->my_StrCmpList );
          printf("size of NewStrCmpList = %ld\n", size1 );
      */
  }
  
  /*"my_state  = %x\n", me->my_state */

  if( me->my_state & ( VR_ADAPTER0 | VR_REDUCER0 | VR_STRAIGHT ) )
  {
    /*| Get representation and user param from Cmp0 */

    Father0Rep = ( IGRchar ) 1; /* extern representation */

    status =
    om$send( msg = message ACncpx.ACget_NV_rep
                                 ( ( IGRuchar * ) &Father0Rep ),
        targetid = list[0].objid, 
        targetos = list[0].osnum );
    as$status();
  }

  if( me->my_state & ( VR_ADAPTER1 | VR_REDUCER1 ) )
  {
    /*| Get representation and user param from Cmp1 */

    Father1Rep = ( IGRchar ) 1; /* extern representation */

    status =
    om$send( msg = message ACncpx.ACget_NV_rep
                                 ( ( IGRuchar * ) &Father1Rep ),
        targetid = list[1].objid, 
        targetos = list[1].osnum );
    as$status();
  }

  if( me->my_state & VR_ADAPTER0 )
  {
    /*"VR_ADAPTER0 ChanPos = %ld\n", ChanPos */
    strcpy( me->my_StrCmpList[ChanPos].CmpName, "ADP0" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 0;
    me->my_StrCmpList[ChanPos].CmpJustification  = ByCpt0;

    PlaceStr[ChanPos].CmpItemNum        = VR_FLGE_COMP;
    PlaceStr[ChanPos].CmpJustification  = ByCpt0;
    PlaceStr[ChanPos].CmpRepresentation = Father0Rep;
    PlaceStr[ChanPos].CmpOrientation    = 1;

    NbCmp++; ChanPos++;
  }

  if( me->my_state & VR_REDUCER0 )
  {
    /*"VR_REDUCER0 ChanPos = %ld\n", ChanPos */
    strcpy( me->my_StrCmpList[ChanPos].CmpName, "RED0" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 0;

    PlaceStr[ChanPos].CmpItemNum        = VR_REDUCER;
    PlaceStr[ChanPos].CmpRepresentation = Father0Rep;

    if (Father0Params->piping_attr.G_diameter <
                            PipeParams->piping_attr.G_diameter )
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt1;
      PlaceStr[ChanPos].CmpJustification = ByCpt1;
      PlaceStr[ChanPos].CmpOrientation   = -1;
    }
    else
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt0;
      PlaceStr[ChanPos].CmpJustification = ByCpt0;
      PlaceStr[ChanPos].CmpOrientation   = 1;
    }

    NbCmp++; ChanPos++;
  }

  if( me->my_state & VR_STRAIGHT )
  {
    PipeIndex = NbCmp;
  }

  if( me->my_state & VR_REDUCER1 )
  {
    RedIndex = NbCmp;
    NbCmp++;
  }

  if( me->my_state & VR_ADAPTER1 )
  {
    /*"VR_ADAPTER1 ChanPos = %ld\n", ChanPos */
    strcpy( me->my_StrCmpList[ChanPos].CmpName, "ADP1" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 1;
    me->my_StrCmpList[ChanPos].CmpJustification  = ByCpt0;

    PlaceStr[ChanPos].CmpItemNum        = VR_FLGE_COMP;
    PlaceStr[ChanPos].CmpJustification  = ByCpt0;
    PlaceStr[ChanPos].CmpRepresentation = Father1Rep;
    PlaceStr[ChanPos].CmpOrientation    = -1;

    ChanPos++;
  }

  if( me->my_state & VR_REDUCER1 )
  {
    /*"VR_REDUCER1 ChanPos = %ld\n", ChanPos */
    strcpy( me->my_StrCmpList[ChanPos].CmpName, "RED1" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = RedIndex;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 1;

    PlaceStr[ChanPos].CmpItemNum        = VR_REDUCER;
    PlaceStr[ChanPos].CmpRepresentation = Father1Rep;

    if(Father1Params->piping_attr.G_diameter <
                         PipeParams->piping_attr.G_diameter)
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt1;
      PlaceStr[ChanPos].CmpJustification = ByCpt1;
      PlaceStr[ChanPos].CmpOrientation   = 1;
    }
    else
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt0;
      PlaceStr[ChanPos].CmpJustification = ByCpt0;
      PlaceStr[ChanPos].CmpOrientation   = -1;
    }

    ChanPos++;
  }

  End
  return OM_S_SUCCESS;
}


/****************************************************************************/

method VRGetCorLenByCmp( IGRlong    *msg; 
                struct   GRid       *CmpId;
                struct   GRmd_env   *md_env;
                         IGRdouble  *Length )
{
  IGRshort    NbVia=0;
  IGRint      Index, NbParent;
  IGRlong     retcode, status;

  struct  GRid          FatherId[my_nbParent];
  union   VRparam_attr  CmpParams;

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  if( CmpId )
  {
    status =
    om$send( msg = message NDnode.NDget_objects
                                 ( ND_ROOT, FatherId, my_nbParent, NULL, 0, 
                                   OM_K_MAXINT, &NbParent),
        targetid = my_id );
    as$status( action = RET_STATUS );

    if( NbParent != my_nbParent )
    {
      as$status( sts = OM_E_ABORT, msg = "Invalid number of parents" );
      return OM_E_ABORT;
    }

    if( FatherId[0].objid == CmpId->objid ) Index = 0;
    else                                    Index = 1;

    status =
    om$send( msg = message VRCorrection.VRGetCorLength
                                           ( Index+3, md_env, Length ),
        targetid = my_id );
    as$status( action = RET_STATUS );
    
    status =
    om$send( msg = message VRGeneric.VRGetNextOnCpt
                                 ( &retcode, me->my_CmpCptIndex[Index], NULL,
                                   NULL, 0, &NbVia, NULL, NULL, md_env ),
        targetid = CmpId->objid,
        targetos = CmpId->osnum );

    /*"NbVia = %d\n", NbVia */

    if( NbVia && !(me->my_state&VR_COR_PID_REP) )
    {
      status = VR$GetDimensionAttributes(  p_retmsg         = &retcode,
                                           Product          = VR_PIPING,
                                           p_ComponentId    = CmpId,
                                           p_DimAttributes  = &CmpParams,
                                           p_MdEnv          = md_env );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

/*  The increment of the length below, although appears to be a good
 *  thing to do, is not exactly understood. Further, the 0.25 factor appears
 *  arbitrary. Per suggestion of Ed Heinhold, the factor is being changed to
 *  0.01 (Anand for JTS TR MP5468)
 */
//    *Length += 0.25 * CmpParams.piping_attr.G_diameter;
      *Length += 0.01 * CmpParams.piping_attr.G_diameter;
    }
  }

  /*"length = %f\n", *Length */

  return OM_S_SUCCESS;

}

/*****************************************************************************/
/*
/*  GRvg override
/*
/**/

method GRgetobjinfo( IGRlong      *msg;
                     struct  GRobj_info  *info )
{
   
   *msg = MSSUCC;

   strcpy( info->type, "Piping Correction" );
   return(OM_S_SUCCESS);

}

/*****************************************************************************/
/*
/*  assoc override
/*
/**/

method ASconstruct_go( struct GRas        *asso_lis;
                       struct GRmd_env    *md_env;
                              IGRchar     *go_cnst_lis;
                              GRclassid    go_classid;
                              IGRboolean   altconstruct )
{
  IGRlong status;

  extern GRclassid OPP_VRPComp_class_id;
  
  status =
  om$send( mode = OM_e_wrt_message,
           msg  = message VRCorrection.ASconstruct_go
                                          ( asso_lis, md_env, go_cnst_lis, 
                                          OPP_VRPComp_class_id, altconstruct ),
       targetid = my_id );
  as$status();

  return OM_S_SUCCESS;
}

/*****************************************************************************/
/*
/* This method get the dimensoin system paramters of a component 
/*
/**/

method VRGetCmpParams( IGRint          CompType;
                 union VRparam_attr   *PipeParams;
                 union VRparam_attr   *FatherParams;
                 union VRparam_attr   *CmpParams )
{
  IGRshort   Type;
  IGRint     status;

  extern int VRGetCmpParams();

  /*"CompType = %x\n", CompType */

  if( CompType & VR_REDUCER0 || CompType & VR_REDUCER1 ) Type = VR_RED;
  else                                                   Type = VR_ADP;
  
  status = VRGetCmpParams
           ( VR_PIPING, Type, PipeParams, FatherParams, CmpParams );
  as$status();

  return OM_S_SUCCESS;
}

/*****************************************************************************/
/*
/* This method change the component system paramters.
/*
/**/

method VRChgCorCmpAttrs( IGRlong       *msg;
                  struct GRid          *CorCmpId;
                  union  VRparam_attr  *CmpParams;
                         IGRchar        cRep;
                  struct GRmd_env      *md_env )
{
  IGRint status;

  extern int VRChgCorCmpAttrs();

  status = VRChgCorCmpAttrs( msg, VR_PIPING, CorCmpId, CmpParams, 
                                       cRep, md_env );
  as$status( action = RET_STATUS );
  as$status( sts = *msg, action = RET_STATUS );

  return OM_S_SUCCESS;
}

/*****************************************************************************/
/*
/* This method get the component system parameters.
/*
/**/
 
method VRGetCorCmpAttrs( IGRlong         *msg;
                   union VRparam_attr    *CmpParams; 
                  struct GRid            *ActParamId;
                  struct GRid            *CmpParamId;
                  struct GRmd_env        *md_env )
{
  IGRint  status;
  IGRlong retmsg;

  union VRparam_attr ActParams;

  status = VR$GetDimensionAttributes ( p_retmsg          = &retmsg,
                                       Product           = VR_PIPING,
                                       p_SysCollectionId = ActParamId,
                                       p_DimAttributes   = &ActParams,
                                       p_MdEnv           = md_env);

  /* If the attributes are the same for the correction component as 
     in ActParamId, just use ActParamId - don't copy it */
  /*BILLA  Double value comparison problem */
  if( ( fabs(ActParams.piping_attr.G_diameter-CmpParams->piping_attr.R_diameter)
				< 1e-06 ) &&
      ( fabs(ActParams.piping_attr.R_diameter-CmpParams->piping_attr.G_diameter)
				< 1e-06 ) )
  {
    *CmpParamId = *ActParamId;
    return OM_S_SUCCESS;
  }

  /* need to make a new collection to take into account the 
     new dimensional parameters */
  status = VRModifyParameterBox
                ( msg, VR_PIPING, CmpParams, ActParamId, CmpParamId );
  as$status();

  return OM_S_SUCCESS;
}


/*****************************************************************************/
/*
/* This method get given correction template parameters.
/*
/**/

method VRGetTempAttr( IGRlong       *msg;
               struct GRid          *TempId;
               struct GRid          *ActParamId;
               struct GRid          *UserParamId;
                union VRparam_attr  *TempParams;
               struct GRmd_env      *md_env )
{
  IGRint status;

  extern int VRGetTempAttr();

  status = VRGetTempAttr( msg, VR_PIPING, TempId, ActParamId, UserParamId,
                                                  TempParams, md_env );
  as$status();

  return OM_S_SUCCESS;
}

/*****************************************************************************/

method VRBuild( IGRlong        *msg;
                IGRint          OldState;
          union VRparam_attr   *PipeParams;
          union VRparam_attr   *DimParams;
         struct GRid           *ActParamId;
         struct GRid           *UserParamId;
                IGRchar        *go_cnst_lis;
         struct GRas           *assoc_list;
         struct VRPlaceStr     *PlaceStr;
         struct GRmd_env       *md_env )

{
  IGRint       i, j, NbType=2, ComputeTable[5];
  IGRlong      status=OM_S_SUCCESS, retcode=MSSUCC;

  struct  GRid          ParamsTable[8];
  union   VRparam_attr  DimParamsTable[4];

  /*| apdate piping tables */
  ComputeTable[0] = VR_ADAPTER0;
  ComputeTable[1] = VR_REDUCER0;
  ComputeTable[2] = VR_ADAPTER1;
  ComputeTable[3] = VR_REDUCER1;
  ComputeTable[4] = -1;

  for( i=0,j=0; i<NbType; i++,j+=2 )
  {
    DimParamsTable[i]         = DimParams[0];
    DimParamsTable[i+NbType]  = DimParams[1];

    ParamsTable[j]            = ActParamId[0];
    ParamsTable[j+1]          = UserParamId[0];
    ParamsTable[j+2*NbType]   = ActParamId[1];
    ParamsTable[j+1+2*NbType] = UserParamId[1];
  }

  status =
  om$send( msg = message VRCorrection.VRCreate
                               ( &retcode, OldState, ComputeTable, ParamsTable,
                                 PipeParams, DimParamsTable, go_cnst_lis, 
                                 assoc_list, PlaceStr, md_env ),
      targetid = my_id );
  as$status( action = RET_STATUS );

  return OM_S_SUCCESS;
}

/*****************************************************************************
This function was added mainly to fetch the proper ADAPTER or
REDUCER/EXPANDER at the appropriate Parents end. 

for example :
1. Sketch a pipe run of 100 mm.
2. User wants to insert an Valve to control the flow. But he doesn't have
100mm Valve, whereas he's the 150mm Valve and REDUCER/EXPANDER 100 x 150 mm.
So insert the 150mm Valve and expects the REDUCER to get placed adjacent.
Previously it used to place randomly.

Now go ahead insert a Valve of 150mm in the above sketched pipe run.
This would place Valve of 150mm and Flange of 150mm and Reducer of 150x100mm.
closer to the Valve. This is the expected behaviour.

Documented recently while fixing TR179901083. Alwin
*****************************************************************************/

IGRint VR_ChkFlangeCmps( msg, HaveToCorrectCmp0,
			 HaveToCorrectCmp1, my_state, NbCorCmp,
			 nFirstParentType, nSecondParentType, 
			 ConProp0, ConProp1,
			 Father0Params, Father1Params, PipeParams )
IGRint 	*my_state, *NbCorCmp; 
IGRint 	nFirstParentType, nSecondParentType;
IGRlong *msg, HaveToCorrectCmp0, HaveToCorrectCmp1; 
struct 	VRcp_attr ConProp0, ConProp1;
union	VRparam_attr *Father0Params, *Father1Params, *PipeParams;
{
      IGRboolean bFirstParentReducer = FALSE;
      IGRint	 PipeEndPrep = 301;

      SetProc( Fn VRCheckForFlgComps ); Begin 

      *msg = MSSUCC;

      __DBGpr_dbl( " Diameter at Cpt 0 ", ConProp0.width );
      __DBGpr_dbl( " Diameter at Cpt 1 ", ConProp1.width );

      if( ( ( nFirstParentType == VR_FLANGE_COMP_TYPE ) || 
	  ( nFirstParentType == VR_VALVE_COMP_TYPE  ) ) &&
	  ( !verify( ConProp0.end_prep, PipeEndPrep ) ) && 
	  ( HaveToCorrectCmp0 == MSSUCC ) )
      {
	  __DBGpr_com( " First Parent is of VALVE/FLANGE family " );

	  Father0Params->piping_attr.G_diameter = ConProp0.width;
	  *my_state = *my_state | VR_ADAPTER0;
	  *NbCorCmp += 1;

	  //if( ConProp0.width !=  ConProp1.width ) Changing this condition check
	  if( VR_NE_( ConProp0.width, ConProp1.width ) )
	  {
	      bFirstParentReducer = TRUE;

	      __DBGpr_com( " need a 'reducer/expander' near FIRST parent ");
	      *my_state = *my_state | VR_REDUCER0;
	      *NbCorCmp += 1;
	      PipeParams->piping_attr.G_diameter = ConProp1.width;
	  }
	  else
	  {
		  __DBGpr_com( " Don't need a REDUCER near First Parent " );
	      PipeParams->piping_attr.G_diameter = ConProp0.width;
	  }
          __DBGpr_dbl( " Pipe Diameter ", PipeParams->piping_attr.G_diameter );
      }

      if( ( ( nSecondParentType == VR_FLANGE_COMP_TYPE ) ||
	  ( nSecondParentType == VR_VALVE_COMP_TYPE  ) ) && 
	  ( !verify( ConProp1.end_prep, PipeEndPrep ) )  && 
	  ( HaveToCorrectCmp1 == MSSUCC ) )
      {
	  __DBGpr_com( " Second Parent is of VALVE/FLANGE family " );
	  Father1Params->piping_attr.G_diameter = ConProp1.width;
	  *my_state = *my_state | VR_ADAPTER1;
	  *NbCorCmp += 1;

	  //if( !bFirstParentReducer && ( ConProp0.width != ConProp1.width ) ) 
	  //Changing this condition check. TR179901083 Alwin
	  if( !bFirstParentReducer && ( VR_NE_(ConProp0.width, ConProp1.width) ) )
	  {
	      __DBGpr_com( " need a 'reducer/expander' near SECOND parent ");
	      *my_state = *my_state | VR_REDUCER1;
	      *NbCorCmp += 1;
	      PipeParams->piping_attr.G_diameter = ConProp0.width;
	  }
	  else 
	  {
		  __DBGpr_com( " Don't need a REDUCER near Second Parent " );
		  PipeParams->piping_attr.G_diameter = ConProp1.width;
	  }

          __DBGpr_dbl( " Pipe Diameter ", PipeParams->piping_attr.G_diameter );
      }
      End
      return OM_S_SUCCESS;
}

/****************************************************************************/
/* The method VREvalComponent has been revamped, with the database access   */
/* now being done through the cache. Header files VRPDBmac.h and VRPDBdef.h */
/* have been included for this purpose. A lot of restructuring of the old   */
/* code has also been done. - Anand ( Nov '97 )                             */
/****************************************************************************/

method VREvalComponent( IGRlong                 *msg;
                        IGRint                  CompType;
                        union VRparam_attr      *PipeParams, *FatherParams;
                        IGRchar                 *go_cnst_lis;
                        struct  GRas            *assoc_list;
                        struct  GRmd_env        *md_env;
                        struct  GRid            *CorCmpId )
{
  IGRint                        nOption_code=0;
  IGRshort                      Product;
  IGRlong                       status=OM_S_SUCCESS, retcode=MSSUCC;
  struct        GRid            ActParamId, ParentId;
  struct        VRGenInfo       *CmpStr, CmpInstance;
  union         VRparam_attr    CmpParams;

  SetProc( VRPCorentity.VREvalComponent );Begin

  *msg = MSSUCC;

  CmpStr = ( struct VRGenInfo * ) assoc_list->as_attr;

  __DBGpr_obj("CorCmpId ",*CorCmpId );
  __DBGpr_int("CompType ", CompType );
#ifdef vdsDEBUG
  printf("      ##############\n");
  printf("      VR_TRANS0  =%d\n",VR_TRANS0);
  printf("      VR_TRANS1  =%d\n",VR_TRANS1);
  printf("      VR_ADAPTER0=%d\n",VR_ADAPTER0);
  printf("      VR_ADAPTER1=%d\n",VR_ADAPTER1);
  printf("      ##############\n");
#endif

  status = om$send( msg      = message VRCorrection.VRGetCmpParams(CompType,
                                         PipeParams, FatherParams, &CmpParams),
                    targetid = my_id );
  as$status();

/* Get the Product Name */
  status = om$send ( msg = message VRCorrection.VRGetProductName( &Product ),
                             targetid = my_id );

  __DBGpr_int( "Product =" , Product);

  if( CorCmpId->objid == NULL_OBJID )
  {
/* add collection in the assoc parent list */
        ActParamId = assoc_list->parents[0];
        assoc_list->parents[0].objid = NULL_OBJID;
        status = om$send( msg      = message VRCorrection.VRGetCorCmpAttrs
                                     ( &retcode, &CmpParams, &ActParamId,
                                       &assoc_list->parents[0], md_env ),
                          targetid = my_id );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );

        status = om$send( msg      = message ASnode.ASconstruct_go
                                      ( assoc_list, md_env, go_cnst_lis,
                                        0, FALSE ),
                          targetid = my_id );
        as$status( action = RET_STATUS );

        *CorCmpId = assoc_list->go_objid;
        __DBGpr_com("collection added in the assoc parent list");
  }


  if( CompType & VR_TRANS0 || CompType & VR_TRANS1 )
  {
        __DBGpr_int("CompType (=VR_TRANS here)",CompType);

        status = om$send( msg      = message VRGeneric.VRGetInstance
                                                   ( &retcode, &CmpInstance ),
                          targetid = CorCmpId->objid,
                          targetos = CorCmpId->osnum );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );

        CmpInstance.Attr.Comp.Desc.nItemNum = CmpStr->Attr.Comp.Desc.nItemNum;

        status = om$send( msg      = message VRGeneric.VRSetInstance
                                                   ( &retcode, &CmpInstance ),
                          targetid = CorCmpId->objid,
                          targetos = CorCmpId->osnum );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );

        status = om$send( msg      = message VRCorrection.VRChgCorCmpAttrs
                                   ( &retcode, CorCmpId, &CmpParams,
                                     CmpStr->cRep, md_env ),
                          targetid = my_id );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );

        End
        return OM_S_SUCCESS;
  }
  else if( CompType & VR_ADAPTER0 || CompType & VR_ADAPTER1 )
  {
        IGRint                  i, j, num_rows, *opt_code, direct_index=-1;
        IGRdouble               dUnits_set=0;
        IGRdouble               *size_g_low, *size_g_high, npd_g;
        struct GRid             ModelId;
        struct ret_struct       StrInfo;

/* If the CompType is of FLANGE, get its parent*/
        status = om$send ( msg = message VRCorrection.VRGetMyCmp(
                                    &retcode, CorCmpId, &ParentId, md_env ),
                                targetid = my_id );

        __DBGpr_obj( "ParentId ", ParentId );

        /* added by Alwin ...for TR179800791 */

        /* There are cases, where Parent might be located in reference file.
        In that case the VRCptIn object will be created and be set as the
        parent of the Correction Entity. To retreive the data from the parent
        we need to identify our actual parent first and get the details. */

        {
            GRclassid ClassId;

            status = om$get_classid(    objid     = ParentId.objid,
                                        osnum     = ParentId.osnum,
                                        p_classid = &ClassId );

            if( ClassId == OPP_VRCptIn_class_id )
            {
                struct GRid RealParentId;

                status =
                om$send ( msg = message NDnode.ASreturn_go( &ParentId,
                                                NULL, NULL ),
                                targetid = ParentId.objid,
                                targetos = ParentId.osnum);
                __DBGpr_obj( "from return_go. Real ParentId ", ParentId );
            }
        }
        /* added by Alwin ...for TR179800791 */

/* Get the "npd_g" from the Parent */
        status = om$send ( msg = message ACncpx.ACgive_structure(
                                      (int *)&retcode, &direct_index,
                                      VR_N_GDIAMETER_DB, &StrInfo, md_env ),
                            senderid = NULL_OBJID,
                            targetid = ParentId.objid,
                            targetos = ParentId.osnum );
        npd_g = StrInfo.var.root_pm_st.value;
        __DBGpr_dbl("npd_g ",npd_g);

/* Get the "comp_code" from the Parent */
        status = om$send ( msg = message ACncpx.ACgive_structure(
                                  (int *)&retcode, &direct_index,
                                  VR_N_COMP_CODE_AN, &StrInfo, md_env ),
                           senderid = NULL_OBJID,
                           targetid = ParentId.objid,
                           targetos = ParentId.osnum );
        __DBGpr_str("comp_code ",StrInfo.var.text_st.text_string);

 /***************************************************************************/
 /* The if portion of the following if-else loop handles the case of the    */
 /* parent being a flange, wherein the mating flange to be placed is simply */
 /* assigned the opt_code of the parent.                                    */
 /* The else portion handles the cases of the parent being either a nozzle  */
 /* or a valve, wherein, rating_g is being used as the criterion to get the */
 /* mating flange (as per CR 179421375). - Anand                            */
 /* The criterion has been further refined to take into account prep_g and  */
 /* prep_r criteria based on sugguestions given by Rod and Tyler (vide      */
 /* mails between Alwin and Rod during mid - Nov '97) - Anand               */
 /***************************************************************************/

        if( !strcmp(StrInfo.var.text_st.text_string , "FLANGE") )
        {

/* In the case of FLANGE, the procedure used below holds good. But
   taking "speed" into consideration, I prefer this procedure. Alwin*/

/* In the case of FLANGE, the mating FLANGE is nothing but "FLANGE" of
   same opt_code as that of the Parent */

              status = om$send( msg  = message VRGeneric.VRGetInstance
                                        ( &retcode, &CmpInstance ),
                         targetid = ParentId.objid,
                         targetos = ParentId.osnum );

              nOption_code = CmpInstance.nOption;
              __DBGpr_int("Flange's nOption_code",nOption_code);
        }
        else
        {
              IGRshort                  nPreps=0, NumComp=0;
              IGRint                    nHits;
              IGRchar                   sRatingG[10];
              struct VRPDB_comps        *CompPtr;
              GRclassid                 obj_class;

              sRatingG[0]='\0';

              ModelId.objid = NULL_OBJID;
              status = om$send ( msg = message VRGeneric.VRGetModel(
                                                   &retcode, &ModelId, md_env ),
                                             senderid = NULL_OBJID,
                                             targetid = ParentId.objid,
                                             targetos = ParentId.osnum );

              __CheckRC( status, 1, "Model Id is NULL", SettingInstance );

              __DBGpr_obj("ModelID",ModelId);

              status = om$send ( msg = message ACncpx.ACgive_structure(
                                           (int *)&retcode, &direct_index,
                                           "units_set", &StrInfo, md_env ),
                                         senderid = NULL_OBJID,
                                         targetid = ModelId.objid,
                                         targetos = ModelId.osnum );

              dUnits_set = StrInfo.var.root_pm_st.value;
              __DBGpr_dbl(" units_set ",dUnits_set);

              status = om$get_classid( osnum     = ParentId.osnum,
                                       objid     = ParentId.objid,
                                       p_classid = &obj_class );

              as$status( action = RET_STATUS );

/* This condition which checks whether the Parent component is Nozzle or not */

              if( obj_class == OPP_VRPNozz_class_id )
              {

/* Get the "ratings_g" from the Parent */
                     status = om$send ( msg = message ACncpx.ACgive_structure(
                                          (int *)&retcode, &direct_index,
                                          VR_N_RATINGS_G_DB, &StrInfo, md_env ),
                                      senderid = NULL_OBJID,
                                      targetid = ParentId.objid,
                                      targetos = ParentId.osnum );

                     strcpy( sRatingG, StrInfo.var.text_st.text_string );
                     __DBGpr_str("Nozzle's ratings_g ",sRatingG);

/* Get the End Preparation from the Parent - both as string and value.*/

                     status = om$send(msg = message ACncpx.ACgive_structure(
                                         (int *)&retcode, &direct_index,
                                         VR_N_PREP_G_IN, &StrInfo, md_env),
                                      senderid = NULL_OBJID,
                                      targetid = ParentId.objid,
                                      targetos = ParentId.osnum );

                     nPreps = (IGRshort) StrInfo.var.root_pm_st.value;
                     __DBGpr_int("Nozzle's end condition ",nPreps);

              }
              else
              {
/* Get the parameters of the valve */
                  IGRint           ParentIndex;
                  struct VRcp_attr CptAttr;

/* Get the "rating_g" from the Model */
                 status = om$send ( msg = message ACncpx.ACgive_structure(
                                        (int *)&retcode, &direct_index,
                                        VR_N_RATING_G_DB, &StrInfo, md_env),
                                    senderid = NULL_OBJID,
                                    targetid = ModelId.objid,
                                    targetos = ModelId.osnum );

/* Note: rating_g for valve is rec'd differently from StrInfo */
                 sprintf(sRatingG,"%g#", StrInfo.var.root_pm_st.value);
                 __DBGpr_str("Valve's rating_g",sRatingG);

/* Need to ask Cpt for end_prep instead of the component for it's prep_g,
 * prep_r 
 *                                             JDS for JTS TR MP 5435
 */
/* To get the end prep of the parent: Get the Cpt Index of the component to
 * which I (the correction) am getting hooked to. Based on the Cpt Index, query
 * the Model for either "prep_g" (if it is Cpt 0) or prep_r (if Cpt 1). The
 * earlier method confused green and red ends as inlet and outlet -> won't work
 * in some cases (e.g., if the component is flipped or sketching in opposite
 * direction).                                  Anand for JTS TR MP 5418
 */

                 if( CompType & VR_ADAPTER1 )
                     ParentIndex = 1;
                 else if(CompType & VR_ADAPTER0 )
                     ParentIndex = 0;
                 __DBGpr_int("Mating flange is between Pipe and Parent No.",
                                                                 ParentIndex );

                 status = om$send(msg = message VRGeneric.VRGetCptProp(
                                                        &retcode,
                                                        me->my_CmpCptIndex[ParentIndex],
                                                        &CptAttr,
                                                        md_env        ),
                                  senderid = NULL_OBJID,
                                  targetid = ParentId.objid,
                                  targetos = ParentId.osnum  );

                 nPreps = CptAttr.end_prep;
                 __DBGpr_int("Parent's end condition ",nPreps);
              }

/****************************************************************************/
/* Step 1 (see comment box below) has been removed for CR 179901668. This   */
/* step used to attempt to query current cache, which might not correspond  */
/* to the spec of the valve.                            Anand (July 19, 2k) */
/****************************************************************************/

/****************************************************************************/
/*  Query from cache for size_g's and opt_code.The equivalence of the cache */
/*  implementation can be readily seen. The query that needs to be done is: */
/*                                                                          */
/*  SELECT piping_comps.size_g's high and low values and opt_code           */
/*  FROM piping_spec , piping_comp                                          */
/*  WHERE piping_comps.comp_code='FLANGE'  AND                              */
/*        piping_comps.rating_g = sRatingG AND                              */
/*        piping_comps.prep_g   = sPrepG   AND                              */
/*        piping_spec.spec_name = sSpecName AND                             */
/*        piping_spec.spec_name = piping_comps.spec_name                    */
/*                                                                          */
/*  The above query is accomplished by the cache-access as follows:         */
/*                                                                          */
/*  Step 1: Use the "DA" ('D'irect 'A'ccess) macro corresponding to the     */
/*          table that you need to query. In this case, we need to use the  */
/*          VR$PDA_COMP macro to access the cache that stores the           */
/*          piping_comps table corresponding to the spec_name of            */
/*          piping_spec (i.e., you don't need to additionally query the     */
/*          piping_spec table). The macro returns a pointer that points to  */
/*          the cache storing the corresponding table (piping_comps here).  */
/*                                                                          */
/*  Step 2: Verify that the above pointer is not NULL. If it is NULL, force */
/*          cache update using the VR$PDB_SET macro.                        */
/*                                                                          */
/*  Step 3: Do your querying on the pointer using an if condition within a  */
/*          for loop (the macro also returns the number of records in the   */
/*          cache, so that a for loop may be used). Here, the condition for */
/*          querying is that the comp_code is FLANGE and the rating_g       */
/*          requirement. The other two criteria (in the old method) can be  */
/*          dispensed away with, because the cache ensures that the         */
/*          piping_comps's spec_name corresponds to that of the piping_spec */
/*                                                                          */
/****************************************************************************/


/* Step 1 */
// Below two lines commented by Anand for CR 179901668
//            status = VR$PDA_COMP ( p_num = &NumComp, p_ptr = &CompPtr );
//            if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
              {
                 IGRchar                sSpecName[10];
                 IGRshort               dSpecNum;

                 sSpecName[0]='\0';

/* Get the "spec_name" from the Parent */
                 __DBGpr_com("Getting spec_name info from parent");
                 status = om$send ( msg = message ACncpx.ACgive_structure(
                                           (int *)&retcode, &direct_index,
                                           VR_N_CLASS_AN, &StrInfo, md_env ),
                                    senderid = NULL_OBJID,
                                    targetid = ParentId.objid,
                                    targetos = ParentId.osnum );

                 strcpy( sSpecName, StrInfo.var.text_st.text_string );
                 __DBGpr_str("spec_name from the Parent",sSpecName);

/* From the spec_name, get the spec_no */
                 VR$PDB_SNUM( p_nam = sSpecName ,
                              p_num = &dSpecNum );
                 __DBGpr_int("spec_num from spec_name (VR$PDB_SNUM)",dSpecNum);


/* Step 2 */
                 VR$PDB_SET ( p_msg = &retcode ,
                              spec  = dSpecNum ,
                              dia   = npd_g );

                 status = VR$PDA_COMP( p_num = &NumComp , p_ptr = &CompPtr );

                 if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
                 {
                    nOption_code = 0;
                    __CheckPtr(CompPtr,"Error in Cache (Comp) Access!\n",
                                                              SettingInstance);
                    __CheckSTS(status ,"Error in Cache (Comp) Access!\n",
                                                              SettingInstance);
                 }
              }

              __DBGpr_int("NumComp",NumComp);

              size_g_low  = size_g_high = NULL;
              opt_code = NULL;
              nHits = 0;

/* Step 3 */
              for( j=0 ; j < NumComp ; j=j+1 )
              {

 /***************************************************************************/
 /*  The mating flange should satisfy ALL of the following 3 conditions:    */
 /*  [1]   The comp_code should be 'FLANGE'                                 */
 /*  [2]   "Rating_g of flange = rating_g of parent" requirement should be  */
 /*        satisfied.                                                       */
 /*  [3]   The prep_g of the flange should coincide with the end preparation*/
 /*        of that end of the component to which the flange is going to get */
 /*        attached (this assumes that "always" it is the green end of the  */
 /*        flange that attaches to the component.                           */
 /*                                                                         */
 /*            < Help from Tyler sought; Criteria may need refinement. >    */
 /*                                                             ANAND       */
 /*                                                                         */
 /* Per requirement of JTS CR 5177, the 3rd criterion did need refinement.  */
 /* The end_preps of the flanges should be compatible, not necessarily      */
 /* equal to each other.                                                    */
 /*                                                     Anand (May 7, 01)   */
 /*                                                                         */
 /***************************************************************************/

                  if(   !strcmp((CompPtr+j)->key.comp_code,"FLANGE")
                     && !strcmp((CompPtr+j)->data.rating_g,sRatingG)
                     &&  verify((CompPtr+j)->data.prep_g,nPreps) )
                  {
                     size_g_low = (IGRdouble *)realloc( (char *)size_g_low ,
                                        (unsigned)(nHits+1)*sizeof(IGRdouble) );
                     size_g_high= (IGRdouble *)realloc( (char *)size_g_high,
                                        (unsigned)(nHits+1)*sizeof(IGRdouble) );
                     opt_code   = (IGRint    *)realloc( (char *)opt_code   ,
                                        (unsigned)(nHits+1)*sizeof(IGRint)    );

                     *(size_g_low +nHits)= (CompPtr+j)->dia.dia1_l;
                     *(size_g_high+nHits)= (CompPtr+j)->dia.dia1_h;
                     *(opt_code   +nHits)= (CompPtr+j)->key.option;
                     nHits = nHits + 1;
                  }
              }
              __DBGpr_int("nHits ",nHits);

/* If its "units_set" is greater then or equal to 20, then its component
   is using Metric Units. Then we need to convert the diameters which we
   obtained from the DB, which is in Imperial Units. This can done by
   just getting the equivalent diameters from "piping_npd_allowed" Table. */

              if( dUnits_set >= 20 )
              {
                 IGRshort nRows;
                 IGRdouble *npd=NULL, *npd_equiv=NULL;
                 struct VRPDB_npd *NpdPtr=NULL;

                 nRows = 0;

/* To get the conversion from "imperial units" to "metric units", use the
   following macro, that accesses the cache corresponding to the
   "piping_npd_allowed" table. */

                 VR$PDA_NPD( p_num=&nRows , p_ptr=&NpdPtr );
                 __DBGpr_int("nRows (of piping_npd_allowed)",nRows);

                 if( nRows )
                 {
                    npd = _MALLOC( nRows, IGRdouble );
                    npd_equiv = _MALLOC( nRows, IGRdouble );
                 }

                 if( !(npd && npd_equiv) )
                 {
                     as$status( sts = OM_E_ABORT,
                                msg = "Insuffcient Memory Space" );
                     return OM_E_ABORT;
                 }
                 __DBGpr_com("Allocation for npd, npdequiv successful!");

                 for( i=0; i<nRows; i++ )
                 {
                    npd[i]       = (NpdPtr+i)->npd;
                    npd_equiv[i] = (NpdPtr+i)->npd_eq;
                 }

                 for( j=0; j<nHits; j++ )
                 {
                     for( i=0; i<nRows; i++ )
                        /*BILLA  Double value comparison problem */
                        if( fabs(size_g_low[j] - npd[i] ) <
                                                       VRGetTol(VR_DIST_TOL) )
                        {
                           size_g_low[j] = npd_equiv[i];
                           __DBGpr_dbl("converted size_g_low ",size_g_low[j] );
                           break;
                        }

                     for( i=0; i<nRows; i++ )
                        /*BILLA  Double value comparison problem */
                        if( fabs(size_g_high[j] - npd[i]) <
                                                       VRGetTol(VR_DIST_TOL) )
                        {
                           size_g_high[j] = npd_equiv[i];
                           __DBGpr_dbl("converted size_g_high",size_g_high[j]);
                           break;
                        }

                 }

                 _FREE( npd);
                 _FREE( npd_equiv );
              }

              for( i=0; i<nHits; i++ )
              {
                if( (size_g_low[i] <= npd_g) && (npd_g <= size_g_high[i]) )
                {
                   nOption_code = opt_code[i];
                   __DBGpr_int("nOption_code (after cache query)",nOption_code);
                   break;
                }
              }
              _FREE( size_g_low );
              _FREE( size_g_high );
              _FREE( opt_code );
        }

SettingInstance:
        status = om$send( msg  = message VRGeneric.VRGetInstance
                                     ( &retcode, &CmpInstance ),
                      targetid = CorCmpId->objid,
                      targetos = CorCmpId->osnum );

        __DBGpr_int("nOption_code (at SettingInstance)",nOption_code);
        if( nOption_code )
             CmpInstance.nOption = nOption_code;
        else
        {
           printf("\n MATING FLANGE not found, placing DEFAULT \n" );
           CmpInstance.nOption = 1;
        }

        status = om$send( msg      = message VRGeneric.VRSetInstance
                                          ( &retcode, &CmpInstance ),
                     targetid = CorCmpId->objid,
                     targetos = CorCmpId->osnum );

   }

   status = om$send( msg      = message VRCorrection.VRChgCorCmpAttrs
                            ( &retcode, CorCmpId, &CmpParams,
                              CmpStr->cRep, md_env ),
                         targetid = my_id );
   as$status( action = RET_STATUS );
   as$status( sts = retcode, action = RET_STATUS );


  End
  return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

end implementation VRPCorentity;
