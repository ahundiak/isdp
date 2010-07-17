typedef struct  {
		union
		{
		  double	size_d;
		  short		size[4];
		}su;
		int    uor_per_su;
		int    su_per_mu;
		int    gbl_x_uor;
		int    gbl_y_uor;
		int    gbl_z_uor;
		int    range[2][3]; 
		int    diag1_i[9][3];
		int    diag2_i[9][3];
		int    section_set[8];		/* [7] = total number of components written to envelope file , set by SEF_CLOSE */
		int    copy_set[8];		
		short  model_no;
		short  sys_of_units;
		short  whole;	/* whole model if set */
		short  nch1;
		short  nch2;
		short  level[4];
		short  dgn_filespec[7];
		short  db_filespec[7];
		short  dgnchrs;
		short  elchrs;
		short  dummy[10];	/* reserved */
		char   view_name[6];
		char   munit[2];
		char   sunit[2];
		char   diag1_c[40];
		char   diag2_c[40];
		char   dgn_file[64];
		char   db_file[64];
		char   el_list_file[64];
	     } design_data;


typedef struct  {
		double		tm[3][3];

		union
		{
		double		cmp_cp_d[2];
		int		cmp_cp[4];
		short		npd[8];			/* npd[6] = npd for this cp */
		}pu;
		
		}cp_record;

typedef struct Component_Data
              {
		union				/* storage for short data , where:				*/
		{				/* size[0]=size		size[5]=cp_type	, where: 0 = not used	*/
		  double	size_d[2];	/* size[1]=sector				 1 = pip	*/
		  short		size[8];	/* size[2]=byte					 2 = comp	*/
		}su;				/* size[3]=ent_no				 3 = other_cmp  */
						/* size[4]=model_item                            4 = lrs	*/
						/* size[6]=no_cp						*/
						/* size[7]=no_mpcs for Modeldraft     					*/



                union					/* storage for component numbers , where:			*/
		{					/*cmp_no[0]=cmp_no						*/
		  double	cmp_no_d;		/*cmp_no[1]=occ_no						*/
		  int		cmp_no[2];
		}nu;
		
		union
		{
		  double	range_d[3];
		  int		range[2][3];		/* component range 						*/
		}ru;
		
		union					/* storage for char data , where:				*/
  		{					/*chr[0:5]=index_to_pgcl					*/
		  double	chr_d[12];		/*chr[6]=which_attr						*/
		  char		chr[96];		/*chr[7:26]=primary_attr					*/
		}cu;					/*chr[27:32]=alternate_attr					*/
							/*chr[33]=hard_soft						*/
							/*chr[34]=emulate_flag						*/
							/*chr[35:74]=descript						*/
							/*chr[75:94]=label						*/
							/*chr[95]=reserved						*/
		union
		{
		  double	r_d[3];
		  short		reserved[12];/* [11]= con tol exclusion flag */
		}rs;

		union  connect_point_data {

			struct  pipe {
				double  pi_tm1[3][3];
				int	pi_pnt1[3];
				int	pi_pnt2[3];
				short	npd;			/* pipe npd */
			}  pip;

			struct piping_comp {
				cp_record	cp_rec[7];
			}  comp;
			
			struct other_comp {
				int	cp[50][3];
			}  other_cmp;

			struct mpc_comp {
				int	cp[50][3];
				int	lcp[64][2];
			}  mpc_cmp;

			struct line_route {
				int	lrs_end1[3];
				int	lrs_end2[3];
				char	pipe_tube_indicator;
			}  lrs;
		} cp_data;


	     }component_data;




typedef struct  {
		double	cy_pri[3];
		double  cy_sec[3];
		int 	cy_p[3];
		int	cy_len;
		int	cy_rad;
		} cyl;

typedef struct {
		double	co_pri[3];
		double  co_sec[3];
		int 	co_p[3];	/* end pt 1 */
		int 	co_p2[3];	/* end pt 2 */
		int	co_len;
		int	co_rad_1;	/* radius 1 */
		int	co_rad_2;	/* radius 2 */
		char	co_type;	/* 0 - right, 1 - skew */
		} cone;

typedef struct  {
		double  to_pri[3];
		double  to_sec[3];
   		double  to_sweep_angle;
		int	to_p1[3];
		int	to_p[3];
 		int	to_rad;
 		int	to_ellipse_rad;
                } torus;

