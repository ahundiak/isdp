/* $Id: VDCmdDtDyn.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtDyn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtDyn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1996/08/27  18:12:54  pinnacle
# TR179601991
#
# Revision 1.2  1996/08/12  09:18:12  pinnacle
# Replaced: vddetail/cmd/VDCmdDtDyn.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      08/27/96        ah              TR179601991
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDetail;

/*
 * Revision:
 *
 * 06/94 Adz/Rad :Display of the view volume in mode dynamics is inproper
 *		  as result of modification of top view.
 */


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%safe
#include <math.h>
%endsafe

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "msdef.h"
#include "madef.h"
#include "growner.h"
#include "grgs.h"
#include "dpmacros.h"

#include "grmacros.h"

#include "detaildef.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "igrdef.h"
#include "AS_status.h"
#include "v_miscmacros.h"
#include "VDdetail.h"

/* include/prototypes */
#include "maidmx.h"
#include "mamulmx.h"
#include "matypemx.h"
/**
  #include "VDpr_detail.h"
 **/


#define	AS_DEBUG	1

from GRgraphics   import GRdelete;

struct dyn_args
{
   struct GRid          cs_obj_id;
   struct GRmdenv_info  cs_env;

   struct DPele_header  ele[6];
   struct IGRpolyline	polyline[6];

   IGRdouble		z_depth[2];
   IGRdouble		box[3];
   IGRdouble		delta_vec[3];
   IGRvector		x_vec;
   IGRvector		y_vec;
   IGRvector		z_vec;

   struct IGRdisplay    display;
};


