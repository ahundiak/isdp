
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <FI.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "exmacros.h"

#include "HSplot.h"
#include "HSplot_def.h"

#include "wl.h"
#include "HSpr_hplot.h"


#define VE_F_OpenFile	1
#define VE_F_chmod	4

#define DEBUG	0

#if defined (__STDC__)
#define L_cuserid    9
#endif

/*
 *  Prototype declaration for static functions
 */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HPsubmit_job.C */
static int HPcreate_scripts __((	char *unique, 
					char *server, 
					char keep_files, 
					char *dimensions, 
					char *resolution, 
					char *plotfile_name, 
					char *rasterfile_name, 
					char *outfile));

#if defined(__cplusplus)
}
#endif


#undef __


/*--- HPcreate_scripts ------------------------------------------------- */

/*
NAME
	HPcreate_scripts
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	This is really old stuff.  It appears to make a	script file for 
	running HSmkrf, which was HSplot's original name.  This would allow
	us to run HSplot or HSmkrf from a batch queue.
	
PARAMETERS
	unique		:
	server		:
	keep_files	:
	dimensions	:
	resolution	:(IN) : resolution at which to create the rasterfile
	plotfile_name	:(IN) : name of the shaded plotfile
	rasterfile_name	:(IN) : name of the output rasterfile
	outfile		:
	
NOTES
	This is not being called today.  Can it be taken out???
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HPcreate_scripts( char *unique,
				     char *server,
				     char keep_files,
				     char *dimensions,
				     char *resolution,
				     char *plotfile_name,
				     char *rasterfile_name,
				     char *outfile )
#else
	static int HPcreate_scripts(
				unique, 
				server, 
				keep_files,
				dimensions,
				resolution,
				plotfile_name,
				rasterfile_name,
				outfile )

	char	*unique;
	char	*server;
	char	keep_files;
	char	*dimensions;
	char	*resolution;
	char	*plotfile_name;
	char	*rasterfile_name;
	char	*outfile;
#endif
	{
	int  sts;			/* status from called functions */
	FILE *fp;			/* output file descriptor */
	char buff[200];			/* a place to put message string for output */
	char login_name[L_cuserid];
	char  fname[200];

	/* get the login name */
	
	cuserid( login_name );
	
	/* open output file to be sent to server by the name unique.sh1 */
	
	sprintf( fname, "%s.sh1", unique );

	fp = fopen( fname, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	/* put in NQS commands to set submittal options */
	
	fprintf( fp, "#\n" );
	fprintf( fp, "# @$-o  %s.leo\n", unique );
	fprintf( fp, "# @$-eo\n" );
	fprintf( fp, "# @$-q hplotmkrf\n" );
	fprintf( fp, "# @$\n" );
	fprintf( fp, "#\n\n" );

	fprintf( fp, "if [ ${hplot_path} ]\n" );
	fprintf( fp, "  then\n" );
	fprintf( fp, "    ${hplot_path}/HSmkrf " );
	fprintf( fp, "      -e%s -r%s -f%s -o%s \n", 
		dimensions, resolution, plotfile_name, rasterfile_name );
	fprintf( fp, "    rm %s\n", plotfile_name );
	fprintf( fp, "  else\n" );
	fprintf( fp, "    echo \"HSmkrf not found\"\n" );
	fprintf( fp, "fi\n" );

	fclose( fp );

	/* change mode on server script file to execute */
	
	sts = chmod( fname, 0777 );
	if (sts)
	   return VE_F_chmod;

	/* open output file to be run on this node by the name unique.sh2 */
	
	sprintf( outfile, "%s.sh2", unique );
	fp = fopen( outfile, "w" );
	if (! fp)
	   return VE_F_OpenFile;

	/* put in error reporting and clean up functions */
	
	fprintf( fp, "print_error () {\n" );
	fprintf( fp, "   echo \"HPLOT: $*\" >>%s.log\n", unique );
	fprintf( fp, "   echo \"HPLOT: $*\" >/dev/console\n" );
	fprintf( fp, "}\n" );
	fprintf( fp, "clean_up () {\n" );
	fprintf( fp, "   if [ \"$1\" ]\n" );
	fprintf( fp, "      then\n" );
	if ( keep_files )
	   fprintf( fp, "         :\n" );
	else
	   fprintf( fp, "         fmu \"%s\" rm %s.\\* >>%s.log 2>&1\n",
	            server, unique, unique );
	fprintf( fp, "      else\n" );
	fprintf( fp, "         rm -f %s.log\n", unique );
	fprintf( fp, "   fi\n" );
	fprintf( fp, "}\n\n" );

	fprintf( fp, "server=%s\n", server );
	fprintf( fp, "leo_file=%s.leo\n", unique );
	fprintf( fp, "log_file=%s.log\n", unique );
	fprintf( fp, "sh1_file=%s.sh1\n", unique );
	fprintf( fp, "sh2_file=%s.sh2\n", unique );
	fprintf( fp, "plt_file=%s\n", plotfile_name );

	/* put in commands for fmu to send the necessary files */
	
	fprintf( fp, "Files_Sent=\"\"\n" );
	fprintf( fp, "for File in ${log_file} ${sh1_file} ${plt_file}\n" );
	fprintf( fp, "   do\n");
	fprintf( fp, "      if fmu \"${server}\" send ${File} . >>${log_file} 2>&1\n", unique );
	fprintf( fp, "         then\n" );
	fprintf( fp, "            Files_Sent=\"true\"\n" );
	fprintf( fp, "         else\n" );

	sprintf( buff, "HPLOT: error sending file" );
	fprintf( fp, "            print_error \"%s ${File}\"\n", buff );
	fprintf( fp, "            clean_up ${Files_Sent}\n" );
	fprintf( fp, "            exit 0\n" );
	fprintf( fp, "      fi\n" );
	fprintf( fp, "   done\n" );

	/* put in command to initiate ems via NQS */
	
	fprintf( fp, "fmu \"${server}\" command" );
	fprintf( fp, " \"qsub %s.sh1 >>%s.log 2>&1\" \n", unique, unique );
	fprintf( fp, "fmu \"${server}\" rec %s.log ${log_file}\n", unique );
	fprintf( fp, "if grep \"submitted to queue\" ${log_file} >/dev/null 2>&1\n" );
	fprintf( fp, "   then\n" );
	fprintf( fp, "      clean_up\n" );
	
	sprintf( buff, "job submitted on remote node" );
	fprintf( fp, "      echo \"HPLOT: %s\" >/dev/console\n", buff );
	fprintf( fp, "   else\n" );
	sprintf( buff, "error submitting job on remote node" );
	fprintf( fp, "      print_error \"HPLOT: %s\"\n", buff );
	fprintf( fp, "      clean_up ${Files_Sent}\n" );
	fprintf( fp, "fi\n" );

	fprintf( fp, "rm ${sh2_file}\n" );
	fprintf( fp, "rm ${sh1_file}\n" );
	fprintf( fp, "rm ${plt_file}\n" );
	fprintf( fp, "exit 0\n" );

	fclose( fp );

	/* change mode on script file to execute */
	
	sts = chmod( outfile, 0777 );
	if (sts)
	   return VE_F_chmod;

	return (int)0;

	} /* HPcreate_scripts */

