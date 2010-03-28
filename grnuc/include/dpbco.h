 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 


#ifndef dpbco_include
#define dpbco_include

/*
 * Instance data structure for COdpb attributes.
 */
struct COdpb_attr {
    struct IGRdisplay           dpb_Display;
    IGRshort                    Level;  
    struct GRdpb_scale          Scale;  
    IGRdouble                   Angle;  
    struct GRdpb_text_symb      TextSymb;
};

/*
 * Attribute types.
 *
 * The first 3 bytes of the of the 4 byte mask used by COdpb methods
 * is reserved for the COdpb class. The high order byte may be
 * used by subclasses of COdpb.
 */
#define CO_scale    1       /* 0x00000001     .... .... .... .... .... .... .... ...1 */
#define CO_xscale   2       /* 0x00000002     .... .... .... .... .... .... .... ..1. */
#define CO_yscale   4       /* 0x00000004     .... .... .... .... .... .... .... .1.. */
#define CO_zscale   8       /* 0x00000008     .... .... .... .... .... .... .... 1... */
#define CO_color    16      /* 0x00000010     .... .... .... .... .... .... ...1 .... */
#define CO_weight   32      /* 0x00000020     .... .... .... .... .... .... ..1. .... */ 
#define CO_style    64      /* 0x00000040     .... .... .... .... .... .... .1.. .... */
#define CO_level    128     /* 0x00000080     .... .... .... .... .... .... 1... .... */
#define CO_angle    256     /* 0x00000100     .... .... .... .... .... ...1 .... .... */
#define CO_font     512     /* 0x00000200     .... .... .... .... .... ..1. .... .... */
#define CO_frac     1024    /* 0x00000400     .... .... .... .... .... .1.. .... .... */
#define CO_symb     2048    /* 0x00000800     .... .... .... .... .... 1... .... .... */
#define CO_ascii    4096    /* 0x00001000     .... .... .... .... ...1 .... .... .... */
#define CO_just     8192    /* 0x00002000     .... .... .... .... ..1. .... .... .... */
#define CO_size     16384   /* 0x00004000     .... .... .... .... .1.. .... .... .... */
#define CO_height   32768   /* 0x00008000     .... .... .... .... 1... .... .... .... */
#define CO_width    65536   /* 0x00010000     .... .... .... ...1 .... .... .... .... */
#define CO_charsp   131072  /* 0x00020000     .... .... .... ..1. .... .... .... .... */
#define CO_linesp   262144  /* 0x00040000     .... .... .... .1.. .... .... .... .... */
/* RESERVED         524288     0x00080000     .... .... .... 1... .... .... .... .... */
/* RESERVED         1048576    0x00100000     .... .... ...1 .... .... .... .... .... */
/* RESERVED         2097152    0x00200000     .... .... ..1. .... .... .... .... .... */

/*
 * Valid structure types. Used with the COdpb get and put methods.
 */
#define CO_default          0   /* default dpb type */
#define CO_double           1   /* IGRdouble */
#define CO_integer          2   /* IGRint */
#define CO_scale_struct     3   /* struct GRdpb_scale * */
#define CO_disp_struct      4   /* struct GRdisplay * */
#define CO_text_struct      5   /* struct GRdpb_text_symb * */
#define CO_string           6   /* IGRchar * */
#define CO_message          7   /* IGRchar * - this is a status display message */

/*
 * PRIV: These are NOT attribute types!!!
 */
#define CO_scales   (CO_scale | CO_xscale | CO_yscale | CO_zscale) 
#define CO_disp     (CO_color | CO_weight | CO_style) 
#define CO_sym      (CO_disp | CO_level) 
#define CO_vg       (CO_scales | CO_sym | CO_angle) 
#define CO_text     (CO_font | CO_frac | CO_symb | CO_ascii | CO_just | CO_size | CO_height | CO_width | CO_charsp | CO_linesp)
#define CO_everything (CO_vg | CO_text)

/*
 * PRIV: High and low values for dpb params.
 */
#define CO_lo_color         0
#define CO_hi_color         511
#define CO_lo_weight        0
#define CO_hi_weight        31
#define CO_lo_style         0
#define CO_hi_style         7
#define CO_lo_layer         0
#define CO_hi_layer         1023
#define CO_lo_scale         0
#define CO_lo_just          0
#define CO_hi_just          14

/*
 * PRIV: Operations for the library functions.
 */
#define CO_attr_to_name     0
#define CO_name_to_attr     1

/*
 * PRIV: Error messages
 */
#define CO_E_INVINP         50505050

#endif
