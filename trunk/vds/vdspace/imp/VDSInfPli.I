/* $Id: VDSInfPli.I,v 1.3 2002/05/14 18:49:55 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/imp / VDSInfPli.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSInfPli.I,v $
 *	Revision 1.3  2002/05/14 18:49:55  ramarao
 *	Removed some more debug information.
 *	
 *	Revision 1.2  2001/02/28 16:32:35  ramarao
 *	Removed Unncessary Setproc and End.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:15  cvs
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
# Revision 1.7  1996/05/21  11:45:54  pinnacle
# Replaced: vdspace/imp/VDSInfPli.I for:  by v240_int for vds.240
#
# Revision 1.6  1996/05/10  06:10:50  pinnacle
# Replaced: vdspace/imp/VDSInfPli.I for:  by msbraju for vds.240
#
# Revision 1.5  1996/04/30  22:12:12  pinnacle
# Replaced: vdspace/imp/VDSInfPli.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/10/26  20:32:26  pinnacle
# Replaced: vdspace/imp/VDSInfPli.I for:  by yzhu for vds.240
#
# Revision 1.3  1995/10/25  17:27:08  pinnacle
# Replaced: vdspace/imp/VDSInfPli.I for:  by tlbriggs for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/25/95	tlb		EMS 3.2: changed cs.h to grcoordsys.h
 *      10/26/95        yzhu            comment print
 * -------------------------------------------------------------------*/

/*
ABSTRACT : 


CHANGE HISTORY
	
     Ch		6   Dec 90  : Design date
     AD, JJ	24  Jun 93  : Add fuction VDInfPlGetName
     Mallik	8   Jan 94  : Removed reference to ENV 5 for EMS 3.
     tlb	3   Mar 94  : change call to WLdraw_text to vd$WLdraw_text
     adz	3   Apr 94  : Check parameters for NULL pointers.
     pas        3   june 94 : commented strcpy(txt,pt_name); 
                              and added txt[0] ='\0' to avoid sigsegv; 
     yz         18  Oct. 95 : vd$WLdraw_text only print out when AS_DEBUG
                              is defined.
*/

class implementation VDSInfPl;

#include <math.h>

#include "OMmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "bserr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "EMSssprops.h"
#include "EMSopt.h"
#include "EMS.h"
#include "msdef.h"                      /* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "bsparameters.h"
#include "gocmacros.h" /* GRgetabsg */
#include "VDSutil_def.h"
#include "wl.h"
#include "VDWLmacros.h"
#include "v_dbgmacros.h"

/* prototypes */

#include "madetplan.h"
#include "maptsxfor.h"
#include "maunitvc.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bssfeval.h"
#include "bscrossp.h"


#define TXT    0x0001
#define PLN    0x0002

#define SZ_PLANE 10
#define EPSILON  10e-05

from ACpretend import ACgive_downscan, ACfind_parent;

extern  GRclassid       OPP_SMframe_class_id;
extern  GRclassid       OPP_VDSInfPl_class_id;
extern  GRclassid       OPP_SMInfPlane_class_id;


method GRdisyourself(	IGRlong		*msg;
			IGRshort	*mx_type;
			IGRmatrix	matrix;
			enum GRdpmode	*mode;
			struct IGRaltdisplay	*alt_symb;
			struct DP_information	*sp_info;
                        OM_p_KEY_DESC		range_key)
{
	IGRint 	status;

	struct IGRbsp_surface	*surf = NULL;
	IGRchar			*absptr = NULL;
	IGRpoint		pt0;
	BSrc			rc;
	IGRboolean		display_frame;

#ifdef	WILL_BE_VERIFIED

	/*
	 * Fix for TR#: 179601179  - Raju 5/10/996
	 * Verify if the frame is within the view volume of graphic gadget
	 */

	status =
	om$send(msg = message EMSplane.GRgenabsg(       msg,
							mx_type,
							matrix,
							&absptr ),
		targetid = my_id);
	__CheckRC( status, *msg, "EMSplane.GRgenabsg", wrapup );

	surf = (struct IGRbsp_surface *) absptr;
	BSsfeval(surf, 0., 0., 0, &pt0, &rc);

	{
		double  xformed_pt[3];


		display_frame = FALSE;

		xformed_pt[0] =  sp_info->gragad->rotation[0][0] * pt0[0] +
				 sp_info->gragad->rotation[0][1] * pt0[1] +
				 sp_info->gragad->rotation[0][2] * pt0[2] -
				 sp_info->gragad->origin[0];

		xformed_pt[1] =  sp_info->gragad->rotation[1][0] * pt0[0] +
				 sp_info->gragad->rotation[1][1] * pt0[1] +
				 sp_info->gragad->rotation[1][2] * pt0[2] -
			  	 sp_info->gragad->origin[1];

		xformed_pt[2] =  sp_info->gragad->rotation[2][0] * pt0[0] +
				 sp_info->gragad->rotation[2][1] * pt0[1] +
				 sp_info->gragad->rotation[2][2] * pt0[2] -
			  	 sp_info->gragad->origin[2];

		if ( 
			xformed_pt[0] > sp_info->gragad->vw_volume[0] &&
			xformed_pt[0] < sp_info->gragad->vw_volume[3] &&
			xformed_pt[1] > sp_info->gragad->vw_volume[1] &&
			xformed_pt[1] < sp_info->gragad->vw_volume[4] &&
			xformed_pt[2] > sp_info->gragad->vw_volume[2] &&
			xformed_pt[2] < sp_info->gragad->vw_volume[5]
		    )	  display_frame = TRUE;

	}

	/*
	 * frame is not within the view volume
	 */
 	if ( !display_frame )
	{
	    status = OM_S_SUCCESS;
	    goto wrapup;
	}

#endif

	status =
	om$send(msg = message EMSsubbs.GRdisyourself( msg, mx_type,
			   matrix, mode, alt_symb, sp_info, range_key),
		mode = OM_e_wrt_message,
		targetid = my_id);
	__CheckRC( status, *msg, "EMSsubbs.GRdisyourself", wrapup );

	status =
	om$send(msg = message VDSInfPl.VDdisyourself( msg, mx_type,
			   matrix, mode, alt_symb, sp_info, range_key),
		mode = OM_e_wrt_message,
		targetid = my_id);
	__CheckRC( status, *msg, "VDSInfPl.VDdisyourself", wrapup );

wrapup:
	if (absptr) GRabsg_del(absptr);
	return(status);
}

