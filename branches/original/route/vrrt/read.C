/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/read.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: read.C,v $
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

#include <alloca.h>
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "GMlist.h"
#include "GMdef.h"
#include "GMerrordef.h"
#include "gr.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "GMhcode.h"
#include "vrdef.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "vrmacros.h"
#include "VRsize.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "GMndg.h"
#include "GMerrordef.h"
#include "rtiges.h"
#include "AS_status.h"
#include "msdef.h"
#include "VRDbStruct.h"
#include "VRmacros.h"
#include "VDmacdef.h"
#include "PDUerror.h"
#include "exmacros.h"
#include "OMlimits.h"
#include "stdio.h"
#include "vdsmacros.h"

#define VR_MATLCODE_LIST_NUM  145
#define VR_PREPCODE_LIST_NUM  330
#define RT_MAX_TIPS	30
#define RT_MAX_NW	20

extern GMgridcmp();
extern GMh_activate();
extern GMh_getlist();
extern GMh_grid();
extern VRget_allow_connect();
extern GMndg_activate();
extern GMndg_getgraph();

#include "rtiges.h"



typedef int (*funcp)(); 	
typedef char* charp;		
typedef void* pointer; 		
typedef pointer (*pfuncp)(); 	

typedef struct lc_struct { charp lc_name;
	funcp lc_cmpfunc; unsigned lc_order:1, lc_collapse:1; }* LLCONTROL;

typedef struct ln_struct {
	struct ln_struct* ln_ll;
	struct ln_struct* ln_next;
	struct ln_struct* ln_prev;
	int ln_count; pointer ln_object; }* LLNODE;




typedef LLNODE (*LLNODEfuncp)();
extern struct lc_struct LLcontrol_struct;
extern struct lc_struct LLcontrol_ints_struct;
extern struct lc_struct LLcontrol_longs_struct;
extern struct lc_struct LLcontrol_strs_structa[];

extern pointer ll_find_object();
extern pointer* ll_array();
extern LLNODE ll_insert ();
extern LLNODE ll_new();
extern LLCONTROL ll_freef();
extern LLCONTROL ll_free();
extern	charp	str_copy ();
extern	int Diag_debug;

/* The Structures that are internal to these routines can be tailored to
   suit our own needs. */

/*
static  struct GRid* new_gridp()
{
   struct GRid *p = ( struct GRid* )diag_malloc( 04000, sizeof( struct GRid) );

   if( ((p)==0) )
    return 0;

   return p;
}

static void free_gridp(p)
struct GRid *p;
{   diag0_free(p);
}

static struct GRid * gridp_copy(gridp0)
struct GRid *gridp0;
{
	struct GRid *gridp = new_gridp();
	memcpy(gridp,gridp0,sizeof(struct GRid));
	return gridp;
}
*/

static int gridpcmp(gridp1,gridp2)
struct GRid *gridp1;
struct GRid *gridp2;
{
	long cmp;
	if (cmp = (long)gridp1->osnum - (long)gridp2->osnum)
		return long_to_cmpint(cmp);
	if (cmp = (long)gridp1->objid - (long)gridp2->objid)
		return long_to_cmpint(cmp);
	return 0;
}

/*
static struct lc_struct LLcontrol_gridps_struct =
	 { "gridps", gridpcmp, 0, 0, }; */

/* New Code */

struct st_prpart
{
  connect_pt_id begincpi;
  struct GRid grid;
  connect_pt_id endcpi;
};

typedef struct pr_struct {
        pipe_run_info pr_pri;
        LLNODE pr_parts;
}* PR;

prpartcmp( prpart1, prpart2 )
struct st_prpart *prpart1;
struct st_prpart *prpart2;
{
  return gridpcmp( &prpart1->grid, &prpart2->grid );
}

static struct lc_struct LLcontrol_prparts_struct =
         { "gridps", prpartcmp, 0, 0, };

static PR pr_new()
{
  PR pr = (PR)diag_malloc( 04000, sizeof(struct pr_struct) );
  pr->pr_pri.pipe_spec[0] = NULL;
  pr->pr_parts = ll_new( &LLcontrol_prparts_struct, 0 );

  return pr;
}

static  struct st_prpart* new_prpart()
{
   struct st_prpart *p;

   p = (struct st_prpart *)diag_malloc( 04000, sizeof(struct st_prpart) );

   if( p == 0 )
    return 0;

   return p;
}

static struct st_prpart * prpart_copy( prpart0 )
struct st_prpart *prpart0;
{
        struct st_prpart *prpart;

	prpart = new_prpart();

        memcpy( prpart, prpart0, sizeof(struct st_prpart) );

        return prpart;
}

/*
static void free_prpart(p)
struct st_prpart *p;
{
  diag0_free(p);
} */

/*  New Code */

static 	connect_pt_id* new_cpi( )
{
  connect_pt_id* p =
	 (connect_pt_id *)diag_malloc( 04000, sizeof(connect_pt_id) );

  if( ((p)==0) )
   return 0;

  return p;
}

static void free_cpi( p )
connect_pt_id *p;
{
   diag0_free( p );
}

static linear_pipe_info *new_lpi( )
{
  linear_pipe_info *p =
	 (linear_pipe_info *)diag_malloc( 04000, sizeof(linear_pipe_info) );

  if( ((p)==0) )
   return 0;

  p->branch_coords = 0;

  return p;
}

 static void free_lpi( p )
 linear_pipe_info* p;
 {
   if( p->branch_coords )
    free(p->branch_coords);

   diag0_free(p);
 }
/*# 47 ""*/

static bent_pipe_info* new_bpi( )
{
  bent_pipe_info *p =
	(bent_pipe_info *)diag_malloc( 04000, sizeof(bent_pipe_info) );

  if( ((p)==0) )
   return 0;

  p->branch_coords = 0;

  return p; 
}

 static void free_bpi(p)
	bent_pipe_info* p;
{
  	if(p->branch_coords)
	  diag0_free(p->branch_coords);

	 diag0_free(p); 
}
/*# 52 ""*/

static 	component_info* new_ci()
{
  component_info* p =
	 (component_info *)diag_malloc( 04000, sizeof(component_info) );

 if( ((p)==0) ) return 0;

  /*p->port_coords = new_coords( );*/

  return p; 
}

 static void free_ci( p )
  component_info* p;
 {
 	/*if(p->port_coords)
         diag0_free(p->port_coords);*/

        diag0_free(p);
 }
/*# 57 ""*/

char *new_tu()
{
 char *p = (char *)diag_malloc( 04000, (9*sizeof(char)) );

 if( p == 0 )
  return 0;

 p[0] = NULL;

 return p;
}

char *new_md()
{
 char *p = (char *)diag_malloc( 04000, (9*sizeof(char)) );

 if( p == 0 )
  return 0;

 p[0] = NULL;

 return p;
}

static insul_info* new_ii( )
{
  insul_info* p = (insul_info *)diag_malloc( 04000, sizeof(insul_info) );

  if( p == 0 ) return 0;

   /*p->thickness_units = new_tu();*/
   p->thickness_units[0] = '\0';

   /*p->matl_desc = new_md();*/
   p->matl_desc[0] = '\0';

  return p;
}

 static void free_ii( p )
 insul_info* p;
 {
   /*if( p->matl_desc )
    diag0_free(p->matl_desc);

   if( p->thickness_units )
    diag0_free( p->thickness_units );*/

   /*if( p->matl_name )
    diag0_free( p->matl_name );*/

   diag0_free( p );
 }

static char *new_sn()
 {
   char *p = (char *)diag_malloc( 04000, (36*sizeof(char)) );

   if( p == 0 )
    return 0;

   p[0] = NULL;

   return p;
 }

 static	part_info* new_pi( )
 {
   part_info* p = (part_info *)diag_malloc( 04000, sizeof(part_info) );

   if( p == 0 ) return 0;

   p->stock_number = new_sn();
   p->insul_info = new_ii();
   p->begin_connect_pt = new_cpi();
   p->end_connect_pt = new_cpi();

   return p;
 }

 static void free_pi( p )
 part_info* p;
 {
   if(p->end_connect_pt)
    free_cpi(p->end_connect_pt);

   if(p->begin_connect_pt)
    free_cpi(p->begin_connect_pt);

   if(p->insul_info)
    free_ii(p->insul_info);

   if(p->stock_number)
    diag0_free(p->stock_number);

   diag0_free(p);
 }

/*
 static	pipe_attr *new_pa( )
 {
   pipe_attr* p = (pipe_attr *)diag_malloc( 04000, sizeof(pipe_attr) );

   if( p == 0 ) return 0;

   p->nom_pipe_size_type[0]	    = NULL;
   p->material_name[0]		    = NULL;
   p->wall_thickness_or_schedule[0] = NULL;
   p->pressure_rating_units[0]	    = NULL;
   p->comp_code[0]		    = NULL;

   return p;
 }

 static void free_pa( p )
 pipe_attr *p;
 {
    diag0_free( p );
 }
 */

