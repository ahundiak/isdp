#include	<string.h>
#include 	<stdio.h>
#include 	<errno.h>
#include 	<sys/types.h>
#include        <sys/stat.h>
#include 	<dirent.h>
#include	<ctype.h>

#define PDM_S_SUCCESS 0

char            PDMCWD[100];
char            ENV_FILE[100];
char            PDM_DEBUG_FILE[100];
int debug_on;

/****************************************************************************
Name
    main
Abstract
   A converter  written to go through all the nfms_xxxx, and nfme_xxx
   files and create the NFMenv.dat.

Synopsis

Description
   Input:
      -d <debug files>
   Input/Output:
    debug file
   Output:
    NFMenv.bat, debug file
   Algorithm:
   1) Open the directory /usr/lib/nodes/heard directory.
   2) Get the files starting with pdms_
   2) Sort the file alphabatically.
   3) Open each file
       1. Read the information from the file.
       2. Put the information in the NFMenv.bat file
   4) Open the directory /usr/lib/nodes/heard directory.
   5) Get the files starting with pdme_
   6) Sort the file alphabatically.
   7) Open each file
       1. Read the information from the file.
       2. Put the information in the NFMenv.bat file



Return Values

Notes
NFMenv.dat FILE FORMAT
-----------------------

The NFMenv.dat file holds the information regarding servers and environment.

The file has following rules

1. # in the first column indicates a comment.

2. ( \001) is used as a separator.

3. Newline starts a new set of data.

4. ::  indicates end of a set of data.

5. The first set of data includes

#Name of the server, node on which the server will run.

servernamenodename

6. The second set of data includes

#Name of the environment, Application Name (e.g. PDM, NFM ... ),
#Node information where the schema file resides, encrypted schema name,
#encrypted schema password, encrypted username, and encrypted user_password

environmentnameAppl_NAMEnodenameschema_nameschema_passwordusernameuser_password

7. The protocol information is NOT stored. The default protocol will be TCP/IP.
   The protocol information may be obtained using "gethostbyname" type of calls.

Example file

========================================================+++====================
#This is a consolidated data file for I/NFM.
#
#
#
#Name of the server, node on which the server will run.
nfms_kumarnana
nfms_newpdmdel
nfms_xyzw120
nfms_goodb30
nfms_badb12
::
#Name of the environment, Application Name (e.g. PDM, NFM ... ),
#Node information where the schema file resides, encrypted schema name,
#encrypted schema password, encrypted username, and encrypted user_password
nfme_goodb30T3Arv_1_q{p-I9tX[h:>Zr;--B"d\STe(8UWb>%zY~!CK`^Pd*:f3'vdb}z14P;?$}]85o_=:"45v$H\9Coz%T2<Dm2jYiz3U(6DNFM
nfme_badb15T3Arv_1_q{p-I9tX[h:>Zr;--B"d\STe(8UWb>%zY~!CK`^Pd*:f3'vdb}z14P;?$}]85o_=:"45v$H\9Coz%T2<Dm2jYiz3U(6DPDM
nfme_gooddatamgmtT3Arv_1_q{p-I9tX[h:>Zr;--B"d\STe(8UWb>%zY~!CK`^Pd*:f3'vdb}z14P;?$}]85o_=:"45v$H\9Coz%T2<Dm2jYiz3U(6DNFM
::
================================================================================
Index

Keywords

History
   Kumar Narayanan Fri Mar 19 11:44:59 CST 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


main(int argc, char **argv)
{
	long             status = PDM_S_SUCCESS;
        PDM_DEBUG_FILE[0] = '\0';
       
      if(argc == 2)
        {
/* PS - to print the usage */
        if ( !(strcmp(argv[1], "-?")) )
        {
            fprintf(stdout, "Usage: %s [-d][debug_file_name]\n\n", argv[0]);
            exit(0);
        }
                fprintf(stdout,"DEBUG ON .....\n\n\n");
                fflush(stdout);
                strcpy(PDM_DEBUG_FILE,"/usr/tmp/pdm.dbg");
                debug_on = 1;
        }
      else if(argc == 3)
        {
                fprintf(stdout,"DEBUG ON .....\n\n\n");
                fflush(stdout);
                strcpy(PDM_DEBUG_FILE,argv[2]);
                debug_on = 1;
         }
     else debug_on = 0;

     status = nfmClhToTcpConvertor();
     if(status != PDM_S_SUCCESS)
     {
     fprintf(stdout,"Error in converting the environment and server files \n");
     fflush(stdout);
     }
     exit (0);
}

