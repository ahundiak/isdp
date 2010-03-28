/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlinear

     METHOD NAME:	GRvtadjseg

     Abstract: 	This method returns to the user the closest vertex
	      to the input point along with identifiers of the 
	      segments adjacent to that vertex.
	
-----
%SC%    

     GRvtadjseg(msg,matrix_type,matrix,vert_loc,point,vertex,seg_id1,seg_id2)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *vert_loc	   GRparms	  locates the appropriate vertex 
				  (i.e. line strings which may have
				 	repeated vertices)
     point	   IGRpoint	  point to project

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     vertex	   IGRpoint	 vertex nearest input point
     *seg_id1	   GRparms	 parameter identifying adjacent seg
     *seg_id2	   GRparms 	 parameter identifying adjacent seg
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAptpsproj
		MAutoparms

     Methods:	

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	SDG	05/30/86 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method projects the input point onto the control points
	of the B-spline representation of the object and returns
	that point found by the projection along with u parameters
	identifying the segments adjacent to that vertex located.
	If the vertex is repeated in the series of control points,
	the input parameter structure will be used to determine the
	correct one.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "maerr.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAptpsproj();
extern    IGRboolean    MAutoparms();

method GRvtadjseg(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct GRparms *vert_loc; IGRpoint point,vertex; 
		struct GRparms *seg_id1,*seg_id2)

{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1,msg2;		/* local completion code	*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	IGRlong i;			/* loop counter			*/
	struct IGRbsp_curve *curve;	/* pointer to B-spline curve	*/
	struct IGRpointset pt_set;	/* point set,control pts of curve*/
	IGRlong pt_num;			/* point number of point set	*/
	struct GRprops props;		/* geometry properties		*/
	IGRlong segnum;			/* segment number of u parm	*/
	IGRdouble tparm;		/* t parameter of point	on curve*/

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	
	GRgetabsg(&msg1,matrix_type,matrix,&absgptr,i);

	if (! (1 & msg1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	curve = (struct IGRbsp_curve *)absgptr;

	/*
	 * form a point set from the B-spline poles
	 * project the input point onto this point set
	 */

	pt_set.num_points = curve->num_poles;
	pt_set.points = curve->poles;

	if (! (1 & MAptpsproj(&msg1,point,&pt_set,vertex,&pt_num)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	OMmsg = om$send(mode = OM_e_wrt_object,
			msg = message GRvg.GRgeomprops(&msg2,matrix_type,
							matrix,&props),
			senderid = my_id,
			targetid = my_id);

	if (! (1 & OMmsg))
	{
	   *msg = MSFAIL;
	   goto wrapup;
	}

	if (msg1 == MAINOTUNIQUE)
	{
	   /* the vertex occurs more than once in the curve 
	    * check the incoming u parameter to locate the  
	    * correct vertex
	    * assign the u parameters identifying adjacent  
	    * segments accordingly			    
	    */
	   if (1 & MAutoparms(&msg1,curve,&vert_loc->u,&segnum,&tparm))
	   {
	      if (tparm <= .5)
	      {
		 /* use the beginning of the segment as the vertex */
		 MAcopy(vertex,&curve->poles[(segnum - 1)*3],1,i);
		 
		 seg_id2->u = tparm;

		 if ((segnum == 1) && (props.closed))
	 	 {
		    seg_id1->u = (curve->knots[curve->num_poles - 1] +
					curve->knots[curve->num_poles])/2;
		 }
		 else
	 	 {
		    seg_id1->u = (curve->knots[segnum - 1] + 
						curve->knots[segnum])/2;
		 }		 
	      }
	      else
	      {
		 /* use the end of the segment as the vertex */
		 MAcopy(vertex,&curve->poles[segnum*3],1,i);
		 
		 seg_id1->u = tparm;

		 if ((segnum == (curve->num_poles - 1)) && (props.closed))
		 {
		    seg_id2->u = (curve->knots[1] + curve->knots[2])/2;
		 }
		 else
		 {
	 	    seg_id2->u = (curve->knots[segnum + 1] + 
						curve->knots[segnum + 2])/2;
		 }
	      }
	   } 
	   else
	   {
	      *msg = MSFAIL;
	      OMmsg = OM_E_ABORT;
	   }
	}
	else
	{	 
	   /* 
	    * determine the u parmeters that identify the segments 
	    * adjacent to the vertex nearest the input point
	    */	
	   if ((props.closed) && (pt_num == 1))
	   {
	      seg_id1->u = (curve->knots[curve->num_poles - 1] +
				curve->knots[curve->num_poles])/2;
	   }
	   else
	   {
	      seg_id1->u = (curve->knots[pt_num - 1] + curve->knots[pt_num])/2;
	   }

	   if ((props.closed) && (pt_num == curve->num_poles))
	   {
	      seg_id2->u = (curve->knots[1] + curve->knots[2])/2;
	   }
	   else
	   {
	      seg_id2->u = (curve->knots[pt_num] + curve->knots[pt_num + 1])/2;
	   }
	}

	seg_id1->v = 0.0;
	seg_id1->leaf_id.objid = my_id;
	seg_id1->leaf_id.osnum = OM_Gw_current_OS;
	seg_id1->polygon_inx = 1;

	seg_id2->v = 0.0;
	seg_id2->leaf_id.objid = my_id;
	seg_id2->leaf_id.osnum = OM_Gw_current_OS;
	seg_id2->polygon_inx = 1;

	

wrapup:

	return(OMmsg);

}

end implementation GRlinear;
