/* $Id: VCCinfo.I,v 1.6 2002/05/29 20:25:43 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCinfo.I
 *
 * Description:
 *
 *      Methods for instance management
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCinfo.I,v $
 *      Revision 1.6  2002/05/29 20:25:43  anand
 *      Third set of bug fixes for the split cable functionality.
 *      Merge does not corrupt the model. The marker information is
 *      now propagated to newly sketched cables/sub-cables. Changed
 *      interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *      Revision 1.5  2002/05/14 14:15:05  anand
 *      Bug fixes. TRs 6347 and 6348.
 *
 *      Revision 1.4  2002/05/08 15:48:22  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.3  2001/05/02 16:20:36  anand
 *      TR 5097
 *
 *      Revision 1.2  2001/02/20 01:08:49  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.6  2000/03/21  16:35:50  pinnacle
# Replaced: vccable/VCCinfo.I for:  by lawaddel for route
#
# Revision 1.5  2000/02/04  21:46:54  pinnacle
# Replaced: vccable/VCCinfo.I for:  by lawaddel for route
#
# Revision 1.4  1999/02/16  16:25:30  pinnacle
# Replaced: vccable/VCCinfo.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.8  1998/04/02  20:11:32  pinnacle
# Replaced: vccable/VCCinfo.I for:  by azuurhou for route
#
# Revision 1.7  1998/04/01  20:18:00  pinnacle
# Replaced: vccable/VCCinfo.I for:  by kddinov for route
#
# Revision 1.6  1998/03/31  07:09:34  pinnacle
# Replaced: vccable/VCCinfo.I for: TR 179800045 by aharihar for route
#
# Revision 1.5  1998/03/12  10:12:48  pinnacle
# Replaced: vccable/VCCinfo.I for: TR179800045 by aharihar for route
#
# Revision 1.4  1998/02/24  22:42:46  pinnacle
# Replaced: vccable/VCCinfo.I for:  by kddinov for route
#
# Revision 1.3  1998/02/21  18:48:32  pinnacle
# Replaced: vccable/VCCinfo.I for:  by kddinov for route
#
# Revision 1.2  1997/12/08  09:34:28  pinnacle
# Replaced: vccable/VCCinfo.I for:  by apazhani for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.17  1997/10/24  12:31:02  pinnacle
# Replaced: vccable/VCCinfo.I for:  by apazhani for cabling
#
# Revision 1.16  1997/08/06  15:25:22  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.15  1997/08/05  22:28:02  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.14  1997/07/31  19:53:50  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.13  1997/07/29  14:54:02  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.12  1997/07/22  21:39:52  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.11  1997/07/22  15:01:18  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.10  1997/07/14  22:31:46  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.9  1997/05/22  13:59:42  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.8  1997/04/28  22:16:04  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/14  18:21:34  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/31  18:02:08  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/20  20:48:40  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/03  17:05:40  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.3  1996/12/16  17:22:42  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/12  15:40:32  pinnacle
# Replaced: vccable/VCCinfo.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:48:08  pinnacle
# Created: vccable/VCCinfo.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      07/08/96    hv          Initial
 *      10/24/97    Alwin       Modified ACgive_structure to add some attributes
 *                              like "from_cino, to_cino, fromeq, toeq, fromtg
 *                              and totg". 
 *      12/08/97    Alwin       Added method VCCInitSection.
 *      12 Mar 98   Anand       Added 2 methods VCCSetOffset & VCCGetOffset
 *	04/02/98    AdZ		Change usage of VCSetOffset/VCCGetOffset
 *      12/31/98    law         CR179802489-Added numerous values for posting
 *      02/08/99    law         CR179701619-Added bullet proofing for NULL_OBJID
 *                              posting to try to avoid Db contamination.
 *      02/16/99    law         TR179802033-Added splice to VCDUMP
 *      02/04/00    law         CR179702191-freqmino and toeqmino for formatted
 *                              text applications.
 *      03/21/00    law         TR179901242-length computation omitted breaks
 *      05/02/01    Anand       TR 5097 - ensure valid tail & estim lengths.
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG      1
#define  MY_DEBUG     1
*/

#include "VDmem.h"
#include  "vds.h"
#include  "VDmsg.h"
#include "VCproto.h"
#include "parametric.h"

#include "bsdistptpt.h"
#include "vrdbgmacros.h"

#include "VCstructs2.h"
#include "OMprimitives.h"
#include "vdreporterr.h"
#include "VDsa.h"

#include "VCLead.h"


from   VCTerm     import   VCGetEquipId;
from   VCMac      import   VCGetEquipTag;
from   VRGeneric  import   VRGetOrigCoor;
from   GRlinear   import   GRgetpolyline;

extern  GRclassid    OPP_VRCptIn_class_id;


/*D ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  VCSetInstance stores data in the cable instance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VCSetInstance  (IGRlong *msg; struct VCGenInfo *Instance)
{
  IGRint  status;
  IGRint  i;

SetProc(VCCable_VCSetInstance ); Begin

  /*A store data in my instance */
  status =
  om$send(msg = message VCRoot.VCSetInstance (msg,Instance),
         mode = OM_e_wrt_message,
     targetid = my_id );
  as$status(action = RET_STATUS );

  /*     copy section map to instance     */

  if ((Instance->Attr.Cable.NbSections > 0) &&
      (Instance->Attr.Cable.pSect != NULL))
  {
    status =
    om$vla_set_dimension (varray = me->Sect,
                           size  = Instance->Attr.Cable.NbSections);
    as$status(action = RET_STATUS );

    for (i=0; i<Instance->Attr.Cable.NbSections; i++)
    {
      me->Sect[i].type    = Instance->Attr.Cable.pSect[i].type;
      me->Sect[i].iFrom   = Instance->Attr.Cable.pSect[i].iFrom;
      me->Sect[i].iTo     = Instance->Attr.Cable.pSect[i].iTo;
      me->Sect[i].numvert = Instance->Attr.Cable.pSect[i].numvert;
      me->Sect[i].strno   = Instance->Attr.Cable.pSect[i].strno;
      me->Sect[i].parno   = Instance->Attr.Cable.pSect[i].parno;
    }

#ifdef vdsDEBUG
    printf (" stored cable instance %d sections\n",
                               Instance->Attr.Cable.NbSections);
#endif
  }

End;
  return OM_S_SUCCESS;
}/* end VCSetInstance */

/*D ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  VCGetInstance returns the cable instance data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VCGetInstance  (IGRlong *msg; struct VCGenInfo *Instance)
{
  IGRlong              retmsg;
  IGRint               status;
  IGRint               i;
  IGRint               action;
  IGRdouble           *LocVtx;

  struct VCCL_sectmap *LocSct;
  struct IGRpolyline   LineIn;
  struct GRmd_env      md_env;
  IGRshort             store1;

SetProc(VCCable_VCGetInstance ); Begin

  LineIn.num_points = 0;
  md_env.md_env.matrix_type = MAIDMX;
  MAidmx( &retmsg, md_env.md_env.matrix );

  /*A get my generic instance */
  status =
  om$send(msg = message VCRoot.VCGetInstance (msg,Instance),
         mode = OM_e_wrt_message,
     targetid = my_id );
  as$status(action = RET_STATUS );

