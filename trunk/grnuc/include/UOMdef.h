#ifndef UOMdef_included
#define UOMdef_included 1

  /* Indexes in array of dimension exponents */

#define UOM_K_MASS_DIM   0       /* Mass dimension               */
#define UOM_K_LENG_DIM   1       /* Length dimension             */
#define UOM_K_TIME_DIM   2       /* Time dimension               */
#define UOM_K_ELEC_DIM   3       /* Electrical current dimension */
#define UOM_K_PANG_DIM   4       /* Plane angle dimension        */
#define UOM_K_SANG_DIM   5       /* Solid angle dimension        */
#define UOM_K_TEMP_DIM   6       /* Temperature dimension        */
#define UOM_K_ITEN_DIM   7       /* Luminous intensity dimension */

  /* Maximum size of dimensions array */
#define UOM_K_MAX_DIMS 8

  /* Maximum number of chars in unit readout */
#define UOM_K_MAX_LEN 150

  /* Maximum number of chars in dimension keyword */
#define UOM_K_MAX_KEYWORD 17

  /* Maximum number of chars in unit type */
#define UOM_K_MAX_TYPE 33

  /* Maximum number of default aliases */
#define UOM_K_MAX_DEFS 3

  /* Maximum number of chars in unit alias */
#define UOM_K_MAX_ALIAS 33

  /* mode in which to display */
#define UOM_DECIMAL                     0
#define UOM_FRACTIONAL                  1
#define UOM_SCIENTIFIC                  2
#define UOM_NON_REDUCED_FRACTION        3

  /* type of justification in which to display */
#define UOM_LEFT_JUSTIFY        ((char) 0)
#define UOM_CENTER_JUSTIFY      ((char) 1)
#define UOM_RIGHT_JUSTIFY       ((char) 2)

  /* flags indicating if case conversion is required for display */
#define UOM_DEFAULT_CASE        ((char) 0)
#define UOM_UPPER_CASE          ((char) 1)
#define UOM_LOWER_CASE          ((char) 2)

  /* flags indicating character used for thousands separation */
#define UOM_NONE                ((char) 0)
#define UOM_COMMA               ((char) 1)
#define UOM_PERIOD              ((char) 2)

  /* flags indicating how fractions are display */
#define UOM_ASCII_FRACT                 0
#define UOM_TEXT_FRACT                  1

  /* Flags indicating if scale and shift are unchained */
#define UOM_UC_SCALE 0x4         /* variant scale is unchained */
#define UOM_UC_SHIFT 0x8         /* variant shift is unchained */

  /* Flags state of type/variant in the super */
#define UOM_TS_STORED 0x1        /* type/variant stored in super */
#define UOM_TS_FILED  0x2        /* type/variant filed in os */

#define UOM_K_SUPERNAME  "UOMsuper"
#define UOM_K_SUPERCLASS "UOMsuper"

#endif          /* #ifndef UOMdef_included above */
