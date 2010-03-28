/*
  ACpretendi.I
  robert patience
  21_jul_86
*/
class implementation ACpretend;

#include "ASmacroi.h"

#include "macro.h"
#include "madef.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#define AS_DEBUG

from ACmacro_defn import ACfind_map;
from ACpreroot 	import 	ACplace;

/* states of pretends bad implementation but to late now */
extern GRclassid OPP_ACcpx_class_id;

/* ========================================================================= */
method ACfind_parent(struct GRid *father;IGRshort *mat_type;IGRdouble *matrix)
{
int status,size,msg;

   status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_template_chns,
				count = (OMuint *)&size );
   as$status( action = RET_STATUS );

   if(size!=1)
   {
    printf("ACpretend bad number of parents\n");
    return(0);
   }
   ACmagic_read(my_id, &AC_template_chns,father, size);
  /*"oretend in design father %d\n",father->objid,father->osnum*/

  /* context now */

  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&msg,matrix);


return(1);
}

/* ========================================================================= */
method ACplace(IGRint prop; OM_S_OBJID *list;char *down_scan)
{
  int		status;
  struct GRid 	father;

  father.objid=list[0];
  father.osnum=OM_Gw_current_OS;

  status = om$send(msg = message ACpretend.ACpconnect(prop, father, down_scan),
		   targetid = my_id );
  as$status( action = RET_STATUS );
  return(1);
}

/* ========================================================================= */

method ACpconnect(IGRint prop; struct GRid father; char *down_scan)
{
  int	status;

  status = om$vla_set_dimension( varray = me->down_scan, 
				 size = strlen(down_scan)+1 );
  strcpy(me->down_scan,down_scan);

  me->direct_index=-1;

  {
    status = om$send( msg = message NDnode.NDconnect(1, &father, 
				NULL_GRID, ND_NEW),
		    targetid = my_id);
    as$status( action = RET_STATUS );
  }

  status = om$send( msg = message NDnode.NDchg_state
                                              (ND_SUP_ONLY, ND_SUP_ONLY),
	  	    targetid = my_id );
  as$status( action = RET_STATUS );

  return(1);
}

/* ========================================================================= */

method NDgive_structure(IGRlong *msg; struct ret_struct  *x;
			struct GRmd_env *md_env )
{
  int 		suc, status;
  struct 	GRid father;
  struct GRmd_env local_env;
  IGRmatrix     tmp_matrix;
  short four;

  /*"down_scan %s index %d \n",  me->down_scan,me->direct_index */

  /* Get parent and matrix to use */

  local_env.md_id = md_env->md_id;
  status = om$send(msg = message ACpretend.ACfind_parent(&father,
					    &local_env.md_env.matrix_type,
					     tmp_matrix
					    ),
		       targetid = my_id);
  as$status( action = RET_STATUS );

  four = 4;
  MAmulmx(msg,&four,&four,&four,md_env->md_env.matrix,tmp_matrix,
			        local_env.md_env.matrix);
  MAtypemx(msg,local_env.md_env.matrix,
  	      &local_env.md_env.matrix_type);


  if('.'==me->down_scan[0])
   {
    status = om$send(msg = message NDnode.NDgive_structure(msg,x,&local_env),
		       targetid = father.objid,
		       targetos = father.osnum );
      as$status( action = RET_STATUS ); 
    }
    else
    {
      status = om$send(msg = message NDmacro.ACgive_structure ( &suc,
				&(me->direct_index),me->down_scan,x,&local_env),
        	       targetid = father.objid,
		       targetos = father.osnum );
      as$status( action = RET_STATUS ); 
      if(suc==0)
      {
        printf
	 ("ACpretends ACgive_structure unable to find feet with downscan %s\n",
	   me->down_scan);
        return(0);
      }
    }
      /*"struct_type %#x \n",x->type */
  return(1);
} 

/* ========================================================================= */


method NDcompute_node ( IGRlong *msg; int cn_type;int count; 
			struct GRid list[]; struct GRmd_env *md_env )
{
 long status,loc_msg;
/* Verify if the object I'm pointing to still exist */
  status = om$send(msg = message NDmacro.ACtest_foot(&loc_msg,me->down_scan),
		  targetid = list->objid,
		  targetos = list->osnum);
  if(status&loc_msg&1) *msg = ND_COMP_SUCC;
  else 		       *msg = ND_COMP_FAIL;
  return( OM_S_SUCCESS );
}

