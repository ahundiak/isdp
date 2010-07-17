/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/drive.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: drive.C,v $
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
