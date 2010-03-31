class implementation EMSpatfea;
#include "math.h"
#include "EMSprop.h"
#include "nddef.h"
#include "asbox.h"
#include "dm_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "msdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "parametric.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasprops.h"
#include "EMSmsgdef.h"
#include "EMSmsgnumdef.h"
#include "report.h"
#include "REassoc.h"
#include "bserr.h"
#include "EMSdpr.h"
#include "bsvalues.h"
#include "dimplcmacros.h"
#include "bsdistptpt.h"
#include <math.h>

/*
       25 Aug 94    GVK   During memcpy number of bytes copied
                          were wrong for matrix case.

*/

from EMSsurface import EMget_tree_top;
from EMSdpr     import EMdelete_feature;
from DMdim     import get_text_extents;
from EMSsfmacro import EMdelete_macro_node;
from DMroot    import return_dim_go;

extern OMuword OPP_DMroot_class_id, OPP_GAcompcurve_class_id;
extern OMuword OPP_EMSslmacro_class_id;
extern OMuword OPP_ASsource_class_id;
extern OMuword OPP_ACpretend_class_id;

#define fe_projpt(vc,s,vr,V) \
{ \
        V[0] = vc[0] + s*vr[0];\
        V[1] = vc[1] + s*vr[1];\
        V[2] = vc[2] + s*vr[2];\
}

method EMupdate_feature_pattern(IGRlong *EMmsg;
				struct GRmd_env *md_env)
{
  IGRint status;
  IGRlong long_rc ,fea_deleted;
  IGRint i,j,index,count,del_options,init_index;
  IGRint copies_to_create,old_copies;
  IGRint create_count,delete_count,r_index;
  struct GRid null_grid,my_grid,dim_par[10],new_grid,feature,macro;
  struct GRas_pattern pattern;
  struct GRptrn_matrix *matrix;
  struct GRptrn_polar *polar;
  struct GRptrn_along_ele *linear;
  struct GRid tree_top,fea_parents[MAX_FS_PARENTS],*copy_list =NULL;
  IGRint fea_count,copy_count,dim_count,copy_size = 0;
  struct ret_struct info_struct;
  OM_S_CHANSELECT *to_father,*to_children,to_notify;
  struct GRid *list,*obj_list,*n_list;
  IGRint rows,cols,changed,new_count,obj_count,new_list_count ,new_index;
  IGRint ocols,ncols,orows,nrows,d_index = 0;
  IGRint update_connect = 0, row_delete_info_update = 0 ;
int colchanged;
colchanged =1;
  status = om$send(msg = message EMSpatfea.get_feature_list(
					   EMmsg,
					   fea_parents,
					   &fea_count),
		   targetid = my_id);
  dm$status(action = RET_STATUS);
  delete_count = om$dimension_of(varray=me->deleted);

  create_count = 0 ;
  status = om$send(msg = message EMSpatfea.EMget_copy(
					EMmsg,
                                        i,
                                        (struct GRid *) NULL,
                                        &null_grid,
                                        fea_parents,
                                        fea_count,
                                        &create_count,
                                        create_count,
                                       md_env,
                                        NULL),
		   targetid = my_id);
  fe$status(action = RET_STATUS);

