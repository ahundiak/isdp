
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsurf_include
#define hsurf_include 1

/*
 * hsurf.h contains structure definitions for the getting at the
 * instance data in HSinstance and HSdpb2 objects.  All unsigned
 * types don't use IGR types because ASAPII compilation requires
 * strict ANSI mode and "unsigned IGRint", etc. is not allowed 
 * in ANSI mode.
 */

/* instance data structure for HSinstance objects */

struct	HStotal_window_instance
	{
	unsigned int   disp_flags;
	unsigned short depth_cue_shades;
	unsigned char  shading_style;
	};


/* Symbology structure for VHL */
struct HSvhl_symb
	{
	unsigned short color;                   /* 0 - 511 */
	unsigned char  style;                   /* 0 - 7   */
	unsigned char  weight;                  /* 0 - 31  */
	IGRboolean     use_orig_color;
	IGRboolean     use_orig_style;
	IGRboolean     use_orig_weight;
	};

/* structures used for bundling shading symbologies */
struct HSrender_bundle
	{
	unsigned short tex_index;     /* index into texture table              */
	unsigned char shad_style;     /* shading style                         */
	unsigned char tex_orient;     /* texture orientation                   */
	unsigned char finish;         /* phong exponent, 0-255                 */
	unsigned char trans;          /* transparency percentage, scaled 0-255 */
	unsigned char diff_refl;      /* diffuse refl. coeff., scaled 0-255    */
	unsigned char spec_refl;      /* specular refl. coeff., scaled 0-255   */
	unsigned char red;	      /* red: 0 - 255                          */
	unsigned char green;	      /* green: 0 - 255                        */
	unsigned char blue;	      /* blue: 0 - 255                         */
	};

struct HSextra_render_bundle
	{
	float          refraction;
	float          pattern_x_offset;
	float          pattern_y_offset;
	float          pattern_rot_angle;
	float          pattern_scale;
	unsigned short flags;
	unsigned char  reflection;
	};

/* bit masks for flags word in HSextra_render_parms */
#define HS_BACKGROUND_TRANS 0x0001   /* 1 -> background transparent */
#define HS_FRESNEL	    0x0002   /* 1 -> fresnel on */
#define HS_MIRROR           0x0004   /* 1 -> mirror on */
#define HS_PIXIE            0x0008   /* 1 -> pixie on */

#endif
