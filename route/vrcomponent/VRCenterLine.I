/* $Id: VRCenterLine.I,v 1.5 2002/04/10 15:10:40 louis Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:        vrcomponent/VRCEnterLine.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRCenterLine.I,v $
 *      Revision 1.5  2002/04/10 15:10:40  louis
 *      TR5649-standardize tolerances
 *
 *      Revision 1.4  2001/09/02 19:34:41  ramarao
 *      Fixed TR# 5570.
 *
 *      Revision 1.3  2001/02/20 01:12:30  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/12 15:37:51  anand
 *      SP merge
 *
# Revision 1.1  2000/05/23  17:24:34  pinnacle
# Created: route/vrcomponent/VRCenterLine.I by lawaddel for Service Pack
#
# Revision 1.4  2000/03/31  19:17:34  pinnacle
# Replaced: vrcomponent/VRCenterLine.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/03/25  23:00:30  pinnacle
# Replaced: vrcomponent/VRCenterLine.I for:  by mdong for route
#
# Revision 1.3  1998/03/10  16:06:22  pinnacle
# Replaced: vrcomponent/VRCenterLine.I for:  by mdong for route
#
# Revision 1.2  1998/03/02  14:54:06  pinnacle
# Replaced: vrcomponent/VRCenterLine.I for:  by mdong for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/03/21  10:05:36  pinnacle
# Replaced: vrcomponent/VRCenterLine.I for:  by ashankar for route
#
# Revision 1.3  1996/11/20  13:26:12  pinnacle
# Replaced: vrcomponent/VRCenterLine.I for:  by ashankar for route
#
# Revision 1.1  1996/11/05  15:23:18  pinnacle
# Created: vrcomponent/VRCenterLine.I by r241_int for route
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/05/96        shankar         creation date
 *      03/28/00        law,alwin,anand TR179901233 - Fix centerline on generic
 *                                      view extraction.
 *      04/05/02        law             TR5649-standardize tolerance with
 *                                      VRGetTol
 *
 ***************************************************************************/

class implementation VRComponent;

#include <math.h>

#include "ndmacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "vrparameters.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "bstypes.h"
#include "ma.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRdef.h"
#include "VRMath.h"
#include "VRsize.h"
#include "VRPid.h"

/***
#define	vdsDEBUG	1
#define	vdserrDEBUG	1
***/

#include <stdio.h>
#include "vrdbgmacros.h"
#include "acrepdef.h"

#include "bslenvec.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsvalues.h" 
#include "bspl_pl_pl.h" 
#include "bsdistptpt.h" 
#include "maptalln.h" 
#include "maarc2ptc.h" 
#include "mabctoar.h" 
#include "matypemx.h" 
#include "ma3protmx.h" 
#include "mamulmx.h" 
#include "maidmx.h" 
#include "igr.h" 

#define AS_DEBUG        1

extern GRclassid OPP_GR3dcirarc_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GRbcsubbc_class_id;

from	GR3dcirarc	import  GRputarc;
from	GR3dlineseg	import  GRputpolyline;
from	VRCnrlSeg	import  VRGetTopo, VRget_terminators;
from    GRbcsubbc	import	EMcurve_by_poles;


/***********************************************************************/

method VDGetCenterLine(IGRlong        		*msg;
			struct GRmd_env		*md_env;
			IGRint         		*retCount;
                        struct GRid 		**retObjects )

{
  IGRint		status=OM_S_SUCCESS ;
  IGRdouble		chord_len = 0;
  IGRdouble		radius = 0;
  struct GRid		MyId;
  IGRlong		retmsg;
  struct ret_struct	bend_ang,
			t1_str, t2_str, br_str;

  SetProc( VRComponent_VDGetCenterLine ); Begin

  *msg=MSSUCC;

  __DBGpr_int(" nNbCpts ", me->nNbCpts );

  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;
  __DBGpr_obj(" MyId ", MyId );

