#ifndef dimac

#define dimac

/* individual send
   =============== */

#ifdef DEBUG
#define om_send(mss,my_id,object_id){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_object,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = object_id );\
  if((stat&1)!=1)\
  {\
    printf( "om_send in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send(mss,my_id,object_id){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_object,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = object_id );\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_send_me(mss){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_object,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = my_id );\
  if((stat&1)!=1)\
  {\
    printf( "om_send_me in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send_me(mss){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_object,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = my_id );\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_send_msg(mss,my_id,object_id){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_message,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = object_id);\
  if((stat&1)!=1)\
  {\
    printf( "om_send_msg in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send_msg(mss,my_id,object_id){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_message,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = object_id);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_send_me_msg(mss){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_message,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = my_id);\
  if((stat&1)!=1)\
  {\
    printf( "om_send_me_msg in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send_me_msg(mss){\
  int stat;\
  stat = om$send ( mode     = OM_e_wrt_message,\
                   msg      = message mss,\
                   senderid = my_id,\
                   targetid = my_id);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_send_for(mss,my_id,object_id,osnum){\
  int stat;\
     stat=om$send(mode = OM_e_wrt_object,\
                  msg = message mss,\
                  senderid = my_id,\
                  targetid = object_id,\
                  targetos = osnum);\
  if((stat&1)!=1)\
  {\
    printf( "om_send_for in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send_for(mss,my_id,object_id,osnum){\
  int stat;\
     stat=om$send(mode = OM_e_wrt_object,\
                  msg = message mss,\
                  senderid = my_id,\
                  targetid = object_id,\
                  targetos = osnum);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_send_for_msg(mss,my_id,object_id,osnum){\
  int stat;\
  stat = om$send( mode     = OM_e_wrt_message,\
                  msg      = message mss,\
                  senderid = my_id,\
                  targetid = object_id,\
                  targetos = osnum);\
  if((stat&1)!=1)\
  {\
    printf( "om_send_for_msg in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send_for_msg(mss,my_id,object_id,osnum){\
  int stat;\
  stat = om$send( mode     = OM_e_wrt_message,\
                  msg      = message mss,\
                  senderid = my_id,\
                  targetid = object_id,\
                  targetos = osnum);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


/* channel send 
   ============ */

#ifdef DEBUG
#define om_send_chan(mss,my_id,chan_addr){\
 int stat;\
 OM_S_CHANSELECT chan;\
 chan.type = OM_e_addr;\
 chan.u_sel.addr = chan_addr;\
 stat = om$send ( mode = OM_e_wrt_object,\
                  msg = message mss,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = 0,\
                  to = 0);\
  if((stat&1)!=1)\
  {\
    printf( "om_send_chan in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send_chan(mss,my_id,chan_addr){\
 int stat;\
 OM_S_CHANSELECT chan;\
 chan.type = OM_e_addr;\
 chan.u_sel.addr = chan_addr;\
 stat = om$send ( mode = OM_e_wrt_object,\
                  msg = message mss,\
                  senderid = my_id,\
                  p_chanselect = &chan,\
                  from = 0,\
                  to = 0);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif

#ifdef DEBUG
#define om_send_channame(mss,objid,channame){\
  int stat;\
  OM_S_CHANSELECT chan;\
  chan.type = OM_e_name;\
  chan.u_sel.name = channame;\
  stat = om$send ( mode = OM_e_wrt_object,\
                   msg = message mss,\
                   senderid = objid,\
                   p_chanselect = &chan,\
                   from = 0,\
                   to = 0);\
  if((stat&1)!=1)\
  {\
    printf( "om_send_channame in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_send_channame(mss,objid,channame){\
  int stat;\
  OM_S_CHANSELECT chan;\
  chan.type = OM_e_name;\
  chan.u_sel.name = channame;\
  stat = om$send ( mode = OM_e_wrt_object,\
                   msg = message mss,\
                   senderid = objid,\
                   p_chanselect = &chan,\
                   from = 0,\
                   to = 0);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif



/* channel inquiries 
   ================= */

#ifdef DEBUG
#define om_channame_count(obj_id,channame,cnt){\
  int stat;\
  char OSname[OM_K_MAXOSNAME_LEN];\
  OM_S_CHANSELECT chan;\
  chan.type = OM_e_name;\
  chan.u_sel.name = channame;\
  stat = om$get_channel_count ( osnum = OM_Gw_current_OS,\
                                objid = obj_id,\
                                p_chanselect = &chan,\
                                count = cnt);\
  if((stat&1)!=1)\
  {\
    printf( "om_channame_count in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_channame_count(obj_id,channame,cnt){\
  int stat;\
  char OSname[OM_K_MAXOSNAME_LEN];\
  OM_S_CHANSELECT chan;\
  chan.type = OM_e_name;\
  chan.u_sel.name = channame;\
  stat = om$get_channel_count ( osnum = OM_Gw_current_OS,\
                                objid = obj_id,\
                                p_chanselect = &chan,\
                                count = cnt);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif
  

#ifdef DEBUG
#define om_chan_count(obj_id,chan_addr,cnt){\
  int stat;\
  OM_S_CHANSELECT chan;\
  chan.type = OM_e_addr;\
  chan.u_sel.addr = chan_addr;\
  stat = om$get_channel_count ( osnum = OM_Gw_current_OS,\
                                objid = obj_id,\
                                p_chanselect = &chan,\
                                count = cnt);\
  if((stat&1)!=1)\
  {\
    printf( "om_chan_count in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_chan_count(obj_id,chan_addr,cnt){\
  int stat;\
  OM_S_CHANSELECT chan;\
  chan.type = OM_e_addr;\
  chan.u_sel.addr = chan_addr;\
  stat = om$get_channel_count ( osnum = OM_Gw_current_OS,\
                                objid = obj_id,\
                                p_chanselect = &chan,\
                                count = cnt);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_convert_channame(chan_name,number){\
  int stat;\
  stat=om$get_channel_number (channame = chan_name,\
                              p_channum = number );\
  if((stat&1)!=1)\
  {\
    printf( "om_convert_channame in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_convert_channame(chan_name,number){\
  int stat;\
  stat=om$get_channel_number (channame = chan_name,\
                              p_channum = number );\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


/* channel operation
   ================= */

#ifdef DEBUG
#define om_connect_by_name(objid1,name1,objid2,name2){\
  int stat;\
  OM_S_CHANSELECT chan1, chan2;\
  chan1.type = OM_e_name;\
  chan1.u_sel.name = name2;\
  chan2.type = OM_e_name;\
  chan2.u_sel.name = name1;\
  stat = om$send ( mode = OM_e_wrt_object,\
                   msg  = message Root.connect ( chan1, 0, objid1,\
                                                 OM_Gw_current_OS, chan2,\
                                                 0),\
                   senderid = objid1,\
                   targetid = objid2);\
  if((stat&1)!=1)\
  {\
    printf( "om_connect_by_name in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_connect_by_name(objid1,name1,objid2,name2){\
  int stat;\
  OM_S_CHANSELECT chan1, chan2;\
  chan1.type = OM_e_name;\
  chan1.u_sel.name = name2;\
  chan2.type = OM_e_name;\
  chan2.u_sel.name = name1;\
  stat = om$send ( mode = OM_e_wrt_object,\
                   msg  = message Root.connect ( chan1, 0, objid1,\
                                                 OM_Gw_current_OS, chan2,\
                                                 0),\
                   senderid = objid1,\
                   targetid = objid2);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_disconnect_by_name(send_obj,name1,targ_obj,name2){\
  int stat;\
  OMuword os = OM_Gw_current_OS;\
  OM_S_CHANSELECT to_sel, fr_sel;\
  to_sel.type = OM_e_name;\
  to_sel.u_sel.name = name2;\
  fr_sel.type = OM_e_name;\
  fr_sel.u_sel.name = name1;\
  stat = om$send ( mode = OM_e_wrt_object,\
                   msg = message Root.disconnect ( to_sel, send_obj, os,\
                                                   fr_sel),\
                   senderid = send_obj,\
                   targetid = targ_obj);\
  if((stat&1)!=1)\
  {\
    printf( "om_disconnect_by_name in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_disconnect_by_name(send_obj,name1,targ_obj,name2){\
  int stat;\
  OMuword os = OM_Gw_current_OS;\
  OM_S_CHANSELECT to_sel, fr_sel;\
  to_sel.type = OM_e_name;\
  to_sel.u_sel.name = name2;\
  fr_sel.type = OM_e_name;\
  fr_sel.u_sel.name = name1;\
  stat = om$send ( mode = OM_e_wrt_object,\
                   msg = message Root.disconnect ( to_sel, send_obj, os,\
                                                   fr_sel),\
                   senderid = send_obj,\
                   targetid = targ_obj);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


/* object construction
   =================== */

#ifdef DEBUG
#define om_construct_by_name(name,os,objid){\
  int stat;\
  stat = om$construct ( osnum = os,\
                        classname = name,\
                        p_objid = objid,\
                        neighbor = OM_GS_NULL_NEIGHBOR);\
  if((stat&1)!=1)\
  {\
    printf( "om_construct_by_name in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_construct_by_name(name,os,objid){\
  int stat;\
  stat = om$construct ( osnum = os,\
                        classname = name,\
                        p_objid = objid,\
                        neighbor = OM_GS_NULL_NEIGHBOR);\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


#ifdef DEBUG
#define om_get_classid(os,obj,clssd){\
  int stat;\
  stat = om$get_classid ( osnum     = os,\
                          objid     = obj,\
                          p_classid = clssd );\
  if((stat&1)!=1)\
  {\
    printf( "om_get_classid in file %s at line %d\n",\
            __FILE__, __LINE__ );\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#else
#define om_get_classid(os,obj,clssd){\
  int stat;\
  stat = om$get_classid ( osnum     = os,\
                          objid     = obj,\
                          p_classid = clssd );\
  if((stat&1)!=1)\
  {\
    om$report_error( sts = stat ); return OM_W_ABORT;\
  }\
}
#endif


/* Usefull macros to malloc memory and test the result */

#ifdef NT
#include <malloc.h>
#endif

#ifdef DEBUG
#define DImalloc(ptr,type,size)\
{\
  if (!((ptr) = (type)malloc(size)))\
  {\
    fprintf ( stderr, "in %s at line %d : CAN'T malloc\n",\
              __FILE__, __LINE__ );\
    return ( OM_E_NODYNMEM );\
  }\
}
#else
#define DImalloc(ptr,type,size)\
{\
  if (!((ptr) = (type)malloc(size)))\
    return ( OM_E_NODYNMEM );\
}
#endif

                                   
#ifdef DEBUG
#define DIrealloc(ptr,type,size)\
{\
  if (!((ptr) = (type)realloc(ptr,size)))\
  {\
    fprintf ( stderr, "in %s at line %d : CAN'T realloc\n",\
              __FILE__, __LINE__ );\
    return ( OM_E_NODYNMEM );\
  }\
}
#else
#define DIrealloc(ptr,type,size)\
{\
  if (!((ptr) = (type)realloc(ptr,size)))\
    return ( OM_E_NODYNMEM );\
}
#endif


#ifdef DEBUG
#define DIfree(ptr)\
{\
  if (!(ptr))\
  {\
    fprintf ( stderr, "in %s at line %d : CAN'T free\n",\
              __FILE__, __LINE__ );\
  }\
  else \
  {\
    free ( ptr );\
    ptr = NULL;\
  }\
}
#else
#define DIfree(ptr)\
{\
  if (ptr)\
  {\
    free ( ptr );\
    ptr = NULL;\
  }\
}
#endif



#define DIvalidate(status,type)\
{\
  DIint st;\
  \
  st = om$send ( msg      = message GRoups.validate ( status, type ),\
                 targetid = my_id );\
  if (st != OM_S_SUCCESS)\
    *status = DIR_S_SUCCESS;\
  else\
    if (*status != DIR_S_SUCCESS)\
      return OM_S_SUCCESS;\
}


#define DIcheck_link(diros,dirid)\
{\
  if (DIancestry_valid ( diros, dirid, DIR_G_DIlink_clid ))\
    om$get_intercept ( osnum          = diros,\
                       objid          = dirid,\
                       p_target_osnum = &diros,\
                       p_target_objid = &dirid );\
}



#endif
