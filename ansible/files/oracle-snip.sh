#!/bin/bash

# Use this to add customized oracle parameters
# DO NOT USE this to install/config oracle/grid software

# Starting oracle work

# Determining the location, whether it's oracle and if it's rac
HOSTNAME=$(hostname -s)
#ISORA=$(echo ${HOSTNAME} | egrep -c "lxdba|lxdbas|lxora|lxoras|lxorar")
ISORA=$(echo ${HOSTNAME} | egrep -c "lxdba|lxdbas|lxora|lxoras|lxorar|lxsand")
ORATYPE=$(echo ${HOSTNAME:4:7} | tr '[:upper:]' '[:lower:]' | awk -F'lx' '{print $2}')
DGRUB7="/etc/default/grub"

# Determine if this is an oracle server.
if [ $ISORA -eq 0 ]
then
    echo "Is NOT an oracle server...skipping"
else
    echo "This is an oracle server...continuing"
    echo "Determining RHEL version..."
    if [ $(cat /etc/redhat-release | grep -ic "release 6") -eq 1 ]
    then
        echo "RHEL6..."
		echo "Starting the kernel update work..."
        echo "Determining oracle type (single or rac)..."
        if [ $(echo ${ORATYPE} | grep -wc "lxorar") -eq 1 ]
        then
            echo "Updating kernel with RAC options..."
			/sbin/grubby --update-kernel=$(/sbin/grubby --default-kernel) --args="type1=ORACLE type2=RAC hugepages=1 transparent_hugepage=never"
		else
			echo "Updating kernel with single options..."
			/sbin/grubby --update-kernel=$(/sbin/grubby --default-kernel) --args="type1=ORACLE type2=single hugepages=1 transparent_hugepage=never"
		fi
    else
        # Update the kernel with the correct options.
		echo "RHEL7..."
		echo "Starting the kernel update work..."
        echo "Determining oracle type (single or rac)..."
        if [ $(echo ${ORATYPE} | grep -wc "lxorar") -eq 1 ]
        then
            echo "Updating kernel with RAC options..."
            if [ -f $DGRUB7 ]
            then
                echo "Creating a backup copy of the $DGRUB7 file... "
                mkdir -p /etc/backup
                if [ ! -f /etc/backup/grub.$(date +%Y%m%d) ]
                then
                    cp -p $DGRUB7 /etc/backup/grub.$(date +%Y%m%d)
                fi
                echo "Appending the type1=ORACLE type2=RAC hugepages=1 transparent_hugepage=never values to the end of the GRUB_CMDLINE_LINUX parameter..."
                cd /etc/default
                sed -i '/^GRUB_CMDLINE_LINUX/s/\"$/\ type1=ORACLE type2=RAC hugepages=1 transparent_hugepage=never\"/g' grub
                echo "Regenerating the grub.cfg file..."
                grub2-mkconfig -o /boot/grub2/grub.cfg
                echo "Done updating kernel with RAC options..."
            else
                echo "Missing the $DGRUB7 file...please verify"
            fi
        else
            echo "Updating kernel with single options..."
            if [ -f $DGRUB7 ]
            then
                echo "Creating a backup copy of the $DGRUB7 file... "
                mkdir -p /etc/backup
                if [ ! -f /etc/backup/grub.$(date +%Y%m%d) ]
                then
                    cp -p $DGRUB7 /etc/backup/grub.$(date +%Y%m%d)
                fi
                echo "Appending the type1=ORACLE type2=single hugepages=1 transparent_hugepage=never values to the end of the GRUB_CMDLINE_LINUX parameter..."
                cd /etc/default
                sed -i '/^GRUB_CMDLINE_LINUX/s/\"$/\ type1=ORACLE type2=single hugepages=1 transparent_hugepage=never\"/g' grub
                echo "Regenerating the grub.cfg file..."
                grub2-mkconfig -o /boot/grub2/grub.cfg
                echo "Done updating kernel with single options..."
            else
                echo "Missing the $DGRUB7 file...please verify"
            fi
        fi
    fi
	
	# Adding the standard oracle NFS
	echo "Starting the oracle autofs work..."
	echo "Creating a backup of /etc/auto.export..."
	AUTOFS_EXPORT=auto.export
	cd /etc
	mkdir -p backup
	if [ ! -f /etc/backup/${AUTOFS_EXPORT}.$(date +%Y%m%d) ]
	then
		cp -p $AUTOFS_EXPORT /etc/backup/auto.export.$(date +%Y%m%d)
	fi
	echo "Determing if oracle_depot exist..."
	if [ $(grep -c ^oracle_depot $AUTOFS_EXPORT) -eq 1 ]
	then
		echo "Looks like oracle_depot exist...skipping"
	else
		echo "Adding oracle_depot..."
		echo "oracle -rw,soft,intr,vers=3,rsize=32768,wsize=32768,nosuid KMHPEMCFSPA21:/oracle_depot" >> $AUTOFS_EXPORT
	fi
	echo "Determing if oracle_dump exist..."
	if [ $(grep -c ^oracle_dump $AUTOFS_EXPORT) -eq 1 ]
	then
		echo "Looks like oracle_dump exist...skipping"
	else
		echo "Adding oracle_dump..."
		echo "oracle_dump -rw,bg,hard,nointr,rsize=32768,wsize=32768,tcp,actimeo=0,vers=3,timeo=600 KMHPEMCFSPA21:/oracle_dump" >> $AUTOFS_EXPORT
	fi
	echo "Done with oracle autofs work..."
	
	# Adding the oracle/grid users and needed groups locally.
	echo "Starting the add of local groups used by Oracle/Grid..."
	groupadd -g 11101 dba
	groupadd -g 54321 oinstall
	groupadd -g 54325 asmadmin
	groupadd -g 54326 asmdba
	groupadd -g 54327 asmoper
	echo "Done with adding local groups..."
	echo "Starting the add of oracle/grid users locally..."
	useradd -u 54321 -g oinstall -G "asmadmin,asmdba,asmoper,dba" -c "Oracle service account" -d /home/oracle -s /bin/bash oracle
	useradd -u 54322 -g oinstall -G "asmadmin,asmdba,asmoper,dba" -c "Grid service account" -d /home/grid -s /bin/bash grid
	echo "Done with adding oracle/grid users locally..."
	
	# Updating ownerships and permissions
	echo "Updating /home/oracle..."
	if [ -d /home/oracle ]
	then
	    chown -R oracle.oinstall /home/oracle
	    chmod 770 /home/oracle
	else
	    echo "Missing the /home/oracle filesystem..."
	fi
	echo "Done updating /home/oracle..."
	
	echo "Updating /home/grid..."
	if [ -d /home/grid ]
	then
	    chown -R grid.oinstall /home/grid
	    chmod 770 /home/grid
	else
	    echo "Missing the /home/grid folder..."
	fi
	echo "Done updating /home/grid..."
	
	echo "Updating /u01..."
	if [ -d /u01 ]
	then
	    chown -R oracle.oinstall /u01
	    chmod 770 /u01
	else
	    echo "Missing the /u01 filesystem..."
	fi
	echo "Done updating /u01..."
	
	echo "Updating /etc/sysctl.conf file..."
	SYSCTL_CONF="/etc/sysctl.conf"
	if [ ! -f $SYSCTL_CONF ]
	then
		echo "Missing the $SYSCTL_CONF file..."
	else
		echo "" >> $SYSCTL_CONF
		echo "# Oracle requirements" >> $SYSCTL_CONF
		echo "kernel.sem = 250 32000 100 128" >> $SYSCTL_CONF
		echo "fs.file-max = 6815744" >> $SYSCTL_CONF
		echo "net.ipv4.ip_local_port_range = 9000 65500" >> $SYSCTL_CONF
		echo "net.core.rmem_default = 262144" >> $SYSCTL_CONF
		echo "net.core.rmem_max = 4194304" >> $SYSCTL_CONF
		echo "net.core.wmem_default = 262144" >> $SYSCTL_CONF
		echo "net.core.wmem_max = 1048576" >> $SYSCTL_CONF
		echo "fs.aio-max-nr = 1048576" >> $SYSCTL_CONF
	fi
	echo "Done with /etc/sysctl.conf update..."
	
    SYSCONFIG_NTPD="/etc/sysconfig/ntpd"
    echo "Starting the $SYSCONFIG_NTPD file update..."
    if [ ! -f $SYSCONFIG_NTPD ]
    then
    	echo "Missing the $SYSCONFIG_NTPD file..."
    else
    	cd /etc/sysconfig
    	mkdir -p backup
    	cp -irp ntpd backup/ntpd.orig.$(date +%Y%m%d)
    	sed -i 's/^OPTIONS=.*/OPTIONS="-u ntp:ntp -p \/var\/run\/ntpd.pid"/g' ntpd
    fi
    echo "Done with the update to the $SYSCONFIG_NTPD file..."

    # not needed in the playbook
    # echo "Installing the pre-req packages..."

fi
