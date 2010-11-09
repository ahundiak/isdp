
/*\ Bitangent line implementation

     CHANGE HISTORY:

     Bruno Dressler 22-mar-86 : Design date
     jla               jul-86 : IGE implementation
     jla            20-oct-86 : associative implementation

\*/

class implementation ASlinedbt;


#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"

#include "nddef.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "ASmsg.h"
#include "msmacros.h"

#define AS_DEBUG 1

extern GRclassid OPP_GR3dlineseg_class_id;

/***********************************************************************/
 
IGRdouble ref_from_centers(

  IGRpoint center1,
  IGRpoint center2,
  double *ix, double *iy,     /* normed vector of centers */
  double *jx, double *jy)			/* normed vector orthogonal*/
/* .ref_from_c */
{
double  x,y,d;

x=center2[0]-center1[0];
y=center2[1]-center1[1];
d=sqrt(x*x+y*y);
if (d != 0 )
    {
    *ix=x/d;
    *iy=y/d;
    *jx=(*iy);
    *jy=(-*ix);
    }
else
    {
    *ix=1;
    *iy=0;
    *jx=0;
    *jy=1;
    }

return (d);
}


/**************************************************************************/
/*
   ASlinedbt.place
   Non interactive placement of a dbt line
*/


method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
		IGRchar *go_cnst_lis)
{

	    IGRdouble *pa,*pb;
   	    IGRpoint center1,center2,line[2],p0;
   	    IGRdouble rad1,rad2,xx;
            IGRvector v, v2, vtrans;
	    IGRdouble mat[9];
	    struct ret_struct  pardef1,pardef2,objdef;
	    double length;
	    IGRlong msg,status;

   /* data of the parent circle */
       status = om$send(msg =message NDnode.NDgive_structure
							(&msg,&pardef1,md_env),
		        targetid = asso_lis->parents[0].objid,
		        targetos = asso_lis->parents[0].osnum);
       as$status(action = RET_STATUS);

       status = om$send(msg =message NDnode.NDgive_structure
							(&msg,&pardef2,md_env),
		        targetid = asso_lis->parents[1].objid,
		        targetos = asso_lis->parents[1].osnum);
       as$status(action = RET_STATUS);

     /* snap point location */

if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
    {
     pa = (IGRdouble *) asso_lis->as_attr;
     pb = pa + 3;
    }
else
   {
    IGRdouble dist1, dist2;
    status = as$any_give_structure( go_grid = asso_lis->go_objid,
                                    mod_env = md_env,
				    inst    = &objdef );
    as$status();
		       
    MAsubvc(&msg, pardef1.var.point_st.pt, objdef.var.line_st.p0, v);
    MAsubvc(&msg, pardef2.var.point_st.pt, objdef.var.line_st.p0, v2);
    dist1 = v_len( v ); dist2 = v_len( v2 );

    if( dist1 < dist2 )
    {
     pa = objdef.var.line_st.p0; 
     pb = objdef.var.line_st.p1; 
    }
    else
    {
     pa = objdef.var.line_st.p1;
     pb = objdef.var.line_st.p0;
    }
  }
  	     
 mat4_3(pardef1.var.circle_st.mat,mat);

   	    v_equal(pardef1.var.circle_st.cent_p,p0);
   	    v_identity(center1);
   	    rad1=pardef1.var.circle_st.rad;

   /* is the second object a point or a circle */

       if (pardef2.type & conic_generic) 
	   {
	    rad2=pardef2.var.circle_st.rad;
            v_sub(pardef2.var.circle_st.cent_p,p0,center2);
	   }
	else
 	   {
	    rad2 = 0.;
            v_sub(pardef2.var.point_st.pt,p0,center2);
	   }

   	    /* set the second center  and snap points in the coordonate
		 of the first circle*/
   	    v_sub(pa,p0,pa);
   	    v_sub(pb,p0,pb);
   	    mt_mul_v(mat,center2,center2);
   	    mt_mul_v(mat,pa,pa);
   	    mt_mul_v(mat,pb,pb);

          /* See which of the contact points is nearer raypoint */

    	    {
   		IGRdouble ix,iy,            	/* normed vector of centers */
           		jx,jy,			/* normed vector orthogonal*/
            		d;
    		IGRdouble x,y;
    		int k1 = 0,k2 = 0,i;

    		d= ref_from_centers(center1,center2 ,&ix,&iy,&jx,&jy);
    		x= *pa-center1[0];
    		y= *(pa+1)-center1[1];
                /* modif ch le 9 oct 87 */
		/* k1=0<(x*jx+y*jy);    */
		if( rad1 > 0 )	k1=0<(x*jx+y*jy);
		if( rad1 < 0 )	k1=0>(x*jx+y*jy);
		/* fin modif */

    		x= *pb-center2[0];
    		y= *(pb+1)-center2[1];
                /* modif ch le 9 oct 87 */
    		/* k2=0<(x*jx+y*jy); */
		if( rad2 > 0 ) k2=0<(x*jx+y*jy);
		if( rad2 < 0 ) k2=0>(x*jx+y*jy);
		/* fin modif */

    		me->which1     = k1                     ;
    		me->which2     = k2                     ;
    		line_bitang( center1,rad1, center2,rad2, line,k1,k2 );
    
    		for (i=0;i<2;i++)
    		{	 
   		    m_mul_v(mat,line[i],line[i]);
		    v_add(line[i],p0,line[i]);
    	        }

   	     }
/*-------------------------------------------------*/



/* 
   extend initialization
*/
	
     {
      IGRvector v0;

      v_sub(line[1],line[0],v0);
      length=v_len(v0);

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
    {
     me->d0=0.;
     me->d1=0.;
    }
  else
   {
    struct ret_struct  objdef;
    status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
    as$status();

    if(length != 0) { length = 1./length; v_scale(v0,length,v0); }
    else { v0[0]=1.; v0[1]=0.; v0[2]=0.; }

    v_sub( objdef.var.line_st.p0, line[0], vtrans );
    xx = v_dot( v0, vtrans );
    me->d0 = -xx;
    v_scale(v0, xx, vtrans);
    v_add(line[0], vtrans, line[0] );

    v_sub( objdef.var.line_st.p1, line[1], vtrans );
    me->d1 = v_dot( v0, vtrans );
    v_scale(v0, me->d1, vtrans);
    v_add( line[1], vtrans, line[1] );
   }
  }

 if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 2;
    geom.points     = line[0];

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send(msg = message ASnode.ASconstruct_go
		    (asso_lis,md_env,go_cnst_lis,OPP_GR3dlineseg_class_id,TRUE),
	    	     targetid = my_id);
    as$status(action = RET_STATUS);
   }

