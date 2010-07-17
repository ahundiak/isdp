/* $Id: VRmod.I,v 1.4 2002/04/10 19:42:43 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrgeneric / VRmod.I
 *
 * Description:
     This file contains the methods modifying a generic
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRmod.I,v $
 *      Revision 1.4  2002/04/10 19:42:43  louis
 *      TR5649-standardize tolerances
 *
 *      Revision 1.3  2001/02/20 01:14:17  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/12 20:44:29  anand
 *      SP merge
 *
# Revision 1.1  2000/05/23  23:19:16  pinnacle
# Created: route/vrgeneric/VRmod.I by lawaddel for Service Pack
#
# Revision 1.2  1999/12/02  22:52:28  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/03/17  18:26:00  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by kddinov for route
#
# Revision 1.4  1998/03/08  23:02:38  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by kddinov for route
#
# Revision 1.3  1998/02/10  21:24:28  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by lawaddel for route
#
# Revision 1.2  1997/10/20  15:37:12  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by kddinov for route
#
# Revision 1.6  1997/10/01  22:10:08  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by kddinov for route
#
# Revision 1.5  1997/10/01  20:45:28  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by kddinov for route
#
# Revision 1.4  1997/06/24  21:53:28  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by kddinov for route
#
# Revision 1.3  1997/02/22  00:37:08  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by kddinov for route
#
# Revision 1.2  1997/02/18  20:12:40  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/06/05  19:40:48  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by hverstee for route240
#
# Revision 1.5  1996/05/06  14:07:18  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by ashankar for route240
#
# Revision 1.4  1996/04/25  22:17:52  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by ashankar for route240
#
# Revision 1.2  1996/03/13  22:22:22  pinnacle
# Replaced: vrgeneric/VRmod.I for:  by hverstee for route240
#
 *
 * History:
 *      03/11/96        hv      Cleanup
 *	3-98	KDD		VRGetParams --> VRGetPrivateParams.
 *				This solves attributes NON uniqueness problem.
 *        09/17/99        law        TR179900935-bad sums & reverse flows
 *        04/05/02        law   TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation VRGeneric;
/*
#define vdserrDEBUG 1
#define vdsDEBUG 1
*/

#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "VDmem.h"
#include "VRdef.h"
#include "VRcsdef.h"
#include "vrdbgmacros.h"
#include "VRcordef.h"
#include "vrparameters.h"
#include "VRcompdef.h"
#include "VRMath.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bslenvec.h"


/*
#define    MY_DEBUG
*/

from   VRCorrection  import  	VRSetFlow,
				VRPropagateFlow;
from   VRComponent  import   	VRSetOrientationDef;    
		/* DIRTY, you're not supposed to inherit from your children */

from   VRCnrlSeg  import  	VRSegMinLength;

from 	ACrg_collect	import	ACmod_list_attribute;

/***********************************************************************/

method VRSetCode ( IGRlong *msg;
                   IGRchar *szAABBCC )

{

  SetProc( VRGeneric_VRSetCode ); Begin
  *msg = MSSUCC;

  if ( strlen(szAABBCC)<= (6) )
  {
    strcpy ( me->szAABBCC, szAABBCC );
  }
  else
  {
    /*" ERROR -> INVALID AABBCC CODE LENGTH : %d\n",strlen(szAABBCC)*/
    End
    return ( OM_E_INVARG );
  }

  /*" Component new aabbcc code = %s\n",me->szAABBCC*/
  End
  return ( OM_S_SUCCESS );
}

method VRResetCode (IGRlong *msg)

{
  SetProc( VRGeneric_VRResetCode ); Begin
  *msg = MSSUCC;
  
  if ((me->Status & VR_SYSTEM) &&
      (!(me->Status & VR_FORCED) ))
						me->szAABBCC[0] = '\0';
  End
  return (OM_S_SUCCESS);
}

/***********************************************************************/

method VRSetStatus ( IGRlong *msg;
                     IGRshort StatusMask;
                     IGRshort StatusValue)

{
  SetProc( VRGeneric_VRSetStatus ); Begin
  *msg = MSSUCC;

  me->Status = (me->Status & ~StatusMask) | (StatusValue & StatusMask);

#ifdef MY_DEBUG
  printf ("New status");

  if (me->Status & VR_ERROR)      printf ("ERR ");
  if (me->Status & VR_DUMB_DEL)   printf ("DEL ");
  if (me->Status & VR_SYSTEM)     printf ("SYS ");
  if (me->Status & VR_FORCED)     printf ("FRC ");
  if (me->Status & VR_BUILT_IN)   printf ("BLT ");
  if (me->Status & VR_CORRECTION) printf ("COR ");
  if (me->Status & VR_CLONE)      printf ("CLO ");
  printf ("\n");
#endif
  End
  return ( OM_S_SUCCESS );
}

