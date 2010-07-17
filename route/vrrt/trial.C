/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/trial.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: trial.C,v $
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

void trial()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -15.994306;
  PipeInfo.start_coord[1] = 17.201423;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -15.994306;
  PipeInfo.end_coord[1] = 4.056228;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -15.994306;
  CompInfo.transform.translate[1] = 1.056228;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -12.994306;
  PipeInfo.start_coord[1] = 1.056228;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 8.213167;
  PipeInfo.end_coord[1] = 1.056228;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

 
  /* Tee */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = -1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 10.713167;
  CompInfo.transform.translate[1] = 1.056228;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial2 */
void trial2()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -31.535943;
  PipeInfo.start_coord[1] = 16.296085;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -15.674733;
  PipeInfo.end_coord[1] = 16.296085;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -12.674733;
  CompInfo.transform.translate[1] = 16.296085;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -12.674733;
  PipeInfo.start_coord[1] = 13.296085;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -12.674733;
  PipeInfo.end_coord[1] = -11.485409;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -12.674733;
  CompInfo.transform.translate[1] = -14.485409;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -9.674733;
  PipeInfo.start_coord[1] = -14.485409;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 14.938078;
  PipeInfo.end_coord[1] = -14.485409;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial3 */
void trial3( )
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Trimmed Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90T" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -12.674733;
  CompInfo.transform.translate[1] = -14.485409;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial4 */
void trial4()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -18.710320;
  PipeInfo.start_coord[1] = -7.242705;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 3.958721;
  PipeInfo.end_coord[1] = -7.242705;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Trimmed Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90T" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 9.958719;
  CompInfo.transform.translate[1] = -7.242705;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 9.958719;
  PipeInfo.start_coord[1] = -1.242707;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 9.958719;
  PipeInfo.end_coord[1] = 17.050534;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial5 */
void trial5()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -115.808547;
  PipeInfo.start_coord[1] = 86.635897;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -68.899143;
  PipeInfo.end_coord[1] = 86.635897;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Trimmed Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90T" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -62.899145;
  CompInfo.transform.translate[1] = 86.635897;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -62.899145;
  PipeInfo.start_coord[1] = 80.635899;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -62.899145;
  PipeInfo.end_coord[1] = 48.584615;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial6 */
void trial6()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N5" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -136.464957;
  PipeInfo.start_coord[1] = 86.998291;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -81.220512;
  PipeInfo.end_coord[1] = 86.998291;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow  - this component can be found in the data base */
  strcpy( pSpec.pipe_spec, "N5" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -75.220513;
  CompInfo.transform.translate[1] = 86.998291;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N5" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -75.220513;
  PipeInfo.start_coord[1] = 83.998291;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -75.220513;
  PipeInfo.end_coord[1] = 53.295726;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial7  - NetWork - dgn */
void trial7()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id, FirStartId, SecStartId;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;   /*check this out*/

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -28.216370;
  PipeInfo.start_coord[1] = 13.580071;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -1.038434;
  PipeInfo.end_coord[1] = 13.580071;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;   /*check this out*/

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 1.961566;
  CompInfo.transform.translate[1] = 13.580071;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );


  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;   /*check this out*/

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 1.961566;
  PipeInfo.start_coord[1] = 10.580071;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 1.961566;
  PipeInfo.end_coord[1] = 5.216014;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Tee */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 1.961566;
  CompInfo.transform.translate[1] = 2.716014;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );

  FirStartId = route_id;

  /* start run 2 */

  /* Pipe */
  inlet_cpt.comp_id = FirStartId;
  /* No need for determining a free Cpt. "-1" works fine. */
  inlet_cpt.conn_pt_id    = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 1.961566;
  PipeInfo.start_coord[1] = 0.216014;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 1.961566;
  PipeInfo.end_coord[1] = -11.230961;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Tee */
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 1.961566;
  CompInfo.transform.translate[1] = -13.730961;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
  SecStartId = route_id;

  /* start run 3 */

  /* Pipe */
  inlet_cpt.comp_id = SecStartId;
  inlet_cpt.conn_pt_id    = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -0.538434;
  PipeInfo.start_coord[1] = -13.730961;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -12.825623;
  PipeInfo.end_coord[1] = -13.730961; 
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );

  /* start run 4 */

  /* Pipe */
  inlet_cpt.comp_id = SecStartId;
  inlet_cpt.conn_pt_id    = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 4.461566;
  PipeInfo.start_coord[1] = -13.730961;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 28.367260;
  PipeInfo.end_coord[1] = -13.730961; 
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );

  /* Start Run 5 */

  /* Pipe */
  inlet_cpt.comp_id = FirStartId;
  inlet_cpt.conn_pt_id    = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 4.461566;
  PipeInfo.start_coord[1] = 2.716014;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 18.257651;
  PipeInfo.end_coord[1] = 2.716014;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial8 - new algorithm - dgn */
