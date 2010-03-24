#include </usr/include/math.h>
#include "OMobjectcomm.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"

#define RAND		(drand48())

double drand48();

main()
  { 

  int i, j, jj;
  int  rtn, rett, rettt;
  char         *keyp;

  int xmin, xmax, ymin, ymax;

  DB_2D_INT_BOX lfkey;

  SKEW_KEY_2D_INT skey;

  OM_S_SKEW_DESC skew_key;

  struct mess_arg_str
	{
        OM_p_KEY_DESC p_target_key;
	} mess_args;
	
OM_S_KEY_DESC rtree_key, target_key;

OM_S_RIP rip;

struct constr_tree_str
	{
        unsigned char tree_type;
	int *ret;
	} constr_tree;
	
  int sts;
  uword classid;
  OM_S_MESSAGE add_msg, skew_msg, constr_msg, disp_msg;
  OM_S_OBJID objid, tstobjid;
  OM_p_OBJID p_objid;

  struct add_args_str
	{
	OM_p_KEY_DESC p_key;
	OM_p_OBJID p_objid;
	int (*user_compare)();
	int *ret;
	} add_args;
	
  struct skew_args_str
	{
	OM_p_MESSAGE msg;
	OM_p_SKEW_DESC p_key;
	OM_p_KEY_DESC p_target_key;
	char *p_criteria;
	int (*user_compare)();
	int *ret;
	} skew_args;
	

static char *OMparams[]={"DEFTRANS_GROUP_NUMOBJS=8192", NULL};

sts = om$runtime_init(paramc=1, param_list=OMparams);
if (!(sts & 1))
  {
  printf("Error in om$runtime_init : %x\n", sts);
  om$report_error(sts=sts);
  exit();
  }

constr_tree.tree_type = RTREE_2D_INT;
constr_tree.ret = &rettt;
sts = om$make_message( classname="OMrtree",
	               methodname="OMrtree_constr",
		       size=sizeof(struct constr_tree_str),
		       p_arglist=&constr_tree,
		       p_msg=&constr_msg );
if (!(sts&1))
  {
  printf(" Error in making message for construct tree\n");
  om$report_error(sts=sts);
  exit();
  }

sts = om$construct( classname="OMrtree",
		    osnum=OM_Gw_current_OS,
		    p_objid=&objid,
		    msg=&constr_msg );
if ( ! (sts & 1 ) )
  {
  printf(" Error in constructing rtree: %x\n", sts );
  om$report_error(sts=sts);
  exit();
  }

if (*(constr_tree.ret) != DB_SUCCESS)
  {
  printf(" Error return from rtree create, return code: %d\n",
constr_tree.ret);
  exit();
  }

sts = om$make_message( classname="OMrtree",
		       methodname="add",
		       size=sizeof(struct add_args_str),
		       p_arglist=&add_args,
		       p_msg=&add_msg );
if ( ! (sts & 1 ) )
  {
  printf(" Error in making message for add: %x\n",  sts );
  om$report_error(sts=sts);
  exit();
  }

add_args.ret = &rett;
add_args.user_compare = 0;


sts = om$make_message(	classname="OMrtree", 
			methodname="skew_pass", 
			size=sizeof(struct skew_args_str), 
			p_arglist=&skew_args, 
			p_msg=&skew_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for skew_pass : %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}
	

sts = om$make_message(	classname="OMTpr", 
			methodname="skew_display", 
			size=sizeof(struct mess_arg_str), 
			p_arglist=&mess_args, 
			p_msg=&disp_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for skew_display : %x\n", 
sts );
	om$report_error(sts=sts);
	exit();
	}

mess_args.p_target_key = &target_key;
skew_args.p_target_key = &target_key;
skew_args.ret = &rett;
skew_args.msg = &disp_msg;
skew_args.p_criteria = NULL;
skew_args.user_compare = 0;
skew_key.type = KEY_2D_INT;

#define BUILD_LFKEY2(ptr, xmn, ymn, xmx, ymx) { \
  (ptr)->xmin = (double)(xmn); \
  (ptr)->xmax = (double)(xmx); \
  (ptr)->ymin = (double)(ymn); \
  (ptr)->ymax = (double)(ymx); }

  j = 25;

