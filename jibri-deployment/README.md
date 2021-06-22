# k8s-jibri
multiple jibri instances on kubernetes cluster. Here 40 jibri recording instances are maintained in 4 worker nodes.

### using *a1-statefulset.yaml* and *a2-statefulset.yaml* files for pods deployment.

* The reason to use two staeful is due to limitation of Playback Hardaware (Loopback device) of sound card.
Each node can only support maximum of 30 Loopback. By default ther is only 4 cards.
* To see all the devices,
```bash
$ aplay -l
```
* If you couldn't find any card devices, then install alsa modules or pulse audio.
* To increase the loopback cards,
```bash
$ lsmod | grep snd_aloop
$ echo 'options snd-aloop enable=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 index=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29' >> cat /etc/modprobe.d/alsa-loopback.conf
$ modprobe snd_aloop
```
*you may need to reboot the node to update the device.