/***********************************************************************/

method VRChgParams( IGRlong   *msg;
             struct GRid      *SysParamId;
             struct GRid      *UserParamId;
             struct GRid      *MissParamId )
{
  IGRint    status;
  IGRint    NbTemplates=0;
  IGRint    NbRoots;
  IGRint    IndexOld=0;
  IGRint    i; 
  IGRint    nMaxTemp;
  IGRint    LocNbAttr;
  IGRboolean AddedMissing=FALSE;

  struct GRid     *NewTemplates;
  struct GRid     *buffer, PrimaryId, SecondaryId;

  SetProc( VRGeneric_VRChgParams ); Begin
  LocNbAttr = me->nNbAttr;

  /* get previous templates */
  status = 
  om$send( msg = message NDnode.NDget_objects
                                  (ND_ROOT | ND_IN_BUF, NULL, 0,
                                   &buffer, 0, OM_K_MAXINT, &NbRoots ),
      targetid = my_id);
  as$status( action = RET_STATUS );

  /*" %d templates = %d Attr + %d topo \n",NbRoots,LocNbAttr,me->nNbTopo */

  nMaxTemp = NbRoots + VR_NB_ATTR;

  NewTemplates = _MALLOC (nMaxTemp, struct GRid);
  if (NewTemplates == NULL)
  {
    End
    return OM_E_NODYNMEM;
  }

  if (NbRoots == 0)
  {
    /*| First connection , System and User must be specified */

    NewTemplates[0] = *SysParamId;
    NewTemplates[1] = *UserParamId;

    /*| Update number of attributes */

    if ( MissParamId && MissParamId->objid != NULL_OBJID )
    {
      /*| Missings exist */
      NewTemplates[2] = *MissParamId;
      LocNbAttr     = VR_NB_ATTR;
    }/* end maximum attributes collections */
    else
    {
      /*| No Missings */
      LocNbAttr = VR_NB_ATTR - 1;
    }/* end no missing parameters */

    NbTemplates = LocNbAttr;

  }/* end first connection */
  else
  {
    /*| Create new list of templates */

    /* -- SYSTEM -- */

    if ( SysParamId && SysParamId->objid != NULL_OBJID )
    {
      /*| New System */

      NewTemplates[NbTemplates] = *SysParamId;

    } /* end new system parameters */
    else  NewTemplates[NbTemplates] = buffer[IndexOld];

    IndexOld++;
    NbTemplates++;

    /* -- USER -- */

    if ( UserParamId && UserParamId->objid != NULL_OBJID )
    {
      /*| New User */

      NewTemplates[NbTemplates] = *UserParamId;

    } /* end new user parameters */
    else  NewTemplates[NbTemplates] = buffer[IndexOld];

    IndexOld++;
    NbTemplates++;

    /* -- MISSING -- */

    if ( MissParamId && MissParamId->objid != NULL_OBJID )
    {
      /*| Adding missings */

      NewTemplates[NbTemplates] = *MissParamId;
      NbTemplates++;

      if (LocNbAttr < VR_NB_ATTR )
      {
	AddedMissing = TRUE;
        LocNbAttr = VR_NB_ATTR;
      }/* end add missings */
      else   IndexOld++; /* skip missings that should exists */

    } /* end Missing parameters */
    else
	  NewTemplates[NbTemplates] = buffer[IndexOld];

    /* -- Fill up templates list with other templates */

    for ( i=IndexOld; i<NbRoots; i++ )
      NewTemplates[NbTemplates++] = buffer[i];

  } /* end of connections modifications */

  /*| Perform full reconnection */

  if( AddedMissing )
  {
	status =
	om$send ( msg = message VRComponent.VRGetOrientationDef( msg,
						&PrimaryId, NULL, NULL, 
						&SecondaryId, NULL, NULL ),
				targetid = my_id );
  }

  me->nNbAttr = LocNbAttr; /*  change here NOT BEFORE THE GetOrientationDef */

  status =
  om$send( msg = message NDnode.NDconnect ( NbTemplates, NewTemplates,
                                            NULL_GRID,ND_FULL),
      targetid = my_id);
  as$status(action = RET_STATUS);

  if( AddedMissing )
  {
	status =
	om$send ( msg = message VRComponent.VRSetOrientationDef( msg,
						PrimaryId, NULL,
						SecondaryId, NULL ),
				targetid= my_id );
  }

  /* ------------------------ */
  /* -- Notify corrections -- */
  /* ------------------------ */

  status =
  om$send (msg = message VRGeneric.VRNotifyCorrections ( msg, 0 ),
      targetid = my_id );
  as$status(action = RET_STATUS);

  _FREE (NewTemplates);

