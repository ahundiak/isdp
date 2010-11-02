
/*

Name
  EMassemmath.C

Abstract
  Math routines for assemblies
  
Synopsis

Description
  Assemblies can have two types of constraints, Mate and Align. The objects being
  assembled can have three orientations, parallel, orthogonal or angular. Further the
  number of constraints between the objects can be 1,2 or 3.

  Based on the above classification the constraints are divided into 14 cases.

  Mate
  Align
  Mate-Mate-Ortho
  Mate-Align-Ortho
  Align-Align-Ortho
  Mate-Mate-Parallel
  Mate-Align-Parallel
  Align-Align-Parallel
  Mate-Mate-Angular
  Mate-Align-Angular
  Align-Align-Angular
  Mate-Mate-Mate
  Mate-Mate-Align
  Mate-Align-Align
  
Return Value

Notes
  
Index

Keywords
  mate,align

History
  Satya	 created   --- 	October 1993.
  Satya  changed the logic of Mate-Align-Align  --- 25th November 1993.
  Satya  changed the constraint order for Mate-Align-Ortho --  26th November 1993
  Satya  changed rows and cols data type to IGRshort --- 9th March 1994.
  Satya  made some changes to tolerance values -- 30th March 1994.
*/

#include "stdio.h"
#include "math.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "maerr.h"
#include "madef.h"
#include "msdef.h"

#define  EXTERN 
#include "assemmath.h"
#include "assemdef.h"

extern IGRdouble	BSdistptpt();
extern IGRdouble BSlenvec(),BSdotp();
extern IGRboolean BSdistptpl();
IGRboolean ASxplpl ();

/******************************* CASE 1 ************************************
	Description :   Mate Constraint. Here the normals should be in the
			opposite direction and the points should coincide
	Feasibility :	It is always feasible to get a solution .
	Return Values : ASM_MATH_SUCC - Success
			ASM_MABS_FAIL - Failure
****************************************************************************/


int mate(part_1_orient_info,part_2_orient_info,trans_mat)
ORIENT_INFO	part_1_orient_info;	/** INPUT :Orientation info of part1 */
ORIENT_INFO	part_2_orient_info;	/** INPUT :Orientation info of part2 */
IGRmatrix	trans_mat;		/** OUTPUT:Transformation matrix     */
{
   IGRmatrix	temp_trans_mat,rotmatx,trmat;
   IGRshort	rows,cols;
   IGRint	num_pnts;
   IGRlong	rc;
   IGRvector	vec1;

#ifdef DEBUG
printf("Mate Input:\n");
print_input("Part1 Info:", &part_1_orient_info, 0);
print_input("Part2 Info:", &part_2_orient_info, 0);
#endif
   
   rows = cols = 4;
   num_pnts = 1;

   /*
    *  Mating routines always align the normals in the same direction, so
    *  to maintain opposite direction flip the normals 
    */
   flip_normal(part_1_orient_info.surf_normal);
   /*
    * This routine ensures mating normals of the two surfaces and 
    * coincidence of the points thru which the normals of surfaces pass 
    */
   if(MAte_transform(part_2_orient_info.surf_normal,part_2_orient_info.surf_point,
		     part_1_orient_info.surf_normal,part_1_orient_info.surf_point,
		     temp_trans_mat) == FALSE)
     return(ASM_MABS_FAIL);
#ifdef DEBUG
for(cols=0;cols<16;cols++)
printf("temptransmat[%d]=%f\n",cols,temp_trans_mat[cols]);
#endif

   /* 
    * Transform part1 with above transformation matrix (temp_trans_mat) 
    */
   get_rotmat(temp_trans_mat,trmat);
   if(MAptsxform(&rc,&num_pnts,trmat,part_1_orient_info.surf_rot_vector,vec1) == FALSE)
   {
     memcpy(trans_mat,temp_trans_mat,sizeof(IGRmatrix));
     return(ASM_MABS_FAIL);
   }
#ifdef DEBUG
for(cols=0;cols<16;cols++)
printf("trmat[%d]=%f\n",cols,trmat[cols]);
#endif

   /*
    *  The following routine calculates the inplane rotation required to
    *  align the pair of surface rotation vectors to freeze the rotational d.o.f.
    */
   if(FIx_rotation(part_2_orient_info.surf_rot_vector,vec1,part_2_orient_info.surf_normal,
	           part_2_orient_info.surf_point,rotmatx) == FALSE)
   {
     memcpy(trans_mat,temp_trans_mat,sizeof(IGRmatrix));
     return(ASM_MABS_FAIL);
   }
#ifdef DEBUG
for(cols=0;cols<16;cols++)
printf("rotmat[%d]=%f\n",cols,rotmatx[cols]);
cols=4;
#endif

   /*
    * Product of the above two calculated matrices gives the required
    * final transformation matrix 
    */
   MAmulmx(&rc,&rows,&cols,&rows,rotmatx,temp_trans_mat,trans_mat);

#ifdef DEBUG
for(cols=0;cols<16;cols++)
printf("fmat[%d]=%f\n",cols,trans_mat[cols]);
#endif

   return(ASM_MATH_SUCC);
}

/******************************* CASE 2 ************************************
	Description : Align constraint. Here the normals should be in same
	              direction and the points should be collinear
	Feasibility :	It is always feasible to get a solution .
	Return Values : ASM_MATH_SUCC - Success
			ASM_MABS_FAIL - Failure
***************************************************************************/

int align(part_1_orient_info,part_2_orient_info,trans_mat)
ORIENT_INFO	part_1_orient_info;	/** INPUT :Orientation info of part1 */
ORIENT_INFO	part_2_orient_info;	/** INPUT :Orientation info of part2 */
IGRmatrix	trans_mat;		/** OUTPUT:Transformation matrix     */
{
   IGRmatrix	temp_trans_mat,rotmatx,trmat;
   IGRshort	rows,cols;
   IGRint	num_pnts;
   IGRlong	rc;
   IGRvector	vec1;


#ifdef DEBUG
printf("Align Input:\n");
print_input("Part1 Axis:", &part_1_orient_info, 0);
print_input("Part2 Axis:", &part_2_orient_info, 0);
#endif
   
   rows = cols = 4;
   num_pnts =1;

   if(MAte_transform(part_2_orient_info.surf_normal,part_2_orient_info.surf_point,
		     part_1_orient_info.surf_normal,part_1_orient_info.surf_point,
		     temp_trans_mat) == FALSE)
     return(ASM_MABS_FAIL);

   /* 
    *  Transform part1 with above transformation matrix (temp_trans_mat)
    */
   get_rotmat(temp_trans_mat,trmat);
   if(MAptsxform(&rc,&num_pnts,trmat,part_1_orient_info.surf_rot_vector,vec1) == FALSE)
   {
     memcpy(trans_mat,temp_trans_mat,sizeof(IGRmatrix));
     return(ASM_MABS_FAIL);
   }

   /*
    * The following routine calculates the inplane rotation required to
    *  align the pair of surface rotation vectors to freeze the rotational d.o.f.
    */
   if(FIx_rotation(part_2_orient_info.surf_rot_vector,vec1,part_2_orient_info.surf_normal,
	           part_2_orient_info.surf_point,rotmatx) == FALSE)
   {
     memcpy(trans_mat,temp_trans_mat,sizeof(IGRmatrix));
     return(ASM_MABS_FAIL);
   }
   /*
    * Product of the above two calculated matrices gives final transformation matrix 
    */
   MAmulmx(&rc,&rows,&cols,&rows,rotmatx,temp_trans_mat,trans_mat);
   return(ASM_MATH_SUCC);
}
/******************************* CASE 3 ************************************
	Description :	The two mates are perpendicular to each other
	Feasibility :	It is always feasible to get a solution .
	Return Values : ASM_MATH_SUCC -- Success
			ASM_MABS_FAIL -- Failure
***************************************************************************/
int mate_mate_ortho(part_1_surf_1,part_1_surf_2,part_2_surf_1,
		    part_2_surf_2, trans_mat)
