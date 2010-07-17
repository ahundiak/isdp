/* $Id: VRRinfo.I,v 1.1.1.1 2001/01/04 21:13:06 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vROUTE / VRRinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRRinfo.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1999/04/30  21:52:10  pinnacle
# Truncate problem in key
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/15  20:13:58  pinnacle
# Replaced: vrproduct for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  19:37:10  pinnacle
# Replaced: vrproduct/VRRinfo.I for:  by r240_int for route240
#
 *
 * History:
 * 01/17/96  tlb  Add prototypes
 * 04/30/99  ah   TR179900392 Use ris routine to build key
 *
 *************************************************************************/

class implementation VRRway;

#include "VRparamdef.h"
#include "VRDbStruct.h"
#include "VRdimdef.h"
#include "vrdef.h"
#include "VRcompdef.h"
#include "VRattr_def.h"
#include "VRDbParamDef.h"

#include "vrpdu_pto.h"
#include "vrproduc_pto.h"

#include "VDrisFunc.h"

#define AS_DEBUG  1

from  ACncpx        import  ACgive_structure;
from  ACncpx        import  GRputname;
from  ACrg_collect  import  AClist_attribute;
from  ACrg_collect  import  ACadd_attribute;

static int traceFlag;

/***********************************************************************/
method VRGetProduct ( IGRshort  *pnProduct;
                      IGRchar   *pc3Product )
{
  /* return product's internal number (vrdef.h) */
  if (pnProduct)  *pnProduct = VR_RWAY;

  /* return product's prefixe (2 letters) */
  if (pc3Product)
  {
    pc3Product[0] = 'R';
    pc3Product[1] = 'w';
    pc3Product[2] = '\0';
  }

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
  IGRint      intmsg;
  IGRlong     retmsg;
  IGRint      status;
  IGRint      FootIndex=-1;
  IGRint      i;
  IGRchar     Value[10];
  IGRchar     szSpecNam[20];
  IGRchar     szAABBCC[20];
  IGRshort    nShape;

  struct ret_struct  AttrRst;
  struct ACrg_coll   attributes[VR_MAX_ATTR];

  if ( !ParamList || !NbParams || !szSearch )
  {
    /*| ERROR : Null pointer given as argument */
    *msg = MSFAIL;
    return ( OM_E_INVARG );
  }

  *msg = MSSUCC;
  *NbParams=0;

  if (PbId && PbId->objid == NULL_OBJID)
  {
    IGRdouble     dS1a, dS1b, dS2a, dS2b;   /*   may need these    */

    strcpy (szSearch, VR_RWAY_DIR);
    strcat (szSearch, ":");

    /* -- RETURN HARDCODED SEARCH -- */
 
    status =
    om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecNam, szAABBCC, NULL, &nShape,
                            &dS1a, &dS1b, &dS2a, &dS2b, md_env),
         targetid = my_id);

    /* -- build selection name -- */

    strcat ( szSearch, szSpecNam);
    strcat ( szSearch, "-");

    sprintf(Value, "%d", nShape);
    strcat (szSearch, Value );

    if (szAABBCC[0] != '\0')
    {
      strcat ( szSearch, "-");
      strcat ( szSearch, szAABBCC);
    }

    if (dS1a > 0.0)
    {
      sprintf( Value, "%.3lf",dS1a);
      strcat ( szSearch, "-");
      strcat (szSearch, Value );
    }

    if (dS1b > 0.0)
    {
      sprintf( Value, "%.3lf",dS1b);
      strcat ( szSearch, "-");
      strcat (szSearch, Value );
    }

    if (dS2a > 0.0)
    {
      sprintf( Value, "%.3lf",dS2a);
      strcat ( szSearch, "-");
      strcat (szSearch, Value );
    }

    if (dS2b > 0.0)
    {
      sprintf( Value, "%.3lf",dS2b);
      strcat ( szSearch, "-");
      strcat (szSearch, Value );
    }
  }
  else
  {
    /*| Catalog occurrence */
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_CATAL_OCC_AN,
                                &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1)
    {
      strcat (szSearch, "-");
      strcat (szSearch, AttrRst.var.text_st.text_string );
    }
    else
    {
      /*| -- BUILD DYNAMIC SELECTION -- */
      /*| ------ List Collection attributes ----- */
      status =
      om$send( msg = message ACrg_collect.AClist_attribute
                              ( &retmsg, VR_MAX_ATTR, attributes, NbParams ),
          senderid = PbId->objid,
          targetid = PbId->objid,
          targetos = PbId->osnum) ;

      *NbParams -= 1;

      /* --- Get the values for each param and fill struct --- */
      for( i=0; i<*NbParams; i++ )
      {
        status =
        om$send ( msg = message ACncpx.ACgive_structure
                                ( &intmsg, &FootIndex,
                                   attributes[i].name, &AttrRst, md_env ),
             targetid = my_id);

        if( intmsg&1 )
        {
          strcpy( ParamList[i].sel.name, attributes[i].name );
          if(  attributes[i].desc.type == AC_ATTRIB_TEXT )
          {
            ParamList[i].range = 0;
            ParamList[i].type  = VR_RISDB_TEXT;
            strcpy( ParamList[i].sel.desc.value.att_txt,
                     AttrRst.var.text_st.text_string);

            strcat( szSearch, "-");
            strcat( szSearch, AttrRst.var.text_st.text_string);
            /*"ParamList[%d] = <%s> \n",i,ParamList[i].sel.desc.value.att_txt*/
          }
          else
          {
            if ( ((int)attributes[i].desc.value.att_exp)&1 )
              ParamList[i].range = 1;
            else
              ParamList[i].range = 0;

            ParamList[i].type = attributes[i].desc.value.att_exp
                                         - ParamList[i].range;
            ParamList[i].sel.desc.value.att_exp = AttrRst.var.root_pm_st.value;

            /* -------------------------------------------------
             * TR179900392 Use ris routine to do this 
             * sprintf( Value, "%g", AttrRst.var.root_pm_st.value);
             *"ParamList[%d] = <%f> \n",i,ParamList[i].sel.desc.value.att_exp 
             */
	    VdsRisSqlDblToStr(AttrRst.var.root_pm_st.value,Value);

            strcat( szSearch, "-");
            strcat( szSearch, Value);
          }
        }
        else
        {
          *msg = VR_MISSING_IN_SEARCH;
          return status;
        }
      }
    }
  }/* end build dyn selection */

  return ( OM_S_SUCCESS );

}/* end VRGetSearch */

