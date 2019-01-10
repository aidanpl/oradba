<H1>Oracle DBA creation, maintenance, reporting and troubleshooting scripts</H1>

Copyright (c) 2019 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

Having worked as an Oracle DBA since the mid-1990s I have accumulated numerous example scripts for db creation, health checks, package installation, troubleshooting etc. I have brought them together into this gitlab repository to support my DBA training courses and make them available for the wider community to use as they desire. 

As of Sep 2017 many are used 'in anger' in production against  Oracle 11.2 databases and have been unit tested for basic functionality against a sample Oracle 12.2 installation. 

To re-emphasise the generic copyright and "as is" comments above I strongly recommend you test any of this functionality before using in a production environment. Oracle continually introduces new functionality, tweaks parameters from release to release. Your environment may have different options installed, run on a different flavour of Linux or Windows which could give unexpected results. However even with that warning in place, most functionality here has worked with only minor tweaks since at least Oracle 9 and on both Linux and Windows environments. 

I hope you find these useful and I welcome feedback.

<H1>Areas Covered</H1>

<ul>
<li>Software Installation</li> 
<li>Database Creation</li> 
<li>Example Reporting/Repository Database for long term trends</li> 
<li>Non Admin Monitoring User creation</li> 
<li>Data Dictionary bespoke views by functional area</li> 
<li>DDL Generation for bulk management</li> 
<li>Oracle Package examples</li>
<li>OS Reporting/Management</li> 
</ul>

