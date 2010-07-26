/*
Name

Abstract

Synopsis

Description
 units initialization code.
Return Value

Notes
 It does not use the standard message system because it prints
 to the console, so it is not part of the interface.
Index

Keywords
 units_of_measurement, message, initialization.
History
 03/01/93 : Carlos M. Diaz : put header and notes.
*/

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <limits.h>
#include <string.h>
#if defined( NT )
#  define access _access
#else
#  include <unistd.h>
#endif
#include "OMerrordef.h"
#include "OMminimum.h"
#include "exmacros.h"
#include "msdef.h"

#include "UOMdef.h"
#include "UOM.h"
#include "UOMtls.h"
#include "UOMerrordef.h"
#include "UOMyaerrdef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"

#include "UOMextern.h"

static int UOM_curr_lineno = 0;

  /* The file name of the uom table, this must be changed */
#define UOM_TABLE     "uom_table"

#define UNIT_TYPE     "type"
#define UNIT_DEFAULT  "default"

#define TAB     9
#define SPACE  32

#define _iswspace( c ) ( ((c) == SPACE) || ((c) == TAB) )

struct da_dims {
  char *unit_type;
  UOMdimensions dims;
};


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

static int compare_keywords __((const void *keyword1,
                                const void *keyword2));
static int compare_keyword_types __((const void *keyword1,
                                     const void *keyword2));
static int compare_dims __((const void *dim1, const void *dim2));
static void stripit __((char *line));
static char *getline __((char *line, int sz, FILE *fp));
static void UOM_lookup_dimensions __((char *unit_type, UOMdimensions dims));
static int UOM_parse_type __((char *line, UOM_TYPE **type));
static int UOM_parse_default __((char *line, UOM_TYPE *type));
static int UOM_parse_variant __((char *line, UOM_VARIANT **variant));
static int UOM_verify_scale_units __((UOM_TYPE *type));
static int UOM_read_table __((char *uom_table, UOM_TYPE **uom_types));
static int UOM_unchain_scales __((UOM_TYPE *uom_types));

#if defined(__cplusplus)
}
#endif
#undef __



static int compare_keywords( keyword1, keyword2 )
const void *keyword1,
           *keyword2;
{
  UOM_DIMKEYWORD *k1 = (UOM_DIMKEYWORD *) keyword1;
  UOM_DIMKEYWORD *k2 = (UOM_DIMKEYWORD *) keyword2;

  return( strcmp( k1->keyword, k2->keyword ) );
}

static int compare_keyword_types( keyword1, keyword2 )
const void *keyword1,
           *keyword2;
{
  UOM_DIMKEYWORD *k1 = (UOM_DIMKEYWORD *) keyword1;
  UOM_DIMKEYWORD *k2 = (UOM_DIMKEYWORD *) keyword2;

  if ( k1->type < k2->type )
    return -1;
  if ( k1->type == k2->type )
    return 0;
  return 1;
}

static int compare_dims( dim1, dim2 )
const void *dim1,
           *dim2;
{
  struct da_dims *d1 = (struct da_dims *) dim1;
  struct da_dims *d2 = (struct da_dims *) dim2;

  return( strcmp( d1->unit_type, d2->unit_type ) );
}

static void stripit( line )
char *line;
{
  if ( line[0] ) {
    int len, ii = strlen( line ) - 1;

    while ( (ii >= 0) && _iswspace( line[ ii ] ) ) ii--;
    line[ len = ii + 1 ] = '\0';

    if ( len > 0 ) {
      ii = 0;
      while ( (ii < len) && _iswspace( line[ ii ] ) ) ii++;
      if ( ii > 0 )
        strcpy( line, &line[ ii ] );
    }
  }

  return;
}

static char *getline( line, sz, fp )
char *line;
int sz;
FILE *fp;
{
  UOM_curr_lineno ++;
  if ( fgets( line, sz, fp ) ) {
    line[ strlen( line ) - 1 ] = 0;  /* remove newline */
    stripit( line );                 /* remove leading & trailing white space */
    if ( ! line[0] || line[0] == '#' )
      return getline( line, sz, fp ); /* blank line or comment */
    else
      return line;
  }
  else
    return (char *) 0;
}

