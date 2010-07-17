/* $Id: VRConnInfo.I,v 1.5 2002/04/10 19:40:46 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrgeneric / VRConnInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRConnInfo.I,v $
 *  Revision 1.5  2002/04/10 19:40:46  louis
 *  TR5649-standardize tolerances
 *
 *  Revision 1.4  2001/09/14 15:20:22  anand
 *  JTS TR MP 4843
 *
 *  Revision 1.3  2001/02/20 01:13:59  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/12 20:44:11  anand
 *  SP merge
 *
# Revision 1.6  2000/11/17  23:32:28  pinnacle
# Replaced: route/vrgeneric/VRConnInfo.I for:  by aharihar for Service Pack
#
# Revision 1.5  2000/06/27  16:47:52  pinnacle
# Replaced: route/vrgeneric/VRConnInfo.I for:  by jwfrosch for Service Pack
#
# Revision 1.4  2000/06/27  16:35:38  pinnacle
# Replaced: route/vrgeneric/VRConnInfo.I for:  by jwfrosch for Service Pack
#
# Revision 1.3  2000/06/21  22:31:50  pinnacle
# Replaced: route/vrgeneric/VRConnInfo.I for:  by aharihar for Service Pack
#
# Revision 1.2  2000/06/05  18:07:52  pinnacle
# Replaced: route/vrgeneric/VRConnInfo.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/05/23  23:16:58  pinnacle
# Created: route/vrgeneric/VRConnInfo.I by lawaddel for Service Pack
#
# Revision 1.3  1998/11/06  22:45:54  pinnacle
# Replaced: vrgeneric/VRConnInfo.I for:  by lawaddel for route
#
 *
 * History:
 *   ????     ???  Creation
 *      06/22/94  Manyam  Modified "VRSelectCptByGeom()"
 *                        to support "Eccentric Comps"
 *      08/10/94  Henk    Added default implementations of
 *                        VRGetOffCoord and VRSetOffCoord
 *      01/16/96  tlb     Add protoypes
 *      04/17/96  hv      Get connect props from database
 *      01/12/98  law     CR179309874-New raceway shapes
 *      02/03/98  Alwin   TR179700960, Modified the Md VRGetCptProp().
 *      02/25/98  Alwin   TR179800624, Modified the Md VRGetCptProp(), to make
 *			  simple check, to ensure the proper value of the end
 *			  preparation is returned.
 *      09/11/98  Alwin   TR179701247, Modified the Md VRGetCptProp(), to return
 *			  proper diamter for dangle.
 *      11/03/98  Alwin   Corrected the osnum. Fixed for MariSTEP
 *  June  5 2000  Anand   Fix for TR 179901584 - do-while loop construct caused
 * 			  software to lock-up because of an infinite loop.
 *   			  Rectified by using a for construct.
 *  June 21 2000  Anand   Fix for TR 179901704 - The fix for TR 179901584
 *			  necessitated that a variable be initialised. The
 *			  initialisation of this variable (nScanCpNum) fixes
 *			  this TR!!
 *      06/27/00  HF      Fixed memory leak
 *   Nov 17 2000  Anand   ETL 1401. Prevented DB values in macro being
 *			  overwritten by a kludge.
 *   Sep 14 2000  Anand   JTS TR MP 4843. VRGetNeighbors was failing for some
 *			  cases that were created by a particular workflow. The
 *			  curious fact was that they failed only for 'vertical'
 *			  networks but not for horizontal. This TR took several
 *			  weeks to figure out the bug was on a cut-pasted code!
 *      04/05/02  law     TR5649-standardize tolerance with VRGetTol
 ***********************************************************************/

class implementation VRGeneric;

#include <math.h>
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "vrparameters.h"
#include "VRMath.h"
#include "VRDbParamDef.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "VDmem.h"
#include "asbox.h"
#include "ACrg_collect.h"
#include "ACattrib.h"

#include "vrsegmen_pto.h"
#include "vrtools_pto.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "vrdbgmacros.h"

#define AS_DEBUG
/*
#define MY_DEBUG
*/

from  VRCorrection  import  VRGetCmpNeighbor;
from  VRCorrection  import  VRGetPipeId;
from  VRCnrlSeg     import  VRget_terminators;
from  VRCnrlSeg     import  VRGetTopo;
from  ACrg_collect  import  ACget_named_attribute;
from  VRProduct     import  VRGetProduct;

/***********************************************************************/

method  VRGetNumberOfCpts (IGRlong    *msg;
                           IGRint     *NbCpts;
                    struct GRmd_env   *md_env  )
{
  SetProc( VRGeneric_VRGetNumberOfCpts ); Begin
  *msg=MSSUCC;

  /*" ---- %s ----\n",me->szAABBCC */

  /*" I have %d defined connect points \n",me->nNbCpts */
  *NbCpts = (IGRint) me->nNbCpts;

  End
  return OM_S_SUCCESS;

}/* end VRGetNumberOfCpts */

/***********************************************************************/

method  VRSelectCptByGeom (IGRlong     *msg;
                           IGRdouble   *dConPos;
                           IGRdouble   *dConVect;
                           IGRshort    *nCpNum;
                    struct GRmd_env    *md_env  )
{
  IGRlong      retmsg;
  IGRint       status,i;
  IGRint       NbCpts;
  IGRboolean   bEccentric=FALSE, bCenterJustif=FALSE;
  IGRdouble    dCpAxis[3],dCpCoor[3], dOrigin[3];
  BSrc      rc;

  struct  GRid    MyId;

  IGRdouble    BSlenvec();

  SetProc( VRGeneric_VRSelectCptByGeom ); Begin
  *msg    = MSFAIL;
  *nCpNum = -1;

  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  /*" ---- %s ----\n",me->szAABBCC */
#ifdef vdsDEBUG
  if (dConPos)
    printf ( "Position : %f,%f,%f\n",dConPos[0],dConPos[1], dConPos[2]);
  if (dConVect)
    printf ( "Vector   : %f,%f,%f\n",dConVect[0],dConVect[1], dConVect[2]);
#endif

  /*A Validate the arguments */
  if ( !dConVect )
  {
    /*C ERROR -> No VECTOR specified */
    End
    return OM_E_INVARG;
  }

  /*A Get Total number of connect points  */
  status=
  om$send (msg = message VRGeneric.VRGetNumberOfCpts(&retmsg ,&NbCpts,md_env),
      targetid = my_id);

  /*" Total Number Of Connect Points : %d\n",NbCpts*/

  /*A test whether the component is an eccentric component */
  if ( bEccentric = VRIsEccentricComp( &retmsg, &MyId, md_env ) )
  {
    /*A get the segment on this Cpt  */
    status =
    om$send (msg = message VRGeneric.VRGetOrigCoor(&retmsg, dOrigin, md_env),
        targetid = my_id);
    as$status ( action = RET_STATUS );
  }

