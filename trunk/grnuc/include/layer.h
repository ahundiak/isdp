#include "exfi.h"

/*
 * Struct for named layers.
 */

struct GRlayer
{
    IGRchar number[EXFI_STRLEN];/* the definition of the named layers */
    IGRlong ly_num_mask[32];    /* a mask of the named layers' numbers */
    IGRshort num_lys;           /* number of named layer's in the group */
    IGRchar name[EXFI_STRLEN];  /* the name for the named layers */
    IGRchar elig[6];
    IGRchar occupied[16];
    IGRint  selected;           /* group has been selected for delete */
    IGRint  delete;             /* group has been deleted */
};

/* 
 * Struct for individual layers 0 - 1023.
 */

struct GRindlayer
{
    IGRchar number[5];          /* layer number 0 - 1023 */
/*  IGRchar name[EXFI_STRLEN];     individual layer name */
    IGRchar elig[6];
    IGRchar occupied[18];
};
