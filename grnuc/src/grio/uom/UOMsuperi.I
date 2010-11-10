class implementation UOMsuper;


#define	__malloc_h
#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "OMlimits.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "msdef.h"
#include "hash.h"
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

#include "csdef.h"
#include "csmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "UOMmacros.h"
/* #include "UOMextern.h" */

#define TYPETABLESIZE 97
#define ALIASTABLESIZE 197

/*
 *  UOM globals 
 */

%safe
int UOM_G_inner_to_outer = 1;
%endsafe

struct UOM_osnum_entry {
  struct UOM_osnum_entry *next;
  struct UOM_osnum_entry *prev;
  OMuword osnum;
  UOM_TYPE *uom_types;
  int executed_temp_sleep;
  int executed_wake_up;
  HASHTABLE *TypeTable;
  HASHTABLE *DimsTable;
};
typedef struct UOM_osnum_entry UOM_OSNUM_ENTRY;

%safe
static OM_p_FUNCPTR *notify_fcts = 0;
static UOM_OSNUM_ENTRY *osnum_table = 0;
%endsafe

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

static int hash_dim __((char dim[], int tblsize));
static int cmp_dim __((char dim0[], char dim1[]));
static int UOM_lookup_osnum_table_entry __((OMuword osnum, int create, 
                                            UOM_OSNUM_ENTRY **table_entry));
static int UOM_create_hashtables __((UOM_OSNUM_ENTRY *ote));
static int UOM_remove_duplicate_types __((UOM_OSNUM_ENTRY *ote));
static int UOM_remove_duplicate_aliases __((UOM_OSNUM_ENTRY *ote));
#ifdef DEBUG
static int UOM_dump_hashtables __((UOM_OSNUM_ENTRY *ote));
#endif

#ifndef SUNOS
extern char *strdup __((const char *));
#endif

extern int UOM_convert_old_unit_objects __(( OMuword osnum,
                                             UOM_TYPE **ouom_types ));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



from GRgencs import GRcsgetscale;
from GRgnunit import return_list;

/******************************************************************************/


#if defined(__STDC__) || defined(__cplusplus)
static int UOM_lookup_osnum_table_entry( OMuword           osnum, 
                                         int               create, 
                                         UOM_OSNUM_ENTRY **table_entry )
#else
static int UOM_lookup_osnum_table_entry( osnum, create, table_entry )
OMuword osnum;
int create;
UOM_OSNUM_ENTRY **table_entry;
#endif
{
  int sts = OM_S_SUCCESS;

  *table_entry = 0;

  _FOR_LIST( UOM_OSNUM_ENTRY, osnum_table, ote ) {
    if ( osnum == ote->osnum ) {
      *table_entry = ote;
      break;
    }
  } _END_LIST

  if ( ! *table_entry ) {
    if ( create ) {
      UOM_OSNUM_ENTRY *ote;

      ote = (UOM_OSNUM_ENTRY *) calloc( 1, sizeof( UOM_OSNUM_ENTRY ) );
      if ( ! ote ) {
        sts = OM_E_NODYNMEM;
        goto wrapup;
      }
      ote->osnum = osnum;
      ote->prev = ote->next = ote;
      UOM_list_append( ote, &osnum_table );
      *table_entry = ote;
    }
  }

wrapup:
  return sts;
}

method store_list( UOM_TYPE **uom_types )
{
  int sts;

  sts = UOM_S_SUCCESS;

  _FOR_LIST( UOM_TYPE, *uom_types, tt ) {
    if ( tt->flags & UOM_TS_STORED ) {
      sts = om$send( msg = message UOMsuper.store_unit_type( tt ),
                     targetid = my_id );
      if ( sts & 1 ) {
        tt->flags |= UOM_TS_FILED;            /* now filed in os */
        tt->flags &= ~UOM_TS_STORED;          /* now stored in os */
      }
      else
        goto wrapup;

      _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
        sts = om$send( msg = message UOMsuper.store_unit_variant( tt->name,
                                                                  vv ),
                       targetid = my_id );
        if ( sts & 1 ) {
          vv->flags |= UOM_TS_FILED;            /* now filed in os */
          vv->flags &= ~UOM_TS_STORED;          /* now stored in os */
        }
        else
          goto wrapup;
      } _END_LIST
    }
  } _END_LIST

wrapup:
  return sts;
}

method retrieve_list( UOM_TYPE **uom_types )
{
  int sts;
  int ii, jj;
  int ntypes, nvars;
  UOM_TYPE *tt = 0;
  UOM_VARIANT *vv = 0;
  UOM_TYPE *luom_types = 0;

  *uom_types = 0;

  sts = OM_S_SUCCESS;
  ntypes = om$dimension_of( varray = me->type );
  if ( ntypes > 0 ) {
    UOMS_TYPE *mt;
/*
 *  Build list of my unit types
 */
    mt = &me->type[0];
    for ( ii = 0; (ii < ntypes); ii++, mt++ ) {
      tt = (UOM_TYPE *) calloc( 1, sizeof( UOM_TYPE ) );
      if ( ! tt ) {
        sts = OM_E_NODYNMEM;
        goto ret_error_exit;
      }
/*
 *  Build the type node
 */
      tt->next = tt->prev = tt;
      tt->flags = UOM_TS_FILED;
      strcpy( tt->name, mt->name );
      UOM_CpyUnit( tt->dims, mt->dims );
      memcpy( &tt->primary, &mt->primary, sizeof( UOM_READOUT ) );
      memcpy( &tt->secondary, &mt->secondary, sizeof( UOM_READOUT ) );
      memcpy( &tt->tertiary, &mt->tertiary, sizeof( UOM_READOUT ) );
      jj = 0;
      while ( jj < UOM_K_MAX_DEFS ) {
        if ( mt->defalias[jj][0] )
          jj++;
        else
          break;
      }
      tt->defalias = (char **) calloc( jj + 1, sizeof( char * ) );
      if ( ! tt->defalias ) {
        sts = OM_E_NODYNMEM;
        goto ret_error_exit;
      }
      jj = 0;
      while ( jj < UOM_K_MAX_DEFS ) {
        if ( mt->defalias[jj][0] ) {
          if ( ! ( tt->defalias[jj] = strdup( mt->defalias[jj] ) ) ) {
            sts = OM_E_NODYNMEM;
            goto ret_error_exit;
          }
          jj++;
        }
        else
          break;
      }
/*
 *  Now find all the variants that belong to this type
 */
      nvars = om$dimension_of( varray = me->variant );
      if ( nvars > 0 ) {
        UOMS_VARIANT *mv;

        mv = &me->variant[0];
        for ( jj = 0; (jj < nvars); jj++, mv++ ) {
          if ( mv->type == ii ) {
            int numalias;
            char *tk, *ma, *aliases;

            ma = &me->pkey[ mv->pkey ];
            if ( ! ( aliases = strdup( ma ) ) ) {
              sts = OM_E_NODYNMEM;
              goto ret_error_exit;
            }
            vv = (UOM_VARIANT *) calloc( 1, sizeof( UOM_VARIANT ) );
            if ( ! vv ) {
              sts = OM_E_NODYNMEM;
              goto ret_error_exit;
            }
/*
 *  Build the variant node
 */
            vv->next = vv->prev = vv;
            vv->flags = UOM_UC_SCALE | UOM_UC_SHIFT | UOM_TS_FILED;
            vv->scale = mv->scale;
            vv->shift = mv->shift;
            vv->type = tt;
/*
 *  Now gather the aliases for this variant
 */
            numalias = 0;
            tk = strtok( aliases, " " );
            while ( tk ) {
              int sz = (numalias + 2) * sizeof( char * );

              if ( ! vv->alias )
                vv->alias = (char **) malloc( sz );
              else
                vv->alias = (char **) realloc( vv->alias, sz );

              if ( ! vv->alias ) {
                sts = OM_E_NODYNMEM;
                goto ret_error_exit;
              }

              vv->alias[ numalias + 1 ] = 0;

              if ( ! ( vv->alias[ numalias ] = strdup( tk ) ) ) {
                sts = OM_E_NODYNMEM;
                goto ret_error_exit;
              }
              numalias ++;

              tk = strtok( 0, " " );
            }  /* END while ( tk ) */

            UOM_list_append( vv, &tt->variant );
            vv = 0;

            free( aliases );

          }  /* END if ( mv->type == ii ) */
        }  /* END for all variants */
      }  /* END if some variants */

      UOM_list_append( tt, &luom_types );
      tt = 0;

    }  /* END for all types */

    *uom_types = luom_types;
    luom_types = 0;

  }  /* END if some types */

ret_error_exit:
  UOM_free_variant( &vv );

  UOM_free_type( &tt );
  UOM_free_type( &luom_types );

  return sts;
}

/*
 *  Merge filed unit info into my instance data
 */

method global_class.sleep( IGRint sleep_type )
{
  int sts;
  UOM_OSNUM_ENTRY *ote = 0;

  sts = UOM_lookup_osnum_table_entry( OM_Gw_current_OS, 0, &ote );
  if ( ! (sts & 1) )
    goto ret_error_exit;

  if ( ! ote )
    goto ret_error_exit;

  sts = om$send( msg = message UOMsuper.store_list( &ote->uom_types ),
                 targetid = my_id );
  if ( sts & 1 ) {
    if ( ! sleep_type ) {
      if ( ote->TypeTable )
        hashfree( ote->TypeTable ), ote->TypeTable = 0;
      if ( ote->DimsTable )
        hashfree( ote->DimsTable ), ote->DimsTable = 0;
      sts = UOM_free_type( &ote->uom_types );
      sts = UOM_list_remove( ote, &osnum_table );
      if ( ! osnum_table )   /* last one removed */
        if ( notify_fcts )
          free( notify_fcts ), notify_fcts = 0;
      free( ote );
      ote = 0;
    }
    else
      ote->executed_temp_sleep = 1;
  }

ret_error_exit:
  return OM_S_SUCCESS;
}

/*
 *  All my unit variants that are not defined already should be added to
 *  the global unit table.
 */

method wake_up()
{
  int sts;
  UOM_OSNUM_ENTRY *ote = 0;

  UOM_TYPE *cuom_types = 0;       /* config uom type list */
  UOM_TYPE *suom_types = 0;       /* super uom type list */
  UOM_TYPE *ouom_types = 0;       /* old unit objects converted to list */

  sts = UOM_lookup_osnum_table_entry( OM_Gw_current_OS, 1, &ote );
  if ( ! (sts & 1) )
    goto ret_error_exit;

  if ( ote->executed_temp_sleep ) {
    ote->executed_temp_sleep = 0;
    goto ret_error_exit;
  }

  if ( ote->executed_wake_up )
    goto ret_error_exit;

  ote->executed_wake_up = 1;
/*
 *  Convert old unit objects to list
 */
  sts = UOM_convert_old_unit_objects( OM_Gw_current_OS, &ouom_types );
  if ( ! (sts & 1) )
    goto ret_error_exit;
  if ( ouom_types ) {
    sts = om$send( msg = message UOMsuper.store_list( &ouom_types ),
                   targetid = my_id );
    if ( ! (sts & 1) )
      goto ret_error_exit;
    UOM_free_type( &ouom_types );
  }
/*
 *  Get my unit types
 */
  sts = om$send( msg = message UOMsuper.retrieve_list( &suom_types ),
                 targetid = my_id );
  if ( ! (sts & 1) )
    goto ret_error_exit;
/*
 *  Get the unit types stored in the config/uom_table
 */
  sts = UOM_init( OM_Gw_current_OS, &cuom_types );
  if ( ! (sts & 1) )
    goto ret_error_exit;
/*
 *  Merge them
 */
  ote->uom_types = suom_types;
  suom_types = 0;
  UOM_merge_uom_types( OM_Gw_current_OS, &cuom_types, &ote->uom_types );
  UOM_free_type( &cuom_types );
  sts = UOM_create_hashtables( ote );
#ifdef DEBUG
  UOM_dump_hashtables( ote );
#endif
  if ( ! (sts & 1) )
    goto ret_error_exit;

ret_error_exit:
  UOM_free_type( &cuom_types );
  UOM_free_type( &suom_types );
  UOM_free_type( &ouom_types );

  return OM_S_SUCCESS;
}

