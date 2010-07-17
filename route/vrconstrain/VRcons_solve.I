/* $Id: VRcons_solve.I,v 1.3 2001/02/20 01:13:04 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconstrain / VRcons_solve.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcons_solve.I,v $
 *	Revision 1.3  2001/02/20 01:13:04  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:03:04  anand
 *	SP merge
 *	
# Revision 1.2  2000/07/10  19:38:00  pinnacle
# Replaced: route/vrconstrain/VRcons_solve.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/07/10  19:34:20  pinnacle
# Created: route/vrconstrain/VRcons_solve.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  22:12:24  pinnacle
# Replaced: vrconstrain/VRcons_solve.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add prototypes
 *	07/10/00	Alwin	Check the return status of VRsimplex and throw
 *				appropriate message to UNIX window.
 *
 *************************************************************************/
class implementation VRcons;

#include <math.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"

#include "vrconstr_pto.h"
#include "bserr.h"
#include "vrdbgmacros.h"

#define AS_DEBUG

from VRplane import VRpostabsg,VRget_plane_state;

#define EPS 1.E-6

ASplane_set_equation(coef,plane,md_env)
double *coef;
struct GRid *plane;
struct GRmd_env *md_env;
/*.ASplane_set_equation*/
{
 long status,msg;
 struct ret_struct rst;
 double fabs();

/* normal vector */

 rst.var.ref_st.t[2]  = coef[0];
 rst.var.ref_st.t[6]  = coef[1];
 rst.var.ref_st.t[10] = coef[2];


/* Point of the plane */

/*^printf("move %d %d\n",plane->objid,plane->osnum);
   printf("equation %f %lf %lf %lf\n",coef[0],coef[1],coef[2],coef[3]);
*/

 rst.var.ref_st.t[3] = rst.var.ref_st.t[7] = rst.var.ref_st.t[11] = 0;
 if     (fabs(coef[0]) > 0.1) rst.var.ref_st.t[3] = -coef[3]/coef[0];
 else if(fabs(coef[1]) > 0.1) rst.var.ref_st.t[7] = -coef[3]/coef[1];
 else                         rst.var.ref_st.t[11]= -coef[3]/coef[2];

 status = om$send(msg = message VRplane.VRpostabsg(&msg,md_env,&rst),
		  senderid = NULL_OBJID,
		  targetid = plane->objid,
		  targetos = plane->osnum);
 as$status();
 return OM_S_SUCCESS;
}

