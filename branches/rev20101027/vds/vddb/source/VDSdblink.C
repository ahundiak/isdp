/* $Id: VDSdblink.C,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS 
 *
 * File:	vds/vddb/source / VDSdblink.C
 *
 * Description:
 *	Interface routines called by menu options
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdblink.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1997/01/30  23:58:58  pinnacle
 * ah CR179602053
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.17  1996/07/16  01:36:40  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by sljenks for vds.240
 *
 * Revision 1.16  1996/07/10  16:18:20  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by sljenks for vds.240
 *
 * Revision 1.15  1996/07/09  15:39:30  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by sljenks for vds.240
 *
 * Revision 1.14  1996/05/30  21:26:46  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by sljenks for vds.240
 *
 * Revision 1.13  1996/05/29  19:09:46  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by tlbriggs for vds.240
 *
 * Revision 1.12  1996/05/23  23:53:54  pinnacle
 * Replaced: vddb/source/*link.C for:  by tlbriggs for vds.240
 *
 * Revision 1.11  1996/05/20  14:34:28  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by v240_int for vds.240
 *
 * Revision 1.10  1996/05/20  05:30:00  pinnacle
 * Replaced: vddb/source/*link.C for:  by v240_int for vds.240
 *
 * Revision 1.9  1996/05/20  05:03:52  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by v240_int for vds.240
 *
 * Revision 1.8  1996/04/21  23:49:20  pinnacle
 * Replaced: vddb/source/*.C for:  by v240_int for vds.240
 *
 * Revision 1.7  1996/04/01  12:51:26  pinnacle
 * Replaced: vdris/imp/VdsRisTbl.C for:  by msbraju for vds.240
 *
 * Revision 1.6  1996/03/29  00:31:54  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1996/03/18  11:12:22  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by msbraju for vds.240
 *
 * Revision 1.4  1996/03/05  20:49:04  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/02/25  15:10:38  pinnacle
 * Replaced: vddb/source/VDSdblink.C for:  by msbraju for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	03/02/96	Raju	Fix catalog creation error message
 *	03/05/96	adz	TR179600097 SQLstmt error msg.
 *	03/28/96	tlb	Recover version 1.4 changes 
 *	04/15/96	tlb	Use VDS memory checking
 *				Use partial debug levels for AddPart, GenData 
 *				Add prototypes
 *	04/25/96	tlb	Use return status from VDSreadrisfile
 *				Return status for VDBexecRisFile
 *				Fix error condition for AddCat
 *				ManipTab - zero byte alloc
 *				Remove function VDBfreeUsedIds
 *				Move SQL_err to VDSdbdbg.C
 *				VDBcreatcat: remove login args
 *				VDBAddPart: remove debug arg
 *				Use error checking routines
 *	05/20/96 	tlb	Initialize allocated vars
 *	05/22/96 	tlb	Fix error msg
 *	05/29/96 	tlb	Don't echo calls to AddPart, GenData.
 *				Use error print routines
 *      07/09/96        slj     VDBInsertRows was doing a _LOOPFREE on
 *                              datatypes instead of a _FREE, was causing
 *                              Memory Fault in Add Data menu option.
 *      07/10/96        slj     Changed VDBconvertUnits to update the project
 *                              the user selected instead of project 0.
 *      07/15/96        slj     VDBupdateVdsDbase the string lengths passed
 *				to VDB_menu_oper were of different lengths
 *                              so they were all filled with garbage.
 *                              Changed to VDB_MAX_PATH_LEN, should
 *                              check for illegal file name lengths
 *                              when we have time.
 *      01/30/97        ah      Allow listing catalogs or parts
 *      
 * -------------------------------------------------------------------*/

/* modification : changed this file from .c to .C for omcpp for compilation.
 * this was due to macros included from vdbmacros.h,hence changed .m also.
 */

#include  <curses.h>
#include  <ctype.h>
#include  <string.h>
#include  <unistd.h>
#include  "SQLerrordef.h"
#include  "VDSdberrdef.h"
#include  "VDBload.h"
#include  "VDDbDef.h"
#include  "vdbmacros.h"
#include  "VDmem.h"
#include  "v_risproto.h"
#include  "v_dbloadprot.h"


/* #define VDB_DEBUG  1 */


