/* ###################   APOGEE COMPILED   ################## */
class implementation GRsubbc;

#include "EMS.h"
#include "maidmx.h"
#include "bsprintbspc.h"
# ifndef DEBUG
# define DEBUG 0
# endif

# include <stdio.h>

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# include "OMerrordef.h"
# include "bstypes.h"
# include "msmacros.h"
# include "madef.h" /* has MAIDMX */

/* godef.h replacement */

# ifndef madef_include
# include "madef.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

/* end of godef.h replacement */
# include "codef.h" /* has COERROR macro */
# include "EMSjbklogic.h"

/* needed for EMSmsgReport */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

/* defines EMSmsgReport */
# ifndef EMScmacros_include
# include "EMScmacros.h"
# endif

/* OM_K_MAXCLASS_LEN */
# ifndef OM_D_LIMITS
# include "OMlimits.h"
# endif

# define TempDir "/usr/tmp/"
/*# define TempDirLen sizeof(TempDir)*/
# define TempDirLen 9

# define STATUS_BUF_SIZE 40

method debug ()
{
/*
HISTORY

26-Aug-1987 J. Brooke King Modified to write out classname.  Took
                            out of permanent DEBUG mode.
05-May-1987 Moved class to GRsubbc and removed send to self
29-Dec-1986 J. Brooke King  Modified to print out the
                            element specific attributes.
19-Nov-1986 J. Brooke King  Genesis.

Sudha  06/16/93     Modified for BSprototype ansification

ALGORITHM

    First the id of this object and the number of the current
    object space (os) are written using UI_status.

    A temporary file is opened for the rest of the information.
    The id and os number are written to this file.

    Then the temporary file's name is written using UI_status. 
    This quickly overwrites the previous contents of the status
    field.  The file name is also written to stderr by fprintf.

    This object's GRvg->level, GRgraphics->properties and
    GRvg->display_attr are written to the temporary file.

    Then the element specific attributes for this object are
    retrieved and written the temporary file.

    An identity matrix is created so the abstract geometry for
    this object can be retrieved without translation and
    transformation and be written to the temporary file.  Upon
    completion of the identity matrix's creation, the abstract
    geometry is placed in the abstract geometry buffer and
    written as described.

    Finally, the debug message is recursively sent to this object
    with respect to parent (should be, anyway), and the
    relationship between this object and the abstract geometry
    buffer is severed.
*/
    void EFprtGRvgPp (), EFprtIGRdsp (), EFprtCvAttr ();
    IGRboolean status;
    struct IGResbc attributes;
    BSrc rc = MSSUCC, om_msg;
    IGRshort matrixType = MAIDMX;
    IGRmatrix idMatrix;
    struct IGRbsp_curve *curve = NULL;
    IGRint dummyInt;
  extern     char *mktemp ();
char   *fname;
    char template[TempDirLen + 15];
    static int fnum = 0, numfnum = 0;
    FILE *fp = NULL;
    char statusBuf[STATUS_BUF_SIZE], bigBuffer[2*STATUS_BUF_SIZE];
    int len;

    (void)sprintf (bigBuffer, "(%d,%ld)",
        OM_Gw_current_OS, my_id);
    len = 1 + strlen (bigBuffer);
    (void)strncpy (statusBuf, bigBuffer,
        STATUS_BUF_SIZE > len ? len :
        STATUS_BUF_SIZE );
    statusBuf[STATUS_BUF_SIZE - 1] = '\0';

    UI_status (statusBuf);

    (void)sprintf (template, "%sige%dXXXXXX", TempDir, fnum);
    if (++numfnum IS 26)
    {
        numfnum = 0;
        fnum++;
        /* this could cause trouble with a VERY large number of
            invocations of this method */
    }
    
#   if DEBUG
        fprintf (stderr, "GRsubbc.debug, about to mktemp\n");
#   endif

    (void)mktemp (template);

    if (NOT (fp = fopen (template, "w")))
    {
        fprintf (stderr,
            "debug:  Could not open log file %s\n", template);
        return OM_E_ABORT;
    }

    (void)fprintf (fp, "(os,oid) is %s\n", statusBuf);

    (void)sprintf (bigBuffer, "%s %s is log file", statusBuf,
        template);
    fprintf (stderr, "GRsubbc.debug, %s\n", bigBuffer);
    len = 1 + strlen (bigBuffer);
    (void)strncpy (statusBuf, bigBuffer,
        STATUS_BUF_SIZE > len ? len :
        STATUS_BUF_SIZE );
    statusBuf[STATUS_BUF_SIZE - 1] = '\0';

    UI_status (statusBuf);

    (void)fprintf (fp, "level %d\n", me->level);
    (void)fprintf (fp, "\n");
    EFprtGRvgPp (fp, ME.GRgraphics->properties);
    (void)fprintf (fp, "\n");
    EFprtIGRdsp (fp, /*struct IGRdisplay*/ME.GRvg->display_attr);

    om_msg = om$send
    (
        msg = message GRvg.GRgetattr
        (
            &rc, (char *)&attributes
        ),
        targetid = my_id
    );

    if (COERROR (om_msg))
    {
        fprintf (stderr,
            "debug:  Could not send GRvg.GRgetattr\n");
        fclose (fp);
        return OM_E_ABORT;
    }
    if (COERROR (rc))
    {
        fprintf (stderr,
            "debug:  Could not GRvg.GRgetattr\n");
        fclose (fp);
        return OM_E_ABORT;
    }

    (void)fprintf (fp, "\n");
    EFprtCvAttr (fp, &attributes);

    status = MAidmx (&rc, idMatrix);
    if (NOT status)
    {
        fprintf (stderr,
            "debug:  Could not make identity matrix\n");
        fprintf (fp,
            "debug:  Could not make identity matrix\n");
        fclose (fp);
        return OM_E_ABORT;
    }

    GRgetabsg (&rc, &matrixType, idMatrix, (char **)&curve,
        dummyInt);
    if (COERROR (rc))
    {
        fprintf (stderr,
            "debug:  Could not get abstract geometry\n");
        fprintf (fp,
            "debug:  Could not get abstract geometry\n");
        fclose (fp);
        return OM_E_ABORT;
    }

    /* intentional block for declaration of "classname" */
    {
        char classname[OM_K_MAXCLASS_LEN+1];

        rc = om$get_classname (object = me, classname = classname);
        if (EMSmsgReport (rc,
            "EMscdebug.I:  getting classname",
            DEBUG
        ))
        {
            fclose (fp);
            return OM_E_ABORT;
        }
        else
        {
            (void)fprintf (fp, "\n%s\n", classname);
        }
    }

    (void)BSprintbspc (fp, "", curve, FALSE);

    fclose (fp);

#   if DEBUG
        fprintf (stderr, "GRsubbc.debug, about to Root.debug\n");
#   endif

    GRabsg_del ((char *)curve);
    return OM_S_SUCCESS;
}

end implementation GRsubbc;
