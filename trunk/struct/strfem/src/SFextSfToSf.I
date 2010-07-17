class implementation Root;

#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "bsmdistsfsf.h"
#include "bsmdistptsf.h"
#include "ex.h"
#include "msmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "gocmacros.h"
#include "dp.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

#include "vderrmacros.h"

#define  U_LEFT  0
#define  U_RIGHT 1
#define  V_LEFT  2
#define  V_RIGHT 3

#define REPARAMETRIZE_IN_U_AND_V  2


from  EMSsubbs   import  EMextend_by_dist;
from  GRvg       import  GRgenabsg;
from  GRvg       import  GRpostabsg;
from  EMSgenbs   import  EMextend_surface;
from  GRgraphics import  GRdisplay;
from  EMSsurface import  EMputLsIfNotThere;
from  EMSsubbs   import  EMpassloop;
from  EMSloopset import  EMpt_location;
from  EMSedge    import  EMxyz_endpt;
from  EMSedge    import  EMendpts;


long   SFextendSfToSf (
  long			*msg,
  struct GRid		*sf1,
  struct GRmd_env	*env1,
  struct GRid		*sf2,
  struct GRmd_env	*env2
)
{

long			sts, send_msg,
			size1,
			size2;
BSrc			rc;
IGRboolean		ex1 = FALSE,
			ex2 = FALSE;
double			buff1[200],
			buff2[200];
struct IGRbsp_surface   *geom1 = NULL,
			*geom2 = NULL;
struct GRprops		props1,
			props2;
int			num_dists;
IGRdouble		*paruv1 = NULL,
			*paruv2 = NULL,
			dist[10],
			dists_in[4],
			dists_out[4];
GRobjid			new_objid;
int			xtend_opt;
struct	IGRbsp_surface  *extended_surface = NULL;
enum  GRdpmode		dpmode;
struct EMSpartolbasis   partolb;
struct EMSptloc_info    ptloc_info;
double			begin_pt[2], end_pt[2];
IGRpoint		*sfpt1 = NULL, *sfpt2 = NULL;

     if ( !msg || !sf1 || !env1 || !sf2 || !env2 )
     {
	*msg = MSINARG;
	sts = OM_E_INVARG;
	goto wrapup;
     }

     sts = OM_S_SUCCESS;
     *msg = MSSUCC;

     sts = om$send( msg = message EMSsurface.EMputLsIfNotThere(
					msg, &(env1->md_env), NULL, NULL,
					NULL, NULL),
			senderid = NULL_OBJID,
			targetid = sf1->objid,
			targetos = sf1->osnum);
     VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg,VD_VERBOSE,wrapup );

     sts = om$send( msg = message EMSsurface.EMputLsIfNotThere(
					msg, &(env2->md_env), NULL, NULL,
					NULL, NULL),
			senderid = NULL_OBJID,
			targetid = sf2->objid,
			targetos = sf2->osnum);
     VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg,VD_VERBOSE,wrapup );

     size1 = sizeof ( buff1 );
     size2 = sizeof ( buff2 );
     sts = GRget2objgeom ( msg, sf1, &(env1->md_env), &ex1,
			   sf2, &(env2->md_env), &ex2,
			   buff1, buff2,
			   &size1, &size2,
			   &geom1,  &geom2,
			   &props1, &props2  );
    /*
     * return status of above function is of IGRboolean type
     */
    if ( !( sts & *msg & 1 ) )
    {
	printf("GRget2objgeom failure\n");
	if ( sts )
	   sts = OM_S_SUCCESS;
	else
	   sts = OM_E_ABORT;
	goto wrapup;
    }

    BSmdistsfsf ( geom1, geom2, &num_dists, &paruv1, &paruv2, &sfpt1, &sfpt2,
		  dist, &rc );

    if ( rc != BSSUCC )
    {
	printf("SFextendSfToSf : BSmdistsfsf failure\n");
	*msg = MSFAIL;
	goto wrapup;
    }

    __DBGpr_int ( "no. of min. distances from BSmdistsfsf", num_dists );
    __DBGpr_dbl ( "first min. distance", dist[0] );

    if ( num_dists != 1 )
    {
	ex$message (	field   =  ERROR_FIELD,
			justification = CENTER_JUS,
			in_buff = "Can not extend using this command" );
	goto wrapup;
    }


    /* check the options once again */
    ptloc_info.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP |
			 EMS_PTLOC_USECHTTOL ;

    partolb.is_valid = FALSE;
    partolb.in_world = TRUE;
    partolb.mattyp   = &(env1->md_env.matrix_type);
    partolb.mat      = env1->md_env.matrix;

    sts = om$send (msg = message EMSsubbs.EMpassloop ( &send_msg,
			message EMSloopset.EMpt_location ( msg, paruv1,
				&ptloc_info, &partolb)),
		   targetid = sf1->objid,
		   targetos = sf1->osnum,
		   senderid = NULL_OBJID);

    VDS_ERR_HNDLR( "EMSsubbs.EMpassloop", sts, send_msg, VD_VERBOSE, wrapup );
    VDS_ERR_HNDLR( "EMSloopset.EMpt_location", sts, *msg, VD_VERBOSE, wrapup );


    if ( (ptloc_info.location != EMS_L_ONEDGE) &&
	 (ptloc_info.location != EMS_L_ONVRTX)
    )
    {
	/*
	 * point is neither on edge nor on vertex
         */
	ex$message (	field   =  ERROR_FIELD,
			justification = CENTER_JUS,
			in_buff = "Can not extend using this command" );
	goto wrapup;
    }

    if ( ptloc_info.location == EMS_L_ONVRTX )
    {
	/*
	 * point is on vertex. put the parallel edge as the first edge.
	 */
	IGRdouble begin_pt_xyz1[3], end_pt_xyz1[3],
		  begin_pt_xyz2[3], end_pt_xyz2[3],
		  base[3];
	double	  dist1, dist2, dist3, dist4,
		  u_par, v_par;
	GRobjid	  temp_obj;


	__DBGpr_com("Entered pt location on vertex");

	sts = om$send ( msg = message EMSedge.EMxyz_endpt (
						msg,
						NULL,
						NULL,
						NULL, /* begin_pt_uv1, */
						NULL, /* end_pt_uv1, */
						begin_pt_xyz1,
						end_pt_xyz1,
						&geom1), /* NULL */
			targetid = ptloc_info.edge[0].edge_id,
			targetos = sf1->osnum,
			senderid = NULL_OBJID );
	VDS_ERR_HNDLR ( "EMSedge.EMxyz_endpt", sts, *msg, VD_VERBOSE, wrapup );

	BSmdistptsf ( &rc, geom2, begin_pt_xyz1, &u_par, &v_par, base, &dist1 );
	if ( rc != BSSUCC )
	{
	   printf("SFextendSfToSf : BSmdistptsf failure[Line %d]\n",__LINE__);
	   *msg = MSFAIL;
	   goto wrapup;
	}

	BSmdistptsf ( &rc, geom2, end_pt_xyz1, &u_par, &v_par, base, &dist2 );
	if ( rc != BSSUCC )
	{
	   printf("SFextendSfToSf : BSmdistptsf failure[Line %d]\n",__LINE__);
	   *msg = MSFAIL;
	   goto wrapup;
	}

	sts = om$send ( msg = message EMSedge.EMxyz_endpt (
						msg,
						NULL,
						NULL,
						NULL,  /* begin_pt_uv2, */
						NULL,  /* end_pt_uv2, */
						begin_pt_xyz2,
						end_pt_xyz2,
						&geom1),
			targetid = ptloc_info.edge[1].edge_id,
			targetos = sf1->osnum,
			senderid = NULL_OBJID );
	VDS_ERR_HNDLR ( "EMSedge.EMxyz_endpt", sts, *msg, VD_VERBOSE, wrapup );

	BSmdistptsf ( &rc, geom2, begin_pt_xyz2, &u_par, &v_par, base, &dist3 );
	if ( rc != BSSUCC )
	{
	   printf("SFextendSfToSf : BSmdistptsf failure[Line %d]\n",__LINE__);
	   *msg = MSFAIL;
	   goto wrapup;
	}

	BSmdistptsf ( &rc, geom2, end_pt_xyz2, &u_par, &v_par, base, &dist4 );
	if ( rc != BSSUCC )
	{
	   printf("SFextendSfToSf : BSmdistptsf failure[Line %d]\n",__LINE__);
	   *msg = MSFAIL;
	   goto wrapup;
	}

	if ( fabs( dist3 - dist4 ) < 1.0e-6 &&
	     fabs( dist3 - dist[0] ) < 1.0e-6  )
	{
	   /*
	    * second edge of first surface is parallel to second surface.
	    * Exchange second and first edges so that the following program
	    * works fine
	    */
	   temp_obj =  ptloc_info.edge[0].edge_id;
	   ptloc_info.edge[0].edge_id = ptloc_info.edge[1].edge_id;
	   ptloc_info.edge[1].edge_id = temp_obj;
	}
	else if ( fabs ( dist1 - dist2 ) > 1.0e-6 ||
		  fabs ( dist1 - dist[0] ) > 1.0e-6  )
	{
	   printf("SFextendSfToSf : Pt location on vertex error\n");
	   *msg = MSFAIL;
	   goto wrapup;
	}

    } /* if ( ptloc_info.location == EMS_L_ONVRTX ) */


    sts = om$send ( msg = message EMSedge.EMendpts (
						msg,
						begin_pt,
						end_pt,
						NULL, NULL, NULL ),
			targetid = ptloc_info.edge[0].edge_id,
			targetos = sf1->osnum,
			senderid = NULL_OBJID );
    VDS_ERR_HNDLR("EMSedge.EMendpts", sts, *msg, VD_VERBOSE, wrapup );

