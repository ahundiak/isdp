/* $Id: VRRDBi.I,v 1.4 2002/04/10 19:55:45 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRRDBi.I
 *
 * Description:
 *      interface implementation for RWAY database access
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRRDBi.I,v $
 *        Revision 1.4  2002/04/10 19:55:45  louis
 *        TR5649-standardize tolerances
 *
 *        Revision 1.3  2001/02/20 01:14:59  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/11 19:22:55  anand
 *        SP merge
 *
# Revision 1.1  2000/07/10  19:08:02  pinnacle
# Created: route/vrpdu/VRRDBi.I by apazhani for Service Pack
#
# Revision 1.6  1999/10/21  18:56:52  pinnacle
# Replaced: vrpdu/VRRDBi.I for: TR 179900918 by aharihar for route
#
# Revision 1.5  1999/10/01  18:59:18  pinnacle
# Replaced: vrpdu/VRRDBi.I for: TR 179900778 by aharihar for route
#
# Revision 1.4  1999/04/29  21:26:02  pinnacle
# Replaced: vrpdu/VRRDBi.I for:  by lawaddel for route
#
# Revision 1.3  1999/04/29  12:58:10  pinnacle
# Replaced: vrpdu/VRRDBi.I for:  by sbilla for route
#
# Revision 1.2  1998/08/05  15:58:58  pinnacle
# Replaced: vrpdu/VRRDBi.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:39:34  pinnacle
# Created: vrpdu/VRRDBi.I by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        07/25/98        law       Add tiers for raceways - CR179801144
 *        12/02/98        Alwin     Removed the depth checking condition for
 *				    Raceway Components. TR179802015
 *        24/04/99        Reddy     Added Depth checking condition for 
 *				    Raceway  components through a ppl. 
 *	Oct 1 1999	  Anand	    Fixed glitches in Raceway querying
 *				    procedure. Wrote new function
 *				    GetDepths4QryFromPPL that finds which of
 *				    the two depths for a given shape is to be
 *				    queried for, from a PPL.
 *	Oct 21 1999	  Anand	    Defined criteria for width_r query - for
 *				    TR 179900918.
 *	Jul 10 2000	  Alwin	    Added method to access Raceway Nozzle
 *				    cache. CR179901003
 *        04/05/02        law       TR5649-standardize tolerance with VRGetTol
 *				    
 *************************************************************************/

class implementation VRRDB;

#include "VRdef.h"
#include "vrdbgmacros.h"

/* #define MY_DEBUG */

#include        "v_risproto.h"
#include        "bsparameters.h"

/* CR179900491 - include files */

#include "VDtypedef.h"
#include "GM.h"
#include "GMndg.h"
#include "nddef.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "GMerrordef.h"
#include "vrmacros.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "OMlimits.h"
#include "VDmem.h"
#include "VDppl1.h"
#include "VRMath.h"

/* CR179900491 - include files */

extern IGRdouble fabs();

method   RDB_init  (IGRlong      *msg)
{
  SetProc( Md RDB_init ); Begin 

  *msg             = MSSUCC;

  me->bDB_open     = FALSE;
  me->bNEW_bend    = FALSE;
  me->bNEW_branch  = FALSE;
  me->bNEW_trans   = FALSE;

  me->dCUR_wid     = 0.0;
  me->dCUR_dep     = 0.0;

  me->nCUR_prj     = VRRDB_UNDEF;
  me->nCUR_spc     = VRRDB_UNDEF;
  me->nCUR_spc_idx = VRRDB_UNDEF;
  me->nCUR_bend    = VRRDB_UNDEF;
  me->nCUR_branch  = VRRDB_UNDEF;
  me->nCUR_trans   = VRRDB_UNDEF;
  me->nCUR_cdl     = VRRDB_UNDEF;

  om$vla_set_dimension (varray = me->VRct,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRspec,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRcomps,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRbend,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRbranch,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRtrans,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRcdl,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRrwnozz,
                        size   = 0);

  End
  return (OM_S_SUCCESS);
}

