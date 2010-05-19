/* $Id: VDrevintfi.I,v 1.2 2001/01/12 19:11:13 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VDrevintfi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrevintfi.I,v $
 *	Revision 1.2  2001/01/12 19:11:13  hans
 *	SP16 import to CVS
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *
# Revision 1.2  2000/06/22  22:26:04  pinnacle
# Replaced: vds/vdintf/cmd/VDrevintfi.I for:  by jwfrosch for Service Pack
#
# Revision 1.1  2000/06/19  18:23:40  pinnacle
# Created: vds/vdintf/cmd/VDrevintfi.I by jwfrosch for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/16/97	HF		Command to Review <Assoc> VDS Interferences
 *	10/30/97	ah		Warnings
 *
 *	12/22/97	HF		Changed from using instance variable "STATE" of ci_macro
 *					(this was causing problems for "nested" macros) for
 *					storing interference_flags, to using the instance variable
 *					"internal_buffer" (==>>union state intf_flags) instead.
 *
 *					The ci_macro method give_internal_ptr will return a pointer
 *					to this instance variable.
 *					Since we manipulate a pointer into the instance data of the
 *					ci_macro, it is IMPORTANT to be VERY carefull in order to not
 *					corrupt the ci_macro !!!
 *					Because of this change it is not necessary anymore to play
 *					tricks with "byt_0".
 *
 * -------------------------------------------------------------------*/

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

class implementation VDrevintf;

#include	<EMS.h>
#include	<RAPdefs.h>

# ifndef DEBUG
# define DEBUG 0
# endif

/* mytypes */
#define Intf		0

#include	<stdio.h>
#include	<codef.h>
#include	<ECdlb.h>
#include	<igr.h>
#include	<igrtypedef.h>
#include	<griodef.h>
#include	<exdef.h>
#include	<EMSmsgdef.h>
#include	<dpmacros.h>
#include	<exmacros.h>
#include	<OMmacros.h>
#include	<OMprimitives.h>
#include	<griomacros.h>
#include	<grdpbmacros.h>
#include	<lcmacros.h>
#include	<emsdattyp.h>
#include	<emsinter.h>
#include	<EMSbnddef.h>
#include	<EMSbnd.h>
#include	<EMSopt.h>
#include	<EMSlmdef.h>
#include	<grgsdef.h>		/* Needed for the macros */
#include	<grgsmacros.h>		/* gr$gsput_locate_criteria() */

#include	<grmacros.h>		/* */
#include	<EC_M.h>		/* Command strings */
#include	<EC_I.h>		/* Status strings */
#include	<EC_P.h>		/* Prompt strings */
#include	<EC_F.h>		/* Error box strings */
#include	<EC_E.h>		/* Error strings */

#include	<emsdef.h>
#include	<emserr.h>
#include	<EMSmsgdef.h>
#include	<EMSintf.h>
#include	<bserr.h>
#include	<bsparameters.h>
#include	<madetplan.h>
#include	<bsdistnct2.h>

#include	<DItypedef.h>
#include	<DIdef.h>
#include	<DIglob.h>
#include	<DIprims.h>

#include 	<ACattrib.h>
#include	<ACrg_collect.h>

#include	<acrepdef.h>		/* #define AC_2D_REP etc. */
#include	<VDintf_rev.h>		/* struct for storing VDS repr to be used with reffiles	*/
#include	<nddef.h>
#include	<ndmacros.h>
#include	<VDmsg.h>
#include	<v_miscmacros.h>
#include	<vdsmacros.h>

#include "AS_status.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/* AND, ISNT ... */
# ifndef EMSlogic_include
# include	<EMSlogic.h>
# endif

#include	<FI.h>

#define	UNSIGNED_CHAR_0		((unsigned char) ~0)

#define	MAX_TEMP	 2

/* Gadgets info for Status Form */

#define LINES_GROUP	12
#define REPORT_GROUP	29
#define FIT_OBJ		13
#define RATIO		14
#define REPORT_BTN	16
#define REPORT_FIELD	19
#define REPORT_TXT	20
#define CVRT_ASSOC	22
#define SEL_VWT_FIT	28
#define SELECT_OBJ	30
#define MCF_1		31
#define MCF_2		32
#define STAT_LST	42
#define MINMAX_TGL	39
#define APPEND_TGL	40

# define	USER_SIZE		(80)
# define	MAX_INTF_STAT_CODE	125

/* Externs */

extern		GRstatus_display_button();

extern int	FIg_get_text_length(),
		FIg_get_text(),
		FIfld_get_select(),
		FIfld_set_select(),
		FIfld_get_text(),
		FIfld_set_text(),
		FIf_display(),
		FIf_reset(),
		FIg_enable(),
		FIg_disable(),
		FIg_display(),
		FIg_erase(),
		FIfld_get_active_row(),
		FImcf_get_active_col();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	Static variables to save the status_form settings between invocations	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int		VDintf_x_memo, VDintf_y_memo;
static int		overwr_append, minmax_flag;
static IGRint		fit_chk;
static IGRint		convert_assoc_opt_1;
static IGRdouble	fit_rtio;
static struct GRid	fit_win;
static char		report_filename[USER_SIZE];

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int		num_codes;
static int		always_make_macro, avoid_false_interf, REV_avoid_false_interf;

static struct VDintf_stat
{
  int	code;
  char  desc[USER_SIZE];
};

static struct VDintf_stat	intf_stat[MAX_INTF_STAT_CODE];

#define ASSOC_OPTION_1   01
#define ASSOC_OPTION_2   02
#define AVOID_FALSE_INTF 04

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

from	GRgraphics	import	GRdisplay;

from	ACncpx		import	ACget_STATE, ACchg_STATE;
from	ACcpx_defn	import	ACgive_name;
from	ACcpx		import	find_macro, ACfind_exp_temp_obj;

from	NDmacro		import	ACreturn_foot;
from	NDnode		import	NDget_objects;
from	ci_macro	import	give_internal_ptr;

extern OMuword	OPP_EMSsurface_class_id,
		OPP_ACpl_hold_class_id,
		OPP_nci_macro_class_id;

extern int	VDpms_find_objects();

