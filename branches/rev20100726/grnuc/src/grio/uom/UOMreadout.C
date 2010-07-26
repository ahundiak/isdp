/*

Name
  UOMreadout.C

Description
  Various functions used to format values using specified readout 
  specifications.

Notes
  Shelley Heard : 06/02/93 : header added and bug fix from 2.2 release
			     added.  It was an oversight that it was not
			     done earlier.

 */
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <ctype.h>

#include "OMtypes.h"
#include "OMerrordef.h"
#include "UOMdef.h"
#include "UOM.h"
#include "msdef.h"

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static void add_alias __((int outbfsz, char *outbf, char *alias,
                          UOM_READOUT *readout));
static int process_decimal __((int outbfsz, char *outbf,
                               UOMalias_name alias, 
                               double *value, UOM_READOUT *readout, 
                               char *tmp, OM_p_FUNCPTR conv_func));
static int process_fraction __((int outbfsz, char *outbf,
                                UOMalias_name alias, 
                                double *value, UOM_READOUT *readout, 
                                char *tmp, short *fraction_mode));

#if defined(__cplusplus)
}
#endif
#undef __



#define MAX_PRECISION 16
#define ACCURACY 10000000000000000.0 
#define _small  ( 1.0e-12 )
#define _large  ( 1.0e12 )

/******************************************************************************/

int UOM_gcd( n, d )
int n;
int d;
{

/*
 *  greatest common denonimator function
 */

  if ( n == 0 )
    return 1;
  if ( ( d <= n ) && ((n % d) == 0 ) )
    return d;
  if ( n < d )
    return UOM_gcd( d, n );
  return UOM_gcd( d, n % d );
}

int UOM_strprepend( str1, str2 )
char *str1;
char *str2;
{
  short size_str1 = 0;
  short size_str2 = 0;
  int total_size;
  short ii;
  char *pt1;
  char *pt2;

  pt1 = str1;
  pt2 = str2;   
   
  while ( *pt1++ )
    size_str1++;
  while ( *pt2++ )
    size_str2++;
   
  total_size = size_str1 + size_str2;
   
  for ( ii = 0; (ii < size_str2); ii++ )
    str2[ total_size - ii - 1 ] = str2[ size_str2 - ii - 1 ];
    
  for ( ii = 0; (ii < size_str1); ii++ )
    str2[ ii ] = str1[ ii ];

  str2[ total_size ] = 0;

  return total_size;
}

int UOM_float_to_sci( d, readout, out_buf )
double d;
UOM_READOUT *readout;
char *out_buf;
{
  char *ch, fmt[12], delimeter_list[3];
  int int_val, precision;

  delimeter_list[0]=' ';
  delimeter_list[1]=',';
  delimeter_list[2]='.';

  int_val = 1;
  precision = MAX_PRECISION - 1;

  if ( readout->precision < MAX_PRECISION ) {
    int_val = MAX_PRECISION - readout->precision;
    precision = readout->precision;
  }

  sprintf( fmt, "%c%c%d%c%d%c", '%', '-', int_val, '.', precision, 'e' );
  sprintf( out_buf, fmt, d );  

  for ( ch = out_buf; ( (*ch != ' ') && (*ch != 0) ); )
    ch++;
  if ( *ch == ' ' )
    *ch = 0;
/*
 *  add correct decimal delimeter
 */
  for ( ch = out_buf; ( (*ch != '.') && (*ch != 0) ); )
    ch++;
  if ( *ch == '.' )
    *ch = delimeter_list[ readout->decimal_char ];

  return 1;
}

/******************************************************************************/

int UOM_float_to_frac( reduce_flag, value, denominator, string )
short reduce_flag;
double value;
short denominator;
char *string;
{
  double int_value, float_value, temp;
  int numerator, integer;

  temp = fabs( value );  /* temp is the non-negative value */

  float_value = (double) modf( temp, &int_value );
  numerator = (int) (ACCURACY * float_value / ( ACCURACY / denominator ) + .5);

  if ( numerator == denominator ) {
    int_value++;
    numerator = 0;
  }
  else if ( reduce_flag ) {
    int gcd;

    gcd = UOM_gcd( numerator, denominator );
    numerator /= gcd;
    denominator /= gcd;
  }

  integer = (int) int_value;

  if ( numerator > 0 ) {
    if ( integer > 0 )
      sprintf( string, "%d %d/%d", integer, numerator, denominator );
    else
      sprintf( string, "%d/%d", numerator, denominator );
  }
  else
    sprintf( string, "%d", integer );

  if ( value < 0.0 )
    UOM_strprepend( "-", string );

  return 1;
}