  /*A get the Cpt that matches the specified connection vector  */
  for (i=0; i<NbCpts; i++ )
  {
    status=
    om$send (msg = message VRGeneric.VRGetCptGeom
                            (&retmsg, (IGRshort) i, dCpCoor,
                                 dCpAxis, NULL, md_env),
        targetid = my_id);
    as$status( );

#ifdef vdsDEBUG
    printf("Cp Vector : %f,%f,%f\n",dCpAxis[0],dCpAxis[1],dCpAxis[2]);
    printf("Cp Coors  : %f,%f,%f\n",dCpCoor[0],dCpCoor[1],dCpCoor[2]);
#endif

    if ( bEccentric )
    {
      struct  GRid  SupId;

      /*A initialize every time  */
      bCenterJustif = FALSE;

      /*A get the support id    */
      status=
      om$send (msg = message VRGeneric.VRGetSupOnCpt
                                    (&retmsg, (IGRshort) i, &SupId, md_env ),
          targetid = my_id);
      as$status( action = RET_STATUS );

      /*A set the boolean value  */
      bCenterJustif =
      VRIsCenterJustified( &MyId, &SupId, md_env );

    } /*end eccentric treatment  */

    /*A Case Non Oriented connect point */
    if (BSlenvec (&rc,dCpAxis) < VRGetTol(VR_LENGTH_TOL) )
    {
#ifdef vdsDEBUG
      printf("Found I non oriented connect point #%d\n",i);
#endif
      /*A test alignment */
      if ( dConPos )
      {
        IGRint    j;
        IGRdouble  dVect[3];

        /*A process everything wrt center point if
            it is an eccentric component and placed
            wrt  center        */

        if ( bEccentric && bCenterJustif )
          for ( j=0; j<3; j++ )
            dCpCoor[j] = dOrigin[j];

        /*A Test on connection alignement */
        /* build vector cpt,ConPos */
        BSmkvec ( &rc, dVect, dCpCoor, dConPos);
        if ( rc != BSSUCC )
          /*| ERROR -> BSmkvec failed */
          continue;

        if ( BSlenvec ( &rc, dVect ) < VRGetTol(VR_LENGTH_TOL) )
        {
          /*| Coincident Points */
          *nCpNum = (IGRshort) i;
          *msg = MSSUCC;
          break;
        }

        BSnorvec ( &rc, dVect );
        if ( rc != BSSUCC )
          /*| ERROR -> BSnorvec failed */
          continue;

        if ( bVRTestVect (&retmsg, dVect, dConVect, VR_COLINEAR))
        {
          /*| Alignement Succeded */
          *nCpNum = (IGRshort) i;
          continue;/* try to find a better one */
        }

      }/* end check on dConPos */
      else     continue;

    }
    else
    if( bVRTestVect (&retmsg, dConVect,dCpAxis, VR_SAME) )
    {
      /*A Case Oriented connect point */

#ifdef vdsDEBUG
      printf(" Cpt #%d has the right connection axis\n",i);
#endif

      if ( dConPos )
      {
        IGRint    j;
        IGRdouble  dVect[3];
        IGRdouble  dLgt;
        IGRdouble  dCos;
        IGRdouble  fabs();

        /*A process everything wrt center point if
            it is an eccentric component and placed
            wrt  center        */

        if ( bEccentric && bCenterJustif )
        for ( j=0; j<3; j++ )
          dCpCoor[j] = dOrigin[j];

        /*A build vector cpt,ConPos */
        BSmkvec ( &rc, dVect, dCpCoor, dConPos);

        if ( rc != BSSUCC )
          /*| ERROR -> BSmkvec failed */
          continue;

        dLgt = BSlenvec ( &rc, dVect );

#ifdef vdsDEBUG
        printf(" Cpts Vector length : %f\n", dLgt);
#endif

        if ( dLgt < VRGetTol(VR_LENGTH_TOL) )
        {
          /*| Coincident Points */
          *nCpNum = (IGRshort) i;
          *msg = MSSUCC;
          break;
        }
        BSnorvec ( &rc, dVect );
        if ( rc != BSSUCC )
          /*| ERROR -> BSnorvec failed */
          continue;

#ifdef vdsDEBUG
        printf(" Cpts Vector : %f, %f, %f\n",dVect[0],dVect[1],dVect[2]);
#endif

        /*  TR#179422285   */

        /*  for strangely skewed lines this may still be
            to strict, replace with inline colinear test..... */

/*
        if ( bVRTestVect (&retmsg, dVect,
            dConVect, VR_COLINEAR))
*/
        dCos = BSdotp ( &rc, dVect, dConVect) /
                                  (BSlenvec(&rc, dConVect) *
                                   BSlenvec(&rc, dVect));


#ifdef vdsDEBUG
        printf ("DCOS %f\n",dCos);
#endif

        if ((fabs(dCos)) > 0.995)
        {
          /*| Alignement Succeded */
          *nCpNum = (IGRshort) i;
          *msg = MSSUCC;
          break;
        }

      }/* end check on dConPos */
      else
      {
        /*| No test on connection alignement => Good cpt */
        *nCpNum = (IGRshort) i;
        *msg = MSSUCC;
        break;
      }/* end no check on dConPos */

    }/* end test on vector for oriented connect points */

  }/* end loop on connect points */

#ifdef vdsDEBUG
 printf("exit VRSelectCptByGeom on obj %d, ncpnum,msg,SUCC,FAIL %d %d %d %d\n",
                              my_id,*nCpNum,*msg,MSSUCC,MSFAIL);
#endif
  End
  return (OM_S_SUCCESS);

}/* end VRSelectCptByGeom */

/***********************************************************************/

method VRGetCptProp (IGRlong     *msg ;
                     IGRshort     nCpNum;
              struct VRcp_attr   *ConProp;
              struct GRmd_env    *md_env )
{
  /* ---------- METHOD:      VRGetCptProp ---------- */

  IGRint      status;
  SetProc( VRGeneric_VRGetCptProp ); Begin

  __DBGpr_int( " Connect point ", nCpNum );

  if ( !ConProp )
  {
    /*| ERROR -> NULL Pointer given */
    *msg=MSFAIL;
    __DBGpr_com( " Null Pointer " );
    End
    return ( OM_E_INVARG );
  }

  *msg=MSSUCC;


