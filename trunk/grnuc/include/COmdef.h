#ifndef COmdef
#define COmdef
/* Include file for macro definition command object */


/* Possible scrolling mode for parent location */

enum ACm_poss_scroll
 {
  FULL_SCROLL,
  GEOM_SCROLL,
  NUM_SCROLL
 };

/* Possible types of header to be placed */

enum ACm_poss_hdr
 {
  HDR_CONS,
  HDR_DROP,
  HDR_SYMB,
  HDR_GRAPHIC
 };


/* Possible types of macro definition */

enum poss_macro
 {
  mac_exp,
  mac_sym,
  mac_ci,
  mac_not_def,
  mac_cant_change
 };


/* Possible options for symbology  */

#define CHG_LAYER  0x01
#define CHG_COLOR  0x02
#define CHG_WEIGHT 0x04
#define CHG_STYLE  0x08

/* The bits 0x10, 0x20 			  are reserved for scroll option */
/* The bits 0x40, 0x40  0x100 0x200 0x400 are reserved for header option */

#define INCR_LAYER 0x1000

#define CHG_DONT_MVRT 0x2000
#define CHG_DEL_NO_CH 0x4000

/* Possible option for default parameter */

enum ACm_poss_def_par
 {
  IN_MACRO_LIB,
  NO_OPTION, 
  USER_SPECIFIED
 };

/* default parameter for macro placement */

   
struct ACdef_param
 {
  int 		       symb;
  enum ACm_poss_scroll hdr_scroll;
  enum ACm_poss_hdr    hdr_type;
  enum ACm_poss_def_par hdr_def;
  char 		       search_path[DI_PATH_MAX];
  char		       post_placement[DI_PATH_MAX];
 };

/*
  max and min layer available when active + definition layer
*/

#define LO_LAYER 0
#define HI_LAYER 1023

#endif