/*---HPsubmit_job----------------------------------------------------------*/

/*
NAME
	HPsubmit_job
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	calls ex$form to submit a shaded plot job to a BATCH queue
	
PARAMETERS
	plotfile_name
	rasterfile_name
	plot_dimensions
	plot_resolution
	remove_node
	
NOTES
	This sould not be being called today.  Can we take it out???
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	HPsubmit_job( char *plotfile_name,
		      char *rasterfile_name,
		      char *plot_dimensions,
		      char *plot_resolution,
		      char *remote_node )
#else
	HPsubmit_job(	plotfile_name,
			rasterfile_name,
			plot_dimensions,
			plot_resolution,
			remote_node )

	char	*plotfile_name;
	char	*rasterfile_name;
	char	*plot_dimensions;
	char	*plot_resolution;
	char	*remote_node;
#endif

	{
	IGRlong		status;
	IGRchar		unique[100];
	IGRchar		script2[100];
	IGRint		i;
	IGRchar		*argu[2];
	
	/*
	 *  create shell scripts for job submission
	 */

#	if DEBUG	 
	fprintf( stderr, "HPsubmit_job\n" );
	fprintf( stderr, "   plotfile_name ---- %s\n", plotfile_name );
	fprintf( stderr, "   rasterfile_name -- %s\n", rasterfile_name );
	fprintf( stderr, "   plot_dimensions -- %s\n", plot_dimensions );
	fprintf( stderr, "   plot_resolution -- %s\n", plot_resolution );
	fprintf( stderr, "   remote_node ------ %s\n", remote_node );
#	endif

	/*
	 *  create a unique name
	 */
	 
	for( i=0; i<strlen( plotfile_name ); i++ )
		{
		if( plotfile_name[i] == '.' ) break;
		unique[i] = plotfile_name[i];
		}
		
	unique[i] = 0;

#	if DEBUG		
	fprintf( stderr, "   unique ----------- %s\n", unique );
#	endif
	
	HPcreate_scripts(
			unique,
			remote_node,
			(int)0,
			plot_dimensions,
			plot_resolution,
			plotfile_name,
			rasterfile_name,
			script2 );

#	if DEBUG			
	fprintf( stderr, "   script2 ---------- %s\n", script2 );
#	endif

	argu[0] = script2;
	
	status = ex$fork( num_entry   = 1,
			  argu        = argu,
			  delete_flag = 0 );
			  
	if( status == 0 )
		{
		fprintf( stderr, "Error Forking Background Script\n" );
		}
	}
