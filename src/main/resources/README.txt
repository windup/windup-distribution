 __  __ _____   _ 
|  \/  |_   _| / \ 
| |\/| | | |  / _ \
| |  | | | | / ___ \ 
|_|  |_| |_|/_/   \_\  
                                 

Windup ${project.version} is an extensible and customizable rule-based tool that helps simplify migration of Java applications.

Windup examines application artifacts, including project source directories and applications archives, 
then produces an HTML report highlighting areas that need changes. 

Windup can be used to migrate Java applications from previous versions of Red Hat JBoss Enterprise Application Platform 
or from other containers, such as Oracle WebLogic Server or IBM WebSphere Application Server.


How Does Windup Simplify Migration?
-------------------------------------
    Windup looks for common resources and highlights technologies and known “trouble spots” when migrating applications. 
    The goal is to provide a high level view into the technologies used by the application and provide a detailed report organizations can use to estimate, 
    document, and migrate enterprise applications to Java EE and JBoss EAP.


Run Windup
---------------
    Open a terminal and navigate to the WINDUP_HOME directory.

    Run Windup against the application using the appropriate command.
    
        For Linux:
        
        $ bin/windup-cli --input INPUT_ARCHIVE_OR_DIRECTORY --output OUTPUT_REPORT_DIRECTORY \
           --source SOURCE_TECHNOLOGY --target TARGET_TECHNOLOGY --packages PACKAGE_1 PACKAGE_2 PACKAGE_N
           
        For Windows:
        
        > bin\windup-cli.bat --input INPUT_ARCHIVE_OR_DIRECTORY --output OUTPUT_REPORT_DIRECTORY
            --source SOURCE_TECHNOLOGY --target TARGET_TECHNOLOGY --packages PACKAGE_1 PACKAGE_2 PACKAGE_N

    Getting more detailed help on possible arguments and options for command line

        For Linux:
        $ bin/windup-cli --help

        For Windows:
        > bin\windup-cli.bat --help
        
        
Get more resources
---------------------
    User Guide is available at https://windup.github.io/
    Windup Wiki - https://github.com/windup/windup/wiki
    Windup Forum for users - https://community.jboss.org/en/windup
    Windup JIRA issue trackers
        Windup core: https://issues.jboss.org/browse/WINDUP
        Windup Rules: https://issues.jboss.org/browse/WINDUPRULE
    Windup users mailing List: windup-users@lists.jboss.org
    Windup on Twitter: @JBossWindup (https://twitter.com/jbosswindup)
