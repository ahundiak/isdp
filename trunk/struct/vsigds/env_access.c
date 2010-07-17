#include <stdio.h>

#define	on_vax	0
#include "sysdata.h"
#include "idenvelope.h"

static short		env_cmp_no = 0;
static short		env_dgn_no = 1;
static short		env_shp_no = 0;
static char		first = 1;
static int	        local_bs_data;

env_open( file_name )
char	*file_name;
{
  static short	open_type=1;		/* create a new file */

  first = 1;
  env_cmp_no = 0;
  return( SEF_OPEN_FILE( file_name , &open_type ) );
}


env_close(  )
{
  static short	status = 1;
  char	*p;

  p = ( char * ) local_bs_data;
  if ( p != NULL )
    free( p );
  return( SEF_CLOSE_FILE_ONLY( &status ) );
}


env_write_tolerances( cyl_len_cone , cyl_len_ellipse , no_cyl_90_degree ,
		      slicing_distance , construction_tolerance )
double	*cyl_len_cone , *cyl_len_ellipse , *slicing_distance , *construction_tolerance;
short	*no_cyl_90_degree;
{
  struct system_data 	sys;
 
  sys.cyl_len_cone = *cyl_len_cone;
  sys.cyl_len_ellips = *cyl_len_ellipse;
  sys.slicing_dist = *slicing_distance;
  sys.no_cyl_90_degree = *no_cyl_90_degree;
  sys.delta_radius = *construction_tolerance;
  return ( SEF_WRITE_SYS( &sys ) );
}





env_write_design( uor_per_su , su_per_mu , global_origin , range , 
		  sys_of_units , munit , sunit , dgn_file , db_file )
int	*uor_per_su , *su_per_mu , *global_origin[] , *range[];
short	*sys_of_units;
char 	*munit , *sunit , *dgn_file , *db_file;
{
  design_data dgn;
  int	local_global[3];
  short	size;
  int	length;

  dgn.model_no = 1;
  dgn.uor_per_su = *uor_per_su;
  dgn.su_per_mu = *su_per_mu;
  size = 12;
  memcpy( local_global , global_origin , size );  
  dgn.gbl_x_uor = local_global[0];
  dgn.gbl_y_uor = local_global[1];
  dgn.gbl_z_uor = local_global[2];
  size = 24;
  memcpy( dgn.range , range , size );
  dgn.sys_of_units = *sys_of_units;
  length = 2;
  strncpy( dgn.munit , munit , length );
  strncpy( dgn.sunit , sunit , length );
  length = 64;
  strncpy( dgn.dgn_file , dgn_file , length );
  strncpy( dgn.db_file , db_file , length );
  return( SEF_WRITE_DGN( &env_dgn_no , &dgn ) );
}


env_rewrite_component_range( component_range )
int	*component_range;
{
  SEF_REWRITE_CMP_RANGE_FILE( component_range );
}

env_write_component( approval_status , model_item , entity , occ , 
		     number_cp , component_name , 
		     component_description , component_range ,
 		     connect_points )
char	*approval_status;
short	*model_item , *entity , *number_cp;
int 	*occ;
char	*component_name , *component_description;
int	*connect_points[] , *component_range[];

{
  component_data	cmp;
  int			length;
  short			size;


  env_shp_no = 0;
  env_cmp_no = env_cmp_no + 1;	
  cmp.su.size[3] = *entity;
  cmp.su.size[4] = *model_item;		/* 0 unless assigned by checker */
  cmp.su.size[6] = *number_cp;
  cmp.cu.chr[79] = *approval_status;
  if( cmp.su.size[6] > 0 )
    {
    if ( cmp.su.size[6] < 51 )  
      {
      cmp.su.size[5] = 3;    
      }
    else
      {
      return( 0 );
      }
    }
  else
    {
    cmp.su.size[5] = 0;
    }
  cmp.nu.cmp_no[0] = env_cmp_no;
  cmp.nu.cmp_no[1] = *occ;
  size = 24;
  memcpy( cmp.ru.range , component_range , size );
  cmp.cu.chr[6] = 1;
  length = 20;
  strncpy( &cmp.cu.chr[7] , component_name , length );   
  cmp.cu.chr[34] = 0;					/* has not been emulated */
  length = 40;
  strncpy( &cmp.cu.chr[35] , component_description , length );
  size = 12 * cmp.su.size[6];
  memcpy( cmp.cp_data.other_cmp.cp , connect_points , size );
  return( SEF_WRITE_CMP_FILE( &env_dgn_no , &env_cmp_no , &cmp ) );
}




