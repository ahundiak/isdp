/* $Id: VDCmdStrtupi.I,v 1.17 2002/06/13 19:11:13 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/cmd / .I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdStrtupi.I,v $
 *	Revision 1.17  2002/06/13 19:11:13  hans
 *	No TR; Cleanup (& remove potential error: inconsistent '{')
 *	
 *	Revision 1.16  2002/06/07 14:57:09  ramarao
 *	To Do List Implementation.
 *
 *	Revision 1.15  2002/02/26 17:50:28  ahundiak
 *	ah
 *
 *	Revision 1.14  2001/08/30 23:27:37  ad
 *	*** empty log message ***
 *
 *	Revision 1.12  2001/03/22 18:47:56  ahundiak
 *	ah
 *
 *	Revision 1.11  2001/03/12 18:23:10  ahundiak
 *	ah
 *
 *	Revision 1.10  2001/03/11 18:36:16  ahundiak
 *	ah
 *
 *	Revision 1.9  2001/03/07 19:07:02  jdsauby
 *	Replaced vdpdm$UpdatePdmInfo with VDpdmStartup
 *
 *	Revision 1.8  2001/03/06 00:52:38  hans
 *	Moved start_journaling() from VDstartup.u to here
 *
 *	Revision 1.7  2001/02/26 15:51:12  ahundiak
 *	ah
 *
 *	Revision 1.6  2001/02/17 14:34:37  ahundiak
 *	Added call to VDdomInitSystem
 *
 *	Revision 1.5  2001/02/11 18:04:48  hans
 *	Disabled EX_get_version();
 *
 *	Revision 1.4  2001/02/10 22:33:41  hans
 *	Get/display BspMath version info
 *
 *	Revision 1.3  2001/02/10 22:27:11  hans
 *	Get/display BspMath version info
 *
 *	Revision 1.2  2001/01/22 16:08:49  ahundiak
 *	sp merge
 *
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *
# Revision 1.6  2000/09/17  18:56:38  pinnacle
# Replaced: vds/vdstartup/cmd/VDCmdStrtupi.I for:  by jwfrosch for Service Pack
#
# Revision 1.4  2000/08/09  17:46:36  pinnacle
# Replaced: vds/vdstartup/cmd/VDCmdStrtupi.I for:  by jwfrosch for Service Pack
#
# Revision 1.8  2000/03/09  21:42:22  pinnacle
# ah
#
# Revision 1.7  1998/11/08  14:46:20  pinnacle
# ah
#
# Revision 1.6  1998/10/21  11:12:26  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by vsrivast for vds
#
# Revision 1.5  1998/08/21  17:52:08  pinnacle
# CR_179801436: Redesign with ppl call
#
# Revision 1.4  1998/08/20  19:20:20  pinnacle
# (No comment)
#
# Revision 1.2  1998/06/02  20:22:20  pinnacle
# Look for, print "config/motd" during session startup (method execute)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/10  15:49:20  pinnacle
# Delete Smart cache
#
# Revision 1.4  1997/09/30  16:56:40  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by lawaddel for vds
#
# Revision 1.3  1997/09/23  16:45:56  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by impd for vds
#
# Revision 1.2  1997/09/16  19:18:46  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by lawaddel for vds
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1996/04/30  14:53:46  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by hverstee for vds.240
#
# Revision 1.8  1996/01/03  05:38:00  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by ksundar for vds.240
#
# Revision 1.7  1995/10/12  18:28:24  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by rmanem for vds.240
#
# Revision 1.5  1995/09/25  22:56:56  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by sundar for vds.240
#
# Revision 1.4  1995/08/10  18:40:16  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/07/06  21:06:36  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I for:  by azuurhou for vds.240
#
# Revision 1.2  1994/12/21  22:24:50  pinnacle
# Replaced: vdstartup/cmd/VDCmdStrtupi.I by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/21/94	adz/raju	correction to dload function.
 *	07/07/95	adz		Add VDSdrw macro.
 *      08/10/95	Ravi	 	Commented the Add button to
 *					pocket Menu.(fix for TR#179423040)
 *      10/10/95	rmn	 	Changed VDScheckRefFilesDependency
 *					arguments, to include list of mismatched
 *					and broken connections
 *	10/11/95	rmn		Back up to previous version.
 *					Minimal table update will not be
 *					supported for the time being.
 *					Changes to support minimal table
 *					update have been ifdef'ed within
 *					MIN_TBL_UPDATE
 *	01/03/96	Sundar		Changed ifdef in function
 *					VDprd_load_corrections
 *      09/30/97        law             CR179701052 added VDdispfiledat for
 *					reference file dates.
 *      04/10/98        ah              Delete the smart attribute cache
 *      06/05/98        ejm             Look for, print file, "config/motd", on
 *					  session startup
 *      08/18/98        ejm             CR 179801436: Dynamically load fix
 *					  during product startup. Added
 *					  VDprd_dload_files.
 *	10/16/98	vinit		TR 179802014: Added small routine
 *					to load correct fonts during vds
 *					startup.
 *      11/08/98        ah              Start a ppl during file retrieval
 *      01/22/01        ah              sp merge, prints model executable version
 *      02/10/2001      HF              Print BspMath version info
 *      02/16/01        ah              Init the dom system
 *      03/05/2001      HF              Moved start_journaling() from
 *                                      VDstartup.u to here
 *      03/12/01        ah              Added executeCnt functionality
 *      03/22/01        ah              Added executeCnt to init calls
 *      02/26/02        ah              Removed VDdomInitSystem
 *      06/14/02        HF              Cleanup
 * -------------------------------------------------------------------*/

