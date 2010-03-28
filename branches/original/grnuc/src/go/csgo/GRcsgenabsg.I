/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Method
        GRgencs.GRgenabsg

Description
        This method generates the abstract data representation for a
        coordinate system and places the data in a standard buffer.

Synopsis
        IGRlong    *msg             o - return code
                                        MSSUCC - successful completion
                                        MSFAIL - allocation problems
        IGRshort   *matrix_type     i - of module transformation matrix
        IGRmatrix   matrix          i - local-to-world transformation matrix
        IGRchar   **absgptr         o - pointer to abstract geometry

History
        Kumar Talluri   10/15/86    design and implementation
        mrm             08/03/88    remove unnecessary variables
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

extern IGRchar      *GRabsg_alloc(); /* buffer allocation */
extern IGRboolean    MAmulmx();      /* matrix multiplication routine */

method GRgenabsg (IGRlong      *msg;
                  IGRshort     *matrix_type;
                  IGRmatrix     matrix;
                  IGRchar     **absgptr)
{
    IGRshort            i;              /* loop counter */
    IGRlong             sts;            /* return code */
    struct IGRlbsys    *lbs;            /* pointer to LBS structure */
    struct GRabsg_hdr   absg_hdr;       /* abstract header data */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  initialize values of the abstract geometry header
     */

    absg_hdr.id.objid = my_id;
    absg_hdr.id.osnum = OM_Gw_current_OS;
    absg_hdr.matrix_type = *matrix_type;
    absg_hdr.geometry_size = sizeof (struct IGRlbsys);

    for (i = 0; i < 16; ++i)
    {
        absg_hdr.matrix[i] = matrix[i];
    }

    lbs = (struct IGRlbsys *) GRabsg_alloc (msg, &absg_hdr);

    if (!(*msg & 1)) /* error allocating */
    {
        goto finish;
    }

    if (*matrix_type != MAIDMX)
    {
        i = 4;

        if (!MAmulmx (msg, &i, &i, &i, matrix, me->matrix, lbs->matrix))
        {
            goto finish;
        }
    }
    else
    {
        for (i = 0; i < 16; ++i)
        {
            lbs->matrix[i] = me->matrix[i];
        } 
    }

    /*
     *  Initialize range block diagonal points.
     */

    lbs->diag_pt1[0] = 0;
    lbs->diag_pt1[1] = 0;
    lbs->diag_pt1[2] = 0;

    lbs->diag_pt2[0] = 0;
    lbs->diag_pt2[1] = 0;
    lbs->diag_pt2[2] = 0;

    *absgptr = (IGRchar *)lbs;

finish:

    return (sts);
}

end implementation GRgencs;
