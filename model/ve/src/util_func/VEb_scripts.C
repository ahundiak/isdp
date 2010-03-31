
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "msdef.h"
#include "msmacros.h"

#include "exdef.h"
#include "exmacros.h"

#include "vedef.h"
#include "ve.h"
#include "vemsg.h"

/* prototype files */
#include "VEpr_utilfnc.h"

#if defined(__STDC__)
#define L_cuserid   9
#endif

/* External Global Variables */
extern struct VEresults_info    VEoutput_data;
extern struct VEexecution_parms VEexec_parms;

/*--- VEescape_special_characters ----------------------------------------*/

void VEescape_special_characters( string1, string2 )

	char *string1;
	char *string2;

/*
NAME
	VEescape_special_characters

DESCRIPTION
	This function takes a character string "string1" and copies it into
	"string2" and escapes characters that should be escaped for this
	string to be taken literally by the UNIX ksh if the string were
	enclosed in double quotes.  The special characters are:  $ "

PARAMETERS
	string1 (IN) - the string whose special characters are to be escaped
	string2 (OUT) - the resulting escaped string

GLOBALS USED
	none

HISTORY
	01/19/89    S.P. Rogers
	   Creation Date
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


/*--- VEparse_server_name ----------------------------------------------------*/

static void VEparse_server_name(
   char *server,
   char *tcp_serve,
   char *r_node,
   char *r_user )

/*
NAME
	VEparse_server_name

DESCRIPTION
	Breakup a node.login.password string into a tcp/ip format
	string (i.e., login@node) and strings with the login
	and node.

PARAMETERS
	server (IN) - node.login.password string
	tcp_server (OUT) - login@node format string
	r_node (OUT) - node string
	r_user (OUT) - user string

GLOBALS USED
	none

HISTORY
	01/xx/92    Unknown
	   Creation Date
*/

	{
	char *ptr;

	ptr = r_node;
	while ( *server && *server != '.' )
	   *ptr++ = *server++;

	*ptr = '\0';
	server++;

	ptr = r_user;
	while ( *server && *server != '.' )
	   *ptr++ = *server++;

	*ptr = '\0';
	server++;

	sprintf( tcp_serve, "%s\\@%s", r_user, r_node );

	}  /* VEparse_server_name */


/*--- VEget_product_path_for_bg  -------------------------------------------- */

static void VEget_product_path_for_bg(
   char	*unique,
   FILE	*fp )

/*
NAME
	VEget_product_path_for_bg

DESCRIPTION
	This function writes commands to a shell script that determine where
	I/DRAFT or I/EMS is located on the server.  The commands do the
	following:

	   get product_data file from server
	   awk for DRAFT/EMS in product data file
	   clean-up

PARAMETERS
	unique (IN) - a unique string to use when creating files
	fp (IN) - output file descriptor

GLOBALS USED
	none

HISTORY
	19-Sep-88    Lew Brodnax
	   Creation Date
*/

	{
	char       buff[200];	/* a place to put message string for output */
	char       *trans_type;
	IGRboolean fmu_mode;

#if defined( CLIX )
	trans_type = getenv( "FILE_TRANSFER_MODE" );
	fmu_mode = ( trans_type && !strcmp( trans_type, "FMU" ) );
#else
	fmu_mode = FALSE;
#endif

	/* put in commands to get product_data file from server if not here */
	fprintf( fp, "      prod_path=\"\"\n" );
	fprintf( fp, "      pd_file=/usr/tmp/pd.%s\n", unique );
	fprintf( fp, "      if [ ! -r ${pd_file} ]\n" );
	fprintf( fp, "         then\n" );
	if ( fmu_mode )
	   {
	   fprintf( fp, "            fmu \"${server}\" receive /usr/ip32/product_data ${pd_file} >/dev/console 2>&1\n" );
	   }
	else
	   {
	   fprintf( fp, "            rcp \"${server}\":/usr/ip32/product_data ${pd_file} >/dev/console 2>&1\n" );		
	   }
	fprintf( fp, "      fi\n" );

	/* put in commands to awk for DRAFT or EMS in product_data file */
	fprintf( fp, "      if [ -r ${pd_file} ]\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            if prod_path=`awk '/ 'I\\\\\\/DRAFT' / {print $5}' ${pd_file}`\n" );
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  prod_path=${prod_path}/bin\n" );
	fprintf( fp, "               else\n" );
	fprintf( fp, "                  if prod_path=`awk '/ 'I\\\\\\/EMS' / {print $5}' ${pd_file}`\n" );
	fprintf( fp, "                     then\n" );
	fprintf( fp, "                        prod_path=${prod_path}/bin\n" );
	fprintf( fp, "                     else\n" );
	fprintf( fp, "                        prod_path=\"\"\n" );
	fprintf( fp, "                     fi\n" );
	fprintf( fp, "               fi\n" );
	fprintf( fp, "         fi\n" );
	fprintf( fp, "      rm -f ${pd_file} >/dev/null 2>&1\n" );

	/* handle error (no path obtained) */
	ex$message( msgnumb = VE_F_GetEMSPath, buff = buff )
	fprintf( fp, "      if [ -z \"${prod_path}\" ]\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            print_error \"%s\"\n", buff );
	fprintf( fp, "            exit 0\n" );
	fprintf( fp, "         fi\n" );

	} /* VEget_product_path_for_bg */



/*--- VEwrite_sh1_file ---------------------------------------------------------*/

