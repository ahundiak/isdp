#include "SCstruct.h"

NFMfunction nfm_bulk_load();
NFMfunction nfm_client_debug_off();
NFMfunction nfm_client_debug_on();
NFMfunction nfm_debug_off();
NFMfunction nfm_debug_on();
NFMfunction nfm_display_catalogs();
NFMfunction nfm_display_items();
NFMfunction nfm_display_nodes();
NFMfunction nfm_display_storage_areas();
NFMfunction nfm_display_working_areas();
NFMfunction nfm_server_debug_off();
NFMfunction nfm_server_debug_on();

int SCatofn_count = 12;

struct SCatofn_st SCatofn[] = {{"nfm_bulk_load",nfm_bulk_load},
                               {"nfm_client_debug_off",nfm_client_debug_off},
                               {"nfm_client_debug_on",nfm_client_debug_on},
                               {"nfm_debug_off",nfm_debug_off},
                               {"nfm_debug_on",nfm_debug_on},
                               {"nfm_display_catalogs",nfm_display_catalogs},
                               {"nfm_display_items",nfm_display_items},
                               {"nfm_display_nodes",nfm_display_nodes},
                               {"nfm_display_storage_areas",nfm_display_storage_areas},
                               {"nfm_display_working_areas",nfm_display_working_areas},
                               {"nfm_server_debug_off",nfm_server_debug_off},
                               {"nfm_server_debug_on",nfm_server_debug_on}};
char *
nfm_path = "../bulkload";