/* --------------------------------------------------------------------------
Doc :  VDBAddPart

  Desc : Function to add parts.

  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
long VDBAddPart ( 
    char   (*fam_part_list)[81],    	/* i - list containing part files  */
    int    noparts,		 	/* i - no. of part files in the list */
    char   listselflag[],		/* i - flag to indicate if the part 
						in the list is selected or not.
						= 1 if  selected,  
						=0 if not selected */
    char	schema_name[],		 /* i - schema name */
    char	schema_passwd[]	 	/* i - schema password */
    )
{
char     overwrite, yn;
char	 string[200];
char	 deb;
int      ii;
long     sts;


   remove ( "/tmp/part" );
   for ( ii=0; ii<noparts; ii++)
    if ( listselflag[ii] )
    {  sprintf( VDBbuff, "cat %s >>/tmp/part", fam_part_list[ii] );
       sts = system ( VDBbuff );
       if ( sts ) {
	  VDSprintErr ("", "cannot write to parts file: </tmp/part>\n", 
							NULL, NULL );
          goto error;
          }
    } 

   if(VDSdebug_on) deb = 'p'; else deb='q';

   VDBgetyesno( "Do you wish to overwrite existing parts[y/n] : [y] ", 
		&overwrite);

   /* AddPart Parameters
    * 	13 	State number,
    * 	 6 	ACL 
    * 	 4 	Storage area.
    * May have to change later 
    */


   /* Debug version:
    *  sprintf(string,"dbg %s/bin/AddPart %s %s %c 13 6 4 %c", 
    *		VDBvds, schema_name, schema_passwd, deb, overwrite );
    */

   sprintf(string,"%s/bin/AddPart %s %s %c 13 6 4 %c", 
		VDBvds, schema_name, schema_passwd, deb, overwrite );
   ENDWIN;

   VDSprintUsrMsg( "Adding parts... \n");
   VDSdebug(string); 
   sts = system(string);

   if ( sts ) {  
      VDSprintUsrMsg ( "\nError while adding parts\n" );
      VDSdebug ("[%s]\n", string );
      VDB_GET_RETURN;
      VDBgetyesno ( "Do you wish to continue [y/n] ? [y] ", &yn);
      if ( yn == 'n' ) goto error;
    }
    else
       VDB_GET_RETURN;

   return 1;

error:
   return 0;
}

/* --------------------------------------------------------------------------
Doc :  VDBcreatcat

  Desc : Function to create catologs.
         
  Return values:
    1  -  Success
    0  -  Error

  History :
  11-02-93    2.2     raju    creation
  
----------------------------------------------------------------------------*/
long VDBcreatcat (
 	char schema_name[],	/* i - schema name */
 	char schema_passwd[],	/* i - schema password */
 	char (*fam_part_list)[81],	
				/* i - list containing family files */
 	int  nofam,		/* i - no. of family files in the list */
 	char *listselflag	/* i - list containing selected flags.
 					= 1, family selected.
 					= 0, family not selected. */
	)
{
   long   sts;
   char   addparts, yn;
   int    ii, i1;

   ENDWIN;

   VDSprintUsrMsg( "Creating catalogs... \n");

   /* Build temp file containing selected family definitions */
   VDSprintDbgMsg( "   Creating temporary family file \n");
   remove ( VDS_FAM_TEMP_FILE );
   for ( ii=0; ii<nofam; ii++)
        if ( listselflag[ii] ) {  

             sprintf( VDBbuff, "cat %s >> %s", fam_part_list[ii], 
							VDS_FAM_TEMP_FILE);
             sts = system ( VDBbuff );
             if ( sts ) {
	   	VDSprintErr ("","cannot write to family part list file: <%s>\n",
							VDS_FAM_TEMP_FILE);
           	goto error;
		}
      	     }


   sts = VDScreate_catalogs( );
   if ( sts == 0 ) {  /* Error while creating catalogs */
      VDSprintUsrMsg ( "\nError during creation of catalogs\n" );
      VDB_GET_RETURN;
      VDBgetyesno ( "Do you wish to continue [y/n] ? [y] ", &yn);
      if ( yn == 'n' ) goto error;
      else	       goto cont;
      }

   VDB_GET_RETURN;

   VDBgetyesno(
    "Do you wish to ADD PARTS for the created catalogs [y/n] ? [y]", &addparts);
   if ( addparts == 'n' ) { 
	ENDWIN;
     	return TRUE;
   	}

   for( ii=0; ii<nofam; ii++ )
     if ( listselflag[ii] )
     {
       /*   convert the familyfile string to partfile string*/
       i1=0;
       while(  fam_part_list[ii][i1+2] && (fam_part_list[ii][i1] != '.' ||
			 fam_part_list[ii][i1+1] != 'f')  )
		i1++;
       fam_part_list[ii][i1+1] = 'p';
     }

  sts = VDBAddPart ( fam_part_list, nofam, listselflag, schema_name,
							schema_passwd );

cont:
  return TRUE;

error:
  return FALSE;

}