/*
    printf("begin_pt : [%f],[%f]\n", begin_pt[0], begin_pt[1]);
    printf("end_pt : [%f],[%f]\n", end_pt[0], end_pt[1]);
*/

    dists_in[U_LEFT] = dists_in[U_RIGHT] = 0.0;
    dists_in[V_LEFT] = dists_in[V_RIGHT] = 0.0;

    if ( begin_pt[0] == end_pt[0] )   /* u is constant */
    {
       if ( begin_pt[0] < 0.5 )       /* u is less that 0.5, therefore left */
	  dists_in[U_LEFT]  = dist[0];
       else			      /* u is less that 0.5, therefore right */
	  dists_in[U_RIGHT] = dist[0];
    }
    else if ( begin_pt[1] == end_pt[1] )  /* v is constant */
    {
       if ( begin_pt[1] < 0.5 )      /* v is less that 0.5, therefore left */
	  dists_in[V_LEFT]  = dist[0];
       else			     /* v is less that 0.5, therefore right */
	  dists_in[V_RIGHT] = dist[0];
    }

    dpmode = GRbe;
    sts = om$send ( msg = message GRgraphics.GRdisplay (
                        msg,
                        &(env1->md_env.matrix_type),
                        env1->md_env.matrix,
                        &dpmode,
                        &(env1->md_id) ),
                     targetid = sf1->objid,
                     targetos = sf1->osnum,
		     senderid = NULL_OBJID );


    xtend_opt = EMS_opt_extendS_deextend_if_needed |
		EMS_opt_extendS_reparametrize_surface ;

    sts = om$send ( msg = message EMSsubbs.EMextend_by_dist (
					msg,
					env1,
					dists_in,
					dists_out,
					xtend_opt,
					&new_objid ),
		    targetid = sf1->objid,
		    targetos = sf1->osnum,
		    senderid = NULL_OBJID );
    VDS_ERR_HNDLR("EMSsubbs.EMextend_by_disp", sts, *msg, VD_VERBOSE,
		   wrapup );

    dpmode = GRbd;
    sts = om$send ( msg = message GRgraphics.GRdisplay (
				msg,
				&(env1->md_env.matrix_type),
				env1->md_env.matrix,
				&dpmode,
				&(env1->md_id) ),
		    targetid = sf1->objid,
		    targetos = sf1->osnum,
		    senderid = NULL_OBJID );


