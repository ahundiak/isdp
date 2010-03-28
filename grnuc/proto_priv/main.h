#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/query/parser/main.c */
extern int main __((int argc, char *argv[]));
extern int query __((char *op1, int oper, char *op2));

#if defined(__cplusplus)
}
#endif


#undef __