static  port_info* new_poi()
{
  port_info *p = (port_info *)diag_malloc( 04000, sizeof(port_info) );

  if( p == 0 ) return 0;

  p->port_end_prep[0]      = NULL;
  p->nom_pipe_size_type[0] = NULL;

  return p;
 }

/*
 static void free_poi(p)
  port_info* p;
 {
	diag0_free(p);
 }
 */

/*
 static  piping_component_attr* new_pca()
 {
   piping_component_attr* p =
   (piping_component_attr *)diag_malloc( 04000, sizeof(piping_component_attr) );

   if( p == 0 )
    return 0;

   p->num_ports = (-1);

   p->comp_port_defs[0] = NULL;
   p->comp_port_defs[1] = NULL;
   p->comp_port_defs[2] = NULL;

   p->component_type 		    = -1;
   p->part_class[0]		    = NULL; 
   p->matl_desc[0]		    = NULL;
   p->matl_name[0]		    = NULL;
   p->wall_thickness_or_schedule[0] = NULL;
   p->comp_code[0]		    = NULL;

   return p;
 }

 static void free_pca(p)
  piping_component_attr* p;
 {

 	if (!(((p->num_ports)==(-1))))
	 {
	  int i;

	  for ((i) = 0; (i)<(p->num_ports); (i)++)
	  {
	   if(p->comp_port_defs[i])
	    free_poi(p->comp_port_defs[i]);
	  }

	 }

  diag0_free(p);
}
*/

int cpipcmp( cpip1, cpip2 )
connect_pt_id* cpip1;
connect_pt_id* cpip2;
{
  int cmp;

  if( cmp = gridpcmp(&cpip1->comp_id, &cpip2->comp_id) )
   return cmp;

  if( cmp = cpip1->conn_pt_id - cpip2->conn_pt_id )
   return cmp;

  return 0;
}


typedef struct pt_struct {
	struct GRid pt_grid;
	int pt_type;
	void* pt_part;
	part_info* pt_pi;
}* PT;

static PT pt_new( )
{
  PT pt = (PT)diag_malloc( 04000, sizeof(struct pt_struct) );
  pt->pt_grid.objid = NULL_OBJID;
  pt->pt_grid.osnum = 0;
  pt->pt_type = (-1);
  pt->pt_part = 0;
  pt->pt_pi = 0;

  return pt;
}

static void pt_free( pt )
PT pt;
{
  if( pt->pt_pi )
   free_pi( pt->pt_pi );

  if( !(pt->pt_type == -1) )
   if( pt->pt_part )
    switch( pt->pt_type )
    {
      case PART_TYPE_LINEAR_PIPE_SECTION:
       free_lpi((linear_pipe_info* )pt->pt_part); break;

      case PART_TYPE_BENT_PIPE_SECTION:
       free_bpi((bent_pipe_info* )pt->pt_part); break;

      case PART_TYPE_COMPONENT:
       free_ci((component_info* )pt->pt_part); break;
    }
   diag0_free( pt );
}

/*
static int ptcmp(pt1,pt2) PT pt1, pt2; {
	return gridpcmp(&pt1->pt_grid,
	                &pt2->pt_grid ); }

static struct lc_struct LLcontrol_pts_struct = { "pts", ptcmp, 0, 0, }; */

/* test only
typedef struct pr_struct {
	pipe_run_info pr_pri;
	LLNODE pr_gridps;
}* PR;
   test only */

/* test only
static PR pr_new()
{
  PR pr = (PR)diag_malloc( 04000, sizeof(struct pr_struct) );
  pr->pr_pri.pipe_spec[0] = NULL;
  *(pr->pr_pri.run_start) = new_cpi();*
  *  *(pr->pr_pri.run_start) = { { 0, 0, }, -1, };  *
  pr->pr_gridps = ll_new( &LLcontrol_gridps_struct, 0 );

  return pr;
}
 test only */

void part_free( part )
struct st_prpart *part;
{
  diag0_free( part );
}

static void pr_free( pr )
PR pr;
{
  if( pr->pr_parts )
   ll_freef( pr->pr_parts, part_free );

	/*if(pr->pr_gridps)
	 FREE_GRIDS(pr->pr_gridps);*/

	/*free_cpi((pr->pr_pri.run_start));*/
	if(pr->pr_pri.pipe_spec)
	  /*diag0_free(pr->pr_pri.pipe_spec);*/
	  /*pr->pr_pri.pipe_spec[0] = NULL;*/

  diag0_free( pr );
}

static int prcmp( pr1, pr2 )
PR pr1, pr2;
{
	return cpipcmp( &(pr1->pr_pri.run_start), &(pr2->pr_pri.run_start) );
}

static struct lc_struct LLcontrol_prs_struct = { "prs", prcmp, 0, 0, };





static PR prs_find_cpi( cpip, prs )
connect_pt_id* cpip;
LLNODE prs;
{
  struct pr_struct pr_st;
  PR pr = &pr_st;
  connect_pt_id cpt_st;

  cpt_st = *cpip;
  pr->pr_pri.run_start = cpt_st;

  return ll_find_object( pr, prs );
}

static PR diag_prs_find_cpi( dflags, cpip, prs )
int dflags;
connect_pt_id* cpip;
LLNODE prs;
{
  PR pr;

  if( (pr = prs_find_cpi(cpip, prs)) == 0 )
   diag( dflags, "Unknown pipe run: %ld %ld %d\n",
		 (long)cpip->comp_id.osnum, 
		 (long)cpip->comp_id.objid,
		 cpip->conn_pt_id );
	return pr;
}


typedef struct pl_struct {
	pipeline_info pl_pli;
	struct GRid pl_tipgrid;
	struct GMhcode pl_hc;
	int pl_hc_active;
	struct GMndgraph pl_ndg;
	int pl_ndg_active;
	struct VRgrinfo pl_gri;
	LLNODE pl_prs;
	pipe_run_info** pl_pria;
} * PL;


static PL pl_new()
{
	PL pl = ((PL)diag_malloc(04000,sizeof(struct pl_struct)));
	(pl->pl_pli.pipeline_id) = 0;
	pl->pl_pli.equipment_id.objid = NULL_OBJID;
	pl->pl_pli.equipment_id.osnum = 0;
	pl->pl_hc_active = 0;
	pl->pl_ndg_active = 0;
	pl->pl_prs = (ll_new((&LLcontrol_prs_struct),0));
	pl->pl_pria = 0;
	return pl; 
}

static void pl_free( pl )
PL pl;
{
  if( pl->pl_pria )
   pointera_free( pl->pl_pria );

  if( pl->pl_prs )
   ll_freef( pl->pl_prs, pr_free );

  if( pl->pl_ndg_active )
   GMndg_disactivate( &pl->pl_ndg );

  if( pl->pl_hc_active )
   GMh_disactivate( &pl->pl_hc );

  if( pl->pl_pli.pipeline_id )
   diag0_free( pl->pl_pli.pipeline_id );

  diag0_free( pl );
}

int plcmp( pl1, pl2 )
PL pl1, pl2;
{
  return str_cmp( pl1->pl_pli.pipeline_id, pl2->pl_pli.pipeline_id );
}

static struct lc_struct LLcontrol_pls_struct = { "pls", plcmp, 0, 0, };


static PL pls_find_id( id, pls )
charp id;
LLNODE pls;
{
  struct pl_struct pl_st;
  PL pl = &pl_st;

  (pl->pl_pli.pipeline_id) = id;

   return ll_find_object( pl, pls );
}

static PL diag_pls_find_id( dflags, id,pls )
int dflags;
charp id;
LLNODE pls;
{
 PL pl;

 if( ((pl = pls_find_id(id,pls))==0) )
 {
   diag( dflags, "Unknown pipeline: %s\n", id );
   return 0; /* Rishad - 26 June 1996 */
 }

 return pl;
}

static int pl_grid_in_ndg( pl,grid )
PL pl;
struct GRid grid;
{
  if( !(pl->pl_ndg_active) )
   return 0;

  return GMh_give_content( &grid, &pl->pl_ndg.hcode, 0, 0 );
}


static PL pls_find_grid_in_ndg( grid, pls )
struct GRid grid;
LLNODE pls;
{
  LLNODE ln;
  PL pl;

  /* for each pipe line */
  for((ln) = (LLNODE)(pls), 1; ((ln) = ((((LLNODE)(((ln)->ln_next)->ln_ll))==((ln)->ln_next)) ? 0 : (ln)->ln_next)) && ( 1 && ((pl)=(PL)((ln)->ln_object),1)); )
   if( pl_grid_in_ndg(pl,grid) )
    return pl;

  return 0;
}


typedef struct sy_struct {
	char sy_id[12];
	LLNODE sy_pls;
	pipeline_info** sy_plia;
}* SY;

static SY sy_new() { SY sy = ((SY)diag_malloc(04000,sizeof(struct sy_struct)));
	sy->sy_id[0] = NULL;
	sy->sy_pls = ll_new((&LLcontrol_pls_struct),0);
	sy->sy_plia = 0;
	return sy; }