ASplane_get_equation(coef,plane,md_env)
double *coef;
struct GRid *plane;
struct GRmd_env *md_env;
/*.ASplane_get_equation*/
{
 IGRlong status,msg;
 struct ret_struct rst;

 status = om$send(msg = message  NDnode.NDgive_structure(&msg,&rst,md_env),
		  senderid = NULL_OBJID,
		  targetid = plane->objid,
		  targetos = plane->osnum);
 as$status(action = RET_STATUS);

 coef[0] =  rst.var.ref_st.t[3];
 coef[1] =  rst.var.ref_st.t[4];
 coef[2] =  rst.var.ref_st.t[5];

 coef[3] = -coef[0] * rst.var.ref_st.t[0] - coef[1] * rst.var.ref_st.t[1]
           -coef[2] * rst.var.ref_st.t[2];

 return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									     */
/* Check if a constrain is verified or not				     */
/* vectorial compatibilities is assumed to be already verified               */
/* Build sytem of equation or inequalities to be solved 		     */
/*									     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRverify_af_constrain(int cons_type;
			     double *cons_value; int nb_value;
			     int *obj_index;int nb_obj;
			     int *verify;
			     struct GRmd_env *md_env)
{
 
 double d0,d1,*coef,smem,plane_coef[4];
 int i,j;
 int status;
 double sign_dep,sign_cons;
 int unk;
 double *weight;

 /*"verify constrain for plane %d and %d\n",me->plane[obj_index[0]].objid,me->plane[obj_index[1]].objid */

/* Check if the constraint is verify and get coef for the constraint matrix */

cons_type = cons_type&VR_CNS_AFF;

sign_dep = -1;
switch(cons_type)
  {
   case VR_CNS_MIN :
   case VR_CNS_MAX :
   case VR_CNS_VAL :
	/* Increase if necessary size of VLAS used to store matrix and unknown*/

	status = om$send(msg = message VRcons.VRexpand_matrix
				      (me->nb_unknown,me->nb_equation+1),
			 targetid = my_id);
        as$status(action = RET_STATUS);

	/* Get type of equation and second member value used by simplex */

             if(cons_type == VR_CNS_MIN) sign_cons = 1;
	else if(cons_type == VR_CNS_VAL) sign_cons = 0;
	else if(cons_type == VR_CNS_MAX) sign_cons = -1;


        d0 = me->plane_eq[4*obj_index[0]+3];
        d1 = me->plane_eq[4*obj_index[1]+3];
        if(   (me->plane_state[obj_index[0]] & VR_REVERSE)
           != (me->plane_state[obj_index[1]] & VR_REVERSE)) d1 = -d1;

        smem = *cons_value + d1 -d0;

	/*"cons_type %x sign_cons %lf d0 %lf d1 %lf cons_value %lf smem %lf\n",cons_type,sign_cons,d0,d1,*cons_value,smem */
	break;
    

   case VR_CNS_PT :  /*| all the plane have a common point */
	/* This constrain adds 3 unknows that are the coordinate of the */
        /* common point */
	status = om$send(msg = message VRcons.VRexpand_matrix
				      (me->nb_unknown+6,me->nb_equation+nb_obj),
			 targetid = my_id);
        as$status(action = RET_STATUS);
        break;

   case VR_CNS_FIX_PT : /*| fix plane, change its weight for the solver */
	 me->plane_state[obj_index[0]] |= VR_CONS_FIXED;
	 weight = me->matrix+me->max_unknown*me->max_equation +
		  me->unknown_index[obj_index[0]];
	 *weight = 10000;
	 *(weight+1) = 10000;
        break;
  }

/*
   Add line to the constraint matrix
*/

   switch(cons_type&VR_CNS_AFF)
   {
    case VR_CNS_MIN :
    case VR_CNS_MAX :
    case VR_CNS_VAL :

        /*| Add corresponding line to the constraint matrix */

          me->smem[me->nb_equation] = smem;
	  me->smem[me->nb_equation + me->max_equation] = sign_cons;

          coef = me->matrix+me->max_unknown*me->nb_equation;
          for(i=0;i<me->max_unknown;i++) coef[i] = 0;
	  unk = me->unknown_index[obj_index[0]];
	  sign_dep = -1;
          coef[unk]   =  sign_dep;
          coef[unk+1] = -sign_dep;
	  /*"plane %d coef[%d] %lf\n",obj_index[0],unk,coef[unk]*/

          if(   (me->plane_state[obj_index[0]] & VR_REVERSE)
             != (me->plane_state[obj_index[1]] & VR_REVERSE)) sign_dep = 1;

	  unk = me->unknown_index[obj_index[1]];
          coef[unk]   =  -sign_dep;
          coef[unk+1] =   sign_dep;
	  /*"plane %d coef[%d] %lf\n",obj_index[1],unk,coef[unk]*/

          /*"smem[%d] %lf\n",me->nb_equation,me->smem[me->nb_equation]*/

          me->nb_equation++;
	break;

    case VR_CNS_PT :

	/* Add the weight coef of the 3 unknown */

	coef = me->matrix + me->max_unknown*me->max_equation + me->nb_unknown;
	for(i=0;i<6;i++,coef++) *coef = 0;

	/* Add the lines in the matrix corresponding to each unknown +
           the value 
        */
	for(i=0;i<nb_obj;i++,me->nb_equation++)
	 {
	  status = ASplane_get_equation
				     (plane_coef,me->plane+obj_index[i],md_env);
	  as$status(action = RET_STATUS);
	  coef = me->matrix + me->nb_equation*me->max_unknown;
          for (j=0;j<me->max_unknown;j++,coef++) *coef =  0;
	  coef = me->matrix + me->nb_equation*me->max_unknown + me->nb_unknown;
          for (j=0;j<3;j++)
            { *coef =  plane_coef[j];coef++;
	      *coef = -plane_coef[j];coef++; }
	  coef = me->matrix + me->nb_equation*me->max_unknown+
		 me->unknown_index[obj_index[i]];
	  *coef =  sign_dep; coef++;
	  *coef = -sign_dep;
	  
	  

	  me->smem[me->nb_equation] = -plane_coef[3];
	  me->smem[me->nb_equation + me->max_equation] = 0; 
         }

	me->nb_unknown += 6;
	break;
   }

 /* old stuff */

 *verify = FALSE;

 return OM_S_SUCCESS;
}

