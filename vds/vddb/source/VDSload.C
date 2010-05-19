/* $Id: VDSload.C,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSload.C
 *
 * Description:
 *	Main function - window/screen managment
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSload.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.5  1998/04/06  21:46:22  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by v250_int for vds
 *
 * Revision 1.4  1997/07/17  17:44:38  pinnacle
 * Fix for TR# 179701386 -- ap
 *
 * Revision 1.3  1997/07/16  19:17:18  pinnacle
 * (No comment)
 *
 * Revision 1.2  1997/07/16  19:14:00  pinnacle
 * ap -- Fix for CR# 179422209
 *
 * Revision 1.2  1997/01/30  23:57:54  pinnacle
 * ah CR179602053
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.22  1996/05/23  20:56:46  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by tlbriggs for vds.240
 *
 * Revision 1.21  1996/05/22  19:59:50  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by v240_int for vds.240
 *
 * Revision 1.20  1996/05/20  03:09:12  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by v240_int for vds.240
 *
 * Revision 1.19  1996/04/23  16:24:48  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by v240_int for vds.240
 *
 * Revision 1.18  1996/04/21  23:49:20  pinnacle
 * Replaced: vddb/source/*.C for:  by v240_int for vds.240
 *
 * Revision 1.17  1996/04/09  21:45:06  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by v240_int for vds.240
 *
 * Revision 1.16  1996/04/01  12:50:02  pinnacle
 * Replaced: vdris/imp/VdsRisTbl.C for:  by msbraju for vds.240
 *
 * Revision 1.15  1996/03/18  11:13:02  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by msbraju for vds.240
 *
 * Revision 1.14  1996/03/01  10:20:32  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by msbraju for vds.240
 *
 * Revision 1.13  1996/02/20  11:53:44  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by msbraju for vds.240
 *
 * Revision 1.12  1996/02/05  16:00:06  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by azuurhou for vds.240
 *
 * Revision 1.11  1996/02/05  15:44:50  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by azuurhou for vds.240
 *
 * Revision 1.10  1996/02/01  12:59:58  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by rgade for vds.240
 *
 * Revision 1.9  1996/01/31  16:17:46  pinnacle
 * Replaced: ./vddb/source/VDSload.C for:  by azuurhou for vds.240
 *
 * Revision 1.8  1996/01/31  11:51:46  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by ksundar for vds.240
 *
 * Revision 1.7  1996/01/30  21:04:10  pinnacle
 * Replaced: ./vddb/source/VDSload.C for:  by azuurhou for vds.240
 *
 * Revision 1.6  1996/01/30  11:37:02  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by ksundar for vds.240
 *
 * Revision 1.5  1996/01/19  14:55:38  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by azuurhou for vds.240
 *
 * Revision 1.4  1996/01/17  10:13:20  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by msbraju for vds.240
 *
 * Revision 1.3  1995/12/13  19:35:52  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by hverstee for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      10/20/93    Raju	Creation
 *	02/05/96    adz		Inform for multiple projects.
 *	04/08/96    tlb		Initialization/free problems
 *	04/10/96    tlb		Change to VDS memory allocation
 *				Add prototypes
 *				Fix init/free of path_list
 *				Change 'User' directory to 'Current Dir'
 *	04/23/96    tlb		Change units - screen cleared too early 
 *	04/25/96    tlb		Add comments, fix debug messages
 *				Fix invalid password loop
 *				Spelling error in error messages
 *				Move VdsErrMsg to VDSdbdbg.c
 *				Remove FreeUsedId, dynamic cleanup cases 
 *				Convert units - input fields had different
 *				   lengths, but filled based on max size
 *				Move all globals here
 *				Change path_list to simple arrray
 *				Allow select-all for delete catalog
 *				Move string routines to VDSdbstring.c
 *	05/21/96    tlb		Fix NFM error message init bug
 *      01/30/97    ah          CR179602053, CR179602017
 *                              Pick lists for catalogs,parts and projects
 *      07/14/97    ap          CR179422209
 *                              Added yes/no for "dangerous" operations
 *                              like deletion of tables/catalogs
 *	04/06/98    adz		TR179701295 for "DELETE ALL DATA".
 * -------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <curses.h>
#include <varargs.h>
#include <unistd.h>

#include "UMS.h"
#include "ERRerrordef.h"
#include "ERRproto.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "NFMUproto.h"
#include "VDSserver.h"
#include "VDSdberrdef.h"
#include "VDSdbmsg.h"
#include "VDBload.h"
#include "VDDbDef.h"
#include "vdbmacros.h"
#include "VDmem.h"

#include "v_risproto.h"
#include "v_dbloadprot.h"

/* 
 * VDSloaddata global variables 
 */
WINDOW  *VDBmsgwin;
char    VDBmsgstrs[8][81]; 
char	VDBtmps[81];		/* User prompt string */
char	VDBbuff[256];
long    VDBerrstat = 0;

long    VDSuser_id;		/* NFM user id */
char    VDBvds[81];		/* VDS product directory name */

int     VDSwarning_on;          /* to indicate if user wants to be warned
                                   of "dangerous" operations or not
                                */

/* 
 * VDS and PDU globals 
 */
char    g_environ[20];		/* PDM global - pdme* file name */
char    VDSenvir_name[20] = "";	/* VDS global - pdme* file name */


/* #define VDB_DEBUG 1 */
/* #define VDB_LOGIN_OPT 1 */

/* Location of nfm error message files */
#ifdef X11
#	define NFM_MSG	"/opt/ingr/pdu/config/english/messages"
#else
#	define NFM_MSG	"/usr/ip32/nfm/config/english/messages"
#endif

/* --------------------------------------------------------------------------
 *  Doc :  main
 * 
 *  Desc : This program is used for loading VDS tables, catalogs , parts.
 *  It is also used for other operations like updating VDS project etc.
 * 
 *  About windows created in this program :
 *  There are three types of windows.
 *   1. Select window : 
 *	   Window that can be used for displaying and selecting one or 
 *		    more entries. Eg. Main menu, catalog_list_win.
 *         	Function that make this window is VDBmake_select_win.
 * 
 *    2. Input window  : 
 *	    Window in which something is keyed. Eg. login window.
 *          	Function is VDBmake_input_win.
 *    
 *    3. Attribute window : 
 *	     to create, modify tables. 
 *	     	Function is VDBmake_attrib_menu.
 *    
 *  There are four kinds of window operations.
 *    1. Single select : 
 *	      One of the entries of select window is selected by the user.
 *                 Function is VDBmenu_select_oper.
 * 
 *    2. Multiple select : 
 *		One or more than entries of the window are selected.
 *                       Function is VDBmenu_multi_select_oper.
 *                       
 *    3. Input operations : 
 *		User keys in input in the fileds.
 *    		      Function is VDBmenu_input_oper.
 *    		     
 *    4. Attribute operations : 
 *		User keys in new attributes, datatypes, values etc.
 *                      Function is VDBattrib_win_oper.
 * 
 * --------------------------------------------------------------------------*/