  if( me->nNbCpts == 3 )
  {
    IGRdouble  Cpts1[6]; /* stores the two Cpts */
    IGRdouble  Cpts2[6]; /* stores the two Cpts */

     if( retObjects == NULL ){
        
	End
        return OM_S_SUCCESS;
     }

     *retCount = 2;

     status=
     om$send ( msg = message VRGeneric.VRGetCptGeom 
                                      (&retmsg, (IGRshort) 0, Cpts1,
                                             NULL, NULL, md_env),
           targetid = MyId.objid,
           targetos = MyId.osnum );
     as$status ( action = RET_STATUS );

     status=
     om$send( msg = message VRGeneric.VRGetCptGeom 
                                       (&retmsg, (IGRshort) 1, &Cpts1[3],
                                              NULL, NULL, md_env),
           targetid = MyId.objid,
           targetos = MyId.osnum );

     as$status ( action = RET_STATUS );


     Cpts2[0] = (Cpts1[0] + Cpts1[3] )/2;
     Cpts2[1] = (Cpts1[1] + Cpts1[4] )/2;
     Cpts2[2] = (Cpts1[2] + Cpts1[5] )/2;

     VRConstructLine( &retmsg, MyId, Cpts1, *retObjects, md_env );

     status=
     om$send ( msg = message VRGeneric.VRGetCptGeom 
                                       (&retmsg, (IGRshort) 2, &Cpts2[3],
                                              NULL, NULL, md_env),
           targetid = MyId.objid,
           targetos = MyId.osnum );

     as$status ( action = RET_STATUS );

     VRConstructLine( &retmsg, MyId, Cpts2, &( (*retObjects)[1]), md_env );
     status =  OM_S_SUCCESS;
     
  }
  else
  {
    IGRdouble  dCpts[6]; /* stores the two Cpts */
    IGRdouble  dVect[3]; /* temporary vector */

/**
    if ( (me->Desc.nItemNum == VR_PIPE ) && (me->Status & VR_CORRECTION) )
**/
    if ( (me->Desc.nItemNum == VR_PIPE ) )
    {
       if( retObjects == NULL )
       {
          *retCount = 1;
	  End 
          return OM_S_SUCCESS;
       }

      *retCount = 1;

      status=
      om$send ( msg = message VRGeneric.VRGetCptGeom 
                                      (&retmsg, (IGRshort) 0, dCpts,
                                             NULL, NULL, md_env),
           targetid = MyId.objid,
           targetos = MyId.osnum );

      as$status ( action = RET_STATUS );

      status=
      om$send ( msg = message VRGeneric.VRGetCptGeom 
                                       (&retmsg, (IGRshort) 1, &dCpts[3],
                                              NULL, NULL, md_env),
           targetid = MyId.objid,
           targetos = MyId.osnum );

      as$status ( action = RET_STATUS );

      VRConstructLine( &retmsg, MyId, dCpts, *retObjects, md_env );

      End
      return OM_S_SUCCESS;
    } 
    else if ( me->nNbCpts == 2 )
    {
      status=
      om$send ( msg = message VRGeneric.VRGetCptGeom 
                                      (&retmsg, (IGRshort) 0, dCpts,
                                             NULL, NULL, md_env),
           targetid =  my_id );

      as$status ( action = RET_STATUS );

      status=
      om$send ( msg = message VRGeneric.VRGetCptGeom 
                                       (&retmsg, (IGRshort) 1, &dCpts[3],
                                              NULL, NULL, md_env),
           targetid =  my_id );

      as$status ( action = RET_STATUS );

      __DBGpr_vec( "Cpt 0 ", dCpts );
      __DBGpr_vec( "Cpt 1 ", &dCpts[3] );

     BSmkvec( &retmsg, dVect, dCpts, &dCpts[3] );
     if( retmsg == BSSUCC )
	chord_len = BSlenvec ( &retmsg, dVect);
	
     /* Get's the Bend_sweep angle */
     status =
      om$send (msg = message VRComponent.ACgive_structure
                           ( (IGRint *) &retmsg, 0,
                            VR_N_BEND_ANG_DB, &bend_ang, md_env ),
           targetid =  my_id );
      as$status ( action = RET_STATUS );


     
      if ( bend_ang.var.root_pm_st.value > VRGetTol(VR_BENDRAD_TOL) )
      {
 
           status =
                om$send (msg = message VRComponent.ACgive_structure
                                ( (IGRint *) &retmsg, 0,
                                 "br", &br_str, md_env ),
           targetid =  my_id );

   	   if ( (status&retmsg&1) && (br_str.var.root_pm_st.value > VRGetTol(VR_BENDRAD_TOL) ) )
	   {
	      t1_str.var.root_pm_st.value = 0.0;
	      status =
		    om$send (msg = message VRComponent.ACgive_structure
				( (IGRint *) &retmsg, 0,
				  "t1", &t1_str, md_env ),
           targetid =  my_id );

	      t2_str.var.root_pm_st.value = 0.0;
		    
	      status =
		    om$send (msg = message VRComponent.ACgive_structure
				( (IGRint *) &retmsg, 0,
				  "t2", &t2_str, md_env ),
           targetid =  my_id );

		
	      if( (t1_str.var.root_pm_st.value > VRGetTol(VR_DIST_TOL)) && 
                  (t2_str.var.root_pm_st.value > VRGetTol(VR_DIST_TOL)))
	      {
		IGRdouble Cpts1[6], Cpts2[6], output[3];
		struct IGRline line;
		IGRdouble dist;
		struct GRid SegId[2];
		BSrc bsretcode;
		IGRint Seg_size;
		IGRshort dir;

                if( retObjects == NULL )
                {
                   End
                   *retCount = 3;
                   return OM_S_SUCCESS;
                }
                 *retCount = 3;

	        status =
		om$send(msg = message VRComponent.VRGetSupports
					( &retmsg, 2, SegId, &Seg_size ),
                        targetid =  my_id );

		as$status();

	        status =
		om$send(msg = message VRCnrlSeg.VRget_terminators
				( &retmsg, NULL, md_env, Cpts1, NULL ),
			senderid = NULL_OBJID,
			targetid = SegId[0].objid,
			targetos = SegId[0].osnum );
		as$status();

		dir = 1;
		dist = BSdistptpt( &bsretcode, Cpts1, &Cpts1[3] ) + 
				t1_str.var.root_pm_st.value;

		line.point1 = Cpts1;
		line.point2 = &Cpts1[3];

		MAptalln( &retmsg, &line, Cpts1, &dir, &dist, output );

		Cpts1[0] = Cpts1[3];
		Cpts1[1] = Cpts1[4];
		Cpts1[2] = Cpts1[5];
		Cpts1[3] = output[0];
		Cpts1[4] = output[1];
		Cpts1[5] = output[2];

                __DBGpr_vec("Cpts1-345",&Cpts1[3]);
                __DBGpr_vec("output",output);

                __DBGpr_com("construct line from Cpts1-345 to output");
      		VRConstructLine( &retmsg, MyId, Cpts1, *retObjects, md_env );

	        status =
		om$send (msg = message VRCnrlSeg.VRget_terminators
				( &retmsg, NULL, md_env, Cpts2, NULL ),
			senderid = NULL_OBJID,
			targetid = SegId[1].objid,
			targetos = SegId[1].osnum );
		as$status();

		dir = 1;
		dist = BSdistptpt( &bsretcode, Cpts2, &Cpts2[3] ) + 
				t2_str.var.root_pm_st.value;

		line.point1 = Cpts2;
		line.point2 = &Cpts2[3];

		MAptalln( &retmsg, &line, Cpts2, &dir, &dist, output );

		Cpts2[0] = Cpts2[3];
		Cpts2[1] = Cpts2[4];
		Cpts2[2] = Cpts2[5];
		Cpts2[3] = output[0];
		Cpts2[4] = output[1];
		Cpts2[5] = output[2];
                __DBGpr_vec("Cpts2-345",&Cpts2[3]);
                __DBGpr_vec("output",output);
                __DBGpr_com("construct line from Cpts2-345 to output");
      		VRConstructLine( &retmsg, MyId, Cpts2, &( (*retObjects)[1]), md_env );
		dCpts[0] = Cpts1[3];
		dCpts[1] = Cpts1[4];
		dCpts[2] = Cpts1[5];
		dCpts[3] = Cpts2[3];
		dCpts[4] = Cpts2[4];
		dCpts[5] = Cpts2[5];

		__DBGpr_vec( "Connect point 0 ", dCpts );
		__DBGpr_vec( "Connect point 1 ", &dCpts[3] );

		VRConstructArc( &retmsg, MyId, dCpts, br_str.var.root_pm_st.value, 
			bend_ang.var.root_pm_st.value, &( (*retObjects)[2]), md_env );

//              return OM_S_SUCCESS;
              }
              else
              {
                if( retObjects == NULL )
                {
                   *retCount = 1;
		   End
                   return OM_S_SUCCESS;
                }

                *retCount = 1;

		VRConstructArc( &retmsg, MyId, dCpts, br_str.var.root_pm_st.value, 
			bend_ang.var.root_pm_st.value, *retObjects, md_env );

//              return OM_S_SUCCESS;
              }
	    }
	    else
	    {
                if( retObjects == NULL )
                {
                   *retCount = 1;
		   End
                   return OM_S_SUCCESS;
                }

                *retCount = 1;
	        radius = chord_len / ( 2 * sin(VR_PI_RAD*bend_ang.var.root_pm_st.value/360.0) );
		VRConstructArc( &retmsg, MyId, dCpts, radius, 
			bend_ang.var.root_pm_st.value, *retObjects, md_env );

//               return OM_S_SUCCESS;
	    }
      } 
      else
      {
          if( retObjects == NULL )
          {
             *retCount = 1;
	     End ;
             return OM_S_SUCCESS;
          }

          *retCount = 1;
          VRConstructLine( &retmsg, MyId, dCpts, *retObjects, md_env );

//        return OM_S_SUCCESS;

      } /* end linear component treatment */
    } 
  }