/* A pretend is always support only */

method NDget_state( char *n_state)
{
 *n_state = me->state | ND_SUP_ONLY; 
 return OM_S_SUCCESS;
}

/* ========================================================================= */

method unknown (OM_S_MESSAGE *msg)
{

  /*^
  char classname1 [OM_K_MAXCLASS_LEN], classname2 [OM_K_MAXCLASS_LEN];
  IGRint  	status;
  IGRchar 	name [80];
  om$get_classname( classid = msg->select.ReqClassid, 
                    classname = classname2 );
  om$get_classname( classid = msg->select.DefClassid, 
                    classname = classname1 );
  status = om$get_message_name ( classid = msg->select.ReqClassid,
                                 method_index = msg->select.FuncIndex,
                                 msg_name = name );

  printf ( "Unknown Message from %s to %s,%s\n",classname1, classname2,
		name);
  */
    return(OM_W_UNKNOWN_MSG);
} /* end method unknown */

/* ========================================================================= */
#define path_MAX_CHAR 160

ACmkstring(ft,dwn,ftnm)
char *ft,*dwn,*ftnm;
{
  /*| ACmkstring */
  strcpy(ft,"");  
  if(('.' != dwn[0]) && (0 != dwn[0]))
  {
   strcpy(ft,dwn);  
   if(('.' != ftnm[0]) && (0 != ftnm[0]))
   {
    strcat(ft,":");  
   }
  }
  if(('.' != ftnm[0]) && (0 != ftnm[0]))
  {
   strcat(ft,ftnm);  
  }
  /*"ACmkstring %s \n",ft */
  return(1);
}

method  ACgive_structure(int *suc,*direct_index;char *footname;
		struct ret_struct  *ptr_rst;struct GRmd_env *md_env )
{
  int	status,msg;
  char          feet_bloc[path_MAX_CHAR];
  int      	m_1,*d_i;
  struct 	GRid father;
  struct GRmd_env local_env;
  IGRmatrix     tmp_matrix;
  short four;


  /* Get parent and matrix to use */

  local_env.md_id = md_env->md_id;
  status = om$send(msg = message ACpretend.ACfind_parent(&father,
					    &local_env.md_env.matrix_type,
					     tmp_matrix
					    ),
		   targetid = my_id);
  as$status( action = RET_STATUS );

  four = 4;
  MAmulmx(&msg,&four,&four,&four,md_env->md_env.matrix,tmp_matrix,
                                local_env.md_env.matrix);
  MAtypemx(&msg,local_env.md_env.matrix,
              &local_env.md_env.matrix_type);



  /*"ACgive foot %s,%s \n",me->down_scan,footname */
  ACmkstring(feet_bloc,me->down_scan,footname);

  if('.'==me->down_scan[0])
  {
   d_i=direct_index;
  }
  else
  {
   m_1=-1;
   d_i=&m_1;
  }
    
  status = om$send(msg = message NDmacro.ACgive_structure ( suc,
					d_i,feet_bloc,ptr_rst,&local_env),
        	     targetid = father.objid,
		     targetos = father.osnum );
  as$status(  ); 

  return(status);
}

method   ACreturn_foot(IGRlong *msg;char *footname;     
		struct GRid *foot_GRid;IGRshort *mat_type;IGRdouble *matrix)
{
  int	        i,status;
  char          feet_bloc[path_MAX_CHAR];
  struct 	GRid father;
  IGRshort	loc_mat_type1,loc_mat_type2;
  IGRmatrix     loc_matrix1,loc_matrix2;
   

/* 
  This returns the transformation matrix when the modification is accross
  object space 
*/
  status = om$send(msg = message ACpretend.ACfind_parent
			(&father,&loc_mat_type1,loc_matrix1),
		       targetid = my_id);
/*
     as$status(  );
*/
     /** Handling return status from ACfind_parent -- Modification
         made as per the requirement of VDS group ***/
     if(!(status & 1))
         return status;

/*"me->down_scan >>%s<<, foot name >>%s<<\n",me->down_scan,footname */
  ACmkstring(feet_bloc,me->down_scan,footname);

  /*"return_foot >%s< to %d %d\n",feet_bloc,father.objid,father.osnum */
  status = om$send(msg = message NDmacro.ACreturn_foot ( msg,
					feet_bloc,foot_GRid,
					&loc_mat_type2,loc_matrix2),
        	     targetid = father.objid,
		     targetos = father.osnum );
   /*"msg %d status %d\n",*msg,status */
  as$status(  ); 