/***************************************************************************/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
struct	GRid	myId;
IGRchar		name[DI_PATH_MAX];

  myId.objid = my_id;
  myId.osnum = OM_Gw_current_OS;

  /*
   * Ad,JJ : Modif 6/25/93 ==> Return concatenation of macro_name:plane
   */
  if(VDInfPlGetName(&myId,name))
    {	
      strcpy(info->type,name);
      strcat(info->type,":Plane");
    }
  else
    strcpy(info->type,"Plane");

  *msg = MSSUCC;
  return(OM_S_SUCCESS);
}

/***************************************************************************/

method GRdetplane(IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
        struct IGRplane *def)
{
	IGRint			i ;
	struct	IGRbsp_surface  *geom;
	IGRlong                 num_pnts = 3;
	IGRshort		sts_funk;
	IGRchar                	*absptr = NULL;
	IGRdouble              	tol2, tol;
	IGRlong 		msg2, nput, nret;
	IGRint			status ;

	status = OM_S_SUCCESS ;
	geom	= NULL ;
	
	nput = sizeof(tol);
	gr$get_basis_tolerance( msg    = &msg2,
                         sizbuf = &nput,
                         buffer = &tol2,
                         nret   = &nret);
	if(!(msg2 & 1)){
		status = OM_W_ABORT;
		goto wrapup ;
	}

	/*
	 * Let's do an horible kludge to make it working when the
	 * base tol has been changed or at drawing extraction time with
	 * a scale of 100.
	 */

	GRabsg_del_all();	/** NEW NEW NEW NEW **/

//	GRgetabsg (msg, mattyp, mat, &absptr, i);
//	EMerr_hndlr (!(1&*msg) || !absptr, *msg, EMS_E_Fail, wrapup);

        status =
        om$send(msg = message EMSplane.GRgenabsg(       msg,
                                                        mattyp,
                                                        mat,
                                                        &absptr ),
                mode = OM_e_wrt_message,
                targetid = my_id);
        __CheckRC( status, *msg, "EMSplane.GRgenabsg", wrapup );

	geom = (struct IGRbsp_surface *) absptr;

	tol = tol2/100.;
	gr$put_basis_tolerance( msg    = &msg2,
       		                sizbuf = &nput,
                	        buffer = &tol);
	if(!(msg2 & 1)){ 
		status = OM_W_ABORT;
		goto wrapup ;
	}

	sts_funk = MAdetplane(msg, geom->poles, &num_pnts, &tol, def);
	if( !(1&*msg )|| sts_funk == FALSE ){
	  printf("WARNING: cannot get the plane normal (tolerance problem !!!)\n");
	  printf("WARNING: Recompute the plane (with same bas tol) should solve the problem\n");
	  *msg = EMS_E_Fail;
	}

	gr$put_basis_tolerance( msg    = &msg2,
            	             	sizbuf = &nput,
               	          	buffer = &tol2);
	if(!(msg2 & 1)){ 
		status = OM_W_ABORT;
		goto wrapup ;
	}

	/*
	 * To follow the modification of pp for the 2.0 release
	 * Use logical normal instead of an arbitrary normal.
	 * pp 09/15/92
	 */

	if( !geom->pos_orient ){
	  for( i=0; i<3; i++ ) def->normal[i] = -def->normal[i];
	}

wrapup:

	if (absptr) GRabsg_del(absptr);
	return( status );
}


/***************************************************************************/

method GRgenabsg(	IGRlong *msg;
			IGRshort *matrix_type;
			IGRmatrix matrix; 
			IGRchar **absgptr)
{
	IGRint		status;
	IGRpoint	pt0;
	IGRdouble	coef;
	IGRint		i, k, m;
	BSrc		rc;
	struct IGRbsp_surface *surf;

	status =
	om$send(msg = message EMSplane.GRgenabsg(	msg,
							matrix_type,
							matrix,
							absgptr),
		mode = OM_e_wrt_message,
		targetid = my_id);
	__CheckRC( status, *msg, "EMSplane.GRgenabsg", wrapup );

wrapup:
	if(1){
		return status;
	}

 /* IT IS NOT POSSIBLE BECAUSE IT FAILS ON A COPY .... */
 
 /* Dilatation of the plane ...
 /* Transform the pole P to P',
 /* If O is the center (0.5, 0.5),
 /* P'O = K PO,
 /* For now K is 100. 
 /*
 /*  BSEXTRACTPAR(&rc, BSTOLCHRDHT, tol); */
 /* */

 coef = 100.;
 surf = (struct IGRbsp_surface *) *absgptr;

 /* Get the center point */
 BSsfeval(surf, 0., 0., 0, &pt0, &rc);
 if(rc!=BSSUCC)  return(OM_S_SUCCESS);  /* Fail but ... */

 k = 3 * surf->u_num_poles * surf->v_num_poles;
 for(i=0;i<k;i=i+3)
  {
   for(m=0;m<3;m++)
    {
     surf->poles[i+m] = coef * (surf->poles[i+m] - pt0[m]) + pt0[m];
    }
  }

 /* In case of */
 surf->planar = TRUE;

 return OM_S_SUCCESS;

}

