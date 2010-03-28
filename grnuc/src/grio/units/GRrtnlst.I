class implementation GRgnunit;

#include "UOMdef.h"
#include "UOM.h"
#include "UOMerrordef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

struct da_dims {
  char *unit_type;
  UOMdimensions dims;
};

%safe
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

static int compare_dims __((struct da_dims *dim1, struct da_dims *dim2));
static void lookup_dimensions __((char *unit_type, UOMdimensions dims));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


/* ------------------------------------------------------------------------ */

/* Doc:		return_list

   Abstract: 	This method returns instance data in uom list format

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      01-08-92	elp	2.0.0	Creation

   Return Status:
	OM_S_SUCCESS	-	Success
*/
/* *****************************H H H H H******************************* */

static int compare_dims( dim1, dim2 )
struct da_dims *dim1,
               *dim2;
{
  return( strcmp( dim1->unit_type, dim2->unit_type ) );
}

static void lookup_dimensions( unit_type, dims )
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

method return_list( char **uom_type )
{
  int sts, ii,jj;
  char *ptr = 0;
  int numalias;
  UOM_TYPE *utype = 0;
  UOM_VARIANT *variant = 0;
  char name[DI_PATH_MAX];
  char pathname[DI_PATH_MAX];
  UOM_READOUT uomreadout;

  extern char *strdup();

  *uom_type = 0;
  utype = (UOM_TYPE *) calloc( 1, sizeof( UOM_TYPE ) );
  sts = ( utype ) ? OM_S_SUCCESS : OM_E_NODYNMEM ;
  if ( ! (sts & 1) )
    goto wrapup;
  utype->next = utype->prev = utype;
  utype->flags = UOM_TS_STORED;
/*
 *  Get the name of the unit object, strip off leading UOM_ and convert
 *  rest to lower case
 */
  sts = di$untranslate( objname = pathname, objid = my_id );
  if ( ! (sts & 1) )
    goto wrapup;
  sts = di$split( pathname = pathname, name = name );
  if ( ! (sts & 1) )
    goto wrapup;

  if ( ! strncmp( name, "UOM_", 4 ) )
    strcpy( utype->name, &name[4] );
  else
    strcpy( utype->name, name );

  ptr = (char *) utype->name;
  while ( *ptr ) {
    *ptr = tolower( *ptr );
    ptr++;
  }

/*
 *  Lookup unit dimensions 
 */
  lookup_dimensions( utype->name, utype->dims );
/*
 *  Get readout specs
 */
  UOM_cvt_grio_readout( &me^^GRgnunit.readout_spec, &uomreadout );
  memcpy( &utype->primary, &uomreadout, sizeof( UOM_READOUT ) );
  memcpy( &utype->secondary, &uomreadout, sizeof( UOM_READOUT ) );
  memcpy( &utype->tertiary, &uomreadout, sizeof( UOM_READOUT ) );
/*
 *  Get the default units
 */
  utype->defalias = (char **) calloc( me^^GRunit.num_defs_in + 1,
                                      sizeof( char * ) );
  if ( ! utype->defalias ) {
    sts = OM_E_NODYNMEM;
    goto wrapup;
  }

  for ( ii = 0; (ii < me^^GRunit.num_defs_in); ii++ ) {
    utype->defalias[ii] = strdup( me^^GRunit.default_alias_in[ii] );
    if ( ! utype->defalias[ii] ) {
      sts = OM_E_NODYNMEM;
      goto wrapup;
    }
    ptr = (char *) utype->defalias[ii];
    while ( *ptr ) {
      *ptr = tolower( *ptr );
      ptr++;
    }
  }
/*
 *  Build list of unit variants
 */
  for ( ii=0; ( ii < me^^GRgnunit.num_definition ); ii++ ) {
    variant = (UOM_VARIANT *) calloc( 1, sizeof( UOM_VARIANT ) );
    if ( ! variant ) {
      sts = OM_E_NODYNMEM;
      goto wrapup;
    }
    variant->next = variant->prev = variant;

    variant->scale = me^^GRgnunit.unit_list[ii].working_units;
    variant->shift = 0.0;
    variant->scaleunits[0] = 0;
    variant->shiftunits[0] = 0;
    variant->type = utype;
    variant->flags = UOM_UC_SCALE | UOM_UC_SHIFT | UOM_TS_STORED;
/*
 *  Now store all the aliases for this variant
 */
    numalias = 0;
    for ( jj=0; ( jj < me^^GRunit.num_alias ); jj++ ) {
      if ( ii == me^^GRunit.alias_list[jj].index ) {
        int sz = (numalias + 2) * sizeof( char * );

        if ( ! variant->alias )
          variant->alias = (char **) malloc( sz );
        else
          variant->alias = (char **) realloc( variant->alias, sz );

        if ( ! variant->alias ) {
          sts = OM_E_NODYNMEM;
          goto wrapup;
        }

        variant->alias[ numalias + 1 ] = 0;

        variant->alias[ numalias ] = strdup( me^^GRunit.alias_list[jj].alias );
        if ( ! variant->alias[ numalias ] ) {
          sts = OM_E_NODYNMEM;
          goto wrapup;
        }
        ptr = (char *) variant->alias[numalias];
        while ( *ptr ) {
          *ptr = tolower( *ptr );
          ptr++;
        }
        numalias ++;
      }  /* END if ( ii == me^^GRunit.alias_list[jj].index ) */
    }  /* END for ( jj=0; ( jj < me^^GRunit.num_alias ); jj++ ) */

    UOM_list_append( variant, &utype->variant );
    variant = 0;
  }  /* END for ( ii=0; ( ii < me^^GRgnunit.num_definition ); ii++ ) */

  *uom_type = (char *) utype;
  utype = 0;

wrapup:
  UOM_free_type( &utype );
  UOM_free_variant( &variant );
  return sts;
}

end implementation GRgnunit;
