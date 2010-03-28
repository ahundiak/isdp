/* -- Command Language Executor List source Files Form Handler.
      This form is invoked when pressing the "LIST" button of the "CI Setup"
      form. NOTE: even if several CI setups are active at the same time, there
      will only be ONE CiSrcLs form: that of the first CI Setup. This module
      will refuse to construct another one if one already exists.
   -- */
class implementation COcisetup ;
/*----------------------------------------------------------------------------*/
#	include "exsysdep.h"
#	include "OMminimum.h"
#	include "OMerrordef.h"
#	include "igrtypedef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "exmacros.h"
#	include "msmacros.h"
#	include "wl.h"
#	include "igecolor.h"
#	include "igecolmacros.h"
#	include "FI.h"
#	include "cimsg.h"
#	include <string.h>
#	include <sys/types.h>
#	include <sys/stat.h>
#	include <dirent.h>
#	include <ctype.h>
#	include <malloc.h>
#	include <unistd.h>
#	include "cisetup.h"
#	include "ciprivmacros.h"
/*----------------------------------------------------------------------------*/
#define CiSrcLs_name	"CiSrcLs"
/* -- Label of CiLsSrc form ( anything different form CiSetup form label! ).
   -- */
#define CiSrcLs_label	12346
#define CiSrcLs_help	"CIls_help"

#define CI_LS_EDNAME1	"vi"
#define CI_LS_EDNAME2	"emacs"
#ifdef CLIX
#define CI_LS_EDNAME3	"MicroEMACS"
#define CI_LS_EDNAME4	"MousEMACS"
#else
#define CI_LS_EDNAME3   "** NONE **"
#define CI_LS_EDNAME4   "** NONE **"
#endif

#ifdef CLIX
#define CI_LS_EDEXEC1	"/usr/bin/vi"
#define CI_LS_EDEXEC2	"/usr/bin/emacs"
#define CI_LS_EDEXEC3	"/usr/bin/memacs"
#define CI_LS_EDEXEC4	"/usr/bin/me"
#define CI_LS_VTERMEX	"/usr/ip32/vt200/vterm"
#define CI_LS_SHELLEX	"/bin/ksh"
#endif

#ifdef SUNOS
#define CI_LS_EDEXEC1   "/usr/ucb/vi"
#define CI_LS_EDEXEC2   "/usr/ucb/emacs"
#define CI_LS_EDEXEC3   "** NONE **"
#define CI_LS_EDEXEC4   "** NONE **"
#define CI_LS_VTERMEX   "/usr/openwin/bin/xterm"
#define CI_LS_SHELLEX   "/bin/ksh"
#endif

#ifdef SUNOS5
#define CI_LS_EDEXEC1   "/usr/5bin/vi"
#define CI_LS_EDEXEC2   "/usr/5bin/emacs"
#define CI_LS_EDEXEC3   "** NONE **" 
#define CI_LS_EDEXEC4   "** NONE **"
#define CI_LS_VTERMEX   "/usr/openwin/bin/xterm"
#define CI_LS_SHELLEX   "/bin/ksh"
#endif

#ifdef IRIX
#define CI_LS_EDEXEC1   "/usr/bin/vi"
#define CI_LS_EDEXEC2   "/usr/bin/emacs"
#define CI_LS_EDEXEC3   "** NONE **"
#define CI_LS_EDEXEC4   "** NONE **"
#define CI_LS_VTERMEX   "/usr/bin/X11/xterm"
#define CI_LS_SHELLEX   "/bin/ksh"
#endif

/* -- Max number of characters for display of directory name, editor name.
   -- */
#define DIRDPLEN	26
#define EDTDPLEN	11
#define MSGDPLEN	80
#define MSGCOLOR	FI_BLACK
#define ERRCOLOR	FI_GREEN

/* -- Max number of display fields for directories, of editor buttons, of
      directories to display, of gadget ids.
   -- */
#define MAXLSFLD	4
#define MAXEDCNT	4
#define MAXDIRCT 	10
#define MAXLABID	6

#define NULL_LABEL	(-1)
#define FIRST_TIME	2
#define OFF		0
#define ON		1
#define USABLE		1
#define NOFILE		2
#define NOTOPN		0
#define NOTUSD		4


/*----------------------------------------------------------------------------*/
/* -- FMB-assigned gadget labels:
	QUIT BuTton	, HELP BuTton	, LiSt FieLD 1 2 3 4	,
	DIRectory TeXt for name 1 2 3 4	, EXECute BuTton	,
	EDIT BuTton	, EDIToR choice 1 2 3 4			,
	text for EDitor NAMe 1 2 3 4	, MeSsaGe TeXT line	,
	NEW File BuTton			, NEW File FielD	,
	SLIDER to scroll through directory list
   -- */
enum LSlabs {
	QUITBT =  4, HELPBT =  6, LSFLD1 = 14, LSFLD2 = 12, LSFLD3 = 13,
	LSFLD4 = 15, DIRTX1 = 16, DIRTX2 = 17, DIRTX3 = 18, DIRTX4 = 19,
	EXECBT = 20, EDITBT = 21, EDITR1 = 22, EDITR2 = 23, EDITR3 = 24,
	EDITR4 = 25, EDNAM1 = 22, EDNAM2 = 23, EDNAM3 = 24, EDNAM4 = 25,
	MSGTXT = 30, SLIDER = 31, NEWFBT = 37, NEWFFD = 38, TERMBT = 39,
	BORDER = 41, NULGAD = -1
}  ;

typedef char Uname[CI_NAME_MAX+1] ;

