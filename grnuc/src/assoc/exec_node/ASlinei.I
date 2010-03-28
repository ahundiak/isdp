
/*  ASline implementation file

HISTORY :
     C.Heraud  10/06/86   : Design date
     jla       11-mar-87  : Union class and GRdisextend and GRptextend override
    momo       06-fev-89  : Add the ASpoststr method
*/

class implementation ASline;


#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "asbox.h"
#include "asdef.h"
#include "nddef.h"

#define AS_DEBUG

from ASlinepara import change_flag;

method ASpostab( IGRlong *msg ; struct GRmd_env *md_env; 
                 struct ret_struct *linedef)
{
 struct GRpost_info post_info;
 struct IGRpolyline polyline;
 IGRvector vtrans;
 GRobjid newobjid;
 IGRdouble xx;
 IGRint status;
 
 /*" d0: %lf, d1: %lf\n",me->d0,me->d1 */

 *msg = 1;


    /* add the offset */

 if( me->d0 != 0 ||  me->d1 != 0 )
  {
   xx=-me->d0;
   v_scale(linedef->var.line_st.v0, xx, vtrans);
   v_add(linedef->var.line_st.p0, vtrans, linedef->var.line_st.p0 );

   v_scale(linedef->var.line_st.v0, me->d1, vtrans);
   v_add(linedef->var.line_st.p1, vtrans, linedef->var.line_st.p1 );
  }

  polyline.num_points = 2;
  polyline.points = linedef->var.line_st.p0;
  post_info.construct_flag = FALSE;
  status = om$send(msg = message GRlinear.GRputpolyline(msg,md_env,
				    &post_info, &polyline,&newobjid),
	       	   p_chanselect = &AS_to_comp);
  as$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
 }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                             ASpoststr method

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASpoststr(IGRlong *msg; struct GRmd_env *md_env; 
                  struct GRpost_info *info; IGRshort nb_obj; IGRchar **str; 
		  struct GRid *newobjid)
{
  IGRint 		status;
  IGRvector 		vtrans;
  IGRdouble 		xx;
  struct ret_struct	*linedef;
  struct IGRpolyline	polyline;

 
  /*" d0: %lf, d1: %lf\n",me->d0,me->d1 */

  *msg = 1;

  linedef = (struct ret_struct *) *str;

  /* add the offset */

  if( me->d0 != 0 ||  me->d1 != 0 )
  {
    xx=-me->d0;
    v_scale(linedef->var.line_st.v0, xx, vtrans);
    v_add(linedef->var.line_st.p0, vtrans, linedef->var.line_st.p0 );

    v_scale(linedef->var.line_st.v0, me->d1, vtrans);
    v_add(linedef->var.line_st.p1, vtrans, linedef->var.line_st.p1 );
  }

  info->construct_flag = FALSE;

  polyline.num_points = 2;
  polyline.points = linedef->var.line_st.p0;

  status = om$send(msg          = message GRlinear.GRputpolyline
                                  (msg,md_env,info,&polyline,&newobjid->objid),
	       	   p_chanselect = &AS_to_comp);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
 
}


/* function to print the line extend used by associative line subclass */

ASprint_line_ext(stream,d0,d1,name)
 FILE *stream;
 IGRdouble d0,d1;         /* distance to print                  */
 IGRchar *name;           /* name of the object to extend       */

 {
  fprintf(stream,"send ASline.ASlinext(%lf,%lf,NULL) to %s;\n",
	  d0,d1,name);
  return(1);
 }



/*
   GRptextend is overriden to compute the new value of the extend stored in
   the instance of the associative line. Also need to modify the extend
   of my parallel line
*/


