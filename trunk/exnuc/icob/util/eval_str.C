#include "exsysdep.h"

#define _verybose(x)

static long eval_cond();

/* --------------------- */
static long eval_primary ( str )
  char	** str;
{
  long	   val;
  

  while ( isspace ( ** str )) ++ * str;
  if ( ** str == '(' )
    {
      ++ * str;
      val = eval_cond ( str );
      if ( ** str == ')' ) ++ * str;
    }
  else
    {
#ifdef CLIX
	/************************************************************/
	/*** If it's a hex constant, use "strtoul" because	  ***/
	/*** "strtol" doesn't work with hex numbers as of CSS 6.0 ***/
	/******************************************* JAJ:02/04/92 ***/
      if ( ( ! strncmp ( "0x", * str, 2 ) )	||
           ( ! strncmp ( "0X", * str, 2 ) )	 )
	{
          val = (long) strtoul ( * str, str, 0 );
	}
      else
	{
	  val = (long) strtol ( * str, str, 0 );
	}
#elif defined(SUNOS4)
        val = (long) strtol ( * str, str, 0 );
#elif defined(IRIX) || defined (SUNOS5)
        val = strtoul ( * str, str, 0 );
#elif defined(NT)
        val = (long) strtol ( * str, str, 0 );
#else
#error Unknown OS
#endif
    }

  while ( isspace ( ** str )) ++ * str;

  _verybose(fprintf(stderr,"primary %ld  %s\n",val,*str);)

  return val;

} /* eval_primary */

/* --------------------- */
static long eval_unary ( str )
  char	** str;
{
  long     val;
  char	   op;

  while ( isspace ( ** str )) ++ * str;
  if ( ** str == '+' || ** str == '-' || ** str == '!' ) op = * ( * str ) ++ ;
  else op = 0;
  val = eval_primary ( str );
  _verybose(fprintf(stderr,"unary %ld  %s\n",val,*str);)
  if ( op == '-' ) return - val;
  else if ( op == '!' ) return ! val;
  return val;
} /* eval_unary */

/* --------------------- */
static long eval_mul ( str )
  char	** str;
{
  long     val;
  char	   op;

  val = eval_unary ( str );
  while ( ** str == '*' || ** str == '/' || ** str == '%' )
    {
      op = * ( * str ) ++ ;
      if ( op == '*' ) val *= eval_unary ( str );
      else if ( op == '/' ) val /= eval_unary ( str );
      else val %= eval_unary ( str );
    }
  _verybose(fprintf(stderr,"mul %ld  %s\n",val,*str);)
  return val;
} /* eval_mul */

/* --------------------- */
static long eval_add ( str )
  char	** str;
{
  long     val;
  char	   op;

  val = eval_mul ( str );
  while ( ** str == '+' || ** str == '-' )
    {
      op = * ( * str ) ++ ;
      if ( op == '+' ) val += eval_mul ( str );
      else val -= eval_mul ( str );
    }
  _verybose(fprintf(stderr,"add %ld  %s\n",val,*str);)
  return val;
} /* eval_add */

/* --------------------- */
static long eval_shift ( str )
  char	** str;
{
  long     val;
  char	   op;

  val = eval_add ( str );
  while ( ! strncmp ( * str, "<<", 2 ) || ! strncmp ( * str, ">>", 2 ))
    {
      op = * ( * str ) ++ ;
      ++ * str;
      if ( op == '<' ) val <<= eval_add ( str );
      else val >>= eval_add ( str );
    }
  _verybose(fprintf(stderr,"shift %ld  %s\n",val,*str);)
  return val;
} /* eval_shift */

/* --------------------- */
static long eval_ineq ( str )
  char	** str;
{
  long     val;
  long     val2;
  char	   op;
  char	   op2;

  val = eval_shift ( str );
  while ( ** str == '<' || ** str == '>' )
    {
      op = * ( * str ) ++ ;
      if ( ** str == '=' ) op2 = * ( * str ) ++;
      else op2 = 0;
      val2 = eval_shift ( str );
      if ( op2 )
        if ( op == '<' ) val = val < val2;
        else val = val > val2;
      else
        if ( op == '<' ) val = val <= val2;
        else val = val >= val2;
    }
  _verybose(fprintf(stderr,"ineq %ld  %s\n",val,*str);)
  return val;
} /* eval_ineq */