static void VEwrite_sh1_file(
   FILE       *fp,
   IGRchar    *unique,
   IGRchar    *server,
   IGRchar    *nodename,
   IGRchar    *login_name,
   OM_S_OBJID gragad_id,
   IGRchar    *start_time )

/*
NAME
	VEwrite_sh1_file

DESCRIPTION
	Write the commands into the {unique}.sh1 file.  This file is the one
	that is submitted to NQS to actually run Ems.

PARAMETERS
	fp (IN) - output file descriptor
	unique (IN) - unique string for file names
	server (IN) - the server name in the form: server.node.passwd
	nodename (IN) - node name of submitting machine
	login_name (IN) - login name of submitter
	gragad_id (IN) - object id of gragad in which batch VE is to be run
	start_time (IN) - the start time of the batch job

GLOBALS USED
	none

HISTORY
	09/19/88    Lew Brodnax
	   Creation Date
	03/14/92    S.P. Rogers
	   Removed "transos" stuff since all files are now written in
	   Clipper format
*/

	{
	char tcp_serve[128], r_node[128], r_user[128];

	VEparse_server_name( server, tcp_serve, r_node, r_user );

	/* put in NQS commands to set submittal options */
	fprintf( fp, "#\n" );
	fprintf( fp, "# @$-o  %s.leo\n", unique );
	fprintf( fp, "# @$-eo\n" );
	fprintf( fp, "# @$-mu %s!%s\n", nodename, login_name );
	fprintf( fp, "# @$-mb -me\n" );
	fprintf( fp, "# @$-q edgegen\n" );
	fprintf( fp, "# @$-s /bin/ksh\n" );
	if ( strlen( start_time ) )
	   fprintf( fp, "# @$-a \"%s\"\n", start_time );
	fprintf( fp, "# @$\n" );
	fprintf( fp, "#\n\n" );

	/* put in commands to find Emspp, Emscs, or Emsde and run it in batch mode */
	fprintf( fp, "image=\"\"\n" );
	fprintf( fp, "prod_path=$(awk '$1 == \"\\\"Emspp\\\"\" {print $5}' /usr/ip32/product_data)\n" );
	fprintf( fp, "if [ \"${prod_path}\" ]\n" );
	fprintf( fp, "   then\n" );
	fprintf( fp, "      prod_path=$(awk '$1 == \"\\\"Model\\\"\" {print $5}' /usr/ip32/product_data)\n" );
	fprintf( fp, "      prod_path=${prod_path}/bin\n" );
	fprintf( fp, "      if [ -r \"${prod_path}/Model\" ]\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            image=\"Model\"\n" );
	fprintf( fp, "            product=\"Emspp\"\n" );
	fprintf( fp, "      fi\n" );
	fprintf( fp, "fi\n\n" );
	fprintf( fp, "if [ -z \"${image}\" ]\n" );
	fprintf( fp, "   then\n" );
	fprintf( fp, "      prod_path=$(awk '$1 == \"\\\"Emscs\\\"\" {print $5}' /usr/ip32/product_data)\n" );
	fprintf( fp, "      if [ \"${prod_path}\" ]\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            prod_path=$(awk '$1 == \"\\\"Model\\\"\" {print $5}' /usr/ip32/product_data)\n" );
	fprintf( fp, "            prod_path=${prod_path}/bin\n" );
	fprintf( fp, "            if [ -r \"${prod_path}/Model\" ]\n" );
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  image=\"Model\"\n" );
	fprintf( fp, "                  product=\"Emscs\"\n" );
	fprintf( fp, "            fi\n" );
	fprintf( fp, "      fi\n" );
	fprintf( fp, "fi\n\n" );
	fprintf( fp, "if [ -z \"${image}\" ]\n" );
	fprintf( fp, "   then\n" );
	fprintf( fp, "      prod_path=$(awk '$1 == \"\\\"Emsde\\\"\" {print $5}' /usr/ip32/product_data)\n" );
	fprintf( fp, "      if [ \"${prod_path}\" ]\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            prod_path=$(awk '$1 == \"\\\"Model\\\"\" {print $5}' /usr/ip32/product_data)\n" );
	fprintf( fp, "            prod_path=${prod_path}/bin\n" );
	fprintf( fp, "            if [ -r \"${prod_path}/Model\" ]\n" );
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  image=\"Model\"\n" );
	fprintf( fp, "                  product=\"Emsde\"\n" );
	fprintf( fp, "            fi\n" );
	fprintf( fp, "      fi\n" );
	fprintf( fp, "fi\n\n" );

	fprintf( fp, "if [ \"${image}\" ]\n" );
	fprintf( fp, "   then\n" );
	fprintf( fp, "      ${prod_path}/${image} -p ${product} -b -f %s.ems -C '", unique );
	fprintf( fp, "VECrBtEdIn %d \"del\" \"e o l\" \"%d,%d\"",
	         gragad_id, VEexec_parms.displayed_layer, VEexec_parms.non_displayed_layer );
	fprintf( fp, " xy=0,0,0 CLEAR_STACK exit y'\n" );

	fprintf( fp, "      ${prod_path}/ipckill >/dev/null 2>&1\n" );
	fprintf( fp, "   else\n" );
	fprintf( fp, "      echo \"Correct software products not found on server\"\n" );
	fprintf( fp, "fi\n" );

	}  /* VEwrite_sh1_file */


/*--- VEwrite_sh2_file ----------------------------------------------------*/

static void VEwrite_sh2_file(
   FILE    *fp,
   IGRchar *server,
   IGRchar *outfile,
   IGRchar *working_dir,
   IGRchar *unique,
   IGRchar keep_files )

