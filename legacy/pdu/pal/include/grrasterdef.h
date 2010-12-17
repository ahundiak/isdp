/*
 * Include file for Raster Graphics Objects (#defines only)
 */

#ifndef grrasterdef_include

#define grrasterdef_include

#define GRRGRES_SIZE 328
#define GRRG_MAX_COMPRAST_MEM	100000

/*
 * Raster Graphics properties masks.
 */

#define GRIS_TRANSPARENT 0x1
#define GRIS_FASTDIS 0x2
#define GRIS_HIDDEN  0x8
#define GRIS_BORDDIS 0x10
#define GRIS_PARTDIS 0x20
#define GRIS_RAW     0x40
#define GRIS_LOCAL   0x80
#define GRINSIDE_MASKING_ENABLED 0x100
#define GROUTSIDE_MASKING_ENABLED 0x200
#define GRUSE_OVERVIEW		  0x400
#define GRDISPLAY_EDIT_MASK	  0x800
#define GRCOMPRESSED_DATA	  0x1000

/* Raster Graphics masking properties
 *
 */

#define GRREPLACE_MASK        0x0 
#define GRLOGICAL_AND_MASK    0x1
#define GRLOGICAL_OR_MASK     0x2
#define GRLOGICAL_ANDNOT_MASK 0x3

/*
 *  Raster Graphics attribute types.
 */

#define GRBIT_ATTRIBUTE -sizeof(IGRchar)
#define GRBYTE_ATTRIBUTE sizeof(IGRchar)
#define GRSHORT_ATTRIBUTE sizeof(IGRshort)
#define GRLONG_ATTRIBUTE sizeof(IGRlong)
#define GRDOUBLE_ATTRIBUTE sizeof(IGRdouble)
#define GRRGB_ATTRIBUTE -(sizeof(IGRchar)*3)
#define GRCMYK_ATTRIBUTE -sizeof(IGRlong)
#define GRCMPRBYTE_ATTRIBUTE    3
#define GRCMPRBIT_ATTRIBUTE     5

#endif
