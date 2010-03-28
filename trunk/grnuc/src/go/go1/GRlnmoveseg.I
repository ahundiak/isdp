/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlinear

     METHOD NAME:	GRmoveseg

     Abstract: 	This method redefines the geometric representation
	      of the linear object by moving an identified segment
	      in its geometry.
	
-----
%SC%    

     GRmoveseg(msg,md_env,seg_locate,point,boreline)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env       GRmd_env	  environment information
     *seg_locate   GRparms	  locates the appropriate segment to
				  modify 
     point	   IGRpoint	  point on segment ('from' point)
     *boreline	   IGRline	  indicates new location for segment

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAutoparms
		MAsubvc
		MAdotvc
		MAdetplane
		MAlnplproj
		MAptlnproj
		MAlpfrln
		MA2lnproj
		MAptlsdis

     Methods:	
		GRinsvertex
		GRpostabsg		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:	There must exist a unique, local plane determined by 
		the segment chosen for movement and its adjacent 
		segments.  Otherwise, the routine will fail.

-----
%CH%

     CHANGE HISTORY:
	
	SDG	07/15/86 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method moves the segment indicated by the input GRparms
	structure to the location parallel to the original and 
	specified by the boreline.  The segment may not be moved 
	past the intersection of its adjacent segments.  The segment
	will either shrink or lengthen depending on the direction of
	movement.  However, if adjacent segments are either parallel
	or colinear, the length of the segment to move remains the
	same.  The method assumes that the boreline was obtained by 
	using the routine GRbrlncon.c. 

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "maerr.h"
#include "madef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAutoparms();
extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MAdetplane();
extern    IGRboolean    MAlnplproj();
extern    IGRboolean    MAptlnproj();
extern    IGRboolean    MAlpfrln();
extern    IGRboolean    MA2lnproj();
extern    IGRboolean    MAptls2dis();

method GRmoveseg(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *seg_locate; IGRpoint point; 
		struct IGRline *boreline)

{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/
	IGRlong msg2;			/* local completion code	*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	IGRlong i;			/* loop counter			*/
	struct IGRbsp_curve *curve;	/* pointer to B-spline curve	*/
	IGRlong segnum;			/* segment number		*/
	IGRboolean ending,beg;		/* flag for ending or beg seg 	*/
	IGRlong begseg,endseg;		/* end and beg segment numbers	*/
	IGRvector v1;			/* vector representing segment	*/
	IGRdouble len;			/* length of vector		*/
	struct GRprops props;		/* geometry properties		*/
	IGRlong numb;			/* num of pts to determine plane*/
	struct IGRplane plane;		/* plane of object		*/
	IGRdouble tol = 0.0000000001;	/* tolerance for planarity	*/
	IGRdouble tol_sq;
	IGRdouble str[12];	  	/* array of points to find plane*/
	IGRdouble t1,t2;		/* t parms of projects		*/
	IGRpoint line_pt,plane_pt;	/* projected points		*/
	struct IGRline begadj,endadj;	/* segments adjacent to move seg*/
	IGRpoint pt1,pt2;		/* projected points on lines	*/
	struct IGRline seg;		/* line containing seg to move  */
	IGRpoint par_pt;		/* point of parallel line	*/
	struct IGRline parln;		/* line parallel to seg to move	*/
	struct IGRline perp;		/* line perpendicular to moveseg*/
	struct IGRline_seg ls;		/* line seg, colinear check	*/
	IGRpoint p1,p2,p3,p4,p5,p6;	/* line points			*/
	IGRdouble dis = 100;		/* dist for colinear check	*/
	IGRdouble dis2;			/* distance between points	*/
	struct GRparms parms;		/* argument for method call	*/
	struct IGRline brline;		/* argument for method call	*/
	IGRlong corner = 0;		/* indicates if vertex is corner*/
	GRobjid newid;			/* argument for method call	*/
	struct GRpost_info info;	/* information for GRpostabsg	*/

	/* initialize variables */

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	beg = 0;
	ending = 0;	
	begadj.point1 = p1;
	begadj.point2 = p2;
	endadj.point1 = p3;
	endadj.point2 = p4;
	perp.point1 = p5;
	perp.point2 = p6;
	tol_sq = tol * tol;