main( 	int  argc,
	char *argv[]
	)
{
  long	sts;
  WINDOW  *mainwin = NULL, *tablewin = NULL, *catalogwin = NULL,
          *prodwin = NULL, *pathwin = NULL, *listwin = NULL,
          *userwin = NULL, *catwin2 = NULL, *partwin2 = NULL,
          *utilwin = NULL,
          *dyntblwin = NULL,   *creatdyntblwin = NULL, *regtblwin = NULL,
          *modiftblwin = NULL, *creatregtblwin = NULL,

          *adddatawin = NULL;

//WINDOW  *cvrtunitswin = NULL:
//WINDOW  *delpartwin   = NULL;

  int	  maxlen[VDB_MAXLENGTHS], selno[10], ii, i1;
  int	  noprodsel=0, listlen;
  int     state, prev_menu = 0;
  char    *strptrs[10];
  char    prodselflag[VDB_MAX_NO_PROD];
  char    (*fam_part_list)[81] = NULL;
  char    *listselflag = NULL;
  int     nofampart;
  char    usrname[16], usrpasswd[16], envname[16], debug[16], warning[16];
  int	  user_id;
  char    fampartflag = -1;

//char    catname[VDB_MAX_CATALOG_LEN], partno[VDB_MAX_CATALOG_LEN],
//        partrev[VDB_MAX_CATALOG_LEN];

  char    schema_name[20], schema_pwd[20];
  char    *prod_list[VDB_MAX_NO_PROD] =
          	{ "Current Dir", "VDS", "STRUCT", "ROUTE", "SMAN" };
  char    *path_list[VDB_MAX_NO_PROD] ;
  char 	  *pathptrs[VDB_MAX_NO_PROD] ;
  char    tablename[VDB_MAX_TABLE_LEN];
  char    yn;
  struct  VDBtable  *recs = NULL;             /* records in the table*/
  int     norecs;
  int     operation;

  char    dangerWarn[100];         /* added by AP -- CR# 179422209 */
                                  /* general purpose buffer for warning msg
                                     about "dangerous" operations such as
                                     deletion of tables
                                  */

/*
  char    ProjectName[VDB_PROJECT_NAME_LEN], 
          ProjectRev [VDB_PROJECT_NAME_LEN], 
          NewUnits   [VDB_PROJECT_NAME_LEN];
  int     count;
  char	  **prj_no_ver;
*/
  
  char    (*CatList)[81] = NULL;
  int     NumbCat, CatNamLen;
  char    *getenv ();

   
   /* Initialize product structures */
   for ( ii=0; ii<VDB_MAX_NO_PROD; ii++)  
	path_list[ii] = NULL;
   for ( ii=0; ii<VDB_MAXLENGTHS; ii++)  
	maxlen[ii] = 0;

#  ifndef VD_RUNTIME
   /*
    * Activate BS debug malloc routines if BLCKCHECK is defined
    */
    	if (getenv ( "BLCKCHECK" )) {
#		ifdef MEM
		   printf ("\nPoisoning memory and stack...\n");
#		endif
		_MEM_INIT;
		VD_memOpenFile ("/usr/tmp/vds_mem.dbg");
    	}
#   endif

   /* Try to initialize NFM error subsystem 
    *	if /usr/ip32/nfm/config not fount - it will fail, 
    *		parameter is apparently disregarded
    *   if fail - continue anyway 
    *		error messages will be less verbose
    */
   if ((sts = ERRinit_messages (NFM_MSG, UMS_MESSAGE)) != ERR_S_SUCCESS) {
	VDSdebug ("Error: NFM Error subsystem initialization failed: 0x%x\n", 
								sts);
	/* continue anyway; */
	}

#ifdef VDB_LOGIN_OPT
    printf("Enter login option[0/1/2] : "); scanf("%c", &VDBtmps[0] );
#endif


#ifdef X11
   putenv("TERM=xterm");
#else
   putenv("TERM=vt220");
#endif

   initscr();
   noecho();

   VDBmsgwin = newwin( 1, COLS, LINES-3, 0);
   leaveok( VDBmsgwin, TRUE );
   VDBmake_bar_win ();

#ifdef VDB_LOGIN_OPT
   if ( VDBtmps[0] == '0' ) goto step2;
   if ( VDBtmps[0] == '1' ){  
	strcpy(usrname,"sdmadmin"); strcpy(usrpasswd,"sdmadmin");
   	strcpy(envname,"tst_clix");  strcpy(debug,"y");
        strcpy(warning, "y");
   	goto step1;
	}
#endif

get_login:
   /* 15 = max. of username, passwd and environment name */
   maxlen[1] = 15;

   VDBinitialize_login_strs( usrname,usrpasswd,envname, debug, warning);

   sts = VDBmake_input_win( &userwin, 5, 5, &maxlen[0], &maxlen[1], 10+1,
		       " LOGIN ",
		       "Username",usrname,
		       "Password", usrpasswd,
		       "Environment",envname,
		       "Debug ?[y/n]",debug,
                       "Warn before deletion ?[y/n]", warning );

   strptrs[0] = usrname;
   strptrs[1] = usrpasswd;
   strptrs[2] = envname;
   strptrs[3] = debug;
   strptrs[4] = warning;
   sts = VDBuser_menu_oper ( &userwin, maxlen[1], VDB_FIRST_LINE,
			    VDB_FIRST_COL+maxlen[0]+VDB_GAP, 5, strptrs );
   VDB_DELETE_WIN ( userwin );
   if ( sts == VDB_EXIT ) { 
	ENDWIN;
     	goto wrapup;
   	}

   ENDWIN;

   VDBstore_login_strs( usrname, envname, debug, warning );

#ifdef VDB_LOGIN_OPT
step1:
#endif

   /* Store user login info */
   sts = VDSlogin ( usrname, usrpasswd, envname );
   if ( sts != VDS_S_SUCCESS ) {  
	VDBgetyesno ( "Login not successful. Continue [y/n] ? [y] ",&yn);
      	if ( yn == 'n' ) goto wrapup;
	else		 goto get_login;
   	}
   sts = VDSget_user_id( usrname, &user_id );
   if( sts != VDS_S_SUCCESS ) { 
	printf("Cannot get NFM User Id\n");
	VDSprintVdsErr("\t", "VDSget_user_id", sts);
	goto wrapup;
        }
   VDSuser_id = user_id;

/*
   ---  if debug[0] = 'y' or 'Y' make it 'y'. else make it 'n' ---
*/

   /* set debug toggle */
   if ( debug[0] == 'y' || debug[0] == 'Y' ) {
     debug[0] = 'y';
     VDSset_debug_on();
     VDSdebug_on = TRUE;
     VDSsqlDebug_on = TRUE;
     }
   else {
     debug[0] = 'n';
     VDSdebug_on = FALSE;
     VDSsqlDebug_on = FALSE;
     }

/* Similar code to above added by AP to take care of warning */
/* CR# 179422209 */

   /* set warning toggle */
   if ( warning[0] == 'y' || warning[0] == 'Y' ) {
     warning[0] = 'y';
     VDSwarning_on = TRUE;
   }
   else {
     warning[0] = 'n';
     VDSwarning_on = FALSE;
   }

/* end of code added by AP */


   /* Set PDU environment file name */
   sprintf ( g_environ, "pdme_%s", envname);
   sprintf ( VDSenvir_name, "pdme_%s", envname);


   if ( VdsExtractDecodedString ( TITLE_RIS_NAM, schema_name) == 0)
   { fprintf(stderr, "Error getting schema name\n");
     goto wrapup;
   }

   if ( VdsExtractDecodedString ( TITLE_RIS_PWD, schema_pwd) == 0)
   { fprintf(stderr, "Error getting schema password\n");
     goto wrapup;
   }

#ifdef VDB_LOGIN_OPT
step2:
#endif

   sts = VDBproductpath( "VDS", VDBvds );
   if ( sts == 0 ) /* could not get product path */
     VDBvds[0] = '\0';
      
   for(ii=0; ii<VDB_MAX_NO_PROD; ii++)
   {  path_list[ii] = _MALLOC( 81, char );
      _CheckAlloc ( path_list[ii], "path_list", sts, FALSE, wrapup);
      strcpy( path_list[ii], VDBvds );
   }
   strcpy( path_list[0], "." );
   strcat( path_list[1], "/data/equip" );
   strcat( path_list[2], "/data/struct" );
   strcat( path_list[3], "/data/piping" );
   strcat( path_list[4], "/data/sman" );

   state = VDB_MAIN_MENU;

main_switch :

/* reset NFM error subsystem */
ERRreset_struct();

switch ( state )
{
 /*---------------------- Main ---------------------------------------*/
 case VDB_MAIN_MENU :

# ifndef VD_RUNTIME
   VDBmem_CheckPtrs ();
   VDBmem_Status ("Main Menu");
# endif

   if ( ! mainwin )
   {  sts = VDBmake_select_win ( &mainwin, 2, 2, &maxlen[1], 1+4," MAIN MENU ",
				"VDS_SUPPORT_TABLES", "VDS_CATALOGS",
				"UTILITIES", "EXIT");
      selno[1] = 0;
   }
   else
     VDB_REFRESH_WIN ( mainwin );

   sts = VDBmain_menu_oper( &mainwin, maxlen[1], &selno[1] );

   if ( selno[1] == 0 ) state = VDB_TABLES_MENU;
   else if ( selno[1] == 1 ) state = VDB_CATALOGS_MENU;
   else if ( selno[1] == 2 ) state = VDB_UTILITIES_MENU;
   else state = VDB_MAIN_EXIT;
   break;

 /*---------------------- Main / Tables --------------------------------*/
 case VDB_TABLES_MENU :  

# ifndef VD_RUNTIME
   VDBmem_Status ("Tables Menu");
# endif

   if ( ! tablewin )
   {  sts =VDBmake_select_win ( &tablewin, 2, maxlen[1]+8, &maxlen[2], 1+4,
		     " VDS_TABLES ", "CREATE & LOAD", "LOAD", "DELETE", "EXIT");
      selno[2] = 0;
   }
   else
     VDB_REFRESH_WIN ( tablewin );

   sts = VDBtables_menu_oper( &tablewin, maxlen[2], &selno[2] );

   /* Exit */
   if ( selno[2] == 3 ) {  
	state = VDB_MAIN_MENU;
      	VDB_DELETE_WIN ( tablewin );
   }
   else
   {  char  tableoperflag, pathname[VDB_MAX_PATH_LEN],
            filename[VDB_MAX_PATH_LEN], filename2[VDB_MAX_PATH_LEN];

      if ( selno[2] == 0 ) 	tableoperflag = VDB_CREATE_TABLES;
      else if ( selno[2] == 1 ) tableoperflag = VDB_LOAD_TABLES;
      else 			tableoperflag = VDB_DELETE_TABLES;

      sts = VDBgetVdsTableFile ( tableoperflag, pathname, filename, filename2 );
      if ( sts == VDB_EXIT )  break;  /* user selected exit */

      /* Create and Load */
      if ( selno[2] == 0 ) {
	 VDSprintUsrMsg ("  ...Creating VDS Support Tables\n"); 
         sts = VDBexecRisFile ( pathname, filename );
         if( sts )
	 	sts = VDBloadVdsTable( pathname, filename2 );
         }
      /* Load */
      else if ( selno[2] == 1 ) {
	 VDSprintUsrMsg ("  ...Loading VDS Support Tables\n"); 
         sts = VDBloadVdsTable ( pathname, filename );
	 }

      /* Delete */
      else {

	 /* VDSprintUsrMsg ("  ...Deleting all VDS Support Tables\n"); */

         if( VDSwarning_on == TRUE ) {

            sprintf(dangerWarn, "Are you sure you want to delete all support tables ???[y/n] [y]");

            VDBgetyesno(dangerWarn, &yn);

            if( yn == 'n') {
                VDB_REFRESH_WIN ( tablewin );
                state = VDB_TABLES_MENU;
                break;
            }
          }

         sts = VDBexecRisFile ( pathname, filename );
      }

      VDB_DELETE_WIN ( tablewin );
      state = VDB_MAIN_MENU;
      if ( !sts )  {
   	 VDBgetyesno ( "Operation not successful. Continue [y/n] ? [y] ",&yn);
      	 if ( yn == 'n' ) goto wrapup;
	 }
   }
   break;

 /*---------------------- Main / Catalogs --------------------------------*/
 case VDB_CATALOGS_MENU:

# ifndef VD_RUNTIME
   VDBmem_Status ("Catalogs Menu");
# endif

   if ( ! catalogwin )
   {  sts = VDBmake_select_win ( &catalogwin, 2, maxlen[1]+8, &maxlen[2], 1+3,
			 " VDS_CATALOGS ", "CATALOGS", "PARTS", "EXIT");
      selno[2] = 0;
   }
   else
     VDB_REFRESH_WIN ( catalogwin );

   sts = VDBcatalog_menu_oper( &catalogwin, maxlen[2], &selno[2] );
   if ( selno[2] == 0 )
   {  fampartflag = VDB_FAM;
      state = VDB_CAT_MENU2;
   }
   else if ( selno[2] == 1 )
   {  fampartflag = VDB_PART;
      state = VDB_PART_MENU2;
   }
   else if ( selno[2] == 2 )
   {  VDB_DELETE_WIN ( catalogwin );
      state = VDB_MAIN_MENU;
   }
   break;

 /*---------------------- Main / Utitilies --------------------------------*/
 case VDB_UTILITIES_MENU:

# ifndef VD_RUNTIME
   VDBmem_Status ("Utilities Menu");
# endif

   if ( ! utilwin )
   {  sts = VDBmake_select_win( &utilwin, 2, maxlen[1]+8, &maxlen[14],
				5+1, " UTILITIES ", "UPDATE DATABASE",
				"SET PROJECT UNITS", "DYNAMIC TABLES",
			        "REGULAR TABLES", "EXIT" );

      selno[5] = 0;
   }
   else
      VDB_REFRESH_WIN ( utilwin );

   sts = VDButil_menu_oper( &utilwin, maxlen[14], &selno[5], &state );

   break;


 /*---------------------- Main / Catalog / Catalog ---------------------------*/
 case VDB_CAT_MENU2:
   if ( ! catwin2 )
   {  sts = VDBmake_select_win( &catwin2, 2, maxlen[1]+maxlen[2]+14, &maxlen[3],
			        5+1, " CATALOGS ", "CREATE", "DELETE", 
			        "GENERATE FAMILY FILE", "LIST", "EXIT");
      selno[3] = 0;
   }
   else
     VDB_REFRESH_WIN ( catwin2 );

   sts = VDBcat2_menu_oper( &catwin2, maxlen[3], &selno[3] );

        if ( selno[3] == 0 ) state = VDB_PROD_MENU;
   else if ( selno[3] == 1 ) state = VDB_DELCAT_MENU;
   else if ( selno[3] == 2 ) state = VDB_GENFAM_MENU;
   else if ( selno[3] == 3 ) state = VDB_CAT_LIST;
   else 
   {  VDB_DELETE_WIN ( catwin2 );
      state = VDB_CATALOGS_MENU;
   }
 break;

 /*---------------------- Main / Catalog / Part ---------------------------*/
 case VDB_PART_MENU2:
   if ( ! partwin2 )
   {  sts = VDBmake_select_win ( &partwin2, 2, maxlen[1]+maxlen[2]+14,&maxlen[3],
				 1+5, " PARTS ", "ADD", "DELETE",
				 "GENERATE PART FILE", "LIST", "EXIT");
      selno[3] = 0;
   }
   else
     VDB_REFRESH_WIN ( partwin2 );

   sts = VDBcat2_menu_oper( &partwin2, maxlen[3], &selno[3] );

        if ( selno[3] == 0 ) state = VDB_PROD_MENU;
   else if ( selno[3] == 1 ) state = VDB_DELPART_MENU;
   else if ( selno[3] == 2 ) state = VDB_GENPART_MENU;
   else if ( selno[3] == 3 ) state = VDB_PART_LIST;
   else 
   {  VDB_DELETE_WIN ( partwin2 );
      state = VDB_CATALOGS_MENU;
   }
   break;

 case VDB_CAT_LIST:
 case VDB_PART_LIST:
 case VDB_DELPART_MENU:
  VDBCatPartList(&state,mainwin,catalogwin,partwin2);
 break;

 /*---------------------- Products Submenu ------------*/
 /*---------------------- Main / Catalog / Part / Add / Products ------------*/
 /*---------------------- Main / Catalog / Part / Create / Products ----------*/
 case VDB_PROD_MENU:
   if ( VDB_MAX_NO_PROD > 5 )
   {  VDSdebug( "Max. no. of prodcuts > 5. Modify the call\n" );
      VDBerrstat = 1;
      goto wrapup;
   }
   if ( ! prodwin )
     sts = VDBmake_select_win ( &prodwin, 11, 2, &maxlen[6], VDB_MAX_NO_PROD+1,
			 " PRODUCTS ", prod_list[0], prod_list[1],
			 prod_list[2], prod_list[3], prod_list[4]  );
 
   else
     VDB_REFRESH_WIN ( prodwin );

   sts = VDBprod_menu_oper( &prodwin, maxlen[6], prod_list, prodselflag );
   state = VDB_CATALOGS_MENU;
   noprodsel = 0;
   for( ii=0; ii<VDB_PROD_MENU_STRS; ii++)
      if ( prodselflag[ii] )
      {  strptrs[noprodsel*2]   = prod_list[ii];
         strptrs[noprodsel*2+1] = path_list[ii];
         noprodsel++;
      }

   if ((noprodsel == 0) || (sts == VDB_EXIT)) {  
    	if ( fampartflag == VDB_FAM )
         	state = VDB_CAT_MENU2;
      	else
         	state = VDB_PART_MENU2;
   	}
   else
      	state = VDB_PATH_MENU;

   /* refesh bar menu - 
    *	All other submenus have only 2 items
    */
   VDBrefresh_bar_menu();
   VDB_DELETE_WIN ( prodwin );
   break;

 /*---------------------- Path Submenu ----------*/
 /*---------------------- Main / Catalog / Create / Products / Path ----------*/
 case VDB_PATH_MENU:
   /* following statement is redundant, only extra caution */
   if ( noprodsel > VDB_MAX_NO_PROD ) noprodsel = VDB_MAX_NO_PROD;
   maxlen[8] = VDB_MAX_PATH_LEN-1;
   if ( ! pathwin )
     sts = VDBmake_input_win ( &pathwin, 11, 2, &maxlen[7], &maxlen[8],
			        noprodsel*2+1,
			        "PATHS",
			        strptrs[0], strptrs[1],
			        strptrs[2], strptrs[3],
			        strptrs[4], strptrs[5],
			        strptrs[6], strptrs[7],
			        strptrs[8], strptrs[9]);

   else
     VDB_REFRESH_WIN ( pathwin );

   i1=0;
   for( ii=0; ii<VDB_PROD_MENU_STRS; ii++)
      if ( prodselflag[ii] )
        pathptrs[i1++]   = path_list[ii];

   sts = VDBpath_menu_oper ( &pathwin, maxlen[8], VDB_FIRST_LINE,
			    VDB_FIRST_COL+maxlen[7]+VDB_GAP, noprodsel, pathptrs );

   if ( sts == VDB_PROCESS )
    state = VDB_CAT_PART_LIST_MENU; 
   else
     state = VDB_PROD_MENU;
   VDB_DELETE_WIN ( pathwin );
   break;

 /*---------------------- Main / Catalog / Part / Part List  ---------------*/
 case VDB_CAT_PART_LIST_MENU:
   if ( fampartflag == VDB_FAM )
      strcpy ( VDBtmps, "Getting list of catalogs ..." );
   else
      strcpy ( VDBtmps, "Getting list of parts ..." );
   VDBpadstr( VDBtmps, 81, ' ' );
   mvwaddstr ( VDBmsgwin, 0, 0, VDBtmps );
   wrefresh ( VDBmsgwin );
   sts = VDBgetfampartlist ( path_list, VDB_MAX_NO_PROD, prodselflag, fampartflag,
			    &fam_part_list, &nofampart );
   if ( !sts ) 
   {  VDBgetyesno (
	"Error getting list of catalogs/parts. Continue[y/n] ? [y] ",&yn);
      if ( yn == 'y' )
	state = VDB_PATH_MENU;
      else
	state = VDB_MAIN_EXIT;	
      break;
   }

   if ( nofampart == 0 )
   {  VDBgetyesno ( 
	"Error getting list of catalogs/parts. Continue[y/n] ? [y] ",&yn);
      if ( yn == 'y' )
	state = VDB_PATH_MENU;
      else
	/* state = VDB_MAIN_EXIT; */	
        state = VDB_CAT_MENU2;
      break;
   }

   maxlen[9] = VDB_MAX_FILE_LEN-1;
   listlen = MIN( nofampart, 6 );
   if ( fampartflag == VDB_FAM )
      strcpy ( VDBtmps, "FAMILY FILES" );
   else
     strcpy ( VDBtmps, "PART FILES" );
   if ( ! listwin )
     sts = VDBmake_select_win ( &listwin, 11, 2, &maxlen[9],
			        listlen+1,
			        VDBtmps,
			        fam_part_list[0],fam_part_list[1],
                                fam_part_list[2],fam_part_list[3],
			        fam_part_list[4],fam_part_list[5] );
   else
     VDB_REFRESH_WIN ( listwin );

   _FREE (listselflag);

   listselflag = _MALLOC ( nofampart, char );
   _CheckAlloc ( listselflag, "listselflag", sts, FALSE, wrapup);

   sts = VDBlist_menu_oper ( &listwin, maxlen[9], VDB_FIRST_LINE, VDB_FIRST_COL,
		     nofampart, listlen, fampartflag, fam_part_list, TRUE,
		     listselflag );

   VDB_DELETE_WIN ( listwin );

   if ( sts == VDB_PROCESS )
   { if ( fampartflag == VDB_FAM ) {
        sts = VDBcreatcat( schema_name, schema_pwd, fam_part_list, 
			   			nofampart, listselflag );
     }
     else {
        sts = VDBAddPart( fam_part_list, nofampart, listselflag, schema_name,
			  				schema_pwd );
	if( !sts ) {
	  VDB_GET_RETURN;
	  ENDWIN;
	}
     }

     _FREE(fam_part_list);

     if ( sts )  state = VDB_MAIN_MENU;
     else        state = VDB_MAIN_EXIT;	
   }
   else  /* exit */
   { if  ( fampartflag == VDB_FAM )
       state = VDB_CAT_MENU2;
     else
       state = VDB_PART_MENU2;
   }
   break;

 /*---------------------- Main / Catalog / Catalog/  Delete -------------*/
 case VDB_DELCAT_MENU :
   sts = VdbGetCatalogs( &CatList, &NumbCat );

   if( NumbCat == 0 )
   {
     VDBgetyesno( "Error getting list of catalogs/parts. Continue[y/n] ? [y] ",
		  &yn );

     if( yn == 'y' )
      state = VDB_CAT_MENU2;
     else
      state = VDB_MAIN_EXIT;

     break;
   }

   CatNamLen = VDB_MAX_CATALOG_LEN;
   listlen = MIN( NumbCat, 6 );

   if( !listwin )
    sts = VDBmake_select_win( &listwin, 11, 2, &CatNamLen,
                              listlen+1, "CATALOGS",
                              CatList[0], CatList[1], CatList[2],
                              CatList[3], CatList[4], CatList[5] );
   else
     VDB_REFRESH_WIN( listwin );

   _FREE(listselflag);

   listselflag = _MALLOC( NumbCat, char );
   _CheckAlloc ( listselflag, "listselflag", sts, FALSE, wrapup);

   sts = VDBlist_menu_oper( &listwin, CatNamLen, VDB_FIRST_LINE, VDB_FIRST_COL,
                            NumbCat, listlen, VDB_FAM, CatList, TRUE,
			    listselflag );

   VDB_DELETE_WIN( listwin );

   if ( sts == VDB_PROCESS )
   {
     if( VDSwarning_on == TRUE ) {

            sprintf(dangerWarn, "Catalog(s) and all data contained will be deleted !! Continue ?[y/n] [y]");

            VDBgetyesno(dangerWarn, &yn);

            if( yn == 'n') {
                VDB_REFRESH_WIN ( catwin2 );
                state = VDB_CAT_MENU2;
                VDBrefresh_bar_menu();
                break;
            }
     }

     sts = VdbDelCatalogs( CatList, NumbCat, listselflag );

     _FREE(CatList);

     if( sts )
      state = VDB_MAIN_MENU;
     else
      goto wrapup;
   }
   else
    state = VDB_CAT_MENU2;

   /* refesh bar menu - 
    *	All other submenus have only 2 items
    */
   VDBrefresh_bar_menu();
   break;

 /*---------------------- Main / Catalog / Gen Fam -------------*/
 /*-------------------------------------------------------------*/
 case VDB_GENFAM_MENU :
 case VDB_GENPART_MENU :

  sts = VdbGetCatalogs( &CatList, &NumbCat );

  if( NumbCat == 0 )
  {
    VDBgetyesno( "Error getting list of catalogs/parts. Continue[y/n] ? [y] ",
		  &yn );

    if( yn == 'y' ) {
      if ( fampartflag == VDB_FAM ) state = VDB_CAT_MENU2;
      else                          state = VDB_PART_MENU2;
    }
    else {
      state = VDB_MAIN_EXIT;
    }

    break;
  }

  CatNamLen = VDB_MAX_CATALOG_LEN;
  listlen = MIN( NumbCat, 6 );

  if( !listwin ) {
    sts = VDBmake_select_win( &listwin, 11, 2, &CatNamLen,
                              listlen+1, "CATALOGS",
                              CatList[0], CatList[1], CatList[2],
                              CatList[3], CatList[4], CatList[5] );
  }
  else {
    VDB_REFRESH_WIN( listwin );
  }

  _FREE(listselflag);

  listselflag = _MALLOC( NumbCat, char );
  _CheckAlloc ( listselflag, "listselflag", sts, FALSE, wrapup);

  sts = VDBlist_menu_oper( &listwin, CatNamLen, VDB_FIRST_LINE, VDB_FIRST_COL,
                            NumbCat, listlen, VDB_FAM, CatList, TRUE,
			    listselflag );

  VDB_DELETE_WIN( listwin );

  if ( sts == VDB_PROCESS )
  {
    sts = VDBGenFamilyorPartList( CatList, NumbCat, listselflag,
                              fampartflag, schema_name,
  	                      schema_pwd, debug[0] );

    _FREE(CatList);

    if( sts ) {
      state = VDB_MAIN_MENU;
    }
    else {
      goto wrapup;
    }
  }
  else {
    if ( fampartflag == VDB_FAM ) state = VDB_CAT_MENU2;
    else                          state = VDB_PART_MENU2;
  }

  /* refesh bar menu - 
   *	All other submenus have only 2 items
   */
  VDBrefresh_bar_menu();
  break;

#ifdef OLD_GET_CAT
/* ================================== */
   sts = VDBgetCatalogName( VDB_OLD_CATALOG, catname );
 
   if ( sts == VDB_EXIT )               /* user selected exit */
   {  if ( fampartflag == VDB_FAM )
         state = VDB_CAT_MENU2;
      else
         state = VDB_PART_MENU2;
      break;
   }

   sts = VDBGenFamilyorPart( catname, fampartflag, schema_name,
		             schema_pwd, debug[0] );
   if ( sts ) state = VDB_MAIN_MENU;
   else goto wrapup;   /* error during operation */
   break;
#endif

 /*---------------------- Main / Catalog / Part / Delete -------------*/
#ifdef OLD_VDB_DELPART_MENU
 case VDB_DELPART_MENU :

   maxlen[13] = VDB_MAX_CATALOG_LEN-1;
   if ( ! delpartwin )
     sts = VDBmake_input_win ( &delpartwin, 11, 2, &maxlen[12], &maxlen[13],
			        6+1, " DELETE PART ", "Catalog name", "",
			        "Part Number", "all", "Part revision", "all");
   else
     VDB_REFRESH_WIN ( delpartwin );

   strptrs[0] = catname;
   strptrs[1] = partno;
   strptrs[2] = partrev;
   sts = VDBdelpart_menu_oper ( &delpartwin, maxlen[13], VDB_FIRST_LINE,
		     VDB_FIRST_COL+maxlen[12]+VDB_GAP, 3, strptrs );
   VDB_DELETE_WIN ( delpartwin );

   if ( sts == VDB_PROCESS )
   { sts = VDBdeleteparts ( catname, partno, partrev );
     if ( sts )  state = VDB_MAIN_MENU;  /* success */
     else  goto wrapup;			 /* error during opearation */
   }
   else
     state = VDB_PART_MENU2;
   break;
#endif

 /*-------------------------------------------------------------*/
 case VDB_EDIT_TBL:
   state = VDB_UTILITIES_MENU;
   break;

 /*---------------------- Main / Utilities / Set Project Units  -------------*/
 case VDB_CONVERT_UNITS_MENU:

   VDBProjData(&state,mainwin);
   break;

#ifdef XXX_CR_179602053
   maxlen[20] = VDB_PROJECT_NAME_LEN - 1;

  /*
   * Display the prj_number and prj_version of first table.
   * TR#179600097--Ravi
   * The first project will be set as default and a warning message will
   * printed when more project are available.
   */
   vdb$RisSelect(  select      = "prj_number, prj_version",
                   table_name  = "VDS_PROJECT",
                   numselect   = 2,
                   p_numrows   = &count,
                   p_buffer    = &prj_no_ver );

   if ( count == 0 ) {
             VDB_DISP_PADED_MSG ( "Can not get project information" );
             state = VDB_UTILITIES_MENU;
             break;
      	     }

   if ( count > 1 ) {
	char prjBuf[400];
	char prjTmp[200];
	
	strcpy( prjBuf, "Valid projects: ");
	sprintf( prjTmp, "%s ver. %s", prj_no_ver[0], prj_no_ver[1] );
	strcat( prjBuf, prjTmp );

	for( ii=1 ; ii<count ; ii++ ){
	  strcat( prjBuf, ", " );
	  sprintf( prjTmp, "%s/%s", prj_no_ver[ii*2], prj_no_ver[ii*2+1] );
	  strcat( prjBuf, prjTmp );
	}

	/* Display valid projects on prompt line 
	 *	This should be replaced by a form showing valid projects
	 */
	VDB_DISP_PADED_MSG ( prjBuf );
        VDB_GET_RETURN;
      }

   strcpy( ProjectName, prj_no_ver[0] );
   strcpy( ProjectRev,  prj_no_ver[1] );
   vdb$RisFreeBuffer ( buffer = prj_no_ver, size = 2*count );

   /* Force recreation of window based on parameters from database 
    *	not the last values entered by the user
    */
   sts = VDBmake_input_win ( &cvrtunitswin, 11, 2, &maxlen[19], &maxlen[20],
                              6+1, " SET PROJECT UNITS ", "Project Name",
                              ProjectName, "Project Revision", ProjectRev,
                                "Units[METRIC/IMPERIAL]", "IMPERIAL");
   strptrs[0] = ProjectName;
   strptrs[1] = ProjectRev;
   strptrs[2] = NewUnits;
   sts = VDBcvrt_menu_oper ( &cvrtunitswin, maxlen[20], VDB_FIRST_LINE,
			   VDB_FIRST_COL+maxlen[19]+VDB_GAP, 3, strptrs );
   
   if ( sts == VDB_EXIT ) /* user selected exit */
   { VDB_DELETE_WIN ( cvrtunitswin );
     state = VDB_UTILITIES_MENU;
     break;
   }

   sts = VDBconvertUnits ( ProjectName, ProjectRev, NewUnits );
   if ( sts ) state = VDB_MAIN_MENU;
   else  goto wrapup;    /* error during operation */

   break;

#endif

 /*---------------------- Main / Utilities / Dynamic Tables -------------*/
 case VDB_DYN_TBL_MENU:
   if ( ! dyntblwin )
   {  
/**** "freeze" -- fix for TR# 179701386. No cleanup option reqd. in VDSloaddata
#ifdef CLEANUP
	sts = VDBmake_select_win ( &dyntblwin, 2, maxlen[1]+maxlen[14]+14,
				 &maxlen[15], 4+1, " DYNAMIC TABLES ", "CREATE",
				 "MODIFY", "CLEANUP", "EXIT" );
#else
	sts = VDBmake_select_win ( &dyntblwin, 2, maxlen[1]+maxlen[14]+14,
				 &maxlen[15], 3+1, " DYNAMIC TABLES ", "CREATE",
				 "MODIFY", "EXIT" );
      selno[5] = 0;
#endif
      selno[6] = 0;
************************* end "freeze"************************/

	sts = VDBmake_select_win ( &dyntblwin, 2, maxlen[1]+maxlen[14]+14,
				 &maxlen[15], 3+1, " DYNAMIC TABLES ", "CREATE",
				 "MODIFY", "EXIT" );
      selno[5] = 0;
      selno[6] = 0;
   }
   else
     VDB_REFRESH_WIN ( dyntblwin );

   sts = VDBdyntbl_menu_oper( &dyntblwin, maxlen[15], &selno[6], &state );
   break;

 /*---------------------- Main / Utilities / Dynamic Tables / Create ---------*/
 case VDB_CREATE_DYN_TBL:

   sts = VDBgetTableName( tablename , VDB_NEW_TABLE );
   if ( sts == VDB_EXIT )  /* user selected exit */
   {  VDB_REFRESH_WIN ( utilwin );
      state = VDB_DYN_TBL_MENU;
      break;
   }

   VDB_DELETE_WIN ( dyntblwin );

   norecs = 25;
   recs = _CALLOC (norecs, struct VDBtable) ;
   _CheckAlloc ( recs, "recs", sts, FALSE, wrapup);

   sts = VDBcreatTableOption ( &norecs, &recs );

   maxlen[17] = VDB_MAX_ATTRIB_LEN-1;
   maxlen[18] = VDB_MAX_DTYPE_LEN-1;
   if ( ! creatdyntblwin )
   {  sts = VDBmake_attrib_win ( &creatdyntblwin, 2, maxlen[1]+8, &maxlen[17],
			        &maxlen[18], VDB_TABLE_ROWS,
			        " NAME", tablename, "    ATTRIBUTE",
			        "    DATATYPE" );
      selno[7] = 0;
   }
   else
     VDB_REFRESH_WIN ( creatdyntblwin );


   sts = VDBcreatdyntbl_menu_oper( creatdyntblwin, maxlen[17], maxlen[18],
				  VDB_TABLE_ROWS, &norecs, &recs );

   if ( sts == VDB_EXIT )
   {   VDB_DELETE_WIN ( creatdyntblwin );
       VDB_REFRESH_WIN ( mainwin );
       VDB_REFRESH_WIN ( utilwin );
       _FREE (recs);
       state = VDB_DYN_TBL_MENU;
       break;
   }

   operation = VDS_CREATE_TABLE;
   sts = VDBmanipTable ( tablename, norecs, recs, operation );
   _FREE (recs);
   if ( !sts )	goto wrapup;

   state = VDB_MAIN_MENU;
   break;

 /*---------------------- Main / Utilities / Dynamic Tables / Modify ---------*/
 /*---------------------- Main / Tables / Regular Tables / Modify ---------*/
 case VDB_MODIFY_DYN_TBL:
   prev_menu = 1;
   /* fall through */
 case VDB_MODIFY_REG_TBL:
   sts = VDBgetTableName( tablename, VDB_OLD_TABLE );
/* delete irrespective of the return status */
   if ( dyntblwin ) VDB_DELETE_WIN ( dyntblwin );
   if ( regtblwin ) VDB_DELETE_WIN ( regtblwin );

   if ( sts == VDB_EXIT )
   {  VDB_REFRESH_WIN ( mainwin )
      VDB_REFRESH_WIN ( utilwin );
      state = prev_menu ? VDB_DYN_TBL_MENU : VDB_REG_TBL_MENU ;
      prev_menu = 0;
      break;
   }
   
   maxlen[17] = VDB_MAX_ATTRIB_LEN-1;
   maxlen[18] = VDB_MAX_DTYPE_LEN-1;
   if ( ! modiftblwin )
   {  sts = VDBmake_attrib_win ( &modiftblwin, 2, maxlen[1]+8, &maxlen[17],
			        &maxlen[18], VDB_TABLE_ROWS,
			        " NAME", tablename, "    ATTRIBUTE",
			        "    DATATYPE" );
      selno[7] = 0;
   }
   else
     VDB_REFRESH_WIN ( modiftblwin );

   norecs = 25;
   recs = _CALLOC (norecs, struct VDBtable);
   _CheckAlloc ( recs, "recs", sts, FALSE, wrapup);

   sts = VDBmodiftbl_menu_oper( modiftblwin, maxlen[17], maxlen[18],
				  VDB_TABLE_ROWS, tablename,
				  &norecs, &recs );

   if ( sts == VDB_EXIT )
   {   	VDB_DELETE_WIN ( modiftblwin );
       	VDB_REFRESH_WIN ( mainwin );
       	VDB_REFRESH_WIN ( utilwin );
   	_FREE (recs);
      	state = prev_menu ? VDB_DYN_TBL_MENU : VDB_REG_TBL_MENU ;
 	prev_menu = 0;
       	break;
   }

   operation = VDS_MODIFY_TABLE;
   sts = VDBmanipTable ( tablename, norecs, recs, operation );
   _FREE (recs);
   if ( !sts )  goto wrapup;

   state = VDB_MAIN_MENU;
   prev_menu = 0;
   break;

/**** "freeze" - fix for TR# 179701386 -- No cleanup reqd. for VDSloaddata
#ifdef CLEANUP
 ------------------- Main / Utilities / Dynamic Tables / Cleanup ------
 case VDB_CLEANUP_DYN_TBL:
   state = VDB_DYN_TBL_MENU;
   break;
#endif CLEANUP
********************************* end "freeze" *************/

 /*------------------- Main / Utilities / Regular Tables ------*/
 case VDB_REG_TBL_MENU:
   if ( ! regtblwin )
   {  sts = VDBmake_select_win ( &regtblwin, 2, maxlen[1]+maxlen[14]+14,
				 &maxlen[21], 6+1, " REGULAR TABLES ", "CREATE",
		      "MODIFY", "DELETE ALL DATA", "DROP TABLE", "ADD DATA", "EXIT" );
      selno[6] = 0;
   }
   else
     VDB_REFRESH_WIN ( regtblwin );

   sts = VDBregtbl_menu_oper( &regtblwin, maxlen[21], &selno[6], &state );
   break;

 /*------------------- Main / Utilities / Regular Tables / Create  ------*/
 case VDB_CREATE_REG_TBL:

   sts = VDBgetTableName( tablename , VDB_NEW_TABLE );
   if ( sts == VDB_EXIT )  /* user selected exit */
   {  VDB_REFRESH_WIN ( utilwin );
      state = VDB_REG_TBL_MENU;
      break;
   }

   VDB_DELETE_WIN ( regtblwin );
   maxlen[17] = VDB_MAX_ATTRIB_LEN-1;
   maxlen[18] = VDB_MAX_DTYPE_LEN-1;
   if ( ! creatregtblwin )
   {  sts = VDBmake_attrib_win ( &creatregtblwin, 2, maxlen[1]+8, &maxlen[17],
			        &maxlen[18], VDB_TABLE_ROWS,
			        " NAME", tablename, "    ATTRIBUTE",
			        "    DATATYPE" );
      selno[7] = 0;
   }
   else
     VDB_REFRESH_WIN ( creatregtblwin );

   norecs = 25;
   recs = _CALLOC (norecs, struct VDBtable );
   _CheckAlloc ( recs, "recs", sts, FALSE, wrapup);

   sts = VDBcreatregtbl_menu_oper( creatregtblwin, maxlen[17], maxlen[18],
				  VDB_TABLE_ROWS, &norecs, &recs );

   if ( sts == VDB_EXIT )
   {   VDB_DELETE_WIN ( creatregtblwin );
       VDB_REFRESH_WIN ( mainwin );
       VDB_REFRESH_WIN ( utilwin );
       _FREE (recs);
       state = VDB_REG_TBL_MENU;
       break;
   }

   operation = VDS_CREATE_TABLE;
   sts = VDBmanipTable ( tablename, norecs, recs, operation );
   _FREE (recs);
   if ( !sts ) goto wrapup;

   state = VDB_MAIN_MENU;
   break;

 /*------------------- Main / Utilities / Regular Tables / Delete Data  ------*/
 case VDB_DELETE_DATA:
   sts = VDBgetTableName( tablename , VDB_OLD_TABLE);
   if ( sts == VDB_EXIT )  /* user selected exit */
   {  VDB_REFRESH_WIN ( utilwin );
      state = VDB_REG_TBL_MENU;
      break;
   }

   if( VDSwarning_on == TRUE ) {

        sprintf(dangerWarn, "All data in table '%s' will be deleted !! Continue ?[y/n] [y]", tablename);

        VDBgetyesno(dangerWarn, &yn);

        if( yn == 'n') {
            VDB_REFRESH_WIN ( utilwin );
            state = VDB_REG_TBL_MENU;
            break;
        }
   }
   
   sts = VDBdeleteTableData ( tablename ); /* common deletion action, */
                                          /* whether VDSwarning_on is FALSE Or
                                             user keys in 'y'           */
   if ( !sts ) goto wrapup;

   state = VDB_MAIN_MENU;
   break;
 
 /*------------------- Main / Utilities / Regular Tables / Drop Table------*/
 case VDB_DROP_TABLE:
   sts = VDBgetTableName( tablename, VDB_OLD_TABLE );
   if ( sts == VDB_EXIT )  /* user selected exit */
   {  VDB_REFRESH_WIN ( utilwin );
      state = VDB_REG_TBL_MENU;
      break;
   }

   if( VDSwarning_on == TRUE ) {

        sprintf(dangerWarn, "Table '%s' and all data in it will be deleted !! Continue ?[y/n] [y]", tablename);

        VDBgetyesno(dangerWarn, &yn);

        if( yn == 'n') {
            VDB_REFRESH_WIN ( utilwin );
            state = VDB_REG_TBL_MENU;
            break;
        }
   }

   operation = VDS_DROP_TABLE;
   norecs = 0;
   sts = VDBmanipTable ( tablename, norecs, NULL, operation );
   if ( !sts ) goto wrapup;

   state = VDB_MAIN_MENU;
   break;


 /*------------------- Main / Utilities / Regular Tables / Add Data------*/
 case VDB_ADD_DATA:
   sts = VDBgetTableName( tablename, VDB_OLD_TABLE );
   if ( sts == VDB_EXIT )			/* user selected exit */
   {  VDB_REFRESH_WIN ( utilwin );
      state = VDB_REG_TBL_MENU;
      break;
   }

   VDB_DELETE_WIN ( regtblwin );

   maxlen[17] = VDB_MAX_ATTRIB_LEN-1;
   maxlen[18] = VDB_MAX_DVAL_LEN-1;
   if ( ! adddatawin )
   {  sts = VDBmake_attrib_win ( &adddatawin, 2, maxlen[1]+8, &maxlen[17],
			        &maxlen[18], VDB_TABLE_ROWS,
			        " NAME", tablename, "    ATTRIBUTE",
			        "  DATA VALUE" );
      selno[7] = 0;
   }
   else
     VDB_REFRESH_WIN ( adddatawin );

   sts = VDBadddata_menu_oper( adddatawin, maxlen[17], maxlen[18],
				  VDB_TABLE_ROWS, tablename, &norecs, &recs );

   if ( sts == VDB_PROCESS )
   {
     sts = VDBInsertRows ( tablename, norecs, recs );

     _FREE (recs);
     if ( !sts ) goto wrapup;
   }

   VDB_DELETE_WIN ( adddatawin );
   VDB_REFRESH_WIN ( utilwin );
   state = VDB_REG_TBL_MENU;
   break;

 }   /*** end switch ***/

   if ( state != VDB_MAIN_EXIT )  goto main_switch;

wrapup:
   ENDWIN;
   sts = NFMlogoff ();
   if ( sts == NFM_S_SUCCESS )
	VDSdebug("Successful Logout\n");
   else 
	VDSdebug("Unsuccessful Logout\n");

   /* Free static array */
   for ( ii=0; ii<VDB_MAX_NO_PROD; ii++)  
	_FREE (path_list[ii]);

   _FREE (fam_part_list);
   _FREE (listselflag);
   _FREE (recs);
   _FREE (CatList);

   if ( VDBerrstat == 1 )
   {  fprintf( stderr, "Error during the VDSloaddata operations\n" );
      system("cat /usr/tmp/VDBload.out");
   }

#ifndef VDB_DEBUG
   remove("/usr/tmp/VDBload.out");
#endif

#ifndef VD_RUNTIME
    VD_memCloseFile ();
#endif
   return VDBerrstat;
} /* end main */

