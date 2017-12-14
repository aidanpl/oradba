<H1>Scripts for capturing and reporting on audit trail information</H1> 

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Introduction</H1>

Oracle captures audit records in the SYS.AUD$ table and provides some DBA_AUDIT_xxx views upon this. This series of tables, packages, views and jobs collates and manages this audit trail under the standard monitoring DBMON user. 

<H1>Pre-requisites</H1> 

None. 

<H1>Implementation</H1>  

As DBA account 

<ol>
  <li>101_audit_permissions.sql - Required permissions on DBA views and specifically delete permissions on audit trail 
  <li>102_audit_examples.sql    - Some examples for actually setting up auditing. Only run this if this is what you really want on you db. 
</ol>

As the DBMON user 

<ol>
  <li>201_audit_stats_cre.sql                - table definition for AUDIT_STATS</li>
  <li>202_cr_pkg_audit_stats_target_spec.pks - package pkg_audit_stats_target specification</li>
  <li>203_cr_pkg_audit_stats_target_body.pkb - package pkg_audit_stats_target body</li>
  <li>204_run_pkg_audit_stats_target.sql     - one off run of audit_stats_target</li>
  <li>205_security_audit_vw.sql              - Audit view specifically against AUDIT_STATS (For other AUD_xxx views see 0_views)</li> 
</ol>

To schedule regular population of AUDIT_STATS:
<ol>
  <li>211_audit_stats_dbarep_schedule.sql - Schedule for population of AUDIT_STATS (Edit schedule to personal preferences)</li>
  <li>212_audit_stats_dbarep_job.sql      - Job definition for population of AUDIT_STATS</li>
  <li>213_audit_stats_dbarep_one_off_job.sql  - One off execution of for population of AUDIT_STATS for testing </li>
</ol>

For batch reporting 

<ol>
  <li>301_audit_stats_report_ck.sql - batch reporting 
</ol>

<H1>Further development</H1>
<p>
AUDIT_STATS was developed subsequent to TBSP_STATS. Code could be expanded to allow this to be collated in a repository database in the same manner as TBSP_STATS when monitoring multiple systems. 
</p>
