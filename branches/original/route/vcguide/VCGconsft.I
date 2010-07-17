
/* $Id: VCGconsft.I,v 1.2 2001/02/20 01:10:44 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcguide / VCGconsft.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCGconsft.I,v $
 *  Revision 1.2  2001/02/20 01:10:44  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *  Initial import to CVS
 *
# Revision 1.3  1999/04/23  07:49:54  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by apazhani for route
#
# Revision 1.2  1999/04/05  11:55:10  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/02  21:35:32  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by kddinov for route
#
# Revision 1.2  1998/02/21  19:00:30  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.6  1997/07/14  22:25:00  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/06  23:07:34  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/31  00:09:12  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/25  17:40:26  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/09  21:57:52  pinnacle
# Replaced: vcguide/VCGconsft.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:39:52  pinnacle
# Created: vcguide/VCGconsft.I by hverstee for cabling
#
 *
 * History:
 *  06/10/96  hv      initial
 *  03/26/99 Alwin      In the case of PID mode, the B-Spline was constructed
 *                      and the message was sent to wrong method. TR179900470
 *
 *************************************************************************/

class implementation VCGuide;

#include "VDmem.h"

#include "bsnorvec.h"
#include "bsprepcircp.h"
#include "bscveval.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "vrdbgmacros.h"

extern     GRclassid     OPP_EMSgenbs_class_id;
extern     GRclassid     OPP_GR3dlinestr_class_id;
extern     GRclassid     OPP_GR3dcirarc_class_id;
extern     GRclassid     OPP_GRbcsubbc_class_id;
extern     GRclassid     OPP_GRlinear_class_id;

from    EMSgenbs        import  EMplctbesrf;
from    EMSgenbs        import  EMmove_cross_section;

from    GRlinear        import  GRgetpolyline;



/*C regenerate the VCGuide tube */

method ACconstruct_feet(  IGRlong    *msg; 
                          IGRint      cn_type;
                          IGRint      count;
                   struct GRid        list []; 
                   struct GRmd_env   *md_env;
                          int        *fcount; 
                   struct GRid       *FeetList )
{
  IGRint             status;
  IGRlong            retmsg;
  IGRdouble          radi;
  GRclassid          parentClassId;
  IGRchar            szCode[VC_MAX_CCODE];

  struct GRid            GrPar;
  struct GRid            GrLoc;
  struct GRvg_construct  cnst_lis;
  struct GRsymbology     Symb;
  struct GRmd_env        LocEnv;

SetProc(VCGuide_ACconstruct_feet ); Begin

  /*A  the list[] has to contain the following objects:
    [0] : SYstem Attributes Collection
    [1] : User Attributes Collection
    [3] : ASsource, owning graphic string or spline
    */

  /*A initialization */
  *msg    = MSSUCC;
  *fcount = 0;
  radi    = me->dSize1 / 2.0;
  LocEnv  = *md_env;

  status =
  om$send (msg = message VCRoot.VCGetCode (szCode),
      targetid = my_id);

  /*   if DB code present refresh diameter     */

  if (!(VC_EMPTYSTR(szCode)))
  {
    IGRshort                Index = -1;
    IGRshort                Ind = -1;
    struct ret_struct       AttrRst;
    struct GRid             ModelId;

    status =
    om$send(msg = message VCRoot.VCGetModel (&retmsg, &ModelId),
       targetid = my_id );

    if (ModelId.objid != NULL_OBJID)
    {
      status =
      om$send ( msg = message VCDB.VCGpAnum
                       (&retmsg, Index, Ind, VC_X_DIAMETER_DB, &AttrRst),
           targetid = ModelId.objid,
           targetos = ModelId.osnum);

#ifdef MY_DEBUG
      printf (" diameter from db %f\n",AttrRst.var.root_pm_st.value);
#endif
      me->dSize1 = AttrRst.var.root_pm_st.value;
    }
  }

#ifdef MY_DEBUG
  printf ("construct feet for guide %d\n",my_id);
  printf ("type in %d\n",me->nVCType);
#endif

  FeetList->objid = GrLoc.objid = NULL_OBJID;
  FeetList->osnum = GrLoc.osnum = md_env->md_id.osnum;

  /*A   get the ID of the graphics parent    */

  status =
  om$send( msg = message VCGuide.VCGd_GetGRid (&retmsg, &GrPar, &LocEnv),
      targetid = my_id);
  as$status ( action = RET_STATUS );