#ifdef vdsDEBUG
  printf ("Mlink GetInstance after generic\n");
#endif

  /*C Return my vertices number */
  Instance->Attr.Cable.NbSections =
    om$dimension_of( varray = me->Sect );

  Instance->Attr.Cable.NbVertices = 0;
  for (i=0; i<Instance->Attr.Cable.NbSections; i++)
  {
    if (me->Sect[i].type == VCC_STRING)
      Instance->Attr.Cable.NbVertices += me->Sect[i].numvert;
  }

  /*C Return section map if requested   */
  LocSct = Instance->Attr.Cable.pSect;
  LocVtx = Instance->Attr.Cable.pVertex;

  if ((LocSct == NULL) && (LocVtx == NULL))  return (OM_S_SUCCESS);

/* KDD 3-98 */
  store1 = Instance->Attr.Cable.NbVertices;


  Instance->Attr.Cable.NbVertices = 0;

  if (LocSct != NULL)
  {
    for (i=0; i<Instance->Attr.Cable.NbSections; i++)
    {
      Instance->Attr.Cable.pSect[i] = me->Sect[i];

#ifdef vdsDEBUG
      printf (" Mlink getinst sect %d %d %d %d %d %d\n",
                             me->Sect[i].type, me->Sect[i].iFrom,
                             me->Sect[i].iTo, me->Sect[i].numvert,
                             me->Sect[i].strno, me->Sect[i].parno);
#endif
    }
  }

  action = (LocVtx != NULL) ? 1 : 0;

  for (i=0; i<Instance->Attr.Cable.NbSections; i++)
  {
    if (me->Sect[i].type != VCC_STRING) continue;

    LineIn.points = LocVtx;

#ifdef vdsDEBUG
    printf (" getpolyline, stringno %d  (integ) locvtx %d\n",
                    me->Sect[i].strno,LocVtx);
#endif

    status =
    om$send(msg    = message GRlinear.GRgetpolyline
                                (&retmsg, &md_env.md_env.matrix_type,
                                  md_env.md_env.matrix, &action, &LineIn),
      p_chanselect = &AS_to_comp,
      from         = me->Sect[i].strno,
      to           = me->Sect[i].strno);
    as$status();

/* KDD 3-98. Check the memory allocated */
    if ( store1 < LineIn.num_points) {
       vd$report_error( error = "Memory allocation error",
                        mode = 1, filename = __FILE__);
       goto wrapup;
    }


#ifdef vdsDEBUG
    printf (" from polyline %d vertices\n",LineIn.num_points);

    if (LocVtx != NULL)
    {
      IGRint    jj;

      for (jj=0; jj< LineIn.num_points; jj++)
        printf (" vtx %d  -- %f %f %f\n",jj,
                  LocVtx[jj*3],LocVtx[jj*3+1],LocVtx[jj*3+2]);
    }
#endif

    if (Instance->Attr.Cable.pSect != NULL)
      Instance->Attr.Cable.pSect[i].iFrom   = Instance->Attr.Cable.NbVertices;

    Instance->Attr.Cable.NbVertices += LineIn.num_points;

    if (Instance->Attr.Cable.pSect != NULL)
    {
      Instance->Attr.Cable.pSect[i].iTo = Instance->Attr.Cable.NbVertices - 1;
#ifdef vdsDEBUG
      printf (" Mlink getinst vtx from/to %d %d number %d\n",
                              Instance->Attr.Cable.pSect[i].iFrom ,
                              Instance->Attr.Cable.pSect[i].iTo,
                              LineIn.num_points);
#endif
    }

    if (Instance->Attr.Cable.pVertex != NULL)
      LocVtx += (3 * LineIn.num_points);
  }

