#ifndef mspriv_include
#define mspriv_include

struct MS_sd_table
{
   IGRlong msgno;
   IGRchar *msg_chars;
};

struct MS_sd_name 
{
    IGRchar *name;
    struct MS_sd_table *table_link;
};

struct MS_header
{
    IGRint no_entries;
    IGRint nm_entries;
    struct MS_sd_table *table;
    struct MS_sd_name  *n_table;
    struct MS_header *next;
};

struct MS_malloc_header
{
    IGRchar                         *start_buffer;
    IGRchar                         *buffer;
    struct  MS_sd_malloc_header     *next;
    IGRint                          total_size;
    IGRint                          remaining_memory;
};

struct MS_session_config
{
    char	config_name[16];
    struct  MS_header  *config_memory;
    struct  MS_session_config *next_session_config;
};

struct MS_list_current_config
{
    struct MS_session_config *current_config;
    struct MS_list_current_config *next_current_config;
};

#endif
