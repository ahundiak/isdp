
/* $Id: VCRxacover.I,v 1.2 2001/02/20 01:11:22 build Exp $ pinnacle */

/*************************************************************************
 * I/CABLE
 *
 * File:      vcroot / VCRxacover.I
 *
 * Description:
 *    VCRoot override of AC methods
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCRxacover.I,v $
 *      Revision 1.2  2001/02/20 01:11:22  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/02/08  19:11:36  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/04/12  21:32:54  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by kddinov for route
#
# Revision 1.3  1998/01/24  16:38:40  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by kddinov for route
#
# Revision 1.2  1998/01/15  17:17:42  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.7  1997/10/24  12:37:56  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by apazhani for cabling
#
# Revision 1.6  1997/07/29  14:47:20  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by hverstee for cabling
#
# Revision 1.5  1997/07/22  14:31:34  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:58:00  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:53:40  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  21:56:28  pinnacle
# Replaced: vcroot/VCRxacover.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:13:54  pinnacle
# Created: vcroot/VCRxacover.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR      DESCRIPTION
 *      06/10/96    hv          Initial
 *      10/24/97    Alwin       Modified the ACgive_structure, to add some
 *                              attributes like "eq_cino and eq_tag".
 *
 *	Jan-98	    KDD		Modified to translate VCTerm embedded in 
 *			    	VREquipment according to VC_N_PID_SCALE_DB
 *				attribute driven symbology (GRputsymb) is used.
 *
 *	4-98	    KDD		the above is done now in VCGetMatrix. 
 *      12/31/98    law         CR179802489-Added numerous values for posting
 *      02/04/99    law         CR179701619-Minor modifications for posting
 *************************************************************************/

class implementation VCRoot;

/*
#define vdsDEBUG 	1
*/

#include "vc_define.h"
#include "v_miscmacros.h"
#include "vderrmacros.h"
#include "vrdbgmacros.h"
#include "VDsa.h"

/***********************************************************************/
from   VCMac      import   VCGetEquipTag;
from   VCTerm     import   VCGetEquipId;
from   VRGeneric  import   ACgive_structure;