/******************************************************************************/

method debug()
{
  int sts;
  UOM_TYPE *suom_types = 0;       /* super uom type list */

  sts = om$send( msg = message UOMsuper.retrieve_list( &suom_types ),
                 targetid = my_id );
  if ( sts & 1 ) {
    om$send( msg = message Root.debug(),
             targetid = my_id, mode = OM_e_wrt_message );
    sts = UOM_dump_type( suom_types );
  }

  UOM_free_type( &suom_types );

  return OM_S_SUCCESS;
}

/******************************************************************************/

method store_unit_readout( char *typename;
                           UOM_READOUT *primary, *secondary, *tertiary )
{
  int sts;

  if ( typename ) {
    int ntypes, foundit;
    UOMS_TYPE *mt = 0;

    foundit = 0;
    ntypes = om$dimension_of( varray = me->type );
    if ( ntypes > 0 ) {
      int ii;

      mt = &me->type[ 0 ];
      for ( ii = 0; (ii < ntypes); ii++, mt++ ) {
        if ( ! strcmp( typename, mt->name ) ) {
          foundit = 1;
          break;
        }
      }
    }

    if ( ! foundit )
      sts = UOM_E_TYPE_NOT_FOUND;
    else {
      sts = UOM_S_SUCCESS;
      if ( primary )
        memcpy( &mt->primary, primary, sizeof( UOM_READOUT ) );
      if ( secondary )
        memcpy( &mt->secondary, secondary, sizeof( UOM_READOUT ) );
      if ( tertiary )
        memcpy( &mt->tertiary, tertiary, sizeof( UOM_READOUT ) );
    }
  }
  else
    sts = UOM_E_UNEXPECTED_NULL_PTR;

  return sts;
}

/******************************************************************************/

method store_unit_type( UOM_TYPE *type )
{
  int sts;

  if ( type ) {
    int ntypes;
    int ii, addit;
    UOMS_TYPE *mt = 0;

    addit = 1;
    sts = UOM_S_SUCCESS;
    ntypes = om$dimension_of( varray = me->type );
    if ( ntypes > 0 ) {
      mt = &me->type[ 0 ];
      for ( ii = 0; (ii < ntypes); ii++, mt++ ) {
        if ( ! strcmp( type->name, mt->name ) ) {
          addit = 0;
          break;
        }
      }
    }

    if ( addit ) {
      sts = om$vla_set_dimension( varray = me->type, size = ntypes + 1 );
      if ( sts & 1 ) {
        mt = &me->type[ ntypes ];
        memset( mt, 0, sizeof( *mt ) );
        strcpy( mt->name, type->name );
      }
    }

    if ( sts & 1 ) {
      UOM_CpyUnit( mt->dims, type->dims );
      memcpy( &mt->primary, &type->primary, sizeof( UOM_READOUT ) );
      memcpy( &mt->secondary, &type->secondary, sizeof( UOM_READOUT ) );
      memcpy( &mt->tertiary, &type->tertiary, sizeof( UOM_READOUT ) );

      if ( type->defalias ) {
        ii = 0;
        while ( type->defalias[ ii ] ) {
          if ( ii < UOM_K_MAX_DEFS ) {
            strcpy( mt->defalias[ ii ], type->defalias[ ii ] );
            ii++;
          }
          else
            break;
        }
        for ( ; (ii < UOM_K_MAX_DEFS); ii++ )
          strcpy( mt->defalias[ ii ], "" );
      }
    }
  }
  else
    sts = UOM_E_UNEXPECTED_NULL_PTR;

  return sts;
}

/******************************************************************************/

method store_unit_variant( char *typename; UOM_VARIANT *variant )
{
  int sts;

  if ( typename && variant ) {
    int typekey;
    int ii, ntypes;
    UOMS_TYPE *mt = 0;
/*
 *  Find the unit type that this variant will belong to
 */
    typekey = -1;
    ntypes = om$dimension_of( varray = me->type );
    if ( ntypes > 0 ) {
      mt = &me->type[ 0 ];
      for ( ii = 0; (ii < ntypes); ii++, mt++ ) {
        if ( ! strcmp( typename, mt->name ) ) {
          typekey = ii;
          break;
        }
      }
    }

    if ( typekey == -1 )
      sts = UOM_E_TYPE_NOT_FOUND;
    else {
      int addit;
      int jj, nvars;
      char *aliases = 0;
      UOMS_VARIANT *mv = 0;
/*
 *  Got the unit type, verify that all the aliases for this variant do
 *  not exist.
 */
      addit = 1;
      sts = UOM_S_SUCCESS;
      nvars = om$dimension_of( varray = me->variant );
      if ( nvars > 0 ) {
        mv = &me->variant[0];
        for ( ii = 0; (ii < nvars); ii++, mv++ ) {
          if ( mv->type == typekey ) {
            jj = 0;
            addit = 1;
            while ( variant->alias[ jj ] ) {
              char *tk, *ma;

              ma = &me->pkey[ mv->pkey ];
              if ( ! ( aliases = strdup( ma ) ) ) {
                sts = OM_E_NODYNMEM;
                break;
              }

              tk = strtok( aliases, " " );
              while ( tk ) {
                if ( ! strcmp( variant->alias[ jj ], tk ) ) {
                  addit = 0;
                  break;
                }
                tk = strtok( 0, " " );
              }
              free( aliases );
              aliases = 0;

              if ( ! addit )
                break;
              jj++;
            }  /* END while ( variant->alias[ jj ] ) */

            if ( ! ( sts & 1 ) )
              break;

            if ( ! addit )
              break;
          }  /* END if ( mv->type == typekey ) */
        }  /* END for ( ii = 0; (ii < nvars); ii++, mv++ ) */
      }  /* END if ( nvars > 0 ) */

      if ( (sts & 1) && addit ) {
        sts = om$vla_set_dimension( varray = me->variant, size = nvars + 1 );
        if ( sts & 1 ) {
          int nbytes = 0;

          mv = &me->variant[ nvars ];
          memset( mv, 0, sizeof( *mv ) );

          jj = 0;
          aliases = 0;
          while ( variant->alias[ jj ] ) {
            int sz = nbytes + strlen( variant->alias[ jj ] ) + 1;

            if ( ! aliases )
              aliases = (char *) malloc( sz );
            else
              aliases = (char *) realloc( aliases, sz );

            if ( ! aliases ) {
              sts = OM_E_NODYNMEM;
              break;
            }

            if ( nbytes == 0 )
              strcpy( aliases, variant->alias[ jj ] );
            else {
              strcat( aliases, " " );
              strcat( aliases, variant->alias[ jj ] );
            }
            nbytes = sz;

            jj++;
          }

          if ( sts & 1 ) {
            int npkey;

            npkey = om$dimension_of( varray = me->pkey );
            sts = om$vla_set_dimension( varray = me->pkey,
                                        size = npkey + nbytes );
            if ( sts & 1 ) {
              strcpy( &me->pkey[ npkey ], aliases );
              mv->type = typekey;
              mv->scale = variant->scale;
              mv->shift = variant->shift;
              mv->pkey = npkey;
              free( aliases );
              aliases = 0;
            }
          }

          if ( aliases )
            free( aliases );

        }  /* END if ( sts & 1 ) */
      }  /* END if ( (sts & 1) && addit ) */
    }  /* END else typekey != -1 */
  }  /* END if ( typename && variant ) */
  else
    sts = UOM_E_UNEXPECTED_NULL_PTR;

  return sts;
}

/******************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
int UOM_convert_old_unit_objects( OMuword osnum, UOM_TYPE **ouom_types )
#else
int UOM_convert_old_unit_objects( osnum, ouom_types )
OMuword osnum;
UOM_TYPE **ouom_types;
#endif
{
  int sts = UOM_S_SUCCESS;
  struct GRid *grids = 0;
  int ii,ngrids = 0;
  OMuword unit_os;
  OM_S_OBJID md_id,unit_id;
  OM_S_OBJID IGENOD_id;
  char IGENOD[DI_PATH_MAX];
  UOM_TYPE *uom_type = 0;
  UOM_TYPE *luom_types = 0;

  *ouom_types = 0;

  sts = ex$get_modid( mod_osnum = osnum, mod_id = &md_id );
  if ( ! (sts & 1) )
    goto wrapup;
  sts = ex$get_NOD( mod_osnum = osnum, modid = md_id,
                    NODname = "IGENOD", pobjid = &IGENOD_id );
  if ( ! (sts & 1) )
    goto wrapup;
  sts = di$untranslate( objname = IGENOD, objid = IGENOD_id,
                        osnum = osnum );
  if ( ! (sts & 1) )
    goto wrapup;
  sts = di$find( start_dir = IGENOD, regexp = "UOM_*",
                 grids = (DIgrid **)&grids, ptr = &ngrids );
  if ( sts == OM_W_NAMENOTFOUND ) {
    sts = OM_S_SUCCESS;
    goto wrapup;
  }

  if ( ! (sts & 1) )
    goto wrapup;
/*
 *  Find all NOD whose name starts with UOM_
 */
  for ( ii = 0; (ii < ngrids); ii++ ) {
    OMuword classid;
    extern OMuword OPP_GRgnunit_class_id;

    unit_id = grids[ii].objid;
    unit_os = grids[ii].osnum;
    sts = om$get_classid( osnum = unit_os, objid = unit_id,
                          p_classid = &classid );
    if ( ! (sts & 1) )
      goto wrapup;
    sts = om$is_ancestry_valid( superclassid = OPP_GRgnunit_class_id,
                                subclassid = classid );
    if ( sts == OM_S_SUCCESS ) {
      sts = om$send( msg = message GRgnunit.return_list( (char **) &uom_type ),
                     senderid = NULL_OBJID,
                     targetid = unit_id, targetos = unit_os );
      if ( ! (sts & 1) )
        goto wrapup;

      UOM_list_append( uom_type, &luom_types );
      uom_type = 0;
      sts = di$rm_objid( objid = unit_id, osnum = unit_os );
      sts = om$send( msg = message Root.delete( 0 ),
                     senderid = NULL_OBJID,
                     targetid = unit_id, targetos = unit_os );
      if ( ! (sts & 1) )
        goto wrapup;
    }
  }

  *ouom_types = luom_types;
  luom_types = 0;

wrapup:
  if ( grids )
    free( grids );
  UOM_free_type( &luom_types );
  UOM_free_type( &uom_type );

  return sts;
}

/******************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
int UOM_get_super_objid( OMuword osnum, OM_S_OBJID *uom_super )
#else
int UOM_get_super_objid( osnum, uom_super )
OMuword osnum;
OM_S_OBJID *uom_super;
#endif
{
/*
 * Unit types are stored in the super object.  Construct
 * one if one does not already exist.
 */
  int sts;
  OM_S_OBJID mod_id;

  if ( ! uom_super )
    sts = UOM_E_UNEXPECTED_NULL_PTR;
  else {
    *uom_super = NULL_OBJID;
    sts = ex$get_modid( mod_osnum = osnum, mod_id = &mod_id );
  }

  if ( sts & 1 ) {
/*
 *  See if uom super exists
 */
    sts = ex$get_objid_from_NOD( NODname = "IGENOD", objname = UOM_K_SUPERNAME,
                                 modid = mod_id, mod_osnum = osnum,
                                 pobjid = uom_super );
    if ( sts == OM_W_NAMENOTFOUND ) {
/*
 *  Does not exist, so create it.
 */
      sts = ex$get_super( mod_id = mod_id, mod_osnum = osnum,
                          super_name = UOM_K_SUPERNAME,
                          super_class = UOM_K_SUPERCLASS,
                          create = 1, super_id = uom_super );
      if ( sts & 1 )
        sts = UOM_I_CREATED;        /* signifies super was created */
    }
    else if ( sts & 1 ) {
/*
 *  Send wakeup now instead of waiting until module wakes us up.  We do this
 *  to be sure the UOM data structures are initialized when data is accessed.
 */
      sts = om$send( msg = message global_class.wake_up(),
                     senderid = NULL_OBJID,
                     targetos = osnum,
                     targetid = *uom_super );
      if ( sts & 1 )
        sts = UOM_S_SUCCESS;        /* signifies super already exists */
    }
  }

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_lookup_type_locally( OMuword osnum, char *name, char *dims,
                             UOM_TYPE *types, UOM_TYPE **type )
