class implementation Root;
#include "OMtypes.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMprimitives.h"
#include "exdef.h"
#include "exmacros.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "go.h"
#include "gocmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "dpezmac.h"
#include "bstypes.h"
#include "bsconic.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "EMSasnuc.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

#define FRACTION 0.1

static struct IGRdisplay act_disp;
static struct GRmd_env   display_env;
static IGRdouble  	 vector_len;

extern double BSdistptpt();

init_dof_display()
{
IGRlong rc, count;
GRrange range;
struct  GRid sv_ids[20], mod_id;


    gr$get_active_display( buffer = &act_disp);

    gr$get_display_env( buffer = &display_env );

    vector_len = 2.0; 
    mod_id.osnum = display_env.md_id.osnum;
    ex$get_modid(mod_osnum = mod_id.osnum,
                 mod_id = &mod_id.objid);
                         
    dp$get_gragad_id(msg = &rc,
                     mod_GRid = &mod_id, 
                     name = "*",
                     numberofids = &count,
                     array_size = 20,
                     found_GRids = sv_ids);

    if( !count )
    {        
        dp$get_saved_vw_id(msg = &rc, 
                       osnum = display_env.md_id.osnum,
                       name = "*",
                       numberofids = (IGRlong *)&count,
                       found_GRids = sv_ids,
                       array_size = 20, 
                       total_num = &count);
    }

    if( count )
    {   
        dp$inq_window_info(msg=&rc,
                     osnum = sv_ids[0].osnum,
    		     window_objid = sv_ids[0].objid,
              	     vw_volume = range);

	if( rc & 1 )
	{
	        vector_len = BSdistptpt(&rc,
	 		 &range[0],
	 		 &range[3]);

        	vector_len /= 10.0;         /* 10% of view vol */
	}
    }                                           

    return( 1 );
}


display_mate_dof( feature_id, feature_env, mode )
struct GRid *feature_id;
struct GRmd_env *feature_env;
{
long msg;
IGRpoint xpt;
GRrange range;
IGRvector uni_vector[2], normal;
double radius;
      
        if(!EMgetsurf( feature_id, feature_env, xpt, uni_vector, normal))
            return(0);

	range[0] = 0.; range[3] = vector_len;/*2.0;*/
	EFdraw_vector_on_screen(
				feature_id->objid,
 				&act_disp,
 				&display_env,
 				(enum GRdpmode)mode,
 				0,
 				xpt,
 				uni_vector[0],
 				range,
 				&msg);

	EFdraw_vector_on_screen(
				feature_id->objid,
 				&act_disp,
 				&display_env,
 				(enum GRdpmode)mode,
 				0,
 				xpt,
 				uni_vector[1],
 				range,
 				&msg);

	/* Draw a circle with xpt as center and radius as FRACTION of 
		edge length
	*/
	radius = vector_len/2.; /*1.0;*/
        EMdraw_circle_on_screen( xpt, radius, normal, mode );

	return( 1 );
}


/*
 * If type = 0   Display the translation along the Align axis
 *    type = 1   Display the rotation    on    the Align axis
 *    type = 2   Display both translation and rotation on Align axis
 */
display_align_dof( feature_grid, env, mode, type )
struct GRid *feature_grid;
struct GRmd_env *env;
int mode, type;
{
    if( type != 1 )
        if( !display_trans_vec( feature_grid, env, mode ) )
            return( 0 );
    if( type != 0 )
        if( !display_rot_vec ( feature_grid, env, mode ) )
            return( 0 );
    
    return( 1 );
}


display_mate_mate_dof( feature_grid, env, mode )
struct GRid *feature_grid;
struct GRmd_env *env;
int mode;
{
int    i;
long   msg;
IGRvector uni_vector[2], normal1, normal2, dirvec;
IGRpoint  cenpt[2];
GRrange   range;

    if(!EMgetsurf( &feature_grid[0], &env[0], cenpt[0], uni_vector, normal1))
        return(0);

    if(!EMgetsurf( &feature_grid[1], &env[1], cenpt[1], uni_vector, normal2))
        return(0);

    BScrossp(&msg, normal1, normal2, dirvec);
    BSnorvec(&msg, dirvec);
    /*
     * Find the center of the features and draw vectors 
     */
        range[0] = 0.0;
        range[3] = vector_len;/*2.0;*/
        EFdraw_vector_on_screen(
			feature_grid[1].objid,
			&act_disp,
			&display_env,
			(enum GRdpmode)mode,
			0,
			cenpt[1],
			dirvec,
			range,
			&msg);

    return( 1 );
}

