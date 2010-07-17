/* $Id: VRcable_gr.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / VRcable_gr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcable_gr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/16  20:05:14  pinnacle
# Replaced: vrcable/VRcable_gr.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
class implementation VRcable;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "dpdef.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "mautoparm.h"

extern	NDwait_batch();

#define AS_DEBUG 	1

/*--------------------------------------------------------------------------*/
/* method GRgetobjinfo:   just retrieve the info type			    */
/*--------------------------------------------------------------------------*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  *msg = MSSUCC;
  strcpy(info->type,"VRcable");
  return(OM_S_SUCCESS);
}

/*--------------------------------------------------------------------------*/
/* method GRlnproject   just to redirect correctly GRlnproject		    */
/*--------------------------------------------------------------------------*/
method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
		   IGRmatrix matrix; struct IGRline *line;
		   IGRpoint ln_pt,proj_pt; IGRdouble *t;
		   struct GRparms *proj_parms)
{
  int status;
  status = om$send(msg = message GRgraphics.GRlnproject( msg, matrix_type,
        			matrix, line, ln_pt,proj_pt, t, proj_parms),
		  p_chanselect = &AS_to_comp,
		  from = 0,
		  to = 0);
  as$status( action = RET_STATUS );
  return status;
}

/*--------------------------------------------------------------------------*/
/* method GRptproject   just to redirect correctly GRptproject		    */
/*--------------------------------------------------------------------------*/
method GRptproject(IGRlong *msg; IGRshort *matrix_type;
		   IGRmatrix matrix; IGRpoint point,proj_pt;
		   struct GRparms *proj_parms )
{
  int status;
  status = om$send(msg = message GRgraphics.GRptproject(msg, matrix_type,
        			matrix, point, proj_pt, proj_parms),
		  p_chanselect = &AS_to_comp,
		  from = 0,
		  to = 0);
  as$status( action = RET_STATUS );
  return status;
}

/*--------------------------------------------------------------------------*/
/* method GRvtadjseg  just to redirect correctly GRvtadjseg		    */
/*--------------------------------------------------------------------------*/
method GRvtadjseg(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  struct GRparms *vert_loc; IGRpoint point,vertex;
		  struct GRparms *seg_id1,*seg_id2 )
{
  int status;
  status = om$send(msg = message GRlinear.GRvtadjseg(msg,matrix_type, matrix,
	  			vert_loc, point, vertex, seg_id1, seg_id2),
		  p_chanselect = &AS_to_comp,
		  from = 0,
		  to = 0);
  as$status( action = RET_STATUS );
  return status;
}

/*--------------------------------------------------------------------------*/
/* method GRmodify 							    */
/*--------------------------------------------------------------------------*/
method GRmodify(IGRlong *msg; struct GRmd_env *md_env;
		struct GRparms *parms; IGRpoint point;
		struct IGRline *boreline; GRobjid *new_objid )
{
IGRint		status;
IGRint		cn_type;
struct GRid 	mygrid;

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  /*| call message GRcurve.GRmodify */
  status = om$send(msg = message GRcurve.GRmodify( msg, md_env, parms, 
						   point, boreline, new_objid),
		   p_chanselect = &AS_to_comp,
		   from = 0,
		   to = 0);
  as$status( action = RET_STATUS );

  /* do the wait batch */
  cn_type = ND_COMP;
  nd$wait_batch(	type       = GR_GEOM_POSTED, 
		  	l_object   = &mygrid,
			l_obj_info = &cn_type,
		  	nb_obj     = 1);

  *new_objid = my_id;

  return(status);
}

/*--------------------------------------------------------------------------*/
/* method GRxform 							    */
/*--------------------------------------------------------------------------*/
method GRxform( IGRlong *msg; struct GRmd_env *md_env;
		IGRshort *matrix_type; IGRmatrix matrix;
		GRobjid *new_objid )
{
IGRint		status;
IGRint		cn_type;
struct GRid	mygrid;

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  /*| call message GRgraphics.GRxform */
  status = om$send(msg = message GRgraphics.GRxform(msg,md_env,matrix_type,
					matrix,new_objid),
		   p_chanselect = &AS_to_comp,
		   from = 0,
		   to = 0);

  /* do the wait batch */
  cn_type = ND_COMP;
  nd$wait_batch(type = GR_GEOM_POSTED,
		l_object  = &mygrid,  l_obj_info = &cn_type,
		nb_obj    = 1);

  *new_objid = my_id;

  return(status);
}