static void UOM_lookup_dimensions( unit_type, dims )
char *unit_type;
UOMdimensions dims;
{
  static int dimensions_tabsize = 0;
  static struct da_dims dimensions[] = {
/*                                M    D    T    C    A    SA   TP   I
*/
    { "distance",                 0,   1,   0,   0,   0,   0,   0,   0 },
    { "angle",                    0,   0,   0,   0,   1,   0,   0,   0 },
    { "area",                     0,   2,   0,   0,   0,   0,   0,   0 },
    { "volume",                   0,   3,   0,   0,   0,   0,   0,   0 },
    { "second_moment_of_area",    0,   4,   0,   0,   0,   0,   0,   0 },
    { "time",                     0,   0,   1,   0,   0,   0,   0,   0 },
    { "mass",                     1,   0,   0,   0,   0,   0,   0,   0 },
    { "mass_per_length",          1,  -1,   0,   0,   0,   0,   0,   0 },
    { "mass_per_area",            1,  -2,   0,   0,   0,   0,   0,   0 },
    { "force",                    1,   1,  -2,   0,   0,   0,   0,   0 },
    { "moment",                   1,   2,  -2,   0,   0,   0,   0,   0 },
    { "density",                  1,  -3,   0,   0,   0,   0,   0,   0 },
    { "force_per_length",         1,   0,  -2,   0,   0,   0,   0,   0 },
    { "pressure",                 1,  -1,  -2,   0,   0,   0,   0,   0 },
    { "body_force",               1,  -2,  -2,   0,   0,   0,   0,   0 },
    { "trans_stiffness",          1,   0,  -2,   0,   0,   0,   0,   0 },
    { "rot_stiffness",            1,   2,  -2,   0,  -1,   0,   0,   0 },
    { "linear_velocity",          0,   1,  -1,   0,   0,   0,   0,   0 },
    { "linear_acceleration",      0,   1,  -2,   0,   0,   0,   0,   0 },
    { "linear_per_angular",       0,   1,   0,   0,  -1,   0,   0,   0 },
    { "angular_velocity",         0,   0,  -1,   0,   1,   0,   0,   0 },
    { "angular_acceleration",     0,   0,  -2,   0,   1,   0,   0,   0 },
    { "energy",                   1,   2,  -2,   0,   0,   0,   0,   0 },
    { "power",                    1,   2,  -3,   0,   0,   0,   0,   0 },
    { "energy_density",           1,  -1,  -2,   0,   0,   0,   0,   0 },
    { "mechanical_damping",       1,   0,  -1,   0,   0,   0,   0,   0 },
    { "temperature",              0,   0,   0,   0,   0,   0,   1,   0 },
    { "coef_thermal_expansion",   0,   0,   0,   0,   0,   0,  -1,   0 },
    { "thermal_conductivity",     1,   1,  -3,   0,   0,   0,  -1,   0 },
    { "heat_capacity",            0,   2,  -2,   0,   0,   0,  -1,   0 },
    { "volume_flow_rate",         0,   3,  -1,   0,   0,   0,   0,   0 },
    { "mass_flow_rate",           1,   0,  -1,   0,   0,   0,   0,   0 },
    { "viscosity",                1,  -1,  -1,   0,   0,   0,   0,   0 },
    { "shear_rate",               0,   0,  -1,   0,   0,   0,   0,   0 },
    { 0,                          0,   0,   0,   0,   0,   0,   0,   0 }
  };
  
  struct da_dims *dims_ptr, a_dims;

  if ( ! dimensions_tabsize ) {
    while ( dimensions[ dimensions_tabsize ].unit_type )
      dimensions_tabsize++;
    qsort( dimensions, dimensions_tabsize, sizeof( struct da_dims ),
           compare_dims );
  }

  a_dims.unit_type = unit_type;
  dims_ptr = (struct da_dims *) bsearch( &a_dims, dimensions,
                                         dimensions_tabsize,
                                         sizeof( struct da_dims ),
                                         compare_dims );
  if ( dims_ptr ) {
    memcpy( dims, dims_ptr->dims, sizeof( UOMdimensions ) );
  }

}

int UOM_lookup_dimension_keyword( keyword, keyword_type )
char *keyword;
int *keyword_type;
{
  int sts;
  UOM_DIMKEYWORD *keyword_ptr, a_keyword;

  static int dimkeywords_tabsize = 0;
  static UOM_DIMKEYWORD dimkeywords[] = {
    { "m",     UOM_K_MASS_DIM },       /* Mass dimension               */
    { "d",     UOM_K_LENG_DIM },       /* Length dimension             */
    { "t",     UOM_K_TIME_DIM },       /* Time dimension               */
    { "c",     UOM_K_ELEC_DIM },       /* Electrical current dimension */
    { "a",     UOM_K_PANG_DIM },       /* Plane angle dimension        */
    { "sa",    UOM_K_SANG_DIM },       /* Solid angle dimension        */
    { "tp",    UOM_K_TEMP_DIM },       /* Temperature dimension        */
    { "i",     UOM_K_ITEN_DIM },       /* Luminous intensity dimension */
    { "",      0 }
  };

  if ( ! keyword || ! keyword[0] )
    sts = 0;
  else {
/*
 *  On first valid call, count number of keywords in table & sort
 */
    if ( ! dimkeywords_tabsize ) {
      while ( dimkeywords[ dimkeywords_tabsize ].keyword[0] )
        dimkeywords_tabsize++;
      qsort( dimkeywords, dimkeywords_tabsize, sizeof( UOM_DIMKEYWORD ),
             compare_keywords );
    }
/*
 *  Ok, table sorted, lookup specified keyword
 */
    strcpy( a_keyword.keyword, keyword );
    keyword_ptr = (UOM_DIMKEYWORD *) bsearch( &a_keyword, dimkeywords,
                                              dimkeywords_tabsize,
                                              sizeof( UOM_DIMKEYWORD ),
                                              compare_keywords );
    if ( keyword_ptr ) {
      *keyword_type = keyword_ptr->type;
      sts = 1;
    }
    else
      sts = 0;
  }

  return sts;
}

int UOM_lookup_dimension_keyword_type( keyword_type, keyword )
int keyword_type;
char *keyword;
{
  int sts;
  UOM_DIMKEYWORD *keyword_ptr, a_keyword;

  static int dimkeywords_tabsize = 0;
  static UOM_DIMKEYWORD dimkeywords[] = {
    { "m",     UOM_K_MASS_DIM },       /* Mass dimension               */
    { "d",     UOM_K_LENG_DIM },       /* Length dimension             */
    { "t",     UOM_K_TIME_DIM },       /* Time dimension               */
    { "c",     UOM_K_ELEC_DIM },       /* Electrical current dimension */
    { "a",     UOM_K_PANG_DIM },       /* Plane angle dimension        */
    { "sa",    UOM_K_SANG_DIM },       /* Solid angle dimension        */
    { "tp",    UOM_K_TEMP_DIM },       /* Temperature dimension        */
    { "i",     UOM_K_ITEN_DIM },       /* Luminous intensity dimension */
    { "",      0 }
  };

/*
 *  On first valid call, count number of keywords in table & sort
 */
  if ( ! dimkeywords_tabsize ) {
    while ( dimkeywords[ dimkeywords_tabsize ].keyword[0] )
      dimkeywords_tabsize++;
    qsort( dimkeywords, dimkeywords_tabsize, sizeof( UOM_DIMKEYWORD ),
           compare_keyword_types );
  }
/*
 *  Ok, table sorted, lookup specified keyword
 */
  a_keyword.type = keyword_type;
  keyword_ptr = (UOM_DIMKEYWORD *) bsearch( &a_keyword, dimkeywords,
                                            dimkeywords_tabsize,
                                            sizeof( UOM_DIMKEYWORD ),
                                            compare_keyword_types );
  if ( keyword_ptr ) {
    strcpy( keyword, keyword_ptr->keyword );
    sts = 1;
  }
  else
    sts = 0;

  return sts;
}

