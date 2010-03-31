#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


/*---HPavail_mem.c--------------------------------------------------------*/

int HPinq_available_memory __((void));


/*---HPbanding.c----------------------------------------------------------*/

void HPinit_banding __((void));
void HPreset_banding __((void));

void HPremember_minmax __((struct HPbanding_info *p, 
					     int xmin, 
					     int xmax));

struct HPbanding_info *HPremember_object_surf __((FILE *file_ptr, 
						   int base_color, 
						   int translucent, 
						   int translucency_grid, 
						   int rendering_mode, 
						double tiling_tolerance, 
						   int width, 
						   int style, 
						   int count,
                                                   int objid,
                                                 short osnum));
						   
struct HPbanding_info *HPremember_object_curv __((FILE *file_ptr, 
						   int base_color, 
						   int translucent, 
						   int translucency_grid, 
						   int rendering_mode, 
						double tiling_tolerance, 
						   int width, 
						   int style, 
						   int count,
                                                   int objid,
                                                 short osnum));
						   
int HPget_next_object_surf __((FILE *file_ptr, 
				int *base_color, 
				int *translucent, 
				int *translucency_grid, 
				int *rendering_mode, 
			     double *tiling_tolerance, 
				int *width, 
				int *style, 
				int *xmin, 
				int *xmax, 
				int *count,
                                int *objid,
                              short *osnum));
				
int HPget_next_object_curv __((FILE *file_ptr, 
				int *base_color, 
				int *translucent, 
				int *translucency_grid, 
				int *rendering_mode, 
			     double *tiling_tolerance, 
				int *width, 
				int *style, 
				int *xmin, 
				int *xmax, 
				int *count, 
                                int *objid,
                              short *osnum,
	      struct HPbanding_info **object));


/*---HPcvrt_bdrys.c--------------------------------------------------------*/

IGRint HPconvert_surface_boundaries __((struct IGRbsp_surface *surf, 
					  struct IGRbsp_curve *bdrys, 
							  int num_bdrys, 
						       double tiling_tolerance));
						       
int HPstroke_nurb_curve __((struct IGRbsp_curve *curve, 
					 double tiling_tolerance, 
					IGRlong *num_points, 
				      IGRdouble **points));
					 

/*---HPfini_band.c---------------------------------------------------------*/

int HPfini_band __((void));


/*---HPfini_zbuf.c---------------------------------------------------------*/

int HPfini_zbuffering __((FILE *file_ptr, 
			   int *rle_width, 
			   int *rle_length));


/*---HPinit_band.c---------------------------------------------------------*/

void HPdummy_stub __((void));
int HPinit_band __((void));


/*---HPinit_hsurf.c--------------------------------------------------------*/

int HPenter_HSURF __((void));
int HPexit_HSURF __((void));


/*---HPinit_zbuf.c---------------------------------------------------------*/

int HPinit_zbuffering __((IGRdouble device_scale, 
			     double world_to_view_scale));
			     

/*---HPinitpant.c----------------------------------------------------------*/

void HPinit_paint __((IGRint *color, 
		      IGRint *request_code));
		      

/*---HPr_af_op.c-----------------------------------------------------------*/

void HParea_fill_opaque __((struct trapezoid *tile));


/*---HPr_af_tn.c-----------------------------------------------------------*/

void HParea_fill_trans __((struct trapezoid *tile));


/*---HPr_co_op.c-----------------------------------------------------------*/

void HPconstant_shade_opaque __((struct trapezoid *tile));


/*---HPr_co_tn.c-----------------------------------------------------------*/

void HPconstant_shade_trans __((struct trapezoid *tile));


/*---HPr_dzine.c-----------------------------------------------------------*/

void HPstart_dzine5 __((struct polyline_vertex *start_point));
void HPstart_dzine6 __((struct polyline_vertex *start_point));
void HPcontinue_dzine5 __((struct polyline_vertex *next_vertex));
void HPcontinue_dzine6 __((struct polyline_vertex *next_vertex));