  End
  return OM_S_SUCCESS;

}/* end method VRChgParams */

/***********************************************************************/

method VRNotifyLengthModif (IGRlong    *msg ;
                            IGRshort    nCpNum;
                     struct GRmd_env   *md_env)
{
  IGRlong      		retmsg;
  IGRint       		status;
  struct GRid  		SegId;

  SetProc( VRGeneric_VRNotifyLengthModif ); Begin
  *msg       = MSSUCC;

  /* -- Get Support constraint associated to the connect point -- */

  status=
  om$send ( msg = message VRGeneric.VRGetSupOnCpt
                                         ( &retmsg , nCpNum, &SegId, md_env),
       targetid = my_id );
  as$status ( action = RET_STATUS );

  /* -- Forward the message to the support constraint -- */

  status= 
  om$send( msg = message VRCnrlSeg.VRSegMinLength
                                     ( msg, VR_INIT_LENGTH | VR_UPDATE_LENGTH,
                                       NULL, md_env ),
      targetid = SegId.objid,
      targetos = SegId.osnum );

  End
  return status;

}/* end VRNotifyLengthModif */
/***********************************************************************/
/*------------------------
# This method in fact sets the flow in the owner correction.
------------------------*/

method VRSetFlow ( IGRlong   *msg;
                   IGRshort   nCpNum;
                   IGRshort  *nFlowDir ;
                   IGRdouble *dFlowRate;
          struct   GRmd_env  *md_env )
{
  BSrc                  rc;
  IGRint       		status;
  IGRlong      		retmsg;
  IGRint       		NbCors;
  IGRdouble    		dCpAxis[3];
  IGRshort              Direction={1}, *p_FlowDir = NULL,
			ConnectPoint;

  IGRdouble             MyCptCoord[3], Cpt0[3], Cpt1[3], V0[3], V1[3], V2[3];

  struct GRid  		CorId, SysParamId;
  struct ACrg_coll   	Attr;
 
  struct VRCorrection_common   attr;

  IGRdouble    		BSlenvec();


SetProc (VRGeneric.VRSetFlow); Begin

  *msg=MSSUCC;

  if ( !nFlowDir && !dFlowRate ) goto wrapup; 

__DBGpr_int("VRSetFlow for  ", (int) my_id); 

  /* -- Get correction on connect point -- */
  /* This correction treatment is exactly the same as in VRinfo.I: VRGetFlow */

  if ( me->Status & VR_CORRECTION )
  {
    status =
    om$send ( msg = message VRGeneric.VRGetCorrections
                                             (&retmsg, 1, &CorId, &NbCors),
         targetid = my_id);
    as$status ( action = RET_STATUS );

  }
  else
  {
    /* -- Get correction on connect point -- */
    /* KLUDGE FOR OLETS : Got thru GetNeighbors to get correction on cpt 0 */
    IGRshort  nStatus;
    IGRint    TmpNbNei;
    struct GRid  TmpNeiId;

    status=
    om$send ( msg = message VRGeneric.VRGetNeighbors
                               ( &retmsg, nCpNum, nCpNum, &TmpNbNei,
                                               &TmpNeiId, NULL, md_env),
         targetid = my_id);
    as$status ( action = RET_STATUS );
    if ( TmpNeiId.objid == NULL_OBJID ) {*msg = MSFAIL;
      End
      return OM_S_SUCCESS;}


    status =
    om$send ( msg = message VRGeneric.VRGetStatus
                                          (&retmsg, &nStatus),
         targetid = TmpNeiId.objid,
         targetos = TmpNeiId.osnum );
    as$status ( action = RET_STATUS );

    if ( nStatus & VR_CORRECTION )
    {
      status =
      om$send ( msg = message VRGeneric.VRGetCorrections
                                            (&retmsg, 1, &CorId, &NbCors),
           targetid = TmpNeiId.objid,
           targetos = TmpNeiId.osnum );
      as$status ( action = RET_STATUS );
    }
    else
    {
      status =
      om$send ( msg = message VRGeneric.VRGetCorOnCpt
                                            (&retmsg, nCpNum, &CorId, md_env),
           targetid = my_id);
      as$status ( action = RET_STATUS );
    }
  }/* end not correction component treatment */


/*-------------------
#  Set direction symbol in correction.
-------------------*/
__DBGpr_obj("Using VRCorrection  ", CorId);
 