static void sy_free( sy )
SY sy;
{
  if( sy->sy_plia )
   pointera_free( sy->sy_plia );

  ( sy->sy_pls && ll_free( sy->sy_pls ) );

  diag0_free( sy );
}

static int sycmp(sy1,sy2)
SY sy1, sy2;
{
 return str_cmp(sy1->sy_id, sy2->sy_id);
}

static struct lc_struct LLcontrol_sys_struct = { "sys", sycmp, 0, 0, };





static SY sys_find_id( id, sys )
charp id;
LLNODE sys;
{
  struct sy_struct sy_st;
  SY sy = &sy_st;

  strcpy( sy->sy_id, id );

  return ll_find_object( sy, sys );
}

static SY diag_sys_find_id( dflags,id,sys )
int dflags;
charp id;
LLNODE sys;
{
 SY sy;

 if( (sy = sys_find_id(id, sys)) == 0 )
 {
   diag( dflags, "Unknown piping system: %s\n", id );
   return 0; /* Rishad - 26 June 1996 */
 }

 return sy;
}

struct NonDirGraph
{
  struct GMndgraph ndg;
  IGRint NbTips;
  struct GRid Tips[RT_MAX_TIPS];
};

/* Global Variables */
static int Inited = 0;		/* TRUE if the Object Space has been read */
struct GRmd_env Active_env;	/* Module Environment */
static LLNODE Pls = 0;		/* Linked List of PipeLines */
static LLNODE Sys = 0;		/* Linked List of Piping Systems */
static charp* Syida = 0;	/* array of System Id.'s */
struct NonDirGraph *RTndgs;	/* Array of NDG's */
IGRint NbNdgs;			/* Number of NDG's */
IGRdouble *BranchCoords;
/*static IGRdouble (*BranchCoords)[3] = NULL;*/
static t_matrix  *BranchMatrix = NULL;
pipe_attr PipeAttr;		/* pipe attribute */
piping_component_attr PiCompAttr;/* piping component attribute */


#define VRMAXPARTS	500
#define INCREMENT	50
#define MAX_PARTS	100
#define GM_ALL     0xffff /* All the elements of the graph                    */

static void freeall( )
{
  debug("freeall: entry\n","");
  if( Pls )
    ll_freef( Pls, pl_free );
  
  Pls = NULL;

  if( Sys )
   ll_freef( Sys, sy_free );

  Sys = NULL;

  if( Syida )
   pointera_free( Syida );

  Syida = NULL;

  if( BranchCoords )
   diag0_free( BranchCoords );

  if( BranchMatrix )
   diag0_free( BranchMatrix );

  /*if( Pt )
   pt_free( Pt );*/

  debug("freeall: exit\n","");
}

int GetNdg( grid, index, numtips )
struct GRid *grid;
IGRint *index;
IGRint *numtips;
{
  IGRboolean Found = FALSE;
  IGRint ii;

  for( ii=0; ii < NbNdgs; ++ii )
  {
    if( RTndgs[ii].Tips[0].objid == grid->objid &&
	RTndgs[ii].Tips[0].osnum == grid->osnum )
    {
      *index = ii;
      *numtips = RTndgs[ii].NbTips;
      Found = TRUE;
      break;
    }
  }

  return Found;
}

int RT_init_read( batch_mode, route_file, db_name, db_username, db_passwd,
		  unit_flag )
