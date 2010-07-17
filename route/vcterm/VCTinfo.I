/* $Id: VCTinfo.I,v 1.3 2002/05/08 15:48:25 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTinfo.I
 *
 * Description:
 *
 *      methods for terminal instance control and information retrieval
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTinfo.I,v $
 *      Revision 1.3  2002/05/08 15:48:25  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.2  2001/02/20 01:11:36  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/02/18  18:14:56  pinnacle
# Replaced: vcterm/VCTinfo.I for: CR 179701619 by aharihar for route
#
# Revision 1.3  1999/02/12  11:15:40  pinnacle
# Replaced: vcterm/VCTinfo.I for: CR 179701619 by aharihar for route
#
# Revision 1.2  1999/01/19  09:06:44  pinnacle
# Replaced: vcterm/VCTinfo.I for: CR179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/02/24  22:40:48  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by kddinov for route
#
# Revision 1.2  1997/12/03  17:11:06  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by r250_int for route
#
# Revision 1.14  1997/12/02  20:30:50  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by vc241 for cabling
#
# Revision 1.13  1997/08/12  22:08:46  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.12  1997/07/31  22:13:30  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.11  1997/07/22  21:42:06  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.10  1997/07/22  14:48:46  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.9  1997/07/14  22:09:16  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/22  15:22:28  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/19  13:49:40  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.6  1997/03/19  16:05:42  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  16:39:36  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/23  23:38:04  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/20  21:18:58  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:37:40  pinnacle
# Replaced: vcterm/VCTinfo.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:28:22  pinnacle
# Created: vcterm/VCTinfo.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *    19 Jan 1999   Anand     Implemented VCSetJumpInstance and
 *                            VCGetJumpInstance methods for setting jumper
 *                            data and connectivity information to the
 *                            terminal (CR 179701619).
 *
 *    12 Feb 1999   Anand     Implemented VCGetNumJumpCabOnTermPin method.
 *			      (For description, see spec file VCTerm.S)
 *
 *************************************************************************/


class implementation VCTerm;

#include  "vds.h"
#include "vrdbgmacros.h"
#include  "VDmsg.h"
#include "VDmem.h"
#include "VCchansel.h"
#include "vc_structs.h"

from	VCCable		import	VCCbTerm;

extern GRclassid OPP_VCCable_class_id;
extern GRclassid OPP_VCBksh_class_id;

/*
#define MY_DEBUG
*/

method VCSetInstance  (IGRlong    *msg;
                struct VCGenInfo  *Instance)

{
  IGRint          status;

#ifdef  LOOK_TO_REAL_ONE
  if (Instance->nType & VC_GEN_VIRTUAL)
  {
     struct VCGenInfo  LocIns;
     struct GRid       rcon_id;

     /*   virtual terminal, get real one first  */

     status =
     om$send( msg = message VCTerm.VCTRealCon (msg, &rcon_id,NULL),
         targetid = my_id);

#ifdef MY_DEBUG
     printf (" Real term %d %d from virt %d %d\n",rcon_id.objid,
                    rcon_id.osnum, my_id, OM_Gw_current_OS);
#endif

     status =
     om$send (msg = message NDnode.ASreturn_go (&rcon_id, NULL, NULL),
     p_chanselect = &ND_father,
          from    = Instance->nNbAttr,
          to      = Instance->nNbAttr);

#ifdef MY_DEBUG
     printf (" Real term %d %d from virt %d %d\n",rcon_id.objid,
                    rcon_id.osnum, my_id, OM_Gw_current_OS);
#endif

     status =
     om$send( msg = message VCRoot.VCGetInstance (msg, &LocIns),
         targetid = rcon_id.objid,
         targetos = rcon_id.osnum);

     /*    copy code and tag number for convenience   */

     status =
     om$send( msg = message VCRoot.VCSetCode (LocIns.szCode),
         targetid = my_id);

     status =
     om$send( msg = message VCRoot.VCSetTagNo (LocIns.szTagNo),
         targetid = my_id);

     me->nVCType = Instance->nType;
     me->nVCStat = Instance->nStat;
     me->nVCAttr = Instance->nNbAttr;
     me->nVCTopo = 0;
  }
  else
#endif
  {
    status =
    om$send (msg = message VCMac.VCSetInstance (msg, Instance),
            mode = OM_e_wrt_message,
        targetid = my_id);

  }