  if(loc_mat_type1 == MAIDMX)
   {
    if(mat_type) *mat_type = loc_mat_type2;
    if(matrix) for(i=0;i<16;i++) matrix[i] = loc_matrix2[i];
   }
  else if(loc_mat_type2 == MAIDMX)
   {
    if(mat_type) *mat_type = loc_mat_type1;
    if(matrix) for(i=0;i<16;i++) matrix[i] = loc_matrix1[i];
   }
  else
   {
    short four = 4;
    double tmp_matrix[16];
    MAmulmx( msg, &four, &four, &four, loc_matrix1, loc_matrix2, tmp_matrix );
    if(matrix) for(i=0;i<16;i++) matrix[i] = tmp_matrix[i];
    if(mat_type) MAtypemx(msg,tmp_matrix,mat_type);
   }
 

  /*"ACgive foot %d \n",foot_GRid->objid */
  return(status);
}

/* ========================================================================= */
#define MAX_CHAR 80

method NDprint( struct GRmd_env *md_env ; FILE *stream)
{
  OMuint              	count;
  char                	name[MAX_CHAR];
  

  as$printer_set_name( prefix = "PRETEND", name = name);
  if (strcmp(name,"")!=0)
  {
    as$printer_print_parents( count = &count);
    fprintf(stream,
	    "send ACpretend.ACplace(0,list,\"%s\") to %s;\n",
		me->down_scan,name);
  }
  return(1);
}

/* ========================================================================= */

method NDprint_root( struct GRmd_env *md_env ; FILE *stream)
{
  int 			status,j,*iptr, msg;
  char                	name[MAX_CHAR];
  struct ret_struct     rts;

  as$printer_set_name( prefix = "ROOT_PRETEND", name = name);
  if (strcmp(name,"")!=0)
  {
    {
      status = om$send(msg = message ACpretend.NDgive_structure((IGRlong *)&msg, 
								&rts, md_env),
		     targetid = my_id);
      as$status(); 
      if(!(status&1))
      {
      fprintf(stream,"The graph corresponding to a macro can not be printed\n");
      fprintf(stream,"if an occurence has not been placed before\n");
       return(status);
      }
      fprintf(stream,"	rst[0].type=%#x; \n",rts.type);
      iptr=(int *) &(rts.var.dbg_st);
      for(j=0;j<(ASgive_size_st(rts.type)/4) +1;j++)
      {
        fprintf(stream,"	  rst[0].junk[%d]= %#x; \n",j,iptr[j]);
      }
      fprintf(stream,
	    "send ACpreroot.ACplace(&suc,rst) to %s;\n",name);
    }
  }
  return(1);
}

/* ========================================================================= */

method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)
{
  int 		i, status;
  IGRlong	msg;
  struct GRid 	target;
  struct GRid 	father;
  double mat1[16],mat2[16];
  short mat_typ1,mat_typ2;

  /*"down_scan %s index %d \n",  me->down_scan,me->direct_index */

  status = om$send(msg = message ACpretend.ACfind_parent(&father,
							 &mat_typ1,mat1),
		       targetid = my_id);
     as$status( action = RET_STATUS );

  if('.'==me->down_scan[0])
  {
    status = om$send(msg = message NDnode.ASreturn_go(go,&mat_typ2,mat2),
		       targetid = father.objid,
		       targetos = father.osnum);
    as$status( action = RET_STATUS ); 
  }
  else
  {
  /*"parent.return_foot >>>%s<<<\n",me->down_scan */
   status = om$send(msg = message NDmacro.ACreturn_foot
				(&msg,me->down_scan,&target,&mat_typ2,mat2),
      		     targetid = father.objid,
		     targetos = father.osnum );
   /*"msg %d status %d\n",msg,status */
   if(!msg || !(status&1))
    {
     printf("ACpretends %d %d return_go unable to find feet %s \n",
            my_id,OM_Gw_current_OS,me->down_scan);
     return(OM_W_ABORT);
    }
    *go=target; 
  }

 if(mat_typ1 == MAIDMX)
  {
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = mat2[i];
   if(mat_type != NULL) *mat_type = mat_typ2;
  }
 else if(mat_typ2 == MAIDMX)
  {
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = mat1[i];
   if(mat_type != NULL) *mat_type = mat_typ1;
  }
 else
  {
   short four = 4;
   double tmp_matrix[16];
   MAmulmx(&msg,&four,&four,&four,mat1,mat2, tmp_matrix);
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = tmp_matrix[i];
   if(mat_type != NULL) MAtypemx(&msg,tmp_matrix, mat_type);
  }

 /*^ 
 printf("go %d %d mat_type %d\n",go->objid,go->osnum,*mat_type);
 pr_mat("matrix",4,4,matrix);
 */
 return(OM_S_SUCCESS);
}

