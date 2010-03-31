
#include "ve_import.h"

#include <stdio.h>
#include <igrtypedef.h>
#include <msdef.h>
#include <ms.h>
#include <msmacros.h>
#include <vemsg.h>
#include <OMerrordef.h>

/*--- VEescape_special_characters ----------------------------------------*/

void VEescape_special_characters( string1, string2 )

	char *string1;
	char *string2;

/*
DESCRIPTION
	This function takes a character string "string1" and copies it into
	"string2" and escapes characters that should be escaped for this
	string to be taken literally by the UNIX ksh if the string were
	enclosed in double quotes.  The special characters are: "$

HISTORY
	S.P. Rogers  01/19/89  Creation Date
*/

	{
	IGRchar c;
	IGRint  index1, index2;
	
	for ( index1 = index2 = 0; index1 < strlen( string1 ); index1++ )
	   {
	   c  = string1[index1];
	   if ( (c == '"') || (c == '$') )
	      string2[index2++] = '\\';

	   string2[index2++] = c;
	   }

	string2[index2] = '\0';

	}  /* VEescape_special_characters */


/*--- VE_get_ems_path_for_bg  -------------------------------------------- */

void VE_get_ems_path_for_bg( unique, server, fp )

	char	*unique;	/* in: unique name for files */
	char	*server;	/* in: server node name, login and password */
	FILE	*fp;		/* in: output file descriptor */

/* -------

   Outline:
     put in commands to get product_data file from server
     put in commands to awk for ems path in product data file
     put in clean-up commands

   History:
     19-Sep-88	LMB	created.

------- */

	{
	char escaped_server[200];
	char buff[200];	/* a place to put message string for output */

	/* put in commands to get product_data file from server if not here */
	fprintf( fp, "ems_path=\"\"\n" );
	fprintf( fp, "if [ ! -r /usr/tmp/pd.%s ]\n", unique );
	fprintf( fp, "then fmu \"%s\" receive /usr/ip32/product_data /usr/tmp/pd.%s >/dev/console 2>&1\n",
	         server, unique );
	fprintf( fp, "fi\n" );

	/* put in commands to awk for ems path in product_data file */
	fprintf( fp, "if [ -r /usr/tmp/pd.%s ]\n", unique );
	fprintf( fp, "then\n" );
	fprintf( fp, " if ems_path=`awk '/ I\\/EMS / {print $5}' /usr/tmp/pd.%s`\n", unique );
	fprintf( fp, " then ems_path=$ems_path/bin\n" );
	fprintf( fp, " else ems_path=\"\"\n" );
	fprintf( fp, " fi\n" );
	fprintf( fp, "fi\n" );

	/* handle error (no path obtained) */
	ex$message( msgnumb = VE_F_GetEMSPath, buff = buff )
	fprintf( fp, "if [ ! \"$ems_path\" ]\n" );
	fprintf( fp, "then\n" );
	fprintf( fp, " print_error \"%s\"\n", buff );
	fprintf( fp, " rm -f /usr/tmp/pd.%s\n", unique );
	fprintf( fp, " exit 0\n" );
	fprintf( fp, "fi\n" );

	} /* VE_get_ems_path_for_bg */


/*--- VE_initialize_bg ------------------------------------------------- */

int VE_initialize_bg( unique, server, nodename, keep_files, outfile )

	char *unique;		/* in: unique name for files */
	char *server;		/* in: server node name, login and password */
	char *nodename;		/* in: submitter nodename */
	char keep_files;	/* in: flag, T => scripts not to delete server files */
	char outfile[];		/* out: output file name */