class implementation VDCmdStrtup ;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <FI.h>
#include <sys/types.h>
#include <dirent.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EXproduct.h"
#include "exmacros.h"
#include "ciexecmacros.h"
#include "msdef.h"
#include "wl.h"
#include "ms.h"
#include "msmacros.h"
#include "grlicense.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "VDmsg.h"
#include "vdprdmacros.h"
#include "v_slc.h"
#include "v_pplslc.h"     /* vd$obj_ppl_exec */

#include "VDtypedef.h"
#include "VDppl1.h"
#include "VDpdm.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "exdate.h"
#include "exvers.h"

#define	VD_DEBUG
#include	<VDdebug.h>

extern char EX_version[];
extern char EX_date[];
extern EX_get_version ();
extern IGGetBsVersion();

/*
 * Includes of function prototypes.
 */
%safe
#include <VX_FIproto.h>
%endsafe

#include "VDsaProto.h"

#define VDS_SESSION_STARTUP	0
#define VDS_DGNFILE_STARTUP	1

#define TEXT_FONT       "-adobe-courier-medium-*-normal-*-15-*-*-*-*-*-*-*"

extern int	UI_error			__(( char * )) ;
extern long	ASsuper_construct		__(( void )) ;
extern void	VDsuper_construct		__(( void )) ;
extern void	VDSet_SUper_construct		__(( void )) ;
extern int	SMAddToPocketMenu		__(( void )) ;
extern int	VDSnopdu_init			__(( void )) ;
extern int	VDSudp_init			__(( void )) ;
extern int	ACcond_CLEAR    		__(( void )) ;

extern struct EX_prod_def  *EX_product_list;
static WLfont font_id;
static int    chck_jnl;

/* -----------------------------------------------
 * Count the number of times execute is called
 * Expose it the service pack manager for possible
 * selective loading
 *
 * Actually, track the number of time execute is called
 * with me->mytype == VDS_DGNFILE_STARTUP
 */
static IGRint executeCnt;
IGRint VDstartupGetExecuteCnt() { return executeCnt; }

/*----------------------------------------------------------------------------*/

static void start_journaling()
{
  char    *journal;
  OMuint   jnl_id = NULL_OBJID;

  journal = getenv("ISDP_JOURNAL");

  if (journal != NULL && (strcmp(journal, "1") == 0))
  {
    // Until Enable/Disable Verbose Journalling is working correctly...
    if ( ! toggle_enable_print() )
      toggle_enable_print();

    ci$load( file_name = "VDstrjnl.u", file_id = &jnl_id, sender_id = NULL_OBJID );
    if ( jnl_id != NULL_OBJID )
    {
      ci$run(file_id = &jnl_id, sender_id = NULL_OBJID);
    }
  }
}