/*---HPr_pl_ln.c-----------------------------------------------------------*/

void HPstart_polyline __((struct polyline_vertex *start_point));
void HPcontinue_polyline __((struct polyline_vertex *next_vertex));


/*---HPr_pt.c--------------------------------------------------------------*/

void HPdraw_point __((struct polyline_vertex *point));


/*---HPr_radge.c---------------------------------------------------------- */

void HPstart_pline_radge5 __((struct polyline_vertex *start_point));
void HPstart_pline_radge6 __((struct polyline_vertex *start_point));
void HPcontinue_pline_radge5 __((struct polyline_vertex *next_vertex));
void HPcontinue_pline_radge6 __((struct polyline_vertex *next_vertex));
void HPtrap_radge5 __((struct trapezoid *tile));
void HPtrap_radge6 __((struct trapezoid *tile));


/*---HPr_rhl.c-------------------------------------------------------------*/

void HPraster_lines_init __((void));
void HPraster_lines __((struct trapezoid *tile));

void HPsilly_lines __((int line_color, 
		      int bg_color));


/*---HPr_rl.c--------------------------------------------------------------*/

void HPraster_edges __((struct trapezoid *tile));


/*---HPr_sm_op.c-----------------------------------------------------------*/

void HPsmooth_shade_opaque __((struct trapezoid *tile));


/*---HPr_sm_tn.c-----------------------------------------------------------*/

void HPsmooth_shade_trans __((struct trapezoid *tile));


/*---HPr_swine.c-----------------------------------------------------------*/

void HPstart_swine5 __((struct polyline_vertex *start_point));
void HPstart_swine6 __((struct polyline_vertex *start_point));
void HPcontinue_swine5 __((struct polyline_vertex *next_vertex));
void HPcontinue_swine6 __((struct polyline_vertex *next_vertex));


/*---HPreport.c------------------------------------------------------------*/

FILE *HPopen_report_file __((void));
void HPflush_report_file __((FILE **outfile));
void HPclose_report_file __((FILE *outfile));
int HPdisplay_job_information __((FILE *outfile));
int HPdump_window_info __((void));


/*---HPset_style.c---------------------------------------------------------*/

int HPset_line_style __((int line_style_index));


/*---HPtiming.c------------------------------------------------------------*/

int HPtiming_report __((FILE *outfile));


/*---HPtype25.c------------------------------------------------------------*/

void HPcreate_hdr __((FILE   *file_des, 
		      IGRint rle_type));

void HPcreate_PS_header( FILE *fp );
void HPwrite_PS_tail( FILE *fp );
		     

/*---HPuniq_name.c---------------------------------------------------------*/

void HPgenerate_unique_name __((char *unique_name));
				

/*---HPutil.c--------------------------------------------------------------*/

double HPget_scale __((void));
void HPtranspose_matrix __((double a[4 ][4 ]));

void HPmake_scaling_matrix __((double m[4 ][4 ], 
			       double scale_factor));
			      
void HPmatrix_multiply __((double a[4 ][4 ], 
			   double b[4 ][4 ], 
			   double c[4 ][4 ]));
			  
void HPcopy_matrix __((double a[4 ][4 ], 
		       double b[4 ][4 ]));
		      
void HPdump_matrix __((char s[], 
		     double m[4 ][4 ]));
		    
void HPscale_matrix __((double m[4 ][4 ], 
		        double s));
		       
void HPfree_band_memory __((void));

void DPinq_style __((unsigned int index, 
		   unsigned short *pattern));

int HPin_ignore_list( int, short );


/*---HPzbuf_curve.c--------------------------------------------------------*/

int HPzbuffered_curve __((FILE *file_ptr, 
			   int curve_count,
                           int object_type));


/*---HPzbuf_surf.c---------------------------------------------------------*/

int HPzbuffered_surface __((FILE *file_ptr, 
			  double *ele_range, 
			     int surface_count));


#if defined(__cplusplus)
}
#endif


#undef __


