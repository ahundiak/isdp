
/* $Id: VCTmatrix.I,v 1.3 2001/02/20 01:11:40 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTmatrix.I
 *
 * Description:
 *
 *      Method to retrieve terminal's matrix
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTmatrix.I,v $
 *      Revision 1.3  2001/02/20 01:11:40  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/11 22:19:54  anand
 *      SP merge
 *
# Revision 1.1  2000/09/08  21:24:24  pinnacle
# Created: route/vcterm/VCTmatrix.I by aharihar for Service Pack
#
# Revision 1.4  1999/07/22  20:42:54  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by lawaddel for route
#
# Revision 1.2  1998/07/22  07:03:16  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1998/04/26  20:30:46  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by kddinov for route
#
# Revision 1.5  1998/04/20  04:20:30  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by kddinov for route
#
# Revision 1.4  1998/04/13  04:24:30  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by kddinov for route
#
# Revision 1.3  1998/04/12  21:17:10  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by kddinov for route
#
# Revision 1.2  1997/11/30  16:09:56  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by r250_int for route
#
# Revision 1.15  1997/11/24  18:12:02  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by apazhani for cabling
#
# Revision 1.14  1997/05/22  15:23:30  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.13  1997/05/19  13:51:06  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.12  1997/05/12  16:59:46  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.11  1997/05/10  14:36:44  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.10  1997/05/02  20:30:10  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.9  1997/04/28  22:04:06  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.8  1997/03/12  16:39:58  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.7  1997/01/23  23:38:24  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/20  20:39:24  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/09  18:12:34  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/03  21:33:06  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/03  21:27:52  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/30  15:22:20  pinnacle
# Replaced: vcterm/VCTmatrix.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:29:20  pinnacle
# Created: vcterm/VCTmatrix.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 * 	4/98	    KDD		Override VCGetMatrix method to handle offset
 *				scale of PID embedded terminals.
 *	4-98	    KDD		Override GRget_matrix. to handle EMS moves. 
 *      7-98        Alwin       Modified for TR179801132, as the Center Pt of
 *                              is getting scaled, whereas it should be done
 *                              only Embedded Terminals.
 *	8 Sep 2k    Anand	TR 179901869
 *
 *************************************************************************/

class implementation VCTerm;

/*
#define MY_DEBUG	1
#define vdsDEBUG	1
*/

#include "parametric.h"
#include "vc_param.h"
#include "VCproto.h"
#include "vrdbgmacros.h"

from   VRGeneric import      VRGetMatrix;
from   GRgencs   import      GRgetmatrix;

extern GRclassid   OPP_VREquipment_class_id;
extern GRclassid   OPP_VDequipment_class_id;



method VCTransMat (    IGRlong     *msg;
                       IGRshort     NbCpt;
                       IGRdouble   *dRefMatrix;
                struct GRmd_env    *md_env)
{
  IGRlong            retmsg;
  IGRint             status, i;
  IGRshort           nOff;
  IGRdouble          dMat1[16],
                     dMat2[16];

  IGRmatrix	     TermMatrix;

  SetProc(  VCTerm_VCTransMat ); Begin

  MAidmx (&retmsg, dMat1);

  nOff = om$dimension_of (varray = me->dVCOffVal);

/* 4-98 KDD . Use temporary matrix. */

  for ( i = 0; i < nOff; i++ ) TermMatrix[ i ] = me->dVCOffVal[ i ] ;

__DBGpr_mat("me->dVCOffVal", TermMatrix); 

  status = VC_to_world (dMat1, me->nVCType, nOff, TermMatrix, dMat2);

__DBGpr_mat("after VC_to_world  ", dMat2); 

  /*    and add de connectpoint offsets   */

  status =
  om$send (msg = message VCP.VCP_calc
                           (&retmsg, NbCpt, dMat2, dRefMatrix),
      targetid = my_id);

__DBGpr_mat("Translation Matrix", dRefMatrix);

  End
  return ( OM_S_SUCCESS );
}/* end VCGetMatrix */


method VCBaseMat (IGRlong     *msg;
                  IGRshort     NbCpt;
                  IGRdouble   *dRefMatrix;
           struct GRmd_env    *md_env)
{
  IGRlong            retmsg;
  IGRint             status;
  IGRint             i;
  IGRint             LocType;

