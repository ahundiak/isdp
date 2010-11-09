#include "OMminimum.h"
#include <stdio.h>
#include <memory.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "sys/types.h"
#include "DEso.h"


DEset_bdrys ( bdrys, symbs, count, u1, u2, u3, u4, u5, u6, symb1, symb2, symb3 )
              IGRdouble bdrys [6]	/* the resulting boundaries		   OUT */;
              struct    IGRdisplay symbs [3] /* symbologies				 OUT */;
              int       count	          /* number of boundaries			IN  */;
              IGRdouble u1, u2	        /* the first boundary		   	IN  */,
                        u3, u4	        /* the second boundary		  IN  */,
                        u5, u6	        /* the third boundary		    IN  */;
              struct IGRdisplay *symb1	/* symbology for [u1, u2]		IN  */,
                                *symb2	/* symbology for [u3, u4]		IN  */,
                                *symb3	/* symbology for [u5, u6]		IN  */;
/*
   This function fills out bdrys and symbs with u[i] and symb[i] 
   i = 0, ... count.
*/
{
  switch (count)
  {
    case 3: bdrys [4] = u5;
            bdrys [5] = u6;
            symbs [2] = *symb3;
    case 2: bdrys [2] = u3;
            bdrys [3] = u4;
            symbs [1] = *symb2;
    case 1: bdrys [0] = u1;
            bdrys [1] = u2;
            symbs [0] = *symb1;
            break;
    default: printf ( "DEset_bdrys: bad count (%d)\n", count );
  }
  
  return 1;
}


#define DEorder( u1, u2, u3, u4 ) (u1) <= (u2) && (u2) <= (u3) && (u3) <= (u4)


DEinter_bound ( p_count, bdrys, symbs, u1, u2, u3, u4, symb1, symb2 )
                int    *p_count	/* number of boundaries			OUT */;
                IGRdouble bdrys [6]/* the resulting boundaries		OUT */;
                struct IGRdisplay symbs [3] 
                                /* symbologies				OUT */;
                IGRdouble u1, u2	/* the first boundary		     	IN  */,
                          u3, u4	/* the second boundary		        IN  */;
                struct IGRdisplay *symb1
                		/* symbology for [u1, u2]		IN  */,
                                  *symb2
                                /* symbology for [u3, u4]		IN  */;
/*
   This function makes sure that [u1, u2] doesn't intersect [u3,u4] 
   and if it does, the boundaries are modified so they don't intersect 
   anymore.  The resulting boundaries are returned in bdrys.  Note that
   *p_count is NULL if the boundaries don't intersect.  We are sure that
   u1 < u2 and u3 < u4.
*/
{
  /* we have six cases */
  if (DEorder ( u3, u4, u1, u2 ))
    /* u3 <= u4 <= u1 <= u2: unchanged */
    *p_count = 0;
  else
    if (DEorder ( u1, u2, u3, u4 ))
      /* u1 <= u2 <= u3 <= u4: unchanged */
      *p_count = 0;
    else
      if (DEorder ( u1, u3, u2, u4 ))
        /* u1 <= u3 <= u2 <= u4 */
        DEset_bdrys ( bdrys, symbs, *p_count = 2, u1, u3, u3, u4, 0.0, 0.0, symb1, symb2, (struct IGRdisplay *)NULL );
      else
        if (DEorder ( u3, u1, u2, u4 ))
          /* u3 <= u1 <= u2 <= u4 */
          DEset_bdrys ( bdrys, symbs, *p_count = 1, u3, u4, 0.0, 0.0, 0.0, 0.0, symb2, (struct IGRdisplay *)NULL, (struct IGRdisplay *)NULL );
        else
          if (DEorder ( u1, u3, u4, u2 ))
            /* u1 <= u3 <= u4 <= u2 */
	    if ((u1 == u3) || (u2 == u4))
              /* u3 <= u1 <= u4 <= u2 */
              DEset_bdrys ( bdrys, symbs, *p_count = 2, u3, u4, u4, u2, 0.0, 0.0, symb2, symb1, (struct IGRdisplay *)NULL );
            else
              DEset_bdrys ( bdrys, symbs, *p_count = 3, u1, u3, u3, u4, u4, u2, symb1, symb2, symb1 );
          else
            if (DEorder ( u3, u1, u4, u2 ))
              /* u3 <= u1 <= u4 <= u2 */
              DEset_bdrys ( bdrys, symbs, *p_count = 2, u3, u4, u4, u2, 0.0, 0.0, symb2, symb1, (struct IGRdisplay *)NULL );

  return 1;  
}