method VRsolve_af_constrain(int *all_is_ok)
{
int status;
int ip;
double fabs();

SetProc( Md VRsolve_af_constrain ); Begin 

if(me->nb_unknown ==0)
 {/*| Nothing to solve !!! */ 
  *all_is_ok = FALSE; 

  __DBGpr_com( " Nothing to solve !!! " );
  End
  return OM_S_SUCCESS;
 }

 __DBGpr_com( " Calling VRcompress_matrix " );
 status = om$send(msg = message VRcons.VRcompress_matrix(),
		  targetid = my_id);

/*^{int ijl,jjl,jjll;
    double *x;
    printf("solve system of inequalities %d unknow %d equation\n",
	   me->nb_unknown,me->nb_equation);
      { 
	printf(" matrix svect and equation type\n");
	for(ijl=0;ijl<me->nb_equation;ijl++)
        {
	 x = me->matrix + me->nb_unknown*ijl;
	 for(jjl = 0;jjl<me->nb_unknown;jjl++,x++) printf(" %5.1lf",*x);
         printf(" %5.1lf %5.1lf\n",me->smem[ijl],me->smem[ijl+me->nb_equation]);
	}
	printf("weight coef\n");
	 x = me->matrix + me->nb_unknown*me->nb_equation;
	 for(jjl = 0;jjl<me->nb_unknown;jjl++,x++) printf(" %5.1lf",*x);
	printf("\n");
      }
    }
  fflush(stdout);
*/
/*^
{ int file_num,ifile;
  char file_name[80];
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
  struct stat buf;

 strcpy(file_name,"/usr/tmp/domi_debug");
   sprintf(file_name+19,"_%02d",me->iteration_number);
   file_num = open(file_name,O_RDWR|O_CREAT,~0);
   if(file_num >0)
    {
     printf("matrix written in %s\n",file_name);
     write (file_num,&me->nb_unknown,sizeof(int)) ;
     write (file_num,&me->nb_equation,sizeof(int)) ;
     write(file_num,me->matrix,
	   (1+me->nb_equation)*me->nb_unknown*sizeof(double)) ;
     write (file_num,me->smem,me->nb_equation*2*sizeof(double)) ;
     close(file_num);
    }
}
*/

 /* momo modif 10-06-92 : we call the new method if no solutions we call the
 /* old one
 /**/ 

 __DBGpr_int( " Nb. of Unknowns ", me->nb_unknown );
 __DBGpr_int( " Nb. of equation ", me->nb_equation );
 __DBGpr_mat( "  Matrix ", me->matrix );

 status = VRsimplex(me->nb_unknown, me->nb_equation, me->matrix, me->smem);

 if( status == OM_E_INVARG )
 {
    __DBGpr_me();
    printf("\n Failed to resolve - Check/Resketch the Network \n" );
    End
    return status;
 }

 /*^{ int ijla;
     printf("status %d solution with the new method\n",status);
     for(ijla = 0 ; ijla < me->nb_unknown ; ijla++)
	{ printf(" %5.1lf",me->matrix[ijla]); }
     printf("\n");
   }*/
  fflush(stdout);

 if(!(status&1))
  {
	__DBGpr_com( " No Solution with New method " );
	/*| the new simplex failed ==> call the old one */
 	status = VRsimplex_old(me->nb_unknown, me->nb_equation, me->matrix, me->smem);

 	/*^{ int ijla;
     		printf("status %d solution with the old method\n",status);
     		for(ijla = 0 ; ijla < me->nb_unknown ; ijla++)
		{ printf(" %5.1lf",me->matrix[ijla]); }
     		printf("\n");
   	}*/
  	fflush(stdout);

	 if(!(status&1))
	 { 
	    *all_is_ok = VR_SIMPLEX_ERROR; 
	     __DBGpr_com( " Simplex Error " );
	     End
	     return OM_S_SUCCESS;
	 }
  }

 *all_is_ok = 0;
 for(ip = 0; ip < me->nb_plane ; ip ++)
  {
   if(  me->matrix[me->unknown_index[ip]] > EPS
      ||me->matrix[me->unknown_index[ip]+1] > EPS)
      {
        me->plane_state[ip] |= VR_CONS_ERROR;
        if(me->plane_state[ip] & VR_CONS_FREE)  *all_is_ok |= VR_MOVE_FREED;
        if(me->plane_state[ip] & VR_CONS_EXT)   *all_is_ok |= VR_MOVE_EXTERN; 
        if(me->plane_state[ip] & VR_CONS_INIT)  *all_is_ok |= VR_MOVE_INITIAL; 
        if(me->plane_state[ip] & VR_CONS_FIXED) *all_is_ok |= VR_MOVE_FIXED; 
	/*" external plane %d is freeed\n",me->plane[ip].objid */
       }
   }
 if(!*all_is_ok) *all_is_ok = VR_ALL_OK;

 End
 return OM_S_SUCCESS;
}

