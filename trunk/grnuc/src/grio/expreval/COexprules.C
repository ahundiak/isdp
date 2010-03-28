/* #######################    APOGEE COMPILED   ######################## */

/*
 * --------------------------------------------------------------------------
 *    ---------------------- Synantics Rules Checker ---------------------
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

#define NBR_OF_FUNCS           ( 8 )
#define MAX_FUNC_LEN           ( 4 ) /* includes terminating NULL */
#define NUMBER_OF_TYPES        ( 3 )

extern IGRlong     COexpr_sin();
extern IGRlong     COexpr_cos();
extern IGRlong     COexpr_tan();
extern IGRlong     COexpr_sec();
extern IGRlong     COexpr_cosec();
extern IGRlong     COexpr_cotan();
extern IGRlong     COexpr_log();
extern IGRlong     COexpr_sqrt();

extern struct COpriv_expr_info COexpr_info;         /* global info structure */


/*
 *  See griopriv.h for mask definitions.
 */
static IGRchar OpMasks [ NUMBER_OF_TYPES ] [ NUMBER_OF_TYPES ] =
{
/*                SCALAR       IMPLICIT      EXPLICIT 
                __________    __________    __________          */

/* SCALAR   */ {  SCL_SCL  ,   SCL_IMP   ,   SCL_EXP   },

/* IMPLICIT */ {  IMP_SCL  ,   IMP_IMP   ,   IMP_EXP   },

/* EXPLICIT */ {  EXP_SCL  ,   EXP_IMP   ,   EXP_EXP   },

};

static IGRchar  NewTypes [ NUMBER_OF_TYPES ] [ NUMBER_OF_TYPES ] =
{
/*                   SCALAR          IMPLICIT         EXPLICIT 
                 ______________   _______________  ______________     */

/* SCALAR   */ {  EXPR_SCALAR   ,  EXPR_EXPLICIT ,  EXPR_EXPLICIT  },

/* IMPLICIT */ {  EXPR_EXPLICIT ,  EXPR_EXPLICIT ,  EXPR_EXPLICIT  },

/* EXPLICIT */ {  EXPR_EXPLICIT ,  EXPR_EXPLICIT ,  EXPR_EXPLICIT  },

};

IGRlong perform_op( op, val1, val2, result )

   IGRchar     op;
   IGRdouble  *val1, 
              *val2,
             *result;
{
   IGRlong  status = MSSUCC;

   switch ( ( IGRint ) op )
   {
      case  PLUS:
                    *result = *val1 + *val2;
                    break;

      case  MINUS:
                    *result = *val1 - *val2;
                    break;

      case  MUL:
                    *result = *val1 * *val2;
                    break;

      case  DIV:
                    if ( *val2 != 0.0 )
                    {
                       *result = *val1 / *val2;
                    }
                    else
                    {
                       *result = 0.0;
                       status = CO_e_divide_by_zero;
                    }
                    break;

      case  POW:
                    *result = MApower( &status, val1, val2 );
                    break;

      default:
                    *result = 0.0;
                    status = CO_e_syntax;
   }

   return status;

}

IGRboolean rule_check( op, type1, type2, new_type )

   IGRchar                  op;
   enum COexpr_value_type   type1, 
                            type2, 
                           *new_type;
{ 
   IGRboolean  b_status = FALSE;
   IGRchar     op_mask;

   op_mask = OpMasks [ type1 ] [ type2 ];

   if ( op & op_mask )
   {
      b_status = TRUE;
      *new_type = (enum COexpr_value_type)NewTypes[ type1 ] [ type2 ];
   }

   return b_status;
}


/*
 * --------------------------------------------------------------------------
 *    ------------------------ Function Analyzer -------------------------
 * --------------------------------------------------------------------------
 */

static COexpr_p_FUNCPTR COexpr_functions[] = 
{
    COexpr_sin   ,         /*  0   */
    COexpr_cos   ,         /*  1   */
    COexpr_tan   ,         /*  2   */
    COexpr_sec   ,         /*  3   */
    COexpr_cosec ,         /*  4   */
    COexpr_cotan ,         /*  5   */
    COexpr_log   ,         /*  6   */
    COexpr_sqrt  ,         /*  7   */
};

static IGRchar COexpr_func_names[NBR_OF_FUNCS][MAX_FUNC_LEN] = 
{
  "sin",       /*  0   */
  "cos",       /*  1   */
  "tan",       /*  2   */
  "sec",       /*  3   */
  "csc",       /*  4   */
  "cot",       /*  5   */
  "log",       /*  6   */
  "sqr",       /*  7   */
};

IGRboolean get_func_index_from_name( func_name, index )
   IGRchar *func_name;
   IGRint  *index;
{
   *index = 0;
   while( *index < NBR_OF_FUNCS )
   {
     if (strncmp(func_name,COexpr_func_names[*index],MAX_FUNC_LEN)) return TRUE;
     (*index)++ ;
   }

   /*  *index = -1; */

   return FALSE;
}

IGRboolean call_func( status, fun, arg, result )
   IGRlong                  *status;
   IGRchar                  *fun;
   struct COexpr_stacktype  *arg,
                            *result;
{
   IGRint     index;
   IGRboolean b_status = FALSE;

   /*
    * is unit type compatible with result type of this function
    */
   if ( b_status = get_func_index_from_name( fun, &index ) )
   {
      *status = COexpr_functions[ index ] ( &arg->value, result );
   }
   else *status = MSINARG;

   return b_status;
}