/*
NAME
	VEwrite_sh2_file

DESCRIPTION
	Write the commands into the {unique}.sh2 file.  This file submits the
	job from the submitting workstation

PARAMETERS
	fp (IN) - output file descriptor
	server (IN) - the server name in the form: server.node.passwd
	outfile (IN) - output file name
	working_dir (IN) - working directory for files
	unique (IN) - unique name for files
	keep_files (IN) - flag indicating whether files should be kept

GLOBALS USED
	none

HISTORY
	19-Sep-88    Lew Brodnax
	   Creation Date
*/

	{
	IGRchar    buff[200];			/* a place to put message string for output */
	IGRchar    tcp_serve[128], r_node[128], r_user[128];
	char       *trans_type, cmd_type[10];
	IGRboolean fmu_mode;

#if defined( CLIX )
	strcpy( cmd_type, "rcmd" );
	trans_type = getenv( "FILE_TRANSFER_MODE" );
	fmu_mode = ( trans_type && !strcmp( trans_type, "FMU" ) );
#else
	strcpy( cmd_type, "rsh" );
	fmu_mode = 0;
#endif

	VEparse_server_name( server, tcp_serve, r_node, r_user );

	/* put in error reporting and clean up functions */
	fprintf( fp, "print_error () {\n" );
	fprintf( fp, "   echo \"%s: $*\" >>%s%s.log\n", outfile, working_dir, unique );
	fprintf( fp, "   echo \"\\n%s: $*\" >/dev/console\n", outfile );
	fprintf( fp, "}\n\n" );

	fprintf( fp, "clean_up () {\n" );
	fprintf( fp, "   rm -f %s%s.sh1 %s%s.ems\n", working_dir, unique, working_dir, unique );
	fprintf( fp, "   if [ \"$1\" ]\n" );
	fprintf( fp, "      then\n" );
	if ( keep_files )
	   fprintf( fp, "         :\n" );
	else
	if ( fmu_mode )
	   {
	   fprintf( fp, "         fmu \"%s\" rm %s.\\* >>%s%s.log 2>&1\n",
	            server, unique, working_dir, unique );
	   }
	else
	   {
	   fprintf( fp, "         %s \"%s\" -l \"%s\" rm %s.\\* >>%s%s.log 2>&1\n",
	            cmd_type, r_node, r_user, unique, working_dir, unique );
	   }
	fprintf( fp, "      else\n" );
	fprintf( fp, "         rm -f %s%s.log\n", working_dir, unique );
	fprintf( fp, "      fi\n" );
	fprintf( fp, "}\n\n" );

	/* put in variable initializations */
	if ( fmu_mode )
	   {
	   fprintf( fp, "server=%s\n", server );
	   }
	else
	   {
	   fprintf( fp, "server=%s\n", tcp_serve );
	   fprintf( fp, "r_node=%s\n", r_node);
	   fprintf( fp, "r_user=%s\n", r_user );
	   }
	fprintf( fp, "tst_file=/usr/tmp/%s.tst\n", unique );
	fprintf( fp, "leo_file=%s%s.leo\n", working_dir, unique );
	fprintf( fp, "log_file=%s%s.log\n", working_dir, unique );
	fprintf( fp, "ems_file=%s%s.ems\n", working_dir, unique );
	fprintf( fp, "sh1_file=%s%s.sh1\n", working_dir, unique );
	fprintf( fp, "sh2_file=%s%s.sh2\n\n", working_dir, unique );

	/* set the protections on the files */
	fprintf( fp, "chmod 777 ${log_file}\n" );
	fprintf( fp, "chmod 777 ${sh1_file}\n" );
	fprintf( fp, "chmod 777 ${ems_file}\n\n" );

	/* put in commmands to see if submitting machine is also the server  */
	/* This is done by creating a file in the /usr/tmp directory of the  */
	/* server and seeing if it appears on submitting machine.            */
	/* The file in /usr/tmp contains the HOME directory of the login     */
	/* specified on the server.  This is used later to move the files to */
	/* the HOME directory if the submitting machine is the server.       */

	if ( fmu_mode )
	   {
	   fprintf( fp, "if fmu \"${server}\" comm \"pwd >${tst_file}\" >> ${log_file} 2>&1\n" );
	   }
	else
	   {
	   fprintf( fp, "if %s \"${r_node}\" -l \"${r_user}\"  pwd \">\"${tst_file} >> ${log_file} 2>&1\n", cmd_type );
	   }
	fprintf( fp, "   then\n" );
	fprintf( fp, "      echo \"\" >/dev/null 2>&1\n" );
	fprintf( fp, "   else\n" );
	fprintf( fp, "      echo \"Error connecting to server\" >/dev/console\n" );
	fprintf( fp, "      rm -f ${sh1_file}\n" );
	fprintf( fp, "      rm -f ${ems_file}\n" );
	fprintf( fp, "      rm -f ${sh2_file}\n" );
	fprintf( fp, "      exit 0\n" );
	fprintf( fp, "   fi\n\n" );

	fprintf( fp, "if [ -r ${tst_file} ]\n" );
	fprintf( fp, "   then\n" );

	/* submitting machine is the server => move files */
	/* to HOME directory instead of using network     */
	fprintf( fp, "      Home=\"`cat ${tst_file}`\"\n" );
	fprintf( fp, "      rm ${tst_file}\n" );
	fprintf( fp, "      if [ \"${Home}\" != \"`pwd`\" ]\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            mv -f ${sh1_file} ${Home} >>${log_file} 2>&1\n" );
	fprintf( fp, "            if [ ! -r ${Home}/%s.sh1 ]\n", unique );
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  echo \"Error moving files to login directory\" >/dev/console\n" );
	fprintf( fp, "                  rm -f ${sh1_file}\n" );
	fprintf( fp, "                  rm -f ${ems_file}\n" );
	fprintf( fp, "                  rm -f ${sh2_file}\n" );
	fprintf( fp, "                  exit 0\n" );
	fprintf( fp, "               else\n" );
	fprintf( fp, "                  mv -f ${ems_file} ${Home} >>${log_file} 2>&1\n" );
	fprintf( fp, "                  if [ ! -r ${Home}/%s.ems ]\n", unique );
	fprintf( fp, "                     then\n" );
	fprintf( fp, "                        echo \"Error moving files to login directory\" >/dev/console\n" );
	fprintf( fp, "                        rm -f ${Home}/%s.sh1\n", unique );
	fprintf( fp, "                        rm -f ${ems_file}\n" );
	fprintf( fp, "                        rm -f ${sh2_file}\n" );
	fprintf( fp, "                        exit 0\n" );
	fprintf( fp, "                     fi\n" );
	fprintf( fp, "               fi\n" );
	fprintf( fp, "         fi\n\n" );

	/* Use fmu to submit batch job so the owner of the batch job will be  */
	/* the login specified on the form.  This is necessary so the user    */
	/* indicated on the form is the owner of the batch job which causes   */
	/* NQS to login as that user, run its .profile and set the current    */
	/* directory to the login directory of that user (i.e., the directory */
	/* where the files were sent).                                        */
	if ( fmu_mode )
	   {
	   fprintf( fp, "      fmu \"${server}\" command" );
	   }
	else
	   {
	   fprintf( fp, "      %s \"${r_node}\" -l \"${r_user}\" ", cmd_type );	
	   }

	fprintf( fp, " \"qsub %s.sh1\" >>${log_file} 2>&1\n\n", unique );

	fprintf( fp, "      if grep \"submitted to queue\" ${log_file} >/dev/null 2>&1\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            if [ \"${Home}\" != \"`pwd`\" ]\n" );
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  mv -f ${log_file} ${Home} >>/dev/null 2>&1\n" );
	fprintf( fp, "               fi\n" );
	ex$message( msgnumb = VE_I_JobSubmitted, buff = buff )
	fprintf( fp, "            echo \"\\n%s: %s\" >/dev/console\n", outfile, buff );
	fprintf( fp, "         else\n" );
	ex$message( msgnumb = VE_F_ExecEMS, buff = buff )
	fprintf( fp, "            print_error \"%s\"\n", buff );
	fprintf( fp, "            rm -f ${Home}/%s.sh1\n", unique );
	fprintf( fp, "            rm -f ${Home}/%s.ems\n", unique );
	fprintf( fp, "            rm -f ${sh2_file}\n" );
	fprintf( fp, "            exit 0\n" );
	fprintf( fp, "         fi\n\n" );

	fprintf( fp, "   else\n\n" );

	/* submitting machine is not the server => send files to server */

	/* put in commands to get path to DRAFT or EMS on the server node */
	VEget_product_path_for_bg( unique, fp );

	/* put in commands for fmu to send the necessary files */
	fprintf( fp, "      Files_Sent=\"\"\n" );
	fprintf( fp, "      for File in ${log_file} ${sh1_file} ${ems_file}\n" );
	fprintf( fp, "         do\n");
	if ( fmu_mode )
	   {
	   fprintf( fp, "            if fmu \"${server}\" send ${File} . >>${log_file} 2>&1\n", unique );
	   }
	else
	   {
	   fprintf( fp, "            if rcp ${File} \"${server}\":. >>${log_file} 2>&1\n", unique );		
	   }
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  Files_Sent=\"true\"\n" );
	fprintf( fp, "               else\n" );

	ex$message( msgnumb = VE_F_SendFile, buff = buff )
	fprintf( fp, "                  print_error \"%s ${File}\"\n", buff );
	fprintf( fp, "                  clean_up ${Files_Sent}\n" );
	fprintf( fp, "                  exit 0\n" );
	fprintf( fp, "               fi\n" );
	fprintf( fp, "         done\n" );

	/* put in command to initiate ems via NQS */
	if ( fmu_mode )
	   {
	   fprintf( fp, "      fmu \"${server}\" command" );
	   fprintf( fp, " \"qsub %s.sh1 >>%s.log 2>&1\" \n", unique, unique );
	   fprintf( fp, "      fmu \"${server}\" rec %s.log ${log_file}\n", unique );
	   }
	else
	   {
	   fprintf( fp, "      %s \"${r_node}\" -l \"${r_user}\" ", cmd_type );
	   fprintf( fp, " qsub %s.sh1 \">>\"%s.log 2>&1 \n", unique, unique );
	   fprintf( fp, "      rcp \"${server}\":%s.log ${log_file}\n", unique );
	   }
	fprintf( fp, "      if grep \"submitted to queue\" ${log_file} >/dev/null 2>&1\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            clean_up\n" );
	ex$message( msgnumb = VE_I_JobSubmitted, buff = buff )
	fprintf( fp, "            echo \"\\n%s: %s\" >/dev/console\n", outfile, buff );
	fprintf( fp, "         else\n" );
	ex$message( msgnumb = VE_F_ExecEMS, buff = buff )
	fprintf( fp, "            print_error \"%s\"\n", buff );
	fprintf( fp, "            clean_up ${Files_Sent}\n" );
	fprintf( fp, "         fi\n" );

	fprintf( fp, "   fi\n\n" );

	fprintf( fp, "rm ${sh2_file}\n" );
	fprintf( fp, "exit 0\n\n" );


	}  /* VEwrite_sh2_file */