  /*A   someone may have changed the parent to a spline, adapt my type
        if necessary           */

  GrPar = GrPar;

  om$get_classid (objid = GrPar.objid,
                  osnum = GrPar.osnum,
              p_classid = &parentClassId);
#ifdef MY_DEBUG
  {
    IGRchar         c200ClassName[200];


    om$get_classname(classid = parentClassId, classname = c200ClassName);
    printf("Parent class id %d, name %s \n",parentClassId, c200ClassName);
  }
#endif

  if (om$is_ancestry_valid (
             subclassid   = parentClassId,
             superclassid = OPP_GRlinear_class_id) == OM_S_SUCCESS)
  {   /*   force type to linestring   */
    status =
    om$send (msg = message VCRoot.VCSetType (VCGD_SPLINE, 0),
        targetid = my_id);

#ifdef MY_DEBUG
  printf ("type i-l %d\n",me->nVCType);
#endif
    status =
    om$send (msg = message VCRoot.VCSetType (VCGD_STRING, VCGD_STRING),
        targetid = my_id);
  }
  else
  {   /*   it's a spline now..... */
    status =
    om$send (msg = message VCRoot.VCSetType (VCGD_STRING, 0),
        targetid = my_id);

#ifdef MY_DEBUG
  printf ("type i-s %d\n",me->nVCType);
#endif
    status =
    om$send (msg = message VCRoot.VCSetType (VCGD_SPLINE, VCGD_SPLINE),
        targetid = my_id);
  }

#ifdef MY_DEBUG
  printf (" construct feet for id %d %d\n",GrPar.objid,GrPar.osnum);
  printf (" radius = %f\n",radi);
  printf ("type out %d\n",me->nVCType);
#endif

  status =
  om$send( msg = message GRvg.GRgetsymb (&retmsg,&Symb),
      targetid = GrPar.objid,
      targetos = GrPar.osnum);
  as$status ( action = RET_STATUS );

  cnst_lis.msg          = &retmsg;
  cnst_lis.env_info     = &LocEnv;
  cnst_lis.newflag      = FALSE;
  cnst_lis.properties   = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.level        = Symb.level;
  cnst_lis.display      = &(Symb.display_attr);

  cnst_lis.class_attr   = NULL;
  cnst_lis.name         = NULL;
  cnst_lis.geometry     = NULL;

  /*A Retrieve the geometry */