/* --------------------- */
static long eval_eq ( str )
  char	** str;
{
  long     val;
  char	   op;

  val = eval_ineq ( str );
  while ( ! strncmp ( * str, "==", 2 ) || ! strncmp ( * str, "!=", 2 ))
    {
      op = * ( * str ) ++ ;
      ++ * str;
      if ( op == '=' ) val = val == eval_ineq ( str );
      else val = val != eval_ineq ( str );
    }
  _verybose(fprintf(stderr,"eq %ld  %s\n",val,*str);)
  return val;
} /* eval_eq */

/* --------------------- */
static long eval_bit_and ( str )
  char	** str;
{
  long     val;

  val = eval_eq ( str );
  while ( ** str == '&' )
    {
      ++ * str;
      if ( ** str == '&' )
        {
          -- * str;
          break;
        }
      val &= eval_eq ( str );
    }
  _verybose(fprintf(stderr,"bit & %ld  %s\n",val,*str);)
  return val;
} /* eval_bit_and */

/* --------------------- */
static long eval_bit_xor ( str )
  char	** str;
{
  long     val;

  val = eval_bit_and ( str );
  while ( ** str == '^' )
    {
      ++ * str;
      val ^= eval_bit_and ( str );
    }
  _verybose(fprintf(stderr,"bit ^ %ld  %s\n",val,*str);)
  return val;
} /* eval_bit_xor */

/* --------------------- */
static long eval_bit_or ( str )
  char	** str;
{
  long     val;

  val = eval_bit_xor ( str );
  while ( ** str == '|' )
    {
      ++ * str;
      if ( ** str == '|' )
        {
          -- * str;
          break;
        }
      val |= eval_bit_xor ( str );
    }
  _verybose(fprintf(stderr,"bit | %ld  %s\n",val,*str);)
  return val;
} /* eval_bit_or */

/* --------------------- */
static long eval_boole_and ( str )
  char	** str;
{
  long     val;

  val = eval_bit_or ( str );
  while ( ! strncmp ( * str, "&&", 2 ))
    {
      ++ * str;
      ++ * str;
      val = val && eval_bit_or ( str );
    }
  _verybose(fprintf(stderr,"boole & %ld  %s\n",val,*str);)
  return val;
} /* eval_boole_and */

/* --------------------- */
static long eval_boole_or ( str )
  char	** str;
{
  long     val;

  val = eval_boole_and ( str );
  while ( ! strncmp ( * str, "||", 2 ))
    {
      ++ * str;
      ++ * str;
      val = val || eval_boole_and ( str );
    }
  _verybose(fprintf(stderr,"boole | %ld  %s\n",val,*str);)
  return val;
} /* eval_boole_or */

/* --------------------- */
static long eval_cond ( str )
  char	** str;
{
  long	   lval;
  long	   mval;
  long	   rval = 0;

  while ( isspace ( ** str )) ++ * str;
  lval = eval_boole_or ( str );
  if ( ** str == '?' )
    {
      ++ * str;
      mval = eval_cond ( str );
      if ( ** str == ':' )
        {
          ++ * str;
          rval = eval_cond ( str );
        }
      /* ignore error */
    _verybose(fprintf(stderr,"cond %ld ? %ld : %ld  %s\n",lval,mval,rval,*str);)
      return lval ? mval : rval;
    }
  _verybose(fprintf(stderr,"cond %ld  %s\n",lval,*str);)
  return lval;
} /* eval_cond */

long eval_str ( str )
  char	* str;
{
  char	* strp;

  strp = str;
  return eval_cond ( & strp );
} /* eval_str */

#undef _verybose
