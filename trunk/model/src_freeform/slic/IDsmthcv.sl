command_string	IDFFC_M_SMTHCRV,0,IDSmthCv
class		IDsmthcv
super_class	IDundo
super_class	ECcmd
spec_path	"$MODEL/spec"
product_name	"$MODEL"

specification

/*
Abstract
	This command object removes cusps from the selected curve.

History
	04/28/92 -- JSY
	Add option to selectively remove each cusp at a time.
	Also did major clean up to the code.

	12/06/93 -- JSY
	Fix TR#159310288, TR#159313992 and clean up.

*/

#include "dpstruct.h"
#include "go.h"

/* the following structure is used for dynamics */
struct DP_csp
{
  struct DPele_header hds[2];
  IGRint num_csps, *inds;
  IGRdouble *coords;
  struct IGRbsp_curve *cv;
};

instance
{
  IGRboolean save_geom;
}


implementation
/*
Abstract

Algorithm
	If the element is a curve of type other than GRbcsubbc, then this
	command changes the class of it to GRbcsubbc and toggles the polygon
	on.  If the polygon display is off (for either a curve or surface),
	then this command toggles it on.

*/
/* #include "EC_F.h"
	#include "EC_I.h"
	#include "EC_M.h"
	#include "EC_P.h"
*/

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "msmacros.h"
#include "emsdef.h"
#include "lcdef.h"
#include "lc.h"
#include "emserr.h"
#include "ECcmd_def.h"
#include "EMSssprops.h"
#include "bserr.h"
#include "bsparameters.h"
#include "adpdef.h" 
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "exms.h" 
#include "msdef.h"
#include "msmacros.h" 
#include "grmessage.h"
#include "grmacros.h"
/* #include "madef.h" */
#include "dpstruct.h" 
#include "dperr.h" 
#include "alloca.h"
#include "bsalloccv.h"    /* prototypes */
#include "bscv_copy.h"    /* prototypes */
#include "bscvtstclsd.h"    /* prototypes */
#include "bsdelpolcv.h"    /* prototypes */
#include "bsfindspn.h"    /* prototypes */
#include "bsfndcvcsp.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bsmdelpolcv.h"    /* prototypes */
#include "bsmdstptarr.h"    /* prototypes */
#include <memory.h>    /* prototypes */

#define SEL_CUSP 101	/* supply dynamics */
#define IDSMOOTH_CRV	0
#define ID_CURVE_GEOM	0
#define NO_CUSP		10001

from GRgraphics import GRdisplay;
from GRvg	import EMptatpr, GRgetsize, GRgetgeom, GRpostabsg, GRgetsymb;

/* ********************************************************************	*/
#argsused
static IGRlong IDhandle_select_cv_hilite_cusps(
    IGRlong *msg, 
    struct LC_select_args *lc_args, 
    struct GRevent *locate_event)
{
	IGRint status;
    	struct GRlc_info   *current_object;     /* in locate stack */

 	IGRlong            sts;
	BSrc	           rc;
        struct IGRpointset cusp_points;
	IGRdouble	   *cusp_coordinates;
	struct GRsymbology symb;

        struct DPele_header cusp_buffer;
  	struct IGRbsp_curve *curve_ptr;  
        IGRlong             num_bytes; 

        IGRint             num_cusps;
        IGRdouble          *cusp_parms;
        IGRint             cusp_counter;


    /* ---------------------------------------------------- */
    /* curve_ptr will hold the geometry of the curve        */
    /* ---------------------------------------------------- */
    curve_ptr = NULL;

    *msg = OM_S_SUCCESS;
    status = OM_S_SUCCESS;
    sts = 1;

    /* ------------------------------------------------------------ */
    /* Erase the hilite plane, since there may be another object    */
    /* highlighted which we don't want to be hilited.               */
    /* ------------------------------------------------------------ */
    sts = dp$erase_hilite(msg = msg,
			  objid = lc_args->stack->module.objid,
			  osnum = lc_args->stack->module.osnum);

    /* -------------------------------------------------------- */
    /* Our sole purpose in writing a select handler is so that  */
    /* we can show the user the cusps that are going to be      */
    /* smoothed.  So, call the routine to highlight the cusps,  */
    /* and then simply call the regular select handler, which   */
    /* is LCcselect.                                            */
    /* -------------------------------------------------------- */
    current_object = &lc_args->stack->entry[lc_args->stack->num_entries - 1];

