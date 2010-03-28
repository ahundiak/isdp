/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRorthogonal

     METHOD NAME:	GRmodify

     Abstract: 	This method redefines the geometric representation
	      of the orthogonal object by changing some attribute of 
	      its geometry.
	
-----
%SC%    

     GRmodify(msg,md_env,vert_loc,point,boreline,new_objid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env       GRmd_env	  environment information
     *vert_loc	   GRparms	  locates the appropriate vertex 
				  (i.e. line strings which may have
				 	repeated vertices)
     point	   IGRpoint	  point to identify vertex to modify
     *boreline	   IGRline	  locates new vertex that replaces
				  vertex to modify 
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *new_objid	   GRobjid	 modified object id

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAdetplane
		MAlnplproj
		MAptpsproj
		MAsubvc
		MAdotvc
		MAang2vc
		MA2ptdis
		MAlpfrln
		MAptlnproj

     Methods:	

		GRgeomprops
		GRvtsegrtang
		GRpostabsg		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:	The new vertex that replaces the original 
		maintains the orthogonality of the object.
		Note also that only vertices between segments at
		right angles may be modified.
-----
%CH%

     CHANGE HISTORY:
	
	SDG	05/29/86 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method projects the input point onto the control points
	of the B-spline representation of the orthogonal object and 
	replaces that point found by the projection with the first 
	point of the input boreline.  This replacement does not 
	affect the orthogonality of the object. 

----*/
/*EH*/

class implementation GRorthogonal;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "mapriv.h"
#include "madef.h"

extern    IGRboolean    MAdetplane();
extern    IGRboolean    MAlnplproj();
extern    IGRboolean    MAptpsproj();
extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MAang2vc();
extern    IGRboolean    MA2ptdis();
extern    IGRboolean    MAlpfrln();
extern    IGRboolean    MAptlnproj();
 
method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *vert_loc; IGRpoint point; 
		struct IGRline *boreline;GRobjid *new_objid)

{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong status;			/* return status for method	*/
	IGRlong msg1;			/* local completion code	*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	IGRlong i,k;			/* loop counters 		*/
	struct IGRbsp_curve *curve;	/* pointer to B-spline curve	*/
	struct IGRplane plane;		/* plane of object		*/
	IGRpoint pl_pt;			/* plane point			*/
	IGRvector norm;			/* normal vector to plane	*/
	IGRdouble tol = 0.5;		/* tolerance for planarity	*/
	IGRdouble t;			/* t parameter of project	*/
	IGRpoint line_pt,plane_pt;	/* projected points		*/
	struct IGRpointset pt_set;	/* point set,control pts of curve*/
	struct GRprops props;		/* geometry properties		*/
	IGRlong pt_num;			/* point number of point set	*/
	IGRpoint pole;			/* pole to alter		*/
	IGRboolean ending,beg;		/* flag for end or beg vertex	*/
	IGRvector v1,v2;		/* vectors			*/
	IGRdouble angle[3];		/* angle between vectors	*/
	IGRboolean end_found,beg_found; /* flags to indicate ends reached*/
	IGRlong end_num,beg_num;	/* nearest vertices at perps	*/
	IGRlong one = 1;		/* point number			*/
	IGRdouble dis1,dis2;		/* distance of nearest vertices */
	IGRdouble end_dir = 1;		/* direction toward end of string*/
	IGRdouble beg_dir = -1;		/* direction toward beg of string*/
	struct IGRline line,line2;	/* lines containing segments	*/
	struct IGRline perp1,perp2;	/* lines perpendicular to segmts*/
	IGRpoint p1,p2,p3,p4,p5;	/* line pointers		*/
	IGRdouble dot;  		/* length of vectors		*/
	GRobjid newobjid;		/* argument for GRpostabsg	*/
	struct GRpost_info info;	/* information for GRpostabsg   */

	/* initialize variables */

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
        *new_objid = my_id;
	end_found = 0;
	beg_found = 0;
	ending = 0;
	beg = 0;
	line.point1 = p1;
	line.point2 = p2;
	line2.point1 = p3;
	line2.point2 = p4;