/******************************************************************************/

int UOM_float_to_ascii( d, readout, out_buf )
double d;
UOM_READOUT *readout;
char *out_buf;
{
  char type;
  char *ascii_ptr;
  char *end_ptr;
  char *dec_ptr;
  char *tmp_ptr;
  short num_digits = 0;
  short num_fill_chars;
  char fmt[12];
  char delimeter_list[3];
  short char_ct;
  
  delimeter_list[0]=' ';
  delimeter_list[1]=',';
  delimeter_list[2]='.';

/*
 *  Range checking for floating point numbers.  we are trying to
 *  convert these numbers to decimal format, but cannot handle
 *  very large or very small numbers:
 * 
 *  How do we determine if a number can be expressed accurately in
 *  decimal format?
 * 
 *  For verion 1.3.0:  we choose arbitrary but reasonable ranges for
 *  displaying decimal format floating point values.  Scientific 
 *  notation ("%g") is used when the floating point number (F) if:
 * 
 *   +1.0e-12 > F > -1.0E-12   or
 *   F > +1.0e+12              or
 *   F < -1.0E+12 
 * 
 *  Otherwise, we use decimal format ("%f").
 * 
 *  03/07/93:  discovered that when DECIMAL mode is used, very small numbers 
 *  should be expressed a zero - or at least in the precision specified in the
 *  readout spec structure.  Thus if readout->mode == GRIDECIMAL, and the number
 *  is very small ( < _small), we use the 'f' format.  Large numbers are still
 *  expressed in scientific notation, even if mode == GRIO_DECIMAL.  This change
 *  applies to versions 2.2 and later versions of GRNUC.
 */

  if ( fabs( d ) > _large ) /* only large numbers present a problem */
    type = 'g';
  else
    type = 'f';
  
  sprintf( fmt, "%c%c%d%c", '%', '.', readout->precision, type );
  sprintf( out_buf, fmt, d );
/*
 *  See if number came out in scientific notation
 */
  ascii_ptr = &out_buf[0];
  while ( *ascii_ptr != 0 ) {
    if ( *ascii_ptr == 'e' )
      goto wrapup;               /* bailing out */
    ascii_ptr++;
  }
/*
 *  add correct decimal delimeter
 */
  ascii_ptr = &out_buf[0];
  while ( *ascii_ptr != '.' && *ascii_ptr != 0 )
    ascii_ptr++;
  if ( *ascii_ptr == '.' )
    *ascii_ptr = delimeter_list[ readout->decimal_char ];
/*
 *  compute # of digits and find decimal point
 */
  ascii_ptr = dec_ptr = &out_buf[0];
  while ( *dec_ptr != delimeter_list[readout->decimal_char] &&
          *(dec_ptr+1) != 0 )
  {
    dec_ptr++;
    num_digits++;
  }
/*
 *  add thousands separator
 */
  if ( delimeter_list[readout->thousands_char] != ' ' && (num_digits > 3) ) {
    tmp_ptr = dec_ptr;
    char_ct = 0;
    while ( tmp_ptr != ascii_ptr ) {
      if ( ((char_ct % 3) == 0) && (char_ct > 2) && (tmp_ptr[-1] != '-') ) {
        end_ptr = ascii_ptr;
        while ( *end_ptr )
          end_ptr++;  /* scan to the end of string */
        while ( end_ptr >= tmp_ptr ) {
          *(end_ptr+1) = *end_ptr;
          end_ptr--; 
        }
        *tmp_ptr = delimeter_list[readout->thousands_char];
        dec_ptr++; /* decimal place moved since we added thousands delimeter*/
      }
      char_ct++;
      tmp_ptr--;
    }
  }
  
  while ( *(ascii_ptr + 1) )
    ascii_ptr++;
  
  end_ptr = ascii_ptr;
  
#if 0
  if ( dec_ptr < ascii_ptr ) {
    while ( *ascii_ptr == '0' )
      ascii_ptr--;
      
    if ( *ascii_ptr == delimeter_list[ readout->decimal_char ] )
      ascii_ptr--;
  }

  if ( ascii_ptr != end_ptr )
    *(ascii_ptr+1) = 0;
#endif
/*
 *  add trailing zeros
 */
  if ( readout->trailing_zeros ) { 
    if ( ascii_ptr == end_ptr )
      dec_ptr++;
    if ( *dec_ptr == 0 ) {
      *dec_ptr = delimeter_list[ readout->decimal_char ];
      dec_ptr++;
      *dec_ptr = 0;
    }

    end_ptr = &out_buf[0];      
    while ( *end_ptr )
      end_ptr++;
    num_fill_chars = readout->precision - (end_ptr - dec_ptr);
    for ( tmp_ptr = end_ptr; (tmp_ptr < (end_ptr + num_fill_chars)); tmp_ptr++ )
      *tmp_ptr = '0';
    *tmp_ptr = 0;
  }
  else if ( dec_ptr < end_ptr ) {
    while ( *end_ptr == '0' ) {
      *end_ptr = 0;
      end_ptr--;
    }
    if ( *end_ptr == delimeter_list[ readout->decimal_char ] )
      *end_ptr = 0;
  }
  
wrapup:
  return 1;
}