  if ( me->Status & ( VR_BUILT_IN | VR_ERROR ))
  {
    /* -- If system's component : No connection properties -- */
    /*| No Connection properties */

    *msg = MSFAIL;

    /* added by alwin for TR179701247 */
    {
        IGRint                  FootIndex;
        IGRlong                 retmsg;
        struct GRid             SysParamId;
        struct ret_struct       ParamAttr;

        status = om$send ( msg = message VRGeneric.VRGetParams(&retmsg,
                                &SysParamId, NULL, NULL ),
                             targetid =  my_id );

        status =
        om$send( msg = message ACncpx.ACgive_structure
                      ( (IGRint*)&retmsg, &FootIndex, "npd_g",
                      &ParamAttr, md_env),
                targetid = SysParamId.objid,
                targetos = SysParamId.osnum );
        as$status( );

        ConProp->width = ParamAttr.var.root_pm_st.value;
        __DBGpr_dbl( " Dangle Diameter ", ParamAttr.var.root_pm_st.value );
    }
    /* added by alwin for TR179701247 */

  }
  else
  if (bVR_IS_PID(me->xform_chan) )
  { /* Again looking at a macro for parameters..............
       THIS DOES NOT WORK IN PID... NOBODY IS HELPED BY SILENTLY FAILING   */
    IGRshort           nProd;
    IGRint             NbCorr;
    IGRint             FootIndex = -1;
    IGRint             intmsg;
    IGRlong            retmsg;
    IGRdouble          W1, W2, D1, D2;
    IGRdouble          dW1, dD1;

    struct GRid        CorrId[VR_MAX_CPTS];
    struct GRid        PipeId;
    struct ret_struct  ParamAttr;

    __DBGpr_com( " It's in PID rep " );

    ConProp->end_prep = -1;
    ConProp->pressure = 0.0;
    ConProp->cp_offset = 0.0;

    status =
    om$send ( msg = message VRProduct.VRGetProduct (&nProd, NULL),
         targetid = my_id);

    if( nProd == VR_PIPING )
    {   /*    get two diams    */
      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_GDIAMETER_DB,
                              &ParamAttr, md_env),
           targetid = my_id);

      W1 = D1 = ParamAttr.var.root_pm_st.value;
      __DBGpr_dbl( " Green Diameter ", W1 );

      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_RDIAMETER_DB,
                              &ParamAttr, md_env),
           targetid = my_id);

      W2 = D2 = ParamAttr.var.root_pm_st.value;
      __DBGpr_dbl( " Red Diameter ", W2 );

    }
    else
    {
      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_WIDTH1_DB,
                              &ParamAttr, md_env),
           targetid = my_id);

      W1 = ParamAttr.var.root_pm_st.value;

      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_DEPTH1_DB,
                              &ParamAttr, md_env),
           targetid = my_id);

      D1 = ParamAttr.var.root_pm_st.value;

      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_WIDTH2_DB,
                              &ParamAttr, md_env),
           targetid = my_id);

      W2 = ParamAttr.var.root_pm_st.value;

      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_DEPTH2_DB,
                              &ParamAttr, md_env),
           targetid = my_id);

      D2 = ParamAttr.var.root_pm_st.value;

      /* added by alwin */
      /* Previously this wasn't returning the "->section_mask" connection
         property. Because of which in pid rep, whenever you sketch of
         a Nozzle, it used to sketch OVAL duct always */
      { /* Get the System Parameters Id and get the "SHAPE CODE" from
           the Component */

        IGRint                  FootIndex = -1;
        IGRint                  intmsg;
        IGRlong                 retmsg;
        struct GRid             SysParamId;

        status = om$send ( msg = message VRGeneric.VRGetParams(&retmsg,
                                &SysParamId, NULL, NULL ),
                             targetid =  my_id );

        status =
        om$send( msg = message ACncpx.ACgive_structure
                      (&intmsg, &FootIndex, "shape_code", &ParamAttr, md_env),
                            senderid = my_id,
                            targetid = SysParamId.objid,
                            targetos = SysParamId.osnum );
        as$status( );
        /*  status = %x and intmsg = %x \n", status, intmsg */
        /* Shape Code = %f \n", ParamAttr.var.root_pm_st.value */

        switch( (IGRint) ParamAttr.var.root_pm_st.value )
        {
           case VR_RECT :
                        ConProp->section_mask = VR_RECT;
                        break;

           case VR_OVAL :
                        ConProp->section_mask = VR_OVAL;
                        break;

           case VR_CIRC :
                        ConProp->section_mask = VR_CIRC;
                        break;

           case VR_CORNER :
                        ConProp->section_mask = VR_CORNER;
                        break;
           /* Below added for CR179309874 - New raceway shapes */
           case VR_ELLIPSE :  /* Only for raceway */
                        ConProp->section_mask = VR_ELLIPSE;
                        break;
        }
      }
      /* added by alwin */

    }

    /*   set defaults and see if I need to switch    */

    ConProp->width = W1;
    ConProp->depth = D1;
    __DBGpr_dbl( " Default Diameter ", ConProp->width );

    status =
    om$send ( msg = message VRGeneric.VRGetCorrections
                             (&retmsg, VR_MAX_CPTS, CorrId, &NbCorr),
         targetid = my_id);
    as$status ();

    __DBGpr_int( " Nb of Corrections ", NbCorr );
    /* added for TR179700960. Alwin */
    if (NbCorr <= 0)
    {
       IGRint NbCpts=0;
       struct VRcp_attr   CpAttr;
       struct GRid        ModelId;

       status =
       om$send ( msg = message VRGeneric.VRGetNumberOfCpts( &retmsg, &NbCpts,
                                                        md_env ),
                                targetid = my_id );
       __DBGpr_int( " Nb. of Connect Points ", NbCpts );

       if( NbCpts == 2 )
       {
          ConProp->width = W2;
          ConProp->depth = D2;
       }
    /* added for TR179700960. Alwin */
       goto quit;
    }

    status =
    om$send ( msg = message VRCorrection.VRGetPipeId (&retmsg, &PipeId),
         targetid = CorrId[0].objid,
         targetos = CorrId[0].osnum);
    as$status ();

    __DBGpr_obj( " Pipe Id ", PipeId );
    /* added for TR179700960. Alwin */
    if (PipeId.objid == NULL_OBJID)
    {
       IGRint NbCpts=0;

       __DBGpr_com( " PipeId is NULL " );

       status =
       om$send ( msg = message VRGeneric.VRGetNumberOfCpts( &retmsg, &NbCpts,
                                                        md_env ),
                                targetid = my_id );
       __DBGpr_int( " Nb. of Connect Points ", NbCpts );

       if( NbCpts == 2 )
       {
          ConProp->width = W2;
          ConProp->depth = D2;
       }
       else if( NbCpts > 3 )
       {
          if( nCpNum == 1 )
              ConProp->width = W1; /*In ths case of REDTEE(W1xW1xW2) */
          else if( nCpNum == 2 )
              ConProp->width = W2;
       }

    /* added for TR179700960. Alwin */
       goto quit;
    }

#ifdef MY_DEBUG
    printf ("PIPEID %d %d\n",PipeId.objid,PipeId.osnum);
