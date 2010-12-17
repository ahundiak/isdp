/***************************************************
 * linked list definitions *
 ***************************************************/
 
#include     <sunlimits.h>

struct PDUassy_node
	{
        int                    p_level;
        int                    p_pchildno;
        int                    p_childno;
        char                  *n_catalogname;
        char                  *n_itemname;
        char                  *n_itemrev;
        char                  *p_attached;
        char                  *p_quantity;
        char                  *p_usageid;
        char                  *p_tagno;
        char                  *p_alttagno;
        char                  *p_incbom;
        char                  *p_incstr;
        char                  *p_explode;
        char                  *p_filename;
        char                  *p_history;
        int                    n_catalogno;
        int                    n_itemno;
        struct PDUassy_node   *next;
	};

struct PDUlist_parts_info
        {
        char                 *catalog_name;
        char                 *part_id;
        char                 *revision;
        char                 *usage_id;
        struct PDUlist_parts_info *next;
        };

struct PDUlist_origins_info
        {
        char                 *view_name;
        struct PDUlist_origins_info *next;
        };

struct PDUcat_node
        {
         char                 *catalog;
         int                  count;
         struct  PDUcat_node  *next;
        };

struct PDUattach_mac_node
        {
         char                        *part_cat;
         struct  PDUcat_node         *cat_list;
         struct  PDUattach_mac_node  *next;
        };

struct PDUacl_node
        {
        char		catalog[21];
        char            partid[41];
        char		revision[41];
        char		description[256];
        char		filename[15];
        char		parttype[5];
        char            aclname[21];
        char		state[41];
        char            workflow[21];
	struct  PDUacl_node *next;
        };

struct PDUref_info_node
        {
         int                       level;
         char                      refid[20];
         short                     PDUpart;
         char                      parent_id[20];
         short                     part_found;
         struct PDUref_info_node   *prev;
         struct PDUref_info_node   *next;
        };

struct PDUdisplay_list
       {
        char                      part_path[1023];
        char                      displayed[5];
        char                      ref_id[20];
        struct PDUdisplay_list    *next;
       };

struct PDUpath_list
       {
        char                      path[1023];
        struct PDUpath_list       *next;
       };