method   RDB_set   (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec)
{
  IGRint        status;
  IGRshort      i;
  IGRboolean    bLoad;

  bLoad = FALSE;

  if (VDSverify_login() != PDM_S_SUCCESS)
  { /*   not currently logged in, init and terminate   */
    /*   clear caches if I was previously opened       */

    if (me->bDB_open)   VR_DbC_Clear();

    *msg = MSFAIL;

    goto wrapup;
  }

  *msg = MSSUCC;

  if (!(me->bDB_open))
  { /*   load components type table             */
    bLoad = TRUE;

    status =
    om$send (msg = message VRRDB.RDB_lCT (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    /*  check if new bend/branch tables exist    */

    if (VdsVerifyRisTable (VRDB_RWBENDSEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_bend = TRUE;

    if (VdsVerifyRisTable (VRDB_RWBRANSEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_branch = TRUE;

    if (VdsVerifyRisTable (VRDB_RWTRA1SEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_trans = TRUE;
  }

  /*     make sure we've got a project ....   */

  if (nProj == VRRDB_UNDEF)
  {
    IGRint   iP;
    extern
    IGRint   VdsGetPrjNo();

    iP = VRRDB_UNDEF;

    status = VdsGetPrjNo (&iP);

    nProj = iP;
  }

  if ((nProj != VRRDB_UNDEF) && (nProj != me->nCUR_prj))
  { /*    load project info    */
    me->nCUR_prj = nProj;

    bLoad = TRUE;

    status =
    om$send (msg = message VRRDB.RDB_lPROJ (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    /*   load spec records     */

    status =
    om$send (msg = message VRRDB.RDB_lSPEC (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;
  }

  if ((nSpec != VRRDB_UNDEF) && (nSpec != me->nCUR_spc))
  {
    IGRshort     iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (nSpec == me->VRspec[i].key.vendor_no)
      {
        me->nCUR_spc_idx = i;
        goto CONT;
      }
    }

    *msg = MSFAIL;    /*   unknown spec number   */
    goto wrapup;

    CONT:

    /*   load spec components list   */

    me->nCUR_spc = nSpec;

    bLoad = TRUE;

    status =
    om$send (msg = message VRRDB.RDB_lCOMP (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_chdir != me->nCUR_bend)
    { /*   load bend table   */
      me->nCUR_bend = me->VRspec[me->nCUR_spc_idx].data.tbl_chdir;

      bLoad = TRUE;

      status =
      om$send (msg = message VRRDB.RDB_lBEND (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_branch != me->nCUR_branch)
    { /*   load branch table   */
      me->nCUR_branch = me->VRspec[me->nCUR_spc_idx].data.tbl_branch;

      bLoad = TRUE;

      status =
      om$send (msg = message VRRDB.RDB_lBRNC (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

  }

  me->bDB_open = TRUE;

  wrapup:
#ifdef MY_DEBUG
  printf (" RDB SET done Proj %d Spec %d W/h %f %f\n",
                     me->nCUR_prj,me->nCUR_spc,me->dCUR_wid,me->dCUR_dep);
  printf (" RDB SET done trans  %d bend %d branch %d\n",
                     me->nCUR_trans,me->nCUR_bend,me->nCUR_branch);
#endif

  if (bLoad) UI_status (" ");

  return (OM_S_SUCCESS);
}


method   RDB_gprj  (IGRlong         *msg;
                    IGRshort         nProj;
             struct VRRDB_project   *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRRDB.RDB_set (msg, nProj, me->nCUR_spc),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    *Rec = me->VRprj;
  }

  return (OM_S_SUCCESS);
}

method   RDB_act   (IGRshort     *nNum;
             struct VRRDB_ct    **Rec)
{
  *nNum = om$dimension_of (varray = me->VRct);

  if (*nNum == 0)   *Rec = NULL;
  else              *Rec = me->VRct;

  return (OM_S_SUCCESS);
}

method   RDB_gct   (IGRlong      *msg;
             struct VRRDB_ct_key *keyin;
                    IGRshort     *nNum;
             struct VRRDB_ct     *Rec)
{
  IGRint          status;

  SetProc( RDB_gct ); Begin

  status =
  om$send (msg = message VRRDB.RDB_set (msg, me->nCUR_prj, me->nCUR_spc),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRct);
    __DBGpr_int(" Num recs in rway_comp_type",iBuf);
    __DBGpr_str(" Comp code input",keyin->comp_code);
    __DBGpr_str(" Comp sh code input",keyin->sh_code);
    __DBGpr_int(" Comp type input",keyin->comp_type);

    for (i=0; i<iBuf; i++)
    {
      if (keyin != NULL)
      {
	__DBGpr_str(" Comp code match?",me->VRct[i].key.comp_code);
        if (strcmp (keyin->comp_code, me->VRct[i].key.comp_code) != 0) continue;

	__DBGpr_str(" Comp sh code match?",me->VRct[i].key.sh_code);
        if ((keyin->sh_code[0] != '\0') &&
            (strcmp (keyin->sh_code, me->VRct[i].key.sh_code) != 0))   continue;

	__DBGpr_int(" Comp type match?",me->VRct[i].key.comp_type);
        if ((keyin->comp_type != VRRDB_UNDEF) &&
            (keyin->comp_type != me->VRct[i].key.comp_type))           continue;

      }

      if (Rec != NULL)
        Rec[*nNum] = me->VRct[i];
      (*nNum)++;

      *msg = MSSUCC;

      if (keyin != NULL) break;
    }
    __DBGpr_int(" Rec no.",i);
  }

  End
  return (OM_S_SUCCESS);
}

method   RDB_aspec (IGRshort     *nNum;
             struct VRRDB_spec  **Rec)
{
  *nNum = om$dimension_of (varray = me->VRspec);

  if (*nNum == 0)   *Rec = NULL;
  else              *Rec = me->VRspec;

  return (OM_S_SUCCESS);
}


method   RDB_gspec (IGRlong        *msg;
                    IGRshort        nProj;
             struct VRRDB_spec_key *keyin;
                    IGRshort       *nNum;
             struct VRRDB_spec     *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRRDB.RDB_set (msg,nProj,me->nCUR_spc),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (keyin != NULL)
      {
        if ((keyin->vendor_no != VRRDB_UNDEF) &&
            (keyin->vendor_no != me->VRspec[i].key.vendor_no)) continue;

        if ((keyin->vendor_code[0] != '\0') &&
            (strcmp (keyin->vendor_code, me->VRspec[i].key.vendor_code) != 0))
                                  continue;
      }

      if (Rec != NULL)
        Rec[*nNum] = me->VRspec[i];
      (*nNum)++;

      *msg = MSSUCC;
      if (keyin != NULL) break;
    }
  }

  return (OM_S_SUCCESS);
}

method   RDB_acmps (IGRshort     *nNum;
             struct VRRDB_comps **Rec)
{
  *nNum = om$dimension_of (varray = me->VRcomps);

  if (*nNum == 0)   *Rec = NULL;
  else              *Rec = me->VRcomps;

  return (OM_S_SUCCESS);
}

 /* This function calls a PPL to decide which depths (red/green/both)	*
  * to be queried. Originally a part of method RDB_gcmps, this code is	*
  * rewritten as a separate function, so that others (besides		*
  * RDB_gcmps) may also call it.		       - Anand (Sep'99) */

IGRint	GetDepths4QryFromPPL(	IGRlong	*msg,
				IGRint	shapecode,
				IGRchar	*macro_name,
				IGRint	*d1_flag,
				IGRint	*d2_flag )
{
    /**** Variables added for CR179900491  ***/
    TGRid 	  pplID ;
    IGRint	  pplRET ;

    SetProc( Fn GetDepths4QryFromPPL ); Begin

    /*****  CR179900491  *****/

    *msg = MSFAIL ;

    /*New depth query implementation for  muli-tier Raceways through a ppl*/
    /* Name of the ppl is  " RWDepthflag.u " */


    /* Load ppl */

    __DBGpr_com( " PPL is going to be loaded ");
    vdppl$Load(name = "RWDepthflag", pplID = &pplID);

    if (pplID.objid != NULL_OBJID) 
    {
	__DBGpr_com( " PPL is loaded ");

	/* Set the shape_code of Raceway in the ppl by calling the setData
	 * on shapecode given as input  */

	vdppl$SetData(	pplID = &pplID,
			name  = "shape_code",
			size  = sizeof(int),
			data  = (IGRchar*) &shapecode );

	if( macro_name )
	{
	    vdppl$SetData( pplID = &pplID,
			   name  = "macro_name",
			   size  = 30,
			   data  = (IGRchar*) macro_name );
	}

	vdppl$Run( pplID = &pplID, name = "getRWDepthFlag", ret = &pplRET );
	/**  verify with pplRET whether ppl is successful or not **/

	/* Get  the variable from the ppl by calling the GetData on
	 * depthflag which is the output from the ppl  */

	vdppl$GetData(
		pplID = &pplID,
		name  = "depthflag1",
		size  = sizeof(int),
		data  = (IGRchar*) &d1_flag );

	vdppl$GetData(
		pplID = &pplID,
		name  = "depthflag2",
		size  = sizeof(int),
		data  = (IGRchar*) &d2_flag );

	vdppl$Delete(pplID = &pplID);

	__DBGpr_int( " Raceway Shape is" , shapecode);
	__DBGpr_int( " Depth flag :1 is" , d1_flag);
	__DBGpr_int( " Depth flag :2 is" , d2_flag);

	*msg = MSSUCC ;
    }

    End
    return OM_S_SUCCESS;

}


method   RDB_gcmps (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRRDB_comps_key *keyin;
                    IGRdouble        wid1;
                    IGRdouble        dep1;
                    IGRdouble        wid2;
                    IGRdouble        dep2;
                    IGRshort        *nNum;
             struct VRRDB_comps     *Rec)
{
    IGRint	status;
    IGRint	d1_flag;
    IGRint	d2_flag;
    IGRboolean	avnd_flag;
    /*IGRchar 	  macro_name[30]; */

    SetProc( Md RDB_gcmps ); Begin 

    status = om$send (msg = message VRRDB.RDB_set (msg, nProj, nSpec),
		 targetid = my_id);

    *nNum = 0;

#ifdef vdsDEBUG
    if ( keyin != NULL )
	printf (" looking for Component <%s> and Type <%d>\n", 
		keyin->comp_code, keyin->rType);
#endif

    if (*msg == MSSUCC)
    {
	IGRshort     i;
	IGRint       iBuf;

	*msg = MSFAIL;

	iBuf = om$dimension_of (varray = me->VRcomps);
	__DBGpr_int( " Nb. of Rows found in DB ", iBuf );


	/*****  CR179900491  *****/

    /*New depth query implementation for  muli-tier Raceways through a ppl*/

	avnd_flag = FALSE ;

	/* Send macro_name if required at a future date. NOTE: The function
	 * GetDepths4QryFromPPL supports an argument for macro_name, but the
	 * PPL RWDepthflag.u does not! */
	// macro_name = me->VRcomps[i].data.famnam ;

	status = GetDepths4QryFromPPL ( msg, keyin->rType, NULL,
					&d1_flag, &d2_flag ); 

	if( *msg == MSSUCC ) 
	{
	    __DBGpr_com( " PPL was loaded ");
	    avnd_flag = TRUE;
	}
	else
	{
	    printf(" \n\nCould not load PPL RWDepthflag.u !!\n");
	    printf(" Proceeding without depth query.\n\n");
	}
	/**  CR179900491  **/

	for (i=0; i<iBuf; i++)
	{
	    if( keyin != NULL )
	    {
		if( (keyin->comp_code[0] != '\0') &&
		    strcmp(keyin->comp_code,me->VRcomps[i].key.comp_code)
		  )
		    continue;

		if( (keyin->rType != VRRDB_UNDEF) &&
		    (keyin->rType != me->VRcomps[i].key.rType)
		  )
		    continue;

		__DBGpr_str(" Comp code match",me->VRcomps[i].key.comp_code);
		__DBGpr_int(" Rcwy type match!",me->VRcomps[i].key.rType);
	    }

	    if ( fabs( wid1 - me->VRcomps[i].data.dWid1 ) > VRGetTol(VR_DIST_TOL) ) 
		continue;

    /* FIX FOR TR 179900918 - by Anand (Oct '99) */

	    /* Per discussions with Rod Banach, for rectangular components, the
	     * width_r field of the rway_comps table is populated with a
	     * non-zero value, only if there is either a width change or a
	     * depth change or both. The width_r is zero for rectangular
	     * components if there is no depth change.  */

	    if( me->VRcomps[i].key.rType==0 && !(wid1==wid2 && dep1==dep2) &&
		fabs(wid2 - me->VRcomps[i].data.dWid2) > VRGetTol(VR_DIST_TOL) )  
		continue;

    /* FIX FOR TR 179900918 - by Anand (Oct '99) */

#ifdef UNDO_REDESIGN

	    /* MODIFIED FOR CR179801144 */
	    if ((me->VRcomps[i].key.rType != VR_RECT) &&
		    (me->VRcomps[i].key.rType != VR_CIRC))
	    {
		if (dep1 != me->VRcomps[i].data.dDep1)  continue;
		if (dep2 != me->VRcomps[i].data.dDep2)  continue;
	    }
#endif UNDO_REDESIGN

	    /**  Begin - Include depth query - CR179900491  **/

	    if( avnd_flag == TRUE )
	    {
		if( d1_flag == 1 &&
		    fabs(dep1 - me->VRcomps[i].data.dDep1) > VRGetTol(VR_DIST_TOL) )
		    continue;  

		if( d2_flag == 1 &&
		    fabs(dep2 - me->VRcomps[i].data.dDep2) > VRGetTol(VR_DIST_TOL) )
		    continue;
	    }
		/**  End - Include depth query - CR179900491  **/

#ifdef vdsDEBUG
	    printf("sizematch? %lf %lf %lf %lf\nvs\t   %lf %lf %lf %lf\n",
						    wid1,dep1,wid2,dep2,
						    me->VRcomps[i].data.dWid1,
						    me->VRcomps[i].data.dDep1,
						    me->VRcomps[i].data.dWid2,
						    me->VRcomps[i].data.dDep2);
#endif

	    if (Rec != NULL)
		Rec[*nNum] = me->VRcomps[i];
	    (*nNum)++;

#ifdef vdsDEBUG
	    printf (" Match FOUND %d\n",i);
#endif
	    *msg = MSSUCC;
	}
	__DBGpr_int(" Num matches",(*nNum));
    }

    End
    return (OM_S_SUCCESS);
}

method   RDB_gbend (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid;
                    IGRdouble        dDep;
                    IGRchar         *Code)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" RDB gbend\n");
#endif

  status =
  om$send (msg = message VRRDB.RDB_set (msg, nProj, nSpec),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;
    IGRshort     iAcode;

    *msg = MSFAIL;

    Code[0] = '\0';

    iAcode = VRRDB_ANG_ALL;

    if (dAng < 44.9995)      iAcode = VRRDB_ANG_L45;
    else
    if (dAng < 45.0005)      iAcode = VRRDB_ANG_45;
    else
    if (dAng < 89.9995)      iAcode = VRRDB_ANG_L90;
    else
    if (dAng < 90.0005)      iAcode = VRRDB_ANG_90;

    iBuf = om$dimension_of (varray = me->VRbend);

    for (i=0; i<iBuf; i++)
    {
      if (me->bNEW_bend)
      {
        if (cType != me->VRbend[i].rec.new.ctype)        continue;

        if ((dWid < me->VRbend[i].rec.new.dwlow) ||
            (dWid > me->VRbend[i].rec.new.dwhig))         continue;

        if ((dDep < me->VRbend[i].rec.new.ddlow) ||
            (dDep > me->VRbend[i].rec.new.ddhig))         continue;

        if ((me->VRbend[i].rec.new.ang_code != VRRDB_ANG_ALL) &&
            (me->VRbend[i].rec.new.ang_code != iAcode))             continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbend[i].rec.new.comp_code);
      }
      else
      {
        if (cType != me->VRbend[i].rec.old.ctype)        continue;

        if ((dAng < me->VRbend[i].rec.old.ang_low) ||
            (dAng > me->VRbend[i].rec.old.ang_high))      continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbend[i].rec.old.comp_code);
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   RDB_gbran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid1;
                    IGRdouble        dDep1;
                    IGRdouble        dWid2;
                    IGRdouble        dDep2;
                    IGRchar         *Code)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" RDB gbranch\n");
#endif

  status =
  om$send (msg = message VRRDB.RDB_set (msg, nProj, nSpec),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;
    IGRshort     iAcode;

    *msg = MSFAIL;

    Code[0] = '\0';

    iAcode = VRRDB_ANG_ALL;
    if (dAng < 44.9995)      iAcode = VRRDB_ANG_L45;
    else
    if (dAng < 45.0005)      iAcode = VRRDB_ANG_45;
    else
    if (dAng < 89.9995)      iAcode = VRRDB_ANG_L90;
    else
    if (dAng < 90.0005)      iAcode = VRRDB_ANG_90;

    iBuf = om$dimension_of (varray = me->VRbranch);

    for (i=0; i<iBuf; i++)
    {
      if (me->bNEW_branch)
      {
        if (cType != me->VRbranch[i].rec.new.ctype)        continue;

        if (((dWid1 < me->VRbranch[i].rec.new.dwlow1) &&
             (dWid1 > me->VRbranch[i].rec.new.dwhig1))       ||
            ((dWid2 < me->VRbranch[i].rec.new.dwlow2) &&
             (dWid2 > me->VRbranch[i].rec.new.dwhig2)))           continue;

        if (((dDep1 < me->VRbranch[i].rec.new.ddlow1) &&
             (dDep1 > me->VRbranch[i].rec.new.ddhig1))       ||
            ((dDep2 < me->VRbranch[i].rec.new.ddlow2) &&
             (dDep2 > me->VRbranch[i].rec.new.ddhig2)))           continue;

        if ((me->VRbranch[i].rec.new.ang_code != VRRDB_ANG_ALL) &&
            (me->VRbranch[i].rec.new.ang_code != iAcode))             continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbranch[i].rec.new.comp_code);
        break;
      }
      else
      {
        if ((dAng < me->VRbranch[i].rec.old.ang_low) ||
            (dAng > me->VRbranch[i].rec.old.ang_high))      continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbranch[i].rec.old.comp_code);
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}

method   RDB_gClist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort         nSpec;
                     IGRshort        *nNum;
              struct VRRDB_comps_key *Comps)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" RDB gClist\n");
#endif

  status =
  om$send (msg = message VRRDB.RDB_set (msg, nProj, nSpec),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRcomps);

    if (Comps != NULL)
    for (i=0; i<iBuf; i++)
    {
      Comps[i] = me->VRcomps[i].key;
    }

    *nNum = iBuf;
  }

  return (OM_S_SUCCESS);
}


method   RDB_gSlist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort        *nNum;
              struct VRRDB_spec_key  *Specs)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" RDB gSlist\n");
#endif

  status =
  om$send (msg = message VRRDB.RDB_set (msg,nProj,me->nCUR_spc),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    if (Specs != NULL)
    for (i=0; i<iBuf; i++)
    {
      Specs[i] = me->VRspec[i].key;
    }

    *nNum = iBuf;
  }

  return (OM_S_SUCCESS);
}

method   RDB_Stonum (IGRchar         *Spec;
                     IGRshort        *nSpec)
{
  IGRint          status;
  IGRlong         retmsg;

#ifdef MY_DEBUG
  printf (" RDB tonum\n");
#endif

  status =
  om$send (msg = message VRRDB.RDB_set (&retmsg,me->nCUR_prj,me->nCUR_spc),
      targetid = my_id);

  *nSpec  = VRRDB_UNDEF;

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (strcmp (me->VRspec[i].key.vendor_code , Spec) == 0)
      {
        *nSpec = me->VRspec[i].key.vendor_no;

        /*   force this one to be the current.......... */
        status =
        om$send (msg = message VRRDB.RDB_set (&retmsg,me->nCUR_prj,*nSpec),
            targetid = my_id);

        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   RDB_Stonam (IGRshort         nSpec;
                     IGRchar         *Spec)
{
  IGRint          status;
  IGRlong         retmsg;

#ifdef MY_DEBUG
  printf (" RDB toname\n");
#endif

  status =
  om$send (msg = message VRRDB.RDB_set (&retmsg,me->nCUR_prj,me->nCUR_spc),
      targetid = my_id);

  Spec[0] = '\0';

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (me->VRspec[i].key.vendor_no == nSpec)
      {
        strcpy (Spec, me->VRspec[i].key.vendor_code);
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method  RDB_gCDL   (IGRlong         *msg;
                    IGRshort         nList;
                    IGRshort         nCode;
                    IGRshort        *nNum;
             struct VRRDB_cdl       *Cdl)
{
  IGRint          status;
  IGRlong         retmsg;

  *nNum = 0;

  if (nList != me->nCUR_cdl)
  {
    me->nCUR_cdl = nList;

    status =
    om$send (msg = message VRRDB.RDB_lCDL (&retmsg),
      targetid = my_id);
  }
  else
    retmsg = MSSUCC;

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRcdl);

    for (i=0; i<iBuf; i++)
    {
      if ((nCode != VRRDB_UNDEF) && (nCode != me->VRcdl[i].ncode)) continue;

      if (Cdl != NULL)
        Cdl[*nNum] = me->VRcdl[i];

      (*nNum)++;
      *msg  = MSSUCC;
    }
  }
  else
    *msg = retmsg;

  return (OM_S_SUCCESS);
}


method  RDB_cdlnum (IGRlong         *msg;
                    IGRshort         nList;
                    IGRchar         *sTxt;
                    IGRshort        *nNum)
{
  IGRint          status;
  IGRlong         retmsg;

  *nNum = VRRDB_UNDEF;

  if (nList != me->nCUR_cdl)
  {
    me->nCUR_cdl = nList;

    status =
    om$send (msg = message VRRDB.RDB_lCDL (&retmsg),
      targetid = my_id);
  }
  else
    retmsg = MSSUCC;

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRcdl);

    for (i=0; i<iBuf; i++)
    {
      if (strcmp (sTxt, me->VRcdl[i].stxt) == 0)
      {
        *nNum = me->VRcdl[i].ncode;
        *msg  = MSSUCC;
        break;
      }
    }
  }
  else
    *msg = retmsg;

  return (OM_S_SUCCESS);
}

method   RDB_arwnozz (	IGRlong			*msg;
			IGRshort     		*nNum;
             		struct VRRDB_rwaynozz 	**Rec ) 
{
  IGRlong	status, retcode;

  SetProc( Md RDB_arwnozz ); Begin 

  *msg = MSFAIL;
  *Rec = NULL;
  *nNum = om$dimension_of (varray = me->VRrwnozz);
  __DBGpr_int( " Nb. Row found in cache ", *nNum );

  if (*nNum == 0)   
  {
     // Fetch it from Database
     __DBGpr_com( " Fetching it from Database " );
     status = om$send( msg = message VRRDB.RDB_lRWAYNOZZ( msg ),
			targetid = my_id );
     as$status( action = RET_STATUS );
  }

  *nNum = om$dimension_of (varray = me->VRrwnozz);
  __DBGpr_int( " Nb. Row found in cache ", *nNum );
  *Rec = me->VRrwnozz;

  End
  return (OM_S_SUCCESS);
}

end implementation VRRDB;
