/*
ABSTRACT

This is merely a driver for EFprintcode.

SYNOPSIS

EFprintcode [-{dxo} message ...]

DESCRIPTION

It is useful since we sometimes want to see the mnemonic for a
message code.  Even in sdb we might want to use this driver since
executing a shell command does not mess up the registers -- which
a command line function call could do.

This program writes to stdout the mnemonic of the message number
given in message.

Options

    -d:  The message number(s) is (are) decimal.
    -x:  The message number(s) is (are) hexidecimal.
    -o:  The message number(s) is (are) octal.

EFprintcode returns 0 if the function EFprintcode returns an okay
status and everything else went well.  EFprintcode returns 1 if
EFprintcode or another function goofed.

NOTE

The command line strings are parsed by sscanf using "%d", "%x"
and "%d" format strings.  Therefore one need not invoke
EFprintcode using "0x" or "0" prefixes for the numbers to signify
hexidecimal and octal numbers respectively.  Indeed, prefixing
one's hexidecimal number with a "0x" would cause erroneous
output.

HISTORY

4 June 1987 J. Brooke King  Creation.
*/

# include <stdio.h>
# include "EMStypedef.h"    /* EMSrc */
# include "EMSlogic.h"      /* ISNT, EMSokay */
# include "EMSmsgdef.h"     /* EMS_S_Success, EMS_E_Fail */

int  ( * OM_GA_primitives [37] ) ( ) ;

extern int som_report_error ();

extern char *optarg;

main (argc, argv)
int argc;
char *argv[];
{
    EMSrc EFprintcode ();
    EMSrc save_rc = EMS_S_Success;
    int getopt ();
    int cc;

    OM_GA_primitives[36] = som_report_error;

    while ((cc  = getopt (argc, argv, "d:x:o:")) ISNT EOF)
    {
        EMSrc rc = EMS_S_Success, message;
        char *format;

        switch (cc)
        {
        case 'd':
            format = "%d";
            break;
        case 'x':
            format = "%x";
            break;
        case 'o':
            format = "%o";
            break;
        default:
            rc = EMS_E_Fail;
        }

        if (EMSokay (rc))
        {
            int ii;

            ii = sscanf (optarg, format, &message);

            if (ii ISNT 1) rc = EMS_E_Fail;
        }

        if (EMSokay (rc))
        {
            rc = EFprintcode (stdout, message);
            (void)printf ("\n");
        }

        if (EMSerror (rc)) save_rc = EMS_E_Fail;
    }

    return EMSokay (save_rc) ? 0 : 1;
}