static int UOM_parse_type( line, type )
char *line;
UOM_TYPE **type;
{
  int sts;
  int uom_sts = UOM_S_SUCCESS;
  int len;
  int dimtype;
  int exponent;
  int finished, state, error;
  char *ch, *ptr;
  char scrstr[ UOM_K_MAX_KEYWORD ];

  *type = (UOM_TYPE *) calloc( 1, sizeof( UOM_TYPE ) );
  sts = ( *type ) ? OM_S_SUCCESS : OM_E_NODYNMEM ;

  if ( sts & 1 ) {
    (*type)->next = (*type)->prev = *type;
    error = 0;
    state = 0;
    finished = 0;
    ch = line + strlen( UNIT_TYPE );

    while ( ! finished ) {
      while ( _iswspace( *ch ) ) ch++;

      if ( ! *ch ) {
        finished = 1;
/*
 *  Lookup unit dimensions if none were specified
 */
        if ( ! UOM_HasUnit( (*type)->dims ) )
          UOM_lookup_dimensions( (*type)->name, (*type)->dims );
      }
      else {
        switch ( state ) {
          case 0:
            ptr = ch;
            while ( *ch && ! _iswspace( *ch ) ) ch++;
            len = ch - ptr;
            if ( len >= UOM_K_MAX_TYPE ) {
              len = UOM_K_MAX_TYPE - 1;
              uom_sts = UOM_I_TYPE_TRUNCATED;
            }
            strncpy( (*type)->name, ptr, len );
            (*type)->name[ len ] = 0;
            UOM_cvt_to_lower( (*type)->name );
            state = 1;
            break;
          case 1:
            ptr = ch;
            while ( isalpha( *ch ) ) ch++;
            len = ch - ptr;
            if ( len >= UOM_K_MAX_KEYWORD )
              len = UOM_K_MAX_KEYWORD - 1;
            strncpy( scrstr, ptr, len );
            scrstr[ len ] = 0;
            UOM_cvt_to_lower( scrstr );
            if ( UOM_lookup_dimension_keyword( scrstr, &dimtype ) )
              state = 2;
            else
              error = 1;
            break; 
          case 2:
            if ( *ch == '=' ) {
              ch++;
              state = 3;
            }
            else
              error = 2;
            break;
          case 3:
            {
              ptr = ch;
              exponent = (int) strtol( ptr, &ch, 0 );
              if ( ptr == ch )
                error = 3;
              else if ( (exponent < SCHAR_MIN) || (exponent > SCHAR_MAX) )
                error = 4;
              else {
                (*type)->dims[ dimtype ] = (char) exponent;
                state = 1;
              }
            }
            break;
          default:
            error = 5;
            break;
        }

        if ( error )
          finished = 1;
      }
    }

    {
      char *fmt = 0, buf[1024];

      if ( uom_sts == UOM_I_TYPE_TRUNCATED ) {
        UOM_get_message_string( UOM_TYPE_TRUNC, &fmt );
        sprintf( buf, fmt, (*type)->name );
        fmt = (char *) buf;
      }
      else if ( error ) {
        switch ( error ) {
          case 1:
            UOM_get_message_string( UOM_UNKNOWN_DIM_KEYWORD, &fmt );
            sprintf( buf, fmt, scrstr );
            fmt = (char *) buf;
            break;
          case 2:
            UOM_get_message_string( UOM_EXPECTED_EQUAL_SIGN, &fmt );
            break;
          case 3:
            UOM_get_message_string( UOM_INVALID_DIM_EXPONENT, &fmt );
            break;
          case 4:
            UOM_get_message_string( UOM_DIM_EXPONENT_RANGE, &fmt );
            break;
        }
      }

      if ( fmt ) {
        char *lineno = 0;

        UOM_get_message_string( UOM_CURR_LINENO, &lineno );
        if ( lineno )
          UOM_echo_message( lineno );
        UOM_echo_message( fmt );
        UOM_echo_message( "" );
      }
    }
  }

  return ( sts & 1 ) ? uom_sts : sts ;
}

