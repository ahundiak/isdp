
/* $Id: VCBover.I,v 1.3 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCBover.I
 *
 * Description:
 *   This file contains the implementation for the backshell.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCBover.I,v $
 *        Revision 1.3  2002/05/08 15:48:24  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:10:40  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.3  1999/01/28  20:08:06  pinnacle
# Replaced: vcguide/VCBover.I for:  by lawaddel for route
#
# Revision 1.2  1998/10/08  16:47:08  pinnacle
# Replaced: vcguide/VCBover.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/02/24  23:08:10  pinnacle
# Replaced: vcguide/VCBover.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/10/24  12:44:26  pinnacle
# Replaced: vcguide/VCBover.I for:  by apazhani for cabling
#
# Revision 1.1  1997/07/14  22:26:12  pinnacle
# Created: vcguide/VCBover.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *        10/24/97        Alwin      Implemented the method ACgive_structure
 *                                   and ACcheckin_candidate method for posting
 *                                   problem.
 *        10/08/98        Alwin      Did some cleaning up work. Corrected
 *                                   "term_tag" portion, which was failing in
 *                                   obtaining the correct value. TR179801987
 *        12/31/98        law        CR179802489-added numerous fields.
 *
 *************************************************************************/

class implementation VCBksh;

#include <stdlib.h>
#include "OMmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "parametric.h"

#include "VCchansel.h"
#include "VCmacros.h"
#include "VDmem.h"
#include "vc_define.h"
#include "vrdbgmacros.h"
#include  "vds.h"
#include  "VDmsg.h"
#include  "VDsa.h"


extern  GRclassid  OPP_VCRoot_class_id;


/*****************************************************************************/

method VCTransMat (    IGRlong     *msg;
                       IGRshort     NbCpt;
                       IGRdouble   *dRefMatrix;
                struct GRmd_env    *md_env)
{
  IGRint             status;
  IGRshort           nOff;
  IGRdouble          dMat1[16];

  MAidmx (msg, dMat1);

  nOff = om$dimension_of (varray = me->dVCOffVal);

  /*    set the backshell translation matrix    */

  status =
  VC_to_world (dMat1, me->nVCType, nOff, me->dVCOffVal, dRefMatrix);

  return ( OM_S_SUCCESS );
}

method VCBaseMat (IGRlong     *msg;
                  IGRshort     NbCpt;
                  IGRdouble   *dRefMatrix;
           struct GRmd_env    *md_env)
{
  IGRlong            retmsg;
  IGRint             status;

  struct GRid        RefId;

  /*A  get parent from the channel             */

  status =
  om$send(msg = message VCRoot.VCParent
                         (&retmsg, (IGRshort) 0, &RefId, md_env),
     targetid = my_id);

  if (RefId.objid != NULL_OBJID)
  {
    status =
    om$send (msg = message VCRoot.VCGetMatrix (msg, NbCpt, dRefMatrix, md_env),
        targetid = RefId.objid,
        targetos = RefId.osnum);
  }

  return (status);
}

method  VCGetNumberOfCpts (IGRlong     *msg ;
                           IGRshort    *NbCpts)
{
  *msg = MSSUCC;

  *NbCpts = 0;       /*    no connectivity        */

  return (OM_S_SUCCESS);
}

method VCGetEquipId (IGRlong  *msg;
              struct GRid     *EquipId)

{
  IGRint      status;

  /*    send to parent (terminal)    */

  status =
  om$send (msg = message VCMac.VCGetEquipId (msg, EquipId),
  p_chanselect = &ND_father,
  from         = me->nVCAttr,
  to           = me->nVCAttr);

  return (status);
}


method VCGetModel ( IGRlong    *msg;
             struct GRid       *ModelId)
{

  IGRint      status;
  IGRlong     retmsg;
  IGRchar     szCode[VC_MAX_CCODE];

  *msg = MSSUCC;

  ModelId->objid = NULL_OBJID;

  status =
  om$send (msg = message VCRoot.VCGetCode (szCode),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szCode)))
  {
    vc$bksh_old (code = szCode, GRid = ModelId);
  }

  return ( OM_S_SUCCESS );
}/* end VCGetModel */

method VCSetTagNo (IGRchar *szTagNo)

{
   /*    force an empty tag number    */
  IGRint      status;

  status = om$vla_set_dimension (varray = me->szVCTagNo,
                                 size   = 0);

  return ( OM_S_SUCCESS );

}/* end VCSetTagNo */

method GRgetobjinfo(IGRlong     *msg;
             struct GRobj_info  *info)

{
  IGRchar      string[50];
  IGRchar      szRep[8];
  IGRint       status;

  *msg = MSSUCC;

  status =
  om$send ( msg = message VCRoot.VCGetCode (string),
       targetid = my_id);

  strcat(string,"-");

  /* -- add NVrepresentation (4 characters) -- */

  status =
  om$send (msg = message VCRoot.VCGetRep (NULL, szRep),
      targetid = my_id);

  strcat (string, "(");
  strcat (string, szRep);
  strcat (string, ")");

  string[31] = '\0';

  strcpy ( info->type,string );

  return(OM_S_SUCCESS);

}/* end GRgetobjinfo */

/* Added by alwin for TR179701824 */
method ACgive_structure(int          *msg;
                        int          *direct_index;
                        char         *footname;
                 struct ret_struct   *p_rs;
                 struct GRmd_env     *md_env)
 
