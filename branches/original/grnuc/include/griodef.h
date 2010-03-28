#ifndef griodef_include
#   define griodef_include

/*
 *  Symbol definitions for old GRgetevent Unit interface
 */
#define   GRIO_SCALAR       "SCALAR"
#define   GRIO_DISTANCE     "UOM_DISTANCE"
#define   GRIO_ANGLE        "UOM_ANGLE"
#define   GRIO_AREA         "UOM_AREA"

/*
 *  Scale flag values for input filters ( co$getevent, lc$locate, etc. ) 
 *  and for the expression evaluator ( co$expreval ).  NOTE:  the values
 *  of GRIO_X_SCALE, GRIO_Y_SCALE, and GRIO_Z_SCALE are VERY SIGNIFICANT! 
 *  They are used as indices in an array of scales.
 */
#define  GRIO_NO_SCALE              (-1)
#define  GRIO_X_SCALE               (0)
#define  GRIO_Y_SCALE               (1)
#define  GRIO_Z_SCALE               (2)

/*  Positional implied unit index */
#   define   GRIO_PRIMARY           (1)
#   define   GRIO_SECONDARY         (2)
#   define   GRIO_TERTIARY          (3)

#   define   GRIO_BUTTON_EVENT      (1)
#   define   GRIO_VALUE_EVENT       (2)
#   define   GRIO_KEYIN_EVENT       (3)

/*  maximum size of aliases for units and variables */
#   define   GRIO_MAX_ALIAS_SIZE    (24)

/*
 *  variable types - also used as masks for co$get_variable
 */
#   define   GRIO_VAR_FLOAT         (0x0001)
#   define   GRIO_VAR_INT           (0x0002)
#   define   GRIO_VAR_STRING        (0x0004)
#   define   GRIO_VAR_POINT         (0x0008)
#   define   GRIO_ALL_VAR_TYPES     (0xFFFF)

/*  indicates no message index for co$getevent msgnum field */
#   define GRIO_NO_MSG   ( -1 )

    /*
     *  co$getevent return message codes; values are set such that they obey
     *  OM error msg convetions:  Odd numbered codes indicate succecc; Even
     *  numbered codes indicate failure or an error condition; values in the
     *  low order 3 bits have the foollowing interpretation:
     *
     *     Value    Meaning
     *  binary  hex
     *  ----------- -----------------------
     *   000    0,8    warning
     *   001    1,9    success
     *   010    2,A    error
     *   011    3,B    information/success
     *   100    4,C    severe error
     */
#   define CO_e_syntax                   0x12
#   define CO_e_bad_variable_name        0x1A
#   define CO_e_bad_unit_type            0x22
#   define CO_e_bad_variable_type        0x2A
#   define CO_e_no_such_unit_object      0x32
#   define CO_e_data_truncated           0x3A
#   define CO_e_bad_alias_specified      0x42
#   define CO_e_divide_by_zero           0x52

    /*
     * stuff from old ../exec/include/grutildef.h
     */
#   define GR_MAX_SIZE     100
#   define GR_MAX_CHAR     100
#   define GR_UNKNOWN_TYPE 256     /*unknown event type*/
#   define GR_UNWANTED_PT  255     /*unwanted point returned from get_token*/
#   define GR_PT_OUT_MOD   254     /*point outside of module event*/

    /*
     * Subtypes for data point.
     */
#   define GRst_REGULAR                  1
#   define GRst_ANGLE_TO                 2
#   define GRst_ANGLE_FROM               3
#   define GRst_TANGENT_TO               4
#   define GRst_TANGENT_FROM             5
#   define GRst_PERPEND_TO               6
#   define GRst_PERPEND_FROM             7
#   define GRst_CENTER                   8
#   define GRst_INTER                    9
#   define GRst_KEYPOINT                10
#   define GRst_PROJECT                 11
#   define GRst_MIDPOINT                12
#   define GRst_ENDPOINT                13
#   define GRst_LOCATE                  14
#   define GRst_PREC_WLD                15
#   define GRst_DELTA_WLD               16
#   define GRst_DELTA_VIEW              17
#   define GRst_DIST_DIR                18
#   define GRst_AT_SPEC_DIST            19
#   define GRst_AT_DIST_2_PTS           20
#   define GRst_DEFAULT                 21
#   define GRst_PT_ON_RASTER_PREC       22
#   define GRst_PT_ON_RASTER_CENTER     23
#   define GRst_ASSOC_KEYPOINT          24
#   define GRst_MULTI_POINT             25

    /*
     *  hopefully this ( 64 ) is big enough to last until 2.0 
     */
