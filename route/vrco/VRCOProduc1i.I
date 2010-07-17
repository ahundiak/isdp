/* $Id: VRCOProduc1i.I,v 1.4 2002/04/10 15:04:37 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrco / VRCOProduc1i.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRCOProduc1i.I,v $
 *        Revision 1.4  2002/04/10 15:04:37  louis
 *        TR5649-standardize tolerances
 *
 *        Revision 1.3  2001/02/20 01:12:15  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/11 22:46:16  anand
 *        SP merge
 *
# Revision 1.3  2000/11/28  21:36:36  pinnacle
# Replaced: route/vrco/VRCOProduc1i.I for:  by lawaddel for Service Pack
#
# Revision 1.2  2000/11/22  21:28:08  pinnacle
# Replaced: route/vrco/VRCOProduc1i.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/04/27  20:02:52  pinnacle
# Created: route/vrco/VRCOProduc1i.I by apazhani for Service Pack
#
# Revision 1.2  1999/04/19  18:19:36  pinnacle
# Replaced: vrco/VRCOProduc1i.I for: CR179900491 by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  18:44:22  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/04/18  14:11:28  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route
#
# Revision 1.3  1997/04/15  22:13:38  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route
#
# Revision 1.2  1997/03/12  15:11:42  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.10  1996/05/10  20:05:32  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route240
#
# Revision 1.9  1996/05/03  20:08:32  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route240
#
# Revision 1.8  1996/03/20  00:08:44  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route240
#
# Revision 1.6  1996/03/05  22:05:40  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route240
#
# Revision 1.5  1996/03/04  18:15:36  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by hverstee for route240
#
# Revision 1.4  1996/01/18  23:28:52  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/16  21:27:12  pinnacle
# Replaced: vrco/VRCOProduc1i.I for:  by r240_int for route240
#
 *
 * History:
 *      10-24-1994        Lori          CR#179422038  Update action init
 *                                          to set spec list for HVAC
 *        01/15/96        tlb        Add VX_FIproto.h, prototypes
 *        01/17/96        tlb        Use VDfld_set_list_text
 *        04/01/98        law        Fixed length buffer from VRget_code_list
 *        04/19/99        Alwin      Modified the VRLoadForm() method to display
 *				     the Replace form.
 *        04/27/2000      Alwin      Modified VRCopyComponentAttr method to
 *				     Copy the Missing/Graphical attributes from
 *				     one component to another. CR179900999
 *        Nov 22 2k	  Anand	     CR 179902073
 *        11/20/2000      law        TR-MP4140 Allow 80 char. option-code
 *        04/05/02        law        TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation VRCOProduct;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "VRMath.h"
#include "dpmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbParamDef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "VRcsdef.h"
#include "VRDbStruct.h"
#include "VRdbcodlst.h"
#include "VRMcForm.h"
#include "VRPid.h"
#include "acrepdef.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "vrparameters.h"
#include "VDSutil.h"
#include "vrinit_pto.h"
#include "vrpdu_pto.h"
#include "vrtools_pto.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "parametric.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe


/*
#define MY_DEBUG
*/

/*************************************************************
    Components inserted on end-of-line components give
    difficulties (TR 179600376, 179601019, 179600603)

    following define governs a bypass to block this 
    operation. The further code is left intact in case time
    permits some rewrite to enable this option again.
                          HV 5/10/96                           */
#define BLOCK_COMP_TREE
/***************************************************************/

#define VR_OPTCODE_LIST_NUM  400

#define        DISPLAYED                2000
 
from  NDnode           import   NDdisplay,
                                NDchg_state;
from  GRgraphics       import   GRdelete;
from  GRvg             import   GRgetsymb;
from  VRGeneric        import   VRGetParams,
                                VRGetNumberOfCpts,
                                VRGetSysType,
                                VRGetStatus,
                                VRGetTopo,
                                VRGetCptProp,
                                VRGetCptGeom,
                                VRGetInstance,
                                VRGetIndex,
                                VRGetSupOnCpt,
                                VRGetNeighbors;
from  ACncpx           import   ACget_NV_rep,
                                ACgive_structure;
from  VRCnrlSeg        import   VRget_terminators;
from  ACrg_collect     import   ACget_named_attribute;

/* ***************** init *********************************************        */

method init ( int type ; char * str_ptr )
{
  IGRint        status = OM_S_SUCCESS;
  IGRlong       sts,retmsg;
  IGRint        i, j;
  IGRshort      listsize, *code_num;
  IGRchar      *speclist, *codelist;
  IGRdouble    *npdlist;
  IGRchar       Cnpdlist[VR_MAX_NPDLIST_SIZE][10];

  me->ret = OM_S_SUCCESS;
  status  = OM_S_SUCCESS;

  /*| call VDB_LOCATE.init with respect to message */
  sts =
  om$send ( mode = OM_e_wrt_message,
        msg      = message VDB_LOCATE.init( type, str_ptr ),
        targetid = my_id);
  as$status( sts = sts, action = RET_STATUS );
  if (me->VDB_terminated) return (sts);

  /*| call VRinit_products to load the macro object spaces */
  status = VRinit_products();
  as$status( action = RET_STATUS );

  /*"Type of activated command : %d\n", type */

  me->bPktInquired = FALSE;
  /*"bPktInquired is <%d>\n", me->bPktInquired */

  if( !me->ReplaceCommand )
  {
    switch( type )
    {
      case VR_VALVE_INSERTION : 
      case VR_REDUCER_INSERTION :
      case VR_MISC_INSERTION :
      case VR_FLANGE_INSERTION :
      case VR_CONNECTOR_INSERTION :
      case VR_INSTRUMENT_INSERTION :
      case VR_SPECIALTY_INSERTION :
      case VR_PIPEENDS_INSERTION :
        me->Product = VR_PIPING;
        break;

      case VR_HVACTRANSITION_INSERTION :
      case VR_HVACREDUCER_INSERTION :
      case VR_HVACMISC_INSERTION :
      case VR_HVACDEV_INSERTION :
      case VR_HVACOFFSET_INSERTION :
      case VR_HVACSPLIT_INSERTION :
      case VR_HVACENDS_INSERTION :
      case VR_HVACTERMDEV_INSERTION :
        me->Product = VR_HVAC;
        break;

      case VR_RWAYREDUCER_INSERTION :
      case VR_RWAYMISC_INSERTION :
      case VR_RWAYOFFSET_INSERTION :
      case VR_RWAYSPLIT_INSERTION :
        me->Product = VR_RWAY;
        break;

      default:
        return OM_E_ABORT;
    }
  }
  
#ifdef MY_DEBUG
  printf ("mytype is <%d>, form_requested is <%d>\n",
                 me->mytype,me->form_requested);
  printf ("form_os is <%d>, cmd_key is <%s>, active_form_name is <%s>\n",
    me->form_os,
    me->cmd_key,
    me->active_form_name);
#endif

  me->FormPtr = NULL;
  me->FormUser = NULL;

  if( me->status_display_form_ptr && !me->ReplaceCommand )
  {
    me->FormPtr = me->status_display_form_ptr;
    if (me->forms [1].form_ptr)
    {
      /*| me->forms [1].form_ptr is defined */
      me->FormUser = me->forms [1].form_ptr;
    }
  }
  else
  {
    if (me->forms[0].form_ptr)
    {
      /*| me->forms [0].form_ptr is defined */
      me->FormPtr = me->forms[0].form_ptr;
      if (me->forms [1].form_ptr)
      {
        /*| me->forms [1].form_ptr is defined */
        me->FormUser = me->forms [1].form_ptr;
      }
    }
  }

  me->ActiveMessageField    = 0;
  me->ReplaceCommand        = FALSE;
  me->SavMissParamId.objid  = NULL_OBJID;
  me->CmpId.objid           = NULL_OBJID;
  me->OldCmpTagId           = -1;

 if( me->Product != VR_PIPING )  
 {
   if( me->Product != VR_HVAC )
     return OM_S_SUCCESS;
    
   status = VRget_spec_list (&retmsg, VR_HVAC, &listsize , &speclist , NULL); 
   if( status & OM_S_SUCCESS )
   {
      FIfld_set_list_num_rows( me->FormPtr, HVMC, 0, listsize );
      for(i=0,j=0;j<listsize;j++)
      {
        if (speclist [i])
        {
          VDfld_set_list_text( me->FormPtr, HVMC, j, 0, &speclist[i], FALSE);
          i += VR_MAX_SPEC_NAME_LEN;
        }
      }  
    }

    return OM_S_SUCCESS;
  }
  /*| -- Get Spec Name List and initialize form -- */
  status = VRget_spec_list (&retmsg, VR_PIPING, &listsize , &speclist , NULL); 
  if( status & OM_S_SUCCESS )
  {
      /* Below call to qsort placed by Anand for CR 179902073 */
      /* VRget_spec_list returns a CONTIGUOUS array of listsize number of
       * strings, each of length VR_MAX_SPEC_NAME_LEN. That is why the below
       * call to qsort would work. */
     qsort( speclist, listsize, VR_MAX_SPEC_NAME_LEN, strcmp );
      /* Above call to qsort placed by Anand for CR 179902073 */
     FIfld_set_list_num_rows( me->FormPtr, PPMC, 0, listsize );
     for(i=0,j=0;j<listsize;j++)
     {
       if (speclist [i])
       {
         VDfld_set_list_text( me->FormPtr, PPMC, j, 0, &speclist[i], FALSE);
         i += VR_MAX_SPEC_NAME_LEN;
       }
     }
  }

  status = 
  VRget_npd_list (&retmsg, VR_PIPING, "NOZZLE",  &listsize , &npdlist, NULL);

  if ( status & OM_S_SUCCESS )
  {
    for( i = 0; i<listsize; i++)    sprintf(Cnpdlist[i], "%g", npdlist[i]);

    FIfld_set_list_num_rows( me->FormPtr, PDIA_NOM, 0,listsize );
    FIfld_set_list_num_rows( me->FormPtr, PDIA_RED, 0,listsize );
    for(i=0; i<listsize; i++)
    {          
      VDfld_set_list_text( me->FormPtr, PDIA_NOM, i, 0, Cnpdlist[i], FALSE);
      VDfld_set_list_text( me->FormPtr, PDIA_RED, i, 0, Cnpdlist[i], FALSE);
    }
  }
  /*| -- Get Tracing Type List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, VR_PIPING, VR_P_TRACE_TYPE_LSTNUM, 
                                 &listsize , &codelist, &code_num, NULL);
/******** law Modified Mar 31 1998 ************/
  if ( status & 1 )
  {
      /* Below call to qsort placed by Anand for CR 179902073 */
      /* VRget_code_list_set returns a CONTIGUOUS array of listsize number of
       * strings, each of length VR_MAX_SPEC_NAME_LEN. That is why the below
       * call to qsort would work. */
      qsort( codelist, listsize, VR_SHORT_CODETEXT_SIZE, strcmp );
      /* Above call to qsort placed by Anand for CR 179902073 */
        FIfld_set_list_num_rows( me->FormPtr, PHEAT_TRAC, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
                        VDfld_set_list_text( me->FormPtr, PHEAT_TRAC,  j, 0,
                                             &codelist[i], FALSE);
                        j++ ;
                }
        }
  }