  switch(me->pattern_type)
  {
    case GR_ASCOPY_SINGLE:
      /* Nothing to do */
      break;
      
    case GR_ASCOPY_LINEAR:
      linear = &pattern.var.linear;
      memcpy(linear,me->info,sizeof(struct GRptrn_along_ele));
      
      status =
      om$send (msg = message NDnode.NDgive_structure(
						     EMmsg,
						     &info_struct,
						     md_env),
	       p_chanselect = &ND_father,
	       from = LINEAR_PAR_NUM_COPIES,
	       to =  LINEAR_PAR_NUM_COPIES);
      dm$status(action = RET_STATUS); 

      if(!(info_struct.type & parameter_generic))
	return(OM_E_ABORT);

      old_copies = linear->num_copies;
      linear->num_copies = (int)info_struct.var.root_pm_st.value;
     /* 
      status =
      om$send (msg = message NDnode.NDgive_structure(
						     EMmsg,
						     &info_struct,
						     md_env),
	       p_chanselect = &ND_father,
	       from = LINEAR_PAR_ROTATION,
	       to =  LINEAR_PAR_ROTATION);
      dm$status(action = RET_STATUS);

      if(!(info_struct.type & parameter_generic))
	return(OM_E_ABORT);
      
      linear->rotation = info_struct.var.root_pm_st.value;
*/
      copies_to_create = (linear->num_copies - delete_count)- old_copies;
      break;

    case GR_ASCOPY_RECTANGULAR:
      matrix = &pattern.var.matrix;
      /*TR#119419101, Purify fix, sizeof radial structure was posted on
	to matrix */

      memcpy(matrix,me->info,sizeof(struct GRptrn_matrix));
      old_copies = matrix->rows *matrix->cols - delete_count;
      orows = matrix->rows;
      ocols = matrix->cols;
      for( index = MATRIX_PAR_X_DELTA; index <= MATRIX_PAR_COLS;index++)
      {
	  status =
	  om$send (msg = message NDnode.NDgive_structure(
					 EMmsg,
					 &info_struct,
					 md_env),
		   p_chanselect = &ND_father,
		   from = index,
		   to =  index);
	  dm$status(action = RET_STATUS);

	  if(!(info_struct.type & parameter_generic))
	    return(OM_E_ABORT);

	  switch(index)
	    {
	    case  MATRIX_PAR_X_DELTA:
	      matrix->Xdelta = 
		info_struct.var.root_pm_st.value;
	      break;
	    case  MATRIX_PAR_Y_DELTA:
	      matrix->Ydelta = 
		info_struct.var.root_pm_st.value;
	      break;
	    case  MATRIX_PAR_ROWS:
	      matrix->rows = 
		(int)(float)info_struct.var.root_pm_st.value;
	      break;
	    case  MATRIX_PAR_COLS:
	      matrix->cols= 
		(int)(float) info_struct.var.root_pm_st.value;
	      break;
/*	    case  MATRIX_PAR_ROTATION:
	      matrix->rotation = 
		info_struct.var.root_pm_st.value;
	      break;
*/
	    default:
	      return(OM_E_ABORT);
	    }
	}
       copies_to_create = (matrix->cols * matrix->rows - delete_count) -
	                   old_copies;
      memcpy(me->info,matrix,sizeof(struct GRptrn_matrix));
      nrows = matrix->rows;
      ncols = matrix->cols;
      break;

    case GR_ASCOPY_POLAR:
      polar = &pattern.var.polar;
      memcpy(polar,me->info,sizeof(struct GRptrn_polar));
      old_copies = polar->num_copies*polar->num_sweeps - delete_count;
      orows = polar->num_sweeps;
      ocols = polar->num_copies;
      for( index = POLAR_PAR_SWEEP_ANGLE; index <= POLAR_PAR_NUM_COPY ;index++)
	{
	  status =
	  om$send (msg = message NDnode.NDgive_structure(
					 EMmsg,
					 &info_struct,
					 md_env),
		   p_chanselect = &ND_father,
		   from = index,
		   to =  index);
	  dm$status(action = RET_STATUS);

	  if(!(info_struct.type & parameter_generic))
	    continue;

	  switch( index)
	    {

	    case POLAR_PAR_SWEEP_ANGLE:
	      polar->sweep_angle = 
		info_struct.var.root_pm_st.value;
              break;

	    case POLAR_PAR_NUM_COPY:
	      polar->num_copies = 
		(int)info_struct.var.root_pm_st.value;
	      break;
/*
	    case POLAR_PAR_START_ANGLE:
	      polar->start_angle = 
		info_struct.var.root_pm_st.value;
root	      break;
	    case POLAR_PAR_NUM_ROWS:
	      polar->num_sweeps = 
		info_struct.var.root_pm_st.value;
	      break;

	    case POLAR_PAR_R_DELTA:
	      polar->Rdelta = 
		info_struct.var.root_pm_st.value;
	      break;

	    case POLAR_PAR_ROTATION:
	      polar->rotation = 
		info_struct.var.root_pm_st.value;
	      break;
*/
	    default:
	      printf("Pattern:Unknown Polar parent:%d\n",index);
	      break;
	    }
	}
      memcpy(me->info,polar,sizeof(struct GRptrn_polar));
      copies_to_create =(polar->num_copies*polar->num_sweeps -delete_count)-
	                 old_copies ;
      nrows = polar->num_sweeps;
      ncols = polar->num_copies;
      break;
      
    default:
#ifdef DEBUG
      printf(" Unknown type:%ld\n",me->pattern_type);
#endif 
      break;
    }
  
  copy_count = 0;
  if(copies_to_create > 0)
    { 
      copy_list= (struct GRid *)
      stackalloc( (copies_to_create) *sizeof(struct GRid) * create_count);

      copy_size = copies_to_create * create_count;
      status = om$send(msg = message EMSsurface.EMget_tree_top(
					  EMmsg,
                                          &tree_top.objid,
                                          NULL,
                                          NULL),
		       senderid = NULL_OBJID,
		       targetid = fea_parents[0].objid,
		       targetos = fea_parents[0].osnum);

      tree_top.osnum = fea_parents[0].osnum;

      for( i = 0; i < copies_to_create; i++)
	{
	  status =
	  om$send(msg = message EMSpatfea.EMget_copy(
				      EMmsg,
				      i,
				      copy_list,
				      &tree_top,
				      fea_parents,
				      fea_count,
				      &copy_count,
				      copy_size,
				      md_env,
				      NULL),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);
	}
    }
  
  status = 
  om$get_channel_count( object = me,
		       p_chanselect = &ND_children,
		       count = (OMuint *)&count);
  dm$status(action = RET_STATUS);
  list = (struct GRid *) stackalloc(( count + copy_count )* 
				    sizeof(struct GRid));
  if(!list) return(OM_E_ABORT);

  obj_list = (struct GRid *) stackalloc(( count + copy_count )* 
				    sizeof(struct GRid));
  if(!obj_list) return(OM_E_ABORT);

  n_list = (struct GRid *) stackalloc(( count + copy_count )* 
				    sizeof(struct GRid));
  if(!n_list) return(OM_E_ABORT);

  status = om$send(msg = message NDnode.NDget_objects(
				     ND_CHILDREN,
				     obj_list,
				     count,
				     NULL,
				     0,
				     count -1,
				     &obj_count),
		   targetid = my_id);
  dm$status(action = RET_STATUS);

