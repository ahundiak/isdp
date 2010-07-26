#ifndef igecolordef_include

#define igecolordef_include

#define		COL_RIGHT_SCREEN	0	
#define		COL_LEFT_SCREEN	0	

#define		MAX_COLOR		511
#define         DEFAULT_NUM_BG_LOG_HL   256

/* These also match the defines for DP_INVISIBLE_COLOR & DPGRID_COLOR */
#define		IGE_LOGICAL_BACKGROUND	0XFFFF
#define		IGE_LOGICAL_HILITE	0XFFFE

#define		STRUCTURE_COLORS	0x00000000
#define		PACKED_COLORS		0x00000001
#define		IGE_READ_BACKGROUND	0x00000002
#define		IGE_READ_HIGHLIGHT	0x00000004
#define		IGE_CHANGE_BACKGROUND	0x00000008
#define		IGE_CHANGE_HIGHLIGHT	0x00000010

#define         IGE_COLORS		1
#define         IGDS_COLORS		2

#define		MAX_COLORS		-1
#define		MAX_COLORS_W_RES	-2
#define		MAX_SHADES		-1
#define		NO_SHADES		1

#define		NO_MATCH		-1

#define		IGECOLAPP		0
#define		IGECOLNOT		1
#define 	IGEAPPUSR		2

/* index interpretation flags */
#define	IGE_LOGICAL_INDEX_TO_LOG	1
#define	IGE_LOGICAL_INDEX_TO_PHYS	2
#define	IGE_PHYSICAL_INDEX		3

/* slot flags */
#define VLT_EMPTY_SLOT			0x0001
#define VLT_USED_SLOTS			0xFFFE
#define VLT_HILITE_SLOT			0x0002
#define VLT_COLOR_CUBE_SLOT		0x0004
#define VLT_EXACT_MATCH_SLOT		0x0008
#define VLT_CANNOT_SWAP_SLOT		0x0010
#define VLT_WIN_MGR_SLOT		0x0020
#define VLT_INGR_RES_SLOT		0x0040
#define VLT_SPECIAL_AREA_SLOT		0x0080
#define VLT_RAMP_SLOT                   0x0100
#define VLT_RAMP_BASE_COLOR_SLOT        0x0200
#define VLT_USER_RAMP_SLOT              0x0400

/* user cube size */
#define IGE_USER_CUBE_SIZE_DEFAULT      0x01
#define IGE_USER_CUBE_SIZE_MAX          0x10
#define IGE_USER_CUBE_SIZE_MAX_MINUS_1  0x11
#define IGE_USER_CUBE_SIZE_MIN          0x20
#define IGE_USER_CUBE_SIZE_MIN_PLUS_1   0x21

/*swap modes*/
#define IGE_WIN_MGR_TO_CUBE_SWAP	1
#define IGE_INGR_RES_TO_CUBE_SWAP	2
#define IGE_WIN_MGR_CUBE_TO_CUBE_SWAP	3
#define IGE_INGR_RES_CUBE_TO_CUBE_SWAP	4

#define	CLpack_colors(red,green,blue)  \
             ((IGRuint)(((IGRuint) red << 14) & 0xfff00000) | \
	     (((IGRuint) green << 4) & 0xfffffc00) | \
	     ((IGRuint) blue >> 6))

#define CLunpack_colors(color,red,green,blue)			\
	*red = 	(IGRushort) (( color >> 14) & 0x0000ffc0)|(( color >> 24) & 0x0000003f); \
	*green=	(IGRushort) (( color >> 4 ) & 0x0000ffc0)|(( color >> 14) & 0x0000003f); \
	*blue =	(IGRushort) (( color << 6 ) & 0x0000ffc0)|(( color >> 4) & 0x0000003f)



/*
NAME
   IGERGB_TO_INDEX

DESCRIPTION
   This macro calculates the VLT index that should be used to
   draw a pixel given the XY coordinates of the pixel and its
   RGB color.  (For Psuedo True Color).  This macro is used 
   instead of the function for performance reasons.  Set up before
   using the macro is:

   register int dither_val;
   static int   dither_mat[16] = {  0,  8,  2, 10,  
                                   12,  4, 14,  6,  
                                    3, 11,  1,  9,
                                   15,  7, 13,  5 };
   int num_intens;
   struct IGEcontext_info      IGEcontext_info;  

   IGEload_context( me->context_no, &IGEcontext_info );
   num_intens = ((IGEcontext_info.cube_size-1)*16)+1;

PARAMETERS
   color_index (OUT) - the physical vlt index
   x (IN) - x coordinate of pixel to be drawn
   y (IN) - y coordinate of pixel to be drawn
   red (IN) - red component of pixel color; [0..255]
   green (IN) - green component of pixel color; [0..255]
   blue (IN) - blue component of pixel color; [0..255]

GLOBALS USED

RETURN VALUES
   The VLT index that should be used to draw the pixel is returned.

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
#define IGERGB_TO_INDEX( color_index, x, y, red, grn, blu)                   \
{                                                                            \
   /* Calculate dither value. */                                             \
   dither_val = dither_mat[((y & 3) << 2) | (x & 3)];                        \
                                                                             \
   /* find the actual color with number of perceived intensities */          \
   red = (red * num_intens) >> 8;                                            \
   grn = (grn * num_intens) >> 8;                                            \
   blu = (blu * num_intens) >> 8;                                            \
   /* Perform dithering to achieve halftones. */                             \
   red = (((red & 15) > dither_val) ? ((red >> 4) + 1) : (red >> 4));        \
   grn = (((grn & 15) > dither_val) ? ((grn >> 4) + 1) : (grn >> 4));        \
   blu = (((blu & 15) > dither_val) ? ((blu >> 4) + 1) : (blu >> 4));        \
                                                                             \
   /* Return vlt color index value which corresponds to calculated */        \
   /*   9-bit rgb dither value.                                    */        \
   color_index = IGErgb_table[(blu << 6) | (grn << 3) | red] ;               \
}

#endif
