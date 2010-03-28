#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/symb_mac/ACmodeli.I */
extern int ACScmp_attr __((struct ACrg_coll *attr1, struct ACrg_coll *attr2));

#if defined(__cplusplus)
}
#endif


#undef __