env_write_cylinder( solid_hole , hard_soft , cylinder_range , 
		    primary , secondary , cylinder_origin ,
		    cylinder_length , cylinder_radius )

short	*solid_hole , *hard_soft;
int	*cylinder_range , *cylinder_origin , *cylinder_length , *cylinder_radius;
double	*primary , *secondary;
{
  basic_shape_data	sh;
  short			size;

  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 1;
  sh.su.size[2] = *solid_hole;
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , cylinder_range , size );
  memcpy( sh.geom.cylinder.cy_pri , primary , size );
  memcpy( sh.geom.cylinder.cy_sec , secondary , size );
  size = 12;
  memcpy( sh.geom.cylinder.cy_p , cylinder_origin , size );
  sh.geom.cylinder.cy_len = *cylinder_length;
  sh.geom.cylinder.cy_rad = *cylinder_radius;
  return( SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh ) );
}





env_write_cone( hard_soft , cone_range , 
		    primary , secondary , cone_origin , cone_end ,
		    cone_length , origin_radius , end_radius , cone_type )
char	*cone_type;
short   *hard_soft;
int	*cone_range , *cone_origin , *cone_end , *cone_length , *origin_radius;
int	*end_radius;
double	*primary , *secondary;
{
  basic_shape_data	sh;
  short			size;

  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 2;
  sh.su.size[2] = 1;				/*	solid 	*/
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , cone_range , size );
  memcpy( sh.geom.conic.co_pri , primary , size );
  memcpy( sh.geom.conic.co_sec , secondary , size );
  size = 12;
  memcpy( sh.geom.conic.co_p , cone_origin , size );
  memcpy( sh.geom.conic.co_p2 , cone_end , size );
  sh.geom.conic.co_len = *cone_length;
  sh.geom.conic.co_rad_1 = *origin_radius;
  sh.geom.conic.co_rad_2 = *end_radius;
  sh.geom.conic.co_type = *cone_type;
  
  return( SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh ) );
}




env_write_torus( hard_soft , torus_range , 
		    primary , secondary , torus_origin , ellipse_center ,
		    torus_sweep_angle , torus_radius , ellipse_radius )

short	*hard_soft;
int	*torus_range , *torus_origin , *ellipse_center;
int	*ellipse_radius , *torus_radius;
double	*primary , *secondary , *torus_sweep_angle;
{
  basic_shape_data	sh;
  short			size;

  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 3;
  sh.su.size[2] = 1;				/*	solid 	*/
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , torus_range , size );
  memcpy( sh.geom.toroid.to_pri , primary , size );
  memcpy( sh.geom.toroid.to_sec , secondary , size );
  size = 12;
  memcpy( sh.geom.toroid.to_p , torus_origin , size );
  memcpy( sh.geom.toroid.to_p1 , ellipse_center , size );
  sh.geom.toroid.to_sweep_angle = *torus_sweep_angle;
  sh.geom.toroid.to_rad = *torus_radius;
  sh.geom.toroid.to_ellipse_rad = *ellipse_radius;
  return( SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh ) );
}



env_write_projected_shape( solid_hole , hard_soft , ps_range , 
		    primary , secondary , ps_length , number_vertex , vertex )

int	*ps_range , *ps_length , *vertex;
short	*solid_hole , *hard_soft , *number_vertex;
double	*primary , *secondary ;
{
  basic_shape_data	sh;
  short			size;

  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 4;
  sh.su.size[2] = *solid_hole;
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , ps_range , size );
  memcpy( sh.geom.projected_shape.ps_pri , primary , size );
  memcpy( sh.geom.projected_shape.ps_sec , secondary , size );
  sh.geom.projected_shape.ps_len = *ps_length;
  sh.geom.projected_shape.pu.ps_no_point = *number_vertex;
  size = 12 * sh.geom.projected_shape.pu.ps_no_point;
  memcpy( sh.geom.projected_shape.ps_p , vertex , size );
  return( SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh ) );
}