/* --------------------------------------------------------------------------
Doc :  VDBdeleteparts

  Desc : Function to delete parts.

  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
long  VDBdeleteparts (
 char catname[],	/* i - catalog name  */
 char partno[],		/* i - 'all' if all parts to be deleted, or, part no. */
 char partrev[]		/* i - 'all' if all part revisions to be deleted, or, part rev */
)

{
char    product[10] = "", c;
int     sts;

    VDBgetyesno ( "Does the part belong to STRUCT [y/n] ? [y] ", &c);

    if ( c == 'y' )
       strcpy ( product, "struct" );

#ifdef VDB_DEBUG
    VDSdebug ("VDBdeleteparts\n" );
    VDSdebug ("Catalog Name : [%s]\n", catname );
    VDSdebug ("Part num : [%s]\n", partno );
    VDSdebug ("Part rev : [%s]\n", partrev );
    VDSdebug ("product = [%s]\n", product );
#endif

    ENDWIN;

    sts = VDSDeleteParts ( catname, partno, partrev, product );
    if ( sts != VDS_S_SUCCESS ) {	
	/* error messages handled in function */
	VDB_GET_RETURN;
        VDBgetyesno ( "Do you wish to continue [y/n] ? [y] ", &c);
        if ( c == 'n' ) goto error;
    }
    else
        VDB_GET_RETURN;


    return 1;     

error:
    return(0);
}

/* --------------------------------------------------------------------------
Doc :  VDBdeleteCatalog

  Desc : Function to delete a catalog.
         
  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
long  VDBdeleteCatalog(
  char *catname		/* i - catalog name */
)

{
long	sts;
char	yn;


  ENDWIN;

  sts = VDSdelete_catalog( catname );
  if ( sts != VDS_S_SUCCESS )
  {  VDSprintUsrMsg ( "Error deleting catalog <%s>\n", catname );
     VDB_GET_RETURN;
     VDBgetyesno ( "Do you wish to continue [y/n] ? [y] ", &yn);
     if ( yn == 'n' ) goto error;
  }
  else
     VDB_GET_RETURN;
  
  return 1;

error:
  return 0;

} 
/*---------------------------------------------------------------------------
VdbDelCatalogs:
Delete catalogs from a list of catalog names. The selection flag list
indicates whether a catalog should be deleted or not.
 ----------------------------------------------------------------------------*/
long VdbDelCatalogs( CatalogList, NumbCat, listselflag )
char (*CatalogList)[81];
int  NumbCat;
char listselflag[];
{
  int  ii;
  long sts;

  ENDWIN;

  for( ii=0; ii < NumbCat; ++ii )
  {
    if( listselflag[ii] )
    {
      VDBdelTrailSpaces( CatalogList[ii] );

      sts = VDSdelete_catalog( CatalogList[ii] );

      if( sts != VDS_S_SUCCESS )
      {
	VDSprintUsrMsg( "Error deleting catalog <%s>\n", CatalogList[ii] );
        VDB_GET_RETURN;
	return FALSE;
      }

    }
  }

 VDB_GET_RETURN;
 return TRUE;
}
/* --------------------------------------------------------------------------
Doc :  VDBexecRisFile

  Desc : Function to read and execute a ris file.
         
  Return values:
    1  -  always
----------------------------------------------------------------------------*/
long  VDBexecRisFile (
 char  *pathname,	/* i - path of ris file */
 char  *filename	/* i - name of file	*/
)

{
long  sts;

	char  risfile[VDB_MAX_PATH_LEN+14+1];  /* one more for '/' */

  	sprintf( risfile, "%s/%s", pathname, filename );
  	ENDWIN;

  	sts = VDSreadrisfile( risfile );

  	VDB_GET_RETURN;

  	return sts;
}

