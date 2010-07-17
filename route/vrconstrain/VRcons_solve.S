class implementation VRcons;

#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#define AS_DEBUG

from VRplane import VRpostabsg;

ASplane_set_equation(coef,plane,md_env)
double *coef;
struct GRid *plane;
struct GRmd_env *md_env;
{
 long status,msg;
 struct ret_struct rst;
 double fabs();

/* normal vector */

 rst.var.ref_st.t[2]  = coef[0];
 rst.var.ref_st.t[6]  = coef[1];
 rst.var.ref_st.t[10] = coef[2];


/* Point of the plane */

 rst.var.ref_st.t[3] = rst.var.ref_st.t[7] = rst.var.ref_st.t[11] = 0;
 if     (fabs(coef[0]) > 0.1) rst.var.ref_st.t[3] = -coef[3]/coef[0];
 else if(fabs(coef[1]) > 0.1) rst.var.ref_st.t[7] = -coef[3]/coef[1];
 else                         rst.var.ref_st.t[11]= -coef[3]/coef[2];

 status = om$send(msg = message VRplane.VRpostabsg(&msg,md_env,&rst),
		  senderid = NULL_OBJID,
		  targetid = plane->objid,
		  targetos = plane->osnum);
 as$status();


}

ASplane_get_equation(coef,plane,md_env)
double *coef;
struct GRid *plane;
struct GRmd_env *md_env;
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
			     int *verify)
{
 
 double d0,d1,coef0,coef1,*coef;
 int iv,i,ip;
 int in[10];
 int new_equation;
 double sign_dep;
#define EPS 1.E-6

 /*"verify constrain for plane %d and %d\n",me->plane[obj_index[0]].objid,me->plane[obj_index[1]].objid */

 /* Optimistic initialization */

 *verify = TRUE;
 new_equation = -1;

/* 
  Get unknow number.
  If the constraint is parallel, get the 2 d coef only use in the constraint
  matrix
*/

 if(nb_obj>10)
  {printf("To many planes in one constraint\n"); return OM_W_ABORT;}

 for(i=0;i<nb_obj;i++)
  in[i] = me->unknown_index[obj_index[1]];

 d0 = me->plane_eq[4*obj_index[0]+3];
 d1 = me->plane_eq[4*obj_index[1]+3];


 /*"d0 %lf d1 %lf value %lf\n",d0,d1,cons_value[0] */
 /*" unknow %d %d\n",in[0],in[1] */

 if(   (me->plane_state[obj_index[0]] & VR_REVERSE)
    != (me->plane_state[obj_index[1]] & VR_REVERSE)) d1 = -d1;

/* Is the constraint verify */

 switch(cons_type&VR_CNS_AFF)
  {
   case VR_CNS_MIN :
       /*"minimum dist %lf between planes at dist %lf\n",*cons_value,d0-d1 */

        if((d0-d1) < *cons_value-EPS) *verify = FALSE;

        /*| define if possible displacement direction for the vectorial plane */

	iv = me->plane_vectoriel[obj_index[0]];
	/*"iv %d\n",iv*/
	if( !(*verify) && !(me->plane_state[iv] & (VR_MOVE_POS|VR_MOVE_NEG)))
         {
	  if(me->plane_state[obj_index[0]]&VR_CONS_INIT)
	   {
	    /*| 0 is init\n*/
	    if(me->plane_state[obj_index[0]]&VR_REVERSE)
	      me->plane_state[iv] |= VR_MOVE_NEG;
	    else
	      me->plane_state[iv] |= VR_MOVE_POS;
	   }
	  else if(me->plane_state[obj_index[1]]&VR_CONS_INIT)
           {          
	    /*| 0 is init\n*/
	    if(me->plane_state[obj_index[0]]&VR_REVERSE)
	      me->plane_state[iv] |= VR_MOVE_POS;
	    else
	      me->plane_state[iv] |= VR_MOVE_NEG;
	   }
	  /*"plane_state %x\n",me->plane_state[iv] */
	 }
	 if(me->plane_state[iv] & VR_MOVE_NEG) sign_dep = -1;
	 else 				       sign_dep =  1;
        /*"sign_dep %lf\n",sign_dep*/

        /*| Add corresponding line to the constraint matrix */

        if(me->nb_equation >= me->max_equation)
          {printf("WARNING TO MANY CONSTRAIN\N"); return (OM_W_ABORT);}
	   
	if(in[0]>=0 || in[1]>=0)
         {
	  me->svect[me->nb_equation] = *cons_value-d0+d1; 

	  coef = me->matrix+me->max_unknown*me->nb_equation;
	  for(i=0;i<me->max_unknown;i++) coef[i] = 0;
	  if (in[0]>=0)
	   {coef[in[0]] = -sign_dep; /*" in[0] coef[%d] %lf\n",in[0],coef[in[0]]*/}
	  if (in[1]>=0) 
	   {coef[in[1]] =  sign_dep; /*" in[1] coef[%d] %lf\n",in[1],coef[in[1]]*/}
  	  /*"smem[%d] %lf\n",me->nb_equation,me->svect[me->nb_equation]*/
	
          new_equation = me->nb_equation;
          me->nb_equation++;
	 }
	break;
    
   case VR_CNS_MAX :
       /*"maximum dist %lf between planes at dist %lf\n",*cons_value,d0-d1 */
        if((d1-d0) > *cons_value+EPS) *verify = FALSE;
	break;

   case VR_CNS_VAL : /*| verify minimum distance between planes */
	break;

   case VR_CNS_PT :  /*| all the plane have a common point */
        break;
  }

/*
   If not verify can I define positive direction for planes that don't
   verify constrain 
*/


/*
   Add line to the constraint matrix
*/

/*| Set adequate state to planes that don't verify constraint */

  if(!*verify)
   { 
    for(i=0;i<nb_obj;i++)
      me->plane_state[obj_index[i]] |= VR_CONS_ERROR;
   }
/*"constraint is %d\n",*verify*/

/* Store index of the plane that correspond to the equation */

 if(new_equation>=0)
  {
   me->first_plane_in_eq[new_equation] = me->nb_plane_in_eq;
   for(ip=0;ip<nb_obj;ip++)
    {
     me->plane_in_eq[me->nb_plane_in_eq++] = obj_index[ip];
    }
   me->n_plane_in_eq[new_equation] = me->nb_plane_in_eq -
   				     me->first_plane_in_eq[new_equation];
  /*"in eq %d nb %d first %d\n",new_equation,me->n_plane_in_eq[new_equation],me->plane[me->plane_in_eq[me->first_plane_in_eq[new_equation]]].objid*/
  }
 return OM_S_SUCCESS;
}

