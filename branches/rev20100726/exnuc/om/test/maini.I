

class implementation Root;
/* maini.basic */

#include <stdio.h>
#include "OMobjectcomm.h"

 extern int  MAXOS;
 extern int  MAXOBJ;

 extern OM_S_OBJID   oid [10][600]; /* oids of constructed objects */
 extern OMuword	     os  [10];	 /* os numbers */


 extern OM_Gi_conn_debug;
 extern OM_Gi_OMISO_debug;
 extern l_do_print;

 from k    import send_chan;

 OM_S_CHANNUM one_num, many_num, rel_num, abs_num;

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ main */
 main()
{
 int sts;

 l_do_print = 0;

 printf("!!!!!!!!!!!! test before runtime_init !!!!!!!!!!!!!!!!\n");
 sts = om$runtime_init();
 error ("main - runtime_init",sts);

 printf("!!!!!!!!!!!! test before OS construct !!!!!!!!!!!!!!!!\n");
 conTos();

 printf("!!!!!!!!!!!! test before get_channel_number !!!!!!!!!!!!!!!!\n");
 sts = om$get_channel_number(channame = "k.one", p_channum = &one_num);
 error ("main get_channum - one",sts);

 sts = om$get_channel_number(channame = "k.many", p_channum = &many_num);
 error ("main get_channum - many",sts);

 sts = om$get_channel_number(channame = "k.rel", p_channum = &rel_num);
 error ("main get_channum - rel",sts);

 sts = om$get_channel_number(channame = "k.abs", p_channum = &abs_num);
 error ("main get_channum - abs",sts);


 for (;;) {
   fprintf(stderr,"MAXOS (0==quit; else >=3 <=10) :");
   scanf("%d",&MAXOS);
   if (MAXOS < 3 || MAXOS > 10) {
     if (!MAXOS)
       exit(0);
     fprintf(stderr,"bad MAXOS %d\n",MAXOS);
     continue;
   }
   fprintf(stderr,"MAXOBJ (>=2 <=600) :");
   scanf("%d",&MAXOBJ);
   if (MAXOBJ < 3 || MAXOBJ > 600) {
     fprintf(stderr,"bad MAXOBJ %d\n",MAXOBJ);
     continue;
   }
   body();
 }
}
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ body */
body()
{
int sts, i, j, k, m, ii, jj;
int ans;
int m_cnt, r_cnt, a_cnt;

 printf("MAXOS = %d MAXOBJ =%d\n",MAXOS,MAXOBJ);

 printf("!!!!!!!!!!!! test before Object construct !!!!!!!!!!!!!!!!\n");

 con_all_obj();

 printf("!!!!!!!!!!!! test before singleton connect !!!!!!!!!!!!!!!!\n");

 l_connect(0, 0,one_num, 0, 1,one_num);
 l_connect(0, 2,one_num, 1, 1,one_num);

 printf("!!!!!!!!!!!! test before singleton k.send_chan !!!!!!!!!!!!!!\n");
 ans = 0;
 sts = om$send(msg = message k.send_chan (one_num, &ans),
               senderid = NULL, 
	       targetos = os[0], targetid = (oid[0] [0]));
 error("maini: send_object fail",sts);
 ans_chk("maini",ans,1);
    
 ans = 0;
 sts = om$send(msg = message k.send_chan (one_num, &ans),
               senderid = NULL, 
	       targetos = os[0], targetid = oid[0][2]);
 error("maini: send_object fail",sts);
 ans_chk("maini",ans,1);

 printf("!!!!!!!!!!!! test before singleton sibling send !!!!!!!!!!!!!!\n");

 l_sibling(0, 0, one_num, OM_e_inclusive, 1);
 l_sibling(0, 2, one_num, OM_e_exclusive, 0);

 printf("!!!!!!!!!!!! test before singleton disconnect !!!!!!!!!!!!!\n");

 l_disconnect(0, 0,one_num, 0, 1,one_num);
 l_disconnect(0, 2,one_num, 1, 1,one_num);

 printf("!!!!!!!!!!!! test before m_m connect !!!!!!!!!!!!!!!!\n");
 for ( i=0;  i<MAXOS;  i++)  {
 for (ii=0; ii<MAXOBJ; ii++) {
 for ( j=0;  j<MAXOS;   j++) {
 for (jj=0; jj<MAXOBJ; jj++) {
   l_connect(i,ii,many_num, j, jj, rel_num);
 }}}}

 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);

 printf("!!!!!!!!!!!! test before sibling send !!!!!!!!!!!!!!\n");

 i = 1;
 for (j=0; j<MAXOBJ; j++) {
   l_sibling(i, j, many_num, OM_e_inclusive, MAXOS * MAXOBJ);
   l_sibling(i, j, rel_num,  OM_e_exclusive, MAXOS * MAXOBJ - 1);
 }

 printf("!!!!!!!!!!!! test before k.send_chan !!!!!!!!!!!!!!\n");
 i = 1;
 for (j=0; j<MAXOBJ; j++) {
   l_printf("send k.send_chan to %d,%d\n",os[i],oid[i][j]);
   ans = 0;
   m_cnt = l_count(i,j,many_num);
   sts = om$send(msg = message k.send_chan (many_num,&ans),
               senderid = NULL, 
	       targetos = os[i], targetid = oid[i][j]);
   error("maini: send_object fail",sts);
   ans_chk("maini",ans,m_cnt);
 }

 printf("!!!!!!!!!!!! test before k.send_chan 2 !!!!!!!!!!!!!!\n");
 i = 1;
 for (j=0; j<MAXOBJ; j++) {
   l_printf("send k.send_chan to %d,%d\n",os[i],oid[i][j]);
   ans = 0;
   r_cnt = l_count(i,j,rel_num);
   sts = om$send(msg = message k.send_chan (rel_num, &ans),
               senderid = NULL, 
	       targetos = os[i], targetid = oid[i][j]);
   error("maini: send_object fail",sts);
   ans_chk("maini",ans,r_cnt);
 }

 printf("!!!!!!!!!!!! test before m_m disconnect !!!!!!!!!!!!!!!!\n");
 for ( i=0;  i<MAXOS;  i++)  {
 for (ii=0; ii<MAXOBJ; ii++) {
 for ( j=0;  j<MAXOS;   j++) {
 for (jj=0; jj<MAXOBJ; jj++) {
    l_disconnect(i,ii,many_num, j, jj, rel_num);
 }}}}

 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);

 printf("!!!!!!!!!!!! test before m_m connect 2 !!!!!!!!!!!!!!!!\n");
 for (jj=MAXOBJ-1; jj>=0; jj--) {
 for ( i=MAXOS-1;  i>=0;  i--)  {
 for (ii=0; ii<MAXOBJ; ii++) {
 for ( j=0;  j<MAXOS;   j++) {
    l_connect(i,ii,many_num, j, jj, rel_num);
 }}}}

 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);

 printf("!!!!!!!!!!!! test before k.send_chan !!!!!!!!!!!!!!\n");
 i = 0;
 for (j=0; j<MAXOBJ; j++) {
   l_printf("send k.send_chan to %d,%d\n",os[i],oid[i][j]);
   ans = 0;
   m_cnt = l_count(i,j,many_num);
   sts = om$send(msg = message k.send_chan (many_num, &ans),
               senderid = NULL, 
	       targetos = os[i], targetid = oid[i][j]);
   error("maini: send_object fail",sts);
   ans_chk("maini",ans,m_cnt);
 }

 printf("!!!!!!!!!!!! test before k.send_chan 2 !!!!!!!!!!!!!!\n");
 i = 0;
 for (j=0; j<MAXOBJ; j++) {
   l_printf("send k.send_chan to %d,%d\n",os[i],oid[i][j]);
   ans = 0;
   r_cnt = l_count(i,j,rel_num);
   sts = om$send(msg = message k.send_chan (rel_num, &ans),
               senderid = NULL, 
	       targetos = os[i], targetid = oid[i][j]);
   error("maini: send_object fail",sts);
   ans_chk("maini",ans,r_cnt);
 }
 printf("!!!!!!!!!!!! test before wild disconnect !!!!!!!!!!!!!!!!\n");

 for (ii=MAXOBJ-1; ii>=0; ii--) {
 for ( j=0;  j<MAXOS;   j++) {
    l_wild(j,ii,many_num);
    l_wild(j,ii,rel_num);
 }}

 printf("!!!!!!!!!!!! test before count check !!!!!!!!!!!!!!!!\n");

 for (ii=MAXOBJ-1; ii>=0; ii--) {
 for ( j=0;  j<MAXOS;   j++) {
    c_error("many",j,ii,0,l_count(j,ii,many_num));
    c_error("rel", j,ii,0,l_count(j,ii,rel_num));
 }}

 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);

 printf("!!!!!!!!!!!! test before m_m connect 3 !!!!!!!!!!!!!!!!\n");
 
 i = 0;
 for (ii=0; ii<MAXOBJ; ii++) {
 for ( j=0;  j<MAXOS;   j++) {
 for (jj=0; jj<MAXOBJ; jj++) {
    if (os[j]==5 && oid[j][jj]==9) {
    }
    l_connect(i,ii,many_num, j, jj, rel_num);
    if (os[j]==5 && oid[j][jj]==9) {
    }
 }}}
 
 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);

 printf("!!!!!!!!!!!! test before count 1 !!!!!!!!!!!!!!!!\n");

 m = MAXOS * MAXOBJ;
 for ( j=0;  j<MAXOS;   j++) {
 for (ii=0; ii<MAXOBJ; ii++) {
    if ( j ) 
       m = 0;
    c_error("many",j,ii,m     ,l_count(j,ii,many_num));
    c_error("rel", j,ii,MAXOBJ,l_count(j,ii,rel_num));
 }}

 printf("!!!!!!!!!!!! test before copy chan !!!!!!!!!!!!!!\n");

 k = 1;
 for (j=0; j<MAXOBJ; j++) {
   m_cnt = l_count(0,j,many_num);
   r_cnt = l_count(0,j,rel_num);
   l_copy(0, j, many_num, 1, j, many_num);
   c_error("many",0,j,m_cnt, l_count(0,j,many_num));
   c_error("rel", 0,j,r_cnt+1, l_count(0,j,rel_num));
   c_error("many",1,j,m_cnt, l_count(1,j,many_num));

   l_copy(0, j, many_num, 0, k, abs_num);
   c_error("many",0,j,m_cnt, l_count(0,j,many_num));
   c_error("rel", 0,j,r_cnt+2, l_count(0,j,rel_num));
   c_error("abs",0,k,m_cnt, l_count(0,k,abs_num));
   if ( ++k >= MAXOBJ )
     k = 0;
 }

 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);
 
 printf("!!!!!!!!!!!! test before abs wild dis !!!!!!!!!!!!!!\n");

 for (j=0; j<MAXOBJ; j++) {
   l_wild(0, j, abs_num);
   c_error("abs",0,j, 0, l_count(0,j,abs_num));
 }

 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);
 check_all(abs_num);
 
 printf("!!!!!!!!!!!! test before move chan !!!!!!!!!!!!!!\n");

 k = 1;
 for (j=0; j<MAXOBJ; j++) {
   m_cnt = l_count(0,j,many_num);
   r_cnt = l_count(0,j,rel_num);
   l_move(0, j, many_num, 2, j, many_num);
   c_error("many",0,j,0,     l_count(0,j,many_num));
   c_error("rel", 0,j,r_cnt, l_count(0,j,rel_num));
   c_error("many",2,j,m_cnt, l_count(2,j,many_num));

   l_move(1, j, many_num, 1, k, abs_num);
   c_error("many",1,j,0,     l_count(1,j,many_num));
   c_error("rel", 1,j,r_cnt, l_count(1,j,rel_num));
   c_error("abs", 1,k,m_cnt, l_count(1,k,abs_num));
   if ( ++k >= MAXOBJ )
     k = 0;
 }

 printf("!!!!!!!!!!!! test before integrity check !!!!!!!!!!!!!!!!\n");

 check_all(many_num);
 check_all(rel_num);
 check_all(abs_num);

 printf("!!!!!!!!!!!! test before wild/range disconnect !!!!!!!!!!!!!!!!\n");

 for (ii=MAXOBJ-1; ii>=0; ii--) {
 for ( j=0;  j<MAXOS;   j++) {
    l_wild(j,ii,many_num);
    c_error("many",j,ii, 0, l_count(j,ii,many_num));
    r_cnt = l_count(j,ii,rel_num);
    r_cnt -= 2;
    l_range(j,ii,rel_num,1,r_cnt);
    c_error("rel", j,ii, 2, l_count(j,ii,rel_num));
 }}

 printf("!!!!!!!!!!!! test before delete !!!!!!!!!!!!!!!!\n");
 
 del_all_obj();

 for (i=0; i<MAXOS; i++)  {
 for (j=0; j<MAXOBJ; j++) {
   sts = om$is_objid_valid(osnum=os[i], objid=oid[i][j]);
   if (sts != OM_E_NOSUCHOBJ) {
      printf("delete error - %d,%d still valid\n",os[i],oid[i][j]);
      om$report_error(sts=sts);
      exit();
   }
 }}

 i = 2;
 for (j=9; j<100; j++) {
   sts = om$is_objid_valid(osnum = i, objid = j);
   if (sts == OM_S_SUCCESS) {
      printf("********** who is this object **********\n");
      som_show_object(i, j);
   }
 }

 printf("-------------------- done ----------------\n");
 return;
}
end implementation Root;
