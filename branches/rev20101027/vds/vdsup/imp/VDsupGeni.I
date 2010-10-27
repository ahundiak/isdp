/* $Id: VDsupGeni.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupGeni.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupGeni.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.6  1997/12/18  14:39:28  pinnacle
# VDsupEtc
#
# Revision 1.5  1997/12/17  22:01:10  pinnacle
# VDsupEtc
#
# Revision 1.4  1997/11/25  15:50:52  pinnacle
# NULL_GRID
#
# Revision 1.3  1997/10/29  15:23:44  pinnacle
# Add VDmaster.h
#
# Revision 1.2  1997/10/28  18:16:14  pinnacle
# Assorted 2.5 Fixes
#
 *
 * History:
 *      MM/DD/YY  AUTHOR DESCRIPTION
 *      10/28/97  ah     added header
 *      11/25/97  ah     Deleted extern NULL_GRID
 *	12/17/97  ah     Added VDsupEtc
 *      12/18/97  ah     Added Get/Set Longs
 ***************************************************************************/

class implementation VDsupGen;

#include "VDmsg.h"

#include "VDsupMisc.h"
#include "VDsupMac.h"
#include "VDsupCons.h"

from  ACrg_collect  import  AClist_attribute;

/* ------------------------------------------
 * Basically a switch routine for type of macro
 */
method ACconstruct_feet( 
  IGRstat   *msg; 
  IGRint     cn_type;
  IGRint     tempNum; 
  TGRid      tempListId[];
  TGRmd_env *md_env;
  IGRint    *feetNum; 
  TGRid     *feetListId 
)
{
  IGRstat     sts,l_msg;

  IGRint      i,cnt;

  TGRid       tl[VDSUP_I_MAX];
  IGRchar     statMsg[256];

  VDsupConsInfo info;

  /* Decode information */
  memset(&info,0,sizeof(info));
  memset(tl,0,sizeof(tl));

  // Get name for status messages
  om$send(
    msg = message GRvg.GRgetname(&l_msg,info.occName),
    targetid = my_id
  );
  sprintf(statMsg,"Computing %s ...",  info.occName);
// printf(        "Computing %d %s ...\n",my_id,info.occName);

  UI_status(statMsg);

  /* Xfer into master list */
  cnt = om$dimension_of(varray = me->typeTempList);

  if (cnt != tempNum) {
    UI_status("Number of parents does not match internal type list\n");
    printf("WARNING, For %s\n",info.occName);
    printf(
      "   Number of actual parents (%d) does not match "
      "internal parent count (%d)\n",
      tempNum,cnt
    );

    goto wrapup;
  }

  for(i = 0; i < cnt; i++) {
    tl[me->typeTempList[i]] = tempListId[i];
  }

  /* Init some info stuff */
  info.tempListId = tempListId;
  info.tempNum    = tempNum;
  info.feetListId = feetListId;
  info.feetNum    = feetNum;
  info.md_env     = md_env;
  info.tl         = tl;
  info.typeMacro  = me->typeMacro;

  /* Extract template info into */
  VDsupGetDouble(md_env,&tl[VDSUP_I_DIS1],&info.dis1);
  VDsupGetDouble(md_env,&tl[VDSUP_I_DIS2],&info.dis2);
  VDsupGetDouble(md_env,&tl[VDSUP_I_CUT1],&info.cut1);
  VDsupGetDouble(md_env,&tl[VDSUP_I_CUT2],&info.cut2);
  VDsupGetDouble(md_env,&tl[VDSUP_I_CUTF],&info.cutf);
  VDsupGetDouble(md_env,&tl[VDSUP_I_CNT ],&info.cnt );

  VDsupGetPoint(md_env,&tl[VDSUP_I_PT_DIR],&info.dirPt,&info.dirBool);
  VDsupGetPoint(md_env,&tl[VDSUP_I_PT_SEL],&info.selPt,&info.selBool);

  VDsupGetLcInfo(md_env,&tl[VDSUP_I_SURF], &info.baseSurfLc); 

  VDsupGetLcInfo(md_env,&tl[VDSUP_I_REF1], &info.baseObj1Lc); 
  VDsupGetLcInfo(md_env,&tl[VDSUP_I_REF2], &info.baseObj2Lc); 

  VDsupGetLcInfo(md_env,&tl[VDSUP_I_TRIM1],&info.trim1Lc); 
  VDsupGetLcInfo(md_env,&tl[VDSUP_I_TRIM2],&info.trim2Lc); 

  /* Find number of trace curves */ 
  for(i = VDSUP_I_TRACE_BEG;
     (i < VDSUP_I_TRACE_END) && (tl[i].objid);
      i+=2);
  info.traceNum = (i -  VDSUP_I_TRACE_BEG) / 2;

  sts = MSFAIL;
  switch(me->typeMacro) {
    case VDSUP_MAC_TYPE_CRV: sts = VDsupConsCrv(&info); break;
    case VDSUP_MAC_TYPE_OFF: sts = VDsupConsOff(&info); break;
    case VDSUP_MAC_TYPE_EQU: sts = VDsupConsEqu(&info); break;
    case VDSUP_MAC_TYPE_ETC: sts = VDsupConsEtc(&info); break;
  }
  __CheckSTS(sts,"Constructing Curve",wrapup);

  /* Verify at least one curve placed */
  if (*feetNum == 0) {
    __CheckRC(0,0,"No offset curves created",wrapup);
  }
  UI_status("Support Macro Compute Complete");
  // printf("Completed ok\n");

  *msg = MSSUCC;

  return OM_S_SUCCESS;

wrapup:

  UI_status("Support Macro Compute Failed");
  // printf("Failed\n");

  *msg = MSFAIL;

  return OM_W_ABORT;
}