/*----------------------------------------------------------------------*/
void
VDBmem_CheckPtrs()
{
#ifdef MEM
   	ENDWIN;
 	BSchkmemo();
        VDB_GET_RETURN;
#endif
}
/*----------------------------------------------------------------------*/
void
VDBmem_Status (char * name)
{
   VD_memFStatus (name);
   VD_memPrintPtrs ();        
}

int VDBCatPartList(int* state, WINDOW* mainwin, WINDOW* catalogwin, WINDOW* partwin2)
{
  int sts,statex;

  char  (*CatList)[81] = NULL;
  int     NumbCat, CatNamLen, CatListLen;
  char    CatName[128];

  WINDOW *CatListWin = NULL;

  char *CatListFlag = NULL;
  char  yn;

  int ii;

  char  (*PartList)[81] = NULL;
  int     NumbPart, PartNamLen, PartListLen;

  WINDOW *PartListWin = NULL;

  char *PartListFlag = NULL;

  switch(*state) {
    case VDB_CAT_LIST:     statex = VDB_CAT_MENU2;  break;
    case VDB_PART_LIST:    statex = VDB_PART_MENU2; break;
    case VDB_DELPART_MENU: statex = VDB_PART_MENU2; break;
    default:               statex = VDB_MAIN_MENU;
  }

  sts = VdbGetCatalogs( &CatList, &NumbCat );

  if( NumbCat == 0 )
  {
    VDBgetyesno( "Error getting list of catalogs. Continue[y/n] ? [y] ",
		  &yn );

    if( yn == 'y' ) *state = statex;
    else            *state = VDB_MAIN_EXIT;
    return 1;
  }

  CatNamLen = VDB_MAX_CATALOG_LEN;
  CatListLen = MIN( NumbCat, 6 );

  sts = VDBmake_select_win( &CatListWin, 11, 2, &CatNamLen,
                             CatListLen+1, "CATALOGS",
                             CatList[0], CatList[1], CatList[2],
                             CatList[3], CatList[4], CatList[5] );

   CatListFlag = _MALLOC( NumbCat, char );
   _CheckAlloc ( CatListFlag, "CatListFlag", sts, FALSE, wrapup);

   sts = VDBlist_menu_oper( &CatListWin, CatNamLen, VDB_FIRST_LINE, VDB_FIRST_COL,
                            NumbCat, CatListLen, VDB_FAM, CatList, TRUE,
			    CatListFlag );

   VDB_DELETE_WIN( CatListWin );

   if ( sts != VDB_PROCESS ) goto wrapup;

  /* Get list of parts for each selected catalog */
  for(ii = 0; ii < NumbCat; ii++) {

    if (CatListFlag[ii]) {

      strcpy(CatName,CatList[ii]);

      VDBdelTrailSpaces(CatName);

      sts = VdbGetParts( CatName, &PartList, &NumbPart );

      if (NumbPart > 0) {

      PartNamLen  = 40; // VDB_MAX_PART_LEN;
      PartListLen = MIN( NumbPart, 6 );

      sts = VDBmake_select_win( &PartListWin, 11, 2, &PartNamLen,
                             PartListLen+1, CatList[ii],
                             PartList[0], PartList[1], PartList[2],
                             PartList[3], PartList[4], PartList[5] );

      PartListFlag = _MALLOC( NumbPart, char );
     _CheckAlloc ( PartListFlag, "PartListFlag", sts, FALSE, wrapup);

      sts = VDBlist_menu_oper( &PartListWin, PartNamLen, VDB_FIRST_LINE, VDB_FIRST_COL,
                            NumbPart, PartListLen, VDB_PART, PartList, TRUE,
			    PartListFlag );

      VDB_DELETE_WIN( PartListWin );

      if ( sts == VDB_PROCESS ) {
      
        /* Process each part in catalog */
        if (*state == VDB_DELPART_MENU) {
          sts = VDBDelPartList(CatName,PartList,NumbPart,PartListFlag,
            mainwin,catalogwin,partwin2);
          if (!sts) goto wrapup;
        }
      }

      _FREE(PartListFlag); PartListFlag = 0;
      _FREE(PartList);     PartList = 0;
      }
      else {
        printf("No parts in %s\n",CatName);
        VDB_GET_RETURN;
      }
    }
  }

wrapup:
  *state = statex;

  _FREE(CatListFlag);
  _FREE(CatList);

  _FREE(PartListFlag);
  _FREE(PartList);

  VDBrefresh_bar_menu();
  return 1;
}