  if (me->nVCType & VCGD_STRING)
  {
    IGRint                 action, i;
    IGRdouble             *dLocBend;

    struct IGRpolyline     LineIn;

    LineIn.points = NULL;
    dLocBend      = NULL;

#ifdef MY_DEBUG
    printf (" get polyline %d %d\n",GrPar.objid, GrPar.osnum);
#endif

    /*C Get size of geometry */
    action = 0;
    status =
    om$send(msg = message GRlinear.GRgetpolyline
                          (&retmsg, &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &action, &LineIn),
       targetid = GrPar.objid,
       targetos = GrPar.osnum);
    as$status(action = GOTO_VALUE, value = NO_GRAPHIC);
    as$status(sts = retmsg, action = GOTO_VALUE, value = NO_GRAPHIC);

    /*C Get geometry */
    action = 1;

#ifdef MY_DEBUG
    printf (" retrieve polyline %d vertices\n",LineIn.num_points);
#endif

    LineIn.points = _MALLOC (3 * LineIn.num_points, IGRdouble);

    dLocBend =      _MALLOC (LineIn.num_points, IGRdouble);

    for (i=0; i<LineIn.num_points; i++)
     dLocBend[i] = me->dSize1 / 100.0;

    status =
    om$send(msg = message GRlinear.GRgetpolyline
                          (&retmsg, &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &action, &LineIn),
       targetid = GrPar.objid,
       targetos = GrPar.osnum);
    as$status(action = GOTO_VALUE, value = NO_GRAPHIC );
    as$status(sts = retmsg, action = GOTO_VALUE, value = NO_GRAPHIC);

    /*A construct the polyline tube */

#ifdef MY_DEBUG
    printf (" To tube - string , radius %f\n",radi);
#endif

    if (bVC_IS_2D( me->xform_chan ))
    {   /*  PID (schematic) generate heavy dashed line instead of tube   */
        /*  (and put it on top)                                          */

      Symb.display_attr.style  = 1;
      Symb.display_attr.weight = 5;

      cnst_lis.geometry     = (IGRchar *) &LineIn;

      status =
      om$construct (classid = OPP_GR3dlinestr_class_id,
                    p_objid = &GrLoc.objid,
		    msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
      as$status();
    }
    else
    {

      /*TBD   rectangular x section    */
      status =
      om$construct (classid = OPP_EMSgenbs_class_id,
                    p_objid = &GrLoc.objid,
                    msg     = message EMSgenbs.EMplctbesrf
                                           (&retmsg, md_env, GrPar,
                                           radi, dLocBend, &cnst_lis));
      as$status();
    }

#ifdef MY_DEBUG
    printf (" tube id %d %d\n",GrLoc.objid,GrLoc.osnum);
#endif

    if (retmsg != MSSUCC) printf (" ERROR FROM TUBE\n");
    *msg = retmsg;
    FeetList->objid = GrLoc.objid;

    _FREE (LineIn.points);
    _FREE (dLocBend);
  }
  else
  {
    IGRint                  j;
    IGRint                  ncros, ntrac;
    IGRint                  stat;
    IGRlong                 rc;
    IGRdouble               vec[3],nvec[3],stpoint[3], bstab[38];
    IGRdouble               ptdv1[6];
    IGRboolean              is_scal, are_sec;

    struct IGRbsp_curve    *bspcurve, bsp_arc;
    struct GRlc_info        cross, trace_inf;

    cross.geom_parms.u           = trace_inf.geom_parms.u           = 0;
    cross.geom_parms.v           = trace_inf.geom_parms.v           = 0;
    cross.geom_parms.polygon_inx = trace_inf.geom_parms.polygon_inx = 0;

    /*A   retrieve geometry   */

    trace_inf.module_info = LocEnv;
    trace_inf.located_obj = GrPar;

    status =
    om$send(msg = message GRvg.GRgenabsg
                          (&retmsg, &LocEnv.md_env.matrix_type,
                            LocEnv.md_env.matrix, (IGRchar **)&bspcurve),
       targetid = GrPar.objid,
       targetos = GrPar.osnum);
    as$status(action = GOTO_VALUE, value = NO_GRAPHIC);
    as$status(sts = retmsg, action = GOTO_VALUE, value = NO_GRAPHIC);

    if (bVC_IS_2D( me->xform_chan ))
    {   /*  PID (schematic) generate heavy dashed line instead of tube   */
        /*  (and put it on top)                                          */

      Symb.display_attr.style  = 1;
      Symb.display_attr.weight = 5;

      cnst_lis.geometry     = (IGRchar *) bspcurve;

      status =
      om$construct (classid = OPP_GRbcsubbc_class_id,
                    p_objid = &GrLoc.objid,
		    msg     = message GRgraphics.GRconstruct(&cnst_lis));
      as$status();
                    /*** Commented this line changed GRaltconstruct to
                    **   GRconstruct. TR179900470 Alwin
                    ** msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
                    ***/
      *msg = retmsg;
    }
    else
    {
      for (j=0; j<3; j++)
        trace_inf.proj_pnt[j] = bspcurve->poles[j];
#ifdef MY_DEBUG
      printf ("trace proj %f %f %f\n",trace_inf.proj_pnt[0],
                               trace_inf.proj_pnt[1],trace_inf.proj_pnt[2]);
#endif

      bsp_arc.poles   = &bstab[0];
      bsp_arc.knots   = &bstab[21];
      bsp_arc.weights = &bsp_arc.knots[10];

      ncros = 1;
 
      BScveval (bspcurve , 0.0, 1, (IGRpoint *)ptdv1, &retmsg);
      BSnorvec(&retmsg,&ptdv1[3]);

      nvec[0] = -1.0*ptdv1[4];
      nvec[1] = ptdv1[3];
      nvec[2] = 0.0;

      if( (nvec[0] == 0.0) && (nvec[1] == 0.0) ) nvec[0] = 1.0;

      BScrossp(&retmsg,&ptdv1[3],nvec,vec);

      BSnorvec(&retmsg,vec);

      for (j=0;j<3;j++)
        stpoint[j] = ptdv1[j] + radi*vec[j];
#ifdef MY_DEBUG
      printf ("stpoint %f %f %f\n",stpoint[0],stpoint[1],stpoint[2]);
      printf ("ptdv1a  %f %f %f\n",ptdv1[0],ptdv1[1],ptdv1[2]);
      printf ("ptdv1b  %f %f %f\n",ptdv1[3],ptdv1[4],ptdv1[5]);
      printf ("vec     %f %f %f\n",vec[0],vec[1],vec[2]);
#endif

      BSprepcircp(&rc,&ptdv1[0],stpoint,&ptdv1[3],&bsp_arc,nvec,&stat);
      if (rc != BSSUCC)
        printf (" error prepcirc %d\n",rc);

/*--------------------------------------------------------------------------*/
/*----  add knots to get a better representation of the surface         ----*/
/*--------------------------------------------------------------------------*/
/***************************************************************************
    ????? different algorithms, see srf_bend.u srf_tube.u ????

      mul = 2;
      u = 1.0 / 6.0;
      enough_mem = TRUE;

      BSadd_ktr(&rc,&bsp_arc,&u,&mul,&enough_mem);
      if( rc != BSSUCC ) write( "error BSadd_ktr u = 0.1666 \n");

      u = 0.5;
      BSadd_ktr(&rc,&bsp_arc,&u,&mul,&enough_mem);
      if( rc != BSSUCC ) write( "error BSadd_ktr u = 0.5 \n");

      u = 5.0 / 6.0;
      BSadd_ktr(&rc,&bsp_arc,&u,&mul,&enough_mem);
      if( rc != BSSUCC ) write( "error BSadd_ktr u = 0.8333 \n");
****************************************************************************/

      cnst_lis.geometry   = (char *)&bsp_arc;
      cross.located_obj.objid = NULL_OBJID;
      cross.located_obj.osnum = md_env->md_id.osnum;

      status =
      om$construct(classid = OPP_GR3dcirarc_class_id,
                   p_objid = &cross.located_obj.objid,
                   msg     = message GRgraphics.GRconstruct (&cnst_lis));

#ifdef MY_DEBUG
      printf (" skin surf id %d %d\n",cross.located_obj.objid,
                                      cross.located_obj.osnum);
#endif

      for (j=0; j<3; j++)
      cross.proj_pnt[j] = bsp_arc.poles[j];

#ifdef MY_DEBUG
      printf ("cross.proj %f %f %f\n",cross.proj_pnt[0],cross.proj_pnt[1],
                                      cross.proj_pnt[2]);
#endif

      trace_inf.module_info = LocEnv;
      cross.module_info = *md_env;

      ncros        = 1;
      ntrac        = 1;
      is_scal      = FALSE;
      are_sec      = TRUE;

      cnst_lis.geometry = NULL;

      /*TBD   rectangular x section    */

      status =
      om$construct(classid = OPP_EMSgenbs_class_id,
                   p_objid = &GrLoc.objid,
                   msg     = message EMSgenbs.EMmove_cross_section
                                        (&retmsg, &cnst_lis, ncros,
                                          &cross, ntrac, &trace_inf, is_scal,
                                          are_sec, NULL, NULL, NULL, NULL));
      as$status();

      *msg = retmsg;

#ifdef MY_DEBUG
      printf (" tube id %d %d\n",GrLoc.objid,GrLoc.osnum);
#endif

      if (retmsg != MSSUCC)
      {
        printf ("ERROR CONSTRUCT TUBE %d\n",retmsg);
        GrLoc = cross.located_obj;
        /*  for now, place spline on top ......   */
      }
      else
      {
        status =
        om$send (msg = message GRgraphics.GRdelete (&retmsg, md_env),
            targetid = cross.located_obj.objid,
            targetos = cross.located_obj.osnum);
        as$status();
      }
    }
  }

  *fcount = 1;
  FeetList->objid = GrLoc.objid;
#ifdef MY_DEBUG
  printf (" return construct %d %d\n",FeetList->objid, FeetList->osnum);
#endif

/*------------------------
* for CR179702225 
* Do not retrive symbology from file. NDplace gets it from my parent.
* Do not call VDSroot.VDputAttrDrivenSymb.
-----------------------*/

  End
  return OM_S_SUCCESS ;

NO_GRAPHIC :

  printf (" NO+GRAPHIC construct feet\n");

  *fcount = 0;
  End
  return OM_E_ABORT;
}/* end ACconstruct_feet */

end implementation VCGuide;
