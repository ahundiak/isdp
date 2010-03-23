/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/

/*****************************  E R R O R . H  ******************************/
/*                                                                          */
/*  This module contains DEFINES for the error codes                        */
/*                                                                          */
/****************************************************************************/

/* From CACHE.C */

/* Returned from cache_pixels. Means you're trying to put data into an      */
/* character that's not in the cache.                                       */
#define ER_X_CHAR_NOT_LOADED                    1032
#define ER_Y_CHAR_NOT_LOADED                    1033
/* Returned from cache_fpixels. Means the character isn't in the cache      */
#define ER_X_CHAR_UNRND_NOT_LOADED              1034
#define ER_Y_CHAR_UNRND_NOT_LOADED              1035
/* Returned from get cache data */
#define ER_Y_CACHE_ZONE_2BIG                    1036
#define ER_Y_CHAR_NOT_IN_CACHE                  1037
#define ER_X_CACHE_ZONE_2BIG                    1080
#define ER_X_CHAR_NOT_IN_CACHE                  1081
/* Returned from clr_pxls_cache */
#define ER_X_CANT_CLR_NOT_LOADED                1038
#define ER_Y_CANT_CLR_NOT_LOADED                1039
/* Returned from clear_x_cache */
#define ER_CLRX_CHAR_NOT_FOUND                  1040
/* Returned from clear_y_cache */
#define ER_CLRY_CHAR_NOT_FOUND                  1041
/* Returned from clear_scaled_x_cache */
#define ER_CLRXSC_CHAR_NOT_FOUND                1042
/* Returned from clear_scaled_y_cache */
#define ER_CLRYSC_CHAR_NOT_FOUND                1043

/* From CONVERT.C */

/* Returned from fw_set_specs */
#define ER_VECTOR_NOT_COMPILED                  1150
#define ER_WW_NOT_COMPILED                      1151
#define ER_MODE_UNDEFINED                       1053
#define ER_NOT_FW_OUTLINE                       1054
#define ER_2MANY_CHARS_IN_OUTL                  1055
#define ER_EXTENTS_2BIG_4INTS                   1056
#define ER_EXTENTS_2BIG_2PROCS                  1060
/* Returned from fw_make_char */
#define ER_CURVE_DIDNT_CLOSE                    1061
#define ER_CANT_WW_NO_HEIR_DATA                 1062
#define ER_DOCHAR_STACK_OVERFLOW                1063
#define ER_CURVE_DIDNT_CLOSE_AT_ENDCHAR         1064
#define ER_UNDEFINED_REC_TYPE                   1141
/* Returned from add_x_intercept */
#define ER_X_2BIG_4BAND                         1075
#define ER_X_2SMALL_4BAND                       1076
/* Returned from proc_intercepts */
#define ER_UNMATCHED_PAIR_IN_X                  1142
#define ER_UNMATCHED_PAIR_IN_Y                  1143

/* From RULES.C */

/* Returned from setup_trans */                 
#define ER_X_CHE_OVR_TWICE_XCSE0                1127
#define ER_Y_CHE_OVR_TWICE_XCSE1                1128
#define ER_X_CHE_OVR_TWICE_YCSE1                1130
#define ER_Y_CHE_OVR_TWICE_YCSE0                1129
/* Returned from get_pixels */
#define ER_NOT_ALL_ZONES_PROCESSED              1131
#define ER_UNDEFINED_OPERATOR                   1132
#define ER_UNDEFINED_FUNCTION_TYPE              1133
#define ER_DATA_LEFT_ON_STACK_AT_END            1137
/* Returned from get_fpixels */
#define ER_QUEUE_OVERFLOW                       1139
/* Returned from make_path_mask */
#define ER_QUEUE_OVERFLOW_MAKEPATH              1135
/* Returned from make_edge_list */
#define ER_DATA_NOT_IN_CACHE_MAKE_EDGE          1136
/* Returned from make_trans_table */
#define ER_ONLY_ONE_ZONE_FOUND                  1140

/* From GETREC.C */

/* Returned from get_rec16 */
#define ER_UNEXPD_32BIT_VALUE_X                 1065
#define ER_UNEXPD_32BIT_VALUE_Y                 1066
#define ER_SHOULDNT_BE_HERE                     1067
#define ER_2MANY_X_AND_Y_ZONES_SHDR             1068
#define ER_2MANY_X_AND_Y_ZONES_LHDR             1069
#define ER_SHOULDNT_BE_HERE_2                   1070
#define ER_SHOULDNT_BE_HERE_3                   1071
/* Returned from skip_funct */
#define ER_CANT_SKIP_UNDEF_FUNC                 1072 
/* Returned from acc_digits */
#define ER_ILLEGAL_DIGIT                        1073

/* From CFSO_AC */

/* Returned by cft_load */
#define ER_BAD_FONT_FORMAT                      1152
/* Returned by cft_load_header */
#define ER_BAD_FONT_FORMAT_HDR                  1153
/* Returned by cft_write */
#define ER_BAD_FONT_FORMAT_WRITE                1154
/* Returned by read_chk */
#define ER_2FEW_BYTES_READ                      1155
/* Returned by write_chk */
#define ER_2FEW_BYTES_WRITTEN                   1156
/* Returned by format_check */
#define ER_NOT_A_CO                             1157
/* Returned by memory alloc */
#define ER_OUT_OF_MEMORY                        1158
/* Returned by allocmem */
#define ER_ALLOCATION_PROBLEM                   1159
/* Returned by deallocmem */
#define ER_DEALLOCATION_PROBLEM                 1160