void trial8()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  linear_pipe_info PipeInfo;
  component_info CompInfo;
  insul_info iinfo;
  struct GRid route_id;
  struct GRid LastId;
  struct GRid FirStartId, SecStartId;
  write_cpt_struct inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;

  inlet_cpt.route_id.objid = NULL_OBJID;
  inlet_cpt.port_num    = -1;
  outlet_cpt.route_id.objid = NULL_OBJID;
  outlet_cpt.port_num    = -1;

  status = RT_init_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -28.216370;
  PipeInfo.start_coord[1] = 13.580071;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -1.038434;
  PipeInfo.end_coord[1] = 13.580071;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
  LastId = route_id;


  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 1.961566;
  CompInfo.transform.translate[1] = 13.580071;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  inlet_cpt.route_id = LastId;
  inlet_cpt.port_num = -1;

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  LastId = route_id;


  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 1.961566;
  PipeInfo.start_coord[1] = 10.580071;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 1.961566;
  PipeInfo.end_coord[1] = 5.216014;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  inlet_cpt.route_id = LastId;
  inlet_cpt.port_num = -1;

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  LastId = route_id;

  /* Tee */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 1.961566;
  CompInfo.transform.translate[1] = 2.716014;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  inlet_cpt.route_id = LastId;
  inlet_cpt.port_num = -1;

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  FirStartId = route_id;

  /* start run 2 */

  /* Pipe */
  inlet_cpt.route_id = FirStartId;
  /* No need for determining a free Cpt. "-1" works fine. */
  inlet_cpt.port_num    = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 1.961566;
  PipeInfo.start_coord[1] = 0.216014;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 1.961566;
  PipeInfo.end_coord[1] = -11.230961;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  LastId = route_id;


  /* Tee */
  inlet_cpt.route_id.objid = NULL_OBJID;
  inlet_cpt.port_num    = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 1.961566;
  CompInfo.transform.translate[1] = -13.730961;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  inlet_cpt.route_id = LastId;
  inlet_cpt.port_num = -1;

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  SecStartId = route_id;

  /* start run 3 */

  /* Pipe */
  inlet_cpt.route_id = SecStartId;
  inlet_cpt.port_num = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -0.538434;
  PipeInfo.start_coord[1] = -13.730961;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -12.825623;
  PipeInfo.end_coord[1] = -13.730961; 
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* start run 4 */

  /* Pipe */
  inlet_cpt.route_id = SecStartId;
  inlet_cpt.port_num = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 4.461566;
  PipeInfo.start_coord[1] = -13.730961;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 28.367260;
  PipeInfo.end_coord[1] = -13.730961; 
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Start Run 5 */

  /* Pipe */
  inlet_cpt.route_id = FirStartId;
  inlet_cpt.port_num = -1;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 4.461566;
  PipeInfo.start_coord[1] = 2.716014;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 18.257651;
  PipeInfo.end_coord[1] = 2.716014;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
}

/*C trial9 - fitting to fitting */
void trial9()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -31.385053;
  PipeInfo.start_coord[1] = 9.355160;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -20.636299;
  PipeInfo.end_coord[1] = 9.355160;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -14.636299 ;
  CompInfo.transform.translate[1] = 9.355160;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -14.636299;
  CompInfo.transform.translate[1] = -2.644840;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );


  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -2.636299;
  CompInfo.transform.translate[1] = -2.644840 ;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Elbow */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -2.636299;
  CompInfo.transform.translate[1] = -14.644840;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 3.363701;
  PipeInfo.start_coord[1] = -14.644840;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 24.293238;
  PipeInfo.end_coord[1] = -14.644840;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity2( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
}

