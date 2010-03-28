/*\
Description
   This include file represents #defines used by the graphics set package.
\*/

#ifndef  grgsdef_include
#define  grgsdef_include

/* 
 *  Define used for the save set properties word and for
 *  the pass method env_properties.
 */

#define  GSIS_SV_SPEC_MASK 0xfffffff0
#define  GSIS_SV_PROP_MASK 0x0000000f
#define  GSIS_READ_ONLY    0x00000001  /* Save set property */
#define  GSIS_CPX_CONNECT  0x00000010  /* Save set specific property */

/*
 *  Defines for the types of fence contents locates.
 */

#define  FC_INSIDE            0
#define  FC_INSIDE_OVERLAP    1
#define  FC_INSIDE_CLIP       2
#define  FC_OUTSIDE           3
#define  FC_OUTSIDE_OVERLAP   4
#define  FC_OUTSIDE_CLIP      5
#define  FC_OVERLAP           6

/*
 *  Defines for the graphics object relationship with the right prism.
 */

#define  TRUE_REL    0
#define  GO_OVERLAP  1
#define  GO_INSIDE   2
#define  GO_OUTSIDE  4

#define GR_RIGHT_PRISM  0
#define GR_CURVE_PRISM  1

/*
 *  Defines for the Graphics set properties.
 *
 *____________________________________________________________________
 * bit 0 -  GRIS_CLONE
 *             If the object has a copy of all objects on the 
 *             clone channel.
 * bit 1 -  GRIS_CURRENT 
 *             If the GRgrset->current variable is valid.
 * bit 2 -  GRIS_POST_PROCESSING 
 *             If post processing 
 * bit 3 -  GRIS_POST_PROCESSING_INSIDE   
 *             If post processing elements inside
 * bit 4 -  GRIS_POST_PROCESSING_OUTSIDE  
 *             If post processing elements outside
 * bit 5 -  GRIS_BACKGROUND_DISPLAY
 *             If one displayed in background 
 *             If zero not displayed in background
 * bit 6 -  GRIS_DISPLAY_ALL
 *             If one respond to background and highlight requests
 *             If zero respond to only background requests
 * bit 7 -  GRIS_REUSABLE
 *             If one then the graphcs set is reusable by the command
 *             object.
 *             If zero then the graphics set is an select set.
 *_____________________________________________________________________
 */

#define   GRIS_CLONE                   0x0001  
#define   GRIS_CURRENT                 0x0002
#define   GRIS_POST_PROCESSING         0x0004
#define   GRIS_POST_PROCESSING_INSIDE  0x000c
#define   GRIS_POST_PROCESSING_OUTSIDE 0x0014
#define   GRIS_INSIDE                  0x0008
#define   GRIS_OUTSIDE                 0x0010
#define   GRIS_BACKGROUND_DISPLAY      0x0020
#define   GRIS_DISPLAY_ALL             0x0040
#define   GRIS_REUSABLE                0x0080

/*
 *  Defines for the GRfence properties word.
 */

#define  GRFN_IS_DISPLAYABLE  0x1
#define  GRFN_CLIP_INSIDE     0x2   /* treat the fence as inside  */
#define  GRFN_CLIP_OUTSIDE    0x4   /* treat the fence as outside */

/*
 *  Define for the name of the graphics set manager.
 */

#define GR_GSMGR "gr$gsmgr"

/*
 *  The following  defines are used in the post and retreiving of
 *  the locate criteria.
 */

#define GSPUT_LOCATE_ENV         0x1
#define GSPUT_ATTRIBUTES         0x2
#define GSPUT_RTREE_CLASSES      0x4
#define GSPUT_ELIGIBLE_CLASSES   0x8
#define GSPUT_LEVELS             0xf

#endif