/* Find non negative coef on the line and compute the value of the secmmem */

method VRfind_coef(int line,*un0,*un1;double *coef0,*coef1,*value)
{ 
 int col;
 double fabs();
 double *coef; 

 /* Find 2 non negative coef */
 *un0 = -1; *un1= -1;

 coef = me->matrix + line*me->max_unknown;
 *coef0 = 0; *coef1 = 0;
 *value = me->svect[line];
 for(col = 0; col < me->nb_unknown ; col++)
     { 
      if(fabs(coef[col])> EPS) 
       {
        if(*un0<0)
         {*un0 = col; *coef0 = coef[col]; *value -= *coef0*me->unknown[*un0];}
	else
	 {*un1 = col; *coef1 = coef[col]; *value -= *coef1*me->unknown[*un1];
	  break;}
       }
     }
/*"eq %d un %d %d coef %lf %lf val %lf\n",line,*un0,*un1,*coef0,*coef1,*value*/ 
 return OM_S_SUCCESS;
}


method VRsolve_af_constrain(int *all_is_ok)
{
int ifois,status;
int un0,un1;
int ip,ipp;
int line,col;
double *coef,coef0,coef1,value;
double fabs();
int total_failure;

if(me->nb_unknown ==0)
 {/*| Nothing to solve !!! */ *all_is_ok = FALSE;return;}

/*^{int ijl,jjl,jjll;
    double *x;
    printf("solve system of inequalities %d unknow %d equation\n",
	   me->nb_unknown,me->nb_equation);
    if(me->nb_unknown <10)
      { 
	printf(" matrix and svect\n");
	for(ijl=0;ijl<me->nb_equation;ijl++)
         {
	  x = me->matrix + me->max_unknown*ijl;
	  for(jjl = 0;jjl<me->nb_unknown;jjl++,x++) printf(" %lf ",*x);
          printf(" %lf \n",me->svect[ijl]);
	 }
      }
     for(ijl=0;ijl<me->nb_equation;ijl++)
      {printf("plane for equation %d\n",ijl);
       for(jjl=me->first_plane_in_eq[ijl],jjll;jjll<me->n_plane_in_eq[ijl];jjl++,jjll++)
        { printf(" %d ",me->plane[me->plane_in_eq[jjl]].objid);}
       printf("\n");
      }
    }
*/
#define MAX_FOIS 10

total_failure = FALSE;

/* Initialize unknown vector */

for(ip=0;ip<me->nb_unknown;ip++) me->unknown[ip] = 0;


for(ifois=0;ifois<=MAX_FOIS;ifois++)
 {
  *all_is_ok = TRUE;
  for(line=0 ; line<me->nb_equation; line++)
   {
    status = om$send(msg = message VRcons.VRfind_coef
			    (line,&un0,&un1,&coef0,&coef1,&value),
		   targetid = my_id);

    if(un0<0) { total_failure = TRUE; continue; }


     /*| Change if necessary value of an unknow to verify the equation */

    if(value < EPS) continue;
    *all_is_ok = FALSE;
    if(coef0>EPS)
     {
      me->unknown[un0] += value/coef0;
      /*" Modif un0 %d --> %lf \n",un0,me->unknown[un0] */
     }
    else if (coef1>0)
     {
      me->unknown[un1] += value/coef1;
      /*" Modif un1 %d --> %lf \n",un1,me->unknown[un1] */
     }
    else
     {/*| Total failure because negative coef */
      total_failure = TRUE; continue;
     }
   } 
 /*^{ int ijl;
      printf("step %d unknow state \n",ifois);
      for(ijl=0;ijl<me->nb_unknown;ijl++) printf(" %lf ",me->unknown[ijl]);
      printf("\n");
    }
 */
  if(total_failure) break;
  if(*all_is_ok) {/*| Solution found !!!!\n*/ break;}
 } 


 if(!total_failure && *all_is_ok) return (OM_S_SUCCESS);

/*| Tag the planes that don't verify constraints */

 for(line=0 ; line<me->nb_equation; line++)
  {
    status = om$send(msg = message VRcons.VRfind_coef
			    (line,&un0,&un1,&coef0,&coef1,&value),
		   targetid = my_id);

    if(value > EPS)
     {
      for(ip=me->first_plane_in_eq[line],ipp=0;ipp<me->n_plane_in_eq[line];
	  ip++,ipp++)
      me->plane_state[me->plane_in_eq[ip]] |= VR_CONS_ERROR;
      /*" %d is in error\n",me->plane[me->plane_in_eq[ip]].objid*/
     }
  }

 return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* Store a plane */

method VRstore_plane(struct GRid *obj; int *index; struct GRmd_env *md_env)
{
 int status;
 int plane_size,ipp,iv,i,node_type,iz;
 double *coef,*coef_p;
 double fabs();
 double orient;

#define EPS 1.E-8

/* Is this plane already stored */

 for(ipp = 0; ipp< me->nb_plane ; ipp++)
   {
    if(  (obj->objid == me->plane[ipp].objid)
       &&(obj->osnum == me->plane[ipp].osnum)) break;
   }

 plane_size = om$dimension_of(varray = me->plane);
 if(ipp >= me->nb_plane)
   {
    if(me->nb_plane >= plane_size)
     {
      plane_size = 1.5*plane_size;

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
     }

    ipp = me->nb_plane++;
    me->plane[ipp] = *obj;

    if(me->solver_state == VR_SOLVER_PROPAGATE)
       me->plane_state[ipp] = VR_CONS_EXT;
    else
      {
       status = nd$get_type(nb_obj = 1,
			    p_object = me->plane + ipp,
			    p_type = &node_type);

       if(node_type & ND_EXTERN) 
	       me->plane_state[ipp] = VR_CONS_EXT;
       else
	       me->plane_state[ipp] = VR_CONS_INIT;
      }
    }

/*"Get equation and unknown number of plane %d\n",me->plane[ipp].objid */

 if(!(me->plane_state[ipp]&VR_HAVE_EQ))
  {
    if(me->plane_state[ipp] & VR_CONS_FREE)
      {
       if(me->nb_unknown >= me->max_unknown)
	 {printf("PAS PLUS DE 20 UNKNOWN POUR LE MOMENT!\n");return OM_W_ABORT;}
	
       me->unknown_index[ipp] = me->nb_unknown++;
      }
     else
      {
       me->unknown_index[ipp] = -1;
      }
     
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

    if(orient<0) me->plane_state[iv] |= VR_REVERSE;
  }

 *index = ipp;
 return OM_S_SUCCESS;
}
end implementation VRcons;