/***************************************/
  /*| -- Get Constarined Status List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, VR_PIPING, VR_P_CONST_STS_LSTNUM, 
                                 &listsize , &codelist, &code_num, NULL);
/******** law Modified Mar 31 1998 ************/
  if ( status & 1 )
  {
      /* Below call to qsort placed by Anand for CR 179902073 */
      /* VRget_code_list_set returns a CONTIGUOUS array of listsize number of
       * strings, each of length VR_MAX_SPEC_NAME_LEN. That is why the below
       * call to qsort would work. */
      qsort( codelist, listsize, VR_SHORT_CODETEXT_SIZE, strcmp );
      /* Above call to qsort placed by Anand for CR 179902073 */

        FIfld_set_list_num_rows( me->FormPtr, PCONST_STS, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
                        VDfld_set_list_text( me->FormPtr, PCONST_STS,  j, 0,
                                             &codelist[i], FALSE);
                        j++ ;
                }
        }
  }
/***************************************/

  return OM_S_SUCCESS;
} /* end init method */

/* ***************** wakeup *******************************************  */

method wakeup ( int position )
{
  IGRlong    status, msg;

  me->ret  = OM_S_SUCCESS;

  status  =
  om$send ( mode = OM_e_wrt_message,
          msg    = message VDB_LOCATE.wakeup ( position ),
        targetid = my_id);
  as$status ();

  if (me->VDB_terminated) return OM_S_SUCCESS;

  if (me->bPktInquired == TRUE)
  { 
    /*"bPktInquired  %d\n", me->bPktInquired */
    /*"ActivePocketMenuName  %s\n", me->szActivePocketMenuName */
    status =
    om$send (msg = message VRCOProduct.VRChangeActivePocketMenu (&me->ret),
        targetid = my_id);
    as$status ();
  }

  status  =
  om$send ( msg = message VRCOProduct.VRDisplayMessage ( &msg ),
       targetid = my_id);
  as$status ();

  if( me->CmpId.objid != NULL_OBJID )
  {
    status =
    om$send( msg = message VRCOProduct.VRComputeOrientationTee( &msg ),
        targetid = my_id);
    as$status ();
  }

  return OM_S_SUCCESS;

} /* end wakeup method */

/* ***************** sleep ********************************************  */

method sleep ( int position )
{
  IGRlong    status, msg;

  me->ret  = OM_S_SUCCESS;

  if (!(me->VDB_terminated))
  {
    if (me->bPktInquired == TRUE)    vd$pkt_menu( );

    status = dp$erase_hilite ( msg   = &msg,
                               osnum = me->ModuleEnv.md_id.osnum);
  }

  status =
  om$send (mode = OM_e_wrt_message,
       msg      = message VDB_LOCATE.sleep ( position ),
       targetid = my_id);
  as$status ();

  return OM_S_SUCCESS;
} /* end sleep method */

/* ==================== VRGetLocatedObject ============================  */

