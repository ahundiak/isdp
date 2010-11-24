#ifndef RISNET_STUBS_H_
#define RISNET_STUBS_H_

extern void NET_connect_xns();
extern void NET_accept_xns();
extern void NET_write_xns();
extern void NET_read_xns();
extern void NET_close_xns();
extern void NET_addr_xns();
extern void NET_node_xns();
extern void NET_get_file_xns();
extern void NET_put_file_xns();
extern void NET_get_lock_file_xns();
extern void NET_put_lock_file_xns();
extern void NET_remove_file_xns();

extern void NET_connect_dnp();
extern void NET_accept_dnp();
extern void NET_write_dnp();
extern void NET_read_dnp();
extern void NET_close_dnp();
extern void NET_addr_dnp();
extern void NET_node_dnp();
extern void NET_get_file_dnp();
extern void NET_put_file_dnp();
extern void NET_get_lock_file_dnp();
extern void NET_put_lock_file_dnp();
extern void NET_remove_file_dnp();

extern void NET_connect_lu62();
extern void NET_accept_lu62();
extern void NET_write_lu62();
extern void NET_read_lu62();
extern void NET_close_lu62();
extern void NET_addr_lu62();
extern void NET_node_lu62();
extern void NET_get_file_lu62();
extern void NET_put_file_lu62();
extern void NET_get_lock_file_lu62();
extern void NET_put_lock_file_lu62();
extern void NET_remove_file_lu62();

extern void NET_connect_local();
extern void NET_accept_local();
extern void NET_write_local();
extern void NET_read_local();
extern void NET_close_local();
extern void NET_addr_local();
extern void NET_node_local();
extern void NET_get_file_local();
extern void NET_put_file_local();
extern void NET_get_lock_file_local();
extern void NET_put_lock_file_local();
extern void NET_remove_file_local();

#endif
