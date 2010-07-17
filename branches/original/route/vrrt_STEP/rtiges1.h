/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/rtiges.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: rtiges1.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/11/06  19:49:20  pinnacle
 * Alwin
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
/***************************************************
 rtiges.h

 Prototypes, data structures, and constants for
 I/CPIGES translator.

 v1.2, Wed Feb  9 14:20:05 CST 1994

 ***************************************************/

/* Modification history:

   28 Feb 94 - PR - added nozzle_grid field to equipment
                    port definition structure.
   21 Feb 94 - PR - changed name of RT_put_piping_entity;
                    changed type of inlet_cpt & outlet_cpt
		    parameters to agree with postprocessor.
    1 Mar 94 - PR - added typdefs for eq_port, eq_port_def, and
                    piping_support structures.
    1 Mar 94 - PR - added prototypes for RT_get_piping_equipment,
                    RT_get_piping_equip_attr, and RT_get_piping_supports.
    1 Mar 94 - PR - added new #define PART_TYPE_EQUIPMENT to allow
                    reuse of component generators for equipment.
*/


#ifndef __RTIGES__
#define __RTIGES__ 1

#include "OMtypes.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

/* Status codes returned to caller by RT routines. */
#define RTSUCC 		0
#define RTERR 		-1
#define RTERR_SYSTEMS 	-2
#define RTERR_PIPELINE 	-3
#define RTERR_PRUN 	-4
#define RT_END_PIPE_RUN -5
#define RTERR_DB_LOGIN	-6
#define ErrDangleLeadsToOlet	-10

#define CSG_ENT_IGNORED 0               /* specific status codes returned */
#define CSG_SUCCESS 1                   /* by CSG functions               */
#define CSG_ENT_ERROR -1
#define CSG_FAILED_TO_PROCESS 0

/***********************************************
 UTILITY ROUTINES: these routines set up the
 RT routines for reading from or writing to an
 I/ROUTE object space, and they provide
 miscellaneous other services.
 ***********************************************/

extern int RT_init_read(int batch_mode,
			char *route_file,
			char *db_name,
			char *db_username,
			char *db_passwd,
			int unit_flag);

extern int RT_exit_read(void);

extern int RT_get_filename (char *route_file);

extern int RT_exit_write(void);

extern int RT_init_write (int batch_mode, 
			  char *route_file, 
			  char *seed_file, 
			  int unit_flag, 
			  char *db_name, 
			  char *db_username, 
			  char *db_passwd);



/***********************************************
 GENERAL DEFINITIONS: used in preprocessor,
 postprocessor, or both.
 ***********************************************/

#define PART_TYPE_LINEAR_PIPE_SECTION 	0           /* flags to identify the   */
#define PART_TYPE_BENT_PIPE_SECTION 	1           /* type of a returned part */
#define PART_TYPE_COMPONENT 		2
#define PART_TYPE_NOZZLE                3
#define PART_TYPE_EQUIPMENT             4

#define RT_inches 	1                           /* flags to specify English */
#define RT_mm 		2                           /* or metric units          */

#define RT_psi 		3	                    /* flags to specify units   */
#define RT_kpa 		4	                    /* of pressure measurement  */
#define RT_atm 		5

#define RT_ips 		6                           /* types of measurement for   */
#define RT_od 		7                           /* pipe diameter measurements */
#define RT_id 		8

#define RT_INSTRUMENT	3                           /* flags to identify commodity */
#define RT_ENGINEERED	2                           /* class for components        */
#define RT_COMMODITY	1


/********************************************
 UTILITY DATA TYPES
 ********************************************/

/* identifies a connect point on an equipment item or component */
typedef struct {
  struct GRid comp_id;
  int conn_pt_id;
} connect_pt_id;

/* transformation matrix for port, component, or equipment 
   orientation */
typedef struct {
	double x[3], y[3], z[3];
	double translate[3];
} t_matrix;


