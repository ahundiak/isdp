/* #######################    APOGEE COMPILED   ######################## */
/*
 * --------------------------------------------------------------------------
 *   ------------------  Functions called by call_func()  -----------------
 * --------------------------------------------------------------------------
 */

#include "grimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "OMDB.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "griodef.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "codef.h"
#include "griomacros.h"
#include "griopriv.h"
#include "igrmacros.h"

IGRlong COexpr_sin( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->value = MAsin( &status, arg );
   result->type  = EXPR_SCALAR;
   return( status );
}

IGRlong COexpr_cos( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->type  = EXPR_SCALAR;
   result->value = MAcos( &status, arg );
   return( status );
}


IGRlong COexpr_tan( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->type  = EXPR_SCALAR;
   result->value = MAsin( &status, arg );
   return( status );
}


IGRlong COexpr_sec( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->type  = EXPR_SCALAR;
   result->value = MAsin( &status, arg );
   return( status );
}


IGRlong COexpr_cosec( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->type  = EXPR_SCALAR;
   result->value = MAsin( &status, arg );
   return( status );
}


IGRlong COexpr_cotan( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->type  = EXPR_SCALAR;
   result->value = MAsin( &status, arg );
   return( status );
}


IGRlong COexpr_log( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->type  = EXPR_SCALAR;
   result->value = MAlog( &status, arg );
   return( status );
}


IGRlong COexpr_sqrt( arg, result)
   IGRdouble                *arg;
   struct COexpr_stacktype  *result;
{
   IGRlong status = MSSUCC;

   result->type  = EXPR_SCALAR;
   result->value = MAsqrt( &status, arg );
   return( status );
}