env_write_ellipsoid( hard_soft , el_range , primary , secondary ,
		     el_origin , el_primary_radius , el_secondary_radius )

int	*el_range , *el_primary_radius , *el_secondary_radius , *el_origin;
short   *hard_soft ;
double	*primary , *secondary ;
{
  basic_shape_data	sh;
  short			size;

  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 5;
  sh.su.size[2] = 1;				/*	solid 	*/
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , el_range , size );
  memcpy( sh.geom.semi_ellipsoid.el_pri , primary , size );
  memcpy( sh.geom.semi_ellipsoid.el_sec , secondary , size );
  size = 12;
  memcpy( sh.geom.semi_ellipsoid.el_p , el_origin , size );
  sh.geom.semi_ellipsoid.el_rad_pri = *el_primary_radius;
  sh.geom.semi_ellipsoid.el_rad_sec = *el_secondary_radius;
  return( SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh ) );
}





env_write_revolved_shape( hard_soft , rs_range , 
		    primary , secondary , rs_sweep_angle ,
		    number_vertex , vertex , rotation_axis_point_1 , 
		    rotation_axis_point_2 )

int	*rs_range , *vertex , *rotation_axis_point_1 , *rotation_axis_point_2;
short   *hard_soft , *number_vertex;
double	*primary , *secondary , *rs_sweep_angle;
{
  basic_shape_data	sh;
  short			size;

  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 6;
  sh.su.size[2] = 1;				/*	solid 	*/
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , rs_range , size );
  memcpy( sh.geom.revolved_shape.rs_pri , primary , size );
  memcpy( sh.geom.revolved_shape.rs_sec , secondary , size );
  sh.geom.revolved_shape.pu.rs_no_point = *number_vertex;
  sh.geom.revolved_shape.rs_sweep_angle = *rs_sweep_angle;
  size = 12;
  memcpy( sh.geom.revolved_shape.rs_ref_1 , rotation_axis_point_1 , size );
  memcpy( sh.geom.revolved_shape.rs_ref_2 , rotation_axis_point_2 , size );
  size = 12 * sh.geom.revolved_shape.pu.rs_no_point;
  memcpy( sh.geom.revolved_shape.rs_p , vertex , size );
  return( SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh ) );
}




env_write_cylindrical_string( hard_soft , cs_range , 
		    cs_radius , number_vertex , vertex )

int	*cs_range , *vertex , *cs_radius;
short   *hard_soft , *number_vertex;
{
  basic_shape_data	sh;
  short			size;

  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 8;
  sh.su.size[2] = 1;				/*	solid 	*/
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , cs_range , size );
  sh.geom.cylindrical_string.cs_rad = *cs_radius;
  sh.geom.cylindrical_string.pu.cs_no_point = *number_vertex;
  size = 12 * sh.geom.cylindrical_string.pu.cs_no_point;
  memcpy( sh.geom.cylindrical_string.cs_p , vertex , size );
  return( SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh ) );
}



env_write_bspline( hard_soft , bs_range , u_order , v_order , u_num_poles , 
		   v_num_poles , u_num_knots , v_num_knots , num_weights ,
		   num_boundry_points ,
		   u_closed , v_closed , zerozero_solid , poles , u_knots ,
		   v_knots , weights , uv_boundry )

int	*bs_range , *u_order , *v_order , *u_num_poles , *v_num_poles ,
	*u_num_knots , *v_num_knots , *num_boundry_points , *u_closed ,
	*v_closed , *zerozero_solid , *poles , *u_knots , *v_knots ,
	*weights , *uv_boundry , *num_weights;