/* ------------------------------------------
 * Extracts template list
 * for modify routines
 */
method VDsupGetTempList(
  TGRid   *tlId;
  IGRlong  tlNum; 
  IGRlong *tx
)
{
  IGRstat sts;
  IGRstat l_ret = MSFAIL;

  IGRlong i,cnt;
  IGRint  tempNum;
  TGRid  *tempListId = NULL;

  tempListId = _CALLOC(tlNum,TGRid);
  __CheckPtr(tempListId,"Allocating tempListId",wrapup);

  /* Get Array of parents */
  sts = om$send(
    msg = message NDnode.NDget_objects(
      ND_ROOT,tempListId,tlNum,
      NULL, NULL, OM_K_MAXINT, 
      &tempNum
    ),
    targetid = my_id
  );
  __CheckSTS(sts,"Cannot Get Templates of Macro\n",wrapup);

  /* Xfer into master list */
  cnt = om$dimension_of(varray = me->typeTempList);

  if (cnt != tempNum) {
    printf("WARNING: Support Curve Parent Count Mismatch\n");
    if (cnt > tempNum) cnt = tempNum;
  }

  for(i = 0; i < cnt; i++) {
    tlId[me->typeTempList[i]] = tempListId[i];
  }

  l_ret = MSSUCC;

wrapup:
  _FREE(tempListId);
  return l_ret;
}

/* ------------------------------------------
 * Fills in template information
 * 12/17/97 Added check for NULL_OBJID as well as just plain NULL
 */
method VDsupSetTempList(
  TGRid   *tlId; 
  IGRlong  tlNum;
  IGRlong *tx; 
  IGRlong *tempNum; 
  TGRid   *tempListId
)
{
  IGRlong i,j;

  /* Count number of non-null objects */
  j = 0;
  for(i = 0; i < tlNum; i++) {
    if ((tlId[i].objid != 0) && (tlId[i].objid != NULL_OBJID)) j++;
  }
  om$vla_set_dimension(varray = me->typeTempList, size = j);

  /* Now xfer */
  j = 0;
  for(i = 0; i < tlNum; i++) {
    if ((tlId[i].objid != 0) && (tlId[i].objid != NULL_OBJID)) {
      tempListId[j] = tlId[i];
      me->typeTempList[j] = i;
      j++;
    }
  }
  *tempNum = j;

  return MSSUCC;
}

/* ------------------------------------------
 * Check for each command's required input
 */ 
