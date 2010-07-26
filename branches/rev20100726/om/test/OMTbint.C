#include <limits.h>
#Include  "OMobjectcomm.h"
#include  "OMDB.h"
#include  "OMindex.h"
#include  "OMbtreedef.h"

#define NUMKEYS 800


main()
{
 int new_key[NUMKEYS];
 int (integer_compare)();
 int  rett, rettt, ii, j, num_keys;
 unsigned char tree_type;
 void srand48();
 double drand48();
 int s, ret, retu;
 unsigned short  i, jj;
 OM_S_OBJID tstobjid, keepOids[NUMKEYS];
 OM_S_KEY_DESC lbtree_key, hbtree_key;
 int low_key, high_key;
 OM_S_MESSAGE constr_tree, add_msg, pass_msg, disp_msg, A_ans, B_ans;
 OM_S_MESSAGE remove_msg, trans_msg, neighbor_msg, conts_msg, rangep_msg;
 OM_S_MESSAGE seqp_msg, delete_msg, constr_key, dump_msg;
 int sts, A_cnt=0, B_cnt=0, t_cnt=0, count, max;
 uword classid;
 OM_S_OBJID objid;
 OM_p_OBJID p_objid;
 OM_S_RIP   rip;
 char *root_page_p;
 OM_S_KEY_DESC btree_key;

 struct range_pass_args_str
        {
        OM_p_MESSAGE msg;
        OM_p_KEY_DESC *p_key_low;
        OM_p_KEY_DESC *p_key_high;
        char *p_criteria;
        int ( *user_compare )();
        int *ret;
        } range_pass_args;

 struct constr_key_str
	{
	char *key;
	long *rec;
	} constr_key_args;

 struct constr_tree_str
	{
	unsigned char key_type;
	int *ret;
	} constr_tree_args;

 struct add_args_str
	{
	OM_p_KEY_DESC p_key;
	OM_p_OBJID p_objid;
	int ( *user_compare )();
	int *ret;
	} add_args;

 OM_S_BTREE_CONTENTS keyobj_array[90];
 struct conts_args_str
        {
        int start_key_num;
        int *num_keys;
        OM_p_BTREE_CONTENTS p_keyobj_array;
        int *ret;
        } conts_args;

 long   neighbor_objid;
 struct neighbor_args_str
        {
        OM_p_KEY_DESC p_key;
        OM_p_OBJID p_neighbor_objid;
        int ( *user_compare )();
        int *ret;
        } neighbor_args;

 struct
       {
       int *ans;
       } B_ans_args;

 struct trans_args_str
        {
        OM_p_OBJARRAY p_objarray;
        OM_p_KEY_DESC p_key;
        char *p_criteria;
        int ( *user_compare )();
        int *ret;
        } trans_args;

 struct disp_arg_str
	{
	int	value;
	int  	*ret;
	} disp_args;

OM_S_KEYNAME key_array;
struct seq_args_str
        {
        int count;
        OM_S_OBJID objid;
        char *key_array;
        int *ret;
        } seq_args;

 int ansCnt=0;
 OM_S_CLASSLIST myClasslist ;
 struct pass_args_str
	{
	OM_p_MESSAGE msg;
	OM_p_KEY_DESC p_select_key;
        OM_p_CLASSLIST classlist;
	OM_p_KEY_DESC p_target_key;
	int ( *user_compare )();
	int *ret;
	} pass_args;
	
 struct remove_args_str
        {
        OM_p_KEY_DESC p_key;
        OM_p_OBJID p_objid;
        int ( *user_compare )();
        int *ret;
        } remove_args;

 static char *OMparams[]={"DEFTRANS_GROUP_NUMOBJS=8192",NULL};



 printf("===============================================================\n");
 printf("========================= Initializing OM =====================\n\n");
 sts = om$runtime_init(paramc=1, param_list=OMparams);
 if (!(sts & 1)) {
   printf("Error in OM_runtime_init : %x\n", sts);
   om$report_error(sts=sts);
   exit();
 }

 printf("===============================================================\n");
 printf("======================= Constructing B-tree ===================\n\n");
 constr_tree_args.key_type = BTREE_INTEGER;
 constr_tree_args.ret = &retu;

 sts=om$make_message( classname="OMbtree", 
		      methodname="OMbtree_constr", 
		      size=sizeof(struct constr_tree_str), 	
		      p_arglist=&constr_tree_args, 
		      p_msg=&constr_tree );
			
 if (!(sts&1)) {
   printf("Error in making message for construct tree\n");
   om$report_error(sts=sts);
   exit();
 }

 sts = om$construct( classname="OMbtree", 
		     osnum=OM_Gw_current_OS,
		     p_objid=&objid, 
		     msg=&constr_tree );
			
 if (!(sts&1)) {
   printf("Error in constructing btree\n");
   om$report_error(sts=sts);
   exit();
 }

 if ( *(constr_tree_args.ret) != DB_SUCCESS ) {
   printf("Error in DB_btree_create : %d\n", *(constr_tree_args.ret));
   exit();
 }

 printf("===============================================================\n");
 printf("======================= Testing out add =======================\n");
 sts = om$make_message(	classname="OMTpb", 
			methodname="OMTpb_constr", 
			size=sizeof(struct constr_key_str), 
			p_arglist=&constr_key_args, 
			p_msg=&constr_key );
 if (!(sts&1)) {
   printf("Error in make message for construct key\n");
   om$report_error(sts=sts);
   exit();
 }
	
 sts = om$make_message(	classname="OMbtree", 
			methodname="add", 
			size=sizeof(struct add_args_str), 
			p_arglist=&add_args, 
			p_msg=&add_msg );
			
 if ( ! (sts & 1 ) ) {
   printf(" error in making message for add : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 add_args.user_compare = integer_compare;
 add_args.ret = &rett;
 btree_key.type = KEY_INTEGER;
 add_args.p_key  = &btree_key;
 srand48(1);

 for (i = 0; i < NUMKEYS; i++) {
      new_key[i] = INT_MAX * drand48() + INT_MIN * drand48();
 
#ifdef DBGPRT
   printf("\nkey:  ");
   printf("%d\n", new_key[i]);
#endif

   constr_key_args.key = (int *)&new_key[i];
   constr_key_args.rec = (long *)&tstobjid;
   if ( i % 2 ){
     sts = om$construct( classname="A",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
     A_cnt++;
   }
   else
   if ( i % 5 ){
     sts = om$construct( classname="B",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
     B_cnt++;
   }
   else{
     sts = om$construct( classname="OMTpb", 
		         osnum=OM_Gw_current_OS,
		         p_objid=&tstobjid, 
		         msg=&constr_key );
     t_cnt++;
   }

   if ( ! ( sts & 1 ) ) {
     printf(" error in constructing key : %d\n", sts );
     om$report_error( sts=sts );
     exit();
   }

   btree_key.key.p_integer = (int *)&new_key[i];
   add_args.p_objid = &tstobjid;
   sts = om$send( msg=&add_msg, 
		  senderid=NULL_OBJID, 
		  targetid=objid );
			
   if ( ! (sts & 1 ) ) {
     printf(" error in sending add message: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(add_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR return from btree insert: %d***\n", *(add_args.ret));
     exit();
   }
 keepOids[i] = tstobjid;
 }
 printf("The tree was created with:\n");
 printf("     #ofAobject: %d   #ofBobject: %d   #ofOMTprObject: %d\n", A_cnt, B_cnt, t_cnt);
	
 printf("\n===============================================================\n");
 printf("================== Testing out btree_contents =================\n");

 sts = om$make_message( classname="OMbtree",
                        methodname="btree_contents",
                        size=sizeof(struct conts_args_str),
                        p_arglist=&conts_args,
                        p_msg=&conts_msg );

 if ( ! (sts & 1 ) ){
   printf(" error in making message for btree contents : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 /* How many keys are in the btree? */
 conts_args.num_keys = &num_keys;
 conts_args.ret = &rett;
 conts_args.start_key_num = 0;
 *(conts_args.num_keys) = 0;
 conts_args.p_keyobj_array = NULL;

 sts = om$send( msg=&conts_msg,
                senderid=NULL_OBJID,
                targetid=objid );

 if ( ! (sts & 1 ) ) {
   printf(" error in send to btree_contents: %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 printf("*** Number of keys in the btree: %d\n", *conts_args.num_keys);
 conts_args.start_key_num = 0;
 *(conts_args.num_keys) = 90;
 conts_args.p_keyobj_array = keyobj_array;

 do {
   printf("\n*** Send to btree_contents ***\n");
   sts = om$send( msg=&conts_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );

   if ( ! (sts & 1 ) ) {
     printf(" error in sending btree_contents message: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }
   if ( *(conts_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR from btree contents: %d***\n",
     *(conts_args.ret) );
     exit();
   }

   printf("=========== keyobj_array ===========\n");
   printf("number of objid/key pairs: %d\n\n", *(conts_args.num_keys));
   printf("start key num: %d\n\n", conts_args.start_key_num);
   for (i=0; i<(*(conts_args.num_keys)); i++) {
     printf("objid: %d   ", conts_args.p_keyobj_array[i].objid);
     printf("key: ");
     printf("%d", *((int*)conts_args.p_keyobj_array[i].name.key_name));
     printf("\n");
   }
   conts_args.start_key_num += 90;
 }  while (*(conts_args.num_keys) != 0);

 printf("================================================================\n");
 printf("=================== Testing out neighbor =======================\n");
 sts = om$make_message( classname="OMbtree",
                        methodname="neighbor",
                        size=sizeof(struct neighbor_args_str),
                        p_arglist=&neighbor_args,
                        p_msg=&neighbor_msg );

 if ( ! (sts & 1 ) ) {
   printf(" error in making message for neighbor : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 neighbor_args.ret = &rett;
 btree_key.type = KEY_INTEGER;
 neighbor_args.p_key = &btree_key;
 neighbor_args.user_compare = integer_compare;
 neighbor_args.p_neighbor_objid = (OM_p_OBJID)&neighbor_objid;
 for (i = 0; i < NUMKEYS; i+=40) {
   neighbor_objid = NULL_OBJID;
   btree_key.key.p_integer = (int *)&new_key[i];
   sts = om$send( msg=&neighbor_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );

   if ( ! (sts & 1 ) ) {
     printf(" error in send to neighbor: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }
   if ( *(neighbor_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR from BCLUSTER: %d***\n", *(neighbor_args.ret));
     exit();
   }
   printf("*** neighbor_objid : %d ***\n\n", neighbor_objid);
 }

 printf("===============================================================\n");
 printf("====================== Testing out pass =======================\n");
 myClasslist.w_count = 2;
 myClasslist.p_classes = om$malloc(size=sizeof(OMuword)*myClasslist.w_count);
 if (!myClasslist.p_classes)
   om$report_error(sts=OM_E_NODYNMEM);

 if (!(1&(sts=om$get_classid(classname="A", p_classid=myClasslist.p_classes))))
{
   printf("\nerror return om$get_classid for A.\n\n");
   om$report_error(sts=sts);
 }

 if (!(1&(sts=om$get_classid(classname="OMTpb", p_classid=&myClasslist.p_classes[1])))){
   printf("\nerror return om$get_classid for k.\n\n");
   om$report_error(sts=sts);
 }

 sts = om$make_message( classname="OMbtree",
                        methodname="pass",
                        size=sizeof(struct pass_args_str),
                        p_arglist=&pass_args,
                        p_msg=&pass_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for pass: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 if (!(1&(sts = om$make_message( classname="A",
                                 methodname="answer",
                                 p_msg=&A_ans) ))){
   printf("Error in making message for A.answer\n");
   om$report_error(sts=sts);
 }

 if (!(1&(sts = om$make_message( classname="B",
                                 methodname="answer",
                                 size=sizeof(B_ans_args),
                                 p_arglist=&B_ans_args,
                                 p_msg=&B_ans) ))){
   printf("Error in making message for B.answer\n");
   om$report_error(sts=sts);
 }

 sts = om$make_message( classname="OMTpb",
                        methodname="display",
                        size=sizeof(struct disp_arg_str),
                        p_arglist=&disp_args,
                        p_msg=&disp_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for display: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 printf("-------------------------- 1st pass ---------------------------\n");
 printf("-------------- with A and OMTpr on the classlist --------------\n");
 pass_args.classlist = &myClasslist;
 pass_args.user_compare = integer_compare;
 pass_args.p_target_key = 0;
 pass_args.ret = &rett;
 disp_args.value = 111;
 disp_args.ret = &rettt;
 btree_key.type = KEY_INTEGER;
 pass_args.p_select_key = &btree_key;
 B_ans_args.ans = &ansCnt;
 srand48(1);

 for (i=0, j=0; i < NUMKEYS; i+=40, j++) {
   ii = NUMKEYS * drand48();
   printf("\nsearch key:  ");
   printf("%d\n", new_key[ii]);
   btree_key.key.p_integer = (int *)&new_key[ii];
   if (!(j/7)){
     pass_args.msg = &A_ans;
   }
   else
   if (!(j/14)){
     pass_args.msg = &B_ans;
   }
   else{
     pass_args.msg = &disp_msg;
   }

   sts = om$send( msg=&pass_msg, 
  		  senderid=NULL_OBJID, 
		  targetid=objid );
			
   if (!(sts & 1)  && (sts & SEV_LEV)){
     printf(" error in sending to pass: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(pass_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR return from pass: %d***\n",
     *(pass_args.ret));
     exit();
   }
 }

 printf("\n-------------------------- 2nd pass --------------------------\n");
 printf("-------------------- with null classlist ---------------------\n");
 pass_args.classlist = NULL;
 B_ans_args.ans = &ansCnt;

 for (i=0, j=0; i<NUMKEYS; i+=40, j++) {
   printf("\nsearch key:  ");
   printf("%d\n", new_key[i]);
   btree_key.key.p_integer = (int *)&new_key[i];
   if (!(j/7)){
     pass_args.msg = &A_ans;
   }
   else
   if (!(j/14)){
     pass_args.msg = &B_ans;
   }
   else{
     pass_args.msg = &disp_msg;
   }

   sts = om$send( msg=&pass_msg, 
  		  senderid=NULL_OBJID, 
		  targetid=objid );
			
   if (!(sts & 1)  && (sts & SEV_LEV)){
     printf(" error in sending to pass: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(pass_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR return from BSEARCH: %d***\n",
     *(pass_args.ret));
     exit();
   }
 }

 printf("\n===============================================================\n");
 printf("===================== Testing out translate ===================\n");
 sts = om$make_message( classname="OMbtree",
                        methodname="translate",
                        size=sizeof(struct trans_args_str),
                        p_arglist=&trans_args,
                        p_msg=&trans_msg );

 if ( ! (sts & 1 ) ) {
   printf(" error in making message for trans : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 sts = om$make_message( classname="OMbtree",
                        methodname="translate",
                        size=sizeof(struct trans_args_str),
                        p_arglist=&trans_args,
                        p_msg=&trans_msg );

 if ( ! (sts & 1 ) ) {
   printf(" error in making message for trans : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 trans_args.p_criteria = NULL;
 trans_args.user_compare = integer_compare;
 trans_args.ret = &rett;
 btree_key.type = KEY_INTEGER;
 trans_args.p_key = &btree_key;

 for (i = 0; i < NUMKEYS; i+=40) {
   if ( !(trans_args.p_objarray = (OM_p_OBJARRAY)om$malloc(size=(sizeof(OM_S_OBJARRAY)))) )
     om$report_error(sts=OM_E_NODYNMEM);
   trans_args.p_objarray->size = sizeof(OM_S_OBJARRAY);

   printf("\nsearch key:  ");
   printf("%d\n", new_key[i]);
   btree_key.key.p_integer = (int *)&new_key[i];
   printf("starting the 1st translation to get the count of oids...\n");

   sts = om$send( msg=&trans_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );

   if ( ! (sts & 1 ) ) {
     printf(" error in sending to translate: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if ( *(trans_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR return from BTRANS: %d***\n", *(trans_args.ret));
     exit();
   }
   printf("  number of objids: %d\n", trans_args.p_objarray->count);
   printf("The end of the 1st translation.\n");

   trans_args.p_objarray = (OM_p_OBJARRAY) om$realloc(ptr=trans_args.p_objarray, size=(sizeof(OM_S_OBJARRAY))+(trans_args.p_objarray->count-1) * sizeof(OM_S_OBJID));
   if ( ! trans_args.p_objarray)
     om$report_error(sts=OM_E_NODYNMEM);

   trans_args.p_objarray->size = sizeof(OM_S_OBJARRAY)+sizeof(OM_S_OBJID)*(trans_args.p_objarray->count-1);
   printf("starting the 2nd translation to get a list of translated oids...\n");
   sts = om$send( msg=&trans_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );
   if ( ! (sts & 1 ) ) {
     printf(" error in sending translate message : %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }
   if (*(trans_args.ret) != DB_SUCCESS){
     printf("*** ERROR return from translate:%d\t***\n", *(trans_args.ret));
     exit();
   }

   printf("===== obj_array =====\n");
   max = ( trans_args.p_objarray->size - (3 * sizeof(int)) ) / sizeof(OM_S_OBJID);
   if ( trans_args.p_objarray->count < max )
     max = trans_args.p_objarray->count;

   for ( jj = 0; jj < max; jj++ )
     printf("  objid: %d\n", trans_args.p_objarray->array[jj]);

   printf("The end of the 2nd translation.\n");
   free(trans_args.p_objarray);
 }

 printf("\n===============================================================\n");
 printf("=================== Testing out range_pass ====================\n");
 sts = om$make_message( classname="OMbtree",
                        methodname="range_pass",
                        size=sizeof(struct range_pass_args_str),
                        p_arglist=&range_pass_args,
                        p_msg=&rangep_msg );

 if ( ! (sts & 1 ) ) {
   printf(" error in making message for range_pass : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 range_pass_args.p_criteria = NULL;
 range_pass_args.user_compare = integer_compare;
 range_pass_args.ret = &rett;
 range_pass_args.msg = &disp_msg;

 disp_args.value = 111;
 disp_args.ret = &rettt;

 low_key = -4460561;
 high_key = 96791858;
 lbtree_key.type = KEY_INTEGER;
 lbtree_key.key.p_integer = (int *)&low_key;
 range_pass_args.p_key_low = &lbtree_key;
 hbtree_key.type = KEY_INTEGER;
 hbtree_key.key.p_integer = (int *)&high_key;
 range_pass_args.p_key_high = &hbtree_key;

 sts = om$send( msg=&rangep_msg,
                senderid=NULL_OBJID,
                targetid=objid );

 if (!(sts & 1)  && (sts & SEV_LEV)){
   printf(" error in sending range_pass: %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 if (*(range_pass_args.ret) != DB_SUCCESS) {
   printf("**** ERROR return from range pass : %d\t****\n", *(range_pass_args.ret));
   exit();
 }
 printf("*** value of ret from display: %d ***\n", *disp_args.ret );
 printf("Successful return from range_pass \n");

 printf("\n===============================================================\n");
 printf("===================== Testing out seqpass =====================");
 sts = om$make_message( classname="OMbtree",
                        methodname="seqpass",
                        size=sizeof(struct seq_args_str),
                        p_arglist=&seq_args,
                        p_msg=&seqp_msg );

 if ( ! (sts & 1 ) ) {
   printf(" error in making message for seqpass : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }
 seq_args.ret = &rett;
 seq_args.key_array = (char *)&key_array;
 seq_args.count = 1;
 seqp_msg.p_arglist = (char *)(&seq_args);

 for (i = 5; i < NUMKEYS; i+=40) {
   seq_args.objid = keepOids[i];
   sts = om$send( msg=&seqp_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );

   if ( ! (sts & 1 ) ) {
     printf(" error in sending seqpass: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if ( *(seq_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR from btree seq_search: %d***\n", *(seq_args.ret) );
     exit();
   }

   printf("\n*** key_array ***\n");
   printf("objid:  %d\n", keepOids[i] );
   printf("key len: %d\n", (int)key_array.key_len);
   printf("key: ");
   printf("%d", *((int *)key_array.key_name));
   printf("\n");
 }

 printf("\n===============================================================\n");
 printf("================= Testing out remove and dump =================");
 sts = om$make_message( classname="OMbtree",
                        methodname="remove",
                        size=sizeof(struct remove_args_str),
                        p_arglist=&remove_args,
                        p_msg=&remove_msg );

 if ( ! (sts & 1 ) ) {
   printf(" error in making message for remove : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 remove_args.user_compare = integer_compare;
 remove_args.ret = &rett;
 btree_key.type = KEY_INTEGER;
 remove_args.p_key = &btree_key;

 for (i = 0; i < NUMKEYS; i++) {
   btree_key.key.p_integer = (int *)&new_key[i];
   remove_args.p_objid = (OM_p_OBJID)(&keepOids[i]);

#ifdef DBGPRT
   printf("key: ");
   printf("%d   ", new_key[i]);
   printf("oid: %d\n\n", keepOids[i]);
#endif

   sts = om$send( msg=&remove_msg,
                  senderid=NULL_OBJID,
                  targetid=objid);

   if ( ! (sts & 1 ) ) {
     printf(" error in send remove: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if ( *(remove_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR from DB_btree_delete: %d***\n", *(remove_args.ret));
     exit();
   }
 }

 tree_type = BTREE_INTEGER;
 sts = om$make_message( classname="OMbtree",
                        methodname="btree_dump",
                        size=(sizeof (char)),
                        p_arglist=&tree_type,
                        p_msg=&dump_msg);
 if (!(sts&1)){
   printf("Error in making message for btree_dump\n");
   om$report_error(sts=sts);
   exit();
 }

 sts = om$send( msg=&dump_msg,
                senderid=NULL_OBJID,
                targetid=objid );

 if ( ! (sts & 1 ) ){
   printf(" error in sending to btree_dump: %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 printf("\n===============================================================\n");
 printf("======== To rebuild the B-tree and test out delete ============\n");

 for (i = 0; i < NUMKEYS; i++) {
   btree_key.key.p_integer = (int *)&new_key[i];
   add_args.p_objid = &keepOids[i];
   sts = om$send( msg=&add_msg, 
		  senderid=NULL_OBJID, 
		  targetid=objid );
			
   if ( ! (sts & 1 ) ) {
     printf(" error in sending add message: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(add_args.ret) != DB_SUCCESS ) {
     printf("*** ERROR return from btree insert: %d***\n", *(add_args.ret));
     exit();
   }
 }

 sts = om$make_message( classname="OMbtree",
                        methodname="delete",
                        p_msg=&delete_msg);

 if ( ! (sts & 1 ) ) {
   printf(" error in making message for delete : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }
 sts = om$send( msg=&delete_msg,
                senderid=NULL_OBJID,
                targetid=objid );

 if ( ! (sts & 1 ) ) {
   printf(" error in send to delete: %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }
 if ( ! (root_page_p = DEREF(char, objid, rip)) )
   printf("Successful return from delete.\n");
 else
   printf("Failed to delete the tree.\n");
}


int integer_compare(key1_ptr, key2_ptr, length1, length2)

 int  *key1_ptr, *key2_ptr;
 int length1, length2;
{
 int result;



 return(*key1_ptr > *key2_ptr ? 1 : *key1_ptr == *key2_ptr ? 0 : -1);
}
