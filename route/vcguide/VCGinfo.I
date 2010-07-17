
/* $Id: VCGinfo.I,v 1.3 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide / VCGinfo.I
 *
 * Description:
 *   Information methods for cable guide
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCGinfo.I,v $
 *        Revision 1.3  2002/05/08 15:48:24  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:10:46  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/02  21:39:42  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by kddinov for route
#
# Revision 1.2  1998/02/24  23:07:34  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.8  1997/07/14  22:25:10  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/22  13:53:22  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by hverstee for cabling
#
# Revision 1.6  1997/03/19  16:22:20  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/06  23:08:00  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/31  00:09:30  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/20  20:53:32  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/25  17:40:08  pinnacle
# Replaced: vcguide/VCGinfo.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:40:56  pinnacle
# Created: vcguide/VCGinfo.I by hverstee for cabling
#
 *
 * History:
 *        06/20/96        hv         Initial
 *	 4/98		kdd		VDgetObjDef
 *
 *************************************************************************/

class implementation VCGuide;

/*
#define   MY_DEBUG	1
#define vdsDEBUG        1
*/
 
#include "VCmacros.h"
#include "VCdbaccess.h"
#include  "vds.h"
#include  "VDmsg.h"
#include "vrdbgmacros.h"


from     GRcurve  import   GRendpts;
from     GRcurve  import   GRtotlength;

extern GRclassid OPP_ASsource_class_id;



method VCGetModel ( IGRlong    *msg;
             struct GRid       *ModelId)
{

  IGRint      status;
  IGRlong     retmsg;
  IGRchar     szCode[VC_MAX_CCODE];

SetProc(VCGuide_VCGetModel ); Begin

  *msg = MSSUCC;

  ModelId->objid = NULL_OBJID;

  status =
  om$send (msg = message VCRoot.VCGetCode (szCode),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szCode)))
  {
    vc$guide_old (code = szCode, GRid = ModelId);
  }

End;
  return ( OM_S_SUCCESS );
}/* end VCGetModel */


/*------------------------------------------------------------------------- */

method GRgetobjinfo (IGRlong      *msg;
              struct GRobj_info   *info)
{
  IGRint         status;
  IGRchar        string[50];

SetProc(VCGuide_GRgetobjinfo ); Begin

  status =
  om$send (msg = message VCRoot.VCGetCode (string),
      targetid = my_id);

  if (VC_EMPTYSTR(string))
  {   /* (type?? rect or circle)  */
    if (me->nVCType & VCGD_FREED_XS)
      strcpy (string, "VAR-");

    if (me->nVCType & VCGD_SHAPE_ROUND)
      strcat (string, "ROUND");
    else
      strcat (string, "SQUARE");

    strcat (string, " Conduit");
  }

  switch ( (IGRint) (me->xform_chan & AC_VDS_REP) )
  {
    case AC_2D_REP: /*| representation : INTERNAL_2D */
      strcat ( string, "-$2D" );
      break;
    case AC_3D_REP: /*| representation :  INTERNAL_3D */
      strcat ( string, "-$3D" );
      break;
    case AC_ENV_REP:/*| representation :  ENVELOPE */
      strcat ( string, "-$Env" );
      break;
    default :               /*| ERROR : representation not found */
      break;
  }

  string[31] = '\0';
  strcpy ( info->type,string );

End;
  return (OM_S_SUCCESS);
}/* end GRgetobjinfo */

/*------------------------------------------------------------------------- */

method VCSetInstance    (IGRlong *msg; struct VCGenInfo *Instance)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRchar      szCode[VC_MAX_CCODE];

SetProc(VCGuide_VCSetInstance ); Begin

  /*A store data in my instance */
  status =
  om$send(msg = message VCRoot.VCSetInstance (msg,Instance),
         mode = OM_e_wrt_message,
     targetid = my_id );

  me->dSize1  = Instance->Attr.Guide.dSize1;
  me->dSize2  = Instance->Attr.Guide.dSize2;

  /*   get size from DB if code given */

  status =
  om$send (msg = message VCRoot.VCGetCode (szCode),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szCode)))
  {
    IGRshort                Index = -1;
    IGRshort                Map   = -1;
    struct ret_struct       AttrRst;
    struct GRid             ModelId;

    status =
    om$send(msg = message VCRoot.VCGetModel (&retmsg, &ModelId),
       targetid = my_id );

    if (ModelId.objid != NULL_OBJID)
    {
      status =
      om$send ( msg = message VCDB.VCGpAnum
                       (&retmsg, Index, Map, VC_X_DIAMETER_DB, &AttrRst),
           targetid = ModelId.objid,
           targetos = ModelId.osnum);

#ifdef MY_DEBUG
      printf (" diameter from db %f\n",AttrRst.var.root_pm_st.value);
#endif
      me->dSize1 = AttrRst.var.root_pm_st.value;
    }
    else
    {
      printf (" No DB model for %s\n",szCode);
      me->dSize1 = 0.0;
    }
  }

End;
  return OM_S_SUCCESS;
}/* end VCSetInstance */

/*------------------------------------------------------------------------- */