wrapup:
End;
  return OM_S_SUCCESS;
}/* end VCGetInstance */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              override     method    ACgive_structure                         
/*
/*  DESCRIPTION: An attribute belonging to the templates should be returned
/*    as if it were prt of the component.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method ACgive_structure (int          *msg;
                         int          *direct_index;
                         char         *footname;
                  struct ret_struct   *p_rs;
                  struct GRmd_env     *md_env)

{
  IGRint      status=OM_S_SUCCESS;
  IGRint      intmsg;
  IGRlong     retmsg;
  IGRshort    iWhich;
  IGRshort    noret;
  IGRchar	parentName[80]; /* CR179802489 */

  struct VCEXpan   ExRec;

  SetProc( VCCable_ACgive_structure ); Begin
  *msg=MSSUCC;

  __DBGpr_str( "footname ", footname );
  if ( !(strcmp (footname, VC_N_CAB_LENGTH_DB)) )
  {
    IGRdouble    dLgt;
    IGRint       jns;
    IGRint       i, j;
    IGRint       NumVtx;
    IGRdouble    dBendRad;
    IGRdouble   *dLocBend;
    IGRint       NumBover;
    IGRint       action;
      IGRdouble     breakcrd[6];

    struct ret_struct   rs_loc;
    struct IGRpolyline  LineIn;
    struct GRmd_env     LocEnv;
    struct GRid         AsPar;

    rs_loc.type = double_type;
    action      = 1;

    status =
    om$send (msg = message ACncpx.ACgive_db_structure
                    (&intmsg, direct_index, VC_N_BEND_RAD_DB, &rs_loc, md_env),
        targetid = my_id);

    dBendRad = rs_loc.var.root_pm_st.value;

    jns = om$dimension_of (varray = me->Sect);
    NumBover = om$dimension_of (varray = me->Bend);

    NumVtx  = 0;

    for (i=0; i<jns; i++)
    {
      if ((me->Sect[i].iTo - me->Sect[i].iFrom) > NumVtx)
        NumVtx = me->Sect[i].iTo - me->Sect[i].iFrom;
    }

    NumVtx += (2 * jns);   /*   safety margin   */

    LineIn.num_points = 0;
    LineIn.points     = _MALLOC ((3 * NumVtx), IGRdouble);
    dLocBend          = _MALLOC (NumVtx, IGRdouble);
    for(j=0; j<6; j++) breakcrd[j] = 0.0;

    dLgt = 0.0;
    i    = 0;

    while (i<jns)
    {
      IGRdouble     dCoord[3];
      IGRdouble     dTO[3];
      IGRdouble     dDist;
      IGRshort      jindex;
      IGRshort      parno;
      IGRint        Vtxndx;
      /* added for tr179901242 */
      IGRdouble *dVertex;
      IGRdouble templength;

      rs_loc.var.root_pm_st.value = 0.0;
      parno = me->Sect[i].parno;
      switch (me->Sect[i].type)
      {
        case VCC_STRING:
          /*C Get linestring */
#ifdef vdsDEBUG
          printf (" cablen stringcalc %d\n",i);
#endif
          status =
          om$send(msg    = message GRlinear.GRgetpolyline
                                (&retmsg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &action, &LineIn),
            p_chanselect = &AS_to_comp,
            from         = me->Sect[i].strno,
            to           = me->Sect[i].strno);

/* KDD 3-98. Check the memory allocated */
          if ( NumVtx < LineIn.num_points) {
             vd$report_error( error = "Memory allocation error",
                              mode = 1, filename = __FILE__);
             goto wrapup;
          }


          for (j=0; j<NumVtx; j++)
            dLocBend[j] = dBendRad;

          for (j=0; j<NumBover; j++)
          {
            if (me->Bend[j].secno == i)
              dLocBend[me->Bend[j].vtxno] = me->Bend[j].rad;
          }
templength = VC_compute_strlen (&retmsg, &LineIn, me->Sect[i].iFrom,
                              me->Sect[i].iTo, dLocBend);

          /* Modified for tr179901242 */
          rs_loc.var.root_pm_st.value +=
          VC_compute_strlen (&retmsg, &LineIn, me->Sect[i].iFrom,
                              me->Sect[i].iTo, dLocBend);
          i++;
          break;
             
        case VCC_BREAK_ON:
          /* Added for tr179901242 */
          status =
          om$send(msg    = message GRlinear.GRgetpolyline
                                (&retmsg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &action, &LineIn),
            p_chanselect = &AS_to_comp,
            from         = me->Sect[i-1].strno,
            to           = me->Sect[i-1].strno);
        Vtxndx = 3 * (me->Sect[i-1].iTo - me->Sect[i-1].iFrom );
        dVertex = LineIn.points;
        for(j=0; j<3; j++)
        {
          breakcrd[j] = dVertex[Vtxndx+j];
           breakcrd[3+j] = 0.0;
        }
          rs_loc.var.root_pm_st.value = 0.0;
          i++;
          break;
        case VCC_BREAK_OFF:
          /* Added for tr179901242 */
          status =
          om$send(msg    = message GRlinear.GRgetpolyline
                                (&retmsg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &action, &LineIn),
            p_chanselect = &AS_to_comp,
            from         = me->Sect[i+1].strno,
            to           = me->Sect[i+1].strno);
        Vtxndx = 0;
        dVertex = LineIn.points;
        for(j=0; j<3; j++)
        {
          breakcrd[3+j] = dVertex[Vtxndx+j];
        }
        {
        BSrc      rc;
        dDist = BSdistptpt (&rc, &breakcrd[0], &breakcrd[3]);
          rs_loc.var.root_pm_st.value = dDist;
        }
        for(j=0; j<6; j++) breakcrd[j] = 0.0;
          i++;
          break;
        /*   these should not occur after recompute .... */
        case VCC_FREE_VERTEX:
        case VCC_FREE_GUIDE:
        case VCC_FREE_RWAY:

        /*   and these do not have any influence on length  */
        case VCC_TERM_PULL:
        case VCC_TERM_PARENT:
        case VCC_TERM_CHILD:
        case VCC_POINT_PARENT:

        default:
          rs_loc.var.root_pm_st.value = 0.0;
          i++;
          break;

        case VCC_GUIDE_PARENT:
          rs_loc.var.root_pm_st.value = 0.0;

          LocEnv = *md_env;

          status =
          om$send (msg = message VCRoot.VCParent
                                   (&retmsg, parno, &AsPar, &LocEnv),
              targetid = my_id);

          status =
          om$send (msg = message ACncpx.ACgive_structure
                         (&intmsg, direct_index, footname, &rs_loc, &LocEnv),
              targetid = AsPar.objid,
              targetos = AsPar.osnum);
          as$status();

          i++;
          break;

        case VCC_RWAY_PARENT:
          /*   cable length on rway ..... */

          rs_loc.var.root_pm_st.value = 0.0;

          LocEnv = *md_env;

          status =
          om$send (msg = message VCRoot.VCParent
                                   (&retmsg, parno, &AsPar, &LocEnv),
              targetid = my_id);

          status=
          om$send (msg = message VRGeneric.VRGetOrigCoor
                                 (&retmsg, dCoord, &LocEnv),
              targetid = AsPar.objid,
              targetos = AsPar.osnum);
          as$status();

          jindex = i+1;

          while (me->Sect[jindex].type == VCC_RWAY_PARENT)
          {
            IGRshort  nPar;
            BSrc      rc;
            GRclassid pClass;

            nPar = me->Sect[jindex].parno;

            status =
            om$send (msg = message VCRoot.VCParent
                                   (&retmsg, nPar, &AsPar, &LocEnv),
                targetid = my_id);

            om$get_classid (objid = AsPar.objid,
                            osnum = AsPar.osnum,
                        p_classid = &pClass );

            if (pClass != OPP_VRCptIn_class_id)
            {
              status=
              om$send (msg = message VRGeneric.VRGetOrigCoor
                                           (&retmsg, dTO, &LocEnv),
                  targetid = AsPar.objid,
                  targetos = AsPar.osnum);
              as$status();

              dDist = BSdistptpt (&rc, dCoord, dTO);
#ifdef vdsDEBUG
              printf (" raceway section end %d dist %f\n", jindex, dDist);
#endif

              dCoord[0] = dTO[0];
              dCoord[1] = dTO[1];
              dCoord[2] = dTO[2];

              rs_loc.var.root_pm_st.value += dDist;
            }

            jindex++;
          }

          i = jindex + 1;
          break;
      }
                         
      dLgt += rs_loc.var.root_pm_st.value;
#ifdef vdsDEBUG
      printf (" cablen part - total %f %f\n",
                        rs_loc.var.root_pm_st.value, dLgt);
#endif
    }

    _FREE (LineIn.points);
    _FREE (dLocBend);

    p_rs->type = double_type;
    p_rs->var.root_pm_st.value = dLgt;
  }/* end cable summation   */
  else
  if ( !(strcmp (footname, VC_N_TAIL_LENGTH_DB)) )
  {
    iWhich = VC_EXIN_TAIL;

    p_rs->type = double_type;
    p_rs->var.root_pm_st.value = 0.0;

    status=
    om$send (msg = message VCRoot.VCGetExpand
                                  (&retmsg, iWhich, &noret, &ExRec),
        targetid = my_id);

    /* Begin kludge/check/fix/whatever for TR 5097 */
    if ( ExRec.AT.EXd < 0.0 || ExRec.AT.EXd > 1e6 )
    {
	__DBGpr_dbl("Invalid tail length (b4 resetting to 0.0)", ExRec.AT.EXd);
	
	ExRec.type = VCEX_DBL;
	ExRec.AT.EXd = 0.0;
	status = om$send (msg = message VCRoot.VCPutExpand( &retmsg,
						       (IGRshort) VC_EXIN_TAIL,
						       &noret, &ExRec),
		     targetid = my_id);
    }
    /* End   kludge/check/fix/whatever for TR 5097 */

    if (retmsg & MSSUCC)
      p_rs->var.root_pm_st.value = ExRec.AT.EXd;;

    __DBGpr_dbl( "TailLength ", p_rs->var.root_pm_st.value );
  }
  else
  if ( !(strcmp (footname, VC_N_ESTIM_LENGTH_DB)) )
  {
    iWhich = VC_EXIN_ESTIM;

    p_rs->type = double_type;
    p_rs->var.root_pm_st.value = 0.0;

    status=
    om$send (msg = message VCRoot.VCGetExpand
                                  (&retmsg, iWhich, &noret, &ExRec),
        targetid = my_id);

    /* Begin kludge/check/fix/whatever for TR 5097 */
    if ( ExRec.AT.EXd < 0.0 || ExRec.AT.EXd > 1e6 )
    {
	__DBGpr_dbl("Invalid estimated length (b4 resetting to 0.0)",
								 ExRec.AT.EXd);
	
	ExRec.type = VCEX_DBL;
	ExRec.AT.EXd = 0.0;
	status = om$send (msg = message VCRoot.VCPutExpand( &retmsg,
						      (IGRshort) VC_EXIN_ESTIM,
						      &noret, &ExRec),
		     targetid = my_id);
    }
    /* End   kludge/check/fix/whatever for TR 5097 */

    if (retmsg & MSSUCC)
      p_rs->var.root_pm_st.value = ExRec.AT.EXd;;

    __DBGpr_dbl( " EstimatedLength ", p_rs->var.root_pm_st.value );
  }
  /* Added for cr179702191 */
  else if ( !(strcmp (footname, "freqmino")) )
  {
    struct GRid TerminalId;
    /* Get the Terminals connected at origin */
    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 0, &TerminalId),
               targetid = my_id );

    if ( TerminalId.objid != NULL_OBJID)
    {
      struct GRid EquipId;
      status =
      om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
               targetid = TerminalId.objid,
               targetos = TerminalId.osnum );

      __DBGpr_obj( "Origin Parent/Equipment Id ", EquipId );

      /* The value of this attribute should be obtained from the Equipment, to
      which the cable object is connected to. We will get the value of the
      attribute "cino" from the Parent Equipment and set this cable object.
      This is done as asked by the Clark */

      p_rs->var.text_st.text_string[0] = '\0';
      if( EquipId.objid != NULL_OBJID )
      {
         status = om$send ( msg = message VRGeneric.ACgive_structure( msg,
                                   direct_index, "eqp_partno", p_rs, md_env ),
                  targetid = EquipId.objid,
                  targetos = EquipId.osnum );

         if( !status & *msg & 1 )
           p_rs->var.text_st.text_string[0] = '\0';

         __DBGpr_str( "From Equipment mino ", p_rs->var.text_st.text_string );
      }
    }
  }
  /* added by Alwin for TR179701824 Beginning ....*/
  else if ( !(strcmp (footname, "fromcino")) )
  {
    struct GRid TerminalId;
 
    /* Get the Terminals connected at origin */
    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 0, &TerminalId),
               targetid = my_id );
 
    p_rs->var.text_st.text_string[0] = '\0';
    if ( TerminalId.objid != NULL_OBJID)
    {
      struct GRid EquipId;
    
      status =
      om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
               targetid = TerminalId.objid,
               targetos = TerminalId.osnum );

      __DBGpr_obj( "Origin Parent/Equipment Id ", EquipId );

      /* The value of this attribute should be obtained from the Equipment, to
      which the cable object is connected to. We will get the value of the 
      attribute "cino" from the Parent Equipment and set this cable object.
      This is done as asked by the Clark */

      if( EquipId.objid != NULL_OBJID )
      {
         status = om$send ( msg = message VRGeneric.ACgive_structure( msg,
                                   direct_index, "cino", p_rs, md_env ),
                  targetid = EquipId.objid,
                  targetos = EquipId.osnum );

         if( !status & *msg & 1 )
           p_rs->var.text_st.text_string[0] = '\0';

         __DBGpr_str( "From Equipment Cino ", p_rs->var.text_st.text_string );
      }
    }
  }
  /* Added for cr179702191 */
  else if ( !(strcmp (footname, "toeqmino")) )
  {
    struct GRid TerminalId;

    /* Get the Terminals connected at end */
    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 1, &TerminalId),
               targetid = my_id );

    p_rs->var.text_st.text_string[0] = '\0';
    if ( TerminalId.objid != NULL_OBJID)
    {
      struct GRid EquipId;

      status =
      om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
               targetid = TerminalId.objid,
               targetos = TerminalId.osnum );

      __DBGpr_obj( "End Parent/Equipment Id ", EquipId );

      p_rs->var.text_st.text_string[0] = '\0';
      if( EquipId.objid != NULL_OBJID )
      {
         status = om$send ( msg = message VRGeneric.ACgive_structure( msg,
                                   direct_index, "eqp_partno", p_rs, md_env ),
               targetid = EquipId.objid,
               targetos = EquipId.osnum );

         if( !status & *msg & 1 )
           p_rs->var.text_st.text_string[0] = '\0';
      }

      __DBGpr_str( "To Equipment mino ", p_rs->var.text_st.text_string );
    }
  }

  else if ( !(strcmp (footname, "tocino")) )
  {
    struct GRid TerminalId;
 
    /* Get the Terminals connected at end */
    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 1, &TerminalId),
               targetid = my_id );
 
    if ( TerminalId.objid != NULL_OBJID)
    {
      struct GRid EquipId;
   
      status =
      om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
               targetid = TerminalId.objid,
               targetos = TerminalId.osnum );
 
      __DBGpr_obj( "End Parent/Equipment Id ", EquipId );
 
      status = om$send ( msg = message VRGeneric.ACgive_structure( msg,
                                   direct_index, "cino", p_rs, md_env ),
               targetid = EquipId.objid,
               targetos = EquipId.osnum );
 
      if( !status & *msg & 1 )
        p_rs->var.text_st.text_string[0] = '\0';
 
      __DBGpr_str( "To Equipment Cino ", p_rs->var.text_st.text_string );
    }
  }
  else if ( !(strcmp (footname, VC_N_CBFREQPTG_AN)) )/* Modified-CR179802489*/
  {
    /* Get the Terminals connected at origin */
    IGRchar f_eqp[15];
    struct GRid TerminalId;
    struct GRid	EquipId ;

    p_rs->type = text_type;
    f_eqp[0] = p_rs->var.text_st.text_string[0] = '\0';

    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 0, &TerminalId),
               targetid = my_id );
 
    if ( TerminalId.objid != NULL_OBJID)
    {
      status =
               om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
                    targetid = TerminalId.objid,
                    targetos = TerminalId.osnum );
      if(EquipId.objid == NULL_OBJID)
      {
	 status = OM_S_SUCCESS;
         goto wrapup;
      }
      status =
      om$send (msg = message VCMac.VCGetEquipTag (&retmsg, f_eqp, md_env),
            targetid = TerminalId.objid,
            targetos = TerminalId.osnum);
 
      strcpy(p_rs->var.text_st.text_string, f_eqp);

    __DBGpr_str( "Cable.Originating from Equipment Tag", p_rs->var.text_st.text_string );

    }
  }
  /*** Added for CR179802489 ***/
  else if ((!(strcmp (footname, VC_N_CBFREQPID_IN))) ||
           (!(strcmp (footname, VC_N_CBFREQPCAT_AN))) ||
           (!(strcmp (footname, VC_N_CBFREQPNAM_AN))) ||
           (!(strcmp (footname, VC_N_CBFREQPREV_AN))) )
  {

	struct GRid	EquipId ;
        struct GRid TerminalId;

	EquipId.objid = NULL_OBJID ;
        TerminalId.objid = NULL_OBJID;
	/*
	 * get the equipment object
	 */
        /* Get the Terminals connected at origin */
        status =
            om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 0,
                                                         &TerminalId),
               targetid = my_id );

        if (!(strcmp (footname, VC_N_CBFREQPID_IN)))
        {
          IGRint newvar;
          newvar = -1;
          p_rs->type = double_type;
          p_rs->var.root_pm_st.value = newvar; 
        }
        else
        {
          p_rs->type = text_type;
          p_rs->var.text_st.text_string[0] = '\0';
        }

        if ( TerminalId.objid != NULL_OBJID)
        {

            status =
               om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
                    targetid = TerminalId.objid,
                    targetos = TerminalId.osnum );
        }
        else
        {
          __DBGpr_str("Processing foot",footname);
          status = OM_S_SUCCESS;
          goto wrapup;
        }
        if(EquipId.objid == NULL_OBJID)
        {
          __DBGpr_str("Processing foot",footname);
          status = OM_S_SUCCESS;
          goto wrapup;
        }

        if (!strcmp(footname,VC_N_CBFREQPID_IN ) )
        {
           p_rs->type = double_type;
           p_rs->var.root_pm_st.value = (IGRdouble) EquipId.objid; 
        }
	/*
	 * Map the name to the attribute to SA_PMA type.
	 */
	else if (EquipId.objid != NULL_OBJID)
        {
	   parentName[0] = '\0';
           if (!strcmp(footname,VC_N_CBFREQPCAT_AN))
           {
               strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
           }
	   else if (!strcmp(footname,VC_N_CBFREQPNAM_AN))
           {
               strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
           }
	   else if (!strcmp(footname,VC_N_CBFREQPREV_AN))
           {
               strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
           }
	   if ( parentName[0] == '\0' ) goto wrapup;

	   /*
	    * Call routine for value.
	    */
	   status =
	      vdsa$GetStruct(objID = &EquipId, name = parentName, rs = p_rs);
           __DBGpr_str("fr-equip-str",p_rs->var.text_st.text_string);
           if ( ! (status & 1) ) goto wrapup;

         }
         else
         {
           status = OM_S_SUCCESS;
           goto wrapup;
         }

         
  }
  else if(!(strcmp (footname,VC_N_CBFRTERMID_IN)) ||
          !(strcmp (footname,VC_N_CBFRTERMTG_AN)) ||
          !(strcmp (footname,VC_N_CBFRTERMNAM_AN)) ||
          !(strcmp (footname,VC_N_CBFRTERMCAT_AN)) ||
          !(strcmp (footname,VC_N_CBFRTERMREV_AN)))/*Modified for CR179802489*/
  {
    /* Get the Terminals connected at origin */
    IGRchar fromtg[15];
    struct GRid TerminalId;

    fromtg[0] = '\0';
    TerminalId.objid = NULL_OBJID;

    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 0, &TerminalId),
               targetid = my_id );
 
    if (!(strcmp (footname, VC_N_CBFRTERMID_IN)))
    {
      p_rs->type = double_type;
      p_rs->var.root_pm_st.value = 0.0;
    }
    else
    {
      p_rs->type = text_type;
      p_rs->var.text_st.text_string[0] = '\0';
    }

    if ( TerminalId.objid == NULL_OBJID)
    {
          __DBGpr_str("Processing foot",footname);
           __DBGpr_str("fr-equip-str",p_rs->var.text_st.text_string);
      status = OM_S_SUCCESS;
      goto wrapup;
    }

 
    if(!(strcmp (footname,VC_N_CBFRTERMTG_AN)))/* Modified for CR179802489 */
    { 
         status =
            om$send (msg = message VCRoot.VCGetTagNo ( fromtg ),
               targetid = TerminalId.objid,
               targetos = TerminalId.osnum);
         p_rs->type = text_type;
         strcpy(p_rs->var.text_st.text_string, fromtg);
         __DBGpr_str( "Cable.Originating of Terminal Tag", p_rs->var.text_st.text_string );
    } 
    else if (!strcmp(VC_N_CBFRTERMID_IN,footname))
    {
         IGRint newvar;
         newvar = TerminalId.objid;
         p_rs->type = double_type;
         p_rs->var.root_pm_st.value = newvar; 
    }
    else
    {
	 parentName[0] = '\0';
         if (!strcmp(footname,VC_N_CBFRTERMCAT_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
         else if (!strcmp(footname,VC_N_CBFRTERMNAM_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
         else if (!strcmp(footname,VC_N_CBFRTERMREV_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
         if (parentName[0] == '\0') goto wrapup;

         status = vdsa$GetStruct(objID = &TerminalId,name = parentName,rs = p_rs);
            if ( ! (status & 1) ) goto wrapup;
    }
  }
  /* Modified for CR179802489 */
  else if ( (!(strcmp (footname,VC_N_CBTOEQPTG_AN))) ||
            (!(strcmp (footname,VC_N_CBTOEQPID_IN))) ||
            (!(strcmp (footname,VC_N_CBTOEQPCAT_AN))) ||
            (!(strcmp (footname,VC_N_CBTOEQPNAM_AN))) ||
            (!(strcmp (footname,VC_N_CBTOEQPREV_AN))) )
  {
    /* Get the Terminals connected at end */
    IGRchar t_eqp[15];
    struct GRid TerminalId;
    struct GRid EquipId;

    TerminalId.objid = NULL_OBJID;
    EquipId.objid = NULL_OBJID;

    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 1, &TerminalId),
               targetid = my_id );

    if (!(strcmp (footname, VC_N_CBTOEQPID_IN)))
    {
          IGRint newvar;
          newvar = -1; 
          p_rs->type = double_type;
          p_rs->var.root_pm_st.value = newvar;
    }
    else
    {
          p_rs->type = text_type;
          p_rs->var.text_st.text_string[0] = '\0';
    }

    if ( TerminalId.objid == NULL_OBJID)
    {
      status = OM_S_SUCCESS;
      goto wrapup;
    }


    status =
               om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
                    targetid = TerminalId.objid,
                    targetos = TerminalId.osnum );

    if ( EquipId.objid == NULL_OBJID)
    {
      status = OM_S_SUCCESS;
      goto wrapup;
    }

    if (!(strcmp (footname,VC_N_CBTOEQPTG_AN))) /* modified-cr179802489 */
    {
      status =
      om$send (msg = message VCMac.VCGetEquipTag (&retmsg, t_eqp, md_env),
            targetid = TerminalId.objid,
            targetos = TerminalId.osnum);
 
      p_rs->type = text_type;
      strcpy(p_rs->var.text_st.text_string, t_eqp);
 
      __DBGpr_str( "Cable.Terminating at Equipment Tag", p_rs->var.text_st.text_string );
 
    }
    else /* Added for CR179802489 */
    {
      if (!strcmp(footname,VC_N_CBTOEQPID_IN) )
      {
        p_rs->type = double_type;
        p_rs->var.root_pm_st.value = (IGRdouble) EquipId.objid;
      }
      else
      {
         parentName[0] = '\0';
         if (!strcmp(footname,VC_N_CBTOEQPCAT_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
         else if (!strcmp(footname,VC_N_CBTOEQPNAM_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
         else if (!strcmp(footname,VC_N_CBTOEQPREV_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
         if (parentName[0] == '\0') goto wrapup;
         p_rs->type = text_type;
         status = vdsa$GetStruct(objID = &EquipId, name = parentName, rs = p_rs);
           __DBGpr_str("to-equip-str",p_rs->var.text_st.text_string);
            if ( ! (status & 1) ) goto wrapup;
      }
    }
  }
  /* Modified for CR179802489 */
  else if ((!strcmp(footname,VC_N_CBTOTERMTG_AN)) ||
           (!strcmp(footname,VC_N_CBTOTERMID_IN)) ||
           (!strcmp(footname,VC_N_CBTOTERMCAT_AN)) ||
           (!strcmp(footname,VC_N_CBTOTERMNAM_AN)) ||
           (!strcmp(footname,VC_N_CBTOTERMREV_AN)))
  {
    /* Get the Terminals connected at end */
    IGRchar totg[15];
    struct GRid TerminalId;
 
    if (!(strcmp (footname, VC_N_CBTOTERMID_IN)))
    {
      IGRint newvar;
      newvar = -1;
      p_rs->type = double_type;
      p_rs->var.root_pm_st.value = newvar;
    }
    else
    {
      p_rs->type = text_type;
      p_rs->var.text_st.text_string[0] = '\0';
    }

    TerminalId.objid = NULL_OBJID;

    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 1, &TerminalId),
               targetid = my_id );
 
    if ( TerminalId.objid == NULL_OBJID)
    {
      status = OM_S_SUCCESS;
      goto wrapup;
    }


    else if (!strcmp(footname,VC_N_CBTOTERMTG_AN) ) /* Modified-CR179802489*/
    {
      status =
      om$send (msg = message VCRoot.VCGetTagNo ( totg ),
            targetid = TerminalId.objid,
            targetos = TerminalId.osnum);
 
      p_rs->type = text_type;
      strcpy(p_rs->var.text_st.text_string, totg);
 
    __DBGpr_str( "Cable.Terminating at Terminal Tag", p_rs->var.text_st.text_string );
    }
    /* Added for cr179802489 */
    else if ( ! strcmp(footname,VC_N_CBTOTERMID_IN) )
    {
        p_rs->type = double_type;
        p_rs->var.root_pm_st.value = (IGRdouble) TerminalId.objid;
    }
    else
    {
         parentName[0] = '\0';
         if (!strcmp(footname,VC_N_CBTOTERMCAT_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
         else if (!strcmp(footname,VC_N_CBTOTERMNAM_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
         else if (!strcmp(footname,VC_N_CBTOTERMREV_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
         if (parentName[0] == '\0') goto wrapup;

         status = vdsa$GetStruct(objID = &TerminalId, name = parentName, rs = p_rs);
            if ( ! (status & 1) ) goto wrapup;
    }
    /* end add cr179802489 */
   }
/* added by alwin for TR179701824 .....End */
  else
  {
    __DBGpr_com( "Calling the VCRoot wrt to message " );

    status=
    om$send (msg = message VCRoot.ACgive_structure 
                                  (msg, direct_index, footname, p_rs, md_env),
            mode = OM_e_wrt_message,
        targetid = my_id);

  }/* end of generic treatment */

wrapup:
  End;

  return status;
}/* end ACgive_structure */

method VCCbDynCpt  (IGRlong     *msg;
                    IGRshort     nCpt;      /*    my end      */
                    IGRshort     nDyn)      /*    new dynamic connectpoint  */
{
  IGRint       nsInd;

SetProc(VCCable_VCCbDynCpt ); Begin

  *msg = MSSUCC;

  if (nCpt == 0)
    nsInd = 0;
  else
    nsInd = om$dimension_of (varray = me->Sect) - 1;

  me->Sect[nsInd].iFrom = me->Sect[nsInd].iTo = nDyn;

End;
  return (OM_S_SUCCESS);
}

method VCDUMP   (IGRlong     *msg)
{
	IGRint			status;
	IGRint			sizx, i;
	struct VCOffset		*pOffset = NULL ;
	IGRshort	 	NoOffsets=0;
        IGRint			nProd;

SetProc(VCCable_VCDUMP ); Begin

  status =
  om$send (msg = message VCRoot.VCDUMP (msg),
          mode = OM_e_wrt_message,
      targetid = my_id);

  printf (" TYPEFLAGS ");

  if (me->nVCType & VC_CAB_REGULAR)    printf (" REGULAR");
  if (me->nVCType & VC_CAB_SPARE)      printf (" SPARE");
  if (me->nVCType & VC_CAB_REDUNDANT)  printf (" REDUNDANT");

  printf ("\n");
  printf("\tVCX instance data\n");
 
  sizx = om$dimension_of (varray = me->nVCx);
 
  printf (" nVCx     Ptype nPchnix nPmycpt nPocpt\n");
 
  for (i=0; i<sizx; i++) {
    printf(" nVCx     %d, %d, %d, %d\n",
                me->nVCx[i].nPtype,
                me->nVCx[i].nPchnix,
                me->nVCx[i].nPmycpt,
                me->nVCx[i].nPocpt);
  }
 
  printf ("\n");
  printf("\tVCCable instance data\n");

  sizx = om$dimension_of (varray = me->Connect_Data);

  status =
  om$send(msg = message VCRoot.VCGetProduct (&nProd, NULL),
     targetid = my_id );

  if (nProd == VC_PROD_FO)
  {
     printf (" CONNECT Lead Sig FibStat Mark <EndStat Mod Pos (Splice)> - <EndStat Mod Pos (Splice)>\n");
  }
  else
  {
     printf (" CONNECT Lead Sig FibStat Mark <EndStat Mod Pos> - <EndStat Mod Pos>\n");
  }
  for (i=0; i<sizx; i++)
  {
    struct GRid Cableobj;
    IGRchar ConnSplice0[VC_MAX_CCODE],ConnSplice1[VC_MAX_CCODE];
    IGRboolean bLeg;
    struct VCLdInfo	LdInfo;

    Cableobj.objid = my_id;
    Cableobj.osnum = OM_Gw_current_OS;

    strcpy( LdInfo.LeadNam, me->Connect_Data[i].LeadNam );
    VCGetAttrInfoForLead( &Cableobj, &LdInfo, 1, VC_MARKER_TYPE, &bLeg );
    if( bLeg && i==0 )
	printf("Legacy cable (without DataVLA)!\n");

    /* Added for tr179802033 for dumping splice instance data */
  if (nProd == VC_PROD_FO)
    {
       status = VCget_splice_id(Cableobj,sizx, 0,
                               me->Connect_Data[i].LeadNam,ConnSplice0);
       status = VCget_splice_id(Cableobj,sizx, 1,
                               me->Connect_Data[i].LeadNam,ConnSplice1);
       printf (" CONNECT %s %s %d %s <%d %s %s (%s)> - <%d %s %s (%s)>\n",
               me->Connect_Data[i].LeadNam, me->Connect_Data[i].SigNam,
                me->Connect_Data[i].nFibStat,
		LdInfo.Marker,
                me->Connect_Data[i].nEndStat[0],
                me->Connect_Data[i].FibEnds[0].szModId,
                me->Connect_Data[i].FibEnds[0].szPosId,
		ConnSplice0,
                me->Connect_Data[i].nEndStat[1],
                me->Connect_Data[i].FibEnds[1].szModId,
                me->Connect_Data[i].FibEnds[1].szPosId,
		ConnSplice1);
    }
    else
    {
       printf (" CONNECT %s %s %d %s <%d %s %s> - <%d %s %s>\n",
               me->Connect_Data[i].LeadNam, me->Connect_Data[i].SigNam,
                me->Connect_Data[i].nFibStat,
		LdInfo.Marker,
                me->Connect_Data[i].nEndStat[0],
                me->Connect_Data[i].FibEnds[0].szModId,
                me->Connect_Data[i].FibEnds[0].szPosId,
                me->Connect_Data[i].nEndStat[1],
                me->Connect_Data[i].FibEnds[1].szModId,
                me->Connect_Data[i].FibEnds[1].szPosId);

    }

  }

  printf ("\n");

  sizx = om$dimension_of (varray = me->Sect);

  printf (" SECTION  <cbstat type> numvert string parent start end\n");

  for (i=0; i<sizx; i++)
  {
    printf (" SECTION  <%6d %4d> v=%4d s=%4d p=%4d if=%4d it=%4d\n",
               me->Sect[i].cbstat,
               me->Sect[i].type,
               me->Sect[i].numvert,
               me->Sect[i].strno,
               me->Sect[i].parno,
               me->Sect[i].iFrom,
               me->Sect[i].iTo);
  }

  sizx = om$dimension_of (varray = me->Bend);
  printf (" BEND RAD <sectnum vertexnum radius> \n");
 
  for (i=0; i<sizx; i++) {
    printf (" BEND RAD <%6d %6d %f>\n",
               me->Bend[i].secno,
               me->Bend[i].vtxno,
               me->Bend[i].rad);
  }
 
  sizx = om$dimension_of (varray = me->Offset);
  printf(" OFFSET size = %d, type = %d\n", sizx, me->OffsetType);

  status =
  om$send (msg = message VCCable.VCCGetOffset( (void *)&pOffset, &NoOffsets ),
	targetid = my_id );
  as$status( msg = "VCCable.VCCGetOffset", action = GOTO_VALUE,
		value = wrapup );

  printf("%d terminals attached to this cable\n",NoOffsets);

  if( NoOffsets ){
    for( i=0 ; i<NoOffsets ; i++ )
    {
	  printf(" Offset Index is %d\n",(pOffset+i)->Index);
	  printf(" Offset vector-X:%f\n",(pOffset+i)->Offset[0]);
	  printf(" Offset vector-Y:%f\n",(pOffset+i)->Offset[1]);
	  printf(" Offset vector-Z:%f\n",(pOffset+i)->Offset[2]);
    }
  }
  
wrapup:

	_FREE( pOffset );
	End;
	return (OM_S_SUCCESS);
}
  
method      VCCbInsConTab (IGRlong        *msg;
                          IGRshort       *nNum;
                   struct VCcab_connect **Connect)
{

	SetProc(VCCable_VCCbInsConTab ); Begin

	*msg = MSSUCC;
	*nNum = om$dimension_of (varray = me->Connect_Data);
	*Connect = &me->Connect_Data[0];

	End;
	return (OM_S_SUCCESS);
}

/* This method is called to, free the section details when the Terminal Parent
is deleted. Currently it's being used in only one place( VCTplace.I ) called to
free the End of the cable after the deletion of the Terminal. This can be
extended for other parents of the cable object, like "point", "guides". Alwin */
 
method VCCInitSection( IGRlong *msg; struct GRid TerminalId )
{
 IGRint i, NumSect;
 IGRshort ParentI;
 IGRlong status;
 struct GRid ParentId;
 
SetProc( VCCable_VCCInitSection ); Begin
 
 NumSect  = om$dimension_of (varray = me->Sect);
 __DBGpr_int( " No. of Sections ", NumSect );
 
 for (i=0; i<NumSect; i++)
 {
    if( me->Sect[i].type == VCC_TERM_PARENT )
    {
       __DBGpr_com( " Section Type is VC_TERM_PARENT " );
 
       ParentI = me->Sect[i].parno;
       __DBGpr_int( " Parent Index ", ParentI );
 
       status =
       om$send ( msg = message VCCable.VCCbTerm( msg, ParentI, &ParentId ),
                                targetid = my_id );
 
       __DBGpr_obj( " Terminal Id at the Index ", ParentId );
 
       if( ( ParentId.objid == TerminalId.objid ) &&
           ( ParentId.osnum == TerminalId.osnum ) )
       {
         /* For this Particular section intialize the sections details
            so that it becomes a FREE VERTEX */
 
          __DBGpr_com( " Changing the Section Type to FREE_VERTEX " );
          me->Sect[i].type = VCC_FREE_VERTEX;
          me->Sect[i].parno = -1;
 
          me->nVCTopo--;
 
          __DBGpr_int( " No. of Topological Parents", me->nVCTopo );
       }
    }
 }
 
 End
 return OM_S_SUCCESS;
}


/*--------------------------------------
# Jan 98 Kosta
* To get connect point of the cable and corresponding terminal.
*
* PARAMETERS:
*
* O:   IGRlong          *msg    - status
*
* I/O: struct GRid      *Term   - if Term.objid != NULL_OBJID or Term == NULL
*				     will find the corresponding Connect Point.
*                                 else will find the terminal on that ConPoint.
*
* I/O: IGRshort     *ConnPoint  - Depending on Term/Term.objid will either 
*                                 return the connect point on that terminal,
*                                 or the terminal on that point.
*---------------------------------------
*
* RETURN status:
*
* 1 	if OK. 
* 0 	if can not find the input requested (Terminal or Point).
--------------------------------------*/
method     VCGetCptOnTerm( IGRlong      *msg;
                           struct GRid  *Term;
                           IGRshort     *ConnPoint)
{
  IGRint		status = OM_S_SUCCESS;
  IGRshort		Cpt0 = 0, Cpt1 = 1;
  struct GRid		Term0, Term1;

  SetProc(VCCable_VCGetCptOnTerm ); Begin;

  Term0.objid = Term1.objid = NULL_OBJID;

  status = om$send( msg      = message VCCable.VCCbTerm (msg, Cpt0, &Term0),
		    targetid = my_id); 
  __CheckSTS( status, "VCCbTerm failed for Cpt0", wrapup );

  status = om$send( msg      = message VCCable.VCCbTerm (msg, Cpt1, &Term1),
                    targetid = my_id);
  __CheckSTS( status, "VCCbTerm failed for Cpt0", wrapup );

  status = 0; 

/*------------------------
* Does the caller want to find connect point on input terminal? 
------------------------*/
  if ( Term && (Term->objid != NULL_OBJID) ) {

     if ( (Term0.objid == Term->objid) && (Term0.osnum == Term->osnum)) {

	if ( ConnPoint) *ConnPoint = Cpt0;
	status = OM_S_SUCCESS;

     }
     else if ( (Term1.objid == Term->objid) && (Term1.osnum == Term->osnum)) {

        if ( ConnPoint) *ConnPoint = Cpt1;
        status = OM_S_SUCCESS;

     }
  }
/*-----------------------
* Does the caller want to find terminal on input connect point? 
-----------------------*/
  else if ( ConnPoint ) {

     if ( *ConnPoint == Cpt0 ) {
	if (Term) *Term = Term0;
        status = OM_S_SUCCESS;
     }
     else if (*ConnPoint == Cpt1) {
        if (Term) *Term = Term1;
        status = OM_S_SUCCESS;
     }
  }


wrapup:
End;
  *msg = status;
  return (status); 
}

method VDgetObjDef(     long *msg ;
                        VDobjDef *myDef )
{

SetProc(VCCable_VDgetObjDef ); Begin

        myDef->info             = VD_I_ObjVCCable ;
        myDef->type             = 0 ;

        *msg    = MSSUCC ;

End;
        return (OM_S_SUCCESS)  ;
}


/* The following function is used by the below two methods */

IGRint OffsetTypeSize( short Type )
{
    switch( Type )
    {
        case 0 :    return  sizeof( struct VCOffset );
//      case 1 :    return  sizeof( struct VCOffsetXX );
                        /* Alternative structure when needed after 2.5 */
        default :   return 0 ;
    }
}
 
/* The following two methods added by Anand for TR179800045 */

/* For VCCSetOffset, all the arguments are inputs. nTermCount is the number 
   of terminals, while Offset, CONTAINS the coordinates of the cable vertex
   WITH RESPECT TO each of those terminals (ie., offset values).  In the
   present release Offset is a pointer of type struct VCOffset.  Even if the
   cable is connected to the terminal's origin, an offset corresponing to
   that terminal may be passed (as (0,0,0)) - Anand (Mar'98)*/

method VCCSetOffset(    void            *Offset;
                        IGRshort        nTermCount )
{
    IGRint status,size;
 
    SetProc( VCCabel_VCCSetOffset ); Begin
 
    __DBGpr_me();
 
    /* memory allocation */
    me->OffsetType = 0;
    size = nTermCount * OffsetTypeSize( me->OffsetType ) ;
    __DBGpr_int(" offset type", me->OffsetType);

    /* Allocate memory in the vla */
    status =
    om$vla_set_dimension( varray = me->Offset, size = size  );
    as$status(action = RET_STATUS);

    if( ! size ) goto quit;
    __DBGpr_int(" Size of me->offset",size);
 
    switch( me->OffsetType )
    {
        case 0 :
	    __DBGpr_int(" size of struct", sizeof(struct VCOffset) );
            memcpy(me->Offset, Offset, size);
            break;
//      case 1:
//          memcpy( me->Offset, &VCOffsetXX, size );
			/* Alternative structure when needed after 2.5 */
//          break;
        default:
            return OM_E_ABORT;
    }

    __DBGpr_int( " Dimension of the Offset array ",
                        om$dimension_of( varray = me->Offset ) );
quit:
    End
    return(OM_S_SUCCESS);
}
 

/* For method VCCGetOffset, all arguments are outputs. The caller 
   should ensure that the pointer OffsetVectors is freed after eliciting the
   required information - Anand */
 
method VCCGetOffset( void            **InfoOffset;
                     IGRshort        *nNbOffSets )
{
    IGRint status,size,i;

    SetProc( VCCabel_VCCGetOffset ); Begin
 
    __DBGpr_me();
    __CheckPtr( InfoOffset, "INVALID INPUT!", quit);
 
    size = (IGRshort) om$dimension_of( varray = me->Offset );
    __DBGpr_int(" Dimension of me->offset", size);

    *nNbOffSets = size / OffsetTypeSize(me->OffsetType);
    __DBGpr_int(" Number of offsets", *nNbOffSets);
 
    if( *nNbOffSets == 0 )
    {
	__DBGpr_com(" This cable is not connected to any terminal");
	goto quit;
    }
 
    /*
     * Check if we need to have the data back. (Ad 4/2/98).
     */
    if( InfoOffset == NULL ) goto quit;

    switch( me->OffsetType )
    {
	case 0 :
	  {
	    struct VCOffset *OffsetVectors;

	/* Allocate memory for the InfoOffset "structure" .... */
	    *InfoOffset= _MALLOC( *nNbOffSets, struct VCOffset );

	    OffsetVectors  = _MALLOC( *nNbOffSets, struct VCOffset );
	    __CheckPtr( OffsetVectors, "alloc OffsetVectors failed", quit);
	    memcpy(OffsetVectors, me->Offset, size);

	    *InfoOffset = OffsetVectors;

	    for( i=0 ; i < *nNbOffSets ; i=i+1 )
	    {
		__DBGpr_dbl(" Offsets-X",(OffsetVectors+i)->Offset[0]); 
		__DBGpr_dbl(" Offsets-Y",(OffsetVectors+i)->Offset[1]); 
		__DBGpr_dbl(" Offsets-Z",(OffsetVectors+i)->Offset[2]); 
		__DBGpr_int(" Offset Index",(OffsetVectors+i)->Index);
	    }

	    break;
	  }
//      case 1:
//          *OffsetVectors = _MALLOC( *nNbOffSets, struct VCOffSetXX );
                        /* Alternative structure when needed after 2.5 */
//          break;

	default:
	    return OM_E_ABORT;
    }


quit:
 
    End
    return(OM_S_SUCCESS);
}
method GRgetobjinfo(IGRlong     *msg;
             struct GRobj_info  *info)

{
  IGRchar      string[100];
  IGRchar      szRep[8];
  IGRchar      szStr[VC_MAX_TAGNO];
  IGRint       status, length=0;
  IGRint       whichEnd;
  struct GRid  parCable;

  SetProc( Md GRgetobjinfo ); Begin 

  status =
  om$send(msg = message VCRoot.GRgetobjinfo (msg,info),
         mode = OM_e_wrt_message,
     targetid = my_id );
  as$status(action = RET_STATUS );

  // if i'm a sub-cable, prepend the Subcable: string 
  // to the standard info string
  parCable.objid = NULL_OBJID;
  status = om$send(msg = message VCCable.VCAmISubCab( msg, &whichEnd,
                                                    &parCable, NULL, NULL),
		 targetid = my_id);

  if(
     (status&*msg&1) && 
     ((whichEnd==VCC_SPLIT_BEGIN) || (whichEnd==VCC_SPLIT_END)) &&
     (parCable.objid != NULL_OBJID)
    )
  {
      sprintf(string,"Subcable : %s", info->type);
      strcpy(info->type, string);
  }
  *msg = MSSUCC;
  End
  return(OM_S_SUCCESS);
}

end implementation VCCable;