  return ( OM_S_SUCCESS );

}/* end VCSetInstance */



method VCGetInstance (IGRlong    *msg;
               struct VCGenInfo  *Instance)

{
  IGRint		status;

#ifdef LOOK_TO_REAL_ONE
  if (me->nVCType & VC_GEN_VIRTUAL)
  {
    struct GRid	rcon_id;

    status =
    om$send (msg = message NDnode.ASreturn_go (&rcon_id, NULL, NULL),
    p_chanselect = &ND_father,
    from         = me->nVCAttr,
    to           = me->nVCAttr);
    as$status( action = RET_STATUS );

    status =
    om$send( msg = message VCRoot.VCGetInstance (msg, Instance),
        targetid = rcon_id.objid,
        targetos = rcon_id.osnum);

    Instance->nNbAttr = me->nVCAttr;

  }/* end virtual managment */
  else
#endif
  {
    status =
    om$send (msg = message VCMac.VCGetInstance (msg, Instance),
            mode = OM_e_wrt_message,
        targetid = my_id);

  }

  return ( OM_S_SUCCESS );
}/* end VRGetInstance */

method VCTembed   (IGRboolean   *bEmbedded)
{
  IGRint        status;

  *bEmbedded = (me->nVCType & VC_GEN_EXTERN ? TRUE : FALSE );

  return (OM_S_SUCCESS);
}

method ACcheckin_candidate ( IGRint     CheckinType;
                             IGRint    *p_CheckinCandidate)

{
  IGRint                status;
  IGRboolean            bEmbed;

  *p_CheckinCandidate = TRUE ;

  status =
  om$send( msg  = message VCRoot.ACcheckin_candidate
                                        (CheckinType,p_CheckinCandidate),
           mode = OM_e_wrt_message,
       targetid = my_id );

/*** AD: Invalid check; Need to be reviewed for the 2.5 on attribute level

  status =
  om$send( msg  = message VCTerm.VCTembed (&bEmbed),
       targetid = my_id );

  if (bEmbed)             *p_CheckinCandidate = FALSE;
 **/

  return (OM_S_SUCCESS);
}



method  VCTshells    (IGRlong   *msg;
                      IGRshort  *nShell;  /*  total # of backshells    */
               struct GRid      *Shells)  /*  array of shell GRids     */
{
  IGRint             status;
  IGRshort           nC, nR;
  IGRshort           i;
  GRclassid          ClId;

  struct GRid       *Child;

  *nShell = 0;

  status =
  om$send (msg = message VCRoot.VCChildren (msg, &nC, &nR, NULL),
      targetid = my_id);

  if (nC > 0)
  {
    Child = _MALLOC (nC, struct GRid);
    if (Child == NULL) return (OM_E_NODYNMEM);

    status =
    om$send (msg = message VCRoot.VCChildren (msg, &nC, &nR, Child),
        targetid = my_id);

    for (i=0; i<nC; i++)
    {
      om$get_classid (objid = Child[i].objid,
                      osnum = Child[i].osnum,
                  p_classid = &ClId);

      if (om$is_ancestry_valid (
               subclassid   = ClId,
               superclassid = OPP_VCBksh_class_id) != OM_S_SUCCESS) continue;

      if (Shells)
      {
        Shells[*nShell].objid = Child[i].objid;
        Shells[*nShell].osnum = Child[i].osnum;
      }

      (*nShell)++;
    }

    _FREE(Child);
  }

  return (OM_S_SUCCESS);
}


method  VCTcables    (IGRlong   *msg;
                      IGRshort  *nTotcab; /*  total # of cables        */
                      IGRshort  *nRefcab; /*  # of ref. cables         */
               struct GRid      *Cables)  /*  array of cab GRids       */
{
  IGRint             status;
  IGRshort           nC, nR;
  IGRshort           i;
  IGRshort           iThisOS;
  GRclassid          ClId;

  struct GRid       *Child;

  *nTotcab = 0;
  *nRefcab = 0;
  Child    = NULL;

  status =
  om$send (msg = message VCRoot.VCChildren (msg, &nC, &nR, NULL),
      targetid = my_id);

  if (nC == 0) return (OM_S_SUCCESS);