/* --------------------------------------------------------------------------
Doc :  VDBloadVdsTable

  Desc : Function to load VDS tables from a file.
         
  Return values:
    1  -  always
----------------------------------------------------------------------------*/
long  VDBloadVdsTable( 
  char   *pathname,	/* i - path of the file */
  char   *filename	/* i - name of the file */
)

{
/* long    sts; */
char    yn;


  VDBgetyesno ( "Do you wish to delete existing parts [y/n] ? [y] ", &yn);

  ENDWIN;

/* put a processing massage and flush stdout */
  VDBris_load( filename, pathname, &yn );
/* return values ?????*/

  VDB_GET_RETURN;

  return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBupdateVdsDbase

  Desc : Function updates VDS database by executing ris file $VDS/data/vds/update.ddl
         and loading the file $VDS/data/vds/VDSupdate.load.

  Return values:
    1  -  always
----------------------------------------------------------------------------*/
long  VDBupdateVdsDbase()
{

long sts;
char yn;
char risarg[81];
WINDOW *filewin = NULL;
int    maxlen1, maxlen2, ii;
char   defpath[VDB_MAX_PATH_LEN],
       deffile[VDB_MAX_PATH_LEN],
       deffile2[VDB_MAX_PATH_LEN];
char   *outstrs[3];

   maxlen1 = 0;
   maxlen2 = VDB_MAX_PATH_LEN-1;

   strcpy( defpath, VDBvds );
   strcat( defpath, "/data/vds" );

   strcpy( deffile, "VDSupdate.ddl" );
   strcpy( deffile2, "VDSupdate.load" );

   sts = VDBmake_input_win( &filewin, 11, 2, &maxlen1, &maxlen2, 7,
                             " FILENAME ", "Path", defpath, "DdlFile", deffile,
                             "MapFile", deffile2 );

   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   outstrs[0] = defpath;
   outstrs[1] = deffile;
   outstrs[2] = deffile2;

   VDB_DISP_PADED_MSG( "Enter data and press PROCESS" );

   sts = VDBmenu_input_oper( &filewin, maxlen2, VDB_FIRST_LINE,
              VDB_FIRST_COL+maxlen1+VDB_GAP, 3, -1, 1, VDBmsgstrs, outstrs );

   if( sts == VDB_EXIT )
   {   VDB_DELETE_WIN( filewin );
       return 1;
   }

   /*VDBgetyesno( "Do you wish to UPDATE database [y/n] : ", &yn );
   if ( yn == 'n' )
     goto wrapup;*/

   ENDWIN;

   /* Create new tables and load data */
   sprintf( risarg,"%s/%s", defpath, deffile );
   VDSreadrisfile( risarg );

   sprintf( risarg, "%s", defpath );
   yn = 'n';
   VDBris_load( deffile2, risarg,  &yn );

   VDB_GET_RETURN;

/* wrapup: */
   return 1;
 
}

/* --------------------------------------------------------------------------
Doc :  VDBconvertUnits

  Desc : It sets the project units to the given units

  Return values:
    1  -  always
----------------------------------------------------------------------------*/
long  VDBconvertUnits(
		char  *VdsProjectName,		/* i - project name */
		char  *VdsProjectRevision,	/* i - project revision */
		char  *NewUnits			/* i - units to set to. 
						      ='METRIC' or 'IMPERIAL'*/
		)
{
    char   SqlString[500]; /* increased size from 200 to 500 for join */
    int    units, npdtbl, nozequiv_flg;
    long   status;
    short  bErrFlag = FALSE;

    ENDWIN;

    status = 1;

    if (!VdsProjectName || !VdsProjectRevision) goto wrapup;

    if( !strncmp(NewUnits,"MET", 3))
    {
	units = 20;
	npdtbl = 999;
	nozequiv_flg = 1;
    } 
    else
    {
	units = 1;
	npdtbl = 0;
	nozequiv_flg = 0;
    }

    /* Removed hard code project number */ 
    VDSprintUsrMsg ("\t... Updating vds_project table\n");
    sprintf(SqlString,"update VDS_PROJECT set prj_units_set = %d where prj_number = '%s' and prj_version = '%s' ", units, VdsProjectName, VdsProjectRevision ); 
    status = SQLstmt(SqlString);
    if( status != SQL_S_SUCCESS ) {
      VDSprintSqlErr ("\t", "cannot update vds_project", SqlString, status );
      bErrFlag = TRUE;
      goto wrapup;
      /* reset strings to correct value */
    }


    VDSprintUsrMsg ("\t... Updating piping_project table\n", NULL, NULL);
    sprintf(SqlString,"update PIPING_PROJECT set noz_npd_tblno=%d where PIPING_PROJECT.prj_no= (select VDS_PROJECT.prj_no from VDS_PROJECT where VDS_PROJECT.prj_number = '%s' and VDS_PROJECT.prj_version = '%s') ", npdtbl, VdsProjectName, VdsProjectRevision );
    status = SQLstmt(SqlString);
    if( status != SQL_S_SUCCESS ) {
      VDSprintSqlErr ("\t", "cannot update piping project", SqlString, status );
      bErrFlag = TRUE;
      goto wrapup;
    }

    sprintf(SqlString,"update PIPING_PROJECT set noz_eqvnpd_flg=%d where PIPING_PROJECT.prj_no=(select VDS_PROJECT.prj_no from VDS_PROJECT where VDS_PROJECT.prj_number = '%s' and VDS_PROJECT.prj_version = '%s') ", nozequiv_flg, VdsProjectName, VdsProjectRevision );
    status = SQLstmt(SqlString);
    if( status != SQL_S_SUCCESS ) {
      VDSprintSqlErr ("\t", "cannot update piping project", SqlString, status );
      bErrFlag = TRUE;
      goto wrapup;
    }

    if( !bErrFlag )
     VDSprintUsrMsg("Set Project: %s  Revision: %s   to %s\n",
		      VdsProjectName, VdsProjectRevision, NewUnits );


/* what are the return codes ????*/

wrapup:
    VDB_GET_RETURN;

 return (status);

}

/* --------------------------------------------------------------------------
Doc :  VDBgetyesno

  Desc : Function dispalys the given strings and gets one of ['y','Y','n','N']
	 form user.
         
----------------------------------------------------------------------------*/
void VDBgetyesno(
 char *prompt_str,  /* i - prompt string */
 char *c	    /* o - response      */
)
{
chtype   ch;
char     wfi = TRUE; /* waiting for input */


   while ( wfi )
   {
     leaveok ( VDBmsgwin, FALSE );
     VDB_DISP_MSG_NOPAD( prompt_str );
     echo();
     ch = wgetch ( VDBmsgwin );
     *c = ch & A_CHARTEXT;

     if ( *c == '\n' || *c == 'y' || *c == 'Y' || *c == 'n' || *c == 'N' )
     {  
	if ( *c == '\n' )
		*c = 'y';
	else
		*c = tolower ( *c );
	wfi = FALSE;
     }
     else
	VDB_DISP_PADED_MSG( "" );

   } /* while ( wfi ) */

   noecho();

   VDB_DISP_PADED_MSG( "" );
   leaveok ( VDBmsgwin, TRUE );

}

/* --------------------------------------------------------------------------
Doc :  VDBGenFamilyorPartList

  Desc : Function to generate a family or part file.
         Accepts a list of catalogs as input

  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
int VDBGenFamilyorPartList(
  char (*CatalogList)[81],
  int    NumbCat,
  char   listselflag[],
  char	 familyorpart,		/* i = VDB_FAM, generate family file.
				     = VDB_PART, generate part file */
  char	*schema_name,		/* i - schema name */
  char	*schema_passwd,		/* i - schema password */
  char	debug			/* i - debug option. debug is one of 'y','n' */
)
{
  char	deb;
  char	String[100], yn;
  long  sts;
  int	ii;

  ENDWIN;

  if( debug == 'y' ) deb='p'; else deb='q';

  for(ii = 0; ii < NumbCat; ii++) {

    if( listselflag[ii] ) {
      			
      VDBdelTrailSpaces( CatalogList[ii] );
		
      if( familyorpart == VDB_FAM ) {

        sprintf(String,"%s/bin/GenData %s %s %c%c %s ",
	  VDBvds, schema_name, schema_passwd,
	  deb, 'f', CatalogList[ii] );

	sts = system(String);
        if (sts) {
	 
          VDSprintUsrMsg( "Error generating family file for <%s>\n", CatalogList[ii] );
          VDB_GET_RETURN;
          VDBgetyesno ( "Do you wish to continue [y/n] ? ", &yn);
          if ( yn == 'n' ) goto error;
        }
      }

      sprintf(String,"%s/bin/GenData %s %s %c%c %s ",
          VDBvds, schema_name, schema_passwd,
          deb, 'p', CatalogList[ii] );

      sts = system(String);
      if (sts) {
	 
        VDSprintUsrMsg( "Error generating part file for <%s>\n", CatalogList[ii] );
        VDB_GET_RETURN;
        VDBgetyesno ( "Do you wish to continue [y/n] ? ", &yn);
        if ( yn == 'n' ) goto error;
      }
    }
  }

  VDB_GET_RETURN;
  return 1;

error:
  return 0;
	        
}
/* --------------------------------------------------------------------------
Doc :  VDBGenFamilyorPart

  Desc : Function to generate a family or part file.

  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
int VDBGenFamilyorPart(
 char	*catalog_name,		/* i - name of catalog  */
 char	familyorpart,		/* i = VDB_FAM, generate family file.
				     = VDB_PART, generate part file */
 char	*schema_name,		/* i - schema name */
 char	*schema_passwd,		/* i - schema password */
 char	debug			/* i - debug option. debug is one of 'y','n' */
)
{
	char	deb, fp_flag;
	char	String[100], yn;
        long    sts;


        ENDWIN;

	if( debug == 'y' ) deb='p'; else deb='q';
	if( familyorpart == VDB_PART ) fp_flag = 'p'; else fp_flag = 'f';

	sprintf(String,"%s/bin/GenData %s %s %c%c %s ",VDBvds, schema_name, schema_passwd,deb, fp_flag, catalog_name );
	sts = system(String);
        if (sts)
	 {
	   VDSdebug("ERROR executing the following command - ");
	   VDSdebug( "%s\n", String );
           VDB_GET_RETURN;
           VDBgetyesno ( "Do you wish to continue [y/n] ? ", &yn);
           if ( yn == 'n' ) goto error;
         }

	/* If the user wants a family file to be generated, generate
	   a part file as well. */
	if( familyorpart == VDB_FAM )
	{
	  sprintf( String,"%s/bin/GenData %s %s %c%c %s ",VDBvds, schema_name,
		  schema_passwd,deb, 'p', catalog_name );

	  sts = system( String );
	}

	if ( sts )
	{  if ( familyorpart == VDB_PART )
 	     VDSprintUsrMsg("Error generating part file <%s>\n", catalog_name);
	   else
 	     VDSprintUsrMsg("Error generating family file <%s>\n",catalog_name);
           VDB_GET_RETURN;
           VDBgetyesno ( "Do you wish to continue [y/n] ? ", &yn);
           if ( yn == 'n' ) goto error;
        }
        else
           VDB_GET_RETURN;

        return 1;

error:
        return 0;
	        
}