/*--- VE_initialize_bg ------------------------------------------------- */

int VE_initialize_bg( gragad_id, working_dir, unique, server, nodename, keep_files, start_time, outfile )

	OM_S_OBJID gragad_id;		/* object id of gragad in batch file */
	char       *working_dir;	/* working directory for files */
	char       *unique;		/* in: unique name for files */
	char       *server;		/* in: server node name, login and password */
	char       *nodename;		/* in: submitter nodename */
	char       keep_files;		/* in: flag, T => scripts not to delete server files */
	char       *start_time;		/* start time of batch job */
	char       outfile[];		/* out: output file name */

/*
NAME
	VE_initialized_bg

DESCRIPTION
     open output file for shell script by the name unique.sh1
     put in command to cd to server target directory
     put in command to run ems
     close output file
     make file executable

     open output file for shell script by the name unique.sh2
     put in shell functions for error reporting and clean up
     put in commands to get ems directory from server
     put in commands for fmu to send the necessary files:
       unique.log unique.sh1 unique.ems
     put in command for fmu to initiate the batch ems session via unique.sh1
     close output file
     make file executable
     return output file name

PARAMETERS
	gragad_id (IN) - object id of gragad in batch file
	working_dir (IN) - working directory for files
	unique (IN) - unique name for files
	server (IN) - the server name in the form: server.node.passwd
	nodename (IN) - name of submitting node
	keep_files (IN) - flag indicating whether files should be kept
	start_time (IN) - start time of batch job
	outfile (IN) - output file name

GLOBALS USED
	none

RETURN VALUES
	OM_S_SUCCESS - successful completion
	A message number of an error message if a problem was encountered

HISTORY
	24-Aug-88  Lew Brodnax
	   Creation Date
	19-Sep-88  Lew Brodnax
	   Added commands to get ems_path from server node.
*/

	{
	int  sts;			/* status from called functions */
	FILE *fp;			/* output file descriptor */
	char login_name[L_cuserid];
	IGRchar  fname[200];

	/* get the login name */
	cuserid( login_name );
	
	/* open output file to be sent to server by the name unique.sh1 */
	sprintf( fname, "%s%s.sh1", working_dir, unique );

	fp = fopen( fname, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	VEwrite_sh1_file( fp, unique, server,nodename, login_name, gragad_id, start_time );

	fclose( fp );

	/* change mode on server script file to execute */
	sts = chmod( fname, 0777 );
	if (sts)
	   return VE_F_chmod;

	/* open output file to be run on this node by the name unique.sh2 */
	sprintf( outfile, "%s.sh2", unique );
	sprintf( fname, "%s%s", working_dir, outfile );
	fp = fopen( fname, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	VEwrite_sh2_file( fp, server, outfile, working_dir, unique, keep_files );

	fclose( fp );

	/* change mode on script file to execute */
	sts = chmod( fname, 0777 );
	if (sts)
	   return VE_F_chmod;

	return OM_S_SUCCESS;

	} /* VE_initialize_bg */


/*--- VEwrite_check_bg_results_scripts -------------------------------------------------- */

int VEwrite_check_bg_results_script( working_dir, unique, server, outfile )

	char *working_dir;
	char *unique;
	char *server;
	char outfile[];

/*
NAME
	VEwrite_check_bg_results_script

DESCRIPTION
     open output file for shell script by the name unique.sh3
     put in shell function for error reporting
     put in commands to get log file and process status from server
     put in commands to run see if ems process is running
     put in command to remove log file if ems not done
       else leave log file
     close output file
     make output file executable
     return output file name

GLOBALS USED
	none

PARAMETERS
	working_dir (IN) - working directory for files
	unique (IN) - unique name for files
	server (IN) - the server name in the form: server.node.passwd
	outfile (IN) - output file name

RETURN VALUES
	OM_S_SUCCESS - successful completion
	A message number of an error message if a problem was encountered

HISTORY
	25-Aug-88  Lew Brodnax
	   Creation Date
	19-Sep-88  Lew Brodnax
	   Added commands to get ems_path on server node, removed
	   function arguments dir and keep_files.
*/

	{
	int        sts;		/* status from called functions */
	FILE       *fp;		/* output file descriptor */
	IGRchar    tcp_serve[128], r_node[128], r_user[128];
	char       *trans_type, cmd_type[10];
	IGRboolean fmu_mode;

#if defined( CLIX )
	strcpy( cmd_type, "rcmd" );
	trans_type = getenv( "FILE_TRANSFER_MODE" );
	fmu_mode = ( trans_type && !strcmp( trans_type, "FMU" ) );
#else
	strcpy( cmd_type, "rsh" );
	fmu_mode = 0;
#endif

	VEparse_server_name( server, tcp_serve, r_node, r_user );

	/* open output file by the name unique.sh3 */
	sprintf( outfile, "%s%s.sh3", working_dir, unique );
	fp = fopen( outfile, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	if ( fmu_mode )
	   {
	   fprintf( fp, "server=%s\n", server );
	   }
	else
	   {
	   fprintf( fp, "server=%s\n", tcp_serve );
	   fprintf( fp, "r_node=%s\n", r_node );
	   fprintf( fp, "r_user=%s\n", r_user );
	   }

	fprintf( fp, "tst_file=\"/usr/tmp/%s.tst\"\n", unique );
	fprintf( fp, "log_file=\"%s%s.log\"\n", working_dir, unique );
	fprintf( fp, "leo_file=\"%s%s.leo\"\n", working_dir, unique );

	if ( fmu_mode )
	   {
	   fprintf( fp, "if fmu \"${server}\" comm \"pwd >${tst_file}\" >/dev/null 2>&1\n" );
	   }
	else
	   {
	   fprintf( fp, "if %s \"${r_node}\" -l \"${r_user}\"  pwd \">\"${tst_file} >/dev/null 2>&1\n", cmd_type );
	   }
	fprintf( fp, "   then\n" );
	fprintf( fp, "      if [ -r ${tst_file} ]\n" );
	fprintf( fp, "         then\n" );

	/* Submitting node is the server => move files instead of FMU'ing */
	
	fprintf( fp, "            Home=\"`cat ${tst_file}`\"\n" );
	fprintf( fp, "            rm ${tst_file}\n" );
	fprintf( fp, "            if [ -r ${Home}/%s.log ]\n", unique );
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  if [ -r ${Home}/%s.leo ]\n", unique );
	fprintf( fp, "                     then\n" );
	fprintf( fp, "                        cat ${Home}/%s.leo >> ${Home}/%s.log\n", unique, unique );
	fprintf( fp, "                        rm ${Home}/%s.leo >/dev/null 2>&1\n", unique );
	fprintf( fp, "                        mv ${Home}/%s.log ${log_file} >/dev/null 2>&1\n", unique );
	fprintf( fp, "                        ret_code=0\n" );
	fprintf( fp, "                     else\n" );
	fprintf( fp, "                        ret_code=1\n" );  /* Job not finished */
	fprintf( fp, "                        cp ${Home}/%s.log /usr/tmp/%s.log\n", unique, unique );
	fprintf( fp, "                     fi\n" );
	fprintf( fp, "               else\n" );
	fprintf( fp, "                  ret_code=2\n" );  /* Catastrophic failure -> no log file */
	fprintf( fp, "               fi\n" );
	fprintf( fp, "         else\n" );

	/* Submitting node is not the server => use FMU */

	if ( fmu_mode )
	   {
	   fprintf( fp, "            fmu \"${server}\" comm \"rm ${tst_file} >/dev/null 2>&1\" \n" );
	   fprintf( fp, "            if fmu \"${server}\" rec %s.log ${log_file} >/dev/null 2>&1\n", unique );
	   fprintf( fp, "               then\n" );
	   fprintf( fp, "                  if fmu \"${server}\" rec %s.leo ${leo_file} >/dev/null 2>&1\n", unique );
	   }
	else
	   {
	   fprintf( fp, "            %s \"${r_node}\" -l \"${r_user}\"  rm ${tst_file} \">\"/dev/null 2>&1 \n", cmd_type );
	   fprintf( fp, "            if rcp \"${server}\":%s.log ${log_file} >/dev/null 2>&1\n", unique );
	   fprintf( fp, "               then\n" );
	   fprintf( fp, "                  if rcp \"${server}\":%s.leo ${leo_file} >/dev/null 2>&1\n", unique );
	   }
	fprintf( fp, "                     then\n" );
	fprintf( fp, "                        cat ${leo_file} >> ${log_file}\n" );
	fprintf( fp, "                        rm -f ${leo_file}\n" );
	fprintf( fp, "                        ret_code=0\n" );
	fprintf( fp, "                     else\n" );
	fprintf( fp, "                        mv ${log_file} /usr/tmp/%s.log\n", unique );
	fprintf( fp, "                        ret_code=1\n" );  /* Job not finished */
	fprintf( fp, "                     fi\n" );
	fprintf( fp, "               else\n" );
	fprintf( fp, "                  ret_code=2\n" );  /* Catastrophic failure -> no log file */
	fprintf( fp, "               fi\n" );
	fprintf( fp, "         fi\n" );
	fprintf( fp, "   else\n" );
	fprintf( fp, "      ret_code=3\n" );  /* Server is not up */
	fprintf( fp, "   fi\n\n" );

	fprintf( fp, "rm -f %s%s.sh3\n", working_dir, unique );
	fprintf( fp, "exit ${ret_code}\n" );
	
	/* put in command to remove script when it is done */
	fclose( fp );

	/* change mode on script file to execute */
	sts = chmod( outfile, 0777 );
	if (sts)
	   return VE_F_chmod;

	return OM_S_SUCCESS;

	} /* VEwrite_check_bg_results_script */


/*--- VEwrite_retrieve_bg_results_script ---------------------------------------------- */

int VEwrite_retrieve_bg_results_script(	char       *working_dir,
					char       *unique,
					char       *server,
					char       *result_name,
					IGRboolean synchronous,
					char       outfile[] )

/*
NAME
	VEwrite_retrieve_bg_results_script

DESCRIPTION
     open output file for shell script by the name unique.sh4
     make result log file name and rename unique.log to it
     put in shell function for error reporting
     put in commands to get ems path on server
     put in commands for fmu to receive the results file, unique.ems
     put in command for fmu to delete the files from server (if not keeping)
     close output file
     make output file executable
     return output file name

PARAMETERS
	working_dir (IN) - working directory for files
	unique (IN) - unique name for files
	server (IN) - the server name in the form: server.node.passwd
	result_name (IN) - results name of background object space
	synchronous (IN) - flag, if TRUE EMS waits for script to finish
	outfile (IN) - output file name

GLOBALS USED
	none

RETURN VALUES
	OM_S_SUCCESS - successful completion
	A message number of an error message if a problem was encountered

HISTORY
	25-Aug-88  Lew Brodnax
	   Creation Date
	19-Sep-88  Lew Brodnax
	   Added commands to get ems_path from server, removed function
	   argument dir.
*/

	{
	int        sts;		/* status from called functions */
	FILE       *fp;		/* output file descriptor */
	char       buff[200];		/* a place to put message string for output */
	IGRchar    tcp_serve[128], r_node[128], r_user[128];
	char       *trans_type, cmd_type[10];
	IGRboolean fmu_mode;

#if defined( CLIX )
	strcpy( cmd_type, "rcmd" );
	trans_type = getenv( "FILE_TRANSFER_MODE" );
	fmu_mode = ( trans_type && !strcmp( trans_type, "FMU" ) );
#else
	strcpy( cmd_type, "rsh" );
	fmu_mode = 0;
#endif

	VEparse_server_name( server, tcp_serve, r_node, r_user );

	/* open output file by the name unique.sh4 */
	sprintf( outfile, "%s%s.sh4", working_dir, unique );
	fp = fopen( outfile, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	if( ! synchronous )
	   {
	   /* put in error reporting function */
	   fprintf( fp, "print_error () {\n" );
	   fprintf( fp, "   echo \"\\n%s: $*\" >>%s%s.log\n", outfile, working_dir, unique );
	   fprintf( fp, "   echo \"\\n%s: $*\" >/dev/console\n", outfile );
	   fprintf( fp, "}\n" );
	   }

	if ( fmu_mode )
	   {
	   fprintf( fp, "server=%s\n", server );
	   }
	else
	   {
	   fprintf( fp, "server=%s\n", tcp_serve );
	   fprintf( fp, "r_node=%s\n", r_node );
	   fprintf( fp, "r_user=%s\n", r_user );
	   }

	fprintf( fp, "tst_file=/usr/tmp/%s.tst\n", unique );
	fprintf( fp, "log_file=%s%s.log\n", working_dir, unique );
	fprintf( fp, "res_file=%s%s\n", working_dir, result_name );

	if ( fmu_mode )
	   {
	   fprintf( fp, "if fmu \"${server}\" comm \"pwd >${tst_file}\" >> ${log_file} 2>&1\n" );
	   }
	else
	   {
	   fprintf( fp, "if %s \"${r_node}\" -l \"${r_user}\" pwd \">\"${tst_file} >> ${log_file} 2>&1\n", cmd_type );
	   }
	fprintf( fp, "   then\n" );
	fprintf( fp, "      if [ -r ${tst_file} ]\n" );
	fprintf( fp, "         then\n" );

	/* Submitting node is the server => move files instead of FMU'ing */
	
	fprintf( fp, "            Home=\"`cat ${tst_file}`\"\n" );
	fprintf( fp, "            rm ${tst_file}\n" );
	fprintf( fp, "            mv ${Home}/%s.ems ${res_file} >>${log_file} 2>&1\n", unique );
	fprintf( fp, "            if [ -r ${res_file} ]\n" );
	fprintf( fp, "               then\n" );
	fprintf( fp, "                  if [ \"${Home}\" != \"`pwd`\" ]\n" );
	fprintf( fp, "                     then\n" );
	fprintf( fp, "                        rm ${Home}/%s.log >/dev/null 2>&1\n", unique );
	fprintf( fp, "                     fi\n" );
	fprintf( fp, "                  rm ${Home}/%s.sh1 >/dev/null 2>&1\n", unique );
	fprintf( fp, "                  ret_code=0\n" );
	fprintf( fp, "               else\n" );
	fprintf( fp, "                  ret_code=1\n" );
	fprintf( fp, "               fi\n" );

	/* Submitting node is note the server => use FMU */

	fprintf( fp, "         else\n" );
	if ( fmu_mode )
	   {
	   fprintf( fp, "            fmu \"${server}\" comm \"rm ${tst_file} >/dev/null 2>&1\" \n" );

	   fprintf( fp, "            if fmu \"${server}\" receive %s.ems ${res_file} >>${log_file} 2>&1\n", unique );
	   fprintf( fp, "               then\n" );
	   fprintf( fp, "                  fmu \"${server}\" rm %s.\\* >>${log_file} 2>&1\n", unique );
	   }
	else
	   {
	   fprintf( fp, "            %s \"${r_node}\" -l \"${r_user}\"  rm ${tst_file} \">\"/dev/null 2>&1 \n", cmd_type );
	   fprintf( fp, "            if rcp \"${server}\":%s.ems ${res_file} >>${log_file} 2>&1\n", unique );
	   fprintf( fp, "               then\n" );
	   fprintf( fp, "                  %s \"${r_node}\" -l \"${r_user}\" rm %s.\\* >>${log_file} 2>&1\n", cmd_type, unique );
	   }
	fprintf( fp, "                  ret_code=0\n" );
	fprintf( fp, "               else\n" );
	fprintf( fp, "                  ret_code=1\n" );
	fprintf( fp, "               fi\n" );
	fprintf( fp, "         fi\n" );
	fprintf( fp, "   else\n" );
	fprintf( fp, "      ret_code=1\n" );   /* Server is down */
	fprintf( fp, "   fi\n" );


	if ( ! synchronous )
	   {
	   /* put in status messages to console if running asynchronously */
	   fprintf( fp, "if [ \"${ret_code}\" = \"0\" ]\n" );
	   fprintf( fp, "   then\n" );
	   ex$message( msgnumb = VEM_M_ReEdReSe, buff = buff )
	   fprintf( fp, "      echo \"\\nDone: %s -> %s%s\" >/dev/console\n",
	            buff, working_dir, result_name );
	   fprintf( fp, "   else\n" );
	   ex$message (msgnumb = VE_F_RecResult, buff = buff, type = "%s", var =`result_name` )
	   fprintf( fp, "      print_error \"%s\"\n", buff );
	   fprintf( fp, "   fi\n" );
	   }

	fprintf( fp, "rm -f %s\n", outfile );
	fprintf( fp, "exit ${ret_code}\n" );
	fclose( fp );

	/* change mode on script file to execute */
	sts = chmod( outfile, 0777 );
	if (sts)
	   return VE_F_chmod;

	return OM_S_SUCCESS;

	} /* VEwrite_retrieve_bg_results_script */


/*--- VEverify_server_connection ----------------------------------------------------*/

IGRint VEverify_server_connection( server, user_name, password )

	IGRchar *server;
	IGRchar *user_name;
	IGRchar *password;

/*
NAME
	VEverify_server_connection

DESCRIPTION
	This function verifies that a connection to the server can be
	established and that the server is a Clipper workstation.

PARAMETERS
	server (IN) - the node name of the server
	user_name (IN) - the user name to use to connect to the server
	password (IN) - the password that goes with the user name

GLOBALS USED
	none

RETURN VALUES
	0 - if the server connection was established and the server is a Clipper
	1 - if the connection couldn't be established
	2 - if the server is not a Clipper

HISTORY
	01/28/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRint     ret;
	char       *argu[2];
	char       *trans_type, cmd_type[10];
	IGRchar    *unique1, *unique2;
	IGRboolean fmu_mode;
	FILE       *fp;

#if defined( CLIX )
	strcpy( cmd_type, "rcmd" );
	trans_type = getenv( "FILE_TRANSFER_MODE" );
	fmu_mode = ( trans_type && !strcmp( trans_type, "FMU" ) );
#else
	strcpy( cmd_type, "rsh" );
	fmu_mode = 0;
#endif

	unique1 = (IGRchar *)tempnam( "/usr/tmp", NULL );  /* tempnam mallocs output */
	unique2 = (IGRchar *)tempnam( "/usr/tmp", NULL );  /* tempnam mallocs output */

	if ( !unique1 || !unique2 )
	   return( 1 );
	
	fp = fopen( unique1, "w" );
	if ( ! fp )
	   return( 1 );

	/* put in variable initializations */
	if ( fmu_mode )
	   {
	   fprintf( fp, "server=%s.%s", server, user_name );
	   if ( strlen ( password ) )
	      fprintf( fp, ".%s\n", password );
	   else
	      fprintf( fp, "\n" );
	   }
	else
	   {
	   fprintf( fp, "r_node=%s\n", server);
	   fprintf( fp, "r_user=%s\n", user_name );
	   }
	fprintf( fp, "sh_file=%s\n", unique1 );
	fprintf( fp, "tst_file=%s\n", unique2 );

	/* put in commands to see if the server is a Clipper => this is */
	/* determined by running "uname" on the server and checking the */
	/* output for "CLIX"                                            */

	if ( fmu_mode )
	   {
	   fprintf( fp, "if fmu \"${server}\" comm uname >${tst_file} 2>/dev/null\n" );
	   }
	else
	   {
	   fprintf( fp, "if %s \"${r_node}\" -l \"${r_user}\" uname >${tst_file} 2>/dev/null\n", cmd_type );
	   }
	fprintf( fp, "   then\n" );
	fprintf( fp, "      if fgrep CLIX ${tst_file} >/dev/null 2>&1\n" );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            rm -f ${tst_file} >/dev/null 2>&1\n" );  /* server is a clipper */
	fprintf( fp, "            rm -f ${sh_file} >/dev/null 2>&1\n" );
	fprintf( fp, "            exit 0\n" );
	fprintf( fp, "         else\n" );
	fprintf( fp, "            rm -f ${tst_file} >/dev/null 2>&1\n" );  /* server is not a clipper */
	fprintf( fp, "            rm -f ${sh_file} >/dev/null 2>&1\n" );
	fprintf( fp, "            exit 2\n" );
	fprintf( fp, "         fi\n" );
	fprintf( fp, "   else\n" );
	fprintf( fp, "      rm -f ${tst_file} >/dev/null 2>&1\n" );  /* could not connect to server */
	fprintf( fp, "      rm -f ${sh_file} >/dev/null 2>&1\n" );
	fprintf( fp, "      exit 1\n" );
	fprintf( fp, "   fi\n\n" );

	fclose( fp );

	/* make script executable and run it */
	(void) chmod( unique1, 0777 );
	argu[0] = unique1;
	ret = ex$fork( num_entry = 1,
	               argu = argu,
	               wait_flag = TRUE );

	if ( unique1 )
	   free( unique1 );
	if ( unique2 )
	   free( unique2 );

	/* return code from forked script is in high order byte of 'ret' */
	return ( ret >> 8 );

	}  /* VEverify_server_connection */