  count = new_count = 0;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = EMSget_pattern_macro_object(&long_rc,&my_grid, md_env,&macro);
  fe$status(action = RET_STATUS);

  if(copies_to_create != 0 )
    {
      IGRint d_count,ld_count = 0 ,ld_count1 = 0 ,num_delete = 0;
      
      struct GRid *d_list;

      /* prune it */
      for(i = 0; i < obj_count; i++)
	{
	  if (!EFisAncestryValid(EMmsg,obj_list[i].objid,
				obj_list[i].osnum,
				OPP_DMroot_class_id, TRUE))
	    {
	      status = 
	      om$get_channel_count( objid = obj_list[i].objid,
				    osnum = obj_list[i].osnum,
				     p_chanselect = &ND_children,
				     count = (OMuint *)&ld_count1);
	      if(( status &1 ) && ld_count1)
		n_list[ld_count++] = obj_list[i];
	    }
	}
      
      d_count = 0;
      
      new_list_count = 0;

      del_options = EMdel_fea_DELETE_AND_SAVE|EMdel_fea_CLEANUP_DELETED|
	            EMdel_fea_DELAY_UPDATE;
      
      /* Create the new list of objects to be deleted */

      d_list = (struct GRid *)stackalloc( orows * ocols * create_count 
					 * sizeof(struct GRid));

      rows = ( orows > nrows  ? nrows:orows);
      cols = ( ocols > ncols  ? ncols:ocols);

  
      if( ncols > ocols  && nrows < orows)
	{
	  changed = orows - nrows;
	  init_index = nrows*ocols*create_count -2;
	  for( i = 0; i < changed ; i++)
	    {
	      for( j = 0; j < ocols * create_count; j++)
		{
		  init_index ++;
		  
		  EFcheck_deleted_fea(&fea_deleted,&delete_count,me->deleted,
				      init_index,&r_index);
		  if(fea_deleted)
		    {
		     /* Delete the  and continue */
		      me->deleted[r_index] = -1;
		      continue;
		    }
		  d_list[d_count++]= n_list[init_index];	  
		}
	    }
	  row_delete_info_update = 1;
	}
      for ( i = 0; i < rows; i++)
	{
	  for( j = 0; j < cols; j++)
	    {
	      if( i==0 && j== 0 ) continue;
	      index = (i*ocols - 1 +j )*create_count ;
	      EFfepat_add_copies (list,n_list,&count,
				  new_list_count*create_count ,
				  create_count);
	      new_list_count++;
	    }

	  if(ncols > ocols)
	    {
	      changed  = ncols - ocols;
	      for( j = 0; j < changed; j++)
		{
		  if( !update_connect && 
		     (!copy_list || new_count >= copy_size ))
		    {
		      copy_list = d_list;
		      update_connect = TRUE;
		      new_count = 0;
		    }
		  EFfepat_add_copies(list,copy_list,&count,
				     new_count,create_count);
		  new_count +=create_count;
		  if(update_connect)
		    d_index++;
		}
	    }
	  else 
	    {
	      /* Mark them for delete */
	      changed  = ocols  - ncols;
colchanged = changed;
	      for( j = 0; j < changed  ;j++)
		{
		  int d_fea = 0;

		  index = (i*ocols - 1 + cols +j )*create_count + d_fea;
		  new_index = index + create_count;
		  for(;index <  new_index ;index++)
		    {
		      EFcheck_deleted_fea(&fea_deleted,
					  &delete_count,
					  me->deleted,index,&r_index);
		      if(fea_deleted)
			{
			  d_fea ++;
			  me->deleted[r_index] = -1;
			  continue;			  
			}
		      d_list[d_count++] = n_list[index];
		    }
		  new_list_count++;
		}
	    }
	}
      if(nrows >orows)
	{
	  changed = nrows - orows;
	  for( j = 0;(j < changed * ncols); j++)
	    {	      
	      if( !update_connect && 
		 (!copy_list || new_count >= copy_size ))
		{
		  copy_list = d_list;
		  update_connect = TRUE;
		  new_count = d_index;
		}
	      EFfepat_add_copies(list,copy_list,&count,
				 new_count,create_count);
	      new_count +=create_count;
	      if(update_connect)
		d_index++;
	    }
/*
	  if( j != changed * ncols || new_count != copy_count)
	    return(OM_E_ABORT);
*/
	}
      else
	{
	  if(!row_delete_info_update)
    	{
	      changed = orows - nrows;
	      /* Mark all these features for delete */
	      init_index = nrows*ocols*create_count -2;
	      for( i = 0; i < changed ; i++)
		{
		  for( j = 0; j < ocols * create_count; j++)
		    {
		      init_index ++;
		      
 EFcheck_deleted_fea(&fea_deleted,&delete_count,me->deleted, init_index,&r_index);
		      if(fea_deleted)
			{
			  /* Delete the  and continue */
			  me->deleted[r_index] = -1;
			  continue;
			}
		      d_list[d_count++]= n_list[init_index];
		    }
		}
	    }
	}
      
      if(d_count)
	{
	  for( i = d_index; i <d_count; i++)
	    {

              /***check put for TR # 119601719 - Sp.Balamurugan***/
              // added d_count check for TR# 119702125 - jeff 

	      if (EFisAncestryValid(EMmsg,d_list[i].objid,
				           d_list[i].osnum,
           OPP_GAcompcurve_class_id, TRUE) && (fabs(d_count/colchanged) == 2))
             {
                continue;
             }
           // this is check for a problem in create pattern
           // with a non-assoc profile being a parent 
           // Jeff
 
              if (EFisAncestryValid(EMmsg,d_list[i].objid,
                                           d_list[i].osnum,
             OPP_ASsource_class_id, TRUE) || (fabs(d_count/colchanged) == 2))
             {
                continue;
             } 
             if (EFisAncestryValid(EMmsg,d_list[i].objid,
                                           d_list[i].osnum,
              OPP_ACpretend_class_id, TRUE) || (fabs(d_count/colchanged) == 2))
             {
                continue;
             }
	      status = 
	      om$get_objid_at_index( objid = d_list[i].objid,
				    osnum = d_list[i].osnum,
				    p_chanselect = &ND_children,
				    index = 0,
				    objidaddr =&feature.objid,
				    osnumaddr =&feature.osnum);
	      fe$status(action = RET_STATUS);
	      
              status = 
	      om$send( msg = message EMSsfmacro.EMdelete_macro_node(
						      &long_rc,
						      &feature,
						      md_env),
		      targetid = macro.objid,
		      targetos = macro.osnum);
	      fe$status(action = RET_STATUS);
	    }
	}
    }
  else
    {
      int td_count = 0;
      index = 0;
      for(i = 0; i < obj_count; i++)
	{
	  if (!EFisAncestryValid(EMmsg,obj_list[i].objid,
				obj_list[i].osnum,
				OPP_DMroot_class_id, TRUE))
	    {
	      status = 
	      om$get_channel_count( objid = obj_list[i].objid,
				    osnum = obj_list[i].osnum,
				     p_chanselect = &ND_children,
				     count = (OMuint *)&td_count);
	      if(( status &1 ) && td_count)
		list[count++] = obj_list[i];
	    }
	} 
      
    }

