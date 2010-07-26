/* #######################    APOGEE COMPILED   ######################## */
/*
 *--------------------------------------------------------------------
 *               F U N C T I O N   D E S C R I P T I O N
 *--------------------------------------------------------------------
 *
 *	This function is a utility tool to return to the user
 *	the first occurrence of a vertex where the adjacent 
 *	segments are at right angles.  The input pt_num gives a
 *	starting point for the search.  The input dir tells 
 * 	whether to traverse the line string toward the beginning 
 *	(dir = -1) or the end (dir = +1).  The point number of the
 *	vertex found is returned.  If however, the end or beginning
 *	of the line string is reached before finding such a vertex,
 *	the found flag is set and the point number will be that
 *	of the first or last vertex, accordingly.
 *
 */


#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "msdef.h"
#include "mapriv.h"
#include "OMerrordef.h"

IGRlong GRvtsegrtang(msg,curve,pt_num,dir,new_num,found)

	IGRlong		*msg;		/*  return code		*/
  	struct IGRbsp_curve *curve;	/* B-spline curve	*/
	IGRlong		*pt_num;	/* pt num of beg pole	*/
	IGRdouble	*dir;		/* direction to search	*/
	IGRlong		*new_num;	/* pt num of pole found	*/
	IGRboolean	*found;		/* end of curve?	*/

