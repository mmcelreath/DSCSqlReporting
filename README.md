# DSCSqlReporting
Scripts and resources for using a SQL backend for DSC Report Servers

I’ve been looking for a good reporting solution for DSC for a while and wished there was  better database backend for the DSC Report Server in PowerShell 5, like SQL. Recently I came across the following article that describes how to set up a SQL backend for the DSC Report Server in Windows Server 2019 and Server 1803:

https://blogs.technet.microsoft.com/askpfeplat/2018/07/09/configuring-a-powershell-dsc-web-pull-server-to-use-sql-database/

And the followup about pulling reports using SQL:

https://blogs.technet.microsoft.com/askpfeplat/2018/07/23/pulling-reports-from-a-dsc-pull-server-configured-for-sql/

Those articles were a great way to get started. However, the SQL code that was shown in the second article wouldn’t work. After some digging and some help from a DBA friend, I found out that the quotes were in the wrong format. Probably from being pasted into the web page and not being converted right.

After changing all the quotation marks and a couple other things, the code works.

The files in this repo under the SQL folder will create the functions, triggers and views that are necessary to follow the article.
Now that I have all those pieces, I tried to check out the views that are described in the article. Unfortunately, the one I was interested in the most, vNodeStatusComplex, doesn’t work.

I’d be very interested if anyone has successfully implemented this solution or if you want to follow the articles and try it out to see if you can figure out the issue or at least see if we can figure it out together.