/* --------------------------------------------------------------------------
Doc :  VDBmanipTable

  Desc : Function to create, modify or drop a table.
         
  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
long  VDBmanipTable(
char	*tablename,		/* i - name of the table */
int	norecs,			/* i - no. of records in the list 'recs' */
struct  VDBtable *recs,		/* i - list of records   */
int	operation		/* i - =VDS_CREATE_TABLE, create the table
				       =VDS_MODIFY_TABLE, modify the table
				       =VDS_DROP_TABLE, delete the table */
)
{
  int	ii, sts;
  char  yn;
  char	**attribs = NULL;
  char 	**dtypes  = NULL;


   ENDWIN;

   if (norecs)  {
   	attribs = _CALLOC ( norecs, char* );
        _CheckAlloc(attribs, "attribute list", sts, VDS_E_ALLOC_MEMORY, quit )

   	dtypes  = _CALLOC ( norecs, char* );
        _CheckAlloc(dtypes, "data types list", sts, VDS_E_ALLOC_MEMORY, quit )
	}

   for ( ii=0; ii< norecs; ii++) {
      attribs[ii] = _MALLOC (VDB_MAX_ATTRIB_LEN, char );   
       _CheckAlloc(attribs[ii], "attributes", sts, VDS_E_ALLOC_MEMORY, quit )

      dtypes[ii] = _MALLOC (VDB_MAX_DTYPE_LEN, char );
       _CheckAlloc(dtypes[ii], "data types", sts, VDS_E_ALLOC_MEMORY, quit )
      }

   for( ii=0; ii< norecs; ii++)
   {  strcpy ( attribs[ii], recs[ii].attrib );
      strcpy ( dtypes[ii], recs[ii].dtype );
   }

   sts = VdsManipTables( tablename, operation, norecs, attribs, dtypes );

quit:
   _LOOPFREE (attribs, norecs);
   _LOOPFREE (dtypes, norecs);

   if ( sts != 1 )
   {  if ( operation == VDS_CREATE_TABLE )
	VDSprintErr ( "", "cannot create table <%s>\n", tablename);

      else if ( operation == VDS_MODIFY_TABLE )
	VDSprintErr ( "", "cannot modify table <%s>\n", tablename);

      else if ( operation == VDS_DROP_TABLE )
	VDSprintErr ( "", "cannot drop table <%s>\n", tablename);
      
      VDB_GET_RETURN;
      VDBgetyesno ( "Do you wish to continue [y/n] ? ", &yn);
      if ( yn == 'n' ) goto error;
   }
   else
      VDB_GET_RETURN;

   return 1;
   
error:
   return 0;

}