short	*hard_soft;
{
  basic_shape_data	sh;
  short			size;
  int			one;
  int			*temp;
  static int		status;
  static int		bs_data_buffer_size;
  
  env_shp_no = env_shp_no + 1;
  sh.su.size[1] = 9;
  sh.su.size[2] = 1;				/*	solid 	*/
  sh.su.size[3] = *hard_soft;
  size = 24;
  memcpy( sh.ru.range , bs_range , size );
  sh.geom.bs_head.u_order = *u_order;
  sh.geom.bs_head.v_order = *v_order;
  sh.geom.bs_head.u_num_poles = *u_num_poles;
  sh.geom.bs_head.v_num_poles = *v_num_poles;
  sh.geom.bs_head.u_num_knots = *u_num_knots;
  sh.geom.bs_head.v_num_knots = *v_num_knots;
  sh.geom.bs_head.num_weights = *num_weights;
  sh.geom.bs_head.num_boundry_points = *num_boundry_points;
  sh.geom.bs_head.u_closed = *u_closed;
  sh.geom.bs_head.v_closed = *v_closed;
  sh.geom.bs_head.zerozero_solid = *zerozero_solid;
  sh.geom.bs_head.pole_bytes = 12 * (sh.geom.bs_head.u_num_poles * sh.geom.bs_head.v_num_poles);
  sh.geom.bs_head.uv_boundry_bytes = 8 * sh.geom.bs_head.num_boundry_points;
  if ( sh.geom.bs_head.num_weights > 0 )
    sh.geom.bs_head.weights_bytes = 4 * (sh.geom.bs_head.u_num_poles * sh.geom.bs_head.v_num_poles);
  else
    sh.geom.bs_head.weights_bytes = 0;
  sh.geom.bs_head.u_knot_bytes = 4 * sh.geom.bs_head.u_num_knots;
  sh.geom.bs_head.v_knot_bytes = 4 * sh.geom.bs_head.v_num_knots;
  sh.geom.bs_head.bs_data_bytes = sh.geom.bs_head.pole_bytes
				 +sh.geom.bs_head.uv_boundry_bytes
				 +sh.geom.bs_head.weights_bytes
				 +sh.geom.bs_head.u_knot_bytes
				 +sh.geom.bs_head.v_knot_bytes;
  one = 1;
  if ( first )
    {
    first = 0;
    sh.geom.bs_head.bs_data = ( int * ) calloc( one , sh.geom.bs_head.bs_data_bytes );
    bs_data_buffer_size = sh.geom.bs_head.bs_data_bytes;
    local_bs_data = ( int ) sh.geom.bs_head.bs_data;

    }
  else
    {
    if ( sh.geom.bs_head.bs_data_bytes > bs_data_buffer_size )
      {
      sh.geom.bs_head.bs_data = ( int * ) local_bs_data;
      sh.geom.bs_head.bs_data = ( int * ) realloc( sh.geom.bs_head.bs_data , sh.geom.bs_head.bs_data_bytes );
      bs_data_buffer_size = sh.geom.bs_head.bs_data_bytes;
      local_bs_data = ( int ) sh.geom.bs_head.bs_data;
      }
    else
      {
      sh.geom.bs_head.bs_data = ( int * ) local_bs_data;
      }
    }
  if ( sh.geom.bs_head.bs_data == 0 )
    return( -1 );
  else
    {
    temp = sh.geom.bs_head.bs_data;
    if ( sh.geom.bs_head.pole_bytes > 0 )
      {
      memcpy( sh.geom.bs_head.bs_data , poles , sh.geom.bs_head.pole_bytes );
      temp = temp + ((sh.geom.bs_head.u_num_poles*sh.geom.bs_head.v_num_poles)*3);
      }
    if ( sh.geom.bs_head.u_num_knots > 0 ) 
      {
      memcpy( temp , u_knots , sh.geom.bs_head.u_knot_bytes );
      temp = temp + sh.geom.bs_head.u_num_knots;
      }
    if ( sh.geom.bs_head.v_num_knots > 0 ) 
      {
      memcpy( temp , v_knots , sh.geom.bs_head.v_knot_bytes );
      temp = temp + sh.geom.bs_head.v_num_knots;
      }
    if ( sh.geom.bs_head.num_weights > 0 ) 
      {
      memcpy( temp , weights , sh.geom.bs_head.weights_bytes );
      temp = temp + sh.geom.bs_head.num_weights;
      }
    if ( sh.geom.bs_head.num_boundry_points > 0 )
      {
      memcpy( temp , uv_boundry , sh.geom.bs_head.uv_boundry_bytes );
      }
    status = SEF_WRITE_SHAPE_FILE( &env_dgn_no , &env_shp_no , &sh );
    status = SEF_WRITE_BS_DATA_F( &sh );
    return ( status );
    }
}