static int UOM_parse_default( line, type )
char *line;
UOM_TYPE *type;
{
  int sts = OM_S_SUCCESS;
  int uom_sts = UOM_S_SUCCESS;
  int len, sz, truncndx = 0;
  int numdefs;
  int finished, state, error;
  char *ch, *ptr;

  numdefs = 0;

  error = 0;
  state = 0;
  finished = 0;
  ch = line + strlen( UNIT_DEFAULT );

  while ( ! finished ) {
    while ( _iswspace( *ch ) ) ch++;

    if ( ! *ch )
      finished = 1;
    else {
      switch ( state ) {
        case 0:
          if ( numdefs < UOM_K_MAX_DEFS ) {
            ptr = ch;
            while ( *ch && ! _iswspace( *ch ) ) ch++;
            len = ch - ptr;
            if ( len >= UOM_K_MAX_ALIAS ) {
              len = UOM_K_MAX_ALIAS - 1;
              uom_sts = UOM_I_ALIAS_TRUNCATED;
              truncndx = numdefs;
            }

            sz = (numdefs + 2) * sizeof( char * );

            if ( ! type->defalias )
              type->defalias = (char **) malloc( sz );
            else
              type->defalias = (char **) realloc( type->defalias, sz );

            if ( ! type->defalias ) {
              error = 1;
              sts = OM_E_NODYNMEM;
            }
            else {
              type->defalias[ numdefs ] = 0;
              type->defalias[ numdefs + 1 ] = 0;

              type->defalias[ numdefs ] = (char *) malloc( len + 1 );
              if ( ! type->defalias[ numdefs ] ) {
                error = 1;
                sts = OM_E_NODYNMEM;
              }
              else {
                strncpy( type->defalias[ numdefs ], ptr, len );
                type->defalias[ numdefs ][ len ] = 0;
                UOM_cvt_to_lower( type->defalias[ numdefs ] );
                numdefs ++;
              }
            }
          }
          else {
            error = 1;
            uom_sts = UOM_I_MAX_DEFS_EXCEEDED;
          }
          break;
        default:
          error = 1;
          break;
      }

      if ( error )
        finished = 1;
    }

    {
      char *fmt = 0, buf[1024];

      if ( uom_sts == UOM_I_ALIAS_TRUNCATED ) {
        UOM_get_message_string( UOM_DEFALIAS_TRUNC, &fmt );
        sprintf( buf, fmt, type->defalias[ truncndx ], type->name );
        fmt = (char *) buf;
      }
      else if ( uom_sts == UOM_I_MAX_DEFS_EXCEEDED ) {
        UOM_get_message_string( UOM_MAX_DEFALIAS, &fmt );
      }

      if ( fmt ) {
        char *lineno = 0;

        UOM_get_message_string( UOM_CURR_LINENO, &lineno );
        if ( lineno )
          UOM_echo_message( lineno );
        UOM_echo_message( fmt );
        UOM_echo_message( "" );
      }
    }

  }

  return ( sts & 1 ) ? uom_sts : sts ;
}

static int UOM_parse_variant( line, variant )
char *line;
UOM_VARIANT **variant;
{
  int sts = OM_S_SUCCESS;
  int uom_sts = UOM_S_SUCCESS;
  int len, sz;
  int whichone = 0;
  int numalias, truncndx = 0;
  int finished, state, error;
  char *ch, *ptr;

  *variant = (UOM_VARIANT *) calloc( 1, sizeof( UOM_VARIANT ) );
  sts = ( *variant ) ? OM_S_SUCCESS : OM_E_NODYNMEM ;

  if ( sts & 1 ) {
    (*variant)->next = (*variant)->prev = *variant;
    (*variant)->scale = 1.0;
    (*variant)->flags = UOM_UC_SCALE | UOM_UC_SHIFT;

    numalias = 0;

    error = 0;
    state = 0;
    finished = 0;
    ch = line;

    while ( ! finished ) {
      while ( _iswspace( *ch ) ) ch++;

      if ( ! *ch )
        finished = 1;
      else {
        switch ( state ) {
          case 0:
            if ( *ch == '=' ) {
              ch++;
              state = 1;
            }
            else {
              ptr = ch;
              while ( *ch && ! _iswspace( *ch ) ) ch++;
              len = ch - ptr;
              if ( len >= UOM_K_MAX_ALIAS ) {
                len = UOM_K_MAX_ALIAS - 1;
                uom_sts = UOM_I_ALIAS_TRUNCATED;
                truncndx = numalias;
                whichone = 1;
              }

              sz = (numalias + 2) * sizeof( char * );

              if ( ! (*variant)->alias )
                (*variant)->alias = (char **) malloc( sz );
              else
                (*variant)->alias = (char **) realloc( (*variant)->alias, sz );

              if ( ! (*variant)->alias ) {
                error = 1;
                sts = OM_E_NODYNMEM;
              }
              else {
                (*variant)->alias[ numalias ] = 0;
                (*variant)->alias[ numalias + 1 ] = 0;

                (*variant)->alias[ numalias ] = (char *) malloc( len + 1 );
                if ( ! (*variant)->alias[ numalias ] ) {
                  error = 1;
                  sts = OM_E_NODYNMEM;
                }
                else {
                  strncpy( (*variant)->alias[ numalias ], ptr, len );
                  (*variant)->alias[ numalias ][ len ] = 0;
                  UOM_cvt_to_lower( (*variant)->alias[ numalias ] );
                  numalias ++;
                }
              }
            }
            break;

          case 1:
            {
              ptr = ch;
              (*variant)->scale = strtod( ptr, &ch );
              if ( ptr == ch )
                error = 2;
              else
                state = 2;
            }
            break;

          case 2:
            ptr = ch;
            while ( *ch && ! _iswspace( *ch ) && (*ch != ',') ) ch++;
            len = ch - ptr;
            if ( len >= UOM_K_MAX_ALIAS ) {
              len = UOM_K_MAX_ALIAS - 1;
              uom_sts = UOM_I_ALIAS_TRUNCATED;
              whichone = 2;
            }
            strncpy( (*variant)->scaleunits, ptr, len );
            (*variant)->scaleunits[ len ] = 0;
            UOM_cvt_to_lower( (*variant)->scaleunits );
            (*variant)->flags &= ~UOM_UC_SCALE;
            state = 3;
            break;

          case 3:
            if ( *ch == ',' ) {
              ch++;
              state = 4;
            }
            else
              error = 1;
            break;

          case 4:
            {
              ptr = ch;
              (*variant)->shift = strtod( ptr, &ch );
              if ( ptr == ch )
                error = 3;
              else
                state = 5;
            }
            break;

          case 5:
            ptr = ch;
            while ( *ch && ! _iswspace( *ch ) ) ch++;
            len = ch - ptr;
            if ( len >= UOM_K_MAX_ALIAS ) {
              len = UOM_K_MAX_ALIAS - 1;
              uom_sts = UOM_I_ALIAS_TRUNCATED;
              whichone = 3;
            }
            strncpy( (*variant)->shiftunits, ptr, len );
            (*variant)->shiftunits[ len ] = 0;
            UOM_cvt_to_lower( (*variant)->shiftunits );
            (*variant)->flags &= ~UOM_UC_SHIFT;
            finished = 1;
            break;

          default:
            error = 1;
            break;
        }

        if ( error )
          finished = 1;
      }
    }

    {
      char *fmt = 0, buf[1024];

      if ( uom_sts == UOM_I_ALIAS_TRUNCATED ) {
        switch ( whichone ) {
          case 1:
            UOM_get_message_string( UOM_ALIAS_TRUNC, &fmt );
            sprintf( buf, fmt, (*variant)->alias[ truncndx ] );
            break;
          case 2:
            UOM_get_message_string( UOM_SCALEALIAS_TRUNC, &fmt );
            sprintf( buf, fmt, (*variant)->scaleunits );
            break;
          case 3:
            UOM_get_message_string( UOM_SHIFTALIAS_TRUNC, &fmt );
            sprintf( buf, fmt, (*variant)->shiftunits );
            break;
        }
        fmt = (char *) buf;
      }
      else if ( error ) {
        switch ( error ) {
          case 2:
            UOM_get_message_string( UOM_BAD_SCALEFAC, &fmt );
            break;
          case 3:
            UOM_get_message_string( UOM_BAD_SHIFTFAC, &fmt );
            break;
        }
      }

      if ( fmt ) {
        char *lineno = 0;

        UOM_get_message_string( UOM_CURR_LINENO, &lineno );
        if ( lineno )
          UOM_echo_message( lineno );
        UOM_echo_message( fmt );
        UOM_echo_message( "" );
      }
    }

  }

  return ( sts & 1 ) ? uom_sts : sts ;
}