    /* -------------------------------------------------------	*/
    /* Compute the number of bytes required to hold geometry    */
    /* -------------------------------------------------	*/
    sts = om$send(
        msg = message GRvg.GRgetsize(
        msg, 
        &current_object->module_info.md_env.matrix_type,
        current_object->module_info.md_env.matrix,
        &num_bytes), 
        senderid = NULL_OBJID,
        targetid = current_object->located_obj.objid, 
        targetos = current_object->located_obj.osnum); 
    if (!(1 & sts & *msg))   
    {
	*msg = MSFAIL;
	goto ret_end;
    }

    /* ----------------------------------------	*/
    /* Alloc the required memory off the stack	*/
    /* ----------------------------------------	*/
    curve_ptr = (struct IGRbsp_curve *) alloca(num_bytes);
    if (!curve_ptr)
    {
        ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    	*msg = MSFAIL; 
	sts = OM_E_ABORT;
    	goto ret_end;
    }

    /* ----------------------------------------	*/
    /* Get the geometry				*/
    /* ----------------------------------------	*/
    sts = om$send(
        msg = message GRvg.GRgetgeom(
        msg, 
        &current_object->module_info.md_env.matrix_type,
        current_object->module_info.md_env.matrix,
        (IGRchar * ) curve_ptr),
        senderid = NULL_OBJID,
        targetid = current_object->located_obj.objid, 
        targetos = current_object->located_obj.osnum); 
    if (!(1 & sts & *msg))
    {
        *msg = MSFAIL;
	goto ret_end;
    }

    /* ------------------------------------------------------------ */
    /* Now, we need to find out where the cusps are.  We can call   */
    /* BSfndsfcsp, but we need to allocate memory to hold all the   */
    /* cusp u and v parameters.  We don't know how many cusps there */
    /* are, so we allocate for the maximum possible.                */
    /* ------------------------------------------------------------ */
    cusp_parms = NULL;

    cusp_parms = (IGRdouble *) alloca(sizeof(IGRdouble) * 
		 (curve_ptr->num_poles - curve_ptr->order + 1) );
    if ( !cusp_parms) 
    {
        ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	sts = OM_E_ABORT;
	*msg = MSFAIL;
	goto ret_end;
    }

    /* ---------------------------------------- */
    /* This routine finds the U parameters of	*/
    /* all the cusp points in the curve. 	*/
    /* ---------------------------------------- */
    BSfndcvcsp(curve_ptr, &num_cusps, cusp_parms, &rc);
    if(rc != BSSUCC) 
    {
        ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
	*msg = MSFAIL;
	sts = rc;
	goto ret_end;
    }

    /* ---------------------------------------- */
    /* Do not show the following message.      */
    /* 04/28/92 -- JSY                          */
    /* ---------------------------------------- */
    /*
    if(num_cusps > 0) 
    {
 	ex$message(msgnumb=IDFF_M_SMTHCusps, field = ERROR_FIELD); 
    }
    */
    if ( !( num_cusps > 0 ))
    {
 	ex$message(msgnumb=IDFF_M_SMTHCvNoCusp, field = ERROR_FIELD); 
        goto ret_end;
    }

    cusp_coordinates = NULL;
    cusp_coordinates = (IGRdouble *) alloca(sizeof(IGRdouble) * 3 * num_cusps);
    if(! cusp_coordinates)
    {
         *msg = MSFAIL;
         sts = 0;
         goto ret_end;
    }
    cusp_points.num_points = num_cusps;
    cusp_points.points = cusp_coordinates;

    /* ---------------------------------------------------- */
    /* Loop through all of the cusps we found.	            */
    /*      For each one,                                   */
    /*      1) Obtain the coordinates from the U value,     */
    /*      2) store them in the point list.                */
    /* ---------------------------------------------------- */
    for(cusp_counter = 0; cusp_counter < num_cusps;  
                    cusp_counter++)
    {

        /* -------------------------------------------- */
        /* here, we need to obtain the                  */
        /* coordinates of the point corresponding to    */
        /* this U parameter.                            */
        /* -------------------------------------------- */
        sts = om$send(msg = message GRvg.EMptatpr(
	    msg, 
	    &current_object->module_info.md_env.matrix_type,
	    current_object->module_info.md_env.matrix,
            &cusp_parms[cusp_counter],
            1,  /* one param - the U parameter  */
            &cusp_coordinates[cusp_counter * 3]),
            senderid = NULL_OBJID,
       	    targetid = current_object->located_obj.objid,
       	    targetos = current_object->located_obj.osnum);
	if(!(1&*msg&sts))
	{
	    *msg = MSFAIL;
	    goto ret_end;
	}
    }  /* end of cusp_counter loop through u parameters */
	
