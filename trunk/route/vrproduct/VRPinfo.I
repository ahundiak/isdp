/* $Id: VRPinfo.I,v 1.2 2001/02/28 22:40:50 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vROUTE / VRPinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRPinfo.I,v $
 *  Revision 1.2  2001/02/28 22:40:50  anand
 *  No TR. Fix for crash.
 *
 *  Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/15  20:13:58  pinnacle
# Replaced: vrproduct for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  19:37:04  pinnacle
# Replaced: vrproduct/VRPinfo.I for:  by r240_int for route240
#
 *
 * History:
 *  01/17/96	tlb	Add prototypes
 *  02/28/00	Anand	No TR. Check for mod_env before accessing it (prevents
 *			a crash!!)
 *
 *************************************************************************/

class implementation VRPiping;

#include "VRparamdef.h"
#include "VRDbStruct.h"
#include "VRdimdef.h"
#include "vrdef.h"
#include "VRcompdef.h"
#include "vrpdu_pto.h"
#include "vrproduc_pto.h"
#include "vrdbgmacros.h"

#define AS_DEBUG  1

from  ACncpx  import  ACgive_structure;

/***********************************************************************/
method VRGetProduct (IGRshort  *pnProduct;
                     IGRchar   *pc3Product )
{
    SetProc( VRPinfo_VRGetProduct ); Begin
  /* return product's internal number (vrdef.h) */
  if (pnProduct)  *pnProduct = VR_PIPING;

  /* return product's prefixe (2 letters) */
  if (pc3Product)
  {
    pc3Product[0] = 'P';
    pc3Product[1] = 'i';
    pc3Product[2] = '\0';
  }

  End
  return OM_S_SUCCESS;
}/* end VRGetProduct */
/***********************************************************************/

method VRGetSearch (IGRlong      *msg;
             struct GRid         *PbId;
                    IGRint        ListSize;
                    IGRint       *NbParams;
             struct VRSelectAttr *ParamList;
                    IGRchar      *szSearch;
             struct GRmd_env     *md_env)

{
  IGRint      status;
  IGRshort    nOption;
  IGRdouble   dDia1;
  IGRdouble   dDia2;
  IGRchar     szSpecNam[20];
  IGRchar     szAABBCC[20];
  IGRchar     tmp[20];

  SetProc( VRPinfo_VRGetSearch ); Begin

  if ( !szSearch )
  {
    /*| ERROR : Null pointer given as argument */
    *msg = MSFAIL;
    End
    return ( OM_E_INVARG );
  }

  *msg = MSSUCC;

  strcpy (szSearch, VR_PIPING_DIR);
  strcat (szSearch, ":");
  __DBGpr_str(" search string pipingdb",szSearch);

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecNam, szAABBCC, &nOption, NULL,
                            &dDia1, NULL, &dDia2, NULL, md_env),
       targetid = my_id);

  /* -- build selection name -- */

  strcat ( szSearch, szSpecNam);
  strcat ( szSearch, "-");
  __DBGpr_str(" search string spec name",szSearch);

  if (szAABBCC[0] != '\0')
  {
    strcat ( szSearch, szAABBCC);
    strcat ( szSearch, "-");
    __DBGpr_str(" search string comp code",szSearch);
  }

  if (dDia1 > 0.0)
  {
    sprintf( tmp,"%.3lf", dDia1);
    strcat ( szSearch, tmp );
    strcat ( szSearch, "-");
    __DBGpr_str(" search string dia1",szSearch);
  }

  if (dDia2 > 0.0)
  {
    sprintf( tmp,"%.3lf", dDia2);
    strcat ( szSearch, tmp );
    strcat ( szSearch, "-");
    __DBGpr_str(" search string dia2",szSearch);
  }

  sprintf( tmp,"%d", nOption);
  strcat ( szSearch, tmp );
  __DBGpr_str(" search string opt code",szSearch);

  End
  return ( OM_S_SUCCESS );

}/* end VRGetSearch */

/***********************************************************************/

method VRGetSpecComp (IGRlong      *msg;
                      IGRint        NbParams ;
               struct VRSelectAttr *ParamList;
               struct GRid         *CacheId;
               struct GRmd_env     *md_env )
{
  IGRlong     retmsg;
  IGRint      status;
  IGRchar     szSpecName[10], szAABBCC[7], szFamilyName[31];
  IGRshort    nOption, nTopo, nType;
  IGRdouble   dDiam1, dDiam2;

  SetProc( VRPinfo_VRGetSpecComp ); Begin

  *msg = MSSUCC;

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, szAABBCC, &nOption, NULL,
                            &dDiam1, NULL, &dDiam2, NULL, md_env),
       targetid = my_id);

#ifdef vdsDEBUG
  printf("CHECK %d %s\n", __LINE__ , __FILE__);
#endif 

  /* -- acces pdm/pdu to get the component's attributes -- */

  /* Check for mod_env before accessing it (prevents a crash!!) - Anand */
  if( md_env )
      CacheId->osnum = md_env->md_id.osnum;
  else
      CacheId->osnum = OM_Gw_current_OS;

#ifdef vdsDEBUG
  printf("CHECK %d %s\n", __LINE__ , __FILE__);
#endif 

  status=
  VRaccess_db_1 (  &retmsg, szSpecName, szAABBCC,
                    dDiam1, dDiam2, nOption,
                    szFamilyName, &nTopo, &nType, CacheId, NULL );

  if ( !( status & 1 ))
  {
    /*| ERROR -> SPEC ACCESS FAILED */
    *msg=MSFAIL;
    End
    return ( status );
  }

#ifdef vdsDEBUG
  printf(" macro_name    = %s \n", szFamilyName);
  printf(" topology      = %d \n", nTopo);
  printf(" type          = %d \n", nType);
