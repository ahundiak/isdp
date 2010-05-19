/* $Id: VD_isl_regex.c,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/*************************************************************************
 * I/VDS>
 *
 * File:        vdregex/VD_isl_regex.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VD_isl_regex.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/03/14  18:24:00  pinnacle
 * Created: vdregex/VD_isl_regex.c by jwfrosch for vds.240
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *	03/14/96     HF		Temporary FIX for "Generate BEAM/WELD/PLATE Report from Model"
 *				failure in I/STRUCT on Solaris, due to fact that the INCORRECT
 *				library is used to link $MODEL/bin/Model
 *
 *************************************************************************/

/*

  To fix the problem of the "Generate BEAM/WELD/PLATE Report from Model" command on INTEL/Solaris
  it is necessary to:

  (1) rebuild the $MODEL/bin/Model executable with 'libgen.a' in stead of 'SUN_libPW.o & libregexp.a'.
      ($GRNUC/islmakelib has to be changed accordingly !)


      ( It is possible to extract the object modules regcmp.o & regex.o from 'libgen.a' and to
        create a relocatable .so file, which could be used for dynamic loading, but unfortunately
        it will contain the global variable '__loc1' which causes dynamic loading to fail. )

  (2) change the file 'vsreports/VSreportobjs.C'.
      In function VSprecompile() replace:

	#define STR	"(\".{0,29}\")"		( ### Allows ANY character ### )


		with

	#define STR	"(\"[\t -~]{0,29}\")"	( ### Allow <TAB> + '\040' - '\177' characters ### )

  ------------------------------------------------------

  To link THIS file:

    cc -o VD_isl_regex_gen VD_isl_regex.c -lgen	( ### Solaris: Use regcmp() & regex() from libgen.a ### )
    cc -o VD_isl_regex_PW  VD_isl_regex.c -lPW	( ### CLIX   : Use regcmp() & regex() from libPW.a  ### )

	or

    cc -o VD_isl_regex_SUN VD_isl_regex.c $GRNUC/lib/isl/SUN_libPW.o $GRNUC/lib/isl/libregexp.a
				( ### These are used for $MODEL/bin/Model on Solaris ### )

  ------------------------------------------------------

  To run/test the executables:

		- Requires an existing file ".str_rpt_1" to take its input from;

  		- which is created by the function VS_tmp_regex_solaris()
  		  in sourcefile struct/vsreports/VSreportobjs.C

  NOTICE the difference in execution of 'VD_isl_regex_gen' versus 'VD_isl_regex_SUN' !!!

  ------------------------------------------------------
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <pw.h>

extern char	*__loc1;

#define	MAXARGS		10
#define	MAXARGSIZE	32

main
(
  int    argc,
  char **argv
)
{
  FILE *fp;
  char  tst[1024];
  char  pre[1024];
  char  ret[MAXARGS][MAXARGSIZE];
  char *cmp = NULL, *lst = NULL;
  int   i0, sts, dbg = 0;

  memset ( ret, 0, MAXARGS * MAXARGSIZE );

  if ( argc > 1 )
  {
    if ( strcmp ( "DEBUG", argv[1] ) == 0 ) dbg = 1;
  }

  if ( fp = fopen ( ".str_rpt_1", "r" ) )
  {
    fgets ( pre, sizeof ( pre ), fp );
    fgets ( tst, sizeof ( tst ), fp );
    fclose ( fp );

    /*
     * Remove '\n' at end...
     */
    if ( pre[strlen(pre) - 1] == '\n' ) pre[strlen(pre) - 1] = '\0';
    if ( tst[strlen(tst) - 1] == '\n' ) tst[strlen(tst) - 1] = '\0';

    if ( dbg )
    {
      printf ( "\n>>>>>>>>>> START execution of VD_isl_regex\n\n" );
      printf ( "    tst = <%s>\n", tst );
      printf ( "    pre = <%s>\n", pre );
    }

    cmp  = regcmp ( pre, (char *)0);

    if ( dbg ) printf ( "    cmp = <%s>\n", cmp );

    lst = regex ( cmp, tst, ret[0], ret[1], ret[2], ret[3], ret[4], ret[5], ret[6], ret[7], ret[8], ret[9] );

    if ( cmp ) free ( cmp );

    if ( fp = fopen ( ".str_rpt_2", "w" ) )
    {
      for ( i0=0; i0 < 10 && ret[i0][0] ; i0++ )
      {
	if ( dbg )
	{
	  printf ( "    ret[%d] = <%s>\n", i0, ret[i0] );
	}
	fprintf ( fp, "%s\n", ret[i0] );
      }
      fclose ( fp );
      sts = 0;
      if ( dbg ) printf ( "  Successfull execution of VD_isl_regex\n" );
      goto quit;
    }
    else
    {
      if ( dbg ) printf ( "  Failed to open .str_rpt_2 for WRITE\n" );
      sts = -2;
      goto quit;
    }
  }
  else
  {
    if ( dbg ) printf ( "  Failed to open .str_rpt_1 for READ\n" );
    sts = -1;
    goto quit;
  }

quit:

  if ( dbg ) printf ( "\n<<<<<<<<<< END   execution of VD_isl_regex\n\n" );
  exit (sts);
}