method  VRGetLocatedObject ( IGRlong  *ret )
{
  IGRlong       status, msg;
  IGRint        i, NbCpts, NbNeigh;
  IGRdouble     dCpCoors [VR_MAX_CPTS * 3];
  IGRdouble     dAcceptPoint[3];
  IGRshort      nNeiCpNum [VR_MAX_CPTS];
  IGRshort      nStatus;
  IGRdouble     dTmpLength, dLength, dTmpVector [3];
  BSrc          rc;

  struct GRid        NeiId [VR_MAX_CPTS];
  struct  ACrg_coll  Collection;

  *ret = MSSUCC;

  /* start processing message */
  VRProcessingMessage();

  me->CompId    = me->event1.located_object[0].located_obj;
  me->ModuleEnv = me->event1.located_object[0].module_info;


  status = dp$erase_hilite ( msg   = &msg,
                             osnum = me->ModuleEnv.md_id.osnum);

#ifdef MY_DEBUG
  printf ("LocatedObject (id/os) = (%d/%d)\n",
                   me->CompId.objid, me->CompId.osnum);
  printf ("Located MdEnv (id/os) = (%d/%d)\n",
                   me->ModuleEnv.md_id.objid, me->ModuleEnv.md_id.osnum); 
#endif

  /* Check whether we can insert at that point */
  if (me->ModuleEnv.md_id.osnum != me->ModuleInfo.md_id.osnum)
  {
      *ret = VRNOT_OK;
      ex$message( field   = ERROR_FIELD,
                  msgnumb = VR_E_InsNotAllowedAtThatPoint);

      return OM_S_SUCCESS;
  }

  strcpy (me->szActivePocketMenuName, NOTDEFPKTMNU);

  /*"TYPE = %d \n",me->mytype*/
  switch (me->Product)
  {
    case VR_PIPING:
      me->nInitialCompTopo = VRP_V_INLINE_TOPO;

      switch (me->mytype)
      {
        case VR_PIPEENDS_INSERTION:
          me->nInitialCompTopo = VRP_V_CLOSURE_TOPO;
          strcpy (me->szActivePocketMenuName,PPIPEENDSPKTMNU);
          break;

        case VR_REDUCER_INSERTION: 
          strcpy (me->szActivePocketMenuName,PREDUCERPKTMNU);
          break;

        case VR_VALVE_INSERTION:
          strcpy (me->szActivePocketMenuName,PVALVEPKTMNU);
          break;

        case VR_MISC_INSERTION:
          strcpy (me->szActivePocketMenuName,PMISCPKTMNU);
          break;

        case VR_FLANGE_INSERTION:
          strcpy (me->szActivePocketMenuName,PFLANGEPKTMNU);
          break;

        case VR_CONNECTOR_INSERTION:
          strcpy (me->szActivePocketMenuName,PCONNECPKTMNU);
          break;

        case VR_INSTRUMENT_INSERTION:
          strcpy (me->szActivePocketMenuName,PINSTRUPKTMNU);
          break;

        case VR_SPECIALTY_INSERTION:
          strcpy (me->szActivePocketMenuName,PSPECIALPKTMNU);
          break;
      }
      break;

    case VR_HVAC:
      me->nInitialCompTopo = VRH_V_INLINE_TOPO;
  
      switch (me->mytype)
      {  
        case VR_HVACENDS_INSERTION:
          me->nInitialCompTopo = VRH_V_CLOSURE_TOPO;
          strcpy (me->szActivePocketMenuName, HDUCTENDSPKTMNU);
          break;

        case VR_HVACDEV_INSERTION:
          strcpy (me->szActivePocketMenuName, HDEVICEPKTMNU);
          break;

        case VR_HVACTERMDEV_INSERTION:
          me->nInitialCompTopo = VRH_V_CLOSURE_TOPO;
          strcpy (me->szActivePocketMenuName, HTDEVICEPKTMNU);
          break;

        case VR_HVACOFFSET_INSERTION:
          me->nInitialCompTopo = VRH_V_OFFSET_TOPO;
          strcpy (me->szActivePocketMenuName, HOFFSETPKTMNU);
          break;

        case VR_HVACSPLIT_INSERTION:
          me->nInitialCompTopo = VRH_V_SPLIT_TOPO;
          strcpy (me->szActivePocketMenuName, HTEEPKTMNU);
          break;

        case VR_HVACTRANSITION_INSERTION:
          strcpy (me->szActivePocketMenuName, HTRANSITPKTMNU);
          break;

        case VR_HVACREDUCER_INSERTION:
          strcpy (me->szActivePocketMenuName, HREDUCERPKTMNU);
          break;

        case VR_HVACMISC_INSERTION:
          strcpy (me->szActivePocketMenuName, HMISCPKTMNU);
          break;
      }
      break;

    case VR_RWAY:
      me->nInitialCompTopo = VRR_V_INLINE_TOPO;
      switch (me->mytype)
      {  
        case VR_RWAYOFFSET_INSERTION:
          me->nInitialCompTopo = VRR_V_OFFSET_TOPO;
          strcpy (me->szActivePocketMenuName, HOFFSETPKTMNU);
          break;
        case VR_RWAYSPLIT_INSERTION:
          me->nInitialCompTopo = VRR_V_SPLIT_TOPO;
          strcpy (me->szActivePocketMenuName, HTEEPKTMNU);
          break;
        case VR_RWAYMISC_INSERTION:
          strcpy (me->szActivePocketMenuName, HMISCPKTMNU);
          break;
        case VR_RWAYREDUCER_INSERTION:
          strcpy (me->szActivePocketMenuName, HREDUCERPKTMNU);
          break;
      }
      break;
  }

  /*"PocketMenuName got <%s>\n", me->szActivePocketMenuName */

  dAcceptPoint[0] = me->event1.located_object[0].proj_pnt[0];
  dAcceptPoint[1] = me->event1.located_object[0].proj_pnt[1];
  dAcceptPoint[2] = me->event1.located_object[0].proj_pnt[2];

#ifdef MY_DEBUG
  printf ("dAccept (%lf,%lf,%lf)\n",
              dAcceptPoint[0],dAcceptPoint[1],dAcceptPoint[2]);
  printf ("proj_pnt 0 (%lf,%lf,%lf)\n",
               me->event1.located_object [0].proj_pnt [0],
               me->event1.located_object [0].proj_pnt [1],
               me->event1.located_object [0].proj_pnt [2]);
#endif

  /*| retrieve Component type */
  status = 
  om$send( msg = message VRGeneric.VRGetSysType( &msg, &me->nSysType),
     targetid  = me->CompId.objid,
     targetos  = me->CompId.osnum,
     senderid  = my_id );
  as$status( msg = "Error in VRGetSysType" );
  as$status( sts = msg, msg = "Error in VRGetSysType" );
  /*"Component type = %d\n",me->nSysType */

  /*| retrieve Component status */
  status = 
  om$send( msg = message VRGeneric.VRGetStatus( &msg, &nStatus),
     targetid  = me->CompId.objid,
     targetos  = me->CompId.osnum,
     senderid  = my_id );
  as$status();

  /*| GetSymb */
  status =
  om$send( msg  = message GRvg.GRgetsymb (&msg, &me->Symb),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum );
  as$status( );

  switch (me->nSysType)
  {
    case VR_PIPE:
        if ( me->mytype == VR_PIPEENDS_INSERTION    ||
             me->mytype == VR_HVACENDS_INSERTION    ||
             me->mytype == VR_HVACTERMDEV_INSERTION ||
             me->mytype == VR_ECCRED_INSERTION      ||
             me->mytype == VR_HVACOFFSET_INSERTION  ||
             me->mytype == VR_HVACSPLIT_INSERTION   ||
             me->mytype == VR_RWAYOFFSET_INSERTION  ||
             me->mytype == VR_RWAYSPLIT_INSERTION ) 
        {
          *ret = VRNOT_OK;
          ex$message( field   = ERROR_FIELD,
                      msgnumb = VR_E_NotDangleComp);
          return OM_S_SUCCESS;
        }

        /*| -- Compute Projection Point for a Pipe Component -- */
        status = (IGRlong ) VRSkLocatePipe (&msg, &me->event1, dAcceptPoint,
                                            &me->CompId, &me->ModuleEnv,
                                             me->dSplitPoint);
        as$status ();

        if ( msg != MSSUCC )
        {
          ex$message( field   = ERROR_FIELD,
                      msgnumb = VR_E_PointOutOfSegmentRange);
          *ret = VRNOT_OK;
          return OM_S_SUCCESS;
        }

        /*^
        printf ("dSplitPoint = %f %f %f)\n", me->dSplitPoint[0], 
               me->dSplitPoint[1], 
               me->dSplitPoint[2]);
        */

        /*| -- Locate pipe segment -- */
        status =  VRSkGetPipeVirtualSupportInfo ( &me->CompId,
                me->dSplitPoint,
                &me->ModuleEnv,
                &me->SegId,
                NULL,
                (IGRdouble *) NULL);
        as$status ();
        /*"SegId of pipe = %d %d\n",me->SegId.objid,me->SegId.osnum */

        break;

  default:

    status = 
    om$send( msg  = message VRGeneric.VRGetParams(  &msg,  &me->SysParamId,
                                                    &me->UsrParamId, NULL),
        targetid  = me->CompId.objid,
        targetos  = me->CompId.osnum );
    as$status( action = RET_STATUS );

    if (me->mytype == VR_PIPEENDS_INSERTION ||
        me->mytype == VR_HVACENDS_INSERTION ||
        me->mytype == VR_HVACTERMDEV_INSERTION) 
    {
      if (me->nSysType != VR_DANGLING)
      {
        *ret = VRNOT_OK;
        ex$message( field   = ERROR_FIELD,
          msgnumb = VR_E_NotDangleComp);
        return OM_S_SUCCESS;
      }
    }

    /*| Retrieve Component EndPoint close to Accept Point */
    status =
    om$send( msg = message VRGeneric.VRGetTopo ( &msg, VR_MAX_CPTS, &NbCpts,
                                        NULL, dCpCoors, NULL, NULL,
                                        &me->ModuleEnv),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
     as$status();
     if( !status&1)
     {
        *ret = VRNOT_OK;
        return OM_S_SUCCESS;
     }

#ifdef MY_DEBUG
     printf ("Number of connect points : %d\n",NbCpts);

     for (i=0;i<NbCpts;i++)
     {
       printf("i=%d \n",i);
       printf("dCpCoors=%f %f %f\n",
               dCpCoors[i*3],dCpCoors[i*3+1],dCpCoors[i*3+2]);
     }
#endif

     if (NbCpts == 0)
     {
        *ret = VRNOT_OK;
        printf ("**** WARNING number of connect points null *************\n");
        return OM_S_SUCCESS;
     }
     else
     {
        /*| Retrieve nearest connect point of component */
        dTmpLength = 0;
        BSmkvec (&rc, dTmpVector, dAcceptPoint, &dCpCoors[0]);
        dLength = BSlenvec (&rc,dTmpVector);
        me->RetainIndex = 0;
        for (i=1;i<NbCpts;i++)
        {
           /*| Check whether datapoint is close to any other endpoint */

           BSmkvec (&rc, dTmpVector, dAcceptPoint, &dCpCoors [i*3]);
           if (dLength > (dTmpLength = BSlenvec (&rc,dTmpVector)))
           {
             me->RetainIndex = i;
             dLength = dTmpLength;
           } 
        } 

#ifdef MY_DEBUG
        printf ("CptNum retained = %d\n", me->RetainIndex);
#endif

        for (i=0;i<3;i++)
          me->dSplitPoint[i] = dCpCoors[me->RetainIndex*3+i];

        if (nStatus & VR_CORRECTION)
        {
          /*| Locate pipe segment of the correction */
          status = VRSkGetCorVirtualSupport( &me->CompId, me->dSplitPoint,
                                             &me->ModuleEnv, &me->SegId);
          as$status ();
          /*"SegId of correction (os,id) = (%d,%d)\n",
                         me->SegId.objid,me->SegId.osnum */
          if( !(status & OM_S_SUCCESS))
          {
            *ret = VRNOT_OK;
            return OM_S_SUCCESS;
          }
        }
        else
        {
          status =
          om$send( msg = message VRGeneric.VRGetSupOnCpt( &msg,
                                                          me->RetainIndex,
                                                          &me->SegId,
                                                          &me->ModuleEnv),
              targetid = me->CompId.objid,
              targetos = me->CompId.osnum);
           as$status ();

           if( !(status& OM_S_SUCCESS))
           {
             *ret = VRNOT_OK;
             return OM_S_SUCCESS;
           }

          if (me->nSysType == VR_DANGLING)
          {
      /* We need to store the dangling index on segment in case of delete */
      /*| Retrieve Index of DANGLING on segment           */
            status = 
            om$send( msg = message VRGeneric.VRGetIndex( &msg,
                                                         &me->SegId,
                                                         &me->nDanglingIndex),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum);
            as$status();
            if( !(status& OM_S_SUCCESS))
            {
              *ret = VRNOT_OK;
              return OM_S_SUCCESS;
            }

            me->RetainIndex = -1;

          } 
          else
          {
            me->nDanglingIndex = -1;

#ifdef BLOCK_COMP_TREE
            /*  Components inserted on end-of-line components give
                difficulties (TR 179600376, 179601019, 179600603)    */
            if (me->SegId.objid == NULL_OBJID)
            {
              *ret = VRNOT_OK;
              ex$message( field   = ERROR_FIELD,
                          msgnumb = VR_E_InsNotAllowedAtThatPoint);
              return OM_S_SUCCESS;
            }
#endif
          }
        }

#ifdef MY_DEBUG
         printf ("SegId = %d CptNum =%d\n", me->SegId.objid,me->RetainIndex);
#endif
      } 

    break;
  } /* end switch */


  VRUpdateEvent(  &msg , me->dSplitPoint, &me->event1 );

  /*| -- Get Navsea representation -- */
  status = 
  om$send( msg = message ACncpx.ACget_NV_rep( &me->cRep ),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum );
  as$status();

  if (me->nSysType != VR_DANGLING)
  {
#ifdef MY_DEBUG
    printf ("insert on NOT DANGLE\n");
#endif

  if( !bVR_IS_PID( me->cRep) )
  {
        /*| -- Retrieve connect pt attr of located component -- */
        status = 
    om$send( msg     = message VRGeneric.VRGetCptProp
              ( &msg,
                  me->RetainIndex,
                  &me->ConProp,
                  &me->ModuleEnv),
                 targetid = me->CompId.objid,
                 targetos = me->CompId.osnum);
        as$status ();
    if( !status&1)
      {
      *ret = VRNOT_OK;
      return OM_S_SUCCESS;
      }
  }

      /*| -- retrieve attribut of the located component -- */
      status = om$send( msg  = message VRGeneric.VRGetParams( &msg, 
                     &me->SavSysParamId,
                     &me->SavUserParamId,
                 NULL ),
          targetid  = me->CompId.objid,
          targetos  = me->CompId.osnum,
          senderid  = my_id );
      as$status( msg = "Error in VRGetParams" );

      /* First build 2 param box copies to be sure to keep existant one */
      VRGetParamBoxClone( &msg, &me->SavSysParamId, &me->SysParamId);
      VRGetParamBoxClone( &msg, &me->SavUserParamId, &me->UsrParamId);

        /*  TR179600376    Make sure nu weird sizes are copied from
                           adjoining component (reducer??)           */

        status = VREqualSizeForce (me->Product, &me->SysParamId,
                                                &me->ModuleEnv);

#ifdef MY_DEBUG
  printf ("after getparamboxclone\n");
#endif

}
else
{
    status = om$send( msg      = message VRGeneric.VRGetNeighbors ( &msg, 0, 0, &NbNeigh,
                        NeiId, nNeiCpNum,
                        &me->ModuleEnv),
          targetid  = me->CompId.objid,
          targetos  = me->CompId.osnum,
          senderid  = my_id );
    as$status( msg = "Error in VRGetParams" );

    if (NbNeigh)
    {
    /*| -- retrieve attribut of the neighbor component -- */
    /*"NeiId is %d\n", NeiId [0].objid */
    status = om$send( msg      = message VRGeneric.VRGetParams( 
                &msg, 
                &me->SavSysParamId,
                &me->SavUserParamId,
                NULL),
          targetid  = NeiId [0].objid,
          targetos  = NeiId [0].osnum,
          senderid  = my_id );
    as$status();

    /* Build 2 copies not to alter existing one */
    VRGetParamBoxClone( &msg, &me->SavSysParamId, &me->SysParamId);
    VRGetParamBoxClone( &msg, &me->SavUserParamId, &me->UsrParamId);

  if( !bVR_IS_PID( me->cRep) )
  {
    /*| retrieve attribut of the neighbor located component */
    status = om$send( msg       = message VRGeneric.VRGetCptProp( &msg, *nNeiCpNum,
                              &me->ConProp,
                              &me->ModuleEnv),
                 targetid  = NeiId [0].objid,
                targetos  = NeiId [0].osnum,
                senderid  = my_id );
    as$status ();
    as$status ( sts = msg );


    switch (me->Product)
        {
        case VR_PIPING:
          strcpy ( Collection.name , VR_N_GDIAMETER_DB ); 
          Collection.desc.type          = AC_ATTRIB_DOUBLE;
          Collection.desc.value.att_exp = me->ConProp.width;
          status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
          as$status ();

          strcpy ( Collection.name , VR_N_RDIAMETER_DB ); 
          Collection.desc.type          = AC_ATTRIB_DOUBLE;
          Collection.desc.value.att_exp = me->ConProp.width;
          status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
          as$status ();

          /*"G_diam, R_diam=%lf,%lf\n", me->ConProp.width, me->ConProp.depth */
          break;

        case VR_HVAC:
        case VR_RWAY:
          strcpy ( Collection.name , VR_N_WIDTH1_DB ); 
          Collection.desc.type          = AC_ATTRIB_DOUBLE;
          Collection.desc.value.att_exp = me->ConProp.width;
          status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
          as$status ();

          strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
          Collection.desc.type          = AC_ATTRIB_DOUBLE;
          Collection.desc.value.att_exp = me->ConProp.depth;
          status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
          as$status ();

          strcpy ( Collection.name , VR_N_WIDTH2_DB ); 
          Collection.desc.type          = AC_ATTRIB_DOUBLE;
          Collection.desc.value.att_exp = me->ConProp.width;
          status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
          as$status ();

          strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
          Collection.desc.type          = AC_ATTRIB_DOUBLE;
          Collection.desc.value.att_exp = me->ConProp.depth;
          status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
          as$status ();
    } /* end switch */
    /*| Now located Dangling looks like neighbor connect point */
  }/* end treat cpt props if not PID */
    }
    else
    {
    /*| Cannot retrieve Neighbor attributes */
    /*| But dont return */
    }
    VRCircularTreatment (me->Product, &me->SysParamId, &me->ModuleEnv);
  }

#ifdef MY_DEBUG
  printf (" leave VRGetLocatedObject\n");
#endif

return  OM_S_SUCCESS;

} /* end method VRGetLocatedObject */

/* ***************** status_disp () ***************************** */

method status_disp ()
{
  IGRlong status;

  /*^  printf ("form_requested before display is %d\n", me->form_requested); */
  /*| Sending status_disp with respect to message */
  status =
  om$send( msg   = message super_cmd.status_disp (), 
        mode     = OM_e_wrt_message,
        targetid = my_id );
  as$status( msg = "Error in status_disp" );

  /*| display form */
  status = FIf_display (me->FormPtr);

  return  OM_S_SUCCESS;

} /* end method status_disp */

/* ==================================================================== */

method VRDefaultPocketMenu  (IGRlong *ret)
{
  *ret = MSSUCC;

  if (me->bPktInquired)
  {
    vd$pkt_menu( );

    me->bPktInquired = FALSE;
      /*"bPktInquired is <%d>\n", me->bPktInquired */
  }
  else
  {
    /*| No change */
  }

  return OM_S_SUCCESS;

} /* end method VRDefaultPocketMenu */

/* ==================================================================== */

method VRCopyReturnCode (IGRlong *ret)
{

  *ret = me->lRet;

  me->lRet = VRALL_OK;

  return OM_S_SUCCESS;

} /* end method VRCopyReturnCode */

/* ***************** VRRestoreForm () *********************************  */

method VRRestoreForm ( IGRlong *msg  )
{
  IGRlong  status;  

  *msg  = MSSUCC;

  if (!me->FormPtr) return OM_S_SUCCESS;

  /*| Reload saved form values */
  status = 
  om$send( msg = message VRCOProduct.VRFillForm( msg, &me->CompId,
                                                 &me->SysParamId, 
                                                 &me->ModuleEnv ),
      targetid = my_id);
  as$status( );

  return  OM_S_SUCCESS;

} /* end method VRRestoreForm */

/* ==================== VRForceDiamValues =============================  */

method  VRForceDiamValues ( IGRlong *ret )
{
IGRlong      status, msg;
IGRdouble    dWidth, dDepth;
IGRdouble    dGDiam, dRDiam;
struct  ACrg_coll  Collection;

*ret = MSSUCC;


if ( me->Product == VR_PIPING )
{
  /*| Setting new Green and Red diameters */
  dGDiam = dRDiam = me->ConProp.width;

  /*| Updating collection VR_N_GDIAMETER_DB */
  strcpy ( Collection.name , VR_N_GDIAMETER_DB ); 
  Collection.desc.type          = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp =  dGDiam;
  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();

  /*| Updating collection VR_N_RDIAMETER_DB */
  strcpy ( Collection.name , VR_N_RDIAMETER_DB ); 
  Collection.desc.type          = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp =  dRDiam;
  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();
}
else
{
  /*| Setting new Width and Depth diameters */
  dWidth = me->ConProp.width;
  dDepth = me->ConProp.depth;

  /*| Updating collection VR_N_WIDTH1_DB */
  strcpy ( Collection.name , VR_N_WIDTH1_DB ); 
  Collection.desc.type         = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp = dWidth;
  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();

  /*| Updating collection VR_N_DEPTH1_DB */
  strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
  Collection.desc.type         = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp = dDepth;
  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();

  if (VRCircularTreatment (me->Product, &me->SysParamId, &me->ModuleEnv))
  {
      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = RDEPTH_G,
              pAttrName   = VR_N_DEPTH1_DB);

      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = RDEPTH_R,
              pAttrName   = VR_N_DEPTH2_DB);
  } 
}