/*----------------------------------------------------------------------------*/

int   VDS_static_CLEAR()
{
  int   status;

  /*    clear static buffers at designfile init     */

  /*    Conditional macros, until EMS takes care of it
        (see vdassoc/ACcond_defi.I)                            */

  status = ACcond_CLEAR ();

  return 1;
}

/*----------------------------------------------------------------------------*/

method init( int type ; char *s )
{
  me->mytype = type ;
  return OM_S_SUCCESS ;
} /* method init */

/*----------------------------------------------------------------------------*/

method execute(	int *response ; char *response_data ; int pos )
{
  long	msg;
  int	ii, sts;
#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
  int	i;
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */
  char	file_name[257],
	command[261];
	FILE   *fp;
/*********** New for check dates on ref files Sept 97 **********/
  extern int VDdispfiledat();
  char *expr;
  char *p;

  extern char *getenv ();

/* Added for TR 179802014 - Vinit */

  IGRchar          path[DI_PATH_MAX];
  IGRchar          path_out[DI_PATH_MAX];
  IGRchar          **windows;
  IGRint           ptr;
  IGRint           deep;
  GRspacenum       osNum;

  int              VDcomment_sav = VDcomment;

/**********************************/
  SetProc( VDCmdStrtup_execute ); Begin;

  //  if ( ! VDcomment ) VDcomment = 1;
  __enterMethod ( name = "execute", argfmt = "response = %d, pos = %d, response_data = <%s>",
                  args = `*response, pos, response_data` );

/*********** end New **********/

  nd$mod_broadcast(	request     = ND_SET,
                        req_mode    = ND_NO_BROAD_DEL ) ;

  VDdisableToDoList();

  if( me->mytype == VDS_SESSION_STARTUP )
  {
    /*
     *Session startup. See if user has a license to use I/VDS
     *
     * gr$get_license(
     *		product_id      = "SM01096",
     *          run_name        = "Vds",
     *		options		= GRDisableOnError ) ;
     */

    __DBGpr_com(" VDS_SESSION_STARTUP ");

    // Reset counter regardless of what happens
    executeCnt = 0;

    // HF: 08/08/2000 - Print Model-executable version & date info
    if ( 1 )
    {
      char bs_version[128];

      // Get/print BspMath version info...
      IGGetBsVersion(bs_version);

      UI_status (bs_version);
      fprintf(stdout, " %s\n\n", bs_version);
    }

    /* Print contents of $PRODUCT/config/motd to stdout */
    for( ii=0; ;ii++ )
    {
      *file_name=0;
      sts = ex$get_path ( index= ii,
                          path = file_name,
                          len  = sizeof(file_name) );
      if( sts == 0 )
      {
        __DBGpr_com(" motd not found ");
        break;
      }
      strcat(file_name,"config/motd");
      fp = fopen( file_name, "r" );
      if( fp == (FILE *) NULL ) continue;
      else
      {
        __DBGpr_str(" Located motd", file_name);
        sprintf( command, "cat %s", file_name);
        system( command );
        fclose( fp );
        break;
      }
    }

    /*
     * initialization of I/VDS globals.
     */
    VDgblInitStaticData(0);
    VDctxInitSystem(0);
    VDctyInitSystem(0);
    VDct1InitSystem(0);
  }
  else if( me->mytype == VDS_DGNFILE_STARTUP )
  {
    int		nbModRef;
    OMuword	*modRefList = NULL;

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
    int		nbBrkRef ;
    OMuword	*brkRefList = NULL;
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

    TGRid   pplID;
    IGRint  pplRET;
    IGRchar pplProduct[16];

    __DBGpr_com(" VDS_DGNFILE_STARTUP ");

    // Update the counter
    executeCnt++;

    // Inform the ppl about to start
    strcpy(pplProduct,"vds");
    vdppl$Load(pplID = &pplID, name = "VDstartup.u");
    vdppl$SetData(pplID = &pplID,
                  name  = "PRODUCT",
                  size  = 16,
                  data  = pplProduct);

    vdppl$Run(pplID = &pplID, name = "startup1", ret = &pplRET);

    ASsuper_construct() ;
    VDsuper_construct() ;

    /*
     * Initialization of set manager object.
     */
    VDSet_Super_construct();

    /*
     * Initialize non-PDU version of VDS
     * ( check for PDU presence is done in VDSnopdu_init )
     */
    VDSnopdu_init();

    /*
     * Startup command for command "User defined path".
     */
    VDSudp_init();

    /*
     * Load libraries of macro definition of VDS/SMAN objects.
     *	- VDSmacros
     *	- PPMmacros
     *	- SMPrivMac (SMmacro)
     */
    VDSloadMacroLibrary( "VDSmacro" );
    VDSloadMacroLibrary( "PPMmacro" );
    VDSloadMacroLibrary( "SMPrivMac" );
    VDSloadMacroLibrary( "VDSdrw" );

    /*
     * VDSloadMacroLibrary( "SMmacro" );
     */

    /*
     * Add button to the pocket menu, only in interactive mode.
     * This will be moved to the wakeup method of the command.
     */

    /*
     * Dyn load files (if any) in config/dload/VDS_DLOAD_DIR
     */

    vd$prd_load_corrections( run_name = VD_PROD_NAME_VDS );

    /*
     * Dynamically load fixes files (if any)
     * VDprd_dload_files();
     */
    // vd$obj_ppl_exec( file_name = "vd_shared" );

    /*
     * Smart attributes have their own pdm cache.
     * Delete it each time we bring up another file
     */
    vdsa$DeleteCache();

    // Tell ppl that local files are loaded
    vdppl$Run(pplID = &pplID, name = "startup2", ret = &pplRET);

    /*
     * Should this file reference other files, see if this file
     * has elements depending upon objects in the other
     * files; if so perform update of dependent elements in this
     * file if parent objects in the reference files have been
     * modified. Also if objects in this file consume elements
     * in reference files, reconsume them since they come up
     * as not consumed.
     */
    nbModRef = 0 ;

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
    nbBrkRef = 0;
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

    /*
      10/10/95 - rmn : don't check for struct.  Does not matter if
      form appears twice. Supposed to be fixed in future version of Struct.
      Need to check for broken connections in VDS

      ret_status = vd$prd_get_product_info(logo = VD_PROD_LOGO_STRUCT );
      if( !ret_status )
    */
    /* -----------------------------------------------
     * Skip this whole nonsense if anenv variable is set
     */
    p = getenv("ISDP_SKIP_REF_CHECKS");
    if (p)
    {
      if (*p != '1') p = NULL;
    }

    if( (!ex$is_batch()) && (p == NULL) )
    {
      /*** New Sept 97 **********************************/
      expr = NULL;
      expr = getenv("VD_CHECK_REF_LIB");
      if(expr)
      {
        int rc;
        if(expr[0] == '1') rc = VDdispfiledat();
      }
      /*
       * `EX_MAX_INVIS_MODULE' is not a constant but a
       * global, hence we must allocate the memory.
       */

      modRefList = _MALLOC( EX_MAX_INVIS_MODULES, OMuword );

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
			/* 10/10/95 - rmn
			 * Allocate double the amount needed : can use for both
			 * modRefList and brkRefList arguments to the function.
			 */

      modRefList = _MALLOC( 2 * EX_MAX_INVIS_MODULES, OMuword );
      brkRefList = &modRefList[EX_MAX_INVIS_MODULES];
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

      if( modRefList )
      {
        VDScheckRefFilesDependency(	&msg,
                                        FALSE,
                                        &nbModRef,
                                        modRefList );
#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
        VDScheckRefFilesDependency(	&msg,
                                        FALSE,
                                        NULL, NULL,
                                        NULL, NULL,
                                        &nbModRef,
                                        modRefList,
                                        &nbBrkRef,
                                        brkRefList ) ;
			/* fill gaps in list */

        for( i = 0 ; i < nbBrkRef ; i++ )
          modRefList[i+nbModRef] = brkRefList[i];
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */
      }
    }

    __DBGpr_int( "Number of modified ref files", nbModRef );

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
    __DBGpr_int( "Number of broken ref files", nbBrkRef );

    if( nbModRef || nbBrkRef)
#else
    if( nbModRef )
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */
    {
      int rc ;

      /*
       * function will check for duplicate filenames
       */

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */

      rc = VDSupdChkRefFilesForm( nbModRef + nbBrkRef,modRefList );

#endif                  /* -----------End MIN_TBL_UPDATE-------------- */
      rc = VDSupdChkRefFilesForm( nbModRef, modRefList );
      if( !rc )
      {
        /*
         * Form creation failed: force update anyway.
         */
        VDScheckRefFilesDependency( &msg, TRUE, NULL, NULL ) ;
      }
      else
      {
        do
        {
          ex$wait_for_input(response = response,
                            buffer   = response_data,
                            mode     = EX_ALL_ASCII_MODE,
                            byte     = &rc ) ;
        } while( *response != EX_FORM_FINISHED ) ;
      }
    }
    _FREE( modRefList );

    /*   clear local buffers where needed     */

    VDS_static_CLEAR();

    // Repeat initialization but flag as being during drawing retrieval
    VDgblInitStaticData(executeCnt);
    VDctxInitSystem(executeCnt);
    VDctyInitSystem(executeCnt);
    VDct1InitSystem(executeCnt);

    // Verify correct pdm information
    //vdpdm$UpdatePdmInfo();
    VDpdmStartup();

    // Get rid of the ppl
    vdppl$Delete(pplID = &pplID);

    // Start ISDP Journaling...
    if ( chck_jnl == 0 )
    {
      start_journaling();
      chck_jnl = 1;
    }
  } /* Else any other type may be used to have some .o file
       dynamically loaded.
    */

    /* Added for TR 179802014 : Ems measure length showing greek
       text till coordinate displayed is toggled on  */
  {
    int win_no;
    WLuint16 lscreen_no;

    /*  Get the number of windows (ptr) */

    sts = ex$get_cur_mod (osnum = &osNum);
    sts = di$give_pathname ( osnum    = osNum,
                             pathname = path );
    sprintf ( path_out , "%s:views:regviews:GRviews:", path );
    di$find ( start_dir = path_out,
              regexp    = "*",
              lines     = &windows,
              ptr       = &ptr,
              deep      = &deep );

    /* Load the Font for all windows */

    for(win_no=0;win_no< ptr;win_no++)
    {
      WLget_window_screen(win_no, &lscreen_no);
      WLload_font(lscreen_no, TEXT_FONT, &font_id);
      WLset_active_font(win_no, font_id);
    }
  }
  /********************************************************/
  *response = TERMINATE ;

  __exitMethod ( name = "execute" );
  VDcomment = VDcomment_sav;

  End ;
  return OM_S_SUCCESS ;

} /* method execute */

