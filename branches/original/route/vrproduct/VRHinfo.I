/* $Id: VRHinfo.I,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  ROUTE / VRHinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRHinfo.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *  Initial import to CVS
 *
# Revision 1.3  1999/04/30  21:52:10  pinnacle
# Truncate problem in key
#
# Revision 1.2  1998/05/22  19:12:40  pinnacle
# TR179801102
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1997/10/09  16:49:06  pinnacle
# Replaced: vrproduct/VRHinfo.I for:  by onayragu for route
#
# Revision 1.2  1997/08/15  20:13:58  pinnacle
# Replaced: vrproduct for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  19:36:58  pinnacle
# Replaced: vrproduct/VRHinfo.I for:  by r240_int for route240
#
 *
 * History:
 * 10/26/94  Lori  CR#179422038 Added spec to search string
 *                 in VRGetSearch for HVAC
 * 01/17/96  tlb   Add prototypes
 * 10/09/97  Onay  TR179700927 by increasing catalogs var length.
 * 05/22/98  ah    TR179801102 VRProdKey sometimes returns garbage
 * 04/30/99  ah    TR179900392 Use ris routine to build key
 *************************************************************************/

class implementation VRHvac;

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
method VRGetProduct (IGRshort  *pnProduct;
                     IGRchar   *pc3Product )
{
  /* return product's internal number (vrdef.h) */
  if (pnProduct)  *pnProduct = VR_HVAC;

  /* return product's prefixe (2 letters) */
  if (pc3Product)
  {
    pc3Product[0] = 'H';
    pc3Product[1] = 'v';
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
  IGRlong     retmsg;
  IGRint      status;
  IGRint      i, FootIndex=-1;
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

  *szAABBCC  = 0;
  *szSpecNam = 0;
  nShape = 0;
  
  if (PbId && PbId->objid == NULL_OBJID)
  {
    IGRdouble     dS1a, dS1b, dS2a, dS2b;   /*   may need these    */

    strcpy (szSearch, VR_HVAC_DIR);
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
  }
  else
  {
    /*| Catalog occurrence */
    status = 
    om$send ( msg = message ACncpx.ACgive_structure
                            ( (IGRint *)&retmsg, &FootIndex, VR_N_CATAL_OCC_AN,
                                &AttrRst, md_env ),
         targetid = my_id);

    if (retmsg&1)
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
                                ( (IGRint *)&retmsg, &FootIndex, 
                                   attributes[i].name, &AttrRst, md_env ),
             targetid = my_id);

        if( retmsg&1 )
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

method VRGetSpecComp (IGRlong      *msg;
                      IGRint        NbParams ;
               struct VRSelectAttr *ParamList;
               struct GRid         *CacheId;
               struct GRmd_env     *md_env )
{
  IGRlong     retmsg;
  IGRint      status, nb_attr;
  IGRchar     szSpecName[20];
  IGRchar     szAABBCC[20], szFamilyName[31];
  IGRchar     Error[300];
  IGRshort    nShape, nTopo, nType;
  IGRint      FootIndex=-1;
  IGRchar     cat_name[50], cat_occ[50];
  IGRdouble   dS1a, dS1b, dS2a, dS2b;   /*   may need these    */

  struct ACrg_coll   attributes[VR_MAX_ATTR];
  struct ret_struct  AttrRst;

  *msg = MSSUCC;

  traceFlag = VDdbgGetTraceFlag(150);
  if (traceFlag) {
    printf(">>> VRHvac.VRGetSpecComp \n");
  }
  
  Error[0] = '\0';

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, szAABBCC, NULL, &nShape,
                            &dS1a, &dS1b, &dS2a, &dS2b, md_env),
       targetid = my_id);

  if (traceFlag) {
    printf("szSpecName = '%s', szAABBCC = '%s'\n",szSpecName,szAABBCC);
    //if (CacheId->objid == NULL_OBJID) printf("No Cache Object\n");
  }
  
  /* --- Initialize Family name to its value  --- */
  if( CacheId->objid != NULL_OBJID )
  {
    cat_name[0]  = 0;
    cat_occ[0]   = 0;

    /*| -- Get Catalog Name -- */
    status = 
    om$send ( msg = message ACncpx.ACgive_structure
                          ( (IGRint *)&retmsg, &FootIndex, VR_N_CATAL_NAME_AN,
                             &AttrRst, md_env ),
         senderid = NULL_OBJID,
         targetid = CacheId->objid,
         targetos = CacheId->osnum);

    if (retmsg&1)  
      strcpy( cat_name, AttrRst.var.text_st.text_string );

    /* -- Get Catalog Occurrence -- */
    status = 
    om$send ( msg = message ACncpx.ACgive_structure
                            ( (IGRint *)&retmsg, &FootIndex, VR_N_CATAL_OCC_AN,
                              &AttrRst, md_env ),
         targetid = my_id);

    if (retmsg&1)  
      strcpy( cat_occ, AttrRst.var.text_st.text_string );

    if (traceFlag) {
      printf("Cat Name = '%s',Cat Occurence = '%s'\n",cat_name,cat_occ);
    }
    
    if( cat_name[0] != '\0' && cat_occ[0] != '\0' )
    {
      struct VRSelectAttr  ParamList[100];

      NbParams  = 0;
      szFamilyName[0] = 0;
      CacheId->osnum = md_env->md_id.osnum;
      
      /*| --- Acces DB with catalog occurrence --- */
      status = 
      VRdbaccess_hvac ( &retmsg, szAABBCC, cat_name, cat_occ, 
                        ParamList, ( IGRshort *) &NbParams, 
                        szFamilyName, &nTopo, 
                        &nType, CacheId, NULL );
      if (traceFlag) {
	printf("Returning success after calling VRdbaccess_hvac\n");
	printf("### VRHvac.VRGetSpecComp \n");
      }
      return OM_S_SUCCESS;
    }

    /*| ------ Fill structure for next call ----- */
    status =
    om$send( msg = message ACrg_collect.AClist_attribute
                              ( &retmsg, VR_MAX_ATTR, attributes, &nb_attr ),
        senderid = CacheId->objid,
        targetid = CacheId->objid,
        targetos = CacheId->osnum) ;

    /*| ----- Initialize Familly name ----- */
    strcpy( szFamilyName, attributes[nb_attr-1].desc.value.att_txt);
    if (traceFlag) {
      printf("szFamilyName = '%s'\n",szFamilyName);
    }
  }
  else
  {
    /*| Non Inline Component case */
    Error[0] = 0;
    szFamilyName[0] = 0;

    CacheId->objid = NULL_OBJID;
    CacheId->osnum = md_env->md_id.osnum;
  }

  /*| ------- acces pdm/pdu to get the component's attributes ------- */

  /* "SpecName = %s\n", szSpecName */
  /* "AABBCC code = %s \n", szAABBCC */
  /* "Shape = %d \n", nShape */

  status = 
  VRaccess_hvac_db( &retmsg, szSpecName, szAABBCC, nShape, szFamilyName,
                    &nTopo, &nType, CacheId, ParamList,
                    ( IGRshort *) &NbParams, Error );

  if ( !( status & 1 ) || Error[0])
  {
    if (traceFlag) {
      printf("### VRHvac.VRGetSpecComp VRaccess_hvac_db Failed, '%s'\n",Error);
    }
    /*| ERROR -> HVAC SPEC ACCESS FAILED */
    if( Error[0] )  *msg = retmsg;
    else            *msg = MSFAIL;
    return ( status );
  }
  if (traceFlag) {
    printf("### VRHvac.VRGetSpecComp Worked.\n");
  }
  
  return OM_S_SUCCESS;

}/* end VRGetSpecComp */