switch ( me->Product )
{
  case VR_PIPING:
      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = PDIA_NOM,
              pAttrName   = VR_N_GDIAMETER_DB);

      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = PDIA_RED,
              pAttrName   = VR_N_RDIAMETER_DB);
  break;

  case VR_HVAC:
      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = HWIDTH_G,
              pAttrName   = VR_N_WIDTH1_DB);

      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = HDEPTH_G,
              pAttrName   = VR_N_DEPTH1_DB);
  break;

  case VR_RWAY:
      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = RWIDTH_G,
              pAttrName   = VR_N_WIDTH1_DB);

      VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
              Gadget  = RDEPTH_G,
              pAttrName   = VR_N_DEPTH1_DB);
  break;
}

return  OM_S_SUCCESS;

} /* end method VRForceDiamValues */

/* ==================== VRGetOtherValues ============================  */

method  VRGetOtherValues ( IGRlong *ret )
{
IGRlong      status, msg;
IGRint       FootIndex = -1, retstatus;
IGRdouble    dWidth=0.0, dDepth=0.0;
IGRdouble    dGDiam, dRDiam;
IGRdouble    dOtherDiameterValue;
struct ret_struct  ParamAttr;
struct  ACrg_coll  Collection;
IGRchar      szKeyIn [255], *pWidth=NULL, *pDepth=NULL;

*ret = MSSUCC;

/*"keyin is <%s>\n", me->event1.event.keyin */

if ( me->Product == VR_PIPING )
{
  if ((dOtherDiameterValue = atof (me->event1.event.keyin)) <= 0.0)
      {
        *ret = MSFAIL;
        dOtherDiameterValue = 0.0;
        return OM_S_SUCCESS;
      }
  /*"Other Diameter value is <%lf>\n", dOtherDiameterValue */

  status = 
  om$send( msg      = message ACncpx.ACgive_structure( &retstatus, 
           &FootIndex, VR_N_GDIAMETER_DB, &ParamAttr, 
           &me->ModuleEnv),
     targetid = me->SysParamId.objid,
     targetos = me->SysParamId.osnum );
  as$status( action = RET_STATUS );
  dGDiam = ParamAttr.var.root_pm_st.value;

  status = 
  om$send( msg      = message ACncpx.ACgive_structure
                  ( &retstatus, &FootIndex, VR_N_RDIAMETER_DB,
                      &ParamAttr, &me->ModuleEnv),
        targetid = me->SysParamId.objid,
        targetos = me->SysParamId.osnum );
  as$status( action = RET_STATUS );
  dRDiam = ParamAttr.var.root_pm_st.value;
  /*"G and R diameter got are %lf,%lf\n", dGDiam, dRDiam */

  /* We are sure that both green and red diameters are equal on entry */
  /*| Setting new Green and Red diameters */
  if (dOtherDiameterValue == dGDiam)
      {
        /*| Diameter keyed in should different from old values */
        *ret = MSFAIL;
        dOtherDiameterValue = 0.0;
        return OM_S_SUCCESS;
      }
  else if (dOtherDiameterValue > dGDiam)
  {
    /*| Setting GDiameter value */
    dGDiam = dOtherDiameterValue;
    /*"dGDiam = %lf\n", dGDiam */
  }
      else
  {
    /*| Setting RDiameter value */
    dRDiam = dOtherDiameterValue;
    /*"dRDiam = %lf\n", dRDiam */
  }

  /*| Updating collection VR_N_GDIAMETER_DB */
  strcpy ( Collection.name , VR_N_GDIAMETER_DB ); 
  Collection.desc.type = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp =  dGDiam;
  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();

  /*| Updating collection VR_N_RDIAMETER_DB */
  strcpy ( Collection.name , VR_N_RDIAMETER_DB ); 
  Collection.desc.type = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp =  dRDiam;
  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();

  /*| Updating the form */
  VR$DispCollAttr ( pForm   = me->FormPtr,
          pCollId  = &me->SysParamId,
           Gadget  = PDIA_NOM,
          pAttrName   = VR_N_GDIAMETER_DB);


  VR$DispCollAttr ( pForm   = me->FormPtr,
          pCollId  = &me->SysParamId,
           Gadget  = PDIA_RED,
          pAttrName   = VR_N_RDIAMETER_DB);
}
else
{
  strcpy (szKeyIn, me->event1.event.keyin); 
  VRTrimRightLeftSpace (szKeyIn);
  /*"KeyIn after Trim %s\n", szKeyIn */

  pWidth = strtok (szKeyIn, " ,");
  pDepth = strtok (NULL, " ,");

  /*"pWidth %s, pDepth %s\n", pWidth, pDepth */

  if( !pWidth || !pDepth ||
    (dWidth = atof (pWidth)) <= 0.0 ||
      (dDepth = atof (pDepth)) <= 0.0)
      {
        *ret = MSFAIL;
        return OM_S_SUCCESS;
      }
  /*"Other values are <%lf,%lf>\n", dWidth, dDepth */

  /*| Updating collection VR_N_WIDTH2_DB */
  strcpy ( Collection.name , VR_N_WIDTH2_DB ); 
  Collection.desc.type     = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp   =  dWidth;

  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();

  /*| Updating collection VR_N_DEPTH2_DB */
  strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
  Collection.desc.type     = AC_ATTRIB_DOUBLE;
  Collection.desc.value.att_exp   =  dDepth;

  status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
  as$status ();

  /*| Sending Other Values in Form fields */
  /*"dWidth %lf, dDepth %lf\n", dWidth, dDepth */

  

  /*| Updating the form */
  if ( me->Product == VR_RWAY )
  {
    VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
               Gadget  = RWIDTH_R,
              pAttrName   = VR_N_WIDTH2_DB);


    VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
               Gadget  = RDEPTH_R,
              pAttrName   = VR_N_DEPTH2_DB);
  }
  else
  {  
    VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
               Gadget  = HWIDTH_R,
              pAttrName   = VR_N_WIDTH2_DB);


    VR$DispCollAttr ( pForm   = me->FormPtr,
              pCollId  = &me->SysParamId,
               Gadget  = HDEPTH_R,
              pAttrName   = VR_N_DEPTH2_DB);
  }
}

