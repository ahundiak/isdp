#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "UTIstruct.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "ERR.h"
#include "DEBUG.h"
#ifdef OS_SOLARIS
#include <unistd.h>   /* Added  - SSRS - 9/12/93 */
#endif

char    script_line[132];
char    command[132];

long	status;

FILE    *script_file;
FILE	*master_script;

UTIdelete_script( script )
    char *script;
{
    static char * fname = "UTIdelete_script";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    strcpy( command, DEL_CMD );
    strcat( command, WRK_DIR );
    strcat( command, script );
/*In the below line 'if UNIX' changed to 'ifdef OS_UNIX - SSRS 28 Dec 93 */
#ifdef OS_UNIX
    strcat( command, " > /dev/null 2>&1" );
#endif    

#if VMS
    strcat( command, ";0" );
#endif

    status = system( command );
    if( UTIsys_stat( status ) != 0 )
    {
	ERRload_struct( UTI, UTI_E_DELSCR, "%s", script );    
 	return( UTI_E_DELSCR );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  Routine called during RESTORE that will write file to be sorted
 */
UTIwrite_script( wlist, script )
    UTIpending wlist;
    char       *script;
{
    static	char *fname = "UTIwrite_script";

    _UTIdebug(( fname, "Entry: Script <%s>\n", script ));

    script_file = fopen( script, "w+" );
    if( script_file == NULL )
    {
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", script );
	return( UTI_E_WRTSCR );
    }
    while( wlist != NULL )
    {
	if( wlist->state != -1)
  	    fprintf( script_file, "%d %d %6s %s %d %s\n",
		     wlist->node.val, wlist->rstr.storage_no, wlist->label, 
		     wlist->saveset, wlist->state, wlist->ci_file_name);
	wlist = wlist->next;
    }
    
    fclose( script_file );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine executes input script which is a local execution
 */
UTIexecute_script( script )
    char *script;
{
    int  child;
    int  stat_loc;
    int  ret,ret1;
    char *envp[1];

    int i;
 
/* 12/8/92 - KT - no 'statl' on the SUN */
/* MSSP - 30 Dec 93.  changed clipper to OS_CLIX */
#ifdef OS_CLIX
    struct statl buf;
#else
    struct stat buf;
#endif

    static	char *fname = "UTIexecute_script";

    _UTIdebug(( fname, "<%s>\n", script ));

    ret = chmod( script, 06777 );
    _UTIdebug(( fname, "Status from chmod() <%d>\n", ret ));

    unlink("/usr/tmp/UTI.ERR"); /**Remove the error file **/
    strcpy( command, script );
    strcat( command, " >/dev/null 2>/usr/tmp/UTI.ERR" );

#ifdef OS_SCO_UNIX
    /* vfork is not available on SCO. SSRS 31 Jan 94 */
    if( (child = fork()) == -1 )
#else
    if( (child = vfork()) == -1 )
#endif
    {
	ERRload_struct( UTI, UTI_E_FORK, "%s", "execute" );	
	return( UTI_E_FORK );
    }
    else if( child )
    {
        wait( &stat_loc );
  	_UTIdebug(( fname, "Status from wait() <%d>\n", stat_loc>>8));
	buf.st_size = 0;

/* 12/8/92 - KT - no 'statl' on SUN */
/* MSSP - 30 Dec 93.  chnaged clipper to OS_CLIX */
#ifdef OS_CLIX
        ret1 = statl( "/usr/tmp/UTI.ERR", &buf );
#else
        ret1 = stat( "/usr/tmp/UTI.ERR", &buf );
#endif
        _UTIdebug(( fname, "stat Returned <%d>, UTI.ERR size <%d>\n", ret1, buf.st_size ));

	for(i=0;i<10;i++)
	{
	  if(ret1)
	  {
	     buf.st_size = 0;

/* 12/8/92 - KT - no 'statl' on SUN */
/* MSSP - 30 Dec 93.  chnaged clipper to OS_CLIX */
#ifdef OS_CLIX
             ret1 = statl( "/usr/tmp/UTI.ERR", &buf );
#else
             ret1 = stat( "/usr/tmp/UTI.ERR", &buf );
#endif

             _UTIdebug(( fname, "stat Returned <%d>, UTI.ERR size <%d>\n", ret1, buf.st_size ));
	  }
	  else
	     break; /** Success **/
	  sleep(1);
	}

	if( buf.st_size > 0 )
	{
	    ERRload_struct( UTI, UTI_E_EXEC, "%s", script );	
	    return( UTI_E_EXEC );
	}
	unlink("/usr/tmp/UTI.ERR");
    }
    else
    {
#ifdef OS_SCO_UNIX
	extern char ** environ;
#endif
        _UTIdebug(( fname,"Script <%s>\n", command ));
#ifdef OS_SCO_UNIX
        ret = execle( "/bin/sh", "sh", "-c", command, (char*) 0, environ );
#else
	envp[0] = NULL;
        ret = execle( "/bin/sh", "sh", "-c", command, (char*) 0, envp );
#endif
        if( ret == -1 )
	{
            _UTIdebug(( fname,"execle failed <%s>\n", command ));
	    ERRload_struct( UTI, UTI_E_EXEC, "%s", script );	
	    return( UTI_E_EXEC );
	}
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
UTIsort_restore_requests( )
{
    int  child;
    int  stat_loc;
    int  ret,ret1;
    char *envp[1];

    int i;

/* 12/8/92 - KT - no 'statl' on SUN */
/* MSSP - 30 Dec 93.  chnaged clipper to OS_CLIX */
#ifdef OS_CLIX
    struct statl buf;
#else
    struct stat buf;
#endif

    static char *fname = "UTIsort_rstr_requests";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

/*  Prepare script file that will execute sort command 
 */
    sprintf( command, "%sRSORT.COM",  UTI_SERVER_PATH );

    script_file = fopen( command, "w" );
    if( script_file == NULL )
    {
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", command );
	return( UTI_E_WRTSCR );
    }

/*  Sort on node_no, storage_no, label and saveset
    In reverse numeric order of savesets 
    (required for NO-REWIND restore) -DEP
 */
    fprintf( script_file,
    "/bin/sort -o%sRSORT.REQ +0b -1 +1b -2 +2b -3 +3n -4 -r \\\n",
	     UTI_SERVER_PATH );
    fprintf( script_file, " %sRESTORE.REQ\n", UTI_SERVER_PATH );
    fclose( script_file );
    chmod( command, 06777 );

    unlink("/usr/tmp/UTI.ERR"); /** Remove the error file before exec **/

/******************
    strcat( command, " >/dev/null 2>/usr/tmp/UTI.ERR" );
    _UTIdebug(( fname, "cmd_file <%s>\n", command ));

    system(command);
    ret = Stat( "/usr/tmp/UTI.ERR", &buf );
    _UTIdebug(( fname, "UTI.ERR size <%d>\n", buf.st_size ));
    if( buf.st_size > 0 )
    {
        ERRload_struct( UTI, UTI_E_EXEC, "%s", command );
        return( UTI_E_EXEC );
    }
    sprintf( command, "%sRESTORE.REQ", UTI_SERVER_PATH );
    chmod( command, 06777 );
******************/

#ifdef OS_SCO_UNIX
    /* vfork is not available on SCO. SSRS 31 Jan 94 */
    if( (child = fork()) == -1 )
#else
    if( (child = vfork()) == -1 )
#endif
    {
	ERRload_struct( UTI, UTI_E_FORK, "%s", "sort" );	
	return( UTI_E_FORK );
    }
    else if( child )
    {
        wait( &stat_loc );
	buf.st_size = 0;
  	_UTIdebug(( fname, "Status from wait() <%d>\n", stat_loc>>8 ));

/* 12/8/92 - KT - no 'statl' on SUN */
/* MSSP - 30 Dec 93.  chnaged clipper to OS_CLIX */
#ifdef OS_CLIX
        ret1 = statl( "/usr/tmp/UTI.ERR", &buf );
#else
        ret1 = stat( "/usr/tmp/UTI.ERR", &buf );
#endif

        _UTIdebug(( fname, "statl returned <%d>, UTI.ERR size <%d>\n", ret1, buf.st_size ));

	for(i=0;i<10;i++)
	{
	  if(ret1)
	  {
	      buf.st_size = 0;

/* 12/8/92 - KT - no 'statl' on SUN */
/* MSSP - 30 Dec 93.  chnaged clipper to OS_CLIX */
#ifdef OS_CLIX
              ret1 = statl( "/usr/tmp/UTI.ERR", &buf );
#else
              ret1 = stat( "/usr/tmp/UTI.ERR", &buf );
#endif

              _UTIdebug(( fname, "statl returned <%d>, UTI.ERR size <%d>\n", ret1, buf.st_size ));
	  }
	  else
	      break; /** Success **/
	  sleep(1);
	}

        if( buf.st_size > 0 )
        {
            ERRload_struct( UTI, UTI_E_EXEC, "%s", command );
            return( UTI_E_EXEC );
        }
        sprintf( command, "%sRESTORE.REQ", UTI_SERVER_PATH );
	chmod( command, 06777 );
	unlink("/usr/tmp/UTI.ERR");
    }
    else
    {
#ifdef OS_SCO_UNIX
	extern char ** environ;
#endif
        strcat( command, " >/dev/null 2>/usr/tmp/UTI.ERR" );
        _UTIdebug(( fname, "cmd_file <%s>\n", command ));
#ifdef OS_SCO_UNIX
        ret = execle( "/bin/sh", "sh", "-c", command, (char*) 0, environ);
#else
	envp[0] = NULL;
        ret = execle( "/bin/sh", "sh", "-c", command, (char*) 0, envp );
#endif
        if( ret == -1 )
	{
            _UTIdebug(( fname, "execle failed,command <%s>\n", command ));
	    ERRload_struct( UTI, UTI_E_EXEC, "%s", "sort" );	
	    return( UTI_E_EXEC );
	}
    }

    sprintf( command, "%sRSORT.COM", UTI_SERVER_PATH );
    unlink( command );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/* This routine, given link_no, will find that link number in flist and 
 * store the information into rlink. This is done because this information
 * is shuffled when the RESTORE.REQ file is sorted on keys and read again.
 */
UTIpending
UTIfind_link( flist, link_no )
    UTIpending  flist;
    int         link_no;
{
    UTIpending ret = NULL;
    UTIpending UTImake_list();

    static char *fname = "UTIfind_link";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    while( flist != NULL )
    {
	if( flist->state == link_no )
	{
	    ret = UTImake_list();
	    UTIcopy_link( ret, flist );
	    return( ret );
	}
	flist = flist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( ret );
}
/*  This routine reads the "RSORT.REQ" file which is the sorted list
 *  of files requested to be restored.  The sorted list is then broken
 *  into sublists of like nodes, storage areas and savesets.
 *  There is a list of on-line restore requests and a list of off-line
 *  restore requests created.
 */

UTIreturn_sorted_list( rlist, r_on_list, r_off_list )
    UTIpending rlist;		/* input list */
    UTIpending *r_on_list;	/* output ON_LINE list */
    UTIpending *r_off_list; 	/* output OFF_LINE list */
{
    int  i;
    int  node_no;
    int  storage_no;
    int  link_no;

    char label[20];
    char saveset[20];
    char file_name[40];
    char ch;

    UTIpending  on_list;
    UTIpending  on_link;
    UTIpending  off_list;
    UTIpending  off_link;

    static char *fname = "UTIreturn_sorted_list";
    
    on_list  = NULL;
    off_list = NULL;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( command, "%sRSORT.REQ", UTI_SERVER_PATH );

    script_file = fopen( command, "r" );
    for(i=0;i<5;i++)
    {
    	if( script_file == NULL )
    	{
    		sleep(1);/** Sleep for 1 second and try again **/
    		_UTIdebug(( fname, "Open <%s>: Retry# <%d>\n", command, i+1 ));
    		script_file = fopen( command, "r" );
    	}
    	else
		break;
    }

    if( script_file == NULL )
    {
	ERRload_struct( UTI, UTI_E_OPEN, "%s", command );
	return( UTI_E_OPEN );
    }

    while( i = fscanf( script_file, "%d %d %6s %s %d %s",
	   &node_no, &storage_no, label, saveset, &link_no, file_name ) >0 )
    {
	ch = fgetc( script_file );
	if( storage_no < 0 )
 	{
	    off_link = UTIfind_link( rlist, link_no );
	    off_link->next = off_list;
	    off_list = off_link;
	}
	else
	{
	    on_link = UTIfind_link( rlist, link_no );
	    on_link->next = on_list;
	    on_list = on_link;
	}
    } /* end while */
    fclose( script_file );
    unlink( command );

    *r_on_list  = on_list;
    *r_off_list = off_list;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine reads the sorted list of requests and then builds
 *  a RESTORE script for each different node that will restore
 *  all files from storage areas in that node. Each of these scripts
 *  is named according to the restore group number it is in. The 
 *  restore group number is the highest value 'restore_no' attribute in
 *  the nfmsavesets table. Each different script is explicitly named
 *  in a file named RESTORE.'NODE_NO'. The NFMutil requester reads that
 *  file to determine which scripts to execute. The restore group number
 *  is the information that directs the database update if the script
 *  executed successfully.
 */
UTIbuild_restore_master( flist )
    UTIpending flist;	 /* List of requested files to restore */
{
    static char *fname = "UTIbuild_rstr_master";

    UTIpending on_list  = NULL;  /* On-line list */
    UTIpending off_list = NULL;  /* Off-line list */

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    status = UTIreturn_sorted_list( flist, &on_list, &off_list );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Do ON-LINE requests first 
 */
    if( on_list != NULL )
    {
	ON_LINE  = TRUE;
	OFF_LINE = FALSE;

        status = UTIon_line_requests( on_list );
        _UTIdebug(( fname, "UTIon_line_requests <0x%.8x>\n",status ));
    }
/*  Now do OFF-LINE requests
 */
    if( off_list != NULL )
    {
	ON_LINE  = FALSE;
	OFF_LINE = TRUE;

        status = UTIoff_line_requests( off_list );
        _UTIdebug(( fname, "UTIoff_line_requests <0x%.8x>\n", status ));
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    if( status != UTI_S_SUCCESS )
	return( status );

    return( UTI_S_SUCCESS );
}

/*  This routine takes the sorted input list and processes 
 *  ON-LINE requests.
 */
UTIon_line_requests( rlist )
    UTIpending  rlist;
{
    int  old_nno;	 /* Previous node number */

    char old_nnm[30];	 /* Previous node name */  
    char ch_no[10];

    static char *fname = "UTIon_line_requests";

    UTIpending slist    = NULL; /* First link of current node group list */
    UTIpending slistend = NULL; /* Last link of current node group list */
    UTIpending sublist  = NULL; /* First link of next node group list */

    old_nno = -1;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sublist = slist = rlist;
    while( sublist != NULL )
    {
	if( old_nno == -1 ) 		       /* First link */
	{
	    strcpy( old_nnm, slist->node.name );
	    old_nno = slist->node.val;
	}
	else if( old_nno != sublist->node.val ) /* Did node_no change ? */
	{
	    slistend->next = NULL;     /* Break off current node group list */

	    /*  Get utilities reserved storage area name and number for this
	     *  node number.
	     */
	    status = UTISget_util_sa_info( old_nno );
	    if( status != UTI_S_SUCCESS )
	 	return( status );

	    _UTIdebug(( fname, "UTI_SERVER_PATH <%s>\n", UTI_SERVER_PATH ));

	    status = UTIrstr_same_node( slist );
	    if( status != UTI_S_SUCCESS )
  	    {
		sprintf( ch_no, "%d", old_nno );
		ERRload_struct( UTI, UTI_E_RESTORE_GROUP, "%d", old_nno );
        	return( UTI_E_RESTORE_GROUP );
	    }
	    old_nno = sublist->node.val;
	    strcpy( old_nnm, sublist->node.name );
	    slist = sublist;
	}
	slistend = sublist;
	sublist = sublist->next;
    } /* end while */ 

    _UTIdebug(( fname, "%s\n", "Process last node list" ));

    status = UTISget_util_sa_info( old_nno );
    if( status != UTI_S_SUCCESS )
 	return( status );

    status = UTIrstr_same_node( slist );
    if( status != UTI_S_SUCCESS )
    {
	sprintf( ch_no, "%d", old_nno );
	ERRload_struct( UTI, UTI_E_RESTORE_GROUP, "%d", ch_no );
        return( UTI_E_RESTORE_GROUP );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine takes the sorted input list and processes 
 *  OFF-LINE requests.
 */
UTIoff_line_requests( rlist )
    UTIpending  rlist;
{
    int  old_nno;	   /* Previous node number */

    char old_nnm[30];	   /* Previous node name */  
    char new_label[20];
    char script_name[132];
    char utidir_name[132]; /* Name of script in reserved utilities dir */

    static char *fname = "UTIoff_line_requests";

    UTIpending slist    = NULL; /* First link of current node group list */
    UTIpending slistend = NULL; /* Last link of current node group list */
    UTIpending sublist  = NULL; /* First link of next node group list */

    old_nno = -1;

    sublist = slist = rlist;
    while( sublist != NULL )
    {
	 _UTIdebug(( fname, "Current node # <%d>\n", sublist->node.val ));
	if( old_nno == -1 ) 	/* First Link */
	{
	    strcpy( old_nnm, slist->node.name );
	    old_nno = slist->node.val;
   	    _UTIdebug(( fname, "First node # <%d>\n", old_nno ));
	}
	else if( old_nno != sublist->node.val ) /* Did node_no change ? */
	{
	    slistend->next = NULL;     /* Break off current node group list */

	    /*  Get utilities reserved storage area name and number for this
	     *  node number.
	     */
	    status = UTISget_util_sa_info( old_nno );
	    if( status != UTI_S_SUCCESS )
	 	return( status );

	    sprintf( script_name, "%s%s.%d", 
		     UTI_SERVER_PATH, "RESTORE", old_nno );

	    master_script = fopen( script_name, "w" );
	    if( master_script == NULL )
	    {
		ERRload_struct( UTI, UTI_E_WRTSCR, "%s", script_name );
		return( UTI_E_WRTSCR );
	    }

	    status = UTIrstr_same_node( slist );

	    UTIu_rstr_UTAPE(NULL,NULL); /** Cleanup **/
	    UTIu_rstr_CTAPE(NULL,NULL); /** Cleanup **/

	    fclose( master_script );
  	    if( status == UTI_S_SUCCESS )
	    {
	        sprintf( utidir_name, "%s%s.%d", 
			 UTI_CLIENT_PATH, "RESTORE", old_nno );
  	        _UTIdebug(( fname, "UTI_CLIENT_PATH <%s>, Label <%s>\n",UTI_CLIENT_PATH, sublist->label));
  	        UTIreturn_info( utidir_name, old_nnm, sublist->label);

		/* Move script to storage node */

    	        sprintf( script_name, "RESTORE.%d", old_nno );
		chmod( script_name, 06777 );
	        status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA,script_name );
                if( status != UTI_S_SUCCESS )
        	    return( status );
	    }
	    else
		ERRload_struct( UTI, UTI_E_RESTORE_GROUP, "%s",script_name );

	    old_nno = sublist->node.val;
	    strcpy( old_nnm, sublist->node.name );

	    slist = sublist;
	}
	slistend = sublist;
	sublist = sublist->next;
    } /* end while */ 

    status = UTISget_util_sa_info( old_nno );
    if( status != UTI_S_SUCCESS )
 	return( status );

    sprintf( script_name, "%sRESTORE.%d", UTI_SERVER_PATH, old_nno );

    master_script = fopen( script_name, "w" );
    if( master_script == NULL )
    {
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", script_name );
	return( UTI_E_WRTSCR );
    }

    strcpy(new_label, slist->label);
    _UTIdebug(( fname, "New Label : <%s>\n", new_label ));
    status = UTIrstr_same_node( slist );

    UTIu_rstr_UTAPE(NULL,NULL); /** Cleanup **/
    UTIu_rstr_CTAPE(NULL,NULL); /** Cleanup **/

    fclose( master_script );

    if( status == UTI_S_SUCCESS )
    {
        sprintf( utidir_name, "%sRESTORE.%d", UTI_CLIENT_PATH, old_nno );
        _UTIdebug(( fname, "UTI_CLIENT_PATH : <%s>\n", UTI_CLIENT_PATH ));
        UTIreturn_info( utidir_name, old_nnm, new_label);

	/* Move script to storage node */

        sprintf( script_name, "RESTORE.%d", old_nno );
	chmod( script_name, 06777 );
        status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA, script_name );
        if( status != UTI_S_SUCCESS )
       	    return( status );
    }
    else
    {
        _UTIdebug(( fname, "%s\n", "Exiting ..." ));
	ERRload_struct( UTI, UTI_E_RESTORE_GROUP, "%s", script_name );	
	return( UTI_E_RESTORE_GROUP );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine takes the input list of sorted requests from the
 *  same node and breaks the list into sublist of like storage areas
 *  and savesets.  For each like storage area and saveset; the 
 *  RESTORE.NNO file is appended with the shell script commands to
 *  restore the files in the specified saveset.
 */

UTIrstr_same_node( rlist )
    UTIpending rlist;			/* First link of current list */
{
    int	 	old_sno;		/* Previous storage area number */
    int		ar_no;			/* Archive number */
    char	old_set[20];		/* Previous saveset */
    char 	old_label[10];		/* Previous label */
    char	script[80];		/* Script name */
    UTIpending  rlistend = NULL;	/* Last link of current list */
    UTIpending  sublist  = NULL;	/* First link of next list */
    UTIarch     utirec   = NULL;	/* Archive record ( UTI format ) */
    NFMarch     nfmrec   = NULL;	/* Archive record ( NFM format ) */

    static char *fname = "UTIrstr_same_node";

    sublist = rlist;
    old_sno = -1;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    while( sublist != NULL )
    {
	if( old_sno == -1 ) /* First link */
	{
	    old_sno = sublist->rstr.storage_no;
	    strcpy( old_set, sublist->saveset );
	    strcpy( old_label, sublist->label );
	}
	else if( ( old_sno != sublist->rstr.storage_no )||
	       ( strcmp( old_label, sublist->label ) != 0 ) ||
	       ( strcmp( old_set, sublist->saveset ) != 0 ) )
	{
	    nfmrec = NULL;
	    utirec = NULL;

	    _UTIdebug(( fname, "Process saveset <%s>\n", old_set));
	    _UTIdebug(( fname, "Process label <%s>\n", old_label));
	    _UTIdebug(( fname, "Process sano <%d>\n", old_sno));

	    old_sno = sublist->rstr.storage_no;
	    strcpy( old_set, sublist->saveset );
	    strcpy( old_label, sublist->label );
	    rlistend->next = NULL; /* Break off current list */

	    status = UTIreturn_NFMarchives( rlist->rstr.archive_no,
					    &nfmrec, &utirec);
	    if( status != UTI_S_SUCCESS )
	 	return( status );

	    status = UTIget_device_type( utirec->device_type );
	    if( status != UTI_S_SUCCESS )
		return( status );
	    
  	    UTI_GROUP_NO += 1;	    

	    status = UTIu_build_restore_script( rlist, utirec );
	    if( status != UTI_S_SUCCESS )
		return( status );

	    if( ON_LINE )
	    {
	        sprintf( script, "%sRESTORE.COM", UTI_SERVER_PATH );
		status = UTIprocess_on_line( script, rlist, nfmrec );
		if( status != UTI_S_SUCCESS )
		     return( status );
	    }
	    else if( OFF_LINE )
	    {
                sprintf( script, "RSTR.%d", UTI_GROUP_NO );
  	        fprintf( master_script,"%sRSTR.%d\n",UTI_CLIENT_PATH,
			 UTI_GROUP_NO);

  	        /* Move script to storage node */
		chmod( script, 06777 );
	        status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA, script );
                if( status != UTI_S_SUCCESS )
                    return( status );

		if( strcmp( UTI_ARCHIVE_OPSYS, "VMS" ) != 0 )
		{
    	            /* Move configure script to storage node */
                    sprintf( script, "RSTR_C.%d", UTI_GROUP_NO );
	   	    chmod( script, 06777 );
	            status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA, script );
                    if( status != UTI_S_SUCCESS )
                        return( status );
		}
	        status = UTIupdate_nfmsavesets(UTIrestore_p,
					       nfmrec->archive_no, rlist );
	        if( status != UTI_S_SUCCESS )
	            return( status );

	        status = UTIupdate_f_catalog( UTIrestore_p, rlist );
	        if( status != UTI_S_SUCCESS )
	            return( status );

	        status = UTIupdate_catalog( UTIrestore_p, rlist );
	        if( status != UTI_S_SUCCESS )
	            return( status );

                status = UTIupdate_nfmprojectcit( UTIrestore,
				 nfmrec->archive_no, rlist );
	        if( status != UTI_S_SUCCESS )
	            return( status );
	    }
	    rlist = sublist;
	}
        _UTIdebug(( fname, "Link <%d> added to list\n",sublist->state));
	rlistend = sublist;
	sublist  = sublist->next;
    } /* end while */

/*  Process last node list */

    status = UTIreturn_NFMarchives( rlist->rstr.archive_no,&nfmrec, &utirec );
    if( status != UTI_S_SUCCESS )
 	return( status );

    ar_no = nfmrec->archive_no;
    status = UTIget_device_type( utirec->device_type );
    if( status != UTI_S_SUCCESS )
	return( status );

    UTI_GROUP_NO += 1;
	    
    status = UTIu_build_restore_script( rlist, utirec );
    if( status != UTI_S_SUCCESS )
	return( status );

    if( ON_LINE )
    {
        sprintf( script, "%sRESTORE.COM", UTI_SERVER_PATH );
	status = UTIprocess_on_line( script, rlist, nfmrec );
	if( status != UTI_S_SUCCESS )
	     return( status );
    }

    else if( OFF_LINE )
    {
        sprintf( script, "RSTR.%d", UTI_GROUP_NO );
        fprintf( master_script, "%sRSTR.%d\n", UTI_CLIENT_PATH,
		 UTI_GROUP_NO );

        /* Move script to storage node */

	chmod( script, 06777 );
        status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA, script );
        if( status != UTI_S_SUCCESS )
            return( status );

        if( strcmp( UTI_ARCHIVE_OPSYS, "VMS" ) != 0 )
 	{
            /* Move script to storage node */
            sprintf( script, "RSTR_C.%d", UTI_GROUP_NO );
	    chmod( script, 06777 );
            status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA, script );
            if( status != UTI_S_SUCCESS )
                return( status );
	}

        status = UTIupdate_nfmsavesets( UTIrestore_p, ar_no, rlist );
        if( status != UTI_S_SUCCESS )
            return( status );

        status = UTIupdate_f_catalog( UTIrestore_p, rlist );
        if( status != UTI_S_SUCCESS )
            return( status );

        status = UTIupdate_catalog( UTIrestore_p, rlist );
        if( status != UTI_S_SUCCESS )
            return( status );

        status = UTIupdate_nfmprojectcit( UTIrestore, ar_no, rlist );
        if( status != UTI_S_SUCCESS )
            return( status );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );	
}
/*  This routine was thrown in when it was decided to process ON_LINE
 *  requests after the script was built instead of using the NFMutil
 *  to execute the script as in the case of OFF_LINE.
 */
UTIprocess_on_line( script, rlist, nfmrec )
    char 	*script;
    UTIpending  rlist;
    NFMarch	nfmrec;
{
    long	status;

    MEMptr	xfer = NULL;

    static	char *fname = "UTIprocess_on_line";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
	
/*  First get the cpio file to the local utilities storage area ( #3 )
 */
    status = UTIxfer_non_nfm_file_out( nfmrec->storageno,nfmrec->saveset );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Execute the script
 */
    chmod( script, 06777 );
    status = UTIexecute_script( script );
    if( status != UTI_S_SUCCESS )
	return( status );

    status = NFMget_move_files_list( UTIuser_id, &xfer );
    if( status != NFM_S_SUCCESS )
    {
        MEMclose( &xfer );
        return( status );
    }

/*  Move files back to original file storage location
 */
    status = UTIxfer_files_out( &xfer, UTI_RES_SA, rlist, "move" );
    if( status != UTI_S_SUCCESS )
	return( status );

    MEMclose( &xfer );

/*  Delete files and cpio file from local utilities storage
 */
    sprintf( script, "%s%s", UTI_SERVER_PATH, nfmrec->saveset );
    unlink( script );

    status = UTIdelete_local_files( rlist );

/*  Update nfmsavesets table
 */
    status = UTIupdate_nfmsavesets( UTIrestore, nfmrec->archive_no, rlist);
    if( status != UTI_S_SUCCESS )
	return( status );

 /*  Update file_catalog table
 */
    status = UTIupdate_f_catalog( UTIrestore, rlist );
    if( status != UTI_S_SUCCESS )
	return( status );

 /*  Update catalog table
  */
    status = UTIupdate_catalog( UTIrestore, rlist );
    if( status != UTI_S_SUCCESS )
	return( status );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

     status = UTIupdate_nfmprojectcit( UTIrestore, nfmrec->archive_no, rlist );
     if( status != UTI_S_SUCCESS )
        return( status );

    return( UTI_S_SUCCESS );
}
