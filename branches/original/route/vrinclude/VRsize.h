#eofifdef VRsize_include
#define   VRsize_include
/*
  File dependencies : GMlist.h,
                      ACrg_collect.h
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           Mathematical constants                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define VR_PI_RAD            3.1415926535 /* Value of PI                      */
#define VR_EPSILON_VALUE     1.e-12       /* Precision maximum for sections   */
#define VRMAX_FORMULA        300          /* Maximum length for a formula     */
#define VRFT_WIDTH           "width"      /* Foot name of the width           */
#define VRFT_DEPTH           "depth"      /* Foot name of the depth           */
#define VRCPT_FORMAT         "graphics:VRcpt_%02d:" /* Format of the cpt name */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct VRres_info             /* Information necessary for the resizing       */
  {
  double  max_veloc;          /* Width of the section                         */
  double  air_flow;           /* Depth of the section                         */
  double  W_D;                /* Ratio Width/Deth                             */
  double  max_width;          /* Max width of the section                     */
  double  max_depth;          /* Max depth of the section                     */
  short   shape;              /* Type of section                              */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*            Internal data necessary to retrieve information from            */
/*            tha data base for the sizing method                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct COdatab_hvac           /* HVAC data retrieved from the data_base       */
  {
  double  width;              /* Width of the section                         */
  double  depth;              /* Depth of the section                         */
  double  equiv_diam;         /* Equivalent diameter                          */
  short   shape;              /* Type of section                              */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*       Temporary data necessary to simulate a data base for HVAC stuff      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct sim_havcdb             /* HVAC simulated data base                     */
  {
  struct GMlist rect_list;    /* List to store the rectangular profiles       */
  struct GMlist oval_list;    /* List to store the oval profiles              */
  struct GMlist circ_list;    /* List to store the circular profiles          */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      Structure For the graph manager                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct VRgrinfo               /* Define the information for the graph manager */
  {
  struct GRmd_env *p_md_env;  /* Pointer to the module environment            */
  char            *p_add;     /* Pointer to additional info                   */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                   Structure used to resizing equations                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct VRslv_inf              /* Information for equation solving             */
  {
  int           nb_unkn;      /* Number of unknown to solve                   */
  int           nb_constr;    /* Number of constraints in the system          */
  int           cur_constr;   /* Current constraint in the solver             */
  double        *matrix;      /* Matrix for the simplex method                */
  double        *vector;      /* Second term values                           */
  struct GMlist list;         /* List of (var name <-> index)in simplex array */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                 tructure containing pairs (index <-> Name)                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct VRind_name             /* Storage of (index in matrix <-> name)        */
  {
  int          index;         /* Index for the matrix (simplex matrix)        */
  char         name[ATTR_TXT];/* Attribute name                               */
};
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