	GRgetabsg(&msg1,&md_env->md_env.matrix_type,md_env->md_env.matrix,
		  &absgptr,i);

	if (! (1 & msg1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	curve = (struct IGRbsp_curve *)absgptr;

	/* locate the segment to move */

	if (! (1 & MAutoparms(&msg1,curve,&seg_locate->u,&segnum,&t1)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	seg.point1 = &curve->poles[(segnum - 1)*3];
	seg.point2 = &curve->poles[(segnum)*3];

	if (segnum == 1)
	{
	   /* set flag indicating move the first segment */
	   beg = 1;
	}

	if (segnum == (curve->num_poles - 1))
	{
	   /* set flag indicating move the last segment */
	   ending = 1;
	}

	/* check to see if single segmented object */
	if (beg && ending)
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	/* need to find first non-zero segments adjacent */

	if (!beg)
	{

	   begseg = segnum - 1;

	   MAsubvc(&msg1,&curve->poles[(segnum - 2)*3],
			 &curve->poles[(segnum - 1)*3],v1);

	   /* 
	    * check to make sure length of segment (vector) is != 0
	    * if it is, find first segment whose length > 0
	    */

	   MAdotvc(&msg1,v1,v1,&len);
	
	   if (MAabsolute(len) <= MAETA)
	   {  
	      for (i = 2; MAabsolute(len) <= MAETA; ++i)
	      {  
		 if (i > segnum - 1)
		 {
		    /* have reached end of string */
		    /* segment was the first segment */

		    beg = 1;
		    break;
		 }
	         
		 --begseg;

		 MAsubvc(&msg1,&curve->poles[(segnum - i - 1)*3],
			       &curve->poles[(segnum - i)*3],v1);

		 MAdotvc(&msg1,v1,v1,&len);

	      }  
	   }
	}
	
	if (!ending)
	{         
	   endseg = segnum + 1;

	   MAsubvc(&msg1,&curve->poles[(segnum + 1)*3],
		   &curve->poles[(segnum)*3],v1);

	   /* 
	    * check to make sure length of segment (vector) is != 0
	    * if it is, find first segment whose length > 0
	    */

	   MAdotvc(&msg1,v1,v1,&len);
	
	   if (MAabsolute(len) <= MAETA)
	   {  
	      for (i = 2; MAabsolute(len) <= MAETA; ++i)
	      {  
		 if (i > (curve->num_poles - segnum - 1))
		 {
		    /* have reached end of string */
		    /* segment was the last segment */

	 	    ending = 1;
		    break;
		 }
	   
		 ++endseg;

		 MAsubvc(&msg1,&curve->poles[(segnum + i)*3],
			       &curve->poles[(segnum + i - 1)*3],v1);

		 MAdotvc(&msg1,v1,v1,&len);

	      }  
	   }
	}

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

	if ((props.closed) && (beg || ending))
	{
	   if (beg)
	   {
	      /* need to start at end of closed object to find begseg */
	      
	      begseg = curve->num_poles - 1;
	
	      MAsubvc(&msg1,&curve->poles[(begseg - 1)*3],
		      &curve->poles[(begseg)*3],v1);

	      MAdotvc(&msg1,v1,v1,&len);
	
	      if (MAabsolute(len) <= MAETA)
	      {
	      	 while (MAabsolute(len) <= MAETA)
		 {
		    --begseg;

		    MAsubvc(&msg1,&curve->poles[(begseg - 1)*3],
			    &curve->poles[(begseg)*3],v1);

		    MAdotvc(&msg1,v1,v1,&len);
		 }
	      }
	   }
	   else
	   {
	      /* need to start at beginning of object to find endseg */

	      endseg = 1;
	
	      MAsubvc(&msg1,&curve->poles[(endseg)*3],
		      &curve->poles[(endseg - 1)*3],v1);

	      MAdotvc(&msg1,v1,v1,&len);
	
	      if (MAabsolute(len) <= MAETA)
	      {
	      	 while (MAabsolute(len) <= MAETA)
		 {
		    ++endseg;

		    MAsubvc(&msg1,&curve->poles[(endseg)*3],
			    &curve->poles[(endseg - 1)*3],v1);

		    MAdotvc(&msg1,v1,v1,&len);
		 }
	      }
	   }
	}

	/* determine the local plane using the segment to move and  */
	/* 		its surrounding segments		    */

	plane.point = plane_pt;
	plane.normal = v1;

	if (beg && (!(props.closed)))
	{
	   /*  
	    * segment to move is the first 
	    *		- object has no begseg
	    * use segment's endpoints and endpoint of 
	    * the following segment to determine a plane
	    */
	   for (i = 0; i < 3; ++i)
	   {
	      str[i] = curve->poles[(segnum - 1)*3 + i];
	      str[3 + i] = curve->poles[(segnum)*3 + i];
	      str[6 + i] = curve->poles[(endseg)*3 + i];
	   }
	
	   numb = 3;

	}
	else
	{
	   if (ending && (!(props.closed)))
	   {
	      /*  
	       * segment to move is the last 
	       *		- object has no endseg
	       * use segment's endpoints and endpoint from the
	       * preceeding segment to determine a plane
	       */
	      for (i = 0; i < 3; ++i)
	      {
	         str[i] = curve->poles[(begseg - 1)*3 + i];
	         str[3 + i] = curve->poles[(segnum - 1)*3 + i];
	         str[6 + i] = curve->poles[(segnum)*3 + i];
	      }
	
	      numb = 3;

	   }
	   else
	   {
	      /*
	       * normal case 
	       * use segment's endpoints and endpoints from the
	       * preceeding and following segments to determine a plane
	       */
	      for (i = 0; i < 3; ++i)
	      {
	         str[i] = curve->poles[(begseg - 1)*3 + i];
	         str[3 + i] = curve->poles[(segnum - 1)*3 + i];
	         str[6 + i] = curve->poles[(segnum)*3 + i];
		 str[9 + i] = curve->poles[(endseg)*3 + i];
	      }
	
	      numb = 4;

	   }
	}

	/* determine the local plane containing the segment to move */
	if (! (1 & MAdetplane(&msg1,str,&numb,&tol,&plane)))
	{
	   if (msg1 == MASDGENRAT)
 	   {
	      /*
	       * could not find a plane
	       * points were possibly colinear
	       * try again using all points of object
	       */
	      if (! (1 & MAdetplane(&msg1,&curve->poles[0],&curve->num_poles,
				    &tol,&plane)))
	      {
	         *msg = MSFAIL;
	         OMmsg = OM_E_ABORT;
	         goto wrapup;
	      }
	   }
	   else
	   {
	      *msg = MSFAIL;
	      OMmsg = OM_E_ABORT;
	      goto wrapup;
	   }
	}

	/* project the input boreline onto the local plane surrounding
	 * the chosen segment to find a point on same plane as these
	 * segments (this will insure that the movement of the segment 
	 * remain on the same local plane)
	 */

	if (! (1 & MAlnplproj(&msg1,boreline,&plane,line_pt,plane_pt,&t1)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}
	
	parln.point1 = line_pt;
	parln.point2 = par_pt;

	/* form lines containing the first non-zero length adjacent segments */

	if ((!beg) || (props.closed))
	{
	   if ((ending) && (!(props.closed)))
	   {
	      /*
	       * since ending flag is set and the object is not closed,
	       * need to form a perpendicular to the last segment 
	       * for the end adjacent line
	       */
	      if (! (1 & MAlpfrln(&msg1,&seg,&curve->poles[(segnum)*3],
				  plane.normal,&parln)))
	      { 
	         *msg = MSFAIL;
	         OMmsg = OM_E_ABORT;
	         goto wrapup;
	      }

	      for (i = 0; i < 3; ++i)
	      {
		 endadj.point1[i] = parln.point2[i];
		 endadj.point2[i] = parln.point1[i];
	      }

	   }
	   else
	   {
	      /* normal case - form end adjacent line using endseg */
	      for (i = 0; i < 3; ++i)
	      {
	         endadj.point1[i] = curve->poles[(endseg)*3 + i];
	         endadj.point2[i] = curve->poles[(endseg - 1)*3 + i];
	      }
	   }

	   for (i = 0; i < 3; ++i)
	   {
	     /* normal case - form beginning adjacent line using begseg */
	      begadj.point1[i] = curve->poles[(begseg - 1)*3 + i];
	      begadj.point2[i] = curve->poles[(begseg)*3 + i];
	   }
	}
	else
	{
	   /*
	    * since beg flag is set and the object is not closed,
	    * need to form a perpendicular to the first segment 
	    * for the beginning adjacent line
	    */
	   if (! (1 & MAlpfrln(&msg1,&seg,&curve->poles[0],
			       plane.normal,&parln)))
	   {
	      *msg = MSFAIL;
	      OMmsg = OM_E_ABORT;
	      goto wrapup;
	   }

	   for (i = 0; i < 3; ++i)
	   {
 	      begadj.point1[i] = parln.point2[i];
	      begadj.point2[i] = parln.point1[i];
	      endadj.point1[i] = curve->poles[(endseg)*3 + i];
	      endadj.point2[i] = curve->poles[(endseg - 1)*3 + i];
	   }

	
	}
	   
	/*
	 * form line parallel to the segment to move going through
	 * the point indicating new location of segment
	 */

	if (! (1 & MAptlnproj(&msg1,plane_pt,&seg,pt2,&t2)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	for (i = 0; i < 3; ++i)
	{
	   perp.point1[i] = plane_pt[i];
	   perp.point2[i] = pt2[i];
	}

	MA2pt2dis(&msg1,perp.point1,perp.point2,&dis);

	if (dis <= tol_sq)
	{
	    /* the segment is not being moved, exit leaving object
	     * it was
	     */

	    OMmsg = OM_S_SUCCESS;
	    *msg = MSSUCC;
	    goto wrapup;
	}

	if (! (1 & MAlpfrln(&msg1,&perp,plane_pt,plane.normal,&parln)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	/* find the intersection of the lines containing adjacent segments */

	if (! (1 & MA2lnproj(&msg1,&begadj,&endadj,pt1,pt2,&t1,&t2)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	MA2pt2dis(&msg2,pt1,&curve->poles[(segnum - 1)*3],&dis2);
	
	if (dis2 <= tol_sq)
	{
	   /* 
	    * beginning adjacent was perpendicular to moving segment 
	    * with end adjacent being colinear with it
	    */
	   corner = 1;
	}

	MA2pt2dis(&msg2,pt1,&curve->poles[(segnum)*3],&dis2);

	if (dis2 <= tol_sq)
	{
	   /* 
	    * end adjacent was perpendicular to moving segment 
	    * with beginning adjacent being colinear with it
	    */
	   corner = 2;
	}

	if ((msg1 == MAINFSOLUTION) || (corner > 0))
	{

	   if (msg1 == MAINFSOLUTION)
	   {
	      /* 
	       * need to check whether adjacent segments are 
	       * parallel or colinear 
	       */
	      
	      ls.beg_point = p5;
	      ls.end_point = p6;
	
	      for (i = 0; i < 3; ++i)
	      {
	         ls.beg_point[i] = begadj.point1[i];
	         ls.end_point[i] = endadj.point1[i];
	      }
	
	      if (! (1 & MAptls2dis(&msg1,&curve->poles[(segnum - 1)*3],
				   &ls,&dis)))
	      {
	         *msg = MSFAIL;
	         OMmsg = OM_E_ABORT;
	         goto wrapup;
	      }

	   }
	
	   if ((dis <= tol_sq) || (corner > 0))
	   {
	      /* need to add vertices to the curve */

	      if ((dis <= tol_sq) || (corner == 2))
	      {
	 	 /*
		  * need to add a vertex to the beginning of the segment
		  * one or both of the adjacent segments are colinear
		  */
		 parms.u = curve->knots[segnum];
		 brline.point1 = &curve->poles[(segnum - 1)*3];
		 brline.point2 = &curve->poles[(segnum - 1)*3];

		 OMmsg = om$send(mode = OM_e_wrt_message,
                                 msg = message GRlinear.GRinsvertex(&msg1,
						md_env,&parms,&brline,&newid),
                                 senderid = my_id,
                                 targetid = my_id);

		 if (! (1 & OMmsg))
		 {
	   	    *msg = MSFAIL;
	  	    goto wrapup;
		 }

		 GRgetabsg(&msg1,&md_env->md_env.matrix_type,
			   md_env->md_env.matrix,&absgptr,i);

		 if (! (1 & msg1))
		 {
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		 }

		 /* need to increase the segnum count 
	 	  * since a vertex was added before the moving segment
		  */	
		 segnum = segnum + 1;

	      }
	
	      if ((dis <= tol_sq) || (corner == 1))
	      {
	     	 /*
		  * need to add a vertex to the end of the segment 
		  * one or both of the adjacent segments are colinear
		  */
		 parms.u = curve->knots[segnum + 1];
		 brline.point1 = &curve->poles[(segnum)*3];
		 brline.point2 = &curve->poles[(segnum)*3];

		 OMmsg = om$send(mode = OM_e_wrt_message,
                                 msg = message GRlinear.GRinsvertex(&msg1,
						md_env,&parms,&brline,&newid),
                                 senderid = my_id,
                                 targetid = my_id);

		 if (! (1 & OMmsg))
		 {
	    	    *msg = MSFAIL;
	   	    goto wrapup;
		 }

		 GRgetabsg(&msg1,&md_env->md_env.matrix_type,
			   md_env->md_env.matrix,&absgptr,i);

		 if (! (1 & msg1))
		 {
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		 }
	      }

	   }

	   /* find new endpoints of moving segment */

	   if (! (1 & MAptlnproj(&msg1,&curve->poles[(segnum - 1)*3],&parln,
		           	 &curve->poles[(segnum - 1)*3],&t1)))
	   {
	      *msg = MSFAIL;
	      OMmsg = OM_E_ABORT;
	      goto wrapup;
	   }

	   if (! (1 & MAptlnproj(&msg1,&curve->poles[(segnum)*3],&parln,
		                 &curve->poles[(segnum)*3],&t1)))
	   {
	      *msg = MSFAIL;
	      OMmsg = OM_E_ABORT;
	      goto wrapup;
	   }
	}
	else
	{
	   /* 
	    * normal case - adjacent segments neither perpendicular to
	    * 		    nor colinear with segment to move
	    */

	   MAcopy(begadj.point1,pt1,1,i);

	   if (! (1 & MA2lnproj(&msg1,&begadj,&parln,
				&curve->poles[(segnum - 1)*3],pt2,&t1,&t2)))
	   {
	      *msg = MSFAIL;
	      OMmsg = OM_E_ABORT;
	      goto wrapup;
	   }

	   if (t1 > 0)
	   {
	      /*
	       * normal case - endpoint of new segment becomes intersection 
	       * 		of end adjacent line and the parallel line
	       */

	      MAcopy(endadj.point1,pt1,1,i);

	      if (! (1 & MA2lnproj(&msg1,&endadj,&parln,
				   &curve->poles[(segnum)*3],pt2,&t1,&t2)))
	      {
	         *msg = MSFAIL;
	         OMmsg = OM_E_ABORT;
	         goto wrapup;
	      }

	   }
	   else
	   {
	      /*
	       * point to move to is beyond intersection of adjacent segments
	       * segment now becomes zero length with endpoints being
	       * intersection point
	       */

	      for (i = 0; i < 3; ++i)
	      {
		  curve->poles[(segnum - 1)*3 + i] = pt1[i];
		  curve->poles[(segnum)*3 + i] = pt1[i];
	      }
	   }

	}

	if ((props.closed) && (beg || ending))
	{
	   MA2pt2dis(&msg1,&curve->poles[(curve->num_poles - 1)*3],
		    &curve->poles[0],&dis);

	   if (dis > tol_sq)
	   {
	      /* need to adjust object so it remains closed */

	      if (beg)
	      {
	         MAcopy(&curve->poles[(curve->num_poles - 1)*3],
		        &curve->poles[0],1,i);
	      }
	      else
	      {
	         MAcopy(&curve->poles[0],
			&curve->poles[(curve->num_poles - 1)*3],1,i);
	      }
	   }  
	}

	info.construct_flag = FALSE;

	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRpostabsg(msg,md_env,&info,
						     (IGRchar *)curve,&newid),
                        senderid = my_id,
                        targetid = my_id);

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);
wrapup:

	return(OMmsg);

}

end implementation GRlinear;