wrapup:

    if ( (double *)geom1 != buff1 )  free ( geom1 );
    if ( (double *)geom2 != buff2 )  free ( geom2 );
    if ( paruv1 ) free ( paruv1 );
    if ( paruv2 ) free ( paruv2 );
    if ( sfpt1 ) free ( sfpt1 );
    if ( sfpt2 ) free ( sfpt2 );

    if (extended_surface)
    {
	extern	IGRboolean GRabsg_del_all();
	extern	IGRboolean BSfreesf();
	IGRboolean	status;
	IGRlong		loc_msg;

	status = BSfreesf(
			&loc_msg, 
			extended_surface);
	status = GRabsg_del_all();
    }

    return sts;

/*
  dpmode = GRbe;
  sts = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&(env1->md_env.matrix_type),
						env1->md_env.matrix,
						&dpmode,
						&(env1->md_id)
						      ),
		  targetid = sf1->objid,
		  targetos = sf1->osnum,
		  senderid = NULL_OBJID );



  sts = EMpromote_class ( FALSE, env1, sf1, msg );

  if ( ! ( sts & *msg & 1) )
  {
    printf("EMpromote_class failure\n");
    goto wrapup;
  }

  lc_info.module_info = *env1;

  sts = om$send ( msg = message EMSgenbs.EMextend_surface(
						&lc_info,
						sfpt1,
						sfpt2,
						2,
						msg),
		  targetid = sf1->objid,
		  targetos = sf1->osnum,
		  senderid = NULL_OBJID );

  if ( ! ( sts & *msg & 1) )
  {
     printf("EMSgenbs.EXextend_surface failure\n");
     goto wrapup;
  }

*/
/*  IFFFFFFFFFFF 0  */

