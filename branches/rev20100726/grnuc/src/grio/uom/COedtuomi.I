class implementation COedtuom;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "igetypedef.h"
#include "igrtypedef.h"

#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "grmsg.h"

#include "msdef.h"
#include "msmacros.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "grio.h"
#include "griomacros.h"

#include "UOMdef.h"
#include "UOM.h"
#include "UOMmacros.h"
#include "UOMtls.h"

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

/*

  COedtuom - init, wakeup, execute, sleep, delete

DESCRIPTION

HISTORY
       Author     Date          Description
       ------     ----          -----------
        elp     02/04/92        copied FEM's version & modified
        scw     06/23/92        Added static ANSI C prototypes
*/

#define EDTUOMDEFS_FORMNAME   "EdtUomDefs"
#define EDTUOMRDOUT_FORMNAME  "EdtUomRdOut"

#define EDTUOMDEFS            0
#define EDTUOMRDOUT           1

#define FIELD_DIM 30

/*
 *  Gadget labels for EDTUOMDEFS form
 */
#define READOUT                12
#define MAIN_FIELD             13
#  define RDOUT_COL       0
#  define UTYP_COL        1
#  define DB_COL          2
#  define DEF_COL         3
#  define OPTS_COL        4
#define ALIAS_LIST             20
#define SAVE_REST             105

/*
 *  Gadget labels for EDTUOMRDOUT form
 */
#define UNIT_TYPE              21
#define CASE_FLD               30
#define JUSTIFICATION_FLD      31
#define FILL_CHAR_FLD          32
#define INTER_UNIT_SPC_FLD     33
#define INTRA_UNIT_SPC_FLD     34
#define DECIMAL_ACCUR_FLD      35
#define DECIMAL_COMMA_TOG      36
#define DEC_FRAC_MODE_TOG      39
#define LEADING_ZERO_TOG       40
#define TRAILING_ZERO_TOG      41
#define FRAC_DENOM_FLD         49
#define THOUS_DELIM_FLD        54
#define DISPLAY_UNITS_TOG      55


  /* states */
#define INIT     ((short) 0)       /* EDTUOMDEFS displayed */
#define BOTH     ((short) 1)       /* EDTUOMDEFS & EDTUOMRDOUT displayed */
#define FINISHED ((short) 2)

struct UOM_rowtype {
  UOM_TYPE *type;           /* the type DON'T FREE THIS */
  int defchg;               /* default changed */
  UOMalias_name newdef;     /* the new default */
  int typehdr;              /* type header line */
  UOMalias_name dbu;        /* the dbu for this row */
  UOM_READOUT readout;      /* the readout specs for unit type */
  char *aliases;            /* the aliases for this row */
  int  indexes[5];          /* indexes for aliases (5 per row) */
};
typedef struct UOM_rowtype UOM_ROWTYPE;

%safe
static Form EdtUomDefs = 0;
static Form EdtUomRdOut = 0;

static int nrow_types = 0;
static UOM_ROWTYPE *row_types = 0;

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

static int DisplayForm __((OMuword osnum, Form form, int flabel));
static int ReallocRowTypesByOne __((int typehdr, OMuword osnum, 
                                    UOM_TYPE *type));
static int AllocRowTypesAliases __((int newrow, OMuword osnum, char *str, 
                                    int *indexes, UOM_TYPE *type));
static int FreeRowTypes __((void));
static int GetRowTypes __((OMuword osnum));
static int GiveSelectedUnitType __((int *sel_index, int *type_index));
static int FillInForm __((OMuword osnum, Form form, int flabel));
static int GetAllVariantAliases __((UOM_TYPE *type, char *alias, 
                                    char **unitAliases));
static int SetSaveRestore __((Form form));
static int FormNotification __((int flabel, int glabel, double value, 
                                Form form));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


#define FIRET_TEST                 \
{                                  \
  if ( sts != FI_SUCCESS ) {       \
    sts = OM_E_ABORT;              \
    goto wrapup;                   \
  }                                \
  else                             \
    sts = OM_S_SUCCESS;            \
}

method set_state( short state )
{
  me->state = state;

  return OM_S_SUCCESS;
}

method get_state( short *state )
{
  *state = me->state;

  return OM_S_SUCCESS;
}

