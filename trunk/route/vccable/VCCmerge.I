
/* $Id: VCCmerge.I,v 1.5 2002/05/29 20:25:43 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCmerge.I
 *
 * Description:
 *      Merge/split cable methods
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmerge.I,v $
 *        Revision 1.5  2002/05/29 20:25:43  anand
 *        Third set of bug fixes for the split cable functionality.
 *        Merge does not corrupt the model. The marker information is
 *        now propagated to newly sketched cables/sub-cables. Changed
 *        interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *        Revision 1.4  2002/05/24 21:41:49  anand
 *        Second set of bug fixes for the cable lead enhancement.
 *        Fixes errors in model arising out of merge-cable workflows.
 *        Ensure placeholders are created for markers for DB driven
 *        cables. Major shuffling of code in Sketch cable state table.
 *
 *        Revision 1.3  2002/05/10 22:13:24  anand
 *        First set of bug fixes for sub-cable functionality. Attempts
 *        to fix merge issues, and some cpt issues. Fix for TR 6344.
 *
 *        Revision 1.2  2001/02/20 01:08:53  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/06/24  18:17:00  pinnacle
# tr179801134
#
# Revision 1.3  1998/04/20  08:42:46  pinnacle
# Replaced: vccable/VCCmerge.I for:  by apazhani for route
#
# Revision 1.2  1998/04/01  20:34:12  pinnacle
# Replaced: vccable/VCCmerge.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.8  1997/08/05  22:28:24  pinnacle
# Replaced: vccable/VCCmerge.I for:  by hverstee for cabling
#
# Revision 1.7  1997/07/29  14:54:48  pinnacle
# Replaced: vccable/VCCmerge.I for:  by hverstee for cabling
#
# Revision 1.6  1997/07/22  15:00:42  pinnacle
# Replaced: vccable/VCCmerge.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/10  14:49:04  pinnacle
# Replaced: vccable/VCCmerge.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/07  19:53:40  pinnacle
# Replaced: vccable/VCCmerge.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/06  22:54:54  pinnacle
# Replaced: vccable/VCCmerge.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/26  21:02:36  pinnacle
# Replaced: vccable/VCCmerge.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:48:38  pinnacle
# Created: vccable/VCCmerge.I by hverstee for cabling
#
 *
 * History:
 * 05/29/96  hv     Initial
 * 04/20/98  Alwin  While merging, the Old Cable's Connectivity
 *		    information needs to be copied to new cable. TR179800933
 * 06/24/98  ah     TR179801134 Aslo need to transfer children
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
#define   MY_DEBUG	1
*/

#include "exdef.h"
#include "nddef.h"
#include "ndmacros.h"

#include "VDmem.h"
#include "VCdefine.h"
#include "VCproto.h"
#include "vrdbgmacros.h"
#include "vddrwattr.h"
#include "vdreporterr.h"
#include "VCchansel.h"


extern  GRclassid          OPP_GR3dlinestr_class_id;
extern  GRclassid          OPP_nci_macro_class_id;

from    GRlinear   import   GRgetpolyline;