  dim_count = index = 0;

  for(i = 0; i < obj_count; i++)
    {
      if (EFisAncestryValid(EMmsg,obj_list[i].objid,
			    obj_list[i].osnum,
			    OPP_DMroot_class_id, TRUE))
	dim_par[dim_count++] = obj_list[i];

    } 

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  null_grid.objid = NULL_OBJID;

  status = NDget_channel(&to_father,&to_children);

  status = om$construct( p_objid = &new_grid.objid,
			classid = OPP_NDnodein_class_id);
  dm$status(action = RET_STATUS);
  new_grid.osnum = OM_Gw_current_OS;
  
  status = om$send(msg = message Root.move_chan(*to_children,
						my_id,OM_Gw_current_OS,
						*to_children),
		   targetid = new_grid.objid);

  
  for( i = 0; i < count; i++)
    {  
      status = om$send(msg = message NDnode.NDconnect(
				       1,
				       &my_grid,
			               null_grid,
			               ND_NEW),
		       targetid = list[i].objid,
		       targetos = list[i].osnum);
      if(!(status&1))
	{
	 om$send( msg = message Root.move_chan (*to_children,
					     new_grid.objid,OM_Gw_current_OS,
					     *to_children),
			     targetid = my_id);
	  return(OM_E_ABORT);
	}
      
    }

  for( i = 0; i < dim_count; i++)
    {
      
      status = om$send(msg = message NDnode.NDchange_connect(
				       1,
			               &new_grid,
			               &my_grid),
		       targetid = dim_par[i].objid,
		       targetos = dim_par[i].osnum);
      dm$status(action = RET_STATUS);
      
    }

  status =
  om$send( msg = message NDnode.NDnotify_disconnect(new_grid),
                   senderid = new_grid.objid,
                   p_chanselect = to_children);
  status = 
  om$send( msg = message Root.delete(1),
	  targetid = new_grid.objid);
  dm$status(action = RET_STATUS);

  /* Compress deleted list */

  {
    IGRint del_count = 0,new_del_count = 0;
    IGRshort *del_lis ;

    del_count = om$dimension_of(varray = me->deleted);
    del_lis = (short *)stackalloc(del_count *sizeof(IGRshort));
    for( i = 0; i < del_count; i++)
      if(me->deleted[i] != -1)
	del_lis[new_del_count++] = me->deleted[i];
    status = om$vla_set_dimension(varray= me->deleted,
				  size = new_del_count);
    fe$status(action = RET_STATUS);
    memcpy(me->deleted,del_lis,new_del_count*sizeof(IGRshort));
  }
  return(OM_S_SUCCESS);
}

method DMgive_structure(IGRint *msg;
			IGRint type;
			IGRboolean inq0_set1;
			struct dim_ret_struct *str;
			struct GRmd_env *md_env)
{

  IGRint status ,rc;
  IGRlong long_rc;
  OM_S_OBJECT_LINKAGE *list = NULL;
  IGRint i,l_count,index,dim_index;
  struct GRid send_grid,assoc_id,param_id,newgrid;
  IGRmatrix plane,matrix;
  short matrix_type;
  struct GRas_pattern pattern;
  IGRvector new_vec,center,xdir,ydir;
  struct ret_struct info_struct;
  IGRdouble dir,box[12],blen;

  if( inq0_set1 == 1)      return(0);