static int UOM_verify_scale_units( type )
UOM_TYPE *type;
{
  int found;
  UOM_VARIANT *fv;
  char *fmt = 0, buf[1024];
/*
 *  Loop thru each unit variant verifing that valid scale & shift units
 *  have been specified
 */
  if ( ! type->variant )
    found = 0;
  else {
    found = 1;
    _FOR_LIST( UOM_VARIANT, type->variant, vv ) {
      if ( vv->scaleunits[0] ) {
        UOM_lookup_alias_locally( type, vv->scaleunits, &fv );
        if ( ! fv ) {
          UOM_get_message_string( UOM_SCALEALIAS_NOT_FOUND, &fmt );
          if ( fmt ) {
            sprintf( buf, fmt, vv->scaleunits, type->name );
            strcat( buf, "\n" );
            UOM_echo_message( buf );
          }
          found = 0;
          break;
        }
      }
      if ( vv->shiftunits[0] ) {
        UOM_lookup_alias_locally( type, vv->shiftunits, &fv );
        if ( ! fv ) {
          UOM_get_message_string( UOM_SHIFTALIAS_NOT_FOUND, &fmt );
          if ( fmt ) {
            sprintf( buf, fmt, vv->shiftunits, type->name );
            strcat( buf, "\n" );
            UOM_echo_message( buf );
          }
          found = 0;
          break;
        }
      }
    } _END_LIST
  }

  return (found) ? UOM_S_SUCCESS : UOM_E_ALIAS_NOT_FOUND ;
}

int UOM_verify_type( type )
UOM_TYPE *type;
{
  int sts;
  int ii = 0;
  UOM_VARIANT *fv;
/*
 *  Verify that each default is a defined alias for the specified
 *  unit type
 */
  if ( type->defalias ) {
    sts = UOM_S_SUCCESS;
    while ( type->defalias[ii] ) {
      UOM_lookup_alias_locally( type, type->defalias[ii], &fv );
      if ( ! fv ) {
        char *fmt = 0;

        UOM_get_message_string( UOM_DEFALIAS_NOT_FOUND, &fmt );

        if ( fmt ) {
          char buf[1024];

          sprintf( buf, fmt, type->defalias[ii], type->name );
          strcat( buf, "\n" );
          UOM_echo_message( buf );
        }
        sts = UOM_E_ALIAS_NOT_FOUND;
        break;
      }
      ii++;
    }
/*
 *  Verify that each variant has valid scale units & shift units
 */
    if ( sts & 1 )
      sts = UOM_verify_scale_units( type );
  }
  else
    sts = UOM_E_UNEXPECTED_NULL_PTR;

  return sts;
}