/*--------------------------------------------------------------------------*/
/* method GRinsvertex							    */
/*---------------------------------------------------------------------------*/
method GRinsvertex(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *ref_parms; struct IGRline *boreline; 
		GRobjid *new_objid)
{
IGRint		status;
IGRint		cn_type;
struct GRid	mygrid, FeetList[2];
struct IGRbsp_curve	*curve;
IGRdouble	tparm;
IGRlong		segnum, index;

  /* The VRcable.GRinsvertex method allows to insert a vertex on all the 
  /* cable segments, with the exception of the border segments of the 
  /* cable. The border segments are having a predefined directions which 
  /* can not be changed.
  /* */

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  /*| get abstract geometry of object */
  status = om$get_objid_at_index( objid        = mygrid.objid,
				  p_chanselect = &AS_to_comp,
				  index        = 0,
				  objidaddr    = &FeetList[0].objid,
				  osnumaddr    = &FeetList[0].osnum );
  as$status(action = RET_STATUS);

  status = om$get_objid_at_index( objid        = mygrid.objid,
				  p_chanselect = &AS_to_comp,
				  index        = 1,
				  objidaddr    = &FeetList[1].objid,
				  osnumaddr    = &FeetList[1].osnum );
  if( !(status&1) ){
    /*| no tube defined */
    FeetList[1].objid = NULL_OBJID;
  }

  /*" Feet[0] : %d/%d\n", FeetList[0].objid, FeetList[0].osnum */
  /*" Feet[1] : %d/%d\n", FeetList[1].objid, FeetList[1].osnum */

  /*| Retrieve the geometry */
  status = om$send( msg    = message GRvg.GRgenabsg(	
					msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(IGRchar **)&curve  ) ,
		   senderid = NULL_OBJID,
	           targetid = FeetList[0].objid,
                   targetos = FeetList[0].osnum );
  as$status(action = RET_STATUS );
 
  if(( 1 & MAutoparms( msg, curve, &ref_parms->u, &segnum, &tparm)) && 
     (segnum >= 1)){

    /*| test on border segments */
    if( ( segnum == 1 ) || ( segnum == curve->num_poles - 1)){

      /*| end cable segment found */
      UI_status("Can not modify cable end segment.");
      *msg = MSFAIL;
      status = OM_E_ABORT;
      goto wrapup;
    }
    else{
      /*| find the index in the bendtable */
      if (( tparm == 0.0 ) || ( tparm == 1.0 )){
	/* new point must be inserted at a vertex	*/
	/*  point of the object				*/

	if ( tparm == 1.0 ){
	  /* adjust segment number so vertex	*/
	  /* will be inserted in correct place	*/

	  segnum += 1;
	}
	/* set up index	*/
	index = (segnum - 1);
      }
      else{  /*  ( tparm != 0.0 ) && ( tparm != 1.0 )  */

	/* set up index	*/
	index = segnum;
      }

      /* bend index is segment number minus one */
      index -= 1;

      /*| increment of the bendtable */
      status = om$send(msg = message VRcable.VRCbInsBendRad( msg, index ),
		       targetid = my_id );
      as$status(action = RET_STATUS );
      
      /*| call message GRcurve.GRinsvertex */
	*new_objid	= NULL_OBJID;
      status = om$send( msg = message GRcurve.GRinsvertex( msg, md_env, 
					ref_parms, boreline, new_objid ),
			targetid = FeetList[0].objid,
			targetos = FeetList[0].osnum );
      as$status(action = RET_STATUS );

      /*"new_objid = %d\n", *new_objid */

      /*" Feet[0] : %d/%d\n", FeetList[0].objid, FeetList[0].osnum */
      /*" Feet[1] : %d/%d\n", FeetList[1].objid, FeetList[1].osnum */

	/*| KLUDGE: wait modification in assoc (2.0 version ) */
   /*   status = om$send( msg = message ACncpx.ACchange_feet( 2, FeetList,md_env),
   /*		   	    targetid = my_id );
   /*   as$status(action = GOTO_VALUE, value = wrapup );
   /* */

/*| start Kludge */
	if( FeetList[0].objid != *new_objid && *new_objid != NULL_OBJID ){
		IGRlong	sts;
		IGRlong	ind;

		sts = om$send(	msg	= message GRgraphics.GRdelete
						( msg, md_env ),
				targetid = FeetList[0].objid,
				targetos = FeetList[0].osnum );
		as$status( sts = sts );

		/*| connect new feet */
		ind	= 0;
		sts = om$send(	msg	 = message GRconnector.GRrigidconn(
						msg,
						&mygrid,
						&ind ),
				targetid =  *new_objid );
		as$status ( sts = sts );

	}
/*| end Kludge */

      /* do the wait batch */
      cn_type = ND_COMP;
      nd$wait_batch(	type       = GR_GEOM_POSTED,
			l_object   = &mygrid,
			l_obj_info = &cn_type,
			nb_obj     = 1);
      *new_objid = my_id;
      goto wrapup;
    }   
  }
  else{
	/*| function MAuto .. failed */
	*msg = MSFAIL;
	status = OM_E_ABORT;
	goto wrapup;
  }

wrapup:

  GRabsg_del(curve);
  return( status );
}