int  batch_mode;
char *route_file;
char *db_name;
char *db_username;
char *db_passwd;
int  unit_flag;
{
  int sts = RTERR;
  int status, size, nb_byte, PiIndex;
  IGRlong msg;
  struct ACrg_coll SinglyAttr;
  struct GRid *SinglyList, grid, List[50];
  IGRint NbSingly, nunknown;
  LLNODE plln;					/* pointer to structure node */
  PL pl;					/* pointer to a PipeLine */
  IGRint i, FromCpt;
  /*pipe_run_info PipeRun[20]; 10 Sep 1995*/
  pipe_run_info PipeRun[50];
  struct GMhcode h_cut;
  struct VRgrinfo info_list;
  IGRint ii, jj;
  IGRboolean Found = FALSE;
  IGRint TipCount, numtips, index;
  struct GRid tmpgrid, LeadingTip;
  struct GRid NextId;
  IGRshort NextCptNum = -1;
  IGRint TmpCptNum = -1;

  Diag_debug = FALSE;

  SinglyList = &List[0];

  /* return if already initialized for read */

#ifdef DEBUG
  printf( "Inited:%d\n", Inited );
#endif

  /*if( Inited )
   return RTERR; works fine on my machine */

  BranchCoords = (IGRdouble *)diag_malloc( 04000, 30*sizeof(IGRdouble) );

  /*BranchCoords = (IGRdouble (*)[3])diag_malloc( 04000, 10*sizeof(IGRdouble) );*/

  if( BranchCoords == NULL )
   return RTERR;

  BranchMatrix = (t_matrix *)diag_malloc( 04000, 10*sizeof(t_matrix) );

  if( BranchMatrix == NULL )
   return RTERR;

  /* get new linked lists for PipeLines & Piping Systems. ll_new allocates
     memory and returns a pointer to a structure ( LLNODE ) */
  Pls = ll_new( &LLcontrol_pls_struct, 0 ); /* list of pipelines */
  Sys = ll_new( &LLcontrol_sys_struct, 0 ); /* lsit of PipingSystems */

  /* get active module environment */
  size = sizeof( Active_env );
  status =
  gr$get_module_env
  (
	 msg = &msg,
	 sizbuf = &size,
	 buffer = &Active_env,
	 nret = &nb_byte
  );
  gm$status();

  /* get all network tips in the Object Space */
  strcpy( SinglyAttr.name, VR_N_NB_CONNECT_IN );
  SinglyAttr.desc.type = AC_ATTRIB_DOUBLE;
  SinglyAttr.desc.value.att_exp = 1.0;
  vr$select_component(
	 pMsg = &msg,
	 Product = VR_PIPING,
	 NbSelect = 1,
	 pSelect = &SinglyAttr,
	 pAddrList = &SinglyList,
	 pNumber = &NbSingly
  );

  if( NbSingly == 0 )
  {
    printf( "No end components present\n" );
    return RTERR;
  }

  debug("RT_init_read: NbSingly = %d\n",NbSingly);

  /* count of Piping Systems whose system name is NULL */	
  nunknown = 0;

  /* start */
  RTndgs =
  (struct NonDirGraph *)alloca( RT_MAX_NW*sizeof(struct NonDirGraph) );

  if( !RTndgs )
  {
    printf( "No dynamic memory\n" );
    return RTERR;
  } 

  if( VDSverify_login() != PDM_S_SUCCESS )
  {
    printf( "No connection to database\n" );
    return RTERR_DB_LOGIN;
  }


  for( ii=0; ii < RT_MAX_NW; ++ii )
  {
    RTndgs[ii].NbTips = 0;
  }

  status = GMh_activate( DEF_MODULO, DEF_SIZE, DEF_SIZE, NULL,
			 sizeof(struct GRid), GMgridcmp, NULL, GMh_grid,
			 &h_cut);
  gm$status();

  status = GMndg_activate( DEF_MODULO, DEF_SIZE, &(RTndgs[0].ndg) );
  gm$status();

  info_list.p_add = (IGRchar *)&h_cut;
  info_list.p_md_env = &Active_env;

  status = GMndg_getgraph( &SinglyList[0], 1, VRget_allow_connect,
			     (IGRchar *)&info_list, &(RTndgs[0].ndg) );
  gm$status();

  RTndgs[0].Tips[0] = SinglyList[0];

  RTndgs[0].NbTips = 1;
  NbNdgs = 1;

  for( ii=1; ii < NbSingly; ii++ )
  {
   NbNdgs = 1;
   Found = FALSE;
   for( jj=0; jj < NbNdgs; jj++ )
   {
     if( GMh_give_content(&SinglyList[ii], &(RTndgs[jj].ndg.hcode), 0, 0) )
     {
       RTndgs[jj].Tips[RTndgs[jj].NbTips] = SinglyList[ii];
       ++(RTndgs[jj].NbTips);
       Found = TRUE;
       break;
     }
   }/* for jj */

   if( !Found )
   {
     status = GMndg_activate( DEF_MODULO, DEF_SIZE, &(RTndgs[NbNdgs].ndg) );
     gm$status();

     status = GMndg_getgraph( &SinglyList[ii], 1, VRget_allow_connect,
			      (IGRchar *)&info_list, &(RTndgs[NbNdgs].ndg) );
     gm$status();
     RTndgs[NbNdgs].Tips[0] = SinglyList[ii];
     RTndgs[NbNdgs].NbTips = 1;
     NbNdgs++;
   }
  }/* for ii */
  /* end */

#ifdef DEBUG
  printf( "Ndg  NbTips\n" );
  for( ii=0; ii < NbNdgs; ++ ii )
  {
    printf( "%2d)  %2d\n", ii+1, RTndgs[ii].NbTips );
  }
#endif

  /* for each tip */
  for( i=0; i < NbSingly; i++ )
  {
    PL pl, prevpl;
    PR pr;
    int ii;

    grid = SinglyList[i];

    debug("RT_init_read: %1ld %10ld\n",(long)grid.osnum,(long)grid.objid);

    /* skip, if this pipe line has been processed */
    if( prevpl = pls_find_grid_in_ndg(grid,Pls) )
     continue;

    NextId.objid = NULL_OBJID;
    NextCptNum   = -1;
    status = vr$review_topology ( pMsg = &msg,
                                  pComponent = &SinglyList[i],
                                  CptNum = 0,
                                  pNeighbor  = &NextId,
                                  pNeighCpt  = &TmpCptNum,
                                  pMdEnv = &Active_env );
    as$status( action = RET_STATUS );

    NextCptNum = (short)TmpCptNum;

    if( NextId.objid == NULL_OBJID )
      continue;

    /* new pipe line, allocate memory for a pipeline structure */
    pl = pl_new();
		
    /* insert pipeline into linked list */
    ll_insert(pl,Pls);

    /* save the GRid of the tip, usefull for PipeLine Id */		
    pl->pl_tipgrid = grid;

    /* new code */
    /* allocate memory for the hash code table in the pipe
       line structure */	
    status =
    GMh_activate(
    DEF_MODULO, DEF_SIZE, DEF_SIZE, 0, sizeof(struct GRid),
    GMgridcmp, 0 ,GMh_grid, &pl->pl_hc );
    gm$status();

    pl->pl_hc_active = TRUE;

    /* allocate memory for the hash table in the non directed
    graph in the pipeline data structure */
    status = GMndg_activate( DEF_MODULO, DEF_SIZE, &pl->pl_ndg );
    gm$status();

    pl->pl_ndg_active = TRUE;

    /* initialize struct VRGRInfo */		
    pl->pl_gri.p_add = ( IGRchar* )&pl->pl_hc;
    pl->pl_gri.p_md_env = &Active_env;

    /* get the network into the hash code table defined
    in the ND Graph */
    status = GMndg_getgraph(
    	     &pl->pl_tipgrid, 1, VRget_allow_connect, (IGRchar* )&pl->pl_gri,
   	     &pl->pl_ndg );
    gm$status();

    TipCount = 1;
    numtips  = 0;
    index    = -1;
    tmpgrid  = pl->pl_tipgrid;
    LeadingTip = pl->pl_tipgrid;

    do
    {
      /* Break the current PipeLine into PipeRuns */
      PiIndex = 0;
      FromCpt = -1;

      /*status = GetPipeRuns( &pl->pl_tipgrid, FromCpt, PipeRun,
                    &PiIndex, &Active_env, -1 );*/

      status = GetPipeRuns( &tmpgrid, FromCpt, PipeRun,
                    &PiIndex, &Active_env, -1 );

      if( status == ErrDangleLeadsToOlet )
      {
	if( GetNdg(&LeadingTip, &index, &numtips) )
	{
	  tmpgrid = RTndgs[index].Tips[TipCount++];
	}
	else
	{
	 break;
	}
      }
      else
       break;

    }while( status == ErrDangleLeadsToOlet &&
	    TipCount < numtips );

#ifdef DEBUG
    printf( "Number of Pipe Runs:%d\n", (PiIndex+1) );
#endif

    for( ii = 0; ii <= PiIndex; ++ ii )
    {
    	pr = pr_new();
        pr->pr_pri = PipeRun[ii];
        
	status = GetPipeRunParts( pr, &Active_env );
	ll_insert( pr, pl->pl_prs );

#ifdef DEBUG
           printf( "Run%2d) StartId:%d  StartCPNo:%d   EndId:%d  EndCPNo:%d\n",
		    (ii+1),
		    PipeRun[ii].run_start.comp_id.objid,
		    PipeRun[ii].run_start.conn_pt_id,
		    PipeRun[ii].run_end.comp_id.objid,
		    PipeRun[ii].run_end.conn_pt_id );
#endif

    }

    /*status = GMh_getlist(&pl->pl_ndg.hcode,0,0,&keya,&nkeys);
    gm$status();
    printf( "no components:%d\n", nkeys );*/
  }

  if( (LLNODE)(Pls)->ln_count == 0 )
  {
    printf( "No pipe lines found\n" );
    return RTERR;
  }

	/* for each pipe line in the linked list */
	for ((plln) = (LLNODE)(Pls), 1; ((plln) = ((((LLNODE)(((plln)->ln_next)->ln_ll))==((plln)->ln_next)) ? 0 : (plln)->ln_next)) && ( 1 && ((pl)=(PL)((plln)->ln_object),1)); )
	{
	  int NumbPar;
	  struct ACrg_coll AttList[10]; /* Array of parameters */
	  char syid[50];
	  IGRchar TmpStr[10];
	  SY sy;

	  /* get system id for the current pipeline */
    	  NumbPar = 1;
          /*strcpy( AttList[0].name, VR_N_FLUID_CODE_AN );*/
          strcpy( AttList[0].name, VR_N_SYST_NAME_AN );

          status =
          vr$review_parameters(         pMsg            = &msg,
                                        pComponent      = &pl->pl_tipgrid,
                                        NbParams        = NumbPar,
                                        pList           = AttList,
                                        pMdEnv          = &Active_env );

	if( !( status & 1 & msg ) )
	{
	  syid[0] = '\0';
	}
	else
         strcpy( syid, AttList[0].desc.value.att_txt );

	  /* if system id is NULL, treat this as a different piping
	     system */
	  if( strcmp(syid,"")==0 )
	  {
		nunknown++;
		sy = sy_new();
		sprintf( sy->sy_id, "%03d", nunknown );
		ll_insert(sy,Sys);
	  }
	  /* if system is not allready in the linked list */
	  else if( ((sy = sys_find_id(syid,Sys))==0) )
	       {
			sy = sy_new();
			/*sy->sy_id = str_copy(syid);*/
			strcpy( sy->sy_id, syid );
			ll_insert(sy,Sys);
		}
	   /* insert pipe line into that piping system */
	   ll_insert(pl,sy->sy_pls);

	   /*pl->pl_pli.pipeline_id = 
		csprintf( "%ld", pl->pl_tipgrid.objid );*/

	   pl->pl_pli.pipeline_id = (char *)malloc( 20*sizeof(char) );

	   if( !pl->pl_pli.pipeline_id )
	   {
	     status =  GM_E_NODYNMEM;
	     gm$status();
	   }

          /* get line sequence number */
          NumbPar = 1;
          strcpy( AttList[0].name, VR_N_SEQ_NUMBER_AN );

          status =
          vr$review_parameters(         pMsg            = &msg,
                                        pComponent      = &pl->pl_tipgrid,
                                        NbParams        = NumbPar,
                                        pList           = AttList,
                                        pMdEnv          = &Active_env );

          strcpy( pl->pl_pli.pipeline_id, AttList[0].desc.value.att_txt );
	  sprintf( TmpStr, "_%05d", pl->pl_tipgrid.objid );
	  TmpStr[6] = '\0';
 	  strcat( pl->pl_pli.pipeline_id, TmpStr );

	   /* sprintf( pl->pl_pli.pipeline_id, "%ld", pl->pl_tipgrid.objid ); */
	}

	Inited = TRUE;
	sts = RTSUCC; goto end;

	exception:
	end:
	if (sts != RTSUCC) freeall();

	debug("RT_init_read: returning with status %d\n",sts);

	return sts;
}

int RT_exit_read()
{
#ifdef DEBUG
	printf( "RT_exit_read\n" );
#endif
	if (!(Inited)) return RTERR;
	 freeall();

	Inited = 0;

	return RTSUCC;
}

int RT_get_piping_systems( np, bufp)
int* np; charp** bufp;
{
	int sts = RTERR_SYSTEMS;
	int n = 0;
	charp* buf = 0;

	if( !Inited ) goto end;

	if(Syida)
	  pointera_free( Syida );

	Syida = 0;
	if( Sys )
	 if( n = ( (Sys)->ln_count ), n > 0 )
	 { int i;

	   Syida = (charp* )ll_array(Sys,0);
	   for( (i) = 0; (i)<(n); (i)++)
	   { SY sy = (SY)Syida[i];
	     Syida[i] = sy->sy_id;
	   }
	 }
	buf = Syida;
	sts = RTSUCC;

	end:
	 *np = n;
	 *bufp = buf;
	 return sts;
}

int RT_get_pipelines( syid, np, bufp )
charp syid;
int* np;
pipeline_info ***bufp;
{
  int sts = RTERR_PIPELINE;
  int n = 0;
  pipeline_info **buf = 0;
  SY sy;

  if( !Inited ) goto end;

  if( ((sy = diag_sys_find_id(0,syid,Sys))==0) ) goto end;

	if(sy->sy_plia)
	  pointera_free(sy->sy_plia);

	sy->sy_plia = 0;

	if( sy->sy_pls )
	 if( n = ( (sy->sy_pls)->ln_count ), n > 0)
	 { int i;

		sy->sy_plia = (pipeline_info** )ll_array(sy->sy_pls,0);

		for((i) = 0; (i)<(n); (i)++)
		{ 
		  PL pl = (PL)sy->sy_plia[i];
		  sy->sy_plia[i] = &pl->pl_pli;

#ifdef DEBUG
		  printf( "pipe line id:%s\n", sy->sy_plia[i]->pipeline_id );
#endif
		 }
	 }

	buf = sy->sy_plia;
	sts = RTSUCC;

	end:
	 *np = n;
	 *bufp = buf;
	 return sts;
}

