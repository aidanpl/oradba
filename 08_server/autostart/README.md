<H1>Start/Stop Scripts</H1>

Copyright (c) 2018 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

These scripts provide a way to stop/start Oracle on simple, standalone servers. The Oracle provided dbstart and dbshut scripts date back into very old version of Oracle. As Oracle rolled out things like RAC, ASM, Dataguard and grid infrastructure they moved away from these scripts and encouraged users to use an 'Oracle Restart' product. As of Oracle 12.2 this product was initially deprecated and then reinstated as of Jul 2017. 

The Oracle Restart functionality is appropriate where there are many dependencies between instances. However for environments not using RAC, ASM, Dataguard or similar (i.e. probably 90% of existing implementations), dbstart and dbshut are reasonable. 

<H2>Implementation</H2>

<ol>
<li>Copy the ora_startstop to /etc/init.d as user root with permissions 755 </li>
<li>Edit ora_startstop for the hardcoded ORACLE_HOME.</li>
<li>Review the values of chkconfig to ensure you are happy with the run levels </li>
<li>Use chkconfig functionality to add the startup links</li> 
	chkconfig --add ora_startstop 
<li>Check that the scripts have been added:</li>

[root@db01 rc.d]# find /etc -name '*ora_start*' -exec ls -l {} \; |sort
lrwxrwxrwx. 1 root root 26 Feb 26 10:29 /etc/rc.d/rc0.d/K90ora_startstop -> ../init.d/ora_startstop
lrwxrwxrwx. 1 root root 26 Feb 26 10:29 /etc/rc.d/rc1.d/K90ora_startstop -> ../init.d/ora_startstop
lrwxrwxrwx. 1 root root 26 Feb 26 10:29 /etc/rc.d/rc2.d/S90ora_startstop -> ../init.d/ora_startstop
lrwxrwxrwx. 1 root root 26 Feb 26 10:29 /etc/rc.d/rc3.d/S90ora_startstop -> ../init.d/ora_startstop
lrwxrwxrwx. 1 root root 26 Feb 26 10:29 /etc/rc.d/rc4.d/S90ora_startstop -> ../init.d/ora_startstop
lrwxrwxrwx. 1 root root 26 Feb 26 10:29 /etc/rc.d/rc5.d/S90ora_startstop -> ../init.d/ora_startstop
lrwxrwxrwx. 1 root root 26 Feb 26 10:29 /etc/rc.d/rc6.d/K90ora_startstop -> ../init.d/ora_startstop
-rwxr-xr-x. 1 root root 2365 Feb 26 10:29 /etc/rc.d/init.d/ora_startstop

<li>Test....</li>
</ol>