typedef struct {
/* --		Form ID of CiSrcLs form.
   -- */
		Form	fm ;
/* --		Form ID of CiSetup form from which CiSrcLs form is invoked.
   -- */
		Form	super			;
/* --		Active source file.
   -- */
		UNIXpath	active			;
/* --		Directory where currently highlighted field is.
		lab = LSFLD1, LSFLD2, LSFLD3, LSFLD4
		dir = 0 ... MAXINCDIRS-1
		row = 0 ... FI_X_LINE_LEN-1
   -- */
		struct	{	enum LSlabs	lab ;
				unsigned char	row,
						dir  ;
		} hltfld				;
/* --		Source file directories to list.
   -- */
		UNIXpath	PPLdir[MAXINCDIRS]	;
/* --		Directory statuses :
			USABLE : directory contains has PPL files.
			NOFILE : directory does not contain PPL files.
			NOTOPN : directory could not be opened.
   -- */
		char	dirsts[MAXINCDIRS]		;
/* --		Names of available editors and source path to their executables.
   -- */
		char	*edname[MAXEDCNT],
			*edexec[MAXEDCNT]		;

/* --		Index of starting directory for list.
  -- */
		char	strtdir				;
/* --		Edit state ( editing new file, current file ), pathname of file
		to create. Path name of created file.
   -- */
		enum LSlabs	editsta			;
		UNIXpath	newfile			;
} CIls ;
%safe
/*  -- Pointer to form's internal data. If NULL, no CiSrcLs form exists.
    -- */
static CIls		*ci__ls = NULL	;
%endsafe
extern char *CIfm_cut_path() ;

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

static void CIls_put_gadget_color __((enum LSlabs label, int color));
static void CIls_msg __((int msnb, int color, int time));
static int CIls_grestore __((int count, enum LSlabs *list));
static int CIls_gerase __((int count, enum LSlabs *list));
static int CIls_put __((char *text, enum LSlabs lab, int ind, int sel));
static void CIls_select __((enum LSlabs field, int row, int flag));
static int CIls_on_off __((enum LSlabs label, int flag));
static void initPPLdirs __((void));
static void CIfill_dir __((enum LSlabs dirlab, Uname list[FI_X_LINE_LEN ], 
                           int count));
static void CIls_show_editors __((int flag));
static void CIls_me __((void));
static void CIls_edit_file __((UNIXpath file, enum LSlabs edlab));
static int CIls_edit_off __((enum LSlabs btn, int check));
static void CIls_terminal __((void));
static void CIls_prompt __((void));
static void CIls_input_file_name __((void));
static void CIls_create_file __((Uname name));
static void CIls_active __((int row, int col, enum LSlabs lab, Uname file));
static int CIls_valid_input __((char *in));


#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