  send_grid.objid = sender_id;
  send_grid.osnum = sender_os;
  assoc_id.objid = my_id;
  assoc_id.osnum = OM_Gw_current_OS;

  status =
  EFget_active_parameter(&assoc_id,&send_grid,&param_id);
  dm$status(action= RET_STATUS);

  status = om$send(msg = message EMSpatfea.EMget_plane_info(
					&long_rc,
					NULL,
					plane,
					md_env),
		   targetid = my_id); 
  dm$status(action = RET_STATUS);


  status = om$get_channel_count(object = me,
				p_chanselect = &ND_father,
				count = (OMuint *)&l_count);
  dm$status(action = RET_STATUS);

  list = (OM_S_OBJECT_LINKAGE *)malloc( l_count * sizeof(OM_S_OBJECT_LINKAGE));

  status =
  om$get_channel_objects( object = me,
			  p_chanselect = &ND_father,
			  list = list,
			  size = l_count,
			  count = (OMuint *)&l_count);
  dm$status(action = RET_STATUS);
		
  for( i = 0; i < l_count; i++)
    {
      if( list[i].S_objid  ==  param_id.objid)
	{
	  index = i;
	  break;
	}
    }

  if( index == l_count )
    return(OM_E_ABORT);

  status = om$send( msg = message EMSpatfea.EMget_pattern_info(
					   &long_rc,
					   &pattern,
					   md_env),
		   targetid = my_id);
  dm$status(action = RET_STATUS);

