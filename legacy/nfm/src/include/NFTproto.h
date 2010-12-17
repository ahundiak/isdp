
/* NFT API */

long NFT_init(char *node, char *path);
long NFT_index_file(long cno, long ino, long fno, char *file, long type,
                    char *keywords);
long NFT_get_keywords(long cno, long ino, long fno, char **keywords);
long NFT_delete_entry(long cno, long ino, long fno);
long NFT_delete_item(long cno, long ino);
long NFT_delete_collection(long cno);
long NFT_get_word_wheel(char *clist, char *start, long count, char **words);
long NFT_get_preview(char *clist, char *search, char **result);
long NFT_ftr_search(long cno, char *search, char **inos, char **fnos);
long NFT_gen_highlight(long cno,char *search,long ino,long fno,char **buffer);
long NFT_get_thesaurus_list(char *list);



/* Internal use only */

long NFT_prepare_collection(long cno, long flag);
long NFT_setup_search(char *search, char **qry);
long NFT_get_cid(char *col, long ino, long fno, long *cid);
long NFT_get_cid_list(char *col, char *search, char **list);