/* ========================================================================= */

method NDcopy_to_root( IGRlong *msg; int cp_type;
		       struct GRmd_env *fr_env, *to_env;
		       struct GRid *newobjid)
{
  struct ret_struct 	frts;
  int 			status,suc;
  extern GRclassid	OPP_ACpreroot_class_id;

  status = om$send(msg = message NDnode.NDgive_structure
						((IGRlong *)&suc, &frts,fr_env),
		   targetid = my_id );
  as$status(action = RET_STATUS );
	
  newobjid->osnum=to_env->md_id.osnum;

  status = om$construct( classid = OPP_ACpreroot_class_id, 
			 p_objid = &(newobjid->objid ),osnum=newobjid->osnum);
  as$status(action = RET_STATUS );

  status = om$send(msg = message ACpreroot.ACplace(&suc,&frts),
		   targetid = newobjid->objid,targetos = newobjid->osnum);  
  as$status(action = RET_STATUS );
  *msg = MSSUCC;
  return(1);
}

/* ========================================================================= */

method  ACgive_downscan(char *downscan)
{
 strcpy(downscan,me->down_scan);
 return(1);
}

/* ========================================================================= */

method ACconsume(IGRlong *msg;char *footname;int cpy_req;struct GRid *cpy_GRid;
			struct GRmd_env *md_env)
{
  int	        status;
  char          feet_bloc[path_MAX_CHAR];
  struct 	GRid father;
  struct GRmd_env local_env;
  IGRmatrix     tmp_matrix;
  short         tmp_matrix_type;
  short four;


  status = om$send(msg = message ACpretend.ACfind_parent(&father,
						   &tmp_matrix_type,tmp_matrix),
		       targetid = my_id);
     as$status( action = RET_STATUS );

  four = 4;
  MAmulmx(msg,&four,&four,&four,md_env->md_env.matrix,tmp_matrix,
                                local_env.md_env.matrix);
  MAtypemx(msg,local_env.md_env.matrix,
              &local_env.md_env.matrix_type);
  local_env.md_id = md_env->md_id;


  /*"ACconsume %s,%s \n",me->down_scan,footname */
  ACmkstring(feet_bloc,me->down_scan,footname);
    
  status = om$send(msg = message NDmacro.ACconsume 
		     ( msg,feet_bloc,cpy_req,cpy_GRid,&local_env),
        	     targetid = father.objid,
		     targetos = father.osnum );
  as$status( action = RET_STATUS ); 

  return(status);
}


/* ========================================================================= */


method ACunconsume(IGRlong *msg;char *footname)
{
  int	        status;
  char          feet_bloc[path_MAX_CHAR];
  struct 	GRid father;

  status = om$send(msg = message ACpretend.ACfind_parent(&father,NULL,NULL),
		       targetid = my_id);
     as$status( action = RET_STATUS );

  /*"ACconsume %s,%s \n",me->down_scan,footname */
  ACmkstring(feet_bloc,me->down_scan,footname);

  status = om$send(msg = message NDmacro.ACunconsume 
		     ( msg,feet_bloc),
        	     targetid = father.objid,
		     targetos = father.osnum );
  as$status( action = RET_STATUS ); 

  return(status);
}


method  ACbubble_up (long *msg;char *footname;
		     int up_index;OM_p_MESSAGE Condition,Action;
		     enum OM_e_wrt_flag delAction)
{
  int	        status;
  char          feet_bloc[path_MAX_CHAR];
  struct 	GRid father;

  status = om$send(msg = message ACpretend.ACfind_parent(&father,NULL,NULL),
		       targetid = my_id);
     as$status( action = RET_STATUS );

  /*"ACconsume %s,%s \n",me->down_scan,footname */
  ACmkstring(feet_bloc,me->down_scan,footname);