{

 	IGRlong		i,k;		/* loop counters	*/
    	IGRlong		OMmsg;		/* OM return value	*/
	IGRlong 	msg1;		/* internal routines	*/
	IGRvector	v1,v2;		/* vectors		*/
	IGRdouble	angle[3];	/* angle between 2 vects*/
	IGRdouble	abscos;		/* absolute value of cos*/
	IGRdouble 	len;		/* length of vector	*/

	/* initialize variables	*/

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	*found = 0;

	if (*dir == 1)
	{
	   if (*pt_num >= (curve->num_poles - 1))
	   {
	      *found = 1;
	      *new_num = curve->num_poles;
	   }
	   else
	   {
	      k = *pt_num;

	      MAsubvc(&msg1,&curve->poles[(*pt_num - 1)*3],
			    &curve->poles[(*pt_num)*3],v1);

	      MAdotvc(&msg1,v1,v1,&len);

	      if (len <= MAETA)
	      {
		 for (k = (*pt_num + 1); len <= MAETA; ++k)
		 {
		    if (k >= (curve->num_poles - 1))
		    {
		       *found = 1;
		       break;
		    }
		
		    MAsubvc(&msg1,&curve->poles[(k - 1)*3],
				  &curve->poles[k*3],v1);

		    MAdotvc(&msg1,v1,v1,&len);
		 }

		 k = k - 1;

	      }

	      if (! *found)
	      {
		 MAsubvc(&msg1,&curve->poles[(k + 1)*3],
			       &curve->poles[k*3],v2);

	      	 MAdotvc(&msg1,v2,v2,&len);

		 if (len <= MAETA)
	      	 {
		    for (k = (k + 1); len <= MAETA; ++k)
		    {
		       if (k >= (curve->num_poles - 1))
		       {
		          *found = 1;
		          break;
		       }
		
		       MAsubvc(&msg1,&curve->poles[(k + 1)*3],
				     &curve->poles[k*3],v2);

		       MAdotvc(&msg1,v2,v2,&len);
		    }

		    k = k - 1;
	         }
	      }

	      if (*found)
	      {
		 *new_num = curve->num_poles;
		 goto wrapup;
	      }

	      MAang2vc(&msg1,v1,v2,angle);

	      i = k + 1;
	
	      if (MAabslt(angle[2]) > (MAETA*10000))
	      {
		 for (i = (k + 1); abscos > (MAETA*10000); ++i)
		 {
		    if (i >= (curve->num_poles - 1))
		    {
		       *found = 1;
		       i = curve->num_poles;
		       break;
		    }

	  	    MAsubvc(&msg1,&curve->poles[(i - 1)*3],
			    &curve->poles[i*3],v1);

		    MAdotvc(&msg1,v1,v1,&len);

		    if (len <= MAETA)
	   	    {
		       for (k = (i + 1); len <= MAETA; ++k)
		       {
		          if (k >= (curve->num_poles - 1))
		          {
		             *found = 1;
		             break;
		     	  }
		
		    	  MAsubvc(&msg1,&curve->poles[(k - 1)*3],
				  &curve->poles[k*3],v1);

			  MAdotvc(&msg1,v1,v1,&len);
		       } 

		       i = k - 1;

	      	    }  

		    if (! *found)
	  	    {
		       MAsubvc(&msg1,&curve->poles[(i + 1)*3],
			       &curve->poles[i*3],v2);

		       MAdotvc(&msg1,v2,v2,&len);

		       if (len <= MAETA)
	      	       {
		    	  for (k = (i + 1); len <= MAETA; ++k)
		     	  {
		      	     if (k >= (curve->num_poles - 1))
		       	     {
		          	*found = 1;
		          	break;
		       	     }
		
		  	     MAsubvc(&msg1,&curve->poles[(k + 1)*3],
				     &curve->poles[k*3],v2);

		 	     MAdotvc(&msg1,v2,v2,&len);
		    	  } 
		  
		  	  i = k - 1;

	 	       } 
	      	    } 

		    if (*found)
	 	    {
		       *new_num = curve->num_poles;
		       goto wrapup;
	      	    }

		    MAang2vc(&msg1,v1,v2,angle);

		    abscos = MAabslt(angle[2]);

		 }  
	      }  

	      *new_num = i;

	   }  
	}
	else
	{
	   /* dir = -1 : toward beginning */

	   if (*pt_num <= 2)
	   {
	      *found = 1;
	      *new_num = 1;
	   }
	   else
	   {
	      k = *pt_num;

	      MAsubvc(&msg1,&curve->poles[(*pt_num - 1)*3],
			    &curve->poles[(*pt_num - 2)*3],v1);

	      MAdotvc(&msg1,v1,v1,&len);

	      if (len <= MAETA)
	      {
		 for (k = (*pt_num - 1); len <= MAETA; --k)
		 {
		    if (k <= 2)
		    {
		       *found = 1;
		       break;
		    }
		
		    MAsubvc(&msg1,&curve->poles[(k - 1)*3],
				  &curve->poles[(k - 2)*3],v1);

		    MAdotvc(&msg1,v1,v1,&len);
		 }

		 k = k + 1;

	      }

	      if (! *found)
	      {
		 MAsubvc(&msg1,&curve->poles[(k - 3)*3],
			       &curve->poles[(k - 2)*3],v2);

	      	 MAdotvc(&msg1,v2,v2,&len);

		 if (len <= MAETA)
	      	 {
		    for (k = (k - 1); len <= MAETA; --k)
		    {
		       if (k <= 2)
		       {
		          *found = 1;
		          break;
		       }
		
		       MAsubvc(&msg1,&curve->poles[(k - 3)*3],
				     &curve->poles[(k - 2)*3],v2);

		       MAdotvc(&msg1,v2,v2,&len);
		    }
		    
		    k = k + 1;
	         }
	      }

	      if (*found)
	      {
		 *new_num = 1;
		 goto wrapup;
	      }

	      MAang2vc(&msg1,v1,v2,angle);

	      i = k - 1;
	
	      if (MAabslt(angle[2]) > (MAETA*10000))
	      {
		 for (i = (k - 1); abscos > (MAETA*10000); --i)
		 {
		    if (i <= 2)
		    {
		       *found = 1;
		       i = 1;
		       break;
		    }

	  	    MAsubvc(&msg1,&curve->poles[(i - 1)*3],
			    &curve->poles[(i - 2)*3],v1);

		    MAdotvc(&msg1,v1,v1,&len);

		    if (len <= MAETA)
	   	    {
		       for (k = (i - 1); len <= MAETA; --k)
		       {
		          if (k <= 2)
		          {
		             *found = 1;
		             break;
		     	  }
		
		    	  MAsubvc(&msg1,&curve->poles[(k - 1)*3],
				  &curve->poles[(k - 2)*3],v1);

			  MAdotvc(&msg1,v1,v1,&len);
		       } 

		       i = k + 1;

	      	    }  

		    if (! *found)
	  	    {
		       MAsubvc(&msg1,&curve->poles[(i - 3)*3],
			       &curve->poles[(i - 2)*3],v2);

		       MAdotvc(&msg1,v2,v2,&len);

		       if (len <= MAETA)
	      	       {
		    	  for (k = (i - 1); len <= MAETA; --k)
		     	  {
		      	     if (k <= 2)
		       	     {
		          	*found = 1;
		          	break;
		       	     }
		
		  	     MAsubvc(&msg1,&curve->poles[(k - 3)*3],
				     &curve->poles[(k - 2)*3],v2);

		 	     MAdotvc(&msg1,v2,v2,&len);
		    	  } 
		  
		  	  i = k + 1;

	 	       } 
	      	    } 

		    if (*found)
	 	    {
		       *new_num = 1;
		       goto wrapup;
	      	    }

		    MAang2vc(&msg1,v1,v2,angle);

		    abscos = MAabslt(angle[2]);

		 }  
	      }  

	      *new_num = i;

	   }  
	}

wrapup:
    return(OMmsg);
}