/*------------------------------------------------------------------------
 Doc : VDprd_load_corrections()

 Desc: This function dyn loads all the files it finds in the
       directory $VDS/config/dload/VDS_DLOAD_DIR.

 History :
 Raju   10-16-94     Creation
--------------------------------------------------------------------------*/

VDprd_load_corrections( IGRchar	*run_name )
{
  long		status;
  char		dyn_load_dir[256],
		status_mess[256],
		dload_file[256];
  int		len;
  DIR		*dirp;
  struct dirent	*dp;
  int		nbytes;

  SetProc( VDprd_load_corrections ); Begin;

  status =
    vd$prd_get_product_info(	run_name  = run_name,
			     	conf_path = dyn_load_dir    );

  if ( !status )  /* not able to find config path */
    return OM_S_SUCCESS ;

  strcat( dyn_load_dir, "config/dload/" );
  strcat( dyn_load_dir, VDS_DLOAD_DIR );

  if (dirp = opendir (dyn_load_dir))
  {
    strcpy(dload_file, dyn_load_dir);
    strcat(dload_file, "/");
    nbytes = strlen(dload_file);

    while (dp = readdir(dirp))
    {
      len = strlen (dp->d_name);

#if defined(ENV5) || defined(IRIX4)

      if (len >= 2 && 'o' == *(dp->d_name + len-1) && '.' == *(dp->d_name + len-2))

#elif defined(X11) || defined (IRIX5)

      if (len >= 3 && 'o' == *(dp->d_name + len-1) && 's' == *(dp->d_name + len-2) && '.' == *(dp->d_name + len-3))

#else
#error dload files not specified for OS
#endif
      {
        strcpy(&dload_file[nbytes], dp->d_name);
        sprintf( status_mess, "Loading file : %s ", dload_file );
        UI_status( status_mess );
        ems_dload ( dload_file );
      }
    }
    closedir(dirp);
  }

  End ;
  return OM_S_SUCCESS ;
}