method init( int type; char *str_ptr )
{
  int sts;

  me->state = INIT;
  sts = ex$get_cur_mod( id = &me->md_id.objid, osnum = &me->md_id.osnum );
  if ( ! (sts & 1) )
    goto wrapup;

  if ( ! EdtUomDefs ) {
    sts = FIf_new( EDTUOMDEFS, EDTUOMDEFS_FORMNAME, FormNotification,
                   &EdtUomDefs );
    FIRET_TEST;
  }
  else {
    sts = FIf_reset( EdtUomDefs );
    FIRET_TEST;
    sts = FIf_set_notification_routine( EdtUomDefs, FormNotification );
    FIRET_TEST;
  }

  sts = FIf_set_cmd_oid_os( EdtUomDefs, my_id, OM_Gw_current_OS );
  FIRET_TEST;

  if ( ! EdtUomRdOut ) {
    sts = FIf_new( EDTUOMRDOUT, EDTUOMRDOUT_FORMNAME, FormNotification,
                   &EdtUomRdOut );
    FIRET_TEST;
  }
  else {
    sts = FIf_reset( EdtUomRdOut );
    FIRET_TEST;
    sts = FIf_set_notification_routine( EdtUomRdOut, FormNotification );
    FIRET_TEST;
  }

  sts = FIf_set_cmd_oid_os( EdtUomRdOut, my_id, OM_Gw_current_OS );
  FIRET_TEST;
  
wrapup:
  me->sts = sts;
  return OM_S_SUCCESS;
}
/* init */


#if defined(__STDC__) || defined(__cplusplus)
static int DisplayForm( OMuword osnum, Form form, int flabel )
#else
static int DisplayForm( osnum, form, flabel )
OMuword osnum;
Form form;
int flabel;
#endif
{
  int sts = OM_S_SUCCESS;

  if ( form ) {
    int displayed;

    sts = FIf_is_displayed( form, &displayed );
    FIRET_TEST;

    if ( ! displayed ) {
      long attributes = 0;

      sts = FillInForm( osnum, form, flabel );
      if ( ! (sts & 1) )
        goto wrapup;
#ifdef DEBUG
      sts = FIf_get_attr( form, &attributes );
      FIRET_TEST;
      attributes &= ~( FI_SAVE_RESTORE ) ;
      sts = FIf_set_attr( form, attributes );
      FIRET_TEST;
#endif
      sts = FIf_get_attr( form, &attributes );
      FIRET_TEST;
      if ( attributes & FI_SAVE_RESTORE )
        sts = FIg_set_state_off( form, SAVE_REST );
      else
        sts = FIg_set_state_on( form, SAVE_REST );
      FIRET_TEST;
      sts = FIf_display( form );
      FIRET_TEST;
    }
  }

wrapup:
  return sts;
}

method wakeup( int pos )
{
  int sts;

  sts = me->sts;
  if ( ! (sts & 1) )
    goto wrapup;

  ex$message( in_buff = "", field = PROMPT_FIELD );
  ex$message( in_buff = "", field = ERROR_FIELD );
  ex$message( in_buff = me->cmd_name, field = MESSAGE_FIELD,
              justification = CENTER_JUS );

wrapup:
  me->sts = sts;
  return OM_S_SUCCESS;
}
/* wakeup */

method super_cmd.sleep( int pos )
{
  int sts;
  int displayed;

  sts = me->sts;
  if ( ! (sts & 1) )
    goto wrapup;

  if ( me->state == INIT || me->state == BOTH ) {
    if ( EdtUomDefs ) {
      sts = FIf_is_displayed( EdtUomDefs, &displayed );
      FIRET_TEST;
      if ( displayed ) {
        sts = FIf_erase( EdtUomDefs );
        FIRET_TEST;
      }
    }
  }

  if ( me->state == BOTH ) {
    if ( EdtUomRdOut ) {
      sts = FIf_is_displayed( EdtUomRdOut, &displayed );
      FIRET_TEST;
      if ( displayed ) {
        sts = FIf_erase( EdtUomRdOut );
        FIRET_TEST;
      }
    }
  }

  ex$message( in_buff = "", field = MESSAGE_FIELD );
  ex$message( in_buff = "", field = PROMPT_FIELD );

wrapup:
  me->sts = sts;
  return OM_S_SUCCESS;
}
/* sleep */

