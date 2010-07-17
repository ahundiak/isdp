
/* $Id: VCTembedi.I,v 1.2 2001/02/20 01:11:31 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcterm/VCTembedi.I
 *
 * Description:
 *        Implementation of macro-embedded terminal.
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCTembedi.I,v $
 *  Revision 1.2  2001/02/20 01:11:31  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:09:34  pinnacle
# Replaced: vcterm/VCTembedi.I for:  by r250_int for route
#
# Revision 1.6  1997/11/09  06:23:36  pinnacle
# Replaced: vcterm/VCTembedi.I for:  by apazhani for cabling
#
# Revision 1.5  1997/07/14  22:08:28  pinnacle
# Replaced: vcterm/VCTembedi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/22  15:22:14  pinnacle
# Replaced: vcterm/VCTembedi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/05/19  13:50:52  pinnacle
# Replaced: vcterm/VCTembedi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/04/29  13:10:42  pinnacle
# Replaced: vcterm/VCTembedi.I for:  by hverstee for cabling
#
# Revision 1.1  1997/04/28  22:03:32  pinnacle
# Created: vcterm/VCTembedi.I by hverstee for cabling
#
 *
 * History:
 *        04/15/97        hv        Initial
 *
 *************************************************************************/

class implementation VCEmbed;

#include "OMmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "parametric.h"
#include "macro.h"
#include "acmacros.h"
#include "grerr.h"
#include "acrepdef.h"

#include "mamulmx.h"
#include "matypemx.h"
#include "maidmx.h"

#include "VCMacLib.h"
#include "VCproto.h"
#include "vrdbgmacros.h"

from  ACrg_collect  import  AClist_attribute;

/*
#define MY_DEBUG
*/


method GRget_matrix (IGRlong *msg; IGRshort *matrix_type;
                     IGRmatrix matrix; IGRshort *cmp_matrix_type;
                     IGRmatrix cmp_matrix)
{
#ifdef MY_DEBUG
  printf (" EMBEDDED GET MATRIX\n");
#endif

  *msg = MSSUCC;

  return (OM_S_SUCCESS);
}

/***********************************************************************/

method GRxform (IGRlong    *msg;
         struct GRmd_env   *md_env;
                IGRshort   *matrix_type;
                IGRmatrix   matrix;
                GRobjid    *newobjid )
{

  IGRmatrix  TmpMat;

  *msg      = MSSUCC;
  *newobjid = my_id;

  /*A Multiply my matrix and the xform one */

#ifdef MY_DEBUG
  VC_printmat ("XFORMIN",matrix);
#endif

  VC_mat_multiply (matrix, me->dMatrix, TmpMat );

  /*C set it back in my instances */
/*
  for (i=0; i<16; i++)me->dMatrix[i] = TmpMat[i];
*/
#ifdef MY_DEBUG
  VC_printmat ("XFORMED",TmpMat);
#endif

  return OM_S_SUCCESS;

}/* end GRxform */


/***********************************************************************/

method NDcopy (IGRlong     *msg;
               IGRint       cp_type;
        struct GRmd_env    *fr_env;
        struct GRmd_env    *to_env;
        struct GRid        *newobjid)

{
  IGRint    status;

  status = 
  om$send (msg = message NDnodein.NDcopy
                                  (msg,cp_type,fr_env,to_env,newobjid),
          mode = OM_e_wrt_message,
      targetid = my_id );

  return status;
}/* end NDcopy */

/***********************************************************************/

method NDmove_to_root (IGRlong     *msg;
                struct GRid        *src_grid;
                struct GRmd_env    *md_env )
{
  IGRint status;

  status = 
  om$send (msg = message NDnodein.NDmove_to_root (msg, src_grid, md_env),
          mode = OM_e_wrt_message,
      targetid = my_id );

  src_grid->objid = my_id;
  src_grid->osnum = OM_Gw_current_OS;

  return status ;
}/* end NDmove_to_root */

/***********************************************************************/

method ASreturn_go (struct GRid        *go;
                           IGRshort    *mat_type;
                           IGRdouble   *matrix)

{
  IGRlong     retmsg;

  go->objid = my_id;
  go->osnum = OM_Gw_current_OS;

  if (matrix)   MAidmx (&retmsg, matrix);

  if (mat_type)
  {
    if (matrix)   MAtypemx (&retmsg, matrix, mat_type);
    else          *mat_type = 1;
  }

  return OM_S_SUCCESS ;
}/* end ASreturn_go */

/***********************************************************************/

method NDcompute_node (IGRlong     *msg;
                       IGRint       cn_type;
                       IGRint       count;
                struct GRid         list []; 
                struct GRmd_env    *md_env)
{
  IGRlong      retmsg;
  IGRint       status;
  IGRint       i;
  IGRint       NbColl;
  IGRint       NbAttr;

  struct ACrg_coll  *pAttr;

  /* ---------------------- */
  /* -- Store attributes -- */
  /* ---------------------- */

  *msg = MSSUCC;

  /* Once moved to root during place macro, this objects receives
     another compute ??????? */
  /* So, if no templates are given => return success */
  if ( count <= 0 ) return OM_S_SUCCESS;

  NbColl = count - 1;

  /* -- Loop on collections to get attributes list -- */

  /* Get size of each collection */

