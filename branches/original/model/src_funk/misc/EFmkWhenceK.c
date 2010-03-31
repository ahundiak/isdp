/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
NAME

EFmkWhenceK -- make a dereferencing "whence" ksh (1) script

SYNOPSIS

# include "bstypes.h"

BSrc EFmkWhenceK (filename)
char filename[];

DESCRIPTION

EFmkWhenceK writes a script to a file named filename.  This
script completely dereferences its arguments.  Its output is n +
1 lines where n is the number of arguments; the first line is n,
and the remaining lines are the completely dereferenced
arguments.  If the command cannot be dereferenced, a null string
will be placed on the line corresponding to the command.

RETURN VALUES

If EFmkWhenceK is able to write the script in the file named
filename, it returns EMS_S_Success.  Otherwise it returns
EMS_E_FileOpen.

NOTE

The script is a ksh (1) shell script.  One should use ksh to
invoke it.

HISTORY

01 Dec 1988 jBk Removed declaration of fopen since it is already
                declared by stdio.h
                Changed definition of NumLines from a hardcoded
                40 to a relative, compile-time-determined (sizeof
                (whenceArray) / sizeof (char *)).  I do not know
                why I did not think of that before.
25 Nov 1986 jBk Genesis.

SEE ALSO

ksh (1)
*/

# include <stdio.h>
                        /* we do i/o */
# include "EMSerrordef.h"
                        /* has EMS message codes */
# include "bstypes.h"
                        /* has BSrc typedef */
# include "EMSjbklogic.h"
                        /* has things like NOT and IS */

/*
The character array is supposed to filled with this ksh script:

function EFunaliasWhence {
    if unalias $1 > /dev/null 2>&1
    then
        whence $1 # now we'll see what it really is
    else
        echo $1 # probably an error, but it's the best we can do
    fi
}

function EFwhenceKsh {
    find=$1
    found=`whence $find`
    case "blap$found" in
    blap)
        echo ;;
    *)
        if [ "blap $found" = "blap $find" ]
        then
            echo $find # probably a ksh function
        else
            set $found
            find=$1
            shift
            args="$*"
            if [ "blap $found" = "blap `whence $find`" -a $# -gt 0 ]
            then
                # probably an alias like ls for ls -CF or something
                echo `EFunaliasWhence $find` $args
            else
                echo `EFwhenceKsh $find` $args
            fi
        fi ;;
    esac
}

echo $#
for name in $*
do
    EFwhenceKsh $name
done
*/

# ifdef NumLines
# undef NumLines
# endif
# define NumLines (sizeof (whenceArray) / sizeof (char *))

static char *whenceArray[] =
{
"function EFunaliasWhence {",
"    if unalias $1 > /dev/null 2>&1",
"    then",
"        whence $1 # now we'll see what it really is",
"    else",
"        echo $1 # probably an error, but it's the best we can do",
"    fi",
"}",
"",
"function EFwhenceKsh {",
"    find=$1",
"    found=`whence $find`",
"    case \"blap$found\" in",
"    blap)",
"        echo ;;",
"    *)",
"        if [ \"blap $found\" = \"blap $find\" ]",
"        then",
"            echo $find # probably a ksh function",
"        else",
"            set $found",
"            find=$1",
"            shift",
"            args=\"$*\"",
"            if [ \"blap $found\" = \"blap `whence $find`\" -a $# -gt 0 ]",
"            then",
"                # probably an alias like ls for ls -CF or something",
"                echo `EFunaliasWhence $find` $args",
"            else",
"                echo `EFwhenceKsh $find` $args",
"            fi",
"        fi ;;",
"    esac",
"}",
"",
"echo $#",
"for name in $*",
"do",
"    EFwhenceKsh $name",
"done"
};

BSrc EFmkWhenceK (filename)
char filename[];
{
    FILE *fp;
    BSrc value = EMS_S_Success;

    fp = fopen (filename, "w");
    if (NOT fp)
    {
        value = EMS_E_FileOpen;
    }
    else
    {
        int ii;

        for (ii = 0; ii < NumLines; ii++)
        {
            (void)fprintf (fp, "%s\n", whenceArray[ii]);
        }
        (void)fclose (fp);
    }

    return value;
}