#endif

    if( nProd == VR_PIPING )
    {   /*    get pipediam    */
      IGRint NbCpts;

      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_GDIAMETER_DB,
                              &ParamAttr, md_env),
           targetid = PipeId.objid,
           targetos = PipeId.osnum);
      as$status ();

      dW1 = dD1 = ParamAttr.var.root_pm_st.value;
      __DBGpr_dbl( "1 Green Diameter ", dW1 );

      status =
      om$send ( msg = message VRGeneric.VRGetNumberOfCpts( &retmsg, &NbCpts,
                                                        md_env ),
                                targetid = my_id );
      __DBGpr_int( " Nb. of Connect Points ", NbCpts );

      if( NbCpts > 2 )
      {
          if( nCpNum == 1 )
              ConProp->width = W1; /*In ths case of REDTEE(W1xW1xW2) */
          else if( nCpNum == 2 )
              ConProp->width = W2;
      }
      else if (fabs (W1 - dW1) < VRGetTol(VR_DIST_TOL)) ConProp->width = W2;

      ConProp->depth = ConProp->width;
      __DBGpr_dbl( "1 Green Depth ", ConProp->depth );

    }
    else
    {
      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_WIDTH1_DB,
                              &ParamAttr, md_env),
           targetid = PipeId.objid,
           targetos = PipeId.osnum);
      as$status ();

      dW1 = ParamAttr.var.root_pm_st.value;

      status =
      om$send ( msg = message ACncpx.ACgive_structure
                            (&intmsg, &FootIndex, VR_N_DEPTH1_DB,
                              &ParamAttr, md_env),
           targetid = PipeId.objid,
           targetos = PipeId.osnum);
      as$status ();

      dD1 = ParamAttr.var.root_pm_st.value;

      if ((fabs (W1 - dW1) < VRGetTol(VR_DIST_TOL)) && (fabs (D1 - dD1) < VRGetTol(VR_DIST_TOL)))
      {
        ConProp->width = W2;
        ConProp->depth = D2;
      }
    }
  }
  else
  {
    struct VRcp_attr   CpAttr;
    struct GRid        ModelId;
    struct GRid        MyId;
    struct GRid        DBCache;
    struct ACrg_coll   Param;

    IGRlong     retmsg;
    IGRshort    nTmpNum, Product;

    /* KLUDGE : management of dynamic connect points for pipes */

    if ( (me->Status&VR_CORRECTION) && nCpNum > 0 )
    {
      nTmpNum = 1;   /* Oh ! Que ce n'est pas beau !!! */
        /* On part du principe que seul le pipe
           (2 cpts) peut avoir des points de
           connection dynamiques et que ceux-ci
           ont les memes caracteristiques que le
           CP_1 */
        /* En fait, les caracteristiques des points
           dynamiques ne sont jamais accedees car il
           n'y a pas de correction pour eux */
    }
    else
    {
      nTmpNum = nCpNum;
    }

    /* -- Else get connection properties from Graphics -- */

    status = om$get_objid_at_index (object  = me,
                               p_chanselect = &AS_to_comp,
                                    index   = 0,
                               objidaddr    = &ModelId.objid,
                               osnumaddr    = &ModelId.osnum);
    as$status ( action = RET_STATUS );

    __DBGpr_obj( " ModelId ", ModelId );

    status = VRget_cp_attr (&ModelId, nTmpNum, &CpAttr);
    if ( ! (status & OM_S_SUCCESS) )
    {
	__DBGpr_com( " Function VRget_cp_attr failed " );
	End
	return OM_E_INVARG;
    }

    /*" Connect point #%d :\n",nCpNum*/
    /*"  cp_offset  = %f\n",CpAttr.cp_offset*/

    __DBGpr_dbl( " width/diam ", CpAttr.width );
    __DBGpr_int( " end prep ", CpAttr.end_prep );
    __DBGpr_dbl( " pressure ", CpAttr.pressure );

#ifdef MY_DEBUG
    printf ("Model %d, endprep %d\n",ModelId.objid,CpAttr.end_prep);
    printf ("From: %s id %d\n",me->szAABBCC,my_id);
#endif

    MyId.objid =my_id;
    MyId.osnum = OM_Gw_current_OS;

    status = VRGetCmpClass( &MyId, &Product );

    if( !(status&1) )
    {
      /** If product undetermined, retrieve the end_prep from macro **/
/*	printf( "Myid %d\n", my_id ); */
	Product = VR_HVAC;
    }


    /*********************************************************************
     * The below if condition voided (changed to an if(0))
     *					by Anand for ETL1401 (Nov 17, 2k).
     *
     * JUSTIFICATION:
     * The below if condition was inserted for TR 179601434 &
     * 179601311. As per the comment below, the code intended to overwrite
     * the DB values inside the macro. Further, the overwrite was based on
     * the assumption that Cpt 0 always uses PREP_G and Cpts 1 and greater
     * always use PREP_R. This is *NOT* correct.
     * Commenting it out and testing the product extensively (by Paul
     * Cheatham) shows that the product behaves as desired.
     *
     * The below if condition voided (changed to an if(0))
     *					by Anand for ETL1401 (Nov 17, 2k).
     *
     *********************************************************************/

    if( 0 ) // ( Product == VR_PIPING )
    {

    /*  Now to correct this idiocy of storing the DB values inside
        the macro (wrongly at times) for piping, I'll override these with
        the real DB values as needed  (TR# 179601434 & 179601311)   */
    /*    for now, only the endprep to get rid of spurious flanges   */

	/* In the case of Nozzle , the Model Id will be returned as NULL_OBJID.
	Whereas the actual Connect Point properties and end prep values would
	have been obtained before reaching this place; using VRget_cp_attr()
	function. B'cas of the below call the actual values obtained from the
	function will be lost. So check the ModelId for NULL_OBJID, if so quit.
	Alwin for TR179800624 */

    	status =
    	om$send ( msg = message VRGeneric.VRGetModel (&retmsg, &DBCache, md_env),
         	targetid = my_id);
    	as$status ();

	if( DBCache.objid == NULL_OBJID )
	{
	    /* Set the already obtained values through the function
	    VRget_cp_attr(). Alwin */

	    *ConProp = CpAttr;
	    End
	    return ( OM_S_SUCCESS );
	}

    	Param.desc.type = AC_ATTRIB_DOUBLE;
	if( ! nCpNum )
    		strcpy (Param.name, VR_N_PREP_G_IN);
	else
    		strcpy (Param.name, VR_N_PREP_R_IN);

    	status =
    	om$send ( msg = message ACrg_collect.ACget_named_attribute
                                            (&retmsg, &Param),
         	targetid = DBCache.objid,
         	targetos = DBCache.osnum);

      if (retmsg & MSSUCC)
        CpAttr.end_prep = Param.desc.value.att_exp;
      else
      {
        retmsg = MSSUCC;
#ifdef MY_DEBUG
        /*    to be checked, is it piping??? no endprep??    */

        printf ("NO DB ATTR\n");
#endif
       }
    }

#ifdef MY_DEBUG
    printf ("Corrected endprep %d\n",CpAttr.end_prep);
    printf ("From: %s id %d, cache %d\n",me->szAABBCC,my_id,DBCache.objid);
#endif

    *ConProp = CpAttr;

  }

  quit:
  End
  return ( OM_S_SUCCESS );

}/* end method VRGetCptProp */

/***********************************************************************/