  struct GRid        RefId;
  struct GRid        OwnId;
  struct GRid        meself;
  struct ret_struct  RefInfo;
  struct GRmd_env    LocEnv;

  extern IGRint      VDGetCsFromEq ();
  extern IGRint      ASget_as_owner();

  SetProc( VCTerm_VCBaseMat ); Begin

  LocEnv = *md_env;

  RefId.objid  = NULL_OBJID;
  RefId.osnum  = OM_Gw_current_OS;
  meself.objid = my_id;
  meself.osnum = OM_Gw_current_OS;

  __DBGpr_obj( " Terminal Object(my_id) ", meself );

  *msg = MSSUCC;

  __DBGpr_com( " Check for No Parent Condition " );
  if (me->nVCType & VC_TERM_NO)
  {  
    __DBGpr_com( " Terminal has no parent " );

    /*  
     *  If there is No parent , get environment matrix    
     */

    for (i=0; i<16; i++)
      dRefMatrix[i] = md_env->md_env.matrix[i];

/*
*    status = om$send( msg = message VCRoot.VCBaseMat ( msg,
*                                                NbCpt, dRefMatrix, md_env),
*                      mode     = OM_e_wrt_message,
*                      targetid = my_id);
*/

__DBGpr_mat("VCRoot.VCBaseMat", dRefMatrix);

    goto quit;
  }

  OwnId.objid  = NULL_OBJID;

#ifdef commented
 
/* This is no more needed as we've changed the whole process of the Post
 * Placement of the Terminal. Added by Alwin
 *
 * ASget_as_owner (&meself, &OwnId);
 */
 
/*  The following lines have been commented because of the above ASget_owner(),
 *  and so the following statements are not needed any more. For the present
 * situation ASget_owner will not return any value and moreover it's not useful
 * anymore, and so the following lines too. Alwin
 */
 
  __DBGpr_com( " Check for Owned Terminal type " );
  if ((me->nVCType & VC_GEN_OWNED) && (OwnId.objid != NULL_OBJID))
  {  
    /* For an embedded connector get matrix from macro owner  */

    *msg = MSSUCC;

    MAidmx (msg, dRefMatrix);

    {
      IGRshort   nTmpType;
  
      status =
      om$send ( msg = message GRowner.GRget_matrix ( &retmsg,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &nTmpType, dRefMatrix ),
              targetid = OwnId.objid,
              targetos = OwnId.osnum );

    }

    goto quit;
  }
#endif
/* #ifdef commented ends here */

  __DBGpr_com( " Get the Parent of Terminal Object " );
  status =
  om$send(msg = message VCRoot.VCParent
                         (&retmsg, (IGRshort) 0, &RefId, &LocEnv),
     targetid = my_id);

  __DBGpr_obj( " ParentId of Terminal Object ", RefId );

  if ( RefId.objid == NULL_OBJID )
  {  
      IGRshort   nTmpType;

    __DBGpr_com( " The Terminal has no Parent " );

/* 4-98 KDD the following call will result in a infinite loop, so is replaced */

/* If no parent can be found, revert to VCRoot method 
*
*    status =
*    om$send ( msg = message VCRoot.VCGetMatrix
*                    ( msg, NbCpt, dRefMatrix, md_env),
*        mode     = OM_e_wrt_message,
*        targetid = my_id);
*/

/* Ask myself */
      status = om$send( msg = message GRowner.GRget_matrix ( msg, 
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &nTmpType, dRefMatrix ),
                      targetid = my_id);

__DBGpr_mat("GRowner.GRget_matrix", dRefMatrix); 

    goto quit;
  }/* end get matrix without topology */

  /* Most probably the following code mayn't get executed; but I'm not sure.
   * In case if it's found that in no case this gets executed we can remove
   * this. There is no harm in retaining this. Alwin
   */
 
