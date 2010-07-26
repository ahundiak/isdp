/* test utilities
   ============== */

#define If_Err_Abort(stat,msg) \
    if((stat&1)!=1)\
     {\
/*      printf("%s\n",msg);\
/*      om$report_error(sts = stat);*/ \
      return(OM_W_ABORT);\
     }

#define If_Err_Exit(stat,msg) \
    if((stat&1)!=1)\
     {\
      printf("%s\n",msg);\
      om$report_error(sts = stat);\
      exit(1);\
     }

#define Abort(msg) \
    {\
     printf("%s\n",msg);\
     return(OM_W_ABORT);\
    }



/* individual send
   =============== */

#define om_send(msg_struct,my_id,object_id,caller_name) \
    {int stat;\
     stat=om$send(mode = OM_e_wrt_object,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  targetid = object_id);\
     if((stat&1)!=1) { /**** printf("%s OM_send_object error\n",caller_name);\
        om$report_error(sts = stat);*****/ return(OM_W_ABORT);}}



#define om_send_msg(msg_struct,my_id,object_id,caller_name) \
    {int stat;\
     stat=om$send(mode = OM_e_wrt_message,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  targetid = object_id);\
     if((stat&1)!=1) {/***** printf("%s OM_send_object error\n",caller_name);\
        om$report_error(sts = stat);******/ return(OM_W_ABORT);}}


#define om_send_for(msg_struct,my_id,object_id,osnum,caller_name) \
    {int stat;\
     stat=om$send(mode = OM_e_wrt_object,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  targetid = object_id,\
                  targetos = osnum);\
     if((stat&1)!=1) {/***** printf("%s OM_send_object error\n",caller_name);\
        om$report_error(sts = stat);****/ return(OM_W_ABORT);}}

#define om_send_for_msg(msg_struct,my_id,object_id,osnum,caller_name) \
    {int stat;\
     stat=om$send(mode = OM_e_wrt_message,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  targetid = object_id,\
                  targetos = osnum);\
     if((stat&1)!=1) {/***** printf("%s OM_send_object error\n",caller_name);\
        om$report_error(sts = stat);*****/ return(OM_W_ABORT);}}

/* channel send 
   ============ */

#define om_send_chan(msg_struct,my_id,chan_addr,caller_name) \
    {int stat;\
     OM_S_CHANSELECT chan;\
     chan.type = OM_e_addr;\
     chan.u_sel.addr = chan_addr;\
     stat=om$send(mode = OM_e_wrt_object,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = 0,\
                  to = 0);\
     if((stat&1)!=1) {/***** printf("%s OM_send_channel error\n",caller_name);\
        om$report_error(sts = stat);*****/ return(OM_W_ABORT);}}

#define om_send_chan_msg(msg_struct,my_id,chan_addr,caller_name) \
    {int stat;\
     OM_S_CHANSELECT chan;\
     chan.type = OM_e_addr;\
     chan.u_sel.addr = chan_addr;\
     stat=om$send(mode = OM_e_wrt_message,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = 0,\
                  to = 0);\
     if((stat&1)!=1) {/***** printf("%s OM_send_channel error\n",caller_name);\
        om$report_error(sts = stat);****/ return(OM_W_ABORT);}}

#define om_send_channame(msg_struct,objid,channame,caller_name) \
   {int stat;\
   OM_S_CHANSELECT chan;\
   chan.type = OM_e_name;\
   chan.u_sel.name = channame;\
   stat=om$send(mode = OM_e_wrt_object,\
                 msg = msg_struct,\
                 senderid = objid,\
                 p_chanselect = &chan,\
                 from = 0,\
                 to = 0);\
    if((stat&1)!=1) {/****printf("%s OM_send_by_channame error\n",caller_name);\
       om$report_error(sts = stat);*****/ return(OM_W_ABORT);}}