method VRstore_plane(struct GRid *obj; int *index; int obj_state;
		     struct GRmd_env *md_env)
{
 int status;
 int ipp,iv,i,iz;
 double *coef,*coef_p;
 double fabs(),pow();
 double orient;
 double *weight;
 double ratio;
 int fixed_plane;
#define VR_FIXED_PLANE 1

#define EPS 1.E-8

/* If this plane is not already stored, store it */

 for(ipp = 0; ipp< me->nb_plane ; ipp++)
   {
    if(  (obj->objid == me->plane[ipp].objid)
       &&(obj->osnum == me->plane[ipp].osnum)) break;
   }

  if(ipp >= me->nb_plane)
  {
   status = om$send(msg = message VRcons.VRalloc_plane(me->nb_plane+1),
 	            targetid = my_id);
   as$status(action = RET_STATUS);

   /* Verify if the plane is not READ_ONLY */

   status = om$send(msg = message VRplane.VRget_plane_state(&fixed_plane),
	            targetid = obj->objid,
	            targetos = obj->osnum);

   if(fixed_plane & VR_FIXED_PLANE) obj_state |= VR_CONS_FIXED;



    ipp = me->nb_plane++;
    me->plane[ipp] = *obj;
    me->plane_state[ipp] = obj_state;
    me->iteration[ipp] = me->iteration_number;
   }

/*"Store equation of %d and define weight for simplex\n",me->plane[ipp].objid */


/* weight for  fixed plane        : 10000.     */
/* weight for  plane move by user :  1000.     */
/* weight range for free plane    : 0.1 -- 0.5 */
/* weight range for extern plane  : 10  -- 50  */

 if(me->iteration_number > 0) ratio = pow(5.,1./me->iteration_number);
 else ratio = 5;
 /*"ratio %lf\n",ratio */

 if(!(me->plane_state[ipp]&VR_HAVE_EQ))
  {
    status = om$send(msg = message VRcons.VRexpand_matrix
				(me->nb_unknown+2,me->nb_equation),
		     targetid = my_id);
    as$status(action = RET_STATUS);
	
    weight = me->matrix+me->max_unknown*me->max_equation + me->nb_unknown;
    if     (me->plane_state[ipp]&VR_CONS_FIXED)
			{ *weight = -10000;*(weight+1) = -10000;}
    else if(me->plane_state[ipp]&VR_CONS_INIT)
			{ *weight = -1000;*(weight+1) = -1000;}
    else if(me->plane_state[ipp]&VR_CONS_EXT)
			{ *weight = -10*pow(ratio,(double) me->iteration[ipp]);
			  *(weight+1) = *weight;}
    else 	        {
			   *weight = -0.1*pow(ratio,(double)me->iteration[ipp]);
			   *(weight+1) = *weight; }

    me->unknown_index[ipp] = me->nb_unknown;
    me->nb_unknown += 2;

    coef_p = me->plane_eq + 4*ipp;
    status =  ASplane_get_equation (coef_p, me->plane+ipp,md_env);

    /*| Find corresponding vectorial plane and if the planes have same or
        reverse normal */

    coef = me->plane_eq;
    if(fabs(*coef_p) > 0.2)          iz = 0;
    else if(fabs(*(coef_p+1)) > 0.2) iz = 1;
    else if(fabs(*(coef_p+2)) > 0.2) iz = 2;
    else return (OM_W_ABORT);

    for(iv=0,i=0; iv<=ipp; iv++,coef+=4)
    {
     orient = coef[iz]/coef_p[iz];
     if((fabs(fabs(orient)-1)) > EPS) continue;

     for(i=0 ; i<3 ; i++)
      {
       if(coef_p[i]*orient - coef[i] > EPS) break; 
      }
     if(i>=3) break;
    }

    if(iv>=ipp)
     { iv = ipp;
       orient = 1;
       me->plane_state[iv] |= VR_VECTORIEL;
     }
    me->plane_vectoriel[ipp] = iv;
    me->plane_state[ipp] |= VR_HAVE_EQ;

    if(orient<0) me->plane_state[ipp] |= VR_REVERSE;
  }

 *index = ipp;
 return OM_S_SUCCESS;
}

/* Expand the area used to stored matrix and unknow */

