class implementation Root;
/* mainsupi.I */

#include "OMobjectcomm.h"
#include "OMintprims.h"


int l_do_print;

int MAXOS; /* 3 is minimum valid value 10 is max  */
int MAXOBJ;	/* 3 is minimum valid value 600 is max */

OM_S_OBJID oid[10][600];
OMuword    os[10];

from OMObjSpace import print_isodir;
from k import answer;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_connect */
/* connect two objects */
 l_connect (nos1, noid1, ch1, nos2, noid2, ch2)
 int nos1, noid1, nos2, noid2;
 OM_S_CHANNUM	ch1, ch2;
 {
  int sts;
  OM_S_CHANSELECT cs1, cs2;

  l_printf(" %d,%d <-> %d,%d\n",
		os[nos1],oid[nos1][noid1],
		os[nos2],oid[nos2][noid2]);

  cs1.type = cs2.type = OM_e_num;
  cs1.u_sel.number = ch1;
  cs2.u_sel.number = ch2;

  sts = om$send (msg = message Root.connect ( 
		   cs1, NULL,
		   oid[nos2][noid2], os[nos2], cs2, NULL),
		senderid = NULL, 
		targetid = oid[nos1][noid1], targetos = os[nos1]);
  error("l_connect",sts);
  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_connect_rel */
/* connect two objects with relindex specified */
 l_connect_rel (nos1, noid1, ch1, rndx1, nos2, noid2, ch2, rndx2)
 int nos1, noid1, nos2, noid2;
 int    rndx1, rndx2;
 OM_S_CHANNUM	ch1, ch2;
 {
  int sts;
  OM_S_CHANSELECT cs1, cs2;

  l_printf("l_connect_rel  %d,%d to %d,%d\n",
		os[nos1],oid[nos1][noid1],
		os[nos2],oid[nos2][noid2]);

  cs1.type = cs2.type = OM_e_num;
  cs1.u_sel.number = ch1;
  cs2.u_sel.number = ch2;

  sts = om$send (msg = message Root.connect ( 
		   cs1, rndx1,
		   oid[nos2][noid2], os[nos2], cs2, rndx2),
		senderid = NULL, 
		targetid = oid[nos1][noid1], targetos = os[nos1]);

  error("l_connect_rel",sts);
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  check_all */
/* check channel connections for all os, all object */
check_all(ch1)
 OM_S_CHANNUM ch1;
 {
  int i;

  for (i=0; i<MAXOS; i++) {
    check_inos(i, ch1);
  }
  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  check_inos */
/* check channel connections for all object in an os */
check_inos(nos1, ch1)
 int nos1;
 OM_S_CHANNUM ch1;
 {
  int i;

  for (i=0; i<MAXOBJ; i++) {
    check_one(nos1, i, ch1);
  }
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  check_one */
/* check channel connections for specified object / channel */
check_one (nos1, noid1, ch1)
 int nos1, noid1;
 OM_S_CHANNUM	ch1;
 {
  int sts;
  OM_S_CHANSELECT cs1;

  l_printf("check_one  %d,%d(%d.%d)\n",
		os[nos1],oid[nos1][noid1],ch1.classid,ch1.number);

  cs1.type = OM_e_num;
  cs1.u_sel.number = ch1;

  som_connect_integrity(os[nos1], oid[nos1][noid1], cs1);

  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ del_all_obj */
/* delete all objects */
 del_all_obj()
 {
  int sts, i, j;

  for(i=0; i < MAXOS; i++) {
   for(j=0; j < MAXOBJ; j++ ) {
     delobj(os[i],oid[i][j]);
  }}
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ delobj */
/* del an object */
 delobj (os,oid)
 OMuword os;
 OM_S_OBJID oid;
 {
  int sts;

  l_printf("delelete (%d,%d)\n",os,oid);

  sts = om$send (msg = message Root.delete ( FALSE ),
		senderid = NULL, 
		targetid = oid, targetos = os);

  error("delobj",sts);

  return(oid);
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ con_all_obj */
/* construct all objects */
 con_all_obj()
 {
  int sts, i, j;
  OM_S_OBJID conobj ();

  for(i=0; i < MAXOS; i++) {
   for(j=0; j < MAXOBJ; j++ ) {
     oid[i][j] = conobj(os[i]);
  }}
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ conobj */
/* construct an object */
 OM_S_OBJID conobj (os)
 OMuword os;
 {
  int sts;
  OM_S_OBJID oid;

  sts = om$construct(classname = "k", osnum = os,
			p_objid = &oid);
  error("conobj OM$construct fail",sts);
  l_printf("conobj constructed object (%d,%d)\n",os,oid);
  return(oid);
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ conTos */
/* construct Transient objspaces */
 conTos()
 {
  int sts, i, d;
  char name[80];

  for(i=0; i < 10; i++) {
    sprintf(name, "TestTransOS_%d",i);
    sts = om$construct_os(classname = "OMTransOS",
			  p_objid   = &d,
			  osname    = name,
			  osnum	    = &os[i]);
    error("conTos",sts);
    l_printf("conTos trans os name=%s number=%d\n",name,os[i]);
  }
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_copy */
/* copy channels connections from one channel to another */
 l_copy (nos1, noid1, ch1, nos2, noid2, ch2)
 int nos1, noid1, nos2, noid2;
 OM_S_CHANNUM	ch1, ch2;
 {
  int sts;
  OM_S_CHANSELECT cs1, cs2;

  l_printf("l_copy  %d,%d(%d,%d) to %d,%d(%d,%d)\n",
		os[nos1],oid[nos1][noid1],ch1.classid,ch1.number,
		os[nos2],oid[nos2][noid2],ch2.classid,ch2.number);

  cs1.type = cs2.type = OM_e_num;
  cs1.u_sel.number = ch1;
  cs2.u_sel.number = ch2;

  sts = om$send (msg = message Root.copy_chan ( 
		   cs2,
		   oid[nos1][noid1], os[nos1], cs1),
		senderid = NULL, 
		targetid = oid[nos2][noid2], targetos = os[nos2]);

  error("l_copy",sts);
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_disconnect */
/* disconnect two objects */
 l_disconnect (nos1, noid1, ch1, nos2, noid2, ch2)
 int nos1, noid1, nos2, noid2;
 OM_S_CHANNUM	ch1, ch2;
 {
  int sts;
  OM_S_CHANSELECT cs1, cs2;

  l_printf(" %d,%d <X> %d,%d\n",
		os[nos1],oid[nos1][noid1],
		os[nos2],oid[nos2][noid2]);

  cs1.type = cs2.type = OM_e_num;
  cs1.u_sel.number = ch1;
  cs2.u_sel.number = ch2;

  sts = om$send (msg = message Root.disconnect ( 
		   cs1,
		   oid[nos2][noid2], os[nos2], cs2),
		senderid = NULL, 
		targetid = oid[nos1][noid1], targetos = os[nos1]);

  error("l_disconnect",sts);
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_move */
/* move channels connections from one object to another */
 l_move (nos1, noid1, ch1, nos2, noid2, ch2)
 int nos1, noid1, nos2, noid2;
 OM_S_CHANNUM	ch1, ch2;
 {
  int sts;
  OM_S_CHANSELECT cs1, cs2;

  l_printf("l_move  %d,%d(%d.%d) to %d,%d(%d.%d)\n",
		os[nos1],oid[nos1][noid1],ch1.classid,ch1.number,
		os[nos2],oid[nos2][noid2],ch2.classid,ch2.number);

  cs1.type = cs2.type = OM_e_num;
  cs1.u_sel.number = ch1;
  cs2.u_sel.number = ch2;

  sts = om$send (msg = message Root.move_chan ( 
		   cs2,
		   oid[nos1][noid1], os[nos1], cs1),
		senderid = NULL, 
		targetid = oid[nos2][noid2], targetos = os[nos2]);

  error("l_move",sts);
  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_printf  */
/* local printf vector - switcable on/off */
l_printf(s,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
 char *s;
 int p1, p2, p3, p4, p5, p6, p7, p8, p9, p10;
 {
  if ( ! l_do_print ) 
    return;
  printf(s, p1,p2,p3,p4,p5,p6,p7,p8,p9,p10);
  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_range */
/* range disconnect */
l_range (nos1, noid1, ch1, low, hi)
 int nos1, noid1;
 int low, hi;
 OM_S_CHANNUM	ch1;
 {
  int sts;
  OM_S_CHANSELECT cs1;

  l_printf("l_range  %d,%d(%d,%d) [%d-%d]\n",
		os[nos1],oid[nos1][noid1],ch1.classid,ch1.number,
		low,hi);

  cs1.type = OM_e_num;
  cs1.u_sel.number = ch1;

  sts = om$send (msg = message Root.range_disconnect ( cs1 , low, hi ),
		senderid = NULL, 
		targetos = os[nos1], targetid = oid[nos1][noid1]);

  error("l_range",sts);
  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_sibling */
/* sibling_send */
l_sibling (nos1, noid1, ch1, inc, exp)
 int nos1, noid1;
 OM_E_INC_FLAG inc;
 OM_S_CHANNUM	ch1;
 int exp;
 {
  int sts, ans;
  OM_S_CHANSELECT cs1;
  OMuword sos;

  l_printf("l_sibling  %d,%d\n",os[nos1],oid[nos1][noid1]);

  cs1.type = OM_e_num;
  cs1.u_sel.number = ch1;

  sos = OM_Gw_current_OS;
  if ( os[nos1] != sos ) {
    om$make_current_os ( osnum = os[nos1] );
  }

  ans = 0;
  sts = om$sibling_send (msg = message k.answer (&ans),
		p_chanselect=&cs1, senderid=oid[nos1][noid1], inclusive=inc);

  error("l_sibling",sts);
  ans_chk("sibling_send", ans, exp);
  
  if ( OM_Gw_current_OS != sos ) {
    om$make_current_os ( osnum = sos );
  }

  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_count */
/* get channel count  */
l_count (nos1, noid1, ch1)
 int nos1, noid1;
 OM_S_CHANNUM	ch1;
 {
  int sts, count;
  OM_S_CHANSELECT cs1;

  l_printf("l_count  %d,%d(%d.%d)\n",
		os[nos1],oid[nos1][noid1],ch1.classid,ch1.number);

  cs1.type = OM_e_num;
  cs1.u_sel.number = ch1;

  sts = om$get_channel_count (osnum = os[nos1], objid = oid[nos1][noid1],
		p_chanselect = &cs1, count = &count);

  error("l_count",sts);
  return(count);
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ l_wild */
/* wild disconnect */
l_wild (nos1, noid1, ch1)
 int nos1, noid1;
 OM_S_CHANNUM	ch1;
 {
  int sts;
  OM_S_CHANSELECT cs1;

  l_printf("l_wild  %d,%d(%d.%d)\n",
		os[nos1],oid[nos1][noid1],ch1.classid,ch1.number);

  cs1.type = OM_e_num;
  cs1.u_sel.number = ch1;

  sts = om$send (msg = message Root.wild_disconnect ( cs1 ),
		senderid = NULL, 
		targetid = oid[nos1][noid1], targetos = os[nos1]);

  error("l_wild",sts);
  return;
 }
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ dumpem */
 dumpem()
 {
  int i,j;

  for (i=0; i<MAXOS; i++) {
   for (j=0; j<MAXOBJ; j++) {
    som_show_object(os[i], oid[i][j]);
  }}
  return;
}
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ dumpiso */
 dumpiso()
 {
  int i;

  for (i=0; i<MAXOS; i++) {
    om$send(msg = message OMObjSpace.print_isodir (TRUE),
	  senderid = NULL,
	  targetid = OM_GA_OSDs[os[i]]->OSO_Oid, targetos = os[i]);
  }
  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ error */
/* check status - exit if bad */
 error(str,sts)
 char *str;
 int sts;
 {
  int i;

  if (sts == OM_S_SUCCESS)
    return;
  if (1&sts) {
#ifdef FOSURENOTNOW
    printf("!!!!!!!!!!! test INFORMATION status in %s\n",str);
    om$report_error(sts=sts);
#endif
    return;
  }
  if (!(3&sts)) {
    printf("!!!!!!!!!!! test WARNING status in %s\n",str);
    om$report_error(sts=sts);
    return;
  }
  if ( sts == OM_E_CLASS_CONFLICT ) {
    om$report_error(sts=sts);
    return;
  }
  printf("!!!!!!!!!!!!! test failed in %s\n",str);
  om$report_error(sts=sts);
  dumpiso();
  exit(0);
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ans_chk */
/* check numbered answered against number expected */
 ans_chk(str, ans, exp)
 char *str;
 int ans, exp;
 {
  if ( ans == exp )
    return;
  printf("ans_chk from %s  number answered %d, expected %d\n",str,ans,str);
  exit();
  return;
 }
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ c_error */
/* check expectet count vs actual count */
 c_error(str,nos, noid, ex, act)
 char *str;
 int nos, noid, ex, act;
 {
  int i;

  if (ex == act) 
    return;
  printf("!!!!!!! channel count error %d,%d(%s) expected=%d actual=%d\n",
		    os[nos], oid[nos][noid], str, ex, act);
  exit(0);
 }
end implementation Root;
