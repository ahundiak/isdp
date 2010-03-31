
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/


/*
DESCRIPTION
	Structure definitions used by the Rendering portion of HSURF.  All
	unsigned types don't use IGR types because ASAPII compilation requires
	strict ANSI mode and "IGRuint", etc. are not allowed in 
	ANSI mode.

HISTORY
	S.P. Rogers    07/07/89  Creation Date
*/
   
/* texture list structure */
struct HRtexture_list 
	{
	IGRchar               Fname[300];
	IGRchar               *mipmap;
	IGRint                count;
	IGRint                mipmap_size;
	struct HRtexture_list *next;
	IGRboolean            found;
	};


/* generic bucket sort structure */
struct HRgeneric_sort_record
	{
	struct HRgeneric_sort_record *left;
	IGRint key2;
	struct HRgeneric_sort_record *right;
	};
	

/* bucket sort information */
struct HRbucket_info
	{
	IGRdouble                    units_per_bucket;
	IGRint                       num_buckets;
	IGRint                       min_key1;
	struct HRgeneric_sort_record **buckets;
	IGRboolean                   double_sort;
	};
	
/* environment information records */
struct HRenv_record
	{
	struct HRenv_record  *next;             /* pointer to next entry in list                 */
	IGRint               osnum;             /* object space number of attachment             */
	IGRmatrix            matrix;            /* environment matrix                            */
	IGRdouble            clip_range[6];     /* dit clipping range for attachment             */
	IGRint               layers[32];        /* environment layer mask                        */
	IGRshort             matrix_type;       /* environment matrix type                       */
	IGRboolean           mirror_transform;  /* TRUE, if environment matrix contains a mirror */
	};
	
/* rendering parameters in the format that rendering can best use them */
struct HRspecial_rendering_parms
	{
	IGRint			color;			/* color index                                */
	IGRint			finish;			/* Phong exponent                             */
	IGRint			spec_refl;		/* specular reflection coeff, 0x0000 - 0x8000 */
	IGRint			diff_refl;		/* specular reflection coeff, 0x0000 - 0x8000 */
	IGRint			transparency;		/* transparency coefficient, 0x0000 - 0x8000  */
	IGRint			opacity;		/* opacity coefficient, 0x0000 - 0x8000       */
	struct HRtexture_list	*surface_texture;	/* texture map info                           */
	IGRint			texture_orientation;	/* orientation of the surface texture         */
	unsigned int            red, green, blue;       /* RGB values, 0x0000 - 0x8000                */
	};

/* surface sorting records */
struct HRsurface_record
	{
 	struct HRsurface_record           *next;               /* pointer to next surface in bucket    */
	struct HRenv_record               *env;                /* pointer to environment information   */
	struct HRspecial_rendering_parms  rend_parms;          /* element's rendering parameters       */
	IGRint                            objid;               /* object id                            */
	IGRboolean                        resorted_by_tiler;   /* TRUE, if already resorted by tiler   */
	IGRboolean                        dont_cull;           /* TRUE, if surface shouldn't be culled */
	};

/* rendering specific light source structures => values are stored */
/* in a format that optimizes the lighting calculations            */
struct HRpoint_light_source
	{
	IGRdouble	x, y, z;		/* light source location */
	IGRdouble	radius;			/* light source radius */
	IGRshort	red, green, blue;	/* light source RGB (0-255)  */
	};

struct HRparallel_light_source
	{
	IGRint		dir[3];			/* light source direction (16:15) signed */
	IGRshort	red, green, blue;	/* light source RGB (0-255)  */
	};

struct HRspot_light_source
	{
	IGRdouble	x, y, z;		/* light source location */
	IGRdouble 	radius;			/* light source radius */
	IGRint		cosine;			/* light source cosine (16:15) signed */
	IGRint		dir[3];			/* light source direction (16:15) signed */
	IGRshort	red, green, blue;	/* light source RGB (0-255)  */
	};

struct HRpencil_light_source
	{
	IGRdouble	x, y, z;		/* light source location */
	IGRdouble	radius;			/* light source radius */
	IGRint		dir[3];			/* light source direction (16:15) signed */
	IGRshort	red, green, blue;	/* light source RGB (0-255)  */
	};


/* globals used by rendering driver */
struct HRrendering_globals
	{
	struct HRenv_record      *env_list;            /* linked list of environments                    */
	struct HRspan_trapezoid	 *active_traps;        /* active trapezoid list                          */
	struct HRsurface_record  *cur_surf;            /* surface currently being tiled                  */
	struct HRtexture_list    *texture_list;        /* list of active textures                        */
	struct HRbucket_info     surface_buckets;      /* bucket sort info for surfaces                  */
	struct HRbucket_info     trap_buckets;         /* bucket sort info for trapezoids                */
	IGRint                   source_x_dits;        /* x-dits of window being rendered                */
	IGRint                   source_y_dits;        /* y-dits of window being rendered                */
	IGRint                   display_wno;          /* window number of display window                */
	IGRint                   display_x_dits;       /* x-dits of display window                       */
	IGRint                   display_y_dits;       /* y_dits of display window                       */
	IGRint                   scale;                /* pixel magnification for display                */
	IGRint                   scan_line;            /* current scan-line                              */
	IGRchar                  output_file[200];     /* RLE output file name                           */
	IGRint                   num_colors;           /* number of active colors                        */
	IGRboolean               cur_traps_reclaimed;  /* TRUE, if the current surface had traps removed */
	IGRshort                 *red;                 /* base color red array (0-255)                   */
	IGRshort                 *green;               /* base color green array (0-255)                 */
	IGRshort                 *blue;                /* base color blue array (0-255)                  */
	IGRboolean               true_color;           /* TRUE, if rendering in TRUE color               */
	IGRboolean               use_rgb;              /* TRUE, if using RGB from surface bundle         */
	};

extern struct HRrendering_globals rendering_globals;

