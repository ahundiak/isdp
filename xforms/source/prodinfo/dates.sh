dates ACC \
      COMPILSUP \
      COMPTOOLS \
      FONTSERVE \
      INGRUTIL \
      I_LICENSE \
      I_MGUI \
      LIBXC \
      MGUI \
      RESOURCES \
      SYSTEMV \
      SUNCC \
      UMS \
      UNIXBOOT \
      XWINDOW \
      XWINPROG |
  cut -c1-18,20-73 |
  sed 's/^/  /'

echo
dates BAGTOOLS |
  cut -c1-18,20-73 |
  sed 's/^/  /'