    /* ----------------------------------------------------	*/
    /* Now, get the symbology of the curve so we can draw our   */
    /* points in the same symbology.                            */
    /* Make the weight of the points we are going to draw to	*/
    /* be a little greater than the weight of the curve.	*/
    /* ----------------------------------------------------	*/
    sts = om$send(msg = message GRvg.GRgetsymb(msg, &symb),
		  senderid = NULL_OBJID,
		  targetid = current_object->located_obj.objid,
		  targetos = current_object->located_obj.osnum);
    if(!(1&*msg&sts))
    {
	*msg = MSFAIL;
        goto ret_end;
    }

    /* ---------------------------------------------------- */
    /* Check the weight of the curve.  If we can, make the	*/
    /* weight of our pole be 3 weights higher.  		*/
    /* ---------------------------------------------------- */
    if((IGRint) symb.display_attr.weight < GR_HI_WEIGHT - 3)
        symb.display_attr.weight += 3;
    else
        symb.display_attr.weight = GR_HI_WEIGHT;

    dp$build_dis_buffer(buffer = &cusp_buffer,
			type = IGRPS,
			display_att = &(symb.display_attr),
			geometry = &cusp_points);

    dp$display(msg = msg,
	       mode = GRhd,
	       num_elem = 1,
	       buffer = &cusp_buffer);
    if(!(1&*msg))
    {
	*msg = MSFAIL;
	goto ret_end;
    }

ret_end:
    /* -------------------------------------------------------- */
    /* It is NECESSARY to return the status from LCcselect!!    */
    /* -------------------------------------------------------- */
    status = LCcselect(msg, lc_args);
    sts = status;
    if (!(1&sts))
        return OM_E_ABORT;
    else
        return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Function to do real dynamics                                         *
 *----------------------------------------------------------------------*/
#argsused
static IGRlong IDdyn_rmcsp(
        struct DP_csp *DYinfo, 
        struct EX_button *point, 
        IGRdouble *matrix, 
        struct GRid **objects, 
        IGRint *num_objects, 
        struct DPele_header **buffers, 
        IGRint *num_buffers, 
        IGRchar *dummy_in1, IGRchar *dummy_in2, IGRchar *dummy_in3, 
        IGRchar *dummy_out1, IGRchar *dummy_out2, IGRchar *dummy_out3)
{
  IGRpoint pt, pole;
  struct IGRbsp_curve *bspcv;
  IGRdouble dist;
  IGRint ind1, ind2;
  IGRlong msg;

  /* initialize */
  pt[0] = point->x;
  pt[1] = point->y;
  pt[2] = point->z;
  bspcv = DYinfo->hds[1].geometry.bspcurve;
  BScv_copy( &msg, DYinfo->cv, bspcv );

  /* find out which cusp we want to remove */
  BSmdstptarr( 1, &pt, DYinfo->num_csps, ( IGRpoint * ) DYinfo->coords,
	       &ind1, &ind2, &dist, &msg );

  /* delete the pole corresponding to the cusp */
  if ( DYinfo->inds[ind2] > 0 )
  {
    /* copy the cusp to the pole in DP_csp structure */
    memcpy( (char *) pole, (char *) ( DYinfo->coords + ind2 * 3 ),
	    sizeof( IGRpoint ));
    BSdelpolcv( pole, bspcv, &msg );

    /* display them */
    *buffers = DYinfo->hds;
    *num_buffers = 2;
  }
  else
  {
    *buffers = &DYinfo->hds[0];
    *num_buffers = 1;
  }

  return OM_S_SUCCESS;
}

/* ********************************************************************	*/

state_table
#include <msdef.h>
#include <ECcmd_def.h>
#include "IDffmsg.h"
#include "IDffcmd.h"

#define SEL_CUSP 101	/* supply dynamics */
#define IDSMOOTH_CRV	0
#define TRUE 1
#define FALSE 0
#define ID_CURVE_GEOM	0
#define NO_CUSP		10001

at wakeup
  do setup_select_handler
  do message_key IDFFC_M_SMTHCRV

state start
  on CMD_TYPE = IDSMOOTH_CRV
    do message_key IDFFC_M_SMTHCRV
    state start_id

state start_id
  on CMD_TYPE = IDSMOOTH_CRV
    do prompt_key IDFF_P_IdentCrv
    do relocate_key IDFF_E_RelocCrv
    do locate_class "GRbspline"
    state locate_ele

state locate_ele
  locate_display "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
  locate_properties 29 /* locate locatable,displayable,read_write */
  locate_owner LC_FLEX_COMP  /* locate flexible comp */
  accept_key IDFF_P_AccptRejCrv
  filter locate
  on EX_BACK_UP
    state start_id
  on EX_DATA
    do highlight_located 0 /* dehilited locate channel */
    do ECcmd.EMsave_located_object(&me->event1,	&me->located_obj[0])
    do erase_hilite_plane
    do calc_cusps
      on RETURN_CODE = NO_CUSP
 	do status_key IDFF_M_SMTHCvNoCusp
        state start
    state remove_cusps

state remove_cusps
  prompt_key IDFF_P_SmthCvSel
  filter get_event
  on EX_DATA
    do erase_hilite_plane
    do smooth_curve
      on MSFAIL	
        do delete_saved_geom(ID_CURVE_GEOM)
        state not_mod
    state accept_new_curve
  on EX_RJT_MOVEON
    do erase_hilite_plane
    do save_geometry()
    state sel_rm_cusps
  on EX_BACK_UP
    do erase_hilite_plane
    state start_id

state sel_rm_cusps
  prompt_key IDFF_P_SmthCvSelRm
  dynamics SEL_CUSP
  filter get_event
  on EX_BACK_UP
    do calc_cusps
    state remove_cusps
  on EX_RJT_MOVEON
    state accept_new_curve
  on EX_DATA
    do rm_one_cusp
      on RETURN_CODE = NO_CUSP
        state accept_new_curve
    state sel_rm_cusps

state accept_new_curve
  status_key IDFF_P_BckMovUndo
  prompt_key IDFF_P_IdentCrv
  filter get_event
  on EX_BACK_UP
    do restore_original_geometry(&me->ret,
				 &me->located_obj[0],
				 &me->located_obj[0].located_obj.objid)
    do delete_saved_geom(ID_CURVE_GEOM)
    do status_key IDFF_M_CrvRestored
    do init_variables
    state start_id
  on EX_RJT_MOVEON
    do restore_original_geometry(&me->ret,
				 &me->located_obj[0],
				 &me->located_obj[0].located_obj.objid)
    do delete_saved_geom(ID_CURVE_GEOM)
    do status_key IDFF_M_CrvRestored
    do init_variables
    state start_id
  on EX_DATA		
    do delete_saved_geom(ID_CURVE_GEOM)   
    do init_variables
    do feed_event_back_to_locate
    state start_id

state not_mod
  status " "
  on CMD_TYPE = IDSMOOTH_CRV
    do status_key IDFF_E_CrvNotMod
    state start_id

/* ********************************************************************	*/
/* ********************************************************************	*/
/*
Action
        setup_select_handler

Description
        This action sets the pointers for the locate select handler for the
        tentative keypoint snap command.
*/

action setup_select_handler
{
    me->select = ( IGRchar (*)()) IDhandle_select_cv_hilite_cusps;
    me->select_args = (char *) &me->event2;
}

/* ********************************************************************	*/
/*
    Action
        erase_hilite_plane

    Description
        This action erases the highlight plane.

    Note
        This action may be removed when COB adds a keyword to erase the
        highlight plane.
        ----------------------------------------------------------------    */

action erase_hilite_plane
{
    status = dp$erase_hilite(msg = &me->ret,
			     objid = me->ModuleInfo.md_id.objid,
			     osnum = me->ModuleInfo.md_id.osnum);
}

/* ********************************************************************	*/
/* This method calculates number of cusps of the located curve.         */
/* 05/18/92 -- JSY                                                      */
/* ********************************************************************	*/
action calc_cusps
{
  struct IGRbsp_curve *cv;
  struct GRmd_env *md_env;
  struct GRid *id;
  IGRdouble *parms = NULL, *coords = NULL;
  IGRint num_csps, i;
  struct GRsymbology symb;
  struct IGRpointset csps;
  struct IGResbc cv_attr;
  struct DPele_header hd[2];
  IGRlong msg;

  /* get the geometry */
  status = EMget_the_geometry( &me->located_obj[0], TRUE, FALSE, TRUE,
			       my_id, &cv, &msg );
  if ( !( 1 & status ))
  {
    status = OM_E_ABORT;
    goto quit;
  }

  md_env = &me->located_obj[0].module_info;
  id = &me->located_obj[0].located_obj;

  parms = ( IGRdouble * ) om$malloc( size = ( cv->num_poles - cv->order + 1 ) * sizeof( IGRdouble ));
  if ( parms == NULL )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    status = OM_E_ABORT;
    goto quit;
  }

