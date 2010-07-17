
/* $Id: VCRoot2_.I,v 1.2 2001/02/20 01:11:15 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:	vcroot / VCRoot2_.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCRoot2_.I,v $
 *	Revision 1.2  2001/02/20 01:11:15  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/12  20:45:56  pinnacle
# Replaced: vcroot/VCRoot2_.I for:  by kddinov for route
# 
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	12-97	kdd	those 2 methods result from Henk having in Cable DB + 
 *			instance parameters in addition to the system ones. 
 *
 *************************************************************************/

class implementation VCRoot;
 
#include  "VDDbtbldef.h"
#include  "vrdbgmacros.h"
#include  "vdparmacros.h"
#include  "VDmem.h"
#include  "VRutilmacros.h"
#include  "VCproto.h"
#include  "vc_mtoflags.h"
#include  "vc_param.h"
#include  "vc_dbpar.h"

/*----------------- 12-97 KDD
* 12-97 KDD  Copied (partially) from VDgetParameters 
*
*  PARAMETERS:
*
* IGRint             *nbParams  - number of attributes returned
*
* struct ACrg_coll   **parList  - address of the pointer to ACrg_collect
*                                 method allocates memory that user must _FREE()
*                                 may be NULL.
*
* struct GRmd_env    *pMdEnv    - module env (not used)
-----------------*/
method VCgetSysAttributes( IGRlong            *msg ;
                            IGRint             *nbParams;
                            struct ACrg_coll   **parList;
                            struct GRmd_env    *pMdEnv )
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nNbIns= 0 , nNbSys= 0 , nNbUsr= 0 ;
  IGRshort     nSys, nUsr;
  IGRint       NbTot;
  IGRint       nAtt;
  IGRint       nDB= 0;
  IGRint       i;
  IGRshort     nIndex, nMap;
  IGRchar     *pAttNam;
 
  struct ACrg_coll   *Local;
  struct GRid         SysId, UsrId;
  struct GRid         ModelId;
  struct ret_struct   rts;
 
  if ( !msg || !pMdEnv )
    return  OM_E_INVARG;

  /*A initialization  */
  *msg       = MSSUCC;
  *nbParams  = 0;
  *parList   = NULL;
 
  nIndex = nMap = -1;
 
  SysId.objid   = NULL_OBJID ;
  UsrId.objid   = NULL_OBJID ;
 
  /* get the sys collection Ids  */
  status =
  om$send ( msg = message VCRoot.VCGetInsPar (&retmsg, &nNbIns, NULL),
       targetid = my_id );
 
  status =
  om$send ( msg = message VCRoot.VCGetSysPar
                           (&retmsg, &SysId, &nSys, &nNbSys, NULL),
       targetid = my_id );
 
  /*   count the number of DB parameters for this item   */
 
  status =
  om$send ( msg = message VCRoot.VCGetModel (&retmsg, &ModelId),
       targetid = my_id );
 
  nDB = 0;
 
  for (nAtt = 0; nAtt < VC_DB_PARA_LIMIT; nAtt++)
  {
    status =
    om$send ( msg = message VCDB.VCGpAnum
                            (&retmsg, nIndex, nMap, nAtt, &rts),
         targetid = ModelId.objid,
         targetos = ModelId.osnum);
 
    if (retmsg == MSSUCC) nDB++;
  }
 
  *nbParams = NbTot = nNbIns + nNbSys + nNbUsr + nDB;
 
  if (parList)
  {
    Local = _MALLOC (NbTot, struct ACrg_coll);
    if (Local == NULL) return (OM_E_NODYNMEM);
 
    status =
    om$send ( msg = message VCRoot.VCGetInsPar (&retmsg, &nNbIns, Local),
         targetid = my_id );
 
    status =
    om$send ( msg = message VCRoot.VCGetSysPar
                           (&retmsg, &SysId, &nSys, &nNbSys, &Local[nNbIns]),
       targetid = my_id );
 
    *nbParams = nNbIns + nNbSys + nNbUsr;
 
    for (nAtt = 0; nAtt < VC_DB_PARA_LIMIT; nAtt++)
    {
      status =
      om$send ( msg = message VCDB.VCGpAnum
                            (&retmsg, nIndex, nMap, nAtt, &rts),
           targetid = ModelId.objid,
           targetos = ModelId.osnum);
 
      if (retmsg != MSSUCC) continue;
 
      pAttNam = VCDB_AttrNumToNam ((IGRshort) nAtt);
 
      for (i=0; i<(*nbParams); i++)
        if (strcmp (pAttNam, Local[i].name) == 0) goto BYPASS;
 
      strcpy (Local[*nbParams].name, pAttNam);
      if (rts.type == text_type)
      {
        Local[*nbParams].desc.type = AC_ATTRIB_TEXT;
        strcpy (Local[*nbParams].desc.value.att_txt,
                                 rts.var.text_st.text_string);
        (*nbParams)++;
      }
      else
      if (rts.type == double_type)
      {
        Local[*nbParams].desc.type = AC_ATTRIB_DOUBLE;
        Local[*nbParams].desc.value.att_exp = rts.var.root_pm_st.value;
        (*nbParams)++;
      }
 
      BYPASS:;
    }
 
    *parList = Local;
  }
 
  return  status;
}