  status = om$send(msg = message NDmacro.ACbubble_up (msg,feet_bloc,
		     up_index,Condition,Action,delAction),
        	     targetid = father.objid,
		     targetos = father.osnum );
  as$status( action = RET_STATUS ); 

  return(status);
}




/* ========================================================================= */

method  DIgive_output( char *out_s)
{
 int len,msg,status;
 struct ret_struct rst;
 struct GRmd_env md_env;

 len = strlen(out_s);


 MAidmx(&msg,md_env.md_env.matrix);
 md_env.md_env.matrix_type = MAIDMX;

 md_env.md_id.osnum = OM_Gw_current_OS;
 ex$get_modid( mod_osnum = OM_Gw_current_OS,
               mod_id    = &md_env.md_id.objid);

 status = om$send(msg = message NDnode.NDgive_structure
						((IGRlong *) &msg,&rst,&md_env),
		  targetid = my_id);
 as$status(action = RET_STATUS);

 if(rst.type == double_type)
   {
    /*"val %lf\n",rst.var.root_pm_st.value*/
     strcpy(&out_s[len]," = ");
     sprintf(&out_s[len+3],"%g", rst.var.root_pm_st.value);
   }

 else if(rst.type == text_type)
   {
    /*"string %lf\n",rst.var.text_st.text_string*/
     strcpy(&out_s[len]," = \"");
     strcpy(&out_s[len+4],rst.var.text_st.text_string);
     strcat(out_s,"\"");
   }

 /*" return %s\n",out_s */
 return(OM_S_SUCCESS);
}


/* ========================================================================= */


/* Rebind the pretend when its ACcpx is deleted */

method ACrebind(int *msg;struct GRid *old_hdr)
{
 char down_scan[DI_PATH_MAX];
 char *pos,*strchr();
 struct GRid new_hdr;
 int status,succ;
 GRclassid obj_class;
 struct GRid my_grid;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

/* the pretend points to a nested construction */

/*"me->down_scan %s\n",me->down_scan*/

 pos =  strchr(me->down_scan,':');

 if(pos != NULL)
  {
   /*| Modify downscan */
   *pos = '\0';
   strcpy(down_scan,pos+1);

   /*"give_foot for %s\n",me->down_scan */
   status = om$send(msg = message NDmacro.ACgive_foot
						 (&succ,me->down_scan,&new_hdr),
		    targetid = old_hdr->objid,
		    targetos = old_hdr->osnum);
   /*"return obj %d status %d msg %d\n",new_hdr.objid,status,msg */
   as$status();
   *pos = ':';

   if((status&1) && succ) 
    {
     /*| Change pretend connection */
     status = om$send(msg = message NDnode.NDdisconnect(0,NULL),
		      targetid = my_id);
     as$status();

     status = om$send(msg = message ACpretend.ACpconnect(0,new_hdr,down_scan),
		      targetid = my_id);
     as$status();
    }
   /*"new hdr %d %d downscan %s\n",new_hdr.objid,new_hdr.osnum,down_scan */
  }

/* The pretend gives directly an element */

 else if(strcmp(me->down_scan,"."))
  {
   status = om$send(msg = message NDmacro.ACgive_foot
						 (&succ,me->down_scan,&new_hdr),
		    targetid = old_hdr->objid,
		    targetos = old_hdr->osnum);

   status = om$get_classid(objid = new_hdr.objid,
			   osnum = new_hdr.osnum,
			   p_classid = &obj_class);

  if(om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
			  subclassid = obj_class) == OM_S_SUCCESS)
    {
     strcpy(down_scan,".");
     status = om$send(msg = message ACpretend.ACpconnect(0,new_hdr,down_scan),
		      targetid = my_id);
     as$status();
    }
   else
    {
     /* Can not use make source because will reconnect to the droped ACcpx */
     if(om$is_ancestry_valid(superclassid = OPP_NDnode_class_id,
			     subclassid = obj_class) != OM_S_SUCCESS)
      {
       struct GRid tmp;
       tmp = new_hdr;
       ASmake_source_from_go(msg,&tmp,&NULL_GRID,OM_Gw_current_OS,&new_hdr);
      }

     /*"--> source %d\n",new_hdr.objid */
     status = om$send(msg = message NDnode.NDchange_connect
							  (1,&my_grid,&new_hdr),
		      p_chanselect = &ND_children);
     as$status();
    }
  }

 *msg = MSSUCC;

 return(OM_S_SUCCESS);
}

end implementation ACpretend;