/*
   add to node tree
*/
     status=om$send(msg = message NDnode.NDconnect (asso_lis->num_parents,
					 asso_lis->parents,NULL_GRID,ND_NEW),
            	   targetid =  my_id);
    as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
 }/* place */



/***********************************************************************/

int line_bitang( center1,rad1, center2,rad2, line, Which1, Which2 ) 

       /*---------------------------------------------------------------*\
        | Computes the bitangent line on 2 circles ( or a limit case ). |
        | or point                                                      |
        |                                                               |
        | Returns 1 if good tangent case and 0 if no classical case     |
        | but a line is allway computed.                                |
       \*---------------------------------------------------------------*/

IGRpoint center1, center2 ; 
IGRdouble rad1,rad2;
IGRpoint  line[]             ;
int                 Which1, Which2    ;	/*1:left, 0:right*/

{  
IGRdouble ix,iy,            	/* normed vector of centers */
       jx,jy,			/* normed vector orthogonal*/
       ui,uj,
        d;			/* d= distance of centers*/
IGRdouble s,u,p;
int t,k1,k2,good,degen1,degen2;



k1=Which1?1:-1;
k2=Which2?1:-1;
d=ref_from_centers(center1,center2,&ix,&iy,&jx,&jy);
if (d!= 0)
     {
     s=k1 * rad1 - k2 * rad2;
     t= (s<0	)?-1:1;
     s=(s<0)?-s:s;
     u = d*d - s*s;
     degen1= (u<=0);
     p = (degen1)?0:sqrt (u);
     ui = t* ((d<=s)?1:s/d);
     degen2= (d<p);
     uj = (degen2)?0:p/d;
     line[0][0]=center1[0] +rad1* (ui*ix+uj*jx)*k1; 
     line[0][1]=center1[1] +rad1* (ui*iy+uj*jy)*k1; 
     line[0][2]=0;
     if ( !degen1)
           {
           line[1][0]=center2[0] +rad2* (ui*ix+uj*jx)*k2; 
           line[1][1]=center2[1] +rad2* (ui*iy+uj*jy)*k2; 
           line[1][2]=0;
           }
     else
           { 
           line[1][0]=line[0][0] +(rad2-rad1)* jx*k2; 
           line[1][1]=line[0][1] +(rad2-rad1)* jy* k2; 
           line[1][2]=0;
           }
     good = !(degen1 | degen2 );
     }
else
     {
     good =0;		/* Give arbitray line */
     line[0][0]=center1[0] -100000; 
     line[0][1]=center1[1] -100000;
     line[0][2]=0;
     line[1][0]=center2[0] +100000;
     line[1][1]=center2[1] +100000;  
     line[0][2]=0;
     }

return(good);

} /* end line_bitang */

