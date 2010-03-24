#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMbtreedef.h"

#define MAXA	3
#define MAXB	3
#define MAXC	3
#define MAXD	3
#define MAXE    3
#define MAXF	3
#define MAXG	3
#define MAXQ	3

#define NUMKEYS	 (30) 

main ()

{						/* main */

int		sts, i, num;
OM_S_OBJID	a_objid[MAXA], b_objid[MAXB], c_objid[MAXC], e_objid[MAXE], d_objid[MAXD];
OM_S_OBJID	pa_objid, pb_objid, f_objid[MAXF], g_objid[MAXG],q_objid[MAXQ];
OM_S_MESSAGE    connect_msg, printa_msg, printb_msg,
printclsc_msg, fillnum_msg, printg_msg;
OM_S_MESSAGE    fillvla_msg, display_vla_msg, fill_info_msg, display_info_msg;
OM_S_CHANSELECT chansel;
char            chan_acb[15], chan_anychan[15], chan_cchan[15], chan_btoany[15];

struct connect_struct
	{
	OM_S_CHANSELECT	to_sel;
	int		to_idx;
	OM_S_OBJID	fr_objid;
	uword		fr_os;
	OM_S_CHANSELECT fr_sel;
	int		fr_idx;
	} connect_args;

int               user_action();
int    (user_compare)();
int    new_key;
int    rett, kl;
OM_S_OBJID tstobjid, objid;

struct constr_key_str
	{
	char *key;
	long *rec;
	} constr_key;

struct constr_tree_str
	{
	unsigned char key_type;
	int *ret;
	} constr_tree;

OM_S_MESSAGE  ass_add, ass_constr_tree, ass_constr_key, dump_msg;
void srand48();
double drand48();
int retu, constr_rec;
OM_S_KEY_DESC btree_key;

struct add_args_str
	{
	OM_p_KEY_DESC p_key;
	OM_p_OBJID p_objid;
	int ( *user_compare )();
	int *ret;
	} add_args;
	

static char *OMparams[]={"DEFTRANS_GROUP_NUMOBJS=12000",NULL};

sts=om$runtime_init( paramc=1, param_list=OMparams );
if (!(sts&1))
{
    printf ("error in OM_runtime_init: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

#ifdef DEBUG
printf("\n*** RUNTIME_INIT COMPLETE ***\n");
#endif

strcpy(chan_acb, "clsa.acb");
strcpy(chan_anychan, "clsa.any_chan");
strcpy(chan_btoany, "clsb.btoany");
strcpy(chan_cchan, "clsc.cchan");

constr_tree.key_type = BTREE_INTEGER;
constr_tree.ret = &retu;

sts=om$make_message(    classname="OMbtree", 
			methodname="OMbtree_constr", 
			size=sizeof(struct constr_tree_str), 	
			p_arglist=&constr_tree, 
			p_msg=&ass_constr_tree);
			
if (!(sts&1))
	{
	printf("Error in make message for construct tree\n");
	om$report_error(sts=sts);
	exit();
	}

sts = om$construct(	classname="OMbtree", 
			osnum=OM_Gw_current_OS,
			p_objid=&objid, 
			msg=&ass_constr_tree);
			
if (!(sts&1))		
	{
	printf("Error in constructing btree\n");
	om$report_error(sts=sts);
	exit();
	}

if ( *(constr_tree.ret) != DB_SUCCESS )
	{
	printf("Error in DB_btree_create : %d\n", *(constr_tree.ret));
	exit();
	}

sts = om$make_message(	classname="OMbtree", 
			methodname="add", 
			size=sizeof(struct add_args_str), 
			p_arglist=&add_args, 
			p_msg=&ass_add);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for add : %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

add_args.user_compare = user_compare;
kl = 4; 
srand48(1 );

sts = om$make_message(	classname="OMTpb", 
			methodname="OMTpb_constr", 
			size=sizeof(struct constr_key_str), 
			p_arglist=&constr_key, 
			p_msg=&ass_constr_key);
if (!(sts&1))
	{
	printf("Error in make message for construct key\n");
	om$report_error(sts=sts);
	exit();
	}

for (i = 0; i < NUMKEYS; i++)
  {

   new_key =  (int)(65000 * drand48() - 32500);
   constr_key.key = (char *)&new_key;
   constr_key.rec = (long *) &constr_rec;

   sts = om$construct(	classname="OMTpb", 
			osnum=OM_Gw_current_OS,
			p_objid=&tstobjid, 
			msg=&ass_constr_key);
			
   if ( ! ( sts & 1 ) )
     {
      printf(" error in constructing key : %d\n", sts );
      om$report_error( sts=sts );
      exit();
     }

   add_args.ret = &rett;
   btree_key.type = KEY_INTEGER;
   btree_key.key.p_integer = (int *)(&new_key);
   add_args.p_key  = &btree_key;
   add_args.p_objid = (OM_p_OBJID)(constr_key.rec);
   
   sts = om$send(	msg=&ass_add, 
			senderid=NULL_OBJID, 
			targetid=objid);
			
   if ( ! (sts & 1 ) )
     {
      printf(" error in send : %x\n", sts );
      om$report_error(sts=sts);
      exit();
     }

   if ( *(add_args.ret) != DB_SUCCESS )
	{
	printf("*** ERROR from BINSERT: %d***\n", *(add_args.ret) );
	exit();
	}

  }

sts=om$construct(classname="parenta", osnum=OM_Gw_current_OS,
			p_objid=&pa_objid
			);
			
if (!(sts&1))
   {
   printf ("error in om$construct: %x \n", sts );
   om$report_error(sts=sts);
   exit();
   }

sts=om$construct(classname="parentb", osnum=OM_Gw_current_OS,
			p_objid=&pb_objid
			);
			
if (!(sts&1))
   {
   printf ("error in om$construct: %x \n", sts );
   om$report_error(sts=sts);
   exit();
   }

#ifdef DEBUG
printf("\n*** Construct A objects ***\n");
#endif

for(i=0; i<MAXA; i++)

{
    sts=om$construct(classname="clsa", osnum=OM_Gw_current_OS,
			p_objid=&a_objid[i]
			);
			
    if (!(sts&1))
    {
        printf ("error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

for(i=0; i<MAXB; i++)
{

    sts=om$construct(classname="clsb", osnum=OM_Gw_current_OS,
			p_objid=&b_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}


for(i=0; i<MAXC; i++)
{

    sts=om$construct(classname="clsc", osnum=OM_Gw_current_OS,
			p_objid=&c_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

for(i=0; i<MAXD; i++)
{

    sts=om$construct(classname="clsd", osnum=OM_Gw_current_OS,
			p_objid=&d_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

for(i=0; i<MAXE; i++)
{

    sts=om$construct(classname="clse", osnum=OM_Gw_current_OS,
			p_objid=&e_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

for(i=0; i<MAXF; i++)
{

    sts=om$construct(classname="clsf", osnum=OM_Gw_current_OS,
			p_objid=&f_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

for(i=0; i<MAXG; i++)
{

    sts=om$construct(classname="clsg", osnum=OM_Gw_current_OS,
			p_objid=&g_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

for(i=0; i<MAXQ; i++)
{

    sts=om$construct(classname="clsq", osnum=OM_Gw_current_OS,
			p_objid=&q_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

sts=om$make_message(classname="clsf", 
		methodname="fillnum", 
		p_msg=&fillnum_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for fillnum: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

sts=om$send(msg=&fillnum_msg, 
	senderid=NULL_OBJID, 
	targetid=f_objid[0]);
		
if (!(sts&1))
    {
    printf ("\nerror in send to fillnum for clsf objid: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }

connect_args.to_sel.type = OM_e_name;
connect_args.to_sel.u_sel.name = chan_btoany;
connect_args.to_idx = 0;
connect_args.fr_os = OM_Gw_current_OS;
connect_args.fr_sel.type = OM_e_name;
connect_args.fr_sel.u_sel.name = chan_acb;
connect_args.fr_idx = 0;

sts=om$make_message(classname="Root", 
		methodname="connect", 
		size=sizeof(struct connect_struct), 
		p_arglist=&connect_args, 
		p_msg=&connect_msg
		);
if (!(sts&1))
    {
    printf ("\nerror in om$make_message for connect: %x\n", sts);
    om$report_error(sts=sts);
    exit();
    }

for(i=0; i<MAXA; i++)

{
    connect_args.fr_objid = a_objid[i];

    sts=om$send(msg=&connect_msg, 
		senderid=a_objid[i], 
		targetid=b_objid[0],
		targetos=OM_Gw_current_OS
		);
		
    if (!(sts&1))
    {
        printf ("\nerror in send to connect for clsa objid: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}


printf("==============================================================\n");
printf("\n\n*** PROMOTE AN OBJECT %d TO AN OMOSCO OBJECT\n\n", pa_objid);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=pa_objid, classname="OMOSCO");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	}
printf("==============================================================\n");

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n*** PROMOTE PARENTA OBJECT %d TO A PARENTB OBJECT\n\n", pa_objid);
printf("======= SHOW OBJECT TO BE PROMOTED =======\n");
som_show_object(OM_Gw_current_OS, pa_objid);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=pa_objid, classname="parentb");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}

printf("======= SHOW PROMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, pa_objid);
printf("==============================================================\n");

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n*** PROMOTE OMBTREE OBJECT %d TO A DUMP_BTREE OBJECT\n\n", pa_objid);
printf("======= SHOW OBJECT TO BE PROMOTED =======\n");
som_show_object(OM_Gw_current_OS, objid);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=objid, classname="dump_btree");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}

printf("======= SHOW PROMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, objid);
printf("==============================================================\n");

sts=om$make_message(classname="dump_btree", 
		methodname="dump", 
		p_msg=&dump_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for dump: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

sts=om$send(msg=&dump_msg, 
	senderid=NULL_OBJID, 
	targetid=objid);
		
if (!(sts&1))
    {
    printf ("\nerror in send to dump for dump_btree objid: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n**** PROMOTE CLSE OBJECT %d TO A CLSC OBJECT\n\n",e_objid[0]);
printf("======= SHOW OBJECT TO BE PROMOTED =======\n");
som_show_object(OM_Gw_current_OS, e_objid[0]);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=e_objid[0], classname="clsc");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}
printf("======= SHOW PROMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, e_objid[0]);
printf("==============================================================\n");

printf("\n*** Connect the promoted clsc object to the clsa object ***\n");

connect_args.to_sel.type = OM_e_name;
connect_args.to_sel.u_sel.name = chan_anychan;
connect_args.to_idx = 0;
connect_args.fr_os = OM_Gw_current_OS;
connect_args.fr_sel.type = OM_e_name;
connect_args.fr_sel.u_sel.name = chan_cchan;
connect_args.fr_objid = e_objid[0];
connect_args.fr_idx = 0;

sts=om$make_message(classname="Root", 
		methodname="connect", 
		size=sizeof(struct connect_struct), 
		p_arglist=&connect_args, 
		p_msg=&connect_msg
		);
if (!(sts&1))
    {
    printf ("\nerror in om$make_message for connect: %x\n", sts);
    om$report_error(sts=sts);
    exit();
    }

for(i=0; i<MAXA; i++)

{
    sts=om$send(msg=&connect_msg, 
		senderid=e_objid[0], 
		targetid=a_objid[i],
		targetos=OM_Gw_current_OS
		);
		
    if (!(sts&1))
    {
        printf ("\nerror in send to connect to clsa objid: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

printf("\n*** Channel send from promoted clsc object e_objid[0] to class clsa's display ***\n\n");

num=101;
sts=om$make_message(classname="clsa", 
		methodname="printa", 
		size=sizeof(num), 
		p_arglist=&num, 
		p_msg=&printa_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for printa: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

chansel.type = OM_e_name;
chansel.u_sel.name = chan_cchan;

sts = om$send(	msg=&printa_msg,
		senderid=e_objid[0],
		p_chanselect=&chansel);

if ( ! ( sts & 1 ) )
	{
	printf("\n Error in channel send from c[0] \n");
	om$report_error(sts=sts);
	exit();
	}

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n**** PROMOTE CLSA OBJECT %d TO A CLSC OBJECT\n\n",a_objid[0]);
printf("======= SHOW OBJECT TO BE PROMOTED =======\n");
som_show_object(OM_Gw_current_OS, a_objid[0]);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=a_objid[0], classname="clsc");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}

printf("======= SHOW PROMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, a_objid[0]);
printf("==============================================================\n");

sts = om$make_message(	classname="clsc", 
			methodname="printclsc", 
			p_msg=&printclsc_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printclsc: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printclsc from promoted a_objid[0] ***\n");

sts = om$send(	msg=&printclsc_msg, 
		senderid=NULL_OBJID, 
		targetid=a_objid[0] );
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsc's display from clsc a_objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n**** PROMOTE CLSC OBJECT %d TO A CLSD OBJECT\n\n",c_objid[0]);
printf("======= SHOW OBJECT TO BE PROMOTED =======\n");
som_show_object(OM_Gw_current_OS, c_objid[0]);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=c_objid[0], classname="clsd");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}
printf("======= SHOW PROMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, c_objid[0]);
printf("==============================================================\n");

sts = om$make_message(	classname="clsd", 
			methodname="printb", 
			p_msg=&printb_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printb: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printb from promoted c_objid[0] ***\n");

sts = om$send(	msg=&printb_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb's display from clsd c_objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n**** DEMOTE CLSD OBJECT %d TO A CLSA object\n\n",d_objid[0]);
printf("======= SHOW OBJECT TO BE DEMOTED =======\n");
som_show_object(OM_Gw_current_OS, d_objid[0]);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=d_objid[0], classname="clsa");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}
printf("======= SHOW DEMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, d_objid[0]);
printf("==============================================================\n");

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n**** PROMOTE CLSF OBJECT %d TO A CLSG OBJECT\n\n",f_objid[0]);
printf("======= SHOW OBJECT TO BE PROMOTED =======\n");
som_show_object(OM_Gw_current_OS, f_objid[0]);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=f_objid[0], classname="clsg");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}
printf("======= SHOW PROMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, f_objid[0]);
printf("==============================================================\n");
  
printf("\n*** Send printg message using promoted f_objid[0] ***\n");

sts=om$make_message(classname="clsg", 
		methodname="printg", 
		p_msg=&printg_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for printg: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

sts=om$send(msg=&printg_msg, 
	senderid=NULL_OBJID, 
	targetid=f_objid[0]);
		
if (!(sts&1))
    {
    printf ("\nerror in send to printg for clsg objid: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }


sts=om$make_message(classname="clsq", 
		methodname="fill_info", 
		p_msg=&fill_info_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for fill_info: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

sts=om$send(msg=&fill_info_msg, 
	senderid=NULL_OBJID, 
	targetid=q_objid[0]);
		
if (!(sts&1))
    {
    printf ("\nerror in send to fill_info for clsq objid: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }


printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n**** PROMOTE CLSQ OBJECT %d TO A CLSR OBJECT\n\n",q_objid[0]);
printf("======= SHOW OBJECT TO BE PROMOTED =======\n");
som_show_object(OM_Gw_current_OS, q_objid[0]);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=q_objid[0], classname="clsr");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}
printf("======= SHOW PROMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, q_objid[0]);
printf("==============================================================\n");

printf("\n*** Send to display_info from promoted clsq object ***\n");

sts=om$make_message(classname="clsq", 
		methodname="display_info", 
		p_msg=&display_info_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for display_info: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

sts=om$send(msg=&display_info_msg, 
	senderid=NULL_OBJID, 
	targetid=q_objid[0]);
		
if (!(sts&1))
    {
    printf ("\nerror in send to display_info for clsq objid: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }

sts=om$make_message(classname="clsf", 
		methodname="fillvla", 
		p_msg=&fillvla_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for fillvla: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

sts=om$send(msg=&fillvla_msg, 
	senderid=NULL_OBJID, 
	targetid=g_objid[0]);
		
if (!(sts&1))
    {
    printf ("\nerror in send to fillvla for clsg objid: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }

printf("\n\n==============================================================\n");
printf("==============================================================\n");
printf("\n\n**** DEMOTE CLSG OBJECT %d TO A CLSF OBJECT\n\n",g_objid[0]);
printf("======= SHOW OBJECT TO BE DEMOTED =======\n");
som_show_object(OM_Gw_current_OS, g_objid[0]);

sts = om$change_class(osnum=OM_Gw_current_OS, objid=g_objid[0], classname="clsf");

if ( ! ( sts & 1 ) )
	{
	printf("error from om$change_class\n");
	om$report_error(sts=sts);
	exit();
	}

printf("======= SHOW DEMOTED OBJECT =======\n");
som_show_object(OM_Gw_current_OS, g_objid[0]);
printf("==============================================================\n");

sts=om$make_message(classname="clsf", 
		methodname="display_vla", 
		p_msg=&display_vla_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for display_vla: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }

sts=om$send(msg=&display_vla_msg, 
	senderid=NULL_OBJID, 
	targetid=g_objid[0]);
		
if (!(sts&1))
    {
    printf ("\nerror in send to display vla for clsf objid g_objid[0]: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }

}


/* user comparison routine for testing btree. */
int user_compare(key1_ptr, key2_ptr)

  int  *key1_ptr, *key2_ptr;
  {
    return(*key1_ptr > *key2_ptr ? 1 : *key1_ptr == *key2_ptr ? 0 : -1);
  }



EX_error_box(vs, msg, title)
int   vs;
char  *msg, *title;
{
   if (!vs || !msg || !title)
   {
      printf("\n\nPoor Man's EX_error_box:\n");
      printf("\n+-------------------+\n");
      printf("|                   |\n");
      printf("|       x  x        |\n");
      printf("|         >         |\n");
      printf("|       ____        |\n");
      printf("|        U          |\n");
      printf("|                   |\n");
      printf("+-------------------+\n\n");
   }
   else if (msg)
      printf("--->%s\n", msg);
   return(1);
}