method GRptextend(IGRlong *msg; struct GRmd_env *md_env; IGRpoint endpoint,
		   ext_pt, new_end)
{
 struct ret_struct  my_def;
 IGRint status;
 IGRpoint w,p1,p0;
 IGRdouble dist0,dist1;
 IGRdouble d,d0,d1,scal,xx,one=1.;
 

/* 
   witch one of the extend value has to be modified
*/
  
 
  status = om$send(msg = message NDnode.NDgive_structure(msg,&my_def,md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  v_sub(my_def.var.line_st.p0,endpoint,w);
  dist0 = v_dot(w,w);
  v_sub(my_def.var.line_st.p1,endpoint,w);
  dist1 = v_dot(w,w);


/* send the message to the graphic object */

  if(dist0<dist1) 
    {/*v_sub(new_end,my_def.var.line_st.p0,w);*/
     v_sub(ext_pt,my_def.var.line_st.p0,w);
     d  = -v_dot(w,my_def.var.line_st.v0);
     d0 = d;  d1 =  0;}
  else
    {/*v_sub(new_end,my_def.var.line_st.p1,w);*/
     v_sub(ext_pt,my_def.var.line_st.p1,w);
     d = v_dot(w,my_def.var.line_st.v0);
     d1 = d; d0 =  0 ;}

   status = om$send(msg = message ASline.ASlinext(d0,d1,md_env),
		    targetid = my_id);
   as$status();
  
/* update the extend of my parallel line if any */


   v_comb(one,my_def.var.line_st.p1,d1,my_def.var.line_st.v0,p1);
   xx = -d0;
   v_comb(one,my_def.var.line_st.p0,xx,my_def.var.line_st.v0,p0);
   v_sub(p1,p0,w);
   scal = v_dot(my_def.var.line_st.v0,w);
   if(scal>0)
     {
      /*| original does not change sign */
      d0 = -d0; d1 = -d1;
     }
   else
     {
      /*| original change sign */
     }
    
   status = om$send(msg = message ASline.ASchildlinext(d0,d1,
						       my_def.var.line_st.v0,w,
						       md_env),
	            targetid = my_id);
    as$status();


/* tell it */


    status = om$send(msg = message NDnode.NDchange_node(NULL),
	    	     targetid = my_id);
    as$status();

  return (status);
}

method GRdisextend(IGRlong *msg; struct GRmd_env *md_env; IGRpoint endpoint; 
	  	    IGRdouble *dist; IGRpoint new_end)
{
 struct ret_struct  my_def;
 IGRint status;
 IGRpoint w,p0,p1;
 IGRdouble dist0,dist1;
 IGRdouble d0,d1,scal,xx,one=1.;
 struct GRmd_env local_env;

/* when used by ci */

if(md_env == NULL)
  {
   IGRlong NumberOfBytes, BytesReceived,rt;
   NumberOfBytes = sizeof( local_env );
   gr$get_module_env(msg = &rt,
                sizbuf = &NumberOfBytes,
                buffer = &local_env,
                nret = &BytesReceived );
   md_env = &local_env;
  }

 

/* 
   witch one of the extend value has to be modified
*/
  status = om$send(msg = message NDnode.NDgive_structure(msg,&my_def,md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  v_sub(my_def.var.line_st.p0,endpoint,w);
  dist0 = v_dot(w,w);
  v_sub(my_def.var.line_st.p1,endpoint,w);
  dist1 = v_dot(w,w);


/* new value of my extends */

  if(dist0<dist1)

       {d0 = *dist; d1 = 0.;}
  else
       {d0 = 0.; d1 = *dist;}
  status = om$send(msg = message ASline.ASlinext(d0,d1,md_env),
	    	     targetid = my_id);
  as$status();
   

/* Update parallel extend */

   v_comb(one,my_def.var.line_st.p1,d1,my_def.var.line_st.v0,p1);
   xx = -d0;
   v_comb(one,my_def.var.line_st.p0,xx,my_def.var.line_st.v0,p0);
   v_sub(p1,p0,w);
   scal = v_dot(my_def.var.line_st.v0,w);
   if(scal>0)
     {
      /*| original does not change sign */
      d0 = -d0; d1 = -d1;
     }
   else
     {
      /*| original change sign */
     }

   status = om$send(msg = message ASline.ASchildlinext(d0,d1,
						       my_def.var.line_st.v0,w,
						       md_env),
	    	     targetid = my_id);
   as$status();


/* tell it */

     status = om$send(msg = message NDnode.NDchange_node(NULL),
		      targetid = my_id);
     as$status();
     return(status);
   
}


/*
   when my extend are modified, i need to also change the extend of my paraline
*/

method ASchildlinext(IGRdouble d0,d1;IGRvector old_v0,new_v0;
		      struct GRmd_env *md_env)
{
IGRlong status,msg;
IGRint count,i_count;
IGRchar *ptr;
struct GRid *list_obj;
GRclassid para_class,child_class;
struct ret_struct para_def;
IGRdouble scal,scal_ori;
IGRdouble dc0,dc1;

/*"childlinext of %d %lf %lf\n",my_id,d0,d1 */

/*
   node.children chanselect init and classid of ASlinepara
*/

status = om$get_classid(classname = "ASlinepara",
	                p_classid = &para_class);
as$status(action = RET_STATUS);


/*
   get objects connected on chilidren channel
   Do not use buffer because ASlinext will call ND_compute_node
   and ND_compute_node also use the buffer
*/
   
status=om$send(msg=message NDnode.NDget_objects(ND_CHILDREN ,
					 NULL,0,NULL,0,OM_K_MAXINT,&count),
	       targetid = my_id);
as$status(action = RET_STATUS);
 
if(count<1) return(OM_S_SUCCESS);

ptr = om$malloc(size = count*sizeof(struct GRid));
list_obj = (struct GRid *)ptr;
if(list_obj == NULL) return(OM_W_ABORT);

status=om$send(msg=message NDnode.NDget_objects(ND_CHILDREN ,
				     list_obj,count,NULL,0,OM_K_MAXINT,&count),
	       targetid = my_id);
as$status(action = RET_STATUS);


/* loop to send a extend to my para_line */

 scal_ori = v_dot(old_v0,new_v0);

for (i_count=0 ; i_count<count ; i_count++)
  {
   status = om$get_classid(osnum = list_obj[i_count].osnum,
		           objid = list_obj[i_count].objid,
		           p_classid = &child_class);
   as$status();

   if(om$is_ancestry_valid(superclassid = para_class,
			    subclassid = child_class) == OM_S_SUCCESS)
     {
      status = om$send(targetid = list_obj[i_count].objid,
		       targetos = list_obj[i_count].osnum,
		       msg=message NDnode.NDgive_structure
						(&msg,&para_def,md_env));
      if(!(status&1)) continue;

      /* original line has changed sign --> change signe of parallel offset */

      if(scal_ori > 0)
        {dc0 = 0; dc1 = 0;}
      else
	{
	 /*|change signe of parallel offset */
         status = om$send(targetid = list_obj[i_count].objid,
		          targetos = list_obj[i_count].osnum,
		       msg=message ASline.ASgetlinext(&dc0,&dc1));
         if(!(status&1)) continue;
	}
	
      /* original line and parallel in opposite direction */
      scal = v_dot(new_v0,para_def.var.line_st.v0);
      if(scal>=0)
        {dc0 =  d0 - 2*dc0;dc1 =  d1 - 2*dc1;}
      else
        {/*| original and parallel in opposite direction */
         dc0 = -d0 + 2*dc0;dc1 = -d1 + 2*dc1;}

      if(scal_ori<0)
        {IGRint count_ch;
         status = om$send(targetid = list_obj[i_count].objid,
		          targetos = list_obj[i_count].osnum,
		          msg = message NDnode.NDget_objects(ND_ROOT,
					NULL,0,NULL,1,0,&count_ch));
         as$status();
	 if(count < 3)
	   {
            status = om$send(targetid = list_obj[i_count].objid,
		             targetos = list_obj[i_count].osnum,
		             msg = message ASlinepara.change_flag());
            as$status();
	   }
	}

      status = om$send(targetid = list_obj[i_count].objid,
		       targetos = list_obj[i_count].osnum,
		       msg = message ASline.ASlinext(dc0,dc1,md_env));
      as$status();
     }
  }

 om$dealloc(ptr = ptr);
 return(status);
}


method ASlinext(IGRdouble d0,d1; struct GRmd_env *md_env)
{
 IGRlong status,msg;
 struct GRmd_env local_env;
 IGRdouble save_d0,save_d1,scal;
 struct ret_struct my_def;
 IGRvector old_v0;
 IGRint cn_type;


/*"linext of %d %lf %lf\n",my_id,d0,d1 */
/* when used by ci */

if(md_env == NULL)
  {
   IGRlong NumberOfBytes, BytesReceived,rt;
   NumberOfBytes = sizeof( local_env );
   gr$get_module_env(msg = &rt,
                sizbuf = &NumberOfBytes,
                buffer = &local_env,
                nret = &BytesReceived );
   md_env = &local_env;
  }

/* Is the line already reversed ?*/

 status = om$send(msg = message NDnode.NDgive_structure(&msg,&my_def,md_env),
		  targetid = my_id);
 as$status();

 v_equal(my_def.var.line_st.v0,old_v0);
 save_d0 = me->d0;
 save_d1 = me->d1;

 me->d0 = 10;
 me->d1 = 10;

 cn_type = 0;
 status = om$send(msg = message NDnode.NDs_compute_node(&msg,cn_type,md_env),
		  targetid = my_id);
 as$status();

 status = om$send(msg = message NDnode.NDgive_structure(&msg,&my_def,md_env),
		  targetid = my_id);
 as$status();

 scal = v_dot(old_v0,my_def.var.line_st.v0);
 
 if(scal>0)
   {
    /*| previous extends doesn't change line direction */
    me->d0 = save_d0+d0;
    me->d1 = save_d1+d1;
   }
 else
   {
    /*| previous change line direction */
    me->d0 = save_d0-d0;
    me->d1 = save_d1-d1;
   }


 cn_type = 0;
 status = om$send(msg = message NDnode.NDs_compute_node(&msg,cn_type,md_env),
		  targetid = my_id);
 as$status();
 return (OM_S_SUCCESS);
}


method ASgetlinext(IGRdouble *d0,*d1)
{
 *d0 = me->d0;
 *d1 = me->d1;
 return(OM_S_SUCCESS);
}
end implementation ASline;
