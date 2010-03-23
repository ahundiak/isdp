
/*
 *   File:  MKBM.H
 */

/*****  DEFINITIONS *****/

/* constants */
#define  TWO32  4.294967296E+09     /*  2 ** 32 , bulge factor normalization */
#define  PI     3.1415926536        /* pi */
#define  PTPERINCH 72.2892          /* nbr points per inch, exactly! */
#define  GENERIC  72                /* generic device resolution, 72 x 72  */
#define  DCHRCT   64                /* max nbr of subcharacters in compound char */

/* strings, names */
#define BMAPDEF  "cmpr"
#define KERNDEF  "/user/include/kern.prs"

/* Em-square dimensions in high-precision relative units (baseline is at 0) */
#define   EM_TOTAL  8640      /* size of em-square */
#define   EM_LEFT   0         /* left edge of em-square */
#define   EM_RIGHT  8640      /* right edge of em-square */
#define   EM_TOP    6597      /* top edge of em-square */
#define   EM_BOT   -2043      /* bottom edge of em-square */


/* Plaid data constants */
#define X_DIMENSION              0
#define Y_DIMENSION              1
#define MAX_ZONES_PER_DIM       64
#define MAX_ZONES_PER_COMP_DIM 100
#ifdef apollo
#define MAX_CHARS             1000
#define MAX_CACHE_ZONES       1000
#endif /* apollo */
#ifdef MSDOS
#define MAX_CHARS          640
#define MAX_CACHE_ZONES    512
#endif /* MSDOS */
#ifdef IPRO
#define MAX_CHARS             1000
#define MAX_CACHE_ZONES       1000
#endif /* interpro */


#define MASK_P_FLAG           0x8000   /* Mask to extract parent flag from flags word */
#define MASK_L_FLAG           0x4000   /* Mask to extract level flag from flags word */
#define MASK_C_FLAG           0x2000   /* Mask to extract continue flag from flags word */
#define MASK_FN_FLAG          0x1800   /* Mask to extract function field from flags word */
#define FN_ONE_ITEM           0x0800   /* Value of function field representing one item */
#define MASK_MIN              0x00ff   /* Mask to extract minimum field from flags word */


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
    fix15   choff;              /* char offset number */
    real    lines_per_em;
    real    point_size_x;
    real    point_size_y;
    real    res_hor;            /* horizontal resolution */
    real    res_ver;            /* vertical resolution */
    real    rot_angle;
    real    obl_angle;
    bool16  print_data;         /* dump debugging information */
    bool16  import_widths;      /* use imported width table */
    lrtb    clip;               /* clip to char extents */
    lrtb    squeeze;            /* squeeze to char extents */
    bool16  scanx;              /* if T, do scan conv. in 2 dimensions */
    fix31   bsloff_x;           /* left s.b.offset in x-scan conversion lists */
    fix31   bsloff_y;           /* baseline offset in y-scan conversion lists */
   /* These 3 items are passed to the rules.c module */
    bool16  sw_fixed;           /* if T, set width constrained */
    bool16  bogus_mode;         /* if T, ignore plaid data */
    float   xht_adj;            /* x-height adj factor (always 1.0) */
    }   comp_char_desc;     /* character attributes for scan conversion */