/*
 *  Numeric evaluation of Implicit Unit and Scalar expresions depends upon:
 *     1) whether the value wanted is scalar or a unit
 *     2) operator involved
 *     3) syntactic types of the two arguments
 *     4) order of the arguments ( for MUL, DIV, and POW )
 */ 

IGRlong evaluate_expr( op,
                       scalar,
                       arg1,
                       arg2,
                       result )
                    
   IGRchar                   op;
   IGRboolean                scalar;
   struct COexpr_stacktype  *arg1,
                            *arg2,
                            *result;

{
   /*
    * Action mask bits:
    */
   IGRlong status = MSSUCC;

   if ( ! scalar )
   {
      enum { ACT_no_cvt  = 0,
             ACT_cvt_1   = 1,
             ACT_cvt_2   = 2  } action = ACT_no_cvt;

      /* 
       *  Determine which ( if any ) of the args has to be converted into
       *  working units before the operation is performed; if a conversion
       *  is made to working units, then the result type is modified to
       *  EXPR_EXPLICIT ( this may seem strange since the unit was actually
       *  converted as an IMPLICIT value; however, it BEHAVES as an EXPLICIT
       *  as far as the semantic rules are concerned.
       *
       *  SRH  07/26/88 - only ONE or NONE of the args will need converting
       */
      switch ( ( IGRint ) op )
      {
         case  PLUS:
         case  MINUS:
                       if ( arg1->type == EXPR_SCALAR
                         && arg2->type != EXPR_SCALAR )
                       {
                         action |= ACT_cvt_1;
                       }
                       else if ( arg1->type != EXPR_SCALAR
                              && arg2->type == EXPR_SCALAR )
                       {
                         action |= ACT_cvt_2;
                       }
                       break;

         case  MUL:    /* no conversion for multiplication or division */
         case  DIV:
		       break;
         default:
                       break;
      }



      {
         /*
          * IF   both arguments need to be converted to working units
          * THEN 
          *      the operation is performed BEFORE the conversion to working 
          *      units
          * ELSE
          *      any conversion of arguments to working units precedes the 
          *      operation
	  */
         IGRlong    msg;
         IGRdouble  val1, val2, ret_val;

         /*
          *  initialize in case not converted before operation
          */
         val1 = arg1->value;
         val2 = arg2->value;


	 /*
	  * There are two (2) passes :  
          *
	  *  Pass #1:  If neither or both arguments need to be converted 
	  *            to working units, then we perform the operation on
	  *            them in this pass.  If only one of the argumetns 
	  *            needs to be converted then we convert that one 
	  *            argument in this pass.
	  */
         switch ( action )
         {
            case ( ACT_no_cvt ) :

               status = perform_op(  op,
                                    &val1,
                                    &val2,
                                    &ret_val);
               break;


            case ( ACT_cvt_1 ) : 

	       status = co$cvt_imp_to_wrk( msg       = &msg, 
                                           osnum     =  COexpr_info.osnum,
                                           unit_type =  COexpr_info.p_unit_type,
                                           primary   =  arg1->value,
                                           result    = &val1 );

               _m_check2p(status,msg,"COparse: co$cvt_imp_to_wrk FAILED:");

               if (! (status & msg & 1 ) )
               {
                  status = CO_e_bad_alias_specified;
               }

               break;


            case ( ACT_cvt_2 ) :
	       status = co$cvt_imp_to_wrk( msg       = &msg, 
                                           osnum     =  COexpr_info.osnum,
                                           unit_type =  COexpr_info.p_unit_type,
                                           primary   =  arg2->value,
                                           result    = &val2 );

               _m_check2p(status,msg,"COparse: co$cvt_imp_to_wrk FAILED:");

               if (! (status & msg & 1 ) )
               {
                  status = CO_e_bad_alias_specified;
               }

               break;

            default:
              break;
         }


         /*
	  *  Pass #2:  If neither of the arguments needed to be converted,
	  *            then the result is already calculated and stored in
	  *            <ret_val>.  
	  *
	  *            If both arguments needed to be converted, then we 
	  *            perform the conversion of the result of the 
	  *            operation calculated in Pass #1.  
	  *
	  *            If only one of the arguments needed to be converted,
	  *            then we perform the operation on the result of the 
	  *            convertion ( from Pass #1 ) and the unconverted 
	  *            argument.
	  */
         if ( status & 1 )  switch ( action )
         {

            case ( ACT_no_cvt ) :
	       result->value = ret_val;
	       break;

            case ( ACT_cvt_1 ) :
            case ( ACT_cvt_2 ) :
	       /* one of the values is converted, the other is not */
               status = perform_op(  op,
                                    &val1,
                                    &val2,
                                    &result->value );

               break;


            default :
               break;

         }

      }

      /*
       * this statement takes care of all exceptions to the rule_check() 
       * program logic.  If we had to convert any of the values, then we
       * have a result that behaves semantically as an explicit value.
       */
      if ( action ) 
	 result->type = EXPR_EXPLICIT;

   }
   else if ( arg1->type == EXPR_SCALAR && arg2->type == EXPR_SCALAR )
   {
      /* simple scalar evaluation */
      status = perform_op(  op,
                           &arg1->value,
                           &arg2->value,
                           &result->value );

   }
   else 
   {
      /*
       * The value wanted is scalar but one or both of the arguments
       * are not scalar values; thus we have a semantic error.
       */
      status = CO_e_syntax;
   }

   return status;
}