  __DBGpr_com( " Check for the Virtual Terminal " );
  if (me->nVCType & VC_GEN_VIRTUAL)
  { 
    /*  For a virtual connector find the pretend owner    */

    IGRint           NbBuf;
    GRclassid        ObjClass;
    struct GRid     *PrBuf;

    __DBGpr_com( " It's a Virtual Terminal " );
    LocType = 0;

    status =
    om$send( msg = message NDnode.NDget_objects
                        (ND_ROOT | ND_IN_BUF, NULL, 0, &PrBuf, 0,
                                      OM_K_MAXINT, &NbBuf ),
               targetid = RefId.objid,
               targetos = RefId.osnum);

    RefId = PrBuf[0];

    status =
    om$get_classid( osnum      = RefId.osnum,
                    objid      = RefId.objid,
                    p_classid  = &ObjClass );

    if (om$is_ancestry_valid( subclassid = ObjClass,
                            superclassid = OPP_VDequipment_class_id )
                         == OM_S_SUCCESS )
       LocType |= VC_TERM_EQ;
    else
       LocType |= VC_TERM_RE;
  }
  else
  {
    LocType = me->nVCType;
  }

  /*A    For a real connector retrieve the referential    */
  /*A   either direct or from the equipment foot   */

  if (LocType & VC_TERM_CS)
  { /*A    either directly       */

__DBGpr_mat("Parent is CS env matrix is", md_env->md_env.matrix);

    status=
    om$send( msg = message NDnode.NDgive_structure
                                   (&retmsg,&RefInfo,&LocEnv),
        targetid = RefId.objid,
        targetos = RefId.osnum);

    for (i=0; i<16; i++)
      dRefMatrix[i] = RefInfo.var.ref_st.t[i];

#ifdef MY_DEBUG
    VC_printmat (" yyyyyy ",dRefMatrix);
#endif
  }
  else
  if (LocType & VC_TERM_EQ)
  { /*A   or as a foot of the parent equipment macro   */
    int            info;
    struct GRid    DrfId;

    __DBGpr_com( " Get the Equipment Coordinate System " );
    status =
    VDGetCsFromEq (&RefId, &DrfId, &info);

    __DBGpr_com( " Get the Matrix from Coordinate System " );
    status =
    om$send( msg = message GRgencs.GRgetmatrix (&retmsg, dRefMatrix),
        targetid = DrfId.objid,
        targetos = DrfId.osnum);

    __CheckRC( status, retmsg, "GRgencs.GRgetmatrix", quit );
  }
  else
  if (LocType & VC_TERM_RE)
  {
    __DBGpr_obj( " Route Equipment Id ", RefId );
 
    /* Initialize the Matrix before getting the Matrix Route Equipment */
    MAidmx( &retmsg, dRefMatrix );

    __DBGpr_com( " Get the Matrix from Route Equipment " );
    status=
    om$send( msg = message VRGeneric.VRGetMatrix
                                (&retmsg, 0, NULL, dRefMatrix,  &LocEnv),
        targetid = RefId.objid,
        targetos = RefId.osnum);

    __CheckRC( status, retmsg, "VRGeneric.VRGetMatrix ", quit );
  }
  else
    return (OM_E_ABORT);    /*   unknown terminal type   */

  quit:

  __DBGpr_mat( " Matrix of the Parent ", dRefMatrix );
  
  End
  return ( OM_S_SUCCESS );
}/* end VCTBasMat */

/*------------------------------------------------------------------*/

method VCGetMatrix (IGRlong   *msg;
                    IGRshort   nCpt;
                    IGRdouble *dRefMatrix;
             struct GRmd_env  *md_env)
{
  IGRint       status;
  int		dummy;
  IGRlong      retmsg;

  IGRdouble    dRef1[16],
               dRef2[16],
               dRef3[16];

  struct ret_struct  	ParamAttr;
  IGRint             	FootIndex = -1;
  IGRboolean		bEmbedded=FALSE;

SetProc( VCTerm_VCGetMatrix); Begin

__DBGpr_mat("Input md_env mat  ", md_env->md_env.matrix); 

  status =
  om$send (msg = message VCRoot.VCBaseMat (&retmsg, nCpt, dRef1, md_env),
      targetid = my_id);


  status =
  om$send (msg = message VCRoot.VCTransMat (&retmsg, nCpt, dRef2, md_env),
      targetid = my_id);


/* KDD 4-98  Translate terminal connect point according to PID scale */ 