typedef struct {
		double	ps_pri[3];
		double  ps_sec[3];
		union
		{
		  double	ps_no_point_d;
		  short		ps_no_point;		/* [0] = number of vertices */
		}pu;
		int	ps_len;
                int	ps_p[99][3];
		} proj_shp;

typedef struct {
		double  el_pri[3];	/* unit primary vector */
		double  el_sec[3];	/* unit secondary vector */
		int	el_p[3];	/* origin of semi-ellipsoid */
		int	el_rad_pri;	/* radius in primary direction */
		int	el_rad_sec;	/* radius in secondary direction */
	       } semi_ell;

typedef struct {
		double	rs_pri[3];      /* normal prim. vect */
		double  rs_sec[3];      /* normal sec. vect  */
                double  rs_sweep_angle; /* sweep angle of rev*/
		union
		{
		  double		rs_no_point_d;
		  short			rs_no_point;		/*  number of vertices */
		}pu;
		int	rs_ref_1[3];    /* pnt 1 of rot axis */
		int	rs_ref_2[3];    /* pnt 2 of rot axis */
                int	rs_p[99][3];    /* vertices of face 1*/
		} rev_shp;

typedef	struct {
		union
		{
		  double	cs_no_point_d;
		  short		cs_no_point;	
		}pu;
		int	cs_rad;
		int	cs_p[99][3];
		} cyl_string;

typedef struct { 
		int	u_order;
		int	v_order;
		int	u_num_poles;
		int 	v_num_poles;
		int	u_num_knots;
		int	v_num_knots;
		int	num_weights;
		int	num_boundry_points;
		int	u_closed;
		int	v_closed;
		int	zerozero_solid;
		int	bs_data_bytes;
		int	pole_bytes;
		int	u_knot_bytes;
		int	v_knot_bytes;
		int	weights_bytes;
		int	uv_boundry_bytes;
		int	*bs_data;
		} bs_header;
		


typedef struct {
		double  d[159];
	       } shape_align;


typedef struct  {
		union				/* size[0] = byte size */
		{				/* size[1] = type      */
		  double	size_d;		/* size[2] = status, 1=solid , 2=hole	*/
		  short		size[4];	/* size[3] = hard_soft		*/
		}su;

		union
		{
		  double	range_d[3];
		  int		range[2][3];	/* shape range 		*/
		}ru;

		union shape_geometry {
		       cyl cylinder;
  		       cone conic;
		       torus toroid;
		       proj_shp projected_shape;
		       semi_ell semi_ellipsoid;
		       rev_shp revolved_shape;
		       cyl_string cylindrical_string;
		       bs_header bs_head;
		       shape_align sh_align;
		} geom;		

	     } basic_shape_data;


typedef struct
{
  union
  {
    double	key_d;
    short	key[4];
  }ku;
  struct	system_data		sys_dat; 
}key_sys;


typedef struct Key_Cmp
{
  struct	Key_Cmp		*next_key_cmp;
  struct	Key_Shp		*first_key_shp;
  struct	Key_Shp		*active_key_shp;
  struct	Key_Shp		*first_hole;
  struct	Key_Shp		*active_hole;
  struct	Key_Shp		*first_exp_shp;
  struct	Key_Shp		*active_exp_shp;
  struct	Key_Shp		*first_exp_hole;
  struct	Key_Shp		*active_exp_hole;
  struct	Key_Shp		*first_soft_shp;
  struct	Key_Shp		*active_soft_shp;
  struct	Key_Shp		*active_unused;
  union
  {
    double	range_d[3];
    int		nonxrange[6];	    /* nonexpanded component range */
  }ru;
  union
  {
    double	key_d;
    short	key[4];
  }ku;
  component_data	cmp_dat; 
}key_cmp;


typedef struct Key_Dgn
{
  union
  {
    double	key_d;
    short	key[4];
  }ku;
  design_data	dgn_dat; 

  struct	Key_Cmp		*first_comp;
  struct	Key_Cmp		*active_comp;
 
}key_dgn;



typedef struct Key_Shp
{
  struct	Key_Shp		*next_key_shp;
  struct	Key_Shp		*first_prim;
  struct	Key_Shp		*active_prim;
  union
  {
    double	range_d[3];
    int		xrange[6];	    /* expanded shape range */
  }ru;
  union
  {
    double	key_d;
    short	key[4];
  }ku;
  basic_shape_data	shp_dat; 


}key_shp;