/********************************************
 PREPROCESSOR DATA TYPES
 ********************************************/

/* structure to uniquely identify any single pipeline */
typedef struct {
  char *pipeline_id;
  struct GRid equipment_id;
} pipeline_info;


/*  structure to uniquely identify any single pipe run */
typedef struct {
  char pipe_spec[9];
  connect_pt_id run_start;
  connect_pt_id run_end;
} pipe_run_info;


/* structure to describe linear pipe elements */
typedef struct {
	double start_coord[3];
	double end_coord[3];
	int n_branch_ports;
	double *branch_coords;
	t_matrix *branch_matrix;   /*array of T-matrices, one per branch port */
} linear_pipe_info;


/* structure to describe bent or curved pipe elements */
typedef struct {
	double center_coord[3];
	double start_coord[3];
	double end_coord[3];
	t_matrix transform;        /* T-matrix for arc section */
	int n_branch_ports;
	double *branch_coords;
	t_matrix *branch_matrix;   /* array of T-matrices, one per branch port */	
} bent_pipe_info;

/* structure to describe component. I/ROUTE components only support
   3 ports per component as of release 2.3.0.0 */
typedef struct {
	t_matrix transform;
	int n_ports;
	double port_coords[3][3];
	t_matrix port_matrix[3];
} component_info;


/* structure to describe piping nozzle. */
typedef struct {
  struct GRid equip_grid;
} nozzle_info;


/* structure to describe insulation attached to piping part */
typedef struct {
	double thickness;
	char thickness_units[9];
	char matl_desc[9];
} insul_info;


/* structure to describe generic attributes shared by different
   types of parts: unique stock number, object ID, and so on. */
typedef struct {
	char *stock_number;
	struct GRid part_id;
	insul_info  *insul_info1;
	int num_supports;
	connect_pt_id  *begin_connect_pt;
	connect_pt_id  *end_connect_pt;
} part_info;


/* structure to describe component port instances */
typedef struct {
  double cp_coord[3];
  double nom_pipe_size;
  char port_end_prep[10];
  char nom_pipe_size_type[10];
  double pressure_ratings;
  int pressure_rating_unit;
  t_matrix port_orient;
  char label[9];
} port_info;



/* structure to describe equipment port instances */
typedef struct {
  double cp_coord[3];
  char label[9];
  t_matrix port_orient;
  struct GRid nozzle_grid;
} eq_port;


/* structure to describe equipment port definitions */
typedef struct {
  double cp_coord[3];
  double nom_pipe_size;
  char nom_pipe_size_type[10];
  char port_end_prep[10];
  char wall_thickness[10];
  double pressure_ratings;
  int pressure_rating_unit;
  t_matrix port_orient;
} eq_port_def;


/* structure to describe pipe attributes */
typedef struct {
	double nom_pipe_size;
	char nom_pipe_size_type[10];		/* units */
	char material_name[21];
	char wall_thickness_or_schedule[9];
	double pressure_rating;
	char pressure_rating_units[10];
	double pipe_outside_diameter;
	char comp_code[7];
	double g_size;
	double r_size;
	int opt_code;
} pipe_attr;


/* structure to describe component attributes */
typedef struct {
  int num_ports;
  port_info *comp_port_defs[3];
  int component_type;      /* RT_COMMODITY, RT_ENGINEERED, or RT_INSTRUMENT */
  char part_class[12]; 
  char matl_desc[10];
  char matl_name[21];
  char wall_thickness_or_schedule[9];
  char comp_code[7];
  double g_size;
  double r_size;
  int opt_code;
} piping_component_attr; 



/* structure to describe piping supports */
typedef struct {
  double attach_pt[3];
  double scale;
  char support_type[30];
  double weight;
} piping_support;


  

/***********************************************
 PREPROCESSOR ROUTINES: these routines read
 object/attribute data from the I/ROUTE object
 space and return that data to the caller.
 ***********************************************/