int VDBDelPartList(
  char* CatName, 
  char (*PartList)[81], 
  int NumbPart, 
  char PartListFlag[],
  WINDOW* mainwin,
  WINDOW* catalogwin,
  WINDOW* partwin2)
{
  int  ii,flag,sts;
  char product[10] = "";
  char yn;
  char n_itemname[40];
  char n_itemrev[40];
  char n_itemwork[128];
  char *p;

  // See if all were selected
  flag = 1;
  for(ii = 0; (ii < NumbPart) && (flag); ii++) {
    if (!PartListFlag[ii]) flag = 0;
  }

  ENDWIN;

  if (flag) {

    yn = 'y';
    sprintf(n_itemwork,"Does '%s' belong to STRUCT [y/n] ? [y] ",CatName);
    VDBgetyesno ( n_itemwork, &yn);

    if ( yn == 'y' ) strcpy ( product, "struct" );
    
    sts = VDSDeleteParts ( CatName, "all", "all", product );

    goto wrapup;
  }

  for(ii = 0; ii < NumbPart; ii++) {

    if (PartListFlag[ii]) {

      // Grab the display string
      strcpy(n_itemwork,PartList[ii]);
      VDBdelTrailSpaces(n_itemwork);

      // Pull item rev
      for(p = n_itemwork; *p > ' '; p++);
      *p = 0;
      strcpy(n_itemrev,n_itemwork);

      // Pull item name
      for(p++; *p == ' '; p++);
      strcpy(n_itemname,p);

      sts = VDSDeleteParts ( CatName, n_itemname, n_itemrev, product );

      if (sts != VDS_S_SUCCESS) goto wrapup;
    }
  }

wrapup:
  VDB_GET_RETURN;
  VDB_REFRESH_WIN(mainwin);
  VDB_REFRESH_WIN(catalogwin);
  VDB_REFRESH_WIN(partwin2);

  return 1;
}