#   define GRst_MAX_VALUE               64

    /*
     * Subtypes for value.
     */
#   define GRst_v_REGULAR                1
#   define GRst_v_NEWEXPR                2
#   define GRst_v_OLDEXPR                3
#   define GRst_v_SYNTAX	         4


    /*
     * Event mask currently recognized by co$getevent 
     */
#   define GRm_COMMAND         0x00000001  /* not used by getevent filter */
#   define GRm_DATA            0x00000002
#   define GRm_RESET           0x00000004
#   define GRm_RJT_MOVEON      0x00000004  /* duplicate */
#   define GRm_STRING          0x00000008
#   define GRm_SCALAR          0x00000010
#   define GRm_DIST            0x00000020  /* used by GRgetevent only */
#   define GRm_ANGLE           0x00000040  /* used by GRgetevent only */
#   define GRm_TEXT_VALUE      0x00000080
#   define GRm_CHAR            0x00000100
#   define GRm_MOVE_ON         0x00000200
#   define GRm_PT_OUT_MOD      0x00000400  /* not used by getevent filter */
#   define GRm_SPECIFIED_OBJ   0x00000800
#   define GRm_OBJID           0x00000800  /* duplicate */
#   define GRm_VALUE           0x00001000  
#   define GRm_RESTART         0x00002000
#   define GRm_BACK_UP         0x00004000
#   define GRm_FORM_FINISHED   0x00008000
#   define GRm_PLNDATA         0x00010000
#   define GRm_STATUS_DISP     0x00020000

#   define MAX_BUF_SIZE         ( 100 )

#   define GRIO_VSD_BUF_SIZE    ( 256 )

    /* return code for GRgetXXXXXX                          */

#   define GRw_ev_trunc            -1
#   define GRw_no_value            -2
#   define GRe_var_undef           -3
#   define GRe_conv                -4
#   define GRe_div_by_0            -5

#   define MAX_TOKEN_SIZE  80

/* defines used by readout */

#define  GRIO_LEFT_JUSTIFY          0
#define  GRIO_CENTER_JUSTIFY        1
#define  GRIO_RIGHT_JUSTIFY         2

#define  GRIO_DECIMAL               0
#define  GRIO_FRACTIONAL            1
#define  GRIO_SCIENTIFIC            2
#define  GRIO_NON_REDUCED_FRACTION  3

#define  GRIO_NONE                  0
#define  GRIO_COMMA                 1
#define  GRIO_PERIOD                2

#define  GRIO_DEFAULT_CASE          0
#define  GRIO_UPPER_CASE            1
#define  GRIO_LOWER_CASE            2

/* error codes returned by grio conversion macros */

#define  GRIO_E_INVALID_OS         2
#define  GRIO_W_ALIAS_TRUNC        3
#define  GRIO_E_BAD_ALIAS          4
#define  GRIO_W_DATA_TRUNC         5


/*
 *  Flag settings for co$update_current_point_form macro
 */
#   define  UPDATE_ONLY_IF_DISPLAYED   0
#   define  UPDATE_UNCONDITIONALLY     1

#define GRIO_ASCII_FRACT 0
#define GRIO_TEXT_FRACT  1

/* data base types returned by gr$unit_database_type() */
#define GRIO_UNITS_ARE_UNKNOWN   (0)
#define GRIO_UNITS_ARE_ENGLISH   (1)
#define GRIO_UNITS_ARE_METRIC    (2)

#endif 