/*C trial10 - FittingToFitting to test the new algorithm */
void trial10()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -31.385053;
  PipeInfo.start_coord[1] = 9.355160;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -20.636299;
  PipeInfo.end_coord[1] = 9.355160;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* Elbow */
  inlet_cpt.comp_id = LastId;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -14.636299 ;
  CompInfo.transform.translate[1] = 9.355160;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -14.636299;
  CompInfo.transform.translate[1] = -2.644840;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -2.636299;
  CompInfo.transform.translate[1] = -2.644840 ;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -2.636299;
  CompInfo.transform.translate[1] = -14.644840;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 3.363701;
  PipeInfo.start_coord[1] = -14.644840;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 24.293238;
  PipeInfo.end_coord[1] = -14.644840;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;
}


/*C trial11 */
void trial11()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Elbow */
   strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -14.636299 ;
  CompInfo.transform.translate[1] = 9.355160;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;
}

/*C trial12 - try  */
void trial12()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId;
  struct GRid PipeId;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -30.027046;
  PipeInfo.start_coord[1] = -5.884698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 32.441281;
  PipeInfo.end_coord[1] = -5.884698;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  PipeId = route_id;


  /* Olet */
  inlet_cpt.comp_id = PipeId;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -8.449822;
  CompInfo.transform.translate[1] = -5.884698;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -8.449822;
  PipeInfo.start_coord[1] = -2.134698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -8.449822;
  PipeInfo.end_coord[1] = 12.976512;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* Olet */
  inlet_cpt.comp_id = PipeId;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 15.541637;
  CompInfo.transform.translate[1] = -5.884698;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 15.541637;
  PipeInfo.start_coord[1] = -9.634698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 15.541637;
  PipeInfo.end_coord[1] = -16.899644;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;
}

/*C trial112 - try  */
void trial112()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  write_cpt_struct inlet_cpt, outlet_cpt;
  struct GRid LastId;
  struct GRid PipeId;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.route_id.objid  = NULL_OBJID;
  inlet_cpt.port_num	    = -1;
  outlet_cpt.route_id.objid = NULL_OBJID;
  outlet_cpt.port_num	    = -1;

  status = RT_init_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -30.027046;
  PipeInfo.start_coord[1] = -5.884698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 32.441281;
  PipeInfo.end_coord[1] = -5.884698;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  PipeId = route_id;


  /* Olet */
  inlet_cpt.route_id = PipeId;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -8.449822;
  CompInfo.transform.translate[1] = -5.884698;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.route_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -8.449822;
  PipeInfo.start_coord[1] = -2.134698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -8.449822;
  PipeInfo.end_coord[1] = 12.976512;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* Olet */
  inlet_cpt.route_id = PipeId;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 15.541637;
  CompInfo.transform.translate[1] = -5.884698;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.route_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 15.541637;
  PipeInfo.start_coord[1] = -9.634698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 15.541637;
  PipeInfo.end_coord[1] = -16.899644;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;
}

/*C trial13 - test_case3 */
void trial13()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId;
  struct GRid PipeId;
  struct GRid StartId;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -120.882051;
  PipeInfo.start_coord[1] = 56.194872;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -77.171154;
  PipeInfo.end_coord[1] = 56.194872;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  PipeId = route_id;

  /* Tee */
  inlet_cpt.comp_id = PipeId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -73.046154;
  CompInfo.transform.translate[1] = 56.194872;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId = route_id;


  /* Olet */
  inlet_cpt.comp_id = PipeId;

  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -105.299145;
  CompInfo.transform.translate[1] = 56.194872;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -105.299145;
  PipeInfo.start_coord[1] = 59.944872;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -105.299145;
  PipeInfo.end_coord[1] = 82.287179;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.comp_id = StartId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -68.921154;
  PipeInfo.start_coord[1] = 56.194872;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -27.022222;
  PipeInfo.end_coord[1] = 56.194872;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.comp_id = StartId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -73.046154;
  PipeInfo.start_coord[1] = 60.319872;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -73.046154;
  PipeInfo.end_coord[1] = 89.897436;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;
}