	__DBGpr_int(" retCount ", *retCount );
#ifdef	vdsDEBUG
	if( retObjects == NULL ){
	  if( *retCount <= 1 ) VD_ShowObj( &(*retObjects[0]));
	  if( *retCount <= 2 ) VD_ShowObj( &(*retObjects[1]));
	  if( *retCount <= 3 ) VD_ShowObj( &(*retObjects[2]));
	}
#endif

	End
	return ( status );
}

IGRint VRConstructArc( IGRlong *retmsg, 
			struct GRid CompId,
			IGRdouble   *dCpts,
			IGRdouble   radius,
			IGRdouble   bend_ang,
			struct GRid *ret_obj,
			struct GRmd_env *md_env )
{
	BSrc bsretcode;
	struct GRvg_construct cst;
	struct GRsymbology symb;
	struct GRmd_env new_env, cur_env;
	struct GRid new_id;
	struct IGRarc arc;
	struct IGRplane plane1, plane2, plane3;
	IGRdouble OldMatrix[16], Org[3], dVect0[3], dVect1[3],dVect2[3];
	IGRdouble pl1_pnt[3], pl1_nor[3];
	IGRdouble pl2_pnt[3], pl2_nor[3], points[9];
        IGRint status=OM_S_SUCCESS;
	IGRshort mx_size;
	IGRlong size1, size2;
	IGRint i, flag;
	IGRpoint pt1, q, r;
	IGRvector u, v;