method VRGetCptGeom (IGRlong     *msg;
                     IGRshort     nCpNum;
                     IGRdouble   *dCptCoor;
                     IGRdouble   *dConAxis;
                     IGRdouble   *dOrientation;
              struct GRmd_env    *md_env)

{
  /* ---------- METHOD:      VRGetCptGeom ---------- */

  IGRint      status;
  IGRint      i, NbCpts,DynCpts;
  IGRshort    TmpCpNum;
  IGRlong     retmsg;

  SetProc( VRGeneric_VRGetCptGeom ); Begin
  if (me->Status&VR_ERROR)
  {
    /* Call Error component */
    status=
    om$send ( msg = message VRGeneric.VRGetErrGeom
                      (msg ,nCpNum,dCptCoor,dConAxis,dOrientation,md_env ),
         targetid = my_id);

    End
    return (status);
  }/* end error treatment */

  /*" ---- %s ----\n",me->szAABBCC */

  /*" Connect point : %d \n",nCpNum*/

  /* -- Get Total number of connect points -- */
  status=
  om$send (msg = message VRGeneric.VRGetNumberOfCpts (&retmsg ,&NbCpts, md_env),
      targetid = my_id);

  /*" Total Number Of Connect Points : %d\n",NbCpts*/

  if ( nCpNum < 0 || nCpNum >= NbCpts )
  {
    /*| ERROR -> Bad Cpt Number */
    *msg=MSFAIL;
    End
    return ( OM_E_INVARG );
  }

  /* -- manage dynamic connect points -- */
  DynCpts = NbCpts - me->nNbCpts;

  if ( (nCpNum>0) && (nCpNum<=DynCpts) )
  {
    IGRint    TmpNbNei;
    IGRshort  nNeiCpNum;
    struct GRid  TmpNeiId;

    /*"----> Cpt#%d is a Dynamic Cpt\n", nCpNum */

    status=
    om$send ( msg = message VRGeneric.VRGetNeighbors
                                 ( &retmsg, nCpNum, nCpNum, &TmpNbNei,
                                        &TmpNeiId, &nNeiCpNum, md_env),
         targetid = my_id);
    as$status ( action = RET_STATUS );

    /* -- get geometry from neighbor connect point -- */
    status=
    om$send ( msg = message VRGeneric.VRGetCptGeom
                                         (msg, (IGRint)nNeiCpNum,
                                      dCptCoor, dConAxis, dOrientation, md_env),
         targetid = TmpNeiId.objid,
         targetos = TmpNeiId.osnum);
    as$status ( action = RET_STATUS );

  }/* end dynamic connect points management */
  else
  {
    IGRchar     footname[20];
    IGRint      Index=-1;
    BSrc        rc;

    struct ret_struct  AttrSt;
    struct GRid        GraphicId;

    TmpCpNum = (nCpNum) ? (nCpNum-DynCpts) : 0;

    /*"----> Cpt#%d (%d) is a Predefined Cpt\n", nCpNum, TmpCpNum */

    *msg=MSSUCC;


    /* -- Else get connection properties from Model -- */

    status = om$get_objid_at_index (object  = me,
                               p_chanselect = &AS_to_comp,
                                    index   = 0,
                               objidaddr    = &GraphicId.objid,
                               osnumaddr    = &GraphicId.osnum);
    as$status ( action = RET_STATUS );

    if(dCptCoor)
    {

      /*| Return connect point coordinates */

      VRCptEncode (TmpCpNum, footname, ":graphic");

      status =
      om$send ( msg = message NDmacro.ACgive_structure
                                      ( (IGRint *) &retmsg, &Index,
                                           footname, &AttrSt, md_env ),
           targetid = GraphicId.objid,
           targetos = GraphicId.osnum );
      as$status ( action = RET_STATUS );

      for (i=0;i<3;i++)
        dCptCoor [i] = AttrSt.var.point_st.pt[i];

      /*" \t %f,%f,%f\n",dCptCoor[0],dCptCoor[1],dCptCoor[2]*/

    }/* end return CptCoor */

    if ( dConAxis )
    {
      /*| Return connection vector */

      VRCptEncode (TmpCpNum, footname, ":axis");

      status =
      om$send ( msg = message NDmacro.ACgive_structure
                                      ( (IGRint *) &retmsg, &Index,
                                           footname, &AttrSt, md_env ),
           targetid = GraphicId.objid,
           targetos = GraphicId.osnum );
      as$status ( action = RET_STATUS );

      for (i=0;i<3;i++)
        dConAxis [i] = AttrSt.var.point_st.pt[i];

      BSnorvec ( &rc, dConAxis );
      /*" \t %f,%f,%f\n",dConAxis[0],dConAxis[1],dConAxis[2]*/

    }/* end return connection axis */

    if ( dOrientation )
    {
      /*| Return orientation vector */

      VRCptEncode (TmpCpNum, footname, ":yaxis");

      status =
      om$send ( msg = message NDmacro.ACgive_structure
                                      ( (IGRint *) &retmsg, &Index,
                                           footname, &AttrSt, md_env ),
           targetid = GraphicId.objid,
           targetos = GraphicId.osnum );
      as$status ( action = RET_STATUS );

      for (i=0;i<3;i++)
        dOrientation [i] = AttrSt.var.point_st.pt[i];

      BSnorvec ( &rc, dOrientation );
      /*" \t %f,%f,%f\n",dOrientation[0],dOrientation[1],dOrientation[2]*/

    } /* end return section orientation */

  }/* end defined connect points management */

  End
  return ( OM_S_SUCCESS );

}/* end VRGetCptGeom */

/***********************************************************************/

method VRGetOrigCoor ( IGRlong      *msg ;
                       IGRdouble    *dOrigCoor;
                struct GRmd_env     *md_env)

{
/* ---------- METHOD:      VRGetOrigCoor ---------- */
  IGRint    status;
  SetProc( VRGeneric_VRGetOrigCoor ); Begin

  /*" ---- %s ----\n",me->szAABBCC */

  if ( !dOrigCoor )
  {
    /*| ERROR -> NULL Pointer given */
    *msg=MSFAIL;
    End
    return ( OM_E_INVARG );
  }
  else
  {
    IGRshort   nTmpType;
    IGRdouble  dMatrix[16];

    *msg=MSSUCC;

    /*| Get matrix from graphics */

    status =
    om$send ( msg = message GRowner.GRget_matrix ( msg,
                                            &md_env->md_env.matrix_type,
                                            md_env->md_env.matrix,
                                            &nTmpType, dMatrix ),
     p_chanselect = &AS_to_comp,
             from = 0,
               to = 0  );
    if ( !(status & OM_S_SUCCESS) )
    {
       End
       return OM_W_ABORT;
    }

    dOrigCoor[0]= dMatrix[3];
    dOrigCoor[1]= dMatrix[7];
    dOrigCoor[2]= dMatrix[11];

    /*" \t %f,%f,%f\n",dOrigCoor[0],dOrigCoor[1],dOrigCoor[2]*/
  } /* end if */

  End
  return ( OM_S_SUCCESS );

}/* end method VRGetOrigCoord */