method VCGetInstance    (IGRlong *msg; struct VCGenInfo *Instance)
{
  IGRint  status;

SetProc(VCGuide_VCGetInstance ); Begin

  /*A get my generic instance */
  status =
  om$send(msg = message VCRoot.VCGetInstance (msg,Instance),
         mode = OM_e_wrt_message,
     targetid = my_id );

  Instance->Attr.Guide.dSize1 = me->dSize1;
  Instance->Attr.Guide.dSize2 = me->dSize2;

End;
  return OM_S_SUCCESS;
}/* end VCGetInstance */

/*------------------------------------------------------------------------- */

method VCGd_GetGRid (IGRlong         *msg;
              struct GRid            *LineGRid;
              struct GRmd_env        *md_env)
{
  IGRint             status;
  GRclassid          mclid;

  struct GRid        Paren;
  struct GRmd_env    LocEnv;

SetProc(VCGuide_VCGd_GetGRid ); Begin

#ifdef MY_DEBUG
  {
    struct GRid     mself;
    IGRchar         c200ClassName[200];

    mself.objid = my_id;
    mself.osnum = OM_Gw_current_OS;

    printf ("VCGd_GetGRid, mself <%d %d>\n",mself.objid,mself.osnum);

    om$get_classid (objid = mself.objid,
                    osnum = mself.osnum,
                p_classid = &mclid );

    om$get_classname(classid = mclid, classname = c200ClassName);
    printf("Parent class id %d, name %s \n",mclid, c200ClassName);
  }
#endif

  status =
  om$send( msg  = message VCRoot.VCParent
                         (msg, (IGRshort) 0, &Paren, NULL),
       targetid = my_id);
  as$status ();

    om$get_classid (objid = Paren.objid,
                    osnum = Paren.osnum,
                p_classid = &mclid );

  if (om$is_ancestry_valid (subclassid = mclid,
                           superclassid = OPP_ASsource_class_id )
                                      == OM_S_SUCCESS)
  {
    IGRlong    retmsg;

    LocEnv = *md_env;

    status =
    om$send (msg = message NDmacro.ACreturn_foot (&retmsg, "", LineGRid,
                                                  &LocEnv.md_env.matrix_type,
                                                   LocEnv.md_env.matrix),
        targetid = Paren.objid,
        targetos = Paren.osnum);
    as$status();
  }
  else
    *LineGRid = Paren;

#ifdef MY_DEBUG
  printf (" getgrid graphicsid %d %d\n",LineGRid->objid,LineGRid->osnum);
#endif

End;
  return (status);
}

/*------------------------------------------------------------------------- */

method ACgive_structure (int        *msg;
                         int        *direct_index;
                         char       *footname;
                  struct ret_struct *p_rs;
                  struct GRmd_env   *md_env)
{
  IGRint  status;

SetProc(VCGuide_ACgive_structure ); Begin

  if (strcmp (footname, VC_N_CAB_LENGTH_DB) == 0)
  {
    struct GRid     GoId;
    struct GRmd_env LocEnv;

    LocEnv = *md_env;

    status =
    om$send( msg = message VCGuide.VCGd_GetGRid 
                                       ((IGRlong *)msg, &GoId, &LocEnv),
        targetid = my_id);
    as$status( action = RET_STATUS );

    status =
    om$send( msg = message GRcurve.GRtotlength
                                ((IGRlong *)msg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                                  &p_rs->var.root_pm_st.value),
        targetid = GoId.objid,
        targetos = GoId.osnum );
  }
  else
  {
    status =
    om$send( msg = message VCRoot.ACgive_structure
                                (msg, direct_index, footname, p_rs, md_env),
            mode = OM_e_wrt_message,
        targetid = my_id );
  }

End;
  return (status);
}

method  VCCmpDef  (IGRlong    *msg;
                   CHARPTR    *pCHR)
{
SetProc(VCGuide_VCCmpDef ); Begin

  *msg = MSSUCC;

  pCHR[0] = VC_DIR_TAG;
  pCHR[1] = VC_DIR_GD;
  pCHR[2] = NULL;

End;
  return (OM_S_SUCCESS);
}

method VCDUMP   (IGRlong     *msg)
{
  IGRint     status;

SetProc(VCGuide_VCDUMP ); Begin

  status =
  om$send (msg = message VCRoot.VCDUMP (msg),
          mode = OM_e_wrt_message,
      targetid = my_id);

  printf (" TYPEFLAGS ");

  if (me->nVCType & VCGD_SPLINE)       printf (" SPLINE");
  if (me->nVCType & VCGD_STRING)       printf (" STRING");
  if (me->nVCType & VCGD_RWAY)         printf (" RWAY");
  if (me->nVCType & VCGD_FIXED_XS)     printf (" FIXED_XS");
  if (me->nVCType & VCGD_FREED_XS)     printf (" FREED_XS");
  if (me->nVCType & VCGD_SHAPE_ROUND)  printf (" ROUND");
  if (me->nVCType & VCGD_SHAPE_SQUARE) printf (" SQUARE");

  printf ("GUIDE sizes %f %f\n", me->dSize1, me->dSize2);

End;
  return (OM_S_SUCCESS);
}

method VDgetObjDef(     long *msg ;
                        VDobjDef *myDef )
{

        myDef->info             = VD_I_ObjVCGuide ;
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


end implementation VCGuide;

