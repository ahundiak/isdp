/*______________________________________________________________________
 |									|
 |	Unpublished, but if published:					|
 |	Copyright Intergraph Corporation, 1991, including software	|
 |	and its file formats, and audio-visual displays;   this is the	|
 |	property  of  Intergraph  Corporation;   All  Rights  Reserved	|
 |	May only be used pursuant to the applicable  software  license	|
 |	agreement; contains confidential and  proprietary  information	|
 |	of Intergraph and/or other third parties which is protected by	|
 |	copyright,  trade secret  and  trademark law  and  may  not be	|
 |	provided or otherwise  made  available  without  prior written	|
 |	authorization;							|
 |	Restricted Rights Legend:					|
 |	Use, duplication or disclosure by the government is subject to	|
 |	restrictions as set forth in  subdivision (b) (3) (ii)  of the	|
 |	rights  in  technical  data  and  computer software  clause at	|
 |	52.227-7013.							|
 |									|
 |	Intergraph Corporation						|
 |	One Madison Industrial Park					|
 |	Huntsville, Alabama 35807					|
 |______________________________________________________________________|
*/
/* 91May21afb - Created for Help version 08.00.00.00. */
/* 91Nov25war - Modified with latest changes          */
/* 92Jan07war - Add Help_hc                           */

/**********************************************************************/
/* Help library function declarations */
/**********************************************************************/

int Help_kill (void);
int Help_origin (int xorigin, int yorigin);
int Help_remove (void);
int Help_status (struct HP_status_struct *status_ptr);
int Help_defaults (struct HP_defaults_struct *defaults);
int Help_display (void);
int Help_toc (void);
int Help_topic (char *logical_name);
int Help_set_topic (char *topic_logical_name);
int Help_document (struct HP_doc_id_struct *doc_id);
int Help_pass_through_signal (int signal_number,  
                              void  (*data_rec_function )(), 
                              char *data_buffer,int size);
int Help_pass_through_get (char *data, int size);
int Help_set_Xdisplay (char *xdisplay_name);
int Help_active(int *status_in);
struct HP_status_struct *Help_init_status();
int Help_free_status(struct HP_status_struct *h_stat_struck);
int Help_hc(char **source_file_names,char **search_path,
            char *title_string,char *doc_id_string,
            char *compiled_file_name, unsigned int options,
            char ***messages);