method execute( int *response; char *response_data; int  pos )
{
  int sts, msg;
  struct GRevent event;

  sts = me->sts;
  if ( ! (sts & 1) )
    goto wrapup;

  if ( me->state == INIT || me->state == BOTH ) {
    sts = DisplayForm( me->md_id.osnum, EdtUomDefs, EDTUOMDEFS );
    if ( ! (sts & 1) )
      goto wrapup;
  }

  if ( me->state == BOTH ) {
    sts = DisplayForm( me->md_id.osnum, EdtUomRdOut, EDTUOMRDOUT );
    if ( ! (sts & 1) )
      goto wrapup;
  }

  while ( 1 ) {
    co$getevent( msg = &msg,
                 msgnum = EX_P_Clear,
                 event_mask = GRm_FORM_FINISHED,
                 response = response,
                 response_data = response_data,
                 event = &event );
    if ( event.response == EX_FORM_FINISHED ) {
      if ( me->state == INIT ) {
        *response = TERMINATE;
        break;
      }
      else if ( me->state == BOTH ) {
        me->state = INIT;
      }
    }
    else if ( *response == EX_RJT_MOVEON ||
              *response == EX_STRING ||
              *response == EX_DATA ||
              *response == EX_BACK_UP ||
              *response == EX_RESTART ||
              *response == EX_OBJID)
    {
      ex$message( msgnumb = GR_I_InpDiscard );
    }
    else /* unknown input */
      break;
  }

wrapup:
  if ( ! (sts & 1) )
    *response = TERMINATE;
  return ( sts & 1 ) ? OM_S_SUCCESS : OM_E_ABORT ;
}
/* execute */

method delete( int f_defer_flag )
{
  FreeRowTypes();

  return OM_S_SUCCESS;
}
/* delete */


#if defined(__STDC__) || defined(__cplusplus)
static int ReallocRowTypesByOne( int typehdr, OMuword osnum, UOM_TYPE *type )
#else
static int ReallocRowTypesByOne( typehdr, osnum, type )
int typehdr;
OMuword osnum;
UOM_TYPE *type;
#endif
{
  int sts = OM_S_SUCCESS;
  int size = (nrow_types + 1) * sizeof( UOM_ROWTYPE );

  if ( ! row_types )
    row_types = (UOM_ROWTYPE *) malloc( size );
  else
    row_types = (UOM_ROWTYPE *) realloc( row_types, size );

  if ( ! row_types ) {
    sts = OM_E_NODYNMEM;
    goto wrapup;
  }

  if ( type ) {
    row_types[ nrow_types ].defchg = 0;
    row_types[ nrow_types ].type = type;
    if ( typehdr ) {
      row_types[ nrow_types ].typehdr = 1;
      sts = uom$get_type_dbu( osnum = osnum, typename = type->name,
                              alias = row_types[ nrow_types ].dbu );
      if ( ! sts )
        goto wrapup;
    }
    else {
      row_types[ nrow_types ].typehdr = 0;
      row_types[ nrow_types ].dbu[0] = 0;
    }
    row_types[ nrow_types ].aliases = 0;
    memset( row_types[ nrow_types ].indexes, 0, 5 * sizeof( int ) );
    memcpy( &row_types[ nrow_types ].readout, &type->primary,
            sizeof( UOM_READOUT ) );
  }
  else
    memset( &row_types[ nrow_types ], 0, sizeof( UOM_ROWTYPE ) );
  nrow_types ++;

wrapup:
  return sts;
}


#if defined(__STDC__) || defined(__cplusplus)
static int AllocRowTypesAliases( int        newrow, 
                                 OMuword    osnum, 
                                 char      *str, 
                                 int       *indexes, 
                                 UOM_TYPE  *type )
#else
static int AllocRowTypesAliases( newrow, osnum, str, indexes, type )
int newrow;
OMuword osnum;
char *str;
int *indexes;
UOM_TYPE *type;
#endif
{
  int sts;

  if ( newrow ) {
    sts = ReallocRowTypesByOne( 0, osnum, type );
    if ( ! (sts & 1) )
      goto wrapup;
  }
  else
    sts = OM_S_SUCCESS;

  if ( ! (row_types[ nrow_types - 1 ].aliases = (char *) strdup( str )) )
    sts = OM_E_NODYNMEM;
  else
    memcpy( row_types[ nrow_types - 1 ].indexes, indexes, 5 * sizeof( int ) );

wrapup:
  return sts;
}

static int FreeRowTypes()
{
  int sts = OM_S_SUCCESS;

  if ( row_types ) {
    int ii;

    for ( ii = 0; (ii < nrow_types); ii++ ) {
      if ( row_types[ii].aliases ) {
        free( row_types[ii].aliases );
        row_types[ii].aliases = 0;
      }
    }

    free( row_types );
    row_types = 0;
  }

  nrow_types = 0;

  return sts;
}

