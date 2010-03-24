#include <math.h>
#include "OMobjectcomm.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"

main()

{

int i;
int sts, rett, rettt;
OM_S_MESSAGE ass_constr_tree, ass_write;
OM_S_OBJID objid, tstobjid;
OM_S_RIP rip;

struct constr_tree_str
	{
        unsigned char tree_type;
	int *ret;
	} constr_tree;
	
struct constr_arg_str
        {
	unsigned char tree_type;
	int ret;
	} constr_arg;
	
char osname[30];

struct write_args_struct
	{
	char *new_osname;
	} write_args;

OM_S_OBJID filedobj;
uword filed_osnum;

static char *OMparams[]={"DEFTRANS_GROUP_NUMOBJS=8192",NULL};

sts = om$runtime_init(paramc=1, param_list=OMparams);
if (!(sts & 1))
  {
  printf("Error in om$runtime_init : %x\n", sts);
  om$report_error(sts=sts);
  exit();
  }

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


constr_tree.tree_type = RTREE_3D_DBL;
constr_tree.ret = &rettt;
sts = om$make_message( classname="OMrtree",
	               methodname="OMrtree_constr",
		       size=sizeof(struct constr_tree_str),
		       p_arglist=&constr_tree,
		       p_msg=&ass_constr_tree );
if (!(sts&1))
  {
  printf(" Error in makeing message for construct tree\n");
  om$report_error(sts=sts);
  exit();
  }

sts = om$construct( classname="OMrtree",
		    osnum=filed_osnum,
		    p_objid=&objid,
		    msg=ass_constr_tree );
if ( ! (sts & 1 ) )
  {
  printf(" Error in constructing rtree: %x\n", sts );
  om$report_error(sts=sts);
  exit();
  }

if (*(constr_tree.ret) != DB_SUCCESS)
  {
  printf(" Error return from rtree create, return code: %d\n", constr_tree.ret);
  exit();
  }

printf("\n\n\n\n\n************************\n");
printf("\nrtree objid: %d\n", objid);
printf("\n************************\n\n\n\n\n\n\n\n\n\n");

#ifdef DEBUG
printf("\n*** Rtree successfully constructed ***\n");
#endif

/****************** Write out Rtree ***********************************/

strcpy(osname,"Filedr3dd");

write_args.new_osname = osname;
   
#ifdef DEBUG
printf("\n*** Prepare to write out the OS ***\n");
#endif

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


}