/***********************************************************************/

method VRGetNeighbors (IGRlong   *msg;
                       IGRint     CpFrom;
                       IGRint     CpTo;
                       IGRint    *NbNeigh;
                struct GRid      *NeiId;
                       IGRshort  *nNeiCpNum;
                struct GRmd_env  *md_env)
{
  IGRint    status;
  IGRlong   retmsg;
  IGRint    CpNum, NbCpts, NbNeiInBuf=0;

  struct GRid  CorId, MyId;
  struct GRid *SegIds = NULL;

  SetProc( VRGeneric_VRGetNeighbours ); Begin
  *NbNeigh   = 0;
  *msg       = MSSUCC;
  MyId.objid = my_id;

  /* changed by alwin... found this while fixing MariSTEP */
  MyId.osnum = md_env->md_id.osnum; /* OM_Gw_current_OS ->md_env->md_id.osnum */

  __DBGpr_str( " Component's Code", me->szAABBCC );

  /*" Connect points between %d and %d\n",CpFrom, CpTo*/

  status =
    om$send (msg = message VRGeneric.VRGetNumberOfCpts( &retmsg, &NbCpts, md_env),
             targetid = my_id);
  as$status ( action = RET_STATUS );

  __DBGpr_int( " Total Number Of Connect Points ", NbCpts );

  if ( CpFrom < 0 || CpFrom >= NbCpts || CpFrom > CpTo || !NbNeigh )
  {
    __DBGpr_com( " ERROR -> Bad Cpt Number " );
    *msg=MSFAIL;
    End
    return ( OM_E_INVARG );
  }

  /* -- get correction on my cpt -- */

