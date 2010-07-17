/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/fun.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: fun.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/12  23:17:34  pinnacle
 * Loading RT functions
 *
 *
 * History:
 *	01/12/98	Onay	Integration date.
 *
 *************************************************************************/

#include <stdio.h>
#include "GM.h"
#include "GMndg.h"
#include "AS_status.h"
#include "nddef.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "GMerrordef.h"
#include "ACrg_collect.h"
#include "VRsize.h"
#include "rtiges.h"
#include "AS_status.h"
#include "vrmacros.h"
#include "vrparameters.h"
#include "OMlimits.h"

extern int RT_init_read();

void fun()
{
	int sts, ret, ii;
	int batch;
	char* fname;
	char* dbname;
	char* dbuser;
	char* dbpasswd;
	int units, jj;
	int nsy; char** syida;
	int i, count, part_type, PiLinCount = 0;
	part_info *partinfo = NULL;
	void *part_data = NULL;
	/*int *csg_types, num_csgs;
	void **csgs;*/
	struct GRid part_id, comp_id;
	pipe_attr *PipeAttr;
	piping_component_attr *PiCompAttr;

	char system[30], pipeline[30], filename[OM_K_MAXOSNAME_LEN];
	connect_pt_id cpi;
	short bFlag = FALSE;

	/* can be a ptr to LinPiInfo, BtPiInfo or CmpInfo */

	pipeline_info pipeline_info_buff, *buff_ptr, **p_buff_ptr;
	pipe_run_info piperun_info_buff, *rbuff_ptr, **p_rbuff_ptr;

	buff_ptr = &pipeline_info_buff;
        p_buff_ptr = &buff_ptr;

	rbuff_ptr = &piperun_info_buff;
        p_rbuff_ptr = &rbuff_ptr;

	part_id.objid = NULL_OBJID;
	comp_id.objid = NULL_OBJID;

	strcpy( system, "" );
	strcpy( pipeline, "" );
	cpi.comp_id.objid = NULL_OBJID;

	batch = 0;
	fname = NULL;
	dbname = NULL;
	dbuser = NULL;
	dbpasswd = NULL;
	units = 1;

	sts = RT_init_read(batch,fname,dbname,dbuser,dbpasswd,units);

	if( sts == RTERR_DB_LOGIN )
	 printf( "error status is RTERR_DB_LOGIN\n" );

	if ( sts != RTSUCC ) goto end;

	sts = RT_get_piping_systems(&nsy,&syida);

	fprintf(stderr,"\nnsy = %d\n",nsy);
	for( i = 0; i < nsy; i = i+1 )
		fprintf(stderr,"syida[%d] = \"%s\"\n",i,syida[i]);

	sts = RT_get_pipelines( syida[0],  &PiLinCount, &p_buff_ptr );

        printf( "Number of PipeLines in %s is %d\n", syida[0], PiLinCount );
	for( jj=0; jj < PiLinCount; ++ jj )
	 printf( "PipeLineId[%d]:%s\n", jj, p_buff_ptr[jj]->pipeline_id );

	/* for each PipeLine */
        for( jj=0; jj < PiLinCount; ++jj )
	{
	  printf( "\nStart PipeLine:%2d\n", jj+1 );
	sts = RT_get_pipe_runs( syida[0], p_buff_ptr[jj]->pipeline_id,
				&count, &p_rbuff_ptr );
	printf( "Pipe Run Count:%d\n", count );

	 printf( " Run  Start        End        Spec\n" );
	for( i=0; i < count; ++i )
	 printf( "%2d)  %3d %3d     %3d %3d         %s\n",
		  i+1,
		  p_rbuff_ptr[i]->run_start.comp_id.objid,
		  p_rbuff_ptr[i]->run_start.conn_pt_id,
		  p_rbuff_ptr[i]->run_end.comp_id.objid,
		  p_rbuff_ptr[i]->run_end.conn_pt_id,
		  p_rbuff_ptr[i]->pipe_spec );


	ret = RTSUCC;

	printf( "syida[0]:%s  [0]->pipeline_id:%s  [0]->run_start:%d %d\n",
	         syida[0], p_buff_ptr[jj]->pipeline_id,
		 p_rbuff_ptr[0]->run_start.comp_id.objid,
		 p_rbuff_ptr[0]->run_start.conn_pt_id );

	/* for each pipe run */
	for( i=0; i < count; ++i )
	{
          printf( "Start run %2d) - %d %d\n",
		   i+1,
		   p_rbuff_ptr[i]->run_start.comp_id.objid,
		   p_rbuff_ptr[i]->run_start.conn_pt_id );

	  strcpy( system, syida[0] );
	  strcpy( pipeline, p_buff_ptr[jj]->pipeline_id );

	  cpi = p_rbuff_ptr[i]->run_start;

          /*printf( "fun.C - pipeline:%s  sys:%s\n", pipeline, system );*/

          do
	  {
 	   ret = RT_get_pipe_run_part(system, pipeline, &cpi,
				     &part_type, &part_data, &partinfo );

	   if( ret == RTSUCC )
	   {
	     bFlag = TRUE;

	     printf( "part_type:%d\n", part_type );

	     if( part_data != NULL )
	     {
	       switch( part_type )
	       {
	         case PART_TYPE_LINEAR_PIPE_SECTION:
	          printf( "start-coord:%lf  %lf  %lf\n",
		          ((linear_pipe_info *)(part_data))->start_coord[0],
		          ((linear_pipe_info *)(part_data))->start_coord[1],
		          ((linear_pipe_info *)(part_data))->start_coord[2] );
	          printf( "end-coord  :%lf  %lf  %lf\n",
		          ((linear_pipe_info *)(part_data))->end_coord[0],
		          ((linear_pipe_info *)(part_data))->end_coord[1],
		          ((linear_pipe_info *)(part_data))->end_coord[2] );

		  printf( "n_branch_ports:%d\n",
			  ((linear_pipe_info *)(part_data))->n_branch_ports );

		  if( ((linear_pipe_info *)(part_data))->n_branch_ports )
		  {
		    printf( "BranchCoord[0]:%lf\n",
		      ((linear_pipe_info *)(part_data))-> branch_coords[0] );

		    printf( "BranchCoord[1]:%lf\n",
		      ((linear_pipe_info *)(part_data))-> branch_coords[1] );

		    printf( "BranchCoord[2]:%lf\n",
		      ((linear_pipe_info *)(part_data))-> branch_coords[2] );


		    printf( "\nBranchMatrix[0].x[0]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].x[0] );

		    printf( "BranchMatrix[0].x[1]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].x[1] );

		    printf( "BranchMatrix[0].x[2]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].x[2] );


		    printf( "\nBranchMatrix[0].y[0]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].y[0] );

		    printf( "BranchMatrix[0].y[1]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].y[1] );

		    printf( "BranchMatrix[0].y[2]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].y[2] );


		    printf( "\nBranchMatrix[0].z[0]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].z[0] );

		    printf( "BranchMatrix[0].z[1]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].z[1] );

		    printf( "BranchMatrix[0].z[2]:%lf\n",
		     ((linear_pipe_info *)(part_data))->branch_matrix[0].z[2] );


		    printf( "\nBranchMatrix[0].translate[0]:%lf\n",
	     ((linear_pipe_info *)(part_data))->branch_matrix[0].translate[0] );

		    printf( "BranchMatrix[0].translate[1]:%lf\n",
	     ((linear_pipe_info *)(part_data))->branch_matrix[0].translate[1] );

		    printf( "BranchMatrix[0].translate[2]:%lf\n",
	     ((linear_pipe_info *)(part_data))->branch_matrix[0].translate[2] );

		  }

		  sts = RT_get_pipe_attributes(
			 &(((part_info *)(partinfo))->part_id), &PipeAttr );
	          break;

	         case PART_TYPE_BENT_PIPE_SECTION:
	          printf( "start-coord:%lf\n",
		          ((bent_pipe_info *)(part_data))->start_coord[0] );

	          printf( "x) %lf  %lf  %lf\n",
		          ((bent_pipe_info *)(part_data))->transform.x[0],
		          ((bent_pipe_info *)(part_data))->transform.x[1],
		          ((bent_pipe_info *)(part_data))->transform.x[2] );

	          printf( "y) %lf  %lf  %lf\n",
		          ((bent_pipe_info *)(part_data))->transform.y[0],
		          ((bent_pipe_info *)(part_data))->transform.y[1],
		          ((bent_pipe_info *)(part_data))->transform.y[2] );

	          printf( "z) %lf  %lf  %lf\n",
		          ((bent_pipe_info *)(part_data))->transform.z[0],
		          ((bent_pipe_info *)(part_data))->transform.z[1],
		          ((bent_pipe_info *)(part_data))->transform.z[2] );

	          printf( "o) %lf  %lf  %lf\n",
		        ((bent_pipe_info *)(part_data))->transform.translate[0],
		        ((bent_pipe_info *)(part_data))->transform.translate[1],
		      ((bent_pipe_info *)(part_data))->transform.translate[2] );

		  sts = RT_get_piping_component_attr(
			 &(((part_info *)(partinfo))->part_id), &PiCompAttr );
	          break;

	         case PART_TYPE_COMPONENT:
	          printf( "n_ports:%d\n",
		          ((component_info *)(part_data))->n_ports );

		  printf( "Component:\n" );

	          printf( "x) %lf  %lf  %lf\n",
		          ((component_info *)(part_data))->transform.x[0],
		          ((component_info *)(part_data))->transform.x[1],
		          ((component_info *)(part_data))->transform.x[2] );

	          printf( "y) %lf  %lf  %lf\n",
		          ((component_info *)(part_data))->transform.y[0],
		          ((component_info *)(part_data))->transform.y[1],
		          ((component_info *)(part_data))->transform.y[2] );

	          printf( "z) %lf  %lf  %lf\n",
		          ((component_info *)(part_data))->transform.z[0],
		          ((component_info *)(part_data))->transform.z[1],
		          ((component_info *)(part_data))->transform.z[2] );

	          printf( "o) %lf  %lf  %lf\n",
		        ((component_info *)(part_data))->transform.translate[0],
		        ((component_info *)(part_data))->transform.translate[1],
		      ((component_info *)(part_data))->transform.translate[2] );

		  for( ii=0; ii < ((component_info *)(part_data))->n_ports;
		       ++ii )
		  {
		    printf( "port:%d\n", ii );
		    printf( "p_x) %lf  %lf  %lf\n",
			((component_info *)(part_data))->port_matrix[ii].x[0],
			((component_info *)(part_data))->port_matrix[ii].x[1],
			((component_info *)(part_data))->port_matrix[ii].x[2] );

		    printf( "p_y) %lf  %lf  %lf\n",
			((component_info *)(part_data))->port_matrix[ii].y[0],
			((component_info *)(part_data))->port_matrix[ii].y[1],
			((component_info *)(part_data))->port_matrix[ii].y[2] );

		    printf( "p_z) %lf  %lf  %lf\n",
			((component_info *)(part_data))->port_matrix[ii].z[0],
			((component_info *)(part_data))->port_matrix[ii].z[1],
			((component_info *)(part_data))->port_matrix[ii].z[2] );

		    printf( "p_o) %lf  %lf  %lf\n",
		((component_info *)(part_data))->port_matrix[ii].translate[0],
		((component_info *)(part_data))->port_matrix[ii].translate[1],
		((component_info *)(part_data))->port_matrix[ii].translate[2] );
		  }

		  sts = RT_get_piping_component_attr(
			 &(((part_info *)(partinfo))->part_id), &PiCompAttr );
	       }
	     }

	     if( partinfo != NULL )
	     {
	      printf( "partinfo->stock_number:%s\n\n",
				 ((part_info *)(partinfo))->stock_number );

	      if( part_type == PART_TYPE_LINEAR_PIPE_SECTION ||
		  part_type == PART_TYPE_BENT_PIPE_SECTION )
	       part_id = ((part_info *)(partinfo))->part_id;
	      else if( part_type == PART_TYPE_COMPONENT )
		    comp_id = ((part_info *)(partinfo))->part_id;
	     }

	   }

	  }while( ret == RTSUCC );
	}/* for each pipe run */
	}/* for each pipe line */

	
	printf( "part_id.objid:%d\n",  part_id.objid );
        printf( "comp_id.objid:%d\n",  comp_id.objid );

	sts = 100;

	if( bFlag )
         sts = RT_get_pipe_attributes( &part_id, &PipeAttr );

	printf( "\n" );

	if( sts == RTSUCC )
	{
	 printf( "size:%lf\n", ((pipe_attr *)PipeAttr)->nom_pipe_size );
	 printf( "s-type:%s\n", ((pipe_attr *)PipeAttr)->nom_pipe_size_type );
	 printf( "material:%s\n", ((pipe_attr *)PipeAttr)->material_name );
	 printf( "schedule:%s\n", 
		((pipe_attr *)PipeAttr)->wall_thickness_or_schedule );
	 printf( "prs_rtng:%lf\n", ((pipe_attr *)PipeAttr)->pressure_rating );
	 printf( "units:%s\n", ((pipe_attr *)PipeAttr)->pressure_rating_units );
	 printf( "outside-dia:%lf\n",
		 ((pipe_attr *)PipeAttr)->pipe_outside_diameter );
	 printf( "comp-code:%s\n", ((pipe_attr *)PipeAttr)->comp_code );
	 printf( "g_size:%lf\n", ((pipe_attr *)PipeAttr)->g_size );
	 printf( "opt-code:%d\n", ((pipe_attr *)PipeAttr)->opt_code );
	}

	if( bFlag )
         sts = RT_get_piping_component_attr( &comp_id, &PiCompAttr );

	if( sts == RTSUCC )
	{
	  printf( "\n" );
	  printf( "num_ports:%d\n", PiCompAttr->num_ports );
	  printf( "cp_coord[0]:%lf\n",
		 PiCompAttr->comp_port_defs[0]->cp_coord[0] );
	  printf( "nom_pipe_size:%lf\n",
			 PiCompAttr->comp_port_defs[0]->nom_pipe_size );
	  printf( "g_size:%lf\n",
			 PiCompAttr->g_size );
	  printf( "r_size:%lf\n",
			 PiCompAttr->r_size );
	  printf( "nom_pipe_size_type:%s\n",
			 PiCompAttr->comp_port_defs[0]->nom_pipe_size_type );
	  printf( "end_prep:%s\n",
			 PiCompAttr->comp_port_defs[0]->port_end_prep );
	  printf( "prs-rtng:%lf\n",
			 PiCompAttr->comp_port_defs[0]->pressure_ratings );
	  printf( "comp-type:%d\n", PiCompAttr->component_type );
	  printf( "part_class:%s\n", PiCompAttr->part_class );
	}
#ifdef CSG
	printf( "calling RT_get_entity_csg\n" );
        sts = RT_get_entity_csg( part_id, 0,
				 &num_csgs, &csg_types, &csgs );

	printf( "out of RT_get_entity_csg\n" );

	if( sts > 0 )
	{
	printf( "num_csgs:%d\n",num_csgs);
	printf("   csg_types: " );
	for (i = 0; i < num_csgs; i++)
	{
	    printf("%d, ",csg_types[i]);
	}
	printf ("\n");
	} else {
	printf ( "NO CSGS Processed \n");
	}
#endif

	printf( "\nNo of PipingSystems:%d\n", nsy );
	for( i=0; i < nsy; ++i )
	 printf( "Sys[%d]:%s\n", i, syida[i] );

	printf( "No of PipeLines:%d\n", PiLinCount );
	for( i=0; i < PiLinCount; ++i )
	 printf( "p_buff_ptr[%d]->pipeline_id:%s\n",
		 i, p_buff_ptr[i]->pipeline_id );

	sts = RT_get_file_name( filename );

	if( sts == RTSUCC )
	 printf( "filename: %s\n", filename );

	/* do an RT_exit_read only after retrieving all info */
	RT_exit_read();
	end: ;
}