/*-------------------------------------------------------------------------
 Doc : VDprd_dload_files()

 Desc: This function dynamically loads all the files it finds in the
         directory, "/????/shared/config/dload/corrections/run_name", using
         ems_dload, provided "-S /????/shared" is included on command line.
       Option, "-S" can have several paths separated by a colon (:) but
         this code assumes the first path is intended as the fixes path.
       If no "-S" option included on command line, a product's config
         directory path is returned and is ignored.

       Called by /vds/vdppl/vd_shared.u.

       The VDS startup object is executed when STRUCT, ROUTE and LOFT are
         run, therefore, code to dynamically load fixes only needs to reside
         in this, the VDS startup object.

 History :
 ejm    10-17-98     Creation
--------------------------------------------------------------------------*/

VDprd_dload_files( IGRchar *prd_dload_path )
{
  long		status;
  char		status_mess[256],
		dload_file[256];
  int		len;
  DIR		*dirp;
  struct dirent	*dp;
  int		nbytes;

  SetProc( VDprd_dload_files ); Begin;

  __DBGpr_str("prd_dload_path", prd_dload_path);

  if (dirp = opendir (prd_dload_path))
  {
    strcpy(dload_file, prd_dload_path);
    strcat(dload_file, "/");
    nbytes = strlen(dload_file);

    /* Read directory contents */
    while (dp = readdir(dirp))
    {
      __DBGpr_str("  dp->d_name",   dp->d_name);
      len   = strlen (dp->d_name);

#if defined(ENV5) || defined(IRIX4)

      if (len >= 2 && 'o' == *(dp->d_name + len-1) && '.' == *(dp->d_name + len-2))

#elif defined(X11) || defined (IRIX5)

      if (len >= 3 && 'o' == *(dp->d_name + len-1) && 's' == *(dp->d_name + len-2) && '.' == *(dp->d_name + len-3))
#else
#error   dload files not specified for OS
#endif
      {
        strcpy(&dload_file[nbytes], dp->d_name);
        __DBGpr_str("dload_file", dload_file);
        sprintf( status_mess, "Loading fix: %s ", dload_file );
        UI_status( status_mess );
        ems_dload ( dload_file );
      }
    } /* while */
    closedir(dirp);
  } /* if (dirp) */
  else
    __DBGpr_str("Not found", prd_dload_path);

  End ;
  return OM_S_SUCCESS ;

} /* VDprd_dload_files */

/*----------------------------------------------------------------------------
method wakeup( int pos ) {
 long	msg;

	SetProc( VDStartup_wakeup ); Begin

	om$send ( msg = message super_cmd.wakeup ( pos ),
		  mode = OM_e_wrt_message,
		  targetid = my_id  );

	if( ! ( ex$is_batch() )){
		__DBGpr_com(" Calling SMAddToPocketMenu ");
		msg = SMAddToPocketMenu();
	}

	End ;
	return OM_S_SUCCESS ;
}
----------------------------------------------------------------------------*/

end implementation VDCmdStrtup ;