#define om_send_channame_msg(msg_struct,objid,channame,caller_name) \
   {int stat;\
   OM_S_CHANSELECT chan;\
   chan.type = OM_e_name;\
   chan.u_sel.name = channame;\
    stat=om$send(mode = OM_e_wrt_message,\
                 msg = msg_struct,\
                 senderid = objid,\
                 p_chanselect = &chan,\
                 from = 0,\
                 to = 0);\
    if((stat&1)!=1) {/****printf("%s OM_send_by_channame error\n",caller_name);\
       om$report_error(sts = stat);*****/ return(OM_W_ABORT);}}

#define om_send_channum(msg_struct,my_id,channum,caller_name) \
   {int stat;\
   OM_S_CHANSELECT chan;\
   chan.type = OM_e_num;\
   chan.u_sel.number = channum;\
     stat=om$send(mode = OM_e_wrt_object,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = 0,\
                  to = 0);\
     if((stat&1)!=1) {/**** printf("%s OM_send_channel error\n",caller_name);\
        om$report_error(sts = stat);*****/ return(OM_W_ABORT);}}

#define om_send_channum_msg(msg_struct,my_id,channum,caller_name) \
   {int stat;\
   OM_S_CHANSELECT chan;\
   chan.type = OM_e_num;\
   chan.u_sel.number = channum;\
     stat=om$send(mode = OM_e_wrt_message,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = 0,\
                  to = 0);\
     if((stat&1)!=1) {/*** printf("%s OM_send_channel error\n",caller_name);\
        om$report_error(sts = stat);***/ return(OM_W_ABORT);}}

#define om_send_ord_chan(msg_struct,my_id,chan_addr,ndx1,ndx2,caller_name) \
    {int stat;\
     OM_S_CHANSELECT chan;\
     chan.type = OM_e_addr;\
     chan.u_sel.addr = chan_addr;\
     stat=om$send(mode = OM_e_wrt_object,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = ndx1,\
                  to = ndx2);\
     if((stat&1)!=1) {/**** printf("%s OM_send_channel error\n",caller_name);\
        om$report_error(sts = stat);****/ return(OM_W_ABORT);}}

#define om_send_ord_chan_msg(msg_struct,my_id,chan_addr,ndx1,ndx2,caller_name) \
    {int stat;\
     OM_S_CHANSELECT chan;\
     chan.type = OM_e_addr;\
     chan.u_sel.addr = chan_addr;\
     stat=om$send(mode = OM_e_wrt_message,\
                  msg = msg_struct,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = ndx1,\
                  to = ndx2);\
     if((stat&1)!=1) {/***** printf("%s OM_send_channel error\n",caller_name);\
        om$report_error(sts = stat);****/ return(OM_W_ABORT);}}


/* channel inquiries 
   ================= */

#define om_channame_count(obj_id,channame,cnt,caller_name) \
    {int stat; char OSname[OM_K_MAXOSNAME_LEN];\
     OM_S_CHANSELECT chan;\
     chan.type = OM_e_name;\
     chan.u_sel.name = channame;\
     stat=om$get_channel_count(osnum = OM_Gw_current_OS,\
                               objid = obj_id,\
                               p_chanselect = &chan,\
                               count = cnt);\
     if((stat&1)!=1) {/*printf("%s OM_get_channame_count error\n",caller_name);\
        om$report_error(sts = stat);****/ return(OM_W_ABORT);}}
  
#define om_chan_count(obj_id,chan_addr,cnt,caller_name) \
    {int stat;\
     OM_S_CHANSELECT chan;\
     chan.type = OM_e_addr;\
     chan.u_sel.addr = chan_addr;\
     stat=om$get_channel_count(osnum = OM_Gw_current_OS,\
                               objid = obj_id,\
                               p_chanselect = &chan,\
                               count = cnt);\
     if((stat&1)!=1) {/**printf("%s OM_get_channel_count error\n",caller_name);\
        om$report_error(sts = stat);***/ return(OM_W_ABORT);}}