/*----------------- 12-97 KDD
* 12-97 KDD  Copied (partially) from VDgetParameters 
*
* Modifies (Updates) system collection. 
*-------------------------------
*
* PARAMETERS:
*
* I: IGRint             pNbAttrs  - number of imput attributes.
*
* I: struct ACrg_coll   *pAttr    - pointer to ACrg_collect attribute location.
*                                 method allocates memory that user must _FREE()
*                                 may be NULL.
*
* I: struct GRmd_env    *pMdEnv    - module env (not used)
*------------------------
*
* Any modification of VCRoot.VCGetInsPar must be reflected here as well 
*
-----------------*/
method VCmodSysAttributes( IGRlong            *msg;
                            IGRint             NumSysAttr;
                            struct ACrg_coll  *SysAttr;
                            struct GRmd_env   *pMdEnv  )
{
  IGRint       		status;
  IGRlong      		retmsg;
  IGRint       		NumLocal = 0;
  IGRint       		i;
  struct ACrg_coll   	*Local;
  struct GRid         	SysId;
  IGRboolean		MTOflag; 
 
  if ( !msg ) { status = OM_E_INVARG; goto wrapup; } 
  if ( NumSysAttr == 0 ) goto wrapup;

  SysId.objid   = NULL_OBJID ;
 
  /* Don't modify the DB collection pars.  */

  /* modify the sys collection pars  */
  status = om$send( msg = message VCRoot.VCGetSysPar
                                      (msg, &SysId, NULL, NULL, NULL),
                    targetid = my_id );

  VR$ModifyCollection(  p_msg                 = msg,
                        Operation             = VR_UPDATE_COLL,
                        p_ParamsListToModify  = SysAttr,
                        NbParamsToModify      = NumSysAttr,
			p_OutputCollectionId  = &SysId); 

  /* modify the instance collection parameters  */
  status = om$send (msg      = message VCRoot.VCGetInsPar 
					(msg, (IGRshort *) &NumLocal, NULL),
                    targetid = my_id );

  Local = _MALLOC (NumLocal, struct ACrg_coll);
  if (Local == NULL) { status = OM_E_NODYNMEM; goto wrapup; } 
 
  status = om$send (msg      = message VCRoot.VCGetInsPar 
					(msg, (IGRshort *) &NumLocal, Local),
                    targetid = my_id );

  VR$ModifyCollection(  p_msg                 = msg,
                        Operation             = VR_UPDATE_COLL,
                        p_ParamsListToModify  = SysAttr,
                        NbParamsToModify      = NumSysAttr,
                        OutParList            = &Local,
                        OutNumPar             = &NumLocal);

  for ( i = 0; i < NumLocal; i++ ) { 
     if ( !strcmp( Local[ i ].name , VC_N_COMP_CODE_AN) ) { 
      	status = om$send (msg      = message VCRoot.VCSetCode 
					(Local[i].desc.value.att_txt),
                          targetid = my_id);
	continue;
     }

     if ( !strcmp( Local[ i ].name , VC_N_TAG_NUMBER_AN) ) { 
  	status = om$send( msg      = message VCRoot.VCSetTagNo 
					(Local[i].desc.value.att_txt),
                          targetid = my_id);

        continue;
     }  

     if ( !strcmp( Local[ i ].name , VC_N_NO_MTO_AN) ) { 
	if ( !strcmp( Local[i].desc.value.att_txt, VC_MTOFLAG_INCLUDE) )  {
			MTOflag = TRUE;
	}
	else {
			MTOflag = FALSE;
	}

    	status = om$send( msg      = message VCRoot.VCSetMtoFlag ( MTOflag),
                          targetid = my_id);
 
        continue;
     }  
  }
 
wrapup:
  if ( Local) _FREE(Local); 
  *msg   = status && *msg ;
  return   (*msg) ;
}
 
end implementation VCRoot;