method dynamics ( int dynamics ; int * sts )
{
  int		  status = OM_S_SUCCESS;

struct GRid		my_GRid;
struct GRmd_env		mod_env;
IGRlong			rc;
IGRint			i;
/* for the coordinate system */
struct GRid		object_id;
struct IGRlbsys		lb;

/* IGRdouble		ref_scale, units_scale,  */

IGRdouble		scale;	/* scale factor */

struct VDdet_formdata	fd_data;
IGRpoint		r_origin;	/* default range origin */
IGRvector		d_origin;	/* lower left corner - active origin */
IGRdouble		box[3];		/* range sizes */
IGRdouble		z_depth[2];	/* the z_depth values */

/* 
 * TR179601991, Update box,arrow and cs from here
 * because Solaris havdles dynamics differently from clix
*/

/*
printf("Entering Dynamics()\n");
*/
  /* Update the arrow and box */
    if (me->m_OldArrId.objid != NULL_OBJID) {
/*
printf("Erasing old arrow\n");
*/
      gr$display_object(
        object_id = &me->m_OldArrId,
        md_env    = &me->ModuleInfo,
        mode      = GRbe);

      vd_$bulk_delete(
        count  = 1,
        grids  = &me->m_OldArrId,
        theEnv = &me->ModuleInfo);

      me->m_OldArrId.objid = NULL_OBJID;
    }

    if (me->m_OldBoxId.objid != NULL_OBJID) {
/*
printf("Erasing old box\n");
*/
      gr$display_object(
        object_id = &me->m_OldBoxId,
        md_env    = &me->ModuleInfo,
        mode      = GRbe);

      vd_$bulk_delete(
        count  = 1,
        grids  = &me->m_OldBoxId,
        theEnv = &me->ModuleInfo);

      me->m_OldBoxId.objid = NULL_OBJID;
    }

    if (me->m_OldCsId.objid != NULL_OBJID) {
/*
printf("Erasing old cs\n");
*/
      gr$display_object(
        object_id = &me->m_OldCsId,
        md_env    = &me->ModuleInfo,
        mode      = GRbe);

      vd_$bulk_delete(
        count  = 1,
        grids  = &me->m_OldCsId,
        theEnv = &me->ModuleInfo);

      me->m_OldCsId.objid = NULL_OBJID;
    }

  if (me->m_UpdateArr == TRUE) {

    if (me->tmpList[VD_Obj_arrId].objid != NULL_OBJID) {
/*
printf("Displaying new arrow\n");
*/
      gr$display_object(
        object_id = &me->tmpList[VD_Obj_arrId],
        md_env    = &me->ModuleInfo,
        mode      = GRbd);
    }
    me->m_UpdateArr = FALSE;
  }

  if (me->m_UpdateBox == TRUE) {
    if (me->tmpList[VD_Obj_boxId].objid != NULL_OBJID) {
/*
printf("Displaying new box\n");
*/
      gr$display_object(
        object_id = &me->tmpList[VD_Obj_boxId],
        md_env    = &me->ModuleInfo,
        mode      = GRbd);
    }
    me->m_UpdateBox = FALSE;
  }

  if (me->m_UpdateCs == TRUE) {

    if (me->tmpList[VD_Obj_csId].objid != NULL_OBJID) {
/*
printf("Displaying new cs\n");
*/
      gr$display_object(
        object_id = &me->tmpList[VD_Obj_csId],
        md_env    = &me->ModuleInfo,
        mode      = GRbd);
    }
    me->m_UpdateCs = FALSE;
  }

  my_GRid.osnum = OM_Gw_current_OS;
  my_GRid.objid = my_id;
  mod_env = me->ModuleInfo;
  mod_env.md_id.objid = NULL_OBJID;

  /*" dynamics: %d\n", dynamics */

  if( ! dynamics ){
	*sts = MSSUCC;
	return( OM_S_SUCCESS );
  }


  MAidmx(&rc, lb.matrix);

  status = GRconstruct_cs(sts,	&mod_env,
				me->ActiveLevel, 
				&me->ActiveDisplay,
				GRIS_DISPLAYABLE,
				NULL,
				"GRgencs", 
				&lb,
				&object_id );

  /*" objid : %d,%d\n", object_id.objid, object_id.osnum */

  /* copy the instance */
  fd_data = me->fd_data;

  /*
   * Calcalution of the scale factor for the box,
   * which depends on : 
   *	- drawing view scale factor	( user defined )
   *	- local scale factor between intern and user distance units
   *    - reference scale factor between intern and reference intern
   *	  distance units.
   */

  /* user scale factor */
  VDdet_get_scale_fact( fd_data.text_scale, &scale );

#if 0
  /* Commented out for the TR#179527420 -Ravi 08/05/96  */

  /* reference scale factor */
  ref_scale = 1.0;
  VDdet_conv_ext_int( ref_scale, &ref_scale, me->VDref_os );
  
  /* local scale factor */
  units_scale = 1.0;
  VDdet_conv_ext_int( units_scale, &units_scale, me->VDcur_os );

  /* used scale factor */ 
  scale = scale * units_scale / ref_scale ;

#endif

  /*
   * calculate the box sizes of the drawview dynamics and the vector
   * offset of the event point and the lower left corner of the box.
   *
   *	.---------------------------------------.
   *    |					|
   *	|					|
   *	|	|y				|
   *    |	|				|
   *	|	.___x				|
   *	|      /(data.origin)			|
   *	|     /z				|
   *	|					|
   *    .---------------------------------------.
   *  (llc)
   *		d_origin = llc - fd_data.origin
   */


  /*
   * create the dynamics range
   */

  if( fd_data.vol_toggle & VD_DET_DEP_EXT ){
    /*| copy dependency extents */
    for(i=0;i<6;i++)
	fd_data.vw_volume[i] = fd_data.dep_volume[i];
  }

  /*
   * vector between event and lower left corner
   */
  for(i=0;i<3;i++)
    d_origin[i] = fd_data.vw_volume[i] - fd_data.origin[i] ;

  /*
   * project the points the plane
   */
  for(i=0;i<3;i++) r_origin[i] = 
	(fd_data.vw_volume[3+i] + fd_data.vw_volume[i]) / 2.0;
  
  VDproj_pnt_plane(&rc,	r_origin,
			fd_data.z_vec,
			me->fd_old.origin,
			r_origin );

  VDproj_pnt_plane(&rc, fd_data.origin,
			fd_data.z_vec,
			r_origin,
			fd_data.origin );
  {
	IGRshort	four, one;
	IGRdouble	fr_pnt[4], to_pnt[4];

	/* get d_origin */	
	four = 4; one = 1;
	/* copy the points */
	for(i=0;i<3;i++) fr_pnt[i] = d_origin[i];
	fr_pnt[3] = 1; 
	MAmulmx( &rc, &four, &four, &one, me->VDdet_matrix, fr_pnt, to_pnt );
	if( ! rc ) {
	  printf(" dynamics : fct MAmulmx failed\n");
	  goto quit;
	}

        for(i=0;i<3;i++) d_origin[i] = to_pnt[i] * scale;
	/*" v_ori:  %f %f %f\n", d_origin[0], d_origin[1], d_origin[2] */
  }
  
  /*
   * project the view volume values on the plane
   */
  VDproj_pnt_plane( &rc, &(fd_data.vw_volume[0]),
			 fd_data.z_vec,
			 r_origin,
			 &(fd_data.vw_volume[0]) );

  VDproj_pnt_plane( &rc, &(fd_data.vw_volume[3]),
			 fd_data.z_vec,
			 r_origin, 
			 &(fd_data.vw_volume[3]) );

  /* calculate the points is new object space */
  {
    IGRshort	four,one,j;
    IGRdouble	fr_pnt[4], to_pnt[4];

    four = 4; one = 1;
    for(i=0; i<2; i++){
      /* copy the points */
      for(j=0;j<3;j++) fr_pnt[j] = fd_data.vw_volume[i*3+j];
      fr_pnt[3] = 1; 
      MAmulmx( &rc, &four, &four, &one, me->VDdet_matrix, fr_pnt, to_pnt );
      if( ! rc ) {
        printf(" dynamics : fct MAmulmx failed\n");
        goto quit;
      }
      for( j=0; j<3; j++ ) fd_data.vw_volume[i*3+j] = to_pnt[j];
    }
  }

  /* define the polygon (box) extents */
  for(i=0;i<3;i++){
    /* get the vw_volume ranges */
    box[i] = (fd_data.vw_volume[3+i] - fd_data.vw_volume[i]) * scale;
  }

  /* get the z_depth values */
  if( fd_data.toggle & VD_DET_ZDEPTH_FLAG ){
    z_depth[0] = fd_data.usr_z_depth[0] * scale ;
    z_depth[1] = fd_data.usr_z_depth[1] * scale ;
  }
  else{
    z_depth[0] = fd_data.z_depth[0] * scale ;
    z_depth[1] = fd_data.z_depth[1] * scale ;
  }

  /* call the dynamics loop */
  VDdyn_cs_range(	&object_id,     /* coordinate system object */
			d_origin,       /* placement origin         */
			box,            /* dynamics sizes           */
		        z_depth,        /* z_depth volume           */
			fd_data.x_vec,  /* x_vector plane           */
			fd_data.y_vec,  /* y_vector plane           */
			fd_data.z_vec );/* z_vector plane           */

  status =
  om$send(msg = message GRgraphics.GRdelete( &rc, &mod_env),
	  targetid = object_id.objid,
	  targetos = object_id.osnum );
  as$status();

quit:
  return OM_S_SUCCESS;
}