#endif

  End
  return ( OM_S_SUCCESS );

}/* end VRGetSpecComp */


/***********************************************************************/

method VRRetrieveTeeCode (IGRlong    *msg ;
                          IGRdouble   dAngle;
                          IGRchar    *szAABBCC ;
                   struct GRmd_env   *md_env)
{
  IGRint      status;
  IGRchar     szSpecName[20];
  IGRdouble   dDiam1, dDiam2;

  *msg = MSSUCC;

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, NULL, NULL, NULL,
                            &dDiam1, NULL, &dDiam2, NULL, md_env),
       targetid = my_id);

  szAABBCC[0]= 0;

  status=
  VRget_branch (msg, (IGRshort)VR_PIPING, szSpecName,
                  dDiam1, dDiam2, dAngle,
                  0, szAABBCC, NULL );

  if (!(status &1))
  {
     printf(" -----> %s branch table access failed : angle     = %f\n",
      szSpecName, dAngle);
     printf("                                        diameter1 = %f\n",dDiam1);
     printf("                                        diameter2 = %f\n",dDiam2);
    *msg = MSFAIL;
  }
  else
  {
     /*" AABBCC code : %s \n", szAABBCC */
    *msg = MSSUCC;
  }

  return ( status );
} /* end VRRetrieveTeeCode */


/***********************************************************************/

method VRRetrieveElbowCode (IGRlong     *msg ;
                            IGRdouble    dAngle;
                            IGRshort    *nRotationType;
                            IGRchar     *szAABBCC;
                     struct GRmd_env    *md_env)
{
  IGRint     status;
  IGRchar    szSpecName[10];
  IGRdouble  dDiam;

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, NULL, NULL, NULL,
                            &dDiam, NULL, NULL, NULL, md_env),
       targetid = my_id);

  szAABBCC[0]= 0;

  status =
  VRget_bend (msg, (IGRshort) VR_PIPING, szSpecName, dAngle, 0 ,
               szAABBCC , NULL);
  if (!(status &1))
  {
     printf(" -----> %s bend table access failed for an angle of %f \n",
      szSpecName, dAngle);
    *msg = MSFAIL;
  }
  else
  {
     /*" AABBCC code : %s \n", szAABBCC */
    *msg = MSSUCC;
  }

return ( OM_S_SUCCESS );

} /* end VRRetrieveElbowCode */


/***********************************************************************/

method VRRetrieveGeneralCode (IGRlong  *msg ;
                              IGRshort  nItemNum;
                              IGRchar  *szAABBCC;
                       struct GRmd_env *md_env)
{
  IGRlong    retmsg;
  IGRint    status;

  *msg = MSSUCC;

  /* -- Access commodity item table -- */

  szAABBCC[0]= 0;

  status =
  VRcint_piping ( &retmsg, nItemNum, szAABBCC );

  /*" AABBCC code : %s \n", szAABBCC */

  return ( OM_S_SUCCESS );
} /* end VRRetrieveGeneralCode */


method  VRProdKey  (IGRlong   *msg;
                    IGRchar   *szSpecNam;      /*  spec/class name   */
                    IGRchar   *szAABBCC;       /*  compcode          */
                    IGRshort  *nOption;        /*  option code       */
                    IGRshort  *nShape;         /*  shape code        */
                    IGRdouble *dSiz1a;         /*  width1/dia1       */
                    IGRdouble *dSiz1b;         /*  depth1            */
                    IGRdouble *dSiz2a;         /*  width2/dia2       */
                    IGRdouble *dSiz2b;         /*  depth2            */
             struct GRmd_env  *md_env )
{
  IGRint      intmsg;
  IGRint      status;
  IGRint      FootIndex;

  struct ret_struct  AttrRst;

  SetProc( VRPinfo_VRProdKey ); Begin

  *msg = MSSUCC;

  if (nShape) *nShape  = 0;

  if (dSiz1b) *dSiz1b  = 0.0;
  if (dSiz2b) *dSiz2b  = 0.0;

  /* Class */
  if (szSpecNam)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                           ( &intmsg, &FootIndex, VR_N_CLASS_AN,
                              &AttrRst, md_env ),
         targetid = my_id);

    if ( intmsg&1 ) strcpy (szSpecNam, AttrRst.var.text_st.text_string );
    else            strcpy (szSpecNam, "N1");

    __DBGpr_str(" spec name",szSpecNam);
  }

  /* AABBCC code */
  if (szAABBCC)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_AABBCC_AN,
                               &AttrRst, md_env ),
         targetid = my_id);

    if ( intmsg&1 ) strcpy (szAABBCC, AttrRst.var.text_st.text_string );
    else            szAABBCC[0]  = '\0';

    __DBGpr_str(" comp code",szAABBCC);
  }

  /* Green Diameter */
  if (dSiz1a)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_GDIAMETER_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *dSiz1a  = AttrRst.var.root_pm_st.value;
    else          *dSiz1a  = 0.0;

    __DBGpr_dbl(" green dia",*dSiz1a);
  }

  /* Red Diameter */
  if (dSiz2a)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_RDIAMETER_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *dSiz2a = AttrRst.var.root_pm_st.value;
    else          *dSiz2a = 0.0;
    __DBGpr_dbl(" red dia",*dSiz2a);
  }

  /* Option */
  if (nOption)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                              ( &intmsg, &FootIndex, VR_N_OPTION_IN,
                                 &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *nOption = (IGRshort)AttrRst.var.root_pm_st.value;
    else          *nOption = 0;

    __DBGpr_int(" opt code",*nOption);
  }

  End
  return (OM_S_SUCCESS);
}

end implementation VRPiping;