  ParamAttr.var.root_pm_st.value = 1.0;

  status= om$send( msg   = message ACncpx.ACgive_structure ( &dummy,
                             	(int *) &FootIndex, 
				VC_N_PID_SCALE_DB, &ParamAttr, md_env),
                   targetid= my_id);

  /* The following 'if' condition added by Alwin for TR179801132 */
  /* B'cas the scaling is needed only for the connect points and not for
  the offset of Terminal itself. By checking the connect point for -1, we
  allow only the connect points getting scaled to the respective values. */
/* In the case of the Embedded Terminals even the offsets need to be scaled */
 
  status = om$send( msg = message VCTerm.VCTembed( &bEmbedded ),
                   targetid= my_id);
 
//  if( ( nCpt != -1 ) || bEmbedded )

/*  The above if condition changed to the one below (the nCpt check was
 *  removed) by Anand for TR 179901869 */

  if( bEmbedded )
  {
      dRef2 [ 3 ] *= ParamAttr.var.root_pm_st.value;
      dRef2 [ 7 ] *= ParamAttr.var.root_pm_st.value;
      dRef2 [ 11] *= ParamAttr.var.root_pm_st.value;
  }

  VC_mat_multiply (dRef1, dRef2, dRef3);

/* 4-98 KDD TR179800044 transform whatever we get to the input environment */
 
  VC_mat_multiply (md_env->md_env.matrix, dRef3, dRefMatrix);

__DBGpr_mat("Exit matrix       ", dRefMatrix);

End;
  return (OM_S_SUCCESS);
}

/*------------------------------------------------------------------*/
method GRget_matrix (IGRlong       *msg;
                     IGRshort      *matrix_type;
                     IGRmatrix      matrix;
                     IGRshort      *cmp_matrix_type;
                     IGRmatrix      cmp_matrix)
{
  IGRint     status,i ;
  IGRdouble  dVecteurO[3];
  BSrc       rc;
 
SetProc(VCTerm_GRget_matrix); Begin
 
__DBGpr_mat("input matrix   ", matrix);

#ifdef MY_DEBUG
  VC_printmat ("GRmat in", matrix);
#endif
 
/* KDD 4-98 Copy code from VRGeneric */
 
  status =
  om$send ( msg = message GRowner.GRget_matrix ( msg,
                                    matrix_type, matrix,
                                    cmp_matrix_type, cmp_matrix ),
  p_chanselect  = &AS_to_comp,
        from    = 0,
          to    = 0  );

__DBGpr_mat("GRowner.GRget_matrix   ", cmp_matrix);

  if ( !(status & OM_S_SUCCESS) ) return OM_W_ABORT;
 
  /* -- Norme matrix -- */
 
  for (i=0; i<3; i++)
  {
    dVecteurO[0] = cmp_matrix[i];
    dVecteurO[1] = cmp_matrix[i+4];
    dVecteurO[2] = cmp_matrix[i+8];
    BSnorvec (&rc, dVecteurO);
    cmp_matrix[i]   = dVecteurO[0];
    cmp_matrix[i+4] = dVecteurO[1];
    cmp_matrix[i+8] = dVecteurO[2];
  }
 
  status =
  om$send ( msg = message VDSroot.GRget_matrix
                                 (msg, matrix_type, matrix,
                                  cmp_matrix_type, cmp_matrix),
           mode = OM_e_wrt_message,
       targetid = my_id);
 
 
#ifdef MY_DEBUG
  VC_printmat ("GRmat out", cmp_matrix);
#endif
 
__DBGpr_mat("GRowner.GRget_matrix output  ", cmp_matrix);

End;
  return (OM_S_SUCCESS);
}
/*------------------------------------------------------------------*/

method  VCGetNumberOfCpts (IGRlong     *msg ;
                           IGRshort    *NbCpts)
{
  IGRint      status;

  status =
  om$send (msg = message VCP.VCP_num (msg, NbCpts),
      targetid = my_id);

  /*   add one for the unmanaged center default   */

  *NbCpts += 1;

  return ( OM_S_SUCCESS );
}

end implementation VCTerm;

