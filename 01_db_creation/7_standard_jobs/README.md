<H1>Standard Database Jobs</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A list of standard maintenance jobs installed on all/most databases

<H1>Individual jobs</H1>

<H2>Recyclebin management</H2>

Job to execute PURGE DBA_RECYCLEBIN on a periodic basis. To implement connect as SYSDBA privileges: 

<ol>
<li>Execute 0_sys_purge_recyclebin_proc.sql to create the purge_dba_recyclebin procedure</li> 
<li>Adjust the Schedule in 1_sys_purge_recyclebin_schedule.sql to your preference and execute the script to create the schedule</li> 
<li>Execute 2_sys_purge_recyclebin_job.sql to create the job</li> 
<li>Execute 3_sys_purge_recyclebin_one_off_run_job to test the job</li> 
</ol>