int RT_get_pipe_runs( syid, plid, np, bufp )
charp syid;
charp plid;
int* np;
pipe_run_info*** bufp;
{
	int sts = RTERR_PRUN;
	int n = 0;
	pipe_run_info** buf = 0;
	SY sy;
	PL pl;

	if( !Inited ) goto end;

	if(((sy = diag_sys_find_id(0,syid,Sys))==0)) goto end;

	if(((pl = diag_pls_find_id(0,plid,sy->sy_pls))==0)) goto end;

	if(pl->pl_pria)
	  pointera_free(pl->pl_pria);

	pl->pl_pria = 0;

	if( pl->pl_prs )
	 if( n = ( (pl->pl_prs)->ln_count ), n > 0 )
	 { int i;
		pl->pl_pria = (pipe_run_info** )ll_array(pl->pl_prs,0);
		for( (i) = 0; (i)<(n); (i)++ )
		{
		  PR pr = (PR)pl->pl_pria[i];
		  pl->pl_pria[i] = &pr->pr_pri;
		 }
	 }

	buf = pl->pl_pria;
	sts = RTSUCC;
	end: *np = n; *bufp = buf; return sts;
}

static int resolve_pt( pt, BeginCptNo, EndCptNo )
PT  pt;
int BeginCptNo, EndCptNo;
{
  struct GRid grid = pt->pt_grid;
  IGRint comptype, ii, jj;
  int status = TRUE, NumbPar;
  IGRlong msg;
  struct ACrg_coll AttList[5];
  IGRdouble matrix[16], startmatrix[16], endmatrix[16],
	    BrnPtMatrix[16];
  IGRshort NbCpts;

  /* get component type */
  NumbPar = 1;

  strcpy( AttList[0].name, VR_N_COMP_TYPE_IN );

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = &grid,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = &Active_env );

  if( status != OM_S_SUCCESS )
  {
   return RTERR;
  }

  /*as$status( action = RET_STATUS );*/

  comptype = (IGRint)AttList[0].desc.value.att_exp;

#ifdef DEBUG
  printf( "CompType:%d\n", comptype );
