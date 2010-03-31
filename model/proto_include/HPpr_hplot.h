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

/*---HPdload.c----------------------------------------------------------------------*/

void HPdload_errors __((char *msg, 
			 int sev));
			 
void HPdload __((char *filename));


/*---HPinit.c-----------------------------------------------------------------------*/

IGRint HPread_command_line __((IGRint argc, 
			      IGRchar *argv[]));

IGRint HPparse_double __((IGRchar *s, 
			   IGRint n, 
			IGRdouble *d));

int HPread_header __((void));
int HPread_device __((void));
int HPread_env_vars __((void));
int HPset_globals __((void));


/*---HPinterp.c---------------------------------------------------------------------*/

int HPplotfile_interpreter __((FILE *file_ptr, 
			    IGRchar command[2 ], 
			     IGRint level, 
			  IGRdouble range[6 ], 
			     IGRint data_num, 
			    IGRchar *data_ptr));


/*---HPmessage.c--------------------------------------------------------------------*/

void HPfind_message_file __((char *msg_path));

int HPinitialize_message_system __((char *pname, 
				    char *mfname));

IGRint HPmessage __((IGRint msgnumb, 
		    IGRchar *msgstring, 
		     IGRint flag));

void HPmessage_str __(( char*, int ));


/*---HPplot.c-----------------------------------------------------------------------*/

#if defined (CLIX)
IGRint HPplot_rasterfile __((IGRchar *rle_file, 
			       IGRint width, 
			       IGRint height));
			       
int HPsubmit_textfile __((char *queue));
#endif

void HPattach_rasterfile_to_textfile __((void));


/*---HPread_ctbl.c------------------------------------------------------------------*/

int HPread_color_table __((FILE *file_ptr, 
		       IGRshort **table_data, 
			    int *buffer_size, 
			    int *table_size));
			    

/*---HPread_curv.c------------------------------------------------------------------*/

void create_knot_vector __((IGRdouble *cv_knots, 
			       IGRint cv_order, 
			      IGRlong cv_num_poles));
			      
IGRint read_nurb_curve __((FILE *file_ptr, 
			 IGRint dimension, 
	    struct IGRbsp_curve *curve, 
			 IGRint *num_soos, 
	      struct HPsoo_info **soos));
	      

/*---HPread_soo.c--------------------------------------------------------------------*/

IGRint HPread_curve_soo __((FILE *file_ptr, 
			  IGRint *num_soos, 
	       struct HPsoo_info **soos));
	       

/*---HPread_surf.c-------------------------------------------------------------------*/

IGRint read_nurb_surface __((FILE *file_ptr, 
	    struct IGRbsp_surface *surface, 
	      struct IGRbsp_curve **bdry_curves, 
			   IGRint *curves_size, 
			   IGRint *surface_type));
			   

/*---HPreader.c----------------------------------------------------------------------*/

int HPplotfile_reader __((FILE *file_ptr, 
		       IGRchar command[2 ], 
		      IGRshort *level,
		     IGRdouble range[6 ], 
		        IGRint *data_num, 
		       IGRchar **data_ptr));
		       

/*---HPset.c-------------------------------------------------------------------------*/

IGRint set_color_table_rgb_values __((IGRint table_size, 
				    IGRshort *rgb_value));
				    
IGRint set_depth_cue_intensity __((IGRchar *depth_cues));

IGRint set_light_source __((struct HS_light_source *light,
					    IGRint type));
					    
IGRint set_old_light_source __((struct HS_old_light_source *light, 
						    IGRint type));
						    
IGRint set_old_old_light_source __((struct HS_old_old_light_source *light, 
							    IGRint type));
							    
IGRint set_plot_scale __((void));


/*---HPversion.c--------------------------------------------------------------------*/

int HPversion __((void));

#if defined(__cplusplus)
}
#endif


#undef __