  BSfndcvcsp( cv, &num_csps, parms, &msg );
  if ( msg != BSSUCC )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
    status = OM_E_ABORT;
    goto quit;
  }

  if ( num_csps > 0 )
  {
    coords = ( IGRdouble * ) om$malloc( size = num_csps * sizeof( IGRpoint ));
    if ( coords == NULL )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
      status = OM_E_ABORT;
      goto quit;
    }
    
    for ( i = 0; i < num_csps; i++ )
    {
      /* find coordinates */
      status = om$send( msg = message GRvg.EMptatpr( &msg,
						     &md_env->md_env.matrix_type,
						     md_env->md_env.matrix,
						     &parms[i],
						     1,  /* U parameter */
						     &coords[i * 3] ),
		        targetid = id->objid,
		        targetos = id->osnum );
      if ( !( 1 & status ))
      {
	status = OM_E_ABORT;
	goto quit;
      }
    }

    /* get symbology */
    status = om$send( msg = message GRvg.GRgetsymb( &msg, &symb ),
		      targetid = id->objid,
		      targetos = id->osnum );
    if ( !( 1 & status ))
    {
      status = OM_E_ABORT;
      goto quit;
    }

    if ( (IGRint)symb.display_attr.weight < GR_HI_WEIGHT - 3 )
      symb.display_attr.weight += 3;
    else
      symb.display_attr.weight = GR_HI_WEIGHT;

    /* we want to display one cusp point dynamically */
    csps.num_points = num_csps;
    csps.points = coords;

    /* build display buffer */
    dp$build_dis_buffer( buffer = &hd[0],
			 type = IGRPS,
			 display_att = &symb.display_attr,
			 geometry = &csps );

    BSmdelpolcv( 1 , cv, &msg );
    BScvtstclsd( cv, &msg );

    /* initialize to display curve but not polygon */
    cv_attr.is_polydis = FALSE;
    cv_attr.is_curvedis = TRUE;

    /* build display buffer for smoothed curve */
    dp$build_dis_buffer( buffer = &hd[1],
			 type = IGRBC,
			 display_att = &me->ActiveDisplay,
			 ele_spec_att = &cv_attr,
			 geometry = cv );

    /* display curve and cusps in highlight */
    dp$display( msg = &msg,
	        mode = GRhd,
	        num_elem = 2,
	        buffer = hd );
  }
  else
    me->ret = NO_CUSP;

  /* free memory */
  BSfreecv( &msg, cv );
  om$dealloc( ptr = parms );
  om$dealloc( ptr = coords );
}