extern int RT_get_piping_systems(int *count,
				 char ***system_id_buffer);

extern int RT_get_pipelines(char *system_id,
			    int *count,
			    pipeline_info ***pipeline_id_buffer);

extern int RT_get_pipe_runs(char *system_id,
			    char *pipeline_id,
			    int *count,
			    pipe_run_info ***pipe_run_buffer);

extern int RT_get_pipe_run_part(char *system_id,
				char *pipeline_id,
				connect_pt_id *pipe_run,
				int *part_type, 
				void **part,
				part_info **partinfo);

extern int RT_get_pipe_attributes(struct GRid *grid,
				  pipe_attr **pipe_attr);

extern int RT_get_piping_component_attr(struct GRid *grid,
					piping_component_attr **attr);



extern int RT_get_entity_csg (struct GRid part_id,
			      int desired_rep,
			      int *num_csg,
			      int **csg_types,
			      void ***csgs);

extern int CSG_out150( struct GRid id, 
		      int *csg_type,
		      void **csg );
extern int CSG_out152( struct GRid id, 
		      int *csg_type, 
		      void **csg);
extern int CSG_out154( struct GRid id, 
		      int *csg_type,
		      void **csg);
extern int CSG_out156( struct GRid id, 
		      int *csg_type, 
		      void **csg);
extern int CSG_out158( struct GRid id, 
		      int *csg_type, 
		      void **csg);
extern int CSG_out160( struct GRid id, 
		      int *csg_type, 
		      void **csg);

extern int CSG_out_processing_error(OM_S_OBJID objid,
				    OMuword os,
				    int error_type);

 int RT_get_equipment (struct GRid equip_grid,
			     char *equip_stock_num,
			     t_matrix *equip_orient,
			     eq_port *ports);

extern int RT_get_piping_equip_attr (struct GRid piping_equip_id,
				     int num_ports,
				     eq_port_def *eq_ports,
				     char *catalog_name,
				     int revision_num);

extern int RT_get_piping_supports (char *system_id,
				   char *pipeline_id,
				   connect_pt_id *pipe_run,
				   struct GRid part_id,
				   piping_support *supports);
				   


/********************************************
 POSTPROCESSOR DATA TYPES
 ********************************************/

/* defines the spec for a piping object to be placed */
typedef struct
{
 char pipe_spec[9];
 char comp_code[7];
 float g_size;
 float r_size;
 int option;
} p_spec;


/* defines the spec for an equipment item to be placed */
typedef struct
{
   char catalog_name[20];
   char part_num[36];       /** PDM Part number **/
   char revision[60];       /** Revision        **/
} e_spec;


/* used to represent the inlet & outlet connect points during
   a postprocessor run */
typedef struct
{
  struct GRid route_id;
  long port_num;
  char port_label[40];
  long joint_des;
} write_cpt_struct;


typedef struct
{
  int     port_num; 
  char    port_label[40];
} PTport_id; 


/***********************************************
 POSTPROCESSOR ROUTINES: these routines place
 objects, with attribute data, into the I/ROUTE
 object space.
 ***********************************************/

int RT_put_equipment (e_spec equip_spec, 
		      char *sys_name, 
		      t_matrix matrix, 
		      struct GRid *route_id);

int RT_put_piping_entity (p_spec *part_spec, 
			 char *system_name, 
			 char *pipeline_id, 
			 int part_type, 
			 void *part, 
			 insul_info *insul_info, 
			 write_cpt_struct *inlet_cpt, 
			 write_cpt_struct *outlet_cpt,
			 IGRint StartOfRun,
			 struct GRid *route_id);


int RT_put_support (struct GRid route_id, 
		    t_matrix matrix);

int RT_connect (struct GRid route_id1, 
		PTport_id port1, 
		struct GRid route_id2, 
		PTport_id port2);

#endif




