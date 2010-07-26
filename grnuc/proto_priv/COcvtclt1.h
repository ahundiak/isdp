#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/COcvtclt1.C */
extern char *add_mem __((char *mem_ptr, int allocate, int size_bytes));
extern int add_to_buf __((char *name, int oid));
extern int rem_from_buf __((char *name));
extern int find_from_buf __((char *name, int *num, int *oid));

#if defined(__cplusplus)
}
#endif


#undef __
