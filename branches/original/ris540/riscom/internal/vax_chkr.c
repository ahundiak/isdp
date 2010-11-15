/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */

#ifdef VAX_CHECKER

/*
** For every item in the structures, print its offset from the
** beginning of the structure.  The total sizes of the structures
** do not matter because we are always using variable buffers.
** However, the position of each item within each structure
** has to be the same on the CLIPPER/SUN and on the VAX.
**
** If they do not match up, the client will put things into the
** buffer in one place but the vax server will look for them
** somewhere else.
*/

main()
{
	printf("----- Client to Server buf -- size %d -----\n",
		sizeof(ris_clisrv_buf));
	printf("%d\n",&((ris_clisrv_buf *)0)->opcode);
	printf("%d\n",&((ris_clisrv_buf *)0)->stmt_id);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.in_data);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.in_sqlvar);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.out_sqlvar);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.query);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.in_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.out_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.query_len);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.stmt_type);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pddo.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe.in_data);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe.in_sqlvar);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe.query);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe.in_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe.query_len);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe.stmt_type);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.pe.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.open);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.open.in_data);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.open.dbms);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.open.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec.in_data);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec.dbms);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.fetch);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.fetch.dbms);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.fetch.row_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.get_tab);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.get_tab.tabname[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.get_schema_grantors);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.get_schema_grantors.schname[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.alt_schema);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.alt_schema.tabtype);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.alt_schema.tabname[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.drop);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.drop.query);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.drop.name[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.drop.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.get_access);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.get_access.data);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_table);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_table.col_sqlvar);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_table.def_string);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_table.col_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_table.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_index);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_index.def_string);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_index.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_view);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_view.col_sqlvar);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_view.dbms_string);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_view.ris_string);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_view.col_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_view.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.alter_table);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.alter_table.col_sqlvar);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.alter_table.def_string);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.alter_table.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec_now);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec_now.string);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec_now.stmt_type);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.exec_now.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.lock_tables);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.lock_tables.string);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.lock_tables.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_schema);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_schema.schema);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_schema.db);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_schema.force_flag);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_schema.autocommit_flag);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.schema_db);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.schema_db.schema);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.schema_db.db);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.schema_db.newpasswd[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.schema_db.autocommit_flag);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.debug);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.debug.data);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.grow);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.grow.new_size);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.init);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.init.max_rows);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.init.max_buf_size);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.init.debug);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.init.maj);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.init.min);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.init.rel);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_user);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.create_user.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.new_schpass);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.new_schpass.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.upd_access);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.upd_access.acc);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.upd_access.count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.upd_access.delete_flag);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.upd_access.more_to_follow);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.upd_access.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risdbs);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risdbs.dbs);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risdbs.db_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risdbs.delete_flag);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risdbs.more_to_follow);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risdbs.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risschemas);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risschemas.schemas);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risschemas.schema_count);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risschemas.delete_flag);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risschemas.more_to_follow);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.load_risschemas.data[0]);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.drop_schema);
	printf("%d\n",&((ris_clisrv_buf *)0)->buf.drop_schema.force_flag);
	printf("----- Server to Client buf -------\n");
	printf("----- Server to Client buf -- size %d -----\n",
		sizeof(ris_srvcli_buf));
	printf("%d\n",&((ris_srvcli_buf *)0)->status);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.fetch);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.fetch.row_count);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.fetch.more_to_follow);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.fetch.data[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_tab);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_tab.count);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_tab.data[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_tabtype);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_tabtype.data);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_access);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_access.count);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_access.more_to_follow);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_access.data[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_grantees);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_grantees.count);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_grantees.more_to_follow);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.get_grantees.data[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.pddo);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.pddo.dbms);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.pe);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.pe.dbms);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.create_schema);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.create_schema.pid);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.create_schema.dbversion);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.create_schema.xns_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.create_schema.tcp_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.create_schema.dnp_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.create_schema.lu62_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.open_schema);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.open_schema.pid);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.open_schema.dbversion);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.open_schema.xns_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.open_schema.tcp_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.open_schema.dnp_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.open_schema.lu62_addr[0]);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.error);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.error.dbstmt_len);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.error.dbca);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.error.dbms);
	printf("%d\n",&((ris_srvcli_buf *)0)->buf.error.data[0]);
}
#endif /*  VAX_CHECKER */