/***********************************************************************/


/*
  compute_node

    compute a line bitangente to two parent circles  

*/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];
		      struct GRmd_env *md_env)

{
    struct ret_struct  pardef1,pardef2,linedef;
    IGRdouble length,mat[9];
    IGRlong status;


    if (!(count& 2))
    {
       printf("ASlinedbt.compute_node bad parent number\n");
    }  

/* data of the parent line */ 
 
   
    status = om$send(msg =message NDnode.NDgive_structure(msg,&pardef1,md_env),
		     targetid = list[0].objid ,
		     targetos = list[0].osnum);
    as$status(action = RET_STATUS);

    status = om$send(msg =message NDnode.NDgive_structure(msg,&pardef2,md_env),
		     targetid = list[1].objid ,
		     targetos = list[1].osnum);
    as$status(action = RET_STATUS);

/*  to compute the ASlinedbt we work first in the referential defined
    by the matrix and the cent_p of the first circle.
       This matrix is also token as a base to store the cases
    of construction.
*/
   {
       IGRpoint center1,center2,line[2],p0;
       IGRdouble rad1,rad2;
   
       mat4_3(pardef1.var.circle_st.mat,mat);
       v_equal(pardef1.var.circle_st.cent_p,p0);
       v_identity(center1);
       rad1=pardef1.var.circle_st.rad;

  /* is the second object a circle or a point */

       if (pardef2.type & conic_generic) 
	   {
	    rad2=pardef2.var.circle_st.rad;
            v_sub(pardef2.var.circle_st.cent_p,p0,center2);
	   }
	else
 	   {
	    rad2 = 0.;
            v_sub(pardef2.var.point_st.pt,p0,center2);
	   }

   /* set the second center in the coordonate of the first circle*/
   

       mt_mul_v(mat,center2,center2);

       line_bitang( center1,rad1, center2,rad2,
		 line,me->which1, me->which2 );
    
       m_mul_v(mat,line[0],line[0]);
       v_add(line[0],p0,linedef.var.line_st.p0);

       m_mul_v(mat,line[1],line[1]);
       v_add(line[1],p0,linedef.var.line_st.p1);
       
       v_sub(linedef.var.line_st.p1,linedef.var.line_st.p0,
             linedef.var.line_st.v0);
  length = v_len(linedef.var.line_st.v0);
  if(length == 0) { linedef.var.line_st.v0[0]=1.; linedef.var.line_st.v0[1]=0.;
                    linedef.var.line_st.v0[2]=0.;
		  }
  else		  {length = 1./length;v_scale(linedef.var.line_st.v0,length,
					      linedef.var.line_st.v0 );
		  }
	

/* update the graphic associated object */
 
 status = om$send(msg =message ASline.ASpostab(msg,md_env,&linedef),
 		  targetid =  my_id);
 as$status(action = RET_STATUS);
 }
  
    return(OM_S_SUCCESS);

}  /* compute_node */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  OMuint              icount;              /* Index for loop                  */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct ret_struct   my_def;
  IGRlong msg,status;

  /* Get the structure of the class */

  status = om$send(msg =message NDnode.NDgive_structure(&msg,&my_def,md_env),
	  	   targetid = my_id);
  as$status(action = RET_STATUS);

  /* Get the name of this object */

  as$printer_set_name(prefix="DBT_LINE",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print the instances ( 2 snap point) */

  for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,my_def.var.line_st.p0[icount]);
  for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount+3,my_def.var.line_st.p1[icount]);

  /* Print the message */

  fprintf(stream,"send ASlinedbt.place(%d,list,ptr) to %s;\n\n",count,name);

  /* Is there also extend to print */

  if(me->d0 !=0 || me->d1 !=0)
      {
       ASprint_line_ext(stream,me->d0,me->d1,name);
      }

  return(OM_S_SUCCESS);
}/* end print */


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_BiTgLn);
     return(OM_S_SUCCESS);
}



method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
 
 *nb_tot = 2;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  switch( i )
  {
   case 0 : 
    {
     geom_code[j]   = conic_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 1 :
    {
     geom_code[j]   = point_generic | conic_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
  } /*  end switch  */

 /*  track point or ref ? */

 *index_ref   = -1;  /* no ref.        */
 *index_track = -1;  /* no track point */
 *index_plan  = -1;  /* no plan        */

 return(OM_S_SUCCESS);
}



end implementation ASlinedbt;