#if 0

{
 IGRlong	loc_msg, i;

 *msg = MSSUCC;

 /*
  * Get my geometry
  */
 {
  struct	GRmdenv_info *mdenv_info;

  mdenv_info = &(env1->md_env);

  sts = om$send ( msg = message GRvg.GRgenabsg ( msg,
						 &(env1->md_env.matrix_type),
						 (env1->md_env.matrix),
						 (char **) &surface ) ,
		  targetid = sf1->objid,
		  targetos = sf1->osnum,
		  senderid = NULL_OBJID );
  if ( ! ( sts & *msg & 1) )
  {
    printf("GRvg.GRgetabsg failure\n");
    goto wrapup;
  }

/*
  GRgetabsg(
    msg,
    &mdenv_info->matrix_type, 
    mdenv_info->matrix,
    (IGRchar **) &surface,
    i);
   if (! (1 & *msg)) goto wrapup;
*/
 }

 /*
  * Call the math function
  */
 {
  extern   void	BSsfxttpt();

  BSsfxttpt(
    0,
    surface,
    sfpt2,
    sfpt2,
    &extended_surface,
    &loc_msg);

  switch ( loc_msg )
  {
    case BSSUCC :
	printf("BSSUUC\n");
	break;

    case BSINARG :
	printf("BSINARG\n");
	break;

    case BSNOMEMORY :
	printf("BSNOMEMORY\n");
	break;

    case BSNOSTKMEMORY :
	printf("BSNOSTKMEMORY\n");
	break;

    case BSPHYCLOSED :
	printf("BSPHYCLOSED\n");
	break;

    case BSINVEXTDIR :
	printf("BSINVEXTDIR\n");
	break;

    case BSINVOPTION :
	printf("BSINVOPTION\n");
	break;

    case BSINVORD :
	printf("BSINVORD\n");
	break;

    default :
	printf("default\n");
	break;
   }

   if (loc_msg != BSSUCC)
    {
     extended_surface = NULL;  /* Core dumps reported on failure */
     *msg = MSFAIL;
     goto wrapup;
    }

   BSarclnpars(&loc_msg, REPARAMETRIZE_IN_U_AND_V,
                                   extended_surface );
   if( loc_msg != BSSUCC)
   {
	*msg = MSFAIL;
	goto wrapup;
   }

 }

 /*
  * Post the modified geometry into the database
  */
 {
  GRobjid	newobjid;
  struct	GRpost_info info;

  info.construct_flag = FALSE;
  sts = om$send(
    msg = message GRvg.GRpostabsg(
     msg,
     env1,
     &info,
     (IGRchar *) extended_surface,
     &newobjid),
    targetid = sf1->objid, targetos = sf1->osnum, senderid = NULL_OBJID);
   if (! (1 & sts)) goto wrapup;
 }
}

#endif
}

end implementation Root;
