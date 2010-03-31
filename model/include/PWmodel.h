#ifndef _PWmodel_include
#define _PWmodel_include

/*--------------------- Surface/Solid Features ------------------------------*/
#define UNION 1
#define INTERSECTION 2
#define DIFFERENCE 3

struct PWdpbdata
{
 
  unsigned short u_order;
  unsigned short v_order;
  unsigned short u_rules;
  unsigned short v_rules;
  unsigned short polygon_display;
  unsigned short consider_boundaries;
  unsigned short u_periodic;
  unsigned short v_periodic;
 
 
  double basis_tol;
  double arclen_tol;
  double offset_tol;
  double cht_tol;
  double max_step_size;
};
 
struct PWrelstable
{
   int num_entries;
   unsigned int *table;
};


/*
 * Other types can be added to PWvaluetype and struct PWvalueinfo as and
 * when a need for them is felt and support can be provided.
 */
enum PWvaluetype
{
  value_numeric,
  value_name,
  value_null
};
 
 
/*
 * Structure to provide value information to the APIs, such as distances,
 * angles etc. This structure allows the user to give the value information
 * either in the numeric form (eg.2.0) or as an expression (eg."d10=d25/3.0").
 * The fields in the structure are accessed based on the type specified as
 * follows :
 * value_numeric -> value
 * value_name    -> name
 */
 
struct PWvalueinfo
{
  enum PWvaluetype type;
  double value;
  char name[PW_K_PathMax];
};
 
/*
 * The PWrndedgeset structure is used to input edges to the pwRoundEdges API
 * in the form of an array of edges per set with a common radius or variable
 * radius flag set.
 */
 
struct PWrndedgeset
{
  int num_edges;
  PWobjid *edges;
  struct PWvalueinfo start_radius;
  struct PWvalueinfo end_radius;
  PWboolean is_variable;
};

/*
 * The PWspecialsfs structure is used to input surfaces to the pwThinWall API
 * in the form of an array of surfaces that have a special offset thickness
 */

struct PWspecialsfs
{
  int num_sfs;
  PWobjid *objids;
  struct PWvalueinfo thickness;
};

/*
 * This enum enumerates all the extent types currently supported by the
 * Add/Remove Functionality.
 */
enum PWaddremexttype
{
  to_next,
  from_to,
  finite_one_sided,
  finite_symmetric,
  thru_all
};


/*--------------------- Profile -------------- ------------------------------*/

/*
 * This enum enumerates all the types of constraints supported by Variational
 * Geometry functionality
 */
enum PWprfcnstrtype
{
  PWprfcnstr_horizontal,
  PWprfcnstr_vertical,
  PWprfcnstr_relangular,
  PWprfcnstr_horzabsangular,
  PWprfcnstr_vertabsangular,
  PWprfcnstr_coincident,
  PWprfcnstr_collinear,
  PWprfcnstr_equality,
  PWprfcnstr_ground,
  PWprfcnstr_horizontal_dim,
  PWprfcnstr_vertical_dim,
  PWprfcnstr_normal,
  PWprfcnstr_parallel,
  PWprfcnstr_ptonelmt,
  PWprfcnstr_radial,
  PWprfcnstr_singleparl_dim,
  PWprfcnstr_tangency,
  PWprfcnstr_axis_horizontal_dim,
  PWprfcnstr_axis_vertical_dim,
  PWprfcnstr_invalid
};

#endif