method VRexpand_matrix(int new_unknown,new_equation)
{
int status;
int w_unknown,w_equation;
int old_size,size,line,col,line_size;
double *old,*new;

/* The allocated space were */

   me->max_equation =  om$dimension_of(varray = me->smem) / 2;
   if(me->max_equation <= 0) me->max_unknown = 0;
   else me->max_unknown = om$dimension_of(varray = me->matrix)
				 / (me->max_equation+1) ;

   
/* The new required size for matrix are */

   w_unknown =me->max_unknown  > new_unknown  ? me->max_unknown  : new_unknown;
   w_equation=me->max_equation > new_equation ? me->max_equation : new_equation;

/* Get the necessary size (+1 line for the coef in the cost function)
   and Realloc first the matrix array */

/*"old size %d %d new size %d %d\n",me->max_unknown,me->max_equation,w_unknown,w_equation*/

   size = w_unknown*(w_equation+1);

   old_size = om$dimension_of(varray = me->matrix);
   if(old_size < size) 
     {
      status = om$vla_set_dimension(varray = me->matrix,
				    size   = size);
      as$status(action = RET_STATUS);
     }

/* move the last line of the initial matrix to the last line of the new
   matrix (This line contains cost coefficient */
 line_size = me->nb_unknown*sizeof(double);
 if(size > old_size)
  {
   old = me->matrix + me->max_equation*me->max_unknown;
   new = me->matrix + w_equation      *      w_unknown;
   OM_BLOCK_MOVE(old,new,line_size);
  }

/* Translate now existing line of the matrix and insert 0 
   where necessary */

 if(w_unknown > me->max_unknown)
  {
   for(line=me->max_equation-1 ; line>=0 ; line--)
    {
     old = me->matrix + line*me->max_unknown;
     new = me->matrix + line*w_unknown;
     OM_BLOCK_MOVE(old,new,line_size);

     new = new + me->max_unknown;
     for(col=me->max_unknown ; col<w_unknown ; col++,new++) *new = 0;
    } 
  }

/* 
   Get new new required size for  second member and equation type 
   Expand now the unknown array and
   Move the flags that described the type of the equations 
*/


   old_size = om$dimension_of(varray = me->smem);
   size = 2*w_equation;

  if(size > old_size)
    {status = om$vla_set_dimension(varray = me->smem,
				   size   = size);
     as$status(action = RET_STATUS);
    }
 
  if(w_equation > me->max_equation)
    {
     old = me->smem + me->max_equation;
     new = me->smem + w_equation;
     OM_BLOCK_MOVE(old,new,me->max_equation*sizeof(double));
    }


/* Store new max dimensions */

  me->max_unknown  = w_unknown;
  me->max_equation = w_equation;
 return OM_S_SUCCESS;

}

/* Compress the matrix and the vector to its used size */

method VRcompress_matrix()
{
 int ieq,size_line,size_max;
 double *old,*new;


 SetProc( Md VRcompress_matrix ); Begin 

/* Move line that describe the coef of the constrains to solve */

 size_max = me->max_unknown * sizeof(double);
 size_line  = me->nb_unknown  * sizeof(double);
 old = me->matrix;
 new = me->matrix;
 
 for(ieq=0 ; ieq<me->nb_equation ; ieq++)
 {
  OM_BLOCK_MOVE(old,new,size_line);
  new += me->nb_unknown;
  old += me->max_unknown;
 }

/* Move line that describe the weigth in the linear form to optimize */

 old = me->matrix + me->max_unknown*me->max_equation;
 new = me->matrix + me->nb_unknown *me->nb_equation;
 OM_BLOCK_MOVE(old,new,size_line);

/* Move flags that describe the type of the constrains */

 old = me->smem + me->max_equation;
 new = me->smem + me->nb_equation;
 size_line = me->nb_equation  * sizeof(double);
 OM_BLOCK_MOVE(old,new,size_line);

 End
 return(OM_S_SUCCESS);

}

/* Allocate space to store planes */

method VRalloc_plane(int new_plane_size)
 {
  int status; 
  int plane_size;

  plane_size = om$dimension_of(varray = me->plane);

  if(new_plane_size < plane_size) return(OM_S_SUCCESS);

  plane_size = 1.5 * new_plane_size;

  /*"realloc plane array with size %d\n",plane_size */


  status = om$vla_set_dimension(varray = me->plane,
				size   = plane_size);
  as$status(action = RET_STATUS);

  status = om$vla_set_dimension(varray = me->plane_state,
				size   = plane_size);
  as$status(action = RET_STATUS);

  status = om$vla_set_dimension(varray = me->plane_vectoriel,
				size   = plane_size);
  as$status(action = RET_STATUS);

  status = om$vla_set_dimension(varray = me->unknown_index,
				size   = plane_size);
  as$status(action = RET_STATUS);

  status = om$vla_set_dimension(varray = me->plane_eq,
				size   = 4*plane_size);
  as$status(action = RET_STATUS);

  status = om$vla_set_dimension(varray = me->iteration,
				size   = plane_size);
  as$status(action = RET_STATUS);
  return OM_S_SUCCESS;
 }
end implementation VRcons;