return  OM_S_SUCCESS;

} /* end method VRGetOtherValues */

/* ===================================================================  */

method  VRLoadForm ( IGRlong  *ret )
{
  IGRlong    status;
  IGRlong    msg;

  SetProc( Md VRLoadForm ); Begin 

  *ret = MSSUCC;
  me->lRet = VRALL_OK;

  VRCircularTreatment (me->Product, &me->SysParamId, &me->ModuleEnv);

  /*"SysParamId = %d\n", me->SysParamId.objid*/

  /*| -- Initialization of form -- */
  status = 
  om$send ( msg   = message VRCOProduct.VRFillForm( &msg , &me->CompId,
                &me->SysParamId,
                &me->ModuleEnv),
      targetid = my_id );
  as$status(); 


  if( me->CmpAABBCCcode[0] )
      FIg_set_text( me->FormPtr, HCODE, me->CmpAABBCCcode );

  FIf_display( me->FormPtr ); /* Previously when the command is invoked the
                                used to display. Now it will display only after
                                user locates the valid component. Alwin */

End
return  OM_S_SUCCESS;
} /* end method VRLoadForm */

/* ====================================================================  */

method VRDeleteComponent (IGRlong *ret)
{
  IGRlong  msg, status;
  struct GRid  CompIds[2];
  IGRint  NbCmp;
  
  *ret = MSSUCC;

  if( me->ReplaceCommand && me->CompId.objid != NULL_OBJID )
  {

#ifdef  MANAGE_IDS
     if ( bVR_IS_PID_ACTIVE && me->Product != VR_RWAY ) 
     {
  struct ret_struct  ParamAttr;
  struct ACrg_coll  Attr;
  IGRint       FootIndex = -1, retstatus;
  IGRchar      SysName[20];
  IGRint      OldCmpId, NewCmpId=-1, Original=0;
  
  /*A Report the comp num modifications to the database */
  /*A get the system name */
  FootIndex = -1;
  status = 
  om$send( msg      = message 
    ACncpx.ACgive_structure( &retstatus, 
           &FootIndex, 
                  VR_N_SYST_NAME_AN,
                  &ParamAttr, 
           &me->ModuleEnv),
    targetid = me->SysParamId.objid,
    targetos = me->SysParamId.osnum );
  as$status();  
  strcpy(SysName, ParamAttr.var.text_st.text_string);

  OldCmpId = me->OldCmpTagId;

  /*A get the new comp id */
  FootIndex = -1;
  status = 
  om$send( msg      = message ACncpx.ACgive_structure( &retstatus, 
           &FootIndex, 
                  VR_N_TAG_NUMBER_AN,
                  &ParamAttr, 
           &me->ModuleEnv),
    targetid = me->CmpId.objid,
    targetos = me->CmpId.osnum );
  as$status();  

  NewCmpId = (int) atoi(ParamAttr.var.text_st.text_string);
  
  /*H( hard coded ) */
  /*A check whether original or referenced */
  strcpy(Attr.name, "original" );
  status = 
  om$send( msg      = message ACrg_collect.ACget_named_attribute(
      &msg, &Attr ),
    targetid = me->UsrParamId.objid,
    targetos = me->UsrParamId.osnum );
  as$status();
  Original = (int) Attr.desc.value.att_exp;

  if ( Original && (OldCmpId != NewCmpId) )
  {
    /*A report thr change to DB */
    retstatus =
    VDModifyID( SysName, me->CmpCat, OldCmpId, NewCmpId );

    /*A free the old Id */
/* KLUDGE:
    retstatus =
    VDUnLockID ( SysName, me->CmpCat, OldCmpId );
*/
  }

  /*A set the tag num to -1 */
  /*A don't want the comp to report to DB about the deletion */
  status =
  VRResetTagNum( &me->CompId );
  as$status( action = RET_STATUS );
      }
#endif

  /*| --- the component as changed comparing to the beginning --- */
    status = 
  om$send ( msg      = message GRgraphics.GRdelete( &msg, &me->ModuleEnv),
      senderid = my_id,
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);
    as$status ();

  nd$exec_batch ();

  return OM_S_SUCCESS;
  }

  me->CmpAABBCCcode[0]  = '\0';  

  if ( me->CmpId.objid == NULL_OBJID )  return OM_S_SUCCESS;

  /*| Undisplay Component */
  status = 
  om$send ( msg      = message NDnode.NDdisplay ( 0, GRbe, &me->ModuleEnv),
      senderid = my_id,
      targetid = me->CmpId.objid,
      targetos = me->CmpId.osnum);
  as$status ();

  if( me->SysParamId.objid != NULL_OBJID )
  {
    status = 
    om$send ( msg      = message NDnode.NDchg_state( (ND_DEL_NO_CH ), 
               (~ND_DEL_NO_CH) ),
          senderid = my_id,
          targetid = me->SysParamId.objid,
          targetos = me->SysParamId.osnum);
    as$status ();
  }

  if( me->UsrParamId.objid != NULL_OBJID )
  {
    status = 
    om$send ( msg      = message NDnode.NDchg_state( (ND_DEL_NO_CH), 
               (~ND_DEL_NO_CH)),
          senderid = my_id,
          targetid = me->UsrParamId.objid,
          targetos = me->UsrParamId.osnum);
    as$status ();
  }

  /*A set the tag num to -1 */
  /*A don't want the comp to report to DB about the deletion */
  status = VRResetTagNum( &me->CmpId );
  as$status( action = RET_STATUS );

  /*| Delete Component */
  status = om$send ( msg      = message GRgraphics.GRdelete ( &msg, &me->ModuleEnv),
         senderid = my_id,
         targetid = me->CmpId.objid,
         targetos = me->CmpId.osnum);
  as$status ();

  me->CmpId.objid  = NULL_OBJID;
 
  nd$exec_batch ();

  if( me->SysParamId.objid != NULL_OBJID )
  {
  /*"SysParamId = %d \n",me->SysParamId.objid*/
    status =
    om$send ( msg      = message NDnode.NDchg_state( (ND_DEL_NO_CH), 
               (ND_DEL_NO_CH)),
          senderid = my_id,
          targetid = me->SysParamId.objid,
          targetos = me->SysParamId.osnum);
    as$status ();
  }

  if( me->UsrParamId.objid != NULL_OBJID )
  {
    status = 
    om$send ( msg      = message NDnode.NDchg_state( (ND_DEL_NO_CH), 
               (ND_DEL_NO_CH)),
          senderid = my_id,
          targetid = me->UsrParamId.objid,
          targetos = me->UsrParamId.osnum);
    as$status ();
  }


  if (me->nSysType == VR_DANGLING)
  {
  /*| We need to recover the new component id because dangling deleted */
      status = 
  om$send ( msg     = message VRCnrlSeg.VRget_terminators( &msg,
                 &NbCmp,
                 &me->ModuleEnv,
                 NULL,
                 CompIds),
      targetid = me->SegId.objid,
      targetos = me->SegId.osnum);

      me->CompId = CompIds [me->nDanglingIndex];
      /*^
      printf ("New Dangling created and located is (id,os)=(%d,%d)\n",me->CompId.objid,me->CompId.osnum);
      */
      me->CmpId = me->CompId;
  }
  else
  {
      if ( me->CmpStatus & VR_CORRECTION)
  {
    /*^ printf ("Correction located so don't known what to do ?\n");*/
    *ret = VRNOT_OK;
    return OM_S_SUCCESS;
  }
  }

return OM_S_SUCCESS;

} /* end method VRDeleteComponent */

/* ====================================================================  */
from ACrg_collect  	import GRcopy;
from ACdb_info  	import ACgive_db_structure;
#define VRCOPY_GRAPHIC_ATTRS 1000
#define COPY_GRAPHIC_ATTRS 171