/* insert some entries. */

  for (i=0; i<j; i+=3)
    {				/* begin for loop */
    if ((i % 5) == 0)
     
    xmin = RAND * 100 - 50;
    ymin = RAND * 100 - 50;
    xmax = xmin + 5;
    ymax = ymin + 5;

   BUILD_LFKEY2(&lfkey, xmin, ymin, xmax, ymax);


sts = om$construct( classname="OMTpr",
		    osnum=OM_Gw_current_OS,
		    p_objid=&tstobjid);
if ( ! (sts & 1 ) )
  {
  printf(" Error in constructing rtree key: %x\n", sts );
  om$report_error(sts=sts);
  exit();
  }

rtree_key.type = KEY_2D_INT;
rtree_key.key.p_2dint = (DB_2D_INT_BOX *)&lfkey;
add_args.p_key  = &rtree_key;
add_args.p_objid = (OM_p_OBJID)&tstobjid;

sts = om$send( msg=&add_msg,
	 senderid=NULL_OBJID,
	 targetid=objid );

if ( ! (sts & 1 ) )
    {
    printf(" error in sending add message : %x\n", sts );
    om$report_error(sts=sts);
    exit();
    }

if (*(add_args.ret) != DB_SUCCESS)
    {
    printf(" Error return from rtree insert : %d\t***\n",
*(add_args.ret));
    exit();
    }


    xmax = xmin = RAND * 100 - 50;
    ymin = RAND * 100 - 50;
    ymax = ymin + 5;
    
   BUILD_LFKEY2(&lfkey, xmin, ymin, xmax, ymax);

sts = om$construct( classname="OMTpr",
		    osnum=OM_Gw_current_OS,
		    p_objid=&tstobjid);
if ( ! (sts & 1 ) )
  {
  printf(" Error in constructing rtree key: %x\n", sts );
  om$report_error(sts=sts);
  exit();
  }

rtree_key.type = KEY_2D_INT;
rtree_key.key.p_2dint = (DB_2D_INT_BOX *)&lfkey;
add_args.p_key  = &rtree_key;
add_args.p_objid = (OM_p_OBJID)&tstobjid;

sts = om$send( msg=&add_msg,
	 senderid=NULL_OBJID,
	 targetid=objid );

if ( ! (sts & 1 ) )
    {
    printf(" error in sending add message : %x\n", sts );
    om$report_error(sts=sts);
    exit();
    }

if (*(add_args.ret) != DB_SUCCESS)
    {
    printf(" Error return from rtree insert : %d\t***\n",
*(add_args.ret));
    exit();
    }

    xmax = xmin = RAND * 100 - 50;
    ymax = ymin = RAND * 100 - 50;

   BUILD_LFKEY2(&lfkey, xmin, ymin, xmax, ymax);

sts = om$construct( classname="OMTpr",
		    osnum=OM_Gw_current_OS,
		    p_objid=&tstobjid);
if ( ! (sts & 1 ) )
  {
  printf(" Error in constructing rtree key: %x\n", sts );
  om$report_error(sts=sts);
  exit();
  }

rtree_key.type = KEY_2D_INT;
rtree_key.key.p_2dint = (DB_2D_INT_BOX *)&lfkey;
add_args.p_key  = &rtree_key;
add_args.p_objid = (OM_p_OBJID)&tstobjid;

sts = om$send( msg=&add_msg,
	 senderid=NULL_OBJID,
	 targetid=objid );

if ( ! (sts & 1 ) )
    {
    printf(" error in sending add message : %x\n", sts );
    om$report_error(sts=sts);
    exit();
    }

if (*(add_args.ret) != DB_SUCCESS)
    {
    printf(" Error return from rtree insert : %d\t***\n",
*(add_args.ret));
    exit();
    }
    
  }

/* Enter rectangle to test around */  
	    
   xmin = 0;
   ymin = 0;
   xmax = 3;
   ymax = 3;
   
   BUILD_LFKEY2(&lfkey, xmin, ymin, xmax, ymax);

sts = om$construct( classname="OMTpr",
		    osnum=OM_Gw_current_OS,
		    p_objid=&tstobjid);
if ( ! (sts & 1 ) )
  {
  printf(" Error in constructing rtree key: %x\n", sts );
  om$report_error(sts=sts);
  exit();
  }

rtree_key.type = KEY_2D_INT;
rtree_key.key.p_2dint = (DB_2D_INT_BOX *)&lfkey;
add_args.p_key  = &rtree_key;
add_args.p_objid = (OM_p_OBJID)&tstobjid;

sts = om$send( msg=&add_msg,
	 senderid=NULL_OBJID,
	 targetid=objid );

if ( ! (sts & 1 ) )
    {
    printf(" error in sending add message : %x\n", sts );
    om$report_error(sts=sts);
    exit();
    }

if (*(add_args.ret) != DB_SUCCESS)
    {
    printf(" Error return from rtree insert : %d\t***\n",
*(add_args.ret));
    exit();
    }

/********************* test search *******************/


     printf (" search v1(7, 3) v2( 4,6 ) delta 1 \n");
      
	skey.v1.x = 7;
	skey.v1.y = 3;
	skey.v2.x = 4;
	skey.v2.y = 6;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }


     printf (" search v1(3, 4) v2(-2, 6) delta 1 \n");
      
	skey.v1.x = 3;
	skey.v1.y = 4;
	skey.v2.x = -2;
	skey.v2.y = 6;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }

     printf (" search v1(-4, -3) v2(5, -1) delta 1 \n");
      
	skey.v1.x = -4;
	skey.v1.y = -3;
	skey.v2.x = 5;
	skey.v2.y = -1;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }

     printf (" search v1(1, -2) v2(3, -3) delta 1 \n");
      
	skey.v1.x = 1;
	skey.v1.y = -2;
	skey.v2.x = 3;
	skey.v2.y = -3;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }

     printf (" search v1(0, -3) v2(3, 4) delta 1 \n");
      
	skey.v1.x = 0;
	skey.v1.y = -3;
	skey.v2.x = 3;
	skey.v2.y = 4;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }
      
     printf(" search v1(-2, 2)   v2(4, 1) delta 1\n ");

	skey.v1.x = -2;
	skey.v1.y = 2;
	skey.v2.x = 4;
	skey.v2.y = 1;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }
      
     printf(" search v1(-2, 1)   v2(4, 2) delta 1. \n ");

	skey.v1.x = -2;
	skey.v1.y = 1;
	skey.v2.x = 4;
	skey.v2.y = 2;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }
     
     printf(" search v1(3, -2)   v2(1, 4) delta 1. \n ");

	skey.v1.x = 3;
	skey.v1.y = -2;
	skey.v2.x = 1;
	skey.v2.y = 4;
	skey.delta = 1.;
	
    skew_key.key.p_skew_2dint = &skey;
    skew_args.p_key = &skew_key;
   
     sts = om$send(	msg=&skew_msg, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
     if ( ! (sts & 1 ) )
      {
      printf(" error in send to skew_pass: %x\n", sts );
      om$report_error(sts=sts);
      exit();
      }

}