  Child = _MALLOC (nC, struct GRid);
  if (Child == NULL) return (OM_E_NODYNMEM);

  status =
  om$send (msg = message VCRoot.VCChildren (msg, &nC, &nR, Child),
      targetid = my_id);

  for (i=0; i<nC; i++)
  {
    iThisOS = Child[i].osnum;

    om$get_classid (objid = Child[i].objid,
                    osnum = Child[i].osnum,
                p_classid = &ClId);

    if (om$is_ancestry_valid (
             subclassid   = ClId,
             superclassid = OPP_VCCable_class_id) != OM_S_SUCCESS) continue;

    if (Cables)
    {
      Cables[*nTotcab].objid = Child[i].objid;
      Cables[*nTotcab].osnum = Child[i].osnum;
    }

    (*nTotcab)++;

    if (iThisOS != OM_Gw_current_OS) (*nRefcab)++;

  }

  _FREE(Child);

  return (OM_S_SUCCESS);
}

method VCDUMP      (IGRlong   *msg)
{
  IGRint    status;
  IGRint    iSize, i;

  *msg = MSSUCC;

  status =
  om$send (msg = message VCMac.VCDUMP (msg),
          mode = OM_e_wrt_message,
      targetid = my_id);

  iSize = om$dimension_of (varray = me->VCT_sig);

  for (i=0; i<iSize; i++)
    printf ("VCTERM sigtab %d %d %s\n",i, me->VCT_sig[i].nPkey,
                                          me->VCT_sig[i].SigNam);

  if (iSize > 0) printf ("\n");

  iSize = om$dimension_of (varray = me->VCT_pass);

  for (i=0; i<iSize; i++)
    printf ("VCTERM passtab %d %d - %d %d %d %d - %d %d %d %d\n",
                        i, me->VCT_pass[i].nLeads,
                        me->VCT_pass[i].Cab1.nPtype,
                        me->VCT_pass[i].Cab1.nPchnix,
                        me->VCT_pass[i].Cab1.nPmycpt,
                        me->VCT_pass[i].Cab1.nPocpt,
                        me->VCT_pass[i].Cab2.nPtype,
                        me->VCT_pass[i].Cab2.nPchnix,
                        me->VCT_pass[i].Cab2.nPmycpt,
                        me->VCT_pass[i].Cab2.nPocpt);

  if (iSize > 0) printf ("\n");

  iSize = om$dimension_of (varray = me->VCoff);

  for (i=0; i<iSize; i++)
   printf ("VCTERM cpttab %d %d %d - %f %f %f - %f %f %f\n",i,
                        me->VCoff[i].bAdded,
                        me->VCoff[i].bFree,
                        me->VCoff[i].dX,
                        me->VCoff[i].dY,
                        me->VCoff[i].dZ,
                        me->VCoff[i].dOff1,
                        me->VCoff[i].dOff2,
                        me->VCoff[i].dOff3);

  return (OM_S_SUCCESS);
}

method VDgetObjDef(     long *msg ;
                        VDobjDef *myDef )
{

        myDef->info             = VD_I_ObjVCTerm ;
        myDef->type             = 0 ;

        *msg    = MSSUCC ;

        return (OM_S_SUCCESS)  ;
}

     /* The below two functions are called by VCGetJumpInstance and
	VCSetJumpInstance methods. These functions help overcoming
	legacy data issues that might arise in future. */

IGRint JumpConnSize( short Type )
{
    SetProc( JumpConnSize ); Begin 

    switch( Type )
    {
      case 0:
	  __DBGpr_com(" It's an old file?");
	  End
	  return 0;

      case 1:
	  End
	  return( sizeof(struct VCJumpConn) );

      default:
	  __DBGpr_com(" a bad mistake?");
	  End
	  return 0;
    }
}

IGRint JumpDataSize( short Type )
{
    SetProc( JumpDataSize ); Begin 

    switch( Type )
    {
      case 0:
	  __DBGpr_com(" It's an old file?");
	  End
	  return 0;

      case 1:
	  End
	  return( sizeof(struct VCJumpData) );

      default:
	  __DBGpr_com(" a bad mistake?");
	  End
	  return 0;
    }
}