/* ********************************************************************	*/

action feed_event_back_to_locate
{
    long size = sizeof(struct GRevent) - sizeof(long) * 2;
    IGRint response = EX_DATA;
    IGRlong msg;

    status = ex$putque(msg= &msg, byte = &size, response = &response,
		       buffer = (IGRchar *) &ME.CEO_LOCATE->event1.event);
}

/* ********************************************************************	*/
/* This method saves the original curve geometry                        */
/* 04/28/92 -- JSY                                                      */
/* ********************************************************************	*/
action save_geometry()
{
  struct IGRbsp_curve *cv;
  IGRlong msg;

  if ( me->save_geom == FALSE )
  {
    /* get the geometry */
    status = EMget_the_geometry( &me->located_obj[0], TRUE, FALSE, FALSE,
				 my_id, &cv, &msg );
    if ( !( 1 & status ))
    {
      status = OM_E_ABORT;
      goto quit;
    }

    /* save the original geometry */
    status = om$send( msg = message IDundo.save_original_geometry( &msg,
								   ( char * ) cv,
								   ID_CURVE_GEOM ),
		      mode = OM_e_wrt_message,
		      targetid = my_id );

    if ( cv )
      om$dealloc( ptr = cv );
    me->save_geom = TRUE;
  }
}

/* ********************************************************************	*/
/* This method dynamically determines the cusp that will be smoothed    */
/* 04/28/92 -- JSY                                                      */
/* ********************************************************************	*/
action dynamics
{
  struct GRmd_env *md_env;
  struct GRid *id;
  struct DP_csp csps;
  IGRdouble *csp_parms = NULL;
  IGRint i;
  struct GRsymbology symb;
  struct IGRpointset csp_point;
  struct IGRbsp_curve *sm_cv;
  struct IGResbc cv_attr;
  IGRlong msg;

  /* get the geometry */
  status = EMget_the_geometry( &me->located_obj[0], TRUE, FALSE, FALSE,
			       my_id, &csps.cv, &msg );
  if ( !( 1 & status ))
  {
    status = OM_E_ABORT;
    goto quit;
  }

  md_env = &me->located_obj[0].module_info;
  id = &me->located_obj[0].located_obj;

  csp_parms = ( IGRdouble * ) om$malloc( size = ( csps.cv->num_poles - csps.cv->order + 1 ) * sizeof( IGRdouble ));
  if ( csp_parms == NULL )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    status = OM_E_ABORT;
    goto quit;
  }

  /* ---------------------------------------- */
  /* This routine finds the U parameters of   */
  /* all the cusp points in the curve. 	      */
  /* ---------------------------------------- */
  BSfndcvcsp( csps.cv, &csps.num_csps, csp_parms, &msg );
  if ( msg != BSSUCC )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
    status = OM_E_ABORT;
    goto quit;
  }

  if ( csps.num_csps > 0 )
  {
    csps.coords = ( IGRdouble * ) om$malloc( size = csps.num_csps * sizeof( IGRpoint ));
    if ( csps.coords == NULL )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
      status = OM_E_ABORT;
      goto quit;
    }
    csps.inds = ( IGRint * ) om$malloc( size = csps.num_csps * sizeof( IGRint ));
    if ( csps.inds == NULL )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
      status = OM_E_ABORT;
      goto quit;
    }
    
    for ( i = 0; i < csps.num_csps; i++ )
    {
      /* find coordinates */
      status = om$send( msg = message GRvg.EMptatpr( &msg,
						     &md_env->md_env.matrix_type,
						     md_env->md_env.matrix,
						     &csp_parms[i],
						     1,  /* U parameter */
						     &csps.coords[i * 3] ),
		        targetid = id->objid,
		        targetos = id->osnum );
      if ( !( 1 & status ))
      {
	status = OM_E_ABORT;
	goto quit;
      }

      /* find span indices */
      BSfindspn( &msg, &csps.cv->order, &csps.cv->num_poles, csps.cv->knots,
		 &csp_parms[i], &csps.inds[i] );
    }

    /* get symbology */
    status = om$send( msg = message GRvg.GRgetsymb( &msg, &symb ),
		      targetid = id->objid,
		      targetos = id->osnum );
    if ( !( 1 & status ))
    {
      status = OM_E_ABORT;
      goto quit;
    }

    /* ---------------------------------------------------- */
    /* Check the weight of the curve.  If we can, make the  */
    /* weight of our pole be 3 weights higher.  	    */
    /* ---------------------------------------------------- */
    if ( (IGRint)symb.display_attr.weight < GR_HI_WEIGHT - 3 )
      symb.display_attr.weight += 3;
    else
      symb.display_attr.weight = GR_HI_WEIGHT;

    /* we want to display one cusp point dynamically */
    csp_point.num_points = csps.num_csps;
    csp_point.points = csps.coords;

    /* build display buffer */
    dp$build_dis_buffer( buffer = &csps.hds[0],
			 type = IGRPS,
			 display_att = &symb.display_attr,
			 geometry = &csp_point );

    /* allocate a curve to store and show the smoothed curve */
    BSalloccv( csps.cv->order, csps.cv->num_poles, csps.cv->rational, 0,
	       &sm_cv, &msg );

    /* initialize to display curve but not polygon */
    cv_attr.is_polydis = FALSE;
    cv_attr.is_curvedis = TRUE;

    /* build display buffer for smoothed curve */
    dp$build_dis_buffer( buffer = &csps.hds[1],
			 type = IGRBC,
			 display_att = &me->ActiveDisplay,
			 ele_spec_att = &cv_attr,
			 geometry = sm_cv );

    /* perform dynamics */
    status = dp$dynamics( dyn_fun = IDdyn_rmcsp,
			  information = &csps );

    /* free memory */
    om$dealloc( ptr = csps.coords );
    om$dealloc( ptr = csps.inds );
    BSfreecv( &msg, sm_cv );
  }
  else 
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_M_SMTHCvNoCusp );
  }

  /* free memory */
  if ( csps.cv )
    om$dealloc( ptr = csps.cv );
  om$dealloc( ptr = csp_parms );
}