	SetProc( VRComponent_VRConstructArc ); Begin

	if( ret_obj == NULL )
	{
		End
        	return ( status );
	}

	symb.display_attr.color = 3;
	symb.display_attr.weight = 3;
	symb.display_attr.style = 3;
	symb.level = 1;

	size1 = sizeof( struct GRmd_env );
	gr$get_module_env(msg    = retmsg,
			sizbuf = &size1,
			buffer = &cur_env,
			nret   = &size2 );

	new_env.md_id.objid = cur_env.md_id.objid;
	new_env.md_id.osnum = cur_env.md_id.osnum;
	new_env.md_env.matrix_type = md_env->md_env.matrix_type;

	for(i=0; i<16; i++ )
		new_env.md_env.matrix[i] = md_env->md_env.matrix[i];

  	cst.msg		= retmsg;
      	cst.newflag	= FALSE;
      	cst.env_info	= &new_env;
      	cst.class_attr	= NULL;
      	cst.name	= NULL;
        cst.level       = symb.level;
      	cst.display	= &symb.display_attr;
      	cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	cst.geometry    = NULL;
     
	__DBGpr_obj(" CompId ", CompId );

        status =
	om$send(msg = message VRComponent.VRGetMatrix
                            ( retmsg, 0, NULL, OldMatrix, md_env ),
		mode = OM_e_wrt_message,
		senderid = NULL_OBJID,
                targetid = CompId.objid,
		targetos = CompId.osnum );
        as$status();

