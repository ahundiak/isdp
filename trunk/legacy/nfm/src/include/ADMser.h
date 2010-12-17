#define  ON         1
#define  OFF        0
#define  DISCARD    999
#define  CLIENT     0
#define  SERVER     1


struct ps_buffer {
                        char *node,
                             *date,
                             *time;
                        int  pid;
                        int  spid;
                        char *path;
                        int  connect;
                 };
