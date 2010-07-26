#include <math.h>
#include "OMobjectcomm.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"

#define RAND   (mrand48())
#define DRAND  (drand48())
#define HI_VAL ( 10e+12 )
#define LO_VAL ( -10e+12 )
#define MULT_VAL ( HI_VAL - LO_VAL )

#ifndef TIME_TEST
#define NUMKEYS 800
#else
#define NUMKEYS 8000
#endif

extern int OM_Gd_write;

main()

{
double xmin, xmax, ymin, ymax, zmin, zmax;
int i, levels;
float aa, bb;
double drand48(); 
long mrand48();
void srand48();
char *root_page_p;
DB_3D_DBL_BOX lfkey;
#define BUILD_LFKEY3(key, xmn, ymn, zmn, xmx, ymx, zmx)  \
  	{ (key).xmin = (xmn); \
	  (key).xmax = (xmx); \
 	  (key).ymin = (ymn); \
	  (key).ymax = (ymx); \
	  (key).zmin = (zmn); \
 	  (key).zmax = (zmx); }

OM_S_MESSAGE ass_write;

char osname[30];
	
struct write_args_struct
	{
	char *new_osname;
	} write_args;

OM_S_OBJID filedobj;
uword filed_osnum;

int sts, rett, rettt;
OM_S_MESSAGE ass_add;
OM_S_OBJID objid, tstobjid;
OM_S_KEY_DESC rtree_key;
OM_S_RIP rip;

struct add_args_str
	{
	OM_p_KEY_DESC p_key;
	OM_p_OBJID p_objid;
	int (*user_compare)();
	int *ret;
	} add_args;
	
static char *OMparams[]={"DEFTRANS_GROUP_NUMOBJS=8192",NULL};

sts = om$runtime_init(paramc=1, param_list=OMparams);
if (!(sts & 1))
  {
  printf("Error in om$runtime_init : %x\n", sts);
  om$report_error(sts=sts);
  exit();
  }

/******** Construct Filed Object Space *****************/

sts = om$make_message(	classname="OMFiledOS", 
			methodname="write", 
			size=sizeof(struct write_args_struct), 
			p_arglist=&write_args, 
			p_msg=&ass_write);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for write : %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}
	
#ifdef DEBUG
printf("\n*** Prepare to construct filed OS ***\n");
#endif

sts = om$construct_os(	classname="OMFiledOS",
			osnum=&filed_osnum,
			osname="Filedr3dd",
			p_objid=&filedobj);

if (!(sts&1))
	{
	printf("*** ERROR in CONSTRUCT OS ***\n");
	om$report_error(sts=sts);
	exit();
	}

#ifdef DEBUG
printf("\n*** Filed OS successfully constructed ***\n");
printf("filed_osnum: %d\n", filed_osnum);
printf("filedobj: %d\n", filedobj);
#endif

om$make_current_os( osnum=filed_osnum );


printf("\n\n\n\n\nPlease enter objid of rtree\n\n\n\n");
scanf("%d", &objid);

printf("\n\n\n*** Adding 800 keys to the rtree ***\n\n\n\n\n");

sts = om$make_message( classname="OMrtree",
		       methodname="add",
		       size=sizeof(struct add_args_str),
		       p_arglist=&add_args,
		       p_msg=&ass_add );
if ( ! (sts & 1 ) )
  {
  printf(" Error in makeing message for add: %x\n",  sts );
  om$report_error(sts=sts);
  exit();
  }

add_args.user_compare = 0;
add_args.ret = &rett;
  
srand48(1);
for (i = 0; i < NUMKEYS; i++)
  {
  aa =  RAND;
  bb =  RAND;
  while (aa > HI_VAL - 100) 
    {
    aa = RAND;
    }
  while (bb > HI_VAL - 100) 
    {
    bb = RAND;
    }

  xmin = aa;
  ymin = bb;
  xmax = DRAND * 100 + xmin;
  ymax = DRAND * 100 + ymin;
  zmax = zmin = 0.00;
  BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);

  sts = om$construct( classname="OMTpr",
		      osnum=OM_Gw_current_OS,
		      p_objid=&tstobjid );
  if ( ! ( sts & 1 ) )
    {
    printf(" Error in constructing key : %d\n", sts );
    om$report_error(sts=sts);
    exit();
    }

  rtree_key.type = KEY_3D_DBL;
  rtree_key.key.p_3ddbl = &lfkey;
  add_args.p_key  = &rtree_key;
  add_args.p_objid = (OM_p_OBJID)&tstobjid;

  sts = om$send( msg=ass_add,
		 senderid=NULL_OBJID,
		 targetid=objid,
		 targetos=filed_osnum );

  if ( ! (sts & 1 ) )
    {
    printf(" error in sending add message : %x\n", sts );
    om$report_error(sts=sts);
    exit();
    }

  if (*(add_args.ret) != DB_SUCCESS)
    {
    printf(" Error return from rtree insert : %d\t***\n", *(add_args.ret));
    exit();
    }
  }

/****************** Write out Btree ***********************************/

strcpy(osname, "Filedr3dd");
write_args.new_osname = osname;
   
#ifdef DEBUG
printf("\n*** Prepare to write out the OS ***\n");
#endif

OM_Gd_write = 1;

sts = om$send(	msg=ass_write, 
		senderid=filedobj, 
		targetid=filedobj,
		targetos=filed_osnum);
		
if ( ! (sts & 1 ) )
    {
     printf(" error in send to write os: %x\n", sts );
     om$report_error(sts=sts);
     exit();
    }

#ifdef DEBUG
  levels = 5;
  root_page_p = DEREF( char, objid, rip );
  DB_dump_rtree( root_page_p, &levels);
#endif

}