/* --------------------------------------------------------------------------
Doc :  VDBdeleteTableData

  Desc : Delete data from a table.
         
  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
long  VDBdeleteTableData(
 char	*tablename		/* i - name of the table */
)
{
   ENDWIN;
/* return values ????? */
   vdb$RisDelete(  table_name    =    tablename,
                   where         =    "");

   VDB_GET_RETURN;

   return 1;
/*   
Try to activate this in future
error:
   VDB_GET_RETURN;
   return 0;
*/
}

/* --------------------------------------------------------------------------
Doc :  VDBInsertRows

  Desc : Function to add data to table by inserting rows.

  Return values:
    1  -  Success
    0  -  Error
----------------------------------------------------------------------------*/
long  VDBInsertRows(
char	*tablename,		/* i - name of the table */
int	norecs,			/* i - no. of records to be inserted */
struct  VDBtable *recs		/* i - list of records */
)
{
char	**attribs = NULL;
char 	**datavals = NULL;
int	*datatypes = NULL;
int	ii, sts; 
char 	yn;

   ENDWIN;

   attribs = _CALLOC (norecs, char* );
    _CheckAlloc(attribs, "attribute list", sts, VDS_E_ALLOC_MEMORY, quit )

   datavals  = _CALLOC (norecs, char* );
   _CheckAlloc(datavals, "data value list", sts, VDS_E_ALLOC_MEMORY, quit )

   datatypes = _MALLOC (norecs, int );
   _CheckAlloc(datatypes, "data type list", sts, VDS_E_ALLOC_MEMORY, quit )

   for ( ii=0; ii< norecs; ii++) {  
      attribs[ii] = _MALLOC (VDB_MAX_ATTRIB_LEN, char );   
      _CheckAlloc(attribs[ii], "attributes", sts, VDS_E_ALLOC_MEMORY, quit )

      datavals[ii] = _MALLOC (VDB_MAX_DVAL_LEN, char );
      _CheckAlloc(datavals[ii], "data values", sts, VDS_E_ALLOC_MEMORY, quit )
      }

   for( ii=0; ii< norecs; ii++)
   {  strcpy ( attribs[ii], recs[ii].attrib );
      strcpy ( datavals[ii], recs[ii].dval );
      datatypes[ii] = atoi( recs[ii].dtype );
   }

   sts = VdsInsertRowsinTable( tablename, norecs, attribs, datatypes, datavals );

quit:
   _LOOPFREE (attribs, norecs);
   _LOOPFREE (datavals, norecs);
   _FREE (datatypes);

   if ( sts != 1 )
   {  VDSprintUsrMsg( "Error inserting row into table <%s>\n", tablename );
      VDB_GET_RETURN;
      VDBgetyesno ( "Do you wish to continue [y/n] ? ", &yn);
      if ( yn == 'n' ) goto error;
   }
   else
      VDB_GET_RETURN;

   return 1;
   
error:
   return 0;

}
