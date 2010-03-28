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
Name
        GRgencs.GRpostabsg

Description
        This method converts the internal format (abstract geometry
        form) of a GRgencs object to its permanent format.  Before
        the permanent  format is modified, the internal format is 
        transformed using the matrix in the md_env structure. A new 
        range for the object is then calculated and compared against 
        the design limits.  If all tests pass, the instance data for
        the object is posted, including the range. The updated object
        is inserted into the R-tree using the new range. This method
        will post the abstract data representation for a GRgencs
        object back into the objects's permanent format. Note that
        if a failure occurs, the object's permanent format will not
        be modified.
 
Synopsis
        IGRlong             *msg        o completion code
                                            MSSUCC if successful
                                            GRSNOINVTRAN (severe) if input
                                                matrix is not invertible
                                            MSFAIL (severe) if failure
        struct GRmd_env     *env_info   i information about the current module
        struct GRpost_info  *post_info  i processing control information
        IGRchar             *absptr     i points to internal format
        GRobjid             *newobjid   o different from my_id only if object
                                          changes class
History
        Kumar Talluri   10/15/86    design and implementation
        mrm             08/03/88    remove unnecessary variables
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "gocmacros.h"

extern IGRboolean MAptsxform();  
extern IGRboolean MAinvmx();
extern IGRboolean MAmulmx();

method GRpostabsg (IGRlong *msg;
                   struct GRmd_env *env_info;
                   struct GRpost_info *post_info;
                   IGRchar *absptr;
                   GRobjid *newobjid)
{
    IGRshort         i;             /* loop counter             */
    IGRlong          sts;           /* return status for method */
    IGRmatrix        invmx;         /* storage for inverse mx   */
    IGRmatrix        tmp_matrix;    /* storage for local matrix */
    GRrange          range;         /* range of text object     */
    GRrange          old_range;     /* old range of text        */
    struct IGRlbsys *absg;          /* pointer to abstract geom */

    /*
     * initialize variables
     */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    absg = (struct IGRlbsys *) absptr;
    *newobjid = my_id;

    if (env_info->md_env.matrix_type != MAIDMX)
    {
        /* 
         *  determine inverse transformation matrix
         */

        i = 4;

        if (!MAinvmx (msg, &i, env_info->md_env.matrix, invmx))
        {
            *msg = GRSNOINVTRAN;
            goto finish;
        }

        /* 
         *  multiply local bounded system matrix by inverse matrix
         */

        if (!MAmulmx (msg, &i, &i, &i, invmx, absg->matrix, tmp_matrix))
        {
            *msg = MSFAIL;
            goto finish;
        }
    }
    else /* identity matrix */
    {
        for (i = 0; i < 16; i++)
        {
            tmp_matrix[i] = absg->matrix[i];
        }
    }

    /*
     *  low and high range = origin
     */

    for (i = 0; i < 3; ++i)
    {
        range[i] = range[i + 3] = absg->matrix[(i * 4) + 3];
    }

    /*
     *  if the object is not being constructed,
     *  update the range in the object and the R-tree
     */

    if (!post_info->construct_flag)
    {
        old_range[0] = me->matrix[3];     /* origin */
        old_range[1] = me->matrix[7];
        old_range[2] = me->matrix[11];
        old_range[3] = me->matrix[3];
        old_range[4] = me->matrix[7];
        old_range[5] = me->matrix[11];
  
        sts = GRupdaterng (msg, env_info, post_info, &my_id, &me->properties,
                           old_range, range);
        if (!sts)
        {
            *msg = MSFAIL;
        }
    }

    /*
     *  update object
     */

    for (i = 0; i < 16; ++i)
    {
        me->matrix[i] = tmp_matrix[i];
    }

finish:
      
    GR_NOTIFY_LISTENERS (msg, &sts, GR_GEOM_POSTED);

    return (sts);
}

end implementation GRgencs;
