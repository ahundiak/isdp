/*
 *   File:  MKBM.H
 *
 *   Modified: 11-06-87 mby  Added lines_per_emx and ww_thresh to 'comp_char_desc'
 *   Modified: 7 Jan 88 jsc  comp_char_desc members modified
 */

/*****  DEFINITIONS *****/

/* constants */
#define  TWO32  4.294967296E+09     /*  2 ** 32 , bulge factor normalization */
#define  TWO31  2.147483648E+09     /*  2 ** 31 , fixed point limit */
#define  PI     3.1415926536        /* pi */
#define  PTPERINCH 72.2892          /* nbr points per inch, exactly! */
#define  GENERIC  72                /* generic device resolution, 72 x 72  */
#define  DCHRCT   64                /* max nbr of subcharacters in compound char */
#define  MAX_ARC_DEPTH 10            /* Max depth to which arcs can be recursively subdivided */
#define  MAX_INTERCEPTS 1000        /* Max storage for intercepts */
#define  X_SCAN_THRESH  35          /* lowest res at which x scan not required */
#define  ARC_ERROR_TOLERANCE  0.1   /* curve must be split into enough vectors such that */
                                    /* the maximum error is ARC_ERROR_TOLERANCE pixels */
#define  SIXBITS 1                  /* 1 for six bits of accuracy when below */
                                    /* the limit of X_SCAN_THRESH, results in very good */
                                    /* bmaps at a cost of speed. 0 is for four bits of */
                                    /* accuracy for fast good bmaps */
#define WHITE_WRITER 0              /* 1 to compile whitewriter code */
                                    /* 0 to not compile whitewriter code */
#define VECT_OUT 0                  /* 1 to compile vector output code */
                                    /* 0 to not compile vector output code */

#define SCALE_1_PLUS 0              /* Bitstream reserved for scale control */

#if SIXBITS

#define  ROUND_UP 32
#define  ROUND_DOWN 31
#define  SHIFT_VAR 6
#define  MAX_DIFF 65
#define  DIVIDE_BY 7
#define  ROUND_RULES 512
#define  SHIFT_RULES 10

#else

#define  ROUND_UP 8
#define  ROUND_DOWN 7
#define  SHIFT_VAR 4
#define  MAX_DIFF 17
#define  DIVIDE_BY 5
#define  ROUND_RULES 2048
#define  SHIFT_RULES 12

#endif                 

/* strings, names */               
#define BMAPDEF  "cmpr"
#define KERNDEF  "/user/include/kern.prs"

/* Em-square dimensions in 8640ths of an em (baseline is at y = 0) */
#define   EM_TOTAL  8640      /* size of em-square */
#define   EM_LEFT   0         /* left edge of em-square */
#define   EM_TOP    6597      /* top edge of em-square */
#define   EM_BOT   -2043      /* bottom edge of em-square */


/* Plaid data constants */
#define X_DIMENSION              0
#define Y_DIMENSION              1
#define MAX_ZONES_PER_DIM       64
#define MAX_ZONES_PER_COMP_DIM 100

#if __APOLLO
#define MAX_CHARS             640
#define MAX_CACHE_ZONES       1000
#endif /* apollo */
#if __MSDOS
#define MAX_CHARS          640
#define MAX_CACHE_ZONES    512
#endif /* MSDOS */

#define MASK_P_FLAG           0x8000   /* Mask to extract parent flag from flags word */
#define MASK_L_FLAG           0x4000   /* Mask to extract level flag from flags word */
#define MASK_C_FLAG           0x2000   /* Mask to extract continue flag from flags word */
#define MASK_FN_FLAG          0x1800   /* Mask to extract function field from flags word */
#define FN_ONE_ITEM           0x0800   /* Value of function field representing one item */
#define MASK_MIN              0x00ff   /* Mask to extract minimum field from flags word */

typedef
struct
    {
    fix15               car;
    ufix16 near         *cdr;       /* Actually, a pointer to another intrcpt_element */
    fix15               sub_char_num;
    }   intrcpt_element;

typedef
struct
    {
    fix15   raswid;             /* raster width  */
    fix15   rashgt;             /* raster height */
    fix15   offhor;             /* horizontal offset from left edge of emsquare */
    fix15   offver;             /* vertical offset from baseline */
    fix15   set_width;          /* character set width */
    }   btminf;


typedef
struct
    {
    bool16  left;
    bool16  right;
    bool16  top;
    bool16  bottom;
    }   lrtb;


typedef
struct
    {
    cft_outl_str  *compf;       /* compressed outline font data str */
    ufix16  mode;               /* what mode is the font generator in */
    real    point_size_x;       /* Point size in X dimension */
    real    point_size_y;       /* Point size in Y dimension */
    real    res_hor;            /* Horizontal resolution of output device */
    real    res_ver;            /* Vertical resolution of output device */
    real    rot_angle;          /* Rotation angle in degrees (clockwise) */
    real    obl_angle;          /* Obliquing angle in degrees (clockwise) */
    bool16  whitewrite;         /* if T, generate bitmaps for whitewriters */
    real    thresh;             /* Scan conversion threshold 
                                 * Thickens characters on each edge by
                                 * <thresh> sub-pixels  */  
    bool16  import_widths;      /* Use imported width table */
    lrtb    clip;               /* Clip to standard character cell */
    lrtb    squeeze;            /* Squeeze to standard character cell */
    bool16  bogus_mode;         /* if T, ignore plaid data */
    }   comp_char_desc;         /* character attributes for scan conversion */

typedef  struct
    {
    fix15   xoff;               /* ordered pair */
    fix15   yoff;
    ufix16  xscale;             /* actual scaling */
    ufix16  yscale;
    ufix16  xscale_nom;         /* nominal scaling */
    ufix16  yscale_nom;
    ufix16 *pc;                 /* program counter */
    }
    stack_frame;


