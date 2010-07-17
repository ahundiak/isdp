
/* $Id: VCRmatrix.I,v 1.2 2001/02/20 01:11:13 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRmatrix.I
 *
 * Description:
 *   This file contains the methods dealing with matrices
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRmatrix.I,v $
 *        Revision 1.2  2001/02/20 01:11:13  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/26  20:39:40  pinnacle
# Replaced: vcroot/VCRmatrix.I for:  by kddinov for route
#
# Revision 1.4  1998/04/13  00:03:50  pinnacle
# Replaced: vcroot/VCRmatrix.I for:  by kddinov for route
#
# Revision 1.3  1998/04/12  21:40:50  pinnacle
# Replaced: vcroot/VCRmatrix.I for:  by kddinov for route
#
# Revision 1.2  1998/04/12  21:35:50  pinnacle
# Replaced: vcroot/VCRmatrix.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/05/22  14:59:24  pinnacle
# Replaced: vcroot/VCRmatrix.I for:  by hverstee for cabling
#
# Revision 1.1  1997/05/19  13:05:30  pinnacle
# Created: vcroot/VCRmatrix.I by hverstee for cabling
#
 *
 * History:
 *      05/29/96        hv      Initial
 *		
 * 	4-98	KDD	VCTerm-inals have their own GRget_matrix to override. 
 *
 *************************************************************************/

class implementation VCRoot;

/*
#define  MY_DEBUG	1
#define  vdsDEBUG	1
*/

#include "bsvalues.h"
#include "bsnorvec.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "parametric.h"
#include "vrdbgmacros.h"


/***********************************************************************/

method VCBaseMat   (IGRlong   *msg;
                    IGRshort   nCpt;
                    IGRdouble *dRefMatrix;
             struct GRmd_env  *md_env)

{
  IGRint     status;
  IGRlong    retmsg;
  IGRshort   nTmpType;

SetProc(VCRoot_VCBaseMat); Begin 

  /*   as default get matrix from component channel   */
  status =
  om$send ( msg = message GRowner.GRget_matrix ( &retmsg,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &nTmpType, dRefMatrix ),
  p_chanselect  = &AS_to_comp,
        from    = 0, 
          to    = 0  );

__DBGpr_mat("GRowner.GRget_matrix   ", dRefMatrix);
__DBGpr_int("status   = ", status);
__DBGpr_int("retmsg   = ", retmsg);

  if ( !(status & OM_S_SUCCESS & retmsg) )
  {
    IGRshort    i;

    for (i=0;i<16;i++)
      dRefMatrix[i] = md_env->md_env.matrix[i];
  }

  *msg = MSSUCC;

  status = VC_mat_normalize (dRefMatrix);

End; 
  return ( OM_S_SUCCESS );

}/* end VCGetMatrix */

method VCTransMat  (IGRlong   *msg;
                    IGRshort   nCpt;
                    IGRdouble *dRefMatrix;
             struct GRmd_env  *md_env)

{
  IGRshort    nC;
  struct GRmd_env  *pLoc;

  nC = nCpt;
  pLoc = md_env;

  MAidmx (msg, dRefMatrix);

  return (OM_S_SUCCESS);
}

method VCGetMatrix (IGRlong   *msg;
                    IGRshort   nCpt;
                    IGRdouble *dRefMatrix;
             struct GRmd_env  *md_env)
{
  IGRint       status;
  IGRlong      retmsg;

  IGRdouble    dRef1[16],
               dRef2[16],
               dRef3[16];

  IGRvector		Old_Origin, New_Origin; 
  struct ret_struct  	ParamAttr;
  IGRint             	i, FootIndex = -1;
  IGRchar		ClassName[128]; 

SetProc( VCRoot_VCGetMatrix); Begin

__DBGpr_mat("Input md_env mat  ", md_env->md_env.matrix); 

  status =
  om$send (msg = message VCRoot.VCBaseMat (&retmsg, nCpt, dRef1, md_env),
      targetid = my_id);

__DBGpr_mat("Base matrix       ", dRef1);


  status =
  om$send (msg = message VCRoot.VCTransMat (&retmsg, nCpt, dRef2, md_env),
      targetid = my_id);

__DBGpr_mat("Translation matrix", dRef2);


/* Terminals now do this themselves 
* KDD 4-98 Translate terminal connect point according to PID scale 
*
*  status= om$send( msg   = message ACncpx.ACgive_structure (msg,
*                             &FootIndex, VC_N_PID_SCALE_DB, &ParamAttr,md_env),
*                   targetid= my_id);
*
*  dRef2 [ 3 ] *= ParamAttr.var.root_pm_st.value;
*  dRef2 [ 7 ] *= ParamAttr.var.root_pm_st.value;
*  dRef2 [ 11] *= ParamAttr.var.root_pm_st.value;
*/

  VC_mat_multiply (dRef1, dRef2, dRef3);

/* 4-98 KDD TR179800044 transform whatever we get to the input environment */
 
  VC_mat_multiply (md_env->md_env.matrix, dRef3, dRefMatrix);


__DBGpr_mat("Exit matrix       ", dRefMatrix);

End;
  return (OM_S_SUCCESS);
}


method GRget_matrix (IGRlong       *msg;
                     IGRshort      *matrix_type;
                     IGRmatrix      matrix;
                     IGRshort      *cmp_matrix_type;
                     IGRmatrix      cmp_matrix)
{
  IGRint     status,i ;
  IGRshort   nTmpType;
  IGRdouble  dVecteurO[3];
  BSrc       rc;


#ifdef MY_DEBUG
  VC_printmat ("GRmat in", matrix);
#endif

  status =
  om$send ( msg = message VDSroot.GRget_matrix
                                 (msg, matrix_type, matrix,
                                  cmp_matrix_type, cmp_matrix),
           mode = OM_e_wrt_message,
       targetid = my_id);


#ifdef MY_DEBUG
  VC_printmat ("GRmat out", cmp_matrix);
#endif

  return (OM_S_SUCCESS);
}
 
end implementation VCRoot;