method VCSetJumpInstance (	IGRlong	*msg;
				void	*JumperInfo;
				IGRint	NbJumpers;
				void	*JumpConnectInfo )
{
    IGRint	status, size, i, NumPins=0;

    SetProc( VCSetJumpInstance ); Begin
    __DBGpr_me();

    me->JumpDataType=1;

    size = NbJumpers * JumpDataSize( me->JumpDataType );
    __DBGpr_int("size of Jump Data", size);

    status = om$vla_set_dimension( varray = me->JumpData,
				   size   = size );
    as$status(action=RET_STATUS);

    switch( me->JumpDataType )
    {
      case 1:
      {
	  struct VCJumpData	*Temp;

	  __DBGpr_int("size of 1 jumpdata struct", sizeof(struct VCJumpData) );
	  memcpy( me->JumpData , JumperInfo , size );

	  Temp = (struct VCJumpData *) me->JumpData;

	  for( i=0 ; i<NbJumpers ; i++ )
	  {
	      __DBGpr_int(" Jumper ID",Temp[i].JumperId);
	      __DBGpr_int(" No. pins in jumper",Temp[i].NumTermPins);
	      NumPins += Temp[i].NumTermPins;
	      __DBGpr_int("Total number of pins so far",NumPins);
	  }
	  break;
      }

      case 0:
	  __DBGpr_com(" Old file?");
      default:
	  End
	  return OM_E_ABORT;
    }

    __DBGpr_int("dimension of jumpdata array", 
	    			om$dimension_of( varray = me->JumpData ) );

    __DBGpr_int(" Number of pins", NumPins);

    me->JumpConnType=1;

    size = NumPins * JumpConnSize( me->JumpDataType );
    __DBGpr_int("size of Jump conn",size);

    status = om$vla_set_dimension( varray = me->JumpConn,
				   size   = size );
    as$status(action=RET_STATUS);

    switch( me->JumpConnType )
    {
      case 0:
	  __DBGpr_com(" Old file?");
	  End
	  return OM_E_ABORT;

      case 1:
	  __DBGpr_int("size of 1 jumpConn struct", sizeof(struct VCJumpConn) );
	  memcpy( me->JumpConn , JumpConnectInfo , size );
	  break;

      default:
	  End
	  return OM_E_ABORT;
    }

    __DBGpr_int("dimension of jumpconn array", 
	    			om$dimension_of( varray = me->JumpConn ) );


    End
    return(OM_S_SUCCESS);
}