/* ********************************************************************	*/
/* This method removes one selected cusp                                */
/* 04/28/92 -- JSY                                                      */
/* ********************************************************************	*/
action rm_one_cusp
{
  struct IGRbsp_curve *cv;
  struct GRmd_env *md_env;
  struct GRid *id;
  IGRdouble *csp_parms = NULL;
  IGRint num_csps;
  struct GRpost_info info;
  GRobjid new_objid;
  IGRlong msg;

  /* get the geometry */
  status = EMget_the_geometry( &me->located_obj[0], TRUE, FALSE, FALSE,
			       my_id, &cv, &msg );
  if ( !( 1 & status ))
  {
    status = OM_E_ABORT;
    goto quit;
  }

  md_env = &me->located_obj[0].module_info;
  id = &me->located_obj[0].located_obj;

  csp_parms = ( IGRdouble * ) om$malloc( size = ( cv->num_poles - cv->order + 1 ) * sizeof( IGRdouble ));
  if ( csp_parms == NULL )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    status = OM_E_ABORT;
    goto quit;
  }

  /* ---------------------------------------- */
  /* This routine finds the U parameters of   */
  /* all the cusp points in the curve. 	      */
  /* ---------------------------------------- */
  BSfndcvcsp( cv, &num_csps, csp_parms, &msg );
  if ( msg != BSSUCC )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
    status = OM_E_ABORT;
    goto quit;
  }
  om$dealloc( ptr = csp_parms );

  if ( num_csps > 0 )
  {
    /* erase the original curve */
    gr$display_object( object_id = id,
		       mode = GRbe );

    /* call bsp routine to modify geometry */
    BSdelpolcv( &me->event1.event.button.x, cv, &msg );
    BScvtstclsd( cv, &msg );

    /* post modified geometry */
    info.construct_flag = FALSE;
    status = om$send( msg = message GRvg.GRpostabsg( &msg,
						     md_env,
						     &info,
						     ( IGRchar * ) cv, 
						     &new_objid ),
		      targetid = id->objid,
		      targetos = id->osnum );
    if ( !( 1 & status ))
    {
      if ( cv )
	om$dealloc( ptr = cv );
      status = OM_E_ABORT;
      goto quit;
    }

    /* clear the object cache so that we show the new change */
    GRabsg_del_by_objid( &id->objid, &id->osnum );

    /* display modified object */
    gr$display_object( object_id = id,
		       mode = GRbd );

    /* check to see if the curve has any cusps left */
    if ( num_csps <= 1 )
      me->ret = NO_CUSP;
  }
  else
    me->ret = NO_CUSP;

  if ( cv )
    om$dealloc( ptr = cv );
}