static int UOM_read_table( uom_table, uom_types )
char *uom_table;
UOM_TYPE **uom_types;
{
  int sts;
  FILE *fp;
  char line[ BUFSIZ ];
  UOM_TYPE *type = 0;
  UOM_VARIANT *variant = 0;
  int state, finished, error, transfer;

  *uom_types = 0;
  UOM_curr_lineno = 0;
  fp = fopen( uom_table, "r" );
  sts = ( fp ) ? OM_S_SUCCESS : OM_E_READ_ERROR ;

  if ( sts & 1 ) {
    error = 0;
    state = 0;
    transfer = 0;
    finished = 0;

    while ( ! finished ) {
      if ( transfer )
        transfer = 0;
      else if ( ! getline( line, BUFSIZ, fp ) ) {
        finished = 1;

        if ( type ) {
          sts = UOM_verify_type( type );
          if ( sts & 1 ) {
            UOM_list_append( type, uom_types );
            type = 0;
          }
          else {
            UOM_free_type( &type );
          }
        }
      }

      if ( ! finished ) {
        switch ( state ) {
          case 0:
            if ( ! strncmp( line, UNIT_TYPE, strlen( UNIT_TYPE ) ) ) {
              sts = UOM_parse_type( line, &type );
              if ( sts & 1 )
                state = 1;
              else
                error = 1;
            }
            else
              error = 2;          /* expecting "type" keyword */
            break;
          case 1:
            if ( ! strncmp( line, UNIT_DEFAULT, strlen( UNIT_DEFAULT ) ) ) {
              sts = UOM_parse_default( line, type );
              if ( sts & 1 )
                state = 2;
              else
                error = 1;
            }
            else
              error = 3;          /* expecting "default" keyword */
            break;
          case 2:
            if ( ! strncmp( line, UNIT_TYPE, strlen( UNIT_TYPE ) ) ) {
/*
 *  Add current type to list of types, then transfer to build new unit
 *  type state
 */
              sts = UOM_verify_type( type );
              if ( sts & 1 ) {
                UOM_list_append( type, uom_types );
                type = 0;
              }
              else {
                UOM_free_type( &type );
              }

              state = 0;
              transfer = 1;
            }
            else {
              sts = UOM_parse_variant( line, &variant );
              if ( sts & 1 ) {
                UOM_list_append( variant, &type->variant );
                variant->type = type;
                variant = 0;
              }
              else {
                UOM_free_variant( &variant );
                error = 1;
              }
            }
            break;
          default:
            error = 1;
            break;
        }

        if ( error )
          finished = 1;
      }
    }

    {
      char *fmt = 0;

      if ( error ) {
        switch ( error ) {
          case 2:
            UOM_get_message_string( UOM_EXPECT_TYPE, &fmt );
            break;
          case 3:
            UOM_get_message_string( UOM_EXPECT_DEFAULT, &fmt );
            break;
        }
      }

      if ( fmt ) {
        char *lineno = 0;

        UOM_get_message_string( UOM_CURR_LINENO, &lineno );
        if ( lineno )
          UOM_echo_message( lineno );
        UOM_echo_message( fmt );
        UOM_echo_message( "" );
      }
    }

  }

  UOM_free_type( &type );
  UOM_free_variant( &variant );

  if ( fp )
    fclose( fp );
 
  return sts;
}

static UOM_unchain_scales( uom_types )
UOM_TYPE *uom_types;
{
  int sts = OM_S_SUCCESS;
  double scale, shift;
  UOM_VARIANT *sv, *tv;

  _FOR_LIST( UOM_TYPE, uom_types, tt ) {
    _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
/*
 *  Unchain scale for this variant
 */
      if ( ! (vv->flags & UOM_UC_SCALE) ) {
        scale = vv->scale;
        tv = vv;
        while ( 1 ) {
          UOM_lookup_alias_locally( tt, tv->scaleunits, &sv );
          scale *= sv->scale;
          if ( ! (sv->flags & UOM_UC_SCALE) )
            tv = sv;
          else
            break;
        }
        vv->scale = scale;
        vv->flags |= UOM_UC_SCALE;
      }
/*
 *  Unchain shift for this variant
 */
      if ( ! (vv->flags & UOM_UC_SHIFT) ) {
        shift = vv->shift;
        tv = vv;
        while ( 1 ) {
          UOM_lookup_alias_locally( tt, tv->shiftunits, &sv );
          shift *= sv->shift;
          if ( ! (sv->flags & UOM_UC_SHIFT) )
            tv = sv;
          else
            break;
        }
        vv->shift = shift;
        vv->flags |= UOM_UC_SHIFT;
      }
    } _END_LIST
  } _END_LIST

  return sts;
}

int UOM_merge_uom_types( osnum, prod_uom_types, uom_types )
OMuword osnum;
UOM_TYPE **prod_uom_types,
          **uom_types;
{
  int sts = OM_S_SUCCESS;

  if ( ! *uom_types ) {
    *uom_types = *prod_uom_types;
    *prod_uom_types = 0;
  }
  else {
    int restart;
    UOM_TYPE *ft;

    while ( 1 ) {
      restart = 0;
      _FOR_LIST( UOM_TYPE, *prod_uom_types, tt ) {
        UOM_lookup_type_locally( osnum, tt->name, (char *) 0, *uom_types, &ft );
        if ( ! ft ) {
/*
 *  The unit type was not found so add it to uom_types
 */
          UOM_list_remove( tt, prod_uom_types );
          UOM_list_append( tt, uom_types );
          restart = 1;
        }
        else {
          int addit;
/*
 *  The unit type was found, loop thru all the variants and see if we can
 *  add some of them
 */
          while ( 1 ) {
            addit = 0;
            _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
              int ii;
              UOM_VARIANT *fv;
/*
 *  If all the aliases for the variant are not found than we can add the
 *  variant to the unit type
 */
              ii = 0;
              addit = 1;
              while ( vv->alias[ii] ) {
                UOM_lookup_alias_locally( ft, vv->alias[ii], &fv );
                if ( fv ) {
                  addit = 0;
                  break;
                }
                ii++;
              }

              if ( addit ) {
/*
 *  All the aliases did not exist so we can merge this variant into the type
 *  if this variants scale & shift units exist in the type
 */
                if ( vv->scaleunits[0] ) {
                  UOM_lookup_alias_locally( ft, vv->scaleunits, &fv );
                  if ( ! fv )
                    addit = 0;
                }
                if ( addit ) {
                  if ( vv->shiftunits[0] ) {
                    UOM_lookup_alias_locally( ft, vv->shiftunits, &fv );
                    if ( ! fv )
                      addit = 0;
                  }
                  if ( addit ) {
                    UOM_list_remove( vv, &tt->variant );
                    UOM_list_append( vv, &ft->variant );
/*
 *  If this unit type is filed in the object space, then we need to mark the
 *  unit type so it will be stored again.
 */
                    if ( ft->flags & UOM_TS_FILED ) {
                      ft->flags |= UOM_TS_STORED;
                      vv->flags |= UOM_TS_STORED;
                    }

                    vv->type = ft;
                    break;
                  }
                }
              }
            } _END_LIST

            if ( ! addit )
              break;
          }
        }

        if ( restart )
          break;
      } _END_LIST

      if ( ! restart )
        break;
    }
  }

  return sts;
}