SURF_INFO	part_1_surf_1; /** 1st surface on part 1 info INPUT **/
SURF_INFO	part_1_surf_2; /** 2nd surface on part 1 info INPUT **/
SURF_INFO	part_2_surf_1; /** 1st surface on part 2 info INPUT **/
SURF_INFO	part_2_surf_2; /** 2nd surface on part 2 info INPUT **/
IGRmatrix	trans_mat;     /** Transformation matrix OUTPUT     **/
{

	IGRlong		rc;
	IGRmatrix	trmat,fmat;
	IGRpoint	pnttrans,pntproj,pntproj1;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRdouble	dist,dist_tol;
	IGRint		value;

#ifdef DEBUG
printf("Mate_Mate_Ortho Input:\n");
print_input("Part1 Surf1 Info:", &part_1_surf_1, 1 );
print_input("Part1 Surf2 Info:", &part_1_surf_2, 1 );
print_input("Part2 Surf1 Info:", &part_2_surf_1, 1 );
print_input("Part2 Surf2 Info:", &part_2_surf_2, 1 );
#endif


	num_pnts =1;
	rows = cols = 4;
 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	/*
	 *  part_1_surf_1 and part_2_surf_1 surfaces are mated part_1_surf_2 and part_2_surf_2 
	 *  surfaces are mated with this routine. Mating ensures normals to be in
	 *  opposite direction and the surfaces to touch each other
	 */
	 value = mate_mate_ortho_half(part_1_surf_1,part_1_surf_2,part_2_surf_1,part_2_surf_2,fmat);
	 if(value != ASM_MATH_SUCC)
	 {
	   memcpy(trans_mat,fmat,sizeof(IGRmatrix));
	   return(ASM_MABS_FAIL);
	 }
	
	/*  
	 *  Minimize distance between the two specified points on the surfaces part1surf1 
	 *  and part2surf1 to freeze translational degree of freedom  
	 */

	if(proj_pnt_to_plane(part_2_surf_1.surf_point,part_2_surf_2.surf_normal,
			     part_2_surf_2.surf_point,pntproj) == FALSE)
	{
	  memcpy(trans_mat,fmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	if(MAptsxform(&rc,&num_pnts,fmat,part_1_surf_1.surf_point,pnttrans) == FALSE)
        {
	  memcpy(trans_mat,fmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	if(proj_pnt_to_plane(pnttrans,part_2_surf_2.surf_normal,
			  part_2_surf_2.surf_point,pntproj1) == FALSE)
        {
	  memcpy(trans_mat,fmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	/*
	 * if distance between projected points is zero it implies that
	 * the points are already at minimum distance 
         */
	dist = BSdistptpt(&rc,pntproj,pntproj1); 
	if(dist < dist_tol) 
	  memcpy(trans_mat,fmat,sizeof(IGRmatrix));
	else
	{
	  get_trnsl_matrix(pntproj1,pntproj,trmat);
	  MAmulmx(&rc,&rows,&cols,&rows,trmat,fmat,trans_mat);
	}
	return(ASM_MATH_SUCC);
}

/******************************* CASE 4 ************************************
	Description   :	Mate and Align are perpendicular to each other
	Feasibility   :	It is Not always feasible to get a complete solution.
	Return Values : ASM_MATH_SUCC -- Success with full solution
			ASM_MATE_SUCC -- Partial Solution with only Mate success
		        ASM_ALIGN_SUCC - Partial Solution with only Align success
			ASM_MABS_FAIL -- Failure
***************************************************************************/
int mate_align_ortho(part_1_axis,part_1_surf,part_2_axis,
		     part_2_surf,constr_order,trans_mat)
AXIS_INFO	part_1_axis;   /** axis on part 1 info INPUT       **/
AXIS_INFO	part_2_axis;   /** axis on part 2 info INPUT       **/ 
SURF_INFO	part_1_surf;   /** surface on part 1 info INPUT    **/
SURF_INFO	part_2_surf;   /** surface on part 2 info INPUT    **/
IGRint		constr_order;  /** Order of satisfying constraints **/
IGRmatrix	trans_mat;     /** Transformation matrix  OUTPUT   **/
{

	IGRint		num_pnts;
	IGRdouble	dist_tol,dist;
	IGRlong		rc;
	IGRpoint	pnttrans,pnt1,pnt2;
	IGRpoint	pnts[3];
	IGRboolean	status;
	IGRmatrix	rmat;
	IGRvector	nrmtrans;


#ifdef DEBUG
printf("Mate_Align_Ortho Input:\n");
print_input("Part1 Axis Info:", &part_1_axis, 2 );
print_input("Part1 Surf Info:", &part_1_surf, 1 );
print_input("Part2 Axis Info:", &part_2_axis, 2 );
print_input("Part2 Surf Info:", &part_2_surf, 1 );
#endif
	num_pnts = 1;

 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	flip_normal(part_1_surf.surf_normal);

	/* 
	 * Following routine ensures aligning of axes , coincidence of 
	 * points (axis_points) and parallelity of normals of the surfaces , 
	 * but touching of the surfaces is not ensured which is requirement for mating 
	 */ 
	if(constr_order == 2) 
	{
	  if(ALign_vector_pair(part_2_axis.axis_direction, part_2_axis.axis_point,
			       part_1_axis.axis_direction,part_1_axis.axis_point,
			       part_2_surf.surf_normal, part_2_surf.surf_point,
			       part_1_surf.surf_normal, part_1_surf.surf_point,
			       trans_mat) == FALSE)
             return(ASM_MABS_FAIL);
	  /*
	   * If part_1_surf_point lies on the surface part_2_surf
           * then it is a full solution, otherwise it is a partial solution. 
           */
	  MAptsxform(&rc,&num_pnts,trans_mat,part_1_surf.surf_point,pnttrans);
	  BSdistptpl(&rc,pnttrans,part_2_surf.surf_point,part_2_surf.surf_normal,&dist);
	  if(dist < dist_tol)
	    return(ASM_MATH_SUCC);
	  else
	    return(ASM_ALIGN_SUCC);
	}
	if(constr_order == 1) /*** surfaces to be mated first ****/
	{
	  if(ALign_vector_pair(part_2_surf.surf_normal, part_2_surf.surf_point,
			       part_1_surf.surf_normal, part_1_surf.surf_point,
			       part_2_axis.axis_direction,part_2_axis.axis_point,
			       part_1_axis.axis_direction,part_1_axis.axis_point,
			       trans_mat) == FALSE)
	    return(ASM_MABS_FAIL);
	  /*
	   *  If the axes are collinear then it is a full solution otherwise it is 
	   *  a partial solution 
	   */
	   MAptsxform(&rc,&num_pnts,trans_mat,part_1_axis.axis_point,pnttrans);
	   get_rotmat(trans_mat,rmat);
	   MAptsxform(&rc,&num_pnts,rmat,part_1_axis.axis_direction,nrmtrans);
	   get_second_point(pnttrans,nrmtrans ,pnt1);
	   get_second_point(part_2_axis.axis_point,part_2_axis.axis_direction,pnt2);
	   num_pnts = 4;
	   memcpy(pnts[0],pnt1,sizeof(IGRpoint));
	   memcpy(pnts[1],pnt2,sizeof(IGRpoint));
	   memcpy(pnts[2],pnttrans,sizeof(IGRpoint));
	   memcpy(pnts[3],part_2_surf.surf_point,sizeof(IGRpoint));
	   status = BScollinmny(&rc,&num_pnts,pnts);
	   if(status == TRUE)
	     return(ASM_MATH_SUCC);
	   else
	     return(ASM_MATE_SUCC);
	}
	return(ASM_MABS_FAIL);
}

/******************************* CASE 5 ************************************
	Description   : The two aligns are perpendicular to each other  
	Feasibility   :	It is NOT always feasible to get a solution .
	Return Values :	ASM_MATH_SUCC -- Success
			ASM_MABS_FAIL -- Failure
			ASM_FST_ALIGN_SUCC -- Partial Success
			ASM_SEC_ALIGN_SUCC -- Partial Success
***************************************************************************/
int align_align_ortho(part_1_axis_1,part_1_axis_2,part_2_axis_1,part_2_axis_2,
		  constr_order,trans_mat)
AXIS_INFO	part_1_axis_1;   /** axis 1 on part 1 info INPUT     **/
AXIS_INFO	part_2_axis_1;   /** axis 2 on part 2 info INPUT     **/ 
AXIS_INFO	part_1_axis_2;   /** axis 1 on part 1 info INPUT     **/
AXIS_INFO	part_2_axis_2;   /** axis 2 on part 2 info INPUT     **/ 
IGRint		constr_order;    /** Order of satisfying constraints **/
IGRmatrix	trans_mat;       /** Transformation matrix  OUTPUT   **/
{
	IGRlong		rc;
	IGRmatrix	fmattmp,trnsmat;
	IGRpoint	pnt1,pnt2,pnttrans,pntproj;
	IGRdouble	dist,length;
	IGRdouble	cross_tol,dist_tol;
	IGRvector	vec1,crossvc;
	IGRshort	rows,cols;
	IGRint		num_pnts;


#ifdef DEBUG
printf("Align_Align_Ortho Input:\n");
print_input("Part1 Axis1 Info:", &part_1_axis_1, 2 );
print_input("Part1 Axis2 Info:", &part_1_axis_2, 2 );
print_input("Part2 Axis1 Info:", &part_2_axis_1, 2 );
print_input("Part2 Axis2 Info:", &part_2_axis_2, 2 );
#endif

	rows = cols = 4;
	num_pnts = 1;

 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	BSEXTRACTPAR(&rc,BSTOLCOLLINVEC,cross_tol);

        /*
         * This ensures alignment of the axis_1's on both parts and
         * and makes the axis_2's parallel 
         */
	if(ALign_vector_pair(part_2_axis_1.axis_direction,part_2_axis_1.axis_point,
			     part_1_axis_1.axis_direction,part_1_axis_1.axis_point,
			     part_2_axis_2.axis_direction,part_2_axis_2.axis_point,
			     part_1_axis_2.axis_direction,part_1_axis_2.axis_point,
			     fmattmp) == FALSE)
	  return(ASM_MABS_FAIL);
	memcpy(pnt2,part_1_axis_2.axis_point,sizeof(IGRpoint));
	memcpy(pnt1,part_2_axis_2.axis_point,sizeof(IGRpoint));

	/** Transform pnt2 with fmattmp  ***/
	if(MAptsxform(&rc,&num_pnts,fmattmp,pnt2,pnttrans) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	/*** Project pnttrans on to plane of axis_2_part2 **/
	if(proj_pnt_to_plane(pnttrans,part_2_axis_2.axis_direction,
			  part_2_axis_2.axis_point,pntproj) == FALSE)
        {
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	MA2ptdis(&rc,pnt1,pntproj,&dist);
	if(dist < dist_tol)   
	/*
	 * the vectors are already aligned 
	 */
        {
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MATH_SUCC); 
	}
	BSmkvec(&rc,vec1,pnt1,pntproj);
	if(MAcrossvc(&rc,vec1,part_2_axis_1.axis_direction,crossvc) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	MAlenvc(&rc,crossvc,&length);
	if(fabs(length) < cross_tol)
	{
	  get_trnsl_matrix(pntproj,pnt1,trnsmat);
          MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmattmp,trans_mat);
	  return(ASM_MATH_SUCC);
	}
	else
	{
	  /*
	   *  Partial solution satisfies only alignment of 1st set of axes
	   *  or second set of axes 
	   */
	  if(constr_order == 1)
	  {
	    memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	    return(ASM_FST_ALIGN_SUCC);
	  }
	  if(constr_order == 2)  
	  {
      	    if(ALign_vector_pair(part_2_axis_2.axis_direction,part_2_axis_2.axis_point,
			         part_1_axis_2.axis_direction,part_1_axis_2.axis_point,
			         part_2_axis_1.axis_direction,part_2_axis_1.axis_point,
			         part_1_axis_1.axis_direction,part_1_axis_1.axis_point,
				 trans_mat) == FALSE)
	      return(ASM_MABS_FAIL);
	    else
	      return(ASM_SEC_ALIGN_SUCC);
	  }
	}
	return(ASM_MABS_FAIL);
}

/******************************* CASE 7 ************************************
	Description :	Mate and Align are parallel to each other
	Feasibility :	It is always feasible to get a solution .
	Return Values : ASM_MATH_SUCC -- Success
			ASM_MABS_FAIL -- Failure
***************************************************************************/
int mate_align_parallel(part_1_orient_info,part_2_orient_info,trans_mat)
ORIENT_INFO	part_1_orient_info;	/** INPUT :Orientation info of part1 */
ORIENT_INFO	part_2_orient_info;	/** INPUT :Orientation info of part2 */
IGRmatrix	trans_mat;		/** OUTPUT:Transformation matrix     */
{
	IGRlong		rc;
	IGRmatrix	fmattmp,trmat,rotmatx;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRvector	vec1;

#ifdef DEBUG
printf("Mate_Align_Parallel Input:\n");
print_input("Part1 Orient Info:", &part_1_orient_info, 0 );
print_input("Part2 Orient Info:", &part_2_orient_info, 0 );
#endif


	rows = cols = 4;
	num_pnts = 1;
	if(MAte_transform(part_2_orient_info.surf_normal,part_2_orient_info.surf_point,
		          part_1_orient_info.surf_normal,part_1_orient_info.surf_point,
		          fmattmp) == FALSE)
	  return(ASM_MABS_FAIL);
	get_rotmat(fmattmp,trmat);
	if( MAptsxform(&rc,&num_pnts,trmat,part_1_orient_info.surf_rot_vector,vec1) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
        if(FIx_rotation(part_2_orient_info.surf_rot_vector,vec1,part_2_orient_info.surf_normal,
		        part_2_orient_info.surf_point,rotmatx) == FALSE)
	{
          memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
        MAmulmx(&rc,&rows,&cols,&rows,rotmatx,fmattmp,trans_mat);
	return(ASM_MATH_SUCC);
}

/******************************* CASE 8 ************************************
	Description :   Two aligns parallel to each other
	Feasibility :	It is Not feasible to get a full solution always.
	Return Values : ASM_MATH_SUCC - Complete Solution
			ASM_FST_ALIGN_SUCC - Partial Solution
			ASM_SEC_ALIGN_SUCC - Partial Solution
			ASM_MABS_FAIL	Failure
***************************************************************************/
int align_align_parallel(part_1_axis_1,part_1_axis_2,part_2_axis_1,part_2_axis_2,
		         constr_order,trans_mat)
AXIS_INFO	part_1_axis_1;   /** axis 1 on part 1 info INPUT     **/
AXIS_INFO	part_2_axis_1;   /** axis 2 on part 2 info INPUT     **/ 
AXIS_INFO	part_1_axis_2;   /** axis 1 on part 1 info INPUT     **/
AXIS_INFO	part_2_axis_2;   /** axis 2 on part 2 info INPUT     **/ 
IGRint		constr_order;    /** Order of satisfying constraints **/
IGRmatrix	trans_mat;       /** Transformation matrix  OUTPUT   **/
{
	IGRlong		rc;
	IGRmatrix	fmattmp,rotmatx;
	IGRpoint	pnt1,pnt2,pnt1trans,pnt1proj,pnt2proj;
	IGRvector	vec1,vec2;
	IGRdouble	alpha,dist1,dist2,dist_tol;
	IGRshort	rows,cols;
	IGRint		num_pnts;

#ifdef DEBUG
printf("Align_Align_Parallel Input:\n");
print_input("Part1 Axis1 Info:", &part_1_axis_1, 2 );
print_input("Part1 Axis2 Info:", &part_1_axis_2, 2 );
print_input("Part2 Axis1 Info:", &part_2_axis_1, 2 );
print_input("Part2 Axis2 Info:", &part_2_axis_2, 2 );
#endif

	rows = cols = 4;
	num_pnts = 1;

 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	/*
         * This aligns axis_1 of both parts and coincides their axis points 
	 */
	if(MAte_transform(part_2_axis_1.axis_direction,part_2_axis_1.axis_point,
		          part_1_axis_1.axis_direction, part_1_axis_1.axis_point,
		          fmattmp) == FALSE)
	  return(ASM_MABS_FAIL);
	memcpy(pnt1,part_1_axis_2.axis_point,sizeof(IGRpoint));
	memcpy(pnt2,part_2_axis_1.axis_point,sizeof(IGRpoint));
	if(MAptsxform(&rc,&num_pnts,fmattmp,pnt1,pnt1trans) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));	  
	  return(ASM_MABS_FAIL);
	}
	if(proj_pnt_to_plane(pnt1trans,part_2_axis_1.axis_direction,
			  part_2_axis_1.axis_point,pnt1proj) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));	  
	  return(ASM_MABS_FAIL);
	}
	
	if(proj_pnt_to_plane(part_2_axis_2.axis_point,part_2_axis_1.axis_direction,
		          part_2_axis_1.axis_point,pnt2proj) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));	  
	  return(ASM_MABS_FAIL);
	}
	
	/*
	 * It may not be always possible to align the second normal 
	 * calculate the distance between pnt2 & pnt1proj and pnt2 & pnt2proj 
	 * if they are different then full solution is not feasible 
	 */

	MA2ptdis(&rc,pnt2,pnt1proj,&dist1);
	MA2ptdis(&rc,pnt2,pnt2proj,&dist2);
	if(fabs(dist1 - dist2) > dist_tol)
	{
#ifdef DEBUG
	  printf("Not always feasible case \n");
#endif
	   if(constr_order == 1)
	   {
	     memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	     return(ASM_FST_ALIGN_SUCC);
	   }
	   if(constr_order == 2)
	   {
	     if( MAte_transform(part_2_axis_2.axis_direction,part_2_axis_2.axis_point,
				part_1_axis_2.axis_direction,part_1_axis_2.axis_point,
				trans_mat) == FALSE)
	       return(ASM_MABS_FAIL);
	     else
	       return(ASM_SEC_ALIGN_SUCC);
	   }
	}
	
	/*
	 * if the 3 points are collinear then the second pair is already aligned
	 */
	if(BScollin(&rc,pnt2,pnt1proj,pnt2proj) == TRUE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	}
	else
	{	
	  /*
	   * Rotate about part2axis1 to align second set of normals 
	   */
	  BSmkvec(&rc,vec1,pnt2,pnt1proj);
	  BSmkvec(&rc,vec2,pnt2,pnt2proj);
	  MATH_ang_of_lines(vec1,vec2,&alpha,part_2_axis_1.axis_direction);
	  MAgrotmx(&rc,part_2_axis_1.axis_direction,part_2_axis_1.axis_point,
	           &alpha,rotmatx);
	  if(rc != MSSUCC)
	  {
	    memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	    return(ASM_MABS_FAIL);
	  }  
          MAmulmx(&rc,&rows,&cols,&rows,rotmatx,fmattmp,trans_mat);
	}
	return(ASM_MATH_SUCC);
}

/******************************* CASE 9 ************************************
	Description :	Two mates with an acute angle between them
	Feasibility :	It is always feasible to get a solution .
	return_values : ASM_MATH_SUCC - Full Solution
			ASM_MABS_FAIL - Failure
			ASM_INVALID_INPUT - Corresponding Angles unequal
***************************************************************************/
int mate_mate_acute(part_1_surf_1,part_1_surf_2,part_2_surf_1,part_2_surf_2,
		trans_mat)
SURF_INFO	part_1_surf_1; /** 1st surface on part 1 info INPUT **/
SURF_INFO	part_1_surf_2; /** 2nd surface on part 1 info INPUT **/
SURF_INFO	part_2_surf_1; /** 1st surface on part 2 info INPUT **/
SURF_INFO	part_2_surf_2; /** 2nd surface on part 2 info INPUT **/
IGRmatrix	trans_mat;     /** Transformation matrix OUTPUT     **/
{
	IGRlong		rc;
	IGRmatrix	trnsmat,fmattmp;
	IGRdouble	tparm;
	IGRpoint	orthtranspt,pnt3,orthptproj;
	IGRvector	orthvec;
	struct IGRline	line1;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRint		value;


#ifdef DEBUG
printf("Mate_Mate_Acute Input:\n");
print_input("Part1 Surf1 Info:", &part_1_surf_1, 1 );
print_input("Part1 Surf2 Info:", &part_1_surf_2, 1 );
print_input("Part2 Surf1 Info:", &part_2_surf_1, 1 );
print_input("Part2 Surf2 Info:", &part_2_surf_2, 1 );
#endif

	rows = cols = 4;
	num_pnts = 1;

	value = mate_mate_acute_half(part_1_surf_1,part_1_surf_2,part_2_surf_1,
			             part_2_surf_2,fmattmp);
	if(value == ASM_INVALID_INPUT)
	  return(ASM_INVALID_INPUT);
	if(value == ASM_MABS_FAIL)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	/*
	 *  To Freeze the dof orthogonal to both the state vectors 
         *  find orthogonal vector which is cross prod of state vectors 
	 */
	
	if(MAcrossvc(&rc,part_2_surf_1.surf_normal,part_2_surf_2.surf_normal,
		     orthvec) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	if(MAptsxform(&rc,&num_pnts,fmattmp,part_1_surf_1.surf_point,orthtranspt) == FALSE)
	{
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	get_second_point(part_2_surf_1.surf_point,orthvec,pnt3);
	line1.point1 = part_2_surf_1.surf_point;
	line1.point2 = pnt3;
	if(MAptlnproj(&rc,orthtranspt,&line1,orthptproj,&tparm) == FALSE)
        {
	  memcpy(trans_mat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	get_trnsl_matrix(orthptproj,part_2_surf_1.surf_point,trnsmat);
	MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmattmp,trans_mat);
	return(ASM_MATH_SUCC);
}

/******************************* CASE 10 ************************************
	Description   : mate and align making an acute angle between them
	Feasibility   :	It is always feasible to get a solution .
	Return Values : ASM_MATH_SUCC -- Success
			ASM_MABS_FAIL -- Failure
			ASM_INVALID_INPUT -- Corresponding angles not equal
***************************************************************************/
int mate_align_acute(part_1_axis,part_1_surf,part_2_axis,part_2_surf,trans_mat)
AXIS_INFO	part_1_axis;   /** axis on part 1 info INPUT       **/
AXIS_INFO	part_2_axis;   /** axis on part 2 info INPUT       **/ 
SURF_INFO	part_1_surf;   /** surface on part 1 info INPUT    **/
SURF_INFO	part_2_surf;   /** surface on part 2 info INPUT    **/
IGRmatrix	trans_mat;     /** Transformation matrix  OUTPUT   **/
{
	IGRdouble	alpha,beta,dist_tol;
	IGRmatrix	tmat,rmat,trnsmat;
	IGRpoint	pnt1,intpnt1,pnttrans,pnt2,intpnt2;
	IGRlong		rc;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRvector	nrmtrans;
#ifdef DEBUG
printf("Mate_Align_Acute Input:\n");
print_input("Part1 Axis Info:", &part_1_axis, 2 );
print_input("Part1 Surf Info:", &part_1_surf, 1 );
print_input("Part2 Axis Info:", &part_2_axis, 2 );
print_input("Part2 Surf Info:", &part_2_surf, 1 );
#endif

	num_pnts = 1;
	rows = cols =4;
 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);

	/** Compute angles between the constraints for both parts **/
	if(get_angles_btwn_normals(part_1_axis.axis_direction,
				part_1_surf.surf_normal,&alpha) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_2_axis.axis_direction,
				part_2_surf.surf_normal,&beta) == FALSE)
	  return(ASM_MABS_FAIL);

	/*
	 * Verify that the angles between the constraints are same 
	 */
	if(fabs(alpha - beta) > dist_tol)
	{
#ifdef DEBUG
	  printf("ERR:angles between mating surfaces do not match\n");
#endif	
	  return(ASM_INVALID_INPUT);
	}

	flip_normal(part_1_surf.surf_normal);
	if(ALign_vector_pair(part_2_surf.surf_normal,part_2_surf.surf_point,
			     part_1_surf.surf_normal, part_1_surf.surf_point,
			     part_2_axis.axis_direction,part_2_axis.axis_point,
			     part_1_axis.axis_direction, part_1_axis.axis_point,
			     tmat) == FALSE)
	  return(ASM_MABS_FAIL);
	memcpy(trans_mat,tmat,sizeof(IGRmatrix));
	/*
	 * Find the pnt of intersection of surf2.part1.norm & surf2.part2.norm
	 * with surf1.part1 
	 */
	get_second_point(part_2_axis.axis_point,part_2_axis.axis_direction,pnt1);
	BSxlnpl(&rc,part_2_surf.surf_normal,part_2_surf.surf_point,
		part_2_axis.axis_point,pnt1,intpnt1);	
	if((rc == BSCOINCIDENT) || (rc == BSNOSOLUTION))
	  return(ASM_MABS_FAIL);
	if(MAptsxform(&rc,&num_pnts,tmat,part_1_axis.axis_point,pnttrans) == FALSE)
	  return(ASM_MABS_FAIL);
	get_rotmat(tmat,rmat);
	if(MAptsxform(&rc,&num_pnts,rmat,part_1_axis.axis_direction,nrmtrans) == FALSE)
	  return(ASM_MABS_FAIL);
	get_second_point(pnttrans,nrmtrans,pnt2);

	BSxlnpl(&rc,part_2_surf.surf_normal,part_2_surf.surf_point,pnttrans, pnt2,intpnt2);
        if((rc == BSCOINCIDENT) || (rc == BSNOSOLUTION))
	  return(ASM_MABS_FAIL);
	get_trnsl_matrix(intpnt2,intpnt1,trnsmat);
	MAmulmx(&rc,&rows,&cols,&rows,trnsmat,tmat,trans_mat);
	return(ASM_MATH_SUCC);
}

/******************************* CASE 11 ************************************
	Description    :   Two aligns with an acute angle between them
	Feasibility    :   It is not always feasible to get a solution .
	Return_values  :   ASM_MATH_SUCC -- Full Solution
			   ASM_MABS_FAIL -- Failure
			   ASM_INVALID_INPUT -- Invalid Input
			   ASM_FST_ALIGN_SUCC -- Only 1st align satsified
			   ASM_SEC_ALIGN_SUCC - only 2nd align satisfied
***************************************************************************/
int align_align_acute(part_1_axis_1,part_1_axis_2,part_2_axis_1,
		      part_2_axis_2,constr_order,trans_mat)
AXIS_INFO	part_1_axis_1;   /** axis 1 on part 1 info INPUT     **/
AXIS_INFO	part_2_axis_1;   /** axis 2 on part 2 info INPUT     **/ 
AXIS_INFO	part_1_axis_2;   /** axis 1 on part 1 info INPUT     **/
AXIS_INFO	part_2_axis_2;   /** axis 2 on part 2 info INPUT     **/ 
IGRint		constr_order;    /** Order of satisfying constraints **/
IGRmatrix	trans_mat;       /** Transformation matrix  OUTPUT   **/
{
	IGRdouble	alpha,beta,dist,dist_tol;
	IGRmatrix	tmat,rmat,trnsmat;
	IGRlong		rc;
	IGRpoint	pnttrans,pnt1,pnt2,intpnts[2];
	IGRvector	nrmtrans;
	struct	IGRline	vecline[2], *vlin[2];
	IGRshort	rows,cols;
	IGRint		num_pnts;
#ifdef DEBUG
printf("Align_Align_Parallel Input:\n");
print_input("Part1 Axis1 Info:", &part_1_axis_1, 2 );
print_input("Part1 Axis2 Info:", &part_1_axis_2, 2 );
print_input("Part2 Axis1 Info:", &part_2_axis_1, 2 );
print_input("Part2 Axis2 Info:", &part_2_axis_2, 2 );
#endif


	rows = cols = 4;
	num_pnts = 1;

	if(get_angles_btwn_normals(part_1_axis_1.axis_direction,
				part_2_axis_1.axis_direction,&alpha) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_1_axis_2.axis_direction,
				part_2_axis_2.axis_direction,&beta) == FALSE)
	  return(ASM_MABS_FAIL);
 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	if(fabs(alpha - beta) > dist_tol)
	{
#ifdef DEBUG
	  printf("ERR:angles between mating surfaces do not match\n");
#endif	
	  return(ASM_INVALID_INPUT);
	}
	/* 
	 * Mate the first pair of surfaces given as input 
	 */
	if( ALign_vector_pair(part_2_axis_1.axis_direction, part_2_axis_1.axis_point,
			      part_1_axis_1.axis_direction, part_1_axis_1.axis_point,
			      part_2_axis_2.axis_direction, part_2_axis_2.axis_point,
			      part_1_axis_2.axis_direction, part_1_axis_2.axis_point,
			      tmat) == FALSE )
	  return(ASM_MABS_FAIL);
	if(MAptsxform(&rc,&num_pnts,tmat,part_1_axis_2.axis_point,pnttrans) == FALSE)
	{
	  memcpy(trans_mat,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	get_rotmat(tmat,rmat);
	if( MAptsxform(&rc,&num_pnts,rmat,part_1_axis_2.axis_direction,nrmtrans) == FALSE)
	{
	  memcpy(trans_mat,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	/*
	 *  Find point of intersection between nrmtrans & surf2-part1.norm2 
	 */
	vecline[0].point1 = part_2_axis_2.axis_point;
	get_second_point(part_2_axis_2.axis_point,part_2_axis_2.axis_direction,				 pnt1);
	vecline[0].point2 = pnt1;
	vecline[1].point1 = pnttrans;
	get_second_point(pnttrans,part_2_axis_1.axis_direction,pnt2);
	vecline[1].point2 = pnt2;

	vlin[0] = &vecline[0];
	vlin[1] = &vecline[1];
	BSint2lns(vlin,intpnts,&dist,&rc);
	if(rc == BSNOINTERS)
	{
	  /*
	   *  Partial Solution
	   */
	  if(constr_order == 1)
	  {
	    memcpy(trans_mat,tmat,sizeof(IGRmatrix));
	    return(ASM_FST_ALIGN_SUCC);
	  }
	  if(constr_order == 2)
	  {
	    if(ALign_vector_pair(part_2_axis_2.axis_direction, part_2_axis_2.axis_point,
			         part_1_axis_2.axis_direction, part_1_axis_2.axis_point,
				 part_2_axis_1.axis_direction, part_2_axis_1.axis_point,
				 part_1_axis_1.axis_direction, part_1_axis_1.axis_point,
				 trans_mat) == FALSE)
	      return(ASM_MABS_FAIL);
	    else
	      return(ASM_SEC_ALIGN_SUCC);
	  }
	}
	get_trnsl_matrix(pnttrans,intpnts[0],trnsmat);
	MAmulmx(&rc,&rows,&cols,&rows,trnsmat,tmat,trans_mat);
	return(ASM_MATH_SUCC);
}

/******************************* CASE 12 ************************************

	Description :	Three Mates to be satisfied. None of the mates can
		        be parallel 
	Feasibility :	It is always feasible to get a solution .
	Remarks     :   The two normals of part2 surface normal's to be flipped.
			No need of flipping third one as no rotation
			can be applied on this normal to satisfy
			the third mate, without disturbing first two mates. 
	Return Values:  ASM_MATH_SUCC -- Success
			ASM_MABS_FAIL -- Failure
			ASM_INVALID_INPUT -- Input not valid
***************************************************************************/
int mate_mate_mate(part_1_surf_1,part_1_surf_2,part_1_surf_3,
		   part_2_surf_1,part_2_surf_2,part_2_surf_3,trans_mat)
SURF_INFO	part_1_surf_1; /** 1st surface on part 1 info INPUT **/
SURF_INFO	part_1_surf_2; /** 2nd surface on part 1 info INPUT **/
SURF_INFO 	part_1_surf_3; /** 3rd surface on part 1 info INPUT **/
SURF_INFO	part_2_surf_1; /** 1st surface on part 2 info INPUT **/
SURF_INFO	part_2_surf_2; /** 2nd surface on part 2 info INPUT **/
SURF_INFO 	part_2_surf_3; /** 3rd surface on part 2 ifno INPUT **/
IGRmatrix	trans_mat;     /** Transformation matrix OUTPUT     **/
{
	IGRdouble	alpha,beta,gama,dist_tol;
	IGRdouble	alpha1,beta1,gama1,ninety;
	IGRmatrix	fmatmp,trnsmat,rmat;
	IGRlong		rc;
	IGRpoint	pnttrans,intpnt,pnt1;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRvector	nrmtrans;
	IGRint		value;

#ifdef DEBUG
printf("Mate_Mate_Mate Input:\n");
print_input("Part1 Surf1 Info:", &part_1_surf_1, 1 );
print_input("Part1 Surf2 Info:", &part_1_surf_2, 1 );
print_input("Part1 Surf3 Info:", &part_1_surf_3, 1 );
print_input("Part2 Surf1 Info:", &part_2_surf_1, 1 );
print_input("Part2 Surf2 Info:", &part_2_surf_2, 1 );
print_input("Part2 Surf3 Info:", &part_2_surf_3, 1 );
#endif


	rows = cols = 4;
	num_pnts = 1;
	MAidmx( &rc, trans_mat);
	ninety = PI/2.0;

	if( get_angles_btwn_normals(part_1_surf_1.surf_normal,
				part_1_surf_2.surf_normal,&alpha) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_1_surf_2.surf_normal,
				part_1_surf_3.surf_normal,&beta) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_1_surf_3.surf_normal,
				part_1_surf_1.surf_normal,&gama) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_2_surf_1.surf_normal,
				part_2_surf_2.surf_normal,&alpha1) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_2_surf_2.surf_normal,
				part_2_surf_3.surf_normal,&beta1) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_2_surf_3.surf_normal,
				part_2_surf_1.surf_normal,&gama1) == FALSE)
	  return(ASM_MABS_FAIL);

 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	
	/*
	 * Not very sure if this check will be always correct
	 */

	if((fabs(alpha - alpha1) > dist_tol)|| (fabs(beta - beta1) > dist_tol)
		|| (fabs(gama - gama1) > dist_tol))
	{
#ifdef DEBUG
		printf("Corresponding Relative angles are not same\n");
#endif	
	        return(ASM_INVALID_INPUT);
	}

	/* 
	 *  Also check for none of the mates being parallel 
	 */
	if((fabs(alpha) < dist_tol) || (fabs(beta) < dist_tol) || 
			(fabs(gama) < dist_tol))
	{
#ifdef DEBUG
	  printf("Constraints cannot be parallel to each other\n");
#endif	
	  return(ASM_INVALID_INPUT);
	}

	/* 
	 * The angle between any two constraints can be ninety or an acute 
	 */

	if(fabs(alpha - ninety) < dist_tol)
	{
	  value = mate_mate_ortho_half(part_1_surf_1,part_1_surf_2,part_2_surf_1,
			       part_2_surf_2,fmatmp);
	  if(value != ASM_MATH_SUCC)
	  {
	     memcpy(trans_mat,fmatmp,sizeof(IGRmatrix));
	     return(ASM_MABS_FAIL);
	  }
	}
	else
	{   
	  if(mate_mate_acute_half(part_1_surf_1,part_1_surf_2,part_2_surf_1,
			       part_2_surf_2,fmatmp) == FALSE)
	  if(value != ASM_MATH_SUCC)
	  {
	     memcpy(trans_mat,fmatmp,sizeof(IGRmatrix));
	     return(value);
	  }
	}

	/* 
	 *  project the transformed point on surf3part2 on to surf3part1 
	 *  Translate along the line of intersection of two mated surfaces 
	 *  to mate with the third surface 
	 */
	
	get_rotmat(fmatmp,rmat);
	if(MAptsxform(&rc,&num_pnts,fmatmp,part_1_surf_3.surf_point,pnttrans) == FALSE)
	{
	  memcpy(trans_mat,fmatmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	if(MAptsxform(&rc,&num_pnts,rmat,part_1_surf_3.surf_normal,nrmtrans) == FALSE)
	{
	  memcpy(trans_mat,fmatmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	get_second_point(pnttrans,nrmtrans,pnt1);
	BSxlnpl(&rc,part_2_surf_3.surf_normal,part_2_surf_3.surf_point,pnttrans,
		pnt1,intpnt);
	if( (rc == BSCOINCIDENT) || (rc == BSNOSOLUTION))
	{
	   memcpy(trans_mat,fmatmp,sizeof(IGRmatrix));
	   return(ASM_MABS_FAIL);
	}
	get_trnsl_matrix(pnttrans,intpnt,trnsmat);
	MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmatmp,trans_mat);
	return(ASM_MATH_SUCC);
}

/******************************* CASE 13 *****************************************
        Description : The two mates are perpendicular and the align is parallel
	              to one of the mates. The order of satisfying constraints 
	              is based on constr_order. if constr_order[0] is 1 and 
	              constr_order[1] is 3, it means that first satisfy mate 
	              followed by align then mate the remaining set of surfaces 
	Feasibility : It is not always feasible to get the solution
	Return Values : ASM_MATH_SUCC -- Success
			ASM_MABS_FAIL -- Failure
			ASM_ALIGN_PART_SUCC -- Align Partially Success
			ASM_MATE_SUCC -- Only Mate successful
			ASM_ALIGN_SUCC - Only Align successful
**********************************************************************************/

int mate_mate_align(part_1_surf_1,part_1_surf_2,part_1_axis,part_2_surf_1,
			part_2_surf_2,part_2_axis,constr_order,trans_mat)
SURF_INFO 	part_1_surf_1,part_1_surf_2,part_2_surf_1,part_2_surf_2;
AXIS_INFO 	part_1_axis,part_2_axis;
IGRint	  	constr_order[2];
IGRmatrix 	trans_mat;
{
	
	IGRmatrix	fmat;
	IGRvector	crsvec1,crsvec2,crsvec;
	IGRlong		rc;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRint		constr_order2; 
	IGRint		value;

#ifdef DEBUG
printf("Mate_Mate_Align Input:\n");
print_input("Part1 Surf1 Info:", &part_1_surf_1, 1 );
print_input("Part1 Surf2 Info:", &part_1_surf_2, 1 );
print_input("Part1 Axis  Info:", &part_1_axis, 2 );
print_input("Part2 Surf1 Info:", &part_2_surf_1, 1 );
print_input("Part2 Surf2 Info:", &part_2_surf_2, 1 );
print_input("Part2 Axis Info:", &part_2_axis, 2 );
#endif


	rows = cols = 4;
	num_pnts = 1;
	constr_order2 = 1;

	if(MAcrossvc(&rc,part_1_surf_1.surf_normal,part_1_surf_2.surf_normal,crsvec) == FALSE)
	  return(ASM_MABS_FAIL);
	if(MAcrossvc(&rc,part_1_surf_1.surf_normal,part_1_axis.axis_direction,crsvec1) == FALSE)
          return(ASM_MABS_FAIL);
	if(MAcrossvc(&rc,part_1_surf_2.surf_normal,part_1_axis.axis_direction,crsvec2) == FALSE)
	  return(ASM_MABS_FAIL);
	switch(constr_order[0])
	{
	  case 1:
	  {
	    switch(constr_order[1])
            {
	      case 2:  /* mate1-mate2-align **/
	      {
		value = mate_mate_ortho_half(part_1_surf_1, part_1_surf_2,part_2_surf_1,
	                                     part_2_surf_2,fmat);
	        if(value != ASM_MATH_SUCC)
		{
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		    return(ASM_MABS_FAIL);
		}
		value = orient_align_vector(part_2_axis.axis_direction,part_2_axis.axis_point,
				    part_1_axis.axis_point,fmat,crsvec,trans_mat);
		return(value);		
	      }
	      case 3:   /* mate1-align-mate2 **/
	      {
	        if(crsvec1 == 0) /* align parallel to mate1 */
	        {
		  value = mate_align_parl_half(part_1_axis,part_1_surf_1,part_2_axis,
					       part_2_surf_1,fmat);
		  if(value != ASM_MATH_SUCC)
		  {
		      memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		      return(ASM_MABS_FAIL);
		  }
		  /*
	           * mate2 pending & perpendclar to align
                   */
	          value = orient_mate_vec_ortho(part_1_surf_2.surf_normal, part_1_surf_2.surf_point,
				                part_2_surf_2.surf_normal, part_2_axis.axis_direction,
				                part_2_axis.axis_point,fmat,trans_mat);
		  if(value == ASM_MABS_FAIL)
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		  return(value);
		}
	        if(crsvec2 == 0) /*mate1 perpendicular to align*/
	        {
		  value = mate_align_ortho(part_1_axis,part_1_surf_2,part_2_axis,part_2_surf_2,
		                   constr_order2,fmat);
		  if(value != ASM_MATH_SUCC)
		  {
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		    return(value);
		  }
		
		  /*
		   * Align is not ensured in the above only mate1 is ensured 
              	   * mate2 pending & parallel to align 
	           */
		  value = orient_mate_vec_parl(part_1_surf_2.surf_point, part_2_surf_2.surf_point,
				       part_2_surf_2.surf_normal,fmat,trans_mat);
  		  if(value != ASM_MATH_SUCC)
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		  return(value);
		}
	      }
            }
	  }
	  case 2:   /*** mate2 **/
	  {
	    switch(constr_order[1])
            {
	      case 1:  /** mate2-mate1-align **/
	      {
	        value = mate_mate_ortho_half(part_1_surf_1,part_1_surf_2,part_2_surf_1,
					     part_2_surf_2,fmat);
	        if(value != ASM_MATH_SUCC)
		{
                  memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		  return(ASM_MABS_FAIL);
		}  
		value = orient_align_vector(part_2_axis.axis_direction, part_2_axis.axis_point,
				    part_1_axis.axis_point,fmat,crsvec,trans_mat);
		return(value);		
	      }
	      case 3: /*** mate2-align-mate1 **/
	      {
	        if(crsvec1 == 0) 
	        /* 
	         * mate2 perpendicular to align and  align parallel to mate1 
                 */
	        {
		  value = mate_align_ortho(part_1_axis,part_1_surf_2,part_2_axis,part_2_surf_2,
                                   constr_order2,fmat);
		  if(value != ASM_MATH_SUCC)
		  {
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		    return(value);
		  }
		  /* 
	           * mate1 pending and parallel to align 
		   */
		   value = orient_mate_vec_parl(part_1_surf_1.surf_point,part_2_surf_1.surf_point,
					part_2_surf_1.surf_normal,fmat,trans_mat);
	           if(value != ASM_MATH_SUCC)
		     memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		   return(value);
		 }
		if(crsvec2 == 0) /* align parallel to mate2 */
		{
		  value = mate_align_parl_half(part_1_axis,part_1_surf_2,part_2_axis,
					       part_2_surf_2,fmat);
         	  if(value != ASM_MATH_SUCC)
		  {
		      memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		      return(ASM_MABS_FAIL);
		  }
		 /* 
	           * mate1 pending and prpndclar to align 
                   */
		  value = orient_mate_vec_ortho(part_1_surf_1.surf_normal,part_1_surf_1.surf_point,
					part_2_surf_1.surf_normal,part_2_axis.axis_direction,
					part_2_axis.axis_point,fmat,trans_mat);
		  if(value == ASM_MABS_FAIL)
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		  return(value);
		}
	      }
	    }
	  }
	  case 3:
	  {
            switch(constr_order[1])
	    {
	      case 1: /** align-mate1-mate2 ***/
	      {
		if(crsvec1 == 0) /** align parallel to mate1 **/
		{
		  value =  mate_align_parl_half(part_1_axis,part_1_surf_1,part_2_axis,
					       part_2_surf_1,fmat);
		  if(value != ASM_MATH_SUCC)
		  {
		      memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		      return(ASM_MABS_FAIL);
		  }
		 /* 
	           * mate2 pending and prpndclar to align 
	           */
		  value = orient_mate_vec_ortho(part_1_surf_2.surf_normal,part_1_surf_2.surf_point,
					part_2_surf_2.surf_normal,part_2_axis.axis_direction,
					part_2_axis.axis_point,fmat,trans_mat);
		  if(value == ASM_MABS_FAIL)
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		  return(value);
		}
		if(crsvec2 == 0)/** align prpndclar to mate1 **/
		{
		  value = mate_align_ortho(part_1_axis,part_1_surf_1,part_2_axis,part_2_surf_1,
				           constr_order2,fmat);
		  if(value != ASM_MATH_SUCC)
		  {
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		    return(value);
		  }
		  /* 
		   * mate2 pending and parallel to align 
		   */
		  value = orient_mate_vec_parl(part_1_surf_2.surf_point,part_2_surf_2.surf_point,
				       part_2_surf_2.surf_normal,fmat,trans_mat);
		  if(value != ASM_MATH_SUCC)
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		  return(value);
		}
	      }
	      case 2:  /** align-mate2-mate1 ***/
	      {
	        if(crsvec1 == 0) /* Align parallel to mate1 **/
		{
		  value = mate_align_ortho(part_1_axis,part_1_surf_2,part_2_axis,part_2_surf_2,
				   constr_order2,fmat);
	          if(value != ASM_MATH_SUCC)
		  {
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		    return(value);
		  }
		  /* 
		   * mate1 pending and parallel to align 
		   */
		  value = orient_mate_vec_parl(part_1_surf_1.surf_point,part_2_surf_1.surf_point,
				       part_2_surf_1.surf_normal,fmat,trans_mat);
		   if(value != ASM_MATH_SUCC)
		     memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		   return(value);
		}
		if(crsvec2 == 0) /* Align parallel to mate2 **/
		{
		  value = mate_align_parl_half(part_1_axis,part_1_surf_2,part_2_axis,part_2_surf_2,fmat);
		  if(value != ASM_MATH_SUCC)
		  {
		      memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		      return(ASM_MABS_FAIL);
		  }
		  /* 
		   *  mate1 pending and perpndclr to align 
		   */
		  orient_mate_vec_ortho(part_1_surf_1.surf_normal,part_1_surf_1.surf_point,
					part_2_surf_1.surf_normal,part_2_axis.axis_direction,
					part_2_axis.axis_point,fmat,trans_mat);
		  if(value == ASM_MABS_FAIL)
		    memcpy(trans_mat,fmat,sizeof(IGRmatrix));
		  return(value);
		}
	      }
	    }
	  }
	}
	return(ASM_MABS_FAIL);
}

/******************************* CASE 14 ************************************
	Description   :   The mate and aligns are all parallel to each other
	Feasibility   :	  Not always Feasible to get full solution
	Return values :   ASM_MATH_SUCC      -- Complete Solution
			  ASM_MABS_FAIL      -- Failure
			  ASM_FST_ALIGN_SUCC -- Partial Solution
			  ASM_SEC_ALIGN_SUCC -- Second align is only successful
***************************************************************************/
int mate_align_align(part_1_surf,part_1_axis_1,part_1_axis_2,
		     part_2_surf,part_2_axis_1,part_2_axis_2,
		     constr_order,trans_mat)
AXIS_INFO	part_1_axis_1;   /** axis_1 on part 1 info INPUT       **/ 
AXIS_INFO	part_1_axis_2;   /** axis_2 on part 1 info INPUT       **/ 
SURF_INFO	part_1_surf;     /** surface on part 1 info INPUT      **/
AXIS_INFO	part_2_axis_1;   /** axis_1 on part 2 info INPUT       **/ 
AXIS_INFO	part_2_axis_2;   /** axis_2 on part 2 info INPUT       **/ 
SURF_INFO	part_2_surf;     /** surface on part 2 info INPUT      **/
IGRint	  	constr_order;    /** Order of priority                 **/
IGRmatrix 	trans_mat;       /** Transformation matrix  OUTPUT     **/
{

	IGRmatrix	trnsmat,trans_mat_tmp;
	IGRmatrix	rotmatx,fmattmp;
	IGRpoint	pnt1proj,pnt1,pntcent,pnt2proj;
	IGRlong		rc;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRdouble	dist1,dist2,dist_tol,alpha;
	IGRvector	vec1,vec2;

#ifdef DEBUG
printf("Mate_Align_Align Input:\n");
print_input("Part1 Surf1 Info:", &part_1_surf, 1 );
print_input("Part1 Axis1 Info:", &part_1_axis_1, 2 );
print_input("Part1 Axis2 Info:", &part_1_axis_2, 2 );
print_input("Part2 Surf1 Info:", &part_2_surf, 1 );
print_input("Part2 Axis1 Info:", &part_2_axis_1, 2 );
print_input("Part2 Axis2 Info:", &part_2_axis_2, 2 );
#endif
	rows = cols = 4;
	num_pnts = 1;
 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);

	/*
	 *  First satisfy the mate constraint, translate to satisfy first align constraint
	 *  and then rotate about the first align axis to satisfy the second align.
	 */
	
	flip_normal(part_1_surf.surf_normal);
	if(MAte_transform(part_2_surf.surf_normal,part_2_surf.surf_point,
		       part_1_surf.surf_normal,part_1_surf.surf_point,fmattmp) == FALSE)
	  return(ASM_MABS_FAIL);
        if(MAptsxform(&rc,&num_pnts,fmattmp,part_1_axis_1.axis_point,pnt1) == FALSE)
	  return(ASM_MABS_FAIL);
        if(proj_pnt_to_plane(pnt1,part_2_surf.surf_normal,part_2_surf.surf_point,pnt1proj) == FALSE)
	  return(ASM_MABS_FAIL);
  	if(proj_pnt_to_plane(part_2_axis_1.axis_point,part_2_surf.surf_normal,
  			  part_2_surf.surf_point,pntcent) == FALSE)
	  return(ASM_MABS_FAIL);
  	get_trnsl_matrix(pnt1proj,pntcent,trnsmat);
 	MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmattmp,trans_mat_tmp);
 	if(MAptsxform(&rc,&num_pnts,trans_mat_tmp,part_1_axis_2.axis_point,pnt1) == FALSE)
	  return(ASM_MABS_FAIL);
 	if(proj_pnt_to_plane(pnt1,part_2_surf.surf_normal,part_2_surf.surf_point,pnt1proj) == FALSE)
	  return(ASM_MABS_FAIL);

	/*
	 * It may not be always possible to align the second normal calculate the distance 
	 * between pntcent & pnt1proj and pntcent & pnt2proj if they are different then break 
	 * out as the solution is not feasible 
         */
	MA2ptdis(&rc,pntcent,pnt1proj,&dist1);
 	if(proj_pnt_to_plane(part_2_axis_2.axis_point,part_2_surf.surf_normal,
 		          part_2_surf.surf_point,pnt2proj) == FALSE)
	  return(ASM_MABS_FAIL);
	MA2ptdis(&rc,pntcent,pnt2proj,&dist2);
	if(fabs(dist1 - dist2) > dist_tol)
	{
#ifdef DEBUG
	   printf("Not always feasible case \n");
#endif
	  if(constr_order == 1)
	  {
	    memcpy(trans_mat,trans_mat_tmp,sizeof(IGRmatrix));
	    return(ASM_FST_ALIGN_SUCC);
	  }
	  if(constr_order == 2)
	  {     
	    if(MAptsxform(&rc,&num_pnts,fmattmp,part_1_axis_2.axis_point,pnt1) == FALSE)
	      return(ASM_MABS_FAIL);
 	    if(proj_pnt_to_plane(pnt1,part_2_surf.surf_normal,part_2_surf.surf_point,
		                 pnt1proj) == FALSE)
	      return(ASM_MABS_FAIL);
 	    get_trnsl_matrix(part_2_axis_2.axis_point,pnt1proj,trnsmat);
 	    MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmattmp,trans_mat);
	    return(ASM_SEC_ALIGN_SUCC);
	  }
	}
	
	/* 
	 * if the angle is zero the second pair is already aligned 
	 */
	
	BSmkvec(&rc,vec1,pntcent,pnt1proj);
	BSmkvec(&rc,vec2,pntcent,pnt2proj);
	MATH_ang_of_lines(vec1,vec2,&alpha, part_2_axis_1.axis_direction);
	if(fabs(alpha) > dist_tol)
	{
          MAgrotmx(&rc,part_2_axis_1.axis_direction, part_2_axis_1.axis_point,&alpha,rotmatx);
	  if(rc != MSSUCC)
	    return(ASM_MABS_FAIL);
	  MAmulmx(&rc,&rows,&cols,&rows,rotmatx,trans_mat_tmp,trans_mat);
	  return(ASM_MATH_SUCC);	
	}
        memcpy(trans_mat,trans_mat_tmp,sizeof(IGRmatrix));
	return(ASM_MATH_SUCC);
}

/*******************************************************************************
   Description      : core routine for mate-mate-ortho without freezing other
                      degrees of freedom 
   Return Values    : ASM_MATH_SUCC  - Success
		      ASM_MABS_FAIL - Math routines Failure
 *******************************************************************************/
int mate_mate_ortho_half(part_1_surf_1,part_1_surf_2,part_2_surf_1,part_2_surf_2,fmat)
IGRmatrix	fmat;
SURF_INFO	part_1_surf_1,part_1_surf_2,part_2_surf_1,part_2_surf_2;
{

	IGRlong		rc;
	IGRmatrix	fmattmp,trmat;
	IGRpoint	pnttrans,pntproj;
	IGRshort	rows,cols;
	IGRint		num_pnts;
	IGRdouble	dist_tol;


	num_pnts =1;
	rows = cols = 4;
 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	
	/*
	 * Align the pair of normals and mate with first surface 
	 */
	flip_normal(part_1_surf_1.surf_normal);
	flip_normal(part_1_surf_2.surf_normal);
	if(ALign_vector_pair(part_2_surf_1.surf_normal, part_2_surf_1.surf_point,
	                  part_1_surf_1.surf_normal, part_1_surf_1.surf_point,
			  part_2_surf_2.surf_normal, part_2_surf_2.surf_point,
			  part_1_surf_2.surf_normal, part_1_surf_2.surf_point, fmattmp) == FALSE)
	  return(ASM_MABS_FAIL);

	/*
	 * Project the part_2_surf_2 point on to part_1_surf_2 plane 
	 */
	if(MAptsxform(&rc,&num_pnts,fmattmp,part_1_surf_2.surf_point,pnttrans) == FALSE)
	{
	  memcpy(fmat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	if(proj_pnt_to_plane(pnttrans,part_2_surf_2.surf_normal, part_2_surf_2.surf_point,
			     pntproj) == FALSE)
	{
	  memcpy(fmat,fmattmp,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	/* 
	 *  get translation matrix btwn transformed pnt & projected pnt 
	 */
	get_trnsl_matrix(pnttrans,pntproj,trmat);
        MAmulmx(&rc,&rows,&cols,&rows,trmat,fmattmp,fmat);
	return(ASM_MATH_SUCC);
}

/*******************************************************************************

   Description      :  Core routine for  mate_align_parallel without freezing 
                       other degrees of freedom
   Return Values    :  ASM_MATH_SUCC  - Success
		       ASM_MABS_FAIL - Failure

*******************************************************************************/

int mate_align_parl_half(axis_part1,surf_part1,axis_part2,surf_part2,fmat)
IGRmatrix fmat;
SURF_INFO surf_part1,surf_part2;
AXIS_INFO axis_part1,axis_part2;
{
	IGRlong		rc;
	IGRmatrix	fmattmp,trnsmat;
	IGRpoint	pnt1,pnttrans,pntproj;
	IGRshort	rows,cols;
	IGRint		num_pnts;

	rows = cols = 4;
	num_pnts = 1;

	flip_normal(surf_part1.surf_normal);
	if( MAte_transform(axis_part2.axis_direction, axis_part2.axis_point,
                           axis_part1.axis_direction,axis_part1.axis_point,
                           fmattmp) == FALSE)
          return(ASM_MABS_FAIL);
	memcpy(pnt1,surf_part1.surf_point,sizeof(IGRpoint));
	if(MAptsxform(&rc,&num_pnts,fmattmp,pnt1,pnttrans) == FALSE)
	{
	  memcpy(fmat,fmattmp,sizeof(IGRmatrix));  
	  return(ASM_MABS_FAIL);
	}
	
	/* 
	 * Project the surf2_part1 point on to surf2_part2 plane 
	 */
	if(proj_pnt_to_plane(pnttrans,surf_part2.surf_normal, surf_part2.surf_point,pntproj) == FALSE)
	{
	  memcpy(fmat,fmattmp,sizeof(IGRmatrix));  
	  return(ASM_MABS_FAIL);
	}
	
	/*
	 *  get translation matrix btwn transformed pnt & projected pnt 
	 */
	get_trnsl_matrix(pnttrans,pntproj,trnsmat);
	MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmattmp,fmat);
	return(ASM_MATH_SUCC);
}

/*******************************************************************************
   Description      : �Core routine for mate-mate-acute without freezing other 
   		       degrees of freedom
   Return Values    :  ASM_MATH_SUCC - Successful
		       ASM_MABS_FAIL - Failure
		       ASM_INVALID_INPUT - Corresponding angles on the two 
					   objects are not equal	
		       ASM_PART_SUCC - Partial solution
*******************************************************************************/

int mate_mate_acute_half(part_1_surf_1,part_1_surf_2,part_2_surf_1,
			 part_2_surf_2,fmattmp)
SURF_INFO	part_1_surf_1; /** 1st surface on part 1 info INPUT **/
SURF_INFO	part_1_surf_2; /** 2nd surface on part 1 info INPUT **/
SURF_INFO	part_2_surf_1; /** 1st surface on part 2 info INPUT **/
SURF_INFO	part_2_surf_2; /** 2nd surface on part 2 info INPUT **/
IGRmatrix	fmattmp;       /** Transformation matrix OUTPUT     **/
{
	IGRlong		rc;
	IGRmatrix	trnsmat,rmat,tmat;
	IGRpoint	pnt1trans,pnt2trans;
	IGRdouble	alpha,beta,tparm,dist_tol;
	IGRpoint	vec1pt1,vec2pt1,pnt3;
	IGRvector	intvec1,intvec2,nrm1trans,nrm2trans;
	struct IGRline	line1;
	IGRshort	rows,cols;
	IGRint		num_pnts;

	rows = cols = 4;
	num_pnts = 1;
 	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);

	if(get_angles_btwn_normals(part_1_surf_1.surf_normal,part_1_surf_2.surf_normal,
				   &alpha) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part_2_surf_1.surf_normal,part_2_surf_2.surf_normal,
				   &beta) == FALSE)
	  return(ASM_MABS_FAIL);
	if(fabs(alpha - beta) > dist_tol)
		return(ASM_INVALID_INPUT);
	flip_normal(part_2_surf_1.surf_normal);
	flip_normal(part_2_surf_2.surf_normal);

	/* 
	 * This mates the first pair of surfaces and ensures parallelity
	 * of second pair of surfaces 
	 */
	if(ALign_vector_pair(part_2_surf_1.surf_normal, part_2_surf_1.surf_point,
	                  part_1_surf_1.surf_normal, part_1_surf_1.surf_point,
			  part_2_surf_2.surf_normal, part_2_surf_2.surf_point,
			  part_1_surf_2.surf_normal, part_1_surf_2.surf_point, tmat) == FALSE)
	  return(ASM_MABS_FAIL);
	
	/*
	 *  Find line of intersection of part2 surfaces 
	 */
	if(ASxplpl(part_2_surf_1.surf_point,part_2_surf_1.surf_normal,
	        part_2_surf_2.surf_point,part_2_surf_2.surf_normal, vec1pt1,intvec1) == FALSE)
	{
	  memcpy(fmattmp,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	/*
	 * transform the part1(with tmat) to its current location 
	 */
	get_rotmat(tmat,rmat);
	if(MAptsxform(&rc,&num_pnts,tmat,part_1_surf_1.surf_point,pnt1trans) == FALSE)
	{
	  memcpy(fmattmp,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	if(MAptsxform(&rc,&num_pnts,rmat,part_1_surf_1.surf_normal,nrm1trans) == FALSE)
	{
	  memcpy(fmattmp,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	if(MAptsxform(&rc,&num_pnts,tmat,part_1_surf_2.surf_point,pnt2trans) == FALSE)
	{
	  memcpy(fmattmp,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}

	if(MAptsxform(&rc,&num_pnts,rmat,part_1_surf_2.surf_normal,nrm2trans) == FALSE)
	{
	  memcpy(fmattmp,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	/*
	 *  Find line of intersection of part1 surfaces 
	 */
	if(ASxplpl(pnt1trans,nrm1trans,pnt2trans,nrm2trans,vec2pt1,intvec2) == FALSE)
	{
	  memcpy(fmattmp,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	get_second_point(vec1pt1,intvec1,pnt3);
	line1.point1 = vec1pt1;
	line1.point2 = pnt3;
	if(MAptlnproj(&rc,vec2pt1,&line1,vec1pt1,&tparm) == FALSE)
	{
	  memcpy(fmattmp,tmat,sizeof(IGRmatrix));
	  return(ASM_MABS_FAIL);
	}
	get_trnsl_matrix(vec2pt1,vec1pt1,trnsmat);
	MAmulmx(&rc,&rows,&cols,&rows,trnsmat,tmat,fmattmp);
	return(ASM_MATH_SUCC);
}

/***************************************************************************
     Description   :  This function determines the transformation matrix to 
     		      align two normals
     Input	   :  Normal of a surface and a point on the surface
		      Normal of another surface and a point there on
     Output        :  Transformation matrix
     Return Values :  TRUE -- Success
		      FALSE -- Failure
****************************************************************************/
MAte_transform(nrmblk,pntblk,nrmwdg,pntwdg,finaltrmat)
IGRvector nrmblk,nrmwdg;
IGRpoint  pntblk,pntwdg;
IGRmatrix 	finaltrmat;
{

  IGRlong	rc,num_pnts;
  short 	rows,cols;
  IGRmatrix 	rotwdg,rotwdginv,rotblk,rotblkinv;

  rows =  cols = 4;
  num_pnts = 1;

  if(ALtransf_space_vec ( pntblk,nrmblk,rotblk,rotblkinv) == FALSE)
    return(FALSE);
  /*
   * rotwdginv is actually not required so no need of checking for return value
   */  
  ALtransf_space_vec ( pntwdg,nrmwdg,rotwdg,rotwdginv); 
  MAmulmx(&rc,&rows,&cols,&rows,rotblkinv,rotwdg,finaltrmat);
  return(TRUE);
}

/*********************************************************************************
   Description   : This function returns transformation matrix for transforming 
   	           an arbitrary axis so as to align it with the global z_axis and 
   	           the point on it with the global origin. 
   Input         : axis_vec the vector  
   	           origin_from the point on this vector
   Output        : glob_loc_mat the transformation matrix
   		   loc_glob_mat inverse of glob_loc_mat
   Return Values : TRUE  inverse is found
	           FALSE  singular matrix	             
*********************************************************************************/

int ALtransf_space_vec (origin_from, axis_vec, glob_loc_mat,loc_glob_mat)
IGRpoint  origin_from; 
IGRvector  axis_vec;
IGRmatrix  glob_loc_mat;
IGRmatrix  loc_glob_mat;
{

	IGRlong			rc;
	IGRdouble		hyp,hypsqr;
	IGRvector		unit_axis_vec,norm_unit_axis_vec;
	IGRmatrix		temp, T1, T2, T3;
	IGRshort		rows,cols;

	rows = cols = 4;

	memcpy(unit_axis_vec,axis_vec,sizeof(IGRvector));
        MAunitvc(&rc,unit_axis_vec,norm_unit_axis_vec);
	if(rc == MASDGENRAT)
	  return(FALSE);
	memcpy(norm_unit_axis_vec,unit_axis_vec,sizeof(IGRvector));
	MAidmx(&rc,T1);
	MAidmx(&rc,T2);
	MAidmx(&rc,T3);

        /* 
         * T1 is the matrix for translating 'origin_from' to global-origin 
	 */        
        T1[3] = -origin_from[0];
        T1[7] = -origin_from[1];
        T1[11]= -origin_from[2];

        hypsqr = unit_axis_vec[0]*unit_axis_vec[0] + unit_axis_vec[2]*unit_axis_vec[2];
        hyp = sqrt(hypsqr);
        
        /*
         *  T2 is the matrix for rotation about global Y-axis to bring 
	 *   the vector 'unit_axis_vec' to the YOZ plane. 
	 */
        if(hyp > 0)
        {
          T2[0] = unit_axis_vec[2]/hyp;
          T2[2] = -unit_axis_vec[0]/hyp;
          T2[8] = -T2[2];
          T2[10]= T2[0];
        }

        /*
         *  T3 is the matrix for rotation about X-axis to align the 
	 *  transformed vector 'unit_axis_vec' with  global Z-axis. 
	 */
        T3[5] = hyp;
        T3[6] = -unit_axis_vec[1];
        T3[9] = -T3[6];
        T3[10]= T3[5];

        MAmulmx(&rc,&rows,&cols,&rows,T3,T2,temp);
        MAmulmx(&rc,&rows,&cols,&rows,temp,T1,glob_loc_mat);
	if(MAinvmx(&rc,&rows,glob_loc_mat,loc_glob_mat) == FALSE)
	  return(FALSE);
	else
	  return(TRUE);
}

/***************************************************************************
	Description   : This routine aligns a pair of generic vectors, given 
		        their directions and points through which they pass.
        Return Values : TRUE -  Success 
        		FALSE - Failure due to various reasons
*****************************************************************************/

ALign_vector_pair( blknrm1, blkpnt1, wdgnrm1,wdgpnt1, blknrm2, blkpnt2,
		   wdgnrm2, wdgpnt2, finaltrmat)
IGRvector	blknrm1,blknrm2,wdgnrm1,wdgnrm2;
IGRpoint	blkpnt1,blkpnt2,wdgpnt1,wdgpnt2;
IGRmatrix 	finaltrmat;
{
	struct  IGRplane	plane1;
	IGRmatrix	trmat,rotmatx,rmat;
	IGRlong		rc;
	IGRshort	rows,cols;
	IGRint		num_pnts,ii;
	IGRpoint	wdgpnt2new;
	IGRvector	wdgnrm2new;
	IGRvector	vec1,vec2;
	IGRpoint	pnt1,pnt2,proj_pnt1,proj_pnt2,proj_pnt3,proj_pnt4;
	IGRdouble	alpha;
	IGRdouble	dot_tol,dotval;
	IGRvector	cv_normal;
	IGRpoint	cv_point;

	num_pnts = 1;
	rows = cols = 4;

	plane1.normal = cv_normal;
	plane1.point = cv_point;

  	BSEXTRACTPAR(&rc, BSTOLORTHOVEC, dot_tol);
        
        for(ii=0;ii<3;ii++)
        {
          plane1.point[ii] = blkpnt1[ii];
          plane1.normal[ii] = blknrm1[ii];
        }
	
	/*
	 * This aligns the first pair of normals btwn given surfaces 
	 */
	if(MAte_transform(blknrm1,blkpnt1,wdgnrm1,wdgpnt1,trmat) == FALSE)
	  return(FALSE);
	get_rotmat(trmat,rmat);
	/*
	 * Transform the point and normal of second pair with above transformation 
	 */
	if(MAptsxform(&rc,&num_pnts,trmat,wdgpnt2,wdgpnt2new) == FALSE)
	  return(FALSE);
	if(MAptsxform(&rc,&num_pnts,rmat,wdgnrm2,wdgnrm2new) == FALSE)
	  return(FALSE);
        
	/*
         * Check if already the other set of normals are aligned 
         */
	MAdotvc(&rc,wdgnrm2new,blknrm2,&dotval);
	dotval = fabs(1.0 - dotval);
	if(dotval < dot_tol)
	{
	  memcpy(finaltrmat,trmat,sizeof(IGRmatrix));
          return(TRUE);
	}
	
	/*
	 * Get the points on the second normal for projecting 
	 */
	memcpy(pnt1,wdgpnt2new,sizeof(IGRpoint));
	for(ii=0;ii<3;ii++)
	  pnt2[ii] = pnt1[ii] + wdgnrm2new[ii];

	/*
	 * project the points on the second normal failure may be due to invalid normal 
	 */
	if(MAptplproj(&rc,pnt1,&plane1,proj_pnt1) == FALSE)
	  return(FALSE);
	
	if(MAptplproj(&rc,pnt2,&plane1,proj_pnt2) == FALSE)
          return(FALSE);
	
	/*
	 * Get the points on the block normal2 for projecting 
	 */
	memcpy(pnt1,blkpnt2,sizeof(IGRpoint));
	for(ii=0;ii<3;ii++)
	  pnt2[ii] = pnt1[ii] + blknrm2[ii];

	/*
	 * project the points on the normal to the plane about which alignment
	 * has already been done 
	 */
	if(MAptplproj(&rc,pnt1,&plane1,proj_pnt3) == FALSE)
	  return(FALSE);
	if(MAptplproj(&rc,pnt2,&plane1,proj_pnt4) == FALSE)
	  return(FALSE);
	BSmkvec(&rc,vec1,proj_pnt1,proj_pnt2);
	BSmkvec(&rc,vec2,proj_pnt3,proj_pnt4);
	MATH_ang_of_lines(vec1,vec2,&alpha,blknrm1);

	/*
	 * compute the rotation matrix to align the two vectors 
	 */
	MAgrotmx(&rc,blknrm1,blkpnt1,&alpha,rotmatx);

	MAmulmx(&rc,&rows,&cols,&rows,rotmatx,trmat,finaltrmat);
	return(TRUE);
}


/********************************************************************************
   
   Description   :  This routine orients and then aligns the given vector
   Return Values :  ASM_MATH_SUCC - When complete solution is available
                    ASM_ALIGN_PART_SUCC - When align is partly successful
		    ASM_MABS_FAIL - MA/BS routine Failure 
*******************************************************************************/
orient_align_vector(part2_axis_dir,part2_axis_pnt,
		    part1_axis_pnt,fmat,crsvec,trans_mat)
IGRmatrix	fmat,trans_mat;
IGRvector	crsvec;
IGRvector	part2_axis_dir;
IGRpoint	part1_axis_pnt,part2_axis_pnt;
{

	IGRlong	rc;
	struct	IGRline	line1;
	IGRmatrix	trnsmat;
	IGRpoint	pnt1,pnttrans,pnt1proj,pnt2,pnt2proj;
	IGRdouble	dist,tparm,dist_tol;
	IGRint		num_pnts;
	IGRshort	rows,cols;

        num_pnts = 1;
	rows = cols = 4;

	/* 
	 *  project transformed point of axis_part1 on to surfce of axis_part2 
	 */
	
	if(MAptsxform(&rc,&num_pnts,fmat,part1_axis_pnt,pnttrans) == FALSE)
	  return(ASM_MABS_FAIL);
	if(proj_pnt_to_plane(pnttrans, part2_axis_dir, part2_axis_pnt,pnt1proj) == FALSE)
	  return(ASM_MABS_FAIL);
	get_second_point(pnttrans,crsvec,pnt1);
	BSdistptli(&rc,pnt1proj,pnttrans,pnt1,&dist);
	BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
	
	if(dist < dist_tol)
	{
	  /*
	   *  This is a complete solution
	   */
	  get_trnsl_matrix(pnttrans,pnt1proj,trnsmat);
	  MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmat,trans_mat);
	  return(ASM_MATH_SUCC);
	}
	
	else 
	{
	 /*
	  *  This is a partial solution
	  */
          line1.point1 = (double *)malloc(sizeof(IGRpoint));
          line1.point2 = (double *)malloc(sizeof(IGRpoint));
          get_second_point(pnt1proj,crsvec,pnt2);
          line1.point1 = &pnt1proj[0];
          line1.point2 = &pnt2[0];
          if(MAptlnproj(&rc,part2_axis_pnt,&line1,pnt2proj,&tparm) == FALSE)
	  {
	     memcpy(trans_mat,fmat,sizeof(IGRmatrix));
	     return(ASM_MABS_FAIL);
	  }
          get_trnsl_matrix(pnt2proj,pnt1proj,trnsmat);
          MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmat,trans_mat);
	  return(ASM_ALIGN_PART_SUCC);
	}
}

/*******************************************************************************
    Description   :	
    Return Values : ASM_MATH_SUCC - Success
		    ASM_MABS_FAIL - Failure
 *******************************************************************************/

int orient_mate_vec_ortho(part1_surf_pnt,part1_surf_norm,
			  part2_surf_norm,part2_axis_dir,part2_axis_pnt,
			  fmatmp,trans_mat)
IGRpoint	part1_surf_pnt,part2_axis_pnt;
IGRvector	part1_surf_norm,part2_surf_norm,part2_axis_dir;
IGRmatrix	fmatmp,trans_mat;
{
	IGRint		num_pnts;
	IGRshort	rows,cols;
	IGRlong 	rc;
	IGRpoint	pnttrans;
	IGRmatrix	rmat;
	IGRvector	nrmtrans;
	IGRdouble	alpha;

	num_pnts = 1;
	rows = cols = 4;

	/*
	 * The following ensures the mating of normals but does not ensure the 
	 * coincidence of the points on these normals.
	 */
	if(MAptsxform(&rc,&num_pnts,fmatmp,part1_surf_pnt,pnttrans) == FALSE)
	  return(ASM_MABS_FAIL);
	get_rotmat(fmatmp,rmat);
	if(MAptsxform(&rc,&num_pnts,rmat,part1_surf_norm,nrmtrans) == FALSE)
	  return(ASM_MABS_FAIL);
	if(get_angles_btwn_normals(part2_surf_norm,nrmtrans,&alpha) == FALSE)
	  return(ASM_MABS_FAIL);
	MAgrotmx(&rc,part2_axis_dir,part2_axis_pnt,&alpha,rmat);
	if(rc != MSSUCC)
	  return(ASM_MABS_FAIL);
        MAmulmx(&rc,&rows,&cols,&rows,rmat,fmatmp,trans_mat);
	return(ASM_MATH_SUCC);
}

/****************************************************************************
    Return Values : ASM_MATH_SUCC -- Success
		    ASM_MABS_FAIL -- Failure
 ****************************************************************************/
int orient_mate_vec_parl(part1_surf_point,part2_surf_point,
			 part2_surf_norm,fmatmp,trans_mat)
IGRpoint	part1_surf_point,part2_surf_point;
IGRvector	part2_surf_norm;
IGRmatrix	fmatmp,trans_mat;
{
	IGRpoint	pnttrans,pntproj;
	IGRint		num_pnts;
	IGRshort	rows,cols;
	IGRlong		rc;
	IGRmatrix       rmat,trnsmat;
	
	num_pnts = 1;
	rows = cols = 4;

        if(MAptsxform(&rc,&num_pnts,fmatmp,part1_surf_point,pnttrans) == FALSE)
	  return(ASM_MABS_FAIL);
        get_rotmat(fmatmp,rmat);
        if(proj_pnt_to_plane(pnttrans,part2_surf_norm,part2_surf_point,pntproj) == FALSE)
	  return(ASM_MABS_FAIL);
	get_trnsl_matrix(pnttrans,pntproj,trnsmat);
        MAmulmx(&rc,&rows,&cols,&rows,trnsmat,fmatmp,trans_mat);
	return(ASM_MATH_SUCC);
}

/*********************************************************************************
	Description     :  computes angles between two normals 
	Return Values   :  TRUE -- Success
			   FALSE -- Failure
 ********************************************************************************/
get_angles_btwn_normals(nrm1,nrm2,alpha)
IGRvector	nrm1,nrm2;
IGRdouble 	*alpha;
{
	IGRvector	crosspd;
	IGRlong		rc;

	if(MAcrossvc(&rc,nrm1,nrm2,crosspd) == FALSE)
	  return(FALSE);
	MATH_ang_of_lines(nrm1,nrm2,alpha,crosspd);
	return(TRUE);
}

/*******************************************************************************
   Description      :  Projects a point on to plane and returns projected point.
   Return Values    :  TRUE -- Success.
		       FALSE -- Failure
*******************************************************************************/

proj_pnt_to_plane(pnt1,nrm,pnt,projpnt)
IGRvector	nrm;
IGRpoint	pnt1,projpnt,pnt;
{

	struct IGRplane	plane1;
	IGRlong		rc;
	
	plane1.normal = nrm;
	plane1.point =  pnt;
	if(MAptplproj(&rc,pnt1,&plane1,projpnt) == FALSE)
	  return(FALSE);
	else
	  return(TRUE);
}

/*******************************************************************************
   Description      :  Given two points, computes the translation matrix between
                       the two points. Translation is from pnt1 to pnt2.
   Return Values    :  Always returns Success
*******************************************************************************/

get_trnsl_matrix(pnt1,pnt2,trnsmat)
IGRpoint	pnt1,pnt2;
IGRmatrix	trnsmat;
{
	IGRvector	trans_vec;
	IGRlong		rc;

        trans_vec[0] = pnt2[0] - pnt1[0];	
        trans_vec[1] = pnt2[1] - pnt1[1];	
        trans_vec[2] = pnt2[2] - pnt1[2];	
        MAtrlmx(&rc,trans_vec,trnsmat);
        return(TRUE);
}

/*******************************************************************************
   Description      : Given a vector a point on it, this determines another 
                      point on the given vector  
   Return Values    : Always returns Success
*******************************************************************************/

get_second_point(pnt1,normal1,pnt2)
IGRpoint	pnt1,pnt2;
IGRvector	normal1;
{
	pnt2[0] = pnt1[0] + normal1[0];
	pnt2[1] = pnt1[1] + normal1[1];
	pnt2[2] = pnt1[2] + normal1[2];
	return(TRUE);
}

/*******************************************************************************
   Description      : This flips the direction of the given vector 
   Return Values    : It always returns success
*******************************************************************************/

flip_normal(nrm1)
IGRvector nrm1;
{
	nrm1[0] = -nrm1[0];
	nrm1[1] = -nrm1[1];
	nrm1[2] = -nrm1[2];
	return(TRUE);
}

/*************************************************************************
	Description   :   This function computes the angle between two 
			  space vectors. 
	Return Values :   It always returns success
**************************************************************************/

IGRint MATH_ang_of_lines (vec1, vec2, angle, norm)
IGRdouble *vec1,*vec2,*norm;
IGRdouble *angle;
{
        int rc;
        double cost,sint, dotp;
        double perp_vec[3];

        BScrossp(&rc,vec1,vec2,perp_vec);

        sint = BSlenvec(&rc,perp_vec);
        cost = BSdotp(&rc,vec1,vec2);
        *angle = atan2(sint,cost);

        dotp = BSdotp(&rc,norm,perp_vec);
        if( dotp < 0)
        {
                if( *angle < 0) *angle = - *angle;
                else  *angle = 2* PI - *angle;
        }
        else if( *angle < 0 )  *angle = 2 * PI + *angle;

        return(TRUE);
}

/*****************************************************************************
	Description   : This routine finds the line of intersection (if any) 
			 between two infinite planes defined by a point and a 
			 normal(p1, N1).It returns the line of intersection 
			 specified by a point and a vector. 
	Return Value  :  TRUE - If a intersection could be determined
			 FALSE - If the planes are parallel or vectors are zero 
*****************************************************************************/

IGRboolean ASxplpl ( IGRpoint  p1, IGRvector  N1, IGRpoint  p2, IGRvector  N2,
	 		IGRpoint  point, IGRvector  vector)
{
IGRlong    rc;
IGRboolean stat_func;
IGRshort   k;	
IGRvector  lin_dir,lin_dirtmp,N1tmp,N2tmp,vectortmp;
IGRdouble  d,d1;
IGRdouble dot_tol, basis_tol;

   memcpy(N1tmp,N1,sizeof(IGRvector));
   memcpy(N2tmp,N2,sizeof(IGRvector));
   MAunitvc(&rc,N1tmp,N1);
   MAunitvc(&rc,N2tmp,N2);
  
  BSEXTRACTPAR(&rc, BSTOLBASIS, basis_tol);

  BSEXTRACTPAR(&rc, BSTOLBASIS, dot_tol);

   if(fabs(BSdotp(&rc, N1, N2))> (1.0 - dot_tol ))
      return(FALSE);

   d  = -1.0*BSdotp(&rc,N1,p1);
   d1 = -1.0*BSdotp(&rc,N2,p2);

   stat_func = BScrossp(&rc,N1,N2,lin_dir);
   memcpy(lin_dirtmp,lin_dir,sizeof(IGRvector));
   MAunitvc(&rc,lin_dirtmp,lin_dir);
  
   if(fabs(lin_dir[0]) > basis_tol)
   {
      point[0] = 0.0;
      point[1] = (N1[2]*d1-N2[2]*d)/(N2[2]*N1[1]-N1[2]*N2[1]);
      point[2] = (N1[1]*d1-d*N2[1])/(N2[1]*N1[2]-N1[1]*N2[2]);
   }
   else if(fabs(lin_dir[1]) > basis_tol)
   {
      point[0] = (N1[2]*d1-N2[2]*d)/(N1[0]*N2[2]-N2[0]*N1[2]);
      point[1] = 0.0;
      point[2] = (N1[0]*d1-N2[0]*d)/(N2[0]*N1[2]-N1[0]*N2[2]);
   }

   else if(fabs(lin_dir[2]) > basis_tol)
   {	
      point[0] = (N1[1]*d1-N2[1]*d)/(N1[0]*N2[1]-N2[0]*N1[1]);
      point[1] = (N2[0]*d-N1[0]*d1)/(N1[0]*N2[1]-N2[0]*N1[1]);
      point[2] = 0.0;
   }

  for(k=0;k<3;k++)
      vector[k] = lin_dir[k];

   memcpy(vectortmp,vector,sizeof(IGRvector));
   MAunitvc(&rc,vectortmp,vector); 

   return(TRUE);
}   

/***************************************************************************
	Description   : Aligns two vectors rotating them within the plane	
        Input         : Two vectors to be aligned 
        	        Plane in which the vectors lie
        Output        : Rotation matrix
        Return Values : TRUE -- Rotation matrix determined
			FALSE -- Failure
***************************************************************************/
		

FIx_rotation(vec1,vec2,blknrm1,blkpnt1,rotmatx)
IGRvector	vec1,vec2,blknrm1;
IGRpoint	blkpnt1;
IGRmatrix	rotmatx;
{
	IGRdouble	alpha;
	IGRlong		rc;
	IGRvector	unit_vec1,unit_vec2;

	
        MAunitvc(&rc,vec1,unit_vec1);
        MAunitvc(&rc,vec2,unit_vec2);
    
	/*
	 * compute the angle between the two vectors 
	 */
	MATH_ang_of_lines(unit_vec2,unit_vec1,&alpha,blknrm1);

	/*
	 * compute the rotation matrix to align the two vectors 
	 */
	MAgrotmx(&rc,blknrm1,blkpnt1,&alpha,rotmatx);

  	return(TRUE);
}

/*****************************************************************************
	Description   : Computes pure rotation matrix from a matrix which has 
		        both rotation and translation components
	Return Values : It always returns Success
*****************************************************************************/

get_rotmat(inpmat,rotmat)
IGRmatrix	inpmat;
IGRmatrix	rotmat;
{
	memcpy(rotmat,inpmat,sizeof(IGRmatrix));
	rotmat[3] = 0.0;
        rotmat[7] = 0.0;
        rotmat[11] = 0.0;
	return(TRUE);
}