	if( fabs( bend_ang - 90.0 ) > VRGetTol(VR_ANGULAR_TOL) )
	{
        points[0] = dCpts[0]; points[1] = dCpts[1]; points[2] = dCpts[2] ;
        points[3] = OldMatrix[3]; points[4] = OldMatrix[7];
        points[5] = OldMatrix[11];
        points[6] = dCpts[3]; points[7] = dCpts[4]; points[8] = dCpts[5] ;

	ret_obj->objid = NULL_OBJID;
        ex$get_cur_mod( osnum = &ret_obj->osnum );
        status  = om$construct( classid = OPP_GRbcsubbc_class_id,
                         p_objid = &ret_obj->objid,
                         osnum   = ret_obj->osnum,
			 msg     = message GRbcsubbc.EMcurve_by_poles(
			   3, 0, 3, (IGRpoint *) points, NULL, &cst ) );
	}
	else
	{
	__DBGpr_mat(" md_env ", md_env->md_env.matrix );
	__DBGpr_mat(" OLDenv ", OldMatrix );
	__DBGpr_int(" status ", status );
	__DBGpr_int(" retmsg ", *retmsg );
		
	arc.prim_axis = radius;
	arc.sec_axis = radius;
	arc.start_angle = 0;
	arc.sweep_angle = (VR_PI_RAD*bend_ang)/180.0;
	for( i=0; i<16; i++ )
	  arc.rot_matrix[i]  = OldMatrix[i];

	Org[0]  = OldMatrix[3];
	Org[1]  = OldMatrix[7];
	Org[2]  = OldMatrix[11];
        __DBGpr_vec("org",Org);
        /*** block modified for tr179901233 ***/
        /**** Get dResultantVec from dVect0, dVect1 ***********/
        /**** Get dCompVectOrg from Org from coordinate origin ***/
        /*** Get dOriginArc from dCompVectOrg , dResultantVec ***/
	{
	  IGRdouble crdorg[3];
	  IGRvector	dResultantVec, dCompVectOrg, dOriginArc;

	  BSmkvec( retmsg, dVect0, Org, dCpts );
	  BSmkvec( retmsg, dVect1, Org, &dCpts[3] );

	  MAaddvc( retmsg, dVect0, dVect1, dResultantVec ); 

	  for(i=0;i<3;i++)
	  {
	    crdorg[i] = 0.0;
	  }

	  BSmkvec( retmsg, dCompVectOrg, crdorg, Org);

	  MAaddvc( retmsg, dCompVectOrg, dResultantVec, dOriginArc );

	  __DBGpr_vec( " Origin of Arc ", dOriginArc );

	  pt1[0] = dOriginArc[0];
	  pt1[1] = dOriginArc[1];
	  pt1[2] = dOriginArc[2];

	  __DBGpr_com(" Call MA3protmx ");
  	  MA3protmx( retmsg, pt1, dCpts, &dCpts[3], OldMatrix );

	  arc.origin[0] = pt1[0];
	  arc.origin[1] = pt1[1];
	  arc.origin[2] = pt1[2];
	  mx_size = 4;
	  __DBGpr_com(" Call MAinvmx ");
	  MAinvmx( retmsg, &mx_size, OldMatrix, OldMatrix );

	  for( i=0; i<16; i++ )
	    arc.rot_matrix[i]  = OldMatrix[i];

	}

	__DBGpr_mat(" ARCMatrix ", arc.rot_matrix );
	__DBGpr_vec(" ArcPoint ", arc.origin );
	__DBGpr_dbl(" ARCprim_axis ", arc.prim_axis );
	__DBGpr_dbl(" ARCsec_axis  ", arc.sec_axis );
	__DBGpr_dbl(" ARCst_angle  ", arc.start_angle );
	__DBGpr_dbl(" ARCsw_angle  ", arc.sweep_angle );

	__DBGpr_com(" Call GRaltconstruct ");
      	cst.geometry	= (char *)&arc;
        ex$get_cur_mod( osnum = &ret_obj->osnum );
        status  = om$construct( classid = OPP_GR3dcirarc_class_id,
			      p_objid = &ret_obj->objid,
			      osnum   = ret_obj->osnum,
			      msg     = message GRvg.GRaltconstruct(&cst) );
        as$status();

	__DBGpr_obj(" ret_obj ", *ret_obj );
	// VD_dumpObject( ret_obj, &cur_env );
	}

	if( (om$is_objid_valid ( osnum=ret_obj->osnum, objid=ret_obj->objid ))								 == OM_S_SUCCESS )
	{
		new_id.objid = NULL_OBJID ;
		new_id.osnum = ret_obj->osnum ;
		status = om$send( msg = message GRvg.GRxform( retmsg, &new_env, 
			&md_env->md_env.matrix_type, md_env->md_env.matrix,
							 &new_id.objid ),
			senderid = NULL_OBJID,
			targetid = ret_obj->objid,
			targetos = ret_obj->osnum );
		__DBGpr_obj(" new_id ", new_id );

		as$status();

		gr$put_symbology( object_id = ret_obj, symb = &symb );
	}