method VRCopyComponentAttr ( IGRlong  *ret )
{
  IGRlong      retmsg;
  IGRint      status;
  struct  GRid    *LocatedComp;
  struct  VRGenInfo  Instance;
  IGRint		gad_state=0;

  SetProc( Md VRCopyComponentAttr ); Begin 

  /*| Get Component Attributes */
  *ret  = MSSUCC;

  dp$erase_hilite (  msg   = &retmsg,
      osnum = me->ModuleEnv.md_id.osnum);

  LocatedComp  = &me->event1.located_object[0].located_obj;

#ifdef MY_DEBUG
  printf ("LocatedComp (id/os) = (%d/%d)\n",
             LocatedComp->objid,LocatedComp->osnum);
#endif

  /* added for CR179900999. Alwin */
  {
	FIg_get_state( me->FormPtr, COPY_GRAPHIC_ATTRS, &gad_state );
	__DBGpr_int( " Gadget state ", gad_state );

	if( gad_state == 1 )
	{
	  /* Check whether the Selected component is of same macro as that of the
	  original component. Only if they're same we're supposed to copy the
	  attributes from "located component" to Original component. This
	  is as per Claudette/Rod Banach. Alwin */

	  IGRint			direct_index=-1;
	  IGRchar			szMacroName[80];
	  struct ret_struct	strMacro;

	  szMacroName[0] = '\0';
	  /* Get the located components macro_name */
	  status = 
	  om$send( msg = message ACdb_info.ACgive_db_structure( (IGRint*)&retmsg,
							&direct_index, VR_N_MACRO_NAME_AN, 
							&strMacro, &me->ModuleEnv ),
			   targetid = LocatedComp->objid,
			   targetos = LocatedComp->osnum );
	  as$status();

	  strcpy( szMacroName, strMacro.var.text_st.text_string );
	  __DBGpr_str( " Located Component's Macro Name ", szMacroName );

	  strMacro.var.text_st.text_string[0] = '\0';

	  /* Get the Original components macro_name */
	  om$send( msg = message ACdb_info.ACgive_db_structure( (IGRint*)&retmsg,
							&direct_index, VR_N_MACRO_NAME_AN, 
							&strMacro, &me->ModuleEnv ),
			   targetid = me->CompId.objid,
			   targetos = me->CompId.osnum );
	  as$status();

	  __DBGpr_str( " Original Component's Macro Name ", 
							strMacro.var.text_st.text_string );

	  __DBGpr_com( " Yeah !! Copy Button is Active :-) " );
	  FIg_set_state_off (me->FormPtr, COPY_GRAPHIC_ATTRS);
	  FIg_enable( me->FormPtr, COPY_GRAPHIC_ATTRS );

	  if( strcmp( szMacroName, strMacro.var.text_st.text_string ) )
	  {
		 /* Macro Name's are different so don't copy and let the user
		 know about that */
		 UI_status( "Macro Names are different - Can't Copy " );
		 UI_status( "" );
		 FIg_set_text( me->FormPtr, MESSAGE, 
						"Macro Names are different - Can't Copy" );
		 End
		 return status;
	  }

	  status = 
	  om$send( msg      = message VRGeneric.VRGetParams
		( &retmsg, NULL, NULL, &me->MissParamId ),
		 targetid = LocatedComp->objid,
		 targetos = LocatedComp->osnum,
		 senderid = my_id );
	  as$status();

	  UI_status( "Attribute Values are copied \n" );
	  UI_status( "" );
	  FIg_set_text( me->FormPtr, MESSAGE, "Graphic Attribute Values - Copied" );
	  End
	  return status;
	}
  }

  /*A Get of collections of the identified component */
  status = 
  om$send( msg      = message VRGeneric.VRGetParams
    ( &retmsg, &me->SysParamId, &me->UsrParamId, NULL ),
     targetid = LocatedComp->objid,
     targetos = LocatedComp->osnum,
     senderid = my_id );
  as$status();

  /*A Copy the collections if not in the current OS */
  if ( LocatedComp->osnum != me->ModuleEnv.md_id.osnum )
  {
  /*C Copy the System collection */
  status =
  om$send (msg = message ACrg_collect.GRcopy
      (&retmsg, &me->event1.located_object[0].module_info,
      &me->ModuleEnv, &me->SysParamId.objid),
    targetid = me->SysParamId.objid,
    targetos = me->SysParamId.osnum );
  as$status(action = RET_STATUS);

  me->SysParamId.osnum = me->ModuleEnv.md_id.osnum;

  /*C Copy the User collection */
  status =
  om$send (msg = message ACrg_collect.GRcopy
      (&retmsg, &me->event1.located_object[0].module_info,
      &me->ModuleEnv, &me->UsrParamId.objid),
    targetid = me->UsrParamId.objid,
    targetos = me->UsrParamId.osnum );
  as$status(action = RET_STATUS);

  me->UsrParamId.osnum = me->ModuleEnv.md_id.osnum;

  }/* end copy collections */
#ifdef MY_DEBUG
  printf ("copied\n");
#endif

  VRCircularTreatment (me->Product, &me->SysParamId, &me->ModuleEnv);

  status = 
  om$send( msg      = message VRGeneric.VRGetInstance( &retmsg, &Instance ),
     senderid = my_id,
     targetid = LocatedComp->objid,
     targetos = LocatedComp->osnum );
  as$status();
  
  strcpy( me->CmpAABBCCcode, Instance.szAABBCC );

  /*A copy the tag number if transfer is from PID to 3D*/
  if ( me->Product != VR_RWAY )
  {
  if ( !bVR_IS_PID( me->cRep ) &&
    bVR_IS_PID( (int)Instance.cRep ) )
      strcpy( me->CmpNumber, Instance.szNumber );
  } else   strcpy( me->CmpNumber, Instance.szNumber );

  strcpy( me->CmpNotes, Instance.szNotes );
  me->CmpOption   = Instance.nOption;
  me->CmpNoMtoFlag   = Instance.cNoMtoFlg;

#ifdef MY_DEBUG
printf ("me->CmpAABBCCcode = %s\n",me->CmpAABBCCcode);
printf ("me->CmpNumber = %s\n",me->CmpNumber);
printf ("me->CmpNotes = %s\n",me->CmpNotes);
printf ("me->CmpOption = %d\n",me->CmpOption);
printf ("me->CmpNoMtoFlag = %c\n",me->CmpNoMtoFlag);
#endif

  /*A update the comp category and bahaviour */
  if ( me->Product != VR_RWAY && bVR_IS_PID_ACTIVE )
  {
  status =
  VRdbGetCompCat( &retmsg, (short)VR_PIPING, 
    me->CmpAABBCCcode, &me->CmpCat, &me->CmpBehavior,NULL );
  as$status();
  }  

  /*| initialisalization of displayed form */
  status =
  om$send( msg     = message VRCOProduct.VRFillForm(  &retmsg, LocatedComp,
              &me->SysParamId,
              &me->ModuleEnv ),
     targetid = my_id);
  as$status ();

End
return  OM_S_SUCCESS;

} /* end method VRCopyComponentAttr */

/*****************************************************************************/

method  VRGetOptionCode ( IGRlong *ret; IGRboolean bDispDef )
{
  IGRlong      status, msg;

  *ret = MSSUCC;

  /* -- display the text corresponding to the option code -- */
  /* extended o_lname for TR-MP4140-probably not necessary here */
  if ( bDispDef )
  {
    IGRint  i_code;
    IGRchar  o_lname[81], p_error[30];

    i_code = 1;        /* -- hard coded ( temp ) -- */

    /*** TR-MP4140 initialize for no-match ***/
    o_lname[0] = '\0';

    status = vd$get_alias (  p_msg  = &msg,
                 product  = PIPING,
                 type  = VR_OPTCODE_LIST_NUM,
                   i_code  = i_code,
                 o_lname  = o_lname,
                 p_error  = p_error  );

    if ( !strlen(o_lname) ) 
      sprintf(o_lname, "%d", i_code );      
    FIg_set_text( me->FormPtr, POPTION, o_lname );
  }

  if( me->Product == VR_PIPING )
  {
  status = VRGetOptionCode( &msg, me->CmpAABBCCcode, &me->SysParamId, 
          POPTION, me->FormPtr, &me->ModuleInfo );
  if (!(status & 0x01) || !(msg & 0x01) )  me->ret = VRNOT_OK;
  }

  return  OM_S_SUCCESS;
}

/*****************************************************************************/

method delete ( int f_defer_flag )
{
  IGRlong   msg,status;

  if (!(me->VDB_terminated))
  {
  FIf_erase ( me->FormPtr );

  if(  me->ReplaceCommand && me->CmpId.objid != NULL_OBJID && 
  me->CompId.objid != NULL_OBJID)
  {
  status = 
  om$send ( msg      = message GRgraphics.GRdelete ( &msg, 
                 &me->ModuleEnv),
      senderid = my_id,
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);
    as$status ();
  }  
  else  if(1&(om$is_objid_valid(objid = me->CmpId.objid,
                osnum = me->CmpId.osnum)))
  {
  status = 
  om$send ( msg      = message NDnode.NDdisplay ( 0, GRbe, &me->ModuleEnv),
      senderid = my_id,
      targetid = me->CmpId.objid,
      targetos = me->CmpId.osnum);
  as$status ();

  /*| Delete Component */
    status = om$send ( msg      = message GRgraphics.GRdelete ( &msg, 
                    &me->ModuleEnv),
         senderid = my_id,
         targetid = me->CmpId.objid,
         targetos = me->CmpId.osnum);
    as$status ();
  }
  }

  status = om$send ( mode     = OM_e_wrt_message,
         msg      = message VDB_LOCATE.delete( f_defer_flag),
         targetid = my_id);
  as$status();

  return OM_S_SUCCESS;
}


/*****************************************************************************/