#define om_convert_channame(chan_name,number,caller_name) \
    {int stat;\
     stat=om$get_channel_number (channame = chan_name,\
                                 p_channum = number );\
     if((stat&1)!=1) {/** printf("%s OM_cvrt_chaname_to_num error\n",caller_name);\
        om$report_error(sts = stat);*****/ return(OM_W_ABORT);}}


/* channel operation
   ================= */

#define om_connect_by_name(objid1,name1,objid2,name2,caller_name) \
  {int stat;\
   OM_S_CHANSELECT chan1, chan2;\
   chan1.type = OM_e_name;\
   chan1.u_sel.name = name2;\
   chan2.type = OM_e_name;\
   chan2.u_sel.name = name1;\
   stat=om$send(mode = OM_e_wrt_object,\
                msg = message Root.connect\
                              (chan1,\
                               NULL,\
                               objid1,\
                               OM_Gw_current_OS,\
                               chan2,\
                               NULL),\
                senderid = objid1,\
                targetid = objid2);\
     if((stat&1)!=1) {/*** printf("%s OM_send (Root.connect) error\n",caller_name);\
        om$report_error(sts = stat);***/ return(OM_W_ABORT);}}


#define om_disconnect_by_name(send_obj,name1,targ_obj,name2,caller_name) \
   {int stat;\
   OMuword obj_space = OM_Gw_current_OS;\
   OM_S_CHANSELECT to_sel, fr_sel;\
   to_sel.type = OM_e_name;\
   to_sel.u_sel.name = name2;\
   fr_sel.type = OM_e_name;\
   fr_sel.u_sel.name = name1;\
   stat=om$send(mode = OM_e_wrt_object,\
                msg = message Root.disconnect\
                (to_sel,send_obj,obj_space,fr_sel),\
                senderid = send_obj,\
                targetid = targ_obj);\
    if((stat&1)!=1) {/*** printf("%s om_disconnect_by_name error\n",caller_name);\
	om$report_error(sts = stat);***/ return(OM_W_ABORT);}}


#define om_connect_by_number(OS_num1,objid1,num1,OS_num2,objid2,num2,caller_name) \
  {int stat;\
   OM_S_CHANSELECT chan1, chan2;\
   chan1.type = OM_e_num;\
   chan1.u_sel.number = num2;\
   chan2.type = OM_e_num;\
   chan2.u_sel.number = num1;\
   stat=om$send(mode = OM_e_wrt_message,\
                msg = message Root.connect\
                              (chan1,\
                               NULL,\
                               objid1,\
                               OS_num1,\
                               chan2,\
                               NULL),\
                senderid = objid1,\
                targetid = objid2,\
                targetos = OS_num2);\
     if((stat&1)!=1) {/*** printf("%s OM_send (Root.connect) error\n",caller_name);\
        om$report_error(sts = stat);****/ return(OM_W_ABORT);}}



#define om_disconnect_by_number(send_obj,num1,targ_obj,num2,caller_name) \
   {int stat;\
   OM_S_CHANSELECT to_sel, fr_sel;\
   OMuword obj_space = OM_Gw_current_OS;\
   to_sel.type = OM_e_num;\
   to_sel.u_sel.number = num2;\
   fr_sel.type = OM_e_num;\
   fr_sel.u_sel.number = num1;\
   stat=om$send(mode = OM_e_wrt_object,\
                msg = message Root.disconnect\
                (to_sel,send_obj,obj_space,fr_sel),\
                senderid = send_obj,\
                targetid = targ_obj);\
    if((stat&1)!=1) {/** printf("%s om_disconnect_by_num error\n",caller_name);\
	om$report_error(sts = stat);***/ return(OM_W_ABORT);}}