int VDBProjData(int* state, WINDOW* mainwin)
{
  int sts,ii;

  char  (*ProjList)[81] = NULL;
  int     NumbProj, ProjNamLen, ProjListLen;

  WINDOW *ProjListWin = NULL;
  WINDOW *ProjWin = NULL;

  char *ProjListFlag = NULL;

  char yn;

  char    ProjectName[VDB_PROJECT_NAME_LEN], 
          ProjectRev [VDB_PROJECT_NAME_LEN], 
          NewUnits   [VDB_PROJECT_NAME_LEN];
  char    work[128],*p;

  int maxlen19 = 0;
  int maxlen20 = VDB_PROJECT_NAME_LEN - 1;

  char    *strptrs[10];

  sts = VdbGetProjs( &ProjList, &NumbProj );

  if( NumbProj < 1 )
  {
    VDBgetyesno( "Error getting list of projects. Continue[y/n] ? [y] ",
		  &yn );

    if( yn == 'y' ) *state = VDB_UTILITIES_MENU;
    else            *state = VDB_MAIN_EXIT;
    return 1;
  }

  ProjListFlag = _MALLOC( NumbProj, char );
  _CheckAlloc ( ProjListFlag, "ProjListFlag", sts, FALSE, wrapup);

  if (NumbProj == 1) {
    ProjListFlag[0] = 1;
  }
  else {
    ProjNamLen = 40;
    ProjListLen = MIN( NumbProj, 6 );

    sts = VDBmake_select_win( &ProjListWin, 11, 2, &ProjNamLen,
                               ProjListLen+1, "PROJECTS",
                               ProjList[0], ProjList[1], ProjList[2],
                               ProjList[3], ProjList[4], ProjList[5] );

    sts = VDBlist_menu_oper( &ProjListWin, ProjNamLen, VDB_FIRST_LINE, VDB_FIRST_COL,
                            NumbProj, ProjListLen, VDB_PROJ, ProjList, TRUE,
			    ProjListFlag );

    VDB_DELETE_WIN( ProjListWin );
  
    if ( sts != VDB_PROCESS ) goto wrapup;
  }

  // Find first selected project, only do one
  for(ii = 0; (ii < NumbProj) && (!ProjListFlag[ii]); ii++);
  if (ii == NumbProj) goto wrapup;

  // Pull out project data
  strcpy(work,ProjList[ii]);
  VDBdelTrailSpaces(work);

  for(p = work; *p > ' '; p++);
  *p = 0;
  strcpy(ProjectRev,work);

  for(p++; *p == ' '; p++);
  strcpy(work,p);

  for(p = work + strlen(work) - 1; (p >= work) && (*p > ' '); p--);
  strcpy(NewUnits,p+1);

  for(; (p >= work) && (*p == ' '); p--);
  *(p+1) = 0;
  strcpy(ProjectName,work);

  sts = VDBmake_input_win ( &ProjWin, 11, 2, &maxlen19, &maxlen20,
                              6+1, " SET PROJECT UNITS ", "Project Name",
                              ProjectName, "Project Revision", ProjectRev,
                                "Units[METRIC/IMPERIAL]", NewUnits);
   strptrs[0] = ProjectName;
   strptrs[1] = ProjectRev;
   strptrs[2] = NewUnits;

   sts = VDBcvrt_menu_oper ( &ProjWin, maxlen20, VDB_FIRST_LINE,
			   VDB_FIRST_COL+maxlen19+VDB_GAP, 3, strptrs );
   
   VDB_DELETE_WIN(ProjWin);

   if ( sts == VDB_EXIT ) {
     goto wrapup;
   }

   sts = VDBconvertUnits ( ProjectName, ProjectRev, NewUnits );
   VDB_REFRESH_WIN(mainwin);

wrapup:
  _FREE(ProjListFlag);
  _FREE(ProjList);
  *state = VDB_UTILITIES_MENU;

  return 1;
}

