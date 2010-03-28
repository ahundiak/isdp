/* #######################    APOGEE COMPILED   ######################## */

#include   "codebug.h"
#include   "igrtypedef.h"
#include   "OMminimum.h"
#include   "OMDB.h"
#include   "igetypedef.h"
#include   "OMlimits.h"
#include   "igr.h"
#include   "gr.h"
#include   "exdef.h"
#include   "ex.h"
#include   "igrdp.h"
#include   "godef.h"
#include   "go.h"
#include   "griodef.h"
#include   "grio.h"
#include   "grdpbdef.h"

/* Grid of the "Current Point" Form */
/* struct GRid  CurrentPointFormGrid = { 0, -1 }; */
 
IGRboolean   DPdynamic_update_in_progress = FALSE;
IGRboolean   dynamics_in_progress = FALSE;

/* declare the global structure for expression evaluator; for communication   */
/* between co$expreval and the yacc parser COparse()                          */
struct COpriv_expr_info
{
   IGRlong    msg;              /* return code for expression evaluation */
   IGRdouble  result;           /* result of expression evaluation       */
   IGRchar   *p_expr;           /* points to first char in expression    */
   IGRchar   *p_current_char;   /* points to current input char (lex)    */
   IGRchar   *p_unit_type;      /* type of unit being evaluated          */
   OMuword    osnum;            /* OS where unit conversions occurs      */
} COexpr_info = { 0 };


IGRchar COexpr_ident[26] = { 0 };       /* allocate global char buffer for  *
                                         * storing explicit unit identifier */
short  COInvisibleColor = 0;

IGRchar GRdpad[512] = {0};
