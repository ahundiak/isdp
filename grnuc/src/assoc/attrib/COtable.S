class specification COtable (2:0) of COpara;

#define MAX_HDR_NAME 256
#define MAX_TABLE 10
#define MAX_TABLE_NAME 20

instance COtable
{
 struct GRid Temp_List[2]; 
 char hdr_name[MAX_HDR_NAME];
 variable char table_name[MAX_TABLE_NAME*MAX_TABLE];
 int nb_table;
 int selected_table;
 char *form_ptr;
};

override wakeup,execute,sleep;

message find_table();
message add_table(struct dirent *file);
message generate_hdr_name(int *name_changed);
message place_table();
message write_table();


end specification COtable;