method ACreturn_foot(IGRlong     *msg;
                     char        *footname;     
              struct GRid        *foot_obj;
                     IGRshort    *mat_type;
                     IGRdouble   *matrix)
{
  IGRint  status,i;

  *msg = MSSUCC;

  status =
  om$send ( msg = message ACncpx.ACreturn_foot
                               ( msg, footname, foot_obj, mat_type, matrix),
           mode = OM_e_wrt_message,
       targetid = my_id );

  if ( !(*msg & OM_S_SUCCESS & status) )
  {

    for ( i=0; (i<me->nVCAttr) && !(status & *msg & OM_S_SUCCESS); i++ )
    {
      status=
      om$send ( msg = message NDmacro.ACreturn_foot
                                 ( msg, footname, foot_obj, mat_type, matrix),
       p_chanselect = &ND_father,
          from      = i,
            to      = i);
    /*" Collection %d : status = %d, msg = %d\n",i, status, *msg */

    }/* end loop on collections */

  }/* end send it back to collections templates */

  return (status);

}/* end ACreturn_foot */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              override     method    ACgive_structure                         
/*
/*  DESCRIPTION: An attribute belonging to the templates should be returned
/*    as if it were prt of the component.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ACgive_structure(int           *msg;
                        int           *direct_index;
                        char          *footname;
                 struct ret_struct    *p_rs;
                 struct GRmd_env      *md_env)

{
  IGRint       status;
  IGRint       i;
  IGRlong      retmsg;
  IGRshort     nIndex;

  SetProc( ACgive_structure ); Begin;

  *msg   = MSSUCC;
  nIndex = -1;
  status = OM_S_SUCCESS;

  /*   return known instance attributes    */

  __DBGpr_str( "Footname ", footname );

  if ( !(strcmp (footname, VC_N_COMP_CODE_AN)) )
  {
    p_rs->type= text_type;
    status =
    om$send ( msg = message VCRoot.VCGetCode(p_rs->var.text_st.text_string),
         targetid = my_id );

  }
  else
  if ( !(strcmp (footname, VC_N_TAG_NUMBER_AN)) )
  {
    p_rs->type= text_type;
    status =
    om$send ( msg = message VCRoot.VCGetTagNo(p_rs->var.text_st.text_string),
         targetid = my_id );
  }
  else
  if ( !(strcmp (footname, VC_N_NO_MTO_AN )) )
  {
    p_rs->type= text_type;

    status =
    om$send (msg = message VCRoot.VCGetMtoFlag
                              (NULL, p_rs->var.text_st.text_string),
         targetid = my_id );

  }   
  else if ( !(strcmp (footname, VC_N_ERR_FLAG_AN)) )
  {
    p_rs->type= text_type;
    if(me->nVCStat & VC_ERROR) strcpy (p_rs->var.text_st.text_string, "Y");
    else                       strcpy (p_rs->var.text_st.text_string, "N");
  }
  else
  if ( !(strcmp (footname, VC_N_REF_CS)) )
  {
    p_rs->type= ref_generic;

    status =
    om$send ( msg = message VCRoot.VCGetMatrix
                            ( &retmsg, nIndex, p_rs->var.ref_st.t, md_env ),
         targetid = my_id);
    as$status ();

    /*    correct for PID_scale   */
    if ( bVC_IS_PID(me->xform_chan))
    {
      struct ret_struct  ParamAttr;
      IGRint             FootIndex = -1;

      /* -- Get scale factor -- */

      status=
      om$send ( msg   = message ACncpx.ACgive_structure (msg, 
			   &FootIndex, VC_N_PID_SCALE_DB, &ParamAttr, md_env),
            targetid= my_id);
      if ( ! ( status & (*msg) & OM_S_SUCCESS ) )
      { /*   set scale to one if not found   */
        *msg = MSSUCC;
        status = OM_S_SUCCESS;
        ParamAttr.var.root_pm_st.value = 1.0;
      }

      /* -- Scale matrix (x,y,z) -- */
      for (i=0; i<3; i++)
      {
        p_rs->var.ref_st.t[i]   *= ParamAttr.var.root_pm_st.value;
        p_rs->var.ref_st.t[i+4] *= ParamAttr.var.root_pm_st.value;
        p_rs->var.ref_st.t[i+8] *= ParamAttr.var.root_pm_st.value;
      }

/*---------------------------- 
# 4-98 KDD VCTerm.VCGetMatrix does this for us. 
# 1-98 KDD scale the offset also, TR179800088.
*
* Note: 
* VCGetMatrix includes once the original translation (me->Attr.Term.dOffVal).
* Therefore we have to scale with (scale - 1.0).
*
* Note 2: Due to bad design we must allocate memory for the points.
*
* Algorithm:
* Check with VCGetMatrix for VCTerm to see what we need:
* 1. to construct a matrix for the (scale - 1.0) translation.
* 2. To transform this one to the world Coordinate system.

      { 
	struct VCGenInfo	Instance;
	IGRdouble		scale, DummyPoints[16];
	char			classname[256];
	IGRmatrix		IdentityMat, dMat2;

      om$get_classname( objid = my_id, classname = classname); 
      if ( 1 & om$is_ancestry_valid( subclassname   = classname,
                                     superclassname = "VCTerm") ) {

	 MAidmx (msg, IdentityMat); 

         scale  = (ParamAttr.var.root_pm_st.value - 1.0) ;
	
         Instance.Attr.Term.dOffVal = DummyPoints;

         status= om$send( msg    = message VCRoot.VCGetInstance
                                    ( &retmsg, &Instance),
                     targetid = my_id);

	 if ( Instance.Attr.Term.nOff == 16 ) { 
	    Instance.Attr.Term.dOffVal[3]  *= scale;
	    Instance.Attr.Term.dOffVal[7]  *= scale;
	    Instance.Attr.Term.dOffVal[11] *= scale;
	 }
	 else if ( Instance.Attr.Term.nOff == 3 ) {
	    Instance.Attr.Term.dOffVal[0]  *= scale;
	    Instance.Attr.Term.dOffVal[1]  *= scale;
	    Instance.Attr.Term.dOffVal[2]  *= scale;
	 }

  	 status = VC_to_world( 	IdentityMat, 
				Instance.nType, 
				Instance.Attr.Term.nOff, 
				Instance.Attr.Term.dOffVal, 
				dMat2);

         p_rs->var.ref_st.t[3]   += dMat2[3];
         p_rs->var.ref_st.t[7]   += dMat2[7];
         p_rs->var.ref_st.t[11]  += dMat2[11];

      }
      }
----------------------------*/

    }/* end scale referencial */
  }/* end return referential */
  else
  if ( !(strcmp (footname, VC_N_NB_CONNPT_IN)) )
  {
    IGRshort  NbCpts;

    p_rs->type= double_type;

    /*C Get number of connection points */
    status =
    om$send (msg = message VCRoot.VCGetNumberOfCpts (&retmsg, &NbCpts),
        targetid = my_id );

    p_rs->var.root_pm_st.value = NbCpts;
  }
  else
  if ( !(strcmp (footname, VC_N_LOC_PT)) )
  {
    IGRshort     nCP;

    nCP = 0;

    p_rs->type= point_generic;
    status =
    om$send (msg = message VCRoot.VCGetCptCoord (&retmsg, nCP,
                                        (IGRdouble *)p_rs->var.point_st.pt,
                                         md_env) ,
        targetid = my_id );
  }