/******************************************************************************/

static void add_alias( outbfsz, outbf, alias, readout )
int outbfsz;
char *outbf;
char *alias;
UOM_READOUT *readout;
{
  short ii;
  int len = outbfsz - strlen( outbf ) - 1;

  if ( len > 0 ) {
    if ( readout->alias_displayed ) {
      for (ii = 0; (ii < readout->intrameas_spacing && len > 0); ii++, len-- )
        strcat( outbf, " " );
      outbf[ outbfsz - 1 ] = 0;

      if ( len > 0 ) {
        strncat( outbf, alias, len );
        outbf[ outbfsz - 1 ] = 0;
        len = outbfsz - strlen( outbf ) - 1;
      }
    }

    for ( ii = 0; (ii < readout->intermeas_spacing && len > 0); ii++, len-- )
      strcat( outbf, " " );
    outbf[ outbfsz - 1 ] = 0;
  }
}

/******************************************************************************/

static int process_decimal( outbfsz, outbf, alias, value, readout,
                            tmp, conv_func )
int outbfsz;
char *outbf;
UOMalias_name alias;
double *value;
UOM_READOUT *readout;
char *tmp;
OM_p_FUNCPTR conv_func;
{
  int sts = OM_S_SUCCESS;
  int len = outbfsz - strlen( outbf ) - 1;

  if ( len > 0 ) {
    sts = conv_func( *value, readout, tmp );
    if ( sts & 1 ) {
      strncat( outbf, tmp, len );
      outbf[ outbfsz - 1 ] = 0;

      add_alias( outbfsz, outbf, alias, readout );
    }
  }

  return sts;
}

/******************************************************************************/

static int process_fraction( outbfsz, outbf, alias, value, readout,
                             tmp, fraction_mode )
int outbfsz;
char *outbf;
UOMalias_name alias;
double *value;
UOM_READOUT *readout;
char *tmp;
short *fraction_mode;
{
  int sts = OM_S_SUCCESS;
  int len = outbfsz - strlen( outbf ) - 1;
  int reduce_flag = (readout->mode == UOM_FRACTIONAL) ? 1 : 0;

  if ( len > 0 ) {
    if ( fraction_mode )               /* make apogee happy */
      *fraction_mode = *fraction_mode;

    sts = UOM_float_to_frac( reduce_flag, *value, readout->denominator,
                             tmp );
    if ( sts & 1 ) {
      strncat( outbf, tmp, len );
      outbf[ outbfsz - 1 ] = 0;

      add_alias( outbfsz, outbf, alias, readout );
    }
  }

  return sts;
}

/******************************************************************************/

int UOM_format_readout( readout, num_alias, alias_list,
                        value_list, field_size, fraction_mode, out_buf )
