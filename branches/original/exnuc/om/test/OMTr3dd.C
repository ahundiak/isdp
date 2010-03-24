#include <math.h>
#include <limits.h>
#include "OMobjectcomm.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"

#define RAND   (mrand48())
#define DRAND  (drand48())
#define HI_VAL ( 2147483647 )

#define NUMKEYS 800
#define SEAR_FAC 6
#define TRAN_FAC 6
#define REPL_KEYS 50

main()
{
 double xmin, xmax, ymin, ymax, zmin, zmax;
 double min_x , max_x , min_y , max_y , min_z , max_z;
 double x_interval , y_interval , z_interval;
 int sts, rett, rettt, tree_height, num_pages;
 int i, j, jj, max, A_cnt=0, B_cnt=0, t_cnt=0, levels;
 float aa, bb, cc;
 double drand48();
 long mrand48();
 void srand48();
 char *root_page_p;
 DB_3D_DBL_BOX lfkey, lfkey2, temp_replkeys[REPL_KEYS], key_wanted;
 #define BUILD_LFKEY3(key, xmn, ymn, zmn, xmx, ymx, zmx)  \
        { (key).xmin = (xmn); \
          (key).xmax = (xmx); \
          (key).ymin = (ymn); \
          (key).ymax = (ymx); \
          (key).zmin = (zmn); \
          (key).zmax = (zmx); }

 OM_S_OBJID objid, tstobjid, temp_newobjids[REPL_KEYS], neighbor_objid;
 OM_S_OBJID objid_wanted, rec_ptr[NUMKEYS+REPL_KEYS], nonexistoid;
 OM_S_MESSAGE constr_msg, add_msg, pass_msg, disp_msg, A_ans, B_ans;
 OM_S_MESSAGE replace_msg, remove_msg, getstat_msg, trans_msg, neighbor_msg;
 OM_S_MESSAGE findrem_msg, delete_msg, findkey_msg;
 OM_S_KEY_DESC rtree_key, select_key, target_key, replace_key, temp_newkeys[REPL_KEYS];
 OM_p_OBJARRAY p_objarray;
 OM_S_RIP rip;

 struct constr_tree_str
	{
        unsigned char tree_type;
	int *ret;
	} constr_tree;
	
 struct disp_arg_str
	{
        OM_p_KEY_DESC p_key;
	int value;
	int *ret;
	} disp_args;

 struct add_args_str
	{
	OM_p_KEY_DESC p_key;
	OM_p_OBJID p_objid;
	int (*user_compare)();
	int *ret;
	} add_args;
	
 struct neighbor_args_str
	{
	OM_p_KEY_DESC p_select_key;
	OM_p_OBJID p_objid;
	int (*user_compare)();
	int *ret;
	} neighbor_args;

 struct pass_args_str
	{
	OM_S_MESSAGE *msg;
	OM_p_KEY_DESC p_select_key;
        OM_p_CLASSLIST classlist;
	OM_p_KEY_DESC p_target_key;
	int (*user_compare)();
	int *ret;
	} pass_args;

 struct
       {
       int *ans;
       } B_ans_args;

 struct trans_args_str
        {
        OM_p_OBJARRAY p_objarray;
        OM_p_KEY_DESC p_key;
        char *p_criteria;
        int (*user_compare)();
        int *ret;
        } trans_args;

struct replace_args_str
        {
        OM_p_KEY_DESC p_key;
        OM_p_OBJID p_objid;
        int dim;
        OM_p_KEY_DESC new_keys;
        OM_p_OBJID    new_objids;
        int *ret;
        } replace_args;

 struct get_stat_args_str
        {
        OM_p_RTREESTAT p_stat;
        int *ret;
        } get_stat_args;

 OM_S_RTREESTAT rtree_stat;
 struct remove_args_str
        {
        OM_p_KEY_DESC p_key;
        OM_p_OBJID p_objid;
        int (*user_compare)();
        int *ret;
        } remove_args;

 struct findkey_args_str
        {
        OM_p_KEY_DESC p_select_key;
        OM_p_OBJID p_objid;
        OM_p_KEY_DESC p_target_key;
        int (*user_compare)();
        int *ret;
        } findkey_args;

 int ansCnt=0;
 OM_S_CLASSLIST myClasslist ;
 static char *OMparams[]={"DEFTRANS_GROUP_NUMOBJS=8192",NULL};

	
	
 printf("===============================================================\n");
 printf("========================= Initializing OM =====================\n\n");
 sts = om$runtime_init(paramc=1, param_list=OMparams);
 if (!(sts & 1)){
   printf("Error in om$runtime_init : %x\n", sts);
   om$report_error(sts=sts);
   exit();
 }

 printf("===============================================================\n");
 printf("======================= Constructing R-tree ===================\n\n");
 constr_tree.tree_type = RTREE_3D_DBL;
 constr_tree.ret = &rettt;
 sts = om$make_message( classname="OMrtree",
	                methodname="OMrtree_constr",
		        size=sizeof(struct constr_tree_str),
		        p_arglist=&constr_tree,
		        p_msg=&constr_msg );
 if (!(sts&1)){
   printf(" Error in making message for OMrtree_constr\n");
   om$report_error(sts=sts);
   exit();
 }

 sts = om$construct( classname="OMrtree",
	 	     osnum=OM_Gw_current_OS,
		     p_objid=&objid,
		     msg=&constr_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in constructing rtree: %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 if (*(constr_tree.ret) != DB_SUCCESS){
   printf(" Error return from rtree create, return code: %d\n", constr_tree.ret);
   exit();
 }

 printf("===============================================================\n");
 printf("======================= Testing out add =======================\n\n");
 sts = om$make_message( classname="OMrtree",
	 	        methodname="add",
		        size=sizeof(struct add_args_str),
		        p_arglist=&add_args,
		        p_msg=&add_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for add: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 add_args.user_compare = 0;
 add_args.ret = &rett;
 rtree_key.type = KEY_3D_DBL;
 rtree_key.key.p_3ddbl = &lfkey;
 add_args.p_key = &rtree_key;
 add_args.p_objid = (OM_p_OBJID)(&tstobjid);

 min_x = min_y = min_z = INT_MAX;
 max_x = max_y = max_z = INT_MIN;

 srand48(1);
 for (i = 0; i < NUMKEYS; i++){
   aa =  RAND;
   bb =  RAND;
   cc =  RAND;
   while (aa > HI_VAL - 100){
     aa = RAND;
   }
   while (bb > HI_VAL - 100){
     bb = RAND;
   }
   while (cc > HI_VAL - 100){
     cc = RAND;
   }
   xmin = aa;
   ymin = bb;
   zmin = cc;
   xmax = DRAND * 100 + xmin;
   ymax = DRAND * 100 + ymin;
   zmax = DRAND * 100 + zmin;

   if (min_x > xmin) min_x = xmin;
   if (min_y > ymin) min_y = ymin;
   if (min_z > zmin) min_z = zmin;
   if (max_x < xmax) max_x = xmax;
   if (max_y < ymax) max_y = ymax;
   if (max_z < zmax) max_z = zmax;
   BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);

   if (i % 2){
     sts = om$construct( classname="A",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
     A_cnt++;
   }
   else
   if (i % 5){
     sts = om$construct( classname="B",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
     B_cnt++;
   }
   else{
     sts = om$construct( classname="OMTpr",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
     t_cnt++;
   }

  if ( ! ( sts & 1 ) ){
    printf(" Error in constructing key : %d\n", sts );
    om$report_error(sts=sts);
    exit();
  }

  if (i == 72)
    {
    key_wanted = lfkey;
    objid_wanted = tstobjid;
    }

  rec_ptr[i] = tstobjid;

  sts = om$send( msg=&add_msg,
		 senderid=NULL_OBJID,
		 targetid=objid );
  if ( ! (sts & 1 ) ){
    printf(" error in sending add message : %x\n", sts );
    om$report_error(sts=sts);
    exit();
  }

  if (*(add_args.ret) != DB_SUCCESS){
    printf(" Error return from rtree insert : %d\t***\n", *(add_args.ret));
    exit();
  }
 }

 printf("The tree was created with:\n");
 printf("     #ofAobject: %d   #ofBobject: %d   #ofOMTprObject: %d\n\n", A_cnt, B_cnt, t_cnt);

#ifdef DBGPRT
 printf("\n***** The MBR of the tree ********\n");
 printf("\tmin_x:  %d\n", min_x);
 printf("\tmin_y:  %d\n", min_y);
 printf("\tmax_x:  %d\n", max_x);
 printf("\tmax_y:  %d\n", max_y);
#endif

 printf("===============================================================\n");
 printf("======================= Testing out find_key ==================\n\n");
 sts = om$make_message( classname="OMrtree",
                        methodname="find_key",
                        size=sizeof(struct findkey_args_str),
                        p_arglist=&findkey_args,
                       p_msg=&findkey_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for find_key: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 select_key.type = KEY_3D_DBL;
 select_key.key.p_3ddbl = &lfkey2;
 findkey_args.p_select_key = &select_key;
 rtree_key.type = KEY_3D_DBL;
 rtree_key.key.p_3ddbl = &lfkey;
 findkey_args.p_target_key = &rtree_key;
 findkey_args.user_compare = 0;
 findkey_args.ret = &rett;
 srand48(1);
 for (i = 0; i < NUMKEYS/2; i++){
   findkey_args.p_objid = (OM_p_OBJID)(&rec_ptr[i]);
   aa =  RAND;
   bb =  RAND;
   cc =  RAND;
   while (aa > HI_VAL - 100){
     aa = RAND;
   }
   while (bb > HI_VAL - 100){
     bb = RAND;
   }
   while (cc > HI_VAL - 100){
     cc = RAND;
   }
   xmin = aa;
   ymin = bb;
   zmin = cc;
   xmax = 100 + xmin;
   ymax = 100 + ymin;
   zmax = 100 + zmin;
   DRAND;
   DRAND;
   DRAND;
   BUILD_LFKEY3(lfkey2, xmin, ymin, zmin, xmax, ymax, zmax);

   sts = om$send( msg=&findkey_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );
   if ( ! (sts & 1 ) ){
     printf(" error in sending find_key message : %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(findkey_args.ret) != DB_SUCCESS){
     printf(" Error return from rtree find_key:%d\t**\n", *(findkey_args.ret));
     exit();
   }
 }

 findkey_args.p_select_key = NULL;
 for (i = NUMKEYS/2; i < NUMKEYS; i++){
   findkey_args.p_objid = (OM_p_OBJID)(&rec_ptr[i]);
   sts = om$send( msg=&findkey_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );
   if ( ! (sts & 1 ) ){
     printf(" error in sending find_key message : %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(findkey_args.ret) != DB_SUCCESS){
     printf(" Error return from rtree find_key:%d\t**\n", *(findkey_args.ret));
     exit();
   }
 }

 nonexistoid = rec_ptr[799] + 10;
 findkey_args.p_objid = (OM_p_OBJID)(&nonexistoid);
 sts = om$send( msg=&findkey_msg,
                senderid=NULL_OBJID,
                targetid=objid );
 if ( ! (sts & 1 ) ){
   printf(" error in sending find_key message : %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 if (*(findkey_args.ret) != DB_KEYNOTFOUND)
   printf(" Error return from rtree find_key:%d\t**\n", *(findkey_args.ret));

 printf("===============================================================\n");
 printf("======================= Testing out neighbor ==================\n\n");
 sts = om$make_message( classname="OMrtree",
	 	        methodname="neighbor",
		        size=sizeof(struct neighbor_args_str),
		        p_arglist=&neighbor_args,
		        p_msg=&neighbor_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for neighbor: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 neighbor_args.user_compare = NULL;
 neighbor_args.ret = &rett;
 rtree_key.type = KEY_3D_DBL;
 rtree_key.key.p_3ddbl = &lfkey;
 neighbor_args.p_select_key = &rtree_key;
 neighbor_args.p_objid = (OM_p_OBJID)&neighbor_objid;

 srand48(1);
 for (i = 0; i < NUMKEYS; i++){
   aa =  RAND;
   bb =  RAND;
   cc =  RAND;
   while (aa > HI_VAL - 100){
     aa = RAND;
   }
   while (bb > HI_VAL - 100){
     bb = RAND;
   }
   while (cc > HI_VAL - 100){
     cc = RAND;
   }
   xmin = aa+1;
   ymin = bb+1;
   zmin = bb+1;
   xmax = DRAND * 100 + xmin;
   ymax = DRAND * 100 + ymin;
   zmax = DRAND * 100 + zmin;
   if ( !(i%20) ){
     BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);
     sts = om$send( msg=&neighbor_msg,
		    senderid=NULL_OBJID,
		    targetid=objid );
     if ( ! (sts & 1 ) ){
       printf(" error in sending neighbor message : %x\n", sts );
       om$report_error(sts=sts);
       exit();
     }

     if (*(neighbor_args.ret) != DB_SUCCESS){
       printf("Error return from rtree cluster:%d\t\n", *(neighbor_args.ret));
       exit();
     }
     printf("*** neighbor_objid = %d ***\n", neighbor_objid);
   }
 }

 printf("\n\n=============================================================\n");
 printf("===================== Testing out pass ======================\n\n");

 myClasslist.w_count = 2;
 myClasslist.p_classes = om$malloc(size=sizeof(OMuword)*myClasslist.w_count);
 if (!myClasslist.p_classes)
   om$report_error(sts=OM_E_NODYNMEM);

 if (!(1&(sts=om$get_classid(classname="A", p_classid=myClasslist.p_classes)))){
   printf("\nerror return om$get_classid for A.\n\n");
   om$report_error(sts=sts);
 }

 if (!(1&(sts=om$get_classid(classname="OMTpr", p_classid=&myClasslist.p_classes[1])))){
   printf("\nerror return om$get_classid for k.\n\n");
   om$report_error(sts=sts);
 }

 sts = om$make_message( classname="OMrtree",
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

 sts = om$make_message( classname="OMTpr",
	 	        methodname="display",
		        size=sizeof(struct disp_arg_str),
		        p_arglist=&disp_args,
		        p_msg=&disp_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for display: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 printf("------------------------ 1st pass -------------------------\n");
 printf("------------ with A and OMTpr on the classlist ------------\n\n");
 pass_args.classlist = &myClasslist;
 pass_args.user_compare = 0;
 pass_args.ret = &rett;
 disp_args.p_key = &target_key;
 disp_args.ret = &rettt;
 disp_args.value = 111;
 rtree_key.type = KEY_3D_DBL;
 rtree_key.key.p_3ddbl = &lfkey;
 pass_args.p_select_key = &rtree_key;
 pass_args.p_target_key = disp_args.p_key;

 x_interval = ( (double)max_x - (double)min_x ) /  SEAR_FAC;
 y_interval = ( (double)max_y - (double)min_y ) /  SEAR_FAC;
 z_interval = ( (double)max_z - (double)min_z ) /  SEAR_FAC;

#ifdef DBGPRT
 printf ( "\tx_interval:  %f\n" , x_interval ) ;
 printf ( "\ty_interval:  %f\n" , y_interval ) ;
 printf ( "\tz_interval:  %f\n" , z_interval ) ;
#endif

 xmin = min_x;
 ymin = min_y;
 zmin = min_z;

 B_ans_args.ans = &ansCnt;

 for (i = 0; i < SEAR_FAC; ++i){
   ymax = ymin + y_interval;
   if (!(i/2)){
     pass_args.msg = &A_ans;
   }
   else
   if (!(i/4)){
     pass_args.msg = &B_ans;
   }
   else{
     pass_args.msg = &disp_msg;
   }

   for (j = 0; j < SEAR_FAC; ++j){
     xmax = xmin + x_interval;
     zmax = zmin + z_interval;
     BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);

#ifdef DBGPRT
     printf ( "The searching key\n" ) ;
     printf ( "\txmin:  %f\n" , xmin ) ;
     printf ( "\tymin:  %f\n" , ymin ) ;
     printf ( "\tzmin:  %f\n" , zmin ) ;
     printf ( "\txmax:  %f\n" , xmax ) ;
     printf ( "\tymax:  %f\n" , ymax ) ;
     printf ( "\tzmax:  %f\n" , zmax ) ;
#endif

     sts = om$send( msg=&pass_msg,
                    senderid=NULL_OBJID,
                    targetid=objid );
     if (!(sts & 1)  && (sts & SEV_LEV)){
       printf(" error in sending pass message : %x\n", sts );
       om$report_error(sts=sts);
       exit();
     }

     if (*(pass_args.ret) != DB_SUCCESS){
       printf(" Error return from rtree search: %d\t***\n", *(pass_args.ret));
       exit();
     }

     xmin = xmax;
     zmin = zmax;
   }
   xmin = min_x;
   zmin = min_z;
   ymin = ymax;
 }

 printf("\n------------------------ 2nd pass ------------------------\n");
 printf("------------------ with null classlist -------------------\n\n");
 pass_args.classlist = NULL;
 xmin = min_x;
 ymin = min_y;
 zmin = min_z;
 B_ans_args.ans = &ansCnt;

 for (i = 0; i < SEAR_FAC; ++i){
   ymax = ymin + y_interval;
   if (!(i/2)){
     pass_args.msg = &A_ans;
   }
   else
   if (!(i/4)){
     pass_args.msg = &B_ans;
   }
   else{
     pass_args.msg = &disp_msg;
   }

   for (j = 0; j < SEAR_FAC; ++j){
     xmax = xmin + x_interval;
     zmax = zmin + z_interval;
     BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);

#ifdef DBGPRT
     printf ( "The searching key\n" ) ;
     printf ( "\txmin:  %f\n" , xmin ) ;
     printf ( "\tymin:  %f\n" , ymin ) ;
     printf ( "\tzmin:  %f\n" , zmin ) ;
     printf ( "\txmax:  %f\n" , xmax ) ;
     printf ( "\tymax:  %f\n" , ymax ) ;
     printf ( "\tzmax:  %f\n" , zmax ) ;
#endif

     sts = om$send( msg=&pass_msg,
                    senderid=NULL_OBJID,
                    targetid=objid );
     if (!(sts & 1)  && (sts & SEV_LEV)){
       printf(" error in sending pass message : %x\n", sts );
       om$report_error(sts=sts);
       exit();
     }
     if (*(pass_args.ret) != DB_SUCCESS){
       printf(" Error return from rtree search: %d\t***\n", *(pass_args.ret));
       exit();
     }

     xmin = xmax;
     zmin = zmax;
   }
   xmin = min_x;
   zmin = min_z;
   ymin = ymax;
 }

 printf("\n\n===========================================================\n");
 printf("=================== Testing out translate =================\n");
 sts = om$make_message( classname="OMrtree",
                        methodname="translate",
                        size=sizeof(struct trans_args_str),
                        p_arglist=&trans_args,
                        p_msg=&trans_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for translate: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 xmin = min_x;
 ymin = min_y;
 zmin = min_z;
 for (i=0; i<TRAN_FAC; i++){
   ymax = ymin + y_interval;
   for (j=0; j<TRAN_FAC; j++){
     xmax = xmin + x_interval;
     zmax = zmin + z_interval;

#ifdef DBGPRT
     printf("\txmin:  %d\n", xmin);
     printf("\tymin:  %d\n", ymin);
     printf("\txmax:  %d\n", xmax);
     printf("\tymax:  %d\n", ymax);
#endif

     BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);
     p_objarray = (OM_p_OBJARRAY) om$malloc(size=(sizeof(OM_S_OBJARRAY)));
     if (!p_objarray)
       om$report_error(sts=OM_E_NODYNMEM);
     trans_args.p_criteria = NULL;
     trans_args.user_compare = 0;
     trans_args.ret = &rettt;

     p_objarray->size = sizeof(OM_S_OBJARRAY);
     trans_args.p_objarray = p_objarray;
     rtree_key.type = KEY_3D_DBL;
     rtree_key.key.p_3ddbl = &lfkey;
     trans_args.p_key = &rtree_key;

     printf("\nstarting the 1st translation to get the count of oids...\n");
     sts = om$send( msg=&trans_msg,
                    senderid=NULL_OBJID,
    	            targetid=objid );
     if ( ! (sts & 1 ) ){
       printf(" error in sending translate message : %x\n", sts );
       om$report_error(sts=sts);
       exit();
     }

     if (*(trans_args.ret) != DB_SUCCESS){
       printf("*** ERROR return from translate:%d\t***\n", *(trans_args.ret));
       exit();
     }

     printf("  number of objids: %d\n", p_objarray->count);
     printf("The end of the 1st translation.\n");

     p_objarray = (OM_p_OBJARRAY) om$realloc(ptr=p_objarray, size=(sizeof(OM_S_OBJARRAY))+(p_objarray->count-1) * sizeof(OM_S_OBJID));
     if (!p_objarray)
       om$report_error(sts=OM_E_NODYNMEM);

     p_objarray->size = sizeof(OM_S_OBJARRAY)+sizeof(OM_S_OBJID)*(p_objarray->count-1);
     /* p_objarray might have been changed, reassign it to trans_args. */
     trans_args.p_objarray= p_objarray; 

     printf("starting the 2nd translation to get a list of translated oids...\n");
     sts = om$send( msg=&trans_msg,
                    senderid=NULL_OBJID,
   	            targetid=objid );
     if ( ! (sts & 1 ) ){
       printf(" error in sending translate message : %x\n", sts );
       om$report_error(sts=sts);
       exit();
     }

     if (*(trans_args.ret) != DB_SUCCESS){
       printf("*** ERROR return from translate:%d\t***\n", *(trans_args.ret));
       exit();
     }

     printf("===== obj_array =====\n");
     max = ( p_objarray->size - (3 * sizeof(int)) ) / sizeof(OM_S_OBJID);
     if ( p_objarray->count < max ){
       max = p_objarray->count;
     }
     for ( jj = 0; jj < max; jj++ ){
       printf("  objid: %d\n", p_objarray->array[jj]);
     }
     printf("The end of the 2nd translation.\n");
 
     xmin = xmax;
     zmin = zmax;
     }
   xmin = min_x;
   zmin = min_z;
   ymin = ymax;
 }

 printf("\n\n============================================================\n");
 printf("==================== Testing out replace ===================\n\n");
 sts = om$make_message( classname="OMrtree",
                        methodname="replace",
                        size=sizeof(struct replace_args_str),
                        p_arglist=&replace_args,
                        p_msg=&replace_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for replace: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 rtree_key.type = KEY_3D_DBL;
 rtree_key.key.p_3ddbl = &key_wanted;
 replace_key.type = KEY_3D_DBL;
 replace_args.p_key = &rtree_key;
 replace_args.p_objid = &objid_wanted;
 replace_args.dim = REPL_KEYS;
 replace_args.new_keys = temp_newkeys;
 replace_args.new_objids = temp_newobjids;
 replace_args.ret = &rett;
 for (i = 0; i < replace_args.dim; i++){
   aa =  RAND;
   bb =  RAND;
   cc =  RAND;
   while (aa > HI_VAL - 100){
     aa = RAND;
   }
   while (bb > HI_VAL - 100){
     bb = RAND;
   }
   while (cc > HI_VAL - 100){
     cc = RAND;
   }

   xmin = aa;
   ymin = bb;
   zmin = cc;
   xmax = DRAND * 100 + xmin;
   ymax = DRAND * 100 + ymin;
   zmax = DRAND * 100 + zmin;
   BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);

   sts = om$construct( classname="OMTpr",
                       osnum=OM_Gw_current_OS,
                       p_objid=&tstobjid );
   if ( ! ( sts & 1 ) ){
     printf(" Error in constructing key : %d,   i:  %d\n", sts, i);
     om$report_error(sts=sts);
     exit();
   }

   rec_ptr[NUMKEYS + i] = tstobjid;
   temp_replkeys[i] = lfkey;
   replace_key.key.p_3ddbl = &temp_replkeys[i];
   replace_args.new_keys[i] = replace_key;
   replace_args.new_objids[i] = tstobjid;
 }

 sts = om$send( msg=&replace_msg, senderid=NULL_OBJID, targetid=objid );
 if ( ! (sts & 1 ) ){
   printf(" error in sending replace message : %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 if (*(replace_args.ret) != DB_SUCCESS){
   printf(" Error return from rtree replace:%d\t\n", *(replace_args.ret));
   exit();
 }
 printf("Successful return from replace.\n");

 printf("\n\n============================================================\n");
 printf("==================== Testing out get_stat ==================\n\n");
 sts = om$make_message( classname="OMrtree",
	   	        methodname="get_stat",
 		        size=sizeof(struct get_stat_args_str),
		        p_arglist=&get_stat_args,
		        p_msg=&getstat_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for get_stat: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 /****** To get misc status ******/

 get_stat_args.p_stat = &rtree_stat;
 get_stat_args.p_stat->request_type = RTREE_MISC_STATUS;
 get_stat_args.ret = &rett;

 sts = om$send( msg=&getstat_msg,
   	        senderid=NULL_OBJID,
	        targetid=objid );
 if ( ! (sts & 1 ) ){
   printf(" error in sending get_stat message : %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 if (*(get_stat_args.ret) != DB_SUCCESS){
   printf(" Error return from rtree get status:%d\t**\n", *(get_stat_args.ret));
   exit();
 }
 printf("**** misc status\n\n");
 printf("     tree_type: %d\n", get_stat_args.p_stat->rtree_status.misc.tree_type);
 printf("     key_count: %d\n", get_stat_args.p_stat->rtree_status.misc.key_count);
 printf("     nl_maxkeys: %d\n", get_stat_args.p_stat->rtree_status.misc.nl_maxkeys);
 printf("     lf_maxkeys: %d\n", get_stat_args.p_stat->rtree_status.misc.lf_maxkeys);
 printf("     tree_height: %d\n", get_stat_args.p_stat->rtree_status.misc.tree_height);
 printf("     num_pages: %d\n\n\n", get_stat_args.p_stat->rtree_status.misc.page_count);

 tree_height = get_stat_args.p_stat->rtree_status.misc.tree_height;
 for (i = 0; i <= tree_height; i++){
   /****** To get the status of a specified level ******/

   get_stat_args.p_stat = &rtree_stat;
   get_stat_args.p_stat->request_type = RTREE_LEVEL_STATUS;
   get_stat_args.p_stat->rtree_status.level.level_no = i;
   get_stat_args.ret = &rett;

   sts = om$send( msg=&getstat_msg,
     	          senderid=NULL_OBJID,
	          targetid=objid );
   if ( ! (sts & 1 ) ){
     printf(" error in sending get_stat message : %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(get_stat_args.ret) != DB_SUCCESS){
     printf(" Error return from rtree get status:%d\t**\n", *(get_stat_args.ret));
     exit();
   }

   printf(" *** level status\n\n");
   printf("     level_no: %d\n", get_stat_args.p_stat->rtree_status.level.level_no);
   printf("     level_type: %d\n", get_stat_args.p_stat->rtree_status.level.level_type);
   printf("     num_pages: %d\n\n\n", get_stat_args.p_stat->rtree_status.level.num_pages);

   num_pages = get_stat_args.p_stat->rtree_status.level.num_pages; 
   for (j = 0; j < num_pages; j++){
     /****** To get the status of a page at a specific level ******/

     get_stat_args.p_stat = &rtree_stat;
     get_stat_args.p_stat->request_type = RTREE_PAGE_STATUS;
     get_stat_args.p_stat->rtree_status.page.level_no = i;
     get_stat_args.p_stat->rtree_status.page.page_no = j;
     get_stat_args.ret = &rett;

     sts = om$send( msg=&getstat_msg,
   	            senderid=NULL_OBJID,
	            targetid=objid );
     if ( ! (sts & 1 ) ){
       printf(" error in sending get_stat message : %x\n", sts );
       om$report_error(sts=sts);
       exit();
     }

     if (*(get_stat_args.ret) != DB_SUCCESS){
       printf(" Error return from rtree get status:%d\t**\n", *(get_stat_args.ret));
       exit();
     }

     printf("  ** page status\n\n");
     printf("     level_no: %d\n", get_stat_args.p_stat->rtree_status.page.level_no);
     printf("     page_no: %d\n", get_stat_args.p_stat->rtree_status.page.page_no);
     printf("     xmin: %f\n", get_stat_args.p_stat->rtree_status.page.page_range.r3ddkey.xmin);
     printf("     ymin: %f\n", get_stat_args.p_stat->rtree_status.page.page_range.r3ddkey.ymin);
     printf("     zmin: %f\n", get_stat_args.p_stat->rtree_status.page.page_range.r3ddkey.zmin);
     printf("     xmax: %f\n", get_stat_args.p_stat->rtree_status.page.page_range.r3ddkey.xmax);
     printf("     ymax: %f\n", get_stat_args.p_stat->rtree_status.page.page_range.r3ddkey.ymax);
     printf("     zmax: %f\n", get_stat_args.p_stat->rtree_status.page.page_range.r3ddkey.zmax);
     printf("     num_keys: %d\n\n", get_stat_args.p_stat->rtree_status.page.num_keys);
   }
 }

 printf("\n============================================================\n");
 printf("========== Testing out remove and find_and_remove ==========\n\n");
 sts = om$make_message( classname="OMrtree",
                        methodname="remove",
                        size=sizeof(struct remove_args_str),
                        p_arglist=&remove_args,
                        p_msg=&remove_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for remove: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 sts = om$make_message( classname="OMrtree",
                        methodname="find_and_remove",
                        size=sizeof(struct remove_args_str),
                        p_arglist=&remove_args,
                        p_msg=&findrem_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for remove: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 remove_args.user_compare = 0;
 remove_args.ret = &rettt;
 rtree_key.type = KEY_3D_DBL;
 rtree_key.key.p_3ddbl = &lfkey;
 remove_args.p_key = &rtree_key;

 srand48(1);
 for (i = 0; i < NUMKEYS; i++){
   aa =  RAND;
   bb =  RAND;
   cc =  RAND;
   while (aa > HI_VAL - 100){
     aa = RAND;
   }
   while (bb > HI_VAL - 100){
     bb = RAND;
   }
   while (cc > HI_VAL - 100){
     cc = RAND;
   }
   xmin = aa;
   ymin = bb;
   zmin = cc;
   xmax = DRAND * 100 + xmin;
   ymax = DRAND * 100 + ymin;
   zmax = DRAND * 100 + zmin;

   if ( i != 72 ){
     remove_args.p_objid = (OM_p_OBJID)(&rec_ptr[i]);
     if ( i%2 ){
       xmax = xmin;
       ymax = ymin;
       zmax = zmin;
       BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);
       sts = om$send( msg=&findrem_msg,
                      senderid=NULL_OBJID,
                      targetid=objid );

       if ( ! (sts & 1 ) ){
         printf(" error in sending find_and_remove message : %x\n", sts );
         om$report_error(sts=sts);
         exit();
       }

       if (*(remove_args.ret) != DB_SUCCESS){
         printf(" Error return from rtree delete:%d\t\n", *(remove_args.ret));
         printf(" i : %d\n", i);
       }
     }
     else{
       BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);
       sts = om$send( msg=&remove_msg,
                      senderid=NULL_OBJID,
                      targetid=objid );

       if ( ! (sts & 1 ) ){
         printf(" error in sending remove message : %x\n", sts );
         om$report_error(sts=sts);
         exit();
       }

       if (*(remove_args.ret) != DB_SUCCESS){
         printf(" Error return from rtree delete:%d\t\n", *(remove_args.ret));
         printf(" i : %d\n", i);
       }
     }
   }
 }

 for (i = 0; i < replace_args.dim; i++){
   rtree_key.type = KEY_3D_DBL;
   rtree_key.key.p_3ddbl = &temp_replkeys[i];
   remove_args.p_key = &rtree_key;
   remove_args.p_objid = (OM_p_OBJID)(&rec_ptr[NUMKEYS + i]);

   sts = om$send( msg=&remove_msg,
                  senderid=NULL_OBJID,
                  targetid=objid );
   if ( ! (sts & 1 ) ){
     printf(" error in sending remove message : %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   if (*(remove_args.ret) != DB_SUCCESS){
     printf(" Error return from rtree delete:%d\t\n", *(remove_args.ret));
     printf("***   i : %d\n", i);
     exit();
   }
 }

 /* Dumping the tree to make sure it's empty */
 levels = 5;
 root_page_p = DEREF( char, objid, rip );
 DB_dump_rtree( root_page_p, &levels, rip);

 printf("\n============================================================\n");
 printf("======== To build a new tree for testing out delete ========\n\n");
 srand48(1);
 for (i = 0; i < NUMKEYS; i++){
   aa =  RAND;
   bb =  RAND;
   cc =  RAND;
   while (aa > HI_VAL - 100){
     aa = RAND;
   }
   while (bb > HI_VAL - 100){
     bb = RAND;
   }
   while (cc > HI_VAL - 100){
     cc = RAND;
   }
   xmin = aa;
   ymin = bb;
   zmin = cc;
   xmax = DRAND * 100 + xmin;
   ymax = DRAND * 100 + ymin;
   zmax = DRAND * 100 + zmin;
   BUILD_LFKEY3(lfkey, xmin, ymin, zmin, xmax, ymax, zmax);

   if (i % 2){
     sts = om$construct( classname="A",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
   }
   else
   if (i % 5){
     sts = om$construct( classname="B",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
   }
   else{
     sts = om$construct( classname="OMTpr",
                         osnum=OM_Gw_current_OS,
                         p_objid=&tstobjid );
   }

  if ( ! ( sts & 1 ) ){
    printf(" Error in constructing key : %d\n", sts );
    om$report_error(sts=sts);
    exit();
  }

  sts = om$send( msg=&add_msg,
		 senderid=NULL_OBJID,
		 targetid=objid );
  if ( ! (sts & 1 ) ){
    printf(" error in sending add message : %x\n", sts );
    om$report_error(sts=sts);
    exit();
  }

  if (*(add_args.ret) != DB_SUCCESS){
    printf(" Error return from rtree insert : %d\t***\n", *(add_args.ret));
    exit();
  }
 }

 sts = om$make_message( classname="OMrtree",
                        methodname="delete",
                        p_msg=&delete_msg );
 if ( ! (sts & 1 ) ){
   printf(" Error in making message for delete: %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }

 sts = om$send( msg=&delete_msg,
                senderid=NULL_OBJID,
                targetid=objid );
 if ( ! (sts & 1 ) ){
   printf(" error in sending delete message : %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 if ( ! (root_page_p = DEREF(char, objid, rip)) )
   printf("Successful return from delete.\n");
 else
   printf("Failed to delete the tree.\n");
}