#else
int UOM_lookup_type_locally( osnum, name, dims, types, type )
OMuword osnum;
char *name;
char *dims;
UOM_TYPE *types;
UOM_TYPE **type;
#endif
{
  int sts;
  UOM_OSNUM_ENTRY *ote = 0;

  *type = 0;

  sts = UOM_lookup_osnum_table_entry( osnum, 0, &ote );
  if ( ! (sts & 1) )
    goto ret_error_exit;

  if ( name ) {
    UOMtype_name tname;

    if ( ! strncmp( name, "UOM_", 4 ) )
      strcpy( tname, &name[4] );
    else
      strcpy( tname, name );
    UOM_cvt_to_lower( tname );

    if ( ote && ote->TypeTable ) {
      UOM_TYPE_HASH *th = (UOM_TYPE_HASH *) hashlookup( ote->TypeTable, tname );

      if ( th )
        *type = th->type;
    }
    else {
      _FOR_LIST( UOM_TYPE, types, tt ) {
        if ( ! strcmp( tname, tt->name ) ) {
          *type = tt;
          break;
        }
      } _END_LIST
    }
  }
  else if ( dims ) {
    if ( ote && ote->DimsTable ) {
      int nmatches;
      UOM_DIMS_HASH **matches;

      if ( nmatches = hashdlookup( ote->DimsTable, dims, &matches ) ) {
        *type = matches[0]->type;            /* is this first one added */
/*      *type = matches[nmatches-1]->type;         or is this ???       */
        free( matches );
      }
    }
    else {
      _FOR_LIST( UOM_TYPE, types, tt ) {
        if ( UOM_EquUnit( tt->dims, dims ) ) {
          *type = tt;
          break;
        }
      } _END_LIST
    }
  }

ret_error_exit:
  return OM_S_SUCCESS;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_lookup_alias_locally( UOM_TYPE *type, char *alias,
                              UOM_VARIANT **variant )
#else
int UOM_lookup_alias_locally( type, alias, variant )
UOM_TYPE *type;
char *alias;
UOM_VARIANT **variant;
#endif
{
  UOMalias_name talias;

  strcpy( talias, alias );
  UOM_cvt_to_lower( talias );
/*
 *  Loop thru each unit variant until the specified alias is found or all
 *  variants have been processed
 */
  *variant = 0;
  if ( type->aliashashtab ) {
    UOM_ALIAS_HASH *ah = (UOM_ALIAS_HASH *) hashlookup( 
                                              (HASHTABLE *)type->aliashashtab,
                                              talias );

    if ( ah )
      *variant = ah->variant;
  }
  else {
    _FOR_LIST( UOM_VARIANT, type->variant, vv ) {
      if ( vv->alias ) {
        int ii = 0;

        while ( vv->alias[ii] ) {
          if ( ! strcmp( vv->alias[ii], talias ) ) {
            *variant = vv;
            break;
          }
          ii++;
        }

        if ( *variant )
          break;
      }
    } _END_LIST
  }

  return OM_S_SUCCESS;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_lookup_dims( OMuword osnum, char *typename, char *alias, UOMdimensions dims )
#else
int UOM_lookup_dims( osnum, typename, alias, dims )
OMuword osnum;
char *typename;
char *alias;
UOMdimensions dims;
#endif
{
  int sts;
  UOM_OSNUM_ENTRY *ote = 0;

  if ( ! dims )
    sts = UOM_E_UNEXPECTED_NULL_PTR;
  else {
    OM_S_OBJID super;

    UOM_NoUnit( dims );
    sts = UOM_get_super_objid( osnum, &super );
    if ( sts & 1 )
      sts = UOM_lookup_osnum_table_entry( osnum, 0, &ote );
  }

  if ( (sts & 1) && ote && ote->uom_types ) {
    if ( typename ) {
      UOM_TYPE *tt;

      UOM_lookup_type( osnum, typename, 0, &tt );
      if ( tt ) {
        UOM_CpyUnit( dims, tt->dims );
        sts = UOM_S_SUCCESS;
      }
      else
        sts = UOM_E_TYPE_NOT_FOUND;
    }
    else if ( alias ) {
      UOM_VARIANT *vv;

      UOM_lookup_alias( osnum, alias, &vv );
      if ( vv ) {
        UOM_CpyUnit( dims, vv->type->dims );
        sts = UOM_S_SUCCESS;
      }
      else
        sts = UOM_E_ALIAS_NOT_FOUND;
    }
    else
      sts = UOM_E_UNEXPECTED_NULL_PTR;
  }

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_lookup_alias( OMuword osnum, char *alias, UOM_VARIANT **variant )
#else
int UOM_lookup_alias( osnum, alias, variant )
OMuword osnum;
char *alias;
UOM_VARIANT **variant;
#endif
{
  int sts;
  UOM_OSNUM_ENTRY *ote = 0;
  int uom_sts = UOM_S_SUCCESS;
  char *ch;
  int len;
  char mytype[ UOM_K_MAX_TYPE ];
  char myalias[ UOM_K_MAX_ALIAS ];

  if ( ! variant || ! alias )
    sts = UOM_E_UNEXPECTED_NULL_PTR;
  else {
    OM_S_OBJID super;

    *variant = 0;
    sts = UOM_get_super_objid( osnum, &super );
    if ( sts & 1 )
      sts = UOM_lookup_osnum_table_entry( osnum, 0, &ote );
  }

  if ( (sts & 1) && ote && ote->uom_types ) {
/*
 *  See if lookup is restricted to a specific unit type
 */
    if ( ch = strchr( alias, ':' ) ) {
      UOM_TYPE *tt;

      len = ch - alias;
      if ( len >= UOM_K_MAX_ALIAS ) {
        len = UOM_K_MAX_ALIAS - 1;
        uom_sts = UOM_I_ALIAS_TRUNCATED;
      }
      strncpy( myalias, alias, len );
      myalias[ len ] = 0;
      len = strlen( &ch[1] );
      if ( len >= UOM_K_MAX_TYPE ) {
        len = UOM_K_MAX_TYPE - 1;
        uom_sts = UOM_I_TYPE_TRUNCATED;
      }
      strncpy( mytype, &ch[1], len );
      mytype[ len ] = 0;
      UOM_lookup_type( osnum, mytype, 0, &tt );
      if ( tt ) {
        UOM_lookup_alias_locally( tt, myalias, variant );
        if ( *variant )
          sts = UOM_S_SUCCESS;
        else
          sts = UOM_E_ALIAS_NOT_FOUND;
      }
      else
        sts = UOM_E_TYPE_NOT_FOUND;
    }
    else {
      sts = UOM_E_ALIAS_NOT_FOUND;
      _FOR_LIST( UOM_TYPE, ote->uom_types, tt ) {
        UOM_lookup_alias_locally( tt, alias, variant );
        if ( *variant ) {
          sts = UOM_S_SUCCESS;
          break;
        }
      } _END_LIST
    }
  }

  return ( sts & 1 ) ? uom_sts : sts ;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_readout_spec( OMuword osnum, char *typename, int inquire,
                      UOM_READOUT *primary, UOM_READOUT *secondary,
                      UOM_READOUT *tertiary )
#else
int UOM_readout_spec( osnum, typename, inquire, primary, secondary, tertiary )
OMuword osnum;
char *typename;
int inquire;
UOM_READOUT *primary;
UOM_READOUT *secondary;
UOM_READOUT *tertiary;
#endif
{
  int sts;
  UOM_TYPE *tt;

  UOM_lookup_type( osnum, typename, 0, &tt );
  if ( ! tt ) {
    sts = UOM_E_TYPE_NOT_FOUND;
    goto ret_error_exit;
  }

  if ( ! primary && ! secondary && ! tertiary ) {
    sts = UOM_S_SUCCESS;
    goto ret_error_exit;
  }

  sts = UOM_S_SUCCESS;
  if ( inquire ) {
    if ( primary )
      memcpy( primary, &tt->primary, sizeof( UOM_READOUT ) );
    if ( secondary )
      memcpy( secondary, &tt->secondary, sizeof( UOM_READOUT ) );
    if ( tertiary )
      memcpy( tertiary, &tt->tertiary, sizeof( UOM_READOUT ) );
  }
  else {
    if ( primary )
      memcpy( &tt->primary, primary, sizeof( UOM_READOUT ) );
    if ( secondary )
      memcpy( &tt->secondary, secondary, sizeof( UOM_READOUT ) );
    if ( tertiary )
      memcpy( &tt->tertiary, tertiary, sizeof( UOM_READOUT ) );
    tt->flags |= UOM_TS_STORED;
    UOM_call_notify_functions( osnum, typename, 0 );
  }

ret_error_exit:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_convert_to_readout( OMuword osnum, double ivalue, char *ialias,
                            char *typename, int *num_oalias,
                            UOMalias_name *oalias, UOM_READOUT *readout,
                            short *field_size, short *fraction_mode,
                            char *out_buf )
#else
int UOM_convert_to_readout( osnum, ivalue, ialias, typename, num_oalias, oalias,
                            readout, field_size, fraction_mode, out_buf )
OMuword osnum;
double ivalue;
char *ialias;
char *typename;
int *num_oalias;
UOMalias_name *oalias;
UOM_READOUT *readout;
short *field_size;
short *fraction_mode;
char *out_buf;
#endif
{
  int sts;
  int uom_sts = UOM_S_SUCCESS;
  double ovalue, value;

  out_buf[0] = 0;
  sts = UOM_convert_value_to_dbu( osnum, ivalue, ialias, &ovalue, 0 );
  if ( sts & 1 ) {
    int ii = 0;
    char talias[ UOM_K_MAX_ALIAS ];
    short num_alias = 0;
    UOMalias_name *alias = 0;
    int num_defaults = 0;
    UOMalias_name defaults[ UOM_K_MAX_DEFS ];
    UOM_READOUT oreadout;
    char *ch = 0;

    if ( oalias ) {
      if ( ! num_oalias ) {
        num_alias = 1;
        uom_sts = UOM_I_MIN_DEFS_EXCEEDED;
      }
      else if ( *num_oalias < 1 ) {
        num_alias = 1;
        uom_sts = UOM_I_MIN_DEFS_EXCEEDED;
      }
      else if ( *num_oalias > UOM_K_MAX_DEFS ) {
        num_alias = UOM_K_MAX_DEFS;
        uom_sts = UOM_I_MAX_DEFS_EXCEEDED;
      }
      else
        num_alias = (short) *num_oalias;

      if ( typename ) {
/*
 *  Qualify aliases that are not qualified
 */
        for ( ii = 0; (ii < num_alias); ii++ ) {
          if ( strchr( oalias[ii], ':' ) )
            strcpy( defaults[ii], oalias[ii] );
          else
            sprintf( defaults[ii], "%s:%s", oalias[ii], typename );
        }
      }
      else {
/*
 *  Use what was given
 */
        for ( ii = 0; (ii < num_alias); ii++ )
          strcpy( defaults[ii], oalias[ii] );
      }
    }
    else if ( typename ) {
/*
 *  Use the defaults for the specified unit type
 */
      sts = UOM_default_units( osnum, typename, 1, &num_defaults, defaults );
      if ( sts & 1 ) {
        for ( ii = 0; (ii < num_defaults); ii++ ) {
          strcpy( talias, defaults[ ii ] );
          sprintf( defaults[ ii ], "%s:%s", talias, typename );
        }

        if ( num_oalias ) {
          if ( *num_oalias < 1 ) {
            num_alias = 1;
            uom_sts = UOM_I_MIN_DEFS_EXCEEDED;
          }
          else if ( *num_oalias > num_defaults ) {
            num_alias = (short) num_defaults;
            uom_sts = UOM_I_MAX_DEFS_EXCEEDED;
          }
          else
            num_alias = *num_oalias;
        }
        else
          num_alias = (short) num_defaults;
      }
    }
    else
      sts = UOM_E_UNEXPECTED_NULL_PTR;

    if ( sts & 1 ) {
      alias = defaults;
      if ( readout )
        oreadout = *readout;
      else {
/*
 *  Get the neccessary readout specifications
 */
        sts = UOM_readout_spec( osnum, typename, 1, &oreadout,
                                (UOM_READOUT *) 0,
                                (UOM_READOUT *) 0 );
      }

      if ( sts & 1 ) {
        UOMalias_name myalias;
        double values[ UOM_K_MAX_DEFS ];
        UOMalias_name aliases[ UOM_K_MAX_DEFS ];
/*
 *  For each readout alias format a output spec
 */
        for ( ii = 0; (ii < num_alias); ii++ ) {
          sts = UOM_convert_dbu_to_value( osnum, ovalue, alias[ii], &value );
          if ( ! (sts & 1) )
            break;

          if ( ii < (num_alias - 1) ) {
            double ivalue, tvalue;

            ivalue = (double) ((int) value);
            tvalue = value - ivalue;
            sts = UOM_convert_value_to_dbu( osnum, tvalue, alias[ii], &ovalue,
                                            0 );
            if ( sts & 1 )
              value = ivalue;
            else
              break;
          }

          if ( ch = strchr( alias[ii], ':' ) ) {
            int len = ch - alias[ii];

            if ( len >= UOM_K_MAX_ALIAS ) {
              len = UOM_K_MAX_ALIAS - 1;
              uom_sts = UOM_I_ALIAS_TRUNCATED;
            }
            strncpy( myalias, alias[ii], len );
            myalias[ len ] = 0;
          }
          else
            strcpy( myalias, alias[ii] );

          values[ii] = value;
          strcpy( aliases[ii], myalias );
        }  /* END for ( ii = 0; (ii < num_alias); ii++ ) */

        sts = UOM_format_readout( &oreadout, &num_alias,
                                  aliases, values, field_size,
                                  fraction_mode, out_buf );
      }
    }
  }

  return ( sts & 1 ) ? uom_sts : sts ;
}

#if defined(__STDC__) || defined(__cplusplus)
void UOM_cvt_grio_readout( struct GRIOreadout_spec *grioreadout,
                           UOM_READOUT *uomreadout )
#else
void UOM_cvt_grio_readout( grioreadout, uomreadout )
struct GRIOreadout_spec *grioreadout;
UOM_READOUT *uomreadout;
#endif
{
  switch ( grioreadout->mode ) {
    case GRIO_FRACTIONAL:
      uomreadout->mode = UOM_FRACTIONAL; break;
    case GRIO_SCIENTIFIC:
      uomreadout->mode = UOM_SCIENTIFIC; break;
    case GRIO_NON_REDUCED_FRACTION:
      uomreadout->mode = UOM_NON_REDUCED_FRACTION; break;
    default:
    case GRIO_DECIMAL:
      uomreadout->mode = UOM_DECIMAL; break;
  }
  uomreadout->precision = (short) grioreadout->precision;
  uomreadout->denominator = (short) grioreadout->denominator;
  uomreadout->intermeas_spacing = (short) grioreadout->intermeas_spacing;
  uomreadout->intrameas_spacing = (short) grioreadout->intrameas_spacing;
  switch ( grioreadout->justification ) {
    case GRIO_CENTER_JUSTIFY:
      uomreadout->justification = UOM_CENTER_JUSTIFY; break;
    case GRIO_RIGHT_JUSTIFY:
      uomreadout->justification = UOM_RIGHT_JUSTIFY; break;
    default:
    case GRIO_LEFT_JUSTIFY:
      uomreadout->justification = UOM_LEFT_JUSTIFY; break;
  }
  switch ( grioreadout->case_type ) {
    case GRIO_UPPER_CASE:
      uomreadout->case_type = UOM_UPPER_CASE; break;
    case GRIO_LOWER_CASE:
      uomreadout->case_type = UOM_LOWER_CASE; break;
    default:
    case GRIO_DEFAULT_CASE:
      uomreadout->case_type = UOM_DEFAULT_CASE; break;
  }
  switch ( grioreadout->decimal_char ) {
    case GRIO_NONE:
      uomreadout->decimal_char = UOM_NONE; break;
    case GRIO_COMMA:
      uomreadout->decimal_char = UOM_COMMA; break;
    default:
    case GRIO_PERIOD:
      uomreadout->decimal_char = UOM_PERIOD; break;
  }
  switch ( grioreadout->thousands_char ) {
    case GRIO_PERIOD:
      uomreadout->thousands_char = UOM_PERIOD; break;
    case GRIO_COMMA:
      uomreadout->thousands_char = UOM_COMMA; break;
    default:
    case GRIO_NONE:
      uomreadout->thousands_char = UOM_NONE; break;
  }
  uomreadout->left_fill_char = grioreadout->left_fill_char;
  uomreadout->alias_displayed = (char) grioreadout->alias_displayed;
  uomreadout->leading_zeros = (char) grioreadout->leading_zeros;
  uomreadout->trailing_zeros = (char) grioreadout->trailing_zeros;
}

#if defined(__STDC__) || defined(__cplusplus)
void UOM_cvt_uom_readout( UOM_READOUT *uomreadout,
                          struct GRIOreadout_spec *grioreadout )
#else
void UOM_cvt_uom_readout( uomreadout, grioreadout )
UOM_READOUT *uomreadout;
struct GRIOreadout_spec *grioreadout;
#endif
{
  switch ( uomreadout->mode ) {
    case UOM_FRACTIONAL:
      grioreadout->mode = GRIO_FRACTIONAL; break;
    case UOM_SCIENTIFIC:
      grioreadout->mode = GRIO_SCIENTIFIC; break;
    case UOM_NON_REDUCED_FRACTION:
      grioreadout->mode = GRIO_NON_REDUCED_FRACTION; break;
    default:
    case UOM_DECIMAL:
      grioreadout->mode = GRIO_DECIMAL; break;
  }
  grioreadout->precision = (IGRshort) uomreadout->precision;
  grioreadout->denominator = (IGRshort) uomreadout->denominator;
  grioreadout->intermeas_spacing = (IGRshort) uomreadout->intermeas_spacing;
  grioreadout->intrameas_spacing = (IGRshort) uomreadout->intrameas_spacing;
  switch ( uomreadout->justification ) {
    case UOM_CENTER_JUSTIFY:
      grioreadout->justification = GRIO_CENTER_JUSTIFY; break;
    case UOM_RIGHT_JUSTIFY:
      grioreadout->justification = GRIO_RIGHT_JUSTIFY; break;
    default:
    case UOM_LEFT_JUSTIFY:
      grioreadout->justification = GRIO_LEFT_JUSTIFY; break;
  }
  switch ( uomreadout->case_type ) {
    case UOM_UPPER_CASE:
      grioreadout->case_type = GRIO_UPPER_CASE; break;
    case UOM_LOWER_CASE:
      grioreadout->case_type = GRIO_LOWER_CASE; break;
    default:
    case UOM_DEFAULT_CASE:
      grioreadout->case_type = GRIO_DEFAULT_CASE; break;
  }
  switch ( uomreadout->decimal_char ) {
    case UOM_NONE:
      grioreadout->decimal_char = GRIO_NONE; break;
    case UOM_COMMA:
      grioreadout->decimal_char = GRIO_COMMA; break;
    default:
    case UOM_PERIOD:
      grioreadout->decimal_char = GRIO_PERIOD; break;
  }
  switch ( uomreadout->thousands_char ) {
    case UOM_PERIOD:
      grioreadout->thousands_char = GRIO_PERIOD; break;
    case UOM_COMMA:
      grioreadout->thousands_char = GRIO_COMMA; break;
    default:
    case UOM_NONE:
      grioreadout->thousands_char = GRIO_NONE; break;
  }
  grioreadout->left_fill_char = uomreadout->left_fill_char;
  grioreadout->alias_displayed = (IGRboolean) uomreadout->alias_displayed;
  grioreadout->leading_zeros = (IGRboolean) uomreadout->leading_zeros;
  grioreadout->trailing_zeros = (IGRboolean) uomreadout->trailing_zeros;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_cvt_imp_to_alias( long *msg, char *table_name, OMuword osnum,
                          double *working_units, short *num_alias,
                          short num_conversions,
                          struct GRIOreadout_spec *readout_spec,
                          short *field_size, short inverse_scale_flag,
                          short *fraction_mode, char *cvt_list )
#else
int UOM_cvt_imp_to_alias( msg, table_name, osnum, working_units, num_alias,
                          num_conversions, readout_spec,
                          field_size, inverse_scale_flag, fraction_mode,
                          cvt_list )
long *msg;
char *table_name;
OMuword osnum;
double *working_units;
short *num_alias;
short num_conversions;
struct GRIOreadout_spec *readout_spec;
short *field_size;
short inverse_scale_flag;
short *fraction_mode;
char *cvt_list;
#endif
{
  int sts;
  int ii;
  double value;
  double inverse_scale_factor = 1.0;
  int noalias = 0;
  int *num_oalias;
  char *out_buf;
  short scale_flag = 0;
  struct GRid active_cs;
  double cs_scale[6];
  short uom_frac_mode = 0;
  short *uomfraction_mode;
  UOM_READOUT uomreadout;
  UOM_READOUT *readout = 0;
  char **cvt_strings = (char **) cvt_list;

  sts = UOM_S_SUCCESS;

  if ( num_alias ) {
    noalias = (int) *num_alias;
    num_oalias = &noalias;
  }
  else
    num_oalias = 0;

  if ( fraction_mode ) {
    switch ( *fraction_mode ) {
      case GRIO_TEXT_FRACT:
        uom_frac_mode = UOM_TEXT_FRACT; break;
      default:
      case GRIO_ASCII_FRACT:
        uom_frac_mode = UOM_ASCII_FRACT; break;
    }
    uomfraction_mode = &uom_frac_mode;
  }
  else
    uomfraction_mode = 0;

  if ( readout_spec ) {
    UOM_cvt_grio_readout( readout_spec, &uomreadout );
    readout = &uomreadout;
  }

  if ( inverse_scale_flag >= 0 ) {
    sts = UOM_is_unit_scalable( msg, table_name, osnum, &scale_flag );
    if ( sts & 1 ) {
      if ( scale_flag ) {
        active_cs.osnum = osnum;
        sts = cs$get_active_info( msg = msg,
                                  osnum = active_cs.osnum,
                                  objid = &active_cs.objid );
        if ( (sts & 1) && (*msg & 1) ) {
          sts = om$send( msg = message GRgencs.GRcsgetscale( msg, cs_scale ),
                         senderid = NULL_OBJID,
                         targetid = active_cs.objid,
                         targetos = active_cs.osnum );
          if ( (sts & 1) && (*msg & 1) )
            inverse_scale_factor = cs_scale[ inverse_scale_flag ];
          else if ( sts & 1 )
            sts = *msg;
        }
        else if ( sts & 1 )
          sts = *msg;
      }
    }
  }

  if ( sts & 1 ) {
    for ( ii = 0; (ii < num_conversions); ii++ ) {
      out_buf = (num_conversions == 1) ? (char *) cvt_list : cvt_strings[ii];
      value = working_units[ii] / inverse_scale_factor;
      sts = UOM_convert_to_readout( osnum, value, (char *) 0, table_name,
                                    num_oalias, (UOMalias_name *) 0, readout,
                                    field_size, uomfraction_mode, out_buf );
      if ( ! (sts & 1) )
        break;
    }
  }

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_cvt_exp_to_alias( long *msg, char *table_name, OMuword osnum,
                          short *num_def, GRIOalias_name *output_alias,
                          double *working_units,
                          struct GRIOreadout_spec *readout_spec,
                          short *field_size, short inverse_scale_flag,
                          short *fraction_mode, char *cvt_string )
#else
int UOM_cvt_exp_to_alias( msg, table_name, osnum, num_def, output_alias,
                          working_units, readout_spec, field_size,
                          inverse_scale_flag, fraction_mode, cvt_string )
long *msg;
char *table_name;
OMuword osnum;
short *num_def;
GRIOalias_name *output_alias;
double *working_units;
struct GRIOreadout_spec *readout_spec;
short *field_size;
short inverse_scale_flag;
short *fraction_mode;
char *cvt_string;
#endif
{
  int sts;
  double value = 0.0;
  int noalias = 0;
  int *num_oalias;
  short scale_flag = 0;
  struct GRid active_cs;
  double cs_scale[6];
  short uom_frac_mode = 0;
  short *uomfraction_mode;
  UOMalias_name *oalias = 0;
  UOM_READOUT uomreadout;
  UOM_READOUT *readout = 0;
  GRIOalias_name **output_aliases = (GRIOalias_name **) output_alias;

  sts = *msg = UOM_S_SUCCESS;

  if ( num_def && (*num_def > 0) ) {
    noalias = (int) *num_def;
    num_oalias = &noalias;
  }
  else
    num_oalias = 0;

  if ( fraction_mode ) {
    switch ( *fraction_mode ) {
      case GRIO_TEXT_FRACT:
        uom_frac_mode = UOM_TEXT_FRACT; break;
      default:
      case GRIO_ASCII_FRACT:
        uom_frac_mode = UOM_ASCII_FRACT; break;
    }
    uomfraction_mode = &uom_frac_mode;
  }
  else
    uomfraction_mode = 0;

  if ( readout_spec ) {
    UOM_cvt_grio_readout( readout_spec, &uomreadout );
    readout = &uomreadout;
  }

  if ( inverse_scale_flag >= 0 ) {
    sts = UOM_is_unit_scalable( msg, table_name, osnum, &scale_flag );
    if ( sts & 1 ) {
      if ( scale_flag ) {
        active_cs.osnum = osnum;
        sts = cs$get_active_info( msg = msg,
                                  osnum = active_cs.osnum,
                                  objid = &active_cs.objid );
        if ( (sts & 1) && (*msg & 1) ) {
          sts = om$send( msg = message GRgencs.GRcsgetscale( msg, cs_scale ),
                         senderid = NULL_OBJID,
                         targetid = active_cs.objid,
                         targetos = active_cs.osnum );
          if ( (sts & 1) && (*msg & 1) )
            value = *working_units / cs_scale[ inverse_scale_flag ];
          else if ( sts & 1 )
            sts = *msg;
        }
        else if ( sts & 1 )
          sts = *msg;
      }
      else
        value = *working_units;
    }
  }
  else
    value = *working_units;

  if ( sts & 1 ) {
    if ( output_alias && (noalias > 0) ) {
      oalias = (UOMalias_name *) malloc( noalias * sizeof( UOMalias_name ) );
      if ( ! oalias )
        sts = OM_E_NODYNMEM;
      else {
        int ii;

        for ( ii = 0; (ii < noalias); ii++ )
          strcpy( oalias[ii], (char *) output_aliases[ii] );
      }
    }
  }
  
  if ( sts & 1 )
    sts = UOM_convert_to_readout( osnum, value, (char *) 0, table_name,
                                  num_oalias, oalias, readout, field_size,
                                  uomfraction_mode, cvt_string );

  if ( oalias )
    free( oalias );

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_cvt_imp_to_wrk( long *msg, char *table_name, OMuword osnum,
                        double primary, double second, double tertiary,
                        double *working_units )
#else
int UOM_cvt_imp_to_wrk( msg, table_name, osnum, primary, second, tertiary,
                        working_units )
long *msg;
char *table_name;
OMuword osnum;
double primary;
double second;
double tertiary;
double *working_units;
#endif
{
  int sts;
  int ii;
  int num_defaults;
  UOMalias_name defaults[ UOM_K_MAX_DEFS ];

  sts = UOM_default_units( osnum, table_name, 1, &num_defaults, defaults );
  if ( sts & 1 ) {
    double value;
    double values[3];
    UOMalias_name alias;

    values[0] = primary;
    values[1] = second;
    values[2] = tertiary;
    *working_units = 0.0;
    for ( ii = 0; (ii < num_defaults); ii++ ) {
      sprintf( alias, "%s:%s", defaults[ii], table_name );
      sts = UOM_convert_value_to_dbu( osnum, values[ii], alias, &value,
                                      (char *) 0 );
      if ( ! (sts & 1) )
        break;
      *working_units += value;
    }
  }

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_cvt_exp_to_wrk( long *msg, char *table_name, OMuword osnum,
                        double units, char *alias, double *working_units )
#else
int UOM_cvt_exp_to_wrk( msg, table_name, osnum, units, alias,
                        working_units )
long *msg;
char *table_name;
OMuword osnum;
double units;
char *alias;
double *working_units;
#endif
{
  int sts;
  UOMalias_name ralias;

  sts = UOM_S_SUCCESS;

  sprintf( ralias, "%s:%s", alias, table_name );
  sts = UOM_convert_value_to_dbu( osnum, units, ralias, working_units,
                                  (char *) 0 );

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_cvt_value_to_value( long *msg, char *table_name, OMuword osnum,
                            char *alias_to_cvt_from, char *alias_to_cvt_to,
                            int num_vals, double *values_in,
                            double *values_out )
#else
int UOM_cvt_value_to_value( msg, table_name, osnum, alias_to_cvt_from,
                            alias_to_cvt_to, num_vals, values_in,
                            values_out )
long *msg;
char *table_name;
OMuword osnum;
char *alias_to_cvt_from;
char *alias_to_cvt_to;
int num_vals;
double *values_in;
double *values_out;
#endif
{
  int sts;
  int ii;
  UOMalias_name ialias, *ialias_ptr = 0;
  UOMalias_name oalias, *oalias_ptr = 0;

  sts = UOM_S_SUCCESS;

  if ( alias_to_cvt_from ) {
    sprintf( ialias, "%s:%s", alias_to_cvt_from, table_name );
    ialias_ptr = (UOMalias_name *) ialias;
  }
    
  if ( alias_to_cvt_to ) {
    sprintf( oalias, "%s:%s", alias_to_cvt_to, table_name );
    oalias_ptr = (UOMalias_name *) oalias;
  }

  for ( ii = 0; (ii < num_vals); ii++ ) {
    sts = UOM_convert_values( osnum, 1, &values_in[ii], (char *) ialias_ptr,
                                        &values_out[ii], (char *) oalias_ptr );
    if ( ! (sts & 1) )
      break;
  }

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_is_unit_scalable( long *msg, char *unit_type, OMuword osnum,
                          short *scale_flag )
#else
int UOM_is_unit_scalable( msg, unit_type, osnum, scale_flag )
long *msg;
char *unit_type;
OMuword osnum;
short *scale_flag;
#endif
{
  int sts;
  UOMdimensions dims;

  sts = UOM_S_SUCCESS;
/*
 * since GRIO_SCALAR is not a unit element, we special case -
 * scalars should NOT be scaled
 */
  *scale_flag = 0;
  if ( strcmp( unit_type, GRIO_SCALAR ) ) {
    sts = UOM_lookup_dims( osnum, unit_type, (char *) 0, dims );
    if ( sts & 1 )
      *scale_flag = ( ! dims[ UOM_K_LENG_DIM ] ) ? 0 : 1;
  }

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_update_readout_spec( long *msg, char *table_name, OMuword osnum,
                             short update_flag,
                             struct GRIOreadout_spec *readout_spec )
#else
int UOM_update_readout_spec( msg, table_name, osnum, update_flag,
                             readout_spec )
long *msg;
char *table_name;
OMuword osnum;
short update_flag;
struct GRIOreadout_spec *readout_spec;
#endif
{
  int sts;
  UOM_READOUT uomreadout;

  sts = UOM_S_SUCCESS;

  if ( update_flag ) {
    UOM_cvt_grio_readout( readout_spec, &uomreadout );
    sts = UOM_readout_spec( osnum, table_name, 0, &uomreadout,
                            &uomreadout,
                            &uomreadout );
  }
  else {
    sts = UOM_readout_spec( osnum, table_name, 1, &uomreadout,
                            (UOM_READOUT *) 0,
                            (UOM_READOUT *) 0 );
    if ( sts & 1 )
      UOM_cvt_uom_readout( &uomreadout, readout_spec );
  }

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_get_default_units( long *msg, char *table_name, OMuword osnum,
                           short *flag, short *num_defaults,
                           GRIOalias_name *default_units )
#else
int UOM_get_default_units( msg, table_name, osnum, flag, num_defaults,
                           default_units )
long *msg;
char *table_name;
OMuword osnum;
short *flag;
short *num_defaults;
GRIOalias_name *default_units;
#endif
{
  int sts;
  int ndefaults;
  UOMalias_name defaults[ UOM_K_MAX_DEFS ];

  sts = UOM_S_SUCCESS;

  if ( flag )
    flag = flag;          /* make apogee happy */

  sts = UOM_default_units( osnum, table_name, 1, &ndefaults, defaults );
  if ( sts & 1 ) {
    int ii;

    *num_defaults = (short) ndefaults;
    for ( ii = 0; (ii < ndefaults); ii++ )
      strcpy( default_units[ii], defaults[ii] );
  }

  *msg = (long) sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_put_default_units( long *msg, char *table_name, OMuword osnum,
                           short *flag, short *num_defaults,
                           GRIOalias_name *default_units )
#else
int UOM_put_default_units( msg, table_name, osnum, flag, num_defaults,
                           default_units )
long *msg;
char *table_name;
OMuword osnum;
short *flag;
short *num_defaults;
GRIOalias_name *default_units;
#endif
{
  int sts;
  int ndefaults = 0;
  UOMalias_name *defaults = 0; 

  sts = UOM_S_SUCCESS;

  if ( flag )
    flag = flag;          /* make apogee happy */

  if ( num_defaults && (*num_defaults > 0) ) {
    ndefaults = (int) *num_defaults;

    defaults = (UOMalias_name *) malloc( ndefaults * sizeof( UOMalias_name ) );
    if ( ! defaults )
      sts = OM_E_NODYNMEM;
    else {
      int ii;

      for ( ii = 0; (ii < ndefaults); ii++ )
        strcpy( defaults[ii], default_units[ii] );
      sts = UOM_default_units( osnum, table_name, 0, &ndefaults, defaults );
    }
  }

  if ( defaults )
    free( defaults );

  *msg = (long) sts;
  return sts;
}

/*
Name
  UOM_default_units

Abstract
  Retrieves or stores the primary, (and optionally) secondary and tertiary 
  "implied" units.

Synopsis
  int UOM_default_units( osnum, 
			 typename, 
			 inquire, 
			 num_defaults,
			 defaults )

  OMuword         osnum          object space of the unit table
  char           *typename       name of unit table (e.g. UOM_DISTANCE )
  int             inquire        for retrieval (1) or posting (0)
  int            *num_defaults   1, 2, or 3 positional units
  UOMalias_name  *defaults       list of positional units

Description
  The primary, (and optionally) the secondary and tertiary positional unit
  aliases are set for the speicified unit table (table_name) in the 
  specified OS (osnum).  For now, flag should be set to 0.

Return Value
  UOM_S_SUCCESS           - successful
  UOM_E_INVALID_ARG       - "p>s>t" rule violated OR bad inquire arg value
  UOM_E_TYPE_NOT_FOUND    - UOM table entry for 'typename' arg not found
  UOM_I_MAX_DEFS_EXCEEDED - num_defaults too big
  UOM_E_ALIAS_NOT_FOUND   - one of the specified defaults was not found
  OM_E_NODYNMEM           - memory allocation failure

Notes
  Some standard unit table names are found in $GRNUC/include/griodef.h

Index

Keywords
  units,default,change

History
  (unknown) : Eddie Pike        : created

  02/16/93  : Shelley R. Heard  : TR # 119301353
     Modified UOM_default_units to enforce the premice that 
     primary > secondary > tertiary units ( e.g. MD=ft,in,in or 
     MA=second, minute, degree )

 */


#if defined(__STDC__) || defined(__cplusplus)
int UOM_default_units( OMuword osnum, char *typename, int inquire,
                       int *num_defaults, UOMalias_name *defaults )
#else
int UOM_default_units( osnum, typename, inquire, num_defaults, defaults )
OMuword osnum;
char *typename;
int inquire;
int *num_defaults;
UOMalias_name *defaults;
#endif
{
  int sts;
  int uom_sts = UOM_S_SUCCESS;
  UOM_TYPE *tt;

  UOM_lookup_type( osnum, typename, 0, &tt );
  if ( ! tt ) 
  {
    sts = UOM_E_TYPE_NOT_FOUND;
    goto ret_error_exit;
  }

  sts = UOM_S_SUCCESS;
  if ( inquire ) 
  {
    *num_defaults = 0;
    while ( tt->defalias[ *num_defaults ] ) 
    {
      strcpy( defaults[ *num_defaults ], tt->defalias[ *num_defaults ] );
      (*num_defaults) ++;
    }
  }
  else if ( *num_defaults > 0 ) 
  {
    int ii, jj, sz;
    int num_defs;
    int ndx;

    if ( *num_defaults > UOM_K_MAX_DEFS ) 
    {
      num_defs = UOM_K_MAX_DEFS;
      uom_sts = UOM_I_MAX_DEFS_EXCEEDED;
    }
    else
      num_defs = *num_defaults;

    /*
     *  Verify that each of the default unit aliases are valid aliases
     *  for this unit type
     */    
    for ( ii = 0; ( ii < num_defs ); ii++ ) 
    {
      UOM_VARIANT *vv;

      UOM_lookup_alias_locally( tt, defaults[ ii ], &vv );
      if ( ! vv ) 
      {
        sts = UOM_E_ALIAS_NOT_FOUND;
        goto ret_error_exit;
      }
    }

    /*
     * TR # 119301353 was caused by not enforcing the premice that
     * primary > secondary > tertiary units ( e.g. MD=ft,in,in or 
     * MA=second, minute, degree ).  Here we enforce this relationship 
     * upon which subsequent algorithms rely. (Shelley Heard - 02/15/93)
     */
    for ( ndx = 0; (ndx < *num_defaults); ndx++ )
    {
      double results[3];
      UOMalias_name alias_desc;

      /* build "qualified" unit description */
      strcpy( alias_desc, defaults[ndx] );
      strcat( alias_desc, ":" );
      strcat( alias_desc, typename );
  
      sts = uom$cvt_value_to_dbu( osnum  = osnum,
                                  ivalue = 1.0,
                                  ialias = alias_desc,
                                  ovalue = &results[ndx]);
  
      if ( ndx == 1 )
      {
        /* check primary vs. secondary */
        if ( results[0] <= results[1] )
        {
          sts = UOM_E_INVALID_ARG;
          goto ret_error_exit;
        }
      }
      else if ( ndx == 2 )
      {
        /* check secondary vs. tertiary */
        if (results[1] <= results[2])
        {
          sts = UOM_E_INVALID_ARG;
          goto ret_error_exit;
        }
      }
    }

    /*
     *  Increase/Decrease table size for specified unit
     */
    ii = 0;
    while ( tt->defalias[ ii ] )
      ii++;

    if ( ii < num_defs ) 
    {
      sz = (num_defs + 1) * sizeof( char * );
      if ( ! ( tt->defalias = (char **) realloc( tt->defalias, sz ) ) ) 
      {
        sts = OM_E_NODYNMEM;
        goto ret_error_exit;
      }
      for ( jj = ii + 1; (jj <= num_defs); jj++ )
        tt->defalias[ jj ] = 0;
    }
    else if ( num_defs < ii ) 
    {
      for ( jj = ii - 1; (jj >= num_defs); jj-- ) 
      {
        free( tt->defalias[ jj ] );
        tt->defalias[ jj ] = 0;
      }
    }

    for ( ii = 0; (ii < num_defs); ii++ ) 
    {
      sz = strlen( defaults[ ii ] ) + 1 ;
      if ( ! ( tt->defalias[ii] = (char *) realloc( tt->defalias[ii], sz ) ) ) 
      {
        sts = OM_E_NODYNMEM;
        goto ret_error_exit;
      }
      strcpy( tt->defalias[ ii ], defaults[ ii ] );
    }
    tt->flags |= UOM_TS_STORED;
    UOM_call_notify_functions( osnum, typename, 1 );
  }
  else
    sts = UOM_E_INVALID_ARG;

ret_error_exit:
  return ( sts & 1 ) ? uom_sts : sts ;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_lookup_type( OMuword osnum, char *typename, UOMdimensions dims,
                     UOM_TYPE **type )
#else
int UOM_lookup_type( osnum, typename, dims, type )
OMuword osnum;
char *typename;
UOMdimensions dims;
UOM_TYPE **type;
#endif
{
  int sts;
  UOM_OSNUM_ENTRY *ote = 0;

  if ( (! typename && ! dims) || ! type )
    sts = UOM_E_UNEXPECTED_NULL_PTR;
  else {
    OM_S_OBJID super;

    *type = 0;
    sts = UOM_get_super_objid( osnum, &super );
    if ( sts & 1 )
      sts = UOM_lookup_osnum_table_entry( osnum, 0, &ote );
  }

  if ( (sts & 1) && ote && ote->uom_types ) {
    UOM_lookup_type_locally( osnum, typename, dims, ote->uom_types, type );
    if ( *type )
      sts = UOM_S_SUCCESS;
    else
      sts = UOM_E_TYPE_NOT_FOUND;
  }

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_convert_value_to_dbu( OMuword osnum, double ivalue, char *ialias,
                              double *ovalue, char *dims )
#else
int UOM_convert_value_to_dbu( osnum, ivalue, ialias, ovalue, dims )
OMuword osnum;
double ivalue;
char *ialias;
double *ovalue;
char *dims;
#endif
{
  int sts;

  sts = UOM_S_SUCCESS;
  if ( ialias ) {
    UOM_VARIANT *iv;

    UOM_lookup_alias( osnum, ialias, &iv );
    if ( ! iv ) {
      sts = UOM_E_ALIAS_NOT_FOUND;
      goto ret_error_exit;
    }
    *ovalue = (ivalue + iv->shift) * iv->scale;
    if ( dims )
      UOM_CpyUnit( dims, iv->type->dims );
    iv->flags |= UOM_TS_STORED;
    iv->type->flags |= UOM_TS_STORED;
  }
  else {
    *ovalue = ivalue;
    if ( dims )
      UOM_NoUnit( dims );
  }

ret_error_exit:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_convert_dbu_to_value( OMuword osnum, double ivalue, char *oalias,
                              double *ovalue )
#else
int UOM_convert_dbu_to_value( osnum, ivalue, oalias, ovalue )
OMuword osnum;
double ivalue;
char *oalias;
double *ovalue;
#endif
{
  int sts;

  sts = UOM_S_SUCCESS;
  if ( oalias ) {
    UOM_VARIANT *ov;

    UOM_lookup_alias( osnum, oalias, &ov );
    if ( ! ov ) {
      sts = UOM_E_ALIAS_NOT_FOUND;
      goto ret_error_exit;
    }
    *ovalue = (ivalue / ov->scale) - ov->shift;
    ov->flags |= UOM_TS_STORED;
    ov->type->flags |= UOM_TS_STORED;
  }
  else
    *ovalue = ivalue;

ret_error_exit:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_convert_values( OMuword osnum, int nvalues, double ivalues[],
                        char *ialias, double ovalues[], char *oalias )
#else
int UOM_convert_values( osnum, nvalues, ivalues, ialias, ovalues, oalias )
OMuword osnum;
int nvalues;
double ivalues[];
char *ialias;          /* if NULL input is dbu */
double ovalues[];
char *oalias;          /* if NULL output is dbu */
#endif
{
  int sts;
  int ii;
  double tvalue;
  double iscale, oscale;
  double ishift, oshift;
  UOM_VARIANT *iv = 0, *ov = 0;

  sts = UOM_S_SUCCESS;
  if ( ialias ) {
    UOM_lookup_alias( osnum, ialias, &iv );
    if ( ! iv ) {
      sts = UOM_E_ALIAS_NOT_FOUND;
      goto ret_error_exit;
    }
    iscale = iv->scale;
    ishift = iv->shift;
  }
  else {
    iscale = 1.0;
    ishift = 0.0;
  }

  if ( oalias ) {
    UOM_lookup_alias( osnum, oalias, &ov );
    if ( ! ov ) {
      sts = UOM_E_ALIAS_NOT_FOUND;
      goto ret_error_exit;
    }
    oscale = ov->scale;
    oshift = ov->shift;
  }
  else {
    oscale = 1.0;
    oshift = 0.0;
  }

  for ( ii = 0; (ii < nvalues); ii++ ) {
    tvalue = (ivalues[ii] + ishift) * iscale;        /* to data base units */
    ovalues[ii] = (tvalue / oscale) - oshift;        /* to output units */
  }

  if ( iv ) {
    iv->flags |= UOM_TS_STORED;
    iv->type->flags |= UOM_TS_STORED;
  }
  if ( ov ) {
    ov->flags |= UOM_TS_STORED;
    ov->type->flags |= UOM_TS_STORED;
  }

ret_error_exit:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_add_function( int (*function)() )
#else
int UOM_add_function( function )
int (*function)();
#endif
{
  int sts;

  if ( ! notify_fcts ) {
    notify_fcts = (OM_p_FUNCPTR *) malloc( sizeof( OM_p_FUNCPTR ) );
    if ( ! notify_fcts ) {
      sts = OM_E_NODYNMEM;
      goto ret_error_exit;
    }
    notify_fcts[0] = 0;
  }
  sts = UOM_S_SUCCESS;

  if ( function && notify_fcts ) {
    int ii = 0, found = 0;

    while ( notify_fcts[ ii ] ) {
      if ( function == notify_fcts[ ii ] ) {
        found = 1;
        break;
      }
      else
        ii++;
    }

    if ( ! found ) {
      int sz = (ii + 2) * sizeof( OM_p_FUNCPTR );

      notify_fcts = (OM_p_FUNCPTR *) realloc( notify_fcts, sz );
      if ( notify_fcts ) {
        notify_fcts[ ii ] = function;
        notify_fcts[ ii+1 ] = 0;
      }
    }
  }

ret_error_exit:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_del_function( int (*function)() )
#else
int UOM_del_function( function )
int (*function)();
#endif
{
  if ( function && notify_fcts ) {
    int ii = 0, found = 0;

    while ( notify_fcts[ ii ] ) {
      if ( ! found && (function == notify_fcts[ ii ]) )
        found = ii + 1;
      ii++;
    }

    if ( found ) {
      int nbytes = (ii - found) * sizeof( OM_p_FUNCPTR );

      if ( nbytes > 0 )
        OM_BLOCK_MOVE( &notify_fcts[ found ],
                       &notify_fcts[ found - 1 ], nbytes );
      notify_fcts[ ii - 1 ] = 0;
    }
  }

  return UOM_S_SUCCESS;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_call_notify_functions( OMuword osnum, char *typename,
                               int default_changed )
#else
int UOM_call_notify_functions( osnum, typename, default_changed )
OMuword osnum;
char *typename;
int default_changed;
#endif
{
  if ( notify_fcts ) {
    int ii = 0;

    while ( notify_fcts[ ii ] ) {
      notify_fcts[ ii ]( osnum, typename, default_changed );
      ii++;
    }
  }

  return UOM_S_SUCCESS;
}


#if defined(__STDC__) || defined(__cplusplus)
static int hash_dim( char dim[], int tblsize )
#else
static int hash_dim( dim, tblsize )
char dim[];
int tblsize;
#endif
{
  unsigned int hashval = 0;
  int ii, hashkey;
  unsigned long grouper;
  char *here;

  for ( ii = 0, here = dim; (here != (dim + UOM_K_MAX_DIMS)); here++ ) {
    ((char *) &grouper)[ii] = *here;
    if (ii == sizeof( grouper ) - 1 ) {
      hashval ^= grouper;
      ii = 0;
    }
    else
      ii++;
  }

  if ( ii != 0 ) {
    for ( ; (ii <= sizeof( grouper ) - 1); ii++ )
      ((char *) &grouper)[ii] = '\0';
    hashval ^= grouper;
  }

  hashkey = hashval % tblsize;

  if ( hashkey < 0 ) {
    fprintf( stderr, "BAD UOM hashkey %d <> %d %d %d %d %d %d %d %d\n",
             hashkey, dim[0], dim[1], dim[2], dim[3], dim[4], dim[5],
             dim[6], dim[7] );
    hashkey = -hashkey;
  }

  return hashkey;
}

#if defined(__STDC__) || defined(__cplusplus)
static int cmp_dim( char dim0[], char dim1[] )
#else
static int cmp_dim( dim0, dim1 )
char dim0[];
char dim1[];
#endif
{
  return ! UOM_EquUnit( dim0, dim1 );
}

#ifdef DEBUG
#if defined(__STDC__) || defined(__cplusplus)
static int UOM_dump_hashtables( UOM_OSNUM_ENTRY *ote )
#else
static int UOM_dump_hashtables( ote )
UOM_OSNUM_ENTRY *ote;
#endif
{
  int sts = UOM_S_SUCCESS;
  int ii;
  int nt = 0, nd = 0;
  UOM_TYPE_HASH *th;
  UOM_DIMS_HASH *dh;

  printf( "\ndump of TypeTable\n" );
  while ( th = hashnext( ote->TypeTable ) ) {
    nt++;
    printf( "hash name = %s\n", th->name );
    printf( "type name = %s\n", th->type->name );
  }
  printf( "%d TypeTable entries\n", nt );
 
  printf( "\ndump of DimsTable\n" );
  while ( dh = hashnext( ote->DimsTable ) ) {
    nd++; 
    printf( "hash dims (%s) =", dh->type->name );
    for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
      printf( " %d", dh->dims[ii] );
    printf( "\n" );
    printf( "type dims (%s) =", dh->type->name );
    for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
      printf( " %d", dh->type->dims[ii] );
    printf( "\n" );
  }
  printf( "%d DimsTable entries\n", nd );

  printf( "\n" );
 
  return sts;
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
static int UOM_create_hashtables( UOM_OSNUM_ENTRY *ote )
#else
static int UOM_create_hashtables( ote )
UOM_OSNUM_ENTRY *ote;
#endif
{
  int sts = UOM_S_SUCCESS;

  if ( ote->uom_types ) {
    sts = UOM_remove_duplicate_types( ote );
    if ( ! (sts & 1) )
      goto ret_error_exit;

    sts = UOM_remove_duplicate_aliases( ote );
    if ( ! (sts & 1) )
      goto ret_error_exit;

    if ( ! (ote->TypeTable = hashinit( UOM_TYPE_HASH, TYPETABLESIZE, hashc,
                                       strcmp, name[0], 0 )) )
    {
      sts = OM_E_NODYNMEM;
      goto ret_error_exit;
    }
    if ( ! (ote->DimsTable = hashinit( UOM_DIMS_HASH, TYPETABLESIZE, hash_dim,
                                       cmp_dim, dims[0], DUPS )) )
    {
      sts = OM_E_NODYNMEM;
      goto ret_error_exit;
    }

    _FOR_LIST( UOM_TYPE, ote->uom_types, tt ) {
      UOM_TYPE_HASH th;
      UOM_DIMS_HASH dh;

      strcpy( th.name, tt->name );
      th.type = tt;
      if ( ! hashadd( ote->TypeTable, &th, 0 ) ) {
        sts = OM_E_NODYNMEM;
        goto ret_error_exit;
      }
/*
 *  Ok to have duplicate unit dimensions
 */
      UOM_CpyUnit( dh.dims, tt->dims );
      dh.type = tt;
      if ( ! hashadd( ote->DimsTable, &dh, 0 ) ) {
        sts = OM_E_NODYNMEM;
        goto ret_error_exit;
      }
      
      if ( ! (tt->aliashashtab = (char *) hashinit( UOM_ALIAS_HASH,
                                                    ALIASTABLESIZE,
                                                    hashc, strcmp,
                                                    name[0], 0 )) )
      {
        sts = OM_E_NODYNMEM;
        goto ret_error_exit;
      }

      _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
        int ii;
        UOM_ALIAS_HASH ah;

        ii = 0;
        while ( vv->alias[ ii ] ) {
          strcpy( ah.name, vv->alias[ ii ] );
          ah.variant = vv;
          if ( ! hashadd( (HASHTABLE *)tt->aliashashtab, &ah, 0 ) ) {
            sts = OM_E_NODYNMEM;
            goto ret_error_exit;
          }
          ii++;
        }  /* END while ( vv->alias[ ii ] ) */
      } _END_LIST
    } _END_LIST
  }  /* END if ( ote->uom_types ) */

ret_error_exit:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_grio_float_to_ascii( double float_in,
                             struct GRIOreadout_spec *readout_spec,
                             char *ascii_result )
#else
int UOM_grio_float_to_ascii( float_in, readout_spec, ascii_result )
double float_in;
struct GRIOreadout_spec *readout_spec;
char *ascii_result;
#endif
{
  UOM_READOUT uomreadout;

  UOM_cvt_grio_readout( readout_spec, &uomreadout );
  return UOM_float_to_ascii( float_in, &uomreadout, ascii_result );
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_grio_float_to_sci( double float_in,
                           struct GRIOreadout_spec *readout_spec,
                           char *ascii_result )
#else
int UOM_grio_float_to_sci( float_in, readout_spec, ascii_result )
double float_in;
struct GRIOreadout_spec *readout_spec;
char *ascii_result;
#endif
{
  UOM_READOUT uomreadout;

  UOM_cvt_grio_readout( readout_spec, &uomreadout );
  return UOM_float_to_sci( float_in, &uomreadout, ascii_result );
}


#if defined(__STDC__) || defined(__cplusplus)
int UOM_grio_format_readout( int *msg, struct GRIOreadout_spec *readout_spec,
                             short *num_alias, GRIOalias_name *alias_list[],
                             double *value_list, short *field_size,
                             short *fraction_mode, char *return_string )
#else
int UOM_grio_format_readout( msg, readout_spec, num_alias, alias_list,
                             value_list, field_size, fraction_mode,
                             return_string )

int                        *msg;
struct GRIOreadout_spec    *readout_spec;
short                      *num_alias;
GRIOalias_name             *alias_list[];
double                     *value_list;
short                      *field_size;
short                      *fraction_mode;
char                       *return_string;
#endif
{
  int sts = UOM_S_SUCCESS;
  UOM_READOUT uomreadout;
  short naliases;
  short ii,uom_frac_mode = 0;
  short *uomfraction_mode;
  UOMalias_name aliases[ UOM_K_MAX_DEFS ];

  if ( fraction_mode ) {
    switch ( *fraction_mode ) {
      case GRIO_TEXT_FRACT:
        uom_frac_mode = UOM_TEXT_FRACT; break;
      default:
      case GRIO_ASCII_FRACT:
        uom_frac_mode = UOM_ASCII_FRACT; break;
    }
    uomfraction_mode = &uom_frac_mode;
  }
  else
    uomfraction_mode = 0;

  naliases = ( *num_alias > UOM_K_MAX_DEFS ) ? UOM_K_MAX_DEFS : *num_alias ;
  for ( ii = 0; (ii < naliases); ii++ )
    strcpy( aliases[ii], (char *) alias_list[ii] );
  UOM_cvt_grio_readout( readout_spec, &uomreadout );
  sts = UOM_format_readout( &uomreadout, &naliases, aliases,
                            value_list, field_size, &uomfraction_mode,
                            return_string );

  *msg = sts;
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_cvt_to_lower( char *str )
#else
int UOM_cvt_to_lower( str )
char *str;
#endif
{
  char *ptr = str;

  while ( *ptr ) {
    *ptr = tolower( *ptr );
    ptr++;
  } 

  return 1;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_mark_all_for_write( OMuword osnum )
#else
int UOM_mark_all_for_write( osnum )
OMuword osnum;
#endif
{
  int sts = UOM_S_SUCCESS;
  OM_S_OBJID super;

  sts = UOM_get_super_objid( osnum, &super );
  if ( sts & 1 ) {
    UOM_OSNUM_ENTRY *ote = 0;

    sts = UOM_lookup_osnum_table_entry( osnum, 0, &ote );
    if ( sts & 1 ) {
      _FOR_LIST( UOM_TYPE, ote->uom_types, tt ) {
        _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
          vv->flags |= UOM_TS_STORED;
        } _END_LIST
        tt->flags |= UOM_TS_STORED;
      } _END_LIST
    }
  }

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_mark_for_write( OMuword osnum, char *typename )
#else
int UOM_mark_for_write( osnum, typename )
OMuword osnum;
char *typename;
#endif
{
  int sts;
  UOM_TYPE *tt;

  UOM_lookup_type( osnum, typename, (char *) 0, &tt );
  if ( tt ) {
    tt->flags |= UOM_TS_STORED;
    _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
      vv->flags |= UOM_TS_STORED;
    } _END_LIST
    sts = UOM_S_SUCCESS;
  }
  else
    sts = UOM_E_TYPE_NOT_FOUND;

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_give_table( OMuword osnum, UOM_TYPE **uom_table )
#else
int UOM_give_table( osnum, uom_table )
OMuword osnum;
UOM_TYPE **uom_table;
#endif
{
  int sts = UOM_S_SUCCESS;
  OM_S_OBJID super;

  *uom_table = 0;
  sts = UOM_get_super_objid( osnum, &super );
  if ( sts & 1 ) {
    UOM_OSNUM_ENTRY *ote = 0;

    sts = UOM_lookup_osnum_table_entry( osnum, 0, &ote );
    if ( sts & 1 )
      *uom_table = ote->uom_types;
  }

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_get_type_dbu( OMuword osnum, char *typename, char *dbualias )
#else
int UOM_get_type_dbu( osnum, typename, dbualias )
OMuword osnum;
char *typename;
char *dbualias;
#endif
{
  int sts = UOM_S_SUCCESS;
  UOM_TYPE *tt;

  dbualias[0] = 0;

  UOM_lookup_type( osnum, typename, (char *) 0, &tt );
  if ( tt ) {
/*
 *  Look for variant that has 1.0 as scale and 0.0 as shift
 */
    _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
      if ( vv->scale == 1.0 && vv->shift == 0.0 ) {
        UOM_get_variant_shortname( osnum, vv, (char *) 0, (char *) 0,
                                   dbualias, 0 );
        break;
      }
    } _END_LIST

    if ( ! dbualias[0] )
      sts = UOM_E_ALIAS_NOT_FOUND;
  }
  else
    sts = UOM_E_TYPE_NOT_FOUND;

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_get_variant_shortname( OMuword osnum, UOM_VARIANT *variant,
                               char *typename, char *aliasname,
                               char *shortname, int *index )
#else
int UOM_get_variant_shortname( osnum, variant, typename, aliasname,
                               shortname, index )
OMuword osnum;
UOM_VARIANT *variant;
char *typename;
char *aliasname;
char *shortname;
int *index;
#endif
{
  int sts = UOM_S_SUCCESS;

  shortname[0] = 0;
  
  if ( ! variant ) {
    UOM_VARIANT *vv;

    if ( ! typename )
      UOM_lookup_alias( osnum, aliasname, &vv );
    else {
      UOM_TYPE *tt;

      UOM_lookup_type( osnum, typename, (char *) 0, &tt );
      if ( tt )
        UOM_lookup_alias_locally( tt, aliasname, &vv );
      else
        sts = UOM_E_TYPE_NOT_FOUND;
    }

    if ( sts & 1 ) {
      if ( vv )
        variant = vv;
      else
        sts = UOM_E_ALIAS_NOT_FOUND;
    }

    if ( ! (sts & 1) )
      goto wrapup;
  }

  if ( variant ) {
    int ii = 0;
    int longest = -1;
    int longest_index = -1;

    while ( variant->alias[ii] ) {
      int len = strlen( variant->alias[ii] );

      if ( (len > 1) && (len < 11) ) {
        if ( (longest_index == -1) || (len > longest) ) {
          longest = len;
          longest_index = ii;
        }
      }
      ii++;
    }

    if ( longest_index == -1 ) {
      if ( index )
        *index = 0;
      strcpy( shortname, variant->alias[0] );
    }
    else {
      if ( index )
        *index = longest_index;
      strcpy( shortname, variant->alias[longest_index] );
    }
  }

wrapup:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_set_uom_table_processing_order( int inner_to_outer )
#else
int UOM_set_uom_table_processing_order( inner_to_outer )
int inner_to_outer;
#endif
{
  UOM_G_inner_to_outer = inner_to_outer;

  return UOM_S_SUCCESS;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_get_uom_table_processing_order( void )
#else
int UOM_get_uom_table_processing_order()
#endif
{
  return UOM_G_inner_to_outer;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_get_type_aliases( OMuword osnum, UOM_TYPE *type, char *typename,
                          char ***aliases )
#else
int UOM_get_type_aliases( osnum, type, typename, aliases )
OMuword osnum;
UOM_TYPE *type;
char *typename;
char ***aliases;
#endif
{
  int sts;

  *aliases = 0;
  if ( ! type ) {
    UOM_TYPE *tt;

    UOM_lookup_type( osnum, typename, (char *) 0, &tt );
    if ( tt )
      type = tt;
  }

  if ( type ) {
    int tot = 0;

    _FOR_LIST( UOM_VARIANT, type->variant, vv ) {
      int ii = 0;

      while ( vv->alias[ ii ] ) {
        int size = (tot + 2) * sizeof( char * );

        if ( ! *aliases )
          *aliases = (char **) malloc( size );
        else
          *aliases = (char **) realloc( *aliases, size );
        if ( ! *aliases ) {
          sts = OM_E_NODYNMEM;
          goto wrapup;
        }

        (*aliases)[ tot + 1 ] = 0;

        if ( ! ( (*aliases)[ tot ] = strdup( vv->alias[ii] ) ) ) {
          sts = OM_E_NODYNMEM;
          goto wrapup;
        }

        ii++;
        tot++;
      }
    } _END_LIST

    sts = UOM_S_SUCCESS;
  }
  else
    sts = UOM_E_TYPE_NOT_FOUND;

wrapup:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_get_variant_aliases( OMuword osnum, UOM_VARIANT *variant,
                             char *typename, char *aliasname,
                             char ***aliases )
#else
int UOM_get_variant_aliases( osnum, variant, typename, aliasname, aliases )
OMuword osnum;
UOM_VARIANT *variant;
char *typename;
char *aliasname;
char ***aliases;
#endif
{
  int sts = UOM_S_SUCCESS;

  *aliases = 0;

  if ( ! variant ) {
    UOM_VARIANT *vv;

    if ( ! typename )
      UOM_lookup_alias( osnum, aliasname, &vv );
    else {
      UOM_TYPE *tt;

      UOM_lookup_type( osnum, typename, (char *) 0, &tt );
      if ( tt )
        UOM_lookup_alias_locally( tt, aliasname, &vv );
      else
        sts = UOM_E_TYPE_NOT_FOUND;
    }

    if ( sts & 1 ) {
      if ( vv )
        variant = vv;
      else
        sts = UOM_E_ALIAS_NOT_FOUND;
    }

    if ( ! (sts & 1) )
      goto wrapup;
  }

  if ( variant ) {
    int ii = 0;

    while ( variant->alias[ii] ) {
      int size = (ii + 2) * sizeof( char * );

      if ( ! *aliases )
        *aliases = (char **) malloc( size );
      else
        *aliases = (char **) realloc( *aliases, size );
      if ( ! *aliases ) {
        sts = OM_E_NODYNMEM;
        goto wrapup;
      }

      (*aliases)[ ii + 1 ] = 0;

      if ( ! ( (*aliases)[ ii ] = strdup( variant->alias[ii] ) ) ) {
        sts = OM_E_NODYNMEM;
        goto wrapup;
      }

      ii++;
    }
  }

wrapup:
  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
int UOM_report_error( int msg, char *errstr )
#else
int UOM_report_error( int, errstr )
int msg;
char *errstr;
#endif
{
  int sev = UOM_ret_severity( msg );
  char str[256];

  if ( UOM_ret_facility( msg ) == UOM_FAC ) {
    strcpy( str, "UOM-" );
    switch( sev ) {
      case UOM_WARN:
        strcat( str, "W-" );
        break;
      case UOM_SUCC:
        strcat( str, "S-" );
        break;
      case UOM_ERR:
        strcat( str, "E-" );
        break;
      case UOM_INFO:
        strcat( str, "I-" );
        break;
      case UOM_FATAL:
        strcat( str, "F-" );
        break;
      default:
        strcat( str, "-" );
        break;
    }

    switch ( msg ) {
      case UOM_S_SUCCESS:
        strcat( str, "SUCCESS, Successful completion" );
        break;
      case UOM_E_ALIAS_FOUND:
        strcat( str, "ALIAS_FOUND, unit alias name found" );
        break;
      case UOM_E_ALIAS_NOT_FOUND:
        strcat( str, "ALIAS_NOT_FOUND, unit alias name not found" );
        break;
      case UOM_E_TYPE_FOUND:
        strcat( str, "TYPE_FOUND, unit type name found" );
        break;
      case UOM_E_TYPE_NOT_FOUND:
        strcat( str, "TYPE_NOT_FOUND, unit type name not found" );
        break;
      case UOM_E_UNEXPECTED_NULL_PTR:
        strcat( str, "UNEXPECTED_NULL_PTR, null pointer passed" );
        break;
      case UOM_I_CREATED:
        strcat( str, "CREATED, super created" );
        break;
      case UOM_I_ALIAS_TRUNCATED:
        strcat( str, "ALIAS_TRUNCATED, unit alias name truncated" );
        break;
      case UOM_I_TYPE_TRUNCATED:
        strcat( str, "TYPE_TRUNCATED, unit type name truncated" );
        break;
      case UOM_E_ZERO_SCALE:
        strcat( str, "ZERO_SCALE, variant declared with zero scale" );
        break;
      case UOM_I_MAX_DEFS_EXCEEDED:
        strcat( str, "MAX_DEFS_EXCEEDED, > 3 defaults specified" );
        break;
      case UOM_I_MIN_DEFS_EXCEEDED:
        strcat( str, "MIN_DEFS_EXCEEDED, < 1 default specified" );
        break;
      case UOM_E_INVALID_ARG:
        strcat( str, "INVALID_ARG, invalid argument" );
        break;
      default:
        sprintf( &str[ strlen( str ) ], ", unknown 0x%x", msg );
        break;
    }
  }
  else {
    switch( sev ) {
      case UOM_WARN:
        sprintf( str, "not UOM code, 0x%x unknown warning", msg );
        break;
      case UOM_SUCC:
        sprintf( str, "not UOM code, 0x%x unknown success", msg );
        break;
      case UOM_ERR:
        sprintf( str, "not UOM code, 0x%x unknown error", msg );
        break;
      case UOM_INFO:
        sprintf( str, "not UOM code, 0x%x unknown informational", msg );
        break;
      default:
      case UOM_FATAL:
        sprintf( str, "not UOM code, 0x%x unknown fatal", msg );
        break;
    }
  }

  if ( errstr )
    strcpy( errstr, str );
  else
    fprintf( stderr, "%s\n", str );

  return UOM_S_SUCCESS;
}

#if defined(__STDC__) || defined(__cplusplus)
static int UOM_remove_duplicate_types( UOM_OSNUM_ENTRY *ote )
#else
static int UOM_remove_duplicate_types( ote )
UOM_OSNUM_ENTRY *ote;
#endif
{
  int sts = UOM_S_SUCCESS;

  if ( ote->uom_types ) {
    int finished;

    while ( 1 ) {
      finished = 1;
      _FOR_LIST( UOM_TYPE, ote->uom_types, t0 ) {
        _FOR_LIST( UOM_TYPE, ote->uom_types, t1 ) {
          if ( t0 != t1 ) {
            if ( ! strcmp( t0->name, t1->name ) ) {
              char *fmt = 0, buf[ 1024 ];

              UOM_get_message_string( UOM_DUP_TYPE, &fmt );
              sprintf( buf, fmt, t1->name );
              UOM_echo_message( buf );

              UOM_list_remove( t1, &ote->uom_types );
              UOM_free_type( &t1 );
              finished = 0;
              break;
            }
          }
        } _END_LIST

        if ( ! finished )
          break;

      } _END_LIST

      if ( finished )
        break;
    }
  }

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
static int UOM_remove_duplicate_aliases( UOM_OSNUM_ENTRY *ote )
#else
static int UOM_remove_duplicate_aliases( ote )
UOM_OSNUM_ENTRY *ote;
#endif
{
  int sts = UOM_S_SUCCESS;
  char *fmt = 0, buf[1024];

  if ( ote->uom_types ) {
    int ii, jj, kk, finished;
    int naliases, gotdup;
    char *alias;
/*
 *  Remove duplicate aliases from variants
 */
    _FOR_LIST( UOM_TYPE, ote->uom_types, tt ) {
      _FOR_LIST( UOM_VARIANT, tt->variant, v0 ) {
/*
 *  Check for and remove duplicates within a variant
 */
        naliases = 0;
        while ( v0->alias[naliases] ) naliases++;

        ii = 0;
        while ( ii < (naliases - 1) ) {
          jj = ii + 1;

          finished = 0;
          alias = v0->alias[ii];

          while ( ! finished ) {
            gotdup = 0;

            while ( jj < naliases ) {
              if ( ! strcmp( alias, v0->alias[jj] ) ) {
                gotdup = 1;
                break;
              }
              jj++;
            }

            if ( gotdup ) {
              UOM_get_message_string( UOM_DUP_ALIAS, &fmt );
              sprintf( buf, fmt, v0->alias[jj], tt->name );
              UOM_echo_message( buf );

              free( v0->alias[jj] );
              if ( jj < (naliases - 1) ) {
                for ( kk = jj; (kk < (naliases - 1)); kk++ )
                  v0->alias[ kk ] = v0->alias[ kk+1 ];
              }
              v0->alias[ --naliases ] = 0;
            }
            else
              finished = 1;
          }  /* END while ( ! finished ) */

          ii++;
        }  /* END while ( ii < (naliases - 1) ) */
/*
 *  Now check for duplicate aliases across variants
 */
        _FOR_LIST( UOM_VARIANT, tt->variant, v1 ) {
          if ( v0 != v1 ) {
            ii = 0;
            while ( alias = v0->alias[ii] ) {

              gotdup = 0;

              jj = 0;
              while ( v1->alias[jj] ) {
                if ( ! strcmp( alias, v1->alias[jj] ) ) {
                  gotdup = 1;
                  break;
                }
                jj++;
              }

              if ( gotdup ) {
                naliases = 0;
                while ( v1->alias[naliases] ) naliases++;

                UOM_get_message_string( UOM_DUP_ALIAS, &fmt );
                sprintf( buf, fmt, v1->alias[jj], tt->name );
                UOM_echo_message( buf );

                free( v1->alias[jj] );
                if ( jj < (naliases - 1) ) {
                  for ( kk = jj; (kk < (naliases - 1)); kk++ )
                    v1->alias[ kk ] = v1->alias[ kk+1 ];
                }
                v1->alias[ --naliases ] = 0;
              }

              ii++;
            }  /* END while ( v0->alias[ii] ) */
          }  /* END if ( v0 != v1 ) */
        } _END_LIST

      } _END_LIST
/*
 *  Now remove variants that no longer have any aliases
 */
      while ( 1 ) {
        finished = 1;
        _FOR_LIST( UOM_VARIANT, tt->variant, v0 ) {
          naliases = 0;
          while ( v0->alias[naliases] ) naliases++;

          if ( naliases == 0 ) {
            UOM_list_remove( v0, &tt->variant );
            UOM_free_variant( &v0 );
            finished = 0;
            break;
          }
        } _END_LIST

        if ( finished )
          break;
      }

    } _END_LIST
  }

  return sts;
}

end implementation UOMsuper;
