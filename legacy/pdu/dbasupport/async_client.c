main ()
{
  char *buffer[10];
  int i, new;

  dba_setup_async_client ();
  for (i=0; i<1000; i++) {
    sprintf (buffer, "%d", i);
    dba_send_to_dba (buffer, 10);
    dba_receive_from_dba (buffer, 10);
    sscanf (buffer, "%d", &new);
    printf ("%d %d\n", i+1, new);
  }
}