extern	void	VDintf_rep_info_2 ( unsigned char , OMuword, char * );

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable toggling the value of avoid_false_interf from within a PPL.
// Execute PPL: ci=false_intf
int toggle_false_interf_review()
{
  if (REV_avoid_false_interf)
  {
    REV_avoid_false_interf = 0;
  }
  else
  {
    REV_avoid_false_interf = 1;
  }
  return REV_avoid_false_interf;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDread_intf_status( FILE *fptr, int *num_codes )
{
  char str [USER_SIZE];
  char desc[USER_SIZE];
  int  i0 = 1, j0, code;

  intf_stat[0].code = 0;
  strcpy ( intf_stat[0].desc, "NoChange" );

  while ( fgets (str, USER_SIZE, fptr) && i0 <= MAX_INTF_STAT_CODE )
  {
    if ( str[0] == '#' ) continue;
    memset ( desc, 0, USER_SIZE ) ;

    j0 = sscanf ( str, "%d %[^\n]", &code, desc );
    if ( j0 > 1 && code > 0 && code <= MAX_INTF_STAT_CODE )
    {
      intf_stat[i0].code = code;
      strcpy ( intf_stat[i0].desc, desc );
      i0++;
    }
  }
  *num_codes = i0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDretrieve_intf_status( int *num_codes )
{
  char  file_name[257];
  char  tmpfile  [257];
  char *slash;
  int   path_found;
  int   j;
  int   status;
  FILE *fptr;

  __enterFunction ( name = "VDretrieve_intf_status" );

  *num_codes = 0;

  fptr = fopen ( "Interf.status", "r" );

  if ( fptr )
  {
    goto read_intf_fil;
  }

  status = ex$get_path ( index = 0, path = file_name, len = sizeof(file_name) );
  strcat (file_name, "config/" );

  slash = (char *)strrchr (file_name, '/' );
  *slash = '\0';
  strcat (file_name, "/Interf.status" );

  fptr = fopen ( file_name, "r" );
  if ( fptr )
  {
    goto read_intf_fil;
  }
  __printf ( "file_name  = <%s>", file_name );

  path_found = TRUE;
  for (j=1; path_found; j++)
  {
    path_found = ex$get_path ( index = j,
			       path  = tmpfile,
			       len   = sizeof(tmpfile) );
    if (path_found)
    {
      strcat (tmpfile, "config/Interf.status" );

      __printf ( "tmpfile[%d] = <%s>", `j, tmpfile` );

      fptr = fopen ( tmpfile, "r" );
      if ( fptr )
      {
	goto read_intf_fil;
      }
    }
  }

read_intf_fil:

  if ( fptr )
  {
    VDread_intf_status( fptr, num_codes );
    fclose ( fptr );
    status = 1;
  }
  else
  {
    status = 0;
  }

  __exitFunction ( name = "VDretrieve_intf_status" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_print_info_max
(
  IGRint		 num_located,
  IGRint		 num_empty,
  struct VDintf_info	*intf_info,
  FILE			*ptr,
  char			*start_time
)
{
  IGRlong	msg;
  int		i0, j0, k0, sts;
  static char	txt[USER_SIZE * 2];
  char		osname[OM_K_MAXOSNAME_LEN];
  struct GRmd_env mod_env;
  GRrange         rng;
  int		BytesReceived = 0, NumberOfBytes;

  NumberOfBytes = sizeof(mod_env);
  gr$get_module_env (	msg	= &msg,
			sizbuf	= &NumberOfBytes,
			buffer	= &mod_env,
			nret	= &BytesReceived );

  sts = om$os_number_to_name ( osnum	= intf_info[0].intf.osnum,
			       osname	= osname);

  if ( start_time && start_time[0] != 0 )
  {
    fprintf ((FILE *)ptr, "\n");
    fprintf ((FILE *)ptr, "  INTERFERENCE ANALYSIS REPORT           Finished: %s",  EMgettime());
    fprintf ((FILE *)ptr, "                                         Started : %s\n",start_time);
  }
  else
  {
    fprintf ((FILE *) ptr, "\nINTERFERENCE ANALYSIS REPORT\t\t\tDate: %s\n",EMgettime());
  }

  fprintf ((FILE *) ptr, "SUMMARY:\n");
  fprintf ((FILE *) ptr, "Number of     Interfering Elements = %d\n", num_located );
  fprintf ((FILE *) ptr, "Number of Non-Interfering Elements = %d\n", num_empty );
  fprintf ((FILE *) ptr, "Interference Filename   : %s\n", osname );

  for ( i0=0, j0=1, k0=1 ; i0 < num_located; i0++ )
  {
    unsigned char byt_0 = intf_info[i0].STATE.byt_stat[0];
    int		  m0, code_found = 0;

    if ( i0 && intf_info[i0].tmp1.obj_id.osnum == intf_info[i0-1].tmp1.obj_id.osnum
	    && intf_info[i0].tmp1.obj_id.objid == intf_info[i0-1].tmp1.obj_id.objid ) goto next;

    k0 = 1;

    sprintf ( txt,"[%d,%d]", intf_info[i0].tmp1.obj_id.osnum, intf_info[i0].tmp1.obj_id.objid );

    fprintf ((FILE *) ptr, "\n%3d) Element-ID : %s\n", j0, txt ); j0++;

    if ( strlen (intf_info[i0].name1) > 0 )
    {
      sprintf ( txt,"%s - %s", intf_info[i0].name1, intf_info[i0].objinf1 );
    }
    else
    {
      sprintf ( txt,"%s", intf_info[i0].objinf1 );
    }
    fprintf ((FILE *) ptr, "     Identifier : %s", txt );

    sprintf ( txt," - layer %d", intf_info[i0].symb1.level );
    fprintf ((FILE *) ptr, "%s", txt );

    VDintf_rep_info_2 ( intf_info[i0].STATE.byt_stat[1],
			intf_info[i0].tmp1.obj_id.osnum, txt );
    fprintf ((FILE *) ptr, " - Repr: %s\n", txt );

    sts = om$os_number_to_name ( osnum	= intf_info[i0].tmp1.obj_id.osnum,
				 osname	= osname);

    fprintf ((FILE *) ptr, "     Filename   : %s\n", osname );

next:

    if ( k0 == 1 ) fprintf ((FILE *) ptr, "\tInterferes with :\n " );

    sprintf ( txt,"[%d,%d]\tApproval Status = ", intf_info[i0].tmp2.obj_id.osnum, intf_info[i0].tmp2.obj_id.objid );

    for ( m0=1 ; m0 < num_codes; m0++ )
    {
      if ( intf_info[i0].STATE.byt_stat[3] == intf_stat[m0].code )
      {
	code_found = 1;
	break;
      }
    }
    if ( code_found )
    {
      strncat ( txt, intf_stat[m0].desc, 20 );
    }
    else
    {
      sprintf ( txt, "%s%d", txt, intf_info[i0].STATE.byt_stat[3] );
    }

    fprintf ((FILE *) ptr, "\t%3d) Element-ID : %s\n", k0, txt ); k0++;

    always_make_macro  = byt_0 & (ASSOC_OPTION_1 | ASSOC_OPTION_2);
    avoid_false_interf = byt_0 & AVOID_FALSE_INTF;

    sprintf ( txt,"[%d,%d]\tAssoc Option    = %d, Suppress False Intf = %d",
	      intf_info[i0].intf.osnum, intf_info[i0].intf.objid, always_make_macro, avoid_false_interf );
    fprintf ((FILE *) ptr, "\t     Macro_ID   : %s\n", txt );

    if ( strlen (intf_info[i0].name2) > 0 )
    {
      sprintf ( txt,"%s - %s", intf_info[i0].name2, intf_info[i0].objinf2 );
    }
    else
    {
      sprintf ( txt,"%s", intf_info[i0].objinf2 );
    }
    fprintf ((FILE *) ptr, "\t     Identifier : %s", txt );

    sprintf ( txt," - layer %d", intf_info[i0].symb2.level );
    fprintf ((FILE *) ptr, "%s", txt );

    VDintf_rep_info_2 ( intf_info[i0].STATE.byt_stat[2],
			intf_info[i0].tmp2.obj_id.osnum, txt );
    fprintf ((FILE *) ptr, " - Repr: %s\n", txt );

    sts = om$os_number_to_name (	osnum	= intf_info[i0].tmp2.obj_id.osnum,
					osname	= osname);

    fprintf ((FILE *) ptr, "\t     Filename   : %s\n", osname );


    if ( (EMintf_getrange (&intf_info[i0].intf, &mod_env, rng) ) == EMS_E_Fail)
    {
      fprintf((FILE *)ptr, "\t     range      : unknown\n");
    }
    else
    {
      fprintf((FILE *)ptr, "\t     range (min): %g %g %g\n", rng[0], rng[1], rng[2]);
      fprintf((FILE *)ptr, "\t     range (max): %g %g %g\n", rng[3], rng[4], rng[5]);
      fprintf((FILE *)ptr, "\t     mid_point  : %g %g %g\n", (rng[0] + rng[3])/2, (rng[1] + rng[4])/2, (rng[2] + rng[5])/2);
    }

  }
  fprintf ((FILE *) ptr, "\n" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_print_info_min
(
  IGRint		 num_located,
  IGRint		 num_empty,
  struct VDintf_info	*intf_info,
  FILE			*ptr,
  char			*start_time
)
{
  int		i0, j0, k0, sts;
  static char	txt [USER_SIZE * 2];
  static char	txt2[USER_SIZE * 2];
  static char  *blanks = { "                                                                                " };

  char		osname[OM_K_MAXOSNAME_LEN];

  sts = om$os_number_to_name ( osnum	= intf_info[0].intf.osnum,
			       osname	= osname);

  if ( start_time && start_time[0] != 0 )
  {
    fprintf ((FILE *)ptr, "\n");
    fprintf ((FILE *)ptr, "  INTERFERENCE ANALYSIS REPORT           Finished: %s",  EMgettime());
    fprintf ((FILE *)ptr, "                                         Started : %s\n",start_time);
  }
  else
  {
    fprintf ((FILE *) ptr, "\nINTERFERENCE ANALYSIS REPORT\t\t\tDate: %s\n",EMgettime());
  }

  fprintf ((FILE *) ptr, "SUMMARY:\n");
  fprintf ((FILE *) ptr, "Number of     Interfering Elements = %d\n", num_located );
  fprintf ((FILE *) ptr, "Number of Non-Interfering Elements = %d\n", num_empty );
  fprintf ((FILE *) ptr, "Interference Filename   : %s\n", osname );

  for ( i0=0, j0=1, k0=1 ; i0 < num_located; i0++ )
  {
    unsigned char byt_0 = intf_info[i0].STATE.byt_stat[0];
    int		  txt_lng = 0;
    int		  m0, code_found = 0;

    if ( i0 && intf_info[i0].tmp1.obj_id.osnum == intf_info[i0-1].tmp1.obj_id.osnum
	    && intf_info[i0].tmp1.obj_id.objid == intf_info[i0-1].tmp1.obj_id.objid ) goto next;

    k0 = 1;
    fprintf ((FILE *) ptr, "\n" );

    if ( strlen (intf_info[i0].name1) > 0 )
    {
      sprintf ( txt2,"%s - %s", intf_info[i0].name1, intf_info[i0].objinf1 );
    }
    else
    {
      sprintf ( txt2,"%s", intf_info[i0].objinf1 );
    }
    sprintf ( txt, "%3d) Identifier : %s", j0, txt2 ); j0++;
    fprintf ((FILE *) ptr, "%s", txt );

    sprintf ( txt," - layer %d", intf_info[i0].symb1.level );
    fprintf ((FILE *) ptr, "%s", txt );

    VDintf_rep_info_2 ( intf_info[i0].STATE.byt_stat[1], intf_info[i0].tmp1.obj_id.osnum, txt2 );

    sprintf ( txt, " - Repr: %s\n", txt2);
    fprintf ((FILE *) ptr, "%s", txt );

    sts = om$os_number_to_name ( osnum	= intf_info[i0].tmp1.obj_id.osnum, osname = osname);

    fprintf ((FILE *) ptr, "     Filename   : %s\n", osname );

next:
    txt_lng = 0;

    if ( k0 == 1 ) fprintf ((FILE *) ptr, "\tInterferes with :\n " );

    if ( strlen (intf_info[i0].name2) > 0 )
    {
      sprintf ( txt2,"%s - %s", intf_info[i0].name2, intf_info[i0].objinf2 );
    }
    else
    {
      sprintf ( txt2,"%s", intf_info[i0].objinf2 );
    }
    sprintf ( txt, "\t%3d) Identifier : %s", k0, txt2 ); k0++;
    fprintf ((FILE *) ptr, "%s", txt );
    txt_lng += strlen ( txt );

    sprintf ( txt," - layer %d", intf_info[i0].symb2.level );
    fprintf ((FILE *) ptr, "%s", txt );
    txt_lng += strlen ( txt );

    VDintf_rep_info_2 ( intf_info[i0].STATE.byt_stat[2], intf_info[i0].tmp2.obj_id.osnum, txt2 );

    sprintf ( txt, " - Repr: %s", txt2 );
    fprintf ((FILE *) ptr, "%s", txt );
    txt_lng += strlen ( txt );

    if ( 0 )		// Set to ( 1 ) if Assoc Option is required
    {
      memset ( txt, 0, sizeof (txt) );

      always_make_macro  = byt_0 & (ASSOC_OPTION_1 | ASSOC_OPTION_2);
      avoid_false_interf = byt_0 & AVOID_FALSE_INTF;

      sprintf ( txt,"\tAssoc Option = %d, Suppress False Intf = %d", always_make_macro, avoid_false_interf );
      fprintf ((FILE *) ptr, "%s", txt );
      txt_lng += strlen ( txt );
    }

    memset ( txt, 0, sizeof (txt) );

    if ( USER_SIZE - txt_lng -8 > 0 )
    {
      strncpy ( txt, blanks, USER_SIZE - txt_lng -8 );
    }
    else
    {
      strcpy ( txt, "\t" );
    }
    sprintf ( txt,"%sStatus = ", txt );

    for ( m0=1 ; m0 < num_codes; m0++ )
    {
      if ( intf_info[i0].STATE.byt_stat[3] == intf_stat[m0].code )
      {
	code_found = 1;
	break;
      }
    }
    if ( code_found )
    {
      strncat ( txt, intf_stat[m0].desc, 20 );
    }
    else
    {
      sprintf ( txt, "%s%d", txt, intf_info[i0].STATE.byt_stat[3] );
    }

    fprintf ((FILE *) ptr, "%s\n", txt );

    sts = om$os_number_to_name ( osnum	= intf_info[i0].tmp2.obj_id.osnum, osname = osname);

    fprintf ((FILE *) ptr, "\t     Filename   : %s\n", osname );
  }
  fprintf ((FILE *) ptr, "\n" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_print_info
(
  IGRint		 num_located,
  IGRint		 num_empty,
  struct VDintf_info	*intf_info,
  FILE			*ptr,
  int			 minmax_flag,
  char			*start_time
)
{
  if ( minmax_flag == 0 )
  {
    VDintf_print_info_max ( num_located, num_empty, intf_info, ptr, start_time );
  }
  else
  {
    VDintf_print_info_min ( num_located, num_empty, intf_info, ptr, start_time );
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int VDintf_update_MCF_2
(
  int			 act_row,
  struct VDintf_info	*intf_info,
  char			*form_ptr
)
{
  static char	txt[USER_SIZE];
  char		osname[OM_K_MAXOSNAME_LEN];

  int		sts;

  if ( strlen (intf_info[act_row].name1) > 0 )
  {
    sprintf ( txt,"%s - %s", intf_info[act_row].name1, intf_info[act_row].objinf1 );
  }
  else
  {
    sprintf ( txt,"%s", intf_info[act_row].objinf1 );
  }
  FIfld_set_text ( form_ptr, MCF_2, 0, 0, txt, FALSE );

  sprintf ( txt,"%2d%6d", intf_info[act_row].tmp1.obj_id.osnum, intf_info[act_row].tmp1.obj_id.objid );
  FIfld_set_text ( form_ptr, MCF_2, 0, 1, txt, FALSE );

  if ( strlen (intf_info[act_row].name2) > 0 )
  {
    sprintf ( txt,"%s - %s", intf_info[act_row].name2, intf_info[act_row].objinf2 );
  }
  else
  {
    sprintf ( txt,"%s", intf_info[act_row].objinf2 );
  }
  FIfld_set_text ( form_ptr, MCF_2, 1, 0, txt, FALSE );

  sprintf ( txt,"%2d%6d", intf_info[act_row].tmp2.obj_id.osnum, intf_info[act_row].tmp2.obj_id.objid );
  FIfld_set_text ( form_ptr, MCF_2, 1, 1, txt, FALSE );

  sprintf ( txt,"%d", intf_info[act_row].symb1.level );
  FIfld_set_text ( form_ptr, MCF_2, 0, 2, txt, FALSE );

  sprintf ( txt,"%d", intf_info[act_row].symb2.level );
  FIfld_set_text ( form_ptr, MCF_2, 1, 2, txt, FALSE );

  VDintf_rep_info_2 ( intf_info[act_row].STATE.byt_stat[1],
		      intf_info[act_row].tmp1.obj_id.osnum, txt );

//  sprintf ( txt,"%d", intf_info[act_row].STATE.byt_stat[1] );
  FIfld_set_text ( form_ptr, MCF_2, 0, 3, txt, FALSE );

  VDintf_rep_info_2 ( intf_info[act_row].STATE.byt_stat[2],
		      intf_info[act_row].tmp2.obj_id.osnum, txt );

//  sprintf ( txt,"%d", intf_info[act_row].STATE.byt_stat[2] );
  FIfld_set_text ( form_ptr, MCF_2, 1, 3, txt, FALSE );

  sprintf ( txt, "Object %d", act_row+1 );
  FIg_set_text ( form_ptr, FI_MSG_FIELD, txt );

  sts = om$os_number_to_name (	osnum	= intf_info[act_row].tmp1.obj_id.osnum,
				osname	= osname);

  FIfld_set_text ( form_ptr, MCF_2, 0, 4, osname, FALSE );

  sts = om$os_number_to_name (	osnum	= intf_info[act_row].tmp2.obj_id.osnum,
				osname	= osname);

  FIfld_set_text ( form_ptr, MCF_2, 1, 4, osname, FALSE );

  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int compare_intf_macro_template_id
(
  struct VDintf_info	*istr,
  struct VDintf_info	*ostr
)
{
  int sts = 0;
  struct GRid in_id = istr->tmp1.obj_id;
  struct GRid of_id = ostr->tmp1.obj_id;

  if ( in_id.osnum == of_id.osnum && in_id.objid == of_id.objid )
  {
    sts = 0;
  }
  else if ( in_id.osnum == of_id.osnum )
  {
    if ( in_id.objid < of_id.objid )
    {
      sts = -1;
    }
    else if ( in_id.objid > of_id.objid )
    {
      sts = 1;
    }
  }
  else if ( in_id.osnum < of_id.osnum )
  {
    sts = -1;
  }
  else if ( in_id.osnum > of_id.osnum )
  {
    sts = 1;
  }

  if ( 0 )
  {
    printf ( "sts = %d, istr[] = [%d,%d], ostr[] = [%d,%d]\n", sts,
	     istr->tmp1.obj_id.osnum, istr->tmp1.obj_id.objid,
	     ostr->tmp1.obj_id.osnum, ostr->tmp1.obj_id.objid );
  }

  return ( sts );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDrevintf_check_located_obj
(
  int			 *number_of_objects,
  int			 *number_of_empties,
  OM_S_OBJID		**objcts
)
{
  /*
   * - Check for nci_macro objects with name "VDinterf_cvs" and remove ALL other objects !!!
   */

  IGRint		i0, sts, status;
  OMuint		cnt = 0;
  OMuword		clid;
  int			j0 = 0;
  OM_S_OBJID		*objects = NULL;
  OM_S_CHANSELECT	my_chansel;
  OM_S_OBJECT_LINKAGE	lobj;

  __enterFunction ( name = "VDrevintf_check_located_obj" );
  __printf ( ">>>>> *number_of_objects = %d", `*number_of_objects` );

  *number_of_empties = 0;

  /*
   * Copy the pointer to array of "objts" to "objects"
   */
  objects = _MALLOC ( *number_of_objects, OM_S_OBJID );
  if ( ! objects )
  {
    goto quit;
  }
  else
  {
    memcpy ( objects, *objcts, *number_of_objects * sizeof ( OM_S_OBJID ) );
  }

  /*
   * Remove ALL objects which are not nci_macro's with name "VDinterf_cvs" from the set !!!
   */

  j0 = *number_of_objects;
  i0 = 0;

  while ( i0 < j0 )
  {
    char		*c = NULL;
    struct GRid		macro;

    om$get_classid ( objid	= objects[i0],
		     osnum	= (OMuword)2,
		     p_classid	= &clid);

    if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_nci_macro_class_id) == OM_S_SUCCESS)
    {
      status =
	om$send (	msg	 = message ACcpx.find_macro ( &macro ),
			targetid = objects[i0],
			targetos = (OMuword)2,
			senderid = NULL_OBJID);
      as$status();
      status =
	om$send (	msg	 = message ACcpx_defn.ACgive_name ( &c ),
			targetid = macro.objid,
			targetos = macro.osnum,
			senderid = NULL_OBJID);
      as$status();

      if ( c && strcmp ( c, "VDinterf_cvs" ) != 0 )
      {
	j0--;
	memcpy( &objects[i0], &objects[i0+1], (j0 - i0) * sizeof(OM_S_OBJID) );
      }
      else
      {
	/*
	 * Check for ACpl_hold on the to_component channel : if found remove them from the list
	 */
	my_chansel.type	= OM_e_name;
	my_chansel.u_sel.name = "to_components";

	sts = om$get_channel_objects(
				osnum		= (OMuword)2,
				objid		= objects[i0],
				p_chanselect	= &my_chansel,
				size		= (cnt=1),
				list		= &lobj,
				count		= &cnt );

	om$get_classid (	objid		= lobj.S_objid,
				osnum		= lobj.osnum,
				p_classid	= &clid );

	if ( clid == OPP_ACpl_hold_class_id )
	{
	  j0--;
	  memcpy( &objects[i0], &objects[i0+1], (j0 - i0) * sizeof(OM_S_OBJID) );

	  (*number_of_empties)++;	// Counting empty Interferences
	}
	else
	{
	  /*
	   * This is a REAL VDinterf_cvs macro which needs to be kept in the list
	   */
	  __printf ("ACcpx_defn.ACgive_name: i0 = %d, objects[%d] = [%d,%d], name = <%s>", `i0, j0, 2, objects[i0], c` );

	  i0++;
	}
      }
    }
  }

  *number_of_objects = j0;

  __printf ( "<<<<< *number_of_objects = %d, j0 = %d", `*number_of_objects, j0` );

  if ( j0 == 0 ) j0 = 1;

  *objcts = _REALLOC ( *objcts, j0,  OM_S_OBJID );
  if ( ! *objcts )
  {
    goto quit;
  }
  else
  {
    memcpy ( *objcts, objects, *number_of_objects * sizeof ( OM_S_OBJID ) );
  }

quit:

  _FREE (objects);

  __exitFunction ( name = "VDrevintf_check_located_obj" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDintf_find_sorted_intf
(
  long			 *ret_sts,
  IGRint		 *num_located,
  IGRint		 *num_empty,
  struct VDintf_info	**intf_info	// The calling function MUST call:  _FREE (intf_info)
)
{
  union	state		*intf_flags;
  IGRint		sts = OM_S_SUCCESS, i0, j0, cnt = 0, num_tmp = 2;
  IGRlong		msg;
  OM_S_OBJID		*list = NULL;
  struct GRid		go_sup [2], OBJ_ID[2];
  struct GRmd_env	sup_env[2];
  enum GRdpmode		Display_Mode = GRhd;
  IGRlong		numberOfBytes, BytesReceived;
  struct GRmd_env	ModuleInfo;

  __enterFunction ( name = "VDintf_find_sorted_intf" );

  *ret_sts = MSSUCC;

  /*
   * First allocate memory
   */

  sts = VDpms_find_objects ( (OMuword)2, OPP_nci_macro_class_id, &cnt, NULL );
  __printf ( "VDpms_find_objects() : sts = %d, Number of nci_macros = %d", `sts, cnt` );

  if ( cnt )
  {
    list = _MALLOC ( cnt, OM_S_OBJID );
    if ( list == NULL )
    {
      *ret_sts = MSFAIL;
      sts = 0;
      goto quit;
    }
  }
  else
  {
    *ret_sts = MSFAIL;
    sts = 0;
    goto quit;
  }
  /*
   * Find ALL objects of class nci_macro
   */
  sts = VDpms_find_objects ( (OMuword)2, OPP_nci_macro_class_id, &cnt, list );

  /*
   * Keep ONLY nci_macro's with name VDinterf_cvs AND non-empty FEET
   * i.e. remove macros which only have ACpl_hold as foot.
   */
  VDrevintf_check_located_obj( &cnt, num_empty, &list );

  *num_located = cnt;

  if ( cnt > 0 )
  {
    (*intf_info) = _MALLOC ( cnt, struct VDintf_info );
    if ( (*intf_info) == NULL )
    {
      *ret_sts = MSFAIL;
      sts = 0;
      goto wrapup;
    }
  }
  else
  {
    *ret_sts = MSFAIL;
    sts = 0;
    goto wrapup;
  }

  numberOfBytes = sizeof ModuleInfo ;
  gr$get_module_env(	msg	= &msg,
			sizbuf	= &numberOfBytes,
			buffer	= &ModuleInfo,
			nret	= &BytesReceived ) ;

  for ( i0=0; i0 < cnt; i0++ )
  {
    int	status;

    Display_Mode = GRbehd;

    (*intf_info)[i0].intf.objid = list[i0];
    (*intf_info)[i0].intf.osnum = 2;

    /*
     * This is tricky: get a pointer into the instance data of the macro
     */
    status =
      om$send (	msg	 = message ci_macro.give_internal_ptr ( (IGRint *) &msg, (IGRchar **) &intf_flags ),
		targetid = (*intf_info)[i0].intf.objid,
		targetos = (*intf_info)[i0].intf.osnum,
		senderid = NULL_OBJID);

    __printf ( "<<<<<<<<<< ci_macro.give_internal_ptr : status = %d, msg = %d, intf_flags->int_stat = %d",
	       `status, msg, intf_flags->int_stat` );

    if( ! ( status & msg & 1 ) )
    {
	continue;
    }

    (*intf_info)[i0].STATE.int_stat = intf_flags->int_stat;

    __printf ( "<<<<< intf_info[%d].STATE : int = %d, [0] = %d, [1] = %d, [2] = %d, [3] = %d",
	       `i0, (*intf_info)[i0].STATE.int_stat,
	       (*intf_info)[i0].STATE.byt_stat[0], (*intf_info)[i0].STATE.byt_stat[1],
	       (*intf_info)[i0].STATE.byt_stat[2], (*intf_info)[i0].STATE.byt_stat[3]` );
    /*
     * Find the number or templates of the interference macro : SHOULD BE 2
     */

    status =
      om$send (	msg	 = message NDnode.NDget_objects (
							 ND_ROOT, NULL, 0, NULL,
							 0, OM_K_MAXINT, &num_tmp),
		targetid = (*intf_info)[i0].intf.objid,
		targetos = (*intf_info)[i0].intf.osnum,
		senderid = NULL_OBJID);
    if ( ! ( status & 1 ) || num_tmp != MAX_TEMP )
    {
      printf("Nr. of templates of Interference should be 2 <==> %d\n", num_tmp );
      continue;
    }

    /*
     * Retrieve the two templates of the interference macro
     */

    for ( j0=0; j0 < num_tmp; j0++ )
    {
      status =
	om$send (	msg	 = message  ACcpx.ACfind_exp_temp_obj ( (int *)&msg, j0, &OBJ_ID[j0] ),
			targetid = (*intf_info)[i0].intf.objid,
			targetos = (*intf_info)[i0].intf.osnum,
			senderid = NULL_OBJID);
      if( ! ( status & msg & 1 ) )
      {
	continue;
      }

      status =
	om$send (	msg	 = message NDmacro.ACreturn_foot(
								 &msg, "",
								 &go_sup [j0],
								 &sup_env[j0].md_env.matrix_type,
								  sup_env[j0].md_env.matrix ),
			targetid = OBJ_ID[j0].objid,
			targetos = OBJ_ID[j0].osnum,
			senderid = NULL_OBJID);
      as$status();
    }

    (*intf_info)[i0].tmp1.obj_id = go_sup[0];
    (*intf_info)[i0].tmp2.obj_id = go_sup[1];

    memcpy ( &(*intf_info)[i0].tmp1.mod_env, &sup_env[0], sizeof (struct GRmd_env) );
    memcpy ( &(*intf_info)[i0].tmp2.mod_env, &sup_env[1], sizeof (struct GRmd_env) );

    (*intf_info)[i0].tmp1.mod_env.md_id.osnum = go_sup[0].osnum;
    (*intf_info)[i0].tmp1.mod_env.md_id.objid = 21;

    (*intf_info)[i0].tmp2.mod_env.md_id.osnum = go_sup[1].osnum;
    (*intf_info)[i0].tmp2.mod_env.md_id.objid = 21;

    status =  ex$get_modid ( mod_osnum = go_sup[0].osnum,
			     mod_id    = &(*intf_info)[i0].tmp1.mod_env.md_id.objid );

    status =  ex$get_modid ( mod_osnum = go_sup[1].osnum,
			     mod_id    = &(*intf_info)[i0].tmp2.mod_env.md_id.objid );

    status = vd$get_name   ( obj = &(*intf_info)[i0].tmp1.obj_id, name = (*intf_info)[i0].name1 );
    status = vd$get_name   ( obj = &(*intf_info)[i0].tmp2.obj_id, name = (*intf_info)[i0].name2 );

    EMintf_getident ( &(*intf_info)[i0].tmp1.obj_id, (*intf_info)[i0].objinf1 );
    EMintf_getident ( &(*intf_info)[i0].tmp2.obj_id, (*intf_info)[i0].objinf2 );

    Display_Mode = GRhd;
    status = vd_$bulk_display ( dpmode = Display_Mode,
				count  = 1,
				theEnv = &ModuleInfo,
				grids  = &(*intf_info)[i0].intf );
    Display_Mode = GRhhd;
    status = vd_$bulk_display ( dpmode = Display_Mode,
				count  = 1,
				objenvs= &(*intf_info)[i0].tmp1 );

    status = vd_$bulk_display ( dpmode = Display_Mode,
				count  = 1,
				objenvs= &(*intf_info)[i0].tmp2 );

    status = gr$get_symbology( object_id = &(*intf_info)[i0].tmp1.obj_id, symb = &(*intf_info)[i0].symb1 );
    status = gr$get_symbology( object_id = &(*intf_info)[i0].tmp2.obj_id, symb = &(*intf_info)[i0].symb2 );

    /*
     * Just for testing...
     */

    __printf ( "num_tmp = %d, i0 = %d, tmp1[0] = [%d,%d], tmp2[1] = [%d,%d]", `num_tmp, i0,
	       (*intf_info)[i0].tmp1.obj_id.osnum, (*intf_info)[i0].tmp1.obj_id.objid,
	       (*intf_info)[i0].tmp2.obj_id.osnum, (*intf_info)[i0].tmp2.obj_id.objid` );
  }

  /*
   * We need to SORT the struct intf_info[] with ascending (*intf_info)[i0].tmp1.obj_id.objid
   * in order to simplify manipulating the FORM gadgets SELECT_OBJ & MCF_1
   *
   * BUT :	the problem then is that there is NO WAY to get to the CORRECT index into the
   *	struct intf_info[] from the FORM gadget SELECT_OBJ ,
   *	if we were to remove the multiplicity in SELECT_OBJ
   * CONCLUSION: do SORT and disable display of MCF_1 in case of multiplicity of lines in SELECT_OBJ
   */

  __printf ( ">>>>>>>>>> Before qsort() : cnt = %d", cnt );

  if ( cnt )
  {
    qsort ( (char *) (*intf_info), cnt, sizeof ( struct VDintf_info ),
	    (int (*) (const void *, const void *) ) compare_intf_macro_template_id );
  }
  __printf ( "<<<<<<<<<< After  qsort() : cnt = %d", cnt );

wrapup:

  _FREE ( list );

quit:

  __exitFunction ( name = "VDintf_find_sorted_intf" );

  return ( sts );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDinterference_report( char * rep_fil, int overwr_append, int minmax_flag, char * start_time )
{
  int			sts;
  IGRint		num_located = 0, num_empty = 0;
  IGRlong		msg;
  char			*report_file = { "Interfer.rpt" };
  char			*app_ovwr[2] = { "overwritten", "appended to" };
  char			*filptr;
  FILE			*fptr;
  struct VDintf_info	*intf_info = NULL;

  __enterFunction ( name = "VDintferference_report" );

  if ( rep_fil )
  {
    __printf ( "report_file = <%s>", rep_fil );
  }

  if ( rep_fil && ! ( strcmp(rep_fil,"stdout") == 0 || strcmp(rep_fil,"stderr") == 0 ) )
  {
    filptr = rep_fil;
  }
  else
  {
    filptr = report_file;
  }

  sts = VDintf_find_sorted_intf ( &msg, &num_located, &num_empty, &intf_info );

  if ( (1 & sts & msg) && num_located )
  {
    VDintf_print_info ( num_located, num_empty, intf_info, stdout, minmax_flag, start_time );

    if ( filptr[0] != '\0' )
    {
      fptr = fopen ( filptr, "r");
      if ( fptr )
      {
	fclose ( fptr );
	printf ( "Report File <%s> already exists and will be %s ...\n", filptr, app_ovwr[overwr_append] );
      }

      if ( overwr_append )
      {
	fptr = fopen ( filptr, "a" );
      }
      else
      {
	fptr = fopen ( filptr, "w" );
      }

      if ( fptr )
      {
	VDintf_print_info ( num_located, num_empty, intf_info, fptr, minmax_flag, start_time );
	fclose ( fptr );
      }
    }
  }
  sts = dp$erase_hilite(msg = &msg);

  _FREE ( intf_info );

  __exitFunction ( name = "VDintferference_report" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDconvert_all_intf_macros ( char bstat, int val )
{
  union	state		*intf_flags;
  int			 i0, sts, byt_num = 0, store_in_macro = 0;
  IGRint		 num_located = 0, num_empty = 0;
  IGRlong		 msg;
  struct VDintf_info	*intf_info = NULL;

  __enterFunction ( name = "VDconvert_all_intf_macros" );

  if      ( bstat == 'a' )	// Check values for modification of Assoc_Opt
  {
    byt_num = 0;
    if ( val < 1 || val > 2 )
    {
      printf ( "Invalid Assoc Option : %d (only 1 or 2 is allowed)\n", val );
      goto quit;
    }
  }
  else if ( bstat == 's' )	// Check values for modification of Status
  {
    byt_num = 3;
    if ( val < 1 || val > MAX_INTF_STAT_CODE )
    {
      printf ( "Invalid Status : %d (only 1-%d is allowed)\n", val, MAX_INTF_STAT_CODE );
      goto quit;
    }
  }
  else
  {
    goto quit;
  }

  sts = VDintf_find_sorted_intf ( &msg, &num_located, &num_empty, &intf_info );

  if ( ! (1 & sts & msg) ) goto quit;

  for ( i0=0; i0 < num_located; i0++ )
  {
    /*
     * This is tricky: get a pointer into the instance data of the macro
     */
    sts =
      om$send (	msg	 = message ci_macro.give_internal_ptr ( (IGRint *) &msg, (IGRchar **) &intf_flags ),
		targetid = intf_info[i0].intf.objid,
		targetos = intf_info[i0].intf.osnum,
		senderid = NULL_OBJID);

    __printf ( "<<<<<<<<<< ci_macro.give_internal_ptr : sts = %d, msg = %d, intf_flags->int_stat = %d",
	       `sts, msg, intf_flags->int_stat` );

    if( ! ( sts & msg & 1 ) )
    {
	continue;
    }

    intf_info[i0].STATE.int_stat = intf_flags->int_stat;

    __printf ( ">>>>> intf_info[%d].STATE : [0] = %d, [1] = %d, [2] = %d, [3] = %d",
	       `i0,
	       intf_info[i0].STATE.byt_stat[0], intf_info[i0].STATE.byt_stat[1],
	       intf_info[i0].STATE.byt_stat[2], intf_info[i0].STATE.byt_stat[3]` );

    always_make_macro    = intf_info[i0].STATE.byt_stat[0] & (ASSOC_OPTION_1 | ASSOC_OPTION_2);
    avoid_false_interf   = intf_info[i0].STATE.byt_stat[0] & AVOID_FALSE_INTF;

    // if ( 1 ) -- Allow ONLY one way: "Do NOT Suppress False..." ==>> "Suppress False..."
    if ( 1 )
    {
      if (REV_avoid_false_interf)
      {
        avoid_false_interf = AVOID_FALSE_INTF;
      }
    }
    else
    {
      // else   -- Allow BOTH ways: "Do NOT Suppress False..." <<==>> "Suppress False..."
      // however, this does not really work now, so if it is going to be a requirement,
      // some work needs to be done...
      avoid_false_interf = REV_avoid_false_interf;
    }
    store_in_macro       = always_make_macro | avoid_false_interf;

    if ( byt_num == 0 )
    {
      store_in_macro   = val | avoid_false_interf;
      intf_info[i0].STATE.byt_stat[byt_num] = (unsigned char) store_in_macro;
    }
    else
    {
      intf_info[i0].STATE.byt_stat[byt_num] = (unsigned char) val;
    }
    intf_flags->int_stat = intf_info[i0].STATE.int_stat;
  }
  sts = dp$erase_hilite(msg = &msg);

  // For debug purpose only...
  for ( i0=0; i0 < num_located; i0++ )
  {
    __printf ( "<<<<< intf_info[%d].STATE : [0] = %d, [1] = %d, [2] = %d, [3] = %d",
	       `i0,
	       intf_info[i0].STATE.byt_stat[0], intf_info[i0].STATE.byt_stat[1],
	       intf_info[i0].STATE.byt_stat[2], intf_info[i0].STATE.byt_stat[3]` );
  }

quit:

  _FREE ( intf_info );

  __exitFunction ( name = "VDconvert_all_intf_macros" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#define _start 0

method VDintf_init ( long * sts )
{
  IGRlong		msg, numberOfBytes, BytesReceived;
  struct GRmd_env	ModuleInfo;

  *sts = MSSUCC;

  __enterMethod ( name = "VDintf_init" );

  me->num_located		= 0;
  me->num_empty			= 0;
  me->stdreportonly		= FALSE;

  me->fit_ratio			= 1.0;
  me->fit_check			= 0;
  me->curr_indx			= -1;
  me->windowId.objid		= NULL_OBJID;

  convert_assoc_opt_1		= 0;	// ALWAYS INITIALIZE to ZERO ( 0 ) !!!

  __printf ( "me->windowId = [%d,%d], fit_win =  [%d,%d]", `me->windowId.osnum, me->windowId.objid, fit_win.osnum, fit_win.objid` );

  FIg_disable      ( me->status_display_form_ptr, FI_EXECUTE );

  if ( fit_win.objid != NULL_OBJID && ( fit_win.osnum != 0 && fit_win.objid != 0 ) )
  {
    me->windowId = fit_win;
  }

  if ( VDintf_x_memo != 0 && VDintf_y_memo != 0 )
  {
    me->origin_x = VDintf_x_memo;
    me->origin_y = VDintf_y_memo;
  }
  else
  {
    me->origin_x = 0;
    me->origin_y = 150;
  }

  if ( fit_rtio > 0.0 )
  {
    me->fit_ratio = fit_rtio;
  }

  if ( overwr_append )
  {
    FIg_set_state ( me->status_display_form_ptr, APPEND_TGL, TRUE );
  }
  else
  {
    FIg_set_state ( me->status_display_form_ptr, APPEND_TGL, FALSE );
  }

  if ( minmax_flag )
  {
    FIg_set_state ( me->status_display_form_ptr, MINMAX_TGL, TRUE );
  }
  else
  {
    FIg_set_state ( me->status_display_form_ptr, MINMAX_TGL, FALSE );
  }

  if ( fit_chk )
  {
    me->fit_check = fit_chk;
    FIg_enable    ( me->status_display_form_ptr, SEL_VWT_FIT );
    FIg_set_state ( me->status_display_form_ptr, FIT_OBJ, TRUE );
  }
  else
  {
    FIg_disable   ( me->status_display_form_ptr, SEL_VWT_FIT );
    FIg_set_state ( me->status_display_form_ptr, FIT_OBJ, FALSE );
  }

  if ( report_filename[0] != '\0' )
  {
    FIg_set_text  ( me->status_display_form_ptr, REPORT_FIELD, report_filename );
  }

  if ( me->num_located )
  {
    FIg_enable    ( me->status_display_form_ptr, REPORT_BTN );
    FIg_enable    ( me->status_display_form_ptr, REPORT_FIELD );
    FIg_enable    ( me->status_display_form_ptr, REPORT_TXT );
  }
  else
  {
    FIg_disable   ( me->status_display_form_ptr, REPORT_GROUP );
  }

  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  numberOfBytes = sizeof ModuleInfo ;
  gr$get_module_env(	msg	= &msg,
			sizbuf	= &numberOfBytes,
			buffer	= &ModuleInfo,
			nret	= &BytesReceived ) ;

  memcpy ( &me->ModuleInfo, &ModuleInfo, numberOfBytes );

  __exitMethod ( name = "VDintf_init" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method wakeup ( int pos )
{
  char			txt[USER_SIZE];
  int			i0, rc;
  IGRint		sts = OM_S_SUCCESS;
  IGRlong		msg;
  enum GRdpmode		Display_Mode = GRhd;

  __enterMethod ( name = "wakeup" );

  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  sts = om$send ( mode     = OM_e_wrt_message,
		  msg      = message CEO_LOCATE.wakeup( pos ),
		  targetid = my_id);

  UI_message ("Review VDS Interference Objects");
  UI_status  ("Locating Interference Objects...");

  if ( me->status_display_form_ptr )
  {
    FIf_reset        ( me->status_display_form_ptr );
    FIf_set_location ( me->status_display_form_ptr, me->origin_x, me->origin_y );
  }

  sts = om$send ( msg      = message VDrevintf.VDintf_collect_info( &msg ),
		  targetid = my_id,
		  mode     = OM_e_wrt_message);

  if ( overwr_append )
  {
    FIg_set_state ( me->status_display_form_ptr, APPEND_TGL, TRUE );
  }
  else
  {
    FIg_set_state ( me->status_display_form_ptr, APPEND_TGL, FALSE );
  }

  if ( minmax_flag )
  {
    FIg_set_state ( me->status_display_form_ptr, MINMAX_TGL, TRUE );
  }
  else
  {
    FIg_set_state ( me->status_display_form_ptr, MINMAX_TGL, FALSE );
  }

/* DO NOT CALL status_disp HERE BECAUSE OF FLASHING FORM
  sts = om$send ( msg      = message VDrevintf.status_disp(),
		  targetid = my_id,
		  mode     = OM_e_wrt_message);
*/
  if ( me->num_located && me->curr_indx > -1 && me->curr_indx < me->num_located )
  {
      Display_Mode = GRhd;

      sts = vd_$bulk_display ( dpmode = Display_Mode,
			       count  = 1,
			       theEnv = &me->ModuleInfo,
			       grids  = &me->intf_info[me->curr_indx].intf );

      Display_Mode = GRhhd;
      sts = vd_$bulk_display ( dpmode = Display_Mode,
			       count  = 1,
			       objenvs= &me->intf_info[me->curr_indx].tmp1 );

      sts = vd_$bulk_display ( dpmode = Display_Mode,
			       count  = 1,
			       objenvs= &me->intf_info[me->curr_indx].tmp2 );
  }

  if ( ME.super_cmd->mytype == Intf)
  {
    GRstatus_display_button(1);
  }

  rc = VDretrieve_intf_status( &num_codes );

  if ( ! rc )
  {
    intf_stat[0].code = 0;
    strcpy ( intf_stat[0].desc, "NoChange" );
    num_codes = 1;
  }

  if ( me->status_display_form_ptr )
  {
    if ( ! rc && me->num_located )
    {
      FIg_set_text   ( me->status_display_form_ptr, FI_MSG_FIELD, "Error locating file : <Interf.status>");
    }

    FIfld_set_text ( me->status_display_form_ptr, STAT_LST, 0, 0, intf_stat[0].desc, FALSE );
    for ( i0=1; i0 < num_codes; i0++ )
    {
      sprintf ( txt, "%d %s", intf_stat[i0].code, intf_stat[i0].desc);
      FIfld_set_text ( me->status_display_form_ptr, STAT_LST, i0, 0, txt, FALSE );
      __printf( "code = %2d, desc = <%s>", `intf_stat[i0].code, intf_stat[i0].desc` );
    }

    FIg_enable       ( me->status_display_form_ptr, FI_FORM_GROUP );	// Enable status_form

    if ( me->fit_check )
    {
      FIg_enable  ( me->status_display_form_ptr, SEL_VWT_FIT );
    }
    else
    {
      FIg_disable ( me->status_display_form_ptr, SEL_VWT_FIT );
    }

    if ( report_filename[0] != '\0' )
    {
      FIg_set_text  ( me->status_display_form_ptr, REPORT_FIELD, report_filename );
    }

    if ( me->num_located )
    {
      FIg_enable    ( me->status_display_form_ptr, REPORT_BTN );
      FIg_enable    ( me->status_display_form_ptr, REPORT_FIELD );
      FIg_enable    ( me->status_display_form_ptr, REPORT_TXT );
    }
    else
    {
      FIg_disable   ( me->status_display_form_ptr, REPORT_GROUP );
    }

    if ( convert_assoc_opt_1 )
    {
      FIg_enable    ( me->status_display_form_ptr, FI_EXECUTE );
      FIg_set_state ( me->status_display_form_ptr, CVRT_ASSOC, TRUE );
    }
    else
    {
      FIg_disable   ( me->status_display_form_ptr, FI_EXECUTE );
      FIg_set_state ( me->status_display_form_ptr, CVRT_ASSOC, FALSE );
    }
  }

  UI_status  ("");

  __exitMethod ( name = "wakeup" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method sleep ( int pos )
{
  IGRint	sts = OM_S_SUCCESS;
  IGRlong	msg = EMS_S_Success;

  __enterMethod ( name = "sleep" );

  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  sts = dp$erase_hilite(msg = &msg);

  ex$message(msgnumb = EM_M_ClearMessageField);
  ex$message(msgnumb = EMS_I_00000);
  ex$message(msgnumb = EMS_P_00000);

  if ( me->status_display_form_ptr )
  {
    FIg_disable ( me->status_display_form_ptr, FI_FORM_GROUP );	// Disable status_form
  }

  if ( me->status_display_form_ptr )
  {
    FIf_get_location ( me->status_display_form_ptr, &VDintf_x_memo, &VDintf_y_memo );
    me->origin_x = VDintf_x_memo;
    me->origin_y = VDintf_y_memo;
  }

  if ( me->windowId.objid != NULL_OBJID )
  {
    fit_win = me->windowId;
  }

  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  __exitMethod ( name = "sleep" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method delete ( int f_defer_flag )
{
  IGRint  sts;

  __enterMethod ( name = "delete" );

  sts = om$send ( mode     = OM_e_wrt_message,
		  msg      = message CEO_LOCATE.delete ( f_defer_flag ),
		  targetid = my_id);

  if ( me->windowId.objid != NULL_OBJID )
  {
    fit_win = me->windowId;
  }

  if ( me->status_display_form_ptr )
  {
    FIg_get_text     ( me->status_display_form_ptr, REPORT_FIELD, report_filename );
    FIf_get_location ( me->status_display_form_ptr, &VDintf_x_memo, &VDintf_y_memo );
    me->origin_x = VDintf_x_memo;
    me->origin_y = VDintf_y_memo;

    fit_chk  = me->fit_check;
    fit_rtio = me->fit_ratio;
    FIf_erase( me->status_display_form_ptr );
  }
  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  __exitMethod ( name = "delete" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method status_disp ( )
{
  int 		sts;

  __enterMethod ( name = "status_disp" );

  __printf ( ">>>>> me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  sts = om$send ( msg	   = message CEO.status_disp(),
		  targetid = my_id,
		  mode	   = OM_e_wrt_message);

  __printf ( "<<<<< me->origin = [%d,%d]", `me->origin_x, me->origin_y` );

  __exitMethod ( name = "status_disp" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDintf_collect_info ( long * ret_sts )
{
  char			txt[USER_SIZE];

  IGRint		sts = OM_S_SUCCESS, i0, j0;
  struct VDintf_info	*tmp_intf_info = NULL;

  __enterMethod ( name = "VDintf_collect_info" );

  *ret_sts = MSSUCC;

  sts = VDintf_find_sorted_intf ( ret_sts, &me->num_located, &me->num_empty, &tmp_intf_info );

  __printf ("<<<<<<<<<< VDintf_find_sorted_intf() : me->num_located = %d, me->num_empty = %d", `me->num_located, me->num_empty` );

  if ( (1 & sts & (*ret_sts)) && me->num_located )
  {
    sts = om$vla_set_dimension(	varray	= me->intf_info,
				size	= me->num_located);
    sts = om$vla_set_dimension(	varray	= me->intf_copy,
				size	= me->num_located);

    for ( i0=0; i0 < me->num_located; i0++ )
    {
      me->intf_info[i0] = tmp_intf_info[i0];
    }

    _FREE ( tmp_intf_info );
  }

  if ( me->status_display_form_ptr )
  {
    if ( me->fit_check )
    {
      sts = FIg_set_state ( me->status_display_form_ptr, FIT_OBJ, TRUE );
    }

    if ( fit_rtio > 0.0 )
    {
      me->fit_ratio = fit_rtio;
    }

    sprintf ( txt, "%lg", me->fit_ratio );
    sts = FIg_set_text ( me->status_display_form_ptr, RATIO, txt );

    if ( me->num_empty )
    {
      sprintf ( txt, "Number of Interferences = %d (total number empty = %d)", me->num_located, me->num_empty );
    }
    else
    {
      sprintf ( txt, "Number of Interferences = %d", me->num_located );
    }

    sts = FIg_set_text ( me->status_display_form_ptr, FI_MSG_FIELD, txt );

    FIf_display      ( me->status_display_form_ptr );

    for ( i0=0, j0=0 ; i0 < me->num_located; i0++ )
    {
      if ( i0 == 0 )
      {
	me->intf_copy[j0] = me->intf_info[i0];

	if ( strlen (me->intf_info[i0].name1) > 0 )
	{
	  sprintf ( txt,"%s - %s", me->intf_info[i0].name1, me->intf_info[i0].objinf1 );
	}
	else
	{
	  sprintf ( txt,"%s", me->intf_info[i0].objinf1 );
	}

	FIfld_set_text ( me->status_display_form_ptr, SELECT_OBJ, j0, 0, txt, FALSE );
	j0++;
      }

      /*
       * In order to remove multiple display of the SAME object in the SELECT_OBJ field, copy ONLY
       * those records from me->intf_info[] to me->intf_copy[] which are unique with respect to tmp1.obj_id ...
       */
      if ( i0
	   && ( me->intf_info[i0].tmp1.obj_id.osnum != me->intf_info[i0-1].tmp1.obj_id.osnum ||
	        me->intf_info[i0].tmp1.obj_id.objid != me->intf_info[i0-1].tmp1.obj_id.objid ) )
      {
	me->intf_copy[j0] = me->intf_info[i0];

	if ( strlen (me->intf_copy[j0].name1) > 0 )
	{
	  sprintf ( txt,"%s - %s", me->intf_copy[j0].name1, me->intf_copy[j0].objinf1 );
	}
	else
	{
	  sprintf ( txt,"%s", me->intf_copy[j0].objinf1 );
	}

	FIfld_set_text ( me->status_display_form_ptr, SELECT_OBJ, j0, 0, txt, FALSE );
	j0++;
      }
    }
  }

  __exitMethod ( name = "VDintf_collect_info" );

  return ( OM_S_SUCCESS );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*+me
 -------------------------------------------------------------------------
  Public Message getWindow

  Abstract
	Gets and stores the window for fitting object

  Arguments
        long    *sts           O       Completion code

  Status
      status    OM_S_SUCCESS    if success

  Return Code
      sts
                VD_ERROR        if error

 -------------------------------------------------------------------------
-me*/

method getWindow( long *sts )
{
  IGRchar		winPrompt[] = "Identify window to fit object";
  IGRlong		msg;
  struct GRevent	event;

  *sts = MSSUCC;

  __enterMethod ( name = "getWindow" );

    /* erase the form */

//  FIf_erase   ( me->status_display_form_ptr );
  FIg_disable ( me->status_display_form_ptr, FI_FORM_GROUP );	// Disable status_form

  while( 1 )
  {
    while ( ! co$getevent( msg			= &msg,
			   event_mask		= ( GRm_DATA ),
			   prompt		= winPrompt,
			   response		= me->response,
			   response_data	= me->response_data,
			   event		= &event ) )
      ;

    if( ( msg&1 ) && (*me->response == EX_DATA) )
    {
      me->windowId.objid = event.event.button.objid;
      me->windowId.osnum = event.event.button.osnum;
      fit_win = me->windowId;
      break;
    }
  }

  /* restore the prompt */

  ex$message( msgnumb	= VD_P_DgEntPmFm );

  /* restore the form */

//  FIf_display( me->status_display_form_ptr );
  FIg_enable ( me->status_display_form_ptr, FI_FORM_GROUP );

  __exitMethod ( name = "getWindow", argfmt = "me->windowId = [%d,%d]", args = `me->windowId.osnum, me->windowId.objid` );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  double	fld_value;

  static char	txt[USER_SIZE];

  static int	act_mcf_1_row;
  IGRlong	msg;
  int		i0, j0, status, act_row, act_clm, pos, sts, s_flg, col=0, txt_len = 0;
  enum GRdpmode	Display_Mode;
  FILE		*fptr;

  __enterMethod ( name = "form_notification" );

  if ( form_ptr )
  {
    if ( form_ptr != me->status_display_form_ptr )
    {
      me->status_display_form_ptr = form_ptr;
    }
  }
  else
  {
    __print_goto ( "quit" );
    goto quit;
  }

  fit_rtio = me->fit_ratio;

  if ( me->fit_check )
  {
    FIg_enable ( form_ptr, SEL_VWT_FIT );
  }
  else
  {
    FIg_disable ( form_ptr, SEL_VWT_FIT );
  }

  if ( me->num_located )
  {
    FIg_enable    ( form_ptr, REPORT_BTN );
    FIg_enable    ( form_ptr, REPORT_FIELD );
    FIg_enable    ( form_ptr, REPORT_TXT );
  }
  else
  {
    FIg_disable   ( form_ptr, REPORT_GROUP );
  }

  if ( convert_assoc_opt_1 )
  {
    FIg_enable    ( form_ptr, FI_EXECUTE );
  }
  else
  {
    FIg_disable   ( form_ptr, FI_EXECUTE );
  }

  if ( gadget_label != STAT_LST ) dp$erase_hilite( msg = &msg );

  switch ( gadget_label )
  {
  case FI_CANCEL:
    {
      _put_response ( resp = EX_FORM_FINISHED );
    }
  case FI_ACCEPT:
    {
      FIf_erase ( form_ptr );
      me->form_requested = FALSE;

      break;
    }
  case FI_EXECUTE:
    {
      if ( convert_assoc_opt_1 )
      {
	/*
	 * Convert ALL Interference Macros to Assoc Option 2
	 * =================================================
	 */
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_DK_BLUE );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "Converting ALL Interference Macros to Assoc Option 2 ..." );

	VDconvert_all_intf_macros( 'a', 2 );

	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );

	/*
	 * We need to update the instance data, so ...
	 */
	FIf_get_location         ( me->status_display_form_ptr, &VDintf_x_memo, &VDintf_y_memo );

	me->origin_x = VDintf_x_memo;
	me->origin_y = VDintf_y_memo;

	sts = om$send ( msg      = message VDrevintf.VDintf_collect_info( &msg ),
			targetid = my_id,
			mode     = OM_e_wrt_message);

	sts = FIg_set_state      ( me->status_display_form_ptr, CVRT_ASSOC, FALSE );
	sts = FIg_disable	 ( me->status_display_form_ptr, FI_EXECUTE );

	convert_assoc_opt_1 = FALSE;
      }

      break;
    }
  case CVRT_ASSOC:
    {
      __printf ( ">>>>> case CVRT_ASSOC: convert_assoc_opt_1 = %d", `convert_assoc_opt_1` );

      sts = FIg_get_state        ( me->status_display_form_ptr, CVRT_ASSOC, &convert_assoc_opt_1 );

      if ( convert_assoc_opt_1 )
      {
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_DK_BLUE );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "The RUN button will convert ALL Interference Macros to Assoc Option 2" );
	sts = FIg_enable	 ( me->status_display_form_ptr, FI_EXECUTE );
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );
      }
      else
      {
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD, "" );
	sts = FIg_disable	 ( me->status_display_form_ptr, FI_EXECUTE );
      }

      __printf ( "<<<<< case CVRT_ASSOC: convert_assoc_opt_1 = %d", `convert_assoc_opt_1` );

      break;
    }
  case REPORT_FIELD:
    {
      sts = FIg_get_text_length  ( form_ptr, gadget_label, &txt_len );
      sts = FIg_get_text         ( form_ptr, gadget_label, report_filename );

      __printf ( "case REPORT_FIELD: txt_len = %d, report_filename = <%s>", `txt_len, report_filename` );

      if ( report_filename[0] != '\0' )
      {
	fptr = fopen ( report_filename, "r");
	if ( fptr )
	{
	  FIg_set_text  ( form_ptr, FI_MSG_FIELD, "ReportFile already exists ..." );

	  ems_sleep (1);
	  fclose ( fptr );
	}
      }
      else
      {
	FIg_set_text  ( form_ptr, FI_MSG_FIELD, "No Filename specified ..." );

	ems_sleep (1);
      }
      break;
    }
  case REPORT_BTN:
    {
      char			*app_ovwr[2] = { "overwritten", "appended to" };
      struct VDintf_info	*intf_info = NULL;

      FIg_set_text  ( form_ptr, FI_MSG_FIELD, "Preparing Report ..." );

      sts = FIg_get_text_length ( form_ptr, REPORT_FIELD, &txt_len );
      sts = FIg_get_text        ( form_ptr, REPORT_FIELD, report_filename );

      __printf ( "case REPORT_BTN: txt_len = %d, report_filename = <%s>", `txt_len, report_filename` );

      sts = VDintf_find_sorted_intf ( &msg, &me->num_located, &me->num_empty, &intf_info );

      if ( (1 & sts & msg) && me->num_located )
      {
	VDintf_print_info ( me->num_located, me->num_empty, intf_info, stdout, minmax_flag, NULL );

	if ( report_filename[0] != '\0' )
	{
	  fptr = fopen ( report_filename, "r");
	  if ( fptr )
	  {
	    sprintf ( txt, "Report File <%s> already exists and will be %s ...\n", report_filename, app_ovwr[overwr_append] );
	    FIg_set_text  ( form_ptr, FI_MSG_FIELD, txt );

	    ems_sleep (3);
	    fclose ( fptr );
	  }

	  if ( overwr_append )
	  {
	    fptr = fopen ( report_filename, "a" );
	  }
	  else
	  {
	    fptr = fopen ( report_filename, "w" );
	  }

	  if ( fptr )
	  {
	    VDintf_print_info ( me->num_located, me->num_empty, intf_info, fptr, minmax_flag, NULL );
	    fclose ( fptr );
	  }
	}
	else
	{
	  FIg_set_text  ( form_ptr, FI_MSG_FIELD, "No Filename specified ..." );

	  ems_sleep (1);
	}

	_FREE ( intf_info );
      }

      FIg_set_state ( form_ptr, gadget_label, FALSE );
      FIg_set_text  ( form_ptr, FI_MSG_FIELD, "Report Finished ..." );

      break;
    }
  case APPEND_TGL:
    {
      __printf ( ">>>>> case APPEND_TGL: overwr_append = %d", `overwr_append` );

      FIg_get_state  ( form_ptr, gadget_label, &overwr_append );

      if ( overwr_append )
      {
	FIg_set_text ( form_ptr, FI_MSG_FIELD, "The Report will be appended to ..." );
      }
      else
      {
	FIg_set_text ( form_ptr, FI_MSG_FIELD, "The Report will be created/overwritten ..." );
      }
      __printf ( "<<<<< case APPEND_TGL: overwr_append = %d", `overwr_append` );

      break;
    }
  case MINMAX_TGL:
    {
      __printf ( ">>>>> case MINMAX_TGL: minmax_flag = %d", `minmax_flag` );

      FIg_get_state  ( form_ptr, gadget_label, &minmax_flag );

      if ( minmax_flag )
      {
	FIg_set_text ( form_ptr, FI_MSG_FIELD, "Generate Condensed Report ..." );
      }
      else
      {
	FIg_set_text ( form_ptr, FI_MSG_FIELD, "Generate Detailed Report ..." );
      }
      __printf ( "<<<<< case MINMAX_TGL: minmax_flag = %d", `minmax_flag` );

      break;
    }
  case RATIO:
    {
      FIg_get_value ( form_ptr, gadget_label, &fld_value);

      me->fit_ratio = fit_rtio = fld_value;

      break;
    }
  case FIT_OBJ:
    {
      FIg_get_state ( form_ptr, gadget_label, &me->fit_check);

      fit_chk  = me->fit_check;

      if ( me->fit_check )
      {
	FIg_enable ( form_ptr, SEL_VWT_FIT );
	status =
	  om$send (	msg	 = message VDrevintf.getWindow( &msg ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
      }
      else
      {
	FIg_disable ( form_ptr, SEL_VWT_FIT );
      }
      break;
    }
   case SEL_VWT_FIT:
    {
      /*
       * get the window if needed
       */
      status =
	om$send (	msg	 = message VDrevintf.getWindow( &msg ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );

      FIg_set_state ( form_ptr, gadget_label, FALSE );
      break;
    }
  case STAT_LST:	// TODO: This case needs to be extended in funtionality, preliminary only...
    {
      int	    sel_flag;

      sts = FIfld_get_active_row  ( form_ptr, gadget_label, &act_row, &pos );
      sts = FIfld_get_text        ( form_ptr, gadget_label,  act_row, 0, USER_SIZE, (unsigned *)txt, &sel_flag, &pos );

      if ( act_row > 0 )	// act_row == 0 : DO NOT change the STATUS
      {
	int	      n0 = me->curr_indx;

	unsigned char approv;
	unsigned int  appdum;
	extern void VDintf_update_status();

	sscanf ( txt, "%u ", &appdum );
	approv = appdum;

	me->intf_info[n0].STATE.byt_stat[3] = approv;
	sprintf ( txt,"%d", approv );

	VDintf_update_status ( &me->intf_info[n0] );

	FIfld_set_text		  ( form_ptr, MCF_1, act_mcf_1_row, 3, txt, FALSE );
      }

      sts = FIg_erase             ( form_ptr, 43 );
      sts = FIg_disable		  ( form_ptr, STAT_LST );
      sts = FIg_erase		  ( form_ptr, STAT_LST );

      sts = FIg_enable            ( form_ptr, SELECT_OBJ );
      sts = FIg_enable            ( form_ptr, MCF_1 );
      sts = FIg_enable            ( form_ptr, REPORT_GROUP );
      sts = FIg_display           ( form_ptr, MCF_1 );
      sts = FIg_display           ( form_ptr, 24 );
      sts = FIg_display           ( form_ptr, 25 );
      sts = FIg_display           ( form_ptr, LINES_GROUP );

      break;
    }
  case MCF_1:
    {
      struct GRid	sel_ID;
      int		s0_flg = 0, s1_flg = 0, s3_flg = 0;

      sts = FIg_get_state         ( form_ptr, FIT_OBJ, &me->fit_check);
      sts = FIfld_get_active_row  ( form_ptr, gadget_label, &act_row, &pos );
      sts = FImcf_get_active_col  ( form_ptr, gadget_label, &act_clm, &pos );
      sts = FIfld_get_select      ( form_ptr, gadget_label,  act_row, 0, &s0_flg );
      sts = FIfld_get_select      ( form_ptr, gadget_label,  act_row, 1, &s1_flg );
      sts = FIfld_get_select      ( form_ptr, gadget_label,  act_row, 3, &s3_flg );

      act_mcf_1_row = act_row;

      __printf ( "case MCF_1: act_row = %d, act_clm = %d, s0_flg = %d, s1_flg = %d, s3_flg = %d",
		 `act_row, act_clm, s0_flg, s1_flg, s3_flg` );

      if ( s0_flg == 0 && s1_flg == 0 )
      {
	sts = FIfld_set_select    ( form_ptr, gadget_label,  act_row, act_clm, TRUE );
	if ( act_clm == 1 )
	{
	  s1_flg = 1;
	}
	else
	{
	  s0_flg = 1;
	}
      }

      if ( s1_flg )		// Special processing for STATUS column
      {
	sts = FIg_disable      ( form_ptr, SELECT_OBJ );
	sts = FIg_disable      ( form_ptr, MCF_1 );
	sts = FIg_disable      ( form_ptr, REPORT_GROUP );
	sts = FIg_erase        ( form_ptr, 24 );
	sts = FIg_erase        ( form_ptr, 25 );
	sts = FIg_erase        ( form_ptr, LINES_GROUP );

	sts = FIg_enable       ( form_ptr, STAT_LST );
	sts = FIg_display      ( form_ptr, STAT_LST );
	sts = FIg_display      ( form_ptr, 43 );
      }
      else
      {
	sts = FIg_disable      ( form_ptr, STAT_LST );
	sts = FIg_erase        ( form_ptr, STAT_LST );
	sts = FIg_erase        ( form_ptr, 43 );

	sts = FIg_enable       ( form_ptr, SELECT_OBJ );
	sts = FIg_enable       ( form_ptr, MCF_1 );
	sts = FIg_enable       ( form_ptr, REPORT_GROUP );
	sts = FIg_display      ( form_ptr, MCF_1 );
	sts = FIg_display      ( form_ptr, 24 );
	sts = FIg_display      ( form_ptr, 25 );
	sts = FIg_display      ( form_ptr, LINES_GROUP );
      }

      if ( s0_flg || s1_flg )
      {
	int sel_flag;

	sts = FIfld_get_text ( form_ptr, gadget_label,  act_row, col=1, USER_SIZE, (unsigned *)txt, &sel_flag, &pos );

	sscanf ( txt, "%u %u", &sel_ID.osnum, &sel_ID.objid );

	for ( i0=0; i0 < me->num_located; i0++ )
	{
	  if ( me->intf_info[i0].intf.osnum == sel_ID.osnum &&
	       me->intf_info[i0].intf.objid == sel_ID.objid )
	  {
	    me->curr_indx = act_row = i0;
	    break;
	  }
	}

	FIg_reset ( form_ptr, MCF_2 );

	sts = VDintf_update_MCF_2 ( act_row, me->intf_info, form_ptr );

	if ( me->fit_check )
	{
	  if ( s0_flg )
	  {
	    sts =
	      vd$vw_fit_object(
			       object	= &me->intf_info[act_row].tmp2.obj_id,
			       md_env	= &me->intf_info[act_row].tmp2.mod_env,
			       ggid	= &me->windowId,
			       factor	=  me->fit_ratio,
			       num_ggid	= 1 );
	  }
	  else if ( s1_flg )
	  {
	    sts =
	      vd$vw_fit_object(
			       object	= &me->intf_info[act_row].intf,
			       md_env	= &me->ModuleInfo,
			       ggid	= &me->windowId,
			       factor	=  me->fit_ratio,
			       num_ggid	= 1 );
	  }
	}

	Display_Mode = GRhhd;
	status = vd_$bulk_display ( dpmode = Display_Mode,
				    count  = 1,
				    objenvs= &me->intf_info[act_row].tmp1 );
	status = vd_$bulk_display ( dpmode = Display_Mode,
				    count  = 1,
				    objenvs= &me->intf_info[act_row].tmp2 );

	Display_Mode = GRhd;
	status = vd_$bulk_display ( dpmode = Display_Mode,
				    count  = 1,
				    theEnv = &me->ModuleInfo,
				    grids  = &me->intf_info[act_row].intf );
      }
      else
      {
	FIg_reset    ( form_ptr, MCF_2 );
	FIg_set_text ( form_ptr, FI_MSG_FIELD, "" );
      }

      break;
    }
  case SELECT_OBJ:
    {
      struct GRid	sel_ID;

      s_flg = 0;

      sts = FIfld_get_active_row  ( form_ptr, gadget_label, &act_row, &pos );
      sts = FIfld_get_select      ( form_ptr, gadget_label,  act_row, 0, &s_flg );

      if ( s_flg )
      {
	me->curr_indx = act_row;

	sel_ID = me->intf_copy[act_row].tmp1.obj_id;

	__printf ( "case SELECT_OBJ: act_row = %d, s_flg = %d, sel_ID = [%d,%d]", `act_row, s_flg, sel_ID.osnum, sel_ID.objid` );

	FIg_reset ( form_ptr, MCF_1 );
	FIg_reset ( form_ptr, MCF_2 );

	if( me->windowId.objid != NULL_OBJID && me->fit_check )
	{
	  sts =
	    vd$vw_fit_object(
			     object	= &me->intf_copy[act_row].tmp1.obj_id,
			     md_env	= &me->intf_copy[act_row].tmp1.mod_env,
			     ggid	= &me->windowId,
			     factor	=  me->fit_ratio,
			     num_ggid	= 1 );
	}

	Display_Mode = GRhhd;
	status = vd_$bulk_display ( dpmode = Display_Mode,
				    count  = 1,
				    objenvs= &me->intf_copy[act_row].tmp1 );

	for ( i0=0, j0=0; i0 < me->num_located; i0++ )
	{
	  if ( me->intf_info[i0].tmp1.obj_id.osnum == sel_ID.osnum &&
	       me->intf_info[i0].tmp1.obj_id.objid == sel_ID.objid )
	  {
	    unsigned char byt_0 = me->intf_info[i0].STATE.byt_stat[0];

	    if ( strlen (me->intf_info[i0].name2) > 0 )
	    {
	      sprintf ( txt,"%s - %s", me->intf_info[i0].name2, me->intf_info[i0].objinf2 );
	    }
	    else
	    {
	      sprintf ( txt,"%s", me->intf_info[i0].objinf2 );
	    }
	    FIfld_set_text ( form_ptr, MCF_1, j0, 0, txt, FALSE );

	    sprintf ( txt,"%2d%6d", me->intf_info[i0].intf.osnum, me->intf_info[i0].intf.objid );
	    FIfld_set_text ( form_ptr, MCF_1, j0, 1, txt, FALSE );

            always_make_macro  = byt_0 & (ASSOC_OPTION_1 | ASSOC_OPTION_2);

	    sprintf ( txt,"%d", always_make_macro );
	    FIfld_set_text ( form_ptr, MCF_1, j0, 2, txt, FALSE );

	    sprintf ( txt,"%d", me->intf_info[i0].STATE.byt_stat[3] );
	    FIfld_set_text ( form_ptr, MCF_1, j0, 3, txt, FALSE );

	    Display_Mode = GRhd;
	    status = vd_$bulk_display ( dpmode = Display_Mode,
					count  = 1,
					theEnv = &me->ModuleInfo,
					grids  = &me->intf_info[i0].intf );
	    Display_Mode = GRhhd;
	    status = vd_$bulk_display ( dpmode = Display_Mode,
					count  = 1,
					objenvs= &me->intf_info[i0].tmp2 );

/********** Not necessary anymore since we are only displaying unique occurences of tmp1.obj_id
	    if ( act_row )
	    {
	      struct GRid t0, t1;

	      t0 = me->intf_info[act_row-1].tmp1.obj_id;
	      t1 = me->intf_info[act_row  ].tmp1.obj_id;

	      if ( t1.osnum == t0.osnum && t1.objid == t0.objid )
	      {
		sts = FIg_disable     ( form_ptr, MCF_1 );
	      }
	      else
	      {
		sts = FIg_enable      ( form_ptr, MCF_1 );
	      }
	    }
**********/
	    j0++;
	  }
	}

	FIg_display  ( form_ptr, MCF_1 );

	sprintf ( txt, "Object %d : Number of Interferences = %d", act_row+1, j0 );

	if ( j0 == 1 )		// If j0 == 1 , also fill out MCF_2
	{
	  sts = VDintf_update_MCF_2 ( act_row, me->intf_info, form_ptr );
	}

      	FIg_set_text ( form_ptr, FI_MSG_FIELD, txt );
      }
      else
      {
	me->curr_indx = -1;
	FIg_reset    ( form_ptr, MCF_1 );
	FIg_reset    ( form_ptr, MCF_2 );
	FIg_set_text ( form_ptr, FI_MSG_FIELD, "" );
      }

      break;
    }
  case MCF_2:
    {
      break;
    }
  } /* END switch ( gadget_label ) */

quit:

 __exitMethod ( name = "form_notification" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_update_status
(
  struct VDintf_info	*intf_info
)
{
  union state  *intf_flags;
  IGRint	sts, msg;

  __enterFunction ( name = "VDintf_update_status" );

  __printf ( "<<<<< intf_info->STATE : int = %d, [0] = %d, [1] = %d, [2] = %d, [3] = %d",`
	     intf_info->STATE.int_stat,
	     intf_info->STATE.byt_stat[0], intf_info->STATE.byt_stat[1],
	     intf_info->STATE.byt_stat[2], intf_info->STATE.byt_stat[3]` );
  /*
   * This is tricky: get a pointer into the instance data of the macro
   */
  sts =
    om$send (	msg	 = message ci_macro.give_internal_ptr ( (IGRint *) &msg, (IGRchar **) &intf_flags ),
		targetid = intf_info->intf.objid,
		targetos = intf_info->intf.osnum,
		senderid = NULL);

  __printf ( "<<<<< ci_macro.give_internal_ptr : sts = %d, msg = %d, intf_flags->int_stat = %d", `sts, msg, intf_flags->int_stat` );

  if( ! ( sts & msg & 1 ) )
  {
    goto quit;
  }

  intf_flags->int_stat = intf_info->STATE.int_stat;

  __printf ( "<<<<< intf_info->STATE : int = %d, [0] = %d, [1] = %d, [2] = %d, [3] = %d, intf_flags->int_stat = %d",`
	     intf_info->STATE.int_stat,
	     intf_info->STATE.byt_stat[0], intf_info->STATE.byt_stat[1],
	     intf_info->STATE.byt_stat[2], intf_info->STATE.byt_stat[3], intf_flags->int_stat` );
quit:
  __exitFunction ( name = "VDintf_update_status" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDrevintf;
