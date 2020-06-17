 __  __ _____   _ 
|  \/  |_   _| / \ 
| |\/| | | |  / _ \
| |  | | | | / ___ \ 
|_|  |_| |_|/_/   \_\  
                                 

Migration Toolkit for Applications by Red Hat (MTA) ${project.version} is an extensible and customizable rule-based tool that helps simplify migration of Java applications.

MTA examines application artifacts, including project source directories and applications archives, 
then produces an HTML report highlighting areas that need changes. 

MTA can be used to migrate Java applications from previous versions of Red Hat JBoss Enterprise Application Platform 
or from other containers, such as Oracle WebLogic Server or IBM WebSphere Application Server.


How Does MTA Simplify Migration?
-------------------------------------
    MTA looks for common resources and highlights technologies and known “trouble spots” when migrating applications. 
    The goal is to provide a high level view into the technologies used by the application and provide a detailed report organizations can use to estimate, 
    document, and migrate enterprise applications to Java EE and JBoss EAP.


Run MTA
---------------
    Open a terminal and navigate to the MTA_HOME directory.

    Run MTA against the application using the appropriate command.
    
        For Linux:
        
        $ bin/mta-cli --input INPUT_ARCHIVE_OR_DIRECTORY --output OUTPUT_REPORT_DIRECTORY \
           --source SOURCE_TECHNOLOGY --target TARGET_TECHNOLOGY --packages PACKAGE_1 PACKAGE_2 PACKAGE_N
           
        For Windows:
        
        > bin\mta-cli.bat --input INPUT_ARCHIVE_OR_DIRECTORY --output OUTPUT_REPORT_DIRECTORY
            --source SOURCE_TECHNOLOGY --target TARGET_TECHNOLOGY --packages PACKAGE_1 PACKAGE_2 PACKAGE_N

    Getting more detailed help on possible arguments and options for command line

        For Linux:
        $ bin/mta-cli --help

        For Windows:
        > bin\mta-cli.bat --help
        
        
Get more resources
---------------------
    User Guide is available at https://access.redhat.com/documentation/en/red-hat-jboss-migration-toolkit
    MTA Wiki - https://github.com/windup/windup/wiki 
    MTA Forum for users - https://community.jboss.org/en/windup
    MTA JIRA issue trackers
        MTA core: https://issues.jboss.org/browse/WINDUP
        MTA Rules: https://issues.jboss.org/browse/WINDUPRULE
    MTA users mailing List: windup-users@lists.jboss.org
    MTA on Twitter: @JBossWindup (https://twitter.com/jbosswindup)
    MTA IRC channel: Server FreeNode (irc.freenode.net), channel #windup