{
 
  IGRlong status=OM_S_SUCCESS;
 
  SetProc( Md ACgive_structure ); Begin

  *msg=MSSUCC;

  __DBGpr_str( "Footname ", footname );
  /* Modified for cr179802489 */
  if( !strcmp( footname, VC_N_BKTERMTAG_AN ) ||
      !strcmp( footname, VC_N_BKTERMCAT_AN ) ||
      !strcmp( footname, VC_N_BKTERMOBJ_IN ) ||
      !strcmp( footname, VC_N_BKTERMNAM_AN ) ||
      !strcmp( footname, VC_N_BKTERMREV_AN ) )
  {
    IGRint NbRoots, i;
    IGRchar TagNumber[VC_MAX_TAGNO];
    struct GRid *buffer, TerminalId;
 
    TagNumber[0] = '\0';
 
    __DBGpr_com( "Getting the Parent of the Backshell Component" );

    status = om$send ( msg = message NDnode.NDget_objects( ND_ROOT | ND_IN_BUF,
                                            NULL, 0, &buffer, 0,
                                            OM_K_MAXINT, &NbRoots ),
                             targetid = my_id);
    as$status();
 
    __DBGpr_int( "No of Parents ", NbRoots );

    TerminalId.objid = NULL_OBJID;
    for( i=0; i<NbRoots; i++ )
    {
       GRclassid Classid;

       status = om$get_classid(objid = buffer[i].objid,
                               osnum = buffer[i].osnum,
                           p_classid = &Classid);
       if ( status & 1 )
       {
         if( ( om$is_ancestry_valid (
                     subclassid   = Classid,
                     superclassid = OPP_VCRoot_class_id ) ) == OM_S_SUCCESS )
         {
            TerminalId.objid = buffer[i].objid;
            TerminalId.osnum = buffer[i].osnum;
            __DBGpr_obj( "BackShell's Parent(TerminalId) ", TerminalId );
            break;
         }
       }
    }
    /* Added for CR179802489 */
    if  ( ! strcmp( footname,VC_N_BKTERMOBJ_IN) )
    {
      p_rs->type = double_type;
      p_rs->var.root_pm_st.value = TerminalId.objid;
      return (1);
    }
    else if  ( ! strcmp( footname,VC_N_BKTERMCAT_AN) )
    {
    status = vdsa$GetStruct(objID = &TerminalId,
                            name = VDSA_KEY_SA_PDM_ASSY_CAT,rs = p_rs);
    return (status);
    }
    else if  ( ! strcmp( footname,VC_N_BKTERMNAM_AN) )
    {
    status = vdsa$GetStruct(objID = &TerminalId,
                            name = VDSA_KEY_SA_PDM_ASSY_NAM,rs = p_rs);
    return (status);
    }
    else if  ( ! strcmp( footname,VC_N_BKTERMREV_AN) )
    {
    status = vdsa$GetStruct(objID = &TerminalId,
                            name = VDSA_KEY_SA_PDM_ASSY_VER,rs = p_rs);
    return (status);
    }
    else if ( ! strcmp( footname,VC_N_BKTERMTAG_AN) )
    {     
    __DBGpr_com( "Getting the Tagnumber from the Terminal" ); 

    if( TerminalId.objid != NULL_OBJID )
    {
       IGRlong retmsg;
       struct VCGenInfo TermInstance;

       /***** commenting and calling VCGetTagNo ...Alwin for TR179801987
       status = 
       om$send ( msg = message VCRoot.VCGetInstance( &retmsg, &TermInstance ),
                                 targetid = TerminalId.objid,
                                 targetos = TerminalId.osnum );
       as$status();

       __DBGpr_str( " TagNumber 0", TermInstance.szTagno );
       strcpy( TagNumber, TermInstance.szTagno );
       *****/
       status =
       om$send ( msg = message VCRoot.VCGetTagNo( TagNumber ),
                                 targetid = TerminalId.objid,
                                 targetos = TerminalId.osnum );
       as$status();
       __DBGpr_str( " TagNumber 1", TagNumber );
    }

    p_rs->type = text_type; //set the type of attribute
    strcpy( p_rs->var.text_st.text_string, TagNumber );
    __DBGpr_str( "TagNumber ", p_rs->var.text_st.text_string );
   }
  }
  else
  {
    __DBGpr_com( "Call the VCRoot implementation of ACgive_structure" );

    status = om$send (msg = message VCRoot.ACgive_structure
                             (msg, direct_index, footname, p_rs, md_env),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
 
  }
 
  End
  return status;
}

method ACcheckin_candidate ( IGRint     CheckinType;
                             IGRint    *p_CheckinCandidate)
 
{
  IGRint     ii;
 
  SetProc( ACcheckin_candidate ); Begin

  ii = CheckinType;    /*  compiler warning    */
 
  __DBGpr_com( "Setting the p_CheckinCandidate to TRUE " );
  *p_CheckinCandidate = TRUE;
 
  __DBGpr_int( "Can I check this Object ", *p_CheckinCandidate );
 
  End
  return (OM_S_SUCCESS);
}
/* added by alwin for TR179701824 */


method VDgetObjDef(     long *msg ;
                        VDobjDef *myDef )
{

        myDef->info             = VD_I_ObjVCBksh ;
        myDef->type             = 0 ;

        *msg    = MSSUCC ;

        return (OM_S_SUCCESS)  ;
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

end implementation VCBksh;