  switch(me->pattern_type)
    {
    case GR_ASCOPY_SINGLE:
      break;

    case GR_ASCOPY_LINEAR:
      break;

    case GR_ASCOPY_RECTANGULAR:
      if( index == MATRIX_PAR_X_DELTA )
	{
	  str->type = DMkeyseg;

	  dir = (me->fea_props & REF_DIR_X_NEG ? -1 : 1);
	  for(i = 0; i <3;i++)
	    {
	      str->var.dm_keyseg.line[i] = plane[3 + 4*i];
	      str->var.dm_keyseg.line[3+i] = 
		plane[3 + 4*i] + plane[i] * dir * pattern.var.matrix.Xdelta;
	    }
	}
      else if( index == MATRIX_PAR_Y_DELTA)
	{
	  str->type = DMkeyseg;

	  dir = (me->fea_props & REF_DIR_Y_NEG ? -1 : 1);

	  for(i = 0; i <3;i++)
	    {
	      str->var.dm_keyseg.line[i] = plane[3 + 4*i];
	      str->var.dm_keyseg.line[3+i] = 
		plane[3 + 4*i] + plane[4+i]*dir* pattern.var.matrix.Ydelta;
	    }
		 
	}
      else if( index ==  MATRIX_PAR_ROWS || index == MATRIX_PAR_COLS)
	{
	  /* Get the dimension id corresponding to deltax or deltay */
	  
	  dim_index = ( index == MATRIX_PAR_ROWS  ?
		        MATRIX_PAR_X_DELTA : MATRIX_PAR_Y_DELTA);
	  status = om$get_objid_at_index(objid = list[dim_index].S_objid,
					 osnum = list[dim_index].osnum,
					 p_chanselect = &AS_to_comp,
					 index = 0,
					 objidaddr = &newgrid.objid,
					 osnumaddr = &newgrid.osnum);
	  fe$status(action = RET_STATUS);

	  if (!EFisAncestryValid(msg,newgrid.objid,
			    newgrid.osnum,
			    OPP_DMdim_class_id, FALSE))
	    {
	      fe$status(action= RET_VALUE,value=OM_E_ABORT);
	    }
	  status = om$send( msg = message  DMdim.get_text_extents(
						   &rc,
						   box,
						   md_env),
			   targetid = newgrid.objid,
			   targetos = newgrid.osnum);
	  fe$status(action = RET_STATUS);
	  str->type = DMptdist;
	  str->var.dm_ptdist.u_par = 0.0;

	  BSmkvec( &long_rc, xdir, box , &box[3]);
	  BSnorvec(&long_rc, xdir);
	  BSmkvec( &long_rc, ydir, box , &box[9]);
	  BSnorvec(&long_rc, ydir);
	  blen = BSdistptpt(&long_rc,box,&box[9]);

	  for( i = 0; i< 3; i++)
	    {
	      if( index == MATRIX_PAR_ROWS)
		str->var.dm_ptdist.point[i] = (box[6+i] + box[9+i])/2.0;
	      else
		str->var.dm_ptdist.point[i] = (box[i] + box[9+i])/2.0;
	      str->var.dm_ptdist.vec[i] = 0.0;
	    }
	  
	  if( index == MATRIX_PAR_ROWS)
	    {
	      fe_projpt(str->var.dm_ptdist.point,
			blen/4,
			ydir,
			str->var.dm_ptdist.point);

	      fe_projpt(str->var.dm_ptdist.point,
			-blen*.75,
			xdir,
			str->var.dm_ptdist.point);
	    }
	  else
	    {
	      fe_projpt(str->var.dm_ptdist.point,
			-blen/4,
			ydir,
			str->var.dm_ptdist.point);

	      fe_projpt(str->var.dm_ptdist.point,
			-blen,
			xdir,
			str->var.dm_ptdist.point);
	    }

	}
      break;
    case GR_ASCOPY_POLAR:
      switch(index)
	{
	case POLAR_PAR_SWEEP_ANGLE:
	  str->type = DMkeyseg;

	  center[0] = plane[3];
	  center[1] = plane[7];
	  center[2] = plane[11];

	  status = 
	  om$send( msg = message NDnode.ASreturn_go(
	       			     &param_id,
	       			     &matrix_type,
	       			     matrix),       
		  p_chanselect = &ND_father,
		  from = POLAR_PAR_CENTER,
		  to = POLAR_PAR_CENTER);
	  fe$status(action = RET_STATUS);

	  as$any_give_structure(go_grid = param_id,
				inst = &info_struct,
				mod_env = md_env);

	  BSproj1(&long_rc,info_struct.var.point_st.pt,&plane[8],center,
		  str->var.dm_keyseg.line);

	  BSmkvec(&long_rc,new_vec,str->var.dm_keyseg.line,center);
	  BSnorvec(&long_rc,new_vec);

	  dir = (me->fea_props & REF_DIR_X_NEG ? -1 : 1);
	  if(type == ORIG_INFO)
	    {
/*
	      MATH_rotate_vector(&long_rc,
				 new_vec,
				 pattern.var.polar.sweep_angle * 1.74532925199432958e-2,
				 plane,
				 new_vec);
*/
	      for( i =0; i< 3; i++)
		str->var.dm_keyseg.line[3+i] =
		  str->var.dm_keyseg.line[i] + new_vec[i] * pattern.var.polar.radius;
	    }
	  else
	    {
	      MATH_rotate_vector(&long_rc,
				 new_vec,
				 pattern.var.polar.sweep_angle *dir* 1.74532925199432958e-2,
				 plane,
				 new_vec);
	      
	      for( i =0; i< 3; i++)
		str->var.dm_keyseg.line[3+i] =
		str->var.dm_keyseg.line[i]+ new_vec[i] * pattern.var.polar.radius;
	    }
	  break;

	case POLAR_PAR_NUM_COPY:
	  status = om$get_objid_at_index(
		      objid = list[POLAR_PAR_SWEEP_ANGLE].S_objid,
		      osnum = list[POLAR_PAR_SWEEP_ANGLE].osnum,
		      p_chanselect = &AS_to_comp,
		      index = 0,
		      objidaddr = &newgrid.objid,
		      osnumaddr = &newgrid.osnum);
	  fe$status(action = RET_STATUS);

	  if (!EFisAncestryValid(msg,newgrid.objid,
			    newgrid.osnum,
			    OPP_DMdim_class_id, FALSE))
	    {
	      fe$status(action = RET_VALUE,value= OM_E_ABORT);
	    }
	  status = om$send( msg = message  DMdim.get_text_extents(
						   &rc,
						   box,
						   md_env),
			   targetid = newgrid.objid,
			   targetos = newgrid.osnum);
	  fe$status(action = RET_STATUS);
	  str->type = DMptdist;
	  str->var.dm_ptdist.u_par = 0.0;

	  BSmkvec( &long_rc, xdir, box , &box[3]);
	  BSnorvec(&long_rc, xdir);
	  BSmkvec( &long_rc, ydir, box , &box[9]);
	  BSnorvec(&long_rc, ydir);
	  blen = BSdistptpt(&long_rc,box,&box[9]);

	  for( i = 0; i< 3; i++)
	    {
	      str->var.dm_ptdist.point[i] = (box[i] + box[9+i])/2.0;
	      str->var.dm_ptdist.vec[i] = 0.0;
	    }
	  fe_projpt(str->var.dm_ptdist.point,
		    -blen/4,
		    ydir,
		    str->var.dm_ptdist.point);

	  fe_projpt(str->var.dm_ptdist.point,
		    -blen,
		    xdir,
		    str->var.dm_ptdist.point);
	  break;
    	default:
	  printf(" Unknown DMgive structure index:%d\n",index);
	  break;
	}
      break;
    default:
      printf(" EMSpatfea:DMgive_structure: Unknown Case:%d\n",me->pattern_type);
      break;
      
    }
  if( list) free(list);
  return(OM_S_SUCCESS);
}

method EMplace_dimensions(
  IGRlong * EMmsg;
  IGRint num_parents;
  struct GRid    *parents;
  IGRint *num_dim_obj;
  struct GRid  *dim_grid;
  struct GRmd_env *md_env)
{
  IGRint  status ,rc;
  IGRint sector,trak_dir,i;
  IGRlong long_rc;
  struct GRptrn_polar *polar;
  IGRint index;
  struct GRid my_grid,go_grid;
  IGRdouble dummypt[3],break_pt[3];
  IGRdouble angle,origin[3];
  struct GRas_pattern pattern;
  IGRmatrix plane;
  IGRchar pat_str[80];

  IGRdouble box[12],blen;
  IGRvector xdir,ydir;

  /* Same object will act as the DMsrc object */
  /* Reference plane will act as the source plane */


  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  dummypt[0] = dummypt[1] = dummypt[2]= 0.0;

  status =
  om$send( msg = message EMSpatfea.EMget_plane_info(
			    EMmsg,
			    parents,
	   		    plane,
			    md_env),
	  targetid = my_id);
  fe$status(action = RET_STATUS);

  status =
  om$send( msg = message EMSpatfea.EMget_pattern_info(
			      EMmsg,
			      &pattern,
			      md_env),
	  targetid = my_id);
  fe$status(action = RET_STATUS);
  *num_dim_obj = 0;