#if defined(__STDC__) || defined(__cplusplus)
static int GetRowTypes( OMuword osnum )
#else
static int GetRowTypes( osnum )
OMuword osnum;
#endif
{
  int sts = OM_S_SUCCESS;
  UOM_TYPE *uom_types = 0;

  if ( nrow_types == 0 ) {
    int nvar;
    char line[64], tempBuff[12];

    sts = uom$give_table( osnum = osnum, table = &uom_types );
    if ( ! (sts & 1) )
      goto wrapup;

    _FOR_LIST( UOM_TYPE, uom_types, tt ) {
      int newrow = 0, indexes[5], ndx;

      sts = ReallocRowTypesByOne( 1, osnum, tt );
      if ( ! (sts & 1) )
        goto wrapup;

      ndx = 0;
      nvar = 0;
      line[0] = ' ' ;      /* put blank in first char */
      line[1] = '\0';      /* and terminate string    */
      memset( indexes, 0, 5 * sizeof( int ) );

      _FOR_LIST( UOM_VARIANT, tt->variant, vv ) {
        int index;
        char shortname[11];

        uom$get_variant_shortname( variant = vv, shortname = shortname,
                                   index = &index );
        indexes[ ndx ] = index;
        sprintf( tempBuff, "%-10.10s ", shortname );
        strcat( line, tempBuff );
        if ( ! ( (nvar + 1) % 5) ) {   /* must be 1 relative, not 0 relative */
          sts = AllocRowTypesAliases( newrow, osnum, line, indexes, tt );
          if ( ! (sts & 1) )
            goto wrapup;
          line[0] = ' ' ;         /* put blank in first char */
          line[1] = '\0';         /* and terminate string    */
          memset( indexes, 0, 5 * sizeof( int ) );
          newrow = 1;
          ndx = 0;
        }
        else
          ndx++;

        nvar++;
      } _END_LIST

      if ( nvar % 5 ) {
        sts = AllocRowTypesAliases( newrow, osnum, line, indexes, tt );
        if ( ! (sts & 1) )
          goto wrapup;
      }
/*
 *  Put blank row between types
 */
      sts = ReallocRowTypesByOne( 0, osnum, (UOM_TYPE *) 0 );
      if ( ! (sts & 1) )
        goto wrapup;
    } _END_LIST
  }

wrapup:
  return sts;
}

static int GiveSelectedUnitType( sel_index, type_index )
int *sel_index, *type_index;
{
  int sts = OM_S_SUCCESS;
  int ii, jj;
  int sel_flag;

  *sel_index = *type_index = -1;

  for ( ii = 0; (ii < nrow_types); ii++ ) {
    sts = FIfld_get_select( EdtUomDefs, MAIN_FIELD, ii, RDOUT_COL, &sel_flag );
    FIRET_TEST;
    if ( sel_flag ) {
      *sel_index = ii;
      for ( jj = ii; (jj >= 0); jj-- ) {
        if ( row_types[jj].typehdr ) {
          *type_index = jj;
          break;
        }
      }
      break;
    }
  }

wrapup:
  return sts;
}