/*C trial14 - case */
void trial14()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId;
  struct GRid PipeId;
  struct GRid StartId;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 33.799288;
  PipeInfo.start_coord[1] = -8.449822;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -7.191726;
  PipeInfo.end_coord[1] = -8.449822;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  PipeId = route_id;
  printf( "PipeId:%d\n", PipeId.objid );

  /* Tee */
  inlet_cpt.comp_id = PipeId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -11.316726;
  CompInfo.transform.translate[1] = -8.449822;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId = route_id;


  /* Start Run 2 */

  /* Pipe */
  inlet_cpt.comp_id = StartId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -11.316726;
  PipeInfo.start_coord[1] = -8.449822;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -30.479715;
  PipeInfo.end_coord[1] = -8.449822;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* Start Run 3 */
  /* Pipe */
  inlet_cpt.comp_id = StartId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -11.316726;
  PipeInfo.start_coord[1] = -4.324822;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -11.316726;
  PipeInfo.end_coord[1] = 6.071174;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = 1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -11.316726;
  CompInfo.transform.translate[1] = 12.071174;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -5.316726;
  PipeInfo.start_coord[1] = 12.071174;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -3.358007;
  PipeInfo.end_coord[1] = 12.071174;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Reducer */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "CONRED" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -1.358007;
  CompInfo.transform.translate[1] = 12.071174;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 0.641993;
  PipeInfo.start_coord[1] = 12.071174;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 16.012100;
  PipeInfo.end_coord[1] = 12.071174;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 19.012100;
  CompInfo.transform.translate[1] = 12.071174;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 19.012100;
  PipeInfo.start_coord[1] = 9.071174;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 19.012100;
  PipeInfo.end_coord[1] = -4.699822;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* Olet */
  inlet_cpt.comp_id = LastId;
  outlet_cpt.comp_id = PipeId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 19.012100;
  CompInfo.transform.translate[1] = -8.449822;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;
}

/*C trial15 - junk */
void trial15()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId;
  struct GRid StartId1, StartId2, StartId3;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -25.500356;
  PipeInfo.start_coord[1] = 14.636299;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -10.846263;
  PipeInfo.end_coord[1] = 14.636299;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -7.846263;
  CompInfo.transform.translate[1] = 14.636299;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -7.846263;
  PipeInfo.start_coord[1] = 11.636299;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -7.846263;
  PipeInfo.end_coord[1] = 8.384698;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Tee */
  inlet_cpt.comp_id = LastId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -7.846263;
  CompInfo.transform.translate[1] = 5.884698;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId1 = route_id;

  /* Start Run 2 */

  /* Pipe */
  inlet_cpt.comp_id = StartId1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -7.846263;
  PipeInfo.start_coord[1] = 3.384698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -7.846263;
  PipeInfo.end_coord[1] = -7.156940;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Tee */
  inlet_cpt.comp_id = LastId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -7.846263;
  CompInfo.transform.translate[1] = -9.656940;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId2 = route_id;

  /* Start Run 3 */

  /* Pipe */
  inlet_cpt.comp_id = StartId2;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -10.346263;
  PipeInfo.start_coord[1] = -9.656940;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -29.272598;
  PipeInfo.end_coord[1] = -9.656940;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Start Run 4 */

  /* Pipe */
  inlet_cpt.comp_id = StartId2;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -5.346263;
  PipeInfo.start_coord[1] = -9.656940;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 3.686477;
  PipeInfo.end_coord[1] = -9.656940;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Tee */
  inlet_cpt.comp_id = LastId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 6.186477;
  CompInfo.transform.translate[1] = -9.656940;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId3 = route_id;

  /* Start Run 5 */

  /* Pipe */
  inlet_cpt.comp_id = StartId3;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 8.686477;
  PipeInfo.start_coord[1] = -9.656940;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 14.654093;
  PipeInfo.end_coord[1] = -9.656940;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 17.654093;
  CompInfo.transform.translate[1] = -9.656940;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 17.654093;
  PipeInfo.start_coord[1] = -12.656940;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 17.654093;
  PipeInfo.end_coord[1] = -19.313879;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Start Run 6 */
  /* Pipe */
  inlet_cpt.comp_id = StartId3;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 6.186477;
  PipeInfo.start_coord[1] = -7.156940;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 6.186477;
  PipeInfo.end_coord[1] = 2.884698;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 6.186477;
  CompInfo.transform.translate[1] = 5.884698;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  outlet_cpt.comp_id = StartId1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 3.186477;
  PipeInfo.start_coord[1] = 5.884698;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -5.346263;
  PipeInfo.end_coord[1] = 5.884698;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;
}

