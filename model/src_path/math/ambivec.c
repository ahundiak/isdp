#include  <stdio.h>
#include  <math.h>
#include  <alloca.h>
#include  "bsvalues.h"
#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/normvec.h"
#include "PWapi/angmeas.h"
#include "PWapi/angtol.h"
#include "PWapi/ambivec.h"

#define  MARKED           -1.0

/*
 *   Application Function : pwAmbiVec()
 *   ------------------------------------
 *
 *   Description
 *   -----------
 *   This function finds the number of ambiguous sets of vectors in a
 *   sorted list and also outputs the vector indices of each set.
 *
 *   Input
 *   -----
 *    int           numvecs               *
 *                                        * Number of input vectors to be
 *                                        * sorted.
 *                                        *
 *
 *    double        (*vecs)[3]            *
 *                                        * Array of vectors to be sorted.
 *                                        *
 *    double         *dirvec              *
 *                                        * Dirction vector about which
 *                                        * sorting is done.
 *                                        *
 *   int             *sort_indices        *
 *                                        * Contains sorted indices of input
 *                                        * vectors.
 *                                        *
 *   Output
 *   ------
 *                                        *
 *   int             *numambi             *
 *                                        * Number of ambiguous vector sets.
 *                                        *
 *   int             *p_ambi_indices      * Sets of ambiguous vector
 *                                        * indices.
 *                                        *
 *  Note
 *  ----
 *  Caller should allocate  1.5*(number of input vectors)*sizeof(int) to
 *  p_ambi_indices before calling this function. For each set of ambiguous
 *  vectors first value in the set will indicate the number of vectors
 *  present in that ambiguous set. The rest of the values indicate the
 *  vector indices of vectors belonging to that set.
 *  Example :
 *  If there are 4 vectors with 2 abiguous set ( 0 & 2 ) and (1 & 3 ) then
 *
 *  *numambi will be 2 while
 *  (*ambi_indices)[0] = 2; <-- First set no of vectors
 *  (*ambi_indices)[1] = 0; | Vector indices
 *  (*ambi_indices)[2] = 2; |
 *  (*ambi_indices)[3] = 2; <-- Second set no of vectors
 *  (*ambi_indices)[4] = 1; | Vector indices
 *  (*ambi_indices)[5] = 3; |
 */



PWresult      pwGetAmbiguousVecs 
( 
   int numvecs, 
   double (*vecs)[3], 
   double *dirvec,
   int *sort_indices, 
   int *numambi,
   int *p_ambi_indices 
)
{
   unsigned int        retval;
   int                 i, j, first_instance;
   int                 temp_count=0, *temp_ptr=NULL;
   PWvector            nvec0, ndvec, nvec;
   double              *p_angmeas=NULL, angtol;


   *numambi = 0;
   retval = PW_K_Success;

   /* Allocate space for 'angmeas'
    */
   p_angmeas = (double *)alloca ( (numvecs -1)*sizeof(double) );
   OnErrorState (!p_angmeas, retval, SetError(0, PW_K_DynamicMemory),
                 wrapup);

   /* Normalize the first input vector
   */
   retval = pwNormVec (vecs[0], nvec0 );
   OnErrorCode ( retval, wrapup);

   /* Normalize the dirction vector
    */
   retval = pwNormVec ( dirvec, ndvec );
   OnErrorCode ( retval, wrapup);


   /* Find the counter-clockwise angle between this vector and all
    * other vectors in the input list of vectors about the dirction
    * vector.
    */
   for( i=1; i<numvecs; i++ )
   {
      /* Get the normalized vector for the present vector
       */
      retval = pwNormVec( vecs[sort_indices[i]], nvec );
      OnErrorCode ( retval, wrapup);

      p_angmeas[i-1] = pwAngmeas (nvec0, nvec, ndvec);
   }


     if( p_ambi_indices )
     {

        /* Convert the angle values in 'angmeas' list to degrees (0 to 360)
         */
        for( i=0; i<(numvecs-1); i++)
        {
           p_angmeas[i] = pwConvertAngleMeasure (p_angmeas[i]);
        }

        first_instance = TRUE;
        angtol = pwGetZeroAngTolDeg();

        for( i=0; i<(numvecs -1); i++ )
        {
           if( (p_angmeas[i] < angtol)||(p_angmeas[i]>(360.0 - angtol)))
           {
              if(first_instance)
              {
                 *numambi += 1;
                 p_ambi_indices[0] = 2;
                 p_ambi_indices[1]    = 0;
                 p_ambi_indices[2] = sort_indices[i+1];
                 first_instance = FALSE;
                 p_angmeas[i] = MARKED;
                 temp_count    = 3;
              }
              else
              {
                 p_ambi_indices[0] = p_ambi_indices[0] +1;
                 p_ambi_indices[temp_count] = sort_indices[i+1];
                 p_angmeas[i] = -1;
                 temp_count++;
              }
           }
        }
        for( i=0; i<(numvecs -2); i++)
        {
           if( p_angmeas[i] != MARKED )
           {
              first_instance = TRUE;
              for( j=i+1; j<(numvecs-1); j++)
              {
                 if( fabs( p_angmeas[i]-p_angmeas[j]) < angtol)
                 {
                    if(first_instance)
                    {
                       *numambi += 1;
                       p_ambi_indices[temp_count] = 2;
                       p_ambi_indices[temp_count +1] = sort_indices[i+1];
                       p_ambi_indices[temp_count +2] = sort_indices[j+1];
                       p_angmeas[j] = MARKED;
                       first_instance = FALSE;
                       temp_ptr = &p_ambi_indices[temp_count];
                       temp_count += 3;
                    }
                    else
                    {
                       p_ambi_indices[temp_count] = sort_indices[j+1];
                      p_angmeas[j] = MARKED;
                       (*temp_ptr)++;
                       temp_count++;
                    }
                 }/* end of if ambiguous */
                 else
                 {
                    break;
                    /* The logic is, if at any point
                     * fabs( p_angmeas[i]-p_angmeas[j]) is greater than the tol
                     * value then for the next 'j' the difference will be still
                     * greater. So no need for further checking.
                     */
                 }
              }/* end of for 'j' */
           }/* if angmeas */
        }/* end of for 'i' */

     }/* end processing for ambiguous vectors */

   wrapup:

   PW_Wrapup( retval, "Function : pwAmbiVec() " );

   return (retval);

}/* end of function pwAmbiVec */