IGRint VDdyn_cs_range( obj_id, vec, box, z_depth, x_vec, y_vec, z_vec )
struct GRid	*obj_id;
IGRdouble	*vec;
IGRdouble	*box;
IGRdouble	*z_depth;
IGRdouble	*x_vec;
IGRdouble	*y_vec;
IGRdouble	*z_vec;
{
IGRlong		rc;
IGRint		i;          
IGRboolean	dyn_on;       /* is dynamics on?             */
IGRboolean	inquire = 1;  /* inquire from DPdynflags     */
struct dyn_args	data;         /* arguments passed to DYmove  */
IGRdouble	pts_buffer[6*6];

IGRint   VDdisplay_cs_range();

  /*
   *  if dynamics is off then exit
   */

  DPdynflags (&rc, &inquire, &dyn_on, NULL);
  if (!dyn_on){ return (OM_S_SUCCESS); }

  data.cs_obj_id = *obj_id;
  MAidmx(&rc, data.cs_env.matrix);

  data.display.color	= 2;
  data.display.weight	= 0;
  data.display.style	= 0;

  data.z_depth[0] 	= z_depth[0];
  data.z_depth[1] 	= z_depth[1];

  for(i=0;i<3;i++){
    data.box[i]		= box[i];
    data.delta_vec[i]	= vec[i];
    data.x_vec[i]	= x_vec[i];
    data.y_vec[i]	= y_vec[i];
    data.z_vec[i]	= z_vec[i];
  }

  /* build the display buffers*/
  for(i=0;i<6;i++){
    data.polyline[i].num_points	= 2;
    data.polyline[i].points	= &(pts_buffer[i*6]);

    dp$build_dis_buffer(buffer	= &data.ele[i],
			type	= IGRPY,
			display_att = &data.display,
			geometry  = (struct IGRpolyline *)&(data.polyline[i]));
  }
  
  dp$dynamics (dyn_fun = VDdisplay_cs_range, information = &data);

  return( OM_S_SUCCESS );
}


IGRint VDdisplay_cs_range(dptr, point,
			mtx, objects, num_objects, 
			buffers, num_buffers,
			in_dummy1, in_dummy2, in_dummy3, 
			out_dummy1, out_dummy2, out_dummy3)