/*
 * Documentation for this method (Anand, 5/28):
 *
 * 1. This method merges two cables viz., my_id and pOtherId.
 * 2. The nEnd cpt of my_id is merged with nOthersEnd cpt of pOtherId.
 * 3. The final merged cable's objid is my_id.
 * 4. The cpt of pOtherId not involved with the merge i.e., the (1-nOthersEnd)
 *    cpt of pOtherId will be the 0th cpt of newly merged cable.
 * 5. The cpt of my_id not involved with the merge i.e., the (1-nEnd) cpt
 *    of my_id will be the 1st cpt of newly merged cable.
 * 6. Section map of newly merged cable will be as follows:
 *    [6.1]  All the sections of pOtherId (possibly reversed).
 *    [6.2]  One section introduced for the merge point (section-type for this
 *	     section is VCC_FREE_VERTEX).
 *    [6.3]  All the sections of my_id (possibly reversed).
 *    The 'possibly' clause above will qualify depending upon nEnd and
 *    nOthersEnd values.
 * 7. Newly merged cable will inherit all the topological parents and children
 *    of pOtherId.
 * 8. If the end of pOtherId not involved in merge is connected to a terminal
 *    (with lead-pin connections), the corresponding leads of the newly merged
 *    cable are connected to the appropriate pins.
 *
 *
 * Additions for sub-cable functionality:
 *
 * o  The newly merged cable will be a sub-cable splitting the parent cable at
 *    BEGINNING or END, depending upon pOtherId splitting the parent cable at
 *    BEGINNING or END.
 * o  If input argument pOtherId is a sub-cable, the input argument nOthersEnd
 *    HAS to be 1 for the result (newly merged cable) to be meaningful.
 * o  Since the objid of the final merged cable is my_id, the my_id sent as
 *    the implied input to this method is not checked for being a sub-cable or
 *    not. The finally merged cable being a sub-cable and its consequent
 *    characteristics (leads & signals) are entirely dependent/influenced by
 *    pOtherId.
 * o  If the finally merged cable is a parent-cable, AND the newly merged
 *    cable has its BEGIN-END orientation opposite that of pOtherId, all child
 *    sub-cables receive a message to update their section maps to reflect
 *    this.
 *
 *
 * Addition for marker:
 *
 * o  The marker information from pOtherId is blindly copied over to the newly
 *    merged cable.
 */

method VCCbMerge (IGRlong         *msg;
                 IGRshort         nEnd;
          struct GRid            *pOtherId;
                 IGRshort         nOthersEnd;
          struct GRmd_env        *md_env)
{
  IGRlong      retmsg;
  IGRint       status;
  IGRint       nOsect, nOvert;
  IGRint       nMvert;
  IGRint       nMsect;
  IGRdouble   *pOvert;
  IGRdouble   *pMvert;
  IGRint       i, ii, j;
  IGRint       NoLines;
  IGRint       nParThis;
  IGRint       nParAdd;
  IGRint       nParTot;
  IGRint       Action;
  IGRint       cn_type;

  struct VCCL_sectmap    *pOsect;
  struct VCCL_sectmap    *pLsect;
  struct VCGenInfo        Instance;
  struct IGRpolyline      LineIn;
  struct GRid             Lines[50];
  struct GRid             ParThis[20];
  struct GRid             ParAdd[20];
  struct GRid             ParTot[40];
  struct GRid             mygrid;
  struct GRvg_construct   cnst_lis;
  struct GRsymbology      Symb;

  /* added by alwin */
  IGRint 	NbChild=0;
  struct GRid *ChildBuf=NULL;
  /* added by alwin */

  /* Added by Anand for CR 5844 */
  IGRboolean	bMrgSubCab=FALSE;
  IGRint	nSplEnd, nLeads=0;
  /* Added by Anand for CR 5844 */

  SetProc(VCCable_VCCbMerge); Begin;

  __DBGpr_me();
  __DBGpr_int("This end of me",nEnd);
  __DBGpr_obj("to be merged with Other cable",*pOtherId);
  __DBGpr_int("end of other",nOthersEnd);

  status = om$send( msg = message VCCable.VCAmISubCab( &retmsg, &nSplEnd,
						       NULL, &nLeads, NULL ),
		    targetid = pOtherId->objid,
		    targetos = pOtherId->osnum );
  if( (status&retmsg&1) &&
      (nSplEnd == VCC_SPLIT_BEGIN || nSplEnd == VCC_SPLIT_END) )
  {
      if( nOthersEnd != 1 )
      {
	  printf("Attempt to merge with the start point of sub-cable!\n");
	  End;
	  return OM_E_INVARG;
      }
      bMrgSubCab = TRUE;
  }

  *msg    = MSSUCC;
  NoLines = 0;
  nMvert  = 1;
  nMsect  = om$dimension_of (varray = me->Sect);

  for (i=0; i< nMsect; i++)
    if (me->Sect[i].numvert > nMvert) nMvert = me->Sect[i].numvert;