/*----------------------------------------------------------------------------*/
char *CIexmessage( code ) int code ; {
	static char text[FI_X_STRLEN+1] ;

 	ex$message(	msgnumb	= code	,
 			buff	= text	) ;

	return text ;
}
/*----------------------------------------------------------------------------*/
static void CIls_put_gadget_color( label, color )	enum LSlabs	label ;
							int		color ;{

/* -- Changes color of gadget.
   -- */
	int rc;
	rc = FIg_set_color (ci__ls->fm, label, color);
#ifdef DEBUG
  if( rc != FI_SUCCESS ) {
	printf( "CIls_put_gadget_color: error %d for gadget %d\n", rc, label ) ;
  }
#endif

} /* CIls_put_gadget_color */
/*----------------------------------------------------------------------------*/
static void CIls_msg( msnb, color, time ) int msnb, color, time ; {

/* -- Outputs message to message area.
      INPUT  : msnb, message number for ex$message.
               color, logical color of message text.
               time , time to sleep after message is displayed.
   -- */
	char *msg ; static int old = MS_NO_MSG ;

	if( msnb != old ) {
 		CIls_put_gadget_color( MSGTXT, color )		;
		switch( msnb ) {
			case 0	: msg = ""			; break ;
			default	: msg = CIexmessage( msnb )	;
			  	  msg[MSGDPLEN] = '\0'		; break ;
		}
		CIls_put( msg, MSGTXT, 0, 0 ) ;
		old = msnb ;
	}
	if( time ) sleep( time ) ;
}
/*----------------------------------------------------------------------------*/
static int CIls_grestore( count, list ) int count ; enum LSlabs *list ; {
	int rc;

  rc = FI_SUCCESS;
  while (count-- && rc == FI_SUCCESS)
    rc = FIg_display (ci__ls->fm, list[count]);

#ifdef DEBUG
 fflush( stderr ) ;
 if( rc != FI_SUCCESS ) {
	printf( "CIls_grestore: restore_gadgets( %d, %d ) failed\n", count, *list ) ;
 	fflush( stdout ) ;
 }
 printf( "CIls_grestore: EXIT\n" ) ; fflush ( stdout ) ;
#endif
	return rc ;
}
/*----------------------------------------------------------------------------*/
static int CIls_gerase( count, list ) int count ; enum LSlabs *list ; {
				int rc;

  rc = FI_SUCCESS;
  while (count-- && rc == FI_SUCCESS)
    rc = FIg_erase (ci__ls->fm, list[count]);
#ifdef DEBUG
 fflush( stderr ) ;
 if( rc != FI_SUCCESS ) {
	printf( "CIls_gerase: erase_gadgets( %d, %d ) failed\n", count, *list ) ;
	fflush( stdout ) ;
 }
#endif
	return rc ;
}
/*----------------------------------------------------------------------------*/
static int CIls_put( text, lab, ind, sel )	char		*text	;
						enum LSlabs	lab	;
						int		ind	,
								sel	; {

	struct FI_X_data_st gad ;

	gad.type	= FI_X_ALPHA	;
	gad.label	= lab		;
	gad.index	= ind		;
	gad.select_flag	= sel		;
	strncpy( gad.value.alpha, text, FI_X_STRLEN )[FI_X_STRLEN] = '\0' ;
	return CIfm_put( ci__ls->fm, &gad )	;
}
/*----------------------------------------------------------------------------*/
static void CIls_select( field, row, flag )	enum LSlabs	field	;
						int		row, flag ; {

/* -- Makes a field selected or not selected (according to `flag').
   -- */
				int			rc	;

#ifdef DEBUG
  printf( "CIls_select: field %d row %d flag %d\n", field, row, flag ) ; fflush( stdout ) ;
#endif
	rc = FIfld_set_select (ci__ls->fm, field, row, 0, flag);

#ifdef DEBUG
  printf( "CIls_select: EXIT\n" ) ; fflush( stdout ) ;
#endif
}
/*----------------------------------------------------------------------------*/
static int CIls_on_off( label, flag )	enum LSlabs	label	;
					int		flag	; {
	struct FI_X_data_st input ; int rc ;

	input.type		= FI_X_INT	;
	input.value.ivalue	= flag		;
	input.label		= label		;

	CIfm_put( ci__ls->fm, &input )		;
	return rc ;
}
/*----------------------------------------------------------------------------*/
static void initPPLdirs() {

/* -- Extract directories from search path for PPL source files.
   -- */
	char		*dirs[MAXINCDIRS], cipath[1+CIPATHLEN]	;
	UNIXpath	expanded				;
	int		i ;

	CIsplit_path( strcpy( cipath, CIsrc_path ), dirs, MAXINCDIRS ) ;
	for( i = 0 ; i < MAXINCDIRS ; i++ ) {
		if( dirs[i] != NULL ) {
			CIexpand( dirs[i], expanded, CI_PATH_MAX + 1 )	;
			strcpy( ci__ls->PPLdir[i], expanded )		;
		} else	*ci__ls->PPLdir[i] = '\0' ;
		ci__ls->dirsts[i] = NOTUSD ;
	}
}
/*----------------------------------------------------------------------------*/
char *CIls_cnst( coid, coos, superid )	OM_S_OBJID	coid;
					OMuword		coos;
					Form		superid ; {
	
/* -- Constructs a CiLsSrc form if none exists.
      INPUT  : superid, of calling form.
               coid   , coos   , of command object of calling form.
      RETURNS: NULL if OK, else pointer to error message.
   -- */
	int		rc					;
	char		*msg = NULL				;
/* ERASE if OK
	char		*dirs[MAXINCDIRS], cipath[1+CIPATHLEN]	;
	UNIXpath	expanded				;
end ERASE if OK */

 if( ci__ls == NULL ) {
   if( ci__ls = (CIls *) malloc( sizeof( CIls ) ) ) {
	ci__ls->edname[0]	= CI_LS_EDNAME1 ;
	ci__ls->edexec[0]	= CI_LS_EDEXEC1 ;
	ci__ls->edname[1]	= CI_LS_EDNAME2 ;
	ci__ls->edexec[1]	= CI_LS_EDEXEC2 ;
	ci__ls->edname[2]	= CI_LS_EDNAME3 ;
	ci__ls->edexec[2]	= CI_LS_EDEXEC3 ;
	ci__ls->edname[3]	= CI_LS_EDNAME4 ;
	ci__ls->edexec[3]	= CI_LS_EDEXEC4 ;
	ci__ls->active[0] 	= '\0' 		;
	ci__ls->newfile[0] 	= '\0' 		;
	ci__ls->strtdir		= 0		;
	ci__ls->super		= superid	;
	ci__ls->hltfld.lab	= LSFLD1	;
	ci__ls->hltfld.row	= 0     	;
	ci__ls->hltfld.dir	= 0     	;
	ci__ls->editsta		= NULGAD     	;

/* -- Extract directories from search path for PPL source files.
   -- */
	initPPLdirs() ;
	for( rc = 0 ; rc < MAXINCDIRS ; rc++ ) {
		ci__ls->dirsts[rc] = NOTUSD ;
	}
/* ERASE if OK
	CIsplit_path( strcpy( cipath, CIsrc_path ), dirs, MAXINCDIRS ) ;
	for( rc = 0 ; rc < MAXINCDIRS ; rc++ ) {
		if( dirs[rc] != NULL ) {
			CIexpand( dirs[rc], expanded, CI_PATH_MAX + 1 )	;
			strcpy( ci__ls->PPLdir[rc], expanded )		;
		} else	*ci__ls->PPLdir[rc] = '\0' ;
	}
end ERASE if OK */

	rc = CIfm_init( CiSrcLs_name	, CiSrcLs_label	, coid	,
			coos		, TRUE		, &ci__ls->fm ) ;

	if( !rc ) msg = CIexmessage( CI_W_lsLSCNST ) ;
   } else msg = CIexmessage( CI_W_lsLSCNST ) ;
 } else msg = CIexmessage( CI_I_lsLSEXST ) ;

 return msg ;

} /* CIls_cnst */
/*----------------------------------------------------------------------------*/
static void CIfill_dir( dirlab, list, count )
				enum LSlabs	dirlab			;
				Uname		list[FI_X_LINE_LEN]	;
				int		count			; {

		int i, blank ; struct FI_X_data_st *name ;

#ifdef DEBUG
  printf( "CIfill_dir: lab %d count %d\n", dirlab, count ) ; fflush( stdout ) ;
#endif
  if( !count ) {
	blank = TRUE	;
	count = 1	;
  } else blank = FALSE ;

  if( name = (struct FI_X_data_st *) malloc( count * sizeof *name ) ) {	
	FIfld_set_num_rows (ci__ls->fm, dirlab, count);
	if( blank ) *list[0] = '\0' ;
	for( i = 0 ; i < count ; i++ ) {
		name[i].label		= dirlab		;
		name[i].type		= FI_X_ALPHA		;
		name[i].index		= i			;
		name[i].select_flag	= FI_X_EDIT_NOSELECT	;
		strcpy( name[i].value.alpha, list[i] ) ;
		CIfm_put (ci__ls->fm, &name[i]);
	}

	FIfld_pos_cursor (ci__ls->fm, dirlab, 0, 0, 0, 0, 0, 0);
	free( (char *) name ) ;
  }
}
/*----------------------------------------------------------------------------*/
#argsused
void CIls_upd_selected( action, actdir, actrow, actcol, actfil )
		int 		action, actrow, actcol	;
		enum LSlabs	actdir			;
		Uname		actfil			; {
}
/*----------------------------------------------------------------------------*/
void CIls_dpdir( action, min, max ) int action, min, max ; {

/* -- Displays the source file directories: only retain regular files ending
      with ".u". in columns between `min' and `max' ( NOT INCLUDING `max' ).
      INPUT  : action, FALSE: no reset, TRUE: reset, FIRST_TIME: 1st time call.
	       min, max, diplays in fields >= `min' and <= `max'.
   -- */

extern	char			*bsearch();
	UNIXpath		fname				;
	char			*cur, *c, buf[DIRDPLEN+1]	;
	struct stat		fstat				;
	struct dirent		*fentry				;
	DIR			*dirp				;
	int			col, row, act_col, act_row	;
	enum LSlabs		Dnam[MAXLSFLD],
				Dfld[MAXLSFLD]			;
	Uname			list[FI_X_LINE_LEN], act_file	;
	void			qsort()				;
 
#ifdef DEBUG
  printf( "CIls_dpdir : ENTER\n" ) ; fflush( stdout ) ;
#endif
  if( action ) initPPLdirs() ;

  CIls_msg( CI_I_lsDSPDIR, MSGCOLOR, 0 )	;
  Dnam[0] = DIRTX1 ; Dnam[1] = DIRTX2 ; Dnam[2] = DIRTX3 ; Dnam[3] = DIRTX4 ;
  Dfld[0] = LSFLD1 ; Dfld[1] = LSFLD2 ; Dfld[2] = LSFLD3 ; Dfld[3] = LSFLD4 ;
  CIls_gerase( MAXLSFLD, Dfld )	;
  *act_file = '\0' ; act_col = 0 ; act_row = 0 ;

  for( col = min ; col < max ; col++ ) {

	if( *( cur = ci__ls->PPLdir[ci__ls->strtdir+col] ) ) {
	   CIls_put( CIfm_cut_path( cur, DIRDPLEN, buf ), Dnam[col], 0, 0 ) ;
	   if( ( dirp = opendir( cur ) ) != NULL ) {
		row = 0 ;
		while(     ( fentry = readdir( dirp ) ) != NULL
			&& row < FI_X_LINE_LEN			) {
/* --			Only keep ".u" regular files.
   -- */
			c = strchr( fentry->d_name, '\0' ) ;
			if( *--c == 'u' && *--c == '.' ) {
				sprintf( fname, "%s/%s", cur, fentry->d_name ) ;
				stat( fname, &fstat ) ;
				if( fstat.st_mode & S_IFREG ) {
					strcpy(	list[row], fentry->d_name ) ;
					row++ ;
			   	}
			}
		}
		if( row == 0 ) {
/* --			Directory is empty ...
   -- */
#ifdef DEBUG
  printf( "CIls_dpdir: <%s> is empty", cur ) ; fflush( stdout ) ;
#endif
			ci__ls->dirsts[ci__ls->strtdir+col] = NOFILE	;
			CIls_put_gadget_color( Dfld[col], ERRCOLOR )	;
			strcpy( list[0], CIexmessage( CI_I_lsDIREMP ) )	;
			row = 1 ;
		} else {
/* --			Sort files. Remember active file and column.
   -- */
			CIls_put_gadget_color( Dfld[col], MSGCOLOR )	;
			ci__ls->dirsts[ci__ls->strtdir+col] = USABLE	;
			qsort( (char *) list, row, sizeof( Uname ), strcmp ) ;

/* --			Find new file if one has just been created.
   -- */
			if( *ci__ls->newfile ) {
				char *c = strrchr( ci__ls->newfile, '/' ) + 1 ;
				char *ptr ;
				ptr = bsearch( c		,
					       (char *) list	,
					       row		,
					       sizeof( Uname )	,
					       strcmp		) ;
				if( ptr ) {
					strcpy( act_file, c ) ;
					act_col = col ;
					act_row = (ptr - (char *) list)/sizeof(Uname) ;
#ifdef DEBUG
printf( "bsearch NEWFILE IS <%s> row %d\n", c, act_row ) ;
#endif
				}
				*ci__ls->newfile = '\0' ;
			}
			
			if( ! *act_file ) {
				strcpy( act_file, list[0] ) ;
#ifdef DEBUG
printf( "ACTIVE FILE WILL BE <%s>\n", act_file ) ;
#endif
				act_col = col ;
			}
		} /* if row ... */
		closedir( dirp ) ;
	   } else {
/* --		Directory could not be opened.
   -- */
		ci__ls->dirsts[ci__ls->strtdir+col] = NOTOPN	;
		strcpy( list[0], CIexmessage( CI_W_lsDIROPN ) )	;
		CIls_put_gadget_color( Dfld[col], ERRCOLOR )	;
		row = 1 ;
	   }
	} else {
	   CIls_put( "", Dnam[col], 0, FI_X_EDIT_NOSELECT ) ;
	   row = 0 ;
	}

/* --  Fill field.
   --  */
	CIfill_dir( Dfld[col], list, row ) ;
  } /* for */

  CIls_grestore( MAXLSFLD, Dfld ) ;

  for( col = 0 ; col < MAXLSFLD ; col++ ) CIls_select( Dfld[col], 0, OFF ) ;

#ifdef DEBUG
  printf( "CIls_dpdir act_col %d strtdir %d hltdir %d\n",
		 act_col, ci__ls->strtdir, ci__ls->hltfld.dir ) ; fflush( stdout ) ;
#endif
  col = ci__ls->hltfld.dir - ci__ls->strtdir ;

#ifdef DEBUG
  printf( "CIls_dpdir col %d\n", col ) ; fflush( stdout ) ;
#endif
  if( 0 <= col && col < MAXLSFLD ) {
/* --	Highlight active file, which is always within window.
   -- */
	if( action == FALSE ) {
		CIls_select( ci__ls->hltfld.lab, 0, OFF ) ;
		if( ci__ls->dirsts[ci__ls->strtdir+col] == USABLE ) {
			ci__ls->hltfld.lab = Dfld[col]	;
			if( act_row ) {
				FIfld_pos_cursor (ci__ls->fm, Dfld[col],
						    act_row, 0, 0, 0, 0, 0);
			}
			CIls_select( ci__ls->hltfld.lab, ci__ls->hltfld.row, ON );
		}
	} else {
	  CIls_active( act_row, act_col, Dfld[act_col], act_file ) ;
	  CIls_select( ci__ls->hltfld.lab, ci__ls->hltfld.row, ON )  ;
	}
/* --	Active file outside window: choose new one.
   -- */
  } else {
	CIls_active( act_row, act_col, Dfld[act_col], act_file ) ;
	if( ci__ls->dirsts[ci__ls->strtdir+act_col] == USABLE ) {
		CIls_select( ci__ls->hltfld.lab, 0, ON ) ;
	}
  }

  CIls_msg( CI_I_lsCMDPRM, MSGCOLOR, 0 )	;
#ifdef DEBUG
  printf( "CIls_dpdir : EXIT\n" ) ; fflush( stdout ) ;
#endif
} /* CIls_dpdir */
/*----------------------------------------------------------------------------*/
int CIls_init() {

/* -- Fills directory fields and displays form.
      RETURNS: the CiSrcLs form label.
   -- */

/* -- CIget_gadget_id must be called BEFORE CIls_dpdir.
   -- */
	CIfm_display( ci__ls->fm, 1 ) ;
	CIls_dpdir( FIRST_TIME, 0, MAXLSFLD )	;
	return CiSrcLs_label ;

} /* CIls_init */
/*----------------------------------------------------------------------------*/
static void CIls_show_editors( flag ) int flag ; {

/* -- If flag is TRUE displays editor buttons else erases them.
   -- */
	enum LSlabs	ednam[MAXEDCNT  ],
			edbtn[MAXEDCNT  ],
			label[MAXEDCNT*2]	;
	int		i, j			;

#ifdef DEBUG
   printf( "CIls_show_editors: ENTER\n" ) ; fflush( stdout ) ;
#endif
/*  -- Put buttons first!
    -- */
	edbtn[0] = EDITR1 ; edbtn[1] = EDITR2 ;
	edbtn[2] = EDITR3 ; edbtn[3] = EDITR4 ;
	ednam[0] = EDNAM1 ; ednam[1] = EDNAM2 ;
	ednam[2] = EDNAM3 ; ednam[3] = EDNAM4 ;

	for( i = j = 0 ; i < MAXEDCNT ; i++ ) {
		if( access( ci__ls->edexec[i], X_OK ) == 0 ) {
			CIls_put( ci__ls->edname[i], ednam[j], 0, 0 ) ;
			label[j*2  ] = edbtn[j]		;
			label[j*2+1] = ednam[j]		;
			CIls_on_off( label[j*2], OFF )	;
			j++ ;
		}
	}
	if( j ) {
		if( flag ) {
			CIls_grestore( 2 * j, label ) ;
			CIls_msg( CI_I_lsEDTPRM, MSGCOLOR, 0 ) ;
	   	} else	CIls_gerase( 2 * j, label ) ;
	} else CIls_msg( CI_E_lsNOEDTR, ERRCOLOR, 1 ) ;
#ifdef DEBUG
   printf( "CIls_show_editors: EXIT\n" ) ; fflush( stdout ) ;
#endif

} /* CIls_show_editors */	
/*----------------------------------------------------------------------------*/
static void CIls_me() {
/*
 2/14/92 - The function logname() is not provided on the Sun.
           This code needs to be rewritten to function on the Sun.
 */
#if !defined( SUNOS ) && !defined( SUNOS5 )
	extern char *logname() ; UNIXpath dot_me ; FILE *s_me ;

	strcat( strcat( strcpy( dot_me, "/usr/" ), logname() ), "/.me" ) ;
	if( access( dot_me, F_OK ) != 0 ) {
		if( ( s_me = fopen( dot_me, "w" ) ) != NULL ) {
			fprintf( s_me, "\
# Command Interpreter MousEMACS Set-up.\n\
origin 5 73\n\
rows 35\n\
columns 80\n\
font /usr/ip32/resrc/rfont/fix.9\n\
normaltext 60000 65535 0\n\
normalbackground 20000 20000 20000\n\
reversebackground 20000 60000 60000\n" ) ;
			fclose( s_me ) ;
		}
	}
#endif
} /* CIls_me */	
/*----------------------------------------------------------------------------*/
static void CIls_edit_file( file, edlab ) UNIXpath file ; enum LSlabs edlab ; {

/* -- Edits a file.
      INPUT : file	, file path name.
	      edlab	, label of button corresponding to the choosen editor.
   -- */
	struct FI_X_data_st	ed 		;
	int			rc, argc	;
	char			*argv[10]	,
				title[100]	;
	UNIXpath		buf		;
	enum LSlabs		ednam		;

/*  -- Get editor's name.
    -- */
  switch( edlab ) {
	case  EDITR1 : ednam =  EDNAM1 ; break ;
	case  EDITR2 : ednam =  EDNAM2 ; break ;
	case  EDITR3 : ednam =  EDNAM3 ; break ;
	case  EDITR4 : ednam =  EDNAM4 ; break ;
  }
  ed.type	= FI_X_ALPHA	;
  ed.label	= ednam		;

/* -- Highlight editor's name.
   -- */
/*  FIg_hilite (ci__ls->fm, ed.label);  */

  if( !*file ) {
	CIls_msg( CI_E_lsNOACTF, ERRCOLOR, 1 ) ;
  } else {
	rc   = ednam - EDNAM1;
	argc = 0 ;
	if( !strcmp( ci__ls->edname[rc], CI_LS_EDNAME4 ) ) {
/* -- 		Use of ksh is done so as to have MousEMACS use ".me" in the
		user's directory.
   -- */
		CIls_me() ;
		sprintf( buf, "me %s", file ) ;
		argv[argc++] = CI_LS_SHELLEX		;
		argv[argc++] = "-c"			;
		argv[argc++] = buf			;
	} else {
		strcat( strcpy( title, CIexmessage( CI_I_lsEDTITL ) ),
			CIfm_cut_path( file, 30, buf ) ) ;
		sprintf( buf, "%s %s", ci__ls->edexec[rc], file ) ; 
#if defined(CLIX)
                argv[argc++] = CI_LS_VTERMEX            ;
                argv[argc++] = "-origin"                ;
                argv[argc++] = "3"                      ;
                argv[argc++] = "335"                    ;
                argv[argc++] = "-x"                     ;
                argv[argc++] = buf                      ;
                argv[argc++] = "-T"                     ;
                argv[argc++] = title                    ;
#endif
#if ( defined(SUNOS) || defined(SUNOS5) ) | defined(IRIX)
                argv[argc++] = CI_LS_VTERMEX            ;
                argv[argc++] = "-T"                     ;
                argv[argc++] = title                    ;
                argv[argc++] = "-e"                     ;
                argv[argc++] = ci__ls->edexec[rc]	;
		argv[argc++] = file			;
#endif
	}
	CIls_msg( CI_I_lsEDTFIL, MSGCOLOR, 0 ) ;

	if( ex$is_driver_exist() ) {

/* OLD
		ex$fork(	num_entry	= argc	,
				argu		= argv	,
				wait_flag	= 1	) ;

*/
		int		edpid ;

		ex$fork(	num_entry	= argc	,
				argu		= argv	,
				childpid	= &edpid,
				wait_flag	= FALSE	) ;

		while( kill( edpid, 0 ) == 0 ) {
#ifndef X11
			DPhandle_event() ;
#endif
		}

	} else CIls_msg( CI_F_lsNODRIV, ERRCOLOR, 1 ) ;

  }

/* -- Return from editor. Switch editor button off.
   -- */
  CIls_on_off( edlab, OFF ) ;
/*  FIg_unhilite (ci__ls->fm, ed.label);  */

/* -- If a new file has been created, refresh its directory.
   -- */
  CIls_edit_off( ci__ls->editsta, FALSE ) ;
  if( ci__ls->editsta == NEWFBT ) {
		rc = ci__ls->hltfld.dir - ci__ls->strtdir ;
		CIls_dpdir( FALSE, rc, rc + 1 ) ;
  } 
  ci__ls->editsta = NULGAD ;

} /* CIls_edit_file */
/*----------------------------------------------------------------------------*/
static int CIls_edit_off( btn, check ) enum LSlabs btn ; int check ; {

/* -- Sets EDIT or NEW button off. If `check' specified, first makes sure that
      `btn' was on.
      RETURNS: TRUE if button is now off else FALSE.
   -- */
	struct FI_X_data_st edit ; char reset ;

   if( check ) {
	edit.label = btn ;
	CIfm_get (ci__ls->fm, &edit);
	reset = edit.value.ivalue != 0 ;
   } else reset = TRUE ;
   if( reset ) {
	CIls_show_editors( FALSE )	;
	CIls_on_off( btn, OFF )		;
   }
/* -- Reset new file name if file has not been created.
   -- */
   if( *ci__ls->newfile && access( ci__ls->newfile, R_OK ) != 0 )
		*ci__ls->newfile = '\0' ;
   return reset ;
}
/*----------------------------------------------------------------------------*/
static void CIls_terminal() {

/* -- Creates a VT220 terminal.
   -- */
	char	*argv[20], cmd[400], saypwd[80], endtrm[80], termtl[80] ;
	int	argc ;

#if defined CLIX || defined IRIX
#define HILITE		"/usr/bin/tput smso"
#define UNHILITE	"/usr/bin/tput rmso"
#endif
#if defined SUNOS || defined SUNOS5
#define HILITE		"/usr/5bin/tput smso"
#define UNHILITE	"/usr/5bin/tput rmso"
#endif
#define ECHO		"/bin/echo"
#define SLEEP		"sleep 1"
#define PS1		"PS1=\"CI(0\\`(B \"; export PS1"

	strcpy( saypwd, CIexmessage( CI_I_lsSAYPWD ) ) ;
	strcpy( endtrm, CIexmessage( CI_I_lsENDTRM ) ) ;
	strcpy( termtl, CIexmessage( CI_I_lsTERMTL ) ) ;
	sprintf( cmd, "%s ; %s \"%s $PWD\"; %s ; %s ; %s ; %s ; %s '%s'; %s ; %s",
		 HILITE	, ECHO	, saypwd, UNHILITE, PS1, CI_LS_SHELLEX,
		 HILITE	, ECHO	, endtrm, UNHILITE, SLEEP	) ;
	argc = 0 ;
	argv[argc++] = CI_LS_VTERMEX	;
	argv[argc++] = "-T"		;
	argv[argc++] = termtl		;
#ifdef CLIX
	argv[argc++] = "-origin"	;
	argv[argc++] = "3"		;
	argv[argc++] = "335"		;
	argv[argc++] = "-x"		;
	argv[argc++] = cmd		;
#endif
#if defined( SUNOS ) || defined( SUNOS5 )
	argv[argc++] = "-geometry"	;
	argv[argc++] = "80x24+3+335"	;
	argv[argc++] = "-e"		;
	argv[argc++] = CI_LS_SHELLEX	;
	argv[argc++] = "-c"		;
	argv[argc++] = cmd		;
#endif

	CIls_msg( CI_I_lsCRTERM, MSGCOLOR, 0 ) ;
	if( ex$is_driver_exist() ) {
		ex$fork(	num_entry	= argc	,
				argu		= argv	,
				wait_flag	= 1	) ;
	} else	CIls_msg( CI_F_lsNODRIV, ERRCOLOR, 1 ) ;

} /* CIls_terminal() */
/*----------------------------------------------------------------------------*/
static void CIls_prompt() {

/* -- Writes a prompt to the message area. According to whether one is in an
      edit/create file process or not.
   -- */

	char prompt[CI_PATH_MAX], *dir ;

#ifdef DEBUG
  printf( "CIls_prompt: editsta %d\n", ci__ls->editsta ) ;
#endif
  switch( ci__ls->editsta ) {
	case EDITBT : CIls_msg( CI_I_lsEDTPRM, MSGCOLOR, 0 ) ;
		      break ;

	case NEWFBT : dir = *ci__ls->newfile ? ci__ls->newfile
					    : ci__ls->PPLdir[ci__ls->hltfld.dir] ;
		      ex$message( msgnumb = CI_I_lsNEWPRM	,
				  buff	  = prompt		,
				  type	  = "%s"		,
				  var	  = `dir`		) ;
		      CIls_put_gadget_color( MSGTXT, MSGCOLOR )	;
		      CIls_put( prompt, MSGTXT, 0, 0 )		;
		      break ;

	case NULGAD : CIls_msg( CI_I_lsCMDPRM, MSGCOLOR, 0 ) ;
		      break ;
  }
}
/*----------------------------------------------------------------------------*/
static void CIls_input_file_name() {

/* -- Displays field for keyin.
   -- */
	enum LSlabs L ;

#ifdef DEBUG
  printf( "CIls_input_file_name: ENTER\n" ) ; fflush( stdout ) ;
#endif

/* -- Show input field.
   -- */
	L = NEWFFD ;
	CIls_grestore( 1, &L )	;
	FIfld_pos_cursor (ci__ls->fm, L, 0, 0, 0, 0, 0, 0);

	ci__ls->editsta = NEWFBT	;
	CIls_prompt() ;
#ifdef DEBUG
  printf( "CIls_input_file_name: EXIT\n" ) ; fflush( stdout ) ;
#endif

} /* CIls_input_file_name */
/*----------------------------------------------------------------------------*/
static void CIls_create_file( name ) Uname name ; {

/* -- A `name' has been keyed in the "new file" field. Erases field and shows
      editor buttons.
   -- */

	enum LSlabs L ; char *file ;

#ifdef DEBUG
  printf( "CIls_create_file: ENTER\n" ) ; fflush( stdout ) ;
#endif
  file = *ci__ls->newfile ? ci__ls->newfile : ci__ls->PPLdir[ci__ls->hltfld.dir] ;
  sprintf( ci__ls->newfile, "%s/%s", file, name ) ;
  L = NEWFFD 			;
  CIls_gerase( 1, &L ) 		;
  CIls_put( "", L, 0, 0 )	;
  CIls_show_editors( TRUE )	;
  ci__ls->editsta = NEWFBT	;
	
#ifdef DEBUG
  printf( "CIls_create_file: EXIT\n" ) ; fflush( stdout ) ;
#endif
}
/*----------------------------------------------------------------------------*/
static void CIls_active( row, col, lab, file )	int		row, col;
						enum LSlabs	lab	;
				 		Uname		file	; {

/* -- Sets new active file if any, unhighlight previous one if need be.
      INPUT  : col, row, colon[0-3] and row[0-131] of active file.
               lab, gadget label of colon.
	       file, new active file name (without path).
   -- */

#ifdef DEBUG
  printf( "CIls_active: lab %d, col %d, row %d dir %d\n",
	  lab, col, row, ci__ls->strtdir + col ) ;
#endif
	switch( ci__ls->dirsts[ci__ls->strtdir+col] ) {
		case USABLE :
#ifdef DEBUG
  printf( "CIls_active: USABLE\n" ) ;
#endif
			if( ci__ls->hltfld.lab != lab )
				CIls_select(	ci__ls->hltfld.lab,
						ci__ls->hltfld.row,
						OFF ) ;

			ci__ls->hltfld.lab = lab 			;
			ci__ls->hltfld.row = row 			;
			ci__ls->hltfld.dir = ci__ls->strtdir + col 	;
			sprintf( ci__ls->active, "%s/%s",
			 	 ci__ls->PPLdir[ci__ls->strtdir+col], file ) ;
			break ;
		case NOFILE : 
#ifdef DEBUG
  printf( "CIls_active: NOFILE editsta %d\n", ci__ls->editsta ) ;
#endif
			if( ci__ls->editsta == NEWFBT ) { /* TEST CM removed */
				strcpy( ci__ls->newfile,
					ci__ls->PPLdir[ci__ls->strtdir+col] ) ;
				break ;
			}  /* else next case ... */
		case NOTOPN :
#ifdef DEBUG
  printf( "CIls_active: NOTOPN turning lab %d off\n", lab ) ;
#endif
			CIls_msg( CI_W_lsNOFILE, ERRCOLOR, 1 ) 	;
			CIls_select( lab, 0, OFF ) 		;
			CIls_select( ci__ls->hltfld.lab, 0, ON )	;
			
	}
} /* CIls_active */
/*----------------------------------------------------------------------------*/
static int CIls_valid_input( in ) register char *in ; {

/* -- Checks that `in' is not empty or full of spaces.
   -- */
	int valid = strlen( in ) > 0 ;

	if( valid ) {
		valid = FALSE ;
		while( *in ) {
			if( !isspace( *in ) ) {
				valid = TRUE	;
				break		;
			}
			in++ ;
		}
	}
	return valid ;
}
/*----------------------------------------------------------------------------*/
void CIls_delete( check, askerid )	int	check	;
					Form	askerid ; {

/* -- Deletes self. If requested, check id of form which requested it and
      only obey if it was the super form.
   -- */
	if( ci__ls != NULL ) {
#ifdef DEBUG
  printf( "CIls_delete: askerid %u super %u\n",	askerid, ci__ls->super ) ;
#endif
		if( !check || askerid == ci__ls->super ) {
			CIfm_erase ( ci__ls->fm, 0, 0 ) ;
			CIfm_delete( ci__ls->fm ) ;
			free( (char *) ci__ls )	;
			ci__ls = NULL		;
			CIsu_ls_deleted()	;
		}
	}
} /* CIls_delete */
/*----------------------------------------------------------------------------*/
int CIls_input( p_in, co ) struct FI_X_data_st *p_in ; struct GRid *co ; {

/* -- Equivalent of "form_input" method. Called by super form `CiSetup'.
   -- */

	long			retc, size;
	int 			resp;
	int			i, n ;
	char			cmd[56+CI_NAME_MAX+2] ;
	struct EX_cmd		cmdinfo ;
	struct FI_X_data_st	in ;

	in = *p_in ;

	CIls_msg( 0, MSGCOLOR, 0 ) ;
#ifdef DEBUG
  printf( "CIls_input: label %d\n", in.label )  ;
#endif
	switch( in.label ) {
	case QUITBT : CIls_delete( 0, (Form)NULL_OBJID ) ;
		      break ;

	case HELPBT : CIfm_help( co, CiSrcLs_help )	;
		      CIls_on_off( HELPBT, OFF )	;
		      goto CMDPROMPT ;
/* --	Directory fields.
   -- */
	case LSFLD1 : CIls_active( in.index, 0, LSFLD1, in.value.alpha ) ;
		      goto CMDPROMPT ;
	case LSFLD2 : CIls_active( in.index, 1, LSFLD2, in.value.alpha ) ;
		      goto CMDPROMPT ;
	case LSFLD3 : CIls_active( in.index, 2, LSFLD3, in.value.alpha ) ;
		      goto CMDPROMPT ;
	case LSFLD4 : CIls_active( in.index, 3, LSFLD4, in.value.alpha ) ;
		      goto CMDPROMPT ;

/* --	Execute-File button. Put active file on input queue so COci can catch it
   -- */
	case EXECBT : if( ci__ls->editsta == NEWFBT ) {
/*					CIls_put( "", ci__ls->editsta, 0, 0 ) ;*/
					in.label = NEWFFD		;
					CIls_gerase( 1, 
                                                    (enum LSlabs *)&in.label );
					ci__ls->editsta = NULGAD	;
		      }
		      CIls_edit_off( ci__ls->editsta, TRUE )	;
		      CIls_msg( CI_I_lsRUNFIL, MSGCOLOR, 0 )	;
		      ex$get_cmd_info(	string		= "CIAcPPCm"	,
					mode		= EX_CMD_KEY	,
					cmdstr		= &cmdinfo	) ;

		      sprintf( cmd, "%s=%s", cmdinfo.command_name_ptr,
					     ci__ls->active ) ;
		      resp = CMD_STRING		;
		      size = strlen( cmd ) + 1	;
#ifdef DEBUG
  printf( "EXECBT: cmd = <%s>\n", cmd ) ;
#endif
		      ex$putque(	msg	= &retc	,
		      			response= &resp	,
					byte	= &size	,
					buffer	= cmd	) ;
		      CIls_on_off( EXECBT, OFF ) ;
		      break ;

/* --	Edit button.
   -- */
	case EDITBT : 
#ifdef DEBUG
  printf( "EDITBT: in.value.state <%d>\n", in.value.state ) ;
#endif
		      if( in.value.state == 0 ) {
			CIls_edit_off( EDITBT, FALSE ) ;
		      } else {
				if( ci__ls->editsta == NEWFBT ) {
/*					CIls_put( "", ci__ls->editsta, 0, 0 ) ;*/
					in.label = NEWFFD		;
					CIls_gerase( 1, 
                                                    (enum LSlabs *)&in.label );
					CIls_edit_off( NEWFBT, TRUE ) 	;
					CIls_on_off( NEWFBT, OFF )	;
				}
				CIls_show_editors( TRUE ) 	;
				ci__ls->editsta = EDITBT	;
		      }
		      break ;
/* --   Input-Filename field.
   -- */
	case NEWFFD : if( CIls_valid_input( in.value.alpha ) ) {
				CIls_create_file( in.value.alpha ) ;
				break ;
		      } else goto NEWOFF ;
/* --  Create-New-File button.
   -- */
	case NEWFBT : 
#ifdef DEBUG
  printf( "NEWFBT: in.value.state <%d>\n", in.value.state ) ;
#endif
		      if( ci__ls->editsta == EDITBT ) {
				CIls_edit_off( EDITBT, FALSE )    ;
		      }
		      if( in.value.state == 0 ) {
				NEWOFF :
/*				CIls_put( "", ci__ls->editsta, 0, 0 )	;*/
				in.label = NEWFFD		;
				CIls_gerase( 1, 
                                            (enum LSlabs *)&in.label );
				CIls_edit_off( NEWFBT, TRUE )	;
				ci__ls->editsta = NULGAD		;
		      } else CIls_input_file_name()		; break ;
		      
/* --	Editor buttons.
   -- */
	case EDITR1 :
	case EDITR2 :
	case EDITR3 :
	case EDITR4 : switch( ci__ls->editsta ) {
			case NEWFBT : CIls_edit_file(	ci__ls->newfile,
						(enum LSlabs)in.label ) ;
				      break ;
			case EDITBT : CIls_edit_file(	ci__ls->active,
						(enum LSlabs)in.label ) ;
				      break ;
		      }
		      goto CMDPROMPT ;

/* --   Create-VT220 button.
   -- */
	case TERMBT : CIls_terminal() ; CIls_on_off( TERMBT, OFF ) ;
		      goto CMDPROMPT ;

	case BORDER : CIls_on_off( BORDER, OFF )	;
		      goto CMDPROMPT ;

/* --   Review-Directories slider.
   -- */
	case SLIDER : for( i = n = 0 ; i < MAXINCDIRS ; i++ )
				n += ci__ls->dirsts[i] != NOTUSD ;
		      if( in.value.ivalue > n ) in.value.ivalue = n ;
		      CIfm_put( ci__ls->fm, &in ) ;
		      if( ci__ls->strtdir != in.value.ivalue - 1 ) {
				ci__ls->strtdir = in.value.ivalue - 1	;
		      		CIls_dpdir( FALSE, 0, MAXLSFLD )	;
		      		CMDPROMPT : CIls_prompt() ;
		      }
		      break ;
	default	    : fprintf( stderr, "CIls: Unknown gadget %d\n", in.label );
	}

	return OM_S_SUCCESS ;

} /* CIls_input */
/*----------------------------------------------------------------------------*/
int CIls_is_form_on() { return ci__ls != NULL ; }
/*----------------------------------------------------------------------------*/

end implementation COcisetup ;
