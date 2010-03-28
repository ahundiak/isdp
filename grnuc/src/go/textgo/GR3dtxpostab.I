/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME: GR3dtext 
     METHOD NAME GRpostabsg
 
     Abstract: This method will post the abstract data 
            representation for a 3d floating point  text 
            graphics object back into the objects's permanent
            format.  The input structure contains a tranformation
            matrix to be applied to the object before posting.        
-----
%SC%

     VALUE =  GRpostabsg(msg,env_info,post_info,absptr,newobjid)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                     DESCRIPTION
     ----------   ------------------- -----------------------------------
     *env_info     struct GRmd_env    structure defining the transforma-
                                      tion and other info about the 
                                      object
     *post_info    struct GRpost_info processing control information
     *absptr              IGRchar     pointer to buffer containing
                                      internal format representation     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg          IGRlong         Completion code
                                    - MSSUCC if successful
                                    - GRSNOINVTRAN (severe) if 
                                      input matrix is not invertible
                                    - GRSDGNEXCEED (severe) if
                                      range exceeds design limits
                                    - MSFAIL (severe) if failure
     *newobjid    GRobjid         used if object changes classes,
                                  otherwise is same as my_id

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE            - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  MAptsxform
               MAinvmx
               MAmulmx
               MAlbextents
               GRupdaterng

     Methods:
-----
%RL%

     RELATIONS REFERENCED:

-----
%NB%

     NOTES:  If a failure occurs, the object's permanent format
             will not be modified.
-----

%CH%
     CHANGE HISTORY:
        
        DEK  03/28/86 : Design date.
        DEK  03/29/86 : Creation date.
        DEK  04/10/86 : Revision date.
        WBC  06/23/86 : Revision date.
        DEK  07/28/88 : Added view independence.
        SCW  07/22/92 : Removed copyright header
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
        This method converts the internal format (abstract geometry
form) of the text object to its 3D floating point permanent format.
Before the permanent format is modified, the internal format is 
transformed using the matrix in the md_env structure.  A new range
for the object is then calculated and compared against the design
limits.  If all tests pass, the instance data for the object is 
posted, including the range.  The updated object is inserted into
the R-tree using the new range.

----*/
/*EH*/

class implementation GR3dtext;

#include    "msdef.h"
#include    "grerr.h"
#include    "godef.h"
#include    "gocmacros.h"
#include    "gotextdef.h"
#include    "grimport.h"

