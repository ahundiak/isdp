/*
Author:  dh
Date:  3/6/95
*/

#ifndef vd_ve_include
#define vd_ve_include 1

/*
DESCRIPTION
        Structure definitions used by VDS in making use of VE (visible
        edges, or vector hidden line) processing

HISTORY
        dh  3/6/95  Creation Date
*/

#define  VDbuf_incr  25 /* increment to realloc if buffer too small  */

#include "OMtypes.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"

/* buffer of 3D geometry elements for VDS use in VE processing */
struct VDve_elem_buf
{
   struct GRobj_env *obj_info_p;   /* pointer to buffer of element obj */
                                   /* id/environment info structures */
   IGRint count;   /* count of actual # elements in buffer  */
   IGRint buf_siz;   /* actual size of buffer in terms of # elements; */
                     /* note that count <= buf_siz */
};

#endif