  for ( CpNum=CpFrom; (CpNum<NbCpts &&  CpNum<=CpTo); CpNum++, NbNeiInBuf++ )
  {  /* -- Loop on connect points -- */

    if ( NeiId )    NeiId[NbNeiInBuf].objid = NULL_OBJID;
    if ( nNeiCpNum )  nNeiCpNum[NbNeiInBuf] =-1;

    __DBGpr_int( " Getting Correction on Cpt ", CpNum );
    status =
      om$send ( msg = message VRGeneric.VRGetCorOnCpt ( &retmsg, CpNum,
                                                        &CorId, md_env),
                targetid = my_id);
    as$status ();
    __DBGpr_obj( " Correction Id ", CorId );

    if ( retmsg != MSSUCC )
    {
      IGRshort    nMyIndex,nScanCpNum;
      IGRint      NbComps;
      IGRint      NbSegs,j;
      IGRint      PipeCpts,TmpNbNei;
      BSrc        rc;
      IGRboolean  bFound=FALSE;
      IGRdouble   dConAxis[3],dCptCoor[3];
      IGRdouble   BSlenvec();

      struct GRid  SelSegId, PrevId,NextId,CompIds[2];
      struct GRid  PipeId,*TmpNeiIds,CorId;

      TmpNeiIds=NULL;

      /*" \tNO CORRECTION on cpt#%d\n", CpNum */
      /* -- check whether we should have one or not -- */
      status=
        om$send ( msg = message VRGeneric.VRGetCptGeom
                  (msg, (IGRshort)CpNum, dCptCoor, dConAxis, NULL, md_env),
                  targetid = my_id );
      as$status( action = RET_STATUS );

      if ( BSlenvec (&rc,dConAxis) > VRGetTol(VR_LENGTH_TOL) )
      {  /*|\t --> Not Yet connect */
        continue;
      }

      /* ------------------------------ */
      /* -- It's a non corrected cpt -- */
      /* ------------------------------ */

      /*| Scan network to find correction */

      __DBGpr_com( " Getting VRGetSupports " );
      status =
        om$send ( msg = message VRGeneric.VRGetSupports ( &retmsg, 0,
                                                          NULL, &NbSegs ),
                  targetid = my_id);

      NbSegs++;
      // HF: 06/27/00 Memory Leak !!!
      if (SegIds) _FREE(SegIds);
      SegIds = _MALLOC (NbSegs, struct GRid);
      if ( !(SegIds) )
      {
	__DBGpr_com( " Memory Allocation error" );
	*msg=MSFAIL;
	End
        return OM_E_NODYNMEM;
      }

      __DBGpr_com( " Getting VRGetSupports " );
      status =
        om$send ( msg = message VRGeneric.VRGetSupports ( &retmsg, NbSegs,
                                                          SegIds, &NbSegs ),
                  targetid = my_id);

      /* Fix for TR 179901584: The below for loop was originally implemented as
       * a do-while loop that caused an infinite loop for corrupted SegIds */

      __DBGpr_int(" CpNum before for loop",CpNum);
      __DBGpr_objlist( "Segments", NbSegs, SegIds );

      /* Fix for TR 179901704 - Initialise nScanCpNum before it is used! */
      /* -- select support for scanning the network -- */
      for( j=0, nScanCpNum=-1 ; (nScanCpNum != CpNum) && (j < NbSegs) ; j++ )
      { /* loop for finding a support on which CpNum is */
        status =
          om$send( msg   = message VRCnrlSeg.VRGetTopo (&retmsg, dConAxis,NULL,
                                                        NULL,NULL,NULL,md_env),
                   targetid = SegIds[j].objid,
                   targetos = SegIds[j].osnum );
        if (!(status & OM_S_SUCCESS)) continue;

	__DBGpr_vec(" SEGMENT AXIS VECTOR BEFORE VRSelectCptByGeom", dConAxis );
        status=
          om$send ( msg = message VRGeneric.VRSelectCptByGeom ( &retmsg,
                                                                dCptCoor,
                                                                dConAxis,
                                                                &nScanCpNum,
                                                                md_env ),
                    targetid = my_id);
        as$status();
	__DBGpr_vec(" SEGMENT AXIS VECTOR AFTER VRSelectCptByGeom", dConAxis );
      }
      __DBGpr_int(" j after for loop",j);
      __DBGpr_int(" nScanCpNum",nScanCpNum);

      if (j >= NbSegs)
      {  /*|\t --> Cannot get network entry*/
        continue;
      }
      j--;
      SelSegId = SegIds[j];
      __DBGpr_obj(" Selected Segment",SelSegId );
      PrevId.objid = my_id; PrevId.osnum = OM_Gw_current_OS;

      /* -- set the scanning vector -- */
      status=
        om$send ( msg = message VRGeneric.VRGetIndex ( &retmsg,
                                                       &SelSegId, &nMyIndex),
                  targetid = my_id);
      //as$status( action = RET_STATUS );
      as$status();
      if ( ! (status & 1))
      {
	  _FREE (SegIds);
	  End
	  return status;
      }

#ifdef vdsDEBUG
      printf("comp [%d] 's index on Cnrl Seg [%d] is %d\n", my_id,
							    SelSegId.objid,
							    nMyIndex );
#endif 

      if (!nMyIndex)
      {
	  dConAxis[0] *= -1;
	  dConAxis[1] *= -1;
	  /* Fix for JTS TR MP 4843: Changed the array index below from one to
	   * two. Magic of cut and paste! This TR took many many weeks before
	   * being tracked down to this point - Anand (Sept 14, 2001) */
	  dConAxis[2] *= -1;
	  __DBGpr_vec(" con axis reversed",dConAxis);
      }

      /*" We'll scan on support #%d <%d,%d>\n",j ,SelSegId.objid,SelSegId.osnum*/

      do
      {/* skip other components which do not have corrections */

        status =
          om$send( msg = message VRCnrlSeg.VRget_terminators (&retmsg,&NbComps,
                                                              md_env,NULL,CompIds),
                   targetid = SelSegId.objid,
                   targetos = SelSegId.osnum );
        if (!(status & OM_S_SUCCESS)) continue;

        if (   CompIds[0].objid == PrevId.objid &&
               CompIds[0].osnum == PrevId.osnum )
        {
	    /*| Take second child */
	    NextId = CompIds[1];
	}
        else
        {
	    /*| Take first child */
	    NextId = CompIds[0];
	}

        status=
          om$send ( msg = message VRGeneric.VRSelectCptByGeom(&retmsg,dCptCoor,
                                                              dConAxis,
                                                              &nScanCpNum,
                                                              md_env ),
                    targetid = NextId.objid,
                    targetos = NextId.osnum );
        as$status ();

        if ( retmsg != MSSUCC )
        {
          IGRboolean  bNextSeg;
          IGRint      NbSegb;
          struct GRid *SegIdb;

          status =
            om$send ( msg = message VRGeneric.VRGetSupports ( &retmsg, 0,
                                                              NULL, &NbSegb ),
                      targetid = my_id);

          NbSegb++;
          SegIdb = _MALLOC (NbSegb, struct GRid);
          if ( !(SegIdb) )
          {
            *msg=MSFAIL;
            End
            return OM_E_NODYNMEM;
          }

          /*|Skip component */
          status = om$send ( msg = message VRGeneric.VRGetSupports
                             ( &retmsg, NbSegb, SegIdb, &NbSegb ),
                             targetid = NextId.objid,
                             targetos = NextId.osnum );
          //as$status ( action = RET_STATUS );
          as$status();
	  if ( ! (status & 1))
	  {
	      _FREE (SegIdb);
	      End
	      return status;
	  }

          /* select the prolongation segment among the Next's supports */
          VRget_segment_to_notify( &retmsg, NbSegb, SegIdb, &SelSegId,&SelSegId,
                                   md_env, &bNextSeg );
          if (!bNextSeg)
          {
            __DBGpr_com( " ERROR -> cannot go further in the line " );
		*msg=MSFAIL;
		End
		return OM_E_ABORT;
	    }
          PrevId = NextId;

          _FREE (SegIdb);
        }
        else
          bFound = TRUE;

      } while ( ! bFound ); /* end scan for corrected component */

      /*" Found Next corrected component <%d,%d>\n",NextId.objid,NextId.osnum*/

      /* -- Scan Neighbors of this component to get mine -- */

      status=
        om$send ( msg = message VRGeneric.VRGetCorOnCpt
                  ( &retmsg, nScanCpNum, &CorId, md_env ),
                  targetid = NextId.objid,
                  targetos = NextId.osnum );
      as$status ();
      if ( !(status&1) ) continue;

      status=
        om$send ( msg = message VRCorrection.VRGetPipeId( &retmsg, &PipeId),
                  targetid = CorId.objid,
                  targetos = CorId.osnum );
      as$status ();
      if ( !(status&1) ) continue;

      /* -- Get Pipe cpt number -- */
      status=
        om$send ( msg = message VRGeneric.VRGetNumberOfCpts
                  ( &retmsg, &PipeCpts, md_env ),
                  targetid = PipeId.objid,
                  targetos = PipeId.osnum );
      as$status ();
      if ( !(status&1) ) continue;

      TmpNeiIds = _MALLOC( PipeCpts, struct GRid);
      if ( !(TmpNeiIds) )
      {
        *msg=MSFAIL;
        End
        return OM_E_NODYNMEM;
      }

      status=
        om$send ( msg = message VRGeneric.VRGetNeighbors
                  ( &retmsg, 0, PipeCpts, &TmpNbNei, TmpNeiIds,
                    NULL, md_env ),
                  targetid = PipeId.objid,
                  targetos = PipeId.osnum );
      as$status ();
      if ( !(status&1) )
      {
        _FREE(TmpNeiIds);
        continue;
      }

      for (j=0; j<TmpNbNei; j++)
      {
        if (  TmpNeiIds[j].objid == my_id &&
              TmpNeiIds[j].osnum == OM_Gw_current_OS )
        {
          /*" The pipe has me as neigh on cpt#%d\n",j*/

          if ( NeiId )
          {
            NeiId[NbNeiInBuf].objid  = PipeId.objid;
            NeiId[NbNeiInBuf].osnum  = PipeId.osnum;
          }
          if ( nNeiCpNum  )
          {
            nNeiCpNum[NbNeiInBuf]  =(IGRshort) j;
          }
          *NbNeigh += 1;

          break;
        }/* end if pipe neighb = my_id */

      }/* end loop on pipe's neighbors */

      _FREE (SegIds);
      _FREE (TmpNeiIds);
    }/* end no correction on cpt */
    else
    {
      IGRshort    TmpNbNei;

      /*" \tCorId = <%d,%d>\n",CorId.objid,CorId.osnum*/

      /* -- get THE neighborid and cpt from this correction -- */
      status =
        om$send ( msg = message VRCorrection.VRGetCmpNeighbor
                  ( &retmsg,
                    &MyId,
                    CpNum,CpNum,
                    &TmpNbNei,
                    (NeiId)?     &NeiId[NbNeiInBuf]     : NULL,
                    (nNeiCpNum)? &nNeiCpNum[NbNeiInBuf] : NULL,
                    md_env),
                  targetid = CorId.objid,
                  targetos = CorId.osnum );
      as$status ();

      /* -- Increment neighbors count -- */
      *NbNeigh += 1;

    }/* end get neighbor from correction */

    _FREE (SegIds);

  }/* end Loop on connect points */

  /*" ---> %d found neighbors among %d possible \n", *NbNeigh,NbNeiInBuf  */

  if ( NeiId || nNeiCpNum ) *NbNeigh = NbNeiInBuf;

  /*" ---> %d returned neighbors\n", *NbNeigh */

  if( NeiId ) __DBGpr_obj( " Neighbour Component Id ", *NeiId );
  if( nNeiCpNum ) __DBGpr_int( " Neighbour Cpt Num. ", *nNeiCpNum );

  End
  return ( OM_S_SUCCESS );
}/* end VRGetNeighbors */

/***********************************************************************/

method VRGetTopo ( IGRlong *msg ; IGRint BufSize;
      IGRint     *NbCpts;
      IGRdouble  *dCompOrig;
      IGRdouble  *dCpCoors;
      struct GRid   *NeiIds;
      IGRshort   *nNeiCpNum;
      struct GRmd_env *md_env)
{

