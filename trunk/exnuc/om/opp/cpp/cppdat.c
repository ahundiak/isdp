#include <stdio.h>

long int cpp_version = 0x050109;

/*
 11/10/92 version 5.1.9  - Columbus fix to read "Include" env variable to
 				get system include search path.
 				
 11/05/92 version 5.1.8  - Fix to convert filename to fix output filenames
				in #line directives.

 11/03/92 version 5.1.7  - Fix prepro to allow backslash as a valid filename
				character on NT.

 10/29/92 version 5.1.6  - Add prototypes to remove NT warnings.

 10/26/92 version 5.1.5  - Fix processing of #include to convert slashes
 				to backslashes.

 10/21/92 version 5.1.4  - Fix include of stdlib.h in find_file.c for columbus
				only.

 10/21/92 version 5.1.3  - Fix include of stdlib.h in cppout.c for columbus
				only.

 10/20/92 version 5.1.2  - Columbus mod to change #line directives to replace
 				backslash with slash.  This avoids warnings
 				about unrecognized escape sequences when
 				files with the line directives are compiled.
 				
 10/15/92 version 5.1.1  - Columbus mod for pathname separator and add binary
 				mode to file open.
 
 10/07/92 version 5.1.0  - Start NT version
 
 10/06/92 version 5.0.14 - Add ansi include path for sunc compiler.

 08/28/92 version 5.0.13 - Change to use offsetof macro for ansi portable
			   way of computing structure offsets.

 08/26/92 version 5.0.12 - Fix bug with uninitialized data in define_switch
			   and token_malloc.  This caused a core dump
			   when using -Dname=value on the command line.

 08/14/92 version 5.0.11 - Add builtin defines for sgi.

 07/06/92 version 5.0.10 - Add support for #assert.

 06/08/92 version 5.0.9  - Fix conversion of hex constants to ints.

 05/06/92 version 5.0.8  - Remove warning when redefining a symbol if the
			   two definitions are identical.

 05/06/92 version 5.0.7  - Remove warning when undefining a symbol that is
			   not already defined.

 05/05/92 version 5.0.6  - Change to not expand defines if they are defined to
			   have args but the matching identifier in the input
			   stream is not followed by a left paren.

 04/30/92 version 5.0.5  - Add #argsused directive.

 04/01/92 version 5.0.4  - Fix handling of wide character constants.

 04/01/92 version 5.0.3  - Add builtin define of __STDC__.

 03/31/92 version 5.0.2  - Add support for ansi char constants and string
                           constants.

 03/30/92 version 5.0.1  - Add support for #pragma and #error.

 03/27/92 version 5.0.0  - Add support for ansi token: ellipse.

 12/31/91 version 4.0.19 - change to look in /usr/5include before /usr/include
			   on the sun.

 10/07/91 version 4.0.18 - Remove the check for the existence of a directory
			   specified by -I.  Ignore directories that do not
			   exist.

 09/19/91 version 4.0.17 - Change command line parsing to be more robust.
			   Added a cleanup routine for SIGINT and SIGTERM.

 08/12/91 version 4.0.16 - Make source code ansi-compliant.

 05/22/91 version 4.0.15 - Fix to prepro.c.  If on the SUN, do not
			   discard tokens after processing a #include.  It
			   used to discard everything up to the first
			   newline.

 05/14/91 version 4.0.14 - Fix to prepro.c.  Look in -I paths before
			   looking in /usr/include

 05/09/91 version 4.0.13 - Fix to prepro.c.  Names of porting defines
			   have changed.

 05/07/91 version 4.0.12 - Fix fdumpit to check for NULL pointer before
			   doing a strcmp.

 05/06/91 version 4.0.11 - Fix get_to_line to check for NULL pointer before
			   doing a strcmp.

 04/26/91 version 4.0.10 - Add more architecture dependent defines.

 03/06/91 version 4.0.9 - Define sun when running on a sun.

 02/21/89 version 4.0.8 - Allow the filename on #include to be a
			  define name. (prepro.c)

 02/02/89 version 4.0.7 - Added stuff to do malloc profiling if
			  compiled -DMALLOC_PROFILE.

 06/30/87 version 4.0.6 - Changed handling of machine ID macros.
			  Only the active machine is defined and it is 1.
			  Fixed undef so that it can be used twice on
			  inherited macros to get them back.
		          Unknown preprocessor commands are ignored silently.

 06/30/87 version 4.0.5 - Fixed so that failed #undef produces warning.
			  Matching braces {} in macro parameters now hide
			  embedded commas and parens.

 03/06/87 version 4.0.4 - changed version number to reflect changes of Jan.
			  simplified prepro.c etc.
*/

void cpp_print_version()
 {
  fprintf(stderr,"OMCPP Version %d.%d.%d\n",
    (cpp_version>>16) & 0xff, (cpp_version>>8) & 0xff, cpp_version & 0xff);
 }