/***********************************************************************/

method VRGetSpecComp (IGRlong       *msg;
                      IGRint         NbParams ;
               struct VRSelectAttr  *ParamList;
               struct GRid          *CacheId;
               struct GRmd_env      *md_env )
{
  IGRlong     retmsg;
  IGRint      status;
  IGRchar     szSpecName[20], szAABBCC[20], szFamilyName[31];
  IGRshort    nShape, nTopo, nType;
  IGRdouble   dWidth1, dDepth1, dWidth2, dDepth2;

  *msg = MSSUCC;

  /* -- Initialize search parameters -- */

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, szAABBCC, NULL, &nShape,
                            &dWidth1, &dDepth1, &dWidth2, &dDepth2, md_env),
       targetid = my_id);

  /* -- acces pdm/pdu to get the component's attributes -- */

  CacheId->osnum = md_env->md_id.osnum;

  NbParams= 0;
  szFamilyName[0] = 0;

/*A ACCESSING HVAC DATABASE  --- replaced
  status = 
  VRaccess_hvac_db( &retmsg, "SERV1", szAABBCC, nShape, szFamilyName,
                    &nTopo, &nType, CacheId, ParamList,
                     ( IGRshort *) &NbParams, NULL );
*/

  status = 
  VRaccess_rway_db ( &retmsg, szSpecName, szAABBCC, dWidth1, dDepth1,
                      dWidth2, dDepth2, nShape, szFamilyName,
                     &nTopo, &nType, CacheId, ParamList, 
                      ( IGRshort *) &NbParams, NULL);

  if ( !( status & 1 ))
  {
    /*| ERROR -> HVAC SPEC ACCESS FAILED */
    *msg=MSFAIL;
    return ( status );
  }

  /*"macro_name    = %s \n", szFamilyName*/
  /*"topology      = %d \n", nTopo*/
  /*"type          = %d \n", nType*/

return OM_S_SUCCESS;

}/* end VRGetSpecComp */


/***********************************************************************/

