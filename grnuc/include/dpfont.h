




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

#ifndef dpfont_include
#define dpfont_include


	/*
	 *
	 *  This include file contains structures used less frequently
	 *  than the structures in dp.h.  This include file is dependent
         *  on the following include files:
	 *
	 *	igrtypedef.h
	 *	font.h    
	 */

#define DPFONT_CACHE_SIZE	15
#define BITMAP_FONT	0x00000008
#define	FRAC_FONT	0x00000002
#define TEXT_FP_ERR	0.00000001 
#define BODYSIZE_FP_ERR	0.0001
#define MIN_BITMAP_SIZE	3.5
#define MAX_BITMAP_SIZE	100.0


           

	struct DPfnt_os
	{
	    IGRshort		os_num;
	    IGRshort		fst_char_fnt;
	    IGRshort		fst_frac_fnt;
	    IGRshort		fst_16bit_fnt;
	    struct   DPfnt_tbl	*fnt_tbl;
	    struct   DPbmap_tbl *bmaptbl;
	};

	struct DPfnt_os_tbl
	{
	    struct DPfnt_os	fnt_os_tbl[33];
	    struct DPfnt_os_tbl	*next;
	};

	struct DPbmap_fnt
	{
	    IGRint		virt_font_no;
	    IGRuint		time_stamp;
	    IGRint		font_id;
	    IGRdouble		body_size;
	    IGRdouble		angle;
	    IGRdouble		aspect_ratio;
	};
	    
	struct DPbmap_tbl
	{
	    struct DPbmap_fnt	fonts[DPFONT_CACHE_SIZE];
	    IGRuint	count;
	};

	struct DPfnt_ptrs
	{
	    IGRdouble		body_size;
	    IGRdouble		decent;
	    IGRint		font_id;
	    IGRint		flags;
	    IGRchar		fontname[15];
	    IGRchar		charmap[15];
	};

	struct DPfnt_tbl
	{
	    struct DPfnt_ptrs	fonts[64];
	};

struct DPoutldraw
{
   IGRdouble		prev_x;
   IGRdouble		prev_y;
   IGRdouble		prev_char_width;
   IGRdouble		txt_angle_cos;
   IGRdouble		*aspect_ratio;
   IGRdouble		*fnt_to_local;
   IGRdouble		*loc_to_screen;
   IGRdouble		*fnt_to_screen;
   IGRdouble		*x_scale;
   IGRdouble		*y_scale;
   IGRdouble		*txt_width;
   IGRdouble		*txt_height;
   IGRdouble		*intrchr_spc;
   IGRdouble		**strk_buf;
   IGRdouble 		*trans_x_const;
   IGRdouble 		*trans_y_const;
   IGRdouble 		*trans_z_const;
   IGRdouble		*bodysize;
   IGRuchar		*char_string;
   IGRint		bitmap_win_no;
   IGRint		bitmap_drawplanes;
   IGRint		char_num;
   IGRint		*font_id;
   IGRint		gpipe_id;
   IGRuint		flags;
   IGRuint		gragad_flags;
   IGRuint 		*fill_text;   
   IGRint		use_bitmap;
   IGRint		greek_text;
   IGRint		first_char;
   IGRint		*num_points;
   IGRint		total_points;
   IGRint		error;
};




struct DPesc_args
{
      IGRuchar	 		**text_index;
      IGRdouble 		*trans_x_const;
      IGRdouble 		*trans_y_const;
      IGRdouble 		*trans_z_const;
      IGRdouble 		*txt_height;
      IGRdouble 		*txt_width;
      IGRdouble 		*loc_to_screen;
      IGRdouble			*fnt_to_screen;
      struct IGResintx		*txt_ele;
      struct DPfnt_os_tbl	*os_tbl_ptr;
      IGRdouble			*line_spacing;
      IGRdouble			*intrchr_spc;
      IGRdouble			*x_scale;
      IGRdouble			*y_scale;
      IGRdouble			*fnt_to_local;
      IGRdouble			*baseline;
      IGRint			*font_id;
      IGRdouble			*bodysize;
      IGRdouble			*decent;
      IGRdouble			vw_scale;
      IGRdouble			angle;
      IGRdouble			scale_ratio;
      IGRdouble			*aspect_ratio;
      IGRint			*font_flags;
      IGRuint			disp_flags;
      IGRint			use_bitmap;
      IGRint			*fill_text;
      IGRdouble			*strk_buf;
      IGRint			*win_no;
      IGRshort			*cur_font;
      IGRshort			*prev_font;
};

#endif