  pMvert = _MALLOC ((3 * nMvert), IGRdouble);

  /*C    get my parents list   */

  status =
  om$send( msg = message NDnode.NDget_objects
                        (ND_ROOT, ParThis, 20, NULL, 0,
                           OM_K_MAXINT, &nParThis ),
      targetid = my_id);
  as$status ();
  __DBGpr_int("Num My parents",nParThis);

  /* ---------------------------- */
  /*A Get the other link topology */
  /* ---------------------------- */

  status =
  om$send( msg = message NDnode.NDget_objects
                        (ND_ROOT, ParAdd, 20, NULL, 0,
                           OM_K_MAXINT, &nParAdd ),
      targetid = pOtherId->objid,
      targetos = pOtherId->osnum );
  as$status ();
  __DBGpr_int("Num other parents",nParAdd);

  Instance.Attr.Cable.pSect   = NULL;
  Instance.Attr.Cable.pVertex = NULL;
  status =
  om$send(msg = message VCRoot.VCGetInstance (&retmsg,&Instance),
     targetid = pOtherId->objid,
     targetos = pOtherId->osnum );
  as$status();

  nOsect = Instance.Attr.Cable.NbSections;  /* safeguard malloc  */
  nOvert = Instance.Attr.Cable.NbVertices;  /* safeguard malloc  */

  /*   allocate temp space   */
  status = OM_E_ABORT;
  pOvert = _MALLOC ((3 * (nOvert + 1)), IGRdouble);
  pOsect = _MALLOC ((nOsect+1), struct VCCL_sectmap);
  pLsect = _MALLOC ((nOsect + nMsect + 2), struct VCCL_sectmap);

  if (!pMvert || !pOvert || !pOsect || !pLsect)
  {
      End;
      return (OM_E_NODYNMEM);
  }

  Instance.Attr.Cable.pSect   = pOsect;
  Instance.Attr.Cable.pVertex = pOvert;

  status =
  om$send(msg = message VCRoot.VCGetInstance (&retmsg,&Instance),
     targetid = pOtherId->objid,
     targetos = pOtherId->osnum );
  as$status();

  __DBGpr_int("Num my sections",nMsect);
  __DBGpr_int("Num other cable's sections",nOsect);
  __DBGpr_int("Num my vertices",nMvert);
  __DBGpr_int("Num other cable's vertices",nOvert);

  /*C   set up constructionlist and symbology    */

  status =
  om$send( msg = message GRvg.GRgetsymb (&retmsg,&Symb),
      targetid = my_id);
  as$status ( action = RET_STATUS );

  /*A Set up constructionlist   */
  cnst_lis.msg          = &retmsg;
  cnst_lis.env_info     = md_env;
  cnst_lis.newflag      = FALSE;
  cnst_lis.properties   = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.level        = Symb.level;
  cnst_lis.display      = &(Symb.display_attr);

  cnst_lis.class_attr   = NULL;
  cnst_lis.name         = NULL;
  cnst_lis.geometry     = (IGRchar *) &LineIn;

  /*C  set up the combined section map   */
  /*C   move my section map and parent list to temp (possibly reversed) */

  nParTot = 0;

  /*C    add the other line first   */