method VCGetJumpInstance (	IGRlong	*msg;
				void	**JumperInformation;
				IGRint	*NbJumpers;
				void	**JumpConnectInfo )
{
    IGRint	status, size, struct_size, i, NumPins=0;

    SetProc( VCGetJumpInstance ); Begin
    __DBGpr_me();

    size = om$dimension_of( varray = me->JumpData );
    __DBGpr_int(" dimension of jump data", size);

    struct_size = JumpDataSize(me->JumpDataType);

    if( size && struct_size )  // This check is necessary for old files.
	*NbJumpers = size/struct_size;
    else
	*NbJumpers = 0;
    __DBGpr_int(" no jumpers",*NbJumpers);

    if( ! *NbJumpers )
    {
	__DBGpr_com(" No jumpers connected to this terminal");
	goto quit;
    }

    __CheckPtr( JumperInformation, "jump data pointer null", quit);

    switch( me->JumpDataType )
    {
      case 0:
	  __DBGpr_com(" It's an old file");
	  End
	  return OM_E_ABORT;

      case 1:
      {
	  struct VCJumpData	*JumpInfo;

	  JumpInfo = _CALLOC( *NbJumpers , struct VCJumpData );
	  __CheckPtr( JumpInfo, "Alloc failed for JumperInfo", quit);

	  memcpy( JumpInfo, me->JumpData, size );
	  *JumperInformation = JumpInfo;

	  for( i=0 ; i<*NbJumpers ; ++i )
	  {
	      __DBGpr_int(" Jumper ID",(JumpInfo+i)->JumperId );
	      __DBGpr_str(" Jumper code", (JumpInfo+i)->jump_code);

#ifdef vdsDEBUG
	      printf("Material Take off: %c, Count against MAX: %c\n",
				    (JumpInfo+i)->no_mto_flag,
				    (JumpInfo+i)->cnt_vs_max );
	      printf("Remarks: <%s>\n",(JumpInfo+i)->remarks);
#endif

	      __DBGpr_int(" No. of terminal pins",(JumpInfo+i)->NumTermPins);
	      NumPins += (JumpInfo+i)->NumTermPins;
	  }

	  __DBGpr_int(" Total number of pins -> JumpData",NumPins);
	  break;
      }

      default:
	  End
	  return OM_E_ABORT;
    }

    __CheckPtr( JumpConnectInfo, "jump data pointer null", quit);

    size = om$dimension_of( varray = me->JumpConn );
    __DBGpr_int(" dimension of jump Conn", size);

    struct_size = JumpConnSize( me->JumpConnType );

    if( ! ( size && struct_size ) )
    {
	__DBGpr_com(" This is an old file! It couldn't have reached here!");
	End
	return OM_E_ABORT;
    }

    __DBGpr_int(" Total number of pins -> Jumpconn", size/struct_size);

    if( NumPins != size/struct_size )
    {
	__DBGpr_com(" Inconsistency in number of terminal pins!");
	goto quit;
    }

    if( ! NumPins )
    {
	__DBGpr_com(" Jumper not connected to any terminal pins!??!");
	goto quit;
    }

    switch( me->JumpDataType )
    {
      case 1:
      {
	  struct VCJumpConn	*JumpConn;

	  JumpConn = _CALLOC( NumPins , struct VCJumpConn );
	  __CheckPtr( JumpConn, "Alloc failed for JumperInfo", quit);

	  memcpy( JumpConn, me->JumpConn, size );
	  *JumpConnectInfo = JumpConn;

#ifdef vdsDEBUG
	  for( i=0 ; i<NumPins ; ++i )
	  {
	      __DBGpr_int(" Jumper ID",(JumpConn+i)->JumperId );
	      __DBGpr_str(" Terminal Module",(JumpConn+i)->Mod );
	      __DBGpr_str(" Terminal Position",(JumpConn+i)->Pos );
	  }
#endif
	  break;
      }

      case 0:
	  __DBGpr_com(" It's an old file");
      default:
	  End
	  return OM_E_ABORT;
    }

quit:
    End
    return(OM_S_SUCCESS);
}


