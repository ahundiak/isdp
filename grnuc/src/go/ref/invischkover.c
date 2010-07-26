/*
  DESCRIPTION

  This file contains the flag that is used to control the specific behaviour
  that was put into the Super_rfmgr's sleep method. The specific behaviour
  is the assumption that whenever a file is opened invisibly, as in the case
  of most PDM useages, the reference file attachements within the file are
  not awakened. Therefore, while going to sleep, these attachments should not
  be put to sleep.

  This is a bad and a hidden assumption. Code has been written where the
  file is opened invisibly and so also, it's attachments. Rather, then 
  perturb the system, a flag is being introduced that can be manipulated by
  the likes of PDM function that do open invisibly, AND open the reference
  file attachments. Such functions must SET the "override invisible check"
  flag before closing the file that was invisibly opened and then CLEAR
  the override soon after the file-close call, regardless of it's success
  or failure.


  HISTORY

  SS  :  02/22/96  :  Creation
*/

static int invis_check_override_flag=0;

void Set_invis_check_override()
{
  invis_check_override_flag = 1;
  return;
}

void Clear_invis_check_override()
{
  invis_check_override_flag = 0;
  return;
}

int Invis_check_override()
{
  return invis_check_override_flag;
}