#if defined(__STDC__) || defined(__cplusplus)
static int FillInForm( OMuword osnum, Form form, int flabel )
#else
static int FillInForm( osnum, form, flabel )
OMuword osnum;
Form form;
int flabel;
#endif
{
  int sts = OM_S_SUCCESS;
  int ii = 0;
  char text[FIELD_DIM];
 
  sts = GetRowTypes( osnum );
  if ( ! (sts & 1) )
    goto wrapup;

  switch ( flabel ) {
    case EDTUOMDEFS:
      {
        for ( ii = 0; (ii < nrow_types); ii++ ) {
          if ( row_types[ii].typehdr ) {
            sts = FIfld_set_text( form, MAIN_FIELD, ii, UTYP_COL,
                                  row_types[ii].type->name, 0 );
            FIRET_TEST;
            sts = FIfld_set_text( form, MAIN_FIELD, ii, DB_COL,
                                  row_types[ii].dbu, 0 );
            FIRET_TEST;
            if ( ! row_types[ii].defchg ) {
              sts = FIfld_set_text( form, MAIN_FIELD, ii, DEF_COL,
                                    row_types[ii].type->defalias[0], 0 );
              FIRET_TEST;
            }
          }
          else {
            sts = FIfld_set_text( form, MAIN_FIELD, ii, UTYP_COL,
                                  "", 0 );
            FIRET_TEST;
            sts = FIfld_set_text( form, MAIN_FIELD, ii, DB_COL,
                                  "", 0 );
            FIRET_TEST;
            sts = FIfld_set_text( form, MAIN_FIELD, ii, DEF_COL,
                                  "", 0 );
            FIRET_TEST;
          }

          if ( row_types[ii].aliases ) {
            sts = FIfld_set_text( form, MAIN_FIELD, ii, OPTS_COL,
                                  row_types[ii].aliases, 0 );
            FIRET_TEST;
          }
          else {
            sts = FIfld_set_text( form, MAIN_FIELD, ii, OPTS_COL,
                                  "", 0 );
            FIRET_TEST;
          }
        }
      }
      break;
    case EDTUOMRDOUT:
      {
        UOM_TYPE *type;
        UOM_READOUT *readout;
        int sel_index, type_index;
/*
 *  Which unit type readout specs to display ?
 */
        sts = GiveSelectedUnitType( &sel_index, &type_index );
        if ( ! (sts & 1) )
          goto wrapup;
        if ( sel_index >= 0 && type_index >= 0 )
          readout = &row_types[ type_index ].readout;
        else {
          goto wrapup;
        }

        type = row_types[ type_index ].type;

        sts = FIfld_set_text( form, UNIT_TYPE, 0, 0, type->name, 0 );
        FIRET_TEST;

        sts = ( readout->leading_zeros ) ?
          FIg_set_state_on( form, LEADING_ZERO_TOG ) :
            FIg_set_state_off( form, LEADING_ZERO_TOG );
        FIRET_TEST;

        sts = ( readout->trailing_zeros ) ?
          FIg_set_state_on( form, TRAILING_ZERO_TOG ) :
            FIg_set_state_off( form, TRAILING_ZERO_TOG );
        FIRET_TEST;

        sts = ( readout->decimal_char == UOM_PERIOD ) ?
          FIg_set_state_off( form, DECIMAL_COMMA_TOG ) :
            FIg_set_state_on( form, DECIMAL_COMMA_TOG );
        FIRET_TEST;

        sts = ( readout->alias_displayed ) ?
          FIg_set_state_on( form, DISPLAY_UNITS_TOG ) :
            FIg_set_state_off( form, DISPLAY_UNITS_TOG );
        FIRET_TEST;

        sprintf( text, "%d", readout->intermeas_spacing );
        sts = FIfld_set_text( form, INTER_UNIT_SPC_FLD, 0, 0, text, 0 );
        FIRET_TEST;

        sprintf( text, "%d", readout->intrameas_spacing );
        sts = FIfld_set_text( form, INTRA_UNIT_SPC_FLD, 0, 0, text, 0 );
        FIRET_TEST;

        sprintf( text, "%c", readout->left_fill_char );
        sts = FIfld_set_text( form, FILL_CHAR_FLD, 0, 0, text, 0 );
        FIRET_TEST;

        sprintf( text, "%d", readout->precision );
        sts = FIfld_set_text( form, DECIMAL_ACCUR_FLD, 0, 0, text, 0 );
        FIRET_TEST;

        sprintf( text, "%d", readout->denominator );
        sts = FIfld_set_text( form, FRAC_DENOM_FLD, 0, 0, text, 0 );
        FIRET_TEST;

        sts = FIfld_set_select( form, CASE_FLD,
                                readout->case_type, 0, 0 );
        FIRET_TEST;
        sts = FIfld_set_select( form, JUSTIFICATION_FLD,
                                readout->justification, 0, 0 );
        FIRET_TEST;
        sts = FIfld_set_select( form, THOUS_DELIM_FLD,
                                readout->thousands_char, 0, 0 );
        FIRET_TEST;
        sts = FIfld_set_select( form, DEC_FRAC_MODE_TOG,
                                readout->mode, 0, 0 );
        FIRET_TEST;
      }
      break;
    default:
      sts = OM_E_ABORT;
      break;
  }

wrapup:
  return sts;
}

static int GetAllVariantAliases( type, alias, unitAliases )
UOM_TYPE *type;
char *alias;
char **unitAliases;
{
  int sts = OM_S_SUCCESS;

  *unitAliases = 0;

  _FOR_LIST( UOM_VARIANT, type->variant, vv ) {
    char shortname[11];

    uom$get_variant_shortname( variant = vv, shortname = shortname );
    if ( ! strcmp( shortname, alias ) ) {
      int ii = 0;

      while ( vv->alias[ ii ] ) {
        if ( ! *unitAliases )
          *unitAliases = (char *) strdup( vv->alias[ ii ] );
        else
          *unitAliases = (char *) realloc( *unitAliases,
                 strlen( *unitAliases ) + 1 + strlen( vv->alias[ ii ] ) + 1 );
        if ( ! *unitAliases ) {
          sts = OM_E_NODYNMEM;
          goto wrapup;
        }
        if ( ii > 0 ) {
          strcat( *unitAliases, " " );
          strcat( *unitAliases, vv->alias[ ii ] );
        }
        ii++;
      }
      break;
    }
  } _END_LIST

wrapup:
  return sts;
}