/* ********************************************************************	*/
/* This method does the actual removal of the pole from the curve and	*/
/* then posts the new geometry.  Erasure of old geometry and display	*/
/* of the new geometry is done too.					*/
/*	dependent on:							*/
/*		me->located_obj						*/
/*		me->event1						*/
/*		------------------------------------------------------- */
action smooth_curve
{
    IGRlong		msg;
    BSrc			rc;
    struct GRpost_info  	info;

    struct IGRbsp_curve        *curve_ptr;
    IGRlong         num_bytes; 


    curve_ptr = NULL;

    msg = OM_S_SUCCESS;


    /* ------------------------------------ */
    /* Compute the number of bytes required */
    /* ------------------------------------ */
    *sts = om$send(
    msg = message GRvg.GRgetsize(
            &msg, 
            &me->located_obj[0].module_info.md_env.matrix_type,
            me->located_obj[0].module_info.md_env.matrix,
            &num_bytes), 
        senderid = my_id, 
        targetid = me->located_obj[0].located_obj.objid, 
        targetos = me->located_obj[0].located_obj.osnum); 
    if (!(1 & *sts & msg))   
    {
	*sts = MSFAIL;
	goto ret_end;
    }

    /* ----------------------------------------------------	*/
    /* Alloc the required memory off the stack		*/
    /* ----------------------------------------------------	*/
    /* curve_ptr = (struct IGRbsp_curve *) stackalloc(num_bytes); */
    curve_ptr = (struct IGRbsp_curve *) alloca(num_bytes);
    if (!curve_ptr)
    {
        ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    	*sts = MSFAIL; 
    	goto ret_end;
    }


    /* ------------------------------------	*/
    /* Get the geometry			*/
    /* ------------------------------------	*/
    *sts = om$send(
            msg = message GRvg.GRgetgeom(
            &msg, 
            &me->located_obj[0].module_info.md_env.matrix_type,
            me->located_obj[0].module_info.md_env.matrix,
            (IGRchar * ) curve_ptr),
        senderid = my_id, 
        targetid = me->located_obj[0].located_obj.objid, 
        targetos = me->located_obj[0].located_obj.osnum); 
    if (!(1 & *sts & msg))
    {
	*sts = MSFAIL;
	goto ret_end;
    }


    me->DisplayMode = GRbe;
    status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg,
			&me->located_obj[0].module_info.md_env.
                        matrix_type, me->located_obj[0].module_info.
                        md_env.matrix, &me->DisplayMode,
                        &me->located_obj[0].module_info.md_id),
                   senderid = my_id,
                   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);

    /* -------------------------------------------------- */
    /* Added test to guarantee that the geometry is saved */
    /* only once. 04/28/92 -- JSY                         */
    /* -------------------------------------------------- */
    if ( me->save_geom == FALSE )
    {
      status = om$send(msg = message IDundo.save_original_geometry(&msg, 
		       (char *)curve_ptr, ID_CURVE_GEOM),
                       mode = OM_e_wrt_message,
                       targetid = my_id);
      EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
      EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);

      me->save_geom = TRUE;
    }

    /* ------------------------------------------------------------
     *  option 	(0) Remove poles corresponding to multiple knots
     *	        (1) Remove poles corresponding to cusps
     * ------------------------------------------------------------ */
    BSmdelpolcv( 1 , curve_ptr, &rc );
    BScvtstclsd( curve_ptr, &rc );


    info.construct_flag = FALSE;
    status = om$send(msg = message GRvg.GRpostabsg(&msg,
                         &me->located_obj[0].module_info, &info,
                         (IGRchar *) curve_ptr, 
			&me->located_obj[0].located_obj.objid),
                   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRpostabsg error\n");
    EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);


    /* put this in to clear the object cache so that we show the new change */
    GRabsg_del_by_objid(&me->located_obj[0].located_obj.objid, &me->located_obj[0].located_obj.osnum);


