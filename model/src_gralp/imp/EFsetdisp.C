/* ###################   APOGEE COMPILED   ################## */
#include "OMminimum.h"
#include "OMlimits.h"
#include "igrtypedef.h"
#include "ex.h"
#include "EMS.h"
#include "EMSopt.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "EMSdpb.h"
#include "igrdef.h"
#include "dpmacros.h"       
#include "dpdef.h"
#include "dpmacros.h"
# include "EMSlogic.h"      /* EMSokay */


#define DEBUG 0
#if DEBUG
#include <stdio.h>                      /* Needed for print statements */
#endif



#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn COintplane error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    goto wrapup;\
   }\
 }
#endif





/* global variable of flags;
 * 07/06/93 : WBC : Setting the bit DISPLAY_HRZ_EDGES; it is used
 * to control whether horizon edges should be displayed and located
 */
int 
  surface_display_flags = RULE_LINES_ON | 
                          TANGENT_EDGES_ON | GET_GRA_EDGES | DISPLAY_HRZ_EDGES;


void EFset_surface_display(option,turn_on)

int option,
    turn_on;

{
  if(turn_on)
    surface_display_flags |= option;
  else
    surface_display_flags &= ~option;    
  return;
}


int EFget_gra_edges()
{
  return surface_display_flags & GET_GRA_EDGES;
}


int EFold_math_routine()
{
  return surface_display_flags & OLD_MATH_ROUTINE;
}


int EFhorizon_edges_on_off()
{
  return surface_display_flags & HORIZON_EDGES_ON;
}

int EFtangent_edges_on_off()
{
  return surface_display_flags & TANGENT_EDGES_ON;
}


int EFrule_lines_on_off(window_id, window_os)

OM_S_OBJID window_id;
uword      window_os; 

{
struct var_list varlist[2];
IGRint          inq_flags = 0;
IGRlong         num_bytes,
                EMmsg,
                which_error;

  varlist[0].var = GRAGAD_FLAGS;
  varlist[0].var_ptr = (IGRchar *)&inq_flags;
  varlist[0].num_bytes = sizeof(IGRint);
  varlist[0].bytes_returned = &num_bytes;
  varlist[1].var = END_PARAM;

  dp$inq_set_gragad(msg = &EMmsg,
                    inq0_set1 = 0, /* inquire only */
                    osnum = window_os,
                    gragad_objid = window_id,
                    which_error = &which_error,
                    var_list = varlist);
  ERROR(1, EMmsg, "dp$inq_set_gragad");

  /* check status of rule line display for the specified window */
  if(inq_flags & DP_NO_RULE_LINES)
     return( FALSE );
  else return( TRUE );

wrapup:
  return(TRUE);


}

/* if the DISPLAY_HRZ_EDGES bit is set, horizon edges are allowed to be
 * displayed and located
 */

int EFhorizon_edge_display_on_off()
{
  return surface_display_flags & DISPLAY_HRZ_EDGES;
}

