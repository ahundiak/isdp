/*  ALR   8/30/93   Structure for holding part information used for retrieving
    dynamic parts during part placement. Allows for cashing of part information
    so that the database does not need to be queried for each occurrence of a 
    part.
*/

struct part_dynamic_attrs
{
  char catalog[20];
  char part[15];
  char revision[15];
  char p_explode[2];
  MEMptr attr_buff; 
  MEMptr data_buff;
  MEMptr list_buff;
  struct part_dynamic_attrs *next;
};
