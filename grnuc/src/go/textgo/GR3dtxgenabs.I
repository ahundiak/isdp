/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dtext
     METHOD NAME:  GRgenabsg

     Abstract: 
                This method generates the abstract data
        representation for a 3-D double precision text element and
        places the data in the standard buffer.  The input
        matrix may be passed to the object representing a
        transformation to be applied to the object before
        placing it in the buffer.

-----
%SC%    

    VALUE =  GRgenabsg(msg,matrix_type,matrix,absgptr)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort       type of transformation matrix
     matrix        IGRmatrix      transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg          IGRlong         completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
                                      due to allocation problems
     **absgptr     IGRchar         pointer to abstract geometry
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  MAmulmx
               GRabsg_alloc

     Methods:  none.
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     04/11/86: Design date.
        WBC     04/11/86: Creation date.
        SCW     07/22/92: Removed copyright header
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        This method converts the 3-D double precision text element
into its internal format (abstract geometry form).
        
----*/
/*EH*/
class implementation GR3dtext;

#include    "msdef.h"
#include    "godef.h"
#include    "gocmacros.h"
#include    "gotextdef.h"
#include    "grimport.h"

method GRgenabsg(IGRlong *msg; IGRshort *matrix_type;
                 IGRmatrix matrix; IGRchar **absgptr)
{
        extern IGRboolean MAmulmx();
        extern IGRdouble  MAdabs();
        extern IGRchar    *GRabsg_alloc(); /* buffer allocation              */

        IGRlong    msg1;                   /* working completion code        */
        IGRlong    ret_status;             /* OM return status               */
        IGRshort   four = 4;               /* dimension of matrices          */
        struct     IGRlbsys   *lbs;        /* pointer to LBS structure       */
        IGRmatrix  trans_matrix;           /* matrix to hold LBS matrix      */
        IGRint     i, j, k;                /* loop counters                  */
        struct     GRabsg_hdr absg_hdr;    /* abstract header data           */
        IGRdouble  longest_extent;         /* largest abs(coordinate)        */
        IGRdouble  tmp_pt1;
        IGRdouble  tmp_pt2;

        *msg = MSSUCC;                     /* initialize to success          */
        ret_status = OM_S_SUCCESS;

        /*
         * Initialize values of the abstract geometry header.
         */

        absg_hdr.geometry_size = sizeof(struct IGRlbsys);
        absg_hdr.id.objid = my_id;
        absg_hdr.id.osnum = OM_Gw_current_OS;
        absg_hdr.matrix_type = *matrix_type;

        for (i = 0; i < 16; ++i)
        {
            absg_hdr.matrix[i] = matrix[i];
        }

        lbs = (struct IGRlbsys *) GRabsg_alloc (&msg1,&absg_hdr);

        if (1 & msg1)
        {
           if (*matrix_type != MAIDMX)
           {
               for (i=0, k=0; i < 9; i += 4)
               {
                   for (j=i; j < i+3; ++j, ++k)
                   {
                       trans_matrix[j] = me^^GR3dtext.geom.matrix[k];
                   }
               }

               trans_matrix[3]  = me^^GR3dtext.geom.origin[0];
               trans_matrix[7]  = me^^GR3dtext.geom.origin[1];
               trans_matrix[11] = me^^GR3dtext.geom.origin[2];
               trans_matrix[12] = 0;
               trans_matrix[13] = 0;
               trans_matrix[14] = 0;
               trans_matrix[15] = 1;

               MAmulmx(&msg1,&four,&four,&four,matrix,trans_matrix,
                       lbs->matrix);
           }
           else        /* identity matrix */
           {
               for (i=0, k=0; i < 9; i += 4)
               {
                   for (j=i; j < i+3; ++j, ++k)
                   {
                       lbs->matrix[j] = me^^GR3dtext.geom.matrix[k];
                   }
               }

               lbs->matrix[3]  = me^^GR3dtext.geom.origin[0];
               lbs->matrix[7]  = me^^GR3dtext.geom.origin[1];
               lbs->matrix[11] = me^^GR3dtext.geom.origin[2];
               lbs->matrix[12] = 0;
               lbs->matrix[13] = 0;
               lbs->matrix[14] = 0;
               lbs->matrix[15] = 1;
           }

           /*
            * Initialize range block diagonal points.
            */

           if (me^^GRgraphics.properties & GRIS_VIEW_INDEP)
           {
              longest_extent = 0;

              for (i = 0; i < 2; ++i)
              {
                 tmp_pt1 = MAdabs(msg,&(me^^GR3dtext.geom.diag_pt1[i]));
                 tmp_pt2 = MAdabs(msg,&(me^^GR3dtext.geom.diag_pt2[i]));

                 if (tmp_pt1 > longest_extent)
                 {
                    longest_extent = tmp_pt1;
                 }

                 if (tmp_pt2 > longest_extent)
                 {
                    longest_extent = tmp_pt2;
                 }
              }

              lbs->diag_pt1[0] = -longest_extent;
              lbs->diag_pt1[1] = -longest_extent;
              lbs->diag_pt1[2] = longest_extent;
              lbs->diag_pt2[0] = longest_extent;
              lbs->diag_pt2[1] = longest_extent;
              lbs->diag_pt2[2] = -longest_extent;
           }
           else
           {
              lbs->diag_pt1[0] = me^^GR3dtext.geom.diag_pt1[0];
              lbs->diag_pt1[1] = me^^GR3dtext.geom.diag_pt1[1];
              lbs->diag_pt1[2] = 0;

              lbs->diag_pt2[0] = me^^GR3dtext.geom.diag_pt2[0];
              lbs->diag_pt2[1] = me^^GR3dtext.geom.diag_pt2[1];
              lbs->diag_pt2[2] = 0;
           }

           *absgptr = (IGRchar *)lbs;
        }

        return (ret_status);

}

end implementation GR3dtext;
