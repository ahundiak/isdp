/* $Id: VCCONref.I,v 1.4 2002/05/29 20:25:43 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 * File:        vccmdconn/VCCONref.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONref.I,v $
 *     Revision 1.4  2002/05/29 20:25:43  anand
 *     Third set of bug fixes for the split cable functionality.
 *     Merge does not corrupt the model. The marker information is
 *     now propagated to newly sketched cables/sub-cables. Changed
 *     interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *     Revision 1.3  2002/05/08 15:48:24  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.2  2001/02/20 01:10:20  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *     Initial import to CVS
 *
# Revision 1.2  1999/02/18  17:58:34  pinnacle
# Replaced: vccmdconn/VCCONref.I for CR 179701619 by ahariharfor route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/12/18  19:45:28  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by kddinov for route
#
# Revision 1.14  1997/12/09  23:54:28  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by kddinov for cabling
#
# Revision 1.13  1997/11/25  23:12:14  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by kddinov for cabling
#
# Revision 1.12  1997/11/25  20:07:56  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by kddinov for cabling
#
# Revision 1.11  1997/11/21  00:16:34  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by kddinov for cabling
#
# Revision 1.10  1997/11/17  23:38:18  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by kddinov for cabling
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.9  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.8  1997/07/14  22:45:24  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/22  13:44:08  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/24  21:20:18  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/24  19:01:08  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/24  00:11:28  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  14:41:28  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:56:52  pinnacle
# Replaced: vccmdconn/VCCONref.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:33:26  pinnacle
# Created: vccmdconn/VCCONref.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *      08/21/96          HV            New
 *	11-97		KDD	Limit connections to DB defined CR179701619.
 * 
 *				Cable connected on cpt 1 is loaded to layout.
 * 
 *				Don't VCT_virtualize() VCTerm in reference file.
 * 
 *				Terminal Pins are defined by (szModId, szPosId).
 *				Same szModId are filtered out in VCCONfill.I.
 *
 *	Feb 18, 99	Anand	Check for the 2nd form pointer being NULL (a
 *				new form has been introduced for this command
 *				object for displaying jumper information).
 *
 * -------------------------------------------------------------------*/

class implementation VCCmdCON;

/*
#define vdsDEBUG 1
#define MY_DEBUG 1
*/

#include "OMprimitives.h"
#include "VDmem.h"
#include "VCLead.h"
#include "vrdbgmacros.h" 
#include "vdreporterr.h"


from  VCRoot     import        VCGetProduct;
from  VCRoot     import        VCGetTopology;
from  VCRoot     import        VCGetType;
from  VCRoot     import        VCGetModel;
from  VCRoot     import        VCGetTagNo;

from  VCMac      import        VCGetEquipTag;
from  VCFoCable  import        VCFo_GetConn;

from  VCDB       import        VCGetLayout;
from  VCDB       import        VCGetAttr;
from  VCDB       import        VCDB_fill;

from  VCCon      import        VCGetSignal;
from  VCCon      import        VCConList;

extern IGRboolean 	VC_posequal();

/*=======================================================================*/

