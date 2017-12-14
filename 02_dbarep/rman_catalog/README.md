<H1>RMAN Catalog Creation</H1>
Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>1. Introduction

Notes on creating the RMAN catalog 

<H1>2. Pre-requisites 

An existing database where the catalog can be restored. This must be of a version at least as recent as the most recent database that will link to it. In essence when working with a series of databases the repository catalog is normally the first to be upgraded. 

<H1>3. Implementation  

Two stages - first create the RMAN schema, then create the catalog within the schema

<ul>
<li>sql*plus Connect to sys/xxx@<catalog database> as sysdba</li> 
<li>Examine then build_rman_catalog.sql changing passwords etc. as preferred </li> 
<li>rman <rman_schema>/<rman_pw>@<catalog database></li>
<li>execute CREATE CATALOG TABLESPACE <rman_tbsp>
</ul>

