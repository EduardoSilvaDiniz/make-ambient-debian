upt=$(uptime | awk '{print 1}')
if [ $upt == "4" ] || ; then
  shutdown -P now
fi