/*
Name
        grpgendef.h

Description
        Include file for the group generator commands.

History
        wbc     11/27/90    creation
        mrm     01/08/91    added labels for Generate Set form
        dhm     06/19/92    added definitions for layer sub-form
*/

#ifndef grpgendef.h_include
#define grpgendef.h_include

#define NUM_SYMB     4
#define COLOR_SYMB   0
#define STYLE_SYMB   1
#define WEIGHT_SYMB  2
#define LAYER_SYMB   3

#define COLOR_DEFINED  0x1
#define STYLE_DEFINED  0x2
#define WEIGHT_DEFINED 0x4

#define LO_COLOR    0
#define HI_COLOR  512
#define LO_STYLE    0
#define HI_STYLE  256 
#define LO_WEIGHT   0
#define HI_WEIGHT  32
#define LO_LAYER    0
#define HI_LAYER 1024

#define COLOR_MASK_SIZE (((HI_COLOR - 1) / 8) + 1)
#define STYLE_MASK_SIZE (((HI_STYLE - 1) / 8) + 1)
#define WEIGHT_MASK_SIZE (((HI_WEIGHT - 1) / 8) + 1)
#define LAYER_MASK_SIZE (((HI_LAYER - 1) / 32) + 1)

/* definitions for Generate Set form */

#define GENSET_INDEX        0
#define COLOR_INDEX         1
#define WEIGHT_INDEX        2
#define STYLE_INDEX         3
#define LAYER_INDEX         4
#define NFORMS              5
#define GENSET_FORM         100
#define COLOR_FORM          101
#define WEIGHT_FORM         102
#define STYLE_FORM          103
#define LAYER_FORM          104
#define FENCE_CHECK         12
#define WINDOW_CHECK        13
#define FILE_CHECK          14
#define WINDOW_FIELD        42
#define FILE_FIELD          43
#define IN_CHECK            60
#define OUT_CHECK           61
#define OVL_CHECK           65
#define CLIP_CHECK          66
#define COLOR_BUTTON        35
#define WEIGHT_BUTTON       36
#define STYLE_BUTTON        37
#define LAYER_BUTTON        23
#define COLOR_FIELD         31
#define WEIGHT_FIELD        32
#define STYLE_FIELD         33
#define LAYER_FLD           21
#define CLEAR_BUTTON        50
#define SET_BUTTON          52
#define TYPE_FIELD          44
#define SET_OPERATOR_GROUP  59
#define INTERSECT_CHECK     24
#define UNION_CHECK         26
#define SELECT_WINDOW       63

#endif