  switch (me->pattern_type)
    {
    case GR_ASCOPY_SINGLE:
      break;		       

    case GR_ASCOPY_LINEAR:
      break;
		       
    case GR_ASCOPY_RECTANGULAR:

      /* Set the trak direction depending on the fea_props */

      dim_grid[0].objid = NULL_OBJID;

      trak_dir = (me->fea_props & REF_DIR_Y_NEG ? 0:1);

      if(pattern.var.matrix.rows >1)
	{
	  dm$place_sglpara ( orig_grid  = &my_grid,
			    orig_pt    = dummypt,
			    plane_grid = &parents[0],
			    trak_dir   = trak_dir,
			    dim_grid   = &dim_grid[0],
			    owner = &parents[MATRIX_PAR_X_DELTA]);
	  (*num_dim_obj) += 1;
	}

      dim_grid[1].objid = NULL_OBJID;
      trak_dir = (me->fea_props & REF_DIR_X_NEG ? 1:0);

      if(pattern.var.matrix.cols >1)
	{
	dm$place_sglpara ( orig_grid  = &my_grid,
			 orig_pt    = dummypt,
			 plane_grid = &parents[0],
			 trak_dir   = trak_dir,
			 dim_grid   = &dim_grid[1],
			 owner = &parents[MATRIX_PAR_Y_DELTA]);
	  (*num_dim_obj) += 1;
      }

      angle = M_PI/4.0;

      for( i = 0; i < 3; i++)
	{
	  break_pt[i] = plane[3+4*i] + plane[4+i] * cos(angle) +
	                plane[i]*sin(angle);
	  origin[i] = plane[3+4*i];
	}

      if(pattern.var.matrix.rows >1)
	{
	  EFget_dimension_source_point(&long_rc,MATRIX_PAR_ROWS,
				       origin, dim_grid[0],md_env);
	  status = 
	  om$send(msg = message DMroot.return_dim_go(
				   &rc,
                                   0,
                                   FALSE,
                                   -1,
                                   md_env,
                                   &go_grid),
		  targetid = dim_grid[0].objid,
		  targetos = dim_grid[0].osnum);
	  fe$status(action = RET_STATUS);

	  strcpy(pat_str,"%ld X ");
	  dm$place_text_with_leader(attach_ele = &go_grid,
                                attach_pt = origin,
                                num_brkpt = 0,
                                text_length = strlen(pat_str),
                                text_string = pat_str,
                                expr_count = 1,
                                expr_list = &parents[MATRIX_PAR_ROWS],
                                plane_grid = &parents[0],
                                owner = &parents[MATRIX_PAR_ROWS], 
                                dim_grid = &dim_grid[2],
				value_type = DIM_ANGLE); /* DON'T SCALE VALUE*/
	  (*num_dim_obj) += 1;
	}

      if(pattern.var.matrix.cols >1)
	{

	  EFget_dimension_source_point(&long_rc,MATRIX_PAR_COLS,
				       origin, dim_grid[1],md_env);
	  status = 
	  om$send(msg = message DMroot.return_dim_go(
				   &rc,
                                   0,
                                   FALSE,
                                   -1,
                                   md_env,
                                   &go_grid),
		  targetid = dim_grid[1].objid,
		  targetos = dim_grid[1].osnum);
	  fe$status(action = RET_STATUS);

	  strcpy(pat_str,"%ld X ");
	  dm$place_text_with_leader(attach_ele = &go_grid,
                                attach_pt = origin,
                                num_brkpt = 0,
                                text_length = strlen(pat_str),
                                text_string = pat_str,
                                expr_count = 1,
                                expr_list = &parents[MATRIX_PAR_COLS],
                                plane_grid = &parents[0],
				owner = &parents[MATRIX_PAR_COLS], 
			        dim_grid = &dim_grid[3],
				value_type = DIM_ANGLE);/* DONT SCALE VALUE */
	  (*num_dim_obj) += 1;
	}
      break;
      
    case GR_ASCOPY_POLAR:

      polar = &pattern.var.polar;
      memcpy( polar,me->info,sizeof(struct GRptrn_polar));


      if(!(me->fea_props & BASE_FEATURE_INCLUDED))
      {
	  /* Needs to construct the dimension controling
	     the start angle at the index 0 */

	  if( polar->start_angle < 0.0 )
	    polar->start_angle +=360.0;

	  if( polar->start_angle < 90.0 )
	    sector = 0;
	  else if(polar->start_angle > 90.0 &&
		  polar->start_angle < 180.0)
	    sector = 3;
	  else if(polar->start_angle > 180.0 &&
		  polar->start_angle < 270.0 )
	    sector = 6;
	  else if(polar->start_angle > 270.0 &&
		  polar->start_angle < 360.0)
	    sector = 5;

	  status = 
	  dm$place_angular( 
			   orig_grid = &my_grid,
			   orig_pt = dummypt,
			   meas_grid = &my_grid,
			   meas_pt  = dummypt,
			   plane_grid = &parents[FEATURE_PAR_REF_PLANE],
			   sector  = sector,
			   mask = -1,
			   owner = &parents[POLAR_PAR_START_ANGLE],
			   dim_grid = &dim_grid[0]);
	  dm$status(action = RET_STATUS);
	}
      if(polar->start_angle > 0.0)
	polar->start_angle += 360.0;

 	sector = (me->fea_props & REF_DIR_X_NEG ? 1:0);
      index = ((me->fea_props & BASE_FEATURE_INCLUDED) ? 0:1);
      status = 
      dm$place_angular( 
		       orig_grid = &my_grid,
		       orig_pt = dummypt,
		       meas_grid = &my_grid,
		       meas_pt  = dummypt,
		       plane_grid = &parents[FEATURE_PAR_REF_PLANE],
		       sector  = sector,
		       owner = &parents[POLAR_PAR_SWEEP_ANGLE],
		       dim_grid = &dim_grid[index]);
	  dm$status(action = RET_STATUS);
      (*num_dim_obj) += 1;

      /* Construct the  delta dimensions */
      
      strcpy(pat_str,"%ld X ");
	  status = om$send( msg = message  DMdim.get_text_extents(
						   &rc,
						   box,
						   md_env),
			   targetid = dim_grid[0].objid,
			   targetos = dim_grid[0].osnum);
	  fe$status(action = RET_STATUS);

	  BSmkvec( &long_rc, xdir, box , &box[3]);
	  BSnorvec(&long_rc, xdir);
	  BSmkvec( &long_rc, ydir, box , &box[9]);
	  BSnorvec(&long_rc, ydir);
	  blen = BSdistptpt(&long_rc,box,&box[9]);

	  for( i = 0; i< 3; i++)
	    {
	      origin[i] = (box[i] + box[9+i])/2.0;
	    }
	  fe_projpt(origin, -blen/4, ydir, origin);

	  fe_projpt(origin, -blen, xdir, origin);

      status = 
      om$send(msg = message DMroot.return_dim_go(
				   &rc,
                                   0,
                                   FALSE,
                                   -1,
                                   md_env,
                                   &go_grid),
                        targetid = dim_grid[0].objid,
                        targetos = dim_grid[0].osnum);
                fe$status(action = RET_STATUS);

      dm$place_text_with_leader(attach_ele = &go_grid,
                                attach_pt = origin,
                                num_brkpt = 0,
                                text_length = strlen(pat_str),
                                text_string = pat_str,
                                expr_count = 1,
                                expr_list = &parents[POLAR_PAR_NUM_COPY],
                                plane_grid = &parents[0],
                                owner = &parents[POLAR_PAR_NUM_COPY], 
                                dim_grid = &dim_grid[1],
				value_type = DIM_ANGLE); /* DON'T SCALE VALUE*/

      (*num_dim_obj) += 1;
      
      break;
		       
    default:
      break;
  }
    