/*C trial16 */
void trial16()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId;
  struct GRid StartId1, StartId2;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -28.970819;
  PipeInfo.start_coord[1] = -4.979359;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -6.991904;
  PipeInfo.end_coord[1] = -4.979359;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Tee */
  inlet_cpt.comp_id = LastId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -2.866904;
  CompInfo.transform.translate[1] = -4.979359;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId1 = route_id;

  /* start run 2 */

  /* Pipe */
  inlet_cpt.comp_id = StartId1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 1.258096;
  PipeInfo.start_coord[1] = -4.979359;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 14.887100;
  PipeInfo.end_coord[1] = -4.979359;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Tee */
  inlet_cpt.comp_id = LastId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 19.012100;
  CompInfo.transform.translate[1] = -4.979359;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId2 = route_id;

  /* start run 3 */
  /* Pipe */
  inlet_cpt.comp_id = StartId2;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 23.137100;
  PipeInfo.start_coord[1] = -4.979359;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 32.893950; 
  PipeInfo.end_coord[1] = -4.979359;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* start run 4 */

  /* Elbow */
  inlet_cpt.comp_id = StartId2;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 19.012100;
  CompInfo.transform.translate[1] = 5.145641;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 13.012100;
  PipeInfo.start_coord[1] = 5.145641;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 3.133096;
  PipeInfo.end_coord[1] = 5.145641;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  outlet_cpt.comp_id = StartId1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = 1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -2.866904;
  CompInfo.transform.translate[1] = 5.145641;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;
}

/*C trial17 */
void trial17()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  component_info CompInfo;
  linear_pipe_info PipeInfo;
  insul_info iinfo;
  struct GRid route_id;
  connect_pt_id inlet_cpt, outlet_cpt;
  struct GRid LastId, PipeId;
  struct GRid StartId1, StartId2;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;
  inlet_cpt.comp_id.objid = NULL_OBJID;
  inlet_cpt.conn_pt_id    = -1;
  outlet_cpt.comp_id.objid = NULL_OBJID;
  outlet_cpt.conn_pt_id    = -1;

  status = RTinit_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -30.479715;
  PipeInfo.start_coord[1] = -1.358007;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -20.421085;
  PipeInfo.end_coord[1] = -1.358007;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Tee */
  inlet_cpt.comp_id = LastId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -16.296085;
  CompInfo.transform.translate[1] = -1.358007;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId1 = route_id;

  /* start run 2 */

  /* Pipe */
  inlet_cpt.comp_id = StartId1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -12.171085;
  PipeInfo.start_coord[1] = -1.358007;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 14.736210;
  PipeInfo.end_coord[1] = -1.358007;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;
  PipeId = route_id;

  /* Tee */
  inlet_cpt.comp_id = LastId;
  inlet_cpt.conn_pt_id    = -1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "TEE" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;

  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 18.861210;
  CompInfo.transform.translate[1] = -1.358007;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 3;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         0, &route_id );
  StartId2 = route_id;

  /* Start Run 3 */
  /* Olet */
  inlet_cpt.comp_id = PipeId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -7.695374;
  CompInfo.transform.translate[1] = -1.358007;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -7.695374;
  PipeInfo.start_coord[1] = -5.108007;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -7.695374;
  PipeInfo.end_coord[1] = -9.071174;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = -1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = -7.695374;
  CompInfo.transform.translate[1] = -12.071174;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -4.695374;
  PipeInfo.start_coord[1] = -12.071174;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 6.656940;
  PipeInfo.end_coord[1] = -12.071174;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = 1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = 1.0;

  CompInfo.transform.translate[0] = 9.656940;
  CompInfo.transform.translate[1] = -12.071174;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;


  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 2.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 9.656940;
  PipeInfo.start_coord[1] = -9.071174;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 9.656940;
  PipeInfo.end_coord[1] = -5.108007;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Olet */
  inlet_cpt.comp_id = LastId;
  outlet_cpt.comp_id = PipeId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "WOLET" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 2.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 9.656940;
  CompInfo.transform.translate[1] = -1.358007;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* start run 4 */
  /* Pipe */
  inlet_cpt.comp_id = StartId2;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 22.986210;
  PipeInfo.start_coord[1] = -1.358007;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 28.970819;
  PipeInfo.end_coord[1] = -1.358007;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;


  /* start run 5 */
  /* Pipe */
  inlet_cpt.comp_id = StartId2;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 18.861210;
  PipeInfo.start_coord[1] = 2.766993;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = 18.861210;
  PipeInfo.end_coord[1] = 9.541637;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 1.0;
  CompInfo.transform.x[1] = 0.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 0.0;
  CompInfo.transform.y[1] = -1.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = 18.861210;
  CompInfo.transform.translate[1] = 15.541637;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = 12.861210;
  PipeInfo.start_coord[1] = 15.541637;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -10.296085;
  PipeInfo.end_coord[1] = 15.541637;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;

  /* Elbow */
  inlet_cpt.comp_id = LastId;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "EL90" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_COMPONENT;


  CompInfo.transform.x[0] = 0.0;
  CompInfo.transform.x[1] = 1.0;
  CompInfo.transform.x[2] = 0.0;

  CompInfo.transform.y[0] = 1.0;
  CompInfo.transform.y[1] = 0.0;
  CompInfo.transform.y[2] = 0.0;

  CompInfo.transform.z[0] = 0.0;
  CompInfo.transform.z[1] = 0.0;
  CompInfo.transform.z[2] = -1.0;

  CompInfo.transform.translate[0] = -16.296085;
  CompInfo.transform.translate[1] = 15.541637;
  CompInfo.transform.translate[2] = 0.000000;


  CompInfo.n_ports = 2;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &CompInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         FALSE, &route_id );
  LastId = route_id;

  /* Pipe */
  inlet_cpt.comp_id = LastId;
  outlet_cpt.comp_id = StartId1;
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "W" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -16.296085;
  PipeInfo.start_coord[1] = 9.541637;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -16.296085;
  PipeInfo.end_coord[1] = 2.766993;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RTput_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         TRUE, &route_id );
  LastId = route_id;
}

