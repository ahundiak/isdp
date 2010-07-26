/****  Driver for FTB font librarian.              ****
 ****  for Review and Create(copy) a FONTLIB file.  ****/

/*
$Log: flib.c,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:10  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:27  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:22  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:08  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:16  root
 * COMMENT : Corresponds to Rel201.5 in 2.0.1 RCS
 *
 * Revision 201.5  1992/07/13  19:17:06  tim
 * COMMENT : added Log variable
 *
*/

#include    <stdio.h>
#ifdef X11 
#include    <X11/Xlib.h>
#include    <X11/Xutil.h>
#else
#include    <tools.h>
#endif
/*
#include    "fntdata.h"
#include    "flibtpa.h"
           Contains only multiple declarations of variables .
#include    "offset_pos.h"
*/
#include    "flib_global.h"

#define EXISTS     0
#define WRITE      2
#define READ       4
#define READ_WRITE 6

#define USAGE "[cbl] font_file_name\n\
where:\n\
 -c              Create Library\n\
 -b              Brief Listing of Library\n\
 -l              Long Listing of Library\n"

char    *Cdt_n_ptr;           /* Offset pointers for create.c */
char    *Fh_n_ptr;            /* Offset pointers for list.c */
char    flib_nm[256];         /* font library name */
bool    lis_br;               /* global flag       */

main(argc,argv)
int argc;
char *argv[];
{
  int     cmd_opt=0;           /* cmmand options */
  int     status = SUCCESS;

  extern int optind, opterr;
  extern char *optarg;

  if (argc <= 2 || (*argv[argc-1]=='-'))
  {  
    printf ("USAGE: %s %s\n", argv[0], USAGE);
    status = FAILURE;
  }

/*   opterr=0;  Turn off getopt's error reporting */
   while ((cmd_opt = getopt( argc, argv, "?hcbl" )) != EOF &&
           status == SUCCESS )
   {
     /* Moved inside loop to support multi-action usage. */
     strcpy( flib_nm, argv[argc-1] );

     switch (cmd_opt)
      {
        case 'b': /* REVIEW (LIST) FONT LIBRARY CONTENTS - BRIEF FORMAT*/  
          {
            status = access(flib_nm,READ);
            if ( status == SUCCESS )
            {
              lis_br = TRUE;
              status = list_flib();       
            }
            break;
          }

        case 'c': /* CREATE A FONT LIBRARY */  
          {               
            status = access(flib_nm,EXISTS);
            if ( status == SUCCESS )
            {
              status = access(flib_nm,WRITE);
              if ( status == SUCCESS )
              {
              status = create_flib(flib_nm);
              }
            }
            else
            {
            status = create_flib(flib_nm);
            }
            break;
          }

        case 'l': /* REVIEW (LIST) FONT LIBRARY CONTENTS - FULL FORMAT*/  
          {
            status = access(flib_nm,READ);
            if ( status == SUCCESS )
            {
              lis_br = FALSE;
              status = list_flib();       
            }
            break;
          }

        default:
          {
            printf ("USAGE: %s %s\n", argv[0], USAGE);
            status = FAILURE;
            break;       
          }
      } /* End of Case */
   }  /* End of While */
  return(status);
}    