method VCGetNumJumpCabOnTermPin	(	IGRlong			*msg;
					struct VCPinConnect	*TermPin;
				)
{
    IGRshort		NbCables, nRefcab;
    IGRint		i, j, status, NbJumpers;
    struct GRid		ModelId, *CableIds;
    IGRchar		szModId[VC_MAX_MOD_ID], szPosId[VC_MAX_POS_ID];

    SetProc( VCGetNumJumpCabOnTermPin ); Begin

    __DBGpr_me();

    strcpy( szModId, (TermPin->PinId).szModId );
    strcpy( szPosId, (TermPin->PinId).szPosId );
    __DBGpr_str(" Querying for Mod",szModId);
    __DBGpr_str(" Querying for Pos",szPosId);

    if( szModId[0] == '\0' || szPosId[0] == '\0' )
    {
	status = OM_E_INVARG;
	__DBGpr_com("Method VCGetNumJumpCabOnTermPin called without terminal pin info for querying!");
	goto wrapup;
    }


  /* STEP ONE: GET THE NUMBER OF CABLE LEADS CONNECTED TO THIS TERMINAL PIN */

	    /* Get the number of cables connected to this terminal */
    status = om$send ( msg = message VCTerm.VCTcables ( msg, &NbCables,
							&nRefcab, NULL ),
		  targetid = my_id);
    as$status();
    __DBGpr_int(" Num cables connected to this terminal", NbCables );

    if( NbCables )
    {
	CableIds = _CALLOC( NbCables, struct GRid );

	if( ! CableIds )
	{
	    status = OM_E_NODYNMEM;
	    __CheckPtr( CableIds, "Alloc failed for CableIds", wrapup );
	}

	    /* Get the cable ids connected to this terminal */
	status = om$send ( msg = message VCTerm.VCTcables( msg, &NbCables,
							   &nRefcab, CableIds ),
		      targetid = my_id);
	as$status();

	TermPin->NumConnect=0;

/************* For each cable -- */
	for( i=0 ; i<NbCables ; i++ )
	{
	    struct GRid		TermId;
	    IGRshort		nCpt=0, nPos;
	    struct VCpos	*TermPos;

#ifdef vdsDEBUG
	    printf("\t Cable [%d] ObjId : %d\n", i, (CableIds+i)->objid );
#endif

/* -- find which end of this cable is connected to this terminal *******/
	    status = om$send ( msg = message VCCable.VCCbTerm( msg,
							       nCpt,
							       &TermId ),
			  targetid = (CableIds+i)->objid,
			  targetos = (CableIds+i)->osnum );
	    as$status();

	    __DBGpr_obj(" Terminal Id at cpt 0", TermId );

	    if( TermId.objid != my_id || TermId.osnum != OM_Gw_current_OS )
		nCpt=1;

	    __DBGpr_int(" Connect point",nCpt);

/* -- get the terminal pins each of its lead is connected to *********/
	    status = om$send( msg = message VCCable.VCConList( msg, nCpt,
							       VC_CBE_CONNECTED,
							       &nPos, NULL,
							       NULL, NULL,
							       NULL ),
			  targetid = (CableIds+i)->objid,
			  targetos = (CableIds+i)->osnum );
	    as$status();
	    __DBGpr_int(" No. cable leads connected to terminal",nPos );

	    if( ! nPos )
		continue;

	    TermPos = _CALLOC( nPos, struct VCpos );

	    if( ! TermPos )
	    {
		status = OM_E_NODYNMEM;
		__CheckPtr( TermPos, "Alloc failed for TermPos", wrapup );
	    }

	    status = om$send( msg = message VCCable.VCConList( msg, nCpt,
							       VC_CBE_CONNECTED,
							       &nPos, NULL,
							       TermPos,
							       NULL, NULL ),
			 targetid = (CableIds+i)->objid,
			 targetos = (CableIds+i)->osnum );
	    as$status();

	    for( j=0 ; j<nPos ; j++ )
	    {
		__DBGpr_str("Term. Position", (TermPos+j)->Conn.Term.szPosId );
		__DBGpr_str("Term. Module  ", (TermPos+j)->Conn.Term.szModId );

/* -- Check if our terminal pin is connected to one of the leads *******/
		if( ! strcmp( (TermPos+j)->Conn.Term.szPosId, szPosId ) &&
		    ! strcmp( (TermPos+j)->Conn.Term.szModId, szModId ) )
		{
		    __DBGpr_int(" No. cable lead connected to pin",j);
		    ++ TermPin->NumConnect;
		}
	    }

	    _FREE( TermPos  );
	}

	_FREE( CableIds );
    }
    else
	    /* If no cables are connected to this terminal, no cable lead
	     * could be connected to this terminal pin. */
	TermPin->NumConnect=0;

    __DBGpr_int(" Number of cable leads connected to this terminal pin",
						     TermPin->NumConnect );


    /* STEP TWO: GET THE NUMBER OF JUMPERS CONNECTED TO THIS TERMINAL PIN */


	    /* Get the number of jumpers connected to this terminal */
    status = om$send ( msg = message VCTerm.VCGetJumpInstance(  msg, NULL,
								&NbJumpers,
								NULL ),
		  targetid = my_id );
    as$status();

    __DBGpr_int(" Number of jumpers connected to this terminal",NbJumpers);

    if( NbJumpers )
    {
	void	*TempData, *TempConn;

	status = om$send ( msg = message VCTerm.VCGetJumpInstance( msg,
		    						   &TempData,
								   &NbJumpers,
								   &TempConn ),
		      targetid = my_id );
	as$status();

	if( me->JumpDataType==1 && me->JumpConnType==1 ) 
	{
	    struct VCJumpData	*JumpData;
	    struct VCJumpConn	*JumpConn;
	    IGRint		NumPinsTerm=0;

	    JumpData = (struct VCJumpData *) TempData;
	    JumpConn = (struct VCJumpConn *) TempConn;

	    for( i=0 ; i<NbJumpers ; i++ )
	    {
		__DBGpr_int(" Jumper ID",(JumpData+i)->JumperId );
		__DBGpr_str(" Jumper code", (JumpData+i)->jump_code);
#ifdef vdsDEBUG
		printf("Material Take off: %c, Count against MAX: %c\n",
			(JumpData+i)->no_mto_flag,
			(JumpData+i)->cnt_vs_max );
#endif
		__DBGpr_str(" Remarks: ",(JumpData+i)->remarks);
		__DBGpr_int(" No. of terminal pins",(JumpData+i)->NumTermPins);

		NumPinsTerm += (JumpData+i)->NumTermPins;

	    }
	    __DBGpr_int(" Total no pins occupied by all jumpers",NumPinsTerm);

	    TermPin->NumJumpers=0;

	    for( i=0 ; i<NumPinsTerm ; ++i )
	    {
		IGRint	jmp_i;

		__DBGpr_int(" Jumper ID",(JumpConn+i)->JumperId );
		__DBGpr_str(" Terminal Module", (JumpConn+i)->Mod );
		__DBGpr_str(" Terminal Position", (JumpConn+i)->Pos );

		if( ( i==0 ) || ( i>0 &&
		    (JumpConn+i)->JumperId != (JumpConn+i-1)->JumperId ) )
		{
		    /* Query for jumper id to get jumper code */
		    for( jmp_i=0 ; jmp_i<NbJumpers ; jmp_i++ )
			if( (JumpConn+i)->JumperId
				== (JumpData+jmp_i)->JumperId )
			    break;
		}

		__DBGpr_str(" Jumper code for this jumper ID",
						  (JumpData+jmp_i)->jump_code);
#ifdef vdsDEBUG
		printf("\t Count this jumper against MAX_CONNECT: %c\n",
						 (JumpData+jmp_i)->cnt_vs_max);
#endif

		if( ! strcmp( (JumpConn+i)->Pos, szPosId ) &&
		    ! strcmp( (JumpConn+i)->Mod, szModId ) &&
		    (JumpData+jmp_i)->cnt_vs_max == 'y'  )
		{
		    __DBGpr_com(" This jumper connected to our pin");
		    ++ TermPin->NumJumpers; 
		}
	    }
	}

	_FREE( TempData );
	_FREE( TempConn );
    }
    else
	    /* Since, no jumpers are connected to this terminal, this terminal
	     * pin will not have any jumpers connected to it. */
	TermPin->NumJumpers=0;

    __DBGpr_int(" Number of jumpers connected to this terminal pin",
						     TermPin->NumJumpers );



   /* STEP THREE: GET THE 'max_connect' LIMIT OF THIS TERMINAL PIN FROM DB */

	    /* Get the terminal's model id */
    status = om$send (msg = message VCRoot.VCGetModel ( msg, &ModelId ),
		 targetid = my_id );
    as$status();
    __DBGpr_obj(" Terminal's model id",ModelId);

	    /* Get its DB limit */
    {
	struct VCpos		PosTerm;
	struct ret_struct	res;

	PosTerm.nType = VC_TERM_TYPE;
	strcpy( PosTerm.Conn.Term.szModId , TermPin->PinId.szModId );
	strcpy( PosTerm.Conn.Term.szPosId , TermPin->PinId.szPosId );

	status = om$send ( msg = message VCDB.VCGetAttr( msg, &PosTerm,
		    					 VC_N_MAX_CONNECT_DB,
							 &res),
		      targetid = ModelId.objid,
		      targetos = ModelId.osnum);
	as$status();

	TermPin->DBlimit = (IGRint) res.var.root_pm_st.value;
	__DBGpr_int(" DB limit of terminal pin",TermPin->DBlimit);
    }


    status=OM_S_SUCCESS;
wrapup:
    End
    return status;

}


method VCDataTypeSize( IGRint *PcktSize )
{
    //This method should be overridden.
    *PcktSize = 0;

    return OM_S_SUCCESS;
}

method VCSetDataVLA( void	*InstanceAttr;
		     IGRint	NbInstAttr;
		     IGRshort	DataType )
{
    IGRint status;
    IGRlong msg;

    status = om$send( msg = message VCRoot.VCInitInstance( &msg ),
		      targetid = my_id,
		      mode = OM_e_wrt_message );

    return status;
}


method VCGetDataVLA( void	*InstAttr;
		     IGRint	*nNbAttr;
		     IGRshort	*DataType )
{
    IGRint status;

    status = om$send( msg = message VCRoot.VCGetDataVLA( InstAttr,
							 nNbAttr,
							 DataType ),
		      targetid = my_id,
		      mode = OM_e_wrt_message );

    return status;
} 


end implementation VCTerm;