	__DBGpr_obj(" ret_obj ", *ret_obj );
	__DBGpr_int(" retmsg ", *retmsg );
	__DBGpr_int(" status ", status );
	End

        return ( status );
}


IGRint VRConstructLine( IGRlong		*retmsg, 
			struct GRid	CompId,
			IGRdouble	*dCpts,
			struct GRid	*ret_obj,
			struct GRmd_env *md_env )
{
	struct GRvg_construct cst;
	struct GRsymbology symb;
	struct GRmd_env new_env, cur_env;
	struct GRid new_id;
	struct IGRpolyline polyline;
	IGRlong size1, size2;
        IGRint status=OM_S_SUCCESS, i;

	SetProc( VRComponent_VRConstructLine ); Begin

	if( ret_obj == NULL )
	{
                End
        	return ( status );
	}

	symb.display_attr.color = 3;
	symb.display_attr.weight = 3;
	symb.display_attr.style = 3;
	symb.level = 1;

	size1 = sizeof( struct GRmd_env );
	gr$get_module_env(msg    = retmsg,
			sizbuf = &size1,
			buffer = &cur_env,
			nret   = &size2 );

	new_env.md_id.objid = cur_env.md_id.objid;
	new_env.md_id.osnum = cur_env.md_id.osnum;
	new_env.md_env.matrix_type = md_env->md_env.matrix_type;

	for(i=0; i<16; i++ )
		new_env.md_env.matrix[i] = md_env->md_env.matrix[i];

  	cst.msg		= retmsg;
      	cst.newflag	= FALSE;
      	cst.env_info	= &new_env;
      	cst.class_attr	= NULL;
      	cst.name	= NULL;
      	cst.display	= &symb.display_attr;
      	cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     
        polyline.num_points = 2;
        polyline.points =  dCpts;

        cst.geometry	= (char *)&polyline;
        ex$get_cur_mod( osnum = &ret_obj->osnum );
        status  = om$construct( classid = OPP_GR3dlineseg_class_id,
			      p_objid = &ret_obj->objid,
			      osnum   = ret_obj->osnum,
			      msg     = message GRvg.GRaltconstruct(&cst) );
        as$status();

	if( (om$is_objid_valid ( osnum=ret_obj->osnum, objid=ret_obj->objid ))								 == OM_S_SUCCESS )
	{
		status = om$send( msg = message GRvg.GRxform( retmsg, &new_env, 
			&md_env->md_env.matrix_type, md_env->md_env.matrix,
							 &new_id.objid ),
		senderid = NULL_OBJID,
		targetid = ret_obj->objid,
		targetos = ret_obj->osnum );

		as$status();

		gr$put_symbology( object_id = ret_obj, symb = &symb );
	}

	__DBGpr_obj(" ret_obj ", *ret_obj );
	End

        return ( status );
}

IGRint VRGetAdjacentPlanes( struct GRid CompId, 
				struct IGRplane *plane1, 
				struct IGRplane *plane2,
				struct GRmd_env *md_env )
{
	IGRlong		retmsg;
	IGRint		status = OM_S_SUCCESS;
	struct GRid	SegId[5];
	IGRint		num_sup;

	SetProc( VRComponent_VRGetAdjacentPlanes ); Begin

	status = om$send( msg = message VRComponent.VRGetSupports
					( &retmsg, 5, SegId, &num_sup),
			senderid = NULL_OBJID,
			targetid = CompId.objid,
			targetos = CompId.osnum );

	if( SegId[0].objid != NULL_OBJID && SegId[1].objid != NULL_OBJID )
	{
	     status = om$send( msg = message VRCnrlSeg.VRGetTopo(
					&retmsg, NULL, NULL, NULL,
					NULL, plane1, md_env ),
			senderid = NULL_OBJID,
			targetid = SegId[0].objid,
			targetos = SegId[0].osnum );

	    status = om$send( msg = message VRCnrlSeg.VRGetTopo(
					&retmsg, NULL, NULL, NULL,
					plane2, NULL, md_env ),
			senderid = NULL_OBJID,
			targetid = SegId[1].objid,
			targetos = SegId[1].osnum );

	}
	End
	return ( status & retmsg & 1 );
}

end implementation VRComponent;

