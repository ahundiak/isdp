#ifndef EXWL_INCLUDE
#define EXWL_INCLUDE 1

#include "OMminimum.h"

/*================================================*/
/*  This file if for WL specific stuff for EXNUC  */
/*================================================*/

/*===========================================*/
/*  Window Data Struct for EXNUC WL windows  */
/*===========================================*/

struct EX_sd_windata {
   OMuword     id;
   OMuword     win_os;
   OM_S_OBJID  win_oid;
};

typedef struct EX_sd_windata EXwindata;

/*================================*/
/*  Defines for windata ID field  */
/*================================*/

#define EX_GRAPHIC_WINDOW      456          /* some unique value    */
#define EX_DIGITIZER_WINDOW    457          /* another unique value */

#endif