int UOM_init( osnum, uom_types )
OMuword osnum;
UOM_TYPE **uom_types;
{
  int sts = OM_S_SUCCESS;
  int ii, jj, incr, numprods;
  char prodpath[ 1024 ];
  char uom_table[ 1024 ];
  UOM_TYPE *luom_types = 0;
  UOM_TYPE *puom_types = 0;

  extern int UOM_G_inner_to_outer;

  if ( uom_types )
    *uom_types = 0;

/*
 *  Count number of products in path
 */
  numprods = 0;
  while ( ex$get_path( index = numprods++, path = prodpath,
                       len = sizeof( prodpath ) ) ) ;
  numprods--;
/*
 *  Load uom_table ...
 */
  if ( UOM_G_inner_to_outer ) {     /* from inner most product to outer most */
    jj = numprods;
    incr = -1;
  }
  else {                            /* from outer most product to inner most */
    jj = 0;
    incr = 1;
  }

  for ( ii = numprods; (ii >= 0); ii-- ) {
    ex$get_path( index = jj, path = prodpath,
                 len = sizeof( prodpath ) );
/*
 *  See if config/uom_table exists for product
 *  NOTE:  prodpath ends in /
 */
    sprintf( uom_table, "%s%s/%s", prodpath, "config", UOM_TABLE );
    if ( ! access( uom_table, 04 ) ) {
      sts = UOM_read_table( uom_table, &puom_types );
      if ( ! (sts & 1) )
        break;
      UOM_merge_uom_types( osnum, &puom_types, &luom_types );
      UOM_free_type( &puom_types );
    }
    jj += incr;
  }

  if ( sts & 1 ) {
    sts = UOM_unchain_scales( luom_types );
    if ( sts & 1 ) {
      _FOR_LIST( UOM_TYPE, luom_types, tt ) {
        UOM_set_default_readout( &tt->primary );
        UOM_set_default_readout( &tt->secondary );
        UOM_set_default_readout( &tt->tertiary );
      } _END_LIST

      if ( uom_types ) {
        *uom_types = luom_types;
        luom_types = 0;
      }
    }
  }

  UOM_free_type( &puom_types );
  UOM_free_type( &luom_types );

  return sts;
}

int UOM_dump_variant( variants )
UOM_VARIANT *variants;
{
  int ii, jj;

  ii = 1;
  _FOR_LIST( UOM_VARIANT, variants, vv ) {
    printf( "  variant # %d\n", ii );

    printf( "     flags = 0x%x\n", vv->flags );
    printf( "     scale = %.17g\n", vv->scale );
    printf( "     scaleunits = <%s>\n", vv->scaleunits );
    printf( "     shift = %.17g\n", vv->shift );
    printf( "     shiftunits = <%s>\n", vv->shiftunits );

    printf( "     aliases\n" );
    jj = 0;
    while ( vv->alias[jj] ) {
      printf( "        <%s>\n", vv->alias[jj] );
      jj++;
    }

    ii ++;
  } _END_LIST

  return 1;
}

int UOM_quick_dump_variant( variants )
UOM_VARIANT *variants;
{
  int ii, jj;

  ii = 1;
  _FOR_LIST( UOM_VARIANT, variants, vv ) {
    printf( "  variant # %d\n", ii );
    printf( "     aliases\n" );
    jj = 0;
    while ( vv->alias[jj] ) {
      printf( "        <%s>\n", vv->alias[jj] );
      jj++;
    }

    ii ++;
  } _END_LIST

  return 1;
}


int UOM_dump_readout( str, ro )
char *str;
UOM_READOUT *ro;
{
  if ( str )
    printf( "  %s readout\n", str );
  else
    printf( "  readout\n" );
  printf( "    mode = %d\n", ro->mode );
  printf( "    precision = %d\n", ro->precision );
  printf( "    denominator = %d\n", ro->denominator );
  printf( "    intermeas_spacing = %d\n", ro->intermeas_spacing );
  printf( "    intrameas_spacing = %d\n", ro->intrameas_spacing );
  printf( "    justification = %d\n", ro->justification );
  printf( "    case_type = %d\n", ro->case_type );
  printf( "    decimal_char = %d\n", ro->decimal_char );
  printf( "    thousands_char = %d\n", ro->thousands_char );
  printf( "    left_fill_char = '%c'\n", ro->left_fill_char );
  printf( "    alias_displayed = %d\n", ro->alias_displayed );
  printf( "    leading_zeros = %d\n", ro->leading_zeros );
  printf( "    trailing_zeros = %d\n", ro->trailing_zeros );
  printf( "\n" );

  return 1;
}