	GRgetabsg(&msg1,&md_env->md_env.matrix_type,md_env->md_env.matrix,
		  &absgptr,i);

	if (! (1 & msg1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	curve = (struct IGRbsp_curve *)absgptr;

	/* determine the plane of the object */

	plane.point = pl_pt;
	plane.normal = norm;

	if (! (1 & MAdetplane(&msg1,curve->poles,&curve->num_poles,
			      &tol,&plane)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	tol = .0000000001;

	/*
	 * project the input boreline onto the plane of the object
	 * to find a point on same plane as the object that will
	 * replace the one identified to modify
	 */

	if (! (1 & MAlnplproj(&msg1,boreline,&plane,line_pt,plane_pt,&t)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}
	
	pt_set.num_points = curve->num_poles;
	pt_set.points = curve->poles;

	/* locate the vertex to modify */

	MAptpsproj(&msg1,point,&pt_set,pole,&pt_num);

	/* get geometry properties to see if object is closed */

	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRgeomprops(&msg1,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,&props),
                        senderid = my_id,
                        targetid = my_id);

	if (! (1 & OMmsg))
	{
	   *msg = MSFAIL;
	   goto wrapup;
	}

	if (pt_num == 1)
	{
	   /* set flag indicating vertex to modify is the first in object */
	   beg = 1;
	}

	if (pt_num == curve->num_poles)
	{
	   /* set flag indicating vertex to modify is the last in object */ 
	   ending = 1;
	}

	/* check to make sure located vertex (pole) is between
	 * segments at right angles
	 *
	 * keep checking for end of string, if reach it -
	 *     error - vertex not a corner vertex
	 * also make sure length of segments are != 0
	 */

	if (!beg)
	{
	   MAsubvc(&msg1,&curve->poles[(pt_num - 2)*3],
		         &curve->poles[(pt_num - 1)*3],v1);

	   /*
	    * check to make sure length of segment (vector) is != 0
	    * if it is, find first segment whose length > 0
	    */

	   MAdotvc(&msg1,v1,v1,&dot);
	
	   if (MAabsolute(dot) <= MAETA)
	   {
	      for (i = 2; MAabsolute(dot) <= MAETA; ++i)
	      {
	         if (i >= pt_num)
	         {
		    beg = 1;
		    break;
	         }

	         MAsubvc(&msg1,&curve->poles[(pt_num - i - 1)*3],
			       &curve->poles[(pt_num - i)*3],v1);

	         MAdotvc(&msg1,v1,v1,&dot);
	      }
	   }
	}

	if (!ending)
	{
	   MAsubvc(&msg1,&curve->poles[(pt_num)*3],
			 &curve->poles[(pt_num - 1)*3],v2);

	   /*
	    * check to make sure length of segment (vector) is != 0
	    * if it is, find first segment whose length > 0
	    */

	   MAdotvc(&msg1,v2,v2,&dot);
	
	   if (MAabsolute(dot) <= MAETA)
	   {
	      for (i = 1; MAabsolute(dot) <= MAETA; ++i)
	      {
	         if ((pt_num + i) >= curve->num_poles)
	         {
		    ending = 1;
		    break;
	         }

	         MAsubvc(&msg1,&curve->poles[(pt_num + i)*3],
			       &curve->poles[(pt_num + i - 1)*3],v2);

	         MAdotvc(&msg1,v2,v2,&dot);
	      }
	   }   
	}

	if (ending || beg)
	{
	   if (props.closed)
	   {
 	      if (beg)
	      {
		 /* need to find v1 */
		 /* begin at end of object */

	 	 MAsubvc(&msg1,&curve->poles[(curve->num_poles - 2)*3],
			       &curve->poles[(curve->num_poles - 1)*3],v1);

		 /*
		  * check to make sure length of segment (vector) is != 0
	 	  * if it is, find first segment whose length > 0
	   	  */

		 MAdotvc(&msg1,v1,v1,&dot);

		 if (MAabsolute(dot) <= MAETA)
		 {
  		    for (i = 2; MAabsolute(dot) <= MAETA; ++i)
		    {
		       	if (i > curve->num_poles - 2)
			{
			   /* no corner vertices exist */
			   OMmsg = OM_E_ABORT;
	 	 	   *msg = MSFAIL;
		 	   goto wrapup;
	      		}

			MAsubvc(&msg1,
				&curve->poles[(curve->num_poles - i - 1)*3],
				&curve->poles[(curve->num_poles - i)*3],v1);

			MAdotvc(&msg1,v1,v1,&dot);
		    }
		 }
	      }  
	      else
	      {
		 /* need to find v2 */
		 /* start at beginning of object */

	 	 MAsubvc(&msg1,&curve->poles[3],&curve->poles[0],v2);

		 /*
		  * check to make sure length of segment (vector) is != 0
	 	  * if it is, find first segment whose length > 0
	   	  */

		 MAdotvc(&msg1,v2,v2,&dot);

		 if (MAabsolute(dot) <= MAETA)
		 {
  		    for (i = 2; MAabsolute(dot) <= MAETA; ++i)
		    {
			if (i > curve->num_poles - 1)
			{
			   /* no corner vertices exist */
			   OMmsg = OM_E_ABORT;
	 	 	   *msg = MSFAIL;
		 	   goto wrapup;
	      		}

			MAsubvc(&msg1,&curve->poles[i*3],
				&curve->poles[(i - 1)*3],v2);

			MAdotvc(&msg1,v2,v2,&dot);
		    }
		 }
	      }  
	   }
	   else
	   {
	      /* cannot modify first or last vertex of an open object */
	      OMmsg = OM_E_ABORT;
	      *msg = MSFAIL;
	      goto wrapup;
	   }
	}
	      
	/* find angle between non-zero length adjacent segments */

	MAang2vc(&msg1,v1,v2,angle);

	if (MAabsolute(angle[2]) > (MAETA*10000))
	{
	   /* segments not at right angles */
	   /* need to search in both directions until find a corner vertex */
	   /* if reach end, error */
	   /* use the closest corner vertex as one to modify */
	   

	   /* search towards the beginning */
	   if (beg)
	   {
	      status = GRvtsegrtang(&msg1,curve,&curve->num_poles,&beg_dir,
				    &beg_num,&beg_found);

	      if ((! status) || (beg_found))
	      {
		 *msg = MSFAIL;
	   	 OMmsg = OM_E_ABORT;
	   	 goto wrapup;
	      }

	   }
	   else	      
	   {
	      status = GRvtsegrtang(&msg1,curve,&pt_num,&beg_dir,&beg_num,
				    &beg_found);
	      
	      if (! status)
	      {
	   	 *msg = MSFAIL;
	   	 OMmsg = OM_E_ABORT;
	   	 goto wrapup;
	      }

	      if ((beg_found) && (props.closed))
	      {
		 status = GRvtsegrtang(&msg1,curve,&curve->num_poles,&beg_dir,
				       &beg_num,&beg_found);
	
		 if (! status)
		 {
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		 }
	      } 
	   }


	   /* search towards the end */
	   if (ending)
	   {
	      status = GRvtsegrtang(&msg1,curve,&one,&end_dir,&end_num,
				    &end_found);
	
	      if ((! status) || (end_found))
	      {
	   	 *msg = MSFAIL;
	   	 OMmsg = OM_E_ABORT;
		 goto wrapup;
	      }

	   }
	   else
	   {
	      status = GRvtsegrtang(&msg1,curve,&pt_num,&end_dir,&end_num,
				    &end_found);
	
	      if (! status)
	      {
	   	 *msg = MSFAIL;
	   	 OMmsg = OM_E_ABORT;
	   	 goto wrapup;
	      }

	      if ((end_found) && (props.closed))
	      {
		 status = GRvtsegrtang(&msg1,curve,&one,&end_dir,&end_num,
				       &end_found);
	
		 if (! status)
		 {
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		 }
	      } 
	   }

	   if (! end_found)
	   {
	      if (! beg_found)
	      {
		 /* determine the closest vertex */

		 MA2ptdis(&msg1,&curve->poles[(pt_num - 1)*3],
			  &curve->poles[(beg_num - 1)*3],&dis1);

		 MA2ptdis(&msg1,&curve->poles[(pt_num - 1)*3],
			  &curve->poles[(end_num - 1)*3],&dis2);

		 if (dis1 <= dis2)
		 {
		    pt_num = beg_num;
		 }
		 else
		 {
		    pt_num = end_num;
		 }
	      }
	      else
	      {
		 pt_num = end_num;
	      }
	   }
	   else
	   {
	      if (! beg_found)
	      {
		 pt_num = beg_num;
	      }
	      else
	      {
		 /* no corner vertices exist */

		 OMmsg = OM_E_ABORT;
	 	 *msg = MSFAIL;
		 goto wrapup;
	      }
	   }
	}

	/* segments are perpendicular */

	/*
	 * if there exists a string of colinear segments in one or
	 * both directions from the segments found, determine the end
	 * of the string(s)
	 * keep checking for end of string 
	 * if reached, use that piece
	 */

	status = GRvtsegrtang(&msg1,curve,&pt_num,&beg_dir,&beg_num,
				 &beg_found);

	if (! status)
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	if (beg_found && props.closed)
	{
	   /* need to keep searching to find end of colinear string */

	   if (pt_num == 1 ||
	      ((curve->poles[0] == curve->poles[(pt_num - 1)*3]) &&
	       (curve->poles[1] == curve->poles[(pt_num - 1)*3 + 1]) &&
	       (curve->poles[2] == curve->poles[(pt_num - 1)*3 + 2])))
	   {
	      /* search from the end of object for colinear string */
	      status = GRvtsegrtang(&msg1,curve,&curve->num_poles,&beg_dir,
				 &beg_num,&beg_found);

	      if (! status)
	      {
	         *msg = MSFAIL;
	         OMmsg = OM_E_ABORT;
	         goto wrapup;
	      }

	   }
	   else
	   {	
	      /* need to check whether pt_num=1 is a corner vertex */
	      /* and therefore the end of the colinear string	   */

	      MAsubvc(&msg1,&curve->poles[(pt_num - 1)*3],
		      &curve->poles[0],v1);

	      MAsubvc(&msg1,&curve->poles[(curve->num_poles - 2)*3],
			    &curve->poles[(curve->num_poles - 1)*3],v2);

	      /*
	       * check to make sure length of segment (vector) is != 0
	       * if it is, find first segment whose length > 0
	       */

	      MAdotvc(&msg1,v2,v2,&dot);

	      if (MAabsolute(dot) <= MAETA)
	      {
		 /* length of v2 is less than tolerance - find another */

  		 for (i = 2; MAabsolute(dot) <= MAETA; ++i)
		 {
		    MAsubvc(&msg1,
			    &curve->poles[(curve->num_poles - i - 1)*3],
			    &curve->poles[(curve->num_poles - i)*3],v2);

		    MAdotvc(&msg1,v2,v2,&dot);
		 }
 	      }  

	      MAang2vc(&msg1,v1,v2,angle);

	      if (MAabsolute(angle[2]) > (MAETA*10000))
	      {
		 /* pt_num=1 was not a corner vertex - search to find one */

	 	 status = GRvtsegrtang(&msg1,curve,&curve->num_poles,&beg_dir,
				       &beg_num,&beg_found);

	         if (! status)
	         {
	            *msg = MSFAIL;
	            OMmsg = OM_E_ABORT;
	            goto wrapup;
	         }
	      }
	      /* else - 
	       * pt_num=1 was a corner vertex and the end of colinear string; 
	       * therefore, leave beg_num as 1
	       */
	   }
		 
	}

	status = GRvtsegrtang(&msg1,curve,&pt_num,&end_dir,&end_num,
				 &end_found);

	if (! status)
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	if (end_found && props.closed)
	{
	   /* need to keep searching to find end of colinear string */

	   if (pt_num == curve->num_poles ||
	      ((curve->poles[(curve->num_poles - 1)*3] 
					== curve->poles[(pt_num - 1)*3]) &&
	       (curve->poles[(curve->num_poles - 1)*3 + 1] 
					== curve->poles[(pt_num - 1)*3 + 1]) &&
	       (curve->poles[(curve->num_poles - 1)*3 + 2] 
					== curve->poles[(pt_num - 1)*3 + 2])))
	   {
	      /* search from the beginning of object for colinear string */
	      status = GRvtsegrtang(&msg1,curve,&one,&end_dir,&end_num,
				    &end_found);

	      if (! status)
	      {
	         *msg = MSFAIL;
	         OMmsg = OM_E_ABORT;
	         goto wrapup;
	      }
	   }
	   else
	   {
	      /* need to check whether pt_num=curve->num_poles is a corner 
	       * vertex and therefore the end of the colinear string
	       */
	      MAsubvc(&msg1,&curve->poles[(pt_num - 1)*3],
		      &curve->poles[(curve->num_poles - 1)*3],v1);

	      MAsubvc(&msg1,&curve->poles[3],&curve->poles[0],v2);

	      /*
	       * check to make sure length of segment (vector) is != 0
	       * if it is, find first segment whose length > 0
	       */

	      MAdotvc(&msg1,v2,v2,&dot);

	      if (MAabsolute(dot) <= MAETA)
	      {
		 /* length of v2 is less than tolerance - find another */

  		 for (i = 2; MAabsolute(dot) <= MAETA; ++i)
		 {
		    MAsubvc(&msg1,&curve->poles[i*3],
			    &curve->poles[(i - 1)*3],v2);

		    MAdotvc(&msg1,v2,v2,&dot);
		 }
 	      }  

	      MAang2vc(&msg1,v1,v2,angle);

	      if (MAabsolute(angle[2]) > (MAETA*10000))
	      {
		 /* pt_num=curve->num_poles was not a corner vertex
		  * search to find one
		  */

	 	 status = GRvtsegrtang(&msg1,curve,&one,&end_dir,
				       &end_num,&end_found);

	         if (! status)
	         {
	            *msg = MSFAIL;
	            OMmsg = OM_E_ABORT;
	            goto wrapup;
	         }
	      }
	      /*
	       * else-
	       * pt_num=curve->num_poles was a corner vertex and the end
	       * of the colinear string
	       * therefore, leave end_num as curve->num_poles
	       */
	   }
		 
	}

	/*
	 * assign lines to be those extending out from the vertex to modify
	 * and containing all colinear and zero length segments
	 */

	for (i = 0; i < 3; ++i)
	{
	
	   line.point1[i] = curve->poles[(beg_num - 1)*3 + i];
	   line.point2[i] = line2.point2[i] = curve->poles[(pt_num - 1)*3 + i];
	   line2.point1[i] = curve->poles[(end_num - 1)*3 + i];
	}
	
	/* find lines perpendicular to these lines at the endpoints */

	perp1.point1 = pl_pt;
	perp1.point2 = p5;
	perp2.point1 = line.point1;
	perp2.point2 = line.point2;

	if (! (1 & MAlpfrln(&msg1,&line,&curve->poles[(beg_num - 1)*3],
			    plane.normal,&perp1)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}
	
	if (! (1 & MAlpfrln(&msg1,&line2,&curve->poles[(end_num - 1)*3],
			    plane.normal,&perp2)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	if (! (1 & MAptlnproj(&msg1,plane_pt,&perp1,
			      &curve->poles[(beg_num - 1)*3],&t)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	if (! (1 & MAptlnproj(&msg1,plane_pt,&perp2,
			      &curve->poles[(end_num - 1)*3],&t)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	MAcopy(&curve->poles[(pt_num - 1)*3],plane_pt,1,i);

	if ((beg_num > pt_num) || ((pt_num - beg_num) != 1))
	{ 
	   /*
	    * either segments found were colinear or 
	    * of zero length
	    * need to project points inbetween beg_num and pt_num
	    */
	
	   for (i = 0; i < 3; ++i)
	   {
	      line.point1[i] = plane_pt[i];
	      line.point2[i] = curve->poles[(beg_num - 1)*3 + i];
	   }

	   if (pt_num != 1)
	   {
	      if (beg_num > pt_num)
	      {
		 k = pt_num + 1;
	      }
	      else
	      {
		 k = pt_num - beg_num + 1;
	      }

	      for (i = 2; i < k; ++i)
	      {
	         if (! (1 & MAptlsproj(&msg1,&curve->poles[(pt_num - i)*3],
				      &line,&curve->poles[(pt_num - i)*3],&t)))
		 {
	   	    *msg = MSFAIL;
	   	    OMmsg = OM_E_ABORT;
	   	    goto wrapup;
		 }

	      }

	   }
	   if (beg_num > pt_num)
	   {
	      if ((curve->num_poles - beg_num) != 1)
	      {
 		 for (i = (beg_num + 1); i < curve->num_poles; ++i)
		 {
		    if (! (1 & MAptlsproj(&msg1,&curve->poles[(i - 1)*3],&line,
				     &curve->poles[(i - 1)*3],&t)))
		    {
	   	       *msg = MSFAIL;
	   	       OMmsg = OM_E_ABORT;
	   	       goto wrapup;
		    }

		 }
	      }

	      MAcopy(&curve->poles[(curve->num_poles - 1)*3],
		     &curve->poles[0],1,i);

	   }

	}

	if ((end_num < pt_num) || ((end_num - pt_num) != 1))
	{ 
	   /*
	    * either segments found were colinear or 
	    * of zero length
	    * need to project points inbetween end_num and pt_num
	    */

	   for (i = 0; i < 3; ++i)
	   {
	      line.point1[i] = plane_pt[i];
	      line.point2[i] = curve->poles[(end_num - 1)*3 + i];
	   }

	   if (pt_num != curve->num_poles)
	   {
	      if (end_num < pt_num)
	      {
		 k = curve->num_poles - pt_num + 1;
	      }
	      else
	      {
	         k = end_num - pt_num;
	      }

	      for (i = 1; i < k; ++i)
	      {
	         if (! (1 & MAptlsproj(&msg1,&curve->poles[(pt_num + i - 1)*3],
				  &line,&curve->poles[(pt_num + i - 1)*3],&t)))
		 {
	  	    *msg = MSFAIL;
	   	    OMmsg = OM_E_ABORT;
	   	    goto wrapup;
		 }

	      }
	   }

	   if (end_num < pt_num)
	   {
	      if (end_num != 2)
	      {
 		 for (i = 2; i < end_num; ++i)
		 {
		    if (! (1 & MAptlsproj(&msg1,&curve->poles[(i - 1)*3],&line,
				          &curve->poles[(i - 1)*3],&t)))
		    {
		       *msg = MSFAIL;
	   	       OMmsg = OM_E_ABORT;
		       goto wrapup;
		    }

		 }
	      }

	      MAcopy(&curve->poles[0],&curve->poles[(curve->num_poles - 1)*3],
		     1,i);

	   }

	}

	/* check to see if object needs adjusting to remain closed */

	if ((beg_num == 1) && (props.closed))
	{
	   MAcopy(&curve->poles[(curve->num_poles - 1)*3],
		  &curve->poles[0],1,i);
	}
	
	if ((end_num == curve->num_poles) && (props.closed))
	{
	   MAcopy(&curve->poles[0],
		  &curve->poles[(curve->num_poles - 1)*3],1,i);
	}


	info.construct_flag = FALSE;

    /*
     * Don't allow a modification which will make it impossible
     * to determine the plane from the geometry.
     */
    tol = .5;
	OMmsg = MAdetplane(&msg1,curve->poles,&curve->num_poles,&tol,&plane);

    if (!(OMmsg & msg1 & 1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
   }
    
    OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRpostabsg(msg,
                                                  md_env,
                                                  &info,
                                                  (IGRchar *)curve,
                                                  &newobjid),
                    senderid = my_id,
                    targetid = my_id);

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

wrapup:

	return(OMmsg);

}

end implementation GRorthogonal;
