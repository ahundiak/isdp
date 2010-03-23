#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/fcntl.h>
#define  OBJFD    void
#define  OBJINFO  void
#include <dloadpvt.h>

#define  ERRORMSG  1
#define  READYMSG  2
#define  CMDMSG    3

struct msgstuff {
    long type;
    ADDR slotloc;
    char slot[SLOTSIZE];
};

int             proc;
int             qid;
struct msgstuff msgbuffer;


int main ()
{
  char path[14];

  /* try to become root for DBX use */

  setuid (0);

  /* open proc file */

  sprintf (path, "/debug/%.5d", getppid ());
  if (-1 == (proc = open (path, O_RDWR | O_SYNC, 0)))
    exit (1);

  /* get message queue created by parent */

  if (-1 == (qid = msgget ((key_t)getppid (), 0700)))
    exit (1);

  msgbuffer.type = READYMSG;
  while (1) {
    msgsnd (qid, (struct msgbuf *)&msgbuffer, 0, 0);
    msgrcv (qid, (struct msgbuf *)&msgbuffer, sizeof(msgbuffer), CMDMSG, 0);
    if (!msgbuffer.slotloc) {
      msgctl (qid, IPC_RMID, 0);
      return 0;
    }

    if (   (-1 != lseek (proc, msgbuffer.slotloc, 0))
        && (SLOTSIZE == write (proc, msgbuffer.slot, SLOTSIZE)) )
      msgbuffer.type = READYMSG;
    else msgbuffer.type = ERRORMSG;
  }
}