static int SetSaveRestore( form )
Form form;
{
  int sts;
  int state;
  long attributes;

  sts = FIg_get_state( form, SAVE_REST, &state );
  FIRET_TEST;
  sts = FIf_get_attr( form, &attributes );
  FIRET_TEST;
  if ( state )
    attributes &= ~( FI_SAVE_RESTORE ) ;
  else
    attributes |= FI_SAVE_RESTORE ;
  sts = FIf_set_attr( form, attributes );
  FIRET_TEST;
  sts = FIg_set_state( form, SAVE_REST, state );
  FIRET_TEST;
  sts = FIf_erase( form );
  FIRET_TEST;
  sts = FIf_display( form );
  FIRET_TEST;

wrapup:
  return sts;
}

static int FormNotification( flabel, glabel, value, form )
int flabel;
int glabel;
double value;
Form form;
{
  int sts; 
  long msg = OM_S_SUCCESS;
  int response = EX_FORM_FINISHED;
  struct GRid md_id;
  char text[FIELD_DIM];
  int ii, row, col, pos, sel, r_pos, char_pos, sel_flag;
  char line[64], *unitAliases = 0;
  UOMalias_name unitName[3];
  UOMtype_name typeName;
  int sel_index, type_index;

  OM_S_OBJID my_id;
  OMuword osnum;

  sts = ex$get_cur_mod( id = &md_id.objid, osnum = &md_id.osnum );
  if ( ! (sts & 1) )
    goto wrapup;

  sts = FIf_get_cmd_oid_os( form, (unsigned int *) &my_id,
                            (unsigned short *) &osnum );
  FIRET_TEST;

  sts = FIg_set_text( form, FI_MSG_FIELD, "" );
  FIRET_TEST;

  switch ( flabel ) {
    case EDTUOMDEFS:
      {
        switch ( glabel ) {
          case SAVE_REST:
            sts = SetSaveRestore( form );
            if ( ! (sts & 1) )
              goto wrapup;
            break;
          case READOUT:
            sts = GiveSelectedUnitType( &sel_index, &type_index );
            if ( ! (sts & 1) )
              goto wrapup;
            if ( sel_index >= 0 ) {
              sts = om$send( msg = message COedtuom.set_state( BOTH ),
                             senderid = NULL_OBJID,
                             targetos = osnum, targetid = my_id );
              if ( ! (sts & 1) )
                goto wrapup;
              sts = DisplayForm( md_id.osnum, EdtUomRdOut, EDTUOMRDOUT );
              if ( ! (sts & 1) )
                goto wrapup;
            }
            else {
              sts = FIg_set_text( form, FI_MSG_FIELD, "Select unit type." );
              FIRET_TEST;
              sts = FIg_set_state_off( form, READOUT );
              FIRET_TEST;
            }
            break;
          case MAIN_FIELD:
            sts = FImcf_get_active_col( form, MAIN_FIELD, &col, &pos );
            FIRET_TEST;
            sts = FIfld_get_active_row( form, MAIN_FIELD, &row, &pos );
            FIRET_TEST;
            if ( col == DEF_COL ) {  /* Col is only selectable to allow */
                                     /* hilighiting - so reset it */
              sts = FIfld_get_select( form, MAIN_FIELD, row, col, &sel_flag );
              FIRET_TEST;
              sts = FIfld_set_select( form, MAIN_FIELD, row, col, !sel_flag );
              FIRET_TEST;
            }

            if ( col != OPTS_COL ) 
              break;               /* Don't respond to col 0, 1, 2 or 3 input */

            sts = FIfld_set_select( form, MAIN_FIELD, row, col, 0 );
            FIRET_TEST;

            if ( ! row_types[ row ].aliases )
              break;               /* ... or blank lines */

            sts = FIfld_get_text( form, MAIN_FIELD, row, col, 64,
                                  (unsigned char *) line, &sel,
                                  &r_pos );
            FIRET_TEST;
            sts = FIfld_get_active_char( form, MAIN_FIELD, col, &char_pos,
                                         &r_pos );
            FIRET_TEST;

            /* Find the index of the begining of the unit name */
            if ( char_pos >= 1 )
              char_pos = (((char_pos - 1) / 11) * 11) + 1;
            else 
              break;               /* Return if in the left part of the form */

            /* If curser is in the end of a line, NULL chars fill string */
            if ( ! line[ char_pos ] )
              break;  

            /* Determine Unit Type */
            type_index = -1;
            for ( ii = row; (ii >= 0); ii-- ) {
              if ( row_types[ii].typehdr ) {
                type_index = ii;
                break;
              }
            }
  
            if ( type_index >= 0 ) {
              UOM_TYPE *type;
              int nvar, n2skip = (row - type_index) * 5 + (char_pos / 11);

              nvar = 0;
              type = row_types[type_index].type;
              _FOR_LIST( UOM_VARIANT, type->variant, vv ) {
                if ( nvar == n2skip ) {
                  int ndx = row_types[ row ].indexes[ char_pos / 11 ];

                  strcpy( unitName[0], vv->alias[ndx] );
                  break;
                }
                nvar++;
              } _END_LIST

              /* Set default units to the selected units (form only)*/
              /* Space fill old default units name */

              memset( line, (int) ' ', 10 );
              line[11] = '\0';
              sts = FIfld_set_text( form, MAIN_FIELD, type_index, DEF_COL,
                                    line, 0 );
              FIRET_TEST;
              sts = FIfld_set_text( form, MAIN_FIELD, type_index, DEF_COL,
                                    unitName[0], 0 );
              FIRET_TEST;
              sts = FIfld_set_select( form, MAIN_FIELD, type_index, DEF_COL,
                                      1 );
              FIRET_TEST;
              row_types[type_index].defchg = 1;
              strcpy( row_types[type_index].newdef, unitName[0] );

              /* Show alias list of units at bottom of form */

              sts = FIfld_get_text( form, MAIN_FIELD, type_index, UTYP_COL,
                                    UOM_K_MAX_TYPE, (unsigned char *) typeName,
                                    &sel, &r_pos );
              FIRET_TEST;
              sts = GetAllVariantAliases( row_types[ type_index ].type,
                                          unitName[0], &unitAliases );
              if ( ! (sts & 1) )
                goto wrapup;
              if ( unitAliases ) {
                sts = FIg_set_text( form, ALIAS_LIST, unitAliases );
                FIRET_TEST;
              }
              else {
                sts = FIg_set_text( form, ALIAS_LIST, "" );
                FIRET_TEST;
              }
            }
            break;

          case FI_ACCEPT:
            {
              short state;

              for ( ii = 0; (ii < nrow_types); ii++ ) {
                if ( row_types[ii].typehdr && row_types[ii].defchg ) {
                  int num_defaults;
  
                  sts = FIfld_get_text( form, MAIN_FIELD, ii, UTYP_COL,
                                        UOM_K_MAX_TYPE,
                                        (unsigned char *) typeName,
                                        &sel, &r_pos );
                  FIRET_TEST;
/*
 * set default units for given type
 */
                  num_defaults = 1;
                  sts = uom$set_defaults( osnum = md_id.osnum,
                                          typename = typeName,
                                          num_defaults = &num_defaults,
                           defaults = (UOMalias_name *) row_types[ii].newdef );
                  if ( ! (sts & 1) )
                    goto wrapup;
                  row_types[ii].defchg = 0;
                  row_types[ii].newdef[0] = 0;
                }
              }
              ex$putque( msg = &msg, response = &response );

              sts = om$send( msg = message COedtuom.get_state( &state ),
                             senderid = NULL_OBJID,
                             targetos = osnum, targetid = my_id );
              if ( ! (sts & 1) )
                goto wrapup;

              if ( state == BOTH ) {
                sts = om$send( msg = message COedtuom.set_state( INIT ),
                               senderid = NULL_OBJID,
                               targetos = osnum, targetid = my_id );
                if ( ! (sts & 1) )
                  goto wrapup;
                sts = FIf_erase( EdtUomRdOut );
                FIRET_TEST;
              }

              sts = FIf_erase( EdtUomDefs );
              FIRET_TEST;
            }
            break;

          case FI_CANCEL: 
            {
              short state;

              ex$putque( msg = &msg, response = &response );

              sts = om$send( msg = message COedtuom.get_state( &state ),
                             senderid = NULL_OBJID,
                             targetos = osnum, targetid = my_id );
              if ( ! (sts & 1) )
                goto wrapup;

              if ( state == BOTH ) {
                sts = om$send( msg = message COedtuom.set_state( INIT ),
                               senderid = NULL_OBJID,
                               targetos = osnum, targetid = my_id );
                if ( ! (sts & 1) )
                  goto wrapup;
                sts = FIf_erase( EdtUomRdOut );
                FIRET_TEST;
              }

              sts = FIf_erase( EdtUomDefs );
              FIRET_TEST;
            }
            break;

          default:
            break;   /* what gadget ??? */

        }  /* END switch ( glabel ) */
      }
      break;  /* END case EDTUOMDEFS: */

    case EDTUOMRDOUT:
      {
        UOM_TYPE *type;
        UOM_READOUT *readout;
        int sel_index, type_index;
/*
 *  Which unit type readout specs to change ?
 */
        sts = GiveSelectedUnitType( &sel_index, &type_index );
        if ( ! (sts & 1) )
          goto wrapup;
        if ( sel_index >= 0 && type_index >= 0 )
          readout = &row_types[ type_index ].readout;
        else {
          goto wrapup;
        }

        type = row_types[ type_index ].type;

        switch ( glabel ) {
          case SAVE_REST:
            sts = SetSaveRestore( form );
            if ( ! (sts & 1) )
              goto wrapup;
            break;

          case FI_ACCEPT:
            ex$putque( msg = &msg, response = &response );
            sts = FIf_erase( form );
            FIRET_TEST;
            sts = FIg_set_state_off( EdtUomDefs, READOUT );
            FIRET_TEST;
            sts = uom$set_readout( osnum = md_id.osnum, typename = type->name,
                                   primary = readout );
            if ( ! (sts & 1) )
              goto wrapup;
            break;

          case FI_CANCEL: 
            ex$putque( msg = &msg, response = &response );
            sts = FIf_erase( form );
            FIRET_TEST;
            sts = FIg_set_state_off( EdtUomDefs, READOUT );
            FIRET_TEST;
            memcpy( &row_types[ type_index ].readout, &type->primary,
                    sizeof( UOM_READOUT ) );
            break;

          case DEC_FRAC_MODE_TOG:
            readout->mode = (int) value;
            break;

          case CASE_FLD:
            readout->case_type = (char) value;
            break;

          case JUSTIFICATION_FLD:
            readout->justification = (char) value;
            break;

          case FILL_CHAR_FLD:
            sts = FIfld_get_text( form, FILL_CHAR_FLD, 0, 0, FIELD_DIM,
                                  (unsigned char *) text, &sel_flag, &r_pos );
            FIRET_TEST;
            ii = 0;
            while ( text[ii] ) {
              readout->left_fill_char = text[ii];
              ii++;
            }
            break;

          case LEADING_ZERO_TOG:
            readout->leading_zeros = readout->leading_zeros ?
                                                   (char) 0 :
                                                   (char) 1 ;
            break;

          case TRAILING_ZERO_TOG:
            readout->trailing_zeros = readout->trailing_zeros ?
                                                     (char) 0 :
                                                     (char) 1 ;
            break;

          case INTER_UNIT_SPC_FLD:
            sts = FIfld_get_text( form, INTER_UNIT_SPC_FLD, 0, 0,
                                  FIELD_DIM, (unsigned char *) text,
                                  &sel_flag, &r_pos );
            FIRET_TEST;
            readout->intermeas_spacing = (short) atoi( text );
            break;

          case INTRA_UNIT_SPC_FLD:
            sts = FIfld_get_text( form, INTRA_UNIT_SPC_FLD, 0, 0,
                                  FIELD_DIM, (unsigned char *) text,
                                  &sel_flag, &r_pos );
            FIRET_TEST;
            readout->intrameas_spacing = (short) atoi( text );
            break;

          case DECIMAL_COMMA_TOG:
            if ( readout->decimal_char == UOM_COMMA )
              readout->decimal_char = UOM_PERIOD;
            else if ( readout->decimal_char == UOM_PERIOD )
              readout->decimal_char = UOM_COMMA;
            break;

          case THOUS_DELIM_FLD:
            readout->thousands_char = (char) value;
            break;

          case FRAC_DENOM_FLD:
            sts = FIfld_get_text( form, FRAC_DENOM_FLD, 0, 0,
                                  FIELD_DIM, (unsigned char *) text,
                                  &sel_flag, &r_pos );
            FIRET_TEST;
            readout->denominator = (short) atoi( text );
            break;

          case DECIMAL_ACCUR_FLD:
            {
              short temp;

              sts = FIfld_get_text( form, DECIMAL_ACCUR_FLD, 0, 0,
                                    FIELD_DIM, (unsigned char *) text,
                                    &sel_flag, &r_pos );
              FIRET_TEST;
              temp = (short) atoi( text );
              if ( temp >= 0 && temp <= 16 )
                readout->precision = temp;
              else {
                ex$message( msgnumb = GR_E_InvInp, buff = text );
                sts = FIg_set_text( form, FI_MSG_FIELD, text );
                FIRET_TEST;
                sprintf( text, "%d", readout->precision );
                sts = FIfld_set_text( form, DECIMAL_ACCUR_FLD, 0, 0,
                                      text, 0 );
                FIRET_TEST;
              }
            }
            break;

          case DISPLAY_UNITS_TOG:
            readout->alias_displayed = readout->alias_displayed ?
                                                       (char) 0 :
                                                       (char) 1 ;
            break;

          default:
            break;   /* what gadget ??? */

        }  /* END switch ( glabel ) */
      }
      break;  /* END case EDTUOMDEFS: */

    default:
      break;  /* what form ??? */

  }  /* END switch ( flabel ) */

wrapup:
  if ( unitAliases )
    free( unitAliases );

  return sts;
}

end implementation COedtuom;
