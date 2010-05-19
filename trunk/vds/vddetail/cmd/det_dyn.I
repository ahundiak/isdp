/* $Id: det_dyn.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / det_dyn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: det_dyn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
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
 *
 * -------------------------------------------------------------------*/

class implementation VDSdetail;


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
#include "dpdef.h"
#include "dpmacros.h"
#include "detaildef.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "AS_status.h"
#include "VDdetail.h"

/* include/prototypes */
#include "maidmx.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "bstypes.h"
#include "bsdistptpt.h"

#define	AS_DEBUG	1

from	GRgraphics	import	GRdisplay, GRdelete, GRxform, GRaltconstruct;
from	NDnode		import	NDs_compute_node;
from	EMSblock	import	EMboxby2pt, EMextract_vtx_hwd;

struct dyn_args
{
   struct GRid			dyn_id[4];	/* c.s. + Box	*/
   struct GRmdenv_info		dyn_env[4];
   IGRint			dyn_nb;

   struct GRmd_env		md_env;
   IGRpoint			origin;		/* relative - absolute */
};

extern	GRclassid	OPP_EMSblock_class_id,
                	OPP_GR3dlineseg_class_id;

method dynamics ( int dynamics ; int * sts )
{
IGRint			status = OM_S_SUCCESS;
IGRboolean		dyn_on;       /* is dynamics on?             */
IGRboolean		inquire = 1;  /* inquire from DPdynflags     */

struct GRmd_env		mod_env;
struct var_list		var_list[2];
IGRlong			msg, error_var, num_bytes, rc;
IGRint			i,j;
struct IGRlbsys		lb;			/* for the coordinate system */
struct  IGRpolyline     geometry;
IGRdouble		scale, r_scale, u_scale;	/* scale factors */

IGRdouble		pr_vec[3];
IGRdouble		depths[2];
IGRdouble		dist, pvolume[6], volume[6];
IGRpoint		vol_origin;	/* default view volume origin */
IGRpoint		pr_origin;	/* projected user defined origin */
IGRpoint		delta_origin;

struct dyn_args		VDdata;         /* arguments passed to DYmove  */
struct GRvg_construct   const_list;
IGRshort		one, four;
IGRdouble		fpnt[4], tpnt[4];
IGRint			VDdisplay_cs_range();

  if( ! dynamics ){
	*sts = MSSUCC;
	return( OM_S_SUCCESS );
  }
  /*
   * check on the dynamics option.
   */
  DPdynflags (&msg, &inquire, &dyn_on, NULL);
  if (!dyn_on) return (OM_S_SUCCESS); 

  /*
   * get the orientation of the view
   */
  mod_env.md_id.objid = NULL_OBJID;
  mod_env = me->ModuleInfo;

  var_list[0].var               = VIEW_ROTATION;
  var_list[0].var_ptr           = (IGRchar *) mod_env.md_env.matrix;
  var_list[0].num_bytes         = 16 * sizeof (IGRdouble) ;
  var_list[0].bytes_returned    = &num_bytes;
  var_list[1].var               = END_PARAM ;

  status =
  dp$inq_set_gragad (   msg         = &rc,
                        inq0_set1   = 0,
                        calc_info   = 0,
                        update      = 0,        /* or 1 KLUDGE */
                        osnum       = me->event1.event.button.osnum,
                        gragad_objid = me->event1.event.button.objid,
                        which_error = &error_var,
                        var_list    = var_list ) ;
  if ( !(status & 1) ){
    printf(" construct_objview : macro inq_set_gragad failed \n");
    om$report_error( sts = status );
    goto quit;
  }

  /* initialization dynamics data structure */
  VDdata.dyn_nb = 4;
  for(i=0;i<VDdata.dyn_nb;i++) VDdata.dyn_id[i].objid = NULL_OBJID;
  for(i=0;i<VDdata.dyn_nb;i++) VDdata.dyn_id[i].osnum = me->ModuleInfo.md_id.osnum;

  VDdata.md_env = mod_env; 
  pr_mat( "mod_env", 4, 4,  mod_env.md_env.matrix );

  /*
   * create the coordinate system ( dyn_id[0] )
   */
  MAidmx(&rc, lb.matrix);
  status =
  GRconstruct_cs(sts,	&me->ModuleInfo,	me->ActiveLevel, 
			&me->ActiveDisplay,	GRIS_DISPLAYABLE,
			NULL,	"GRgencs",	&lb,
			&VDdata.dyn_id[0] );

  printf(" c.s. : %d,%d\n", VDdata.dyn_id[0].objid, VDdata.dyn_id[0].osnum );

  /*
   * Calcalution of the scale factor for the volume,
   * which depends on : 
   *	- drawing view scale factor	( user defined )
   *	- local scale factor between intern and user distance units
   *    - reference scale factor between intern and reference intern
   *	  distance units.
   */

  r_scale = 1.0;
  u_scale = 1.0;
  VDdet_get_scale_fact(me->fd_data.text_scale, &scale ); /* user */
  VDdet_conv_ext_int( r_scale, &r_scale, me->VDref_os ); /* reference */
  VDdet_conv_ext_int( u_scale, &u_scale, me->VDcur_os ); /* local */
  scale = scale * u_scale / r_scale ;

  /*
  /*
   * calculate the volume sizes of the drawview dynamics and the vector
   * offset of the event point and the lower left corner of the volume.
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
   */


  /*
   * create the dynamics view volume.
   *	- get defined view volume.
   *	- project to plane on selected plane.
   *	- extent with z_depth values.
   */

  /* projection vector */
  for(i=0;i<3;i++) pr_vec[i] = me->fd_data.z_vec[i];

  /* projection depths */
  for(i=0;i<2;i++)
    depths[i] = ( me->fd_data.toggle & VD_DET_ZDEPTH_FLAG )
		?  me->fd_data.usr_z_depth[i] : me->fd_data.z_depth[i] ;

  /* projection volume */
  for(i=0;i<6;i++)
    volume[i] = ( me->fd_data.vol_toggle & VD_DET_DEP_EXT )
	        ? me->fd_data.dep_volume[i] : me->fd_data.vw_volume[i];

  /* relative origin */
  for(i=0;i<3;i++) delta_origin[i] = volume[i] - me->fd_data.origin[i];

  /* projection volume origin */
  for(i=0;i<3;i++) vol_origin[i] = (volume[3+i] + volume[i]) / 2.0;

  /*
   * Project user volume origin to view volume origin.
   */
  VDproj_pnt_plane( &rc, vol_origin, pr_vec, me->fd_old.origin, vol_origin );

  /*
   * project the user defined view volume origin to view plane origin.
   */
  VDproj_pnt_plane( &rc, me->fd_data.origin, pr_vec, vol_origin, pr_origin);
  
  /*
   * project the view volume values on the plane
   */
  VDproj_pnt_plane( &rc, &(volume[0]), pr_vec, vol_origin, &(volume[0]));
  VDproj_pnt_plane( &rc, &(volume[3]), pr_vec, vol_origin, &(volume[3]));
  printf(" [0]: %f, %f, %f \n", volume[0], volume[1], volume[2] );
  printf(" [0]: %f, %f, %f \n", volume[3], volume[4], volume[5] );

  /*
   * extent the view volume with the user defined z_depths
   */
  for(i=0;i<3;i++){
    volume[i]   += pr_vec[i] * -1.0 ; 	/* depths[0]; */
    volume[3+i] += pr_vec[i] * 1.0 ;	/* depths[1]; */
  }
  /*
   * move the points to the relative origin
   */
  for(i=0;i<3;i++) volume[i]   -= vol_origin[i];
  for(i=0;i<3;i++) volume[3+i] -= vol_origin[i];

  /*
   * test the sizes of the box.
   */

  dist = BSdistptpt( &rc, &(volume[0]), &(volume[3]) );
  if( dist < 2 ){
    for( i=0 ; i<3 ; i++ ) volume[i] -= 1;
    for( i=3 ; i<6 ; i++ ) volume[i] += 1;
  }

  /*
   * calculation of the objects in the new environment.
   */
  pr_mat( "det_matrix",4,4,me->VDdet_matrix );
  one  = 1;
  four = 4;
  for( i=0 ; i<3 ; i++ ) fpnt[i] = delta_origin[i];
  fpnt[3] = 1.0;
  MAmulmx( &rc, &four, &four, &one, me->VDdet_matrix, fpnt, tpnt );
  if( ! rc ){
    printf(" VDSdetail.dynamics: fct MAmulmx failed\n");
    goto quit;
  }
  for(i=0;i<3;i++) VDdata.origin[i] = tpnt[i];

  for( j=0 ; j<2 ; j++ ){
    for( i=0 ; i<3 ; i++ ) fpnt[i] = volume[j*3+i];
    fpnt[3] = 1.0;
    MAmulmx( &rc, &four, &four, &one, me->VDdet_matrix, fpnt, tpnt );
    if( ! rc ){
      printf(" VDSdetail.dynamics: fct MAmulmx failed\n");
      goto quit;
    }
    /*
     * set the scale factor with the volume.
     */
    for( i=0 ; i<3 ; i++ ) volume[j*3+i] = tpnt[i] * scale ;
  }

  printf(" [2]: %f, %f, %f \n", volume[0], volume[1], volume[2] );
  printf(" [2]: %f, %f, %f \n", volume[3], volume[4], volume[5] );

  /*
   * construct the box (EMSblock)
   */
  const_list.msg = &msg;
  const_list.newflag = FALSE;
  const_list.name = NULL;
  const_list.class_attr = NULL;
  const_list.env_info = &me->ModuleInfo;
  const_list.properties = GRIS_DISPLAYABLE;
  const_list.level = me->ActiveLevel;
  const_list.display = &me->ActiveDisplay;
  const_list.geometry = NULL;

  status =
  om$construct( msg = message EMSblock.EMboxby2pt( &msg,
						&const_list,
						&(volume[0]),
						&(volume[3])),
		classid = OPP_EMSblock_class_id,
		p_objid = &(VDdata.dyn_id[1].objid),
		osnum	= VDdata.dyn_id[1].osnum );
  as$status();
  printf(" volume: %d,%d\n", VDdata.dyn_id[1].objid, VDdata.dyn_id[1].osnum );

  /* give linesegments of volume */
  geometry.num_points = 2;
  const_list.geometry = (char *)&geometry;

  VDproj_pnt_plane( &rc, &(volume[0]), me->fd_data.x_vec,
			 &(volume[3]), &(pvolume[0]));
  VDproj_pnt_plane( &rc, &(volume[3]), me->fd_data.x_vec,
			 &(volume[0]), &(pvolume[3]));

  printf(" pvol: %f, %f, %f \n", pvolume[0], pvolume[1], pvolume[2] );
  printf(" pvol: %f, %f, %f \n", pvolume[3], pvolume[4], pvolume[5] );

  for(i=0;i<2;i++){
    geometry.points = ( i ) ? volume : pvolume ;
    status =
    om$construct( msg = message GRgraphics.GRaltconstruct ( &const_list ),
                  classid = OPP_GR3dlineseg_class_id,
                  p_objid = &VDdata.dyn_id[i+2].objid,
                  osnum   = VDdata.dyn_id[i+2].osnum );
    as$status();

    printf("line[%d]:%d,%d\n",i,
			VDdata.dyn_id[i+2].objid,VDdata.dyn_id[i+2].osnum );
  }

  /*
   * construct the environment.
   */
  for( j=0 ; j<VDdata.dyn_nb ; j++ ){
    MAidmx( &rc, VDdata.dyn_env[j].matrix );
    for( i=0 ; i<3 ; i++ ){
     if(j==0){
      VDdata.dyn_env[j].matrix[i]   = me->fd_data.x_vec[i];
      VDdata.dyn_env[j].matrix[i+4] = me->fd_data.y_vec[i];
      VDdata.dyn_env[j].matrix[i+8] = me->fd_data.z_vec[i];
     }else{
      VDdata.dyn_env[j].matrix[i*4]   = me->fd_data.x_vec[i];
      VDdata.dyn_env[j].matrix[i*4+1] = me->fd_data.y_vec[i];
      VDdata.dyn_env[j].matrix[i*4+2] = me->fd_data.z_vec[i];
     }
    }
    /* if( j ) VDdata.matrix[15] = scale ; */
    MAtypemx( &rc, VDdata.dyn_env[j].matrix, &VDdata.dyn_env[j].matrix_type );
  }

  /*
   * call the dynamics routine.
   */
  dp$dynamics (dyn_fun = VDdisplay_cs_range, information = &VDdata);

  /*
   * delete the objects after dynamics.
   */
  for( i=0 ; i<VDdata.dyn_nb ; i++ ){
      status =
      om$send(msg = message GRgraphics.GRdelete( &rc, &me->ModuleInfo ),
	      targetid = VDdata.dyn_id[i].objid,
	      targetos = VDdata.dyn_id[i].osnum );
      as$status();
  }

quit:
  return OM_S_SUCCESS;
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
IGRint		status = OM_S_SUCCESS;
IGRlong		rc;
IGRshort	mtx_type;
struct	GRid	tmp;
enum    GRdpmode dpmode;

  dpmode = GRhd;

  pr_point("point:",point);

  /*
   * calculate the matrix for xform.
   */
  *num_objects = dptr->dyn_nb;
  *objects     = dptr->dyn_id;
  *out_dummy2  = dptr->dyn_env;

  dptr->dyn_env[0].matrix[3]  = point->x ;
  dptr->dyn_env[0].matrix[7]  = point->y ;
  dptr->dyn_env[0].matrix[11] = point->z ;

  for( i=1 ; i<*num_objects ; i++ ){
    dptr->dyn_env[i].matrix[3]  = point->x + dptr->origin[0] ;
    dptr->dyn_env[i].matrix[7]  = point->y + dptr->origin[1] ;
    dptr->dyn_env[i].matrix[11] = point->z + dptr->origin[2] ;
    printf(" id: %d,%d\n", dptr->dyn_id[i].objid, dptr->dyn_id[i].osnum );
  }
  MAtypemx( &rc, mtx, &mtx_type );

  for( i=1 ; i<*num_objects ; i++ ){

    status =
    om$send( msg = message GRgraphics.GRxform(&rc,
					&dptr->md_env,
					 &mtx_type,
					 mtx,
					&tmp.objid ),
           senderid = NULL_OBJID,
           targetid = dptr->dyn_id[i].objid,
           targetos = dptr->dyn_id[i].osnum);
    as$status(); 
  }

  return( status );
}

end implementation VDSdetail;
