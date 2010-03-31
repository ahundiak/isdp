#define PROTO_HSdlist_setup_feedback_gragad \
   extern int HSdlist_setup_feedback_gragad( \
      void );

#define PROTO_HSdlist_msc_created \
   extern int HSdlist_msc_created( \
      OM_S_OBJID msc_objid, \
      OMuword osnum );

#define PROTO_HSdlist_save_tri_mesh \
   extern int HSdlist_save_tri_mesh( \
      int vc_no, \
      struct HStri_mesh *mesh );

#define PROTO_HSdlist_display_element \
   extern int HSdlist_display_element( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      IGRmatrix matrix, \
      IGRshort matrix_type, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      OM_p_KEY_DESC key, \
      IGRint single_display );

#define PROTO_HSdlist_display_element_update \
   extern int HSdlist_display_element_update( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      IGRmatrix matrix, \
      IGRshort matrix_type, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      OM_p_KEY_DESC key, \
      IGRint single_display );

#define PROTO_HSdlist_display_point \
   extern int HSdlist_display_point( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_point_update \
   extern int HSdlist_display_point_update( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_polygon \
   extern int HSdlist_display_polygon( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_polygon_update \
   extern int HSdlist_display_polygon_update( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_curve \
   extern int HSdlist_display_curve( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_curve_update \
   extern int HSdlist_display_curve_update( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_text \
   extern int HSdlist_display_text( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_text_update \
   extern int HSdlist_display_text_update( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_surface \
   extern int HSdlist_display_surface( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_surface_update \
   extern int HSdlist_display_surface_update( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_unknown \
   extern int HSdlist_display_unknown( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_display_unknown \
   extern int HSdlist_display_unknown( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_HSdlist_enter_reference_file \
   extern int HSdlist_enter_reference_file( \
      struct DP_information *dp_info, \
      IGRshort matrix_type, \
      IGRmatrix matrix );

#define PROTO_HSdlist_exit_reference_file \
   extern int HSdlist_exit_reference_file( \
      struct DP_information *dp_info, \
      IGRshort matrix_type, \
      IGRmatrix matrix );

#define PROTO_HSdlist_push_matrix \
   extern int HSdlist_push_matrix( \
      IGRshort matrix_type, \
      IGRmatrix matrix );

#define PROTO_HSdlist_pop_matrix \
   extern int HSdlist_pop_matrix( \
      void );

#define PROTO_HSdlist_shading_parameter_notify \
   extern int HSdlist_shading_parameter_notify( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned char diff_refl, \
      unsigned char spec_refl, \
      unsigned char finish, \
      unsigned char trans );

#define PROTO_HSdlist_is_msc \
   extern void HSdlist_is_msc( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      int *flag );

#define PROTO_HSdlist_get_msc_flags \
   extern int HSdlist_get_msc_flags( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned int *flags );

#define PROTO_HSdlist_start_window_update \
   extern int HSdlist_start_window_update( \
      WLuint32 lwin_no, \
      int pipe_id );

#define PROTO_HSdlist_finish_window_update \
   extern int HSdlist_finish_window_update( \
      WLuint32 lwin_no, \
      int pipe_id );

#define HSDLIST_FLOAT_TOL       1e-05

#define HSDLIST_COMPARE_ATTRIBUTES(setting_required,old,new)          \
{                                                                     \
 if(                                                                  \
   (fabs(old.red-new.red) 		> HSDLIST_FLOAT_TOL) ||       \
   (fabs(old.green-new.green) 		> HSDLIST_FLOAT_TOL) ||       \
   (fabs(old.blue-new.blue) 		> HSDLIST_FLOAT_TOL) ||       \
   (fabs(old.diff_refl-new.diff_refl)   > HSDLIST_FLOAT_TOL) ||       \
   (fabs(old.spec_refl-new.spec_refl)   > HSDLIST_FLOAT_TOL) ||       \
   (fabs(old.finish-new.finish)         > HSDLIST_FLOAT_TOL) ||       \
   (fabs(old.trans-new.trans)           > HSDLIST_FLOAT_TOL) ||       \
   (old.illumination != new.illumination))                            \
        setting_required = TRUE;                                      \
 else                                                                 \
        setting_required = FALSE;                                     \
}

#define ONE_OVER_65535 (float)(1.0 / 65535.0)

#define SETUP_FOR_SINGLE_DISPLAY \
   DLget_modelling_matrix( dp_info->gragad->gpipe_id, old_mod_matrix ); \
   MAtrnmx( &static_msg, &static_four, matrix, new_mod_matrix ); \
   DLset_modelling_matrix( dp_info->gragad->gpipe_id, new_mod_matrix ); \

#define RESTORE_FROM_SINGLE_DISPLAY \
   DLset_modelling_matrix( dp_info->gragad->gpipe_id, old_mod_matrix ); \

#define GET_LOG_COLOR( alt_symb, ele_color, log_color ) \
                                                        \
   if ( (alt_symb) )                                    \
   {                                                    \
      if ( (alt_symb)->color )                          \
      {                                                 \
         (log_color) = *(alt_symb)->color;              \
      }                                                 \
      else                                              \
      {                                                 \
         (log_color) = (ele_color);                     \
      }                                                 \
   }                                                    \
   else                                                 \
   {                                                    \
      (log_color) = (ele_color);                        \
   }                                                    \


#define GET_COLOR_UPDATE( lcolor )                           \
   {                                                         \
   WLuint32 temp_red, temp_green, temp_blue;                 \
   (*color_to_rgb)( context_no, lcolor, 0, 0, 0,             \
                    0, &temp_red, &temp_green, &temp_blue ); \
                                                             \
   red = temp_red * ONE_OVER_65535;                          \
   green = temp_green * ONE_OVER_65535;                      \
   blue = temp_blue * ONE_OVER_65535;                        \
   }


#if defined(XGL)
#define	PROTO_HSdlist_xgl_set_display_attributes	\
extern void	HSdlist_xgl_set_display_attributes(	\
		float	red, 	/* i */			\
		float	green,	/* i */			\
		float	blue,	/* i */			\
	     	struct DPdlist_fixed_data 	*fixed	/* i */	\
	);

#define	PROTO_HSdlist_xgl_display_surface	\
extern int HSdlist_xgl_display_surface (	\
	     struct DPdlist_fixed_data 	*fixed	\
	);

/* Workaround for some compilation problem. */
#define XGL_PT_F3D   		(0x3|0x4|0x0|0x0|0x0|0x0|0x0|0x0)
#define XGL_PT_FLAG_F3D   	(0x3|0x4|0x0|0x0|0x80|0x0|0x0|0x0)
#define XGL_PT_NORMAL_F3D    	(0x3|0x4|0x10|0x0|0x0|0x0|0x0|0x0)
#define XGL_PT_NORMAL_FLAG_F3D  (0x3|0x4|0x10|0x0|0x80|0x0|0x0|0x0)
#define XGL_FACET_NORMAL  	(0x0|0x2|0x0)
#define XGL_TLIST_FLAG_TRI_STRIP		0x01
#define XGL_TLIST_FLAG_TRI_RESTART		0x00
#define XGL_FACE_IS_CCW		0x10	/* face orientation */
#define XGL_TLIST_FLAG_USE_VTX_FLAGS		0x03


#define	HS_64_KB			  (64*1024)
#define	HS_PAGE_SIZE			  HS_64_KB

/*	I am not using this macro any where..... sash	*/
#define   HSDLIST_DO_SHADING(total_num_verts,pt_type,facet_list)	\
	   do								\
	   {								\
	      /* Break the strip array, where it restarts. */		\
	      if(total_num_verts > HS_XGL_MAX_LIMIT)			\
	      {								\
		    unsigned long	brk_num_pts=0;			\
	            if(facet_list)					\
	            {							\
			/* I can't move the facet_list pointer. */	\
      			return( DLIST_E_ERROR );			\
	      	    }							\
		    HS_XGL_FIND_BRK_NUM_PTS_IN_ARRAY(pt_list[0],	\
						     pt_type,		\
					             HS_XGL_MAX_LIMIT,	\
						     brk_num_pts);	\
		    pt_list[0].num_pts = brk_num_pts;			\
	      }								\
	      else							\
	      {								\
		    pt_list[0].num_pts = total_num_verts;		\
	      }								\
	      xgl_triangle_list(active_window->xgl_context_3D, 		\
				facet_list,				\
				pt_list,				\
				XGL_TLIST_FLAG_USE_VTX_FLAGS);		\
	      total_num_verts -= pt_list[0].num_pts;			\
	      if(total_num_verts)					\
      	           pt_list[0].pts.pt_type += pt_list[0].num_pts;	\
	      else							\
		   break;						\
	   }while(total_num_verts);


#define	HSDLIST_FREE_SH_MESH_DATA(fixed)				\
{									\
      int			sts;					\
      unsigned int		*p_byte_size,ii;			\
      struct DPdlist_sh_surface_variable sh_surface;			\
      DLIST_SH_SRF_ALL_PTRS( fixed->sh_data, sh_surface );		\
      for ( ii = 0; ii < *sh_surface.num_meshes; ii++ )			\
      {									\
         DLIST_MSH_BYTE_SIZE_PTR( sh_surface.meshes[ii], p_byte_size );	\
         if(sh_surface.meshes[ii])					\
         {								\
            sts=DPdlist_free_chunk(*p_byte_size,sh_surface.meshes[ii]); \
            if ( !(1 & sts) )						\
            {								\
               return( sts );						\
            }								\
         }								\
      }									\
      *sh_surface.num_meshes = 0;					\
}

/*
	Following attributes need not be set.

    XGL_3D_CTX_SURF_BACK_ILLUMINATION,    xgl_surf_illumination,	\
    XGL_3D_CTX_SURF_BACK_COLOR, 	  &xgl_color,			\
    XGL_3D_CTX_SURF_BACK_COLOR_SELECTOR,  XGL_SURF_COLOR_CONTEXT,	\
    XGL_3D_CTX_SURF_BACK_DIFFUSE, 	  diff_refl,			\
    XGL_3D_CTX_SURF_BACK_SPECULAR, 	  spec_refl,			\
    XGL_3D_CTX_SURF_BACK_SPECULAR_COLOR,  &xgl_color,			\
    XGL_3D_CTX_SURF_BACK_SPECULAR_POWER,  (float)(finish > 32.0)?32.0:finish
    XGL_3D_CTX_SURF_FACE_CULL, 		  XGL_CULL_OFF,			\
*/

#define	HS_XGL_SURFACE_ATTRIBUTES					\
    XGL_CTX_SURF_FRONT_COLOR_SELECTOR, 	  XGL_SURF_COLOR_CONTEXT,	\
    XGL_CTX_SURF_FRONT_COLOR, 		  &xgl_color,			\
    XGL_3D_CTX_SURF_FRONT_ILLUMINATION,   xgl_surf_illumination,	\
    XGL_3D_CTX_SURF_FRONT_LIGHT_COMPONENT,				\
				    XGL_LIGHT_ENABLE_COMP_AMBIENT |	\
				    XGL_LIGHT_ENABLE_COMP_DIFFUSE |	\
				    XGL_LIGHT_ENABLE_COMP_SPECULAR,	\
    XGL_3D_CTX_SURF_FRONT_DIFFUSE, 	  diff_refl,			\
    XGL_3D_CTX_SURF_FRONT_SPECULAR, 	  spec_refl,			\
    XGL_3D_CTX_SURF_FRONT_SPECULAR_COLOR, &xgl_color,			\
    XGL_3D_CTX_SURF_FRONT_SPECULAR_POWER, (float)(finish > 32.0)?32.0:finish

#define  HS_XGL_ATTRIBUTES_BY_STYLE                                     \
    XGL_CTX_SURF_FRONT_COLOR_SELECTOR,  XGL_SURF_COLOR_CONTEXT, 	\
    XGL_3D_CTX_SURF_FRONT_ILLUMINATION, xgl_surf_illumination,        	\
    XGL_3D_CTX_SURF_FRONT_LIGHT_COMPONENT,                            	\
                            XGL_LIGHT_ENABLE_COMP_AMBIENT |     	\
                                   XGL_LIGHT_ENABLE_COMP_DIFFUSE |     	\
                                   XGL_LIGHT_ENABLE_COMP_SPECULAR


#define HS_XGL_COLOR_ATTRIBUTES                                        \
     XGL_CTX_SURF_FRONT_COLOR,             &xgl_color,                 \
     XGL_3D_CTX_SURF_FRONT_SPECULAR_COLOR, &xgl_color

#define       HS_XGL_ATTRIBUTES_BY_VALUE                               \
     XGL_3D_CTX_SURF_FRONT_DIFFUSE,      diff_refl,                    \
     XGL_3D_CTX_SURF_FRONT_SPECULAR,     spec_refl,                    \
     XGL_3D_CTX_SURF_FRONT_SPECULAR_POWER, (float)(finish > 32.0)?32.0:finish
 

/****************************************************************************
	Input: single array packed with disconnected strips,
		and max. no. of pts (MAX_LIMIT) XGL function can
		handle.

	Output: No. of points (index to the given array) witch represent
		'n' disconnected strips witch does not exceed the MAX_LIMIT
		of the XGL function.
*****************************************************************************/
#define HS_XGL_FIND_BRK_NUM_PTS_IN_ARRAY(PT_LIST, PT_FIELD, MAX_LIMIT, NUM_PTS)	\
{									\
    NUM_PTS=0;								\
    if(PT_LIST.pts.PT_FIELD[MAX_LIMIT].flag == XGL_TRIANGLE_RESTART) 	\
    {									\
	NUM_PTS=MAX_LIMIT-1;						\
    }									\
    else								\
    { 									\
    	unsigned long	kk=MAX_LIMIT-1;					\
    	while(kk>0)							\
    	{								\
           if(PT_LIST.pts.PT_FIELD[kk].flag == XGL_TRIANGLE_RESTART)	\
	   {								\
		NUM_PTS=kk-1;						\
		break;							\
	   }								\
	   kk--;							\
	}								\
    }									\
    if(NUM_PTS == 0)							\
    {									\
       	printf("strip length exceeded %d\n",MAX_LIMIT);			\
       	return( DLIST_E_ERROR );					\
    }									\
}

#define	HS_XGL_SET_PT_LIST_F3D(PL, NUM_PTS, PTS_F3D)	\
	PL.pt_type = XGL_PT_F3D;			\
	PL.bbox    = NULL;				\
	PL.num_pts = (Xgl_usgn32)NUM_PTS;		\
	PL.pts.f3d = (Xgl_pt_f3d *)PTS_F3D; 		\
	PL.num_data_values = 0;	

#define	HS_XGL_SET_PT_LIST_NORMAL_F3D(PL, NUM_PTS, PTS_NORMAL_F3D) \
	PL.pt_type = XGL_PT_NORMAL_F3D;				\
	PL.bbox    = NULL;					\
	PL.num_pts = (Xgl_usgn32)NUM_PTS;			\
	PL.pts.normal_flag_f3d = (Xgl_pt_normal_flag_f3d *)PTS_NORMAL_F3D; \
	PL.num_data_values = 0;	

#define	HS_XGL_SET_PT_LIST_NORMAL_FLAG_F3D(PL, NUM_PTS, PTS_NORMAL_FLAG_F3D) \
	PL.pt_type = XGL_PT_NORMAL_FLAG_F3D;			\
	PL.bbox    = NULL;					\
	PL.num_pts = (Xgl_usgn32)NUM_PTS;			\
	PL.pts.normal_flag_f3d = (Xgl_pt_normal_flag_f3d *)PTS_NORMAL_FLAG_F3D; \
	PL.num_data_values = 0;	

#define	HS_XGL_SET_PT_LIST_FLAG_F3D(PL, NUM_PTS, PTS_FLAG_F3D) 	\
	PL.pt_type = XGL_PT_FLAG_F3D;				\
	PL.bbox    = NULL;					\
	PL.num_pts = (Xgl_usgn32)NUM_PTS;			\
	PL.pts.flag_f3d = (Xgl_pt_flag_f3d *)PTS_FLAG_F3D; 	\
	PL.num_data_values = 0;

#define HS_XGL_SET_RGB_COLOR(CLR, R, G, B)				\
            CLR.rgb.r = R;					\
            CLR.rgb.g = G;					\
            CLR.rgb.b = B;

#define HS_XGL_SET_PT_NORMAL_F3D(NUM_PTS, PTS, NORMS, PT_NORM_F3D_ARR) \
{								\
  Xgl_usgn32	kk;						\
  for(kk=0;kk<NUM_PTS;kk++){					\
	PT_NORM_F3D_ARR[kk].x = PTS[(3*kk)];			\
	PT_NORM_F3D_ARR[kk].y = PTS[(3*kk)+1];			\
	PT_NORM_F3D_ARR[kk].z = PTS[(3*kk)+2];			\
	PT_NORM_F3D_ARR[kk].normal.x = NORMS[3*kk];		\
	PT_NORM_F3D_ARR[kk].normal.y = NORMS[(3*kk)+1];		\
	PT_NORM_F3D_ARR[kk].normal.z = NORMS[(3*kk)+2];		\
  }								\
}

#define HS_XGL_SET_PT_NORMAL_FLAG_F3D(NUM_PTS, PTS, NORMS, PT_NORM_FLAG_F3D_ARR, BOOL_MOVE_PTR) \
{									\
  Xgl_usgn32	kk;							\
  for(kk=0;kk<NUM_PTS;kk++){						\
	PT_NORM_FLAG_F3D_ARR[kk].x = PTS[(3*kk)];			\
	PT_NORM_FLAG_F3D_ARR[kk].y = PTS[(3*kk)+1];			\
	PT_NORM_FLAG_F3D_ARR[kk].z = PTS[(3*kk)+2];			\
	PT_NORM_FLAG_F3D_ARR[kk].normal.x = NORMS[3*kk];		\
	PT_NORM_FLAG_F3D_ARR[kk].normal.y = NORMS[(3*kk)+1];		\
	PT_NORM_FLAG_F3D_ARR[kk].normal.z = NORMS[(3*kk)+2];		\
	PT_NORM_FLAG_F3D_ARR[kk].flag = XGL_TRIANGLE_STRIP;     	\
  }									\
  PT_NORM_FLAG_F3D_ARR[0].flag = XGL_TRIANGLE_RESTART;   		\
									\
  if(BOOL_MOVE_PTR) 							\
       PT_NORM_FLAG_F3D_ARR +=	NUM_PTS;				\
}

#define HS_XGL_SET_PT_FLAG_F3D(PT_FLAG_F3D_ARR, NUM_PTS, PTS, BOOL_MOVE_PTR) \
{									\
  Xgl_usgn32	kk;							\
  for(kk=0;kk<NUM_PTS;kk++){						\
	PT_FLAG_F3D_ARR[kk].x = PTS[(3*kk)];				\
	PT_FLAG_F3D_ARR[kk].y = PTS[(3*kk)+1];				\
	PT_FLAG_F3D_ARR[kk].z = PTS[(3*kk)+2];				\
	PT_FLAG_F3D_ARR[kk].flag = XGL_TRIANGLE_STRIP;     		\
  }									\
  PT_FLAG_F3D_ARR[0].flag = XGL_TRIANGLE_RESTART; 			\
									\
  if(BOOL_MOVE_PTR) 							\
       PT_FLAG_F3D_ARR +=	NUM_PTS;				\
}

#define	HS_XGL_SET_FACET_LIST(FACET,NUM_FACETS, FACET_NORMALS) 		\
	FACET.facet_type   	    = XGL_FACET_NORMAL;			\
	FACET.num_facets	    = (Xgl_usgn32)NUM_FACETS;		\
	FACET.facets.normal_facets  = (Xgl_normal_facet *)FACET_NORMALS;


#define HStl_allocate_memory(address_space,bytes_allocated, bytes_required){ \
    if(bytes_allocated == 0)					\
    {								\
	if(bytes_required < HS_PAGE_SIZE)			\
		bytes_allocated = HS_PAGE_SIZE;			\
	else if ((bytes_required % HS_PAGE_SIZE)==0)		\
		bytes_allocated  = bytes_required;		\
	else							\
		bytes_allocated = ((bytes_required/HS_PAGE_SIZE)+1)	\
						*HS_PAGE_SIZE;	\
	/* error check. */					\
	if(!bytes_allocated)					\
		bytes_allocated = HS_PAGE_SIZE;			\
	address_space = (char *)malloc(bytes_allocated*		\
						sizeof(char));  \
    }								\
    else if(bytes_required > bytes_allocated )			\
    {								\
        if(!address_space) return;				\
								\
	bytes_allocated = ((bytes_required/HS_PAGE_SIZE)+1)	\
						*HS_PAGE_SIZE;	\
								\
    	address_space = (char *)realloc(address_space,		\
  				   bytes_allocated);		\
    }								\
    if(!address_space)						\
    {								\
       return;							\
    }								\
}

 

#define HS_allocate_memory(bytes_required){                     \
    if(bytes_required > HS_num_bytes_allocated )                \
    {                                                           \
        if(!HS_address_space) return( DLIST_E_ERROR );          \
                                                                \
        HS_num_bytes_allocated += HS_PAGE_SIZE;                 \
        while(HS_num_bytes_allocated < bytes_required)          \
        {                                                       \
                /* One more 60k chunk. */                       \
                HS_num_bytes_allocated += HS_PAGE_SIZE;         \
        }                                                       \
                                                                \
        HS_address_space = (char *)realloc(HS_address_space,    \
                                   HS_num_bytes_allocated);     \
    }                                                           \
    if(!HS_address_space)                                       \
    {                                                           \
       return( DLIST_E_ERROR );                                 \
    }                                                           \
}

#endif

#if defined( OPENGL )
#define SEND_VERTS_TO_OPENGL( numverts, verts ) \
                                                \
   switch( (numverts) % 4 )                     \
   {                                            \
      case 1:                                   \
         glVertex3fv( (verts) );                \
         (verts) += 3;                          \
         (numverts) -= 1;                       \
         break;                                 \
      case 2:                                   \
         glVertex3fv( (verts) );                \
         glVertex3fv( (verts) + 3 );            \
         (verts) += 6;                          \
         (numverts) -= 2;                       \
         break;                                 \
      case 3:                                   \
         glVertex3fv( (verts) );                \
         glVertex3fv( (verts) + 3 );            \
         glVertex3fv( (verts) + 6 );            \
         (verts) += 9;                          \
         (numverts) -= 3;                       \
         break;                                 \
   }                                            \
                                                \
   while ( (numverts) > 0 )                     \
   {                                            \
      glVertex3fv( (verts) );                   \
      glVertex3fv( (verts) + 3 );               \
      glVertex3fv( (verts) + 6 );               \
      glVertex3fv( (verts) + 9 );               \
      (verts) += 12;                            \
      (numverts) -= 4;                          \
   }

#define SEND_VERTS_AND_NORMALS_TO_OPENGL( numverts, verts, norms ) \
                                                                   \
   switch( (numverts) % 4 )                                        \
   {                                                               \
      case 1:                                                      \
         glNormal3fv( (norms) );                                   \
         glVertex3fv( (verts) );                                   \
         (norms) += 3;                                             \
         (verts) += 3;                                             \
         (numverts) -= 1;                                          \
         break;                                                    \
      case 2:                                                      \
         glNormal3fv( (norms) );                                   \
         glVertex3fv( (verts) );                                   \
         glNormal3fv( (norms) + 3 );                               \
         glVertex3fv( (verts) + 3 );                               \
         (norms) += 6;                                             \
         (verts) += 6;                                             \
         (numverts) -= 2;                                          \
         break;                                                    \
      case 3:                                                      \
         glNormal3fv( (norms) );                                   \
         glVertex3fv( (verts) );                                   \
         glNormal3fv( (norms) + 3 );                               \
         glVertex3fv( (verts) + 3 );                               \
         glNormal3fv( (norms) + 6 );                               \
         glVertex3fv( (verts) + 6 );                               \
         (norms) += 9;                                             \
         (verts) += 9;                                             \
         (numverts) -= 3;                                          \
         break;                                                    \
   }                                                               \
                                                                   \
   while ( (numverts) > 0 )                                        \
   {                                                               \
      glNormal3fv( (norms) );                                      \
      glVertex3fv( (verts) );                                      \
      glNormal3fv( (norms) + 3 );                                  \
      glVertex3fv( (verts) + 3 );                                  \
      glNormal3fv( (norms) + 6 );                                  \
      glVertex3fv( (verts) + 6 );                                  \
      glNormal3fv( (norms) + 9 );                                  \
      glVertex3fv( (verts) + 9 );                                  \
      (norms) += 12;                                               \
      (verts) += 12;                                               \
      (numverts) -= 4;                                             \
   }

#endif