method VRCheckTopoCoherency( IGRlong *sts )
{
  IGRchar    *feet_name;
  IGRshort    nStatus;
  IGRint    OldCompTopo, CompTopo, ConnectedPt[VR_MAX_CPTS], NbCpt, OldNbCpt, NbCptConnectd;
  IGRint     i, Index=-1, Index1;
  IGRlong     retcode, status;
  IGRdouble    cosinus, sinus, angle, angle1, CptAxis[3*VR_MAX_CPTS], CptPt[6],
      Axis1[3], Axis2[3], Vect[3];
  struct ret_struct     AttrSt;
  struct GRid    SegId;
  BSrc                  bsretcode;
  IGRchar               szCP[30];

  *sts = MSFAIL;

  if( bVR_IS_PID( me->cRep) )
  {  
  *sts = MSSUCC;
  return OM_S_SUCCESS;
  }

  /* -- See if it's a correction component when not P&ID -- */
  status = 
  om$send( msg      = message VRGeneric.VRGetStatus( &retcode, &nStatus ),
           targetid = me->CompId.objid,
           targetos = me->CompId.osnum );
  as$status ( action = RET_STATUS );

  if( nStatus & VR_CORRECTION ) return OM_S_SUCCESS;

  /* -- Get number of component connection point -- */
  status = 
  om$send( msg      = message VRGeneric.VRGetNumberOfCpts(&retcode,&OldNbCpt,&me->ModuleEnv),
           targetid = me->CompId.objid,
           targetos = me->CompId.osnum ); 
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  
  /*" OldNbCpt = %d \n", OldNbCpt*/
  
  for( i=0; i<OldNbCpt; i++ )
  {
    status = 
  om$send( msg      = message VRGeneric.VRGetCptGeom
          (&retcode, i, NULL, &CptAxis[3*i], NULL, &me->ModuleEnv),
                 targetid = me->CompId.objid,
                 targetos = me->CompId.osnum ); 
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

  /*"CptAxis[%d] = %f %f %f\n", i, CptAxis[3*i], CptAxis[3*i+1], CptAxis[3*i+2] */
  }

  /* -- See how many connect points are already connected -- */
  for( i=0, NbCptConnectd=0; i<OldNbCpt; i++ )
  {
    /*"point : %d \n",i*/

  ConnectedPt[i] = 0;

    status = 
  om$send( msg      = message VRGeneric.VRGetSupOnCpt
                                           ( &retcode, i, &SegId, &me->ModuleEnv ),
                 targetid = me->CompId.objid,
                 targetos = me->CompId.osnum ) ;
    as$status( action = RET_STATUS ) ;

       if( SegId.objid != NULL_OBJID )
  {
    NbCptConnectd++;
    ConnectedPt[i] = 1;
  }
  }

  /*"NbCptConnectd = %d \n", NbCptConnectd */

  /* -- Get number of component connection point -- */
  status = 
  om$send( msg      = message VRGeneric.VRGetNumberOfCpts(&retcode,&NbCpt,&me->ModuleEnv),
           targetid = me->CmpId.objid,
           targetos = me->CmpId.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  
  /*"NbCpt = %d \n", NbCpt */

  if( NbCpt < NbCptConnectd ) return OM_S_SUCCESS;

  switch( NbCptConnectd )
  {
  case 0:
  case 1:  *sts = MSSUCC;
    break;

  case 2:  VRCheckCompTopo( &CompTopo, &me->CmpId, &me->ModuleEnv );
    VRCheckCompTopo( &OldCompTopo, &me->CompId, &me->ModuleEnv );

    if( me->CmpType & VR_CONSTR_COMPONENT_TYPE )
    {
      if( CompTopo != OldCompTopo ) break;
      else
      {
        *sts = MSSUCC;
        break;
      }
     }
    else
    {
      if( ! ( CompTopo == VR_INLINE_TOPO || CompTopo == VR_3_WAYS_TOPO
                 || CompTopo == VR_2_WAYS_TOPO ) ) break;
    }
    VRCptEncode (0, szCP,":axis");
                
    status = om$send( msg      = message ACncpx.ACgive_structure
                                    ( (IGRint *) &retcode, &Index,
                                        szCP, &AttrSt, &me->ModuleEnv ),
                      targetid = me->CmpId.objid,
                      targetos = me->CmpId.osnum );
                as$status ( action = RET_STATUS );

                Axis1[0] = AttrSt.var.point_st.pt[0];
                Axis1[1] = AttrSt.var.point_st.pt[1];
                Axis1[2] = AttrSt.var.point_st.pt[2];

    /*"Axis1 = %f %f %f\n", Axis1[0], Axis1[1], Axis1[2] */

    for( i=0, Index1=0; i<OldNbCpt; i++ )
    {
      if( ConnectedPt[i] )
      {
        CptPt[3*Index1]   = CptAxis[3*i];
        CptPt[3*Index1+1] = CptAxis[3*i+1];
        CptPt[3*Index1+2] = CptAxis[3*i+2];
        Index1 = 1;
      }
    }
    
    /*"CptPt[0-2] = %f %f %f\n", CptPt[0], CptPt[1], CptPt[2] */
    /*"CptPt[3-5] = %f %f %f\n", CptPt[3], CptPt[4], CptPt[5] */

    cosinus = BSdotp( &bsretcode, &CptPt[0], &CptPt[3] );
    /*"cosinus = %f\n", cosinus */

    BScrossp( &bsretcode, &CptPt[0], &CptPt[3], Vect );
    sinus = BSlenvec( &bsretcode, Vect );
    /*"sinus = %f\n", sinus */

    if( fabs( sinus ) < VRGetTol(VR_ANGULAR_TOL) )
    {
      /*| Linear connection */
            if( CompTopo == VR_INLINE_TOPO || CompTopo == VR_3_WAYS_TOPO ) *sts = MSSUCC;
      break;
    }
    else
    {
      /*| No linear connection */

      angle = atan2(sinus,cosinus);
      /*"angle = %f\n", angle */

            if( CompTopo == VR_2_WAYS_TOPO )
              VRCptEncode (1, feet_name ,":axis");
      else if( CompTopo == VR_3_WAYS_TOPO )
              VRCptEncode (2, feet_name ,":axis");

      else break;

            status = om$send( msg      = message ACncpx.ACgive_structure
                                           ( (IGRint *) &retcode, &Index,
                                                   feet_name, &AttrSt, &me->ModuleEnv ),
                        targetid = me->CmpId.objid,
                        targetos = me->CmpId.osnum );
                  as$status ( action = RET_STATUS );

                  Axis2[0] = AttrSt.var.point_st.pt[0];
                  Axis2[1] = AttrSt.var.point_st.pt[1];
                  Axis2[2] = AttrSt.var.point_st.pt[2];

      /*"Axis2 = %f %f %f\n", Axis2[0], Axis2[1], Axis2[2] */

      cosinus = BSdotp( &bsretcode, Axis1, Axis2 );
      BScrossp( &bsretcode, Axis1, Axis2, Vect );
      sinus  = BSlenvec( &bsretcode, Vect );

      angle1 = atan2(sinus,cosinus);
      /*"angle1 = %f\n", angle1 */

      if( fabs( angle1 - angle ) < VRGetTol(VR_ANGULAR_TOL) ) *sts = MSSUCC;

      break;
    }  
      
  case 3:  VRCheckCompTopo( &CompTopo, &me->CmpId, &me->ModuleEnv );
    VRCheckCompTopo( &OldCompTopo, &me->CompId, &me->ModuleEnv );

    if( me->CmpType & VR_CONSTR_COMPONENT_TYPE && CompTopo != OldCompTopo ) break;

    if( CompTopo != VR_3_WAYS_TOPO ) break;

    CptPt[0] = CptAxis[0];
    CptPt[1] = CptAxis[1];
    CptPt[2] = CptAxis[2];
    CptPt[3] = CptAxis[6];
    CptPt[4] = CptAxis[7];
    CptPt[5] = CptAxis[8];

    /*"CptPt[0-2] = %f %f %f\n", CptPt[0], CptPt[1], CptPt[2] */
    /*"CptPt[3-5] = %f %f %f\n", CptPt[3], CptPt[4], CptPt[5] */
        
    cosinus = BSdotp( &bsretcode, &CptPt[0], &CptPt[3] );
    BScrossp( &bsretcode, &CptPt[0], &CptPt[3], Vect );
    sinus = BSlenvec( &bsretcode, Vect );

    angle = atan2(sinus,cosinus);
    /*"angle = %f\n", angle */

    VRCptEncode (0, szCP,":axis");

          status = om$send( msg      = message ACncpx.ACgive_structure
                                    ( (IGRint *) &retcode, &Index,
                                        szCP, &AttrSt, &me->ModuleEnv ),
                      targetid = me->CmpId.objid,
                      targetos = me->CmpId.osnum );
                as$status ( action = RET_STATUS );

                Axis1[0] = AttrSt.var.point_st.pt[0];
                Axis1[1] = AttrSt.var.point_st.pt[1];
                Axis1[2] = AttrSt.var.point_st.pt[2];
    /*"Axis1 = %f %f %f\n", Axis1[0], Axis1[1], Axis1[2] */

    VRCptEncode (2, szCP,":axis");

          status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( (IGRint *) &retcode, &Index,szCP,
                                          &AttrSt, &me->ModuleEnv ),
                      targetid = me->CmpId.objid,
                      targetos = me->CmpId.osnum );
                as$status ( action = RET_STATUS );

                Axis2[0] = AttrSt.var.point_st.pt[0];
                Axis2[1] = AttrSt.var.point_st.pt[1];
                Axis2[2] = AttrSt.var.point_st.pt[2];
    /*"Axis2 = %f %f %f\n", Axis2[0], Axis2[1], Axis2[2] */

    cosinus = BSdotp( &bsretcode, Axis1, Axis2 );
    BScrossp( &bsretcode, Axis1, Axis2, Vect );
    sinus  = BSlenvec( &bsretcode, Vect );

    angle1 = atan2(sinus,cosinus);
    /*"angle1 = %f\n", angle1 */
    
    if( fabs( angle1 - angle ) < VRGetTol(VR_ANGULAR_TOL) ) *sts = MSSUCC;

    break;

  default:
    as$status( sts = OM_W_ABORT, msg = "Missing case" );
    return OM_W_ABORT;
  }

  /*"sts = %d\n", *sts */

  return OM_S_SUCCESS;      
}

method VRIsDisplayed( IGRchar  *form_ptr )
{
  IGRint  VStatus;

  FIf_is_displayed ( form_ptr, &VStatus);

  if (VStatus) me->ret = DISPLAYED;

  return OM_S_SUCCESS;
} /* end method VRis_displayed */

