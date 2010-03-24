#include </usr/include/math.h>
#include "OMobjectcomm.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"

#define RAND            (drand48())
#define NUMKEYS 234
#define SKEWKEYS  8

main ( )
  {
  double xmin , xmax , ymin , ymax , zmin , zmax ;
  int i , j, recCnt;
  DB_3D_DBL_BOX lfkey [ NUMKEYS ] ;
  int  rtn , rett , rettt ;
  char * keyp ;
  double dx , dy , dz ;
  SKEW_KEY_3D_DBL skey [ SKEWKEYS ] ;
  DB_3D_DBL_BOX range1 , range2 ;

  OM_S_SKEW_DESC skew_key ;

  struct mess_arg_str
 {
        OM_p_KEY_DESC p_target_key ;
 } mess_args ;

 OM_S_KEY_DESC rtree_key , target_key ;

 OM_S_RIP rip ;

 struct constr_tree_str
 {
        unsigned char tree_type ;
 int * ret ;
 } constr_tree ;

 int sts ;
 uword classid ;
 OM_S_MESSAGE add_msg , skew_msg , constr_msg , B_cnt ;
 OM_S_OBJID objid , tstobjid ;
 OM_p_OBJID p_objid ;

 struct add_args_str
 {
 OM_p_KEY_DESC p_key ;
 OM_p_OBJID p_objid ;
 int ( * user_compare ) ( ) ;
 int * ret ;
 } add_args ;

 struct skew_args_str
 {
 OM_p_MESSAGE msg ;
 OM_p_SKEW_DESC p_key ;
 OM_p_KEY_DESC p_target_key ;
 char * p_criteria ;
 int ( * user_compare ) ( ) ;
 int * ret ;
 } skew_args ;

 struct
       {
       int *count;
       } B_cnt_args;

 static char * OMparams [ ] = { "DEFTRANS_GROUP_NUMOBJS=8192" , 0 } ;



 sts = om$runtime_init(paramc=1, param_list=OMparams);
 if ( ! ( sts & 1 ) )
  {
  printf ( "Error in om$runtime_init : %x\n" , sts ) ;
  om$report_error(sts=sts);
  exit ( ) ;
  }

 constr_tree . tree_type = RTREE_3D_DBL;
 constr_tree . ret = & rettt ;
 sts = om$make_message( classname="OMrtree",
                        methodname="OMrtree_constr",
                        size=sizeof(struct constr_tree_str),
                        p_arglist=&constr_tree,
                        p_msg=&constr_msg );
 if (!(sts&1)){
   printf(" Error in making message for construct tree\n");
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

 add_args . ret = & rett ;
 add_args . user_compare = 0 ;

 sts = om$make_message(  classname="OMrtree",
                         methodname="skew_pass",
                         size=sizeof(struct skew_args_str),
                         p_arglist=&skew_args,
                         p_msg=&skew_msg);

 if ( ! (sts & 1 ) ){
   printf(" error in make_message for skew_pass : %x\n",  sts );
   om$report_error(sts=sts);
   exit();
 }
 sts = om$make_message(  classname="B",
                         methodname="cnt",
                         size=sizeof(B_cnt_args),
                         p_arglist=&B_cnt_args,
                         p_msg=&B_cnt);

 if ( ! (sts & 1 ) ){
   printf(" error in make_message for B.answer : %x\n", sts );
   om$report_error(sts=sts);
   exit();
 }

 mess_args . p_target_key = & target_key ;
 skew_args . p_target_key = & target_key ;
 skew_args . ret = & rett ;
 B_cnt_args.count = &recCnt;
 skew_args . msg = & B_cnt ;
 skew_args . p_criteria = 0   ;
 skew_args . user_compare = 0 ;
 skew_key . type = KEY_3D_DBL;

 i = 0 ;

 lfkey [ i ] . xmin = 2 ;
 lfkey [ i ] . xmax = 3 ;
 lfkey [ i ] . ymin = 1 ;
 lfkey [ i ] . ymax = 4 ;
 lfkey [ i ] . zmin = 4 ;
 lfkey [ i++ ] . zmax = 7 ;

 lfkey [ i ] . xmin = 4 ;
 lfkey [ i ] . xmax = 5 ;
 lfkey [ i ] . ymin = 3.5 ;
 lfkey [ i ] . ymax = 5 ;
 lfkey [ i ] . zmin = 5 ;
 lfkey [ i++ ] . zmax = 6 ;

 lfkey [ i ] . xmin = 3.5 ;
 lfkey [ i ] . xmax = 4 ;
 lfkey [ i ] . ymin = 1 ;
 lfkey [ i ] . ymax = 3 ;
 lfkey [ i ] . zmin = 5 ;
 lfkey [ i++ ] . zmax = 6 ;

 lfkey [ i ] . xmin = 0 ;
 lfkey [ i ] . xmax = 1 ;
 lfkey [ i ] . ymin = 3 ;
 lfkey [ i ] . ymax = 4 ;
 lfkey [ i ] . zmin = 3 ;
 lfkey [ i++ ] . zmax = 4 ;

 lfkey [ i ] . xmin = 1.2 ;
 lfkey [ i ] . xmax = 1.8 ;
 lfkey [ i ] . ymin = 3.2 ;
 lfkey [ i ] . ymax = 3.8 ;
 lfkey [ i ] . zmin = 3 ;
 lfkey [ i++ ] . zmax = 4 ;

 lfkey [ i ] . xmin = - 1 ;
 lfkey [ i ] . xmax = 5 ;
 lfkey [ i ] . ymin = 1 ;
 lfkey [ i ] . ymax = 4 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 2 ;

 lfkey [ i ] . xmin = 1 ;
 lfkey [ i ] . xmax = 1.9 ;
 lfkey [ i ] . ymin = 2.2 ;
 lfkey [ i ] . ymax = 2.8 ;
 lfkey [ i ] . zmin = 2.2 ;
 lfkey [ i++ ] . zmax = 2.8 ;

 lfkey [ i ] . xmin = 2 ;
 lfkey [ i ] . xmax = 3 ;
 lfkey [ i ] . ymin = 2.2 ;
 lfkey [ i ] . ymax = 2.8 ;
 lfkey [ i ] . zmin = 1 ;
 lfkey [ i++ ] . zmax = 2 ;

 lfkey [ i ] . xmin = 2.5 ;
 lfkey [ i ] . xmax = 4 ;
 lfkey [ i ] . ymin = 2 ;
 lfkey [ i ] . ymax = 3 ;
 lfkey [ i ] . zmin = 2 ;
 lfkey [ i++ ] . zmax = 3 ;

 lfkey [ i ] . xmin = 2 ;
 lfkey [ i ] . xmax = 3 ;
 lfkey [ i ] . ymin = 2.8 ;
 lfkey [ i ] . ymax = 4 ;
 lfkey [ i ] . zmin = 2 ;
 lfkey [ i++ ] . zmax = 3 ;

 lfkey [ i ] . xmin = 3 ;
 lfkey [ i ] . xmax = 4 ;
 lfkey [ i ] . ymin = 3 ;
 lfkey [ i ] . ymax = 4 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 5 ;

 lfkey [ i ] . xmin = 1 ;
 lfkey [ i ] . xmax = 2 ;
 lfkey [ i ] . ymin = 1 ;
 lfkey [ i ] . ymax = 2 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 5 ;

 lfkey [ i ] . xmin = 1 ;
 lfkey [ i ] . xmax = 2 ;
 lfkey [ i ] . ymin = 3 ;
 lfkey [ i ] . ymax = 4 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 5 ;

 lfkey [ i ] . xmin = 1 ;
 lfkey [ i ] . xmax = 2 ;
 lfkey [ i ] . ymin = 2 ;
 lfkey [ i ] . ymax = 3 ;
 lfkey [ i ] . zmin = 3 ;
 lfkey [ i++ ] . zmax = 4 ;

 lfkey [ i ] . xmin = 4 ;
 lfkey [ i ] . xmax = 5 ;
 lfkey [ i ] . ymin = 1 ;
 lfkey [ i ] . ymax = 2 ;
 lfkey [ i ] . zmin = 2 ;
 lfkey [ i++ ] . zmax = 3 ;

 lfkey [ i ] . xmin = 5 ;
 lfkey [ i ] . xmax = 6 ;
 lfkey [ i ] . ymin = 0 ;
 lfkey [ i ] . ymax = 2 ;
 lfkey [ i ] . zmin = 3 ;
 lfkey [ i++ ] . zmax = 4 ;

 lfkey [ i ] . xmin = 4 ;
 lfkey [ i ] . xmax = 5 ;
 lfkey [ i ] . ymin = 2 ;
 lfkey [ i ] . ymax = 3 ;
 lfkey [ i ] . zmin = 1 ;
 lfkey [ i++ ] . zmax = 2 ;

 lfkey [ i ] . xmin = 4 ;
 lfkey [ i ] . xmax = 5 ;
 lfkey [ i ] . ymin = 4.1 ;
 lfkey [ i ] . ymax = 6 ;
 lfkey [ i ] . zmin = 3 ;
 lfkey [ i++ ] . zmax = 4 ;

 lfkey [ i ] . xmin = 0 ;
 lfkey [ i ] . xmax = 1 ;
 lfkey [ i ] . ymin = 0 ;
 lfkey [ i ] . ymax = 1 ;
 lfkey [ i ] . zmin = 3 ;
 lfkey [ i++ ] . zmax = 4 ;

 lfkey [ i ] . xmin = 0 ;
 lfkey [ i ] . xmax = .5 ;
 lfkey [ i ] . ymin = 1 ;
 lfkey [ i ] . ymax = 3 ;
 lfkey [ i ] . zmin = 5.5 ;
 lfkey [ i++ ] . zmax = 8 ;

 lfkey [ i ] . xmin = 4.5 ;
 lfkey [ i ] . xmax = 6 ;
 lfkey [ i ] . ymin = 0 ;
 lfkey [ i ] . ymax = 1 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 1.5 ;

 lfkey [ i ] . xmin = 3.5 ;
 lfkey [ i ] . xmax = 4 ;
 lfkey [ i ] . ymin = 0 ;
 lfkey [ i ] . ymax = 1.5 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 1 ;

 lfkey [ i ] . xmin = 0 ;
 lfkey [ i ] . xmax = 1 ;
 lfkey [ i ] . ymin = 4 ;
 lfkey [ i ] . ymax = 5 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 1 ;

 lfkey [ i ] . xmin = 1 ;
 lfkey [ i ] . xmax = 4 ;
 lfkey [ i ] . ymin = 1 ;
 lfkey [ i ] . ymax = 4 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 2 ;

 lfkey [ i ] . xmin = 0 ;
 lfkey [ i ] . xmax = 1 ;
 lfkey [ i ] . ymin = 0 ;
 lfkey [ i ] . ymax = 1 ;
 lfkey [ i ] . zmin = 0 ;
 lfkey [ i++ ] . zmax = 1 ;

 lfkey [ i ] . xmin = 1 ;
 lfkey [ i ] . xmax = 1.5 ;
 lfkey [ i ] . ymin = - 1 ;
 lfkey [ i ] . ymax = 1 ;
 lfkey [ i ] . zmin = - 1 ;
 lfkey [ i++ ] . zmax = 1 ;


 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -7;
 lfkey [ i++ ] . zmax = -4;

 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 3.5;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;

 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;

 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 1.2;
 lfkey [ i ] . xmax = 1.8;
 lfkey [ i ] . ymin = 3.2;
 lfkey [ i ] . ymax = 3.8;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.9;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = -2.8;
 lfkey [ i++ ] . zmax = -2.2;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = 2.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = 2.8;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = 3;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = 5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 4.1;
 lfkey [ i ] . ymax = 6;	
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = .5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -8;
 lfkey [ i++ ] . zmax = -5.5;
   
 lfkey [ i ] . xmin = 4.5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1.5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1.5;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 4;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.5;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 4;
 lfkey [ i++ ] . zmax = 7;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -3.5;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 1.2;
 lfkey [ i ] . xmax = 1.8;
 lfkey [ i ] . ymin = -3.8;
 lfkey [ i ] . ymax = -3.2;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.9;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = 2.2;
 lfkey [ i++ ] . zmax = 2.8;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 2.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -2.8;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = 3;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = 5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -6;
 lfkey [ i ] . ymax = -4.1;	
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = .5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 5.5;
 lfkey [ i++ ] . zmax = 8;
   
 lfkey [ i ] . xmin = 4.5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1.5;
   
 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -1.5;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.5;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -7;
 lfkey [ i++ ] . zmax = -4;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -3.5;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;
   
 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 1.2;
 lfkey [ i ] . xmax = 1.8;
 lfkey [ i ] . ymin = -3.8;
 lfkey [ i ] . ymax = -3.2;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.9;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = -2.8;
 lfkey [ i++ ] . zmax = -2.2;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = 2.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -2.8;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = 3;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = 5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = -6;
 lfkey [ i ] . ymax = -4.1;	
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = .5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -8;
 lfkey [ i++ ] . zmax = -5.5;
   
 lfkey [ i ] . xmin = 4.5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -1.5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -1.5;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -4;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.5;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 4;
 lfkey [ i++ ] . zmax = 7;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 3.5;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -1.8;
 lfkey [ i ] . xmax = -1.2;
 lfkey [ i ] . ymin = 3.2;
 lfkey [ i ] . ymax = 3.8;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -1.9;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = 2.2;
 lfkey [ i++ ] . zmax = 2.8;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -2.5;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = 2.8;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -5;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 4.1;
 lfkey [ i ] . ymax = 6;	
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -.5;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 5.5;
 lfkey [ i++ ] . zmax = 8;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -4.5;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1.5;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1.5;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 4;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -1.5;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -7;
 lfkey [ i++ ] . zmax = -4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 3.5;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -1.8;
 lfkey [ i ] . xmax = -1.2;
 lfkey [ i ] . ymin = 3.2;
 lfkey [ i ] . ymax = 3.8;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1.9;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = -2.8;
 lfkey [ i++ ] . zmax = -2.2;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -2.5;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = 2.8;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -5;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = 4.1;
 lfkey [ i ] . ymax = 6;	
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -.5;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = -8;
 lfkey [ i++ ] . zmax = -5.5;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -4.5;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1.5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1.5;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 4;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1.5;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 4;
 lfkey [ i++ ] . zmax = 7;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -3.5;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -1.8;
 lfkey [ i ] . xmax = -1.2;
 lfkey [ i ] . ymin = -3.8;
 lfkey [ i ] . ymax = -3.2;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -1.9;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = 2.2;
 lfkey [ i++ ] . zmax = 2.8;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -2.5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -2.8;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -5;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -6;
 lfkey [ i ] . ymax = -4.1;	
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -.5;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 5.5;
 lfkey [ i++ ] . zmax = 8;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -4.5;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1.5;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = -1.5;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = -1.5;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 1;

 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -7;
 lfkey [ i++ ] . zmax = -4;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -3.5;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -6;
 lfkey [ i++ ] . zmax = -5;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -1.8;
 lfkey [ i ] . xmax = -1.2;
 lfkey [ i ] . ymin = -3.8;
 lfkey [ i ] . ymax = -3.2;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1.9;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = -2.8;
 lfkey [ i++ ] . zmax = -2.2;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = -2.8;
 lfkey [ i ] . ymax = -2.2;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -2.5;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = -3;
 lfkey [ i ] . xmax = -2;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -2.8;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -3;
 lfkey [ i ] . zmin = -5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -2;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -3;
 lfkey [ i++ ] . zmax = -2;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -5;
 lfkey [ i ] . ymin = -2;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -2;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = -1;
   
 lfkey [ i ] . xmin = -5;
 lfkey [ i ] . xmax = -4;
 lfkey [ i ] . ymin = -6;
 lfkey [ i ] . ymax = -4.1;	
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -4;
 lfkey [ i++ ] . zmax = -3;
   
 lfkey [ i ] . xmin = -.5;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -3;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -8;
 lfkey [ i++ ] . zmax = -5.5;
   
 lfkey [ i ] . xmin = -6;
 lfkey [ i ] . xmax = -4.5;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -1.5;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -3.5;
 lfkey [ i ] . ymin = -1.5;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -5;
 lfkey [ i ] . ymax = -4;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -4;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -4;
 lfkey [ i ] . ymax = -1;
 lfkey [ i ] . zmin = -2;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 0;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 0;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 0;
   
 lfkey [ i ] . xmin = -1.5;
 lfkey [ i ] . xmax = -1;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 4;
 lfkey [ i++ ] . zmax = 7;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 3.5;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 5;
 lfkey [ i++ ] . zmax = 6;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 1.2;
 lfkey [ i ] . xmax = 1.8;
 lfkey [ i ] . ymin = 3.2;
 lfkey [ i ] . ymax = 3.8;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = -1;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.9;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = 2.2;
 lfkey [ i++ ] . zmax = 2.8;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = 2.2;
 lfkey [ i ] . ymax = 2.8;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 2.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = 2;
 lfkey [ i ] . xmax = 3;
 lfkey [ i ] . ymin = 2.8;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = 3;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = 3;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 5;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 2;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = 2;
 lfkey [ i++ ] . zmax = 3;
   
 lfkey [ i ] . xmin = 5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 2;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 2;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 1;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 4;
 lfkey [ i ] . xmax = 5;
 lfkey [ i ] . ymin = 4.1;
 lfkey [ i ] . ymax = 6;	
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = 3;
 lfkey [ i++ ] . zmax = 4;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = .5;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 3;
 lfkey [ i ] . zmin = 5.5;
 lfkey [ i++ ] . zmax = 8;
   
 lfkey [ i ] . xmin = 4.5;
 lfkey [ i ] . xmax = 6;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1.5;
   
 lfkey [ i ] . xmin = 3.5;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1.5;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 4;
 lfkey [ i ] . ymax = 5;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 4;
 lfkey [ i ] . ymin = 1;
 lfkey [ i ] . ymax = 4;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 2;
   
 lfkey [ i ] . xmin = 0;
 lfkey [ i ] . xmax = 1;
 lfkey [ i ] . ymin = 0;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = 0;
 lfkey [ i++ ] . zmax = 1;
   
 lfkey [ i ] . xmin = 1;
 lfkey [ i ] . xmax = 1.5;
 lfkey [ i ] . ymin = -1;
 lfkey [ i ] . ymax = 1;
 lfkey [ i ] . zmin = -1;
 lfkey [ i ] . zmax = 1;

 rtree_key . type = KEY_3D_DBL;
 add_args . p_key  = & rtree_key ;
 for ( i = 0 ; i < NUMKEYS; i ++ ) {
   sts = om$construct( classname="B",
                       osnum=OM_Gw_current_OS,
                       p_objid=&tstobjid);
   if ( ! (sts & 1 ) ){
     printf(" Error in constructing rtree key: %x\n", sts );
     om$report_error(sts=sts);
     exit();
   }

   rtree_key . key . p_3ddbl = ( DB_3D_DBL_BOX * ) & lfkey [ i ] ;
   add_args . p_objid = ( OM_p_OBJID ) & tstobjid ;
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

 range1 . xmin = - 99.0 ;
 range1 . ymin = - 99.0 ;
 range1 . zmin = - 99.0 ;
 range1 . xmax = 99.0 ;
 range1 . ymax = 99.0 ;
 range1 . zmax = 99.0 ;
 i = 0 ;
 skey [ i ] . range1 = range1 ;
 skey [ i ] . sx = 1 ;
 skey [ i ] . sy = 1 ;
 skey [ i ] . sz = 1 ;

 skey [ ++ i ] . range1 = range1 ;
 skey [ i ] . sx = 1 ;
 skey [ i ] . sy = 1 ;
 skey [ i ] . sz = - 1 ;

 skey [ ++ i ] . range1 = range1 ;
 skey [ i ] . sx = 1 ;
 skey [ i ] . sy = - 1 ;
 skey [ i ] . sz = 1 ;

 skey [ ++ i ] . range1 = range1 ;
 skey [ i ] . sx = 1 ;
 skey [ i ] . sy = - 1 ;
 skey [ i ] . sz = - 1 ;

 skey [ ++ i ] . range1 = range1 ;
 skey [ i ] . sx = - 1 ;
 skey [ i ] . sy = 1 ;
 skey [ i ] . sz = 1 ;

 skey [ ++ i ] . range1 = range1 ;
 skey [ i ] . sx = - 1 ;
 skey [ i ] . sy = 1 ;
 skey [ i ] . sz = - 1 ;

 skey [ ++ i ] . range1 = range1 ;
 skey [ i ] . sx = - 1 ;
 skey [ i ] . sy = - 1 ;
 skey [ i ] . sz = 1 ;

 skey [ ++ i ] . range1 = range1 ;
 skey [ i ] . sx = - 1 ;
 skey [ i ] . sy = - 1 ;
 skey [ i ] . sz = - 1 ;

 skew_key . type = KEY_3D_DBL;
 skew_args . p_key = & skew_key ;

 for ( j = 0 ; j < 9; j ++ ) {
   printf("\n=========================================================================\n");
   printf("Range1=(-99, -99, -99), (99, 99, 99)   ") ;
   switch ( j )
     {
     case 0:  
             printf ( "\nRange2=(2, 2, 0), (3, 3, 5) \n" ) ;
             range2 . xmin = 2 ;
	     range2 . ymin = 2 ;
	     range2 . zmin = 0 ;
	     range2 . xmax = 3 ;
	     range2 . ymax = 3 ;
	     range2 . zmax = 5 ;
             break;
     case 1:
             printf ( "\nRange2=(2, 2, -5), (3, 3, 0) \n" ) ;
	     range2.xmin = 2;
	     range2.ymin = 2;
	     range2.zmin = -5;
	     range2.xmax = 3;
	     range2.ymax = 3;
	     range2.zmax = 0;
 	     break;
     case 2:
             printf ( "\nRange2=(2, -3, 0), (3, -2, 5) \n" ) ;
             range2.xmin = 2;
             range2.ymin = -3;
             range2.zmin = 0;
             range2.xmax = 3;
             range2.ymax = -2;
             range2.zmax = 5;
    	     break;

     case 3:
             printf ( "\nRange2=(2, -3, -5), (3, -2, 0) \n" ) ;
             range2.xmin = 2;
             range2.ymin = -3;
             range2.zmin = -5;
             range2.xmax = 3;
             range2.ymax = -2;
             range2.zmax = 0;
	     break;

     case 4:
             printf ( "\nRange2=(-3, 2, 0), (-2, 3, 5) \n" ) ;
             range2.xmin = -3;
             range2.ymin = 2;
             range2.zmin = 0;
             range2.xmax = -2;
             range2.ymax = 3;
             range2.zmax = 5;
	     break;

     case 5:
             printf ( "\nRange2=(-3, 2, -5), (-2, 3, 0) \n" ) ;
             range2.xmin = -3;
             range2.ymin = 2;
             range2.zmin = -5;
             range2.xmax = -2;
             range2.ymax = 3;
             range2.zmax = 0;
	     break;

     case 6:
             printf ( "\nRange2=(-3, -3, 0), (-2, -2, 5) \n" ) ;
             range2.xmin = -3;
             range2.ymin = -3;
             range2.zmin = 0;
             range2.xmax = -2;
             range2.ymax = -2;
             range2.zmax = 5;
	     break;

     case 7:
             printf ( "\nRange2=(-3, -3, -5), (-2, -2, 0) \n" ) ;
             range2.xmin = -3;
             range2.ymin = -3;
             range2.zmin = -5;
             range2.xmax = -2;
             range2.ymax = -2;
             range2.zmax = 0;
	     break;

     case 8:
             printf ( "\nRange2=(2, 2, 0), (3, 3, 5) \n" ) ;
             range2.xmin = 2;
             range2.ymin = 2;
             range2.zmin = 0;
             range2.xmax = 3;
             range2.ymax = 3;
             range2.zmax = 5;
	     break;
     }
  
   for ( i = 0 ; i < SKEWKEYS; i ++ ) {
     recCnt = 0;
     skey [ i ] . range2 = range2 ;
     printf ( "\nsx = %lf  " , skey [ i ] . sx ) ;
     printf ( "sy = %lf  " , skey [ i ] . sy ) ;
     printf ( "sz = %lf\n" , skey [ i ] . sz ) ;
     skew_key . key . p_skew_3ddbl = & skey [ i ] ;
     sts = om$send( msg=&skew_msg,
                    senderid=NULL_OBJID,
                    targetid=objid );

     if ( ! (sts & 1 ) ){
       printf(" error in sending to skew_pass: %x\n", sts );
       om$report_error(sts=sts);
       exit();
     }
   printf("The number of objects received the B.cnt msg:  %d\n", recCnt);
   }   /* inner for loop */
   }   /* outer for loop */
 }
