#ifndef ci_setmd_include
#define ci_setmd_include

#include "cieveryone.h"
#include "OMminimum.h"
#include "cimacros.h"
#include "cimath.h"
#include "dpmacros.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EMSstruct.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "growner.h"
#include "acdef.h"
#include "acmacros.h"
#include "macro.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "emsdattyp.h"

#define SUCCESS         134250505
#define SOL_SUC         2654217
#define EXP_SCALAR      0
#define EXP_DISTANCE    1
#define EXP_ANGLE       2

#ifndef ci_easy_include
IGRlong                 rtcd, loop_inc;
struct GRid             dspGRid,TEMP_GRID, TEMP_GRID_NEW,
                        TEMP_GRID1,TEMP_GRIDS[100];
struct GRmd_env         MOD_ENV,ALT_ENV;
struct GRsymbology	symb;
struct GRsymbology      sym;
IGRshort                set_properties1,properties1;
IGRshort                props;
struct IGRdisplay       dis;
struct GRvg_construct   cst;
double                  *Dbl9,*Dbl6,*Dbls;
double                  double100[100],double6[6];
#endif

                
extern          GRgs_fun(), 
                DPerase_hilite(),
                GRgsmgr_fun();

extern double   BSdotp();

extern void     BScrossp(),
                BSnorvec();

extern int      GRcvt_imp_to_wrk(),
                GRget_default_units(),
                GRfindmod(),
                init_cnst_list(),
                DIuntranslate(),
                DIreport_error(),
                DIfetch_untrans(),
                DImain(),
                DIfast_trans(),
                DIadd_index(),
                DIsplit(),
                EXP_translate_exp(),
                EXP_create(),
                EMdpb_get();

extern  char    *malloc();
extern  int     free();
extern          sprintf();

extern  char    ASbroadcast_in_progress,
                *strchr(),
                *strrchr(),
                *strncpy();
extern int      strncmp();

/*******
        THESE ARE THE SUPPORTING FUNCTIONS FOR EACH OF THE ABOVE
        MACROS. THESE ARE SUBJECT TO CHANGE.  DO NOT USE THEM!
*******/

#define set_up_easy()  set_up_cnst();

#ifndef ci_easy_include

#define set_up_cnst()\
   ci$get_module_info(md_env=&MOD_ENV);\
   init_cnst_list();\
   get_symb();\
   dis.color      = cnst_list.color;\
   dis.weight     = cnst_list.weight;\
   dis.style      = cnst_list.style;\
   cst.msg        = &rtcd;\
   cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;\
   cst.display    = &dis;\
   cst.env_info   = &MOD_ENV;\
   cst.newflag    = 0;\
   cst.level      = cnst_list.level;\
   cst.geometry   = 0;\
   cst.class_attr = 0;\
   cst.name       = 0;\
   GRfindmod(&dspGRid);

#endif

/****************************************************************/
/*                                                              */
/*define THIS SECTION DEALS WITH THE DISPLAYING OF AN OBJECT    */
/* THE FOLLOWING defines ARE THE DIFFERENT OPTIONS FOR THE      */
/* "display_w_opt()" FUNCTION                                   */
/*                                                              */
/****************************************************************/

#define DRAW                    GRbd    // 0 DRAW THE OBJECT
#define ERASE                   GRbe    // 1 ERASE THE OBJECT
#define HILITE                  GRhd    // 2 HIGHLITE THE OBJECT
#define ERASEHILITE             GRhe    // 3 ERASE HIGHLITE THE OBJECT
#define DRAW_HILITE             GRbdhd  // 4 DRAW AND HIGHLITE THE OBJECT
#define ERASE_ERASEHILITE       GRbehe  // 5 ERASE AND UNHIGHLITE THE OBJECT
#define DRAW_ERASEHILITE        GRbdhe  // 6 DRAW AND UNHIGHLITE THE OBJECT
#define ERASE_HILITE            GRbehd  // 7 ERASE AND HIGHLITE THE OBJECT
#define HALFHILITE              GRhhd   // 8 HALF HILITE THE OBJECT
#define HILITE_OVER             GRhdo   // 9 HILITE ANY OBJECT DISPLAYABLE OR NOT
#define HALFHILITE_OVER         GRhhdo  // 10 HALF HILITE SAME AS HILITE_OVER
#define ERASEHILITE_OVER        GRheo   // 11 ERASE HILITE_OVER
#define DRAW_ERASEHILITE_OVER   GRbdheo // 12 DRAW AND UNHILITE ANY OBJECT
#define ERASE_ERASEHILITE_OVER  GRbeheo // 13 ERASE AND UNHILITE ANY OBJECT
#define NODISPLAY               14      // 14 DON'T DO ANY DISPLAY WITH THE OBJECT

// DISPLAY AN OBJECT
int     display;

/* this function you must supply the display value 0-13 or one of the above */
/* defined display functions                                                */

#define display_w_opt(object,disp)\
\
   set_up_easy();\
\
   display = (disp);\
   if( display >= DRAW && display <= ERASE_ERASEHILITE_OVER)\
   {\
   ci$send(msg = message GRgraphics.GRdisplay(\
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                &display,\
                &dspGRid),\
                targetid = (object).objid,\
                targetos = (object).osnum);\
   }

#define display_object(object)\
   display_w_opt(object,DRAW);


/********************************************************************/
/*                                                                  */
/*define  THESE FUNCTIONS ARE FOR MANIPULATION OF OBJECTS           */
/*                                                                  */
/********************************************************************/


// PUT A NAME ON AN OBJECT WITH A CHECK AND AN INCREMENTER
char    object_name[132];
int     counter,counter1;

#define put_name(name,object)\
  rtcd = -1;\
  counter=0;\
  strcpy(object_name,(name));\
  while( rtcd != SUCCESS && counter < 500)\
  {\
    ci$send(msg = message GRvg.GRputname(\
                &rtcd,\
                object_name),\
                targetid = (object).objid,\
                targetos = (object).osnum);\
    counter=counter+1;\
    strcpy(object_name,(name));\
    strcat(object_name,itoa(counter));\
  }\
  strcpy(name,object_name);

#define name_display(object,name,disp)\
          if( strcmp((name),"0") != 0 )\
          {\
            put_name((name), (object));\
          }\
          if((disp) != 1)\
          {\
             display_w_opt((object), (disp));\
          }

#endif