method VRSetIdManData  (IGRlong *sts )
{
#ifdef  MANAGE_IDS  
  IGRlong      retmsg, status=OM_S_SUCCESS;
  struct ret_struct  ParamAttr;
  IGRint       FootIndex = -1, retstatus;
  IGRint      IdList[VDS_LIST_OF_IDS], i;
#endif  MANAGE_IDS  

  *sts = MSSUCC;

#ifdef  MANAGE_IDS  
  /*A get the cmp id info from data base */
  if ( bVR_IS_PID_ACTIVE )
  {
    /*C Get system name */
    status = 
    om$send( msg      = message ACncpx.ACgive_structure
           ( &retstatus, 
             &FootIndex, 
                    VR_N_SYST_NAME_AN,
                    &ParamAttr, 
             &me->ModuleEnv ),
      targetid = me->SysParamId.objid,
      targetos = me->SysParamId.osnum );
    as$status();

    /*C unlock the previous unused id */
    if ( !me->bTagNumUsed && me->PrevTagNum != -1 )
    {
      status =
      VDUnLockID ( ParamAttr.var.text_st.text_string,
        me->CmpCat, me->PrevTagNum );
      as$status();

    }/* end of unlock */

    status =
    VRdbGetCompCat( &retmsg, (short)VR_PIPING, 
      me->CmpAABBCCcode, &me->CmpCat, &me->CmpBehavior,NULL );
    as$status();
/*KLUDGE : *H */
    if ( me->CmpBehavior == 2 )
    {
      /*C get the list of available line Ids */
      retstatus = 
      VDGetListOfIDs( ParamAttr.var.text_st.text_string,
          me->CmpCat, IdList );
      if ( !(retstatus&1) ) {
        *sts = MSFAIL;
        return OM_E_ABORT;
      }

      /*C lock the first one and use this as default Id*/
      for ( i=0; i<VDS_LIST_OF_IDS; i++ ) {
        retstatus =
        VDLockSelectedID ( ParamAttr.var.text_st.text_string,
          me->CmpCat, IdList[i] );
        if ( retstatus&1 )
        {
        sprintf(me->CmpNumber, "%05d", IdList[i] );
        /*C display in the form */
        FIg_set_text( me->FormPtr, PCMP_NB,
            me->CmpNumber );

        me->PrevTagNum = IdList[i];
        me->bTagNumUsed = FALSE;
        break;
        }
      }
    }
  } /* end if PID */
#endif

  return  OM_S_SUCCESS;
} /* end VRSetIdManData */

/* ==================================================================== */

method VRUnLockId( IGRlong *ret )
{
#ifdef  MANAGE_IDS
  int        status = OM_S_SUCCESS;
  struct ret_struct  ParamAttr;
  IGRint       FootIndex = -1, retstatus;
#endif  MANAGE_IDS

  *ret = MSSUCC;

#ifdef  MANAGE_IDS
  if( bVR_IS_PID_ACTIVE ) 
  {
    /*C Get system name */
    status = 
    om$send( msg      = message ACncpx.ACgive_structure
           ( &retstatus, 
             &FootIndex, 
                    VR_N_SYST_NAME_AN,
                         &ParamAttr, 
             &me->ModuleEnv),
      targetid = me->SysParamId.objid,
      targetos = me->SysParamId.osnum );
    as$status();

    /*printf( " initial_form : system name = %s \n", 
      ParamAttr.var.text_st.text_string );  */

    /*C unlock the previous unused id */
    if ( me->PrevTagNum != -1 )
    {
      status =
      VDUnLockID ( ParamAttr.var.text_st.text_string,
        me->CmpCat, me->PrevTagNum );
      me->PrevTagNum = -1;
      me->bTagNumUsed = FALSE;
    }/* end of unlock */

      }/* end P&ID processing */
#endif

      return (OM_S_SUCCESS);

} /*end VRUnLockId */

method initial_form_notification ( int form_label ; int gadget_label ; 
        double value ; char * form_ptr )
{
#ifdef  MANAGE_IDS
  IGRlong      status=OM_S_SUCCESS;
  IGRint      i;
  struct ret_struct  ParamAttr;
  IGRint       FootIndex = -1, retstatus;
  IGRint      IdList[VDS_LIST_OF_IDS];
  IGRchar      LineIdStr[20];
  IGRint      Original=1, Approved=0;
#endif  MANAGE_IDS

/*PCMP_NB and HCMP_NB are same */

#ifdef  MANAGE_IDS
  if( form_ptr == me->FormPtr && bVR_IS_PID_ACTIVE &&
    me->Product != VR_RWAY && gadget_label == PCMP_NB )
  {
        struct  ACrg_coll  Attr;
        IGRlong      retmsg;

        /*H( hard coded ) */    
        strcpy(Attr.name, "original" );
        status = 
        om$send( msg      = message ACrg_collect.ACget_named_attribute
      ( &retmsg, &Attr ),
    targetid = me->UsrParamId.objid,
    targetos = me->UsrParamId.osnum );
        as$status();
    
        if ( retmsg&1 )
          Original = (int) Attr.desc.value.att_exp;
    
        /*A check the approval status */
        strcpy(Attr.name,  VR_N_APPRV_STAT_AN );
        status = 
        om$send( msg      = message 
      ACrg_collect.ACget_named_attribute(
        &retmsg, &Attr ),
      targetid = me->SysParamId.objid,
      targetos = me->SysParamId.osnum );
        as$status();

        /*H ( Hard coded ) */  
        if( !strcmp(Attr.desc.value.att_txt, "A") ||
    !strcmp(Attr.desc.value.att_txt, "Approved" ) )
      Approved = 1;
        
        if (  me->CmpBehavior == 2 &&
    ( !me->ReplaceCommand || (Original && !Approved) ) )
        {
    /*C Get system name */
    status = 
    om$send( msg      = message ACncpx.ACgive_structure
             ( &retstatus, 
               &FootIndex, 
                      VR_N_SYST_NAME_AN,
                           &ParamAttr, 
               &me->ModuleEnv),
    targetid = me->SysParamId.objid,
    targetos = me->SysParamId.osnum );

    /*printf( " system name = %s \n", 
      ParamAttr.var.text_st.text_string ); */

    /*C unlock the previous unused id */
    if ( !me->bTagNumUsed && me->PrevTagNum != -1 )
    {
      retstatus =
      VDUnLockID ( ParamAttr.var.text_st.text_string,
        me->CmpCat, me->PrevTagNum );
    }/* end of unlock */

    /*C get the list of available line Ids */
    retstatus = 
    VDGetListOfIDs( ParamAttr.var.text_st.text_string,
      me->CmpCat, IdList );
    if ( !(retstatus&1) )  return OM_E_ABORT;

    /*C set the associated list */
    for( i=0; i<VDS_LIST_OF_IDS; i++ )
    {
      sprintf( LineIdStr, "%05d", IdList[i] );
      VDfld_set_list_text( form_ptr, gadget_label, 
        i, 0, LineIdStr, FALSE);
    }
        } else {
    /*A reset the associated list */
    FIfld_set_list_num_rows( form_ptr, gadget_label, 
        0, 0 );
        }
  }
#endif

  return (OM_S_SUCCESS);
} /* end initial_form_notificatio */

method VRValidateIdChg ( IGRlong * sts )
{
#ifdef  MANAGE_IDS
  IGRint      status= OM_S_SUCCESS;
  struct  ACrg_coll  Attr;
  IGRint      Original=1;  /* original comp*/
  IGRlong      retmsg;
  IGRint      CmpIdNum,Approved=0;
  struct ret_struct  ParamAttr;
  IGRint       FootIndex = -1, retstatus;
#endif  MANAGE_IDS

#ifdef  MANAGE_IDS
      if ( bVR_IS_PID_ACTIVE )
      {
  /*R*/  /*H*/
  /*A check whether the cmp is ref or original */
  strcpy(Attr.name, "original" );
  status = 
  om$send( msg      = message ACrg_collect.ACget_named_attribute(
      &retmsg, &Attr ),
    targetid = me->UsrParamId.objid,
    targetos = me->UsrParamId.osnum );
  as$status();
  Original = (int) Attr.desc.value.att_exp;

  /*A set the comp category info */
  status = 
  om$send( msg      = message ACncpx.ACgive_structure( 
      &retstatus, &FootIndex,
      VR_N_AABBCC_AN, &ParamAttr, 
      &me->ModuleEnv),
    targetid = me->CompId.objid,
    targetos = me->CompId.osnum);
  as$status( action = RET_STATUS );

  status =
  VRdbGetCompCat( &retmsg, (short)VR_PIPING,
    ParamAttr.var.text_st.text_string, 
    &me->CmpCat, &me->CmpBehavior,NULL );
  as$status();
  
  /*A store the old tag number */
  me->OldCmpTagId = (int) atoi(me->CmpNumber);

  if ( !Original )
  {
    status = 
    om$send( msg      = message ACncpx.ACgive_structure( 
      &retstatus, &FootIndex,
      VR_N_SYST_NAME_AN, &ParamAttr, 
      &me->ModuleEnv),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);
    as$status( action = RET_STATUS );
    CmpIdNum = (int) atoi( me->CmpNumber );

    /*A get the new id of the original comp refered to */
    status =
    VDGetNewID( ParamAttr.var.text_st.text_string, me->CmpCat, 
      CmpIdNum, &CmpIdNum);
    if ( status&0 )  return OM_E_ABORT;

    if ( status != VDS_ID_NOT_MODIFIED ) {
             ex$message( field   = ERROR_FIELD,
          in_buff = "Original Comp Num Changed => UPDATING" );
      sprintf( me->CmpNumber, "%05d", CmpIdNum );
      FIg_set_text( me->FormPtr, PCMP_NB, me->CmpNumber );
    }

  } /*C end update the cmp number */

  /*A check the approval status */
  strcpy(Attr.name,  VR_N_APPRV_STAT_AN );
  status = 
  om$send( msg      = message 
      ACrg_collect.ACget_named_attribute(
        &retmsg, &Attr ),
    targetid = me->SysParamId.objid,
    targetos = me->SysParamId.osnum );
  as$status();

  /*H ( Hard coded ) */  
  if( !strcmp(Attr.desc.value.att_txt, "A") ||
    !strcmp(Attr.desc.value.att_txt, "Approved" ) )
    Approved = 1;

  /*R check again */
  /*A set the gadget behavior accordingly */
  if ( Approved || !Original )
    FIg_set_notify_off( me->FormPtr, PCMP_NB );
  else
    FIg_set_notify_on( me->FormPtr, PCMP_NB );
      }
#endif

      return OM_S_SUCCESS;
}

end implementation VRCOProduct;


