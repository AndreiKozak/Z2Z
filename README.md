# Z2Z (Zimbra2Zimbra Migration Tool) - _Version 1.0.2_ - Maintained by BKTECH <http://www.bktech.com.br>
 
# Copyright (C) 2016-2024  Fabio Soares Schmidt <fabio@respirandolinux.com.br>

# DISTRIBUTED UNDER THE CREATIVE COMMONS LICENSE: Attribution-NonCommercial-ShareAlike (CC BY-NC-SA)

This license allows others to remix, adapt, and build upon the original work for non-commercial purposes, as long as they give
appropriate credit to the CREATOR (original banner and Copyright), and license the new creations under the SAME terms. This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.
 
#################################################################################################################################
 
# Contact:
 
 Site: <http://www.bktech.com.br>
 E-mail: <z2z@bktech.com.br>
 
 Developer: Fabio Soares Schmidt <fabio@respirandolinux.com.br> or <https://respirandolinux.com.br>

#################################################################################################################################
										
[README - v1.0.2]

												
# CHANGELOG:

 (PLEASE READ THE CHANGELOG FILE)

# INSTALLATION
 
 (PLEASE READ THE INSTALL FILE)
 
# USAGE
 
 (PLEASE READ THE INSTALL FILE)
  
# Z2Z

This tool was created to facilitate the migration process between Zimbra environments, regardless of the version
or edition being **used**. Motivated by the challenges encountered in migrations carried out by BKTECH (official Zimbra partner for business and training), as well as participation in Zimbra communities, the tool aims, throughout its evolution, to meet the most diverse scenarios, also including the migration from other platforms, both open source and proprietary - "A2Z: Anything/Anywhere to Zimbra".

**In cases of Upgrade, i.e., migrating TO a newer version of Zimbra. It is not guaranteed to work in downgrade cases.**

# WHAT WILL BE MIGRATED?

Although Zimbra is a very advanced tool in terms of migration utilities, the tool speeds up and simplifies the process, exporting:

**(Allowing the server name to be renamed during export)**.

[x] Service classes

[x] Accounts - Preserving passwords, if using internal authentication

[x] Alternate names

[x] Distribution lists

[x] Mailboxes (emails, calendars, tasks, contacts, briefcase, preferences, etc...)

In this first version, Z2Z facilitates the process of exporting the mentioned entries, as well as creating the batch of accounts to be exported, using the native command - zmmailbox. **Domains must be created before importing.**

![alt tag](https://respirandolinux.files.wordpress.com/2017/02/zimbrazimbratmp333z2z-master.jpg)

# TESTIMONIALS

"We recently used the **Z2Z** tool to support the migration of 2400 accounts at the Regional Labor Court of the 13th Region. Such a tool was very useful because we were on a very old version of Zimbra which prevented the update via script. The migration occurred incrementally due to the number of accounts until the switch. Everything went as expected and today we are using the most current version of Zimbra." - Filipe A. Motta Braga - Regional Labor Court of the 13th Region - Paraíba

"I would like to congratulate you on the excellent z2z tool, it helped me a lot in a migration from Zimbra 8.0.7 to 8.7.11
Big hug!" - Marco Brandão - Plus Informática - Minas Gerais

"Congratulations on this excellent tool, it would be impossible to migrate our company's old server without the help of your project. The import was perfect, almost 160 accounts with over 700GB of data, no failures and fast, stable environment after import." - Alisson S. Conde - Paranatex Têxtil LTDA IT Team - Paraná

"I used Z2Z to migrate two Zimbra servers (8.8.11 > 8.8.12). My experience with the tool was the best possible, everything went as expected, without any errors. Some time ago, I had to do the same job, as I didn't know the tool yet, we tried it through Zimbra itself, but we had many errors with mailboxes over 2GB, so we did it by other methods. This cost us almost 3 days of work. With Z2Z, we were able to do the same job in just one day and without any headaches. Thanks, Fábio for the excellent work." - Fernando Lima, Gobah! Soluções em TI - Goiás.

# ROADMAP
 
In future versions, the tool aims to address scenarios with Multi-Server environments involving the replacement of mailbox server hostnames, as well as exporting the main Zimbra environment settings.

It is also in the evolution plan of the tool to handle different migration strategies, allowing gradual migrations, for example, through incremental export and import processes.
 
**ANY evaluation and contribution _(coding, testing, criticisms, suggestions)_ is very welcome!**
 
Thank you in advance for your attention.
