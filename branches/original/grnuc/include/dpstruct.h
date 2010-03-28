




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

#ifndef dpstruct_include
#define dpstruct_include


	/*
	 *
	 *  This include file contains structures used less frequently
	 *  than the structures in dp.h.  This include file is dependent
         *  on the following include files:
	 *
	 *	igrtypedef.h
	 *	igetypedef.h
	 *	igrdp.h
         *
	 */



	    struct DPrng_off
	    {
	       IGRshort	x;
	       IGRshort	y;
	       IGRshort	z;
	    };


	    struct DPrange_check
	    {
	       struct DPrng_off xlo;
	       struct DPrng_off ylo;
	       struct DPrng_off zlo;
	       struct DPrng_off xhi;
	       struct DPrng_off yhi;
	       struct DPrng_off zhi;
	    };
           
           
          /*
           *   now starts window instance data
           */
           
           
            struct DPgra_gad                        /* window structure */
            {
                IGRint	  flags;   	   /* view flags       */
		struct    DPfnt_os_tbl *fnt_os_ptr;/* font os ptr      */
                IGRlong   grid_per_ref_x;          /* # of grid dots
                                                      between x-axis 
						      cross  	       */
		IGRlong	  grid_per_ref_y;	   /* # of grid dots 
						      between y-axis
						      cross	       */
		IGRshort  wld_viewport_type;	   /* world to viewport
						      matrix type      */
                IGRshort  display_mode;              /* which type display
							is to take place */

		IGRint	  levels[32];		   /* levels	       */
		IGRint	  gpipe_id;
                IGRdouble uor_per_ref_x;           /* uor value between
                                                      grid reference
						      x-axis crosses   */
                IGRdouble uor_per_ref_y;           /* uor value between
                                                      grid reference
						      y-axis crosses   */
                IGRdouble origin[3];               /* view origin      */
                IGRdouble rotation[4][4];          /* view rotation
                                                      matrix           */
                IGRdouble vw_volume[6];            /* view volume NOTE:
						      stored as 0,1,2
						      minimums & 3,4,5
						      are the maxs     */
                IGRdouble act_z;                   /* active z in viewing
                                                      coordinate system*/
                IGRdouble act_z_screen;            /* active z in screen
                                                      coordinate       */
                IGRdouble dit_tol;                 /* dit tolerance    */
                IGRdouble wld_to_viewport[4][4];   /* world to viewport 
                                                      transformation
                                                      matrix           */
                IGRdouble viewport_to_wld[4][4];   /* viewport to world
                                                      transformation
                                                      matrix           */
                IGRdouble alt_vwport_to_wld[4][4]; /* alternate viewport
                                                      to world
                                                      transformation
                                                      matrix           */
		IGRdouble construct_plane[4][4];   /* construction
						      plane matrix     */
		IGRdouble wld_to_view[4][4];       /* viewport to view
						      transformation   */
                IGRdouble dit_clip_range[6];       /* dit clip range in
                                                      screen units relative
						      to the window origin
						      & stored as 0,1,2
						      minimums & 3,4,5
						      are the maximums */
                IGRdouble vvol_viewport_scale;     /* view volume to
                                                      viewport scale   */
/**********  Perspective data *****************************************/
		IGRdouble  eye_pt[3];		   /* eye point for 
						      perspective     */
		IGRdouble  coi[3];		  /*  center of interest */
	        IGRdouble  vw_angle;		  /*  view angle       */
		IGRdouble  vrp[3];		  /* view reference point */
		IGRdouble  vpn[3];		  /* view plane normal    */
		IGRdouble  vup[3];		  /* view up vector     */
  /**********************************************************************/
		struct DPrange_check range_chk;	   /* used for range
						      checking	       */

		struct DPrange_check vv_range_chk; /* used for range
						      checking	       */

               };

struct gragad_inst
{
   IGRint                       win_no;
   
   IGRint                       min_x_dep;
   IGRint                       min_y_dep;
   IGRint                       max_x_dep;
   IGRint                       max_y_dep;

   IGRdouble                    min_x_indep;
   IGRdouble                    min_y_indep;
   IGRdouble                    max_x_indep;
   IGRdouble                    max_y_indep;

   struct DPgra_gad gragad;
};




struct DP_information
{
   struct DPgra_gad *gragad;
   IGRint          win_no;
   IGRboolean      is_update;
   IGRboolean	   is_fit;
   IGRdouble	   fit_range[6];
   IGRboolean      is_hidden_line;
   IGRchar         *hline_info;
   void            (*hl_tiler)();
   GRobjid	   view_objid;
   GRspacenum	   view_osnum;
};

typedef int DPtag;

union IGRgeometry			   /* allowable element geometries  */
{
	struct IGRpolyline    *polyline;   /* polyline geometry		    */
	struct IGRpointset    *point_set;  /* point    geometry		    */
	struct IGRlbsys       *lbsys;	   /* local bounded sys. geometry   */
	struct IGRbsp_curve   *bspcurve;   /* B-spline curve  * geometry    */
	struct IGRbsp_surface *bspsurf;	   /* B-spline surface geometry	    */
};

struct DPele_header			    /* element header		    */
{
	DPtag		   tag;		    /* object id		    */
	IGRshort	   type;	    /* type of abstract element	    */
	unsigned  short    flags;	    /* display flags	            */
	IGRdouble	   *range;	    /* range of the element	    */
	IGRshort	   *level;	    /* level of the element         */
	struct IGRdisplay  *dis_att;	    /* attributes set		    */
	union  IGRele_attr ele_spec_att;    /* element spec. attributes	    */
	union  IGRgeometry geometry;	    /* geometry description         */
	struct IGRdisplay  **u_bound_att;
	struct IGRdisplay  **v_bound_att;
	IGRint 		   u_num_bound_att;
	IGRint 		   v_num_bound_att;
	IGRint		   **u_bound_att_indices;
	IGRint		   **v_bound_att_indices;
	struct GRmdenv_info *mdenv_info;    /* The display matrix 	    */
}; 

struct	DPviewinfo
{
	IGRdouble	rotation[16];
	IGRdouble	vw_volume[6];
	IGRdouble	origin[3];
	IGRdouble	act_z;
};


struct DPviewind
{
	IGRint		type;
	IGRdouble 	point[3];
};

#endif