method VCCONRefInfo ( long * sts )
{
  int		           status = OM_S_SUCCESS;
  IGRlong                  retmsg, sts1;
  IGRint                   i;
  IGRshort                 nThisno;
  IGRshort                 nAltno;
  IGRshort                 NbNeigh;
  IGRshort                 nCurAttrs = 1;
  IGRboolean               bCreate;

  char		           *Last_szModId, *Last_pAlt_szPosId, *Last_pDef_szPosId,
                           dummy_str[1]={""};

  char		           text[256]={""},
      		           classname[32]={""},
      		           Pin_max_connect[64]={""};

  int		           NumConTab = 0, 
		           count, index, k2 ;
  IGRboolean               isLegacy = TRUE;
  struct ret_struct	   res; 
  struct VCLdInfo          ldInfo; 
  int		           Size_cab = 30; 
  IGRshort                 *nStates = NULL;
  struct   VCpos           *cab = NULL;
  struct   VCpos           *trm = NULL;


SetProc(VCCmdCON.VCCONRefInfo); Begin;

  /*A initialzation         */
  if (   ((cab       = _MALLOC( Size_cab, struct   VCpos)) == NULL ) || 
	 ((trm       = _MALLOC( Size_cab, struct   VCpos)) == NULL ) || 
	 ((nStates   = _MALLOC( Size_cab, IGRshort      )) == NULL ) ) {

	vd$report_error( error = "Memory allocationg failure");
	goto quit;
  }

  *sts = MSFAIL;

  bCreate = FALSE;

  /*A get the located object */
  me->RefId = me->event1.located_object[0].located_obj;
 
  __DBGpr_obj(" Connect, Refid",me->RefId);

  status =
  om$send (msg = message VCRoot.VCGetType (&me->LocType),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

  /*A change to virtual.....  */
  if (me->LocType & VC_GEN_TERM)
  {

/* KDD 11-97. Don't virtualize if located Terminal is in reference file  */
     if ( me->RefId.osnum == me->ModuleInfo.md_id.osnum ) {
    	status = VCT_virtualize (&retmsg, bCreate, &me->RefId, &me->ModuleInfo,
                	                           &me->RefId, &me->ModuleInfo);
    	as$status();
     }
  }
  else
    { status = OM_E_ABORT; goto quit; }

  if ( me->forms[0].form_ptr == NULL || me->forms[1].form_ptr == NULL )
  {
      __DBGpr_com(" Form Pointer null!");
      status = OM_E_ABORT;
      goto quit;
  }

  status =
  om$send (msg = message VCRoot.VCGetModel (&retmsg, &me->ModelId),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

  if ((retmsg != MSSUCC) || (me->ModelId.objid == NULL_OBJID))
  {
    UI_status (" Terminal layout not available .. Login DB...");
    goto quit;
  }

#ifdef MY_DEBUG
  printf (" Connect, modelid <%d %d>\n",me->ModelId.objid, me->ModelId.osnum);
#endif

  UI_status (" Loading Connectivity tables ....");

  status =
  om$send (msg = message VCRoot.VCGetProduct (&me->Product, NULL),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

  status =
  om$send (msg = message VCRoot.VCGetTagNo (me->szTag),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

  status =
  om$send (msg = message VCMac.VCGetEquipTag
                                  (&retmsg, me->szEqT, &me->ModuleInfo),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

#ifdef MY_DEBUG
  printf (" Refid = <%d %d>\n", me->RefId.objid,me->RefId.osnum);
  printf (" Tags  <%s> - <%s>\n",me->szTag, me->szEqT);
#endif

  /*   find the connect buffer sizes (max)  */
  status =
  om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, NULL, &me->nNumConEnt,
                                 &me->nNumConTab, NULL),
      targetid = me->ModelId.objid,
      targetos = me->ModelId.osnum);

  me->bICB = (me->nNumConEnt != me->nNumConTab);

  NumConTab = me->nNumConTab;

__DBGpr_int("me->nNumConEnt", (int) me->nNumConEnt);
__DBGpr_int("me->nNumConTab", (int) me->nNumConTab);

#ifdef MY_DEBUG
  printf (" Layout %d entries on %d lines\n", me->nNumConTab,
                               me->nNumConEnt);
#endif

  /*A  count the number of leads     */

  status =
  om$send (msg = message VCRoot.VCGetTopology
                                   (&retmsg, VC_REQ_ALL_CPT, &NbNeigh,
                                     NULL, NULL, NULL, NULL),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

  if (NbNeigh <= 0)
  {
    UI_status (" Equipment Not Connected to any Cables ");
    NbNeigh = 1;
/*
    *sts = MSSUCC;
    goto quit;
*/
  }

#ifdef MY_DEBUG
  printf (" Cables connected %d \n", NbNeigh);
#endif

  status = om$vla_set_dimension (varray = me->CabId,
                                 size   = NbNeigh);

  status = om$vla_set_dimension (varray = me->nCPS,
                                 size   = NbNeigh);

  NbNeigh = 0;
  status =
  om$send (msg = message VCRoot.VCGetTopology
                                   (&retmsg, VC_REQ_ALL_CPT, &NbNeigh,
                                     me->CabId, me->nCPS, NULL, NULL),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

  /*A  Find the maximum total number of connected fibers    */
  me->nMaxCnd = 0;

  for (i=0; i<NbNeigh; i++)
  {
    status =
    om$send (msg = message VCDB.VCGetLayout
                                  (&retmsg, NULL, &nThisno, &nAltno, NULL),
        targetid = me->CabId[i].objid,
        targetos = me->CabId[i].osnum);

      me->nMaxCnd += nThisno;
#ifdef MY_DEBUG
    printf (" Cable <%d %d>, end =%d, leads =%d\n",me->CabId[i].objid,
                                   me->CabId[i].osnum, me->nCPS[i], nThisno);
#endif
  }

  /*C  make room for some extra   */

  *sts = MSSUCC;

  		/* KDD 11-97   me->nMaxCon = me->nNumConTab + 20; */
  me->nMaxCon = me->nNumConEnt * 3;
  me->nMaxCnd += 5;

  /* It will come back here if more space is needed. */
Update_nMaxCon:
__DBGpr_int("me->nMaxCon   ", me->nMaxCon   );
__DBGpr_int("me->nMaxCnd   ", me->nMaxCnd   );


#ifdef MY_DEBUG
  printf (" allocing Con, Cnd %d %d\n",me->nMaxCon,me->nMaxCnd);
#endif

  /*A    and allocate the memory needed    */

  status = om$vla_set_dimension (varray = me->PosTab,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->PinConnect,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConTab1,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConSig1,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConTab2,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConSig2,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->CndTab,
                                 size   = me->nMaxCnd);

  status = om$vla_set_dimension (varray = me->CndSig,
                                 size   = me->nMaxCnd);

  /*   retrieve all info             */

  for (i=0; i<me->nMaxCon; i++)
  {
    me->PosTab[i].pDef  = me->INITtrm;
    me->PosTab[i].pAlt  = me->INITtrm;
    me->PosTab[i].nTOPO = VC_TOPO_TRG;
  }

  status =
  om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, NULL, &me->nNumConEnt,
                                 &me->nNumConTab, me->PosTab),
      targetid = me->ModelId.objid,
      targetos = me->ModelId.osnum);

/*----- KDD 11-97 
#1	Each Term pin is defined uniquely by the pair (szModId, szPosId).
*	PosTab[i].pDef.Conn.Term.szModId must not be null.
*	Same Term.szModId are filtered in VCCONfill.I.
*
#2 	For double sided terminals pAlt.szModId == pDef.szModId 
-------*/
  Last_szModId = dummy_str;
  Last_pAlt_szPosId = dummy_str;
  Last_pDef_szPosId = dummy_str;

  for (i = 0; i < me->nNumConEnt ; i++) {
      if ( me->PosTab[i].pDef.Conn.Term.szModId[0] == '\0' ) {
		strcpy( me->PosTab[i].pDef.Conn.Term.szModId, Last_szModId); 
      }
      else { 
	        Last_pAlt_szPosId = dummy_str;
	        Last_pDef_szPosId = dummy_str;
      }

      Last_szModId = me->PosTab[i].pDef.Conn.Term.szModId;

      if ( me->bICB ) { 
	 strcpy( me->PosTab[i].pAlt.Conn.Term.szModId, 
		 me->PosTab[i].pDef.Conn.Term.szModId);
      }

      if ( me->PosTab[i].pDef.Conn.Term.szPosId[0] == '\0' ) {
               strcpy( me->PosTab[i].pDef.Conn.Term.szPosId, Last_pDef_szPosId);
      }
      Last_pDef_szPosId = me->PosTab[i].pDef.Conn.Term.szPosId;


      if ( me->PosTab[i].pAlt.Conn.Term.szPosId[0] == '\0' ) {
               strcpy( me->PosTab[i].pAlt.Conn.Term.szPosId, Last_pAlt_szPosId);
      }
      Last_pAlt_szPosId = me->PosTab[i].pAlt.Conn.Term.szPosId;
  }


#ifdef MY_DEBUG
  for (i=0; i<me->nNumConTab; i++)
    printf (" Postab %s %s - nTopo %d - %s %s\n",
                    me->PosTab[i].pDef.Conn.Term.szModId,
                    me->PosTab[i].pDef.Conn.Term.szPosId,
                    me->PosTab[i].nTOPO,
                    me->PosTab[i].pAlt.Conn.Term.szModId,
                    me->PosTab[i].pAlt.Conn.Term.szPosId);

  printf (" Terminal layout loaded, %d lines\n",me->nNumConTab);
#endif


/*--- KDD 11-97 Get DB "max_connect"cable leads for each terminal pin ---*/
{
	int		i2;

   for ( i = 0, i2 = 0; i < NumConTab; i++, i2++ ) {
	me->PinConnect[ i2 ].PinId = me->PosTab[ i ].pDef.Conn.Term;
	me->PinConnect[ i2 ].NumConnect = 0;
	me->PinConnect[ i2 ].DBlimit    = 0;
        me->PinConnect[ i2 ].NumJumpers = 0;

        i2++;
 
	me->PinConnect[ i2 ].PinId = me->PosTab[ i ].pAlt.Conn.Term;
        me->PinConnect[ i2 ].NumConnect = 0;
	me->PinConnect[ i2 ].DBlimit    = 0;
        me->PinConnect[ i2 ].NumJumpers = 0;
   }

   me->DBNumPins = i2;

   count = 0; 
   for ( i = 0; i < me->DBNumPins; i++ ) {
        status= om$send (msg = message VCCmdCON.VCGetNumOfDatabaseConn (&retmsg,
					&me->PinConnect[ i ].PinId,
					NULL,
					&me->PinConnect[ i ].DBlimit), 
                    targetid = my_id);

	count += me->PinConnect[ i ].DBlimit;

#ifdef MY_DEBUG
	printf("Max Connect = %d, Pos <%s, %s>\n", me->PinConnect[i].DBlimit,
	      me->PinConnect[i].PinId.szModId, me->PinConnect[i].PinId.szPosId);
#endif
   }

   if ( count > me->nMaxCon ) {
	me->nMaxCon = count; 
	goto Update_nMaxCon;
   }
}



  for (i=0; i<me->nMaxCon; i++)
  {
    me->ConTab1[i] = me->INITstr;
    me->ConSig1[i] = me->INITsig;
    me->ConTab2[i] = me->INITstr;
    me->ConSig2[i] = me->INITsig;

    if (me->PosTab[i].pDef.nType == VC_TERM_TYPE)
    {
      status =
      om$send (msg = message VCCon.VCGetSignal
                     (&retmsg, &me->PosTab[i].pDef, me->ConSig1[i].sig),
          targetid = me->RefId.objid,
          targetos = me->RefId.osnum);
#ifdef MY_DEBUG
      printf (" Terminal signal %s loaded\n",me->ConSig1[i].sig);
#endif
    }

    if (me->PosTab[i].pAlt.nType == VC_TERM_TYPE)
    {
      status =
      om$send (msg = message VCCon.VCGetSignal
                     (&retmsg, &me->PosTab[i].pAlt, me->ConSig2[i].sig),
          targetid = me->RefId.objid,
          targetos = me->RefId.osnum);
#ifdef MY_DEBUG
      printf (" Terminal signal %s loaded\n",me->ConSig2[i].sig);
#endif
    }
  }

#ifdef MY_DEBUG
  printf (" Terminal signals done, to %d cables\n",NbNeigh);
#endif

  for (i=0; i<me->nMaxCnd; i++)
  {
    me->CndTab[i] = me->INITstr;
    me->CndSig[i] = me->INITsig;
  }

  for (i=0; i<NbNeigh; i++)
  {
    IGRint           j, k;
    IGRchar          szCabTag[VC_MAX_TAGNO];

    status = om$send (msg = message VCCon.VCConList
                                 (&retmsg, me->nCPS[i],
                           (VC_CBE_OPEN | VC_CBE_CONNECTED | VC_CBE_PASSTHRU),
                                    &nThisno, NULL, NULL, NULL, NULL),
        targetid = me->CabId[i].objid,
        targetos = me->CabId[i].osnum);

    if ( nThisno > Size_cab ) {
	Size_cab  = nThisno;
        cab       = _REALLOC( cab,     Size_cab, struct   VCpos);
	trm       = _REALLOC( trm,     Size_cab, struct   VCpos);
	nStates   = _REALLOC( nStates, Size_cab, IGRshort      );
    }
    

    status = om$send (msg = message VCCon.VCConList
                                 (&retmsg, me->nCPS[i], 
                           (VC_CBE_OPEN | VC_CBE_CONNECTED | VC_CBE_PASSTHRU),
                                    &nThisno, cab, trm, nStates, NULL),
        targetid = me->CabId[i].objid,
        targetos = me->CabId[i].osnum);

    status =
    om$send (msg = message VCRoot.VCGetTagNo (szCabTag),
        targetid = me->CabId[i].objid,
        targetos = me->CabId[i].osnum);

/* KDD 11-97 design correction */ 
/* VCCon.VCConList doesn't know which lead end to connect to */
/* It is this Command object that knows this */

#ifdef MY_DEBUG
    printf (" Cable %d end %d leads returned  %d \n",i, me->nCPS[i],nThisno);
#endif

    for ( j=0; j < nThisno; j++) {
        cab[j].Conn.Cable.nCpt = me->nCPS[i]; 

#ifdef MY_DEBUG
	printf (" Term   %s %s - #%d Cable - %s (end %d)\n",
				(char *) trm[j].Conn.Term.szModId,
				(char *) trm[j].Conn.Term.szPosId,
				j,
				(char *) cab[j].Conn.Cable.szLeadId,
				cab[j].Conn.Cable.nCpt);
#endif
    }

    for (j=0;j<nThisno; j++)
    {
#ifdef MY_DEBUG
      printf (" Cable %d lead %d state %x\n",i, j, nStates[j]);
#endif

      if (nStates[j] & VC_CBE_OPEN)
      {  /*  open lead, add to candidates    */
        me->CndTab[me->nCndNum].GR = me->CabId[i];
        me->CndTab[me->nCndNum].ps = cab[j];

        strcpy(ldInfo.LeadNam,cab[j].Conn.Cable.szLeadId);
	sts1 = VCGetAttrInfoForLead( & me->CabId[i], &ldInfo, 1,
				       VC_MARKER_TYPE, &isLegacy);
	if(!(sts1&1))
	{
	    __DBGpr_obj(" VCGetAttrInfoForLead failed for cable", me->CabId[i]);
	    goto quit;
        }
        if(isLegacy)
	{
            strcpy( me->CndSig[me->nCndNum].marker, "");
	}
	else
	{
            strcpy( me->CndSig[me->nCndNum].marker, ldInfo.Marker);
	}
        strcpy (me->CndTab[me->nCndNum].Ctag, szCabTag);

        /*    get signal   */
        status =
        om$send (msg = message VCCon.VCGetSignal
                             (&retmsg, &cab[j], me->CndSig[me->nCndNum].sig),
            targetid = me->CabId[i].objid,
            targetos = me->CabId[i].osnum);

        (me->nCndNum)++;
#ifdef MY_DEBUG
        printf (" Open lead %d signal %s\n",me->nCndNum,
                                        me->CndSig[me->nCndNum].sig);
#endif

        continue;
      }

      /*    insert passthrough treatment .....    */
      if (nStates[j] & VC_CBE_PASSTHRU)               continue;

      /*    connected leads left      */

__DBGpr_str("terminal connect Module  ", trm[j].Conn.Term.szModId);
__DBGpr_str("terminal connect Position", trm[j].Conn.Term.szPosId);

      for (k=0; k<me->nNumConTab; k++)
      {
        if (VC_posequal (&me->PosTab[k].pDef, &trm[j]) )
        {
        /*---- KDD 11-97 Check the number of connections ----*/

__DBGpr_int("Match with PosTab.pDef ", k);

           status = om$send (msg = message VCCmdCON.VCGetNumOfConnections ( 
				       	&retmsg, 
					&me->PosTab[ k ].pDef.Conn.Term,
					&index, 
					&count),
                        targetid = my_id);

           if ( count >= me->PinConnect[ index ].DBlimit ) {
              sprintf( text, "Pin <%s,%s> connected %d (DB max %d)", 
				me->PinConnect[ index ].PinId.szModId,
				me->PinConnect[ index ].PinId.szPosId,
                                (int) count, me->PinConnect[ index ].DBlimit); 
 
              vd$report_error( error = text, mode = VD_UNIX_WINDOW); 
	      /* break; */
           }
	   me->PinConnect[ index ].NumConnect += 1; 


           if ( (me->ConTab1[k].GR.objid != NULL_OBJID) ) {
 
	     /*- KDD 11-97 Search for blank (LeadId,Ctag) same (PosIs,ModId) -*/

               for (k2 = k + 1; k2 < me->nNumConTab; k2++) {
                   if (!VC_posequal(&me->PosTab[k].pDef,&me->PosTab[k2].pDef) ){
                        break;
                   }

                   if (!strcmp(me->ConTab1[ k2 ].ps.Conn.Cable.szLeadId, "")&&
                       !strcmp(me->ConTab1[ k2 ].Ctag                  , "")  ){
 
                        k = k2;                         /* update  that line  */
                        break;
                   }
               }
 
               if ( k2 > k ) {                          /* insert new line */
                   status = om$send (msg    = message VCCmdCON.VCCONinsert (k),
                                   targetid = my_id);
                        k++;
__DBGpr_int("Inserting new line", k); 
               }
           }

           me->ConTab1[k].GR = me->CabId[i];
           me->ConTab1[k].ps = cab[j];

           strcpy(ldInfo.LeadNam,cab[j].Conn.Cable.szLeadId);
	   sts1 = VCGetAttrInfoForLead( & me->CabId[i], &ldInfo, 1,
				       VC_MARKER_TYPE, &isLegacy);
	   if(!(sts1&1))
	   {
	       __DBGpr_obj(" VCGetAttrInfoForLead failed for cable", me->CabId[i]);
	       goto quit;
           }
           if(isLegacy)
	   {
               strcpy( me->ConSig1[k].marker, "");
	   }
	   else
	   {
               strcpy( me->ConSig1[k].marker, ldInfo.Marker);
	   }
           strcpy (me->ConTab1[k].Ctag, szCabTag);

           /*    get signal   */
           status =
           om$send (msg = message VCCon.VCGetSignal
                             (&retmsg, &cab[j], me->ConSig1[k].sig),
               targetid = me->CabId[i].objid,
               targetos = me->CabId[i].osnum);

           /*   FO connector  */

           if (me->Product == VC_PROD_FO)
           {
             status =
             om$send (msg = message VCFoCable.VCFo_GetConn
                             (&retmsg, cab[j].Conn.Cable.nCpt, 0, &cab[j],
                              me->ConTab1[k].CON, &me->ConTab1[k].nCtype),
                 targetid = me->CabId[i].objid,
                 targetos = me->CabId[i].osnum);
           }

	   /*---- KDD 11-97 this lead is connected to a position ----*/
	   break;
        }

        if (!me->bICB)        continue;

        if (VC_posequal (&me->PosTab[k].pAlt, &trm[j]))
        {
        /*---- KDD 11-97 Check the number of connections ----*/

__DBGpr_int("Match with PosTab.pAlt ", k);

           status = om$send (msg = message VCCmdCON.VCGetNumOfConnections (
                                        &retmsg, 
                                        &me->PosTab[ k ].pAlt.Conn.Term,
                                        &index, 
                                        &count),
                        targetid = my_id);
 
           if ( count >= me->PinConnect[ index ].DBlimit ) {
              sprintf( text, "Pin <%s,%s> connected %d (DB max %d)",
                                me->PinConnect[ index ].PinId.szModId,
                                me->PinConnect[ index ].PinId.szPosId,
                                (int) count, me->PinConnect[ index ].DBlimit);
 
              vd$report_error( error = text, mode = VD_UNIX_WINDOW);
              /* break; */
           }
	   me->PinConnect[ index ].NumConnect += 1; 


           if ( (me->ConTab2[k].GR.objid                  != NULL_OBJID) ) {

	     /*- KDD 11-97 Search for blank (LeadId,Ctag) same (PosIs,ModId) -*/

               for (k2 = k + 1; k2 < me->nNumConTab; k2++) {
                   if (!VC_posequal(&me->PosTab[k].pAlt,&me->PosTab[k2].pAlt) ){
			break;
		   }

	           if (!strcmp(me->ConTab2[ k2 ].ps.Conn.Cable.szLeadId, "")&&
                       !strcmp(me->ConTab2[ k2 ].Ctag                  , "")  ){
 
			k = k2; 			/* update  that line  */
                        break; 
                   }
               }

	       if ( k2 > k ) {				/* insert new line */
                   status = om$send (msg    = message VCCmdCON.VCCONinsert (k),
                                   targetid = my_id);
			k++; 
__DBGpr_int("Inserting new line", k);
	       }
           }

           me->ConTab2[k].GR = me->CabId[i];
           me->ConTab2[k].ps = cab[j];

           strcpy(ldInfo.LeadNam,cab[j].Conn.Cable.szLeadId);
	   sts1 = VCGetAttrInfoForLead( & me->CabId[i], &ldInfo, 1,
				       VC_MARKER_TYPE, &isLegacy);
	   if(!(sts1&1))
	   {
	       __DBGpr_obj(" VCGetAttrInfoForLead failed for cable", me->CabId[i]);
	       goto quit;
           }
           if(isLegacy)
	   {
               strcpy( me->ConSig2[k].marker, "");
	   }
	   else
	   {
               strcpy( me->ConSig2[k].marker, ldInfo.Marker);
	   }
           strcpy (me->ConTab2[k].Ctag, szCabTag);

           /*    get signal   */
           status =
           om$send (msg = message VCCon.VCGetSignal
                             (&retmsg, &cab[j], me->ConSig2[k].sig),
               targetid = me->CabId[i].objid,
               targetos = me->CabId[i].osnum);

           /*   FO connector  */

           if (me->Product == VC_PROD_FO)
           {
             status =
             om$send (msg = message VCFoCable.VCFo_GetConn
                             (&retmsg, cab[j].Conn.Cable.nCpt, 0, &cab[j],
                              me->ConTab2[k].CON, &me->ConTab2[k].nCtype),
                 targetid = me->CabId[i].objid,
                 targetos = me->CabId[i].osnum);
           }

	   /*---- KDD 11-97 this lead is connected to a position ----*/
	   break;
        }
      }
    }
  }

  me->bRedisplay = TRUE;

  UI_status ("Done - loaded");
  status = OM_S_SUCCESS;

  quit:

    if (nStates) _FREE(nStates);
    if (cab    ) _FREE(cab    );
    if (trm    ) _FREE(trm);

  End;
  return (status) ;
}
end implementation VCCmdCON;
