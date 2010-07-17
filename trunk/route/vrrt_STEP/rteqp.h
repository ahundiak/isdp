/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/rteqp.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: rteqp.h,v $
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
 *	01/05/98	Onay	Integration date.
 *
 *************************************************************************/

#define RTSUCC 		0
#define RTERR 		-1

#define RT_psi 		3	/* flags to specify units   */
#define RT_kpa 		4	/* of pressure measurement  */
#define RT_atm 		5

/* transformation matrix for port, component, or equipment 
   orientation */
   typedef struct
   {
     double x[3],
	    y[3],
	    z[3];
     double translate[3];
   }t_matrix;

/* equipment port definition - a less detailed version */
   typedef struct
   {
     double coords[3];
     char p_label[9];
     t_matrix port_orient;
     struct GRid noz_id;
   }eqp_port;

/* structure to describe insulation attached to piping part */
   struct insul_info
   {
     double thickness;
     char thickness_units[9];
     char matl_desc[9];
   };

/* structure to describe equipment port instances */
   typedef struct
   {
     double cp_coord[3];
     double nom_pipe_size;
     char port_end_prep[10];
     char nom_pipe_size_type[10];	/* Iron Pipe Side etc. */
     char wall_thickness[9];
     double pressure_ratings;
     int pressure_rating_unit;
     t_matrix port_orient;
     char label[9];
   }eq_port_info;

/* defines the spec for an equipment item to be placed */
typedef struct
{
   char catalog_name[20];
   char part_num[36];       /** PDM Part number **/
   char revision[60];       /** Revision        **/
} e_spec;

extern int RTget_piping_equipment( struct GRid *PiEqpId,	/* I */
				   char *eqp_stk_numb,		/* O */
				   t_matrix *trans_mtx,		/* O */
				   struct insul_info *insul_info,/* O */
				   int *num_ports,		/* O */
				   eqp_port **eqp_ports );	/* O */

/* memory for eqp_ports is allocated inside RTget_piping_equipment   */

extern int RTget_piping_equip_attr( struct GRid *PiEqpId,        /* I */
				    int *num_ports,              /* O */
				    eq_port_info **eq_portinfo,  /* O */
				    char *catalog_name,		 /* O */
				    int *revision_num,		 /* O */
				    IGRboolean *access_env,	 /* O */
				    IGRboolean *insulation_env );/* O */

extern int RT_put_equipment( e_spec equip_spec,		/* I */
			     char *sys_name,		/* I */
			     t_matrix matrix,		/* I */
			     struct insul_info *insulinfo,/* I */
			     struct GRid*route_id,	/* O */
			     int *num_nozzles,		/* O */
			     struct GRid **noz_ids );	/* O */