/* -------

   Outline:
     open output file for shell script by the name unique.sh1
     put in command to cd to server target directory
     put in command to run ems
     close output file
     make file executable

     open output file for shell script by the name unique.sh2
     put in shell functions for error reporting and clean up
     put in commands to get ems directory from server
     put in commands for fmu to send the necessary files:
       unique.log unique.sh1 unique.u unique.ems
     put in command for fmu to initiate the batch ems session via unique.sh1
     close output file
     make file executable
     return output file name

   History:
     24-Aug-88	LMB	created.
     19-Sep-88	LMB	changed ppl file extension to ".u", added commands
			to get ems_path from server node.

------- */

	{
	int  sts;			/* status from called functions */
	FILE *fp;			/* output file descriptor */
	char buff[200];			/* a place to put message string for output */
	char login_name[L_cuserid];

	/* get the login name */
	cuserid( login_name );
	
	/* open output file to be sent to server by the name unique.sh1 */
	strcpy( outfile, unique );
	strcat( outfile, ".sh1" );
	fp = fopen( outfile, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	/* put in NQS commands to set submittal options */
	fprintf( fp, "#\n" );
	fprintf( fp, "# @$-o  %s.leo\n", unique );
	fprintf( fp, "# @$-eo\n" );
	fprintf( fp, "# @$-mu %s!%s\n", nodename, login_name );
	fprintf( fp, "# @$-mb -me\n" );
	fprintf( fp, "# @$-q edgegen\n" );
	fprintf( fp, "# @$-s /bin/ksh\n" );
	fprintf( fp, "# $@\n" );
	fprintf( fp, "#\n\n" );

	/* put in commands to find EMS and run it in batch mode */
	fprintf( fp, "ems_path=`awk '/ I\\/EMS / {print $5}' /usr/ip32/product_data`\n" );
	fprintf( fp, "if [ \"$ems_path\" ]\n" );
	fprintf( fp, "   then\n" );
	fprintf( fp, "      ${ems_path}/bin/ems -b -f %s.ems -C 'ci=%s.u'\n", unique, unique );
	fprintf( fp, "   else\n" );
	fprintf( fp, "      echo \"EMS NOT FOUND\"\n" );
	fprintf( fp, "fi\n" );

	/* change mode on server script file to execute */
	sts = chmod( outfile, 0777 );
	if (sts)
	   return VE_F_chmod;

	/* open output file to be run on this node by the name unique.sh2 */
	strcpy( outfile, unique );
	strcat( outfile, ".sh2" );
	fp = fopen( outfile, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	/* put in error reporting and clean up functions */
	fprintf( fp, "print_error () {\n" );
	fprintf( fp, " echo \"%s: $*\" >>%s.log\n", outfile, unique );
	fprintf( fp, " echo \"\\n%s: $*\" >/dev/console\n", outfile );
	fprintf( fp, "}\n" );
	fprintf( fp, "clean_up () {\n" );
	fprintf( fp, " rm -f %s.sh1 %s.u %s.ems\n", unique, unique, unique );
	fprintf( fp, " if [ \"$1\" ]\n" );
	fprintf( fp, " then " );
	if ( keep_files )
	   fprintf( fp, ":\n" );
	else
	   fprintf( fp, "fmu \"%s\" rm $ems_path/%s.\\* >>%s.log 2>&1\n",
	            server, unique, unique );
	fprintf( fp, " else rm -f %s.log\n", unique );
	fprintf( fp, " fi\n" );
	fprintf( fp, "}\n" );

	/* put in commands to get path to ems on the server node */
	VE_get_ems_path_for_bg( unique, server, fp );

	/* put in commands for fmu to send the necessary files */
	fprintf( fp, "Files_Sent=\"\"\n" );
	fprintf( fp, "for File in %s.log %s.sh1 %s.u %s.ems\n",
	         unique, unique, unique, unique );
	fprintf( fp, "do\n");
	fprintf( fp, " if fmu \"%s\" send $File . >>%s.log 2>&1\n",
	         server, unique );
	fprintf( fp, " then Files_Sent=\"true\"\n" );
	fprintf( fp, " else\n" );

	ex$message( msgnumb = VE_F_SendFile, buff = buff )
	fprintf( fp, "  print_error \"%s $File\"\n", buff );
	fprintf( fp, "  clean_up $Files_Sent\n" );
	fprintf( fp, "  exit 0\n" );
	fprintf( fp, " fi\n" );
	fprintf( fp, "done\n" );

	/* put in command to initiate ems */
	fprintf( fp, "if fmu \"%s\" command", server );
	fprintf( fp, " \"qsub %s.sh1\"\n", unique );
	fprintf( fp, "then :\n" );
	fprintf( fp, "else\n" );

	ex$message( msgnumb = VE_F_ExecEMS, buff = buff )
	fprintf( fp, " print_error \"%s\"\n", buff );
	fprintf( fp, " clean_up $Files_Sent\n" );
	fprintf( fp, " exit 0\n" );
	fprintf( fp, "fi\n" );
	fprintf( fp, "clean_up\n" );
	fprintf( fp, "rm %s\n", outfile );
	fclose( fp );

	/* change mode on script file to execute */
	sts = chmod( outfile, 0777 );
	if (sts)
	   return VE_F_chmod;

	return OM_S_SUCCESS;

	} /* VE_initialize_bg */


/*--- VE_check_bg_results -------------------------------------------------- */

int VE_check_bg_results( unique, server, outfile )

	char *unique;		/* in: unique name for files */
	char *server;		/* in: server node name, login and password */
	char outfile[];		/* out: output file name */

/* -------

   Outline:
     open output file for shell script by the name unique.sh3
     put in shell function for error reporting
     put in commands to get log file and process status from server
     put in commands to run see if ems process is running
     put in command to remove log file if ems not done
       else leave log file
     close output file
     make output file executable
     return output file name

   History:
     25-Aug-88	LMB	created.
     19-Sep-88	LMB	added commands to get ems_path on server node, removed
			function arguments dir and keep_files.

------- */

	{
	int  sts;		/* status from called functions */
	FILE *fp;		/* output file descriptor */
	char buff[200];		/* a place to put message string for output */


	/* open output file by the name unique.sh3 */
	strcpy( outfile, unique );
	strcat( outfile, ".sh3" );
	fp = fopen( outfile, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	/* put in error reporting function */
	fprintf( fp, "print_error () {\n" );
	fprintf( fp, " echo \"\\n%s: $*\" >/dev/console\n", outfile );
	fprintf( fp, "}\n" );

	/* put in commands to get ems path on server node */
	VE_get_ems_path_for_bg( unique, server, fp );

	/* put in commands to get process status and log file from server */
	fprintf( fp, "if fmu \"%s\" command \"ps -e\" >%s.ps 2>&1\n", server, unique );
	fprintf( fp, "then\n" );
	fprintf( fp, " if fmu \"%s\" receive %s.log . >>%s.ps 2>&1\n",
	         server, unique, unique );
	fprintf( fp, " then\n" );

	/* put in commands to run see if ems process is (was) running */
	/* if so, bg process is not finished, put in command to remove log file */
	ex$message( msgnumb = VE_I_BgProcId, buff = buff )
	fprintf( fp, "  if grep -c \" `sed -e '/%s/!D' -e", buff );
	fprintf( fp, " 's/%s *//' %s.log` \" %s.ps >/dev/null 2>&1\n",
	         buff, unique, unique );
	fprintf( fp, "  then rm -f %s.log\n", unique );
	fprintf( fp, "  fi\n" );

	/* put in commands to handle error cases and clean up */
	fprintf( fp, " else\n" );

	ex$message (msgnumb = VE_F_RecLogFil, buff = buff, type = "%s", var =`unique` )
	fprintf( fp, "  print_error \"%s\"\n", buff );
	fprintf( fp, "  echo Error >%s.Err\n", unique );
	fprintf( fp, "  rm -f %s.log\n", unique );
	fprintf( fp, " fi\n" );

	ex$message (msgnumb = VE_F_RecProcStat, buff = buff )
	fprintf( fp, "else print_error \"%s\"\n", buff );
	fprintf( fp, "fi\n" );
	fprintf( fp, "rm -f %s.ps %s\n", unique, outfile );
	fclose( fp );

	/* change mode on script file to execute */
	sts = chmod( outfile, 0777 );
	if (sts)
	   return VE_F_chmod;

	return OM_S_SUCCESS;

	} /* VE_check_bg_results */



/*--- VE_retrieve_bg_results ---------------------------------------------- */

int VE_retrieve_bg_results( unique, server, result_name, keep, outfile )

	char *unique;		/* in: unique name for files */
	char *server;		/* in: server node name, login and password */
	char *result_name;	/* in: ve-bg results file name */
	char keep;		/* in: flag, T=> script not to delete server files */
	char outfile[];		/* out: output file name */

/* -------

   Outline:
     open output file for shell script by the name unique.sh4
     make result log file name and rename unique.log to it
     put in shell function for error reporting
     put in commands to get ems path on server
     put in commands for fmu to receive the results file, unique.ems
     put in command for fmu to delete the files from server (if not keeping)
     close output file
     make output file executable
     return output file name

   History:
     25-Aug-88	LMB	created.
     19-Sep-88	LMB	changed ppl file extension to ".u", added commands to
			get ems_path from server, removed function argument dir.

------- */

	{

	int  sts;		/* status from called functions */
	FILE *fp;		/* output file descriptor */
	char logname[32];	/* result log file name */
	char buff[200];		/* a place to put message string for output */


	/* open output file by the name unique.sh4 */
	strcpy( outfile, unique );
	strcat( outfile, ".sh4" );
	fp = fopen( outfile, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	/* make result log file name.  make sure log and result file names differ. */
	strcpy( logname, result_name );
	if ( strlen( logname ) > 10 )
	   logname[10] = NULL;
	strcat( logname, ".log" );
	if (! strcmp( logname, result_name ) )
	   logname[ strlen( logname ) - 3 ] = 'L';

	/* put in error reporting function */
	fprintf( fp, "print_error () {\n" );
	fprintf( fp, " echo \"\\n%s: $*\" >>%s\n", outfile, logname );
	fprintf( fp, " echo \"\\n%s: $*\" >/dev/console\n", outfile );
	fprintf( fp, "}\n" );

	/* put in commands to get path to ems on server node */
	VE_get_ems_path_for_bg( unique, server, fp );

	/* rename the log file, put in commands for fmu to get the .ems file */
	fprintf( fp, "mv %s.log %s\n", unique, logname );
	fprintf( fp, "if fmu \"%s\" receive $ems_path/%s.ems %s >>%s 2>&1\n",
	         server, unique, result_name, logname );
	fprintf( fp, "then\n" );
	if (! keep)
	   {
	   fprintf( fp, " fmu \"%s\" rm $ems_path/%s.\\* >>%s 2>&1\n",
	            server, unique, logname );
	   }

	ex$message( msgnumb = VEM_M_ReEdReSe, buff = buff )
	fprintf( fp, " echo \"\\nDone: %s -> %s\" >/dev/console\n", buff,result_name );
	fprintf( fp, "else\n" );

	ex$message (msgnumb = VE_F_RecResult, buff = buff, type = "%s", var =`unique` )
	fprintf( fp, " print_error \"%s\"\n", buff );
	fprintf( fp, "fi\n" );
	fprintf( fp, "rm /usr/tmp/pd.%s %s\n", unique, outfile );
	fclose( fp );

	/* change mode on script file to execute */
	sts = chmod( outfile, 0777 );
	if (sts)
	   return VE_F_chmod;

	return OM_S_SUCCESS;

	} /* VE_retrieve_bg_results */
