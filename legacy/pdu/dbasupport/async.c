#include <stdio.h>
#include <signal.h>
#include <errno.h>

static int dba_pid;
static long dba_qid;

struct buftype {
  long key;
  long own;
  char data[1];
};

void alarmhandle ()
{
  kill (dba_pid, SIGUSR2);
  alarm(1);
}  

int dba_setup_async_client ()
{
  char *tmpdir, *getenv(), *filename;
  FILE *fp;

  tmpdir = getenv("TMPDIR");
  if (tmpdir) {
    filename = (char *) malloc (strlen(tmpdir) + 9);
    sprintf (filename, "%s/dba.pid", tmpdir);
    fp = fopen (filename, "r");
    free (filename);
  }
  else
    fp = fopen ("/usr/tmp/dba.pid", "r");
  if (fp) {
    fscanf (fp, "%d", &dba_pid);
    fclose (fp);
    dba_qid = msgget (121365, 0666);
    if (dba_qid == -1) {
      fprintf (stderr, "Error in msgget\n");
      return -1;
    }
    sigset (SIGALRM, (void (*)()) alarmhandle);
    return 0;
  }
  else
  {
    fprintf (stderr, "Cannot open dba.pid file.\n");
    fprintf (stderr,
        "Is DB Access running with DBA_ASYNC_SCRIPT exported?\n");
    fprintf (stderr, "Is TMPDIR set to something different for DBA?\n\n");
    return -1;
  }
}

int dba_send_to_dba (buffer, size)
void *buffer;
int size;
{
  int status;
  char *buf;

  buf = (char *) malloc (size + sizeof(long)*2);
  if (!buf)
    return -1;
  memcpy (((struct buftype *)buf)->data, buffer, size);
  ((struct buftype *)buf)->key = 1;
  ((struct buftype *)buf)->own = getpid();
  status = msgsnd (dba_qid, buf, size+sizeof(long), 0);
  kill (dba_pid, SIGUSR2);
  free (buf);
  return status;
}

int dba_receive_from_dba (buffer, size)
void *buffer;
int size;
{
  char *buf;
  int status;

  buf = (char *) malloc (size + sizeof(long)*2);
  if (!buf)
    return -1;
  alarm (1);
  do
    status = msgrcv (dba_qid, buf, size + sizeof(long), getpid(), 0);
  while (status == -1 && errno == EINTR);
  alarm (0);
  if (status == -1) {
    free (buf);
    return 0;
  }
  memcpy (buffer, ((struct buftype *)buf)->data, size);
  free (buf);
  return status;
}