UOM_READOUT *readout;
short *num_alias;
UOMalias_name *alias_list;
double *value_list;
short *field_size;
short *fraction_mode;
char *out_buf;
{
  int sts, ii;
  char tmp[ 3 * UOM_K_MAX_LEN + 1 ];
  int tmp_fs;
  int left_spaces;
  char fill_char;

  out_buf[0] = 0;
  sts = OM_S_SUCCESS;

  tmp_fs = ( field_size ) ? *field_size : UOM_K_MAX_LEN;

  switch ( readout->mode ) {
    case UOM_DECIMAL:
      for ( ii = 0; (ii < *num_alias); ii++ ) {
        sts = process_decimal( tmp_fs, out_buf, alias_list[ii],
                               &value_list[ii], readout, tmp,
                               UOM_float_to_ascii );
        if ( ! (sts & 1) )
          break;
      }
      break;

    case UOM_SCIENTIFIC: 
      for ( ii = 0; (ii < *num_alias); ii++ ) {
        sts = process_decimal( tmp_fs, out_buf, alias_list[ii],
                               &value_list[ii], readout, tmp,
                               UOM_float_to_sci );
        if ( ! (sts & 1) )
          break;
      }
      break;

    case UOM_FRACTIONAL:
    case UOM_NON_REDUCED_FRACTION:
      for ( ii = 0; (ii < *num_alias); ii++ ) {
        sts = process_fraction( tmp_fs, out_buf, alias_list[ii],
                                &value_list[ii], readout, tmp,
                                fraction_mode );
        if ( ! (sts & 1) )
          break;
      }
      break;
    default:
      sts = MSFAIL;
      break;
  }

  if ( sts & 1 ) {
/*
 *  Convert string to proper case.
 */
    if ( readout->case_type == UOM_UPPER_CASE )
      for ( ii = 0; out_buf[ii]; ii++ )
        out_buf[ii] = toupper( out_buf[ii] );
    else if ( readout->case_type == UOM_LOWER_CASE )
      for ( ii = 0; out_buf[ii]; ii++ )
        out_buf[ii] = tolower( out_buf[ii] );
/*
 *  Justify string.  Compute how many spaces should be inserted
 *  at the front of the string.
 */
    left_spaces = 0;
    if ( readout->justification != UOM_LEFT_JUSTIFY ) {
      int len;

      len = strlen( out_buf );
      if ( tmp_fs >= len )
        left_spaces = tmp_fs - len;

      if ( readout->justification == UOM_CENTER_JUSTIFY )
        left_spaces = left_spaces / 2;
    }
/*
 *  Pad the left with spaces.
 */
    if ( left_spaces ) {
      char *tmp_buf;

      tmp_buf = (char *) malloc( left_spaces + 1 + tmp_fs );
      sts = ( tmp_buf ) ? OM_S_SUCCESS : OM_E_NODYNMEM ;
      if ( sts & 1 ) {
        tmp_buf[ left_spaces ] = 0;
        for ( ii = 0; (ii < left_spaces); ii++ )
          tmp_buf[ ii ] = ' ';
        strcpy( &tmp_buf[ ii ], out_buf );
        strcpy( out_buf, tmp_buf );
        free( tmp_buf );
      }
    }

    if ( sts & 1 ) {
      fill_char = ' ';
      if ( readout->left_fill_char != ' ' )
        fill_char = readout->left_fill_char;
      else if ( readout->leading_zeros )
        fill_char = '0';
/*
 *  Insert left fill character or leading zeros.
 */
      if ( fill_char ! = ' ' ) {
        char *ptr;
        int neg_sign = 0;

        if ( out_buf[0] == '-' )
          neg_sign = 1;
        for ( ptr = out_buf; (*ptr == ' ' || *ptr == '-'); ptr++ )
          *ptr = fill_char;

        if ( neg_sign )
          out_buf[0] = '-';
      }
    }
  }

  return sts;
}

/******************************************************************************/

int UOM_set_default_readout( readout )
UOM_READOUT *readout;
{
  readout->mode = UOM_DECIMAL; 
  readout->precision = 4; 
  readout->denominator = 16;
  readout->intermeas_spacing = 2;  
  readout->intrameas_spacing = 1;
  readout->justification = UOM_LEFT_JUSTIFY; 
  readout->case_type = UOM_DEFAULT_CASE;
  readout->decimal_char = UOM_PERIOD;
  readout->thousands_char = UOM_NONE;
  readout->left_fill_char = ' ';
  readout->alias_displayed = (char)1;
  readout->leading_zeros = (char)0;
  readout->trailing_zeros = (char)0;

  return 1;
}