display_align_align_dof( feature_grid, env, mode )
struct GRid *feature_grid;
struct GRmd_env *env;
int mode;
{
int i;

    for( i = 0; i < 2; i++ )
        display_trans_vec( feature_grid[i], env[i], mode );

    return( 1 );
}

EMdraw_circle_on_screen( center, radius, normal, mode )
IGRpoint center;
IGRint   mode;
IGRdouble radius;
IGRvector normal;
{
int  ret, type;
long msg;
IGRvector uni_vector;
struct IGRbsp_curve circ;
struct DPele_header displayHeader;
struct IGResbc cvElementSpecific;

    circ.poles = (double *)malloc( 3 * sizeof(double) * BSCIRCLE_NUM_POLES_MAX);
    circ.knots = (double *)malloc( sizeof(double) * BSCIRCLE_NUM_KNOTS_MAX);
    circ.weights = (double *)malloc( sizeof(double) * BSCIRCLE_NUM_POLES_MAX);

    ret = BSprepcirc(&msg, center, &radius, normal, &circ, uni_vector, &type);
    if( ! ret )
    	verbose(printf("bsprepcirc failed\n"));

    cvElementSpecific.is_polydis = FALSE;
    cvElementSpecific.is_curvedis = TRUE;

    dp$build_dis_buffer (
            buffer = &displayHeader,
            type = type,
            display_att = &act_disp,
            ele_spec_att = &cvElementSpecific,
            geometry = &circ );

    dp$display (
            msg = &msg,
            osnum = display_env.md_id.osnum,
            objid = display_env.md_id.objid,
            mode = mode,
            num_elem = 1,
            buffer = &displayHeader );

    return( 1 );
}

display_trans_vec( feature_grid, env, mode )
struct GRid *feature_grid;
struct GRmd_env *env;
int mode;
{
int  i, type;
long msg;
IGRpoint axis[2];
IGRpoint arrows[2][3];
IGRpoint xpt[2];
IGRdouble dist;
IGRvector vect;

    if( !EMgetaxis( feature_grid, env, axis, &type ))
        return(0);

    for( i = 0; i < 3; i ++ )
        xpt[0][i] = (axis[0][i] + axis[1][i])/2.;

    dist = BSdistptpt( &msg, axis[0], axis[1] );
    for( i = 0; i < 3; i++ )
    {
	vect[i] = ( axis[1][i] - axis[0][i] )/dist;
        xpt[1][i] = xpt[0][i] + vect[i]*vector_len;/*vect[i];*/
    }
    EMdisppts (2,xpt, &act_disp, TRUE, mode, &display_env.md_id);
    /*
     * Also display the arrow-head(s) at the end-point
     * of this axis.
     */
    EMgetarrowheads (&msg, xpt, arrows, 0.3);
    EMdisppts (3, arrows[0], &act_disp, TRUE, mode, &display_env.md_id);
    EMdisppts (3, arrows[1], &act_disp, TRUE, mode, &display_env.md_id);

    return( 1 );
}

display_rot_vec( feature_grid, env, mode )
struct GRid *feature_grid;
struct GRmd_env *env;
int mode;
{
int  i, type;
long msg;
IGRpoint xpt, axis[2];
IGRdouble dist;
IGRvector normal;

    if( !EMgetaxis( feature_grid, env, axis, &type ))
        return(0);
    /*
     * Take the center of the parameter vector as the circle center
     */
    for( i = 0; i < 3; i ++ )
        xpt[i] = ( axis[0][i] + axis[1][i] ) / 2.;
    
    dist = BSdistptpt( &msg, axis[0], axis[1] );

    for( i = 0; i < 3; i++ )
	normal[i] = ( axis[1][i] - axis[0][i])/dist;

    EMdraw_circle_on_screen( xpt, 0.5, normal, mode );
    
    return( 1 );
}

end implementation Root;
