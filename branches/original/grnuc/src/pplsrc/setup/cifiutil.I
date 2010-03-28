class implementation ci ;

/* -- Generic manipulations of forms
   -- */
/*----------------------------------------------------------------------------*/
#	include "igrtypedef.h"
#	include "igetypedef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "exmacros.h"
#	include "msdef.h"
#	include "msmacros.h"
#	include "cimsg.h"
#	include "FI.h"
#	include "cisetup.h"
#	include <string.h>
#	include	<fcntl.h>
#	include <ctype.h>

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

static void CIfm_form_notification __((int f_label, int g_label, 
                                       double value, Form form));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


/*----------------------------------------------------------------------------*/
int CIfm_put( form, gad ) Form form ; struct FI_X_data_st *gad ; {

  long FIsts;
  int  attr;

  FIg_get_attr (form, gad->label, &attr);
  if (!(attr & FI_NOT_DISPLAYED))
    FIg_erase (form, gad->label);

  switch (gad->type) {

    case FI_X_STATE:
	FIsts = FIg_set_state (form, gad->label, gad->value.state);
	break;
    case FI_X_INT:
	FIsts = FIg_set_value (form, gad->label, (double)gad->value.ivalue);
	break;
    case FI_X_DOUBLE:
	FIsts = FIg_set_value (form, gad->label, gad->value.dvalue);
        break;
    case FI_X_ALPHA: {
	int gtype;

	FIg_get_type (form, gad->label, &gtype);
	if (gtype == FI_FIELD)
	  FIsts = FIfld_set_text (form, gad->label, gad->index, 0,
					gad->value.alpha, gad->select_flag);
	else FIg_set_text (form, gad->label, gad->value.alpha);
        break;
    }
    default:
#ifdef TEST
	printf ("CIfm_put:  Unknown gadget type <%d>\n", gad->type);
#endif
	return FALSE;
  }

  if (!(attr & FI_NOT_DISPLAYED))
    FIg_display (form, gad->label);

  return (FIsts == FI_SUCCESS);
}
/*----------------------------------------------------------------------------*/
int CIfm_get( form, gad ) Form form ; struct FI_X_data_st *gad ; {

  long FIsts; int dummy;

  FIg_get_type (form, gad->label, &gad->type);
  switch (gad->type) {

    case FI_FIELD:
	FIfld_get_type (form, gad->label, 0, &gad->type);
	FIfld_get_num_rows (form, gad->label, &gad->max_index);
/*	FIfld_get_active_row (form, gad->label, &gad->index, &dummy);   */

	switch (gad->type) {
	  case FI_INT:
		gad->type = FI_X_INT;
		FIsts = FIfld_get_value (form, gad->label, gad->index, 0,
				&gad->value.dvalue, &gad->select_flag, &dummy);
		gad->value.ivalue = (int)gad->value.dvalue;
		break;

	  case FI_DOUBLE:
		gad->type = FI_X_DOUBLE;
		FIsts = FIfld_get_value (form, gad->label, gad->index, 0,
				&gad->value.dvalue, &gad->select_flag, &dummy);
		break;

	  case FI_ALPHA:
		gad->type = FI_X_ALPHA;
		FIsts = FIfld_get_text (form, gad->label, gad->index, 0,
				sizeof (gad->value.alpha), gad->value.alpha,
				&gad->select_flag, &dummy);
		break;
	}
	break;

    case FI_TOGGLE:
    case FI_CHECKLIST:
    case FI_BUTTON:
	gad->type        = FI_X_STATE;
	gad->index       = 0;
	gad->max_index   = 0;
	gad->select_flag = 0;
	FIsts = FIg_get_state (form, gad->label, &gad->value.ivalue);
	gad->value.state = (char)gad->value.ivalue;
	break;

    case FI_SLIDER:  /* Am assuming integer ONLY here because PPL does!! */
    case FI_DIAL:
    case FI_SCROLL:
	gad->type        = FI_X_INT;
	gad->index       = 0;
	gad->max_index   = 0;
	gad->select_flag = 0;
	FIsts = FIg_get_value (form, gad->label, &gad->value.dvalue);
	gad->value.ivalue = (int)gad->value.dvalue;
	break;

    default:
#ifdef DEBUG
	printf ("CIfm_get:  Unknown gadget type <%d>\n", gad->type);
#endif
	return FALSE;
  }

  return (FIsts == FI_SUCCESS);
}
/*----------------------------------------------------------------------------*/
void CIfm_erase( form, reset, endf )	Form	form;
					int	reset, endf; {
  FIf_erase (form);
  if (reset)
	FIf_reset (form);
  if (endf) {
	long msg;
	int  resp = EX_FORM_FINISHED;
	ex$putque (msg = &msg, response = &resp);
  }
}
/*----------------------------------------------------------------------------*/
void CIfm_delete( fid ) Form fid ; {

  FIf_delete (fid);
}
/*----------------------------------------------------------------------------*/
static void CIfm_form_notification (f_label, g_label, value, form)

