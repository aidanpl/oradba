<H1>OraSASH Supplementary material</H1> 

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

This README details supplementary material for OraSASH reporting. Please see README.md for installation instructions. 

Included here are:
<ul>
    <li>Allow access to v_$session on target database</li> 
	<li>A series of front end views</li> 
    <li>Improved script for switching target database</li> 
</ul>

<H1>Allow access to v_$session on each target</H1> 

Additional views described below link to v$session on the target database. To facilitate this two scripts are provided to create the necessary grants and synonyms.

<ul>
    <li>cr_gr_target.sql</li> 
	<li>cr_syn_repository.sql</li> 
</ul>

Usage information is provided in each script.

<H1>Additional front end views</H1> 

A series of view prefixed ASH_xxx are provided in script ash_view_vw. To load the views simply execute the script while connected to the sash user on the repository. 

Where multiple targets are in the repository the views will show data for the current active target. 

Some of the views reference v$session_target so have a dependency to this synonym being created as described above. 

<H1>Improved switching databases</H1> 

The base load provides a script switchdb.sql to switch active targets. The additional front end views provided are dependant on a synonym which requires updating when the target changes. To facilitate this a modified script 0_switch_db.sql is provided.