method VRRetrieveTeeCode (IGRlong   *msg ;
                          IGRdouble  dAngle;
                          IGRchar   *szAABBCC;
                   struct GRmd_env  *md_env)
{
  IGRint     status;
  IGRchar    szSpecName[20];
  IGRdouble  dS1a, dS1b, dS2a, dS2b;   /*   may need these    */
  IGRshort   nShape;                   /*   may need these    */

  /* -- Initialize search parameters -- */

  /* Mat Class */
  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, NULL, NULL, &nShape,
                            &dS1a, &dS1b, &dS2a, &dS2b, md_env),
       targetid = my_id);

  /* -- select branch table -- */

  szAABBCC[0]= 0;

  /* @@@@ SIZES    */
  status=
  VRget_branch ( msg, (IGRshort) VR_RWAY, szSpecName,
                  0.0, 0.0, dAngle,0,szAABBCC, NULL );

  if (!(status &1))
  {
     printf(" -----> %s branch table access failed : angle     = %f \n",
                              szSpecName, dAngle);
    *msg = MSFAIL;
  }
  else
  {
     /*" AABBCC code : %s \n", szAABBCC */
    *msg = MSSUCC;
  }

  return ( OM_S_SUCCESS );

} /* end VRRetrieveTeeCode */


/***********************************************************************/

method VRRetrieveElbowCode (IGRlong       *msg ;
                            IGRdouble      dAngle;
                            IGRshort      *nRotationType;
                            IGRchar       *szAABBCC;
                     struct GRmd_env      *md_env)
{
  IGRint     status;
  IGRchar    szSpecName[10];
  IGRdouble   dS1a, dS1b, dS2a, dS2b;   /*   may need these    */
  IGRshort    nShape;                   /*   may need these    */

  /* -- Initialize search parameters -- */

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, NULL, NULL, &nShape,
                            &dS1a, &dS1b, &dS2a, &dS2b, md_env),
       targetid = my_id);

  /* -- access bend deflection table -- */
  szAABBCC[0]= 0;

  /* @@@@ SIZES    */
  status =
  VRget_bend (msg, (IGRshort) VR_RWAY, szSpecName, dAngle,
                  0 , szAABBCC, NULL );

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

method VRRetrieveGeneralCode (IGRlong     *msg ;
                              IGRshort     nItemNum;
                              IGRchar     *szAABBCC;
                       struct GRmd_env    *md_env)
{
  IGRlong   retmsg;
  IGRint    status;

  *msg = MSSUCC;

  /* -- Access commodity item table -- */

  szAABBCC[0]= 0;

  status =
  VRcint_rway ( &retmsg, nItemNum, szAABBCC );

  return ( OM_S_SUCCESS );

} /* end VRRetrieveGeneralCode */

/***********************************************************************/

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

  *msg = MSSUCC;

  if (nOption) *nOption  = 0;

  /* Class */
  if (szSpecNam)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                           ( &intmsg, &FootIndex, VR_N_CLASS_AN,
                              &AttrRst, md_env ),
         targetid = my_id);

    if ( intmsg&1 ) strcpy (szSpecNam, AttrRst.var.text_st.text_string );
    else            strcpy (szSpecNam, "VEND1");
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
  }

  /* First sizes  */
  if (dSiz1a)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_WIDTH1_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *dSiz1a  = AttrRst.var.root_pm_st.value;
    else          *dSiz1a  = 0.0;
  }

  if (dSiz1b)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_DEPTH1_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *dSiz1b  = AttrRst.var.root_pm_st.value;
    else          *dSiz1b  = 0.0;
  }

  /* Second sizes  */
  if (dSiz2a)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_WIDTH2_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *dSiz2a  = AttrRst.var.root_pm_st.value;
    else          *dSiz2a  = 0.0;
  }

  if (dSiz2b)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_DEPTH2_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *dSiz2b  = AttrRst.var.root_pm_st.value;
    else          *dSiz2b  = 0.0;
  }

  /* Shape */
  if (nShape)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                              ( &intmsg, &FootIndex, VR_N_SHAPE_IN,
                                 &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg&1) *nShape = (IGRshort)AttrRst.var.root_pm_st.value;
    else          *nShape = 0;
  }

  return (OM_S_SUCCESS);
}

end implementation VRRway;