int UOM_dump_type( types )
UOM_TYPE *types;
{
  int ii, jj;

  _FOR_LIST( UOM_TYPE, types, tt ) {
    printf( "\ntype = %s\n", tt->name );
    printf( "  flags = 0x%x\n", tt->flags );
    printf( "  defalias\n" );
    if ( ! tt->defalias )
      printf( "    NO DEFAULTS SPECIFIED\n" );
    else {
      jj = 0;
      while ( tt->defalias[jj] ) {
        printf( "    <%s>\n", tt->defalias[jj] );
        jj++;
      }
    }
    printf( "  dims =" );
    for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
      printf( " %d", tt->dims[ii] );
    printf( "\n" );

    UOM_dump_readout( "primary", &tt->primary );
    UOM_dump_readout( "secondary", &tt->secondary );
    UOM_dump_readout( "tertiary", &tt->tertiary );
    UOM_dump_variant( tt->variant );
  } _END_LIST

  return 1;
} 

int UOM_quick_dump_type( types )
UOM_TYPE *types;
{
  int ii, jj;

  _FOR_LIST( UOM_TYPE, types, tt ) {
    printf( "\ntype = %s\n", tt->name );
    printf( "  flags = 0x%x\n", tt->flags );
    printf( "  defalias\n" );
    if ( ! tt->defalias )
      printf( "    NO DEFAULTS SPECIFIED\n" );
    else {
      jj = 0;
      while ( tt->defalias[jj] ) {
        printf( "    <%s>\n", tt->defalias[jj] );
        jj++;
      }
    }
    printf( "  dims =" );
    for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
      printf( " %d", tt->dims[ii] );
    printf( "\n" );

    UOM_quick_dump_variant( tt->variant );
  } _END_LIST

  return 1;
} 

int UOM_get_message_string( msgnumb, str )
int msgnumb;
char **str;
{
  static char strbuf[ 1024 ];

  strbuf[0] = 0;
  *str = (char *) strbuf;

  switch ( msgnumb ) {
    case UOM_TYPE_TRUNC:
      sprintf( strbuf,
               "uom_table: unit type name <%%s> truncated to %d chars",
               UOM_K_MAX_TYPE - 1 );
      break;
    case UOM_UNKNOWN_DIM_KEYWORD:
      strcpy( strbuf, "uom_table: unknown dimensional keyword <%s>" );
      break;
    case UOM_INVALID_DIM_EXPONENT:
      strcpy( strbuf, "uom_table: invalid dimensional exponent" );
      break;
    case UOM_DIM_EXPONENT_RANGE:
      strcpy( strbuf,
              "uom_table: dimensional exponent out of range, -128 < e < 127" );
      break;
    case UOM_DEFALIAS_TRUNC:
      sprintf( strbuf,
       "uom_table: default alias <%%s> for unit <%%s> truncated to %d chars",
               UOM_K_MAX_ALIAS - 1 );
      break;
    case UOM_MAX_DEFALIAS:
      sprintf( strbuf,
               "uom_table: maximum of %d default aliases",
               UOM_K_MAX_DEFS );
      break;
    case UOM_ALIAS_TRUNC:
      sprintf( strbuf,
               "uom_table: unit alias <%%s> truncated to %d chars",
               UOM_K_MAX_ALIAS - 1 );
      break;
    case UOM_BAD_SCALEFAC:
      strcpy( strbuf, "uom_table: invalid scale factor" );
      break;
    case UOM_BAD_SHIFTFAC:
      strcpy( strbuf, "uom_table: invalid shift factor" );
      break;
    case UOM_EXPECT_TYPE:
      strcpy( strbuf, "uom_table: expecting \"type\" keyword" );
      break;
    case UOM_EXPECT_DEFAULT:
      strcpy( strbuf, "uom_table: expecting \"default\" keyword" );
      break;
    case UOM_DUP_TYPE:
      strcpy( strbuf, "uom_table: ignoring duplicate unit type <%s>" );
      break;
    case UOM_DUP_ALIAS:
      strcpy( strbuf,
              "uom_table: ignoring duplicate alias <%s> for unit type <%s>" );
      break;
    case UOM_EXPECTED_EQUAL_SIGN:
      strcpy( strbuf,
              "uom_table: equal sign expected after dimensional keyword" );
      break;
    case UOM_SCALEALIAS_NOT_FOUND:
      strcpy( strbuf,
              "uom_table: scale alias <%s> not found in unit type <%s>" );
      break;
    case UOM_DEFALIAS_NOT_FOUND:
      strcpy( strbuf,
              "uom_table: default alias <%s> not found in unit type <%s>" );
      break;
    case UOM_SHIFTALIAS_NOT_FOUND:
      strcpy( strbuf,
              "uom_table: shift alias <%s> not found in unit type <%s>" );
      break;
    case UOM_SCALEALIAS_TRUNC:
      sprintf( strbuf,
               "uom_table: scale alias <%%s> truncated to %d chars",
               UOM_K_MAX_ALIAS - 1 );
      break;
    case UOM_SHIFTALIAS_TRUNC:
      sprintf( strbuf,
               "uom_table: shift alias <%%s> truncated to %d chars",
               UOM_K_MAX_ALIAS - 1 );
      break;
    case UOM_CURR_LINENO:
      sprintf( strbuf,
               "uom_table: problem at or near line %d",
               UOM_curr_lineno );
      break;
  }

  return 1;
}

int UOM_echo_message( str )
char *str;
{
  if ( 1 ) {
    fprintf( stderr, "%s\n", str );
  }
  return 1;
}