/***************************************************************************/

method VDsettext( char *text)
{
	int		txt_sz, status;

	if( text==NULL ){

	/*| Clear if there is an existing text */
	  if(om$dimension_of( varray= me->vd_text) > 0){
		strcpy(me->vd_text,"");
	  }
	  return(OM_S_SUCCESS);
	}  

	txt_sz = strlen(text) + 1;
	if( txt_sz <=1 ) return(OM_S_SUCCESS);

	if( om$dimension_of(varray= me->vd_text) < txt_sz){
	  status =
	  om$vla_set_dimension(varray= me->vd_text, size = txt_sz);
	  as$status(action = RET_STATUS);
	}

	strcpy(ME.VDSInfPl->vd_text,text);

	return(OM_S_SUCCESS);
}


/***************************************************************************/
method VDgettext( char *text; short size)
{
	if(size < 2) return OM_W_ABORT ;
	if( ! text ) return OM_W_ABORT ;

	if( om$dimension_of( varray= me->vd_text) <= 0 ){
	
	  text[0] = '\0';
	}
	else{
	  strncpy(ME.VDSInfPl->vd_text, text, size-1);
	  text[size-1] = '\0';
	}
   
	return(OM_S_SUCCESS);
}


/***************************************************************************/

method VDinitinst()
{
	me->size = 0;
	return(OM_S_SUCCESS);
}


/***************************************************************************/

method VDsetsize(short pl_size)
{
	if(	pl_size != SMALL_PL_SZ  && 
		pl_size != MEDIUM_PL_SZ &&
		pl_size != LARGE_PL_SZ )  pl_size = MEDIUM_PL_SZ;

	if(pl_size > 0 || pl_size < -3) pl_size = 0;

	/* Store possitive values to take less space */
	pl_size = -pl_size;
 
	me->size = me->size | pl_size;

	return(OM_S_SUCCESS);
}


/***************************************************************************/

method VDsetjustif(short j1, j2)
{
 j1 = (j1 << 4) & 0x00F0;
 j2 = (j2 << 8) & 0x0F00;
 
 me->size = (me->size & 0x000F) | j1 | j2;

 return(OM_S_SUCCESS);
}


/***************************************************************************/

method VDgetjustif(short *j1, *j2)
{
 short tmp;

 tmp = me->size & 0x00F0;
 *j1  = tmp >> 4;

 tmp = me->size & 0x0F00;
 *j2  = tmp >> 8;

 /*" get Justif: %d, %d\n", *j1, *j2 */

 return(OM_S_SUCCESS);
}


/***************************************************************************/

method VDgetsize(short *size)
{
 *size = -(me->size & 0x000F);
 return(OM_S_SUCCESS);
}


/***************************************************************************/
/*
 * Override this message to avoid setting this object in the Display List.
 */

method GRadd_to_display_list( IGRlong *msg; IGRboolean is_hidden_line )
{
	*msg = MSFAIL;
	is_hidden_line = FALSE;

	return(OM_E_ERROR);
}

/***************************************************************************/

method VDdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{
	IGRint		status;
	struct GRid	my_grid;
	short		j1, j2, size;
/***
	extern IGRboolean ASbroadcast_in_progress;
 ***/

 if ( ((me->properties & GRIS_DISPLAYABLE)  || (*mode == GRhdo) || 
	  (*mode == GRhhdo) || (*mode == GRheo) ||
         (*mode == GRbdheo) || (*mode == GRbeheo) )
	&& (DPlevel_on(me->level,sp_info)))
 {
      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;

      status = om$send(msg = message VDSInfPl.VDgetsize( &size),
                     targetid = my_id);
      as$status(action = RET_STATUS);

      status = om$send(msg = message VDSInfPl.VDgetjustif( &j1, &j2),
                     targetid = my_id);
      as$status(action = RET_STATUS);
      
      /*| Get the name of the rigid owner (if existing) */
      VDdraw3(	msg, mx_type, matrix, mode, alt_symb,
		sp_info, range_key, my_grid,
		(om$dimension_of( varray= me->vd_text) > 0) ?
			me->vd_text : NULL,
		&(me->display_attr), PLN | TXT,
		size, j1, j2, TRUE);
  }

  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
VDdraw2 (msg, mx_type, matrix, mode, alt_symb, sp_info, range_key, my_grid,
            name, display_att, type, pl_size)
IGRlong               *msg;
IGRshort              *mx_type;
IGRmatrix              matrix;
enum GRdpmode         *mode;
struct IGRaltdisplay  *alt_symb;
struct DP_information *sp_info;
OM_p_KEY_DESC          range_key;
struct GRid	       my_grid;
char		      *name;
struct IGRdisplay     *display_att;
short		       type;    /* TXT = drawn text, PLN = drawn plane */
short		       pl_size;
/*.VDdraw2*/
{
 int i;

 i = VDdraw3 (msg, mx_type, matrix, mode, alt_symb, sp_info, range_key, my_grid,
              name, display_att, type, pl_size, (short) VD_PL_CENT, 
              (short) VD_PL_CENT, TRUE);

 return i;
}

/* Given 3 points (p0, p1, p2) defining a plane compute the center and 2
/* small point for the x and y direction. Pti and pto can be tha same array
/* */
VDRedPts(pti,pto)
IGRdouble *pti; 	/* Array of 3 points, IN  */
IGRdouble *pto; 	/* Array of 3 points, OUT */
/*.VDRedPts*/
{
 int 	i;
 BSrc	rc;
 double vx[3], vy[3], vz[3], vy_length;
 long msg, nput, nret;
 double  tol, dist;

#define PT_LENGTH 0.001
/*^
  for(i=0;i<7;i=i+3) printf("pt: %lf, %lf, %lf\n", pti[i], pti[i+1], pti[i+2]);
*/

 /*| Get the basis tolerance */
  nput = sizeof(tol);

  gr$get_basis_tolerance(msg    = &msg,
                         sizbuf = &nput,
                         buffer = &tol,
                         nret   = &nret);
  dist = tol * 100;

 for(i=0;i<3;i++) 
  {
   vx[i] = pti[i+3] - pti[i];
   vy[i] = pti[i+6] - pti[i];
  }

 MAunitvc(&msg, vx, vx);
 BScrossp(&rc, vx, vy, vz);
 vy_length = BSlenvec(&rc,vz);

 BScrossp(&rc, vz, vx, vy);
 MAunitvc(&msg, vy, vy);

 for(i=0;i<3;i++) pto[i] = (pti[i+3] + pti[i])/2. + vy[i] * (vy_length/2.);

 for(i=0;i<3;i++) 
  {
/*
/*   pto[i+3] = pto[i] + vx[i] * PT_LENGTH;
/*   pto[i+6] = pto[i] + vy[i] * PT_LENGTH;
/* */
   /* CH 01/25/93 to get it centered */
   pto[i]   = pto[i] - 0.5 * dist * (vx[i] + vy[i]);
   pto[i+3] = pto[i] + vx[i] * dist;
   pto[i+6] = pto[i] + vy[i] * dist;
  }
 
/*^
  for(i=0;i<7;i=i+3) printf("pt: %lf, %lf, %lf\n", pto[i], pto[i+1], pto[i+2]);
*/
return(1);
}

vdgendraw2(window, center_pt, vline, plane, pl_size)
struct GRid	*window;		/* window id	*/
IGRdouble		*center_pt;		/* center point */
IGRdouble		*vline;			/* line vector  */
struct IGRplane *plane;			/* plane def	*/
short		pl_size;		/* plane size (3 types available) (I) */
/*.vdgendraw2*/
{
 IGRint 		status, i;
 IGRlong		msg, error, nb_ret;
 struct var_list	varlist[3];
 IGRdouble		scale; 
 BSrc			rc;
 struct DPele_header 	display_buffer;
 struct IGRpolyline  	polyline;
 struct IGRdisplay   	display_attr;
 IGRdouble              triad_coords[18];
 IGRdouble		size_plane;
 IGRdouble      	x_axis[3], y_axis[3];
 IGRdouble      	pt0[3];

 /*^
 printf(" window: %d, %d,\n", window->objid, window->osnum);
 printf("center_pt: %lf, %lf, %lf\n", center_pt[0], center_pt[1], center_pt[2]);
 printf("vline: %lf, %lf, %lf\n", vline[0], vline[1], vline[2]);
 printf("plane->normal: %lf, %lf, %lf\n", plane->normal[0], plane->normal[1], plane->normal[2]);
 */
 varlist[0].var		   = VVOL_VIEWPORT_SCALE;
 varlist[0].var_ptr	   = (char *) &scale;
 varlist[0].num_bytes	   = sizeof(double);
 varlist[0].bytes_returned = &nb_ret;

 varlist[1].var		   = END_PARAM;

 /*| Get the window info */
 status = dp$inq_set_gragad(msg          = &msg,
			    inq0_set1    = 0,
			    osnum        = window->osnum,
			    gragad_objid = window->objid,
			    which_error  = &error,
			    var_list     = varlist);
 
  for(i=0;i<3;i++) 
   {
    pt0[i] = center_pt[i];
    x_axis[i] = vline[i];
   }
  MAunitvc(&rc, x_axis, x_axis);
  if(rc!=MSSUCC)  return(0);

  BScrossp(&rc, vline, plane->normal, y_axis);
  if(rc!=BSSUCC)  return(0);

  size_plane = SZ_PLANE;
  if(pl_size == SMALL_PL_SZ) size_plane = size_plane * 0.666;
  if(pl_size == LARGE_PL_SZ) size_plane = size_plane * 1.333;
  size_plane = size_plane / scale;

  /*" Fill the array of points, size_plane: %lf\n", size_plane */
  for(i=0;i<3;i++)
   {
    triad_coords[i]    = pt0[i] + size_plane * ( x_axis[i] * 2 + y_axis[i]);
    triad_coords[i+3]  = pt0[i] + size_plane * ( x_axis[i] * 2 - y_axis[i]);
    triad_coords[i+6]  = pt0[i] + size_plane * (-x_axis[i] * 2 - y_axis[i]);
    triad_coords[i+9]  = pt0[i] + size_plane * (-x_axis[i] * 2 + y_axis[i]);
    triad_coords[i+12] = pt0[i] + size_plane * ( x_axis[i] * 2 + y_axis[i]);
    triad_coords[i+15] = pt0[i];
   }

      /*| Display a small plane */
      polyline.num_points = 5;
      polyline.points     = triad_coords;

      /*| SEt the display attributes */
	
      display_attr.color      = 1;
      display_attr.weight     = 0;
      display_attr.style      = 0;
      /*"display: %d, %d, %d\n", display_attr.color,  display_attr.weight,display_attr.style*/

      dp$build_dis_buffer (buffer      = &display_buffer,
                           type        = IGRPY,
                           display_att = &(display_attr),
                           geometry    = (char *) &polyline);

      dp$display  (msg     = &msg,
                   buffer  = &display_buffer,
                   mode    = GRhd);
                   
return 1;
}

VDdraw3 (msg, mx_type, matrix, mode, alt_symb, sp_info, range_key, my_grid,
            name, display_att, type, pl_size, x_justif, y_justif, show_vz)
IGRlong               *msg;
IGRshort              *mx_type;
IGRmatrix              matrix;
enum GRdpmode         *mode;
struct IGRaltdisplay  *alt_symb;
struct DP_information *sp_info;
struct GRid	       my_grid;
char		      *name;
struct IGRdisplay     *display_att;
short		       type;    /* TXT = drawn text, PLN = drawn plane */
short		       pl_size;
short		       x_justif;
short		       y_justif;
IGRboolean	       show_vz;
/*.VDdraw3*/
{
IGRlong			i;                  /* index */
IGRlong			status;		    /* return code */
IGRdouble		triad_coords[21];   /* triad legs in coords */
struct IGRpolyline	polyline;           /* triad legs */
struct DPele_header	display_buffer;     /* to display triad */
struct IGRdisplay	display_attr;
IGRdouble		size_plane, vt[3];
unsigned char		props;
IGRdouble		cs_mat[16];
IGRshort		cs_pl;
IGRlong			rc;
IGRshort		go_mat_type;
IGRdouble		go_mat[16], x_axis[3], y_axis[3], vz[3];
IGRdouble		pt0[3], vz_length;

  *msg = MSSUCC;

 /*
  *  get the local_to_world matrix -- multiply input matrix and
  *  instance data local-to-world matrix
  */

  GRabsg_del_all();

  /* Get the matrix */
  go_mat_type = MAIDMX;
  status = VDget_mat(&my_grid, go_mat_type, go_mat, cs_mat, &props, &cs_pl);
  if(!(status & 1)) return 0;

  for(i=0;i<3;i++)
  {
    x_axis[i] = cs_mat[4*i+0];
    y_axis[i] = cs_mat[4*i+1];
    vz[i]     = cs_mat[4*i+2];
    pt0[i]    = cs_mat[4*i+3];
  }

  vz_length =  0.6 * SZ_PLANE / sp_info->gragad->vvol_viewport_scale;

  if(props & EMSIS_NRML_REVERSED) 
  {
    /*| Reversed vz plane */
    vz_length = -vz_length;
  }
  /* End CH modif */

  /* CH modif size (0.666, 1, 1.333 => 0.5, 0.707, 1) */
  /* CH modif size (0.5, 0.707, 1   => 0.45. 0.6, 0.9) */
  size_plane = SZ_PLANE;
  if(pl_size == SMALL_PL_SZ)  size_plane = size_plane * 0.45;
  if(pl_size == MEDIUM_PL_SZ) size_plane = size_plane * 0.6;
  if(pl_size == LARGE_PL_SZ)  size_plane = size_plane * 0.9;
  size_plane = size_plane / sp_info->gragad->vvol_viewport_scale;


  /*
   *  Set the justification for x and y values.
   */
  if(x_justif == VD_PL_POS){
      /*| x POS justif */
      for(i=0;i<3;i++) vt[i] = size_plane * x_axis[i] * 2.;
  }
  else if(x_justif == VD_PL_NEG){
      /*| x NEG justif */
      for(i=0;i<3;i++) vt[i] = -size_plane * x_axis[i] * 2.;
  }
  else for(i=0;i<3;i++) vt[i] = 0;

  if(y_justif == VD_PL_POS){
      /*| y POS justif */
      for(i=0;i<3;i++) vt[i] = vt[i] + size_plane * y_axis[i];
  }
  else if(y_justif == VD_PL_NEG){
      /*| y NEG justif */
      for(i=0;i<3;i++) vt[i] = vt[i] - size_plane * y_axis[i];
  }

  /*" translation vector: %lf, %lf, %lf\n", vt[0], vt[1], vt[2] */


  /*" Fill the array of points, size_plane: %lf\n", size_plane */
  for(i=0;i<3;i++){

    triad_coords[i+18] = pt0[i]; 
    pt0[i]	       = pt0[i] + vt[i];
    triad_coords[i]    = pt0[i] + size_plane * ( x_axis[i] * 2 + y_axis[i]);
    triad_coords[i+3]  = pt0[i] + size_plane * ( x_axis[i] * 2 - y_axis[i]);
    triad_coords[i+6]  = pt0[i] + size_plane * (-x_axis[i] * 2 - y_axis[i]);
    triad_coords[i+9]  = pt0[i] + size_plane * (-x_axis[i] * 2 + y_axis[i]);
    triad_coords[i+12] = triad_coords[i];
    triad_coords[i+15] = triad_coords[i+12] + vz_length * vz[i];
  }

  i = 7;
  /*| transform to the view coordinates */
  MAptsxform (msg, &i, matrix, triad_coords, triad_coords);
  if(type & PLN){

      /*| Display a small plane */
      if(show_vz) polyline.num_points = 6;
      else        polyline.num_points = 5;
      polyline.points = triad_coords;

      if(alt_symb==NULL)
      {
	 display_attr.color     = display_att->color;
	 display_attr.weight    = display_att->weight;
	 display_attr.style     = display_att->style;
      }
      else{
	 /*
	  * Change for 2.0 compatibility
	  * Check the structure parameters for NULL pointers AdZ 03/14/94
	  */

	 display_attr.color     = ( alt_symb->color ?
		*(alt_symb->color)  : display_att->color  );
	 display_attr.weight    = ( alt_symb->weight ?
		*(alt_symb->weight) : display_att->weight );
	 display_attr.style     = ( alt_symb->style ?
		*(alt_symb->style)  : display_att->style  );
      }

      status =
      dp$build_dis_buffer(buffer      = &display_buffer,
			 type        = IGRPY,
			 display_att = &(display_attr),
			 geometry    = (char *) &polyline);

      status =
      dp$dispelem (msg     = msg,
		 buffer  = &display_buffer,
		 mode    = *mode,
		 dp_info = sp_info);

      /*| Display the center point (Usefull to identify it) */
      polyline.num_points = 1;
      polyline.points     = &(triad_coords[18]);
      display_attr.weight = 4;

      status =
      dp$build_dis_buffer (buffer      = &display_buffer,
			 type        = IGRPS,
			 display_att = &(display_attr),
			 geometry    = (char *) &polyline); 

      status =
      dp$dispelem (msg     = msg,
		 buffer  = &display_buffer,
		 mode    = *mode,
		 dp_info = sp_info);

  }

  /* 
   *  output the axis labels and the name of the coordinate system
   *
   *  NOTE:   This is done using the Environ V tools directly, �since
   *          view- and scale-independent text is not available.  This
   *          happens to work okay since drawing the triad through IGE
   *          leaves everything set up properly.
   */


  if(type & TXT && name != NULL){

    IGRdouble pt[3], vx[3], vy[3];
    IGRint    k;
    IGRshort  dx, dy;

    /*
     *  transform the triad from world to screen coordinates
     */
    i = 4;
    MAptsxform (msg, &i, (IGRdouble *) sp_info->gragad->wld_to_viewport, 
                    triad_coords, triad_coords);

    /*^ pr_mat("wld_to_view",4,4,sp_info->gragad->wld_to_view); */

    /*| Select the x max and y min point (x priority) */
    /* First class by negativ y */
    for(i=0;i<4;i++) 
    {
      for(k=i+1;k<4;k++)
      {
        if(triad_coords[3*k+1] < triad_coords[3*i+1])
	{
	  int kk;

	  for(kk=0;kk<3;kk++){

	    pt[kk] 	         = triad_coords[3*i+kk];
	    triad_coords[3*i+kk] = triad_coords[3*k+kk];
	    triad_coords[3*k+kk] = pt[kk];
          }
	}
      }
    }

    k = 0;
    for(i=1;i<4;i++) if(triad_coords[k+0] < triad_coords[i*3+0]) k = i*3;
    
    /*| Find a nice way to display the text depending on the view orientation */
    for(i=0;i<3;i++){ 

      vx[i] = sp_info->gragad->wld_to_view[0][i];
      vy[i] = sp_info->gragad->wld_to_view[1][i];
    }

    /*^
    printf("vx view: %lf, %lf, %lf\n", vx[0], vx[1], vx[2]);    
    printf("vy view: %lf, %lf, %lf\n", vy[0], vy[1], vy[2]);    
    printf("vz view: %lf, %lf, %lf\n", vz[0], vz[1], vz[2]);    
    */

    if( fabs(BSdotp(&rc, vz, vx)) > 0.8){

      /*| The normal of the plane is like the vx of the view */
      dx = -5;
      dy = -15;
    }
    else if( fabs(BSdotp(&rc, vz, vy)) > 0.8){

      /*| The normal of the plane is like the vy of the view */
      dx =  5;
      dy = -5;
    }
    else{
      dx =   4;
      dy = -12;
    }

    i = 0 ;
    i = strlen(name);
    if( i ){

	vd$WLdraw_text ( win_no = (WLuint32) sp_info->win_no,
		      x = (int)triad_coords[k]  +dx,
		      y = (int)triad_coords[k+1]+dy,
		      text = name,
		      len = i,
		      sts = msg );
	if( *msg != WL_SUCCESS ){
           //__DBGpr_str("WLdraw_text failed: ", name );
	}
     }
     WLflush( (WLuint32) sp_info->win_no);

     *msg = MSSUCC ;
  }

  return TRUE;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*   VDcnst_pln:
     See vdsmacros.h for explanation 
 */

VDcnst_pln(msg,mat,dist,offset1,offset2,axe,length,name,justif,props,plan_obj,cst)
IGRint		*msg;	   /* return code *msg = 1 SUCCESS     	*/
IGRdouble	*mat;	   /* Matrix defining the cs	    	*/
IGRdouble	 dist;	   /* distance on axis			*/
IGRdouble	 offset1, offset2;  /* Distance along axis   	*/
char			 axe;	   /* selected axis of the matrix	*/
IGRdouble	 length;	   /* If regular plane length	    	*/
char			*name;	   /* name to display (NULL => no display */
char			*justif;   /* justification			*/
unsigned char		props;	   /* properties of the plane           */
struct GRid		*plan_obj; /* Identifier of the constructed plane (OUT)*/
struct GRvg_construct   *cst;      /* the construction list		*/
/*.VDcnst_pln*/
{
IGRint		 i, type, status;
IGRlong		 loc_msg;
IGRdouble	 vx[3], vy[3], vz[3], *p_vz;
IGRdouble	 origine[3];
IGRpoint	 pt[3];
int 		 size, j1, j2;
short		 pl_size;
struct IGRplane plane_def;
IGRdouble	pipo[6];
struct GRvg_construct   my_cst;
extern GRclassid OPP_VDSInfPl_class_id, OPP_EMSplane_class_id;
BSrc		rc2;
IGRdouble	dotp;

/*^
 printf("dist: %lf, offsets: %lf, %lf, axe: %c, justif: %s\n",dist, offset1, offset2, axe, justif);
 for(i=0;i<12;i=i+4) printf("mat: %lf, %lf, %lf, %lf\n",mat[i],mat[i+1],mat[i+2],mat[i+3]);
*/

 *msg    = 1;
 my_cst  = *cst;
 pl_size = 0;
 if(length < EPSILON && length > -5 - EPSILON)
  {
   /*| View scale independante */

   pl_size = MEDIUM_PL_SZ;
   if(length > -1-EPSILON && length < -1+EPSILON) pl_size = SMALL_PL_SZ;
   if(length > -2-EPSILON && length < -2+EPSILON) pl_size = LARGE_PL_SZ;

   size = 0;  /* View scale independant */
   length = 1;
  }
 else 
  {
   size = 1;
  }
/* ---  define the  normal to the plane (given by axe)--- */
/* define 2 pts of the plan : origine of coord sys + dist on axe */


   /* When the plane as a reverse normal the distance has to be inverted */
   if(props & EMSIS_NRML_REVERSED) dist = -dist;


    vx[0]      = mat[0]; vx[1]      = mat[4]; vx[2]      = mat[8];
    vy[0]      = mat[1]; vy[1]      = mat[5]; vy[2]      = mat[9];
    vz[0]      = mat[2]; vz[1]      = mat[6]; vz[2]      = mat[10];
    origine[0] = mat[3]; origine[1] = mat[7]; origine[2] = mat[11];

 j1 = 0; j2 = 0;
 if(size == 1)
  {
   /*| take into account the justif */
   if(justif[0] == 'n' || justif[0] == 'N') j1 = -1;
   if(justif[0] == 'p' || justif[0] == 'P') j1 =  1;
   if(justif[1] == 'n' || justif[1] == 'N') j2 = -1;
   if(justif[1] == 'p' || justif[1] == 'P') j2 =  1;
  }

if (axe == 'x' || axe == 'X')
   {
    /*| axe x */
    /* origine = ref_origine + vx * dist + vy * offset1 + vz * offset2 */
    /* origine = origine + justif1 + justif2; only if not view scale indep. */
    /* pt1 = origne - vy *length - vz * length/2 */
    /* pt2 = origne + vy *length - vz * length/2 */
    /* pt1 = origne + vz *length/2             */

    for(i=0;i<3;i=i+1)
     {
      origine[i] = origine[i] + vx[i] * dist + vy[i] * offset1 + vz[i] * offset2;
      origine[i] = origine[i] + j1 * vy[i] * length + j2 * vz[i] * length/2.;
      pt[0][i]      = origine[i] - vy[i] * length - (vz[i] * length/2.);
      pt[1][i]    = origine[i] + vy[i] * length - (vz[i] * length/2.); 
      pt[2][i]    = origine[i] + vz[i] * length/2.;
     }
   }
else if (axe == 'y' || axe == 'Y')
   {
    for(i=0;i<3;i=i+1)
     {
      origine[i] = origine[i] + vx[i] * offset2 + vy[i] * dist + vz[i] * offset1;
      origine[i] = origine[i] + j1 * vz[i] * length/2 + j2 * vx[i] * length;
      pt[0][i]      = origine[i] - vx[i] * length - (vz[i] * length/2.);
      pt[1][i]    = origine[i] - vx[i] * length + (vz[i] * length/2.);    
      pt[2][i]    = origine[i] + vx[i] * length;    
     }
   }
else
   {
    for(i=0;i<3;i=i+1)
     {
      origine[i] = origine[i] + vx[i] * offset1 + vy[i] * offset2 + vz[i] * dist;
      origine[i] = origine[i] + j1 * vx[i] * length + j2 * vy[i] * length/2.;
      pt[0][i]      = origine[i] - vx[i] * length - (vy[i] * length/2.);    
      pt[1][i]    = origine[i] + vx[i] * length - (vy[i] * length/2.);
      pt[2][i]    = origine[i] + vy[i] * length/2.;    
     }
   }

/*^
 for (i=0;i<3;i=i+1)  printf("pt : %lf, %lf, %lf\n",pt[0][i],pt[1][],pt[2][i]);
*/

   
   cst->geometry = NULL;
   plan_obj->osnum = cst->env_info->md_id.osnum;
   plan_obj->objid = NULL_OBJID;
   type = 0; /* rectangular plane */
   if(size == 0)
    {
     short j1, j2;

     /*| View independant */
     
     VDRedPts((IGRdouble *)pt,(IGRdouble *)pt); /* to do a small one */
     status = om$construct( msg = message VDSInfPl.EMplane(msg,cst,pt,type),
			    osnum = plan_obj->osnum,
			    p_objid = &plan_obj->objid,
			    classid = OPP_VDSInfPl_class_id);
     as$status(action=RET_STATUS);

     status = om$send(msg      = message VDSInfPl.VDinitinst(),
		        senderid = NULL_OBJID,
        	        targetid = plan_obj->objid,
 	                targetos = plan_obj->osnum);
     as$status(action=RET_STATUS);
 
     /*| Set the name to be the parameter if existe */
     status = om$send(msg      = message VDSInfPl.VDsettext(name),
		        senderid = NULL_OBJID,
        	        targetid = plan_obj->objid,
 	                targetos = plan_obj->osnum);
     as$status(action=RET_STATUS);

     /*| Set the size of the plane */
     status = om$send(msg      = message VDSInfPl.VDsetsize(pl_size),
		        senderid = NULL_OBJID,
        	        targetid = plan_obj->objid,
 	                targetos = plan_obj->osnum);
     as$status(action=RET_STATUS);

     /*| Kluddge because vz and vx are keeped so vy is inverted   */
     /* I know something better could have done but don't forget  */
     /* that was already existing should still work		  */
     if (0==1 &&(axe == 'y' || axe == 'Y'))
      {
       char tmp;

       tmp = justif[1];

       if     (justif[0] == 'P' || justif[0] == 'p') justif[1] = 'N';
       else if(justif[0] == 'N' || justif[0] == 'n') justif[1] = 'P';
       else 					     justif[1] = 'C';
       justif[0] = tmp;
      }

     /*| Set the justif of the plane */
     if(     justif[0] == 'P' || justif[0] == 'p') j1 = VD_PL_POS;
     else if(justif[0] == 'N' || justif[0] == 'n') j1 = VD_PL_NEG;
     else                      			   j1 = VD_PL_CENT;

     if(     justif[1] == 'P' || justif[1] == 'p') j2 = VD_PL_POS;
     else if(justif[1] == 'N' || justif[1] == 'n') j2 = VD_PL_NEG;
     else                      			   j2 = VD_PL_CENT;

     status = om$send(msg      = message VDSInfPl.VDsetjustif(j1, j2),
		        senderid = NULL_OBJID,
        	        targetid = plan_obj->objid,
 	                targetos = plan_obj->osnum);
     as$status(action=RET_STATUS);
    }
   else
    {

     /*| use the regular EMS plane */
     
     status = om$construct( msg = message EMSplane.EMplane(msg,cst,pt,type),
			    osnum = plan_obj->osnum,
			    p_objid = &plan_obj->objid,
			    classid = OPP_EMSplane_class_id);
     as$status(action=RET_STATUS);

    }

  /* "plan_obj: %d, %d\n",plan_obj->objid,plan_obj->osnum */

  /* We are not sure of the way the plane is created	*/
  /* Take care to the normal (modif CH 05/05/92) 	*/
  plane_def.point  = &pipo[0];
  plane_def.normal = &pipo[3];
  status = om$send( msg = message EMSplane.GRdetplane(&loc_msg,
		&cst->env_info->md_env.matrix_type, cst->env_info->md_env.matrix,
		&plane_def),
		        senderid = NULL_OBJID,
        	        targetid = plan_obj->objid,
 	                targetos = plan_obj->osnum);
  as$status(action=RET_STATUS);

  if      (axe == 'x' || axe == 'X') p_vz = vx;
  else if (axe == 'y' || axe == 'Y') p_vz = vy;
  else				     p_vz = vz;

  dotp = BSdotp(&rc2, p_vz, plane_def.normal);

  /* Verify that the normal is good */
  if(dotp < 0)
   {
    /* The normal has been reversed during the construction !!! */
    props ^= EMSIS_NRML_REVERSED;
   }

  if(props & EMSIS_NRML_REVERSED)
   {
    /*| The plane has a reversed normal */
    status = om$send(msg = message EMSplane.EMset_props(&loc_msg, 
					(char) EMSIS_NRML_REVERSED, EMS_O_SET),
		        senderid = NULL_OBJID,
        	        targetid = plan_obj->objid,
 	                targetos = plan_obj->osnum);

    as$status(action=RET_STATUS);
   }

  *msg =1;
  return 1;
}

/*
 * Giving a VDSInfPlane object, this function returns the name of the
 * parent macro if it is a SMframe or a SMInfPlane object.
 */

int VDInfPlGetName(
 struct GRid	*fr,     /* [I] VDS Infinite plane identifier */
 IGRchar	*name    /* [O] Name of the parent object.    */
)
{
int             index;
OM_S_CHANSELECT owner;
struct GRid     frame, plane;
IGRint		sts;
IGRlong		msg;
IGRchar		DirName[DI_PATH_MAX];

  if ( ( om$is_objid_valid( osnum = fr->osnum, objid = fr->objid ) 
		!= OM_S_SUCCESS ) || ( name == NULL ) ){
    /* invalid information input */
    return FALSE;
  }

  name[0] = '\0';

  frame = *fr;
  if( SMIsKindOf( fr, OPP_VDSInfPl_class_id )){

    plane = *fr;
    sts =
    om$get_channel_number(channame ="GRconnector.to_owners",
			  p_channum = &owner.u_sel.number);
    owner.type  = OM_e_num;
  
    index = 0;
    sts = 1;
    while( sts&1 ){

      sts =
      om$get_objid_at_index(p_chanselect = &owner,
			    index = index++,
			    objid = fr->objid,
			    osnum = fr->osnum,
			    objidaddr = &frame.objid,
			    osnumaddr = &frame.osnum);

      if(( sts&1 ) && ( SMIsKindOf( &frame, OPP_SMframe_class_id ) ||
		        SMIsKindOf( &frame, OPP_SMInfPlane_class_id ))) {
	break;
      }
    }
  }

  if( SMIsKindOf( &frame, OPP_SMframe_class_id ) || 
      SMIsKindOf( &frame, OPP_SMInfPlane_class_id )){

    /* Find the name of the frame */
    sts = om$send(msg = message GRgraphics.GRgetname( &msg, DirName ),
		  senderid = NULL_OBJID,
		  targetid = frame.objid,
		  targetos = frame.osnum);
    if( sts & msg & 1 ){

      sts = di$split( pathname = DirName, name = name );
      return TRUE;
    }
  }

  return FALSE;
}

end implementation VDSInfPl;