ret_end:
    me->DisplayMode = GRbd;
    status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg,
				&me->located_obj[0].module_info.md_env.
                            	matrix_type, me->located_obj[0].module_info.
                            	md_env.matrix, &me->DisplayMode,
                            	&me->located_obj[0].module_info.md_id),
                   senderid = my_id,
                   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
    EMomerr_hndlr(status, quit, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, quit);
}

/* ********************************************************************	*/
/* This method exists so that we can initialize, and just as 		*/
/* importantly, REinitialize our variables.				*/
/*	--------------------------------------------------------------- */
action init_variables
{
    me->located_obj[0].located_obj.objid = NULL_OBJID;
    me->save_geom = FALSE;
}

/* ********************************************************************	*/
action init
{
    IGRlong msg;

    /* ------------------------------------------------ */
    /* send init message to ECcmd since Undo does not */
    /* ------------------------------------------------ */
    status = om$send(msg = message ECcmd.init(type, str_ptr),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "ECcmd init");

    /* ------------------------------------------------ */
    /* send init message to IDundo                      */
    /* ------------------------------------------------ */
    status = om$send(msg = message IDundo.init(type, str_ptr),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "IDundo init");

    status = om$send(msg = message IDsmthcv.init_variables(&msg),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
}

/* ********************************************************************	*/
action delete
{
    /* ------------------------------------------------------------ */
    /* send delete message to IDundo so it can delete saved geom    */
    /* ------------------------------------------------------------ */
    status = om$send(msg = message IDundo.delete(f_defer_flag),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDsmthsf's parent delete\n");

    /* ------------------------------------------------ */
    /* send delete message to ECcmd since Undo does not */
    /* ------------------------------------------------ */
    status = om$send(msg = message ECcmd.delete(f_defer_flag),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDsmthsf's parent delete\n");
}