  for (i=0; i< nOsect; i++)
  {
    j = (nOthersEnd == 0) ? (nOsect - i - 1) : i;

    __DBGpr_int("Other cable's section index",j);
    __DBGpr_int("section type",pOsect[j].type);
    __DBGpr_int("Newly merged cable's section index",i);

    pLsect[i] = pOsect[j];

    /*   reverse break items     */

    if ((nOthersEnd == 0) && (pOsect[j].type == VCC_BREAK_OFF))
      pLsect[i].type = VCC_BREAK_ON;

    if ((nOthersEnd == 0) && (pOsect[j].type == VCC_BREAK_ON))
      pLsect[i].type = VCC_BREAK_OFF;


    if (pOsect[j].parno >= 0)
    {
      if  (nOthersEnd == 0)
      { /* reverse parent indicators   */
        pLsect[i].iFrom = pOsect[j].iTo;
        pLsect[i].iTo   = pOsect[j].iFrom;
      }

      ParTot[nParTot] = ParAdd[pOsect[j].parno + Instance.nNbAttr];
      pLsect[i].parno = nParTot;
      nParTot++;
    }

    if (pOsect[j].strno >= 0)
    {
      IGRint    IDX;

      IDX               = pOsect[j].iFrom * 3;
      LineIn.num_points = pOsect[j].numvert;
      LineIn.points     = &(pOvert[IDX]);

#ifdef MY_DEBUG
      printf (" added string %d vertices from %d IDX = %d\n",
                LineIn.num_points,pOsect[j].iFrom,IDX);
#endif

      if (nOthersEnd == 0)
      {
        VC_revcoord (LineIn.num_points, (IGRdouble *) LineIn.points);
#ifdef MY_DEBUG
        printf (" VCCbMerge, reverse other, string %d\n",pOsect[j].strno);
#endif
      }

      Lines[NoLines].objid = NULL_OBJID;
      Lines[NoLines].osnum = md_env->md_id.osnum;
      cnst_lis.geometry    = (IGRchar *) &LineIn;

      status =
      om$construct (classid = OPP_GR3dlinestr_class_id,
                    p_objid = &Lines[NoLines].objid,
                    msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
      as$status();

      pLsect[i].iFrom   = 0;
      pLsect[i].iTo     = LineIn.num_points -1;
      pLsect[i].numvert = LineIn.num_points;
      pLsect[i].strno   = NoLines;
      NoLines++;
    }
  }

  __DBGpr_int("VCCbMerge, other done, add me at",nOsect);

  /*C    insert the free vertex marker.......     */

  pLsect[nOsect].type    = VCC_FREE_VERTEX;
  pLsect[nOsect].iFrom   = -1;;
  pLsect[nOsect].iTo     = -1;;
  pLsect[nOsect].numvert = -1;;
  pLsect[nOsect].strno   = -1;;
  pLsect[nOsect].parno   = -1;;

  for( i=0 ; i<nMsect ; i++ )
  {
    ii = i + (nOsect+1); // Index for pLsect

    j = (nEnd == 1) ? (nMsect - i - 1) : i;

    __DBGpr_int("My cable's section index",j);
    __DBGpr_int("section type",me->Sect[j].type);
    __DBGpr_int("Newly merged cable's section index",ii);

    pLsect[ii] = me->Sect[j];

    /*   reverse break items     */

    if ((nEnd == 1) && (me->Sect[j].type == VCC_BREAK_OFF))
      pLsect[ii].type = VCC_BREAK_ON;

    if ((nEnd == 1) && (me->Sect[j].type == VCC_BREAK_ON))
      pLsect[ii].type = VCC_BREAK_OFF;

    if (me->Sect[j].parno >= 0)
    {
      if  (nEnd == 1)
      { /* reverse parent indicators   */
        pLsect[ii].iFrom = me->Sect[j].iTo;
        pLsect[ii].iTo   = me->Sect[j].iFrom;
      }

      ParTot[nParTot] = ParThis[me->Sect[j].parno + me->nVCAttr];
      pLsect[ii].parno = nParTot;
      nParTot++;
    }

    if (me->Sect[j].strno >= 0)
    {
      LineIn.points     = pMvert;
      LineIn.num_points = 0;
      Action = 1;

      status =
      om$send(msg    = message GRlinear.GRgetpolyline
                                (&retmsg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &Action, &LineIn),
        p_chanselect = &AS_to_comp,
        from         = me->Sect[j].strno,
        to           = me->Sect[j].strno);
      as$status();


/* KDD 3-98. Check the memory allocated */
    if ( nMvert < LineIn.num_points) {
       vd$report_error( error = "Memory allocation error",
                        mode = 1, filename = __FILE__);
       goto wrapup;
    }


#ifdef MY_DEBUG
      printf (" VCCbMerge, getpoly myself %d vertices\n",LineIn.num_points);
#endif

      if (nEnd == 1)
      {
        VC_revcoord (LineIn.num_points, pMvert);
#ifdef MY_DEBUG
        printf (" VCCbMerge, reverse myself, string %d\n",me->Sect[j].strno);
#endif
      }

#ifdef MY_DEBUG
      {
        IGRint   ii, jj;

        for (ii=0; ii<LineIn.num_points; ii++)
        {
          jj=ii*3;
          printf (" string %d coords %f %f %f\n", NoLines,
                     pMvert[jj], pMvert[jj+1], pMvert[jj+2]);
        }
      }
#endif
          
      Lines[NoLines].objid = NULL_OBJID;
      Lines[NoLines].osnum = md_env->md_id.osnum;
      cnst_lis.geometry    = (IGRchar *) &LineIn;

      status =
      om$construct (classid = OPP_GR3dlinestr_class_id,
                    p_objid = &Lines[NoLines].objid,
                    msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
      as$status();

#ifdef MY_DEBUG
      printf (" VCCbMerge, construct foot %d\n",NoLines);
#endif

      pLsect[ii].iFrom   = 0;
      pLsect[ii].iTo     = LineIn.num_points -1;
      pLsect[ii].numvert = LineIn.num_points;
      pLsect[ii].strno   = NoLines;
      NoLines++;
    }
  }

  /*C   store new section map    */
  __DBGpr_int("Number of sections in newly merged cable",nMsect + nOsect + 1);

  status =
  om$vla_set_dimension (varray   = me->Sect,
                        size     = nMsect + nOsect + 1);

  for (i=0; i<(nMsect + nOsect + 1); i++)
  {
    me->Sect[i] = pLsect[i];
#if defined(vdsDEBUG)
    printf (" sectmap out %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#elif defined(DBG_PROD_NAME)
    if( DBG_Gb_dbg & DBG_PROD )
	fprintf(DBG_Gb_Fp,"sectmap out %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif
  }

  /*C    attach my feet      */

  status =
  om$send( msg = message ACncpx.ACchange_feet (NoLines, Lines, md_env),
      targetid = my_id );
  as$status();

  __DBGpr_objlist("Disconnecting topo parent",(nParThis-me->nVCAttr),&(ParThis[me->nVCAttr]));

  /*C   disconnect parents (not attributes)  */

  if (nParThis > me->nVCAttr)
  {  /*   0 would disconnect all......   */
    status =
    om$send( msg = message NDnode.NDdisconnect
                     ((int)(nParThis - me->nVCAttr), &(ParThis[me->nVCAttr])),
        targetid = my_id );
    as$status();
  }

  /*C   and reconnect new set    */

  __DBGpr_objlist("Reconnecting topo parent",nParTot,ParTot);

  status =
  om$send(msg = message NDnode.NDconnect (nParTot, ParTot, NULL_GRID, ND_ADD),
     targetid = my_id);
  as$status();

  // Below lines added by Anand {{{
  if( bMrgSubCab )
  {
      struct VCcab_connect *LdData=NULL;

      __DBGpr_int("number of leads in sub-cable being merged with",nLeads);
      LdData = _CALLOC( nLeads, struct VCcab_connect );
      status = om$send( msg = message VCCable.VCAmISubCab( &retmsg, &nSplEnd,
							   NULL, &nLeads,
							   LdData ),
			targetid = pOtherId->objid,
			targetos = pOtherId->osnum );

      // Set leads and signals on newly merged cable.
      status = om$send( msg = message VCCable.VCCSetCon_Data( &retmsg, nLeads,
							      LdData, NULL ),
			targetid = my_id );
      _FREE( LdData );
  }
      // Do a blind transfer of the Data VLA from pOtherId to my_id.
  {
      IGRint	nAttr=0,TypeSize=0;
      IGRshort	nType=-1;
      void	*DataPtr=NULL;

      status = om$send( msg = message VCRoot.VCGetDataVLA( NULL, &nAttr,
							   &nType ),
			targetid = pOtherId->objid,
			targetos = pOtherId->osnum );
      __DBGpr_int("Nb Attr",nAttr);
      __DBGpr_int("Attr type (expecting VC_ACRG_COLLECT=1)",nType);

      status = om$send( msg = message VCRoot.VCDataTypeSize( &TypeSize ),
			targetid = pOtherId->objid,
			targetos = pOtherId->osnum );
      __DBGpr_int("Packet size(expecting sizeof struct ACrg_coll)",TypeSize);

      DataPtr = _CALLOC( nAttr*TypeSize, char );

      status = om$send( msg = message VCRoot.VCGetDataVLA( DataPtr, &nAttr,
							   &nType ),
			targetid = pOtherId->objid,
			targetos = pOtherId->osnum );

      status = om$send( msg = message VCRoot.VCSetDataVLA( DataPtr, nAttr,
							   nType ),
			targetid = my_id );

      _FREE( DataPtr );
  }
  // Above lines added by Anand }}}

  /* Added by alwin for TR179800733 */
  {
     IGRshort  nCpt, i;
     struct GRid TerminalId;
  
     TerminalId.objid = NULL_OBJID;

     /* Get the id of Terminal connected to the end of Other cable that is
      * not involved in merge */
     nCpt = 1-nOthersEnd;
     status = om$send( msg = message VCCable.VCCbTerm
			( &retmsg, nCpt, &TerminalId),
		    targetid = pOtherId->objid,
		    targetos = pOtherId->osnum );
     as$status();

     if( TerminalId.objid != NULL_OBJID )
     {
        IGRshort  	nConnectedLeads=0;
	IGRchar		**szSignal=NULL;
	struct VCpos 	*PosTab_cab=NULL, *PosTab_term=NULL;

	/* Get the Number of Leads which are connected to Termianl Pins */
	status = 
	om$send ( msg = message VCCable.VCConList
					   ( &retmsg, nCpt, VC_CBE_CONNECTED,
					   &nConnectedLeads, NULL, NULL,
					  NULL, NULL ),
		      targetid = pOtherId->objid,
		      targetos = pOtherId->osnum );
	as$status();
	__DBGpr_int( " Nb of Connected Leads ", nConnectedLeads );

	if( nConnectedLeads )
	{
	   struct GRid temp;

	   PosTab_cab  = _MALLOC( nConnectedLeads, struct   VCpos);
	   PosTab_term = _MALLOC( nConnectedLeads, struct   VCpos);
	   szSignal    = _MALLOC( nConnectedLeads, IGRchar * );

	   if( !PosTab_cab || !PosTab_term || !szSignal )
	   {
		__DBGpr_com( " Memory Allocation Error :(- " );
		goto skip_update_instance;
	   }

	   status = 
	   om$send ( msg = message VCCable.VCConList
					   ( &retmsg, nCpt, VC_CBE_CONNECTED,
					   &nConnectedLeads, PosTab_cab,
					   PosTab_term, NULL, NULL ),
		       targetid = pOtherId->objid,
		       targetos = pOtherId->osnum );
	   as$status();

	   for( i=0; i<nConnectedLeads;  i++ )
	   {
	       __DBGpr_int( " Cable Cpt ", PosTab_cab[i].Conn.Cable.nCpt );
	       __DBGpr_str( " Cable Lead", PosTab_cab[i].Conn.Cable.szLeadId );
	       __DBGpr_str("Term. Position", PosTab_term[i].Conn.Term.szPosId );
	       __DBGpr_str( "Term. Module ", PosTab_term[i].Conn.Term.szModId );
    
	       /* For the time being set always the "0", as such we have to 
	       find out the correct connect point to which the We have connect
	       the leads back to Terminal */
               PosTab_cab[i].Conn.Cable.nCpt = 0; 

	       szSignal[i]  = _MALLOC( VC_MAX_SIG_ID, IGRchar );
	       if( !szSignal[i] )
	       {
		  __DBGpr_com( " Memory Allocation Error !!! " );
		  goto skip_update_instance;
	       }
    
	       __DBGpr_com( " Get the Signal Name " );
	       szSignal[i][0] = '\0';
	       status =
	       om$send ( msg = message VCCable.VCGetSignal
				   ( &retmsg, &PosTab_cab[i], szSignal[i] ),
		   targetid = pOtherId->objid,
		   targetos = pOtherId->osnum );
	       __DBGpr_str( " Signal Name ", szSignal[i] );
	   }

	   /* Set the above information into the new cable or merged cable, so
	   as to retain the Connectivity details of old cable. Alwin */

	   __DBGpr_com( " Connect the Cables Lead to Terminal " );
	   status =
	   om$send ( msg = message VCCable.VCConnect
			   ( &retmsg, nConnectedLeads, 
			   PosTab_cab, PosTab_term, &temp ),
		   targetid = my_id );
 
	   for( i=0;  i<nConnectedLeads; i++ )
	   {
	       status =
	       om$send ( msg = message VCCable.VCPutSignal
			   ( &retmsg, &PosTab_cab[i], szSignal[i] ),
		   targetid = my_id );
    
	       _FREE( szSignal[i] );
	   }
 
	   _FREE( PosTab_cab );
	   _FREE( PosTab_term );
	   _FREE( szSignal );
	}
     }
  }
  skip_update_instance :
  /* Added by alwin for TR179800933 */

  /* do the wait batch */

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  /* added by alwin for TR179801134 */
  status =
  om$send( msg = message NDnode.NDget_objects
		  ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &ChildBuf, 0,
		    OM_K_MAXINT, &NbChild ),
      targetid = pOtherId->objid,
      targetos = pOtherId->osnum );
  as$status ();
  __DBGpr_int( " Nb. of Childrens for the Cable ", NbChild );

  for( i=0; i<NbChild; i++ )
  {
      IGRint nb_change;
      GRclassid objClassid;

      nb_change = 1;

      __DBGpr_obj( " Connecting Child to new cable ", ChildBuf[i] );
      /* Connect the childrens of the old cable to the new merged cable */
      status =
      om$send(msg = message NDnode.NDchange_connect ( nb_change, pOtherId, 
      						&mygrid ),
	     targetid = ChildBuf[i].objid,
	     targetos = ChildBuf[i].osnum );
      as$status();

      /* Do RTTI and check for cables only. Annotated text objects are
       * candidates for being children of cables. */
      status = om$get_classid(	objid		= mygrid.objid,
				osnum		= mygrid.osnum,
				p_classid	= &objClassid ) ;

      if( OM_S_SUCCESS !=
	  om$is_ancestry_valid( superclassid = OPP_VCCable_class_id,
				subclassid   = objClassid ) )
	  continue;

      /* If necessary, update 0th section type of each child cable */

      if( nOthersEnd )
	  continue;

      /* If code flow comes here, Merged cable has its cpts reverse of
       * pOtherId. The child sub-cables have to be informed about this. */

      status = om$send( msg = message VCCable.VCSubCabTogSectMap( &retmsg ),
			targetid = ChildBuf[i].objid,
			targetos = ChildBuf[i].osnum );
      __CheckRC( status, retmsg, "VCSubCabTogSectMap failed!", wrapup );
  }
  /* added by alwin for TR179801134 */

  cn_type      = ND_COMP;
  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &mygrid,
             l_obj_info = &cn_type,
             nb_obj     = 1);

wrapup:

  _FREE (pMvert);
  _FREE (pOvert);
  _FREE (pOsect);
  _FREE (pLsect);

End;
  return OM_S_SUCCESS;
}/* end VCCbMerge */

/*D ********************************************************************
************************************************************************/

method VCCbSplit ( IGRlong       *msg;
                   IGRdouble     *d3SplitPoint;
            struct GRid          *pNewLink;
            struct GRmd_env      *md_env )
{

SetProc(VCCable_VCCbSplit ); Begin

  printf ("method VCCbSplit NOT YET IMPLEMENTED\n");
End;
  return OM_E_ABORT;

} /* end of VCCbSplit */

end implementation VCCable;