#define om_wild_disconnect_by_name(Name,obj_id,caller_name)\
  {int stat;\
  OM_S_CHANSELECT chan;\
  chan.type=OM_e_name;\
  chan.u_sel.name=Name;\
  stat=om$send(mode = OM_e_wrt_object,\
               msg = message Root.wild_disconnect(chan),\
               targetid = obj_id);\
   if((stat&1)!=1) {/** printf("%s om_wild_discon_by_name error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}
 



/* object construction
   =================== */

   
#define om_construct_by_name(name,objid,caller_name) \
  {int stat; char OSname[OM_K_MAXOSNAME_LEN];\
   stat=om$os_number_to_name(osnum = OM_Gw_current_OS,\
                             osname = OSname);\
   if((stat&1)!=1) {/*** printf("%s OM_convert_OS_num error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}\
   stat=om$construct(osname = OSname,\
                     classname = name,\
                     p_objid = objid,\
                     neighbor = OM_GS_NULL_NEIGHBOR);\
   if((stat&1)!=1) {/** printf("%s OM_construct_by_name error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}



#define om_construct_by_name_and_OSnum(name,os,objid,caller_name) \
  {int stat; char OSname[OM_K_MAXOSNAME_LEN];\
   stat=om$os_number_to_name(osnum = os,\
                             osname = OSname);\
   if((stat&1)!=1) {/** printf("%s OM_convert_OS_num error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}\
   stat=om$construct(osname = OSname,\
                     classname = name,\
                     p_objid = objid,\
                     neighbor = OM_GS_NULL_NEIGHBOR);\
   if((stat&1)!=1) {/** printf("%s OM_construct_by_name error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}



#define om_construct_and_copy_me(obj_id,caller_name) \
  {int stat;\
   stat=om$construct_and_copy(objid = my_id, \
                              osnum = OM_Gw_current_OS,\
                              p_objid = obj_id);\
   if((stat&1)!=1)\
    {/** printf("%s OM_construct_and_copy_me error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}




#define om_construct_object_by_classid(classid,objid,caller_name) \
  {int stat;\
   stat=om$construct(osnum = OM_Gw_current_OS,\
                     classid = classid,\
                     p_objid = objid,\
                     neighbor = \
        OM_GS_NULL_NEIGHBOR);\
   if((stat&1)!=1) {/** printf("%s OM_construct_by_classid error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}


#define om_construct_object(os,cid,objid,msgname,caller_name) \
  {int stat;\
   stat=om$construct(msg = msgname,\
	 	     osnum = os,\
                     classid = cid,\
                     p_objid = objid,\
                     neighbor = OM_GS_NULL_NEIGHBOR);\
   if((stat&1)!=1) {/** printf("%s OM_construct_by_classid error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}


/* Miscellaneous
   ============= */



#define om_make_message(class_name,mess_name,arg,message,caller_name) \
  {int stat;\
    stat=om$make_message(classname = class_name,\
                         methodname = mess_name,\
                         size = sizeof ( arg ),\
                         p_arglist = &arg,\
                         p_msg = message); \
    if((stat&1)!=1) {/** printf("%s OM_make_message error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}



#define om_make_s_message(class_name,mess_name,message,caller_name) \
  {int stat;\
    stat=om$make_message(classname = class_name,\
                         methodname = mess_name,\
                         size = NULL,\
                         p_arglist = NULL,\
                         p_msg = message); \
    if((stat&1)!=1) {/** printf("%s OM_make_message error\n",caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}



#define om_get_clas_name(clname,clssd)\
  {int stat;\
   stat=om$get_classid(classname = clname,\
                       p_classid = clssd);\
   if((stat&1)!=1) {/** printf("%s OM_get_classid errors\n", clname);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}



#define om_get_clas_objid(oss,obid,clssd,caller_name)\
  {int stat;\
   stat=om$get_classid(osnum = oss,\
                       objid = obid,\
                       p_classid = clssd);\
   if((stat&1)!=1) {/** printf("%s OM_get_classid_from_objid errors\n",\
                     caller_name);\
        om$report_error(sts = stat);**/ return(OM_W_ABORT);}}