struct dyn_args       *dptr;
struct EX_button      *point;
IGRdouble             *mtx;
struct GRid          **objects;
IGRint                *num_objects;
struct DPele_header  **buffers;
IGRint                *num_buffers;
IGRchar               *in_dummy1;
IGRchar               *in_dummy2;
IGRchar               *in_dummy3;
IGRchar              **out_dummy1;
struct GRmdenv_info  **out_dummy2;
IGRchar              **out_dummy3;
{
IGRint		i;
IGRlong		rc;
IGRpoint	llc, lrc, ulc, urc;
IGRdouble       idmx[16];

  /*" point: %lf %lf %lf\n", point->x, point->y, point->z */ 

  dptr->cs_env.matrix[0]	= dptr->x_vec[0];
  dptr->cs_env.matrix[1]	= dptr->x_vec[1];
  dptr->cs_env.matrix[2]	= dptr->x_vec[2];
  dptr->cs_env.matrix[3]	= point->x;
  dptr->cs_env.matrix[4]	= dptr->y_vec[0];
  dptr->cs_env.matrix[5]	= dptr->y_vec[1];
  dptr->cs_env.matrix[6]	= dptr->y_vec[2];
  dptr->cs_env.matrix[7]	= point->y;
  dptr->cs_env.matrix[8]	= dptr->z_vec[0];       
  dptr->cs_env.matrix[9]	= dptr->z_vec[1];
  dptr->cs_env.matrix[10]	= dptr->z_vec[2];
  dptr->cs_env.matrix[11]	= point->z;
  dptr->cs_env.matrix[12]	= 0.0;
  dptr->cs_env.matrix[13]	= 0.0;
  dptr->cs_env.matrix[14]	= 0.0;
  dptr->cs_env.matrix[15]	= 1.0;

  MAtypemx (&rc, dptr->cs_env.matrix, &dptr->cs_env.matrix_type);

  /*
   * fill in the polylines
   *   line[0] =	llc --- lrc	(llc = low left corner)
   *   line[1] =	lrc --- urc	(urc = upper right corner)
   *   line[2] =	urc --- ulc
   *   line[3] =	ulc --- llc
   */

  /* the lower left corner */
  llc[0] = point->x + dptr->delta_vec[0];
  llc[1] = point->y + dptr->delta_vec[1];
  llc[2] = point->z + dptr->delta_vec[2];

  /*
   * Changed mtx to identity matrix, to solve dynamics problem - rmn
   * Top view is modified.
   *
   * for(i=0;i<3;i++){
   *   lrc[i] = llc[i] + mtx[i*4]   * dptr->box[i];
   *   ulc[i] = llc[i] + mtx[i*4+1] * dptr->box[i]; 
   *   urc[i] = llc[i] + mtx[i*4]   * dptr->box[i] + mtx[i*4+1] * dptr->box[i]; 
   * }
   */

  MAidmx(&rc, idmx);

  for(i=0;i<3;i++){
    lrc[i] = llc[i] + idmx[i*4]   * dptr->box[i];
    ulc[i] = llc[i] + idmx[i*4+1] * dptr->box[i]; 
    urc[i] = llc[i] + idmx[i*4]   * dptr->box[i] + idmx[i*4+1] * dptr->box[i]; 
  }

  for(i=0;i<3;i++){
    /* first line  */
    dptr->ele[0].geometry.polyline->points[i]	= llc[i];
    dptr->ele[0].geometry.polyline->points[3+i]	= lrc[i];

    /* second line */
    dptr->ele[1].geometry.polyline->points[i]	= lrc[i];
    dptr->ele[1].geometry.polyline->points[3+i]	= urc[i];

    /* third line  */
    dptr->ele[2].geometry.polyline->points[i]	= urc[i];
    dptr->ele[2].geometry.polyline->points[3+i]	= ulc[i];

    /* fourth line */
    dptr->ele[3].geometry.polyline->points[i]	= ulc[i];
    dptr->ele[3].geometry.polyline->points[3+i]	= llc[i];

    /* fifth line */
    dptr->ele[4].geometry.polyline->points[i]	= llc[i];
    dptr->ele[4].geometry.polyline->points[3+i]	= urc[i];

    /* sixth line */
    dptr->ele[5].geometry.polyline->points[i]	= lrc[i];
    dptr->ele[5].geometry.polyline->points[3+i]	= ulc[i];
  }

  /*
   *  set up the buffer pointers
   */

  *objects     = &dptr->cs_obj_id;
  *out_dummy2  = &dptr->cs_env;
  *num_objects = 1;

  *buffers     = dptr->ele;
  *num_buffers = 6;

  return (rc);
}

end implementation VDCmdDetail;
