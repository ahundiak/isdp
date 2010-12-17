#include "SCstruct.h"

NFMfunction block_type();
NFMfunction change_command();
NFMfunction client_file();
NFMfunction cross_ref();
NFMfunction date_format();
NFMfunction debug_off();
NFMfunction debug_on();
NFMfunction del_oper();
NFMfunction display_trans_proc();
NFMfunction export_env();
NFMfunction import_env();
NFMfunction load_program();
NFMfunction log_out();
NFMfunction login_in();
NFMfunction nfm_adm_begin_playback();
NFMfunction nfm_adm_begin_record();
NFMfunction nfm_adm_end_record();
NFMfunction nfs_clean();
NFMfunction prog_to_trans();
NFMfunction purge_activity();
NFMfunction repair_uti();
NFMfunction ris_clean();
NFMfunction ser_login_out();
NFMfunction server_file();
NFMfunction set_access();
NFMfunction set_lock();
NFMfunction slot_file();
NFMfunction storage_file();
NFMfunction time_format();

int SCatofn_count = 29;

struct SCatofn_st SCatofn[] = {{"block_type",block_type},
                               {"change_command",change_command},
                               {"client_file",client_file},
                               {"cross_ref",cross_ref},
                               {"date_format",date_format},
                               {"debug_off",debug_off},
                               {"debug_on",debug_on},
                               {"del_oper",del_oper},
                               {"display_trans_proc",display_trans_proc},
                               {"export_env",export_env},
                               {"import_env",import_env},
                               {"load_program",load_program},
                               {"log_out",log_out},
                               {"login_in",login_in},
                               {"nfm_adm_begin_playback",nfm_adm_begin_playback},
                               {"nfm_adm_begin_record",nfm_adm_begin_record},
                               {"nfm_adm_end_record",nfm_adm_end_record},
                               {"nfs_clean",nfs_clean},
                               {"prog_to_trans",prog_to_trans},
                               {"purge_activity",purge_activity},
                               {"repair_uti",repair_uti},
                               {"ris_clean",ris_clean},
                               {"ser_login_out",ser_login_out},
                               {"server_file",server_file},
                               {"set_access",set_access},
                               {"set_lock",set_lock},
                               {"slot_file",slot_file},
                               {"storage_file",storage_file},
                               {"time_format",time_format}};

char *nfm_path = "../admin";