double     pwConvertAngleMeasure
( 
  double ang_meas
)
{
   double angle;

   if( ang_meas >=0 && ang_meas <=1.0 )
   {
       angle = 90.0 - acos( ang_meas ) * 180.0 / M_PI;
   }
   else if( ang_meas >= 1.0 && ang_meas <= 2.0 )
   {
       angle = 90.0 + acos( 2.0 - ang_meas ) * 180.0 / M_PI;
   }
   else if( ang_meas >= 2.0 && ang_meas <= 3.0 )
   {
       angle = 270 - acos( ang_meas - 2.0 ) * 180 / M_PI;
   }
   else if( ang_meas >= 3.0 && ang_meas <= 4.0 )
   {
       angle = 270.0 + acos( 4.0 - ang_meas ) * 180 / M_PI;
   }
   else
   {
      angle = 0.0;
   }

  return angle;

}/* end of function pwConvertAngleMeasure */

/*
 *   Application function name :  pwMakeNewList().
 *
 *   Description
 *   -----------
 *   This function constructs the final sorted list when some of the input
 *   vectors are ambiguous after the angle sort and the ambiguity is resolved
 *   by looking at the curvature vector and the radius of curvature. In fact
 *   this function constructs the sorted list by taking information from
 *   both the angle sort list and the curvature sort list.

 *   Input
 *   -----
 *   int    numambi                      *
 *                                       * Number of ambiguous vector sets in
 *                                       * the 'ambi_indices' list.
 *                                       *
 *
 *   int    *ambi_indices                *
 *                                       * List of vectors which were ambiguous
 *                                       * after the angle sort. After doing
 *                                       * curvature sorting the list are not
 *                                       * ambiguous any more.
 *                                       *
 *
 *   int    numsort                      *
 *                                       * Number of vecotors present in the
 *                                       * sort_indices
 *                                       *
 *
 *   int    *sort_indices                *
 *                                       * array of sorted vector indices as
 *                                       * output from angle sort
 *                                       *
 *   Output
 *   ------
 *   int    *newlist                     *
 *                                       * Array containing the final sorted
 *                                       * vector indices.
 *                                       *
 */
 

void    pwMergeAmbiguousVecs
( 
   int numambi,
   int *ambi_indices, 
   int numsort,
   int *sort_indices, 
   int *newlist 
)
{
   PWboolean                found= FALSE;
   int                      loc_count, *loc_ptr, *loc_newlistptr,
                            i, j, k;

   loc_newlistptr = newlist;

   /* Loop through the 'sort_indices' array
    */
   for( i=0; i<numsort; i++ )
   {
      /* If sort_indices[i] is present in a marked 'ambi_set' then skip it.
       */
      for( loc_count=0, loc_ptr=ambi_indices; loc_count<numambi;
           loc_ptr += abs(*loc_ptr) +1, loc_count++ )
      {
         for(j=1; j<=fabs(*loc_ptr); j++)
         {
            if( fabs( loc_ptr[j] ) == sort_indices[i] )
            {
               /* If the list is marked then skip
                */
               if( fabs( loc_ptr[0] ) != loc_ptr[0] )
               {
                  found = TRUE;
                  break;
               }
               else 
               {
                  /* Copy the vector indices in abi_set into newlist.
                   */
                  for( k=1; k<= *loc_ptr; k++ )
                  *loc_newlistptr++ = loc_ptr[k]; /* (check) ptr ovrflow */
                  /* Mark this ambi_set.
                   */
                  loc_ptr[0] = -loc_ptr[0];
                  found = TRUE;
                  break;
               }
            }/* end of 'found a match' */
         }/* end of scan through an ambi_set  */
         if( found )
            break;
      }/* end of scan through all the ambi_sets */
      if( !found )
         *loc_newlistptr++ = sort_indices[i];
      else
         found = FALSE;
   }/* end of scan throuh the sort_list */
   
}/* end of function pwMakeNewList */
                  
                  

      


