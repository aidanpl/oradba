<H1>Directory for various data dictionary views</H1>
Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Introduction</H1>

This directory holds scripts containing queries against the data dictionary stored as views. There is generally one script for each area of functionality.

Storing as views rather than scripts allows the queries to be referenced from either sql*plus scripts in batch, SQL*Developer GUI or indeed any preferred front end client. Views are created with a specific prefix related to a subject area to make them easier to document and use.

For example security views are stored under security_vw.sql and are named sec_1_xxx, sec_2_yyy etc.  


<H1>Pre-requisites</H1> 

The views are designed to be created against a generic non-sysdba monitoring user - e.g. DBMON. 

<H1>Implementation</H1>  

<H2>Individual scripts</H2>  

When creating a view the schema requires a direct grant against underlying objects. Each script includes the required grants in the comments at the beginning of the scripts.

e.g. for instance_ck.sql the required grants are 

<code>
GRANT SELECT ON v_$instance TO dbmon;
GRANT SELECT ON v_$database TO dbmon;
GRANT SELECT ON v_$license  TO dbmon; 
</code>

The required GRANTS will typically require SYSDBA access. 

For individual scripts run the required GRANTS as SYSDBA then execute the script under the working schema (i.e. dbmon)

<H2>Batch/New Database setup</H2>

When creating a new database and DBMON user it is useful to be able to create all of the views in one batch run. To facilitate this two scripts are provided:

<ul>
	<li>1_dbmon_view_grants.sql - all required grants - execute as SYSDBA</li>
	<li>2_create_views.sql - driving script for all views - execute as DBMON</li>
</ul>	

<H1>References</H1>

Views against certain extra functionality are documented in those areas. Specifically:

<ul>
	<li>Views for capacity planning on managed under 0_dbmon_user\capacity\target</li>
	<li>Views for RMAN Catalog reporting capacity planning on managed under 0_dbarep\2_rman_reporting</li>
</ul>