/* Just one pipe. All construction planes are visible, locatable and
   can be manipulated. */
void trial18()
{
  IGRint status, part_type;
  p_spec pSpec;
  IGRchar sys_name[10], pipeline_id[10];
  linear_pipe_info PipeInfo;
  component_info CompInfo;
  insul_info iinfo;
  struct GRid route_id;
  struct GRid LastId;
  struct GRid FirStartId, SecStartId;
  write_cpt_struct inlet_cpt, outlet_cpt;
  IGRboolean batch_mode;
  IGRchar route_file[30];
  IGRchar seed_file[30];
  IGRint unit_flag;
  IGRchar db_name[25], db_username[25], db_passwd[25];

  batch_mode = FALSE;
  unit_flag = 1;

  inlet_cpt.route_id.objid = NULL_OBJID;
  inlet_cpt.port_num    = -1;
  outlet_cpt.route_id.objid = NULL_OBJID;
  outlet_cpt.port_num    = -1;

  status = RT_init_write( batch_mode, route_file, seed_file, unit_flag,
			 db_name, db_username, db_passwd );


  if( status == RTERR )
   return;

  /* Pipe */
  strcpy( pSpec.pipe_spec, "N1" );
  strcpy( pSpec.comp_code, "PIPING" );
  pSpec.g_size = 4.0;
  pSpec.r_size = 4.0;
  pSpec.option = 1;

  strcpy( sys_name, "SDR" );
  strcpy( pipeline_id, "seq1" );

  part_type = PART_TYPE_LINEAR_PIPE_SECTION;

  PipeInfo.start_coord[0] = -28.216370;
  PipeInfo.start_coord[1] = 13.580071;
  PipeInfo.start_coord[2] = 0.0;

  PipeInfo.end_coord[0] = -1.038434;
  PipeInfo.end_coord[1] = 13.580071;
  PipeInfo.end_coord[2] = 0.0;

  iinfo.thickness = 0.154;
  strcpy( iinfo.matl_desc, "142" );

  status = RT_put_piping_entity( &pSpec, sys_name, pipeline_id, part_type,
                         &PipeInfo, &iinfo, &inlet_cpt, &outlet_cpt,
                         1, &route_id );
  LastId = route_id;

}