/* added  by alwin for TR179701824 Beginning ... */
  else 
  if ( !(strcmp (footname, "eq_tag"))  )
  {
    IGRchar eq_tag[VC_MAX_TAGNO];
 
    status = om$send ( msg = message VCMac.VCGetEquipTag( &retmsg,
                                                          eq_tag, md_env),
                          targetid = my_id );
 
    p_rs->type = text_type;
    strcpy( p_rs->var.text_st.text_string, eq_tag );

    __DBGpr_str( "Equipment Tag ", p_rs->var.text_st.text_string );
  }
  else
  if ( !(strcmp (footname, "eq_cino"))  )
  {
    struct GRid EquipId;

    /* The value for the attribute "eq_cino" should be obtained from the Parent
    Equipment. The value for the attribute "cino" from the Parent Equipment 
    is set to the "eq_cino". This as stated by Clark. for TR179701824 Alwin */

    status = om$send ( msg = message VCTerm.VCGetEquipId( &retmsg,
                                                          &EquipId ) ,
                          targetid = my_id );
 
    __DBGpr_obj( "Equipment Id ", EquipId );

    p_rs->type = text_type;
    p_rs->var.text_st.text_string[0] = '\0';

    if( EquipId.objid != NULL_OBJID )
    {   
       status = om$send ( msg = message VRGeneric.ACgive_structure( msg,
                                         direct_index, "cino", p_rs, md_env ),
                          targetid = EquipId.objid,
                          targetos = EquipId.osnum );
 
       if(  !status & *msg & 1 )
          p_rs->var.text_st.text_string[0] = '\0';

       __DBGpr_str( "Equipments Cino ", p_rs->var.text_st.text_string );
    }
  }
  /* Added for CR179802489 */
  else if (( ! strcmp(footname,VC_N_GENEQ_ID_IN)) ||
           ( ! strcmp(footname,VC_N_GENEQ_CAT_AN)) ||
           ( ! strcmp(footname,VC_N_GENEQ_NAM_AN)) ||
           ( ! strcmp(footname,VC_N_GENEQ_REV_AN)) )
  {
    struct GRid EquipId;
    status = om$send ( msg = message VCTerm.VCGetEquipId( &retmsg,
                                                          &EquipId ) ,
                          targetid = my_id );

    __DBGpr_obj( "Equipment Id ", EquipId );
    if( ! strcmp(footname,VC_N_GENEQ_ID_IN) )
    {
      /* CR179701619,  a -1 value resulted in trash */
      IGRint tempobj;
      tempobj = EquipId.objid;
      p_rs->type = double_type;
      p_rs->var.root_pm_st.value = tempobj;
    }

    else if (! strcmp(footname,VC_N_GENEQ_CAT_AN) )
    {
    status = vdsa$GetStruct(objID = &EquipId,
                            name = VDSA_KEY_SA_PDM_ASSY_CAT,rs = p_rs);
    }
    else if (! strcmp(footname,VC_N_GENEQ_NAM_AN) )
    {
    status = vdsa$GetStruct(objID = &EquipId,
                            name = VDSA_KEY_SA_PDM_ASSY_NAM,rs = p_rs);
    }
    else if (! strcmp(footname,VC_N_GENEQ_REV_AN) )
    {
    status = vdsa$GetStruct(objID = &EquipId,
                            name = VDSA_KEY_SA_PDM_ASSY_VER,rs = p_rs);
    }
  }
/* added  by alwin for TR179701824  .....Ending */
  else
  {
    IGRshort    nInd, nMap;

    nInd = nMap = -1;

    /*A If not found in the "known feet" :
    Redirect the message to the collections templates */

    *msg = MSFAIL;

    /*| Try in ATTRIBUTES collections */
    for ( i=(me->nVCAttr -1); i>= 0; i--)
    {
      status=
      om$send (msg = message ACncpx.ACgive_structure 
                          (msg, direct_index, footname, p_rs, md_env),
      p_chanselect = &ND_father,
         from      = i,
           to      = i);

      if (*msg & status & OM_S_SUCCESS) return (status);
    }

    /*    not a regular dynamic attribute, try the static (DB) set   */

    status =
    om$send (msg = message VCDB.VCGpAttr (&retmsg, nInd, nMap, footname, p_rs),
        targetid = my_id);

    *msg = retmsg;

    if (retmsg & status & OM_S_SUCCESS) return (status);

    /*    not there either, revert to VDSroot     */

    status =
    om$send (msg = message VDSroot.ACgive_structure
                               (msg, direct_index, footname, p_rs, md_env),
            mode = OM_e_wrt_message,
        targetid = my_id);

  }

  End;
  return ( status );

}/* end ACgive_structure */



method ACgive_db_structure(int           *msg;
                           int           *direct_index;
                           char          *footname;
                    struct ret_struct    *p_rs;
                    struct GRmd_env      *md_env)

{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nIndex;
  IGRshort     nMap;

  nIndex = -1;
  nMap   = -1;

  /*A Try in dynamic attributes */

  status=
  om$send (msg = message ACncpx.ACgive_structure 
                               (msg, direct_index, footname, p_rs, md_env),
      targetid = my_id);

  /*C Dynamic attribute found */
  if ( (status & *msg & OM_S_SUCCESS) ) return status;

  /*    try DB if not yet found      */

  status =
  om$send (msg = message VCDB.VCGpAttr
                         (&retmsg, nIndex, nMap, footname, p_rs),
      targetid = my_id);

  *msg = retmsg;

  return (status);
}/* end ACgive_db_structure */


end implementation VCRoot;