  return (OM_S_SUCCESS);
}

EFget_dimension_source_point(msg, index, point, newgrid, md_env)
IGRlong *msg;
IGRint index;
IGRdouble *point;
struct GRid newgrid;
struct GRmd_env *md_env;
{
  IGRint status, rc, i;
  IGRlong long_rc;
  IGRvector new_vec,center,xdir,ydir;
  IGRdouble box[12],blen,dir;
  
  status = 
  om$send( msg = message  DMdim.get_text_extents(
					 &rc,
				          box,
					  md_env),
	  senderid = NULL_OBJID,
	  targetid = newgrid.objid,
	  targetos = newgrid.osnum);
  fe$status(action = RET_STATUS);

  BSmkvec( &long_rc, xdir, box , &box[3]);
  BSnorvec(&long_rc, xdir);
  BSmkvec( &long_rc, ydir, box , &box[9]);
  BSnorvec(&long_rc, ydir);
  blen = BSdistptpt(&long_rc,box,&box[9]);

  for( i = 0; i< 3; i++)
    {
      if( index == MATRIX_PAR_ROWS)
	point[i] = (box[6+i] + box[9+i])/2.0;
      else
	point[i] = (box[i] + box[9+i])/2.0;
    }
	  
  if( index == MATRIX_PAR_ROWS)
    {
      fe_projpt(point, blen/4, ydir, point);

      fe_projpt(point, -blen*.75, xdir, point);
    }
  else
    {
      fe_projpt(point, -blen/4, ydir, point);

      fe_projpt(point, -blen, xdir, point);
    }
}

method NDselect_copy(long *msg;
                     int select_type;
		     struct GRid *selected_obj;
                     int *info;
		     int selected_size, 
                     *selected_nb)
/* ********************************************************************
Description
This method adds all the roots of the pattern into the list that is
getting copied.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure

History
*********************************************************************** */
{
 IGRlong status,msg_loc;
 struct GRid  my_grid;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;
 *selected_nb = 0;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

/*
 * Add myself.
 */
 *selected_nb = 0;

 if (selected_size > (*selected_nb))
 {
  selected_obj[*selected_nb].objid = my_id;
  selected_obj[*selected_nb].osnum = OM_Gw_current_OS;
 }
 ++(*selected_nb);

 EFadd_to_copy_list(msg, my_grid, info, selected_size, selected_nb,
                    select_type, selected_obj);
 EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*msg, status, "In EMSpatfea: NDselect_copy method error");
 return (status);
}

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

{
 IGRint loc_msg;
 IGRlong status;

 loc_msg = MSSUCC;
 status = OM_S_SUCCESS;

 *msg = ND_DROP_MAC;
 return (status);
}

end implementation EMSpatfea;