int    f_label;
int    g_label;
double value;
Form   form;
{
  unsigned int		cmd_oid;
  unsigned short	cmd_os;  
  struct FI_X_data_st	form_data;

  FIf_get_cmd_oid_os (form, &cmd_oid, &cmd_os);
  form_data.label = g_label;
  form_data.index = (int)value;
  CIfm_get (form, &form_data);

  om$send ( targetid = cmd_oid,
	    targetos = cmd_os,
	    senderid = NULL_OBJID,
	    msg = message super_cmd.form_input (f_label, (char *)&form_data) );
}
/*----------------------------------------------------------------------------*/
int CIfm_init( file, lab, coid, coos, cons, form_p )
					char		*file		;
					int		lab, cons	;
					OMuword 	coos		;
					OM_S_OBJID 	coid		;
					Form		*form_p		; {

/* -- Constructs a form if `cons' is TRUE then initializes it.
      INPUT  : file, form description file.
               lab , label of form.
	       coid, coos, objid/osnum of command object associated with form.
	       cons, construction flag.
               form_p, addr of form pointer if initialization only.
      OUTPUT : form_p, addr of form pointer if construction.
      The construction flag allows an already constructed form to be
      associated with a another command object.
   -- */
		int rc ;

  if( cons ) {
#ifdef DEBUG
  printf( "CIfm_init: construct of <%s>\n", file ) ;
#endif
	rc = FIf_new (lab, file, CIfm_form_notification, form_p);
  } else rc = FI_SUCCESS ;

  if( rc == FI_SUCCESS ) {
#ifdef DEBUG
  printf( "CIfm_init: init of <%s> linked with (%d,%d)\n", file, coos, coid ) ;
#endif
	rc = FIf_set_cmd_oid_os (*form_p, coid, coos);
  }

  return (rc == FI_SUCCESS);

} /* CIfm_init */
/*----------------------------------------------------------------------------*/
int CIfm_display( form, flag ) Form form ; int flag ; {

	long rc;

	if( flag ) ex$message( msgnumb = CI_S_fmDISPLA ) ;
	rc = FIf_display (form);
#ifdef DEBUG
  if( rc != FI_SUCCESS ) {
	printf( "CIfm_display: cannot display form\n" ) ; fflush( stdout ) ;
  }
#endif
	if( flag ) ex$message( field = ERROR_FIELD, in_buff = "" )	;

	return (rc == FI_SUCCESS);

} /* CIfm_display */
/*----------------------------------------------------------------------------*/
#argsused
int CIfm_help( co, topic ) struct GRid *co ; char *topic ; {

/* -- Tells command object to display help topic.
   -- */
	long rc ;

/* Does not work at present ...
	rc = om$send( msg	= message super_cmd.help_topic( 0, topic ),
		      targetid	= co->objid,
		      targetos	= co->osnum,
		      senderid	= NULL_OBJID ) ;
	if( rc & SUCC )
		rc = om$send(	msg		= message super_cmd.help(),
		      		targetid	= co->objid,
				targetos	= co->osnum,
				senderid	= NULL_OBJID ) ;

... Direct call to help in the mean time ... */
	rc = Help_topic( topic ) ;
	return rc ;

} /* CIfm_help */
/*----------------------------------------------------------------------------*/
void CIexpand( path, expanded, size ) char *path, *expanded ; int size ; {

/* -- Replaces shell variables in a path by their values.
      INPUT : path	, path to expand.
      	      size	, dimension of array `expanded'.
      OUTPUT: expanded  , expanded path.
      NOTE  : `expanded' is truncated to size-1 characters if there is not
              enough room.
   -- */
	UNIXpath	shell			;
	char		*getenv()		;
	register char	*p, *q			;
	register int	count			;

	p = path ; count = 0 ;
	while( *p ) {
		if( *p == '$' ) {
			p++ ;
			q = shell ;
			while( isalnum( *p ) || *p == '_' ) {
				*q++ = *p++ ;
			}
			*q = '\0' ;
			if( q = getenv( shell ) ) {
				if( ( count += strlen( q ) ) < size ) {
					strcpy( expanded, q )	;
					expanded += strlen( q )	;
				} else break ;
			}
		} else {
			if( ++count < size )	*expanded++ = *p++	;
			else			break			;
		}
	}
	*expanded = '\0' ;
		
} /* CIexpand */
/*----------------------------------------------------------------------------*/

end implementation ci ;