#endif

  switch( comptype )
  {
    case VRP_V_PIPE_TYPE:
#ifdef DEBUG
     printf( "Linear\n" );
#endif
     pt->pt_type = PART_TYPE_LINEAR_PIPE_SECTION;
     break;

    case VRP_V_BEND_TYPE     :
    case VRP_V_HEL_BEND_TYPE :
#ifdef DEBUG
     printf( "Bent\n" );
#endif
     pt->pt_type = PART_TYPE_BENT_PIPE_SECTION;
     break;

    case VR_V_ERROR_TYPE:
    case VR_V_DANGLING_TYPE:
#ifdef DEBUG
     printf( "Dangle - return RT_END_PIPE_RUN\n" );
#endif
     return VR_V_DANGLING_TYPE;
     /*return RTSUCC;*/

    case VRP_V_ELBOW_TYPE    :
    default:
#ifdef DEBUG
     printf( "Component\n" );
#endif
     pt->pt_type = PART_TYPE_COMPONENT;
     break;
  }

  status = vr$review_topology( pMsg = &msg,
                               pComponent = &grid,
                               CptNum = BeginCptNo,
			       pMatrix = startmatrix,
                               pMdEnv = &Active_env );
  as$status( action = RET_STATUS );

  /* in case a pipe section has no terminating dangle - almost imposs. */
  if( EndCptNo == -1 &&
      (pt->pt_type == PART_TYPE_LINEAR_PIPE_SECTION ||
       pt->pt_type == PART_TYPE_BENT_PIPE_SECTION) )
  {
    if( BeginCptNo == 0 )
     EndCptNo = 1;
    else
     EndCptNo = 0;
  }

  if( EndCptNo != -1 )
  {
    status = vr$review_topology( pMsg = &msg,
                                 pComponent = &grid,
                                 CptNum = EndCptNo,
			         pMatrix = endmatrix,
                                 pMdEnv = &Active_env );
    as$status( action = RET_STATUS );
  }


  status = vr$review_topology( pMsg = &msg,
                               pComponent = &grid,
                               CptNum = BeginCptNo,
			       pTee = matrix,
                               pMdEnv = &Active_env );
  as$status( action = RET_STATUS );


  switch( pt->pt_type )
  {
    case PART_TYPE_LINEAR_PIPE_SECTION:
     /* allocate memory for linear pipe info */
     pt->pt_part = (void *)new_lpi( );
     
     /* load start & end coordinates into linear pipe info */
     ((linear_pipe_info *)(pt->pt_part))->start_coord[0] = startmatrix[3];
     ((linear_pipe_info *)(pt->pt_part))->start_coord[1] = startmatrix[7];
     ((linear_pipe_info *)(pt->pt_part))->start_coord[2] = startmatrix[11];

     ((linear_pipe_info *)(pt->pt_part))->end_coord[0] = endmatrix[3];
     ((linear_pipe_info *)(pt->pt_part))->end_coord[1] = endmatrix[7];
     ((linear_pipe_info *)(pt->pt_part))->end_coord[2] = endmatrix[11];

     /* get number of cpts */
     NumbPar = 1;
     strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

     status =
     vr$review_parameters( pMsg            = &msg,
                           pComponent      = &grid,
                           NbParams        = NumbPar,
                           pList           = AttList,
                           pMdEnv          = &Active_env );
     as$status( );
     NbCpts = (IGRint)AttList[0].desc.value.att_exp;

     ((linear_pipe_info *)(pt->pt_part))->n_branch_ports = NbCpts - 2;

     for( ii=0,jj=0; ii < NbCpts; ++ ii )
     {
       if( ii == BeginCptNo ||
	   ii == EndCptNo )
        continue;

       status = vr$review_topology( pMsg = &msg,
                                    pComponent = &grid,
                                    CptNum = ii,
			            pMatrix = BrnPtMatrix,
                                    pMdEnv = &Active_env );
       as$status( action = RET_STATUS );

       BranchCoords[jj*3 + 0] = BrnPtMatrix[3];
       BranchCoords[jj*3 + 1] = BrnPtMatrix[7];
       BranchCoords[jj*3 + 2] = BrnPtMatrix[11];

       /*BranchCoords[jj][0] = BrnPtMatrix[3];
       BranchCoords[jj][1] = BrnPtMatrix[7];
       BranchCoords[jj][2] = BrnPtMatrix[11];*/

       BranchMatrix[jj].x[0] = BrnPtMatrix[0];
       BranchMatrix[jj].x[1] = BrnPtMatrix[4];
       BranchMatrix[jj].x[2] = BrnPtMatrix[8];

       BranchMatrix[jj].y[0] = BrnPtMatrix[1];
       BranchMatrix[jj].y[1] = BrnPtMatrix[5];
       BranchMatrix[jj].y[2] = BrnPtMatrix[9];

       BranchMatrix[jj].z[0] = BrnPtMatrix[2];
       BranchMatrix[jj].z[1] = BrnPtMatrix[6];
       BranchMatrix[jj].z[2] = BrnPtMatrix[10];

       BranchMatrix[jj].translate[0] = BrnPtMatrix[3];
       BranchMatrix[jj].translate[1] = BrnPtMatrix[7];
       BranchMatrix[jj].translate[2] = BrnPtMatrix[11];

       jj++;
     }

     if( NbCpts - 2 )
     {
       ((linear_pipe_info *)(pt->pt_part))->branch_coords =
				    (IGRdouble *)BranchCoords;

       ((linear_pipe_info *)(pt->pt_part))->branch_matrix =
				    (t_matrix *)BranchMatrix;
     }
     else
     {
       ((linear_pipe_info *)(pt->pt_part))->branch_coords = NULL;

       ((linear_pipe_info *)(pt->pt_part))->branch_matrix = NULL;
     }

     break;

     case PART_TYPE_BENT_PIPE_SECTION:
      /* allocate memory for bent pipe info */
      pt->pt_part = (void *)new_bpi( );

     /* load start & end coordinates into bent pipe info */
     ((bent_pipe_info *)(pt->pt_part))->start_coord[0] = startmatrix[3];
     ((bent_pipe_info *)(pt->pt_part))->start_coord[1] = startmatrix[7];
     ((bent_pipe_info *)(pt->pt_part))->start_coord[2] = startmatrix[11];

     ((bent_pipe_info *)(pt->pt_part))->end_coord[0] = endmatrix[3];
     ((bent_pipe_info *)(pt->pt_part))->end_coord[1] = endmatrix[7];
     ((bent_pipe_info *)(pt->pt_part))->end_coord[2] = endmatrix[11];

     ((bent_pipe_info *)(pt->pt_part))->n_branch_ports = 0;
     ((bent_pipe_info *)(pt->pt_part))->branch_coords = NULL;

     /* load center coordinates & xformation-matrix into bent pipe info */
     ((bent_pipe_info *)(pt->pt_part))->center_coord[0] = matrix[3];
     ((bent_pipe_info *)(pt->pt_part))->center_coord[1] = matrix[7];
     ((bent_pipe_info *)(pt->pt_part))->center_coord[2] = matrix[11];

     /* x vextor */
     ((bent_pipe_info *)(pt->pt_part))->transform.x[0] = matrix[0];
     ((bent_pipe_info *)(pt->pt_part))->transform.x[1] = matrix[4];
     ((bent_pipe_info *)(pt->pt_part))->transform.x[2] = matrix[8];

     /* y vextor */
     ((bent_pipe_info *)(pt->pt_part))->transform.y[0] = matrix[1];
     ((bent_pipe_info *)(pt->pt_part))->transform.y[1] = matrix[5];
     ((bent_pipe_info *)(pt->pt_part))->transform.y[2] = matrix[9];

     /* z vextor */
     ((bent_pipe_info *)(pt->pt_part))->transform.z[0] = matrix[2];
     ((bent_pipe_info *)(pt->pt_part))->transform.z[1] = matrix[6];
     ((bent_pipe_info *)(pt->pt_part))->transform.z[2] = matrix[10];

     /* origin */
     ((bent_pipe_info *)(pt->pt_part))->transform.translate[0] = matrix[3];
     ((bent_pipe_info *)(pt->pt_part))->transform.translate[1] = matrix[7];
     ((bent_pipe_info *)(pt->pt_part))->transform.translate[2] = matrix[11];


      NumbPar = 1;
      strcpy( AttList[0].name, VR_N_BEND_ANG_DB );
      status =
      vr$review_parameters( pMsg            = &msg,
                            pComponent      = &grid,
                            NbParams        = NumbPar,
                            pList           = AttList,
                            pMdEnv          = &Active_env );

      if( status != OM_S_SUCCESS )
      {
       printf( "vr$review_parameters failed\n" );
        return RTERR;
      }

#ifdef DEBUG
      printf( "bend_angle:%lf\n", AttList[0].desc.value.att_exp );
#endif
      break;
  

     case PART_TYPE_COMPONENT:
      /* allocate memory for component info */
      pt->pt_part = (void* )new_ci();

     /* load start & end CP coordinates first into comp info *
     ((component_info *)(pt->pt_part))->port_coords[0][0] = startmatrix[3];
     ((component_info *)(pt->pt_part))->port_coords[0][1] = startmatrix[7];
     ((component_info *)(pt->pt_part))->port_coords[0][2] = startmatrix[11];

     ((component_info *)(pt->pt_part))->port_coords[1][0] = endmatrix[3];
     ((component_info *)(pt->pt_part))->port_coords[1][1] = endmatrix[7];
     ((component_info *)(pt->pt_part))->port_coords[1][2] = endmatrix[11]; */

     /* load xformation-matrix into comp info */

     /* x vextor */
     ((component_info *)(pt->pt_part))->transform.x[0] = matrix[0];
     ((component_info *)(pt->pt_part))->transform.x[1] = matrix[4];
     ((component_info *)(pt->pt_part))->transform.x[2] = matrix[8];

     /* y vextor */
     ((component_info *)(pt->pt_part))->transform.y[0] = matrix[1];
     ((component_info *)(pt->pt_part))->transform.y[1] = matrix[5];
     ((component_info *)(pt->pt_part))->transform.y[2] = matrix[9];

     /* z vextor */
     ((component_info *)(pt->pt_part))->transform.z[0] = matrix[2];
     ((component_info *)(pt->pt_part))->transform.z[1] = matrix[6];
     ((component_info *)(pt->pt_part))->transform.z[2] = matrix[10];

     /* origin */
     ((component_info *)(pt->pt_part))->transform.translate[0] = matrix[3];
     ((component_info *)(pt->pt_part))->transform.translate[1] = matrix[7];
     ((component_info *)(pt->pt_part))->transform.translate[2] = matrix[11];

      NumbPar = 1;
      strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

      status =
      vr$review_parameters( pMsg            = &msg,
                            pComponent      = &grid,
                            NbParams        = NumbPar,
                            pList           = AttList,
                            pMdEnv          = &Active_env );

      NbCpts = (IGRint)AttList[0].desc.value.att_exp;
#ifdef DEBUG
      printf( "NbCpts:%d\n", NbCpts );
#endif

      /* load number of connect points into comp info */
      ((component_info *)(pt->pt_part))->n_ports = NbCpts;

	for( ii=0; ii < NbCpts; ++ii )
        {
          status = vr$review_topology ( pMsg = &msg,
                                    pComponent = &grid,
                                    CptNum = ii,
			            pMatrix = matrix,
                                    pMdEnv = &Active_env );
          as$status( action = RET_STATUS );

          /* load the coordinates of the other connect point */
          ((component_info *)(pt->pt_part))->port_coords[ii][0] = matrix[3];
          ((component_info *)(pt->pt_part))->port_coords[ii][1] = matrix[7];
          ((component_info *)(pt->pt_part))->port_coords[ii][2] = matrix[11];

	  /* fill up transformation matrix for port ii */
	  ((component_info *)(pt->pt_part))->port_matrix[ii].x[0] = matrix[0];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].x[1] = matrix[4];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].x[2] = matrix[8];

	  ((component_info *)(pt->pt_part))->port_matrix[ii].y[0] = matrix[1];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].y[1] = matrix[5];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].y[2] = matrix[9];

	  ((component_info *)(pt->pt_part))->port_matrix[ii].z[0] = matrix[2];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].z[1] = matrix[6];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].z[2] = matrix[10];

	  ((component_info *)(pt->pt_part))->port_matrix[ii].translate[0] =
		matrix[3];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].translate[1] =
		matrix[7];
	  ((component_info *)(pt->pt_part))->port_matrix[ii].translate[2] =
		matrix[11];
	}

      break;
  }

  pt->pt_pi = new_pi( );
  pt->pt_pi->begin_connect_pt->conn_pt_id = BeginCptNo;
  pt->pt_pi->end_connect_pt->conn_pt_id   = EndCptNo;

  pt->pt_pi->begin_connect_pt->comp_id = pt->pt_grid;

  if( EndCptNo == -1 )
   pt->pt_pi->end_connect_pt->comp_id.objid = NULL_OBJID;
  else
   pt->pt_pi->end_connect_pt->comp_id   = pt->pt_grid;

  pt->pt_pi->part_id = pt->pt_grid;
  pt->pt_pi->num_supports = 0;

	/* ?? pt->pt_pi->insul_info->thickness_units
	?? pt->pt_pi->num_supports
	?? pt->pt_pi->eqp_port_name */


      NumbPar = 3;
      strcpy( AttList[0].name, VR_N_INSUL_TYPE_AN );
      strcpy( AttList[1].name, VR_N_INSUL_THK_DB );
      strcpy( AttList[2].name, VR_N_PDM_PART_NUM_AN );

      status =
      vr$review_parameters( pMsg            = &msg,
                            pComponent      = &grid,
                            NbParams        = NumbPar,
                            pList           = AttList,
                            pMdEnv          = &Active_env );

      /* load insulation-type, insulation-thickness & stock-number */
      strcpy( pt->pt_pi->insul_info->matl_desc,
		 AttList[0].desc.value.att_txt );

      pt->pt_pi->insul_info->thickness = AttList[1].desc.value.att_exp;

      pt->pt_pi->insul_info->thickness_units[0] = NULL;

      strcpy( pt->pt_pi->stock_number, AttList[2].desc.value.att_txt );

  return RTSUCC;
}