method GRpostabsg (IGRlong *msg; struct GRmd_env *env_info;
                   struct GRpost_info *post_info;
                   IGRchar *absptr; GRobjid *newobjid)
{
   extern IGRboolean    MAinvmx();
   extern IGRboolean    MAmulmx();
   extern IGRdouble     MAdabs();
   extern IGRlong       GRupdaterng();

   IGRlong           status;             /* return status for method */
   IGRlong           temp_msg;
   struct IGRlbsys   *absg;              /* pointer to abstract geom */
   struct IGRlbsys   tmp_lbsys;          /* storage for local lbsys  */
   IGRshort          i;                  /* loop counter             */
   IGRshort          mxsize = 4;         /* matrix size              */
   GRrange           range;              /* range of text object     */
   GRrange           old_range;          /* old range of text        */
   IGRmatrix         invmx;              /* storage for inverse mx   */
   IGRdouble         longest_extent;     /* largest abs(coordinate)  */
   IGRdouble         tmp_pt1;
   IGRdouble         tmp_pt2;

   /*
    * initialize variables
    */

   status = OM_S_SUCCESS;
   *msg = MSSUCC;
   absg = (struct IGRlbsys *)absptr;  /* type cast pointer to lbs     */
   *newobjid = my_id;                 /* object didn't change classes */

   if (env_info->md_env.matrix_type != MAIDMX)
   {
      /* 
       * determine inverse transformation matrix
       */

      if (MAinvmx(msg,&mxsize,env_info->md_env.matrix,invmx))
      {
         /* 
          * multiply local bounded system matrix by inverse matrix
          */

         MAmulmx(msg,&mxsize,&mxsize,&mxsize,invmx,absg->matrix,
                 tmp_lbsys.matrix);
      }
      else
      {
         *msg = GRSNOINVTRAN;
         status = OM_E_ABORT;
      }
   }
   else                  /* identity matrix */
   {
      for (i = 0; i < 16; ++i)
      {
          tmp_lbsys.matrix[i] = absg->matrix[i];
      }
   }

   if (*msg & status & 1)
   {
      /*
       * determine range of text: if view independent text, must use the
       * coordinate that is the greatest distance from the origin to make
       * a psuedo diagonal box
       */

      if (me^^GRgraphics.properties & GRIS_VIEW_INDEP)
      {
         longest_extent = 0;

         for (i = 0; i < 2; ++i)
         {
            tmp_pt1 = MAdabs(msg,&(absg->diag_pt1[i]));
            tmp_pt2 = MAdabs(msg,&(absg->diag_pt2[i]));

            if (tmp_pt1 > longest_extent)
            {
               longest_extent = tmp_pt1;
            }

            if (tmp_pt2 > longest_extent)
            {
               longest_extent = tmp_pt2;
            }
         }

         tmp_lbsys.diag_pt1[0] = -longest_extent;
         tmp_lbsys.diag_pt1[1] = -longest_extent;
         tmp_lbsys.diag_pt1[2] = longest_extent;
         tmp_lbsys.diag_pt2[0] = longest_extent;
         tmp_lbsys.diag_pt2[1] = longest_extent;
         tmp_lbsys.diag_pt2[2] = -longest_extent;
      }
      else
      {
         for (i = 0; i < 3; ++i)
         {
             tmp_lbsys.diag_pt1[i] = absg->diag_pt1[i];
             tmp_lbsys.diag_pt2[i] = absg->diag_pt2[i];
         }
      }

      MAlbextents(msg,&tmp_lbsys,range,&range[3]); 

      /*
       *  check range of object against design limits
       */

      for (i = 0; i < 3; ++i)
      {
         if ((range[i] < GRDGNLIMITS_MIN_D) ||
             (range[i+3] > GRDGNLIMITS_MAX_D))
         {
            *msg = GRSDGNEXCEED;
            status = OM_E_ABORT;
         }
      }

      if (*msg & status & 1)
      {
         /*
          *  if the object is not being constructed,
          *  update the range in the object and the R-tree
          */

         if (!post_info->construct_flag && !(me->properties & GRNOT_IN_RTREE))
         {
            old_range[0] = ME.GR3dtext->geom.origin[0];
            old_range[1] = ME.GR3dtext->geom.origin[1];
            old_range[2] = ME.GR3dtext->geom.origin[2];
            old_range[3] = ME.GR3dtext->geom.origin[0];
            old_range[4] = ME.GR3dtext->geom.origin[1];
            old_range[5] = ME.GR3dtext->geom.origin[2];

            status = GRupdaterng(&temp_msg,env_info,post_info,&my_id,
                                 &me->properties,old_range,range);

            if (!(1 & status))
            {
               *msg = MSFAIL;
               status = OM_E_ABORT;
            }
         }

         if (*msg & status & 1)
         {
            /*
             * update object
             */

            for (i = 0; i < 3; ++i)
            {
               ME.GR3dtext->geom.matrix[i] = tmp_lbsys.matrix[i];
               ME.GR3dtext->geom.matrix[i+3] = tmp_lbsys.matrix[i+4];
               ME.GR3dtext->geom.matrix[i+6] = tmp_lbsys.matrix[i+8];

               ME.GR3dtext->geom.origin[i] = tmp_lbsys.matrix[4*i+3];
            }

            for (i = 0; i < 2; ++i)
            {
               ME.GR3dtext->geom.diag_pt1[i] = absg->diag_pt1[i];
               ME.GR3dtext->geom.diag_pt2[i] = absg->diag_pt2[i];
            }

            GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_POSTED);

         }
      }
   }
   return (status);
}

end implementation GR3dtext;
