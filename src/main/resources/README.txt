 ____  _   _    _    __  __ _____ 
|  _ \| | | |  / \  |  \/  |_   _|
| |_) | |_| | / _ \ | |\/| | | |  
|  _ <|  _  |/ ___ \| |  | | | |  
|_| \_\_| |_/_/   \_\_|  |_| |_|  
                                 

Red Hat Application Migration Toolkit (RHAMT) ${project.version} is an extensible and customizable rule-based tool that helps simplify migration of Java applications.

RHAMT examines application artifacts, including project source directories and applications archives, 
then produces an HTML report highlighting areas that need changes. 

RHAMT can be used to migrate Java applications from previous versions of Red Hat JBoss Enterprise Application Platform 
or from other containers, such as Oracle WebLogic Server or IBM WebSphere Application Server.


How Does RHAMT Simplify Migration?
-------------------------------------
    RHAMT looks for common resources and highlights technologies and known “trouble spots” when migrating applications. 
    The goal is to provide a high level view into the technologies used by the application and provide a detailed report organizations can use to estimate, 
    document, and migrate enterprise applications to Java EE and JBoss EAP.


Run RHAMT
---------------
    Open a terminal and navigate to the RHAMT_HOME directory.

    Run RHAMT against the application using the appropriate command.
    
        For Linux:
        
        $ bin/rhamt-cli --input INPUT_ARCHIVE_OR_DIRECTORY --output OUTPUT_REPORT_DIRECTORY \
           --source SOURCE_TECHNOLOGY --target TARGET_TECHNOLOGY --packages PACKAGE_1 PACKAGE_2 PACKAGE_N
           
        For Windows:
        
        > bin\rhamt-cli.bat --input INPUT_ARCHIVE_OR_DIRECTORY --output OUTPUT_REPORT_DIRECTORY
            --source SOURCE_TECHNOLOGY --target TARGET_TECHNOLOGY --packages PACKAGE_1 PACKAGE_2 PACKAGE_N

    Getting more detailed help on possible arguments and options for command line

        For Linux:
        $ bin/rhamt-cli --help

        For Windows:
        > bin\rhamt-cli.bat --help
        
        
Get more resources
---------------------
    User Guide is available at https://access.redhat.com/documentation/en/red-hat-jboss-migration-toolkit
    RHAMT Wiki - https://github.com/windup/windup/wiki 
    RHAMT Forum for users - https://community.jboss.org/en/windup
    RHAMT JIRA issue trackers
        RHAMT core: https://issues.jboss.org/browse/WINDUP
        RHAMT Rules: https://issues.jboss.org/browse/WINDUPRULE
    RHAMT users mailing List: windup-users@lists.jboss.org
    RHAMT on Twitter: @JBossWindup (https://twitter.com/jbosswindup)
    RHAMT IRC channel: Server FreeNode (irc.freenode.net), channel #windup