int RT_get_pipe_attributes( grid, attrp  )
struct GRid *grid;
pipe_attr** attrp;
{
  pipe_attr *pa = 0;
  int status = TRUE, NumbPar;
  struct ACrg_coll AttList[12];
  IGRlong msg;
  IGRchar LongText[40], error[30];

  if( !Inited ) return RTERR;

  if( grid->objid == NULL_OBJID )
   return RTERR;

  *attrp = 0;

  /* initialize pipe attributes structure */
  PipeAttr.nom_pipe_size = 0;
  PipeAttr.nom_pipe_size_type[0] = '\0';
  PipeAttr.material_name[0] = '\0';
  PipeAttr.wall_thickness_or_schedule[0] = '\0';
  PipeAttr.pressure_rating = 0;
  PipeAttr.pressure_rating_units[0] = '\0';
  PipeAttr.pipe_outside_diameter = 0;
  PipeAttr.comp_code[0] = '\0';
  PipeAttr.g_size = 0;
  PipeAttr.r_size = 0;
  PipeAttr.opt_code = -1;

  pa = &PipeAttr;

  /* get component attributes */
  NumbPar = 9;

  strcpy( AttList[0].name, VR_N_GDIAMETER_DB );		/* npd green */
  strcpy( AttList[1].name, VR_N_RDIAMETER_DB );		/* npd red */
  strcpy( AttList[2].name, VR_N_COMP_CODE_AN );		/* component code */
  strcpy( AttList[3].name, VR_N_OPTION_IN );		/* option code */
  strcpy( AttList[4].name, VR_N_RATING_G_DB );		/* pres. rating green */
  strcpy( AttList[5].name, VR_N_SCH_THK_G_AN );		/* sched. thickness g */
  strcpy( AttList[6].name, VR_N_MATERIAL_IN );		/* material */
  strcpy( AttList[7].name, VR_N_UNIT_AN );		/* units */
  strcpy( AttList[8].name, VR_N_THK_G_DB );		/* thickness green */

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = grid,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = &Active_env );

  if( status != OM_S_SUCCESS )
  {
   printf( "vr$review_parameters failed\n" );
   return RTERR;
  }

  pa->nom_pipe_size = AttList[0].desc.value.att_exp;
  strcpy( pa->wall_thickness_or_schedule, AttList[5].desc.value.att_txt );
  pa->pressure_rating = AttList[4].desc.value.att_exp;
  pa->pipe_outside_diameter =
	 (pa->nom_pipe_size) + ((AttList[8].desc.value.att_exp));
  strcpy( pa->comp_code, AttList[2].desc.value.att_txt );
  pa->g_size = AttList[0].desc.value.att_exp;
  pa->r_size = AttList[1].desc.value.att_exp;
  pa->opt_code = (int)AttList[3].desc.value.att_exp;

  /* get code listed attribute */
  LongText[0] = NULL;
  status = vd$get_alias( p_msg = &msg,
			 product = PIPING,
			 type = VR_MATLCODE_LIST_NUM,
			 i_code = (IGRint)AttList[6].desc.value.att_exp,
			 o_lname = LongText,
			 p_error = error );

  strcpy( pa->material_name, LongText );

  switch ( VRenq_proj_units() )
  {
    case VR_METRIC_UNITS :
     strcpy( pa->nom_pipe_size_type, "mm" );
     strcpy( pa->pressure_rating_units, "metric" );
       break;

    case VR_IMPERIAL_UNITS :
     strcpy( pa->nom_pipe_size_type, "IPS" );
     strcpy( pa->pressure_rating_units, "psi" );
       break;

    case VR_MIXED_UNITS :
     strcpy( pa->nom_pipe_size_type, "mixed" );
     strcpy( pa->pressure_rating_units, "mixed" );
      break;

    default:
     strcpy( pa->nom_pipe_size_type, "unknown" );
     strcpy( pa->pressure_rating_units, "unknown" );

   }/* end switch on unit */


  *attrp = pa;

  return RTSUCC;
}

int RT_get_piping_component_attr( grid, attrp )
struct GRid *grid;
piping_component_attr **attrp;
{
  piping_component_attr *pca;
  int status = TRUE, NumbPar;
  struct ACrg_coll AttList[10];
  IGRlong msg;
  IGRint comp_type = -1, ii;
  struct VRcp_attr CpAttr;
  int units;
  IGRchar LongText[40], error[30];

  if( !(Inited) ) return RTERR;

  if( grid->objid == NULL_OBJID )
   return RTERR;

  *attrp = 0;


  /* initialize piping component attributes */
  PiCompAttr.num_ports = 0;
  PiCompAttr.comp_port_defs[0] = NULL;
  PiCompAttr.comp_port_defs[1] = NULL;
  PiCompAttr.comp_port_defs[2] = NULL;
  PiCompAttr.component_type = -1;
  PiCompAttr.part_class[0] = '\0';
  PiCompAttr.matl_desc[0] = '\0';
  PiCompAttr.matl_name[0] = '\0';
  PiCompAttr.wall_thickness_or_schedule[0] = '\0';
  PiCompAttr.comp_code[0] = '\0';
  PiCompAttr.g_size = 0;
  PiCompAttr.r_size = 0;
  PiCompAttr.opt_code = -1;

  pca = &PiCompAttr;

  NumbPar = 9;
  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );
  strcpy( AttList[1].name, VR_N_COMP_TYPE_IN );
  strcpy( AttList[2].name, VR_N_MATERIAL_IN );
  strcpy( AttList[3].name, VR_N_COMP_CODE_AN );
  strcpy( AttList[4].name, VR_N_SCH_THK_G_AN );
  strcpy( AttList[5].name, VR_N_COMP_CODE_AN );
  strcpy( AttList[6].name, VR_N_OPTION_IN );
  strcpy( AttList[7].name, VR_N_GDIAMETER_DB );		/* npd green */
  strcpy( AttList[8].name, VR_N_RDIAMETER_DB );		/* npd red */

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = grid,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = &Active_env );

  if( status != OM_S_SUCCESS )
  {
   printf( "vr$review_parameters failed\n" );
   return RTERR;
  }

  pca->num_ports = (IGRint)AttList[0].desc.value.att_exp;

  comp_type = (IGRint)AttList[1].desc.value.att_exp;

  /* get code listed attribute */
  LongText[0] = NULL;
  status = vd$get_alias( p_msg = &msg,
			 product = PIPING,
			 type = VR_MATLCODE_LIST_NUM,
			 i_code = (IGRint)AttList[2].desc.value.att_exp,
			 o_lname = LongText,
			 p_error = error );

  strcpy( pca->matl_name, LongText );

  pca->matl_desc[0] = '\0';

  strcpy( pca->part_class, AttList[3].desc.value.att_txt );


  switch( comp_type )
  {
    case VRP_V_INSTRUMENT_TYPE:
     pca->component_type = RT_INSTRUMENT;
     break;

    case VRP_V_SPECIALITY_TYPE:
     pca->component_type = RT_ENGINEERED;
     break;

    default:
     pca->component_type = RT_COMMODITY;
  }

  units = VRenq_proj_units();

  strcpy( pca->wall_thickness_or_schedule,
		AttList[4].desc.value.att_txt );

  strcpy( pca->comp_code,
		AttList[5].desc.value.att_txt );

  pca->opt_code = (IGRint)(AttList[6].desc.value.att_exp);


  for( ii=0; ii < pca->num_ports; ++ii )
  {
    pca->comp_port_defs[ii] = new_poi();

    status = VR$GetCptInfo( p_retmsg = &msg,
                            p_CmpId = grid,
                            CmpCptNum = ii,
                            p_CptCoord  = (pca->comp_port_defs[ii]->cp_coord),
                            p_CptProp   = &CpAttr,
                            p_MdEnv = &Active_env
                    );
    as$status( action = RET_STATUS );

    pca->comp_port_defs[ii]->nom_pipe_size = CpAttr.width;

    sprintf( pca->comp_port_defs[ii]->port_end_prep, "%d", CpAttr.end_prep );

    /* get code listed attribute */
    LongText[0] = NULL;
    status = vd$get_alias( p_msg = &msg,
			 product = PIPING,
			 type = VR_PREPCODE_LIST_NUM,
			 i_code = CpAttr.end_prep,
			 o_lname = LongText,
			 p_error = error );

    strcpy( pca->comp_port_defs[ii]->port_end_prep, LongText );

    pca->comp_port_defs[ii]->pressure_ratings = CpAttr.pressure;


   switch( units )
   {
     case VR_IMPERIAL_UNITS:
      strcpy( pca->comp_port_defs[ii]->nom_pipe_size_type, "IPS" );
      pca->comp_port_defs[ii]->pressure_rating_unit = RT_psi;
      break;

     case VR_METRIC_UNITS:
      strcpy( pca->comp_port_defs[ii]->nom_pipe_size_type, "mm" );
      pca->comp_port_defs[ii]->pressure_rating_unit = RT_kpa;
      break;

     case VR_MIXED_UNITS:
      strcpy( pca->comp_port_defs[ii]->nom_pipe_size_type, "mixed" );
      pca->comp_port_defs[ii]->pressure_rating_unit = -1;
      break;

     default:
      strcpy( pca->comp_port_defs[ii]->nom_pipe_size_type, "unknown" );
      pca->comp_port_defs[ii]->pressure_rating_unit = -1;
   }
  
  }

  pca->g_size = AttList[7].desc.value.att_exp;
  pca->r_size = AttList[8].desc.value.att_exp;

  /* material description ? */

	*attrp = pca;
	return RTSUCC;
}

IGRint GetPipeRunParts( pr, ModEnv )
PR pr;
struct GRmd_env *ModEnv;
{
  struct GRid *CompId, NextId, NeighId;
  IGRint CptNum, status = TRUE, NumbPar,
	 ii, NbCpts;
  IGRshort NextCptNum, NeighCptNum;
  IGRint TmpCptNum = -1;
  IGRlong msg;
  struct ACrg_coll AttList[5];
  struct st_prpart tmp_part;
  IGRboolean bBranchPort = FALSE;
  IGRchar CompCode[7], NeighCompCode[7], TipCompCode[7];

