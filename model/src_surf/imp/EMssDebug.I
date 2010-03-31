/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# ifndef DEBUG
# define DEBUG 0
# endif

# define DEBUGLOOPSET 1

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

# include <stdio.h>
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

#include "EMSssprops.h"

# define TempDir "/usr/tmp/"
/*# define TempDirLen sizeof(TempDir)*/
# define TempDirLen 9

# define STATUS_BUF_SIZE 40

method debug ()
{
/*
HISTORY
05/07/91    DLB             Print assoc info.
10/19/89    DLB             Removed EMSsurface.debug wrt_message send. 
                            Got and printed my classname.
14-Apr-1988 SS		    Print the fields of ss_props.
15-Nov-1988 SM		    Pass matrix and matrix type to EMget_boundaries
			    instead of NULLs. required for iso edges.
12 Oct 1988 AIC             Added matrix and matrix type to
                            EMget_boundaries message send.
26-Aug-1987 J. Brooke King Modified to write out classname.  Took
                            out of permanent DEBUG mode.  Made up
                            DEBUGLOOPSET to differentiate between
                            the notion of sending debug messages
                            to loopsets and DEBUG mode.
19-Jun-1987 rlw   Somebody packed w/o freeing
29-Dec-1986 J. Brooke King  Modified to print out the
                            element specific attributes.
19-Nov-1986 J. Brooke King  Genesis.

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
    void EFprtGRvgPp (), EFprtIGRdsp (), EFprtSfAttr ();
 extern  IGRboolean  MAidmx ();
    IGRboolean status;
  extern     IGRboolean BSprintbsps ();
    struct IGResbs attributes;
    BSrc rc = MSSUCC, om_msg;
    IGRuchar ssprops;
    IGRshort matrixType = MAIDMX;
    IGRmatrix idMatrix;
    struct IGRbsp_surface *surface = NULL;
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
        fprintf (stderr, "EMSsubbs.debug, about to mktemp\n");
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
    fprintf (stderr, "EMSsubbs.debug, %s\n", bigBuffer);
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
    EFprtSfAttr (fp, &attributes);

    /*
     * Write out the surface-properties (ss_props)
     */

    fprintf (fp, "\n");
    ssprops = ME.EMSsubbs->ss_props;
    fprintf (fp, "Surface properties (ss_props) are 0x%x:\n", ssprops);
    if (ssprops & EMSIS_RTREE_RANGE_GOOD)
      fprintf (fp, "R-tree range better\n");
    else
      fprintf (fp, "Poles range good\n");
    if (ssprops & EMSIS_RANGE_MODIFIED)
      fprintf (fp, "Range may be modified\n");
    else
      fprintf (fp, "Range may not be modified\n");
    if (ssprops & EMSIS_INACTIVE)
      fprintf (fp, "Surface is INACTIVE\n");
    else
      fprintf (fp, "Surface is ACTIVE\n");
      
    /*
     * Write the surface class-name and surface geometry
     */

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

    GRgetabsg (&rc, &matrixType, idMatrix, (char **)&surface,
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
    om_msg = om$send(msg = message EMSsubbs.EMget_boundaries(&rc,
                     &matrixType, idMatrix,
                     &surface->on_off, &surface->num_boundaries,
                     &surface->bdrys), targetid = my_id);

    EMSmsgReport (om_msg, "EMssdebug:  EMget_boundaries", DEBUG);
    EMSmsgReport (rc, "EMssdebug:  EMget_boundaries", DEBUG);

    /* intentional block for declaration of "classname" */
    {
        char classname[OM_K_MAXCLASS_LEN+1];

        rc = om$get_classname (object = me, classname = classname);
        if (EMSmsgReport (rc,
            "EMssdebug.I:  getting classname",
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

        if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
           EFprint_assoc_info(my_id, OM_Gw_current_OS);
    }

    (void)BSprintbsps (fp, "", surface, FALSE);

    fclose (fp);

#   if DEBUG
        fprintf (stderr, "EMSsubbs.debug, about to Root.debug\n");
#   endif
/*
 * Begin rlw fix
 */
 if (surface &&
     surface->num_boundaries &&
     surface->bdrys)
  {
   IGRlong      i;

   for(i = 0; i < surface->num_boundaries; i++)
    {
     om$dealloc(ptr = surface->bdrys[i].points);
    }
    om$dealloc(ptr = surface->bdrys);
   surface->num_boundaries = 0;
   surface->bdrys = NULL;
  }
/*
 * End rlw fix
 */
/************************************************************************
    Removed by DLB 10/19/89
    rc = om$send (mode=OM_e_wrt_message,
                msg = message EMSsurface.debug (), targetid = my_id);
    if (COERROR (rc))
    {
        fprintf (stderr,
          "debug:  Could not send me debug OM_e_wrt_parent\n");
        om$report_error (sts = rc);
        GRabsg_del ((char *)surface);
        return OM_E_ABORT;
    }
************************************************************************/

    {   /*Added by DLB 10/19/89*/
         IGRchar          name[OM_K_MAXCLASS_LEN];
         rc = om$get_classname(object = me,
                               classname = name);
         if (1 & rc) fprintf (stderr, "My class name = %s\n", name);
    }

    /*
     * Send debug message to the loopset
     */
#   if DEBUGLOOPSET
    {
        OM_S_CHANSELECT to_loopset;

        rc = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset        );
        if (COERROR (rc))
        {
#           if DEBUG
            fprintf (stderr,
                "debug:  Could not make_chanselect to_loopset\n");
#           endif
            om$report_error (sts = rc);
            GRabsg_del ((char *)surface);
            return OM_E_ABORT;
        }

        rc = om$send (
            msg = message Root.debug (),
            p_chanselect = &to_loopset
        );
        if (COERROR (rc))
        {
#           if DEBUG
            fprintf (stderr,
                "debug:  Could not send debug to_loopset\n");
#           endif
            om$report_error (sts = rc);
            GRabsg_del ((char *)surface);
            return OM_E_ABORT;
        }
    }
#   endif

    GRabsg_del ((char *)surface);
    return OM_S_SUCCESS;
}

end implementation EMSsubbs;