  if ( nFlowDir ) { 
  /* Find the new direction. Change if needed */

    	status= om$send (msg = message VRGeneric.VRGetCptGeom
                                (&retmsg, nCpNum, MyCptCoord, NULL,NULL,md_env),
                    targetid = my_id);
 
    	status= om$send (msg = message VRGeneric.VRGetCptGeom
                                (&retmsg, (IGRshort) 0, Cpt0, NULL,NULL,md_env),
                    targetid = CorId.objid,
                    targetos = CorId.osnum );
 
    	status= om$send (msg = message VRGeneric.VRGetCptGeom
                                (&retmsg, (IGRshort) 1, Cpt1, NULL,NULL,md_env),
                    targetid = CorId.objid,
                    targetos = CorId.osnum );
 

    /* reverse flow direction if needed */
 
        BSmkvec ( &rc, V0, MyCptCoord, Cpt0);
        Direction = 1; /* default to remain the same tr179900935 */
 
        if (BSlenvec (&rc, V0) < VRGetTol(VR_LENGTH_TOL) )     { Direction = 1; }
        else {
            BSmkvec ( &rc, V2, MyCptCoord, Cpt1); 
            if (BSlenvec (&rc, V2) < VRGetTol(VR_LENGTH_TOL) )
             {
                Direction = -1;
             }
            else { 
                BSmkvec ( &rc, V1, Cpt0, Cpt1);
                if (BSdotp(   &rc, V0, V1 ) < 0 )  { Direction = -1; }
            }
        }

  	attr.Iwant = VRCorrection_FlowDirection;
  	attr.FlowDirection = (*nFlowDir) * Direction;
 
  	status = om$send ( msg = message VRCorrection.GRputattr
       		                            (&retmsg, (IGRchar *) &attr),
  	              targetid = CorId.objid,
  	              targetos = CorId.osnum );

	p_FlowDir = &attr.FlowDirection;
__DBGpr_int("Flow Direction      ", *p_FlowDir);

        status = om$send ( msg = message VRGeneric.VRGetPrivateParams(&retmsg,
                                          &SysParamId, NULL, NULL ),
                      targetid =  my_id );
 
        strcpy (Attr.name, VR_N_FLOW_DIR_IN),
        Attr.desc.type = AC_ATTRIB_DOUBLE;
        Attr.desc.value.att_exp = (double) attr.FlowDirection;
 
        status = om$send( msg     = message ACrg_collect.ACmod_list_attribute
                                           ( &retmsg, 1, &Attr ),
                         targetid = SysParamId.objid,
                         targetos = SysParamId.osnum);
  }
 

/*-------------------
#  Set Flow rate.
-------------------*/
  if ( dFlowRate ) { 
        attr.Iwant = VRCorrection_FlowValue;
        attr.FlowValue = *dFlowRate;
 
        status = om$send ( msg = message VRCorrection.GRputattr
                                            (&retmsg, (IGRchar *) &attr),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );

        status = om$send ( msg = message VRGeneric.VRGetPrivateParams(&retmsg,
                                          &SysParamId, NULL, NULL ),
                      targetid =  my_id );
 
        strcpy (Attr.name, VR_N_FLOW_RATE_DB),
        Attr.desc.type = AC_ATTRIB_DOUBLE;
        Attr.desc.value.att_exp = (double) attr.FlowValue;
 
__DBGpr_dbl("Flow Rate           ", attr.FlowValue);

        status = om$send( msg     = message ACrg_collect.ACmod_list_attribute
                                           ( &retmsg, 1, &Attr ),
                         targetid = SysParamId.objid,
                         targetos = SysParamId.osnum);
  }

/*----------------------
# Dirty update of dependents.
----------------------*/
      status = om$send ( msg      = message VRCorrection.VRSetFlow
                                        (&retmsg, NULL, NULL, md_env ),
                         targetid = CorId.objid,
                         targetos = CorId.osnum );

/*
*       nd$exec_batch (mode = 0);
*/
 
 

wrapup:

  End
  return OM_S_SUCCESS;

}/* end VRSetFlow */

/***********************************************************************/

method VRConnect(IGRlong    *msg;
          struct GRid       *SegId;
                 IGRshort    nIndex;
                 IGRshort    nCptNum;
          struct GRmd_env   *md_env  )
{

  IGRint       status;
  struct GRid  MyId;

  /* ------------------------------- */
  /* -- Connect via assoc channel -- */
  /* ------------------------------- */

  SetProc( VRGeneric_VRConnect ); Begin
  status =
  om$send( msg = message Root.connect
                            (ND_father,OM_K_MAXINT,SegId->objid,SegId->osnum,
                             ND_children, OM_K_MAXINT ),
      targetid = my_id);
  as$status(action = RET_STATUS);

  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  status = 
  om$send( msg = message NDnode.NDnotify_connect ( MyId ),
      targetid = SegId->objid,
      targetos = SegId->osnum );

  /* ---------------------- */
  /* -- Update instances -- */
  /* ---------------------- */

  *msg           = MSSUCC;
  me->nNbTopo   += 1;

End
  return ( OM_S_SUCCESS );

}/* end VRConnect */

end implementation VRGeneric;