  NextId.objid = NULL_OBJID;
  NextId.osnum = 0;

  /* if there is only one part in this pipe run */
  if( pr->pr_pri.run_start.comp_id.objid == pr->pr_pri.run_end.comp_id.objid &&
      pr->pr_pri.run_start.comp_id.osnum == pr->pr_pri.run_end.comp_id.osnum )
  {
    /* Control will never come here  o ====== o*/  
    tmp_part.grid = pr->pr_pri.run_start.comp_id;
    ll_insert( prpart_copy(&tmp_part), pr->pr_parts );

    return(TRUE);
  }

  CompId = &(pr->pr_pri.run_start.comp_id);
  CptNum   = pr->pr_pri.run_start.conn_pt_id;

  while( !(CompId->objid == pr->pr_pri.run_end.comp_id.objid &&
           CompId->osnum == pr->pr_pri.run_end.comp_id.osnum) )
  {
    /* get component code *
    NumbPar = 1;
    strcpy( AttList[0].name, VR_N_COMP_CODE_AN );

    status =
    vr$review_parameters(  pMsg            = &msg,
                           pComponent      = CompId,
                           NbParams        = NumbPar,
                           pList           = AttList,
                           pMdEnv          = ModEnv );

    strcpy( TipCompCode, AttList[0].desc.value.att_txt );

    * if the NetWork tip is not a dangle it should be saved *
    if( strcmp(TipCompCode, "dangle") != 0 )
    {
      tmp_part.grid = CompId->objid;
    } */

    status = vr$review_topology ( pMsg = &msg,
                                pComponent = CompId,
                                CptNum = CptNum,
                                pNeighbor  = &NextId,
                                pNeighCpt  = &TmpCptNum,
                                pMdEnv = ModEnv );
    as$status( action = RET_STATUS );

    NextCptNum = (short)TmpCptNum;

    tmp_part.begincpi.conn_pt_id = NextCptNum;
  
    /* get number of CPs */
    NumbPar = 2;
    strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );
    strcpy( AttList[1].name, VR_N_COMP_CODE_AN );

    status =
    vr$review_parameters(   pMsg            = &msg,
                           pComponent      = &NextId,
                           NbParams        = NumbPar,
                           pList           = AttList,
                           pMdEnv          = ModEnv );

    NbCpts = (IGRint)AttList[0].desc.value.att_exp;
    strcpy( CompCode, AttList[1].desc.value.att_txt );

    if( NbCpts > 2 &&
	strcmp(CompCode, "PIPING" ) == 0 )
    {
      bBranchPort = TRUE;
    }

    for( ii=0; ii < NbCpts; ++ii )
    {
      if( ii == NextCptNum )
       continue;
      else if( bBranchPort )
      {
        /* get the neighbor */
        status = vr$review_topology ( pMsg = &msg,
                                      pComponent = &NextId,
                                      CptNum = ii,
                                      pNeighbor  = &NeighId,
                                      pNeighCpt  = &TmpCptNum,
                                      pMdEnv = ModEnv );
        as$status( action = RET_STATUS );

	NeighCptNum = (short)TmpCptNum;

        NumbPar = 1;
        strcpy( AttList[0].name, VR_N_COMP_CODE_AN );

        status =
        vr$review_parameters( pMsg            = &msg,
                             pComponent      = &NeighId,
                             NbParams        = NumbPar,
                             pList           = AttList,
                             pMdEnv          = ModEnv );

        strcpy( NeighCompCode, AttList[0].desc.value.att_txt );

	if( strcmp(&NeighCompCode[1], "OLET" ) == 0 )
	 continue;
	else
	 CptNum = ii;
      }
      else
       CptNum = ii;
    }

    bBranchPort = FALSE;

    CompId = &NextId;

    tmp_part.grid = NextId;
    tmp_part.begincpi.comp_id = tmp_part.grid;

    if( NextId.objid == pr->pr_pri.run_end.comp_id.objid &&
	NextId.osnum == pr->pr_pri.run_end.comp_id.osnum ) /* end of run */
    {
      tmp_part.endcpi.conn_pt_id = -1;
      tmp_part.endcpi.comp_id.objid = NULL_OBJID;
    }
    else
    {
      tmp_part.endcpi.conn_pt_id = CptNum;
      tmp_part.endcpi.comp_id = tmp_part.grid;
    }

#ifdef DEBUG
    printf( "Begin:%d  Part Objid:%d  End:%d\n",
	     tmp_part.begincpi.conn_pt_id,
	     CompId->objid,
	     tmp_part.endcpi.conn_pt_id );
#endif

    ll_insert( prpart_copy(&tmp_part), pr->pr_parts );

  }


  return(status);
}

int RT_get_pipe_run_part( syid, plid, cpip, part_type, part, partinfo )
charp syid;
charp plid;
connect_pt_id* cpip;
int* part_type;
void** part;
part_info** partinfo;
{
	static PT pt = 0;
	static charp syid0 = 0;
	static charp plid0 = 0;
	static connect_pt_id cpi0 = { { 0, 0, }, -1, };
	static SY sy = 0;
	static PL pl = 0;
	static PR pr = 0;
	static LLNODE gridpln = 0;
	/*struct GRid *gridp;*/
        struct st_prpart *tmp_part_ptr;
	int jnk;

	if( !Inited ) return RTERR;

	*part_type = (-1);
	*part = 0;
	*partinfo = 0;
	

	if( str_cmp( syid0, syid ) == 0 &&
	    str_cmp( plid0,plid )  == 0 &&
	    cpipcmp(&cpi0,cpip)    == 0    )
	{
         goto next;
	}


	if(syid0)
	  diag0_free(syid0);

	 syid0 = 0;

	if(plid0)
	  diag0_free(plid0);

	plid0 = 0;

        cpi0.comp_id.objid = NULL_OBJID;
        cpi0.comp_id.osnum = 0;
	cpi0.conn_pt_id    = -1;

	sy = 0;
	pl = 0;
	pr = 0;
	gridpln = 0;

	if( (sy = diag_sys_find_id(0, syid, Sys)) == 0 )
	 return RTERR;

	if( (pl = diag_pls_find_id(0, plid, sy->sy_pls)) == 0 )
	 return RTERR;

	if( (pr = diag_prs_find_cpi(0, cpip, pl->pl_prs)) == 0 )
	 return RTERR;

	syid0 = str_copy(syid);
	plid0 = str_copy(plid);
	cpi0 = *cpip;

	
	/* contains the GRid's of the Piping Parts in that Pipe Run */
	/* test only
	gridpln = pr->pr_gridps;
	   test only */

	gridpln = pr->pr_parts;

	next:
	if (((sy)==0)) return RTERR;
	if (((pl)==0)) return RTERR;
	if (((pr)==0)) return RTERR;
	if (((gridpln)==0)) return RTERR;

	/* Advance to the next node in the list. */	
	if(((gridpln = ((((LLNODE)(((gridpln)->ln_next)->ln_ll))==((gridpln)->ln_next)) ? 0 : (gridpln)->ln_next))==0))
	{
	 strcpy( syid0, "" );
	 strcpy( plid0, "" );

         cpi0.comp_id.objid = NULL_OBJID;
         cpi0.comp_id.osnum = 0;
         cpi0.conn_pt_id    = -1;

	 return RT_END_PIPE_RUN;
	}

	/* test only
	gridp = (struct GRid *)gridpln->ln_object;
	   test only */

	tmp_part_ptr = (struct st_prpart *)gridpln->ln_object;

#ifdef DEBUG
	printf( "beg-cpt:%d objid:%d end-cpt:%d\n",
		 tmp_part_ptr->begincpi.conn_pt_id,
		 tmp_part_ptr->grid.objid,
		 tmp_part_ptr->endcpi.conn_pt_id );
#endif

	if( pt )
	{
	  pt_free( pt );
	}

	pt = pt_new();

	/* test only
	pt->pt_grid = *gridp;
	   test only */
	pt->pt_grid = tmp_part_ptr->grid;

	jnk = resolve_pt( pt, tmp_part_ptr->begincpi.conn_pt_id,
		    tmp_part_ptr->endcpi.conn_pt_id );

	if( jnk == VR_V_DANGLING_TYPE )	/* treatment for dangles */
	{
	 strcpy( syid0, "" );
	 strcpy( plid0, "" );

         cpi0.comp_id.objid = NULL_OBJID;
         cpi0.comp_id.osnum = 0;
         cpi0.conn_pt_id    = -1;

	 return RT_END_PIPE_RUN;
	}

	*part_type = pt->pt_type;
	*part      = pt->pt_part;
	*partinfo  = pt->pt_pi;

	return RTSUCC;
}

int RT_get_file_name( route_file )
char *route_file;
{
  int status;

  if( route_file == NULL )
   return RTERR;

  status = ex$filename( name = route_file,
                        len  = OM_K_MAXOSNAME_LEN
                      );
  if( status == 1 )
   return RTSUCC;
  else
   return RTERR;
}