  for ( i=0; i<NbColl; i++ )
  {
    /* get attributes number */
    status =
    om$send( msg = message ACrg_collect.AClist_attribute
                                        ( &retmsg, 0, NULL, &NbAttr),
        targetid = list[i].objid,
        targetos = list[i].osnum);
    as$status(action = RET_STATUS);

    if (i == 0)
    {
      if (NbAttr != om$dimension_of (varray = me->SysAtt))
      {
        status =
        om$vla_set_dimension (varray = me->SysAtt,
                              size   = NbAttr);
      }

      pAttr = me->SysAtt;
    }
    else
    {
      if (NbAttr != om$dimension_of (varray = me->UsrAtt))
      {
        status =
        om$vla_set_dimension (varray = me->UsrAtt,
                              size   = NbAttr);
      }

      pAttr = me->UsrAtt;
    }
    if (NbAttr == 0) continue;

    status =
    om$send( msg = message ACrg_collect.AClist_attribute
                                       ( &retmsg, NbAttr, pAttr, &NbAttr),
        targetid = list[i].objid,
        targetos = list[i].osnum);
    as$status(action = RET_STATUS);
  }

  /* ------------------ */
  /* -- Store matrix -- */
  /* ------------------ */

/*
  status =
  om$send( msg = message NDnode.NDgive_structure (&retmsg, &RetStr, md_env),
      targetid = list[count-1].objid,
      targetos = list[count-1].osnum);
  as$status(action = RET_STATUS);

  for (i=0; i<16; i++)
    me->dMatrix[i] = RetStr.var.ref_st.t[i];
*/

  return OM_S_SUCCESS;
}/* end NDcompute_node */

/***********************************************************************/

method NDgive_structure (IGRlong      *msg;
                  struct ret_struct   *str;
                  struct GRmd_env     *md_env )
{
  IGRint   i;

  *msg      = MSSUCC;
  str->type = ref_generic;
  for (i=0; i<16; i++)
    str->var.ref_st.t[i] = me->dMatrix[i];

  if (md_env)
  {
    VC_mat_multiply (md_env->md_env.matrix, me->dMatrix,
                     str->var.ref_st.t);
  }

  return OM_S_SUCCESS;

}/* end NDgive_structure */

/***********************************************************************/

method VCEGiveAtt (IGRlong         *msg;
                   IGRshort        *nSys;
            struct ACrg_coll       *SysAtt;
                   IGRshort        *nUsr;
            struct ACrg_coll       *UsrAtt)

{

  IGRint  i;

  SetProc( VCEGiveAtt.VCTembedi.I ); Begin

  *msg = MSSUCC;

  *nSys = om$dimension_of (varray = me->SysAtt);
  *nUsr = om$dimension_of (varray = me->UsrAtt);
  
  __DBGpr_int( " No of Sys Params ", *nSys );
  __DBGpr_int( " No of Usr Params ", *nUsr );

  if (SysAtt)
  {
    for (i=0; i<*nSys ; i++)
      SysAtt[i] = me->SysAtt[i];
  }

  if (UsrAtt)
  {
    for (i=0; i<*nUsr ; i++)
      UsrAtt[i] = me->UsrAtt[i];
  }

  End
  return OM_S_SUCCESS;
}

/***********************************************************************/

method VCETSetIns (IGRlong         *msg;
            struct VCET_ins        *Ins)
{
  IGRint      status;

  SetProc( VCETSetIns ); Begin

  *msg = MSSUCC;

  me->Product   = Ins->Product;
  me->nVCType   = Ins->Type;
  me->nVCStat   = Ins->Statx;

  __DBGpr_int( " me->Product ", me->Product );
  __DBGpr_int( " me->nVCType ", me->nVCType );

  status = om$vla_set_dimension (varray = me->szVCCode,
                                 size   = VC_MAX_CCODE);

  strcpy (me->szVCCode,  Ins->szCode);
  __DBGpr_str( " Comp Code ", me->szVCCode );

  status = om$vla_set_dimension (varray = me->szVCTagNo,
                                 size   = VC_MAX_TAGNO);

  strcpy (me->szVCTagNo, Ins->szTag);
  __DBGpr_str( " Tag Number ", me->szVCTagNo );

  End
  return OM_S_SUCCESS;
}

/***********************************************************************/

method VCETGetIns (IGRlong         *msg;
            struct VCET_ins        *Ins)
{
  IGRint    iSize;

  SetProc( VCETGetIns ); Begin

  *msg = MSSUCC;

  Ins->Product  = me->Product;
  Ins->Type     = me->nVCType;
  Ins->Statx    = me->nVCStat;

   __DBGpr_int( " Product ", Ins->Product );
   __DBGpr_int( " Type ", Ins->Type );

  iSize = om$dimension_of (varray = me->szVCCode);

  if (iSize > 0)
    strcpy (Ins->szCode, me->szVCCode);
  else
    VC_INITSTR (Ins->szCode);

  iSize = om$dimension_of (varray = me->szVCTagNo);

  if (iSize > 0)
    strcpy (Ins->szTag,  me->szVCTagNo);
  else
    VC_INITSTR (Ins->szTag);

  __DBGpr_str( " Comp Code ", Ins->szCode );
  __DBGpr_str( " Tag Number ", Ins->szTag );

  End
  return OM_S_SUCCESS;
}

/***********************************************************************/

method VCETGetMat (IGRlong         *msg;
                   IGRdouble       *dMat)
{
  IGRshort     i;

  *msg = MSSUCC;

  for (i=0; i<16; i++)
    dMat[i] = me->dMatrix[i];

#ifdef MY_DEBUG
  VC_printmat ("FR-embed",dMat);
#endif

  return (OM_S_SUCCESS);
}

/***********************************************************************/

method VCETSetMat (IGRlong         *msg;
                   IGRdouble       *dMat)
{
  IGRshort     i;

  *msg = MSSUCC;

  for (i=0; i<16; i++)
     me->dMatrix[i] = dMat[i];

  return (OM_S_SUCCESS);
}


/***********************************************************************/

end implementation VCEmbed;