/***********************************************************************/

method VRRetrieveTeeCode (IGRlong    *msg ;
                          IGRdouble   dAngle;
                          IGRchar    *szAABBCC;
                   struct GRmd_env   *md_env)
{
  IGRint      status;
  IGRchar     szSpecName[10];
  IGRdouble   dS1a, dS1b, dS2a, dS2b;   /*   may need these    */
  IGRshort    nShape;                   /*   may need these    */

  /* -- Initialize search parameters -- */

  status =
  om$send ( msg = message VRProduct.VRProdKey
                           (msg, szSpecName, NULL, NULL, &nShape,
                            &dS1a, &dS1b, &dS2a, &dS2b, md_env),
       targetid = my_id);

  /* -- select branch table -- */

  szAABBCC[0]= 0;

  status=
  VRget_branch (msg, (IGRshort)VR_HVAC, szSpecName,
                      0.0, 0.0, dAngle, 0,szAABBCC, NULL );
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

method VRRetrieveElbowCode (IGRlong     *msg ;
                            IGRdouble    dAngle;
                            IGRshort    *nRotationType;
                            IGRchar     *szAABBCC;
                     struct GRmd_env    *md_env)
{
  IGRint      status;
  IGRchar     szSpecName[20];
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

  status =

/* Wait for Twist implementation
  VRget_bend (msg, (IGRshort) VR_HVAC, szSpecName,
       dAngle, *nRotationType , szAABBCC, NULL );
*/

  VRget_bend (msg, (IGRshort) VR_HVAC, szSpecName,
                     dAngle, 0 , szAABBCC, NULL );
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
  VRcint_hvac ( &retmsg, nItemNum, szAABBCC );

  /*" AABBCC code : %s \n", szAABBCC */

  return ( OM_S_SUCCESS );
} /* end VRRetrieveGeneralCode */

/***********************************************************************/
/* TR179801102 If a component is really messed up, random data can
 * be returned, fix by clearing the return structure first
 * The error checking does not catch this problem.
 * Tried checking status but does not help.
 */

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
    memset(&AttrRst,0,sizeof(AttrRst));
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                           ( &intmsg, &FootIndex, VR_N_CLASS_AN,
                              &AttrRst, md_env ),
         targetid = my_id);

    if (intmsg & 1) strcpy (szSpecNam, AttrRst.var.text_st.text_string );
    else                       strcpy (szSpecNam, "SERV1");
  }

  /* AABBCC code */
  if (szAABBCC)
  {
    memset(&AttrRst,0,sizeof(AttrRst));
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
    memset(&AttrRst,0,sizeof(AttrRst));
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
    memset(&AttrRst,0,sizeof(AttrRst));
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
    memset(&AttrRst,0,sizeof(AttrRst));
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
    memset(&AttrRst,0,sizeof(AttrRst));
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
    memset(&AttrRst,0,sizeof(AttrRst));
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

end implementation VRHvac;