method VDsupChkMinInput(
  int     *msg;
  TGRid   *tl;
  char    *form_buff;
)
{
  IGRlong msgnumb = 0;

  SetProc( VDsupChkMinInput ); Begin

  *msg = MSFAIL;

  switch(me->typeMacro)
  {
    case VDSUP_MAC_TYPE_CRV: {

      if( tl[VDSUP_I_SURF].objid == NULL )
      {
	 msgnumb = VD_E_supNoBaseSurf;
         goto wrapup;
      }
  
      if( tl[VDSUP_I_REF1].objid == NULL )
      {
	 msgnumb = VD_E_supNoBaseObj;
         goto wrapup;
      }
  
      break;
    }

    case VDSUP_MAC_TYPE_OFF: {

      if( tl[VDSUP_I_SURF].objid == NULL )
      {
	 msgnumb = VD_E_supNoBaseSurf;
         goto wrapup;
      }
  
      if( tl[VDSUP_I_REF1].objid == NULL )
      {
        msgnumb = VD_E_supNoBaseObj;
        goto wrapup;
      }
  
      if( tl[VDSUP_I_TRACE_BEG].objid == NULL )
      {
        msgnumb = VD_E_supNoTraceObj;
        goto wrapup;
      }
  
      if( tl[VDSUP_I_TRACE_BEG + 2].objid == NULL )
      {
        msgnumb = VD_E_supNoTraceObj2;
        goto wrapup;
      }
  
      if( tl[VDSUP_I_DIS1].objid == NULL )
      {
        msgnumb = VD_E_supNoOffDist;
        goto wrapup;
      }
  
      if( tl[VDSUP_I_CNT].objid == NULL )
      {
        msgnumb = VD_E_supNoNumCurve;
        goto wrapup;
      }

      break;
    }

    case VDSUP_MAC_TYPE_EQU: {

      if( tl[VDSUP_I_SURF].objid == NULL )
      {
        msgnumb = VD_E_supNoBaseSurf;
        goto wrapup;
      }
  
      if( tl[VDSUP_I_REF1].objid == NULL )
      {
        msgnumb = VD_E_supNoBaseObj;
        goto wrapup;
      }

      if( tl[VDSUP_I_REF2].objid == NULL )
      {
	 msgnumb = VD_E_supNoBaseObj2;
         goto wrapup;
      }
  
      if( tl[VDSUP_I_TRACE_BEG].objid == NULL )
      {
	 msgnumb = VD_E_supNoTraceObj;
         goto wrapup;
      }
  
      if( tl[VDSUP_I_TRACE_BEG + 2].objid == NULL )
      {
        msgnumb = VD_E_supNoTraceObj2;
        goto wrapup;
      }
  
      if( tl[VDSUP_I_CNT].objid == NULL )
      {
	 msgnumb = VD_E_supNoNumCurve;
         goto wrapup;
      }
  
      break;
    }
  }

wrapup:
  *form_buff = 0;

  if (msgnumb) {
    ex$message(msgnumb = msgnumb, buff = form_buff);
    *msg = MSFAIL;
  }
  else {
    *msg = MSSUCC;
  }

  End
  return MSSUCC;
}

/* -----------------------------------------
 * Set/Get the type of support curve
 */
method VDsupSetType(IGRlong type)
{
  me->typeMacro = type;
  return OM_S_SUCCESS;
}
method VDsupGetType(IGRlong *type)
{
  *type = me->typeMacro;
  return OM_S_SUCCESS;
}

/* -----------------------------------------
 * Set/Get the types of parents
 */
method VDsupSetLongs(IGRlong *longs; IGRlong cnt)
{
  IGRint i;

  // Adjust the size
  if (cnt < 0) goto wrapup;
  om$vla_set_dimension(varray = me->typeTempList, size = cnt);

  /* Now xfer */
  if (longs == NULL) goto wrapup;
  for(i = 0; i < cnt; i++) {
      me->typeTempList[i] = longs[i];
  }

wrapup:
  return OM_S_SUCCESS;
}

method VDsupGetLongs(IGRlong *longs; IGRlong *cnt)
{
  IGRint i;

  // Get the count
  if (cnt == NULL) goto wrapup;
  *cnt = om$dimension_of(varray = me->typeTempList);

  // Xfer
  if (longs == NULL) goto wrapup;
  for(i = 0; i < *cnt; i++) {
      longs[i] = me->typeTempList[i];
  }

wrapup:
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

  long  sts ; /* OM return code	*/

  myDef->info = VD_I_ObjSupGen ;
  myDef->type = 0 ;

  sts   = OM_S_SUCCESS ;
  *msg  = MSSUCC ;

  return sts ;

} /* method VDgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VDsupGen;