  IGRint    status;
  IGRlong    retmsg;

  SetProc( VRGeneric_VRGetTopo ); Begin
*msg = MSSUCC;

  /*" ---- %s ----\n",me->szAABBCC */

if ( !NbCpts )
{
  /*| ERROR -> CANNOT RETURN NUMBER OF CPTS */
  End
  return (OM_E_INVARG);
}

  /* -- Return nb cpts -- */
  status=
  om$send ( msg = message VRGeneric.VRGetNumberOfCpts
      (&retmsg ,NbCpts, md_env ),
    targetid = my_id);
  as$status ( action = RET_STATUS );
  /*" Total Number Of Connect Points : %d\n",*NbCpts*/

  /* -- Return Origin point -- */
  if ( dCompOrig )
  {
  /*| Return origin point */

  om$send ( msg = message VRGeneric.VRGetOrigCoor
        (&retmsg ,dCompOrig, md_env ),
    targetid = my_id);

  }

  /* -- Check on bufsize -- */

  if ( (BufSize < *NbCpts) && ( dCpCoors || NeiIds || nNeiCpNum ) )
  {
    /*| ERROR -> BUFFER TOO SMALL*/
    *msg=MSFAIL;
    End
    return OM_E_INVARG;
  }

  /* -- Return CptsCoords -- */
  if ( dCpCoors )
  {
    register IGRint i;

    for ( i=0; i<*NbCpts; i++ )
    {
      /*" ---- CPT#%d ----\n",i */

        om$send ( msg = message VRGeneric.VRGetCptGeom
          (&retmsg, (IGRshort) i,
           &dCpCoors[i*3], NULL, NULL,
           md_env),
        targetid = my_id);
    }/* end loop on connect points */

  }/* end return connect points' coordinates  */

  /* -- Return Neighbor id and cpt -- */
  if ( NeiIds || nNeiCpNum )
  {
    IGRint    TmpNbNei;

    status=
    om$send ( msg = message VRGeneric.VRGetNeighbors
           ( &retmsg, 0, *NbCpts, &TmpNbNei,
          NeiIds, nNeiCpNum, md_env),
      targetid = my_id);
    as$status ( action = RET_STATUS );

  }/* end get neighbors info */

End
return ( OM_S_SUCCESS );

}/* end VRGetTopo */

/***********************************************************************/

method VRGetConnDesc (  IGRlong *msg ; struct GRid *OtherId;
      IGRshort *nTargetCpNum;
      IGRshort *nOtherCpNum;
      struct GRmd_env *md_env)
{

  IGRint    status;
  IGRint     i,NbCpts;
  IGRshort  nCpNum;
  IGRlong    retmsg;
  BSrc    rc;
  IGRdouble  dDistance,dVect[3];
  IGRdouble  dTCptCoor[3], dTConAxis[3];
  IGRdouble  dOCptCoor[3];
  IGRdouble  BSlenvec();

SetProc( VRGeneric_VRGetConnDesc ); Begin
*msg = MSFAIL;
*nTargetCpNum = -1;
*nOtherCpNum  = -1;
dDistance = -1;

  status=
  om$send ( msg = message VRGeneric.VRGetNumberOfCpts
      (&retmsg ,&NbCpts, md_env ),
    targetid = my_id);
  as$status ( action = RET_STATUS );
  /*" Total Number Of Connect Points : %d\n",NbCpts*/

  /* -- Loop on my cpts to find the corresponding one in the specified component -- */
  for ( i = 0; i<NbCpts; i++ )
  {
    status=
    om$send ( msg = message VRGeneric.VRGetCptGeom (&retmsg, (IGRshort)i,
            dTCptCoor, dTConAxis, NULL, md_env),
      targetid = my_id );
    as$status( action = RET_STATUS );
    if ( retmsg != MSSUCC ){ /*| ERROR -> cannot get cpt Geom */
      End
      return OM_E_ABORT ;}

    /* invert connection axis */
    dTConAxis[0] *= -1;dTConAxis[1] *= -1;dTConAxis[2] *= -1;

  /*" Select with : %f,%f,%f\n",dTConAxis[0],dTConAxis[1],dTConAxis[2]*/
  /*"        and  : %f,%f,%f\n",dTCptCoor[0],dTCptCoor[1],dTCptCoor[2]*/

    /* ask other component for matching connect point */
    status=
    om$send ( msg = message VRGeneric.VRSelectCptByGeom ( &retmsg,
            dTCptCoor, dTConAxis, &nCpNum, md_env),
      targetid = OtherId->objid,
      targetos = OtherId->osnum );
    as$status( action = RET_STATUS );
    if ( retmsg == MSSUCC )
    {
      /*"Possible : Targetcp#%d <--> Othercp#%d\n",i,nCpNum*/

      /* -- compute connection distance */
      status=
      om$send ( msg = message VRGeneric.VRGetCptGeom (&retmsg, nCpNum,
            dOCptCoor, NULL, NULL, md_env),
        targetid = OtherId->objid,
        targetos = OtherId->osnum );
      as$status( action = RET_STATUS );

      BSmkvec ( &rc, dVect,
          dTCptCoor,
          dOCptCoor);
      if ( rc != BSSUCC )
      {
        /*| ERROR -> BSmkvec failed */
        continue;
      }

      if ( BSlenvec ( &rc, dVect ) <= dDistance  || dDistance < 0)
      {
        /*| This is the best connection */
        dDistance = BSlenvec ( &rc, dVect );
        *nTargetCpNum = (IGRshort) i;
        *nOtherCpNum  = nCpNum;
        *msg = MSSUCC;
      }

    }/* end possible cpt */

  }/* end loop on cpts */

End
return OM_S_SUCCESS;

}/* end VRGetConnDesc */


/***********************************************************************/

method  VRSetOffCoord (IGRlong         *msg;
                struct GRid            *ChildId;
                       IGRshort         nCpt;
                       IGRdouble        dAngle;
                       IGRdouble        dDist;
                struct GRmd_env        *pModEnv)

{   /*   as a default    DO NOTHING, no offset stored    */
  *msg = MSSUCC;

  return OM_S_SUCCESS;
}

/***********************************************************************/

method  VRGetOffCoord (IGRlong         *msg;
                struct GRid            *ChildId;
                       IGRshort         nCpt;
                       IGRdouble       *dCoord;
                       IGRdouble       *dConaxis;
                struct GRmd_env        *pModEnv)

{   /*  as a default simply return the connect point stuff (without offset) */
  IGRdouble     dDummy[3];
  SetProc( VRGeneric_VRGetOffCoord ); Begin

  End
  return (

  om$send (msg = message VRGeneric.VRGetCptGeom
                        (msg, nCpt, dCoord, dConaxis, dDummy, pModEnv),
      targetid = my_id)
          );
}

/***********************************************************************/

end implementation VRGeneric;