/*--------------------------------------------------------------------------*/
/* method GRdelvertex							    */
/*--------------------------------------------------------------------------*/
method GRdelvertex(IGRlong *msg; struct GRmd_env *md_env;
		struct GRparms *ref_parms; GRobjid *new_objid )
{
IGRint		status;
IGRint		cn_type;
struct IGRbsp_curve *curve;
struct GRid	mygrid, str_id;
IGRdouble	tparm;
IGRlong		segnum;
IGRlong		index;

  /* initialize variables */
  status = OM_S_SUCCESS;
  *msg   = MSSUCC;

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  /*| get abstract geometry of object */
  status = om$get_objid_at_index( objid      = mygrid.objid,
				  p_chanselect = &AS_to_comp,
				  index        = 0,
				  objidaddr    = &str_id.objid,
				  osnumaddr    = &str_id.osnum );
  as$status(action = GOTO_VALUE, value = wrapup);

  /*| Retrieve the geometry */
  curve  = NULL;
  status = om$send( msg    = message GRvg.GRgenabsg( msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(IGRchar **)&curve  ) ,
		   senderid = NULL_OBJID,
	           targetid = str_id.objid,
                   targetos = str_id.osnum );
  as$status( action = RET_STATUS );

  /*| determine which vertex to delete */
  if (1 & MAutoparms( msg,curve, &ref_parms->u, &segnum, &tparm)){

    /*^
      printf(" segnum : %d \n", segnum );
      printf(" tparm  : %f \n", tparm );
      printf(" num_pol: %d \n", curve->num_poles );
     */

    if( ((segnum == 1) && ( tparm <= 0.5 )) || 
        ((segnum == (curve->num_poles-1)) && (tparm >= 0.5)) ){

      /*| selected begin/end point of cable element */
      UI_status("Can not delete cable end vertex.");
      *msg = MSFAIL;
      status = OM_E_ABORT;
      goto wrapup;
    }


    /*| find the vertex and the corresponding bend table index */
    if (tparm <= 0.5)	index = segnum;
    else 		index = segnum + 1;

    /* bend_table index */
    if( index < 3 )	index = 0;
    else		index = index - 2;
	
    /*" index : %d \n", index */

    /*| update the bend_table */
    status = om$send( msg = message VRcable.VRCbDelBendRad( msg, index ),
		     targetid = my_id );
    as$status(action = RET_STATUS );

    /*| call message GRcurve.GRdelvertex */
    status = om$send( msg = message GRcurve.GRdelvertex(msg, md_env, 
					     ref_parms, new_objid),
			p_chanselect = &AS_to_comp,
			from = 0,
			to = 0 );
    as$status(action = RET_STATUS );

    /* do the wait batch */
    cn_type = ND_COMP;
    nd$wait_batch(	type       = GR_GEOM_POSTED,
			l_object   = &mygrid,
			l_obj_info = &cn_type,
			nb_obj     = 1 );

    *new_objid = my_id;
    goto wrapup;
  }
  else{
    /*| function MAuto.. failed */ 
    *msg   = MSFAIL;
    status = OM_E_ABORT;
    goto wrapup;
  }

wrapup:

  GRabsg_del(curve);
  return( status );
}

/*--------------------------------------------------------------------------*/
/* method GRmoveseg							    */
/*--------------------------------------------------------------------------*/
method GRmoveseg(IGRlong *msg; struct GRmd_env *md_env;
		struct GRparms *seg_locate; IGRpoint from_pt; 
		struct IGRline *boreline)
{
IGRint		status;
IGRint		cn_type;
struct GRid	mygrid;

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  /*| call message GRlinear.GRmoveseg */
  status = om$send(msg = message GRlinear.GRmoveseg(msg, md_env, seg_locate, 
					from_pt, boreline),
		   p_chanselect = &AS_to_comp,
		   from = 0,
		   to = 0);

  /* do the wait batch */

  cn_type = ND_COMP;
  nd$wait_batch(type = GR_GEOM_POSTED,
		  l_object  = &mygrid,  l_obj_info = &cn_type,
		  nb_obj    = 1);

  return(status);
}

/*--------------------------------------------------------------------------*/
/* end of file								    */
/*--------------------------------------------------------------------------*/
end implementation VRcable;
