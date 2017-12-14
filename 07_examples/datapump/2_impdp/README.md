<H1>Datapump Import examples</H1> 

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A series of example datapump parameter files for various levels of import. 
Three additional files are provided:

<ul>
<li>dp_directories_and_privs.sql Example Directory creation pre requisites</li>
<li>impdp_general.sh             Standard bash front end script for executing expdp</li>
<li>impdp_help_equals_yes.txt    Simple output from expdp help=y for reference</li> 
</ul>

<H1>General Usage</H1>

As a general comment, many of the impdp parameters work the same as expdp with a few specific differences, particularly the various REMAP_xxx options to allow schemas, tables, tablespaces, datafiles to be renamed on import. 

In practice when exporting/importing data or objects around any restrictions are placed in the export. For a one off copy there is no point exporting things you aren't going to import. As such the export parameter file will typically have the limitation by schema, table or whatever and the import will then just import the whole of that export file, with remaps as needed. The exception to the above is where export is used as part of a backup strategy producing a full export - more likely in dev/test systems than large production ones. In that scenario using the restrictions in the import makes sense when needing to restore/import just a part of data 




 
